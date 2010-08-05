Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3D8446B02A5
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 02:12:20 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o756CSbU000954
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Aug 2010 15:12:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 15B9F45DE59
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:12:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D1F0E45DE57
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:12:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 519041DB8060
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:12:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AB231DB8062
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:12:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/7] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
In-Reply-To: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
Message-Id: <20100805151125.31BA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Aug 2010 15:12:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

From: Wu Fengguang <fengguang.wu@intel.com>

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
the LRU lists. And order-1 to order-3 allocations are more than common
with SLUB. Try "grep -v '1 :' /proc/slabinfo" to get the list of high
order slab caches. For example, the order-1 radix_tree_node slab cache
may stall applications at swap-in time; the order-3 inode cache on most
filesystems may stall applications when trying to read some file; the
order-2 proc_inode_cache may stall applications when trying to open a
/proc file.

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

Andreas tested an older version of this patch and reported that it
mostly fixed his problem. Mel Gorman helped improve it and KOSAKI
Motohiro will fix it further in the next patch.

Reported-by: Andreas Mohr <andi@lisas.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   52 +++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 43 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1b145e6..cf51d62 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1234,6 +1234,47 @@ static noinline_for_stack void update_isolated_counts(struct zone *zone,
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
@@ -1298,16 +1339,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
 
-	/*
-	 * If we are direct reclaiming for contiguous pages and we do
-	 * not reclaim everything in the list, try again and wait
-	 * for IO to complete. This will stall high-order allocations
-	 * but that should be acceptable to the caller
-	 */
-	if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
-			sc->lumpy_reclaim_mode) {
+	/* Check if we should syncronously wait for writeback */
+	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
-
 		/*
 		 * The attempt at page out may have made some
 		 * of the pages active, mark them inactive again.
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
