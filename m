Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D3F586B02A8
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 05:19:49 -0400 (EDT)
Date: Thu, 22 Jul 2010 10:19:30 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20100722091930.GD13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-5-git-send-email-mel@csn.ul.ie> <20100719221420.GA16031@cmpxchg.org> <20100720134555.GU13117@csn.ul.ie> <20100720220218.GE16031@cmpxchg.org> <20100721115250.GX13117@csn.ul.ie> <20100721210111.06dda351.kamezawa.hiroyu@jp.fujitsu.com> <20100721142710.GZ13117@csn.ul.ie> <20100722085734.ff252542.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100722085734.ff252542.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 08:57:34AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 21 Jul 2010 15:27:10 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Wed, Jul 21, 2010 at 09:01:11PM +0900, KAMEZAWA Hiroyuki wrote:
>  
> > > But, hmm, memcg will have to select to enter this rounine based on
> > > the result of 1st memory reclaim.
> > > 
> > 
> > It has the option of igoring pages being dirtied but I worry that the
> > container could be filled with dirty pages waiting for flushers to do
> > something.
> 
> I'll prepare dirty_ratio for memcg. It's not easy but requested by I/O cgroup
> guys, too...
> 

I can see why it might be difficult. Dirty pages are not being counted
on a per-container basis. It would require additional infrastructure to
count it or a lot of scanning.

> 
> > 
> > > >  
> > > > -		/*
> > > > -		 * The attempt at page out may have made some
> > > > -		 * of the pages active, mark them inactive again.
> > > > -		 */
> > > > -		nr_active = clear_active_flags(&page_list, NULL);
> > > > -		count_vm_events(PGDEACTIVATE, nr_active);
> > > > +		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
> > > > +			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
> > > > +			congestion_wait(BLK_RW_ASYNC, HZ/10);
> > > >  
> > >
> > > Congestion wait is required ?? Where the congestion happens ?
> > > I'm sorry you already have some other trick in other patch.
> > > 
> > 
> > It's to wait for the IO to occur.
> > 
>
> 1 tick penalty seems too large. I hope we can have some waitqueue in future.
> 

congestion_wait() if congestion occurs goes onto a waitqueue that is
woken if congestion clears. I didn't measure it this time around but I
doubt it waits for HZ/10 much of the time.

> > > > -		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
> > > > +			/*
> > > > +			 * The attempt at page out may have made some
> > > > +			 * of the pages active, mark them inactive again.
> > > > +			 */
> > > > +			nr_active = clear_active_flags(&page_list, NULL);
> > > > +			count_vm_events(PGDEACTIVATE, nr_active);
> > > > +	
> > > > +			nr_reclaimed += shrink_page_list(&page_list, sc,
> > > > +						PAGEOUT_IO_SYNC, &nr_dirty);
> > > > +		}
> > > 
> > > Just a question. This PAGEOUT_IO_SYNC has some meanings ?
> > > 
> > 
> > Yes, in pageout it will wait on pages currently being written back to be
> > cleaned before trying to reclaim them.
> > 
> Hmm. IIUC, this routine is called only when !current_is_kswapd() and
> pageout is done only whne current_is_kswapd(). So, this seems ....
> Wrong ?
> 

Both direct reclaim and kswapd can reach shrink_inactive_list

Direct reclaim
do_try_to_free_pages
  -> shrink_zones
    -> shrink_zone
      -> shrink_list
        -> shrink_inactive list <--- the routine in question

Kswapd
balance_pgdat
  -> shrink_zone
    -> shrink_list
      -> shrink_inactive_list

pageout() is still called by direct reclaim if the page is anon so it
will synchronously wait on those if PAGEOUT_IO_SYNC is set. For either
anon or file pages, if they are being currently written back, they will
be waited on in shrink_page_list() if PAGEOUT_IO_SYNC.

So it still has meaning. Did I miss something?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
