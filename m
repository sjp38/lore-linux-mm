Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1F46006B8
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 09:11:38 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 4/8] vmscan: Do not writeback filesystem pages in direct reclaim
Date: Mon, 19 Jul 2010 14:11:26 +0100
Message-Id: <1279545090-19169-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When memory is under enough pressure, a process may enter direct
reclaim to free pages in the same manner kswapd does. If a dirty page is
encountered during the scan, this page is written to backing storage using
mapping->writepage. This can result in very deep call stacks, particularly
if the target storage or filesystem are complex. It has already been observed
on XFS that the stack overflows but the problem is not XFS-specific.

This patch prevents direct reclaim writing back filesystem pages by checking
if current is kswapd or the page is anonymous before writing back.  If the
dirty pages cannot be written back, they are placed back on the LRU lists
for either background writing by the BDI threads or kswapd. If in direct
lumpy reclaim and dirty pages are encountered, the process will stall for
the background flusher before trying to reclaim the pages again.

As the call-chain for writing anonymous pages is not expected to be deep
and they are not cleaned by flusher threads, anonymous pages are still
written back in direct reclaim.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |  116 +++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 109 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6587155..bc50937 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -323,6 +323,61 @@ typedef enum {
 	PAGE_CLEAN,
 } pageout_t;
 
+int write_reclaim_page(struct page *page, struct address_space *mapping,
+						enum pageout_io sync_writeback)
+{
+	int res;
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = SWAP_CLUSTER_MAX,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
+		.nonblocking = 1,
+		.for_reclaim = 1,
+	};
+
+	if (!clear_page_dirty_for_io(page))
+		return PAGE_CLEAN;
+
+	SetPageReclaim(page);
+	res = mapping->a_ops->writepage(page, &wbc);
+	if (res < 0)
+		handle_write_error(mapping, page, res);
+	if (res == AOP_WRITEPAGE_ACTIVATE) {
+		ClearPageReclaim(page);
+		return PAGE_ACTIVATE;
+	}
+
+	/*
+	 * Wait on writeback if requested to. This happens when
+	 * direct reclaiming a large contiguous area and the
+	 * first attempt to free a range of pages fails.
+	 */
+	if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
+		wait_on_page_writeback(page);
+
+	if (!PageWriteback(page)) {
+		/* synchronous write or broken a_ops? */
+		ClearPageReclaim(page);
+	}
+	trace_mm_vmscan_writepage(page,
+		page_is_file_cache(page),
+		sync_writeback == PAGEOUT_IO_SYNC);
+	inc_zone_page_state(page, NR_VMSCAN_WRITE);
+
+	return PAGE_SUCCESS;
+}
+
+/*
+ * For now, only kswapd can writeback filesystem pages as otherwise
+ * there is a stack overflow risk
+ */
+static inline bool reclaim_can_writeback(struct scan_control *sc,
+					struct page *page)
+{
+	return !page_is_file_cache(page) || current_is_kswapd();
+}
+
 /*
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
@@ -406,7 +461,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 		return PAGE_SUCCESS;
 	}
 
-	return PAGE_CLEAN;
+	return write_reclaim_page(page, mapping, sync_writeback);
 }
 
 /*
@@ -639,6 +694,9 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
 	pagevec_free(&freed_pvec);
 }
 
+/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
+#define MAX_SWAP_CLEAN_WAIT 50
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -646,13 +704,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
 					enum pageout_io sync_writeback)
 {
-	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
-	int pgactivate = 0;
+	LIST_HEAD(putback_pages);
+	LIST_HEAD(dirty_pages);
+	int pgactivate;
+	int dirty_isolated = 0;
+	unsigned long nr_dirty;
 	unsigned long nr_reclaimed = 0;
 
+	pgactivate = 0;
 	cond_resched();
 
+restart_dirty:
+	nr_dirty = 0;
 	while (!list_empty(page_list)) {
 		enum page_references references;
 		struct address_space *mapping;
@@ -741,7 +805,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (PageDirty(page)) {
+		if (PageDirty(page))  {
+			/*
+			 * If the caller cannot writeback pages, dirty pages
+			 * are put on a separate list for cleaning by either
+			 * a flusher thread or kswapd
+			 */
+			if (!reclaim_can_writeback(sc, page)) {
+				list_add(&page->lru, &dirty_pages);
+				unlock_page(page);
+				nr_dirty++;
+				goto keep_dirty;
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
@@ -852,13 +928,39 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
-		list_add(&page->lru, &ret_pages);
+		list_add(&page->lru, &putback_pages);
+keep_dirty:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
+	if (dirty_isolated < MAX_SWAP_CLEAN_WAIT && !list_empty(&dirty_pages)) {
+		/*
+		 * Wakeup a flusher thread to clean at least as many dirty
+		 * pages as encountered by direct reclaim. Wait on congestion
+		 * to throttle processes cleaning dirty pages
+		 */
+		wakeup_flusher_threads(nr_dirty);
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
+
+		/*
+		 * As lumpy reclaim and memcg targets specific pages, wait on
+		 * them to be cleaned and try reclaim again.
+		 */
+		if (sync_writeback == PAGEOUT_IO_SYNC ||
+						sc->mem_cgroup != NULL) {
+			dirty_isolated++;
+			list_splice(&dirty_pages, page_list);
+			INIT_LIST_HEAD(&dirty_pages);
+			goto restart_dirty;
+		}
+	}
+
 	free_page_list(&free_pages);
 
-	list_splice(&ret_pages, page_list);
+	if (!list_empty(&dirty_pages))
+		list_splice(&dirty_pages, page_list);
+	list_splice(&putback_pages, page_list);
+
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
