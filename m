Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8B5466B02A8
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 05:22:03 -0400 (EDT)
Date: Thu, 22 Jul 2010 17:21:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100722092155.GA28425@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
 <20100719142145.GD12510@infradead.org>
 <20100719144046.GR13117@csn.ul.ie>
 <20100722085210.GA26714@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722085210.GA26714@localhost>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> I guess this new patch is more problem oriented and acceptable:
> 
> --- linux-next.orig/mm/vmscan.c	2010-07-22 16:36:58.000000000 +0800
> +++ linux-next/mm/vmscan.c	2010-07-22 16:39:57.000000000 +0800
> @@ -1217,7 +1217,8 @@ static unsigned long shrink_inactive_lis
>  			count_vm_events(PGDEACTIVATE, nr_active);
>  
>  			nr_freed += shrink_page_list(&page_list, sc,
> -							PAGEOUT_IO_SYNC);
> +					priority < DEF_PRIORITY / 3 ?
> +					PAGEOUT_IO_SYNC : PAGEOUT_IO_ASYNC);
>  		}
>  
>  		nr_reclaimed += nr_freed;

This one looks better:
---
vmscan: raise the bar to PAGEOUT_IO_SYNC stalls

Fix "system goes totally unresponsive with many dirty/writeback pages"
problem:

	http://lkml.org/lkml/2010/4/4/86

The root cause is, wait_on_page_writeback() is called too early in the
direct reclaim path, which blocks many random/unrelated processes when
some slow (USB stick) writeback is on the way.

A simple dd can easily create a big range of dirty pages in the LRU
list. Therefore priority can easily go below (DEF_PRIORITY - 2) in a
typical desktop, which triggers the lumpy reclaim mode and hence
wait_on_page_writeback().

In Andreas' case, 512MB/1024 = 512KB, this is way too low comparing to
the 22MB writeback and 190MB dirty pages. There can easily be a
continuous range of 512KB dirty/writeback pages in the LRU, which will
trigger the wait logic.

To make it worse, when there are 50MB writeback pages and USB 1.1 is
writing them in 1MB/s, wait_on_page_writeback() may stuck for up to 50
seconds.

So only enter sync write&wait when priority goes below DEF_PRIORITY/3,
or 6.25% LRU. As the default dirty throttle ratio is 20%, sync write&wait
will hardly be triggered by pure dirty pages.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/vmscan.c	2010-07-22 16:36:58.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-07-22 17:03:47.000000000 +0800
@@ -1206,7 +1206,7 @@ static unsigned long shrink_inactive_lis
 		 * but that should be acceptable to the caller
 		 */
 		if (nr_freed < nr_taken && !current_is_kswapd() &&
-		    sc->lumpy_reclaim_mode) {
+		    sc->lumpy_reclaim_mode && priority < DEF_PRIORITY / 3) {
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
