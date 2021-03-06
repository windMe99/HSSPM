class Fep::HumenController < ApplicationController
  authorize_resource :class => :fep

  layout 'fep'

  require 'csv'

  def index
    @cohort = Cohort.find_by name: 'FEP'
    @subject_all = @cohort.humen.order('accession')
    
    @filterrific = initialize_filterrific(
      @subject_all,
      params[:filterrific],
      :select_options => {
        with_status: Status.options_for_select,
        with_population: Population.options_for_select,
        with_gender: Gender.options_for_select,
        with_race: Race.options_for_select
      }
    ) or return
    @subjects = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=FEP_subjects.csv"
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def show
    @human = Human.find(params[:id])
  end

  def search_results
    @ops = ['Status', 'ID', 'Gender', 'Race', 'Population', 'Note']
    @key = params['key']
    @value = params['value']

    if params['key'] == 'Status'
      @subjects = Human.joins(:cohorts, :status).where("cohorts.name LIKE 'FEP' AND statuses.name LIKE ?", "%%#{params['value']}%%")
    elsif params['key'] == 'ID'
      @subjects = Human.joins(:cohorts).where("cohorts.name LIKE 'FEP' AND (accession LIKE ? OR other_ids LIKE ?)", "%%#{params['value']}%%", "%%#{params['value']}%%")
    elsif params['key'] == 'Gender'
      @subjects = Human.joins(:gender, :cohorts).where("cohorts.name LIKE 'FEP' AND genders.name LIKE ?", "%%#{params['value']}%%")
    elsif params['key'] == 'Race'
      @subjects = Human.joins(:races, :cohorts).where("cohorts.name LIKE 'FEP' AND races.name LIKE ?", "%%#{params['value']}%%")
    elsif params['key'] == 'Population'
      @subjects = Human.joins(:population, :cohorts).where("cohorts.name LIKE 'FEP' AND populations.name LIKE ?", "%%#{params['value']}%%")
    else
      @subjects = Human.joins(:cohorts).where("cohorts.name LIKE 'FEP' AND note LIKE ?", "%%#{params['value']}%%")
    end

    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=FEP_subject_search_results.csv"
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

end
