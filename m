Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E65F76B2B29
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:56:04 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x1-v6so4448992edh.8
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:56:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si5480605edt.45.2018.11.22.05.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 05:56:03 -0800 (PST)
Subject: Re: [PATCH 3/4] mm: Reclaim small amounts of memory when an external
 fragmentation event occurs
References: <20181121101414.21301-1-mgorman@techsingularity.net>
 <20181121101414.21301-4-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cc8ec820-1526-d753-4619-dedaa227a179@suse.cz>
Date: Thu, 22 Nov 2018 14:53:08 +0100
MIME-Version: 1.0
In-Reply-To: <20181121101414.21301-4-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 11/21/18 11:14 AM, Mel Gorman wrote:
> An external fragmentation event was previously described as
> 
>     When the page allocator fragments memory, it records the event using
>     the mm_page_alloc_extfrag event. If the fallback_order is smaller
>     than a pageblock order (order-9 on 64-bit x86) then it's considered
>     an event that will cause external fragmentation issues in the future.
> 
> The kernel reduces the probability of such events by increasing the
> watermark sizes by calling set_recommended_min_free_kbytes early in the
> lifetime of the system. This works reasonably well in general but if there
> are enough sparsely populated pageblocks then the problem can still occur
> as enough memory is free overall and kswapd stays asleep.
> 
> This patch introduces a watermark_boost_factor sysctl that allows a
> zone watermark to be temporarily boosted when an external fragmentation
> causing events occurs. The boosting will stall allocations that would
> decrease free memory below the boosted low watermark and kswapd is woken
> unconditionally to reclaim an amount of memory relative to the size
> of the high watermark and the watermark_boost_factor until the boost
> is cleared. When kswapd finishes, it wakes kcompactd at the pageblock
> order to clean some of the pageblocks that may have been affected by the
> fragmentation event. kswapd avoids any writeback or swap from reclaim
> context during this operation to avoid excessive system disruption in
> the name of fragmentation avoidance. Care is taken so that kswapd will
> do normal reclaim work if the system is really low on memory.
> 
> This was evaluated using the same workloads as "mm, page_alloc: Spread
> allocations across zones before introducing fragmentation".
> 
> 1-socket Skylake machine
> config-global-dhp__workload_thpfioscale XFS (no special madvise)
> 4 fio threads, 1 THP allocating thread
> --------------------------------------
> 
> 4.20-rc1 extfrag events < order 9:  1023463
> 4.20-rc1+patch:                      358574 (65% reduction)
> 4.20-rc1+patch1-3:                    19274 (98% reduction)

So the reason I was wondering about movable vs unmovable fallbacks here
is that movable fallbacks are ok as they can be migrated later, but the
unmovable/reclaimable not, which is bad if they fallback to movable
pageblock. Movable fallbacks can however fill the unmovable pageblocks
and increase change of the unmovable fallback, but that would depend on
the workload. So hypothetically if the test workload was such that
movable fallbacks did not cause unmovable fallbacks, and a patch would
thus only decrease the movable fallbacks (at the cost of e.g. higher
reclaim, as this patch) with unmovable fallbacks unchanged, then it
would be useful to know that for better evaluation of the pros vs cons,
imho.

> +static inline void boost_watermark(struct zone *zone)
> +{
> +	unsigned long max_boost;
> +
> +	if (!watermark_boost_factor)
> +		return;
> +
> +	max_boost = mult_frac(wmark_pages(zone, WMARK_HIGH),
> +			watermark_boost_factor, 10000);

Hmm I assume you didn't use high_wmark_pages() because the calculation
should start with high watermark not including existing boost. But then,
wmark_pages() also includes existing boost, so the limit won't work and
each invocation of boost_watermark() will simply add pageblock_nr_pages?
I.e. this should use zone->_watermark[] instead of wmark_pages()?

> +	max_boost = max(pageblock_nr_pages, max_boost);
> +
> +	zone->watermark_boost = min(zone->watermark_boost + pageblock_nr_pages,
> +		max_boost);
> +}
> +
>  /*
>   * This function implements actual steal behaviour. If order is large enough,
>   * we can steal whole pageblock. If not, we first move freepages in this
> @@ -2160,6 +2176,14 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  		goto single_page;
>  	}
>  
> +	/*
> +	 * Boost watermarks to increase reclaim pressure to reduce the
> +	 * likelihood of future fallbacks. Wake kswapd now as the node
> +	 * may be balanced overall and kswapd will not wake naturally.
> +	 */
> +	boost_watermark(zone);
> +	wakeup_kswapd(zone, 0, 0, zone_idx(zone));
> +
>  	/* We are not allowed to try stealing from the whole block */
>  	if (!whole_block)
>  		goto single_page;
> @@ -3277,11 +3301,19 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>   * probably too small. It only makes sense to spread allocations to avoid
>   * fragmentation between the Normal and DMA32 zones.
>   */
> -static inline unsigned int alloc_flags_nofragment(struct zone *zone)
> +static inline unsigned int
> +alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
>  {
>  	if (zone_idx(zone) != ZONE_NORMAL)
>  		return 0;
>  
> +	/*
> +	 * A fragmenting fallback will try waking kswapd. ALLOC_NOFRAGMENT
> +	 * may break that so such callers can introduce fragmentation.
> +	 */

I think I don't understand this comment :( Do you want to avoid waking
up kswapd from steal_suitable_fallback() (introduced above) for
allocations without __GFP_KSWAPD_RECLAIM? But returning 0 here means
actually allowing the allocation go through steal_suitable_fallback()?
So should it return ALLOC_NOFRAGMENT below, or was the intent different?

> +	if (!(gfp_mask & __GFP_KSWAPD_RECLAIM))
> +		return 0;
> +
>  	/*
>  	 * If ZONE_DMA32 exists, assume it is the one after ZONE_NORMAL and
>  	 * the pointer is within zone->zone_pgdat->node_zones[]

.
