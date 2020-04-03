# frozen_string_literal: true

class CoronavirusForm::SupportAddressController < ApplicationController
  REQUIRED_FIELDS = %i[
      building_and_street_line_1
      town_city
      postcode
  ].freeze

  def submit
    session[:support_address] ||= {}
    session[:support_address][:building_and_street_line_1] = strip_tags(params[:building_and_street_line_1]&.strip).presence
    session[:support_address][:building_and_street_line_2] = strip_tags(params[:building_and_street_line_2]&.strip).presence
    session[:support_address][:town_city] = strip_tags(params[:town_city]&.strip).presence
    session[:support_address][:county] = strip_tags(params[:county]&.strip).presence
    session[:support_address][:postcode] = strip_tags(params[:postcode]&.strip).presence

    invalid_fields = validate_fields(session[:support_address])

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)

      respond_to do |format|
        format.html { render controller_path, status: :unprocessable_entity }
      end
    elsif session[:check_answers_seen]
      redirect_to check_your_answers_url
    else
      redirect_to contact_details_url
    end
  end

private

  def validate_fields(support_address)
    [
      validate_missing_fields(support_address),
      validate_postcode("postcode", support_address.dig(:postcode)),
    ].flatten.uniq
  end

  def validate_missing_fields(product)
    REQUIRED_FIELDS.each_with_object([]) do |field, invalid_fields|
      next if product.dig(field).present?

      invalid_fields << {
        field: field.to_s,
        text: t("coronavirus_form.questions.#{controller_name}.#{field}.custom_error",
                default: t("coronavirus_form.errors.missing_mandatory_text_field",
                           field: t("coronavirus_form.questions.#{controller_name}.#{field}.label")).humanize),
      }
    end
  end

  def previous_path
    date_of_birth_path
  end
end
