Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C56046B01DA
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 07:23:41 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 11/12] vmscan: Write out dirty pages in batch
Date: Mon, 14 Jun 2010 12:17:52 +0100
Message-Id: <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Page reclaim cleans individual pages using a_ops->writepage() because from
the VM perspective, it is known that pages in a particular zone must be freed
soon, it considers the target page to be the oldest and it does not want
to wait while background flushers cleans other pages. From a filesystem
perspective this is extremely inefficient as it generates a very seeky
IO pattern leading to the perverse situation where it can take longer to
clean all dirty pages than it would have otherwise.

This patch queues all dirty pages at once to maximise the chances that
the write requests get merged efficiently. It also makes the next patch
that avoids writeout from direct reclaim more straight-forward.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |  175 ++++++++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 131 insertions(+), 44 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 019f0af..4856a2a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -323,6 +323,55 @@ typedef enum {
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
+	/*
+	 * XXX: This is the Holy Hand Grenade of PotentiallyInvalidMapping. As
+	 * the page lock has been dropped by ->writepage, that mapping could
+	 * be anything
+	 */
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
+		sync_writeback == PAGEOUT_IO_SYNC);
+	inc_zone_page_state(page, NR_VMSCAN_WRITE);
+
+	return PAGE_SUCCESS;
+}
+
 /*
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
@@ -367,45 +416,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
 
-	if (clear_page_dirty_for_io(page)) {
-		int res;
-		struct writeback_control wbc = {
-			.sync_mode = WB_SYNC_NONE,
-			.nr_to_write = SWAP_CLUSTER_MAX,
-			.range_start = 0,
-			.range_end = LLONG_MAX,
-			.nonblocking = 1,
-			.for_reclaim = 1,
-		};
-
-		SetPageReclaim(page);
-		res = mapping->a_ops->writepage(page, &wbc);
-		if (res < 0)
-			handle_write_error(mapping, page, res);
-		if (res == AOP_WRITEPAGE_ACTIVATE) {
-			ClearPageReclaim(page);
-			return PAGE_ACTIVATE;
-		}
-
-		/*
-		 * Wait on writeback if requested to. This happens when
-		 * direct reclaiming a large contiguous area and the
-		 * first attempt to free a range of pages fails.
-		 */
-		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
-			wait_on_page_writeback(page);
-
-		if (!PageWriteback(page)) {
-			/* synchronous write or broken a_ops? */
-			ClearPageReclaim(page);
-		}
-		trace_mm_vmscan_writepage(page,
-			sync_writeback == PAGEOUT_IO_SYNC);
-		inc_zone_page_state(page, NR_VMSCAN_WRITE);
-		return PAGE_SUCCESS;
-	}
-
-	return PAGE_CLEAN;
+	return write_reclaim_page(page, mapping, sync_writeback);
 }
 
 /*
@@ -640,19 +651,75 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
 }
 
 /*
+ * Clean a list of pages. It is expected that all the pages on page_list have been
+ * locked as part of isolation from the LRU.
+ *
+ * XXX: Is there a problem with holding multiple page locks like this?
+ */
+static noinline_for_stack void clean_page_list(struct list_head *page_list,
+				struct scan_control *sc)
+{
+	LIST_HEAD(ret_pages);
+	struct page *page;
+
+	if (!sc->may_writepage)
+		return;
+
+	/* Write the pages out to disk in ranges where possible */
+	while (!list_empty(page_list)) {
+		struct address_space *mapping;
+		bool may_enter_fs;
+
+		page = lru_to_page(page_list);
+		list_del(&page->lru);
+		list_add(&page->lru, &ret_pages);
+
+		mapping = page_mapping(page);
+		if (!mapping || !may_write_to_queue(mapping->backing_dev_info)) {
+			unlock_page(page);
+			continue;
+		}
+
+		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
+			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
+		if (!may_enter_fs) {
+			unlock_page(page);
+			continue;
+		}
+
+		/* Write single page */
+		switch (write_reclaim_page(page, mapping, PAGEOUT_IO_ASYNC)) {
+		case PAGE_KEEP:
+		case PAGE_ACTIVATE:
+		case PAGE_CLEAN:
+			unlock_page(page);
+			break;
+		case PAGE_SUCCESS:
+			break;
+		}
+	}
+	list_splice(&ret_pages, page_list);
+}
+
+/*
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
 					enum pageout_io sync_writeback)
 {
-	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
-	int pgactivate = 0;
+	LIST_HEAD(putback_pages);
+	LIST_HEAD(dirty_pages);
+	struct list_head *ret_list = page_list;
+	int pgactivate;
+	bool cleaned = false;
 	unsigned long nr_reclaimed = 0;
 
+	pgactivate = 0;
 	cond_resched();
 
+restart_dirty:
 	while (!list_empty(page_list)) {
 		enum page_references references;
 		struct address_space *mapping;
@@ -741,7 +808,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (PageDirty(page)) {
+		if (PageDirty(page))  {
+			/*
+			 * On the first pass, dirty pages are put on a separate
+			 * list. IO is then queued based on ranges of pages for
+			 * each unique mapping in the list
+			 */
+			if (!cleaned) {
+				/* Keep locked for clean_page_list */
+				list_add(&page->lru, &dirty_pages);
+				goto keep_dirty;
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
@@ -852,13 +930,22 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
-		list_add(&page->lru, &ret_pages);
+		list_add(&page->lru, &putback_pages);
+keep_dirty:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
+	if (!cleaned && !list_empty(&dirty_pages)) {
+		clean_page_list(&dirty_pages, sc);
+		page_list = &dirty_pages;
+		cleaned = true;
+		goto restart_dirty;
+	}
+	BUG_ON(!list_empty(&dirty_pages));
+
 	free_page_list(&free_pages);
 
-	list_splice(&ret_pages, page_list);
+	list_splice(&putback_pages, ret_list);
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
