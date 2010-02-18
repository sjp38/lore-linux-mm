Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CB0156B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 11:58:53 -0500 (EST)
Received: by pwj7 with SMTP id 7so1332769pwj.14
        for <linux-mm@kvack.org>; Thu, 18 Feb 2010 08:58:51 -0800 (PST)
Subject: Re: [PATCH 05/12] Memory compaction core
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1265976059-7459-6-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
	 <1265976059-7459-6-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Feb 2010 01:58:44 +0900
Message-ID: <1266512324.1709.295.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-02-12 at 12:00 +0000, Mel Gorman wrote:
> This patch is the core of a mechanism which compacts memory in a zone by
> relocating movable pages towards the end of the zone.
> 
> A single compaction run involves a migration scanner and a free scanner.
> Both scanners operate on pageblock-sized areas in the zone. The migration
> scanner starts at the bottom of the zone and searches for all movable pages
> within each area, isolating them onto a private list called migratelist.
> The free scanner starts at the top of the zone and searches for suitable
> areas and consumes the free pages within making them available for the
> migration scanner. The pages isolated for migration are then migrated to
> the newly isolated free pages.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/compaction.h |    8 +
>  include/linux/mm.h         |    1 +
>  include/linux/swap.h       |    5 +
>  include/linux/vmstat.h     |    1 +
>  mm/Makefile                |    1 +
>  mm/compaction.c            |  341 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c            |   37 +++++
>  mm/vmscan.c                |    5 -
>  mm/vmstat.c                |    5 +
>  scripts/kconfig/conf.c     |    1 -
>  10 files changed, 399 insertions(+), 6 deletions(-)
>  create mode 100644 include/linux/compaction.h
>  create mode 100644 mm/compaction.c
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> new file mode 100644
> index 0000000..6201371
> --- /dev/null
> +++ b/include/linux/compaction.h
> @@ -0,0 +1,8 @@
> +#ifndef _LINUX_COMPACTION_H
> +#define _LINUX_COMPACTION_H
> +
> +/* Return values for compact_zone() */
> +#define COMPACT_INCOMPLETE	0
> +#define COMPACT_COMPLETE	1
> +
> +#endif /* _LINUX_COMPACTION_H */
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 60c467b..c2a2ede 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -332,6 +332,7 @@ void put_page(struct page *page);
>  void put_pages_list(struct list_head *pages);
>  
>  void split_page(struct page *page, unsigned int order);
> +int split_free_page(struct page *page);
>  
>  /*
>   * Compound pages have a destructor function.  Provide a
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a2602a8..7e7181b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -238,6 +238,11 @@ static inline void lru_cache_add_active_file(struct page *page)
>  	__lru_cache_add(page, LRU_ACTIVE_FILE);
>  }
>  
> +/* LRU Isolation modes. */
> +#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
> +#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
> +#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
> +
>  /* linux/mm/vmscan.c */
>  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  					gfp_t gfp_mask, nodemask_t *mask);
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index ee03bba..d7f7236 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -43,6 +43,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
>  		KSWAPD_SKIP_CONGESTION_WAIT,
>  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> +		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
>  #ifdef CONFIG_HUGETLB_PAGE
>  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
>  #endif
> diff --git a/mm/Makefile b/mm/Makefile
> index 7a68d2a..ccb1f72 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -33,6 +33,7 @@ obj-$(CONFIG_FAILSLAB) += failslab.o
>  obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
>  obj-$(CONFIG_FS_XIP) += filemap_xip.o
>  obj-$(CONFIG_MIGRATION) += migrate.o
> +obj-$(CONFIG_COMPACTION) += compaction.o
>  obj-$(CONFIG_SMP) += percpu.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
>  obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
> diff --git a/mm/compaction.c b/mm/compaction.c
> new file mode 100644
> index 0000000..51ec864
> --- /dev/null
> +++ b/mm/compaction.c
> @@ -0,0 +1,341 @@
> +/*
> + * linux/mm/compaction.c
> + *
> + * Memory compaction for the reduction of external fragmentation. Note that
> + * this heavily depends upon page migration to do all the real heavy
> + * lifting
> + *
> + * Copyright IBM Corp. 2009 Mel Gorman <mel@csn.ul.ie>
> + */
> +#include <linux/swap.h>
> +#include <linux/migrate.h>
> +#include <linux/compaction.h>
> +#include <linux/mm_inline.h>
> +#include "internal.h"
> +
> +/*
> + * compact_control is used to track pages being migrated and the free pages
> + * they are being migrated to during memory compaction. The free_pfn starts
> + * at the end of a zone and migrate_pfn begins at the start. Movable pages
> + * are moved to the end of a zone during a compaction run and the run
> + * completes when free_pfn <= migrate_pfn
> + */
> +struct compact_control {
> +	struct list_head freepages;	/* List of free pages to migrate to */
> +	struct list_head migratepages;	/* List of pages being migrated */
> +	unsigned long nr_freepages;	/* Number of isolated free pages */
> +	unsigned long nr_migratepages;	/* Number of pages to migrate */
> +	unsigned long free_pfn;		/* isolate_freepages search base */
> +	unsigned long migrate_pfn;	/* isolate_migratepages search base */
> +	struct zone *zone;
> +};
> +
> +static int release_freepages(struct zone *zone, struct list_head *freelist)

"zone" argument. 

> +{
> +	struct page *page, *next;
> +	int count = 0;
> +
> +	list_for_each_entry_safe(page, next, freelist, lru) {
> +		list_del(&page->lru);
> +		__free_page(page);
> +		count++;
> +	}
> +
> +	return count;
> +}
> +
> +/* Isolate free pages onto a private freelist. Must hold zone->lock */
> +static int isolate_freepages_block(struct zone *zone,

return type 'int'?
I think we can't return signed value.

> +				unsigned long blockpfn,
> +				struct list_head *freelist)
> +{
> +	unsigned long zone_end_pfn, end_pfn;
> +	int total_isolated = 0;
> +
> +	/* Get the last PFN we should scan for free pages at */
> +	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> +	end_pfn = blockpfn + pageblock_nr_pages;
> +	if (end_pfn > zone_end_pfn)
> +		end_pfn = zone_end_pfn;
> +
> +	/* Isolate free pages. This assumes the block is valid */
> +	for (; blockpfn < end_pfn; blockpfn++) {
> +		struct page *page;
> +		int isolated, i;
> +
> +		if (!pfn_valid_within(blockpfn))
> +			continue;
> +
> +		page = pfn_to_page(blockpfn);
> +		if (!PageBuddy(page))
> +			continue;
> +
> +		/* Found a free page, break it into order-0 pages */
> +		isolated = split_free_page(page);
> +		total_isolated += isolated;
> +		for (i = 0; i < isolated; i++) {
> +			list_add(&page->lru, freelist);
> +			page++;
> +		}
> +		blockpfn += isolated - 1;
> +	}
> +
> +	return total_isolated;
> +}
> +
> +/* Returns 1 if the page is within a block suitable for migration to */
> +static int suitable_migration_target(struct page *page)
> +{
> +	/* If the page is a large free page, then allow migration */
> +	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> +		return 1;
> +
> +	/* If the block is MIGRATE_MOVABLE, allow migration */
> +	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE)
> +		return 1;
> +
> +	/* Otherwise skip the block */
> +	return 0;
> +}
> +
> +/*
> + * Based on information in the current compact_control, find blocks
> + * suitable for isolating free pages from
> + */
> +static void isolate_freepages(struct zone *zone,
> +				struct compact_control *cc)
> +{
> +	struct page *page;
> +	unsigned long high_pfn, low_pfn, pfn;
> +	unsigned long flags;
> +	int nr_freepages = cc->nr_freepages;
> +	struct list_head *freelist = &cc->freepages;
> +
> +	pfn = cc->free_pfn;
> +	low_pfn = cc->migrate_pfn + pageblock_nr_pages;
> +	high_pfn = low_pfn;
> +
> +	/*
> +	 * Isolate free pages until enough are available to migrate the
> +	 * pages on cc->migratepages. We stop searching if the migrate
> +	 * and free page scanners meet or enough free pages are isolated.
> +	 */
> +	spin_lock_irqsave(&zone->lock, flags);
> +	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
> +					pfn -= pageblock_nr_pages) {
> +		int isolated;
> +
> +		if (!pfn_valid(pfn))
> +			continue;
> +
> +		/* Check for overlapping nodes/zones */
> +		page = pfn_to_page(pfn);
> +		if (page_zone(page) != zone)
> +			continue;

We are progressing backward by physical page order in a zone. 
If we meet crossover between zone, Why are we going backward
continuously? Before it happens, migration and free scanner would meet.
Am I miss something?

> +
> +		/* Check the block is suitable for migration */
> +		if (!suitable_migration_target(page))
> +			continue;

Dumb question. 
suitable_migration_target considers three type's pages

1. free page and page's order >= pageblock_order
2. free pages and pages's order < pageblock_order with movable page
3. used page with movable

I can understand 1 and 2 but can't 3. This function is for gathering
free page. How do you handle used page as free one?
 
In addition, as I looked into isolate_freepages_block, it doesn't
consider 3 by PageBuddy check. 

I am confusing. Pz, correct me.

> +
> +		/* Found a block suitable for isolating free pages from */
> +		isolated = isolate_freepages_block(zone, pfn, freelist);
> +		nr_freepages += isolated;
> +
> +		/*
> +		 * Record the highest PFN we isolated pages from. When next
> +		 * looking for free pages, the search will restart here as
> +		 * page migration may have returned some pages to the allocator
> +		 */
> +		if (isolated)
> +			high_pfn = max(high_pfn, pfn);
> +	}
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +
> +	cc->free_pfn = high_pfn;
> +	cc->nr_freepages = nr_freepages;
> +}
> +
> +/*
> + * Isolate all pages that can be migrated from the block pointed to by
> + * the migrate scanner within compact_control.
> + */
> +static unsigned long isolate_migratepages(struct zone *zone,
> +					struct compact_control *cc)
> +{
> +	unsigned long low_pfn, end_pfn;
> +	struct list_head *migratelist;
> +	enum lru_list lru_src;
> +
> +	low_pfn = ALIGN(cc->migrate_pfn, pageblock_nr_pages);
> +	migratelist = &cc->migratepages;
> +
> +	/* Do not scan outside zone boundaries */
> +	if (low_pfn < zone->zone_start_pfn)
> +		low_pfn = zone->zone_start_pfn;
> +
> +	/* Setup to scan one block but not past where we are migrating to */
> +	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
> +	cc->migrate_pfn = end_pfn;
> +	VM_BUG_ON(end_pfn > cc->free_pfn);
> +
> +	if (!pfn_valid(low_pfn))
> +		return 0;
> +
> +	migrate_prep();
> +
> +	/* Time to isolate some pages for migration */
> +	spin_lock_irq(&zone->lru_lock);
> +	for (; low_pfn < end_pfn; low_pfn++) {
> +		struct page *page;
> +		if (!pfn_valid_within(low_pfn))
> +			continue;
> +
> +		/* Get the page and skip if free */
> +		page = pfn_to_page(low_pfn);
> +		if (PageBuddy(page)) {
> +			low_pfn += (1 << page_order(page)) - 1;
> +			continue;
> +		}
> +
> +		if (!PageLRU(page) || PageUnevictable(page))
> +			continue;
> +
> +		/* Try isolate the page */
> +		lru_src = page_lru(page);
> +		switch (__isolate_lru_page(page, ISOLATE_BOTH, 0)) {
> +		case 0:
> +			list_move(&page->lru, migratelist);
> +			mem_cgroup_del_lru(page);
> +			cc->nr_migratepages++;
> +			break;
> +
> +		case -EBUSY:
> +			/*
> +			 * else it is being freed elsewhere. The
> +			 * problem is that we are not really sure where
> +			 * it came from in the first place
> +			 * XXX: Verify the putback logic is ok. This was
> +			 *       all written before LRU lists were split
> +			 */
> +			list_move(&page->lru, &zone->lru[lru_src].list);
> +			mem_cgroup_rotate_lru_list(page, page_lru(page));
> +			continue;
> +
> +		default:
> +			BUG();
> +		}
> +	}
> +	spin_unlock_irq(&zone->lru_lock);
> +
> +	return cc->nr_migratepages;
> +}
> +
> +/*
> + * This is a migrate-callback that "allocates" freepages by taking pages
> + * from the isolated freelists in the block we are migrating to.
> + */
> +static struct page *compaction_alloc(struct page *migratepage,
> +					unsigned long data,
> +					int **result)
> +{
> +	struct compact_control *cc = (struct compact_control *)data;
> +	struct page *freepage;
> +
> +	VM_BUG_ON(cc == NULL);
> +
> +	/* Isolate free pages if necessary */
> +	if (list_empty(&cc->freepages)) {
> +		isolate_freepages(cc->zone, cc);
> +
> +		if (list_empty(&cc->freepages))
> +			return NULL;
> +	}
> +
> +	freepage = list_entry(cc->freepages.next, struct page, lru);
> +	list_del(&freepage->lru);
> +	cc->nr_freepages--;
> +
> +	return freepage;
> +}
> +
> +/*
> + * We cannot control nr_migratepages and nr_freepages fully when migration is
> + * running as migrate_pages() has no knowledge of compact_control. When
> + * migration is complete, we count the number of pages on the lists by hand.
> + */
> +static void update_nr_listpages(struct compact_control *cc)
> +{
> +	int nr_migratepages = 0;
> +	int nr_freepages = 0;
> +	struct page *page;
> +	list_for_each_entry(page, &cc->migratepages, lru)
> +		nr_migratepages++;
> +	list_for_each_entry(page, &cc->freepages, lru)
> +		nr_freepages++;
> +
> +	cc->nr_migratepages = nr_migratepages;
> +	cc->nr_freepages = nr_freepages;
> +}
> +
> +static inline int compact_finished(struct zone *zone,
> +						struct compact_control *cc)
> +{
> +	/* Compaction run completes if the migrate and free scanner meet */
> +	if (cc->free_pfn <= cc->migrate_pfn)
> +		return COMPACT_COMPLETE;
> +
> +	return COMPACT_INCOMPLETE;
> +}
> +
> +static int compact_zone(struct zone *zone, struct compact_control *cc)
> +{
> +	int ret = COMPACT_INCOMPLETE;
> +
> +	/*
> +	 * Setup to move all movable pages to the end of the zone
> +	 * XXX: This could be improved upon. In the event compaction
> +	 *	is being successful quickly but called often, there
> +	 *	is a likelihood of scanning the same blocks as sources
> +	 *	and targets frequently. Might be worth caching the
> +	 *	last migrate_pfn to reduce scan times.
> +	 */
> +	cc->migrate_pfn = zone->zone_start_pfn;
> +	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
> +	cc->free_pfn &= ~(pageblock_nr_pages-1);
> +
> +	for (; ret == COMPACT_INCOMPLETE; ret = compact_finished(zone, cc)) {
> +		unsigned long nr_migrate, nr_remaining;
> +		if (!isolate_migratepages(zone, cc))
> +			continue;
> +
> +		nr_migrate = cc->nr_migratepages;
> +		migrate_pages(&cc->migratepages, compaction_alloc,
> +						(unsigned long)cc, 0);
> +		update_nr_listpages(cc);
> +		nr_remaining = cc->nr_migratepages;
> +
> +		count_vm_event(COMPACTBLOCKS);
> +		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
> +		if (nr_remaining)
> +			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
> +	}
> +
> +	/* Release free pages and check accounting */
> +	cc->nr_freepages -= release_freepages(zone, &cc->freepages);
> +	VM_BUG_ON(cc->nr_freepages != 0);
> +
> +	/*
> +	 * Release LRU pages not migrated
> +	 * XXX: Page migration at this point tries fairly hard to move
> +	 *	pages as it is but if migration fails, pages are left
> +	 *	on cc->migratepages for more passes. This might cause
> +	 *	multiple useless failures. Watch compact_pagemigrate_failed
> +	 *	in /proc/vmstat. If it grows a lot, then putback should
> +	 *	happen after each failed migration
> +	 */
> +	if (!list_empty(&cc->migratepages))
> +		putback_lru_pages(&cc->migratepages);
> +
> +	return ret;
> +}
> +
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8deb9d0..6d57154 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1168,6 +1168,43 @@ void split_page(struct page *page, unsigned int order)
>  		set_page_refcounted(page + i);
>  }
>  
> +/* Similar to split_page except the page is already free */

Sometime, this function changes pages's type to MIGRATE_MOVABLE.
I hope adding comment about that. 

> +int split_free_page(struct page *page)
> +{
> +	unsigned int order;
> +	unsigned long watermark;
> +	struct zone *zone;
> +
> +	BUG_ON(!PageBuddy(page));
> +
> +	zone = page_zone(page);
> +	order = page_order(page);
> +
> +	/* Obey watermarks or the system could deadlock */
> +	watermark = low_wmark_pages(zone) + (1 << order);
> +	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> +		return 0;
> +
> +	/* Remove page from free list */
> +	list_del(&page->lru);
> +	zone->free_area[order].nr_free--;
> +	rmv_page_order(page);
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
> +
> +	/* Split into individual pages */
> +	set_page_refcounted(page);
> +	split_page(page, order);
> +
> +	/* Set the migratetype on the assumption it's for migration */
> +	if (order >= pageblock_order - 1) {
> +		struct page *endpage = page + (1 << order) - 1;
> +		for (; page < endpage; page += pageblock_nr_pages)
> +			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> +	}
> +
> +	return 1 << order;
> +}
> +
>  /*
>   * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
>   * we cheat by calling it from here, in the order > 0 path.  Saves a branch
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c26986c..47de19b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -803,11 +803,6 @@ keep:
>  	return nr_reclaimed;
>  }
>  
> -/* LRU Isolation modes. */
> -#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
> -#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
> -#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
> -
>  /*
>   * Attempt to remove the specified page from its LRU.  Only take this page
>   * if it is of the appropriate PageActive status.  Pages which are being
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index e2d0cc1..f0930ae 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -852,6 +852,11 @@ static const char * const vmstat_text[] = {
>  	"allocstall",
>  
>  	"pgrotated",
> +
> +	"compact_blocks_moved",
> +	"compact_pages_moved",
> +	"compact_pagemigrate_failed",
> +
>  #ifdef CONFIG_HUGETLB_PAGE
>  	"htlb_buddy_alloc_success",
>  	"htlb_buddy_alloc_fail",



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
