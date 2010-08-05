Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3786B02AE
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 10:09:14 -0400 (EDT)
Date: Thu, 5 Aug 2010 15:09:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when
	reclaim is encountering dirty pages
Message-ID: <20100805140946.GC25688@csn.ul.ie>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie> <1280497020-22816-7-git-send-email-mel@csn.ul.ie> <20100805153257.31D2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100805153257.31D2.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 03:45:24PM +0900, KOSAKI Motohiro wrote:
> 
> sorry for the _very_ delayed review.
> 

Not to worry.

> > <SNIP>
> > +/*
> > + * When reclaim encounters dirty data, wakeup flusher threads to clean
> > + * a maximum of 4M of data.
> > + */
> > +#define MAX_WRITEBACK (4194304UL >> PAGE_SHIFT)
> > +#define WRITEBACK_FACTOR (MAX_WRITEBACK / SWAP_CLUSTER_MAX)
> > +static inline long nr_writeback_pages(unsigned long nr_dirty)
> > +{
> > +	return laptop_mode ? 0 :
> > +			min(MAX_WRITEBACK, (nr_dirty * WRITEBACK_FACTOR));
> > +}
> 
> ??
> 
> As far as I remembered, Hannes pointed out wakeup_flusher_threads(0) is
> incorrect. can you fix this?
> 

It's behaving as it should, see http://lkml.org/lkml/2010/7/20/151

> 
> 
> > +
> >  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> >  						  struct scan_control *sc)
> >  {
> > @@ -649,12 +661,14 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
> >  static unsigned long shrink_page_list(struct list_head *page_list,
> >  					struct scan_control *sc,
> >  					enum pageout_io sync_writeback,
> > +					int file,
> >  					unsigned long *nr_still_dirty)
> >  {
> >  	LIST_HEAD(ret_pages);
> >  	LIST_HEAD(free_pages);
> >  	int pgactivate = 0;
> >  	unsigned long nr_dirty = 0;
> > +	unsigned long nr_dirty_seen = 0;
> >  	unsigned long nr_reclaimed = 0;
> >  
> >  	cond_resched();
> > @@ -748,6 +762,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  		}
> >  
> >  		if (PageDirty(page)) {
> > +			nr_dirty_seen++;
> > +
> >  			/*
> >  			 * Only kswapd can writeback filesystem pages to
> >  			 * avoid risk of stack overflow
> > @@ -875,6 +891,18 @@ keep:
> >  
> >  	list_splice(&ret_pages, page_list);
> >  
> > +	/*
> > +	 * If reclaim is encountering dirty pages, it may be because
> > +	 * dirty pages are reaching the end of the LRU even though the
> > +	 * dirty_ratio may be satisified. In this case, wake flusher
> > +	 * threads to pro-actively clean up to a maximum of
> > +	 * 4 * SWAP_CLUSTER_MAX amount of data (usually 1/2MB) unless
> > +	 * !may_writepage indicates that this is a direct reclaimer in
> > +	 * laptop mode avoiding disk spin-ups
> > +	 */
> > +	if (file && nr_dirty_seen && sc->may_writepage)
> > +		wakeup_flusher_threads(nr_writeback_pages(nr_dirty));
> 
> Umm..
> I don't think this guessing is so acculate. following is brief of
> current isolate_lru_pages().
> 
> 
> static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>                 struct list_head *src, struct list_head *dst,
>                 unsigned long *scanned, int order, int mode, int file)
> {
>         for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
> 		__isolate_lru_page(page, mode, file))
> 
>                 if (!order)
>                         continue;
> 
>                 /*
>                  * Attempt to take all pages in the order aligned region
>                  * surrounding the tag page.  Only take those pages of
>                  * the same active state as that tag page.  We may safely
>                  * round the target page pfn down to the requested order
>                  * as the mem_map is guarenteed valid out to MAX_ORDER,
>                  * where that page is in a different zone we will detect
>                  * it from its zone id and abort this block scan.
>                  */
>                 for (; pfn < end_pfn; pfn++) {
>                         struct page *cursor_page;
> 			(snip)
> 		}
> 
> (This was unchanged since initial lumpy reclaim commit)
> 

I think what you are pointing out is that when lumpy-reclaiming from the anon
LRU, there may be file pages on the page_list being shrinked. In that case, we
might miss an opportunity to wake the flusher threads when it was appropriate.

Is that accurate or have you another concern?

> That said, merely order-1 isolate_lru_pages(ISOLATE_INACTIVE) makes pfn
> neighbor search. then, we might found dirty pages even though the page
> don't stay in end of lru.
> 
> What do you think?
> 

For low-order lumpy reclaim, I think it should only be necessary to wake
the flusher threads when scanning the file LRU. While there may be file
pages lumpy reclaimed while scanning the anon list, I think we would
have to show it was a common and real problem before adding the
necessary accounting and checks.

> 
> > +
> >  	*nr_still_dirty = nr_dirty;
> >  	count_vm_events(PGACTIVATE, pgactivate);
> >  	return nr_reclaimed;
> > @@ -1315,7 +1343,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >  	spin_unlock_irq(&zone->lru_lock);
> >  
> >  	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC,
> > -								&nr_dirty);
> > +							file, &nr_dirty);
> >  
> >  	/*
> >  	 * If specific pages are needed such as with direct reclaiming
> > @@ -1351,7 +1379,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >  			count_vm_events(PGDEACTIVATE, nr_active);
> >  
> >  			nr_reclaimed += shrink_page_list(&page_list, sc,
> > -						PAGEOUT_IO_SYNC, &nr_dirty);
> > +						PAGEOUT_IO_SYNC, file,
> > +						&nr_dirty);
> >  		}
> >  	}
> >  
> > -- 
> > 1.7.1
> > 
> 
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
