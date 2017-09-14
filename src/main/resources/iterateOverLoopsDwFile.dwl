%dw 1.0
%output application/json
%var noOfEligibleSubscribers = (sizeOf payload.cmeResponse.eligibilityList.eligibilityInfo) -1 default 0
---
flatten payload.cmeResponse.eligibilityList.eligibilityInfo..macInfo groupBy $.mac map {
	mac: $.mac[0],
	isExisting: true when $.macSeqNumber != null otherwise false,
	duration: $.duration[0],
	currentDiscount: ((sizeOf $.macSeqNumber default 0) * $.amount[0]),
	availableDiscount: ((sizeOf $.mac) - (sizeOf $.macSeqNumber default 0)) * $.amount[0] when (sizeOf ($.eligibilityCode filter $ != 'P')) > (min [noOfEligibleSubscribers, ($.maxLineLimit[0] default 0)])
						otherwise ((sizeOf ($.eligibilityCode filter $ != 'P')) - (sizeOf $.macSeqNumber default 0)) * $.amount[0] + ((min [noOfEligibleSubscribers, ($.maxLineLimit[0] default 0)]) - (sizeOf ($.eligibilityCode filter $ != 'P'))) * $.amount[0],
	batchProcessInd: false
} default [({batchProcessInd: true}) when payload.cmeResponse.eligibilityList.eligibilityInfo[0].batchProcessInd != null and payload.cmeResponse.eligibilityList.eligibilityInfo[0].batchProcessInd as :boolean]