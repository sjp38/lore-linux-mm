Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 71D93620138
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 10:38:27 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/2] writeback: Account for pages written back belonging to a particular zone
Date: Wed,  4 Aug 2010 15:38:31 +0100
Message-Id: <1280932711-23696-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1280932711-23696-1-git-send-email-mel@csn.ul.ie>
References: <1280932711-23696-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When reclaim encounters dirty file pages on the LRU lists, it wakes up
flusher threads to clean pages belonging to old inodes. In the event the
inode has dirty pages on multiple zones, the flusher threads may exit before
pages within the zone of interest are clean. This patch accounts for the
zone page reclaim is interested in.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/fs-writeback.c         |   35 ++++++++++++++++++++++++++++-------
 include/linux/writeback.h |    6 +++++-
 mm/page-writeback.c       |   12 +++++++++++-
 mm/vmscan.c               |    9 +++++----
 4 files changed, 49 insertions(+), 13 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 0912f93..cc52322 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -40,8 +40,10 @@ int nr_pdflush_threads;
  */
 struct wb_writeback_work {
 	long nr_pages;
+	long nr_zone_pages;
 	struct super_block *sb;
 	enum writeback_sync_modes sync_mode;
+	struct zone *zone;
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
@@ -85,6 +87,7 @@ static void bdi_queue_work(struct backing_dev_info *bdi,
 
 static void
 __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
+		struct zone *zone,
 		bool range_cyclic, bool for_background)
 {
 	struct wb_writeback_work *work;
@@ -104,6 +107,10 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
 	work->for_background = for_background;
+	if (zone) {
+		work->zone = zone;
+		work->nr_zone_pages = nr_pages;
+	}
 
 	bdi_queue_work(bdi, work);
 }
@@ -121,7 +128,7 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
  */
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages)
 {
-	__bdi_start_writeback(bdi, nr_pages, true, false);
+	__bdi_start_writeback(bdi, nr_pages, NULL, true, false);
 }
 
 /**
@@ -135,7 +142,7 @@ void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages)
  */
 void bdi_start_background_writeback(struct backing_dev_info *bdi)
 {
-	__bdi_start_writeback(bdi, LONG_MAX, true, true);
+	__bdi_start_writeback(bdi, LONG_MAX, NULL, true, true);
 }
 
 /*
@@ -650,17 +657,25 @@ static long wb_writeback(struct bdi_writeback *wb,
 		wbc.more_io = 0;
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		wbc.pages_skipped = 0;
+		if (work->zone) {
+			wbc.zone = work->zone;
+			wbc.nr_zone_to_write = wbc.nr_to_write;
+		}
 		if (work->sb)
 			__writeback_inodes_sb(work->sb, wb, &wbc);
 		else
 			writeback_inodes_wb(wb, &wbc);
 		work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
+		if (work->zone)
+			work->nr_zone_pages -=
+				MAX_WRITEBACK_PAGES - wbc.nr_zone_to_write;
 		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 
 		/*
 		 * If we consumed everything, see if we have more
 		 */
-		if (wbc.nr_to_write <= 0)
+		if ((wbc.zone && wbc.nr_zone_to_write <= 0) ||
+							wbc.nr_to_write <= 0)
 			continue;
 		/*
 		 * Didn't write everything and we don't have more IO, bail
@@ -828,7 +843,7 @@ int bdi_writeback_task(struct bdi_writeback *wb)
  * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back
  * the whole world.
  */
-void wakeup_flusher_threads(long nr_pages)
+static void wakeup_flusher_threads_zone(long nr_pages, struct zone *zone)
 {
 	struct backing_dev_info *bdi;
 
@@ -841,7 +856,7 @@ void wakeup_flusher_threads(long nr_pages)
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
 		if (!bdi_has_dirty_io(bdi))
 			continue;
-		__bdi_start_writeback(bdi, nr_pages, false, false);
+		__bdi_start_writeback(bdi, nr_pages, zone, false, false);
 	}
 	rcu_read_unlock();
 }
@@ -850,7 +865,8 @@ void wakeup_flusher_threads(long nr_pages)
  * Similar to wakeup_flusher_threads except prioritise inodes contained
  * in the page_list regardless of age
  */
-void wakeup_flusher_threads_pages(long nr_pages, struct list_head *page_list)
+void wakeup_flusher_threads_pages(long nr_pages, struct zone *zone,
+						struct list_head *page_list)
 {
 	struct page *page;
 	struct address_space *mapping;
@@ -885,7 +901,12 @@ unlock:
 		unlock_page(page);
 	}
 
-	wakeup_flusher_threads(nr_pages);
+	wakeup_flusher_threads_zone(nr_pages, zone);
+}
+
+void wakeup_flusher_threads(long nr_pages)
+{
+	wakeup_flusher_threads_zone(nr_pages, NULL);
 }
 
 static noinline void block_dump___mark_inode_dirty(struct inode *inode)
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 7d4eee4..91e9b89 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -35,7 +35,10 @@ struct writeback_control {
 					   extra jobs and livelock */
 	long nr_to_write;		/* Write this many pages, and decrement
 					   this for each page written */
+	long nr_zone_to_write;		/* Write this many pages from a
+					   specific zone */
 	long pages_skipped;		/* Pages which were not written */
+	struct zone *zone;		/* Zone that needs clean pages */
 
 	/*
 	 * For a_ops->writepages(): is start or end are non-zero then this is
@@ -66,7 +69,8 @@ void writeback_inodes_wb(struct bdi_writeback *wb,
 		struct writeback_control *wbc);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
 void wakeup_flusher_threads(long nr_pages);
-void wakeup_flusher_threads_pages(long nr_pages, struct list_head *page_list);
+void wakeup_flusher_threads_pages(long nr_pages, struct zone *zone,
+						struct list_head *page_list);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 37498ef..0bdddac 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -950,7 +950,17 @@ continue_unlock:
 			}
 
 			if (wbc->nr_to_write > 0) {
-				if (--wbc->nr_to_write == 0 &&
+				long nr_to_write;
+				wbc->nr_to_write--;
+
+				if (wbc->zone) {
+					if (wbc->zone == page_zone(page))
+						wbc->nr_zone_to_write--;
+					nr_to_write = wbc->nr_zone_to_write;
+				} else
+					nr_to_write = wbc->nr_to_write;
+
+				if (nr_to_write == 0 &&
 				    wbc->sync_mode == WB_SYNC_NONE) {
 					/*
 					 * We stop writing back only if we are
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c997d80..036e9fd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -660,6 +660,7 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
+					struct zone *zone,
 					enum pageout_io sync_writeback,
 					int file,
 					unsigned long *nr_still_dirty)
@@ -902,7 +903,7 @@ keep:
 	 */
 	if (file && nr_dirty_seen && sc->may_writepage)
 		wakeup_flusher_threads_pages(nr_writeback_pages(nr_dirty),
-					page_list);
+					zone, page_list);
 
 	*nr_still_dirty = nr_dirty;
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -1343,7 +1344,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC,
+	nr_reclaimed = shrink_page_list(&page_list, sc, zone, PAGEOUT_IO_ASYNC,
 							file, &nr_dirty);
 
 	/*
@@ -1370,7 +1371,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 			}
 
 			wakeup_flusher_threads_pages(laptop_mode ? 0 : nr_dirty,
-								&page_list);
+							zone, &page_list);
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 			/*
@@ -1380,7 +1381,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 			nr_active = clear_active_flags(&page_list, NULL);
 			count_vm_events(PGDEACTIVATE, nr_active);
 
-			nr_reclaimed += shrink_page_list(&page_list, sc,
+			nr_reclaimed += shrink_page_list(&page_list, sc, zone,
 						PAGEOUT_IO_SYNC, file,
 						&nr_dirty);
 		}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
