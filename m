Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B554C6B02A6
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 05:10:51 -0400 (EDT)
Date: Wed, 28 Jul 2010 10:10:33 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] vmscan: remove wait_on_page_writeback() from pageout()
Message-ID: <20100728091032.GD5300@csn.ul.ie>
References: <20100728071705.GA22964@localhost> <AANLkTimaj6+MzY5Aa_xqi75zKy1fDOQV5QiQjdX8jgm7@mail.gmail.com> <20100728084654.GA26776@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100728084654.GA26776@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 04:46:54PM +0800, Wu Fengguang wrote:
> The wait_on_page_writeback() call inside pageout() is virtually dead code.
> 
>         shrink_inactive_list()
>           shrink_page_list(PAGEOUT_IO_ASYNC)
>             pageout(PAGEOUT_IO_ASYNC)
>           shrink_page_list(PAGEOUT_IO_SYNC)
>             pageout(PAGEOUT_IO_SYNC)
> 
> Because shrink_page_list/pageout(PAGEOUT_IO_SYNC) is always called after
> a preceding shrink_page_list/pageout(PAGEOUT_IO_ASYNC), the first
> pageout(ASYNC) converts dirty pages into writeback pages, the second
> shrink_page_list(SYNC) waits on the clean of writeback pages before
> calling pageout(SYNC). The second shrink_page_list(SYNC) can hardly run
> into dirty pages for pageout(SYNC) unless in some race conditions.
> 

It's possible for the second call to run into dirty pages as there is a
congestion_wait() call between the first shrink_page_list() call and the
second. That's a big window.

> And the wait page-by-page behavior of pageout(SYNC) will lead to very
> long stall time if running into some range of dirty pages.

True, but this is also lumpy reclaim which is depending on a contiguous
range of pages. It's better for it to wait on the selected range of pages
which is known to contain at least one old page than excessively scan and
reclaim newer pages.

> So it's bad
> idea anyway to call wait_on_page_writeback() inside pageout().
> 

I recognise that you are probably thinking of the stall-due-to-fork problem
but I'd expect the patch that raises the bar for <= PAGE_ALLOC_COSTLY_ORDER
to be sufficient. If not, I think it still makes sense to call
wait_on_page_writeback() for > PAGE_ALLOC_COSTLY_ORDER.


> CC: Andy Whitcroft <apw@shadowen.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/vmscan.c |   13 ++-----------
>  1 file changed, 2 insertions(+), 11 deletions(-)
> 
> --- linux-next.orig/mm/vmscan.c	2010-07-28 16:22:21.000000000 +0800
> +++ linux-next/mm/vmscan.c	2010-07-28 16:23:35.000000000 +0800
> @@ -324,8 +324,7 @@ typedef enum {
>   * pageout is called by shrink_page_list() for each dirty page.
>   * Calls ->writepage().
>   */
> -static pageout_t pageout(struct page *page, struct address_space *mapping,
> -						enum pageout_io sync_writeback)
> +static pageout_t pageout(struct page *page, struct address_space *mapping)
>  {
>  	/*
>  	 * If the page is dirty, only perform writeback if that write
> @@ -384,14 +383,6 @@ static pageout_t pageout(struct page *pa
>  			return PAGE_ACTIVATE;
>  		}
>  
> -		/*
> -		 * Wait on writeback if requested to. This happens when
> -		 * direct reclaiming a large contiguous area and the
> -		 * first attempt to free a range of pages fails.
> -		 */
> -		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
> -			wait_on_page_writeback(page);
> -
>  		if (!PageWriteback(page)) {
>  			/* synchronous write or broken a_ops? */
>  			ClearPageReclaim(page);
> @@ -727,7 +718,7 @@ static unsigned long shrink_page_list(st
>  				goto keep_locked;
>  
>  			/* Page is dirty, try to write it out here */
> -			switch (pageout(page, mapping, sync_writeback)) {
> +			switch (pageout(page, mapping)) {
>  			case PAGE_KEEP:
>  				goto keep_locked;
>  			case PAGE_ACTIVATE:
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
