Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E45F26B0261
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 08:20:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so13882598wma.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 05:20:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m5si478387wjw.285.2016.07.15.05.20.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 05:20:14 -0700 (PDT)
Subject: Re: [PATCH 34/34] mm, vmstat: remove zone and node double accounting
 by approximating retries
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-35-git-send-email-mgorman@techsingularity.net>
 <bd515668-2d1f-e70e-f419-7a55189757f7@suse.cz>
 <20160715074859.GM9806@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <31d7909c-d99e-3fee-e17c-3f160e7620c0@suse.cz>
Date: Fri, 15 Jul 2016 14:20:10 +0200
MIME-Version: 1.0
In-Reply-To: <20160715074859.GM9806@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/15/2016 09:48 AM, Mel Gorman wrote:
> On Thu, Jul 14, 2016 at 03:40:11PM +0200, Vlastimil Babka wrote:
>>> @@ -4,6 +4,26 @@
>>> #include <linux/huge_mm.h>
>>> #include <linux/swap.h>
>>>
>>> +#ifdef CONFIG_HIGHMEM
>>> +extern atomic_t highmem_file_pages;
>>> +
>>> +static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
>>> +							int nr_pages)
>>> +{
>>> +	if (is_highmem_idx(zid) && is_file_lru(lru)) {
>>> +		if (nr_pages > 0)
>>
>> This seems like a unnecessary branch, atomic_add should handle negative
>> nr_pages just fine?
>>
> 
> On x86 it would but the interface makes no guarantees it'll handle
> signed types properly on all architectures.

Hmm really? At least some drivers do that in an easily grepable way:

drivers/tty/serial/dz.c:                        atomic_add(-1, &mux->map_guard);
drivers/tty/serial/sb1250-duart.c:                      atomic_add(-1, &duart->map_guard);
drivers/tty/serial/zs.c:                        atomic_add(-1, &scc->irq_guard);

And our own __mod_zone_page_state() can get both negative and positive
vales and boils down to atomic_long_add() (I assume the long variant wouldn't
be different in this aspect).

>>> @@ -1456,14 +1461,27 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>>> 		unsigned long available;
>>> 		enum compact_result compact_result;
>>>
>>> +		if (last_pgdat == zone->zone_pgdat)
>>> +			continue;
>>> +
>>> +		/*
>>> +		 * This over-estimates the number of pages available for
>>> +		 * reclaim/compaction but walking the LRU would take too
>>> +		 * long. The consequences are that compaction may retry
>>> +		 * longer than it should for a zone-constrained allocation
>>> +		 * request.
>>
>> The comment above says that we don't retry zone-constrained at all. Is this
>> an obsolete comment, or does it refer to the ZONE_NORMAL constraint? (as
>> opposed to HIGHMEM, MOVABLE etc?).
>>
> 
> It can still over-estimate the amount of memory available if
> ZONE_MOVABLE exists even if the request is not zone-constrained.

OK.

>>> @@ -3454,6 +3455,15 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>>> 		return false;
>>>
>>> 	/*
>>> +	 * Blindly retry lowmem allocation requests that are often ignored by
>>> +	 * the OOM killer up to MAX_RECLAIM_RETRIES as we not have a reliable
>>> +	 * and fast means of calculating reclaimable, dirty and writeback pages
>>> +	 * in eligible zones.
>>> +	 */
>>> +	if (ac->high_zoneidx < ZONE_NORMAL)
>>> +		goto out;
>>
>> A goto inside two nested for cycles? Is there no hope for sanity? :(
>>
> 
> None, hand it in at the door.

Mine's long gone, was thinking for the future newbies :)
 
> It can be pulled out and put past the "return false" at the end. It's
> just not necessarily any better.

I see...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
