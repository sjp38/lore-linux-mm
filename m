Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 10B036B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 07:35:47 -0500 (EST)
Date: Mon, 30 Jan 2012 12:35:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/15] mm: mmzone: MIGRATE_CMA migration type added
Message-ID: <20120130123542.GL25268@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-9-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1327568457-27734-9-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Jan 26, 2012 at 10:00:50AM +0100, Marek Szyprowski wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
> 
> The MIGRATE_CMA migration type has two main characteristics:
> (i) only movable pages can be allocated from MIGRATE_CMA
> pageblocks and (ii) page allocator will never change migration
> type of MIGRATE_CMA pageblocks.
> 
> This guarantees (to some degree) that page in a MIGRATE_CMA page
> block can always be migrated somewhere else (unless there's no
> memory left in the system).
> 
> It is designed to be used for allocating big chunks (eg. 10MiB)
> of physically contiguous memory.  Once driver requests
> contiguous memory, pages from MIGRATE_CMA pageblocks may be
> migrated away to create a contiguous block.
> 
> To minimise number of migrations, MIGRATE_CMA migration type
> is the last type tried when page allocator falls back to other
> migration types then requested.
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  include/linux/mmzone.h         |   43 +++++++++++++++++++++----
>  include/linux/page-isolation.h |    3 ++
>  mm/Kconfig                     |    2 +-
>  mm/compaction.c                |   11 +++++--
>  mm/page_alloc.c                |   68 +++++++++++++++++++++++++++++++++-------
>  mm/vmstat.c                    |    3 ++
>  6 files changed, 107 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 650ba2f..fcd4a14 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -35,13 +35,37 @@
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
> +#ifdef CONFIG_CMA
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
> +#endif
> +	MIGRATE_ISOLATE,	/* can't allocate from here */
> +	MIGRATE_TYPES
> +};
> +
> +#ifdef CONFIG_CMA
> +#  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
> +#else
> +#  define is_migrate_cma(migratetype) false
> +#endif
>  
>  #define for_each_migratetype_order(order, type) \
>  	for (order = 0; order < MAX_ORDER; order++) \
> @@ -54,6 +78,11 @@ static inline int get_pageblock_migratetype(struct page *page)
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
> index 430cf61..454dd29 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -45,6 +45,9 @@ extern void unset_migratetype_isolate(struct page *page);
>  extern int alloc_contig_range(unsigned long start, unsigned long end);
>  extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>  
> +/* CMA stuff */
> +extern void init_cma_reserved_pageblock(struct page *page);
> +
>  #endif
>  
>  #endif
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e338407..3922002 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -198,7 +198,7 @@ config COMPACTION
>  config MIGRATION
>  	bool "Page migration"
>  	def_bool y
> -	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION
> +	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA
>  	help
>  	  Allows the migration of the physical location of pages of processes
>  	  while the virtual addresses are not changed. This is useful in
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 3e21d28..a075b43 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -35,6 +35,11 @@ static unsigned long release_freepages(struct list_head *freelist)
>  	return count;
>  }
>  
> +static inline bool migrate_async_suitable(int migratetype)
> +{
> +	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
> +}
> +
>  /*
>   * Isolate free pages onto a private freelist. Caller must hold zone->lock.
>   * If @strict is true, will abort returning 0 on any invalid PFNs or non-free
> @@ -274,7 +279,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  		 */
>  		pageblock_nr = low_pfn >> pageblock_order;
>  		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
> -				get_pageblock_migratetype(page) != MIGRATE_MOVABLE) {
> +		    migrate_async_suitable(get_pageblock_migratetype(page))) {
>  			low_pfn += pageblock_nr_pages;
>  			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
>  			last_pageblock_nr = pageblock_nr;
> @@ -342,8 +347,8 @@ static bool suitable_migration_target(struct page *page)
>  	if (PageBuddy(page) && page_order(page) >= pageblock_order)
>  		return true;
>  
> -	/* If the block is MIGRATE_MOVABLE, allow migration */
> -	if (migratetype == MIGRATE_MOVABLE)
> +	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> +	if (migrate_async_suitable(migratetype))
>  		return true;
>  
>  	/* Otherwise skip the block */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0a9cc8e..0fcde78 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -750,6 +750,26 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
>  	__free_pages(page, order);
>  }
>  
> +#ifdef CONFIG_CMA
> +/*
> + * Free whole pageblock and set it's migration type to MIGRATE_CMA.
> + */
> +void __init init_cma_reserved_pageblock(struct page *page)
> +{
> +	unsigned i = pageblock_nr_pages;
> +	struct page *p = page;
> +
> +	do {
> +		__ClearPageReserved(p);
> +		set_page_count(p, 0);
> +	} while (++p, --i);
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
> @@ -875,10 +895,15 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>   * This array describes the order lists are fallen back to when
>   * the free lists for the desirable migrate type are depleted
>   */
> -static int fallbacks[MIGRATE_TYPES][3] = {
> +static int fallbacks[MIGRATE_TYPES][4] = {
>  	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
>  	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
> +#ifdef CONFIG_CMA
> +	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_CMA    , MIGRATE_RESERVE },

This is a curious choice. MIGRATE_CMA is allowed to contain movable
pages. By using MIGRATE_RECLAIMABLE and MIGRATE_UNMOVABLE for movable
pages instead of MIGRATE_CMA, you increase the changes that unmovable
pages will need to use MIGRATE_MOVABLE in the future which impacts
fragmentation avoidance. I would recommend that you change this to

{ MIGRATE_CMA, MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE }

> +	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
> +#else
>  	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
> +#endif
>  	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
>  	[MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
>  };

You should also be aware that you may have problems with zone
balancing. If MIGRATE_CMA is large and it is the only free memory
then UNMOVABLE and RECLAIMABLE allocations will fail. kswapd will
not necessarily help because it is checking the watermarks and the
watermarks may be fine. It's actually the reason ZONE_MOVABLE was
created originally.

> @@ -995,11 +1020,18 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
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

You call is_pageblock_cma(page) here which in turn calls
get_pageblock_migratetype(). get_pageblock_migratetype() should be
avoided where possible and it is unecessary in this context because
we know what the migratetype of page. Use that information instead of
calling get_pageblock_migratetype().

>  				pages = move_freepages_block(zone, page,
>  								start_migratetype);
>  
> @@ -1017,11 +1049,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  			rmv_page_order(page);
>  
>  			/* Take ownership for orders >= pageblock_order */
> -			if (current_order >= pageblock_order)
> +			if (current_order >= pageblock_order &&
> +			    !is_pageblock_cma(page))

Same, the get_pageblock_migratetype() call can be avoided.

>  				change_pageblock_range(page, current_order,
>  							start_migratetype);
>  
> -			expand(zone, page, order, current_order, area, migratetype);
> +			expand(zone, page, order, current_order, area,
> +			       is_migrate_cma(start_migratetype)
> +			     ? start_migratetype : migratetype);
>  

What is this check meant to be doing?

start_migratetype is determined by allocflags_to_migratetype() and
that never will be MIGRATE_CMA so is_migrate_cma(start_migratetype)
should always be false.

>  			trace_mm_page_alloc_extfrag(page, order, current_order,
>  				start_migratetype, migratetype);
> @@ -1093,7 +1128,12 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			list_add(&page->lru, list);
>  		else
>  			list_add_tail(&page->lru, list);
> -		set_page_private(page, migratetype);
> +#ifdef CONFIG_CMA
> +		if (is_pageblock_cma(page))
> +			set_page_private(page, MIGRATE_CMA);
> +		else
> +#endif
> +			set_page_private(page, migratetype);
>  		list = &page->lru;
>  	}
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> @@ -1337,8 +1377,12 @@ int split_free_page(struct page *page)
>  
>  	if (order >= pageblock_order - 1) {
>  		struct page *endpage = page + (1 << order) - 1;
> -		for (; page < endpage; page += pageblock_nr_pages)
> -			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> +		for (; page < endpage; page += pageblock_nr_pages) {
> +			int mt = get_pageblock_migratetype(page);
> +			if (mt != MIGRATE_ISOLATE && !is_migrate_cma(mt))
> +				set_pageblock_migratetype(page,
> +							  MIGRATE_MOVABLE);
> +		}
>  	}
>  
>  	return 1 << order;
> @@ -5375,8 +5419,8 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
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
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index f600557..ace5383 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -613,6 +613,9 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
>  	"Reclaimable",
>  	"Movable",
>  	"Reserve",
> +#ifdef CONFIG_CMA
> +	"CMA",
> +#endif
>  	"Isolate",
>  };
>  
> -- 
> 1.7.1.569.g6f426
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
