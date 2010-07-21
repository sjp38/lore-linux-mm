Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9D96E6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 07:53:09 -0400 (EDT)
Date: Wed, 21 Jul 2010 12:52:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20100721115250.GX13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-5-git-send-email-mel@csn.ul.ie> <20100719221420.GA16031@cmpxchg.org> <20100720134555.GU13117@csn.ul.ie> <20100720220218.GE16031@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100720220218.GE16031@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 12:02:18AM +0200, Johannes Weiner wrote:
> On Tue, Jul 20, 2010 at 02:45:56PM +0100, Mel Gorman wrote:
> > On Tue, Jul 20, 2010 at 12:14:20AM +0200, Johannes Weiner wrote:
> > > > @@ -639,6 +694,9 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
> > > >  	pagevec_free(&freed_pvec);
> > > >  }
> > > >  
> > > > +/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
> > > > +#define MAX_SWAP_CLEAN_WAIT 50
> > > > +
> > > >  /*
> > > >   * shrink_page_list() returns the number of reclaimed pages
> > > >   */
> > > > @@ -646,13 +704,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > > >  					struct scan_control *sc,
> > > >  					enum pageout_io sync_writeback)
> > > >  {
> > > > -	LIST_HEAD(ret_pages);
> > > >  	LIST_HEAD(free_pages);
> > > > -	int pgactivate = 0;
> > > > +	LIST_HEAD(putback_pages);
> > > > +	LIST_HEAD(dirty_pages);
> > > > +	int pgactivate;
> > > > +	int dirty_isolated = 0;
> > > > +	unsigned long nr_dirty;
> > > >  	unsigned long nr_reclaimed = 0;
> > > >  
> > > > +	pgactivate = 0;
> > > >  	cond_resched();
> > > >  
> > > > +restart_dirty:
> > > > +	nr_dirty = 0;
> > > >  	while (!list_empty(page_list)) {
> > > >  		enum page_references references;
> > > >  		struct address_space *mapping;
> > > > @@ -741,7 +805,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > > >  			}
> > > >  		}
> > > >  
> > > > -		if (PageDirty(page)) {
> > > > +		if (PageDirty(page))  {
> > > > +			/*
> > > > +			 * If the caller cannot writeback pages, dirty pages
> > > > +			 * are put on a separate list for cleaning by either
> > > > +			 * a flusher thread or kswapd
> > > > +			 */
> > > > +			if (!reclaim_can_writeback(sc, page)) {
> > > > +				list_add(&page->lru, &dirty_pages);
> > > > +				unlock_page(page);
> > > > +				nr_dirty++;
> > > > +				goto keep_dirty;
> > > > +			}
> > > > +
> > > >  			if (references == PAGEREF_RECLAIM_CLEAN)
> > > >  				goto keep_locked;
> > > >  			if (!may_enter_fs)
> > > > @@ -852,13 +928,39 @@ activate_locked:
> > > >  keep_locked:
> > > >  		unlock_page(page);
> > > >  keep:
> > > > -		list_add(&page->lru, &ret_pages);
> > > > +		list_add(&page->lru, &putback_pages);
> > > > +keep_dirty:
> > > >  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> > > >  	}
> > > >  
> > > > +	if (dirty_isolated < MAX_SWAP_CLEAN_WAIT && !list_empty(&dirty_pages)) {
> > > > +		/*
> > > > +		 * Wakeup a flusher thread to clean at least as many dirty
> > > > +		 * pages as encountered by direct reclaim. Wait on congestion
> > > > +		 * to throttle processes cleaning dirty pages
> > > > +		 */
> > > > +		wakeup_flusher_threads(nr_dirty);
> > > > +		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > > > +
> > > > +		/*
> > > > +		 * As lumpy reclaim and memcg targets specific pages, wait on
> > > > +		 * them to be cleaned and try reclaim again.
> > > > +		 */
> > > > +		if (sync_writeback == PAGEOUT_IO_SYNC ||
> > > > +						sc->mem_cgroup != NULL) {
> > > > +			dirty_isolated++;
> > > > +			list_splice(&dirty_pages, page_list);
> > > > +			INIT_LIST_HEAD(&dirty_pages);
> > > > +			goto restart_dirty;
> > > > +		}
> > > > +	}
> > > 
> > > I think it would turn out more natural to just return dirty pages on
> > > page_list and have the whole looping logic in shrink_inactive_list().
> > > 
> > > Mixing dirty pages with other 'please try again' pages is probably not
> > > so bad anyway, it means we could retry all temporary unavailable pages
> > > instead of twiddling thumbs over that particular bunch of pages until
> > > the flushers catch up.
> > > 
> > > What do you think?
> > > 
> > 
> > It's worth considering! It won't be very tidy but it's workable. The reason
> > it is not tidy is that dirty pages and pages that couldn't be paged will be
> > on the same list so they whole lot will need to be recycled. We'd record in
> > scan_control though that there were pages that need to be retried and loop
> > based on that value. That is managable though.
> 
> Recycling all of them is what I had in mind, yeah.  But...
> 
> > The reason why I did it this way was because of lumpy reclaim and memcg
> > requiring specific pages. I considered lumpy reclaim to be the more common
> > case. In that case, it's removing potentially a large number of pages from
> > the LRU that are contiguous. If some of those are dirty and it selects more
> > contiguous ranges for reclaim, I'd worry that lumpy reclaim would trash the
> > system even worse than it currently does when the system is under load. Hence,
> > this wait and retry loop is done instead of returning and isolating more pages.
> 
> I think here we missed each other.  I don't want the loop to be _that_
> much more in the outer scope that isolation is repeated as well. 

My bad.

> What
> I had in mind is the attached patch.  It is not tested and hacked up
> rather quickly due to time constraints, sorry, but you should get the
> idea.  I hope I did not miss anything fundamental.
> 
> Note that since only kswapd enters pageout() anymore, everything
> depending on PAGEOUT_IO_SYNC in there is moot, since there are no sync
> cycles for kswapd.  Just to mitigate the WTF-count on the patch :-)
> 

Anon page writeback can enter pageout. See

static inline bool reclaim_can_writeback(struct scan_control *sc,
                                        struct page *page)
{
        return !page_is_file_cache(page) || current_is_kswapd();
}

So the logic still applies.


> 	Hannes
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -386,21 +386,17 @@ static pageout_t pageout(struct page *pa
>  			ClearPageReclaim(page);
>  			return PAGE_ACTIVATE;
>  		}
> -
> -		/*
> -		 * Wait on writeback if requested to. This happens when
> -		 * direct reclaiming a large contiguous area and the
> -		 * first attempt to free a range of pages fails.
> -		 */
> -		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
> -			wait_on_page_writeback(page);
> -

I'm assuming this should still remain because it can apply to anon page
writeback (i.e. being swapped)?

>  		if (!PageWriteback(page)) {
>  			/* synchronous write or broken a_ops? */
>  			ClearPageReclaim(page);
>  		}
>  		trace_mm_vmscan_writepage(page,
>  			page_is_file_cache(page),
> +			/*
> +			 * Humm.  Only kswapd comes here and for
> +			 * kswapd there never is a PAGEOUT_IO_SYNC
> +			 * cycle...
> +			 */
>  			sync_writeback == PAGEOUT_IO_SYNC);
>  		inc_zone_page_state(page, NR_VMSCAN_WRITE);

To clarify, see the following example of writeback stats - the anon sync
I/O in particular

Direct reclaim pages scanned                156940     150720     145472 142254 
Direct reclaim write file async I/O           2472          0          0 0 
Direct reclaim write anon async I/O          29281      27195      27968 25519 
Direct reclaim write file sync I/O            1943          0          0 0 
Direct reclaim write anon sync I/O           11777      12488      10835 4806 

>  		return PAGE_SUCCESS;
> @@ -643,12 +639,14 @@ static noinline_for_stack void free_page
>   * shrink_page_list() returns the number of reclaimed pages
>   */
>  static unsigned long shrink_page_list(struct list_head *page_list,
> -					struct scan_control *sc,
> -					enum pageout_io sync_writeback)
> +				      struct scan_control *sc,
> +				      enum pageout_io sync_writeback,
> +				      int *dirty_seen)
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
>  	int pgactivate = 0;
> +	unsigned long nr_dirty = 0;
>  	unsigned long nr_reclaimed = 0;
>  
>  	cond_resched();
> @@ -657,7 +655,7 @@ static unsigned long shrink_page_list(st
>  		enum page_references references;
>  		struct address_space *mapping;
>  		struct page *page;
> -		int may_enter_fs;
> +		int may_pageout;
>  
>  		cond_resched();
>  
> @@ -681,10 +679,15 @@ static unsigned long shrink_page_list(st
>  		if (page_mapped(page) || PageSwapCache(page))
>  			sc->nr_scanned++;
>  
> -		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> +		/*
> +		 * To prevent stack overflows, only kswapd can enter
> +		 * the filesystem.  Swap IO is always fine (for now).
> +		 */
> +		may_pageout = current_is_kswapd() ||
>  			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
>  

We lost the __GFP_FS check and it's vaguely possible kswapd could call the
allocator with GFP_NOFS. While you check it before wait_on_page_writeback it
needs to be checked before calling pageout(). I toyed around with
creating a may_pageout that took everything into account but I couldn't
convince myself there was no holes or serious change in functionality.

>  		if (PageWriteback(page)) {
> +			int may_wait;
>  			/*
>  			 * Synchronous reclaim is performed in two passes,
>  			 * first an asynchronous pass over the list to
> @@ -693,7 +696,8 @@ static unsigned long shrink_page_list(st
>  			 * for any page for which writeback has already
>  			 * started.
>  			 */
> -			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
> +			may_wait = (sc->gfp_mask & __GFP_FS) || may_pageout;
> +			if (sync_writeback == PAGEOUT_IO_SYNC && may_wait)
>  				wait_on_page_writeback(page);
>  			else
>  				goto keep_locked;
> @@ -719,7 +723,7 @@ static unsigned long shrink_page_list(st
>  				goto keep_locked;
>  			if (!add_to_swap(page))
>  				goto activate_locked;
> -			may_enter_fs = 1;
> +			may_pageout = 1;
>  		}
>  
>  		mapping = page_mapping(page);
> @@ -742,9 +746,11 @@ static unsigned long shrink_page_list(st
>  		}
>  
>  		if (PageDirty(page)) {
> +			nr_dirty++;
> +
>  			if (references == PAGEREF_RECLAIM_CLEAN)
>  				goto keep_locked;
> -			if (!may_enter_fs)
> +			if (!may_pageout)
>  				goto keep_locked;
>  			if (!sc->may_writepage)
>  				goto keep_locked;
> @@ -860,6 +866,7 @@ keep:
>  
>  	list_splice(&ret_pages, page_list);
>  	count_vm_events(PGACTIVATE, pgactivate);
> +	*dirty_seen = nr_dirty;
>  	return nr_reclaimed;
>  }
>  
> @@ -1232,6 +1239,9 @@ static noinline_for_stack void update_is
>  	reclaim_stat->recent_scanned[1] += *nr_file;
>  }
>  
> +/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
> +#define MAX_SWAP_CLEAN_WAIT 50
> +
>  /*
>   * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
>   * of reclaimed pages
> @@ -1247,6 +1257,7 @@ shrink_inactive_list(unsigned long nr_to
>  	unsigned long nr_active;
>  	unsigned long nr_anon;
>  	unsigned long nr_file;
> +	unsigned long nr_dirty;
>  
>  	while (unlikely(too_many_isolated(zone, file, sc))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -1295,26 +1306,34 @@ shrink_inactive_list(unsigned long nr_to
>  
>  	spin_unlock_irq(&zone->lru_lock);
>  
> -	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
> -
> +	nr_reclaimed = shrink_page_list(&page_list, sc,
> +					PAGEOUT_IO_ASYNC,
> +					&nr_dirty);
>  	/*
>  	 * If we are direct reclaiming for contiguous pages and we do
>  	 * not reclaim everything in the list, try again and wait
>  	 * for IO to complete. This will stall high-order allocations
>  	 * but that should be acceptable to the caller
>  	 */
> -	if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
> -			sc->lumpy_reclaim_mode) {
> -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> +	if (!current_is_kswapd() && sc->lumpy_reclaim_mode || sc->mem_cgroup) {
> +		int dirty_retry = MAX_SWAP_CLEAN_WAIT;
>  
> -		/*
> -		 * The attempt at page out may have made some
> -		 * of the pages active, mark them inactive again.
> -		 */
> -		nr_active = clear_active_flags(&page_list, NULL);
> -		count_vm_events(PGDEACTIVATE, nr_active);
> +		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
> +			wakeup_flusher_threads(nr_dirty);
> +			congestion_wait(BLK_RW_ASYNC, HZ/10);
> +			/*
> +			 * The attempt at page out may have made some
> +			 * of the pages active, mark them inactive again.
> +			 *
> +			 * Humm.  Still needed?
> +			 */
> +			nr_active = clear_active_flags(&page_list, NULL);
> +			count_vm_events(PGDEACTIVATE, nr_active);
>  

I don't see why it would be removed.

> -		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
> +			nr_reclaimed += shrink_page_list(&page_list, sc,
> +							 PAGEOUT_IO_SYNC,
> +							 &nr_dirty);
> +		}
>  	}
>  
>  	local_irq_disable();

Ok, is this closer to what you had in mind?

==== CUT HERE ====
[PATCH] vmscan: Do not writeback filesystem pages in direct reclaim

When memory is under enough pressure, a process may enter direct
reclaim to free pages in the same manner kswapd does. If a dirty page is
encountered during the scan, this page is written to backing storage using
mapping->writepage. This can result in very deep call stacks, particularly
if the target storage or filesystem are complex. It has already been observed
on XFS that the stack overflows but the problem is not XFS-specific.

This patch prevents direct reclaim writing back filesystem pages by checking
if current is kswapd or the page is anonymous before writing back.  If the
dirty pages cannot be written back, they are placed back on the LRU lists
for either background writing by the BDI threads or kswapd. If in direct
lumpy reclaim and dirty pages are encountered, the process will stall for
the background flusher before trying to reclaim the pages again.

As the call-chain for writing anonymous pages is not expected to be deep
and they are not cleaned by flusher threads, anonymous pages are still
written back in direct reclaim.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6587155..e3a5816 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -323,6 +323,51 @@ typedef enum {
 	PAGE_CLEAN,
 } pageout_t;
 
+int write_reclaim_page(struct page *page, struct address_space *mapping,
+						enum pageout_io sync_writeback)
+{
+	int res;
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = SWAP_CLUSTER_MAX,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
+		.nonblocking = 1,
+		.for_reclaim = 1,
+	};
+
+	if (!clear_page_dirty_for_io(page))
+		return PAGE_CLEAN;
+
+	SetPageReclaim(page);
+	res = mapping->a_ops->writepage(page, &wbc);
+	if (res < 0)
+		handle_write_error(mapping, page, res);
+	if (res == AOP_WRITEPAGE_ACTIVATE) {
+		ClearPageReclaim(page);
+		return PAGE_ACTIVATE;
+	}
+
+	/*
+	 * Wait on writeback if requested to. This happens when
+	 * direct reclaiming a large contiguous area and the
+	 * first attempt to free a range of pages fails.
+	 */
+	if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
+		wait_on_page_writeback(page);
+
+	if (!PageWriteback(page)) {
+		/* synchronous write or broken a_ops? */
+		ClearPageReclaim(page);
+	}
+	trace_mm_vmscan_writepage(page,
+		page_is_file_cache(page),
+		sync_writeback == PAGEOUT_IO_SYNC);
+	inc_zone_page_state(page, NR_VMSCAN_WRITE);
+
+	return PAGE_SUCCESS;
+}
+
 /*
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
@@ -367,46 +412,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
 
-	if (clear_page_dirty_for_io(page)) {
-		int res;
-		struct writeback_control wbc = {
-			.sync_mode = WB_SYNC_NONE,
-			.nr_to_write = SWAP_CLUSTER_MAX,
-			.range_start = 0,
-			.range_end = LLONG_MAX,
-			.nonblocking = 1,
-			.for_reclaim = 1,
-		};
-
-		SetPageReclaim(page);
-		res = mapping->a_ops->writepage(page, &wbc);
-		if (res < 0)
-			handle_write_error(mapping, page, res);
-		if (res == AOP_WRITEPAGE_ACTIVATE) {
-			ClearPageReclaim(page);
-			return PAGE_ACTIVATE;
-		}
-
-		/*
-		 * Wait on writeback if requested to. This happens when
-		 * direct reclaiming a large contiguous area and the
-		 * first attempt to free a range of pages fails.
-		 */
-		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
-			wait_on_page_writeback(page);
-
-		if (!PageWriteback(page)) {
-			/* synchronous write or broken a_ops? */
-			ClearPageReclaim(page);
-		}
-		trace_mm_vmscan_writepage(page,
-			page_is_file_cache(page),
-			sync_writeback == PAGEOUT_IO_SYNC);
-		inc_zone_page_state(page, NR_VMSCAN_WRITE);
-		return PAGE_SUCCESS;
-	}
-
-	return PAGE_CLEAN;
+	return write_reclaim_page(page, mapping, sync_writeback);
 }
 
 /*
@@ -639,18 +645,25 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
 	pagevec_free(&freed_pvec);
 }
 
+/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
+#define MAX_SWAP_CLEAN_WAIT 50
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
-					enum pageout_io sync_writeback)
+					enum pageout_io sync_writeback,
+					unsigned long *nr_still_dirty)
 {
-	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
-	int pgactivate = 0;
+	LIST_HEAD(putback_pages);
+	LIST_HEAD(dirty_pages);
+	int pgactivate;
+	unsigned long nr_dirty = 0;
 	unsigned long nr_reclaimed = 0;
 
+	pgactivate = 0;
 	cond_resched();
 
 	while (!list_empty(page_list)) {
@@ -741,7 +754,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (PageDirty(page)) {
+		if (PageDirty(page))  {
+			/*
+			 * Only kswapd can writeback filesystem pages to
+			 * avoid risk of stack overflow
+			 */
+			if (page_is_file_cache(page) && !current_is_kswapd()) {
+				list_add(&page->lru, &dirty_pages);
+				unlock_page(page);
+				nr_dirty++;
+				goto keep_dirty;
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
@@ -852,13 +876,19 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
-		list_add(&page->lru, &ret_pages);
+		list_add(&page->lru, &putback_pages);
+keep_dirty:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
 	free_page_list(&free_pages);
 
-	list_splice(&ret_pages, page_list);
+	if (nr_dirty) {
+		*nr_still_dirty = nr_dirty;
+		list_splice(&dirty_pages, page_list);
+	}
+	list_splice(&putback_pages, page_list);
+
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
@@ -1245,6 +1275,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_active;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	unsigned long nr_dirty;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1293,26 +1324,34 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC,
+								&nr_dirty);
 
 	/*
-	 * If we are direct reclaiming for contiguous pages and we do
+	 * If specific pages are needed such as with direct reclaiming
+	 * for contiguous pages or for memory containers and we do
 	 * not reclaim everything in the list, try again and wait
-	 * for IO to complete. This will stall high-order allocations
-	 * but that should be acceptable to the caller
+	 * for IO to complete. This will stall callers that require
+	 * specific pages but it should be acceptable to the caller
 	 */
-	if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
-			sc->lumpy_reclaim_mode) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+	if (sc->may_writepage && !current_is_kswapd() &&
+			(sc->lumpy_reclaim_mode || sc->mem_cgroup)) {
+		int dirty_retry = MAX_SWAP_CLEAN_WAIT;
 
-		/*
-		 * The attempt at page out may have made some
-		 * of the pages active, mark them inactive again.
-		 */
-		nr_active = clear_active_flags(&page_list, NULL);
-		count_vm_events(PGDEACTIVATE, nr_active);
+		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
+			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
-		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
+			/*
+			 * The attempt at page out may have made some
+			 * of the pages active, mark them inactive again.
+			 */
+			nr_active = clear_active_flags(&page_list, NULL);
+			count_vm_events(PGDEACTIVATE, nr_active);
+	
+			nr_reclaimed += shrink_page_list(&page_list, sc,
+						PAGEOUT_IO_SYNC, &nr_dirty);
+		}
 	}
 
 	local_irq_disable();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
