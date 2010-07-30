Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 06770600044
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 09:37:06 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when reclaim is encountering dirty pages
Date: Fri, 30 Jul 2010 14:37:00 +0100
Message-Id: <1280497020-22816-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

There are a number of cases where pages get cleaned but two of concern
to this patch are;
  o When dirtying pages, processes may be throttled to clean pages if
    dirty_ratio is not met.
  o Pages belonging to inodes dirtied longer than
    dirty_writeback_centisecs get cleaned.

The problem for reclaim is that dirty pages can reach the end of the LRU if
pages are being dirtied slowly so that neither the throttling or a flusher
thread waking periodically cleans them.

Background flush is already cleaning old or expired inodes first but the
expire time is too far in the future at the time of page reclaim. To mitigate
future problems, this patch wakes flusher threads to clean 4M of data -
an amount that should be manageable without causing congestion in many cases.

Ideally, the background flushers would only be cleaning pages belonging
to the zone being scanned but it's not clear if this would be of benefit
(less IO) or not (potentially less efficient IO if an inode is scattered
across multiple zones).

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   33 +++++++++++++++++++++++++++++++--
 1 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2d2b588..c4c81bc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -142,6 +142,18 @@ static DECLARE_RWSEM(shrinker_rwsem);
 /* Direct lumpy reclaim waits up to five seconds for background cleaning */
 #define MAX_SWAP_CLEAN_WAIT 50
 
+/*
+ * When reclaim encounters dirty data, wakeup flusher threads to clean
+ * a maximum of 4M of data.
+ */
+#define MAX_WRITEBACK (4194304UL >> PAGE_SHIFT)
+#define WRITEBACK_FACTOR (MAX_WRITEBACK / SWAP_CLUSTER_MAX)
+static inline long nr_writeback_pages(unsigned long nr_dirty)
+{
+	return laptop_mode ? 0 :
+			min(MAX_WRITEBACK, (nr_dirty * WRITEBACK_FACTOR));
+}
+
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 						  struct scan_control *sc)
 {
@@ -649,12 +661,14 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
 static unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
 					enum pageout_io sync_writeback,
+					int file,
 					unsigned long *nr_still_dirty)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
 	unsigned long nr_dirty = 0;
+	unsigned long nr_dirty_seen = 0;
 	unsigned long nr_reclaimed = 0;
 
 	cond_resched();
@@ -748,6 +762,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
+			nr_dirty_seen++;
+
 			/*
 			 * Only kswapd can writeback filesystem pages to
 			 * avoid risk of stack overflow
@@ -875,6 +891,18 @@ keep:
 
 	list_splice(&ret_pages, page_list);
 
+	/*
+	 * If reclaim is encountering dirty pages, it may be because
+	 * dirty pages are reaching the end of the LRU even though the
+	 * dirty_ratio may be satisified. In this case, wake flusher
+	 * threads to pro-actively clean up to a maximum of
+	 * 4 * SWAP_CLUSTER_MAX amount of data (usually 1/2MB) unless
+	 * !may_writepage indicates that this is a direct reclaimer in
+	 * laptop mode avoiding disk spin-ups
+	 */
+	if (file && nr_dirty_seen && sc->may_writepage)
+		wakeup_flusher_threads(nr_writeback_pages(nr_dirty));
+
 	*nr_still_dirty = nr_dirty;
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
@@ -1315,7 +1343,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	spin_unlock_irq(&zone->lru_lock);
 
 	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC,
-								&nr_dirty);
+							file, &nr_dirty);
 
 	/*
 	 * If specific pages are needed such as with direct reclaiming
@@ -1351,7 +1379,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 			count_vm_events(PGDEACTIVATE, nr_active);
 
 			nr_reclaimed += shrink_page_list(&page_list, sc,
-						PAGEOUT_IO_SYNC, &nr_dirty);
+						PAGEOUT_IO_SYNC, file,
+						&nr_dirty);
 		}
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
