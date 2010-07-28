Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8BC4B6B02A8
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 05:30:37 -0400 (EDT)
Date: Wed, 28 Jul 2010 17:30:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] vmscan: remove wait_on_page_writeback() from pageout()
Message-ID: <20100728093031.GA29551@localhost>
References: <20100728071705.GA22964@localhost>
 <AANLkTimaj6+MzY5Aa_xqi75zKy1fDOQV5QiQjdX8jgm7@mail.gmail.com>
 <20100728084654.GA26776@localhost>
 <20100728091032.GD5300@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100728091032.GD5300@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 05:10:33PM +0800, Mel Gorman wrote:
> On Wed, Jul 28, 2010 at 04:46:54PM +0800, Wu Fengguang wrote:
> > The wait_on_page_writeback() call inside pageout() is virtually dead code.
> > 
> >         shrink_inactive_list()
> >           shrink_page_list(PAGEOUT_IO_ASYNC)
> >             pageout(PAGEOUT_IO_ASYNC)
> >           shrink_page_list(PAGEOUT_IO_SYNC)
> >             pageout(PAGEOUT_IO_SYNC)
> > 
> > Because shrink_page_list/pageout(PAGEOUT_IO_SYNC) is always called after
> > a preceding shrink_page_list/pageout(PAGEOUT_IO_ASYNC), the first
> > pageout(ASYNC) converts dirty pages into writeback pages, the second
> > shrink_page_list(SYNC) waits on the clean of writeback pages before
> > calling pageout(SYNC). The second shrink_page_list(SYNC) can hardly run
> > into dirty pages for pageout(SYNC) unless in some race conditions.
> > 
> 
> It's possible for the second call to run into dirty pages as there is a
> congestion_wait() call between the first shrink_page_list() call and the
> second. That's a big window.

OK there is a <=0.1s time window. Then what about the data set size?
After first shrink_page_list(ASYNC), there will be hardly any pages
left in the page_list except for the already under-writeback pages and
other unreclaimable pages. So it still asks for some race conditions
for hitting the second pageout(SYNC) -- some unreclaimable pages
become reclaimable+dirty in the 0.1s time window.

> > And the wait page-by-page behavior of pageout(SYNC) will lead to very
> > long stall time if running into some range of dirty pages.
> 
> True, but this is also lumpy reclaim which is depending on a contiguous
> range of pages. It's better for it to wait on the selected range of pages
> which is known to contain at least one old page than excessively scan and
> reclaim newer pages.
> 
> > So it's bad
> > idea anyway to call wait_on_page_writeback() inside pageout().
> > 
> 
> I recognise that you are probably thinking of the stall-due-to-fork problem
> but I'd expect the patch that raises the bar for <= PAGE_ALLOC_COSTLY_ORDER
> to be sufficient. If not, I think it still makes sense to call
> wait_on_page_writeback() for > PAGE_ALLOC_COSTLY_ORDER.

The main intention of this patch is to remove semi-dead code.
I'm less disturbed by the long stall time now with the previous patch ;)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
