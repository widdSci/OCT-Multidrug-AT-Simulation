function multisimRun_24_0611_jointWithSwitchOldGamma_heatmapSave(uMax, kR)
tic
%FIGURE 1 FROM ELSA BOTH CONTROLS EMAIL
%goal: compare ratio of growth rates vs. ratio of concentrations @
%different values of x(2)naught/x(3)naught

%population params that are staying the same

%equation parameters
        %drug effect -- rn osimertinib and afatinib
        alphaA = 0.06; %0.06; nM/hr
        alphaB = 0.06; %0.06; nM/hr
    %population growth rate
        lambda_n = 0.031; %0.031; %only EGFR+
        baseJointLambda = 0.028; %0.022; %EGFR+/C797S
        lambda_d = 0.011; %0.011; %EGFR/T790M/C797S
        %no current difference between EGFR+ from L858R and ex19del
    %carrying capacity + population parameters
        kappa = 40000; %actual carrying capacity of cell culture // 40k 96MW
        thresholdRatio = kR;
        kappa_threshold = thresholdRatio.*kappa; %3500000; %goal capacity
    %drug limits
        uMaxA = uMax; %nM
        uMaxB = uMax; %nM
    %time parameters
        cellTime = 3000; %number of timesteps eqns are running for (in hours?)
    %initial conditions
        naivePopIC = 0.685.*kappa_threshold; 
        jointMutPopIC = 0.3.*kappa_threshold; 
        doubleMutPopIC = 0.015.*kappa_threshold;

    %ratios for looping through
        ratio_2naught_3naught = [0.1, 0.2, 0.5, 1, 2, 5, 10];
        ratio_concA_concB = [0.1, 0.2, 0.5, 1, 2, 5, 10]; %Cb/Ca
        ratio_growthRates = [0.5, 0.75, 0.9, 1, 1.1111, 1.33333, 2];
    
    folderName = sprintf("/Users/aftonwiddershins/Desktop/stuff/stuff/academic/phd/thesis/Mirror/thesis data/model data/double boundary shape exploration/2024_0611_jointSwitch_heatmapSave/umax_%s_thresh_%s/", num2str(uMax), num2str(kR));
    
    vectorName = sprintf("%sVectorRange.mat", folderName);
    save(vectorName, "ratio_2naught_3naught", "ratio_concA_concB", "ratio_growthRates");

    %run heatmap loops
    for i=1:length(ratio_2naught_3naught)  
        heatmapVals = zeros(length(ratio_growthRates), length(ratio_concA_concB));
        for j=1:length(ratio_growthRates)
            for k=1:length(ratio_concA_concB)
                %establish population
                popHold = jointMutPopIC./(1+(ratio_2naught_3naught(i)));
                initCondA = popHold;
                initCondB =(ratio_2naught_3naught(i)).*popHold;

                %establish growthRate
                gammaA = baseJointLambda;
                gammaB = ratio_growthRates(j).*baseJointLambda;

                fileName = sprintf("individualGraphs/test_x2x3ratio_%s_gammaAgammaBratio_%s_concAconcBratio_%s", num2str(ratio_2naught_3naught(i)), num2str(ratio_growthRates(j)), num2str(ratio_concA_concB(k)));
                populationFileName = sprintf("%sindividualGraphs/population_x2x3ratio_%s_gammaAgammaBratio_%s_concAconcBratio_%s.mat", folderName, num2str(ratio_2naught_3naught(i)), num2str(ratio_growthRates(j)), num2str(ratio_concA_concB(k)));
                popStruct = fullEditPopulationParametersWithDrugLimits(alphaA, alphaB, lambda_n, gammaA, gammaB, lambda_d, kappa, kappa_threshold, 3000, naivePopIC, initCondA, initCondB, doubleMutPopIC, uMaxA, uMaxB);
                save(populationFileName, "popStruct");
                
                [failureTime4, failureTime5] = jointDoubleBoundaryRun_constantProportionControlswithSwitchtry2(folderName,fileName,popStruct, ratio_concA_concB(k));
                idealTime = calculateIdealFromPopStruct(popStruct);
                normedTime = failureTime5./idealTime;

                %heatmaps
                heatmapVals(j,k) = normedTime;
            end
        end
        heatmapFile = sprintf("%sindividualHeatmaps/test_x2x3ratio_%s.mat", folderName, num2str(ratio_2naught_3naught(i)));
        save(heatmapFile, "heatmapVals");
    end
    toc
end
