Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DC4256B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 07:37:06 -0400 (EDT)
Date: Wed, 21 Jul 2010 13:36:54 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in direct
 reclaim
Message-ID: <20100721113654.GG16031@cmpxchg.org>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-5-git-send-email-mel@csn.ul.ie>
 <20100719221420.GA16031@cmpxchg.org>
 <20100720134555.GU13117@csn.ul.ie>
 <20100720220218.GE16031@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100720220218.GE16031@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 12:02:18AM +0200, Johannes Weiner wrote:
> On Tue, Jul 20, 2010 at 02:45:56PM +0100, Mel Gorman wrote:
> > On Tue, Jul 20, 2010 at 12:14:20AM +0200, Johannes Weiner wrote:
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
[...]
> > The reason why I did it this way was because of lumpy reclaim and memcg
> > requiring specific pages. I considered lumpy reclaim to be the more common
> > case. In that case, it's removing potentially a large number of pages from
> > the LRU that are contiguous. If some of those are dirty and it selects more
> > contiguous ranges for reclaim, I'd worry that lumpy reclaim would trash the
> > system even worse than it currently does when the system is under load. Hence,
> > this wait and retry loop is done instead of returning and isolating more pages.
> 
> I think here we missed each other.  I don't want the loop to be _that_
> much more in the outer scope that isolation is repeated as well.  What
> I had in mind is the attached patch.  It is not tested and hacked up
> rather quickly due to time constraints, sorry, but you should get the
> idea.  I hope I did not miss anything fundamental.
> 
> Note that since only kswapd enters pageout() anymore, everything
> depending on PAGEOUT_IO_SYNC in there is moot, since there are no sync
> cycles for kswapd.  Just to mitigate the WTF-count on the patch :-)

Aaaaand direct reclaimers for swap, of course.  Selfslap.  Here is the
patch again, sans the first hunk (and the type of @dirty_seen fixed):

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -643,12 +643,14 @@ static noinline_for_stack void free_page
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-					struct scan_control *sc,
-					enum pageout_io sync_writeback)
+				      struct scan_control *sc,
+				      enum pageout_io sync_writeback,
+				      unsigned long *dirty_seen)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
+	unsigned long nr_dirty = 0;
 	unsigned long nr_reclaimed = 0;
 
 	cond_resched();
@@ -657,7 +659,7 @@ static unsigned long shrink_page_list(st
 		enum page_references references;
 		struct address_space *mapping;
 		struct page *page;
-		int may_enter_fs;
+		int may_pageout;
 
 		cond_resched();
 
@@ -681,10 +683,15 @@ static unsigned long shrink_page_list(st
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
 
-		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
+		/*
+		 * To prevent stack overflows, only kswapd can enter
+		 * the filesystem.  Swap IO is always fine (for now).
+		 */
+		may_pageout = current_is_kswapd() ||
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
 		if (PageWriteback(page)) {
+			int may_wait;
 			/*
 			 * Synchronous reclaim is performed in two passes,
 			 * first an asynchronous pass over the list to
@@ -693,7 +700,8 @@ static unsigned long shrink_page_list(st
 			 * for any page for which writeback has already
 			 * started.
 			 */
-			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
+			may_wait = (sc->gfp_mask & __GFP_FS) || may_pageout;
+			if (sync_writeback == PAGEOUT_IO_SYNC && may_wait)
 				wait_on_page_writeback(page);
 			else
 				goto keep_locked;
@@ -719,7 +727,7 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 			if (!add_to_swap(page))
 				goto activate_locked;
-			may_enter_fs = 1;
+			may_pageout = 1;
 		}
 
 		mapping = page_mapping(page);
@@ -742,9 +750,11 @@ static unsigned long shrink_page_list(st
 		}
 
 		if (PageDirty(page)) {
+			nr_dirty++;
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
-			if (!may_enter_fs)
+			if (!may_pageout)
 				goto keep_locked;
 			if (!sc->may_writepage)
 				goto keep_locked;
@@ -860,6 +870,7 @@ keep:
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
+	*dirty_seen = nr_dirty;
 	return nr_reclaimed;
 }
 
@@ -1232,6 +1243,9 @@ static noinline_for_stack void update_is
 	reclaim_stat->recent_scanned[1] += *nr_file;
 }
 
+/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
+#define MAX_SWAP_CLEAN_WAIT 50
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
@@ -1247,6 +1261,7 @@ shrink_inactive_list(unsigned long nr_to
 	unsigned long nr_active;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	unsigned long nr_dirty;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1295,26 +1310,32 @@ shrink_inactive_list(unsigned long nr_to
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
-
+	nr_reclaimed = shrink_page_list(&page_list, sc,
+					PAGEOUT_IO_ASYNC,
+					&nr_dirty);
 	/*
 	 * If we are direct reclaiming for contiguous pages and we do
 	 * not reclaim everything in the list, try again and wait
 	 * for IO to complete. This will stall high-order allocations
 	 * but that should be acceptable to the caller
 	 */
-	if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
-			sc->lumpy_reclaim_mode) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+	if (!current_is_kswapd() && sc->lumpy_reclaim_mode || sc->mem_cgroup) {
+		int dirty_retry = MAX_SWAP_CLEAN_WAIT;
 
-		/*
-		 * The attempt at page out may have made some
-		 * of the pages active, mark them inactive again.
-		 */
-		nr_active = clear_active_flags(&page_list, NULL);
-		count_vm_events(PGDEACTIVATE, nr_active);
+		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
+			wakeup_flusher_threads(nr_dirty);
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			/*
+			 * The attempt at page out may have made some
+			 * of the pages active, mark them inactive again.
+			 */
+			nr_active = clear_active_flags(&page_list, NULL);
+			count_vm_events(PGDEACTIVATE, nr_active);
 
-		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
+			nr_reclaimed += shrink_page_list(&page_list, sc,
+							 PAGEOUT_IO_SYNC,
+							 &nr_dirty);
+		}
 	}
 
 	local_irq_disable();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
