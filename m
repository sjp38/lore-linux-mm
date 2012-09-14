Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 7E76A6B025D
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 10:17:47 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MAC006PHFORTUT0@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 14 Sep 2012 23:17:45 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MAC00DSRFPH7740@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 14 Sep 2012 23:17:45 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v3 5/5] cma: fix watermark checking
Date: Fri, 14 Sep 2012 16:12:10 +0200
References: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
 <1346765185-30977-6-git-send-email-b.zolnierkie@samsung.com>
 <20120914041333.GJ5085@bbox>
In-reply-to: <20120914041333.GJ5085@bbox>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201209141612.10924.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Friday 14 September 2012 06:13:34 Minchan Kim wrote:
> On Tue, Sep 04, 2012 at 03:26:25PM +0200, Bartlomiej Zolnierkiewicz wrote:
> > Pass GFP flags to [__]zone_watermark_ok() and use them to account
> > free CMA pages only when necessary (there is no need to check
> > watermark against only non-CMA free pages for movable allocations).
> 
> I want to make it zero-overhead in case of !CONFIG_CMA.
> We can reduce the number of zone_watermark_ok's argument and in case of !CONFIG_CMA,
> overhead would be zero.
> 
> How about this?
> (Below is what I want to show the *concept*, NOT completed, NOT compile tested)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 009ac28..61c592a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1514,6 +1514,8 @@ failed:
>  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
>  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
>  
> +#define ALLOC_CMA		0x80
> +
>  #ifdef CONFIG_FAIL_PAGE_ALLOC
>  
>  static struct {
> @@ -1608,7 +1610,10 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  		min -= min / 2;
>  	if (alloc_flags & ALLOC_HARDER)
>  		min -= min / 4;
> -
> +#ifdef CONFIG_CMA
> +	if (alloc_flags & ALLOC_CMA)

This should be (!(alloc_flags & ALLOC_CMA)) because we want to decrease
free pages when the flag is not set (== unmovable allocation).

> +		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
> +#endif
>  	if (free_pages <= min + lowmem_reserve)
>  		return false;
>  	for (o = 0; o < order; o++) {
> @@ -2303,7 +2308,10 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  				 unlikely(test_thread_flag(TIF_MEMDIE))))
>  			alloc_flags |= ALLOC_NO_WATERMARKS;
>  	}
> -
> +#ifdef CONFIG_CMA
> +	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
> +			alloc_flags |= ALLOC_CMA;
> +#endif
>  	return alloc_flags;
>  }
>  
> @@ -2533,6 +2541,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	struct page *page = NULL;
>  	int migratetype = allocflags_to_migratetype(gfp_mask);
>  	unsigned int cpuset_mems_cookie;
> +	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
>  
>  	gfp_mask &= gfp_allowed_mask;
>  
> @@ -2561,9 +2570,13 @@ retry_cpuset:
>  	if (!preferred_zone)
>  		goto out;
>  
> +#ifdef CONFIG_CMA
> +	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
> +		alloc_flags |= ALLOC_CMA;
> +#endif
>  	/* First allocation attempt */
>  	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> -			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
> +			zonelist, high_zoneidx, alloc_flags,
>  			preferred_zone, migratetype);
>  	if (unlikely(!page))
>  		page = __alloc_pages_slowpath(gfp_mask, order,

Otherwise the change to ALLOC_CMA looks good and I'll do it in the next
revision of the patchset.

Thanks for review & useful ideas!

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

> > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > Cc: Michal Nazarewicz <mina86@mina86.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  include/linux/mmzone.h |  2 +-
> >  mm/compaction.c        | 11 ++++++-----
> >  mm/page_alloc.c        | 29 +++++++++++++++++++----------
> >  mm/vmscan.c            |  4 ++--
> >  4 files changed, 28 insertions(+), 18 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 904889d..308bb91 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -725,7 +725,7 @@ extern struct mutex zonelists_mutex;
> >  void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
> >  void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
> >  bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> > -		int classzone_idx, int alloc_flags);
> > +		int classzone_idx, int alloc_flags, gfp_t gfp_flags);
> >  bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
> >  		int classzone_idx, int alloc_flags);
> >  enum memmap_context {
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 4b902aa..080175a 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -684,7 +684,7 @@ static int compact_finished(struct zone *zone,
> >  	watermark = low_wmark_pages(zone);
> >  	watermark += (1 << cc->order);
> >  
> > -	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
> > +	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0, 0))
> >  		return COMPACT_CONTINUE;
> >  
> >  	/* Direct compactor: Is a suitable page free? */
> > @@ -726,7 +726,7 @@ unsigned long compaction_suitable(struct zone *zone, int order)
> >  	 * allocated and for a short time, the footprint is higher
> >  	 */
> >  	watermark = low_wmark_pages(zone) + (2UL << order);
> > -	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> > +	if (!zone_watermark_ok(zone, 0, watermark, 0, 0, 0))
> >  		return COMPACT_SKIPPED;
> >  
> >  	/*
> > @@ -745,7 +745,7 @@ unsigned long compaction_suitable(struct zone *zone, int order)
> >  		return COMPACT_SKIPPED;
> >  
> >  	if (fragindex == -1000 && zone_watermark_ok(zone, order, watermark,
> > -	    0, 0))
> > +	    0, 0, 0))
> >  		return COMPACT_PARTIAL;
> >  
> >  	return COMPACT_CONTINUE;
> > @@ -889,7 +889,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
> >  		rc = max(status, rc);
> >  
> >  		/* If a normal allocation would succeed, stop compacting */
> > -		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
> > +		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0,
> > +				      gfp_mask))
> >  			break;
> >  	}
> >  
> > @@ -920,7 +921,7 @@ static int __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
> >  
> >  		if (cc->order > 0) {
> >  			int ok = zone_watermark_ok(zone, cc->order,
> > -						low_wmark_pages(zone), 0, 0);
> > +						low_wmark_pages(zone), 0, 0, 0);
> >  			if (ok && cc->order >= zone->compact_order_failed)
> >  				zone->compact_order_failed = cc->order + 1;
> >  			/* Currently async compaction is never deferred. */
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 2166774..5912a8c 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1423,7 +1423,7 @@ int split_free_page(struct page *page, bool check_wmark)
> >  	if (check_wmark) {
> >  		/* Obey watermarks as if the page was being allocated */
> >  		watermark = low_wmark_pages(zone) + (1 << order);
> > -		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> > +		if (!zone_watermark_ok(zone, 0, watermark, 0, 0, 0))
> >  			return 0;
> >  	}
> >  
> > @@ -1628,12 +1628,13 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
> >   * of the allocation.
> >   */
> >  static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> > -		      int classzone_idx, int alloc_flags, long free_pages, long free_cma_pages)
> > +		      int classzone_idx, int alloc_flags, long free_pages,
> > +		      long free_cma_pages, gfp_t gfp_flags)
> >  {
> >  	/* free_pages my go negative - that's OK */
> >  	long min = mark;
> >  	long lowmem_reserve = z->lowmem_reserve[classzone_idx];
> > -	int o;
> > +	int mt, o;
> >  
> >  	free_pages -= (1 << order) - 1;
> >  	if (alloc_flags & ALLOC_HIGH)
> > @@ -1641,8 +1642,14 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> >  	if (alloc_flags & ALLOC_HARDER)
> >  		min -= min / 4;
> >  
> > -	if (free_pages - free_cma_pages <= min + lowmem_reserve)
> > -		return false;
> > +	mt = allocflags_to_migratetype(gfp_flags);
> > +	if (mt == MIGRATE_MOVABLE) {
> > +		if (free_pages <= min + lowmem_reserve)
> > +			return false;
> > +	} else {
> > +		if (free_pages - free_cma_pages <= min + lowmem_reserve)
> > +			return false;
> > +	}
> >  	for (o = 0; o < order; o++) {
> >  		/* At the next order, this order's pages become unavailable */
> >  		free_pages -= z->free_area[o].nr_free << o;
> > @@ -1671,11 +1678,12 @@ static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
> >  #endif
> >  
> >  bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> > -		      int classzone_idx, int alloc_flags)
> > +		      int classzone_idx, int alloc_flags, gfp_t gfp_flags)
> >  {
> >  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> >  					zone_page_state(z, NR_FREE_PAGES),
> > -					zone_page_state(z, NR_FREE_CMA_PAGES));
> > +					zone_page_state(z, NR_FREE_CMA_PAGES),
> > +					gfp_flags);
> >  }
> >  
> >  bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
> > @@ -1696,7 +1704,7 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
> >  	 */
> >  	free_pages -= nr_zone_isolate_freepages(z);
> >  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> > -					free_pages, free_cma_pages);
> > +					free_pages, free_cma_pages, 0);
> >  }
> >  
> >  #ifdef CONFIG_NUMA
> > @@ -1906,7 +1914,7 @@ zonelist_scan:
> >  
> >  			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
> >  			if (zone_watermark_ok(zone, order, mark,
> > -				    classzone_idx, alloc_flags))
> > +				    classzone_idx, alloc_flags, gfp_mask))
> >  				goto try_this_zone;
> >  
> >  			if (NUMA_BUILD && !did_zlc_setup && nr_online_nodes > 1) {
> > @@ -1942,7 +1950,8 @@ zonelist_scan:
> >  			default:
> >  				/* did we reclaim enough */
> >  				if (!zone_watermark_ok(zone, order, mark,
> > -						classzone_idx, alloc_flags))
> > +						classzone_idx, alloc_flags,
> > +						gfp_mask))
> >  					goto this_zone_full;
> >  			}
> >  		}
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 8d01243..4a10038b 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2777,14 +2777,14 @@ out:
> >  
> >  			/* Confirm the zone is balanced for order-0 */
> >  			if (!zone_watermark_ok(zone, 0,
> > -					high_wmark_pages(zone), 0, 0)) {
> > +					high_wmark_pages(zone), 0, 0, 0)) {
> >  				order = sc.order = 0;
> >  				goto loop_again;
> >  			}
> >  
> >  			/* Check if the memory needs to be defragmented. */
> >  			if (zone_watermark_ok(zone, order,
> > -				    low_wmark_pages(zone), *classzone_idx, 0))
> > +				    low_wmark_pages(zone), *classzone_idx, 0, 0))
> >  				zones_need_compaction = 0;
> >  
> >  			/* If balanced, clear the congested flag */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
