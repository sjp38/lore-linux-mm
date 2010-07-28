Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ED1D96B02AC
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:10:37 -0400 (EDT)
Date: Wed, 28 Jul 2010 14:10:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Why PAGEOUT_IO_SYNC stalls for a long time
Message-ID: <20100728131017.GI5300@csn.ul.ie>
References: <20100728071705.GA22964@localhost> <20100728191322.4A85.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100728191322.4A85.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 08:40:21PM +0900, KOSAKI Motohiro wrote:
> In this week, I've tested some IO congested workload for a while. and probably
> I did reproduced Andreas's issue.
> 
> So, I would like to explain current lumpy reclaim how works and why so much sucks.
> 
> 
> 1. Now isolate_lru_pages() have following pfn neighber grabbing logic.
> 
>                 for (; pfn < end_pfn; pfn++) {
> (snip)
>                         if (__isolate_lru_page(cursor_page, mode, file) == 0) {
>                                 list_move(&cursor_page->lru, dst);
>                                 mem_cgroup_del_lru(cursor_page);
>                                 nr_taken++;
>                                 nr_lumpy_taken++;
>                                 if (PageDirty(cursor_page))
>                                         nr_lumpy_dirty++;
>                                 scan++;
>                         } else {
>                                 if (mode == ISOLATE_BOTH &&
>                                                 page_count(cursor_page))
>                                         nr_lumpy_failed++;
>                         }
>                 }
> 
> Mainly, __isolate_lru_page() failure can be caused following reasons.
>   (1) the page have already been freed and is in buddy.
>   (2) the page is used for non user process purpose
>   (3) the page is unevictable (e.g. mlocked)
> 
> (2), (3) have very different characteristic from (1). the lumpy reclaim
> mean 'contenious physical memory reclaiming'. that said, if we are trying
> order 9 reclaim, 512 pages reclaim success and 511 pages reclaim success
> are completely differennt.

Yep, and this can occur quite regularly. Judging from the ftrace
results, contig_failed is frequently positive although whether this is
due to the page being about to be freed or because it's due (2), I don't
know.

> former mean lumpy reclaim successfull, latter mean
> failure. So, if (2) or (3) occur, that pfn have lost a possibility of lumpy
> reclaim successfull. then, we should stop pfn neighbor search immediately and
> try to get lru next page. (i.e. we should use 'break' statement instead 'continue')
> 

Easy enough to do.

> 2. synchronous lumpy reclaim condition is insane.
> 
> currently, synchrounous lumpy reclaim will be invoked when following
> condition.
> 
>         if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
>                         sc->lumpy_reclaim_mode) {
> 
> but "nr_reclaimed < nr_taken" is pretty stupid. if isolated pages have
> much dirty pages, pageout() only issue first 113 IOs.
> (if io queue have >113 requests, bdi_write_congested() return true and
>  may_write_to_queue() return false)
> 
> So, we haven't call ->writepage(), congestion_wait() and wait_on_page_writeback()
> are surely stupid.
> 

This is somewhat intentional though. See the comment

                        /*
                         * Synchronous reclaim is performed in two passes,
                         * first an asynchronous pass over the list to
                         * start parallel writeback, and a second synchronous
                         * pass to wait for the IO to complete......

If all pages on the list were not taken, it means that some of the them
were dirty but most should now be queued for writeback (possibly not all if
congested). The intention is to loop a second time waiting for that writeback
to complete before continueing on.

> 3. pageout() is intended anynchronous api. but doesn't works so.
> 
> pageout() call ->writepage with wbc->nonblocking=1. because if the system have
> default vm.dirty_ratio (i.e. 20), we have 80% clean memory. so, getting stuck
> on one page is stupid, we should scan much pages as soon as possible.
> 
> HOWEVER, block layer ignore this argument. if slow usb memory device connect
> to the system, ->writepage() will sleep long time. because submit_bio() call
> get_request_wait() unconditionally and it doesn't have any PF_MEMALLOC task
> bonus.
> 

Is this not a problem in the writeback layer rather than pageout()
specifically?

> 
> 4. synchronous lumpy reclaim call clear_active_flags(). but it is also silly.
> 
> Now, page_check_references() ignore pte young bit when we are processing lumpy reclaim.
> Then, In almostly case, PageActive() mean "swap device is full". Therefore,
> waiting IO and retry pageout() are just silly.
> 

try_to_unmap also obey reference bits. If you remove the call to
clear_active_flags, then pageout should pass TTY_IGNORE_ACCESS to
try_to_unmap(). I had a patch to do this but it didn't improve
high-order allocation success rates any so I dropped it.

> In andres's case, congestion_wait() and get_request_wait() are root cause.
> Other issue is problematic when more higher order lumpy reclaim.
> 
> Now, I'm preparing some patches and probably I can send them tommorow.
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
