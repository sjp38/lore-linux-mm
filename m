Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 4899F8D0011
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 15:00:06 -0500 (EST)
Message-ID: <50C0F944.5040208@codeaurora.org>
Date: Thu, 06 Dec 2012 12:00:04 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Use aligned zone start for pfn_to_bitidx calculation
References: <1354659001-13673-1-git-send-email-lauraa@codeaurora.org> <20121206101220.GB2580@suse.de>
In-Reply-To: <20121206101220.GB2580@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

On 12/6/2012 2:12 AM, Mel Gorman wrote:
> On Tue, Dec 04, 2012 at 02:10:01PM -0800, Laura Abbott wrote:
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
>> page will not set the migratetype for the full block. The correct
>> fix is to round down zone_start_pfn for the bit index calculation.
>> Rather than do this calculation everytime, store this precalcualted
>> algined start in the zone structure to allow the actual start_pfn to
>> be used elsewhere.
>>
>> Change-Id: I13e2f53f50db294f38ec86138c17c6fe29f0ee82
>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
>
> Hi Laura,
>
> There should be no need to add a new zone field. It's probably ok in terms
> of functionality but it does mean that we have to worry about things like
> hotplug (FWIW, should be fine) and the memory overhead is added even on
> CONFIG_SPARSEMEM where it is not needed. Instead, mask out the lower bits
> in pfn_to_bitidx() using the same round_down trick you already do. The
> cost is negligible.
>
> Thanks.
>

I was debating if storing the size was actually necessary. I'll resubmit 
with the calculation done directly in the function.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
