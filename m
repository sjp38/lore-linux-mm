Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 639066B02A8
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 03:17:11 -0400 (EDT)
Date: Wed, 28 Jul 2010 15:17:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
Message-ID: <20100728071705.GA22964@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

Fix "system goes unresponsive under memory pressure and lots of
dirty/writeback pages" bug.

	http://lkml.org/lkml/2010/4/4/86

In the above thread, Andreas Mohr described that

	Invoking any command locked up for minutes (note that I'm
	talking about attempted additional I/O to the _other_,
	_unaffected_ main system HDD - such as loading some shell
	binaries -, NOT the external SSD18M!!).

This happens when the two conditions are both meet:
- under memory pressure
- writing heavily to a slow device

OOM also happens in Andreas' system. The OOM trace shows that 3
processes are stuck in wait_on_page_writeback() in the direct reclaim
path. One in do_fork() and the other two in unix_stream_sendmsg(). They
are blocked on this condition:

	(sc->order && priority < DEF_PRIORITY - 2)

which was introduced in commit 78dc583d (vmscan: low order lumpy reclaim
also should use PAGEOUT_IO_SYNC) one year ago. That condition may be too
permissive. In Andreas' case, 512MB/1024 = 512KB. If the direct reclaim
for the order-1 fork() allocation runs into a range of 512KB
hard-to-reclaim LRU pages, it will be stalled.

It's a severe problem in three ways.

Firstly, it can easily happen in daily desktop usage.  vmscan priority
can easily go below (DEF_PRIORITY - 2) on _local_ memory pressure. Even
if the system has 50% globally reclaimable pages, it still has good
opportunity to have 0.1% sized hard-to-reclaim ranges. For example, a
simple dd can easily create a big range (up to 20%) of dirty pages in
the LRU lists.

Secondly, once triggered, it will stall unrelated processes (not doing IO
at all) in the system. This "one slow USB device stalls the whole system"
avalanching effect is very bad.

Thirdly, once stalled, the stall time could be intolerable long for the
users.  When there are 20MB queued writeback pages and USB 1.1 is
writing them in 1MB/s, wait_on_page_writeback() will stuck for up to 20
seconds.  Not to mention it may be called multiple times.

So raise the bar to only enable PAGEOUT_IO_SYNC when priority goes below
DEF_PRIORITY/3, or 6.25% LRU size. As the default dirty throttle ratio is
20%, it will hardly be triggered by pure dirty pages. We'd better treat
PAGEOUT_IO_SYNC as some last resort workaround -- its stall time is so
uncomfortably long (easily goes beyond 1s).

The bar is only raised for (order < PAGE_ALLOC_COSTLY_ORDER) allocations,
which are easy to satisfy in 1TB memory boxes. So, although 6.25% of
memory could be an awful lot of pages to scan on a system with 1TB of
memory, it won't really have to busy scan that much.

Reported-by: Andreas Mohr <andi@lisas.de>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   51 ++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 43 insertions(+), 8 deletions(-)

--- linux-next.orig/mm/vmscan.c	2010-07-28 13:00:21.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-07-28 14:58:50.000000000 +0800
@@ -1110,6 +1110,47 @@ static int too_many_isolated(struct zone
 }
 
 /*
+ * Returns true if the caller should wait to clean dirty/writeback pages.
+ *
+ * If we are direct reclaiming for contiguous pages and we do not reclaim
+ * everything in the list, try again and wait for writeback IO to complete.
+ * This will stall high-order allocations noticeably. Only do that when really
+ * need to free the pages under high memory pressure.
+ */
+static inline bool should_reclaim_stall(unsigned long nr_taken,
+					unsigned long nr_freed,
+					int priority,
+					struct scan_control *sc)
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
+	 * priority to be much higher before stalling.
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
@@ -1199,14 +1240,8 @@ static unsigned long shrink_inactive_lis
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
