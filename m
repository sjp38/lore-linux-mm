Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 284CD6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 10:27:30 -0400 (EDT)
Date: Wed, 21 Jul 2010 15:27:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20100721142710.GZ13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-5-git-send-email-mel@csn.ul.ie> <20100719221420.GA16031@cmpxchg.org> <20100720134555.GU13117@csn.ul.ie> <20100720220218.GE16031@cmpxchg.org> <20100721115250.GX13117@csn.ul.ie> <20100721210111.06dda351.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100721210111.06dda351.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 09:01:11PM +0900, KAMEZAWA Hiroyuki wrote:
> > <SNIP>
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
> 
> Hmm, ok. I see what will happen to memcg.

Thanks

> But, hmm, memcg will have to select to enter this rounine based on
> the result of 1st memory reclaim.
> 

It has the option of igoring pages being dirtied but I worry that the
container could be filled with dirty pages waiting for flushers to do
something.

> >  
> > -		/*
> > -		 * The attempt at page out may have made some
> > -		 * of the pages active, mark them inactive again.
> > -		 */
> > -		nr_active = clear_active_flags(&page_list, NULL);
> > -		count_vm_events(PGDEACTIVATE, nr_active);
> > +		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
> > +			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
> > +			congestion_wait(BLK_RW_ASYNC, HZ/10);
> >  
>
> Congestion wait is required ?? Where the congestion happens ?
> I'm sorry you already have some other trick in other patch.
> 

It's to wait for the IO to occur.

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
> 
> Just a question. This PAGEOUT_IO_SYNC has some meanings ?
> 

Yes, in pageout it will wait on pages currently being written back to be
cleaned before trying to reclaim them.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
