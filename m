Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2DA0B6B00AF
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 10:33:10 -0400 (EDT)
Date: Mon, 13 Sep 2010 22:33:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 09/10] vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-ID: <20100913143301.GB14158@localhost>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
 <1283770053-18833-10-git-send-email-mel@csn.ul.ie>
 <20100913133156.GA12355@localhost>
 <20100913135510.GH23508@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100913135510.GH23508@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > >  	/* Check if we should syncronously wait for writeback */
> > >  	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
> > 
> > It is possible to OOM if the LRU list is small and/or the storage is slow, so
> > that the flusher cannot clean enough pages before the LRU is fully scanned.
> > 
> 
> To go OOM, nr_reclaimed would have to be 0 and for that, the entire list
> would have to be dirty or unreclaimable. If that situation happens, is
> the dirty throttling not also broken?

My worry is, even if the dirty throttling limit is instantly set to 0,
it may still take time to knock down the number of dirty pages. Think
about 500MB dirty pages waiting to be flushed to a slow USB stick.

> > So we may need do waits on dirty/writeback pages on *order-0*
> > direct reclaims, when priority goes rather low (such as < 3).
> > 
> 
> In case this is really necessary, the necessary stalling could be done by
> removing the check for lumpy reclaim in should_reclaim_stall().  What do
> you think of the following replacement?

I merely want to provide a guarantee, so it may be enough to add this:

        if (nr_freed == nr_taken)
                return false;

+       if (!priority)
+               return true;

This ensures the last full LRU scan will do necessary waits to prevent
the OOM.

> /*
>  * Returns true if the caller should wait to clean dirty/writeback pages.
>  *
>  * If we are direct reclaiming for contiguous pages and we do not reclaim
>  * everything in the list, try again and wait for writeback IO to complete.
>  * This will stall high-order allocations noticeably. Only do that when really
>  * need to free the pages under high memory pressure.
>  *
>  * Alternatively, if priority is getting high, it may be because there are
>  * too many dirty pages on the LRU. Rather than returning nr_reclaimed == 0
>  * and potentially causing an OOM, we stall on writeback.
>  */
> static inline bool should_reclaim_stall(unsigned long nr_taken,
>                                         unsigned long nr_freed,
>                                         int priority,
>                                         struct scan_control *sc)
> {
>         int stall_priority;
> 
>         /* kswapd should not stall on sync IO */
>         if (current_is_kswapd())
>                 return false;
> 
>         /* If we cannot writeback, there is no point stalling */
>         if (!sc->may_writepage)
>                 return false;
> 
>         /* If we have relaimed everything on the isolated list, no stall */
>         if (nr_freed == nr_taken)
>                 return false;
> 
>         /*
>          * For high-order allocations, there are two stall thresholds.
>          * High-cost allocations stall immediately where as lower
>          * order allocations such as stacks require the scanning
>          * priority to be much higher before stalling.
>          */
>         if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
>                 stall_priority = DEF_PRIORITY;
>         else
>                 stall_priority = DEF_PRIORITY / 3;
> 
>         return priority <= stall_priority;
> }
> 
> 
> > > +		int dirty_retry = MAX_SWAP_CLEAN_WAIT;
> > >  		set_lumpy_reclaim_mode(priority, sc, true);
> > > -		nr_reclaimed += shrink_page_list(&page_list, sc);
> > > +
> > > +		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
> > > +			struct page *page, *tmp;
> > > +
> > 
> > > +			/* Take off the clean pages marked for activation */
> > > +			list_for_each_entry_safe(page, tmp, &page_list, lru) {
> > > +				if (PageDirty(page) || PageWriteback(page))
> > > +					continue;
> > > +
> > > +				list_del(&page->lru);
> > > +				list_add(&page->lru, &putback_list);
> > > +			}
> > 
> > nitpick: I guess the above loop is optional code to avoid overheads
> > of shrink_page_list() repeatedly going through some unfreeable pages?
> 
> Pretty much, if they are to be activated, there is no point trying to reclaim
> them again. It's unnecessary overhead. A strong motivation for this
> series is to reduce overheads in the reclaim paths and unnecessary
> retrying of unfreeable pages.

We do so much waits in this loop, so that users will get upset by the
iowait stalls much much more than the CPU overheads.. best option is
always to avoid entering this loop in the first place, and if we
succeeded on that, these lines of optimizations will be nothing but
mind destroyers for newbie developers.

> > Considering this is the slow code path, I'd prefer to keep the code
> > simple than to do such optimizations.
> > 
> > > +			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
> > 
> > how about 
> >                         if (!laptop_mode)
> >                                 wakeup_flusher_threads(nr_dirty);
> > 
> 
> It's not the same thing. wakeup_flusher_threads(0) in laptop_mode is to
> clean all pages if some need dirtying. laptop_mode cleans all pages to
> minimise disk spinups.

Ah.. that's sure fine. I wonder if the flusher could be more smart to
automatically extend the number of pages to write in laptop mode. This
could simplify some callers.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
