Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 437E36B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 09:08:34 -0400 (EDT)
Date: Tue, 18 Oct 2011 15:08:26 +0200
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/9] mm: MIGRATE_CMA migration type added
Message-ID: <20111018130826.GD6660@csn.ul.ie>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-5-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1317909290-29832-5-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Thu, Oct 06, 2011 at 03:54:44PM +0200, Marek Szyprowski wrote:
> From: Michal Nazarewicz <m.nazarewicz@samsung.com>
> 
> The MIGRATE_CMA migration type has two main characteristics:
> (i) only movable pages can be allocated from MIGRATE_CMA
> pageblocks and (ii) page allocator will never change migration
> type of MIGRATE_CMA pageblocks.
> 
> This guarantees that page in a MIGRATE_CMA page block can
> always be migrated somewhere else (unless there's no memory left
> in the system).
> 

Or the count is premanently elevated by a device driver for some reason or if
the page is backed by a filesystem with a broken or unusable migrate_page()
function. This is unavoidable, I'm just pointing out that you can stil have
migration failures, particularly if GFP_MOVABLE has been improperly
used.

> It is designed to be used with Contiguous Memory Allocator
> (CMA) for allocating big chunks (eg. 10MiB) of physically
> contiguous memory.  Once driver requests contiguous memory,
> CMA will migrate pages from MIGRATE_CMA pageblocks.
> 
> To minimise number of migrations, MIGRATE_CMA migration type
> is the last type tried when page allocator falls back to other
> migration types then requested.
> 

It would be preferable if you could figure out how to reuse the
MIGRATE_RESERVE type for just the bitmap. Like MIGRATE_CMA, it does not
change type except when min_free_kbytes changes. However, it is
something that could be done in the future to keep the size of the
pageblock bitmap where it is now.

> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> [m.szyprowski: cleaned up Kconfig, renamed some functions, removed ifdefs]
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> [m.nazarewicz: fixed incorrect handling of pages from ISOLATE page blocks]
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/linux/mmzone.h         |   41 +++++++++++++++++----
>  include/linux/page-isolation.h |    1 +
>  mm/Kconfig                     |    8 ++++-
>  mm/compaction.c                |   10 +++++
>  mm/page_alloc.c                |   79 ++++++++++++++++++++++++++++++----------
>  5 files changed, 112 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 862a834..cc34965 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -35,13 +35,35 @@
>   */
>  #define PAGE_ALLOC_COSTLY_ORDER 3
>  
> -#define MIGRATE_UNMOVABLE     0
> -#define MIGRATE_RECLAIMABLE   1
> -#define MIGRATE_MOVABLE       2
> -#define MIGRATE_PCPTYPES      3 /* the number of types on the pcp lists */
> -#define MIGRATE_RESERVE       3
> -#define MIGRATE_ISOLATE       4 /* can't allocate from here */
> -#define MIGRATE_TYPES         5
> +enum {
> +	MIGRATE_UNMOVABLE,
> +	MIGRATE_RECLAIMABLE,
> +	MIGRATE_MOVABLE,
> +	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
> +	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
> +	/*
> +	 * MIGRATE_CMA migration type is designed to mimic the way
> +	 * ZONE_MOVABLE works.  Only movable pages can be allocated
> +	 * from MIGRATE_CMA pageblocks and page allocator never
> +	 * implicitly change migration type of MIGRATE_CMA pageblock.
> +	 *
> +	 * The way to use it is to change migratetype of a range of
> +	 * pageblocks to MIGRATE_CMA which can be done by
> +	 * __free_pageblock_cma() function.  What is important though
> +	 * is that a range of pageblocks must be aligned to
> +	 * MAX_ORDER_NR_PAGES should biggest page be bigger then
> +	 * a single pageblock.
> +	 */
> +	MIGRATE_CMA,

This does mean that MIGRATE_CMA also does not have a per-cpu list. I
don't know if that matters to you but all allocations using MIGRATE_CMA
will take the zone lock. I'm not sure this can be easily avoided because
if there is a per-CPU list for MIGRATE_CMA, it might use a new cache
line for it and incur a different set of performance problems.

> +	MIGRATE_ISOLATE,	/* can't allocate from here */
> +	MIGRATE_TYPES
> +};
> +
> +#ifdef CONFIG_CMA_MIGRATE_TYPE
> +#  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
> +#else
> +#  define is_migrate_cma(migratetype) false
> +#endif
>  
>  #define for_each_migratetype_order(order, type) \
>  	for (order = 0; order < MAX_ORDER; order++) \
> @@ -54,6 +76,11 @@ static inline int get_pageblock_migratetype(struct page *page)
>  	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
>  }
>  
> +static inline bool is_pageblock_cma(struct page *page)
> +{
> +	return is_migrate_cma(get_pageblock_migratetype(page));
> +}
> +
>  struct free_area {
>  	struct list_head	free_list[MIGRATE_TYPES];
>  	unsigned long		nr_free;
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 774ecec..9b6aa8a 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -48,4 +48,5 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn);
>  unsigned long scan_lru_pages(unsigned long start, unsigned long end);
>  int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn);
>  
> +extern void init_cma_reserved_pageblock(struct page *page);
>  #endif
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 10d7986..d067b84 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -192,7 +192,7 @@ config COMPACTION
>  config MIGRATION
>  	bool "Page migration"
>  	def_bool y
> -	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION
> +	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA_MIGRATE_TYPE
>  	help

CMA_MIGRATE_TYPE is an implementation detail of how CMA is implemented.
It makes more sense for the Kconfig option to be simply CMA.

>  	  Allows the migration of the physical location of pages of processes
>  	  while the virtual addresses are not changed. This is useful in
> @@ -201,6 +201,12 @@ config MIGRATION
>  	  pages as migration can relocate pages to satisfy a huge page
>  	  allocation instead of reclaiming.
>  
> +config CMA_MIGRATE_TYPE
> +	bool
> +	help
> +	  This enables the use the MIGRATE_CMA migrate type, which lets lets CMA
> +	  work on almost arbitrary memory range and not only inside ZONE_MOVABLE.
> +
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
>  
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 97254e4..9cf6b2b 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -115,6 +115,16 @@ static bool suitable_migration_target(struct page *page)
>  	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
>  		return false;
>  
> +	/* Keep MIGRATE_CMA alone as well. */
> +	/*
> +	 * XXX Revisit.  We currently cannot let compaction touch CMA
> +	 * pages since compaction insists on changing their migration
> +	 * type to MIGRATE_MOVABLE (see split_free_page() called from
> +	 * isolate_freepages_block() above).
> +	 */
> +	if (is_migrate_cma(migratetype))
> +		return false;
> +

This is another reason why CMA and compaction should be using almost
identical code. It does mean that the compact_control may need to be
renamed and get flags to control things like the setting of pageblock
flags but it would be preferable to having two almost identical pieces
of code.

>  	/* If the page is a large free page, then allow migration */
>  	if (PageBuddy(page) && page_order(page) >= pageblock_order)
>  		return true;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8010854..6758b9a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -733,6 +733,29 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
>  	}
>  }
>  
> +#ifdef CONFIG_CMA_MIGRATE_TYPE
> +/*
> + * Free whole pageblock and set it's migration type to MIGRATE_CMA.
> + */
> +void __init init_cma_reserved_pageblock(struct page *page)
> +{
> +	struct page *p = page;
> +	unsigned i = pageblock_nr_pages;
> +
> +	prefetchw(p);
> +	do {
> +		if (--i)
> +			prefetchw(p + 1);

There is no need to use prefetch here. It's a sequential read by a fixed
stride. The hardware prefetcher on modern CPUs (well for x86 anyway) have
no problem identifying this sort of pattern.

> +		__ClearPageReserved(p);
> +		set_page_count(p, 0);
> +	} while (++p, i);
> +
> +	set_page_refcounted(page);
> +	set_pageblock_migratetype(page, MIGRATE_CMA);
> +	__free_pages(page, pageblock_order);
> +	totalram_pages += pageblock_nr_pages;
> +}
> +#endif
>  
>  /*
>   * The order of subdivision here is critical for the IO subsystem.
> @@ -841,11 +864,11 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>   * This array describes the order lists are fallen back to when
>   * the free lists for the desirable migrate type are depleted
>   */
> -static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
> +static int fallbacks[MIGRATE_TYPES][4] = {
>  	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
>  	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
> -	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
> -	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
> +	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_CMA    , MIGRATE_RESERVE },
> +	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
>  };
>  
>  /*
> @@ -940,12 +963,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  	/* Find the largest possible block of pages in the other list */
>  	for (current_order = MAX_ORDER-1; current_order >= order;
>  						--current_order) {
> -		for (i = 0; i < MIGRATE_TYPES - 1; i++) {
> +		for (i = 0; i < ARRAY_SIZE(fallbacks[0]); i++) {

I don't see why this change is necessary.

>  			migratetype = fallbacks[start_migratetype][i];
>  
>  			/* MIGRATE_RESERVE handled later if necessary */
>  			if (migratetype == MIGRATE_RESERVE)
> -				continue;
> +				break;
>  
>  			area = &(zone->free_area[current_order]);
>  			if (list_empty(&area->free_list[migratetype]))
> @@ -960,19 +983,29 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  			 * pages to the preferred allocation list. If falling
>  			 * back for a reclaimable kernel allocation, be more
>  			 * aggressive about taking ownership of free pages
> +			 *
> +			 * On the other hand, never change migration
> +			 * type of MIGRATE_CMA pageblocks nor move CMA
> +			 * pages on different free lists. We don't
> +			 * want unmovable pages to be allocated from
> +			 * MIGRATE_CMA areas.
>  			 */
> -			if (unlikely(current_order >= (pageblock_order >> 1)) ||
> -					start_migratetype == MIGRATE_RECLAIMABLE ||
> -					page_group_by_mobility_disabled) {
> -				unsigned long pages;
> +			if (!is_pageblock_cma(page) &&
> +			    (unlikely(current_order >= pageblock_order / 2) ||
> +			     start_migratetype == MIGRATE_RECLAIMABLE ||
> +			     page_group_by_mobility_disabled)) {
> +				int pages;
>  				pages = move_freepages_block(zone, page,
> -								start_migratetype);
> +							     start_migratetype);
>  
> -				/* Claim the whole block if over half of it is free */
> +				/*
> +				 * Claim the whole block if over half
> +				 * of it is free
> +				 */
>  				if (pages >= (1 << (pageblock_order-1)) ||
> -						page_group_by_mobility_disabled)
> +				    page_group_by_mobility_disabled)
>  					set_pageblock_migratetype(page,
> -								start_migratetype);
> +							start_migratetype);
>  

I only glanced through this because I'm thinking at this point that
MIGRATE_CMA should be like or identical to MIGRATE_RESERVE. That said, I
didn't spot anything obviously wrong other than some of the changes are
only affecting indentation.

>  				migratetype = start_migratetype;
>  			}
> @@ -982,11 +1015,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  			rmv_page_order(page);
>  
>  			/* Take ownership for orders >= pageblock_order */
> -			if (current_order >= pageblock_order)
> +			if (current_order >= pageblock_order &&
> +			    !is_pageblock_cma(page))
>  				change_pageblock_range(page, current_order,
>  							start_migratetype);
>  
> -			expand(zone, page, order, current_order, area, migratetype);
> +			expand(zone, page, order, current_order, area,
> +			       is_migrate_cma(start_migratetype)
> +			     ? start_migratetype : migratetype);
>  
>  			trace_mm_page_alloc_extfrag(page, order, current_order,
>  				start_migratetype, migratetype);
> @@ -1058,7 +1094,10 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			list_add(&page->lru, list);
>  		else
>  			list_add_tail(&page->lru, list);
> -		set_page_private(page, migratetype);
> +		if (is_pageblock_cma(page))
> +			set_page_private(page, MIGRATE_CMA);
> +		else
> +			set_page_private(page, migratetype);
>  		list = &page->lru;
>  	}
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> @@ -1302,7 +1341,9 @@ int split_free_page(struct page *page)
>  	if (order >= pageblock_order - 1) {
>  		struct page *endpage = page + (1 << order) - 1;
>  		for (; page < endpage; page += pageblock_nr_pages)
> -			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> +			if (!is_pageblock_cma(page))
> +				set_pageblock_migratetype(page,
> +							  MIGRATE_MOVABLE);
>  	}
>  
>  	return 1 << order;
> @@ -5592,8 +5633,8 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
>  	 */
>  	if (zone_idx(zone) == ZONE_MOVABLE)
>  		return true;
> -
> -	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE)
> +	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
> +	    is_pageblock_cma(page))
>  		return true;
>  
>  	pfn = page_to_pfn(page);
> -- 
> 1.7.1.569.g6f426
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
