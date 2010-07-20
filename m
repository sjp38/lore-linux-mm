Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7916B02A4
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 09:46:15 -0400 (EDT)
Date: Tue, 20 Jul 2010 14:45:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20100720134555.GU13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-5-git-send-email-mel@csn.ul.ie> <20100719221420.GA16031@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100719221420.GA16031@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 12:14:20AM +0200, Johannes Weiner wrote:
> Hi Mel,
> 
> On Mon, Jul 19, 2010 at 02:11:26PM +0100, Mel Gorman wrote:
> > @@ -406,7 +461,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
> >  		return PAGE_SUCCESS;
> >  	}
> 
> Did you forget to delete the worker code from pageout() which is now
> in write_reclaim_page()?
> 

Damn, a snarl during the final rebase when collapsing patches together that
I missed when re-reading. Sorry :(

> > -	return PAGE_CLEAN;
> > +	return write_reclaim_page(page, mapping, sync_writeback);
> >  }
> >  
> >  /*
> > @@ -639,6 +694,9 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
> >  	pagevec_free(&freed_pvec);
> >  }
> >  
> > +/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
> > +#define MAX_SWAP_CLEAN_WAIT 50
> > +
> >  /*
> >   * shrink_page_list() returns the number of reclaimed pages
> >   */
> > @@ -646,13 +704,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  					struct scan_control *sc,
> >  					enum pageout_io sync_writeback)
> >  {
> > -	LIST_HEAD(ret_pages);
> >  	LIST_HEAD(free_pages);
> > -	int pgactivate = 0;
> > +	LIST_HEAD(putback_pages);
> > +	LIST_HEAD(dirty_pages);
> > +	int pgactivate;
> > +	int dirty_isolated = 0;
> > +	unsigned long nr_dirty;
> >  	unsigned long nr_reclaimed = 0;
> >  
> > +	pgactivate = 0;
> >  	cond_resched();
> >  
> > +restart_dirty:
> > +	nr_dirty = 0;
> >  	while (!list_empty(page_list)) {
> >  		enum page_references references;
> >  		struct address_space *mapping;
> > @@ -741,7 +805,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  			}
> >  		}
> >  
> > -		if (PageDirty(page)) {
> > +		if (PageDirty(page))  {
> > +			/*
> > +			 * If the caller cannot writeback pages, dirty pages
> > +			 * are put on a separate list for cleaning by either
> > +			 * a flusher thread or kswapd
> > +			 */
> > +			if (!reclaim_can_writeback(sc, page)) {
> > +				list_add(&page->lru, &dirty_pages);
> > +				unlock_page(page);
> > +				nr_dirty++;
> > +				goto keep_dirty;
> > +			}
> > +
> >  			if (references == PAGEREF_RECLAIM_CLEAN)
> >  				goto keep_locked;
> >  			if (!may_enter_fs)
> > @@ -852,13 +928,39 @@ activate_locked:
> >  keep_locked:
> >  		unlock_page(page);
> >  keep:
> > -		list_add(&page->lru, &ret_pages);
> > +		list_add(&page->lru, &putback_pages);
> > +keep_dirty:
> >  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> >  	}
> >  
> > +	if (dirty_isolated < MAX_SWAP_CLEAN_WAIT && !list_empty(&dirty_pages)) {
> > +		/*
> > +		 * Wakeup a flusher thread to clean at least as many dirty
> > +		 * pages as encountered by direct reclaim. Wait on congestion
> > +		 * to throttle processes cleaning dirty pages
> > +		 */
> > +		wakeup_flusher_threads(nr_dirty);
> > +		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +
> > +		/*
> > +		 * As lumpy reclaim and memcg targets specific pages, wait on
> > +		 * them to be cleaned and try reclaim again.
> > +		 */
> > +		if (sync_writeback == PAGEOUT_IO_SYNC ||
> > +						sc->mem_cgroup != NULL) {
> > +			dirty_isolated++;
> > +			list_splice(&dirty_pages, page_list);
> > +			INIT_LIST_HEAD(&dirty_pages);
> > +			goto restart_dirty;
> > +		}
> > +	}
> 
> I think it would turn out more natural to just return dirty pages on
> page_list and have the whole looping logic in shrink_inactive_list().
> 
> Mixing dirty pages with other 'please try again' pages is probably not
> so bad anyway, it means we could retry all temporary unavailable pages
> instead of twiddling thumbs over that particular bunch of pages until
> the flushers catch up.
> 
> What do you think?
> 

It's worth considering! It won't be very tidy but it's workable. The reason
it is not tidy is that dirty pages and pages that couldn't be paged will be
on the same list so they whole lot will need to be recycled. We'd record in
scan_control though that there were pages that need to be retried and loop
based on that value. That is managable though.

The reason why I did it this way was because of lumpy reclaim and memcg
requiring specific pages. I considered lumpy reclaim to be the more common
case. In that case, it's removing potentially a large number of pages from
the LRU that are contiguous. If some of those are dirty and it selects more
contiguous ranges for reclaim, I'd worry that lumpy reclaim would trash the
system even worse than it currently does when the system is under load. Hence,
this wait and retry loop is done instead of returning and isolating more pages.

For memcg, the concern was different. It is depending on flusher threads
to clean its pages, kswapd does not operate on the list and it can't clean
pages itself because the stack may overflow. If the memcg has many dirty
pages, one process in the container could isolate all the dirty pages in
the list forcing others to reclaim clean pages regardless of age. This
could be very disruptive but looping like this throttling processes that
encounter dirty pages instead of isolating more.

For lumpy, I don't think we should return and isolate more pages, it's
too disruptive. For memcg, I think it could possibly get an advantage
but there is a nasty corner case if the container is mostly dirty - it
depends on how memcg handles dirty_ratio I guess.

Is it worth it at this point?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
