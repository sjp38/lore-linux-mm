Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 4FB896B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 10:36:26 -0400 (EDT)
Date: Thu, 26 Apr 2012 15:36:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3] mm: compaction: handle incorrect Unmovable type
 pageblocks
Message-ID: <20120426143620.GF15299@suse.de>
References: <201204261015.54449.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201204261015.54449.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Thu, Apr 26, 2012 at 10:15:54AM +0200, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH v3] mm: compaction: handle incorrect Unmovable type pageblocks
> 
> When Unmovable pages are freed from Unmovable type pageblock
> (and some Movable type pages are left in it) the type of
> the pageblock remains unchanged and therefore the pageblock
> cannot be used as a migration target during compaction.
> 

Add a note saying that waiting until an allocation takes ownership of
the block may take too long.

> Fix it by:
> 
> * Adding enum compaction_mode (COMPACTION_ASYNC_PARTIAL,
>   COMPACTION_ASYNC_FULL and COMPACTION_SYNC) and then converting
>   sync field in struct compact_control to use it.
> 

Other compaction constants use just COMPACT such as COMPACT_CONTINUE,
COMPACT_SKIPPED and so on. I suggest you do the same and use
COMPACT_ASYNC_PARTIAL, COMPACT_ASYNC_FULL and COMPACT_SYNC.

> * Scanning the Unmovable pageblocks (during COMPACTION_ASYNC_FULL
>   and COMPACTION_SYNC compactions) and building a count based on
>   finding PageBuddy pages, page_count(page) == 0 or PageLRU pages.
>   If all pages within the Unmovable pageblock are in one of those
>   three sets change the whole pageblock type to Movable.
> 

Good.

> My particular test case (on a ARM EXYNOS4 device with 512 MiB,
> which means 131072 standard 4KiB pages in 'Normal' zone) is to:
> - allocate 120000 pages for kernel's usage
> - free every second page (60000 pages) of memory just allocated
> - allocate and use 60000 pages from user space
> - free remaining 60000 pages of kernel memory
> (now we have fragmented memory occupied mostly by user space pages)
> - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
> 
> The results:
> - with compaction disabled I get 11 successful allocations
> - with compaction enabled - 14 successful allocations
> - with this patch I'm able to get all 100 successful allocations
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
> v2: redo the patch basing on review from Mel Gorman.
>     (http://marc.info/?l=linux-mm&m=133519311025444&w=2)
> v3: apply review comments from Minchan Kim.
>     (http://marc.info/?l=linux-mm&m=133531540308862&w=2)
> 
>  include/linux/compaction.h |   21 ++++++++++++++-
>  mm/compaction.c            |   61 +++++++++++++++++++++++++++++++++------------
>  mm/internal.h              |    6 +++-
>  mm/page_alloc.c            |   24 ++++++++---------
>  4 files changed, 82 insertions(+), 30 deletions(-)
> 
> Index: b/include/linux/compaction.h
> ===================================================================
> --- a/include/linux/compaction.h	2012-04-25 17:57:06.000000000 +0200
> +++ b/include/linux/compaction.h	2012-04-26 09:58:54.272510940 +0200
> @@ -1,6 +1,8 @@
>  #ifndef _LINUX_COMPACTION_H
>  #define _LINUX_COMPACTION_H
>  
> +#include <linux/node.h>
> +
>  /* Return values for compact_zone() and try_to_compact_pages() */
>  /* compaction didn't start as it was not possible or direct reclaim was more suitable */
>  #define COMPACT_SKIPPED		0
> @@ -11,6 +13,21 @@
>  /* The full zone was compacted */
>  #define COMPACT_COMPLETE	3
>  
> +/*
> + * ASYNC_PARTIAL uses asynchronous migration and scans only Movable
> + * pageblocks for pages to migrate from, ASYNC_FULL additionally
> + * scans Unmovable pageblocks (for use as migration target pages)
> + * and converts them to Movable ones if possible, SYNC uses
> + * synchronous migration, scans all pageblocks for pages to migrate
> + * from and also scans Unmovable pageblocks (for use as migration
> + * target pages) and converts them to Movable ones if possible.
> + */

This comment could be less ambiguous. How about the following?

/*
 * compaction supports three modes
 *
 * COMPACT_ASYNC_PARTIAL uses asynchronous migration and only scans
 *    MIGRATE_MOVABLE pageblocks as migration sources and targets.
 * COMPACT_ASYNC_FULL uses asynchronous migration and only scans
 *    MIGRATE_MOVABLE pageblocks as migration sources.
 *    MIGRATE_UNMOVABLE pageblocks are scanned as potential migration
 *    targets and convers them to MIGRATE_MOVABLE if possible
 * COMPACT_SYNC uses synchronous migration and scans all pageblocks
 */

> +enum compaction_mode {
> +	COMPACTION_ASYNC_PARTIAL,
> +	COMPACTION_ASYNC_FULL,
> +	COMPACTION_SYNC,
> +};
> +
>  #ifdef CONFIG_COMPACTION
>  extern int sysctl_compact_memory;
>  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> @@ -22,7 +39,7 @@
>  extern int fragmentation_index(struct zone *zone, unsigned int order);
>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *mask,
> -			bool sync);
> +			enum compaction_mode mode);

Same for the naming. The control structure is called compact_control so
make the mode compact_mode as well for consistency.

>  extern int compact_pgdat(pg_data_t *pgdat, int order);
>  extern unsigned long compaction_suitable(struct zone *zone, int order);
>  
> @@ -64,7 +81,7 @@
>  #else
>  static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *nodemask,
> -			bool sync)
> +			enum compaction_mode mode)
>  {
>  	return COMPACT_CONTINUE;
>  }
> Index: b/mm/compaction.c
> ===================================================================
> --- a/mm/compaction.c	2012-04-25 17:57:09.000000000 +0200
> +++ b/mm/compaction.c	2012-04-26 10:14:09.880510831 +0200
> @@ -235,7 +235,7 @@
>  	 */
>  	while (unlikely(too_many_isolated(zone))) {
>  		/* async migration should just abort */
> -		if (!cc->sync)
> +		if (cc->mode != COMPACTION_SYNC)
>  			return 0;
>  
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -303,7 +303,8 @@
>  		 * satisfies the allocation
>  		 */
>  		pageblock_nr = low_pfn >> pageblock_order;
> -		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
> +		if (cc->mode != COMPACTION_SYNC &&
> +		    last_pageblock_nr != pageblock_nr &&
>  		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
>  			low_pfn += pageblock_nr_pages;
>  			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
> @@ -324,7 +325,7 @@
>  			continue;
>  		}
>  
> -		if (!cc->sync)
> +		if (cc->mode != COMPACTION_SYNC)
>  			mode |= ISOLATE_ASYNC_MIGRATE;
>  
>  		/* Try isolate the page */
> @@ -357,9 +358,33 @@
>  
>  #endif /* CONFIG_COMPACTION || CONFIG_CMA */
>  #ifdef CONFIG_COMPACTION
> +static bool rescue_unmovable_pageblock(struct page *page)
> +{
> +	unsigned long pfn, start_pfn, end_pfn;
> +
> +	pfn = page_to_pfn(page);
> +	start_pfn = pfn & ~(pageblock_nr_pages - 1);
> +	end_pfn = start_pfn + pageblock_nr_pages;
> +
> +	for (pfn = start_pfn; pfn < end_pfn;) {
> +		page = pfn_to_page(pfn);
> +

pfn_to_page() is not cheap at all.

What you need to do avoid the lookup every time and also deal with
pageblocks that straddle zones is something like this

start_page = pfn_to_page(start_pfn)
end_page = pfn_to_page(end_pfn)
/* Do not deal with pageblocks that overlap zones */
if (page_zone(start_page) != page_zone(end_page))
	return;

for (page = start_page, pfn = start_pfn; page < end_page; pfn++, page++)

This avoids doing a PFN lookup every time and will be faster. On ARM,
you also have to call pfn_valid_within so

	if (!pfn_valid_within(pfn))
		continue;

> +		if (PageBuddy(page))
> +			pfn += (1 << page_order(page));

If you use the for loop I have above, you will need to update both pfn
and page and put in a -1

pfn += (1 << page_order(page)) - 1;
page += (1 << page_order(page)) - 1;


> +		else if (page_count(page) == 0 || PageLRU(page))
> +			pfn++;

This would become "continue"

> +		else
> +			return false;

The else is unnecessary there, just return false.

> +	}
> +
> +	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> +	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
> +	return true;
> +}

Despite all my complaining, this function looks more or less like what I
expected.

>  
>  /* Returns true if the page is within a block suitable for migration to */
> -static bool suitable_migration_target(struct page *page)
> +static bool suitable_migration_target(struct page *page,
> +				      enum compaction_mode mode)
>  {
>  
>  	int migratetype = get_pageblock_migratetype(page);
> @@ -376,6 +401,11 @@
>  	if (migrate_async_suitable(migratetype))
>  		return true;
>  
> +	if ((mode == COMPACTION_ASYNC_FULL || mode == COMPACTION_SYNC) &&

mode != COMPACT_ASYNC_PARTIAL ?

> +	    migratetype == MIGRATE_UNMOVABLE &&
> +	    rescue_unmovable_pageblock(page))
> +		return true;
> +
>  	/* Otherwise skip the block */
>  	return false;
>  }
> @@ -434,7 +464,7 @@
>  			continue;
>  
>  		/* Check the block is suitable for migration */
> -		if (!suitable_migration_target(page))
> +		if (!suitable_migration_target(page, cc->mode))
>  			continue;
>  
>  		/*
> @@ -445,7 +475,7 @@
>  		 */
>  		isolated = 0;
>  		spin_lock_irqsave(&zone->lock, flags);
> -		if (suitable_migration_target(page)) {
> +		if (suitable_migration_target(page, cc->mode)) {
>  			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
>  			isolated = isolate_freepages_block(pfn, end_pfn,
>  							   freelist, false);
> @@ -682,8 +712,9 @@
>  
>  		nr_migrate = cc->nr_migratepages;
>  		err = migrate_pages(&cc->migratepages, compaction_alloc,
> -				(unsigned long)cc, false,
> -				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
> +			(unsigned long)cc, false,
> +			(cc->mode == COMPACTION_SYNC) ? MIGRATE_SYNC_LIGHT
> +						      : MIGRATE_ASYNC);
>  		update_nr_listpages(cc);
>  		nr_remaining = cc->nr_migratepages;
>  
> @@ -712,7 +743,7 @@
>  
>  static unsigned long compact_zone_order(struct zone *zone,
>  				 int order, gfp_t gfp_mask,
> -				 bool sync)
> +				 enum compaction_mode mode)
>  {
>  	struct compact_control cc = {
>  		.nr_freepages = 0,
> @@ -720,7 +751,7 @@
>  		.order = order,
>  		.migratetype = allocflags_to_migratetype(gfp_mask),
>  		.zone = zone,
> -		.sync = sync,
> +		.mode = mode,
>  	};
>  	INIT_LIST_HEAD(&cc.freepages);
>  	INIT_LIST_HEAD(&cc.migratepages);
> @@ -742,7 +773,7 @@
>   */
>  unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *nodemask,
> -			bool sync)
> +			enum compaction_mode mode)
>  {
>  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
>  	int may_enter_fs = gfp_mask & __GFP_FS;
> @@ -766,7 +797,7 @@
>  								nodemask) {
>  		int status;
>  
> -		status = compact_zone_order(zone, order, gfp_mask, sync);
> +		status = compact_zone_order(zone, order, gfp_mask, mode);
>  		rc = max(status, rc);
>  
>  		/* If a normal allocation would succeed, stop compacting */
> @@ -805,7 +836,7 @@
>  			if (ok && cc->order > zone->compact_order_failed)
>  				zone->compact_order_failed = cc->order + 1;
>  			/* Currently async compaction is never deferred. */
> -			else if (!ok && cc->sync)
> +			else if (!ok && cc->mode == COMPACTION_SYNC)
>  				defer_compaction(zone, cc->order);
>  		}
>  
> @@ -820,7 +851,7 @@
>  {
>  	struct compact_control cc = {
>  		.order = order,
> -		.sync = false,
> +		.mode = COMPACTION_ASYNC_FULL,
>  	};
>  
>  	return __compact_pgdat(pgdat, &cc);
> @@ -830,7 +861,7 @@
>  {
>  	struct compact_control cc = {
>  		.order = -1,
> -		.sync = true,
> +		.mode = COMPACTION_SYNC,
>  	};
>  
>  	return __compact_pgdat(NODE_DATA(nid), &cc);
> Index: b/mm/internal.h
> ===================================================================
> --- a/mm/internal.h	2012-04-25 17:57:09.000000000 +0200
> +++ b/mm/internal.h	2012-04-26 09:58:15.024510943 +0200
> @@ -94,6 +94,9 @@
>  /*
>   * in mm/page_alloc.c
>   */
> +extern void set_pageblock_migratetype(struct page *page, int migratetype);
> +extern int move_freepages_block(struct zone *zone, struct page *page,
> +				int migratetype);
>  extern void __free_pages_bootmem(struct page *page, unsigned int order);
>  extern void prep_compound_page(struct page *page, unsigned long order);
>  #ifdef CONFIG_MEMORY_FAILURE
> @@ -101,6 +104,7 @@
>  #endif
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +#include <linux/compaction.h>
>  
>  /*
>   * in mm/compaction.c
> @@ -119,7 +123,7 @@
>  	unsigned long nr_migratepages;	/* Number of pages to migrate */
>  	unsigned long free_pfn;		/* isolate_freepages search base */
>  	unsigned long migrate_pfn;	/* isolate_migratepages search base */
> -	bool sync;			/* Synchronous migration */
> +	enum compaction_mode mode;	/* partial/full/sync compaction */
>  
>  	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c	2012-04-25 17:57:09.000000000 +0200
> +++ b/mm/page_alloc.c	2012-04-26 10:02:48.756510912 +0200
> @@ -232,7 +232,7 @@
>  
>  int page_group_by_mobility_disabled __read_mostly;
>  
> -static void set_pageblock_migratetype(struct page *page, int migratetype)
> +void set_pageblock_migratetype(struct page *page, int migratetype)
>  {
>  
>  	if (unlikely(page_group_by_mobility_disabled))
> @@ -967,8 +967,8 @@
>  	return pages_moved;
>  }
>  
> -static int move_freepages_block(struct zone *zone, struct page *page,
> -				int migratetype)
> +int move_freepages_block(struct zone *zone, struct page *page,
> +			 int migratetype)
>  {
>  	unsigned long start_pfn, end_pfn;
>  	struct page *start_page, *end_page;
> @@ -2074,7 +2074,7 @@
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	struct zonelist *zonelist, enum zone_type high_zoneidx,
>  	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
> -	int migratetype, bool sync_migration,
> +	int migratetype, enum compaction_mode migration_mode,
>  	bool *deferred_compaction,
>  	unsigned long *did_some_progress)
>  {
> @@ -2090,7 +2090,7 @@
>  
>  	current->flags |= PF_MEMALLOC;
>  	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
> -						nodemask, sync_migration);
> +						nodemask, migration_mode);
>  	current->flags &= ~PF_MEMALLOC;
>  	if (*did_some_progress != COMPACT_SKIPPED) {
>  
> @@ -2122,7 +2122,7 @@
>  		 * As async compaction considers a subset of pageblocks, only
>  		 * defer if the failure was a sync compaction failure.
>  		 */
> -		if (sync_migration)
> +		if (migration_mode == COMPACTION_SYNC)
>  			defer_compaction(preferred_zone, order);
>  
>  		cond_resched();
> @@ -2135,7 +2135,7 @@
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	struct zonelist *zonelist, enum zone_type high_zoneidx,
>  	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
> -	int migratetype, bool sync_migration,
> +	int migratetype, enum compaction_mode migration_mode,
>  	bool *deferred_compaction,
>  	unsigned long *did_some_progress)
>  {
> @@ -2298,7 +2298,7 @@
>  	int alloc_flags;
>  	unsigned long pages_reclaimed = 0;
>  	unsigned long did_some_progress;
> -	bool sync_migration = false;
> +	enum compaction_mode migration_mode = COMPACTION_ASYNC_PARTIAL;
>  	bool deferred_compaction = false;
>  
>  	/*
> @@ -2380,12 +2380,12 @@
>  					zonelist, high_zoneidx,
>  					nodemask,
>  					alloc_flags, preferred_zone,
> -					migratetype, sync_migration,
> +					migratetype, migration_mode,
>  					&deferred_compaction,
>  					&did_some_progress);
>  	if (page)
>  		goto got_pg;
> -	sync_migration = true;
> +	migration_mode = COMPACTION_SYNC;
>  

Hmm, at what point does COMPACT_ASYNC_FULL get used? I see it gets
used for the proc interface but it's not used via the page allocator at
all.

Minimally I was expecting to see if being used from the page allocator.

A better option might be to track the number of MIGRATE_UNMOVABLE blocks that
were skipped over during COMPACT_ASYNC_PARTIAL and if it was a high
percentage and it looked like compaction failed then to retry with
COMPACT_ASYNC_FULL. If you took this option, try_to_compact_pages()
would still only take sync as a parameter and keep the decision within
compaction.c

>  	/*
>  	 * If compaction is deferred for high-order allocations, it is because
> @@ -2463,7 +2463,7 @@
>  					zonelist, high_zoneidx,
>  					nodemask,
>  					alloc_flags, preferred_zone,
> -					migratetype, sync_migration,
> +					migratetype, migration_mode,
>  					&deferred_compaction,
>  					&did_some_progress);
>  		if (page)
> @@ -5673,7 +5673,7 @@
>  		.nr_migratepages = 0,
>  		.order = -1,
>  		.zone = page_zone(pfn_to_page(start)),
> -		.sync = true,
> +		.mode = COMPACTION_SYNC,
>  	};
>  	INIT_LIST_HEAD(&cc.migratepages);
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
