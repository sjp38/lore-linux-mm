Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 044F06B0069
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 09:45:29 -0500 (EST)
Date: Tue, 10 Jan 2012 14:45:25 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 07/11] mm: add optional memory reclaim in
 split_free_page()
Message-ID: <20120110144525.GD3910@csn.ul.ie>
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-8-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1325162352-24709-8-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Dec 29, 2011 at 01:39:08PM +0100, Marek Szyprowski wrote:
> split_free_page() function is used by migration code to grab a free page
> once the migration has been finished. This function must obey the same
> rules as memory allocation functions to keep the correct level of
> memory watermarks. Memory compaction code calls it under locks, so it
> cannot perform any *_slowpath style reclaim. However when this function
> is called by migration code for Contiguous Memory Allocator, the sleeping
> context is permitted and the function can make a real reclaim to ensure
> that the call succeeds.
> 
> The reclaim code is based on the __alloc_page_slowpath() function.
> 

This feels like it's at the wrong level entirely.

> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> ---
>  include/linux/mm.h |    2 +-
>  mm/compaction.c    |    6 ++--
>  mm/internal.h      |    2 +-
>  mm/page_alloc.c    |   79 +++++++++++++++++++++++++++++++++++++++------------
>  4 files changed, 65 insertions(+), 24 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4baadd1..8b15b21 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -450,7 +450,7 @@ void put_page(struct page *page);
>  void put_pages_list(struct list_head *pages);
>  
>  void split_page(struct page *page, unsigned int order);
> -int split_free_page(struct page *page);
> +int split_free_page(struct page *page, int force_reclaim);
>  
>  /*
>   * Compound pages have a destructor function.  Provide a
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 46783b4..d6c5cb7 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -46,7 +46,7 @@ static inline bool is_migrate_cma_or_movable(int migratetype)
>  unsigned long
>  isolate_freepages_range(struct zone *zone,
>  			unsigned long start_pfn, unsigned long end_pfn,
> -			struct list_head *freelist)
> +			struct list_head *freelist, int force_reclaim)

bool

but this is the first hint that something is wrong with the
layering. The function is about "isolating free pages" but this patch
is making it also about reclaim. If CMA cares about the watermarks,
it should be the one calling try_to_free_pages(), not wedging it into
the side of compaction.

>  {
>  	unsigned long nr_scanned = 0, total_isolated = 0;
>  	unsigned long pfn = start_pfn;
> @@ -67,7 +67,7 @@ isolate_freepages_range(struct zone *zone,
>  			goto next;
>  
>  		/* Found a free page, break it into order-0 pages */
> -		n = split_free_page(page);
> +		n = split_free_page(page, force_reclaim);
>  		total_isolated += n;
>  		if (freelist) {
>  			struct page *p = page;

Second hint - split_free_page() is not a name that indicates it should
have anything to do with reclaim.

> @@ -376,7 +376,7 @@ static void isolate_freepages(struct zone *zone,
>  		if (suitable_migration_target(page)) {
>  			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
>  			isolated = isolate_freepages_range(zone, pfn,
> -					end_pfn, freelist);
> +					end_pfn, freelist, false);
>  			nr_freepages += isolated;
>  		}
>  		spin_unlock_irqrestore(&zone->lock, flags);
> diff --git a/mm/internal.h b/mm/internal.h
> index 4a226d8..8b80027 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -129,7 +129,7 @@ struct compact_control {
>  unsigned long
>  isolate_freepages_range(struct zone *zone,
>  			unsigned long start, unsigned long end,
> -			struct list_head *freelist);
> +			struct list_head *freelist, int force_reclaim);
>  unsigned long
>  isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			   unsigned long low_pfn, unsigned long end_pfn);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8b47c85..a3d5892 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1302,17 +1302,65 @@ void split_page(struct page *page, unsigned int order)
>  		set_page_refcounted(page + i);
>  }
>  
> +static inline
> +void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> +						enum zone_type high_zoneidx,
> +						enum zone_type classzone_idx)
> +{
> +	struct zoneref *z;
> +	struct zone *zone;
> +
> +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> +		wakeup_kswapd(zone, order, classzone_idx);
> +}
> +
> +/*
> + * Trigger memory pressure bump to reclaim at least 2^order of free pages.
> + * Does similar work as it is done in __alloc_pages_slowpath(). Used only
> + * by migration code to allocate contiguous memory range.
> + */
> +static int __force_memory_reclaim(int order, struct zone *zone)
> +{
> +	gfp_t gfp_mask = GFP_HIGHUSER_MOVABLE;
> +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> +	struct zonelist *zonelist = node_zonelist(0, gfp_mask);
> +	struct reclaim_state reclaim_state;
> +	int did_some_progress = 0;
> +
> +	wake_all_kswapd(order, zonelist, high_zoneidx, zone_idx(zone));
> +
> +	/* We now go into synchronous reclaim */
> +	cpuset_memory_pressure_bump();
> +	current->flags |= PF_MEMALLOC;
> +	lockdep_set_current_reclaim_state(gfp_mask);
> +	reclaim_state.reclaimed_slab = 0;
> +	current->reclaim_state = &reclaim_state;
> +
> +	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, NULL);
> +
> +	current->reclaim_state = NULL;
> +	lockdep_clear_current_reclaim_state();
> +	current->flags &= ~PF_MEMALLOC;
> +
> +	cond_resched();
> +
> +	if (!did_some_progress) {
> +		/* Exhausted what can be done so it's blamo time */
> +		out_of_memory(zonelist, gfp_mask, order, NULL);
> +	}
> +	return order;
> +}

At the very least, __alloc_pages_direct_reclaim() should be sharing this
code.

> +
>  /*
>   * Similar to split_page except the page is already free. As this is only
>   * being used for migration, the migratetype of the block also changes.
> - * As this is called with interrupts disabled, the caller is responsible
> - * for calling arch_alloc_page() and kernel_map_page() after interrupts
> - * are enabled.
> + * The caller is responsible for calling arch_alloc_page() and kernel_map_page()
> + * after interrupts are enabled.
>   *
>   * Note: this is probably too low level an operation for use in drivers.
>   * Please consult with lkml before using this in your driver.
>   */
> -int split_free_page(struct page *page)
> +int split_free_page(struct page *page, int force_reclaim)
>  {
>  	unsigned int order;
>  	unsigned long watermark;
> @@ -1323,10 +1371,15 @@ int split_free_page(struct page *page)
>  	zone = page_zone(page);
>  	order = page_order(page);
>  
> +try_again:
>  	/* Obey watermarks as if the page was being allocated */
>  	watermark = low_wmark_pages(zone) + (1 << order);
> -	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> -		return 0;
> +	if (!zone_watermark_ok(zone, 0, watermark, 0, 0)) {
> +		if (force_reclaim && __force_memory_reclaim(order, zone))
> +			goto try_again;
> +		else
> +			return 0;
> +	}
>  
>  	/* Remove page from free list */
>  	list_del(&page->lru);
> @@ -2086,18 +2139,6 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
>  	return page;
>  }
>  
> -static inline
> -void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> -						enum zone_type high_zoneidx,
> -						enum zone_type classzone_idx)
> -{
> -	struct zoneref *z;
> -	struct zone *zone;
> -
> -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> -		wakeup_kswapd(zone, order, classzone_idx);
> -}
> -
>  static inline int
>  gfp_to_alloc_flags(gfp_t gfp_mask)
>  {
> @@ -5917,7 +5958,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  
>  	outer_start = start & (~0UL << ret);
>  	outer_end = isolate_freepages_range(page_zone(pfn_to_page(outer_start)),
> -					    outer_start, end, NULL);
> +					    outer_start, end, NULL, true);
>  	if (!outer_end) {
>  		ret = -EBUSY;
>  		goto done;

I think it makes far more sense to have the logic related to calling
try_to_free_pages here in alloc_contig_range rather than trying to pass
it into compaction helper functions.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
