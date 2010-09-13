Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A74C56B0166
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:08:20 -0400 (EDT)
Message-Id: <20100913130150.138758012@intel.com>
Date: Mon, 13 Sep 2010 20:31:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/4] writeback: introduce bdi_start_inode_writeback()
References: <20100913123110.372291929@intel.com>
Content-Disposition: inline; filename=writeback-bdi_start_inode_writeback.patch
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is to transfer dirty pages encountered in page reclaim to the
flusher threads for writeback.

The flusher will piggy back more dirty pages for IO
- it's more IO efficient
- it helps clean more pages, a good number of them may sit in the same
  LRU list that is being scanned.

To avoid memory allocations at page reclaim, a mempool is created.

Background/periodic works will quit automatically, so as to clean the
pages under reclaim ASAP. However the sync work can still block us for
long time.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           |  103 +++++++++++++++++++++++++++++++++-
 include/linux/backing-dev.h |    2 
 2 files changed, 102 insertions(+), 3 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-09-13 20:06:09.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-09-13 20:24:03.000000000 +0800
@@ -30,11 +30,20 @@
 #include "internal.h"
 
 /*
+ * When flushing an inode page (for page reclaim), try to piggy back more
+ * nearby pages for IO efficiency. These pages will have good opportunity
+ * to be in the same LRU list.
+ */
+#define WRITE_AROUND_PAGES	(1UL << (20 - PAGE_CACHE_SHIFT))
+
+/*
  * Passed into wb_writeback(), essentially a subset of writeback_control
  */
 struct wb_writeback_work {
 	long nr_pages;
 	struct super_block *sb;
+	struct inode *inode;
+	pgoff_t offset;
 	enum writeback_sync_modes sync_mode;
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
@@ -59,6 +68,27 @@ struct wb_writeback_work {
  */
 int nr_pdflush_threads;
 
+static mempool_t *wb_work_mempool;
+
+static void *wb_work_alloc(gfp_t gfp_mask, void *pool_data)
+{
+	/*
+	 * bdi_start_inode_writeback() may be called on page reclaim
+	 */
+	if (current->flags & PF_MEMALLOC)
+		return NULL;
+
+	return kmalloc(sizeof(struct wb_writeback_work), gfp_mask);
+}
+
+static __init int wb_work_init(void)
+{
+	wb_work_mempool = mempool_create(1024,
+					 wb_work_alloc, mempool_kfree, NULL);
+	return wb_work_mempool ? 0 : -ENOMEM;
+}
+fs_initcall(wb_work_init);
+
 /**
  * writeback_in_progress - determine whether there is writeback in progress
  * @bdi: the device's backing_dev_info structure.
@@ -101,7 +131,7 @@ __bdi_start_writeback(struct backing_dev
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
-	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
 	if (!work) {
 		if (bdi->wb.task) {
 			trace_writeback_nowork(bdi);
@@ -110,6 +140,7 @@ __bdi_start_writeback(struct backing_dev
 		return;
 	}
 
+	memset(work, 0, sizeof(*work));
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
@@ -148,6 +179,55 @@ void bdi_start_background_writeback(stru
 	__bdi_start_writeback(bdi, LONG_MAX, true, true);
 }
 
+int bdi_start_inode_writeback(struct backing_dev_info *bdi,
+			      struct inode *inode, pgoff_t offset)
+{
+	struct wb_writeback_work *work;
+
+	spin_lock_bh(&bdi->wb_lock);
+	list_for_each_entry_reverse(work, &bdi->work_list, list) {
+		unsigned long end;
+		if (work->inode != inode)
+			continue;
+		end = work->offset + work->nr_pages;
+		if (work->offset - offset < WRITE_AROUND_PAGES) {
+			work->nr_pages += work->offset - offset;
+			work->offset = offset;
+			inode = NULL;
+			break;
+		} else if (offset - end < WRITE_AROUND_PAGES) {
+			work->nr_pages += offset - end;
+			inode = NULL;
+			break;
+		} else if (offset > work->offset &&
+			   offset < end) {
+			inode = NULL;
+			break;
+		}
+	}
+	spin_unlock_bh(&bdi->wb_lock);
+
+	if (!inode)
+		return 0;
+
+	if (!igrab(inode))
+		return -ENOENT;
+
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
+	if (!work)
+		return -ENOMEM;
+
+	memset(work, 0, sizeof(*work));
+	work->sync_mode		= WB_SYNC_NONE;
+	work->inode		= inode;
+	work->offset		= offset;
+	work->nr_pages		= 1;
+
+	bdi_queue_work(inode->i_sb->s_bdi, work);
+
+	return 0;
+}
+
 /*
  * Redirty an inode: set its when-it-was dirtied timestamp and move it to the
  * furthest end of its superblock's dirty-inode list.
@@ -724,6 +804,20 @@ get_next_work_item(struct backing_dev_in
 	return work;
 }
 
+static long wb_flush_inode(struct bdi_writeback *wb,
+			   struct wb_writeback_work *work)
+{
+	pgoff_t start = round_down(work->offset, WRITE_AROUND_PAGES);
+	pgoff_t end = round_up(work->offset + work->nr_pages,
+			       WRITE_AROUND_PAGES);
+	int wrote;
+
+	wrote = __filemap_fdatawrite_range(work->inode->i_mapping,
+					   start, end, WB_SYNC_NONE);
+	iput(work->inode);
+	return wrote;
+}
+
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
 	if (over_bground_thresh()) {
@@ -796,7 +890,10 @@ long wb_do_writeback(struct bdi_writebac
 
 		trace_writeback_exec(bdi, work);
 
-		wrote += wb_writeback(wb, work);
+		if (work->inode)
+			wrote += wb_flush_inode(wb, work);
+		else
+			wrote += wb_writeback(wb, work);
 
 		/*
 		 * Notify the caller of completion if this is a synchronous
@@ -805,7 +902,7 @@ long wb_do_writeback(struct bdi_writebac
 		if (work->done)
 			complete(work->done);
 		else
-			kfree(work);
+			mempool_free(work, wb_work_mempool);
 	}
 
 	/*
--- linux-next.orig/include/linux/backing-dev.h	2010-09-13 19:48:16.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-09-13 20:20:59.000000000 +0800
@@ -106,6 +106,8 @@ void bdi_unregister(struct backing_dev_i
 int bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
+int bdi_start_inode_writeback(struct backing_dev_info *bdi,
+			      struct inode *inode, pgoff_t offset);
 int bdi_writeback_thread(void *data);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
 void bdi_arm_supers_timer(void);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
