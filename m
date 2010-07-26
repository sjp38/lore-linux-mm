Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AB9696B02A5
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 05:12:46 -0400 (EDT)
Date: Mon, 26 Jul 2010 10:12:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20100726091227.GF5300@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-5-git-send-email-mel@csn.ul.ie> <20100719221420.GA16031@cmpxchg.org> <20100720134555.GU13117@csn.ul.ie> <20100720220218.GE16031@cmpxchg.org> <20100721115250.GX13117@csn.ul.ie> <20100721130435.GH16031@cmpxchg.org> <20100721133857.GY13117@csn.ul.ie> <20100726082935.GC13076@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100726082935.GC13076@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 04:29:35PM +0800, Wu Fengguang wrote:
> > ==== CUT HERE ====
> > vmscan: Do not writeback filesystem pages in direct reclaim
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
> 
> This is also a good step towards reducing pageout() calls. For better
> IO performance the flusher threads should take more work from pageout().
> 

This is true for better IO performance all right but reclaim does require
specific pages cleaned. The strict requirement is when lumpy reclaim is
involved but a looser requirement is when any pages within a zone be cleaned.

> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > ---
> >  mm/vmscan.c |   55 +++++++++++++++++++++++++++++++++++++++----------------
> >  1 files changed, 39 insertions(+), 16 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 6587155..45d9934 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -139,6 +139,9 @@ static DECLARE_RWSEM(shrinker_rwsem);
> >  #define scanning_global_lru(sc)        (1)
> >  #endif
> > 
> > +/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
> > +#define MAX_SWAP_CLEAN_WAIT 50
> > +
> >  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> >                                                   struct scan_control *sc)
> >  {
> > @@ -644,11 +647,13 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
> >   */
> >  static unsigned long shrink_page_list(struct list_head *page_list,
> >                                         struct scan_control *sc,
> > -                                       enum pageout_io sync_writeback)
> > +                                       enum pageout_io sync_writeback,
> > +                                       unsigned long *nr_still_dirty)
> >  {
> >         LIST_HEAD(ret_pages);
> >         LIST_HEAD(free_pages);
> >         int pgactivate = 0;
> > +       unsigned long nr_dirty = 0;
> >         unsigned long nr_reclaimed = 0;
> > 
> >         cond_resched();
> > @@ -742,6 +747,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >                 }
> > 
> >                 if (PageDirty(page)) {
> > +                       /*
> > +                        * Only kswapd can writeback filesystem pages to
> > +                        * avoid risk of stack overflow
> > +                        */
> > +                       if (page_is_file_cache(page) && !current_is_kswapd()) {
> > +                               nr_dirty++;
> > +                               goto keep_locked;
> > +                       }
> > +
> >                         if (references == PAGEREF_RECLAIM_CLEAN)
> >                                 goto keep_locked;
> >                         if (!may_enter_fs)
> > @@ -858,7 +872,7 @@ keep:
> > 
> >         free_page_list(&free_pages);
> > 
> > -       list_splice(&ret_pages, page_list);
> > +       *nr_still_dirty = nr_dirty;
> >         count_vm_events(PGACTIVATE, pgactivate);
> >         return nr_reclaimed;
> >  }
> > @@ -1245,6 +1259,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >         unsigned long nr_active;
> >         unsigned long nr_anon;
> >         unsigned long nr_file;
> > +       unsigned long nr_dirty;
> > 
> >         while (unlikely(too_many_isolated(zone, file, sc))) {
> >                 congestion_wait(BLK_RW_ASYNC, HZ/10);
> > @@ -1293,26 +1308,34 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> > 
> >         spin_unlock_irq(&zone->lru_lock);
> > 
> > -       nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
> > +       nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC,
> > +                                                               &nr_dirty);
> > 
> >         /*
> > -        * If we are direct reclaiming for contiguous pages and we do
> > +        * If specific pages are needed such as with direct reclaiming
> > +        * for contiguous pages or for memory containers and we do
> >          * not reclaim everything in the list, try again and wait
> > -        * for IO to complete. This will stall high-order allocations
> > -        * but that should be acceptable to the caller
> > +        * for IO to complete. This will stall callers that require
> > +        * specific pages but it should be acceptable to the caller
> >          */
> > -       if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
> > -                       sc->lumpy_reclaim_mode) {
> > -               congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +       if (sc->may_writepage && !current_is_kswapd() &&
> > +                       (sc->lumpy_reclaim_mode || sc->mem_cgroup)) {
> > +               int dirty_retry = MAX_SWAP_CLEAN_WAIT;
> > 
> > -               /*
> > -                * The attempt at page out may have made some
> > -                * of the pages active, mark them inactive again.
> > -                */
> > -               nr_active = clear_active_flags(&page_list, NULL);
> > -               count_vm_events(PGDEACTIVATE, nr_active);
> > +               while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
> > +                       wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
> > +                       congestion_wait(BLK_RW_ASYNC, HZ/10);
> 
> It needs good luck for the flusher threads to "happen to" sync the
> dirty pages in our page_list.

That is why I'm expecting the "shrink oldest inode" patchset to help. It
still requires a certain amount of luck but callers that encounter dirty
pages will be delayed.

It's also because a certain amount of luck is required that the last patch
in the series aims at reducing the number of dirty pages encountered by
reclaim. The closer that is to 0, the less important the timing of flusher
threads is.

> I'd rather take the logic as "there are
> too many dirty pages, shrink them to avoid some future pageout() calls
> and/or congestion_wait() stalls".
> 

What do you mean by shrink them? They cannot be reclaimed until they are
clean.

> So the loop is likely to repeat MAX_SWAP_CLEAN_WAIT times.  Let's remove it?
> 

This loop only applies to direct reclaimers in lumpy reclaim mode and
memory containers. Both need specific pages to be cleaned and freed.
Hence, the loop is to stall them and wait on flusher threads up to a
point. Otherwise they can cause a reclaim storm of clean pages that
can't be used.

Current tests have not indicated MAX_SWAP_CLEAN_WAIT is regularly reached
but I am inferring this from timing data rather than a direct measurement.

> > -               nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
> > +                       /*
> > +                        * The attempt at page out may have made some
> > +                        * of the pages active, mark them inactive again.
> > +                        */
> > +                       nr_active = clear_active_flags(&page_list, NULL);
> > +                       count_vm_events(PGDEACTIVATE, nr_active);
> > +
> > +                       nr_reclaimed += shrink_page_list(&page_list, sc,
> > +                                               PAGEOUT_IO_SYNC, &nr_dirty);
> 
> This shrink_page_list() won't be called at all if nr_dirty==0 and
> pageout() was called. This is a change of behavior. It can also be
> fixed by removing the loop.
> 

The whole patch is a change of behaviour but in this case it also makes
sense to focus on just the dirty pages. The first shrink_page_list
decided that the pages could not be unmapped and reclaimed - probably
because it was referenced. This is not likely to change during the loop.

Testing with a version of the patch that processed the full list added
significant stalls when sync writeback was involved. Testing time length
was tripled in one case implying that this loop was continually reaching
MAX_SWAP_CLEAN_WAIT.

The intention of this loop is "wait on dirty pages to be cleaned" and
it's a change of behaviour, but one that makes sense and testing
indicates it's a good idea.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
