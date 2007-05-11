Date: Fri, 11 May 2007 09:47:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory hotremove patch take 2 [02/10] (make page unused)
Message-Id: <20070511094746.15e5f1c3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705101357530.1581@skynet.skynet.ie>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
	<20070509120248.B908.Y-GOTO@jp.fujitsu.com>
	<Pine.LNX.4.64.0705101357530.1581@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: y-goto@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007 16:34:01 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> > +#ifdef CONFIG_PAGE_ISOLATION
> > +	/*
> > +	 *  For pages which are not used but not free.
> > +	 *  See include/linux/page_isolation.h
> > +	 */
> > +	spinlock_t		isolation_lock;
> > +	struct list_head	isolation_list;
> > +#endif
> 
> Using MIGRATE_ISOLATING instead of this approach does mean that there will 
> be MAX_ORDER additional struct free_area added to the zone. That is more 
> lists than this approach.
> 
Thank you!, its an interesting idea. I think it will make our code much
simpler. I'll look into.


> I am somewhat suprised that CONFIG_PAGE_ISOLATION exists as a separate 
> option. If it was a compile-time option at all, I would expect it to 
> depend on memory hot-remove being selected.
> 
I myself think CONFIG_PAGE_ISOLATION can be used by some code which need to
isolate some amount of contiguous pages. So config is divided for now.
Now, CONFIG_MEMORY_HOTREMOVE selects this.
CONFIG_PAGE_ISOLATION and CONFIG_MEMORY_HOTREMOVE will be merged later 
if there are no one who use this except for hot-removal.



> > 	/*
> > 	 * zone_start_pfn, spanned_pages and present_pages are all
> > 	 * protected by span_seqlock.  It is a seqlock because it has
> > Index: current_test/mm/page_alloc.c
> > ===================================================================
> > --- current_test.orig/mm/page_alloc.c	2007-05-08 15:07:20.000000000 +0900
> > +++ current_test/mm/page_alloc.c	2007-05-08 15:08:34.000000000 +0900
> > @@ -41,6 +41,7 @@
> > #include <linux/pfn.h>
> > #include <linux/backing-dev.h>
> > #include <linux/fault-inject.h>
> > +#include <linux/page_isolation.h>
> >
> > #include <asm/tlbflush.h>
> > #include <asm/div64.h>
> > @@ -448,6 +449,9 @@ static inline void __free_one_page(struc
> > 	if (unlikely(PageCompound(page)))
> > 		destroy_compound_page(page, order);
> >
> > +	if (page_under_isolation(zone, page, order))
> > +		return;
> > +
> 
> Using MIGRATE_ISOLATING would avoid a potential list search here.
> 
yes. thank you.

> > 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
> >
> > 	VM_BUG_ON(page_idx & (order_size - 1));
> > @@ -3259,6 +3263,10 @@ static void __meminit free_area_init_cor
> > 		zone->nr_scan_inactive = 0;
> > 		zap_zone_vm_stats(zone);
> > 		atomic_set(&zone->reclaim_in_progress, 0);
> > +#ifdef CONFIG_PAGE_ISOLATION
> > +		spin_lock_init(&zone->isolation_lock);
> > +		INIT_LIST_HEAD(&zone->isolation_list);
> i> +#endif
> > 		if (!size)
> > 			continue;
> >
> > @@ -4214,3 +4222,182 @@ void set_pageblock_flags_group(struct pa
> > 		else
> > 			__clear_bit(bitidx + start_bitidx, bitmap);
> > }
> > +
> > +#ifdef CONFIG_PAGE_ISOLATION
> > +/*
> > + * Page Isolation.
> > + *
> > + * If a page is removed from usual free_list and will never be used,
> > + * It is linked to "struct isolation_info" and set Reserved, Private
> > + * bit. page->mapping points to isolation_info in it.
> > + * and page_count(page) is 0.
> > + *
> > + * This can be used for creating a chunk of contiguous *unused* memory.
> > + *
> > + * current user is Memory-Hot-Remove.
> > + * maybe move to some other file is better.
> 
> page_isolation.c to match the header filename seems reasonable. 
> page_alloc.c has a lot of multi-function stuff like memory initialisation 
> in it.

Hmm.

> 
> > + */
> > +static void
> > +isolate_page_nolock(struct isolation_info *info, struct page *page, int order)
> > +{
> > +	int pagenum;
> > +	pagenum = 1 << order;
> > +	while (pagenum > 0) {
> > +		SetPageReserved(page);
> > +		SetPagePrivate(page);
> > +		page->private = (unsigned long)info;
> > +		list_add(&page->lru, &info->pages);
> > +		page++;
> > +		pagenum--;
> > +	}
> > +}
> 
> It's worth commenting somewhere that pages on the list in isolation_info 
> are always order-0.
> 
okay.

> > +
> > +/*
> > + * This function is called from page_under_isolation()
> > + */
> > +
> > +int __page_under_isolation(struct zone *zone, struct page *page, int order)
> > +{
> > +	struct isolation_info *info;
> > +	unsigned long pfn = page_to_pfn(page);
> > +	unsigned long flags;
> > +	int found = 0;
> > +
> > +	spin_lock_irqsave(&zone->isolation_lock,flags);
> 
> An unwritten convention seems to be that __ versions of same-named 
> functions are the nolock version. i.e. I would expect 
> page_under_isolation() to acquire and release the spinlock and 
> __page_under_isolation() to do no additional locking.
> 
> Locking outside of here might make the flow a little clearer as well if 
> you had two returns and avoided the use of "found".
> 
Maybe MOVABLE_ISOLATING will simplify these code.


> > +	list_for_each_entry(info, &zone->isolation_list, list) {
> > +		if (info->start_pfn <= pfn && pfn < info->end_pfn) {
> > +			found = 1;
> > +			break;
> > +		}
> > +	}
> > +	if (found) {
> > +		isolate_page_nolock(info, page, order);
> > +	}
> > +	spin_unlock_irqrestore(&zone->isolation_lock, flags);
> > +	return found;
> > +}
> > +
> > +/*
> > + * start and end must be in the same zone.
> > + *
> > + */
> > +struct isolation_info  *
> > +register_isolation(unsigned long start, unsigned long end)
> > +{
> > +	struct zone *zone;
> > +	struct isolation_info *info = NULL, *tmp;
> > +	unsigned long flags;
> > +	unsigned long last_pfn = end - 1;
> > +
> > +	if (!pfn_valid(start) || !pfn_valid(last_pfn) || (start >= end))
> > +		return ERR_PTR(-EINVAL);
> > +	/* check start and end is in the same zone */
> > +	zone = page_zone(pfn_to_page(start));
> > +
> > +	if (zone != page_zone(pfn_to_page(last_pfn)))
> > +		return ERR_PTR(-EINVAL);
> > +	/* target range has to match MAX_ORDER alignmet */
> > +	if ((start & (MAX_ORDER_NR_PAGES - 1)) ||
> > +		(end & (MAX_ORDER_NR_PAGES - 1)))
> > +		return ERR_PTR(-EINVAL);
> 
> Why does the range have to be MAX_ORDER alighned?
> 
> > +	info = kmalloc(sizeof(*info), GFP_KERNEL);
> > +	if (!info)
> > +		return ERR_PTR(-ENOMEM);
> > +	spin_lock_irqsave(&zone->isolation_lock, flags);
> > +	/* we don't allow overlap among isolation areas */
> > +	if (!list_empty(&zone->isolation_list)) {
> > +		list_for_each_entry(tmp, &zone->isolation_list, list) {
> > +			if (start < tmp->end_pfn && end > tmp->start_pfn) {
> > +				goto out_free;
> > +			}
> > +		}
> > +	}
> 
> Why not merge requests for overlapping isolations?

This is related to memory-unplug interface. It doesn't allow overlaping.
So this is not expected to happen. just sanity check.
but this code will be removed by MIGRATE_ISOLATING.

Thank you for your good idea.

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
