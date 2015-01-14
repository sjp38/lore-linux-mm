Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2C54E6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:28:10 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id l13so8294367iga.0
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 03:28:10 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id m66si16013328ioe.49.2015.01.14.03.28.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 03:28:06 -0800 (PST)
Message-ID: <54B652BF.9020300@codeaurora.org>
Date: Wed, 14 Jan 2015 16:57:59 +0530
From: Vinayak Menon <vinmenon@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: fix the page state calculation in too_many_isolated
References: <1421147247-10870-1-git-send-email-vinmenon@codeaurora.org> <20150113160940.GD8180@phnom.home.cmpxchg.org>
In-Reply-To: <20150113160940.GD8180@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vdavydov@parallels.com, mhocko@suse.cz, mgorman@suse.de, minchan@kernel.org

On 01/13/2015 09:39 PM, Johannes Weiner wrote:
> On Tue, Jan 13, 2015 at 04:37:27PM +0530, Vinayak Menon wrote:
>> @@ -1392,6 +1392,44 @@ int isolate_lru_page(struct page *page)
>>   	return ret;
>>   }
>>
>> +static int __too_many_isolated(struct zone *zone, int file,
>> +	struct scan_control *sc, int safe)
>> +{
>> +	unsigned long inactive, isolated;
>> +
>> +	if (file) {
>> +		if (safe) {
>> +			inactive = zone_page_state_snapshot(zone,
>> +					NR_INACTIVE_FILE);
>> +			isolated = zone_page_state_snapshot(zone,
>> +					NR_ISOLATED_FILE);
>> +		} else {
>> +			inactive = zone_page_state(zone, NR_INACTIVE_FILE);
>> +			isolated = zone_page_state(zone, NR_ISOLATED_FILE);
>> +		}
>> +	} else {
>> +		if (safe) {
>> +			inactive = zone_page_state_snapshot(zone,
>> +					NR_INACTIVE_ANON);
>> +			isolated = zone_page_state_snapshot(zone,
>> +					NR_ISOLATED_ANON);
>> +		} else {
>> +			inactive = zone_page_state(zone, NR_INACTIVE_ANON);
>> +			isolated = zone_page_state(zone, NR_ISOLATED_ANON);
>> +		}
>> +	}
>
> 	if (safe) {
> 		inactive = zone_page_state_snapshot(zone, NR_INACTIVE_ANON + 2*file)
> 		isolated = zone_page_state_snapshot(zone, NR_ISOLATED_ANON + file)
> 	} else {
> 		inactive = zone_page_state(zone, NR_INACTIVE_ANON + 2*file)
> 		isolated = zone_page_state(zone, NR_ISOLATED_ANON + file)
> 	}
>

Ok. Will change that.

-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
