Message-ID: <446C1E25.4080408@yahoo.com.au>
Date: Thu, 18 May 2006 17:11:33 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: limit lowmem_reserve
References: <200604021401.13331.kernel@kolivas.org> <200604081101.06066.kernel@kolivas.org> <443710F7.3040201@yahoo.com.au> <200605180011.43216.kernel@kolivas.org>
In-Reply-To: <200605180011.43216.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, ck@vds.kolivas.org, linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> I hate to resuscitate this old thread, sorry but I'm still not sure we 
> resolved it and I want to make sure this issue isn't here as I see it.
> 

OK, reclaim is slightly different.

> On Saturday 08 April 2006 11:25, Nick Piggin wrote:
> 
>>Con Kolivas wrote:
>>
>>>Ok. I think I presented enough information for why I thought
>>>zone_watermark_ok would fail (for ZONE_DMA). With 16MB ZONE_DMA and a
>>>vmsplit of 3GB we have a lowmem_reserve of 12MB. It's pretty hard to keep
>>>that much ZONE_DMA free, I don't think I've ever seen that much free on
>>>my ZONE_DMA on an ordinary desktop without any particular ZONE_DMA users.
>>>Changing the tunable can make the lowmem_reserve larger than ZONE_DMA is
>>>on any vmsplit too as far as I understand the ratio.
>>
>>Umm, for ZONE_DMA allocations, ZONE_DMA isn't a lower zone. So that
>>12MB protection should never come into it (unless it is buggy?).
> 
> 
> An i386 pc with a 3GB split will have approx
> 
> 4000 pages ZONE_DMA
> 
> and lowmem reserve will set lowmem reserve to approx
> 
> 0 0 3000 3000
> 
> So if we call zone_watermark_ok with zone of ZONE_DMA and a classzone_idx of a 
> ZONE_NORMAL we will fail a zone_watermark_ok test almost always since it's 
> almost impossible to have 3000 free ZONE_DMA pages. I believe it can happen 
> like this:
> 
> In balance_pgdat (vmscan.c:1116) if we end up with end_zone being a 
> ZONE_NORMAL zone, then during the scan below we (vmscan.c:1137) iterate over 
> all zones from 0 to end_zone and (vmscan.c:1147) we end up calling
> 
> if (!zone_watermark_ok(zone, order, zone->pages_high, end_zone, 0))
> 
> which would now call zone_watermark_ok with zone being a ZONE_DMA, and 
> end_zone being the idx of a ZONE_NORMAL.
> 
> So in summary if I'm not mistaken (and I'm good at being mistaken), if we 
> balance pgdat and find that ZONE_NORMAL or higher needs scanning, we'll end 
> up trying to flush the crap out of ZONE_DMA.

If we're under memory pressure, kswapd will try to free up any candidate
zone, yes.

> 
> On my test case this indeed happens and my ZONE_DMA never goes below 3000
> pages free. If I lower the reserve even further my pages free gets stuck at
> 3208 and can't free any more, and doesn't ever drop below that either.
> 
> Here is the patch I was proposing

What problem does that fix though?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
