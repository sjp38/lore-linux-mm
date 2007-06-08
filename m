Date: Fri, 8 Jun 2007 14:24:11 +0100
Subject: Re: memory unplug v4 intro [4/6] page isolation
Message-ID: <20070608132411.GA9390@skynet.ie>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com> <20070608144151.ac8408e0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070608144151.ac8408e0.kamezawa.hiroyu@jp.fujitsu.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On (08/06/07 14:41), KAMEZAWA Hiroyuki didst pronounce:
> Implement generic chunk-of-pages isolation method by using page grouping ops.
> 
> This patch add MIGRATE_ISOLATE to MIGRATE_TYPES. By this
>  - MIGRATE_TYPES increases.
>  - bitmap for migratetype is enlarged.
> 
> If make_pagetype_isolated(start,end) is called,
>  - migratetype of the range turns to be MIGRATE_ISOLATE  if 
>    its current type is MIGRATE_MOVABLE or MIGRATE_RESERVE.
>  - MIGRATE_ISOLATE is not on migratetype fallback list.
> 
> Then, pages of this migratetype will not be allocated even if it is free.
> 
> Now, this patch only can treat the range aligned to MAX_ORDER.
> This will be fixed if Mel's new work is merged.
> 

Grouping by arbitrary order is now in -mm. The size of a pageblock area is
determined by pageblock_order which will either by the same as the huge page
size if avaialble or MAX_ORDER-1 if not.

> Changes V3 -> V4
>  - removed MIGRATE_ISOLATE check in free_hot_cold_page().
>  - test_and_next_pages_isolated() is added, which sees Buddy information.
>  - rounddown() macro is added to kernel.h, my own macro is removed.
>  - is_page_isolated() function is removed.
>  - change function names to be clearer.
>    make_pagetype_isolated()/make_pagetype_movable().
> 
> Signed-Off-By: Yasunori Goto <y-goto@jp.fujitsu.com>
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  include/linux/kernel.h          |    1 
>  include/linux/mmzone.h          |    3 +
>  include/linux/page-isolation.h  |   47 ++++++++++++++++++++++++++++
>  include/linux/pageblock-flags.h |    2 -
>  mm/Makefile                     |    2 -
>  mm/page_alloc.c                 |   63 +++++++++++++++++++++++++++++++++++++
>  mm/page_isolation.c             |   67 ++++++++++++++++++++++++++++++++++++++++
>  7 files changed, 182 insertions(+), 3 deletions(-)
> 
> Index: devel-2.6.22-rc4-mm2/include/linux/mmzone.h
> ===================================================================
> --- devel-2.6.22-rc4-mm2.orig/include/linux/mmzone.h
> +++ devel-2.6.22-rc4-mm2/include/linux/mmzone.h
> @@ -39,7 +39,8 @@ extern int page_group_by_mobility_disabl
>  #define MIGRATE_RECLAIMABLE   1
>  #define MIGRATE_MOVABLE       2
>  #define MIGRATE_RESERVE       3
> -#define MIGRATE_TYPES         4
> +#define MIGRATE_ISOLATE       4 /* can't allocate from here */
> +#define MIGRATE_TYPES         5
>  
>  #define for_each_migratetype_order(order, type) \
>  	for (order = 0; order < MAX_ORDER; order++) \
> Index: devel-2.6.22-rc4-mm2/include/linux/pageblock-flags.h
> ===================================================================
> --- devel-2.6.22-rc4-mm2.orig/include/linux/pageblock-flags.h
> +++ devel-2.6.22-rc4-mm2/include/linux/pageblock-flags.h
> @@ -31,7 +31,7 @@
>  
>  /* Bit indices that affect a whole block of pages */
>  enum pageblock_bits {
> -	PB_range(PB_migrate, 2), /* 2 bits required for migrate types */
> +	PB_range(PB_migrate, 3), /* 3 bits required for migrate types */
>  	NR_PAGEBLOCK_BITS
>  };
>  
> Index: devel-2.6.22-rc4-mm2/mm/page_alloc.c
> ===================================================================
> --- devel-2.6.22-rc4-mm2.orig/mm/page_alloc.c
> +++ devel-2.6.22-rc4-mm2/mm/page_alloc.c
> @@ -41,6 +41,7 @@
>  #include <linux/pfn.h>
>  #include <linux/backing-dev.h>
>  #include <linux/fault-inject.h>
> +#include <linux/page-isolation.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -4409,3 +4410,65 @@ void set_pageblock_flags_group(struct pa
>  		else
>  			__clear_bit(bitidx + start_bitidx, bitmap);
>  }
> +
> +/*
> + * Chack a range of pages are isolated or not.
> + * returns next pfn to be tested.
> + * If pfn is not isoalted, returns 0.
> + */
> +

Spurious whitespace here. isolated is misspelt.

> +unsigned long test_and_next_isolated_page(unsigned long pfn)
> +{

Can this be defined with test_isolated_pages() as page_order() is now
defined in internal.h?

> +	struct page *page;
> +	if (!pfn_valid(pfn))
> +		return 0;

The caller is already calling pfn_valid() so this should be unnecessary.

Also, you may be calling pfn_valid() more than required. If you know a PFN
is within a MAX_ORDER block that contains at least one valid page, you only
have to call pfn_valid_within() which is a no-op on almost every architecture
but IA64.

> +	page = pfn_to_page(pfn);
> +	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> +		return 0;

You shouldn't need to check this for every single page.

> +	if (PageBuddy(page))
> +		return pfn + (1 << page_order(page));
> +	/* Means pages in pcp list */
> +	if (page_count(page) == 0 && page_private(page) == MIGRATE_ISOLATE)
> +		return pfn + 1;
> +	return 0;
> +}
> +
> +/*
> + * set/clear page block's type to be ISOLATE.
> + * page allocater never alloc memory from ISOLATE block.
> + */
> +
> +

More spurious whitespace

> +int set_migratetype_isolate(struct page *page)
> +{
> +	struct zone *zone;
> +	unsigned long flags;
> +	int ret = -EBUSY;
> +
> +	zone = page_zone(page);
> +	spin_lock_irqsave(&zone->lock, flags);
> +	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
> +		goto out;

hmmm, review this decision on a regular basis. If the block was reclaimable
and Christoph's SLUB defragmentation patches work out, there will be more
block types that can be isolated.

> +	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> +	move_freepages_block(zone, page, MIGRATE_ISOLATE);
> +	ret = 0;
> +out:
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +	if (!ret)
> +		drain_all_local_pages();
> +	return ret;
> +}
> +
> +void clear_migratetype_isolate(struct page *page)
> +{
> +	struct zone *zone;
> +	unsigned long flags;
> +	zone = page_zone(page);
> +	spin_lock_irqsave(&zone->lock, flags);
> +	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> +		goto out;
> +	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> +	move_freepages_block(zone, page, MIGRATE_MOVABLE);
> +out:
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +}
> Index: devel-2.6.22-rc4-mm2/mm/page_isolation.c
> ===================================================================
> --- /dev/null
> +++ devel-2.6.22-rc4-mm2/mm/page_isolation.c
> @@ -0,0 +1,67 @@
> +/*
> + * linux/mm/page_isolation.c
> + */
> +
> +#include <stddef.h>
> +#include <linux/kernel.h>
> +#include <linux/mm.h>
> +#include <linux/page-isolation.h>
> +
> +int
> +make_pagetype_isolated(unsigned long start_pfn, unsigned long end_pfn)
> +{

As these are externally available, they could do with kerneldoc comments
explaining their purpose.

/**
 * make_pagetype_isolated - Mark a range of pages to be isolated from the buddy allocator
 * @start_pfn: The lower PFN of the range to be isolated
 * @end_pfn: The upper PFN of the range to be isolated
 *
 * Mark a range of pages to be isolated from the buddy allocator. Any
 * currently free page will no longer be available when this returns
 * successfully. Any page freed in the future will similarly be isolated
 * 
 * Returns 0 on success and -EBUSY if any part of the range cannot be
 * isolated
 */

or something

The names are not great either.

isolate_page_range() and putback_isolated_range() prehaps? I am not the
best at naming things so prehaps others will have better suggestions.

> +	unsigned long pfn, start_pfn_aligned, end_pfn_aligned;
> +	unsigned long undo_pfn;
> +
> +	start_pfn_aligned = rounddown(start_pfn, NR_PAGES_ISOLATION_BLOCK);
> +	end_pfn_aligned = roundup(end_pfn, NR_PAGES_ISOLATION_BLOCK);
> +

Check that the aligned PFNs do not go outside the zone range. This sort of
check has come up a lot, it may be a candidate for it's own helper.

> +	for (pfn = start_pfn_aligned;
> +	     pfn < end_pfn_aligned;
> +	     pfn += NR_PAGES_ISOLATION_BLOCK)
> +		if (set_migratetype_isolate(pfn_to_page(pfn))) {
> +			undo_pfn = pfn;
> +			goto undo;
> +		}
> +	return 0;
> +undo:
> +	for (pfn = start_pfn_aligned;
> +	     pfn <= undo_pfn;
> +	     pfn += NR_PAGES_ISOLATION_BLOCK)
> +		clear_migratetype_isolate(pfn_to_page(pfn));
> +
> +	return -EBUSY;
> +}
> +
> +
> +int
> +make_pagetype_movable(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn, start_pfn_aligned, end_pfn_aligned;
> +	start_pfn_aligned = rounddown(start_pfn, NR_PAGES_ISOLATION_BLOCK);
> +        end_pfn_aligned = roundup(end_pfn, NR_PAGES_ISOLATION_BLOCK);

Tabs vs Spaces there.

> +
> +	for (pfn = start_pfn_aligned;
> +	     pfn < end_pfn_aligned;
> +	     pfn += NR_PAGES_ISOLATION_BLOCK)
> +		clear_migratetype_isolate(pfn_to_page(pfn));
> +	return 0;
> +}
> +
> +int
> +test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn;
> +
> +	pfn = start_pfn;
> +	while (pfn < end_pfn) {
> +		if (!pfn_valid(pfn)) {
> +			pfn++;
> +			continue;
> +		}
> +		pfn = test_and_next_isolated_page(pfn);
> +		if (!pfn)
> +			break;
> +	}
> +	return (pfn < end_pfn)? -EBUSY : 0;
> +}
> Index: devel-2.6.22-rc4-mm2/include/linux/page-isolation.h
> ===================================================================
> --- /dev/null
> +++ devel-2.6.22-rc4-mm2/include/linux/page-isolation.h
> @@ -0,0 +1,47 @@
> +#ifndef __LINUX_PAGEISOLATION_H
> +#define __LINUX_PAGEISOLATION_H
> +/*
> + * Define an interface for capturing and isolating some amount of
> + * contiguous pages.
> + * isolated pages are freed but wll never be allocated until they are
> + * pushed back.
> + *
> + * This isolation function requires some alignment.
> + */
> +
> +#define PAGE_ISOLATION_ORDER	(MAX_ORDER - 1)
> +#define NR_PAGES_ISOLATION_BLOCK	(1 << PAGE_ISOLATION_ORDER)
> +

Consider using pageblock_order and pageblock_nr_pages from
pageblock-flags.h

> +/*
> + * set page isolation range.
> + * If specified range includes migrate types other than MOVABLE,
> + * this will fail with -EBUSY.
> + */
> +extern int
> +make_pagetype_isolated(unsigned long start_pfn, unsigned long end_pfn);
> +
> +/*
> + *  Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
> + */
> +extern int
> +make_pagetype_movable(unsigned long start_pfn, unsigned long end_pfn);
> +
> +/*
> + * test all pages are isolated or not.
> + */
> +extern int
> +test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
> +
> +/* helper test routine for check page is isolated or not */
> +extern unsigned long
> +test_and_next_isolated_page(unsigned long pfn);
> +
> +/*
> + * Internal funcs.Changes pageblock's migrate type.
> + * Please use make_pagetype_isolated()/make_pagetype_movable().
> + */
> +extern int set_migratetype_isolate(struct page *page);
> +extern void clear_migratetype_isolate(struct page *page);
> +
> +
> +#endif
> Index: devel-2.6.22-rc4-mm2/mm/Makefile
> ===================================================================
> --- devel-2.6.22-rc4-mm2.orig/mm/Makefile
> +++ devel-2.6.22-rc4-mm2/mm/Makefile
> @@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
>  			   page_alloc.o page-writeback.o pdflush.o \
>  			   readahead.o swap.o truncate.o vmscan.o \
>  			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
> -			   $(mmu-y)
> +			   page_isolation.o $(mmu-y)
>  
>  obj-$(CONFIG_BOUNCE)	+= bounce.o
>  obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
> Index: devel-2.6.22-rc4-mm2/include/linux/kernel.h
> ===================================================================
> --- devel-2.6.22-rc4-mm2.orig/include/linux/kernel.h
> +++ devel-2.6.22-rc4-mm2/include/linux/kernel.h
> @@ -40,6 +40,7 @@ extern const char linux_proc_banner[];
>  #define FIELD_SIZEOF(t, f) (sizeof(((t*)0)->f))
>  #define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
>  #define roundup(x, y) ((((x) + ((y) - 1)) / (y)) * (y))
> +#define rounddown(x, y) ((x)/(y)) * (y)
>  
>  /**
>   * upper_32_bits - return bits 32-63 of a number

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
