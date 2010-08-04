Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BBBDC60020C
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 10:38:26 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/2] writeback: Prioritise dirty inodes encountered by reclaim for background flushing
Date: Wed,  4 Aug 2010 15:38:30 +0100
Message-Id: <1280932711-23696-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1280932711-23696-1-git-send-email-mel@csn.ul.ie>
References: <1280932711-23696-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

It is preferable that as few dirty pages are dispatched for cleaning from
the page reclaim path. When dirty pages are encountered by page reclaim,
this patch marks the inodes that they should be dispatched immediately. When
the background flusher runs, it moves such inodes immediately to the dispatch
queue regardless of inode age.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/fs-writeback.c         |   52 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h        |    5 ++-
 include/linux/writeback.h |    1 +
 mm/vmscan.c               |    6 +++-
 4 files changed, 59 insertions(+), 5 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d5be169..0912f93 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -205,9 +205,17 @@ static void move_expired_inodes(struct list_head *delaying_queue,
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
-	struct inode *inode;
+	struct inode *inode, *tinode;
 	int do_sb_sort = 0;
 
+	/* Move inodes reclaim found at end of LRU to dispatch queue */
+	list_for_each_entry_safe(inode, tinode, delaying_queue, i_list) {
+		if (inode->i_state & I_DIRTY_RECLAIM) {
+			inode->i_state &= ~I_DIRTY_RECLAIM;
+			list_move(&inode->i_list, &tmp);
+		}
+	}
+
 	while (!list_empty(delaying_queue)) {
 		inode = list_entry(delaying_queue->prev, struct inode, i_list);
 		if (older_than_this &&
@@ -838,6 +846,48 @@ void wakeup_flusher_threads(long nr_pages)
 	rcu_read_unlock();
 }
 
+/*
+ * Similar to wakeup_flusher_threads except prioritise inodes contained
+ * in the page_list regardless of age
+ */
+void wakeup_flusher_threads_pages(long nr_pages, struct list_head *page_list)
+{
+	struct page *page;
+	struct address_space *mapping;
+	struct inode *inode;
+
+	list_for_each_entry(page, page_list, lru) {
+		if (!PageDirty(page))
+			continue;
+
+		lock_page(page);
+		mapping = page_mapping(page);
+		if (!mapping || mapping == &swapper_space)
+			goto unlock;
+
+		/*
+		 * Test outside the lock to see as if it is already set, taking
+		 * the inode lock is a waste and the inode should be pinned by
+		 * the lock_page
+		 */
+		inode = page->mapping->host;
+		if (inode->i_state & I_DIRTY_RECLAIM)
+			goto unlock;
+
+		/*
+		 * XXX: Yuck, has to be a way of batching this by not requiring
+		 *	the page lock to pin the inode
+		 */
+		spin_lock(&inode_lock);
+		inode->i_state |= I_DIRTY_RECLAIM;
+		spin_unlock(&inode_lock);
+unlock:
+		unlock_page(page);
+	}
+
+	wakeup_flusher_threads(nr_pages);
+}
+
 static noinline void block_dump___mark_inode_dirty(struct inode *inode)
 {
 	if (inode->i_ino || strcmp(inode->i_sb->s_id, "bdev")) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 68ca1b0..19ad1f5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1585,8 +1585,8 @@ struct super_operations {
 /*
  * Inode state bits.  Protected by inode_lock.
  *
- * Three bits determine the dirty state of the inode, I_DIRTY_SYNC,
- * I_DIRTY_DATASYNC and I_DIRTY_PAGES.
+ * Four bits determine the dirty state of the inode, I_DIRTY_SYNC,
+ * I_DIRTY_DATASYNC, I_DIRTY_PAGES and I_DIRTY_RECLAIM.
  *
  * Four bits define the lifetime of an inode.  Initially, inodes are I_NEW,
  * until that flag is cleared.  I_WILL_FREE, I_FREEING and I_CLEAR are set at
@@ -1633,6 +1633,7 @@ struct super_operations {
 #define I_DIRTY_SYNC		1
 #define I_DIRTY_DATASYNC	2
 #define I_DIRTY_PAGES		4
+#define I_DIRTY_RECLAIM		256
 #define __I_NEW			3
 #define I_NEW			(1 << __I_NEW)
 #define I_WILL_FREE		16
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index c24eca7..7d4eee4 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -66,6 +66,7 @@ void writeback_inodes_wb(struct bdi_writeback *wb,
 		struct writeback_control *wbc);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
 void wakeup_flusher_threads(long nr_pages);
+void wakeup_flusher_threads_pages(long nr_pages, struct list_head *page_list);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4c81bc..c997d80 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -901,7 +901,8 @@ keep:
 	 * laptop mode avoiding disk spin-ups
 	 */
 	if (file && nr_dirty_seen && sc->may_writepage)
-		wakeup_flusher_threads(nr_writeback_pages(nr_dirty));
+		wakeup_flusher_threads_pages(nr_writeback_pages(nr_dirty),
+					page_list);
 
 	*nr_still_dirty = nr_dirty;
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -1368,7 +1369,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 				list_add(&page->lru, &putback_list);
 			}
 
-			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
+			wakeup_flusher_threads_pages(laptop_mode ? 0 : nr_dirty,
+								&page_list);
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 			/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
