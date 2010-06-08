Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0386B01D1
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 05:08:42 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 5/6] vmscan: Write out ranges of pages contiguous to the inode where possible
Date: Tue,  8 Jun 2010 10:02:24 +0100
Message-Id: <1275987745-21708-6-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Page reclaim cleans individual pages using a_ops->writepage() because from
the VM perspective, it is known that pages in a particular zone must be freed
soon, it considers the target page to be the oldest and it does not want
to wait while background flushers cleans other pages. From a filesystem
perspective this is extremely inefficient as it generates a very seeky
IO pattern leading to the perverse situation where it can take longer to
clean all dirty pages than it would have otherwise.

This patch recognises that there are cases where a number of pages
belonging to the same inode are being written out. When this happens and
writepages() is implemented, the range of pages will be written out with
a_ops->writepages. The inode is pinned and the page lock released before
submitting the range to the filesystem. While this potentially means that
more pages are cleaned than strictly necessary, the expectation is that the
filesystem will be able to writeout the pages more efficiently and improve
overall performance.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |  220 +++++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 176 insertions(+), 44 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 58527c4..b2eb2a6 100644
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
@@ -621,20 +632,120 @@ static enum page_references page_check_references(struct page *page,
 }
 
 /*
+ * Clean a list of pages in contiguous ranges where possible. It is expected
+ * that all the pages on page_list have been locked as part of isolation from
+ * the LRU
+ *
+ * XXX: Is there a problem with holding multiple page locks like this?
+ */
+static noinline_for_stack void clean_page_list(struct list_head *page_list,
+				struct scan_control *sc)
+{
+	LIST_HEAD(ret_pages);
+	struct page *cursor, *page, *tmp;
+
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+	};
+
+	if (!sc->may_writepage)
+		return;
+
+	/* Write the pages out to disk in ranges where possible */
+	while (!list_empty(page_list)) {
+		struct address_space *mapping;
+		bool may_enter_fs;
+
+		cursor = lru_to_page(page_list);
+		list_del(&cursor->lru);
+		list_add(&cursor->lru, &ret_pages);
+		mapping = page_mapping(cursor);
+		if (!mapping || !may_write_to_queue(mapping->backing_dev_info)) {
+			unlock_page(cursor);
+			continue;
+		}
+
+		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
+			(PageSwapCache(cursor) && (sc->gfp_mask & __GFP_IO));
+		if (!may_enter_fs) {
+			unlock_page(cursor);
+			continue;
+		}
+
+		wbc.nr_to_write = LONG_MAX;
+		wbc.range_start = page_offset(cursor);
+		wbc.range_end = page_offset(cursor) + PAGE_CACHE_SIZE - 1;
+
+		/* Only search if there is an inode to pin the address_space with */
+		if (!mapping->host)
+			goto writeout;
+
+		/* Only search if the address_space is smart about ranges */
+		if (!mapping->a_ops->writepages)
+			goto writeout;
+
+		/* Find a range of pages to clean within this list */
+		list_for_each_entry_safe(page, tmp, page_list, lru) {
+			if (!PageDirty(page) || PageWriteback(page))
+				continue;
+			if (page_mapping(page) != mapping)
+				continue;
+
+			list_del(&page->lru);
+			unlock_page(page);
+			list_add(&page->lru, &ret_pages);
+
+			wbc.range_start = min(wbc.range_start, page_offset(page));
+			wbc.range_end = max(wbc.range_end, 
+				(page_offset(page) + PAGE_CACHE_SIZE - 1));
+		}
+
+writeout:
+		if (wbc.range_start == wbc.range_end - PAGE_CACHE_SIZE + 1) {
+			/* Write single page */
+			switch (write_reclaim_page(cursor, mapping, PAGEOUT_IO_ASYNC)) {
+			case PAGE_KEEP:
+			case PAGE_ACTIVATE:
+			case PAGE_CLEAN:
+				unlock_page(cursor);
+				break;
+			case PAGE_SUCCESS:
+				break;
+			}
+		} else {
+			/* Grab inode under page lock before writing range */
+			struct inode *inode = igrab(mapping->host);
+			unlock_page(cursor);
+			if (inode) {
+				do_writepages(mapping, &wbc);
+				iput(inode);
+			}
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
+	LIST_HEAD(putback_pages);
+	LIST_HEAD(dirty_pages);
+	struct list_head *ret_list = page_list;
 	struct pagevec freed_pvec;
-	int pgactivate = 0;
+	int pgactivate;
+	bool cleaned = false;
 	unsigned long nr_reclaimed = 0;
 
+	pgactivate = 0;
 	cond_resched();
 
 	pagevec_init(&freed_pvec, 1);
+
+restart_dirty:
 	while (!list_empty(page_list)) {
 		enum page_references references;
 		struct address_space *mapping;
@@ -723,7 +834,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
@@ -832,10 +954,20 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
-		list_add(&page->lru, &ret_pages);
+		list_add(&page->lru, &putback_pages);
+keep_dirty:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
-	list_splice(&ret_pages, page_list);
+
+	if (!cleaned && !list_empty(&dirty_pages)) {
+		clean_page_list(&dirty_pages, sc);
+		page_list = &dirty_pages;
+		cleaned = true;
+		goto restart_dirty;
+	}
+	BUG_ON(!list_empty(&dirty_pages));
+
+	list_splice(&putback_pages, ret_list);
 	if (pagevec_count(&freed_pvec))
 		__pagevec_free(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
