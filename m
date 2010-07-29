From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/5] writeback: introduce bdi_start_inode_writeback()
Date: Thu, 29 Jul 2010 19:51:46 +0800
Message-ID: <20100729121423.613727382@intel.com>
References: <20100729115142.102255590@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1OeS99-0006RJ-6z
	for glkm-linux-mm-2@m.gmane.org; Thu, 29 Jul 2010 14:23:35 +0200
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7396D6B02A6
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 08:23:21 -0400 (EDT)
Content-Disposition: inline; filename=writeback-bdi_start_inode_writeback.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

This is to transfer dirty pages encountered in page reclaim to the
flusher threads for writeback.

The flusher will piggy back more dirty pages for IO, yeilding more
efficient IO.

To avoid memory allocations at page reclaim, a mempool is created.
TODO: more adaptive mempool size.

Background works will be kicked to clean the pages under reclaim ASAP.
TODO: sync_works is temporary reused for convenience.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           |   69 ++++++++++++++++++++++++++++++++--
 include/linux/backing-dev.h |    1 
 2 files changed, 66 insertions(+), 4 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-29 17:13:58.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-29 17:49:05.000000000 +0800
@@ -35,12 +35,15 @@
 struct wb_writeback_work {
 	long nr_pages;
 	struct super_block *sb;
+	struct inode *inode;
+	pgoff_t offset;
 	enum writeback_sync_modes sync_mode;
 	unsigned long sync_after;
 	unsigned int for_sync:1;
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
+	unsigned int for_reclaim:1;
 
 	struct list_head list;		/* pending work list */
 	struct completion *done;	/* set if the caller waits */
@@ -61,6 +64,27 @@ struct wb_writeback_work {
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
+	wb_work_mempool = mempool_create(10240, /* XXX: better number */
+					 wb_work_alloc, mempool_kfree, NULL);
+	return wb_work_mempool ? 0 : -ENOMEM;
+}
+fs_initcall(wb_work_init);
+
 /**
  * writeback_in_progress - determine whether there is writeback in progress
  * @bdi: the device's backing_dev_info structure.
@@ -80,7 +104,7 @@ static void bdi_queue_work(struct backin
 
 	spin_lock(&bdi->wb_lock);
 	list_add_tail(&work->list, &bdi->work_list);
-	if (work->for_sync)
+	if (work->for_sync || work->for_reclaim)
 		atomic_inc(&bdi->wb.sync_works);
 	spin_unlock(&bdi->wb_lock);
 
@@ -109,7 +133,7 @@ __bdi_start_writeback(struct backing_dev
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
-	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
 	if (!work) {
 		if (bdi->wb.task) {
 			trace_writeback_nowork(bdi);
@@ -118,6 +142,7 @@ __bdi_start_writeback(struct backing_dev
 		return;
 	}
 
+	memset(work, 0, sizeof(*work));
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
@@ -156,6 +181,26 @@ void bdi_start_background_writeback(stru
 	__bdi_start_writeback(bdi, LONG_MAX, true, true);
 }
 
+void bdi_start_inode_writeback(struct inode *inode, pgoff_t offset)
+{
+	struct wb_writeback_work *work;
+
+	if (!igrab(inode))
+		return;
+
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
+	if (!work)
+		return;
+
+	memset(work, 0, sizeof(*work));
+	work->sync_mode		= WB_SYNC_NONE;
+	work->inode		= inode;
+	work->offset		= offset;
+	work->for_reclaim	= 1;
+
+	bdi_queue_work(inode->i_sb->s_bdi, work);
+}
+
 /*
  * Redirty an inode: set its when-it-was dirtied timestamp and move it to the
  * furthest end of its superblock's dirty-inode list.
@@ -618,6 +663,22 @@ static long wb_writeback(struct bdi_writ
 	long wrote = 0;
 	struct inode *inode;
 
+	if (work->for_reclaim) {
+		struct page *page = find_get_page(work->inode->i_mapping,
+						  work->offset);
+		wrote = __filemap_fdatawrite_range( /* XXX: write around */
+					work->inode->i_mapping,
+					work->offset,
+					work->offset + MAX_WRITEBACK_PAGES,
+					WB_SYNC_NONE);
+		if (page && PageWriteback(page))
+			SetPageReclaim(page);
+		if (page)
+			page_cache_release(page);
+		iput(work->inode);
+		return wrote;
+	}
+
 	if (!wbc.range_cyclic) {
 		wbc.range_start = 0;
 		wbc.range_end = LLONG_MAX;
@@ -771,7 +832,7 @@ long wb_do_writeback(struct bdi_writebac
 
 		wrote += wb_writeback(wb, work);
 
-		if (work->for_sync)
+		if (work->for_sync || work->for_reclaim)
 			atomic_dec(&wb->sync_works);
 
 		/*
@@ -781,7 +842,7 @@ long wb_do_writeback(struct bdi_writebac
 		if (work->done)
 			complete(work->done);
 		else
-			kfree(work);
+			mempool_free(work, wb_work_mempool);
 	}
 
 	/*
--- linux-next.orig/include/linux/backing-dev.h	2010-07-29 17:13:31.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-07-29 17:47:58.000000000 +0800
@@ -108,6 +108,7 @@ void bdi_unregister(struct backing_dev_i
 int bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
+void bdi_start_inode_writeback(struct inode *inode, pgoff_t offset);
 int bdi_writeback_thread(void *data);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
 void bdi_arm_supers_timer(void);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
