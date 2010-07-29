Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D37B46B02A6
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 10:24:34 -0400 (EDT)
Date: Thu, 29 Jul 2010 15:24:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Why PAGEOUT_IO_SYNC stalls for a long time
Message-ID: <20100729142413.GB3571@csn.ul.ie>
References: <20100728191322.4A85.A69D9226@jp.fujitsu.com> <20100728131017.GI5300@csn.ul.ie> <20100729153719.4ABD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100729153719.4ABD.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 29, 2010 at 07:34:19PM +0900, KOSAKI Motohiro wrote:
> > > <SNIP>
> > >
> > > 2. synchronous lumpy reclaim condition is insane.
> > > 
> > > currently, synchrounous lumpy reclaim will be invoked when following
> > > condition.
> > > 
> > >         if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
> > >                         sc->lumpy_reclaim_mode) {
> > > 
> > > but "nr_reclaimed < nr_taken" is pretty stupid. if isolated pages have
> > > much dirty pages, pageout() only issue first 113 IOs.
> > > (if io queue have >113 requests, bdi_write_congested() return true and
> > >  may_write_to_queue() return false)
> > > 
> > > So, we haven't call ->writepage(), congestion_wait() and wait_on_page_writeback()
> > > are surely stupid.
> > > 
> > 
> > This is somewhat intentional though. See the comment
> > 
> >                         /*
> >                          * Synchronous reclaim is performed in two passes,
> >                          * first an asynchronous pass over the list to
> >                          * start parallel writeback, and a second synchronous
> >                          * pass to wait for the IO to complete......
> > 
> > If all pages on the list were not taken, it means that some of the them
> > were dirty but most should now be queued for writeback (possibly not all if
> > congested). The intention is to loop a second time waiting for that writeback
> > to complete before continueing on.
> 
> May I explain more a bit? Generically, a worth of retrying depend on successful ratio.
> now shrink_page_list() can't free the page when following situation.
> 
> 1. trylock_page() failure
> 2. page is unevictable
> 3. zone reclaim and page is mapped
> 4. PageWriteback() is true and not synchronous lumpy reclaim
> 5. page is swapbacked and swap is full
> 6. add_to_swap() fail (note, this is frequently fail rather than expected because
>     it is using GFP_NOMEMALLOC)
> 7. page is dirty and gfpmask don't have GFP_IO, GFP_FS
> 8. page is pinned
> 9. IO queue is congested
> 10. pageout() start IO, but not finished
> 
> So, (4) and (10) are perfectly good condition to wait.

Sure

> (1) and (8) might be solved
> by sleeping awhile, but it's unrelated on io-congestion. but might not be. It only works
> by lucky. So I don't like to depned on luck. 

In this case, waiting a while really in the right thing to do. It stalls
the caller, but it's a high-order allocation. The alternative is for it
to keep scanning which when under memory pressure could result in far
too many pages being evicted. How long to wait is a tricky one to answer
but I would recommend making this a low priority.

> (9) can be solved by io
> waiting. but congestion_wait() is NOT correct wait. congestion_wait() mean 
> "sleep until one or more block device in the system are no congested". That said,
> if the system have two or more disks, congestion_wait() doesn't works well for 
> synchronous lumpy reclaim purpose. btw, desktop user oftern use USB storage
> device.


Indeed not. Eliminating congestion_wait there and depending instad on
wait_on_page_writeback() is a better feedback mechanism and makes sense.

> (2), (3), (5), (6) and (7) can't be solved by waiting. It's just silly.
> 

Agreed.

> In the other hand, synchrounous lumpy reclaim work fine following situation.
> 
> 1. called shrink_page_list(PAGEOUT_IO_ASYNC) 
> 2. pageout() kicked IO
> 3. waiting by wait_on_page_writeback()
> 4. application touched the page again. and the page became dirty again
> 5. IO finished, and wakeuped reclaim thread 
> 6. called pageout()
> 7. called wait_on_page_writeback() again
> 8. ok. we are successful high order reclaim
> 
> So, I'd like to narrowing to invoke synchrounous lumpy reclaim condtion.
> 

Which is reasonable.

> 
> > 
> > > 3. pageout() is intended anynchronous api. but doesn't works so.
> > > 
> > > pageout() call ->writepage with wbc->nonblocking=1. because if the system have
> > > default vm.dirty_ratio (i.e. 20), we have 80% clean memory. so, getting stuck
> > > on one page is stupid, we should scan much pages as soon as possible.
> > > 
> > > HOWEVER, block layer ignore this argument. if slow usb memory device connect
> > > to the system, ->writepage() will sleep long time. because submit_bio() call
> > > get_request_wait() unconditionally and it doesn't have any PF_MEMALLOC task
> > > bonus.
> > 
> > Is this not a problem in the writeback layer rather than pageout()
> > specifically?
> 
> Well, outside pageout(), probably only XFS makes PF_MEMALLOC + writeout. 
> because PF_MEMALLOC is enabled only very limited situation. but I don't know
> XFS detail at all. I can't tell this area...
> 

All direct reclaimers have PF_MEMALLOC set so it's not that limited a
situation. See here

        p->flags |= PF_MEMALLOC;
        lockdep_set_current_reclaim_state(gfp_mask);
        reclaim_state.reclaimed_slab = 0;
        p->reclaim_state = &reclaim_state;

        *did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);

        p->reclaim_state = NULL;
        lockdep_clear_current_reclaim_state();
        p->flags &= ~PF_MEMALLOC;

> > > 4. synchronous lumpy reclaim call clear_active_flags(). but it is also silly.
> > > 
> > > Now, page_check_references() ignore pte young bit when we are processing lumpy reclaim.
> > > Then, In almostly case, PageActive() mean "swap device is full". Therefore,
> > > waiting IO and retry pageout() are just silly.
> > > 
> > 
> > try_to_unmap also obey reference bits. If you remove the call to
> > clear_active_flags, then pageout should pass TTY_IGNORE_ACCESS to
> > try_to_unmap(). I had a patch to do this but it didn't improve
> > high-order allocation success rates any so I dropped it.
> 
> I think this is unrelated issue.  actually, page_referenced() is called before try_to_unmap()
> and page_referenced() will drop pte young bit. This logic have very narrowing race. but
> I don't think this is big matter practically.
> 
> And, As I said, PageActive() mean retry is not meaningful. usuallty swap full doen't clear
> even if waiting a while.
> 

Ok.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
