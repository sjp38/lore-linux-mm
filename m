Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 13BF06B02A6
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 05:45:44 -0400 (EDT)
Date: Wed, 28 Jul 2010 10:45:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] vmscan: remove wait_on_page_writeback() from pageout()
Message-ID: <20100728094527.GE5300@csn.ul.ie>
References: <20100728071705.GA22964@localhost> <AANLkTimaj6+MzY5Aa_xqi75zKy1fDOQV5QiQjdX8jgm7@mail.gmail.com> <20100728084654.GA26776@localhost> <20100728091032.GD5300@csn.ul.ie> <20100728093031.GA29551@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100728093031.GA29551@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 05:30:31PM +0800, Wu Fengguang wrote:
> On Wed, Jul 28, 2010 at 05:10:33PM +0800, Mel Gorman wrote:
> > On Wed, Jul 28, 2010 at 04:46:54PM +0800, Wu Fengguang wrote:
> > > The wait_on_page_writeback() call inside pageout() is virtually dead code.
> > > 
> > >         shrink_inactive_list()
> > >           shrink_page_list(PAGEOUT_IO_ASYNC)
> > >             pageout(PAGEOUT_IO_ASYNC)
> > >           shrink_page_list(PAGEOUT_IO_SYNC)
> > >             pageout(PAGEOUT_IO_SYNC)
> > > 
> > > Because shrink_page_list/pageout(PAGEOUT_IO_SYNC) is always called after
> > > a preceding shrink_page_list/pageout(PAGEOUT_IO_ASYNC), the first
> > > pageout(ASYNC) converts dirty pages into writeback pages, the second
> > > shrink_page_list(SYNC) waits on the clean of writeback pages before
> > > calling pageout(SYNC). The second shrink_page_list(SYNC) can hardly run
> > > into dirty pages for pageout(SYNC) unless in some race conditions.
> > > 
> > 
> > It's possible for the second call to run into dirty pages as there is a
> > congestion_wait() call between the first shrink_page_list() call and the
> > second. That's a big window.
> 
> OK there is a <=0.1s time window.

Ok, big was an exagguration for IO but during this window the page can
also be refaulted. If unmapped, it can get dirtied again.

> Then what about the data set size?
> After first shrink_page_list(ASYNC), there will be hardly any pages
> left in the page_list except for the already under-writeback pages and
> other unreclaimable pages. So it still asks for some race conditions
> for hitting the second pageout(SYNC) -- some unreclaimable pages
> become reclaimable+dirty in the 0.1s time window.
> 

We are hitting this window because otherwise the trace points would not be
reporting sync IO in pageout(). Take from an ftrace-based report

Direct reclaims                               1176
Direct reclaim pages scanned                184337
Direct reclaim write file async I/O           2317
Direct reclaim write anon async I/O          35551
Direct reclaim write file sync I/O            1817
Direct reclaim write anon sync I/O           15920

For the last line to have a positive value, we must have called
pageout(PAGEOUT_IO_ASYNC) and then hit a dirty page during the
pageout(PAGEOUT_IO_SYNC) call.

Here is one fairly plausible scenario where we end up waiting on
writeback despite the previous pageout() call.

shrink_inactive_list()
  shrink_page_list(PAGEOUT_IO_ASYNC)
    Check PageWriteback
    Unmap page (set_dirty_page, if PTE was dirty)
    pageout(PAGEOUT_IO_ASYNC, IO starts, page in writeback)
    call congestion_wait()

During this 0.1s window, the process references the page and faults in.
As it is lumpy reclaim, the page could have been young even though it
was physically located near an old page

  shrink_page_list(PAGEOUT_IO_SYNC)
    Check PageWriteback (Lets assume it is written back for this example)
    Unmap page again (dirty page again, if PTE was dirty)
    pageout(PAGEOUT_IO_SYNC, IO starts, wait on writeback this time)

> > > And the wait page-by-page behavior of pageout(SYNC) will lead to very
> > > long stall time if running into some range of dirty pages.
> > 
> > True, but this is also lumpy reclaim which is depending on a contiguous
> > range of pages. It's better for it to wait on the selected range of pages
> > which is known to contain at least one old page than excessively scan and
> > reclaim newer pages.
> > 
> > > So it's bad
> > > idea anyway to call wait_on_page_writeback() inside pageout().
> > > 
> > 
> > I recognise that you are probably thinking of the stall-due-to-fork problem
> > but I'd expect the patch that raises the bar for <= PAGE_ALLOC_COSTLY_ORDER
> > to be sufficient. If not, I think it still makes sense to call
> > wait_on_page_writeback() for > PAGE_ALLOC_COSTLY_ORDER.
> 
> The main intention of this patch is to remove semi-dead code.
> I'm less disturbed by the long stall time now with the previous patch ;)
> 

Unfortuately, while the code may not be currently doing the most
efficient thing with respect to lumpy reclaim, it's not dead either :/

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
