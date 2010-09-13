Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1B56B0172
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:55:28 -0400 (EDT)
Date: Mon, 13 Sep 2010 14:55:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 09/10] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20100913135510.GH23508@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie> <1283770053-18833-10-git-send-email-mel@csn.ul.ie> <20100913133156.GA12355@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100913133156.GA12355@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 09:31:56PM +0800, Wu Fengguang wrote:
> Mel,
> 
> Sorry for being late, I'm doing pretty much prework these days ;)
> 

No worries, I'm all over the place at the moment so cannot lecture on
response times :)

> On Mon, Sep 06, 2010 at 06:47:32PM +0800, Mel Gorman wrote:
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
> > Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/vmscan.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++---
> >  1 files changed, 46 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ff52b46..408c101 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -145,6 +145,9 @@ static DECLARE_RWSEM(shrinker_rwsem);
> >  #define scanning_global_lru(sc)	(1)
> >  #endif
> >  
> > +/* Direct lumpy reclaim waits up to five seconds for background cleaning */
> > +#define MAX_SWAP_CLEAN_WAIT 50
> > +
> >  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> >  						  struct scan_control *sc)
> >  {
> > @@ -682,11 +685,13 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
> >   * shrink_page_list() returns the number of reclaimed pages
> >   */
> >  static unsigned long shrink_page_list(struct list_head *page_list,
> > -				      struct scan_control *sc)
> > +					struct scan_control *sc,
> > +					unsigned long *nr_still_dirty)
> >  {
> >  	LIST_HEAD(ret_pages);
> >  	LIST_HEAD(free_pages);
> >  	int pgactivate = 0;
> > +	unsigned long nr_dirty = 0;
> >  	unsigned long nr_reclaimed = 0;
> >  
> >  	cond_resched();
> > @@ -785,6 +790,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  		}
> >  
> >  		if (PageDirty(page)) {
> > +			/*
> > +			 * Only kswapd can writeback filesystem pages to
> > +			 * avoid risk of stack overflow
> > +			 */
> > +			if (page_is_file_cache(page) && !current_is_kswapd()) {
> > +				nr_dirty++;
> > +				goto keep_locked;
> > +			}
> > +
> >  			if (references == PAGEREF_RECLAIM_CLEAN)
> >  				goto keep_locked;
> >  			if (!may_enter_fs)
> > @@ -908,6 +922,8 @@ keep_lumpy:
> >  	free_page_list(&free_pages);
> >  
> >  	list_splice(&ret_pages, page_list);
> > +
> > +	*nr_still_dirty = nr_dirty;
> >  	count_vm_events(PGACTIVATE, pgactivate);
> >  	return nr_reclaimed;
> >  }
> > @@ -1312,6 +1328,10 @@ static inline bool should_reclaim_stall(unsigned long nr_taken,
> >  	if (sc->lumpy_reclaim_mode == LUMPY_MODE_NONE)
> >  		return false;
> >  
> > +	/* If we cannot writeback, there is no point stalling */
> > +	if (!sc->may_writepage)
> > +		return false;
> > +
> >  	/* If we have relaimed everything on the isolated list, no stall */
> >  	if (nr_freed == nr_taken)
> >  		return false;
> > @@ -1339,11 +1359,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >  			struct scan_control *sc, int priority, int file)
> >  {
> >  	LIST_HEAD(page_list);
> > +	LIST_HEAD(putback_list);
> >  	unsigned long nr_scanned;
> >  	unsigned long nr_reclaimed = 0;
> >  	unsigned long nr_taken;
> >  	unsigned long nr_anon;
> >  	unsigned long nr_file;
> > +	unsigned long nr_dirty;
> >  
> >  	while (unlikely(too_many_isolated(zone, file, sc))) {
> >  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > @@ -1392,14 +1414,35 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >  
> >  	spin_unlock_irq(&zone->lru_lock);
> >  
> > -	nr_reclaimed = shrink_page_list(&page_list, sc);
> > +	nr_reclaimed = shrink_page_list(&page_list, sc, &nr_dirty);
> >  
> >  	/* Check if we should syncronously wait for writeback */
> >  	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
> 
> It is possible to OOM if the LRU list is small and/or the storage is slow, so
> that the flusher cannot clean enough pages before the LRU is fully scanned.
> 

To go OOM, nr_reclaimed would have to be 0 and for that, the entire list
would have to be dirty or unreclaimable. If that situation happens, is
the dirty throttling not also broken?

> So we may need do waits on dirty/writeback pages on *order-0*
> direct reclaims, when priority goes rather low (such as < 3).
> 

In case this is really necessary, the necessary stalling could be done by
removing the check for lumpy reclaim in should_reclaim_stall().  What do
you think of the following replacement?

/*
 * Returns true if the caller should wait to clean dirty/writeback pages.
 *
 * If we are direct reclaiming for contiguous pages and we do not reclaim
 * everything in the list, try again and wait for writeback IO to complete.
 * This will stall high-order allocations noticeably. Only do that when really
 * need to free the pages under high memory pressure.
 *
 * Alternatively, if priority is getting high, it may be because there are
 * too many dirty pages on the LRU. Rather than returning nr_reclaimed == 0
 * and potentially causing an OOM, we stall on writeback.
 */
static inline bool should_reclaim_stall(unsigned long nr_taken,
                                        unsigned long nr_freed,
                                        int priority,
                                        struct scan_control *sc)
{
        int stall_priority;

        /* kswapd should not stall on sync IO */
        if (current_is_kswapd())
                return false;

        /* If we cannot writeback, there is no point stalling */
        if (!sc->may_writepage)
                return false;

        /* If we have relaimed everything on the isolated list, no stall */
        if (nr_freed == nr_taken)
                return false;

        /*
         * For high-order allocations, there are two stall thresholds.
         * High-cost allocations stall immediately where as lower
         * order allocations such as stacks require the scanning
         * priority to be much higher before stalling.
         */
        if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
                stall_priority = DEF_PRIORITY;
        else
                stall_priority = DEF_PRIORITY / 3;

        return priority <= stall_priority;
}


> > +		int dirty_retry = MAX_SWAP_CLEAN_WAIT;
> >  		set_lumpy_reclaim_mode(priority, sc, true);
> > -		nr_reclaimed += shrink_page_list(&page_list, sc);
> > +
> > +		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
> > +			struct page *page, *tmp;
> > +
> 
> > +			/* Take off the clean pages marked for activation */
> > +			list_for_each_entry_safe(page, tmp, &page_list, lru) {
> > +				if (PageDirty(page) || PageWriteback(page))
> > +					continue;
> > +
> > +				list_del(&page->lru);
> > +				list_add(&page->lru, &putback_list);
> > +			}
> 
> nitpick: I guess the above loop is optional code to avoid overheads
> of shrink_page_list() repeatedly going through some unfreeable pages?

Pretty much, if they are to be activated, there is no point trying to reclaim
them again. It's unnecessary overhead. A strong motivation for this
series is to reduce overheads in the reclaim paths and unnecessary
retrying of unfreeable pages.

> Considering this is the slow code path, I'd prefer to keep the code
> simple than to do such optimizations.
> 
> > +			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
> 
> how about 
>                         if (!laptop_mode)
>                                 wakeup_flusher_threads(nr_dirty);
> 

It's not the same thing. wakeup_flusher_threads(0) in laptop_mode is to
clean all pages if some need dirtying. laptop_mode cleans all pages to
minimise disk spinups.

> > +			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> > +
> > +			nr_reclaimed = shrink_page_list(&page_list, sc,
> > +							&nr_dirty);
> > +		}
> >  	}
> >  
> > +	list_splice(&putback_list, &page_list);
> > +
> >  	local_irq_disable();
> >  	if (current_is_kswapd())
> >  		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
> > -- 
> > 1.7.1
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
