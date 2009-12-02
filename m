Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B376E6007DB
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 09:25:56 -0500 (EST)
Date: Wed, 2 Dec 2009 14:25:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH 4/4] vmscan: vmscan don't use pcp list
Message-ID: <20091202142534.GG1457@csn.ul.ie>
References: <20091127091920.A7D5.A69D9226@jp.fujitsu.com> <20091127161715.GO13095@csn.ul.ie> <20091202140125.5C5E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091202140125.5C5E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 04:15:37PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> sorry for the delayed reply. I've got stucked in Larry's serious bug report awhile.
> 

No worries. I am slow to respond at the best of times.

> > On Fri, Nov 27, 2009 at 09:23:57AM +0900, KOSAKI Motohiro wrote:
> > > 
> > > note: Last year,  Andy Whitcroft reported pcp prevent to make contenious
> > > high order page when lumpy reclaim is running.
> > 
> > I don't remember the specifics of the discussion but I know that when
> > that patch series was being prototyped, it was because order-0
> > allocations were racing with lumpy reclaimers. A lumpy reclaim might
> > free up an order-9 page say but while it was freeing, an order-0 page
> > would be allocated from the middle. It wasn't the PCP lists as such that
> > were a problem once they were getting drained as part of a high-order
> > allocation attempt. It would be just as bad if the order-0 page was
> > taken from the buddy lists.
> 
> Hm, probably I have to update my patch description.
> if we use pavevec_free(), batch size is PAGEVEC_SIZE(=14).
> then, order-9 lumpy reclaim makes 37 times pagevec_free(). it makes lots
> temporary uncontenious memory block and the chance of stealing it from
> order-0 allocator task.
> 

Very true. It opens a wide window during with other allocation requests
can race with the lumpy reclaimer and undo their work.

> This patch free all reclaimed pages at once to buddy.
> 

Which is good. It reduces the window during which trouble can happen
considerably.

> > > He posted "capture pages freed during direct reclaim for allocation by the reclaimer"
> > > patch series, but Christoph mentioned simple bypass pcp instead.
> > > I made it. I'd hear Christoph and Mel's mention.
> > > 
> > > ==========================
> > > Currently vmscan free unused pages by __pagevec_free().  It mean free pages one by one
> > > and use pcp. it makes two suboptimal result.
> > > 
> > >  - The another task can steal the freed page in pcp easily. it decrease
> > >    lumpy reclaim worth.
> > >  - To pollute pcp cache, vmscan freed pages might kick out cache hot
> > >    pages from pcp.
> > > 
> > 
> > The latter point is interesting.
> 
> Thank you.
> 

Another point is that lumpy reclaim releases pages via the PCP means that
a part of the contiguous page is "stuck" in the PCP lists. This is evaded
by doing a drain_all_pages() for high-order allocation requests that are
failing. I suspect that your patch will reduce the number of times the PCP
lists are drained.

> > > This patch make new free_pages_bulk() function and vmscan use it.
> > > 
> > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > ---
> > >  include/linux/gfp.h |    2 +
> > >  mm/page_alloc.c     |   56 +++++++++++++++++++++++++++++++++++++++++++++++++++
> > >  mm/vmscan.c         |   23 +++++++++++----------
> > >  3 files changed, 70 insertions(+), 11 deletions(-)
> > > 
> > > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > > index f53e9b8..403584d 100644
> > > --- a/include/linux/gfp.h
> > > +++ b/include/linux/gfp.h
> > > @@ -330,6 +330,8 @@ extern void free_hot_page(struct page *page);
> > >  #define __free_page(page) __free_pages((page), 0)
> > >  #define free_page(addr) free_pages((addr),0)
> > >  
> > > +void free_pages_bulk(struct zone *zone, int count, struct list_head *list);
> > > +
> > >  void page_alloc_init(void);
> > >  void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
> > >  void drain_all_pages(void);
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 11ae66e..f77f8a8 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2037,6 +2037,62 @@ void free_pages(unsigned long addr, unsigned int order)
> > >  
> > >  EXPORT_SYMBOL(free_pages);
> > >  
> > > +/*
> > > + * Frees a number of pages from the list
> > > + * Assumes all pages on list are in same zone and order==0.
> > > + * count is the number of pages to free.
> > > + *
> > > + * This is similar to __pagevec_free(), but receive list instead pagevec.
> > > + * and this don't use pcp cache. it is good characteristics for vmscan.
> > > + */
> > > +void free_pages_bulk(struct zone *zone, int count, struct list_head *list)
> > > +{
> > > +	unsigned long flags;
> > > +	struct page *page;
> > > +	struct page *page2;
> > > +
> > > +	list_for_each_entry_safe(page, page2, list, lru) {
> > > +		int wasMlocked = __TestClearPageMlocked(page);
> > > +
> > > +		kmemcheck_free_shadow(page, 0);
> > > +
> > > +		if (PageAnon(page))
> > > +			page->mapping = NULL;
> > > +		if (free_pages_check(page)) {
> > > +			/* orphan this page. */
> > > +			list_del(&page->lru);
> > > +			continue;
> > > +		}
> > > +		if (!PageHighMem(page)) {
> > > +			debug_check_no_locks_freed(page_address(page),
> > > +						   PAGE_SIZE);
> > > +			debug_check_no_obj_freed(page_address(page), PAGE_SIZE);
> > > +		}
> > > +		arch_free_page(page, 0);
> > > +		kernel_map_pages(page, 1, 0);
> > > +
> > > +		local_irq_save(flags);
> > > +		if (unlikely(wasMlocked))
> > > +			free_page_mlock(page);
> > > +		local_irq_restore(flags);
> > > +	}
> > > +
> > > +	spin_lock_irqsave(&zone->lock, flags);
> > > +	__count_vm_events(PGFREE, count);
> > > +	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> > > +	zone->pages_scanned = 0;
> > > +
> > > +	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> > > +
> > > +	list_for_each_entry_safe(page, page2, list, lru) {
> > > +		/* have to delete it as __free_one_page list manipulates */
> > > +		list_del(&page->lru);
> > > +		trace_mm_page_free_direct(page, 0);
> > > +		__free_one_page(page, zone, 0, page_private(page));
> > > +	}
> > > +	spin_unlock_irqrestore(&zone->lock, flags);
> > > +}
> > 
> > It would be preferable that the bulk free code would use as much of the
> > existing free logic in the page allocator as possible. This is making a
> > lot of checks that are done elsewhere. As this is an RFC, it's not
> > critical but worth bearing in mind.
> 
> Sure. I have to merge common block. thanks.
> 
> 
> > > +
> > >  /**
> > >   * alloc_pages_exact - allocate an exact number physically-contiguous pages.
> > >   * @size: the number of bytes to allocate
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 56faefb..00156f2 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -598,18 +598,17 @@ redo:
> > >   * shrink_page_list() returns the number of reclaimed pages
> > >   */
> > >  static unsigned long shrink_page_list(struct list_head *page_list,
> > > +				      struct list_head *freed_pages_list,
> > >  					struct scan_control *sc,
> > 
> > Should the freed_pages_list be part of scan_control?
> 
> OK.
> 
> > 
> > >  					enum pageout_io sync_writeback)
> > >  {
> > >  	LIST_HEAD(ret_pages);
> > > -	struct pagevec freed_pvec;
> > >  	int pgactivate = 0;
> > >  	unsigned long nr_reclaimed = 0;
> > >  	unsigned long vm_flags;
> > >  
> > >  	cond_resched();
> > >  
> > > -	pagevec_init(&freed_pvec, 1);
> > >  	while (!list_empty(page_list)) {
> > >  		struct address_space *mapping;
> > >  		struct page *page;
> > > @@ -785,10 +784,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  		__clear_page_locked(page);
> > >  free_it:
> > >  		nr_reclaimed++;
> > > -		if (!pagevec_add(&freed_pvec, page)) {
> > > -			__pagevec_free(&freed_pvec);
> > > -			pagevec_reinit(&freed_pvec);
> > > -		}
> > > +		list_add(&page->lru, freed_pages_list);
> > >  		continue;
> > >  
> > >  cull_mlocked:
> > > @@ -812,8 +808,6 @@ keep:
> > >  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> > >  	}
> > >  	list_splice(&ret_pages, page_list);
> > > -	if (pagevec_count(&freed_pvec))
> > > -		__pagevec_free(&freed_pvec);
> > >  	count_vm_events(PGACTIVATE, pgactivate);
> > >  	return nr_reclaimed;
> > >  }
> > > @@ -1100,6 +1094,7 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> > >  					  int priority, int file)
> > >  {
> > >  	LIST_HEAD(page_list);
> > > +	LIST_HEAD(freed_pages_list);
> > >  	struct pagevec pvec;
> > >  	unsigned long nr_scanned;
> > >  	unsigned long nr_reclaimed = 0;
> > > @@ -1174,7 +1169,8 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> > >  
> > >  	spin_unlock_irq(&zone->lru_lock);
> > >  
> > > -	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
> > > +	nr_reclaimed = shrink_page_list(&page_list, &freed_pages_list, sc,
> > > +					PAGEOUT_IO_ASYNC);
> > >  
> > >  	/*
> > >  	 * If we are direct reclaiming for contiguous pages and we do
> > > @@ -1192,10 +1188,15 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> > >  		nr_active = clear_active_flags(&page_list, count);
> > >  		count_vm_events(PGDEACTIVATE, nr_active);
> > >  
> > > -		nr_reclaimed += shrink_page_list(&page_list, sc,
> > > -						 PAGEOUT_IO_SYNC);
> > > +		nr_reclaimed += shrink_page_list(&page_list, &freed_pages_list,
> > > +						 sc, PAGEOUT_IO_SYNC);
> > >  	}
> > >  
> > > +	/*
> > > +	 * Free unused pages.
> > > +	 */
> > > +	free_pages_bulk(zone, nr_reclaimed, &freed_pages_list);
> > > +
> > >  	local_irq_disable();
> > >  	if (current_is_kswapd())
> > >  		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
> > 
> > This patch does not stand-alone so it's not easy to test. I'll think about
> > the idea more although I do see how it might help slightly in the same way
> > capture-reclaim did by closing the race window with other allocators.
> > 
> > I'm curious, how did you evaluate this and what problem did you
> > encounter that this might help?
> 
> Honestly I didn't it yet. I only tested changing locking scheme didn't cause
> reclaim throughput under light VM pressure. Probably I have to contact 
> Andy and test his original problem workload.
> 
> btw, if you have good high order allocation workload, can you please tell me it?
> 

For the most part, he was using the same tests as I was using for the
anti-fragmentation patches - high-order allocation requests under a heavy
compile-load. The expectation was that capture-based reclaim would increase
success rates and reduce latencies.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
