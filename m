Date: Thu, 10 May 2007 16:34:01 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] memory hotremove patch take 2 [02/10] (make page unused)
In-Reply-To: <20070509120248.B908.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705101357530.1581@skynet.skynet.ie>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
 <20070509120248.B908.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Yasunori Goto wrote:

> This patch is for supporting making page unused.
>

Without reading the patch, this could also be interesting when trying to 
free a block of pages for a contiguous allocation without racing against 
other allocators.

> Isolate pages by capturing freed pages before inserting free_area[],
> buddy allocator.
> If you have an idea for avoiding spin_lock(), please advise me.
>

Again, commenting on this before I read the patch. Grouping pages by 
mobility uses a bitmap to track flags affecting a block of pages. If you 
used a bit there and added a MIGRATE_ISOLATING type, the pages on free 
would get placed in those freelists. As long as MIGRATE_ISOLATING is not 
in fallbacks[] in page_alloc.c, the pages would not get allocated. This 
should avoid the need for a separate spinlock.

That said, it increases the size of struct zone more than yours do and 
ties these patches to a part of grouping pages by mobility which you don't 
do currently.

> Isolating pages in free_area[] is implemented in other patch.
>

I haven't seen that part yet but it sounds like it does something similar 
to move_freepages() so there may be code to be shared there.

> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
>
>
> include/linux/mmzone.h         |    8 +
> include/linux/page_isolation.h |   52 +++++++++++
> mm/Kconfig                     |    7 +
> mm/page_alloc.c                |  187 +++++++++++++++++++++++++++++++++++++++++
> 4 files changed, 254 insertions(+)
>
> Index: current_test/include/linux/mmzone.h
> ===================================================================
> --- current_test.orig/include/linux/mmzone.h	2007-05-08 15:06:49.000000000 +0900
> +++ current_test/include/linux/mmzone.h	2007-05-08 15:08:03.000000000 +0900
> @@ -314,6 +314,14 @@ struct zone {
> 	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
> 	unsigned long		zone_start_pfn;
>
> +#ifdef CONFIG_PAGE_ISOLATION
> +	/*
> +	 *  For pages which are not used but not free.
> +	 *  See include/linux/page_isolation.h
> +	 */
> +	spinlock_t		isolation_lock;
> +	struct list_head	isolation_list;
> +#endif

Using MIGRATE_ISOLATING instead of this approach does mean that there will 
be MAX_ORDER additional struct free_area added to the zone. That is more 
lists than this approach.

I am somewhat suprised that CONFIG_PAGE_ISOLATION exists as a separate 
option. If it was a compile-time option at all, I would expect it to 
depend on memory hot-remove being selected.

> 	/*
> 	 * zone_start_pfn, spanned_pages and present_pages are all
> 	 * protected by span_seqlock.  It is a seqlock because it has
> Index: current_test/mm/page_alloc.c
> ===================================================================
> --- current_test.orig/mm/page_alloc.c	2007-05-08 15:07:20.000000000 +0900
> +++ current_test/mm/page_alloc.c	2007-05-08 15:08:34.000000000 +0900
> @@ -41,6 +41,7 @@
> #include <linux/pfn.h>
> #include <linux/backing-dev.h>
> #include <linux/fault-inject.h>
> +#include <linux/page_isolation.h>
>
> #include <asm/tlbflush.h>
> #include <asm/div64.h>
> @@ -448,6 +449,9 @@ static inline void __free_one_page(struc
> 	if (unlikely(PageCompound(page)))
> 		destroy_compound_page(page, order);
>
> +	if (page_under_isolation(zone, page, order))
> +		return;
> +

Using MIGRATE_ISOLATING would avoid a potential list search here.

> 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
>
> 	VM_BUG_ON(page_idx & (order_size - 1));
> @@ -3259,6 +3263,10 @@ static void __meminit free_area_init_cor
> 		zone->nr_scan_inactive = 0;
> 		zap_zone_vm_stats(zone);
> 		atomic_set(&zone->reclaim_in_progress, 0);
> +#ifdef CONFIG_PAGE_ISOLATION
> +		spin_lock_init(&zone->isolation_lock);
> +		INIT_LIST_HEAD(&zone->isolation_list);
i> +#endif
> 		if (!size)
> 			continue;
>
> @@ -4214,3 +4222,182 @@ void set_pageblock_flags_group(struct pa
> 		else
> 			__clear_bit(bitidx + start_bitidx, bitmap);
> }
> +
> +#ifdef CONFIG_PAGE_ISOLATION
> +/*
> + * Page Isolation.
> + *
> + * If a page is removed from usual free_list and will never be used,
> + * It is linked to "struct isolation_info" and set Reserved, Private
> + * bit. page->mapping points to isolation_info in it.
> + * and page_count(page) is 0.
> + *
> + * This can be used for creating a chunk of contiguous *unused* memory.
> + *
> + * current user is Memory-Hot-Remove.
> + * maybe move to some other file is better.

page_isolation.c to match the header filename seems reasonable. 
page_alloc.c has a lot of multi-function stuff like memory initialisation 
in it.

> + */
> +static void
> +isolate_page_nolock(struct isolation_info *info, struct page *page, int order)
> +{
> +	int pagenum;
> +	pagenum = 1 << order;
> +	while (pagenum > 0) {
> +		SetPageReserved(page);
> +		SetPagePrivate(page);
> +		page->private = (unsigned long)info;
> +		list_add(&page->lru, &info->pages);
> +		page++;
> +		pagenum--;
> +	}
> +}

It's worth commenting somewhere that pages on the list in isolation_info 
are always order-0.

> +
> +/*
> + * This function is called from page_under_isolation()
> + */
> +
> +int __page_under_isolation(struct zone *zone, struct page *page, int order)
> +{
> +	struct isolation_info *info;
> +	unsigned long pfn = page_to_pfn(page);
> +	unsigned long flags;
> +	int found = 0;
> +
> +	spin_lock_irqsave(&zone->isolation_lock,flags);

An unwritten convention seems to be that __ versions of same-named 
functions are the nolock version. i.e. I would expect 
page_under_isolation() to acquire and release the spinlock and 
__page_under_isolation() to do no additional locking.

Locking outside of here might make the flow a little clearer as well if 
you had two returns and avoided the use of "found".

> +	list_for_each_entry(info, &zone->isolation_list, list) {
> +		if (info->start_pfn <= pfn && pfn < info->end_pfn) {
> +			found = 1;
> +			break;
> +		}
> +	}
> +	if (found) {
> +		isolate_page_nolock(info, page, order);
> +	}
> +	spin_unlock_irqrestore(&zone->isolation_lock, flags);
> +	return found;
> +}
> +
> +/*
> + * start and end must be in the same zone.
> + *
> + */
> +struct isolation_info  *
> +register_isolation(unsigned long start, unsigned long end)
> +{
> +	struct zone *zone;
> +	struct isolation_info *info = NULL, *tmp;
> +	unsigned long flags;
> +	unsigned long last_pfn = end - 1;
> +
> +	if (!pfn_valid(start) || !pfn_valid(last_pfn) || (start >= end))
> +		return ERR_PTR(-EINVAL);
> +	/* check start and end is in the same zone */
> +	zone = page_zone(pfn_to_page(start));
> +
> +	if (zone != page_zone(pfn_to_page(last_pfn)))
> +		return ERR_PTR(-EINVAL);
> +	/* target range has to match MAX_ORDER alignmet */
> +	if ((start & (MAX_ORDER_NR_PAGES - 1)) ||
> +		(end & (MAX_ORDER_NR_PAGES - 1)))
> +		return ERR_PTR(-EINVAL);

Why does the range have to be MAX_ORDER alighned?

> +	info = kmalloc(sizeof(*info), GFP_KERNEL);
> +	if (!info)
> +		return ERR_PTR(-ENOMEM);
> +	spin_lock_irqsave(&zone->isolation_lock, flags);
> +	/* we don't allow overlap among isolation areas */
> +	if (!list_empty(&zone->isolation_list)) {
> +		list_for_each_entry(tmp, &zone->isolation_list, list) {
> +			if (start < tmp->end_pfn && end > tmp->start_pfn) {
> +				goto out_free;
> +			}
> +		}
> +	}

Why not merge requests for overlapping isolations?

> +	info->start_pfn = start;
> +	info->end_pfn = end;
> +	info->zone = zone;
> +	INIT_LIST_HEAD(&info->list);
> +	INIT_LIST_HEAD(&info->pages);
> +	list_add(&info->list, &zone->isolation_list);
> +out_unlock:
> +	spin_unlock_irqrestore(&zone->isolation_lock, flags);
> +	return info;
> +out_free:
> +	kfree(info);
> +	info = ERR_PTR(-EBUSY);
> +	goto out_unlock;
> +}
> +/*
> + * Remove IsolationInfo from zone.
> + * After this, we can unuse memory in info or
> + * free back to freelist.
> + */
> +
> +void
> +detach_isolation_info_zone(struct isolation_info *info)
> +{
> +	unsigned long flags;
> +	struct zone *zone = info->zone;
> +	spin_lock_irqsave(&zone->isolation_lock,flags);
> +	list_del(&info->list);
> +	info->zone = NULL;
> +	spin_unlock_irqrestore(&zone->isolation_lock,flags);
> +}
> +
> +/*
> + * All pages in info->pages should be remvoed before calling this.
> + * And info should be detached from zone.
> + */
> +void
> +free_isolation_info(struct isolation_info *info)
> +{
> +	BUG_ON(!list_empty(&info->pages));
> +	BUG_ON(info->zone);
> +	kfree(info);
> +	return;
> +}
> +
> +/*
> + * Mark All pages in the isolation_info to be Reserved.
> + * When onlining these pages again, a user must check
> + * which page is usable by IORESOURCE_RAM
> + * please see memory_hotplug.c/online_pages() if unclear.
> + *
> + * info should be detached from zone before calling this.
> + */
> +void
> +unuse_all_isolated_pages(struct isolation_info *info)
> +{
> +	struct page *page, *n;
> +	BUG_ON(info->zone);
> +	list_for_each_entry_safe(page, n, &info->pages, lru) {
> +		SetPageReserved(page);
> +		page->private = 0;
> +		ClearPagePrivate(page);
> +		list_del(&page->lru);
> +	}
> +}
> +
> +/*
> + * Free all pages connected in isolation list.
> + * pages are moved back to free_list.
> + */
> +void
> +free_all_isolated_pages(struct isolation_info *info)
> +{
> +	struct page *page, *n;
> +	BUG_ON(info->zone);
> +	list_for_each_entry_safe(page, n ,&info->pages, lru) {
> +		ClearPagePrivate(page);
> +		ClearPageReserved(page);
> +		page->private = 0;
> +		list_del(&page->lru);
> +		set_page_count(page, 0);
> +		set_page_refcounted(page);
> +		/* This is sage because info is detached from zone */

s/sage/safe/

> +		__free_page(page);
> +	}
> +}
> +
> +#endif /* CONFIG_PAGE_ISOLATION */
> +
> +
> Index: current_test/mm/Kconfig
> ===================================================================
> --- current_test.orig/mm/Kconfig	2007-05-08 15:06:50.000000000 +0900
> +++ current_test/mm/Kconfig	2007-05-08 15:08:31.000000000 +0900
> @@ -225,3 +225,10 @@ config DEBUG_READAHEAD
>
> 	  Say N for production servers.
>
> +config PAGE_ISOLATION
> +	bool	"Page Isolation Framework"
> +	help
> +	  This option adds page isolation framework to mm.
> +	  This is used for isolate amount of contiguous pages from linux
> +	  memory management.
> +	  Say N if unsure.
> Index: current_test/include/linux/page_isolation.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ current_test/include/linux/page_isolation.h	2007-05-08 15:08:34.000000000 +0900
> @@ -0,0 +1,52 @@
> +#ifndef __LINIX_PAGE_ISOLATION_H
> +#define __LINUX_PAGE_ISOLATION_H
> +
> +#ifdef CONFIG_PAGE_ISOLATION
> +
> +struct isolation_info {
> +	struct list_head	list;
> +	unsigned long	start_pfn;
> +	unsigned long	end_pfn;
> +	struct zone		*zone;
> +	struct list_head	pages;
> +};
> +
> +extern int
> +__page_under_isolation(struct zone *zone, struct page *page, int order);
> +
> +static inline int
> +page_under_isolation(struct zone *zone, struct page *page, int order)
> +{
> +	if (likely(list_empty(&zone->isolation_list)))
> +		return 0;
> +	return __page_under_isolation(zone, page, order);
> +}
> +
> +static inline int
> +is_page_isolated(struct isolation_info *info, struct page *page)
> +{
> +	if (PageReserved(page) && PagePrivate(page) &&
> +	    page_count(page) == 0 &&
> +	    page->private == (unsigned long)info)
> +		return 1;
> +	return 0;
> +}
> +
> +extern struct isolation_info *
> +register_isolation(unsigned long start, unsigned long end);
> +
> +extern void detach_isolation_info_zone(struct isolation_info *info);
> +extern void free_isolation_info(struct isolation_info *info);
> +extern void unuse_all_isolated_pages(struct isolation_info *info);
> +extern void free_all_isolated_pages(struct isolation_info *info);
> +
> +#else
> +
> +static inline int
> +page_under_isolation(struct zone *zone, struct page *page, int order)
> +{
> +	return 0;
> +}
> +
> +#endif
> +#endif
>
> -- 
> Yasunori Goto
>
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
