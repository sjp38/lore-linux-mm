Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 166DE6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:35:26 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so196884520wib.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 04:35:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bf4si26538018wib.67.2015.07.29.04.35.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 04:35:24 -0700 (PDT)
Subject: Re: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-10-git-send-email-mgorman@suse.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B8BA75.9090903@suse.cz>
Date: Wed, 29 Jul 2015 13:35:17 +0200
MIME-Version: 1.0
In-Reply-To: <1437379219-9160-10-git-send-email-mgorman@suse.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On 07/20/2015 10:00 AM, Mel Gorman wrote:
> From: Mel Gorman <mgorman@suse.de>
> 
> High-order watermark checking exists for two reasons --  kswapd high-order
> awareness and protection for high-order atomic requests. Historically we
> depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order free
> pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
> that reserves pageblocks for high-order atomic allocations. This is expected
> to be more reliable than MIGRATE_RESERVE was.
> 
> A MIGRATE_HIGHORDER pageblock is created when an allocation request steals
> a pageblock but limits the total number to 10% of the zone.

This looked weird, until I read the implementation and realized that "an
allocation request" is limited to high-order atomic allocation requests.

> The pageblocks are unreserved if an allocation fails after a direct
> reclaim attempt.
> 
> The watermark checks account for the reserved pageblocks when the allocation
> request is not a high-order atomic allocation.
> 
> The stutter benchmark was used to evaluate this but while it was running
> there was a systemtap script that randomly allocated between 1 and 1G worth
> of order-3 pages using GFP_ATOMIC. In kernel 4.2-rc1 running this workload
> on a single-node machine there were 339574 allocation failures. With this
> patch applied there were 28798 failures -- a 92% reduction. On a 4-node
> machine, allocation failures went from 76917 to 0 failures.
> 
> There are minor theoritical side-effects. If the system is intensively
> making large numbers of long-lived high-order atomic allocations then
> there will be a lot of reserved pageblocks. This may push some workloads
> into reclaim until the number of reserved pageblocks is reduced again. This
> problem was not observed in reclaim intensive workloads but such workloads
> are also not atomic high-order intensive.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

[...]

> +/*
> + * Used when an allocation is about to fail under memory pressure. This
> + * potentially hurts the reliability of high-order allocations when under
> + * intense memory pressure but failed atomic allocations should be easier
> + * to recover from than an OOM.
> + */
> +static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> +{
> +	struct zonelist *zonelist = ac->zonelist;
> +	unsigned long flags;
> +	struct zoneref *z;
> +	struct zone *zone;
> +	struct page *page;
> +	int order;
> +
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
> +								ac->nodemask) {

This fixed order might bias some zones over others wrt unreserving. Is it OK?

> +		/* Preserve at least one pageblock */
> +		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
> +			continue;
> +
> +		spin_lock_irqsave(&zone->lock, flags);
> +		for (order = 0; order < MAX_ORDER; order++) {

Would it make more sense to look in descending order for a higher chance of
unreserving a pageblock that's mostly free? Like the traditional page stealing does?

> +			struct free_area *area = &(zone->free_area[order]);
> +
> +			if (list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
> +				continue;
> +
> +			page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
> +						struct page, lru);
> +
> +			zone->nr_reserved_highatomic -= pageblock_nr_pages;
> +			set_pageblock_migratetype(page, ac->migratetype);

Would it make more sense to assume MIGRATE_UNMOVABLE, as high-order allocations
present in the pageblock typically would be, and apply the traditional page
stealing heuristics to decide if it should be changed to ac->migratetype (if
that differs)?

> +			move_freepages_block(zone, page, ac->migratetype);
> +			spin_unlock_irqrestore(&zone->lock, flags);
> +			return;
> +		}
> +		spin_unlock_irqrestore(&zone->lock, flags);
> +	}
> +}
> +
>  /* Remove an element from the buddy allocator from the fallback list */
>  static inline struct page *
>  __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> @@ -1619,15 +1689,26 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  	return NULL;
>  }
>  
> +static inline bool gfp_mask_atomic(gfp_t gfp_mask)
> +{
> +	return !(gfp_mask & (__GFP_WAIT | __GFP_NO_KSWAPD));
> +}
> +
>  /*
>   * Do the hard work of removing an element from the buddy allocator.
>   * Call me with the zone->lock already held.
>   */
>  static struct page *__rmqueue(struct zone *zone, unsigned int order,
> -						int migratetype)
> +				int migratetype, gfp_t gfp_flags)
>  {
>  	struct page *page;
>  
> +	if (unlikely(order && gfp_mask_atomic(gfp_flags))) {
> +		page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> +		if (page)
> +			goto out;
> +	}
> +
>  	page = __rmqueue_smallest(zone, order, migratetype);
>  	if (unlikely(!page)) {
>  		if (migratetype == MIGRATE_MOVABLE)
> @@ -1637,6 +1718,7 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
>  			page = __rmqueue_fallback(zone, order, migratetype);
>  	}
>  
> +out:
>  	trace_mm_page_alloc_zone_locked(page, order, migratetype);
>  	return page;
>  }
> @@ -1654,7 +1736,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  
>  	spin_lock(&zone->lock);
>  	for (i = 0; i < count; ++i) {
> -		struct page *page = __rmqueue(zone, order, migratetype);
> +		struct page *page = __rmqueue(zone, order, migratetype, 0);
>  		if (unlikely(page == NULL))
>  			break;
>  
> @@ -2065,7 +2147,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  			WARN_ON_ONCE(order > 1);
>  		}
>  		spin_lock_irqsave(&zone->lock, flags);
> -		page = __rmqueue(zone, order, migratetype);
> +		page = __rmqueue(zone, order, migratetype, gfp_flags);
>  		spin_unlock(&zone->lock);
>  		if (!page)
>  			goto failed;
> @@ -2175,15 +2257,23 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  			unsigned long mark, int classzone_idx, int alloc_flags,
>  			long free_pages)
>  {
> -	/* free_pages may go negative - that's OK */
>  	long min = mark;
>  	int o;
>  	long free_cma = 0;
>  
> +	/* free_pages may go negative - that's OK */
>  	free_pages -= (1 << order) - 1;
> +
>  	if (alloc_flags & ALLOC_HIGH)
>  		min -= min / 2;
> -	if (alloc_flags & ALLOC_HARDER)
> +
> +	/*
> +	 * If the caller is not atomic then discount the reserves. This will
> +	 * over-estimate how the atomic reserve but it avoids a search
> +	 */
> +	if (likely(!(alloc_flags & ALLOC_HARDER)))
> +		free_pages -= z->nr_reserved_highatomic;

Hm, so in the case the maximum of 10% reserved blocks is already full, we deny
the allocation access to another 10% of the memory and push it to reclaim. This
seems rather excessive.
Searching would of course suck, as would attempting to replicate the handling of
NR_FREE_CMA_PAGES. Sigh.

> +	else
>  		min -= min / 4;
>  
>  #ifdef CONFIG_CMA
> @@ -2372,6 +2462,14 @@ try_this_zone:
>  		if (page) {
>  			if (prep_new_page(page, order, gfp_mask, alloc_flags))
>  				goto try_this_zone;
> +
> +			/*
> +			 * If this is a high-order atomic allocation then check
> +			 * if the pageblock should be reserved for the future
> +			 */
> +			if (unlikely(order && (alloc_flags & ALLOC_HARDER)))
> +				reserve_highatomic_pageblock(page, zone, order);
> +
>  			return page;
>  		}
>  	}
> @@ -2639,9 +2737,11 @@ retry:
>  
>  	/*
>  	 * If an allocation failed after direct reclaim, it could be because
> -	 * pages are pinned on the per-cpu lists. Drain them and try again
> +	 * pages are pinned on the per-cpu lists or in high alloc reserves.
> +	 * Shrink them them and try again
>  	 */
>  	if (!page && !drained) {
> +		unreserve_highatomic_pageblock(ac);
>  		drain_all_pages(NULL);
>  		drained = true;
>  		goto retry;
> @@ -2686,7 +2786,7 @@ static inline int
>  gfp_to_alloc_flags(gfp_t gfp_mask)
>  {
>  	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
> -	const bool atomic = !(gfp_mask & (__GFP_WAIT | __GFP_NO_KSWAPD));
> +	const bool atomic = gfp_mask_atomic(gfp_mask);
>  
>  	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
>  	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 49963aa2dff3..3427a155f85e 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -901,6 +901,7 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
>  	"Unmovable",
>  	"Reclaimable",
>  	"Movable",
> +	"HighAtomic",
>  #ifdef CONFIG_CMA
>  	"CMA",
>  #endif
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
