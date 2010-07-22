Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D40866B02A5
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 06:48:43 -0400 (EDT)
Date: Thu, 22 Jul 2010 11:48:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
	writeback
Message-ID: <20100722104823.GF13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-8-git-send-email-mel@csn.ul.ie> <20100719142145.GD12510@infradead.org> <20100719144046.GR13117@csn.ul.ie> <20100722085210.GA26714@localhost> <20100722092155.GA28425@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100722092155.GA28425@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 05:21:55PM +0800, Wu Fengguang wrote:
> > I guess this new patch is more problem oriented and acceptable:
> > 
> > --- linux-next.orig/mm/vmscan.c	2010-07-22 16:36:58.000000000 +0800
> > +++ linux-next/mm/vmscan.c	2010-07-22 16:39:57.000000000 +0800
> > @@ -1217,7 +1217,8 @@ static unsigned long shrink_inactive_lis
> >  			count_vm_events(PGDEACTIVATE, nr_active);
> >  
> >  			nr_freed += shrink_page_list(&page_list, sc,
> > -							PAGEOUT_IO_SYNC);
> > +					priority < DEF_PRIORITY / 3 ?
> > +					PAGEOUT_IO_SYNC : PAGEOUT_IO_ASYNC);
> >  		}
> >  
> >  		nr_reclaimed += nr_freed;
> 
> This one looks better:
> ---
> vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
> 
> Fix "system goes totally unresponsive with many dirty/writeback pages"
> problem:
> 
> 	http://lkml.org/lkml/2010/4/4/86
> 
> The root cause is, wait_on_page_writeback() is called too early in the
> direct reclaim path, which blocks many random/unrelated processes when
> some slow (USB stick) writeback is on the way.
> 

So, what's the bet if lumpy reclaim is a factor that it's
high-order-but-low-cost such as fork() that are getting caught by this since
[78dc583d: vmscan: low order lumpy reclaim also should use PAGEOUT_IO_SYNC]
was introduced?

That could manifest to the user as stalls creating new processes when under
heavy IO. I would be surprised it would freeze the entire system but certainly
any new work would feel very slow.

> A simple dd can easily create a big range of dirty pages in the LRU
> list. Therefore priority can easily go below (DEF_PRIORITY - 2) in a
> typical desktop, which triggers the lumpy reclaim mode and hence
> wait_on_page_writeback().
> 

which triggers the lumpy reclaim mode for high-order allocations.

lumpy reclaim mode is not something that is triggered just because priority
is high.

I think there is a second possibility for causing stalls as well that is
unrelated to lumpy reclaim. Once dirty_limit is reached, new page faults may
also result in stalls. If it is taking a long time to writeback dirty data,
random processes could be getting stalled just because they happened to dirty
data at the wrong time.  This would be the case if the main dirtying process
(e.g. dd) is not calling sync and dropping pages it's no longer using.

> In Andreas' case, 512MB/1024 = 512KB, this is way too low comparing to
> the 22MB writeback and 190MB dirty pages. There can easily be a
> continuous range of 512KB dirty/writeback pages in the LRU, which will
> trigger the wait logic.
> 
> To make it worse, when there are 50MB writeback pages and USB 1.1 is
> writing them in 1MB/s, wait_on_page_writeback() may stuck for up to 50
> seconds.
> 
> So only enter sync write&wait when priority goes below DEF_PRIORITY/3,
> or 6.25% LRU. As the default dirty throttle ratio is 20%, sync write&wait
> will hardly be triggered by pure dirty pages.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/vmscan.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- linux-next.orig/mm/vmscan.c	2010-07-22 16:36:58.000000000 +0800
> +++ linux-next/mm/vmscan.c	2010-07-22 17:03:47.000000000 +0800
> @@ -1206,7 +1206,7 @@ static unsigned long shrink_inactive_lis
>  		 * but that should be acceptable to the caller
>  		 */
>  		if (nr_freed < nr_taken && !current_is_kswapd() &&
> -		    sc->lumpy_reclaim_mode) {
> +		    sc->lumpy_reclaim_mode && priority < DEF_PRIORITY / 3) {
>  			congestion_wait(BLK_RW_ASYNC, HZ/10);
>  

This will also delay waiting on congestion for really high-order
allocations such as huge pages, some video decoder and the like which
really should be stalling. How about the following compile-tested diff?
It takes the cost of the high-order allocation into account and the
priority when deciding whether to synchronously wait or not.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..d652e0c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1110,6 +1110,48 @@ static int too_many_isolated(struct zone *zone, int file,
 }
 
 /*
+ * Returns true if the caller should stall on congestion and retry to clean
+ * the list of pages synchronously.
+ *
+ * If we are direct reclaiming for contiguous pages and we do not reclaim
+ * everything in the list, try again and wait for IO to complete. This
+ * will stall high-order allocations but that should be acceptable to
+ * the caller
+ */
+static inline bool should_reclaim_stall(unsigned long nr_taken,
+				unsigned long nr_freed,
+				int priority,
+				struct scan_control *sc)
+{
+	int lumpy_stall_priority;
+
+	/* kswapd should not stall on sync IO */
+	if (current_is_kswapd())
+		return false;
+
+	/* Only stall on lumpy reclaim */
+	if (!sc->lumpy_reclaim_mode)
+		return false;
+
+	/* If we have relaimed everything on the isolated list, no stall */
+	if (nr_freed == nr_taken)
+		return false;
+
+	/*
+	 * For high-order allocations, there are two stall thresholds.
+	 * High-cost allocations stall immediately where as lower
+	 * order allocations such as stacks require the scanning
+	 * priority to be much higher before stalling
+	 */
+	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+		lumpy_stall_priority = DEF_PRIORITY;
+	else
+		lumpy_stall_priority = DEF_PRIORITY / 3;
+
+	return priority <= lumpy_stall_priority;
+}
+
+/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
@@ -1199,14 +1241,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		nr_scanned += nr_scan;
 		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
 
-		/*
-		 * If we are direct reclaiming for contiguous pages and we do
-		 * not reclaim everything in the list, try again and wait
-		 * for IO to complete. This will stall high-order allocations
-		 * but that should be acceptable to the caller
-		 */
-		if (nr_freed < nr_taken && !current_is_kswapd() &&
-		    sc->lumpy_reclaim_mode) {
+		/* Check if we should syncronously wait for writeback */
+		if (should_reclaim_stall(nr_taken, nr_freed, priority, sc)) {
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 			/*



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
