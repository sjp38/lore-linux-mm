Date: Tue, 22 May 2007 11:19:27 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Patch] memory unplug v3 [1/4] page isolation
In-Reply-To: <20070522160151.3ae5e5d7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705221023020.16461@skynet.skynet.ie>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
 <20070522160151.3ae5e5d7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, y-goto@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, KAMEZAWA Hiroyuki wrote:

> Patch for isoalte pages.
> 'isoalte'means make pages to be free and never allocated.
> This feature helps making the range of pages unused.
>
> This patch is based on Mel's page grouping method.
>
> This patch add MIGRATE_ISOLATE to MIGRATE_TYPES. By this
> - MIGRATE_TYPES increases.
> - bitmap for migratetype is enlarged.
>

Both correct.

> If isolate_pages(start,end) is called,
> - migratetype of the range turns to be MIGRATE_ISOLATE  if
>  its current type is MIGRATE_MOVABLE or MIGRATE_RESERVE.

Why not MIGRATE_RECLAIMABLE as well?

> - MIGRATE_ISOLATE is not on migratetype fallback list.
>
> Then, pages of this migratetype will not be allocated even if it is free.
>
> Now, isolate_pages() only can treat the range aligned to MAX_ORDER.
> This can be adjusted if necesasry...maybe.
>

I have a patch ready that groups pages by an arbitrary order. Right now it 
is related to the size of the huge page on the system but it's a single 
variable pageblock_order that determines the range. You may find you want 
to adjust this value.

> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Index: devel-2.6.22-rc1-mm1/include/linux/mmzone.h
> ===================================================================
> --- devel-2.6.22-rc1-mm1.orig/include/linux/mmzone.h	2007-05-22 14:30:43.000000000 +0900
> +++ devel-2.6.22-rc1-mm1/include/linux/mmzone.h	2007-05-22 15:12:28.000000000 +0900
> @@ -35,11 +35,12 @@
>  */
> #define PAGE_ALLOC_COSTLY_ORDER 3
>
> -#define MIGRATE_UNMOVABLE     0
> -#define MIGRATE_RECLAIMABLE   1
> -#define MIGRATE_MOVABLE       2
> -#define MIGRATE_RESERVE       3
> -#define MIGRATE_TYPES         4
> +#define MIGRATE_UNMOVABLE     0		/* not reclaimable pages */
> +#define MIGRATE_RECLAIMABLE   1		/* shrink_xxx routine can reap this */
> +#define MIGRATE_MOVABLE       2		/* migrate_page can migrate this */
> +#define MIGRATE_RESERVE       3		/* no type yet */

MIGRATE_RESERVE is where the min_free_kbytes pages are kept if possible 
and the number of RESERVE blocks depends on the value of it. It is only 
allocated from if the alternative is to fail the allocation so this 
comment should read

/* min_free_kbytes free pages here */

Later we may find a way of using MIGRATE_RESERVE to isolate ranges but 
it's not necessary now because it would obscure how the patch works.

> +#define MIGRATE_ISOLATE       4		/* never allocated from */
> +#define MIGRATE_TYPES         5
>

The documentation changes probably belong in a separate patch but thanks, 
it nudges me again into getting around to it.

> #define for_each_migratetype_order(order, type) \
> 	for (order = 0; order < MAX_ORDER; order++) \
> Index: devel-2.6.22-rc1-mm1/include/linux/pageblock-flags.h
> ===================================================================
> --- devel-2.6.22-rc1-mm1.orig/include/linux/pageblock-flags.h	2007-05-22 14:30:43.000000000 +0900
> +++ devel-2.6.22-rc1-mm1/include/linux/pageblock-flags.h	2007-05-22 15:12:28.000000000 +0900
> @@ -31,7 +31,7 @@
>
> /* Bit indices that affect a whole block of pages */
> enum pageblock_bits {
> -	PB_range(PB_migrate, 2), /* 2 bits required for migrate types */
> +	PB_range(PB_migrate, 3), /* 3 bits required for migrate types */

Right.

> 	NR_PAGEBLOCK_BITS
> };
>
> Index: devel-2.6.22-rc1-mm1/mm/page_alloc.c
> ===================================================================
> --- devel-2.6.22-rc1-mm1.orig/mm/page_alloc.c	2007-05-22 14:30:43.000000000 +0900
> +++ devel-2.6.22-rc1-mm1/mm/page_alloc.c	2007-05-22 15:12:28.000000000 +0900
> @@ -41,6 +41,7 @@
> #include <linux/pfn.h>
> #include <linux/backing-dev.h>
> #include <linux/fault-inject.h>
> +#include <linux/page-isolation.h>
>
> #include <asm/tlbflush.h>
> #include <asm/div64.h>
> @@ -1056,6 +1057,7 @@
> 	struct zone *zone = page_zone(page);
> 	struct per_cpu_pages *pcp;
> 	unsigned long flags;
> +	unsigned long migrate_type;
>
> 	if (PageAnon(page))
> 		page->mapping = NULL;
> @@ -1064,6 +1066,12 @@
>
> 	if (!PageHighMem(page))
> 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
> +
> +	migrate_type = get_pageblock_migratetype(page);
> +	if (migrate_type == MIGRATE_ISOLATE) {
> +		__free_pages_ok(page, 0);
> +		return;
> +	}

This change to the PCP allocator may be unnecessary. If you let the page 
free to the pcp lists, they will never be allocated from there because 
allocflags_to_migratetype() will never return MIGRATE_ISOLATE. What you 
could do is drain the PCP lists just before you try to hot-remove or call 
test_pages_isolated() to that the pcp pages will free back to the 
MIGRATE_ISOLATE lists.

The extra drain is undesirable but probably better than checking for 
isolate every time a free occurs to the pcp lists.

> 	arch_free_page(page, 0);
> 	kernel_map_pages(page, 1, 0);
>
> @@ -1071,7 +1079,7 @@
> 	local_irq_save(flags);
> 	__count_vm_event(PGFREE);
> 	list_add(&page->lru, &pcp->list);
> -	set_page_private(page, get_pageblock_migratetype(page));
> +	set_page_private(page, migrate_type);
> 	pcp->count++;
> 	if (pcp->count >= pcp->high) {
> 		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
> @@ -4389,3 +4397,53 @@
> 		else
> 			__clear_bit(bitidx + start_bitidx, bitmap);
> }
> +
> +/*
> + * set/clear page block's type to be ISOLATE.
> + * page allocater never alloc memory from ISOLATE blcok.
> + */
> +
> +int is_page_isolated(struct page *page)
> +{
> +	if ((page_count(page) == 0) &&
> +	    (get_pageblock_migratetype(page) == MIGRATE_ISOLATE))

(PageBuddy(page) || (page_count(page) == 0 && PagePrivate(page))) &&
 	(get_pageblock_migratetype(page) == MIGRATE_ISOLATE)

PageBuddy(page) for free pages and page_count(page) with PagePrivate 
should indicate pages that are on the pcp lists.

As you currently prevent ISOLATE pages going to the pcp lists, only the 
PageBuddy check is necessary right now but If you drain before you check 
for isolated pages, you only need the PageBuddy() check. If you choose to 
let pages on the pcp lists until a drain occurs, then you need the second 
check.

This page_count() check instead of PageBuddy() appears to be related to 
how test_pages_isolated() is implemented - more on that later.

> +		return 1;
> +	return 0;
> +}
> +
> +int set_migratetype_isolate(struct page *page)
> +{

set_pageblock_isolate() maybe to match set_pageblock_migratetype() naming?

> +	struct zone *zone;
> +	unsigned long flags;
> +	int migrate_type;
> +	int ret = -EBUSY;
> +
> +	zone = page_zone(page);
> +	spin_lock_irqsave(&zone->lock, flags);

It may be more appropriate to have the caller take this lock. More later 
in isolates_pages()

> +	migrate_type = get_pageblock_migratetype(page);
> +	if ((migrate_type != MIGRATE_MOVABLE) &&
> +	    (migrate_type != MIGRATE_RESERVE))
> +		goto out;

and maybe MIGRATE_RECLAIMABLE here particularly in view of Christoph's 
work with kmem_cache_vacate().

> +	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> +	move_freepages_block(zone, page, MIGRATE_ISOLATE);
> +	ret = 0;
> +out:
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +	if (!ret)
> +		drain_all_local_pages();

It's not clear why you drain the pcp lists when you encounter a block of 
the wrong migrate_type. Draining the pcp lists is unlikely to help you.

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
> +	set_pageblock_migratetype(page, MIGRATE_RESERVE);
> +	move_freepages_block(zone, page, MIGRATE_RESERVE);

MIGRATE_RESERVE is likely not what you want to do here. The number of 
MIGRATE_RESERVE blocks in a zone is determined by 
setup_zone_migrate_reserve(). If you are setting blocks like this, then 
you need to call setup_zone_migrate_reserve() with the zone->lru_lock held 
after you have call clear_migratetype_isolate() for all the necessary 
blocks.

It may be easier to just set the blocks MIGRATE_MOVABLE.

> +out:
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +}
> Index: devel-2.6.22-rc1-mm1/mm/page_isolation.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ devel-2.6.22-rc1-mm1/mm/page_isolation.c	2007-05-22 15:12:28.000000000 +0900
> @@ -0,0 +1,67 @@
> +/*
> + * linux/mm/page_isolation.c
> + */
> +
> +#include <stddef.h>
> +#include <linux/mm.h>
> +#include <linux/page-isolation.h>
> +
> +#define ROUND_DOWN(x,y)	((x) & ~((y) - 1))
> +#define ROUND_UP(x,y)	(((x) + (y) -1) & ~((y) - 1))

A roundup() macro already exists in kernel.h. You may want to use that and 
define a new rounddown() macro there instead.

> +int
> +isolate_pages(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn, start_pfn_aligned, end_pfn_aligned;
> +	unsigned long undo_pfn;
> +
> +	start_pfn_aligned = ROUND_DOWN(start_pfn, NR_PAGES_ISOLATION_BLOCK);
> +	end_pfn_aligned = ROUND_UP(end_pfn, NR_PAGES_ISOLATION_BLOCK);
> +
> +	for (pfn = start_pfn_aligned;
> +	     pfn < end_pfn_aligned;
> +	     pfn += NR_PAGES_ISOLATION_BLOCK)
> +		if (set_migratetype_isolate(pfn_to_page(pfn))) {

You will need to call pfn_valid() in the non-SPARSEMEM case before calling 
pfn_to_page() or this will crash in some circumstances.

You also need to check zone boundaries. Lets say start_pfn is the start of 
a non-MAX_ORDER aligned zone. Aligning it could make you start isolating 
in the wrong zone - prehaps this is intentional, I don't know.

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

We fail if we encounter any non-MIGRATE_MOVABLE block in the start_pfn to 
end_pfn range but at that point we've done a lot of work. We also take and 
release an interrupt safe lock for each NR_PAGES_ISOLATION_BLOCK block 
because set_migratetype_isolate() is responsible for lock taking.

It might be better if you took the lock here, scanned first to make sure 
all the blocks were suitable for isolation and only then, call 
set_migratetype_isolate() for each of them before releasing the lock.

That would take the lock once and avoid the need for back-out code that 
changes all the MIGRATE types in the range. Even for large ranges of 
memory, it should not be too long to be holding a lock particularly in 
this path.

> +	return -EBUSY;
> +}
> +
> +
> +int
> +free_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn, start_pfn_aligned, end_pfn_aligned;
> +	start_pfn_aligned = ROUND_DOWN(start_pfn, NR_PAGES_ISOLATION_BLOCK);
> +        end_pfn_aligned = ROUND_UP(end_pfn, NR_PAGES_ISOLATION_BLOCK);

spaces instead of tabs there before end_pfn_aligned.

> +
> +	for (pfn = start_pfn_aligned;
> +	     pfn < end_pfn_aligned;
> +	     pfn += MAX_ORDER_NR_PAGES)

pfn += NR_PAGES_ISOLATION_BLOCK ?

pfn_valid() ?

> +		clear_migratetype_isolate(pfn_to_page(pfn));
> +	return 0;
> +}
> +
> +int
> +test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn;
> +	int ret = 0;
> +

You didn't align here, intentional?

> +	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> +		if (!pfn_valid(pfn))
> +			continue;
> +		if (!is_page_isolated(pfn_to_page(pfn))) {
> +			ret = 1;
> +			break;
> +		}

If the page is isolated, it's free and assuming you've drained the pcp 
lists, it will have PageBuddy() set. In that case, you should be checking 
what order the page is free at and skipping forward that number of pages. 
I am guessing this pfn++ walk here is why you are checking 
page_count(page) == 0 in is_page_isolated() instead of PageBuddy()

> +	}
> +	return ret;

The return value is a little counter-intuitive. It returns 1 if they are 
not isolated. I would expect it to return 1 if isolated like test_bit() 
returns 1 if it's set.

> +}
> Index: devel-2.6.22-rc1-mm1/include/linux/page-isolation.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ devel-2.6.22-rc1-mm1/include/linux/page-isolation.h	2007-05-22 15:12:28.000000000 +0900
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

When grouping-pages-by-arbitary-order goes in, there will be a value 
available called pageblock_order and nr_pages_pageblock which will be 
identical to these two values.

> +/*
> + * set page isolation range.
> + * If specified range includes migrate types other than MOVABLE,
> + * this will fail with -EBUSY.
> + */
> +extern int
> +isolate_pages(unsigned long start_pfn, unsigned long end_pfn);
> +
> +/*
> + * Free all isolated memory and push back them as MIGRATE_RESERVE type.
> + */
> +extern int
> +free_isolated_pages(unsigned long start_pfn, unsigned long end_pfn);
> +
> +/*
> + * test all pages are isolated or not.
> + */
> +extern int
> +test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
> +
> +/* test routine for check page is isolated or not */
> +extern int is_page_isolated(struct page *page);
> +
> +/*
> + * Internal funcs.
> + * Changes pageblock's migrate type
> + */
> +extern int set_migratetype_isolate(struct page *page);
> +extern void clear_migratetype_isolate(struct page *page);
> +extern int __is_page_isolated(struct page *page);
> +
> +
> +#endif
> Index: devel-2.6.22-rc1-mm1/mm/Makefile
> ===================================================================
> --- devel-2.6.22-rc1-mm1.orig/mm/Makefile	2007-05-22 14:30:43.000000000 +0900
> +++ devel-2.6.22-rc1-mm1/mm/Makefile	2007-05-22 15:12:28.000000000 +0900
> @@ -11,7 +11,7 @@
> 			   page_alloc.o page-writeback.o pdflush.o \
> 			   readahead.o swap.o truncate.o vmscan.o \
> 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
> -			   $(mmu-y)
> +			   page_isolation.o $(mmu-y)
>
> ifeq ($(CONFIG_MMU)$(CONFIG_BLOCK),yy)
> obj-y			+= bounce.o
>

All in all, I like this implementation. I found it nice and relatively 
straight-forward to read. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
