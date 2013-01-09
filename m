Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 91C036B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 12:48:03 -0500 (EST)
Message-ID: <50EDAD51.4010803@codeaurora.org>
Date: Wed, 09 Jan 2013 09:48:01 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RESEND][PATCH v3] mm: Use aligned zone start for pfn_to_bitidx
 calculation
References: <1357414111-20736-1-git-send-email-lauraa@codeaurora.org> <20130107143128.face9220.akpm@linux-foundation.org>
In-Reply-To: <20130107143128.face9220.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

On 1/7/2013 2:31 PM, Andrew Morton wrote:
> On Sat,  5 Jan 2013 11:28:31 -0800
> Laura Abbott <lauraa@codeaurora.org> wrote:
>
>> The current calculation in pfn_to_bitidx assumes that
>> (pfn - zone->zone_start_pfn) >> pageblock_order will return the
>> same bit for all pfn in a pageblock. If zone_start_pfn is not
>> aligned to pageblock_nr_pages, this may not always be correct.
>>
>> Consider the following with pageblock order = 10, zone start 2MB:
>>
>> pfn     | pfn - zone start | (pfn - zone start) >> page block order
>> ----------------------------------------------------------------
>> 0x26000 | 0x25e00	   |  0x97
>> 0x26100 | 0x25f00	   |  0x97
>> 0x26200 | 0x26000	   |  0x98
>> 0x26300 | 0x26100	   |  0x98
>>
>> This means that calling {get,set}_pageblock_migratetype on a single
>> page will not set the migratetype for the full block. Fix this by
>> rounding down zone_start_pfn when doing the bitidx calculation.
>
> What are the user-visible effects of this bug?
>

For our use case, the effects were mostly tied to the fact that CMA 
allocations would either take a long time or fail to happen on on. 
Depending on the driver using CMA, this could result in anything from 
visual glitches to application failures.

I'm not sure about effect outside of CMA.

Laura
-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
