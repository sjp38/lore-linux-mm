Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 982006B004D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 18:49:28 -0400 (EDT)
Date: Mon, 7 May 2012 15:49:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
Message-Id: <20120507154926.e9ea8b3e.akpm@linux-foundation.org>
In-Reply-To: <201205071146.22736.b.zolnierkie@samsung.com>
References: <201205071146.22736.b.zolnierkie@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Mon, 07 May 2012 11:46:22 +0200
Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> wrote:

> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH v7] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type pageblocks

I have a bunch of minorish things..

> When MIGRATE_UNMOVABLE pages are freed from MIGRATE_UNMOVABLE
> type pageblock (and some MIGRATE_MOVABLE pages are left in it)
> waiting until an allocation takes ownership of the block may
> take too long.  The type of the pageblock remains unchanged
> so the pageblock cannot be used as a migration target during
> compaction.
> 
> Fix it by:
> 
> * Adding enum compact_mode (COMPACT_ASYNC_[MOVABLE,UNMOVABLE],
>   and COMPACT_SYNC) and then converting sync field in struct
>   compact_control to use it.
> 
> * Adding nr_pageblocks_skipped field to struct compact_control
>   and tracking how many destination pageblocks were of
>   MIGRATE_UNMOVABLE type.  If COMPACT_ASYNC_MOVABLE mode compaction
>   ran fully in try_to_compact_pages() (COMPACT_COMPLETE) it implies
>   that there is not a suitable page for allocation.  In this case
>   then check how if there were enough MIGRATE_UNMOVABLE pageblocks
>   to try a second pass in COMPACT_ASYNC_UNMOVABLE mode.
> 
> * Scanning the MIGRATE_UNMOVABLE pageblocks (during COMPACT_SYNC
>   and COMPACT_ASYNC_UNMOVABLE compaction modes) and building
>   a count based on finding PageBuddy pages, page_count(page) == 0
>   or PageLRU pages.  If all pages within the MIGRATE_UNMOVABLE
>   pageblock are in one of those three sets change the whole
>   pageblock type to MIGRATE_MOVABLE.
> 
> 
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
> 
> NOTE: If we can make kswapd aware of order-0 request during
> compaction, we can enhance kswapd with changing mode to
> COMPACT_ASYNC_FULL (COMPACT_ASYNC_MOVABLE + COMPACT_ASYNC_UNMOVABLE).
> Please see the following thread:
> 
> 	http://marc.info/?l=linux-mm&m=133552069417068&w=2
> 
> 
> Minor cleanups from Minchan Kim.

A common way to do this sort of thing is to add

[minchan@kernel.org: minor cleanups]

just before the Cc: list, and to also Cc: that person in the Cc: list. 
At least, that's what I do, and that makes it common ;)

>
> ...
>
> --- a/include/linux/compaction.h	2012-05-07 11:34:50.000000000 +0200
> +++ b/include/linux/compaction.h	2012-05-07 11:35:29.032707770 +0200
> @@ -1,6 +1,8 @@
>  #ifndef _LINUX_COMPACTION_H
>  #define _LINUX_COMPACTION_H
>  
> +#include <linux/node.h>
> +
>  /* Return values for compact_zone() and try_to_compact_pages() */
>  /* compaction didn't start as it was not possible or direct reclaim was more suitable */
>  #define COMPACT_SKIPPED		0
> @@ -11,6 +13,23 @@
>  /* The full zone was compacted */
>  #define COMPACT_COMPLETE	3
>  
> +/*
> + * compaction supports three modes
> + *
> + * COMPACT_ASYNC_MOVABLE uses asynchronous migration and only scans
> + *    MIGRATE_MOVABLE pageblocks as migration sources and targets.
> + * COMPACT_ASYNC_UNMOVABLE uses asynchronous migration and only scans
> + *    MIGRATE_MOVABLE pageblocks as migration sources.
> + *    MIGRATE_UNMOVABLE pageblocks are scanned as potential migration
> + *    targets and convers them to MIGRATE_MOVABLE if possible
> + * COMPACT_SYNC uses synchronous migration and scans all pageblocks
> + */
> +enum compact_mode {
> +	COMPACT_ASYNC_MOVABLE,
> +	COMPACT_ASYNC_UNMOVABLE,
> +	COMPACT_SYNC,
> +};

Why was the include <linux/node.h> added?  The enum definition didn't
need that.

>  #ifdef CONFIG_COMPACTION
>  extern int sysctl_compact_memory;
>  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> Index: b/mm/compaction.c
> ===================================================================
> --- a/mm/compaction.c	2012-05-07 11:34:53.000000000 +0200
> +++ b/mm/compaction.c	2012-05-07 11:39:06.668707335 +0200
> @@ -235,7 +235,7 @@
>  	 */
>  	while (unlikely(too_many_isolated(zone))) {
>  		/* async migration should just abort */
> -		if (!cc->sync)
> +		if (cc->mode != COMPACT_SYNC)
>  			return 0;
>  
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -303,7 +303,8 @@
>  		 * satisfies the allocation
>  		 */
>  		pageblock_nr = low_pfn >> pageblock_order;
> -		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
> +		if (cc->mode != COMPACT_SYNC &&
> +		    last_pageblock_nr != pageblock_nr &&
>  		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
>  			low_pfn += pageblock_nr_pages;
>  			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
> @@ -324,7 +325,7 @@
>  			continue;
>  		}
>  
> -		if (!cc->sync)
> +		if (cc->mode != COMPACT_SYNC)
>  			mode |= ISOLATE_ASYNC_MIGRATE;
>  
>  		/* Try isolate the page */
> @@ -357,27 +358,82 @@
>  
>  #endif /* CONFIG_COMPACTION || CONFIG_CMA */
>  #ifdef CONFIG_COMPACTION
> +static bool rescue_unmovable_pageblock(struct page *page)

This could do with a bit of documentation.  It returns a bool, but what
does that bool *mean*?  Presumably it means "it worked".  But what was
"it"?

> +{
> +	unsigned long pfn, start_pfn, end_pfn;
> +	struct page *start_page, *end_page;
> +
> +	pfn = page_to_pfn(page);
> +	start_pfn = pfn & ~(pageblock_nr_pages - 1);

Could use round_down() here, but that doesn't add much if any value IMO.

> +	end_pfn = start_pfn + pageblock_nr_pages;
> +
> +	start_page = pfn_to_page(start_pfn);
> +	end_page = pfn_to_page(end_pfn);
> +
> +	/* Do not deal with pageblocks that overlap zones */
> +	if (page_zone(start_page) != page_zone(end_page))
> +		return false;
> +
> +	for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
> +								  page++) {
> +		if (!pfn_valid_within(pfn))
> +			continue;
> +
> +		if (PageBuddy(page)) {
> +			int order = page_order(page);
> +
> +			pfn += (1 << order) - 1;
> +			page += (1 << order) - 1;
> +
> +			continue;
> +		} else if (page_count(page) == 0 || PageLRU(page))
> +			continue;
> +
> +		return false;
> +	}
> +
> +	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> +	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
> +	return true;
> +}
> +
> +enum result_smt {

<thinks for a while>

Ah, I get it: "smt" = "suitable_migration_target".  So "smt_result"
would be a better name.


> +	GOOD_AS_MIGRATION_TARGET,
> +	FAIL_UNMOVABLE,
> +	FAIL_ETC_REASON,

But I can't work out what ETC means.

> +};
>  
>  /* Returns true if the page is within a block suitable for migration to */

This comment is now incorrect.

> -static bool suitable_migration_target(struct page *page)
> +static enum result_smt suitable_migration_target(struct page *page,
> +				      struct compact_control *cc)
>  {
>  
>  	int migratetype = get_pageblock_migratetype(page);
>  
>  	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
>  	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
> -		return false;
> +		return FAIL_ETC_REASON;
>  
>  	/* If the page is a large free page, then allow migration */
>  	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> -		return true;
> +		return GOOD_AS_MIGRATION_TARGET;
>  
>  	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> -	if (migrate_async_suitable(migratetype))
> -		return true;
> +	if (cc->mode != COMPACT_ASYNC_UNMOVABLE &&
> +	    migrate_async_suitable(migratetype))
> +		return GOOD_AS_MIGRATION_TARGET;
> +
> +	if (cc->mode == COMPACT_ASYNC_MOVABLE &&
> +	    migratetype == MIGRATE_UNMOVABLE)
> +		return FAIL_UNMOVABLE;
> +
> +	if (cc->mode != COMPACT_ASYNC_MOVABLE &&
> +	    migratetype == MIGRATE_UNMOVABLE &&
> +	    rescue_unmovable_pageblock(page))
> +		return GOOD_AS_MIGRATION_TARGET;
>  
>  	/* Otherwise skip the block */
> -	return false;
> +	return FAIL_ETC_REASON;
>  }
>  
>  /*
> @@ -410,6 +466,8 @@
>  
>  	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
>  
> +	cc->nr_pageblocks_skipped = 0;

The handling of nr_pageblocks_skipped is awkward - we're repeatedly
clearing a field in the compaction_control at a quite different level
from the other parts of the code and there's a decent chance of us
screwing up the ->nr_pageblocks_skipped protocol in the future.

Do we need to add it at all?  Would it be cleaner to add a ulong*
argument to migrate_pages()?

Alternatively, can we initialise nr_pageblocks_skipped in
compact_zone_order(), alongside everything else?  If that doesn't work
then we must be rezeroing this field multiople times in the lifetime of
a single compact_control.  That's an odd thing to do, so please let's
at least document the ->nr_pageblocks_skipped protocol carefully.

>  	/*
>  	 * Isolate free pages until enough are available to migrate the
>  	 * pages on cc->migratepages. We stop searching if the migrate
>
> ...
>
> @@ -682,8 +745,9 @@
>  
>  		nr_migrate = cc->nr_migratepages;
>  		err = migrate_pages(&cc->migratepages, compaction_alloc,
> -				(unsigned long)cc, false,
> -				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
> +			(unsigned long)cc, false,

ugh ugh.  The code is (and was) assuming that the fist field in the
compact_control is a list_head.  Please let's use container_of(cc,
struct list_head, freepages).


> +			(cc->mode == COMPACT_SYNC) ? MIGRATE_SYNC_LIGHT
> +						      : MIGRATE_ASYNC);
>  		update_nr_listpages(cc);
>  		nr_remaining = cc->nr_migratepages;
>  
>
> ...
>
> --- a/mm/internal.h	2012-05-07 11:34:53.000000000 +0200
> +++ b/mm/internal.h	2012-05-07 11:36:57.548707591 +0200
> @@ -95,6 +95,9 @@
>  /*
>   * in mm/page_alloc.c
>   */
> +extern void set_pageblock_migratetype(struct page *page, int migratetype);
> +extern int move_freepages_block(struct zone *zone, struct page *page,
> +				int migratetype);
>  extern void __free_pages_bootmem(struct page *page, unsigned int order);
>  extern void prep_compound_page(struct page *page, unsigned long order);
>  #ifdef CONFIG_MEMORY_FAILURE
> @@ -102,6 +105,7 @@
>  #endif
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +#include <linux/compaction.h>

It's a bit ungainly to include compaction.h from within internal.h. 
And it's a bit dangerous when this is donw halfway through the file,
inside ifdefs.

For mm/internal.h I think it's reasonable to require that the .c file
has provided internal.h's prerequisites.  This will improve compilation
speed a tad as well.  So let's proceed your way for now, but perhaps
someone can come up with a cleanup patch sometime which zaps the
#includes from internal.h

Alternatively: enums are awkward because they can't be forward-declared
(probably because the compiler can choose different sizeof(enum foo),
based on the enum's value range).  One way around this is to place the
enum's definition in its own little header file.

>  /*
>   * in mm/compaction.c
> @@ -120,11 +124,14 @@
>  	unsigned long nr_migratepages;	/* Number of pages to migrate */
>  	unsigned long free_pfn;		/* isolate_freepages search base */
>  	unsigned long migrate_pfn;	/* isolate_migratepages search base */
> -	bool sync;			/* Synchronous migration */
> +	enum compact_mode mode;		/* Compaction mode */
>  
>  	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
>  	struct zone *zone;
> +
> +	/* Number of UNMOVABLE destination pageblocks skipped during scan */
> +	unsigned long nr_pageblocks_skipped;
>  };
>  
>  unsigned long
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
