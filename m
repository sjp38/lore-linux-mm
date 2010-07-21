Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0446B02A8
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 09:39:18 -0400 (EDT)
Date: Wed, 21 Jul 2010 14:38:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20100721133857.GY13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-5-git-send-email-mel@csn.ul.ie> <20100719221420.GA16031@cmpxchg.org> <20100720134555.GU13117@csn.ul.ie> <20100720220218.GE16031@cmpxchg.org> <20100721115250.GX13117@csn.ul.ie> <20100721130435.GH16031@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100721130435.GH16031@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 03:04:35PM +0200, Johannes Weiner wrote:
> On Wed, Jul 21, 2010 at 12:52:50PM +0100, Mel Gorman wrote:
> > On Wed, Jul 21, 2010 at 12:02:18AM +0200, Johannes Weiner wrote:
> > > What
> > > I had in mind is the attached patch.  It is not tested and hacked up
> > > rather quickly due to time constraints, sorry, but you should get the
> > > idea.  I hope I did not miss anything fundamental.
> > > 
> > > Note that since only kswapd enters pageout() anymore, everything
> > > depending on PAGEOUT_IO_SYNC in there is moot, since there are no sync
> > > cycles for kswapd.  Just to mitigate the WTF-count on the patch :-)
> > > 
> > 
> > Anon page writeback can enter pageout. See
> > 
> > static inline bool reclaim_can_writeback(struct scan_control *sc,
> >                                         struct page *page)
> > {
> >         return !page_is_file_cache(page) || current_is_kswapd();
> > }
> > 
> > So the logic still applies.
> 
> Yeah, I noticed it only after looking at it again this morning.  My
> bad, it got a bit late when I wrote it.
> 

No worries, in an earlier version anon and file writeback were both
blocked and I suspect that was in the back of your mind somewhere.

> > > @@ -643,12 +639,14 @@ static noinline_for_stack void free_page
> > >   * shrink_page_list() returns the number of reclaimed pages
> > >   */
> > >  static unsigned long shrink_page_list(struct list_head *page_list,
> > > -					struct scan_control *sc,
> > > -					enum pageout_io sync_writeback)
> > > +				      struct scan_control *sc,
> > > +				      enum pageout_io sync_writeback,
> > > +				      int *dirty_seen)
> > >  {
> > >  	LIST_HEAD(ret_pages);
> > >  	LIST_HEAD(free_pages);
> > >  	int pgactivate = 0;
> > > +	unsigned long nr_dirty = 0;
> > >  	unsigned long nr_reclaimed = 0;
> > >  
> > >  	cond_resched();
> > > @@ -657,7 +655,7 @@ static unsigned long shrink_page_list(st
> > >  		enum page_references references;
> > >  		struct address_space *mapping;
> > >  		struct page *page;
> > > -		int may_enter_fs;
> > > +		int may_pageout;
> > >  
> > >  		cond_resched();
> > >  
> > > @@ -681,10 +679,15 @@ static unsigned long shrink_page_list(st
> > >  		if (page_mapped(page) || PageSwapCache(page))
> > >  			sc->nr_scanned++;
> > >  
> > > -		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> > > +		/*
> > > +		 * To prevent stack overflows, only kswapd can enter
> > > +		 * the filesystem.  Swap IO is always fine (for now).
> > > +		 */
> > > +		may_pageout = current_is_kswapd() ||
> > >  			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
> > >  
> > 
> > We lost the __GFP_FS check and it's vaguely possible kswapd could call the
> > allocator with GFP_NOFS. While you check it before wait_on_page_writeback it
> > needs to be checked before calling pageout(). I toyed around with
> > creating a may_pageout that took everything into account but I couldn't
> > convince myself there was no holes or serious change in functionality.
> 
> Yeah, I checked balance_pgdat(), saw GFP_KERNEL and went for it.  But
> it's probably better to keep such dependencies out.
> 

Ok.

> > Ok, is this closer to what you had in mind?
> 
> IMHO this is (almost) ready to get merged, so I am including the
> nitpicking comments :-)
> 
> > ==== CUT HERE ====
> > [PATCH] vmscan: Do not writeback filesystem pages in direct reclaim
> > 
> > When memory is under enough pressure, a process may enter direct
> > reclaim to free pages in the same manner kswapd does. If a dirty page is
> > encountered during the scan, this page is written to backing storage using
> > mapping->writepage. This can result in very deep call stacks, particularly
> > if the target storage or filesystem are complex. It has already been observed
> > on XFS that the stack overflows but the problem is not XFS-specific.
> > 
> > This patch prevents direct reclaim writing back filesystem pages by checking
> > if current is kswapd or the page is anonymous before writing back.  If the
> > dirty pages cannot be written back, they are placed back on the LRU lists
> > for either background writing by the BDI threads or kswapd. If in direct
> > lumpy reclaim and dirty pages are encountered, the process will stall for
> > the background flusher before trying to reclaim the pages again.
> > 
> > As the call-chain for writing anonymous pages is not expected to be deep
> > and they are not cleaned by flusher threads, anonymous pages are still
> > written back in direct reclaim.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 6587155..e3a5816 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> 
> [...]
> 
> Does factoring pageout() still make sense in this patch?  It does not
> introduce a second callsite.
> 

It's not necessary anymore and just obscures the patch. I collapsed it.

> > @@ -639,18 +645,25 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
> >  	pagevec_free(&freed_pvec);
> >  }
> >  
> > +/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
> > +#define MAX_SWAP_CLEAN_WAIT 50
> 
> That's placed a bit randomly now that shrink_page_list() doesn't use
> it anymore.  I moved it just above shrink_inactive_list() but maybe it
> would be better at the file's head?
> 

I will move it to the top.

> >  /*
> >   * shrink_page_list() returns the number of reclaimed pages
> >   */
> >  static unsigned long shrink_page_list(struct list_head *page_list,
> >  					struct scan_control *sc,
> > -					enum pageout_io sync_writeback)
> > +					enum pageout_io sync_writeback,
> > +					unsigned long *nr_still_dirty)
> >  {
> > -	LIST_HEAD(ret_pages);
> >  	LIST_HEAD(free_pages);
> > -	int pgactivate = 0;
> > +	LIST_HEAD(putback_pages);
> > +	LIST_HEAD(dirty_pages);
> > +	int pgactivate;
> > +	unsigned long nr_dirty = 0;
> >  	unsigned long nr_reclaimed = 0;
> >  
> > +	pgactivate = 0;
> 
> Spurious change?
> 

Yes, was previously needed for the restart_dirty. Now it's a stupid
change.

> >  	cond_resched();
> >  
> >  	while (!list_empty(page_list)) {
> > @@ -741,7 +754,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  			}
> >  		}
> >  
> > -		if (PageDirty(page)) {
> > +		if (PageDirty(page))  {
> 
> Ha!
> 

:) fixed.

> > +			/*
> > +			 * Only kswapd can writeback filesystem pages to
> > +			 * avoid risk of stack overflow
> > +			 */
> > +			if (page_is_file_cache(page) && !current_is_kswapd()) {
> > +				list_add(&page->lru, &dirty_pages);
> > +				unlock_page(page);
> > +				nr_dirty++;
> > +				goto keep_dirty;
> > +			}
> 
> I don't understand why you keep the extra dirty list.  Couldn't this
> just be `goto keep_locked'?
> 

Yep, because we are no longer looping to retry dirty pages.

> >  			if (references == PAGEREF_RECLAIM_CLEAN)
> >  				goto keep_locked;
> >  			if (!may_enter_fs)
> > @@ -852,13 +876,19 @@ activate_locked:
> >  keep_locked:
> >  		unlock_page(page);
> >  keep:
> > -		list_add(&page->lru, &ret_pages);
> > +		list_add(&page->lru, &putback_pages);
> > +keep_dirty:
> >  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> >  	}
> >  
> >  	free_page_list(&free_pages);
> >  
> > -	list_splice(&ret_pages, page_list);
> > +	if (nr_dirty) {
> > +		*nr_still_dirty = nr_dirty;
> 
> You either have to set *nr_still_dirty unconditionally or
> (re)initialize the variable in shrink_inactive_list().
> 

Unconditionally happening now.

> > +		list_splice(&dirty_pages, page_list);
> > +	}
> > +	list_splice(&putback_pages, page_list);
> 
> When we retry those pages, the dirty ones come last on the list.  Was
> this maybe the intention behind collecting dirties separately?
> 

No, the intention was to only recycle dirty pages but it's not very
important.

> > @@ -1245,6 +1275,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >  	unsigned long nr_active;
> >  	unsigned long nr_anon;
> >  	unsigned long nr_file;
> > +	unsigned long nr_dirty;
> >  
> >  	while (unlikely(too_many_isolated(zone, file, sc))) {
> >  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > @@ -1293,26 +1324,34 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >  
> >  	spin_unlock_irq(&zone->lru_lock);
> >  
> > -	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
> > +	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC,
> > +								&nr_dirty);
> >  
> >  	/*
> > -	 * If we are direct reclaiming for contiguous pages and we do
> > +	 * If specific pages are needed such as with direct reclaiming
> > +	 * for contiguous pages or for memory containers and we do
> >  	 * not reclaim everything in the list, try again and wait
> > -	 * for IO to complete. This will stall high-order allocations
> > -	 * but that should be acceptable to the caller
> > +	 * for IO to complete. This will stall callers that require
> > +	 * specific pages but it should be acceptable to the caller
> >  	 */
> > -	if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
> > -			sc->lumpy_reclaim_mode) {
> > -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +	if (sc->may_writepage && !current_is_kswapd() &&
> > +			(sc->lumpy_reclaim_mode || sc->mem_cgroup)) {
> > +		int dirty_retry = MAX_SWAP_CLEAN_WAIT;
> >  
> > -		/*
> > -		 * The attempt at page out may have made some
> > -		 * of the pages active, mark them inactive again.
> > -		 */
> > -		nr_active = clear_active_flags(&page_list, NULL);
> > -		count_vm_events(PGDEACTIVATE, nr_active);
> > +		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
> > +			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
> 
> Yup, minding laptop_mode (together with may_writepage).  Agreed.
> 
> > +			congestion_wait(BLK_RW_ASYNC, HZ/10);
> >  
> > -		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
> > +			/*
> > +			 * The attempt at page out may have made some
> > +			 * of the pages active, mark them inactive again.
> > +			 */
> > +			nr_active = clear_active_flags(&page_list, NULL);
> > +			count_vm_events(PGDEACTIVATE, nr_active);
> > +	
> > +			nr_reclaimed += shrink_page_list(&page_list, sc,
> > +						PAGEOUT_IO_SYNC, &nr_dirty);
> > +		}
> >  	}
> >  
> >  	local_irq_disable();
> 

Here is an updated version. Thanks very much

==== CUT HERE ====
vmscan: Do not writeback filesystem pages in direct reclaim

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
---
 mm/vmscan.c |   55 +++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 39 insertions(+), 16 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6587155..45d9934 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -139,6 +139,9 @@ static DECLARE_RWSEM(shrinker_rwsem);
 #define scanning_global_lru(sc)	(1)
 #endif
 
+/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
+#define MAX_SWAP_CLEAN_WAIT 50
+
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 						  struct scan_control *sc)
 {
@@ -644,11 +647,13 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
-					enum pageout_io sync_writeback)
+					enum pageout_io sync_writeback,
+					unsigned long *nr_still_dirty)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
+	unsigned long nr_dirty = 0;
 	unsigned long nr_reclaimed = 0;
 
 	cond_resched();
@@ -742,6 +747,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
+			/*
+			 * Only kswapd can writeback filesystem pages to
+			 * avoid risk of stack overflow
+			 */
+			if (page_is_file_cache(page) && !current_is_kswapd()) {
+				nr_dirty++;
+				goto keep_locked;
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
@@ -858,7 +872,7 @@ keep:
 
 	free_page_list(&free_pages);
 
-	list_splice(&ret_pages, page_list);
+	*nr_still_dirty = nr_dirty;
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
@@ -1245,6 +1259,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_active;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	unsigned long nr_dirty;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1293,26 +1308,34 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
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
