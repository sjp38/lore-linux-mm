Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 18FC96007FC
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 06:27:32 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 6/9] writeback: Roll up of writeback changes in next-20100722 versus 2.6.35-rc5
Date: Wed, 28 Jul 2010 11:27:20 +0100
Message-Id: <1280312843-11789-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
References: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Mostly Christoph Hellwig <hch@lst.de>

This is a roll-up of patches in linux-next that Wu's patches depend on. They
are included here for convenience of testing against mainline. They should
be unnecessary for testing against mmotm.

No signoff-required.
---
 fs/btrfs/inode.c                 |    2 +-
 fs/drop_caches.c                 |    2 +-
 fs/fs-writeback.c                |   90 ++++++++++++++++++----
 fs/gfs2/inode.c                  |    2 +-
 fs/inode.c                       |   16 ++--
 fs/nilfs2/gcdat.c                |    2 +-
 fs/notify/inode_mark.c           |    6 +-
 fs/notify/inotify/inotify.c      |    7 +-
 fs/quota/dquot.c                 |    2 +-
 fs/xfs/linux-2.6/xfs_iops.c      |    4 +-
 include/linux/backing-dev.h      |    7 +-
 include/linux/fs.h               |    4 +-
 include/trace/events/writeback.h |  155 ++++++++++++++++++++++++++++++++++++++
 mm/backing-dev.c                 |  114 ++++++----------------------
 mm/page-writeback.c              |    4 +
 15 files changed, 284 insertions(+), 133 deletions(-)
 create mode 100644 include/trace/events/writeback.h

diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 1bff92a..ecf556d 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -3858,7 +3858,7 @@ again:
 			p = &parent->rb_right;
 		else {
 			WARN_ON(!(entry->vfs_inode.i_state &
-				  (I_WILL_FREE | I_FREEING | I_CLEAR)));
+				  (I_WILL_FREE | I_FREEING)));
 			rb_erase(parent, &root->inode_tree);
 			RB_CLEAR_NODE(parent);
 			spin_unlock(&root->inode_lock);
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 83c4f60..2195c21 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -18,7 +18,7 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 
 	spin_lock(&inode_lock);
 	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
-		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE|I_NEW))
+		if (inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW))
 			continue;
 		if (inode->i_mapping->nrpages == 0)
 			continue;
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d5be169..10f939a 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -26,15 +26,9 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/buffer_head.h>
+#include <linux/tracepoint.h>
 #include "internal.h"
 
-#define inode_to_bdi(inode)	((inode)->i_mapping->backing_dev_info)
-
-/*
- * We don't actually have pdflush, but this one is exported though /proc...
- */
-int nr_pdflush_threads;
-
 /*
  * Passed into wb_writeback(), essentially a subset of writeback_control
  */
@@ -50,6 +44,21 @@ struct wb_writeback_work {
 	struct completion *done;	/* set if the caller waits */
 };
 
+/*
+ * Include the creation of the trace points after defining the
+ * wb_writeback_work structure so that the definition remains local to this
+ * file.
+ */
+#define CREATE_TRACE_POINTS
+#include <trace/events/writeback.h>
+
+#define inode_to_bdi(inode)	((inode)->i_mapping->backing_dev_info)
+
+/*
+ * We don't actually have pdflush, but this one is exported though /proc...
+ */
+int nr_pdflush_threads;
+
 /**
  * writeback_in_progress - determine whether there is writeback in progress
  * @bdi: the device's backing_dev_info structure.
@@ -65,6 +74,8 @@ int writeback_in_progress(struct backing_dev_info *bdi)
 static void bdi_queue_work(struct backing_dev_info *bdi,
 		struct wb_writeback_work *work)
 {
+	trace_writeback_queue(bdi, work);
+
 	spin_lock(&bdi->wb_lock);
 	list_add_tail(&work->list, &bdi->work_list);
 	spin_unlock(&bdi->wb_lock);
@@ -73,9 +84,10 @@ static void bdi_queue_work(struct backing_dev_info *bdi,
 	 * If the default thread isn't there, make sure we add it. When
 	 * it gets created and wakes up, we'll run this work.
 	 */
-	if (unlikely(list_empty_careful(&bdi->wb_list)))
+	if (unlikely(!bdi->wb.task)) {
+		trace_writeback_nothread(bdi, work);
 		wake_up_process(default_backing_dev_info.wb.task);
-	else {
+	} else {
 		struct bdi_writeback *wb = &bdi->wb;
 
 		if (wb->task)
@@ -95,8 +107,10 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 	 */
 	work = kzalloc(sizeof(*work), GFP_ATOMIC);
 	if (!work) {
-		if (bdi->wb.task)
+		if (bdi->wb.task) {
+			trace_writeback_nowork(bdi);
 			wake_up_process(bdi->wb.task);
+		}
 		return;
 	}
 
@@ -352,7 +366,7 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 
 	spin_lock(&inode_lock);
 	inode->i_state &= ~I_SYNC;
-	if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
+	if (!(inode->i_state & I_FREEING)) {
 		if ((inode->i_state & I_DIRTY_PAGES) && wbc->for_kupdate) {
 			/*
 			 * More pages get dirtied by a fast dirtier.
@@ -499,7 +513,7 @@ static int writeback_sb_inodes(struct super_block *sb, struct bdi_writeback *wb,
 		if (inode_dirtied_after(inode, wbc->wb_start))
 			return 1;
 
-		BUG_ON(inode->i_state & (I_FREEING | I_CLEAR));
+		BUG_ON(inode->i_state & I_FREEING);
 		__iget(inode);
 		pages_skipped = wbc->pages_skipped;
 		writeback_single_inode(inode, wbc);
@@ -642,10 +656,14 @@ static long wb_writeback(struct bdi_writeback *wb,
 		wbc.more_io = 0;
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		wbc.pages_skipped = 0;
+
+		trace_wbc_writeback_start(&wbc, wb->bdi);
 		if (work->sb)
 			__writeback_inodes_sb(work->sb, wb, &wbc);
 		else
 			writeback_inodes_wb(wb, &wbc);
+		trace_wbc_writeback_written(&wbc, wb->bdi);
+
 		work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 
@@ -673,6 +691,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 		if (!list_empty(&wb->b_more_io))  {
 			inode = list_entry(wb->b_more_io.prev,
 						struct inode, i_list);
+			trace_wbc_writeback_wait(&wbc, wb->bdi);
 			inode_wait_for_writeback(inode);
 		}
 		spin_unlock(&inode_lock);
@@ -751,6 +770,8 @@ long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
 		if (force_wait)
 			work->sync_mode = WB_SYNC_ALL;
 
+		trace_writeback_exec(bdi, work);
+
 		wrote += wb_writeback(wb, work);
 
 		/*
@@ -775,15 +796,43 @@ long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
  * Handle writeback of dirty data for the device backed by this bdi. Also
  * wakes up periodically and does kupdated style flushing.
  */
-int bdi_writeback_task(struct bdi_writeback *wb)
+int bdi_writeback_thread(void *data)
 {
+	struct bdi_writeback *wb = data;
+	struct backing_dev_info *bdi = wb->bdi;
 	unsigned long last_active = jiffies;
 	unsigned long wait_jiffies = -1UL;
 	long pages_written;
 
+	/*
+	 * Add us to the active bdi_list
+	 */
+	spin_lock_bh(&bdi_lock);
+	list_add_rcu(&bdi->bdi_list, &bdi_list);
+	spin_unlock_bh(&bdi_lock);
+
+	current->flags |= PF_FLUSHER | PF_SWAPWRITE;
+	set_freezable();
+
+	/*
+	 * Our parent may run at a different priority, just set us to normal
+	 */
+	set_user_nice(current, 0);
+
+	/*
+	 * Clear pending bit and wakeup anybody waiting to tear us down
+	 */
+	clear_bit(BDI_pending, &bdi->state);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&bdi->state, BDI_pending);
+
+	trace_writeback_thread_start(bdi);
+
 	while (!kthread_should_stop()) {
 		pages_written = wb_do_writeback(wb, 0);
 
+		trace_writeback_pages_written(pages_written);
+
 		if (pages_written)
 			last_active = jiffies;
 		else if (wait_jiffies != -1UL) {
@@ -813,9 +862,20 @@ int bdi_writeback_task(struct bdi_writeback *wb)
 		try_to_freeze();
 	}
 
+	wb->task = NULL;
+
+	/*
+	 * Flush any work that raced with us exiting. No new work
+	 * will be added, since this bdi isn't discoverable anymore.
+	 */
+	if (!list_empty(&bdi->work_list))
+		wb_do_writeback(wb, 1);
+
+	trace_writeback_thread_stop(bdi);
 	return 0;
 }
 
+
 /*
  * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back
  * the whole world.
@@ -935,7 +995,7 @@ void __mark_inode_dirty(struct inode *inode, int flags)
 			if (hlist_unhashed(&inode->i_hash))
 				goto out;
 		}
-		if (inode->i_state & (I_FREEING|I_CLEAR))
+		if (inode->i_state & I_FREEING)
 			goto out;
 
 		/*
@@ -1001,7 +1061,7 @@ static void wait_sb_inodes(struct super_block *sb)
 	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
 		struct address_space *mapping;
 
-		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE|I_NEW))
+		if (inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW))
 			continue;
 		mapping = inode->i_mapping;
 		if (mapping->nrpages == 0)
diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
index f03afd9..edc30b2 100644
--- a/fs/gfs2/inode.c
+++ b/fs/gfs2/inode.c
@@ -84,7 +84,7 @@ static int iget_skip_test(struct inode *inode, void *opaque)
 	struct gfs2_skip_data *data = opaque;
 
 	if (ip->i_no_addr == data->no_addr) {
-		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE)){
+		if (inode->i_state & (I_FREEING|I_WILL_FREE)){
 			data->skipped = 1;
 			return 0;
 		}
diff --git a/fs/inode.c b/fs/inode.c
index 722860b..71fe079 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -317,7 +317,7 @@ void clear_inode(struct inode *inode)
 		bd_forget(inode);
 	if (S_ISCHR(inode->i_mode) && inode->i_cdev)
 		cd_forget(inode);
-	inode->i_state = I_CLEAR;
+	inode->i_state = I_FREEING | I_CLEAR;
 }
 EXPORT_SYMBOL(clear_inode);
 
@@ -553,7 +553,7 @@ repeat:
 			continue;
 		if (!test(inode, data))
 			continue;
-		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE)) {
+		if (inode->i_state & (I_FREEING|I_WILL_FREE)) {
 			__wait_on_freeing_inode(inode);
 			goto repeat;
 		}
@@ -578,7 +578,7 @@ repeat:
 			continue;
 		if (inode->i_sb != sb)
 			continue;
-		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE)) {
+		if (inode->i_state & (I_FREEING|I_WILL_FREE)) {
 			__wait_on_freeing_inode(inode);
 			goto repeat;
 		}
@@ -840,7 +840,7 @@ EXPORT_SYMBOL(iunique);
 struct inode *igrab(struct inode *inode)
 {
 	spin_lock(&inode_lock);
-	if (!(inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE)))
+	if (!(inode->i_state & (I_FREEING|I_WILL_FREE)))
 		__iget(inode);
 	else
 		/*
@@ -1089,7 +1089,7 @@ int insert_inode_locked(struct inode *inode)
 				continue;
 			if (old->i_sb != sb)
 				continue;
-			if (old->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE))
+			if (old->i_state & (I_FREEING|I_WILL_FREE))
 				continue;
 			break;
 		}
@@ -1128,7 +1128,7 @@ int insert_inode_locked4(struct inode *inode, unsigned long hashval,
 				continue;
 			if (!test(old, data))
 				continue;
-			if (old->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE))
+			if (old->i_state & (I_FREEING|I_WILL_FREE))
 				continue;
 			break;
 		}
@@ -1218,7 +1218,7 @@ void generic_delete_inode(struct inode *inode)
 	hlist_del_init(&inode->i_hash);
 	spin_unlock(&inode_lock);
 	wake_up_inode(inode);
-	BUG_ON(inode->i_state != I_CLEAR);
+	BUG_ON(inode->i_state != (I_FREEING | I_CLEAR));
 	destroy_inode(inode);
 }
 EXPORT_SYMBOL(generic_delete_inode);
@@ -1322,7 +1322,7 @@ static inline void iput_final(struct inode *inode)
 void iput(struct inode *inode)
 {
 	if (inode) {
-		BUG_ON(inode->i_state == I_CLEAR);
+		BUG_ON(inode->i_state & I_CLEAR);
 
 		if (atomic_dec_and_lock(&inode->i_count, &inode_lock))
 			iput_final(inode);
diff --git a/fs/nilfs2/gcdat.c b/fs/nilfs2/gcdat.c
index dd5f7e0..84a45d1 100644
--- a/fs/nilfs2/gcdat.c
+++ b/fs/nilfs2/gcdat.c
@@ -78,7 +78,7 @@ void nilfs_clear_gcdat_inode(struct the_nilfs *nilfs)
 	struct inode *gcdat = nilfs->ns_gc_dat;
 	struct nilfs_inode_info *gii = NILFS_I(gcdat);
 
-	gcdat->i_state = I_CLEAR;
+	gcdat->i_state = I_FREEING | I_CLEAR;
 	gii->i_flags = 0;
 
 	nilfs_palloc_clear_cache(gcdat);
diff --git a/fs/notify/inode_mark.c b/fs/notify/inode_mark.c
index 0399bcb..152b83e 100644
--- a/fs/notify/inode_mark.c
+++ b/fs/notify/inode_mark.c
@@ -369,11 +369,11 @@ void fsnotify_unmount_inodes(struct list_head *list)
 		struct inode *need_iput_tmp;
 
 		/*
-		 * We cannot __iget() an inode in state I_CLEAR, I_FREEING,
+		 * We cannot __iget() an inode in state I_FREEING,
 		 * I_WILL_FREE, or I_NEW which is fine because by that point
 		 * the inode cannot have any associated watches.
 		 */
-		if (inode->i_state & (I_CLEAR|I_FREEING|I_WILL_FREE|I_NEW))
+		if (inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW))
 			continue;
 
 		/*
@@ -397,7 +397,7 @@ void fsnotify_unmount_inodes(struct list_head *list)
 		/* In case the dropping of a reference would nuke next_i. */
 		if ((&next_i->i_sb_list != list) &&
 		    atomic_read(&next_i->i_count) &&
-		    !(next_i->i_state & (I_CLEAR | I_FREEING | I_WILL_FREE))) {
+		    !(next_i->i_state & (I_FREEING | I_WILL_FREE))) {
 			__iget(next_i);
 			need_iput = next_i;
 		}
diff --git a/fs/notify/inotify/inotify.c b/fs/notify/inotify/inotify.c
index 27b75eb..cf6b042 100644
--- a/fs/notify/inotify/inotify.c
+++ b/fs/notify/inotify/inotify.c
@@ -377,11 +377,11 @@ void inotify_unmount_inodes(struct list_head *list)
 		struct list_head *watches;
 
 		/*
-		 * We cannot __iget() an inode in state I_CLEAR, I_FREEING,
+		 * We cannot __iget() an inode in state I_FREEING,
 		 * I_WILL_FREE, or I_NEW which is fine because by that point
 		 * the inode cannot have any associated watches.
 		 */
-		if (inode->i_state & (I_CLEAR|I_FREEING|I_WILL_FREE|I_NEW))
+		if (inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW))
 			continue;
 
 		/*
@@ -403,8 +403,7 @@ void inotify_unmount_inodes(struct list_head *list)
 		/* In case the dropping of a reference would nuke next_i. */
 		if ((&next_i->i_sb_list != list) &&
 				atomic_read(&next_i->i_count) &&
-				!(next_i->i_state & (I_CLEAR | I_FREEING |
-					I_WILL_FREE))) {
+				!(next_i->i_state & (I_FREEING|I_WILL_FREE))) {
 			__iget(next_i);
 			need_iput = next_i;
 		}
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 437d2ca..5cec3e2 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -885,7 +885,7 @@ static void add_dquot_ref(struct super_block *sb, int type)
 
 	spin_lock(&inode_lock);
 	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
-		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE|I_NEW))
+		if (inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW))
 			continue;
 #ifdef CONFIG_QUOTA_DEBUG
 		if (unlikely(inode_get_rsv_space(inode) > 0))
diff --git a/fs/xfs/linux-2.6/xfs_iops.c b/fs/xfs/linux-2.6/xfs_iops.c
index 44f0b2d..f4f0a41 100644
--- a/fs/xfs/linux-2.6/xfs_iops.c
+++ b/fs/xfs/linux-2.6/xfs_iops.c
@@ -88,7 +88,7 @@ xfs_mark_inode_dirty_sync(
 {
 	struct inode	*inode = VFS_I(ip);
 
-	if (!(inode->i_state & (I_WILL_FREE|I_FREEING|I_CLEAR)))
+	if (!(inode->i_state & (I_WILL_FREE|I_FREEING)))
 		mark_inode_dirty_sync(inode);
 }
 
@@ -98,7 +98,7 @@ xfs_mark_inode_dirty(
 {
 	struct inode	*inode = VFS_I(ip);
 
-	if (!(inode->i_state & (I_WILL_FREE|I_FREEING|I_CLEAR)))
+	if (!(inode->i_state & (I_WILL_FREE|I_FREEING)))
 		mark_inode_dirty(inode);
 }
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index e9aec0d..e536f3a 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -45,8 +45,6 @@ enum bdi_stat_item {
 #define BDI_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
 
 struct bdi_writeback {
-	struct list_head list;			/* hangs off the bdi */
-
 	struct backing_dev_info *bdi;		/* our parent bdi */
 	unsigned int nr;
 
@@ -80,8 +78,7 @@ struct backing_dev_info {
 	unsigned int max_ratio, max_prop_frac;
 
 	struct bdi_writeback wb;  /* default writeback info for this bdi */
-	spinlock_t wb_lock;	  /* protects update side of wb_list */
-	struct list_head wb_list; /* the flusher threads hanging off this bdi */
+	spinlock_t wb_lock;	  /* protects work_list */
 
 	struct list_head work_list;
 
@@ -105,7 +102,7 @@ void bdi_unregister(struct backing_dev_info *bdi);
 int bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
-int bdi_writeback_task(struct bdi_writeback *wb);
+int bdi_writeback_thread(void *data);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
 void bdi_arm_supers_timer(void);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 68ca1b0..e29f0ed 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1615,8 +1615,8 @@ struct super_operations {
  * I_FREEING		Set when inode is about to be freed but still has dirty
  *			pages or buffers attached or the inode itself is still
  *			dirty.
- * I_CLEAR		Set by clear_inode().  In this state the inode is clean
- *			and can be destroyed.
+ * I_CLEAR		Added by clear_inode().  In this state the inode is clean
+ *			and can be destroyed.  Inode keeps I_FREEING.
  *
  *			Inodes that are I_WILL_FREE, I_FREEING or I_CLEAR are
  *			prohibited for many purposes.  iget() must wait for
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
new file mode 100644
index 0000000..0be26ac
--- /dev/null
+++ b/include/trace/events/writeback.h
@@ -0,0 +1,155 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM writeback
+
+#if !defined(_TRACE_WRITEBACK_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_WRITEBACK_H
+
+#include <linux/backing-dev.h>
+#include <linux/writeback.h>
+
+struct wb_writeback_work;
+
+DECLARE_EVENT_CLASS(writeback_work_class,
+	TP_PROTO(struct backing_dev_info *bdi, struct wb_writeback_work *work),
+	TP_ARGS(bdi, work),
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(long, nr_pages)
+		__field(dev_t, sb_dev)
+		__field(int, sync_mode)
+		__field(int, for_kupdate)
+		__field(int, range_cyclic)
+		__field(int, for_background)
+	),
+	TP_fast_assign(
+		strncpy(__entry->name, dev_name(bdi->dev), 32);
+		__entry->nr_pages = work->nr_pages;
+		__entry->sb_dev = work->sb ? work->sb->s_dev : 0;
+		__entry->sync_mode = work->sync_mode;
+		__entry->for_kupdate = work->for_kupdate;
+		__entry->range_cyclic = work->range_cyclic;
+		__entry->for_background	= work->for_background;
+	),
+	TP_printk("bdi %s: sb_dev %d:%d nr_pages=%ld sync_mode=%d "
+		  "kupdate=%d range_cyclic=%d background=%d",
+		  __entry->name,
+		  MAJOR(__entry->sb_dev), MINOR(__entry->sb_dev),
+		  __entry->nr_pages,
+		  __entry->sync_mode,
+		  __entry->for_kupdate,
+		  __entry->range_cyclic,
+		  __entry->for_background
+	)
+);
+#define DEFINE_WRITEBACK_WORK_EVENT(name) \
+DEFINE_EVENT(writeback_work_class, name, \
+	TP_PROTO(struct backing_dev_info *bdi, struct wb_writeback_work *work), \
+	TP_ARGS(bdi, work))
+DEFINE_WRITEBACK_WORK_EVENT(writeback_nothread);
+DEFINE_WRITEBACK_WORK_EVENT(writeback_queue);
+DEFINE_WRITEBACK_WORK_EVENT(writeback_exec);
+
+TRACE_EVENT(writeback_pages_written,
+	TP_PROTO(long pages_written),
+	TP_ARGS(pages_written),
+	TP_STRUCT__entry(
+		__field(long,		pages)
+	),
+	TP_fast_assign(
+		__entry->pages		= pages_written;
+	),
+	TP_printk("%ld", __entry->pages)
+);
+
+DECLARE_EVENT_CLASS(writeback_class,
+	TP_PROTO(struct backing_dev_info *bdi),
+	TP_ARGS(bdi),
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+	),
+	TP_fast_assign(
+		strncpy(__entry->name, dev_name(bdi->dev), 32);
+	),
+	TP_printk("bdi %s",
+		  __entry->name
+	)
+);
+#define DEFINE_WRITEBACK_EVENT(name) \
+DEFINE_EVENT(writeback_class, name, \
+	TP_PROTO(struct backing_dev_info *bdi), \
+	TP_ARGS(bdi))
+
+DEFINE_WRITEBACK_EVENT(writeback_nowork);
+DEFINE_WRITEBACK_EVENT(writeback_bdi_register);
+DEFINE_WRITEBACK_EVENT(writeback_bdi_unregister);
+DEFINE_WRITEBACK_EVENT(writeback_thread_start);
+DEFINE_WRITEBACK_EVENT(writeback_thread_stop);
+
+DECLARE_EVENT_CLASS(wbc_class,
+	TP_PROTO(struct writeback_control *wbc, struct backing_dev_info *bdi),
+	TP_ARGS(wbc, bdi),
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(long, nr_to_write)
+		__field(long, pages_skipped)
+		__field(int, sync_mode)
+		__field(int, nonblocking)
+		__field(int, encountered_congestion)
+		__field(int, for_kupdate)
+		__field(int, for_background)
+		__field(int, for_reclaim)
+		__field(int, range_cyclic)
+		__field(int, more_io)
+		__field(unsigned long, older_than_this)
+		__field(long, range_start)
+		__field(long, range_end)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name, dev_name(bdi->dev), 32);
+		__entry->nr_to_write	= wbc->nr_to_write;
+		__entry->pages_skipped	= wbc->pages_skipped;
+		__entry->sync_mode	= wbc->sync_mode;
+		__entry->for_kupdate	= wbc->for_kupdate;
+		__entry->for_background	= wbc->for_background;
+		__entry->for_reclaim	= wbc->for_reclaim;
+		__entry->range_cyclic	= wbc->range_cyclic;
+		__entry->more_io	= wbc->more_io;
+		__entry->older_than_this = wbc->older_than_this ?
+						*wbc->older_than_this : 0;
+		__entry->range_start	= (long)wbc->range_start;
+		__entry->range_end	= (long)wbc->range_end;
+	),
+
+	TP_printk("bdi %s: towrt=%ld skip=%ld mode=%d kupd=%d "
+		"bgrd=%d reclm=%d cyclic=%d more=%d older=0x%lx "
+		"start=0x%lx end=0x%lx",
+		__entry->name,
+		__entry->nr_to_write,
+		__entry->pages_skipped,
+		__entry->sync_mode,
+		__entry->for_kupdate,
+		__entry->for_background,
+		__entry->for_reclaim,
+		__entry->range_cyclic,
+		__entry->more_io,
+		__entry->older_than_this,
+		__entry->range_start,
+		__entry->range_end)
+)
+
+#define DEFINE_WBC_EVENT(name) \
+DEFINE_EVENT(wbc_class, name, \
+	TP_PROTO(struct writeback_control *wbc, struct backing_dev_info *bdi), \
+	TP_ARGS(wbc, bdi))
+DEFINE_WBC_EVENT(wbc_writeback_start);
+DEFINE_WBC_EVENT(wbc_writeback_written);
+DEFINE_WBC_EVENT(wbc_writeback_wait);
+DEFINE_WBC_EVENT(wbc_balance_dirty_start);
+DEFINE_WBC_EVENT(wbc_balance_dirty_written);
+DEFINE_WBC_EVENT(wbc_balance_dirty_wait);
+
+#endif /* _TRACE_WRITEBACK_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 123bcef..ac78a33 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -10,6 +10,7 @@
 #include <linux/module.h>
 #include <linux/writeback.h>
 #include <linux/device.h>
+#include <trace/events/writeback.h>
 
 static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
 
@@ -65,28 +66,21 @@ static void bdi_debug_init(void)
 static int bdi_debug_stats_show(struct seq_file *m, void *v)
 {
 	struct backing_dev_info *bdi = m->private;
-	struct bdi_writeback *wb;
+	struct bdi_writeback *wb = &bdi->wb;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
 	unsigned long nr_dirty, nr_io, nr_more_io, nr_wb;
 	struct inode *inode;
 
-	/*
-	 * inode lock is enough here, the bdi->wb_list is protected by
-	 * RCU on the reader side
-	 */
 	nr_wb = nr_dirty = nr_io = nr_more_io = 0;
 	spin_lock(&inode_lock);
-	list_for_each_entry(wb, &bdi->wb_list, list) {
-		nr_wb++;
-		list_for_each_entry(inode, &wb->b_dirty, i_list)
-			nr_dirty++;
-		list_for_each_entry(inode, &wb->b_io, i_list)
-			nr_io++;
-		list_for_each_entry(inode, &wb->b_more_io, i_list)
-			nr_more_io++;
-	}
+	list_for_each_entry(inode, &wb->b_dirty, i_list)
+		nr_dirty++;
+	list_for_each_entry(inode, &wb->b_io, i_list)
+		nr_io++;
+	list_for_each_entry(inode, &wb->b_more_io, i_list)
+		nr_more_io++;
 	spin_unlock(&inode_lock);
 
 	get_dirty_limits(&background_thresh, &dirty_thresh, &bdi_thresh, bdi);
@@ -98,19 +92,16 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BdiDirtyThresh:   %8lu kB\n"
 		   "DirtyThresh:      %8lu kB\n"
 		   "BackgroundThresh: %8lu kB\n"
-		   "WritebackThreads: %8lu\n"
 		   "b_dirty:          %8lu\n"
 		   "b_io:             %8lu\n"
 		   "b_more_io:        %8lu\n"
 		   "bdi_list:         %8u\n"
-		   "state:            %8lx\n"
-		   "wb_list:          %8u\n",
+		   "state:            %8lx\n",
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
 		   K(bdi_thresh), K(dirty_thresh),
-		   K(background_thresh), nr_wb, nr_dirty, nr_io, nr_more_io,
-		   !list_empty(&bdi->bdi_list), bdi->state,
-		   !list_empty(&bdi->wb_list));
+		   K(background_thresh), nr_dirty, nr_io, nr_more_io,
+		   !list_empty(&bdi->bdi_list), bdi->state);
 #undef K
 
 	return 0;
@@ -270,66 +261,6 @@ static void bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
 	INIT_LIST_HEAD(&wb->b_more_io);
 }
 
-static void bdi_task_init(struct backing_dev_info *bdi,
-			  struct bdi_writeback *wb)
-{
-	struct task_struct *tsk = current;
-
-	spin_lock(&bdi->wb_lock);
-	list_add_tail_rcu(&wb->list, &bdi->wb_list);
-	spin_unlock(&bdi->wb_lock);
-
-	tsk->flags |= PF_FLUSHER | PF_SWAPWRITE;
-	set_freezable();
-
-	/*
-	 * Our parent may run at a different priority, just set us to normal
-	 */
-	set_user_nice(tsk, 0);
-}
-
-static int bdi_start_fn(void *ptr)
-{
-	struct bdi_writeback *wb = ptr;
-	struct backing_dev_info *bdi = wb->bdi;
-	int ret;
-
-	/*
-	 * Add us to the active bdi_list
-	 */
-	spin_lock_bh(&bdi_lock);
-	list_add_rcu(&bdi->bdi_list, &bdi_list);
-	spin_unlock_bh(&bdi_lock);
-
-	bdi_task_init(bdi, wb);
-
-	/*
-	 * Clear pending bit and wakeup anybody waiting to tear us down
-	 */
-	clear_bit(BDI_pending, &bdi->state);
-	smp_mb__after_clear_bit();
-	wake_up_bit(&bdi->state, BDI_pending);
-
-	ret = bdi_writeback_task(wb);
-
-	/*
-	 * Remove us from the list
-	 */
-	spin_lock(&bdi->wb_lock);
-	list_del_rcu(&wb->list);
-	spin_unlock(&bdi->wb_lock);
-
-	/*
-	 * Flush any work that raced with us exiting. No new work
-	 * will be added, since this bdi isn't discoverable anymore.
-	 */
-	if (!list_empty(&bdi->work_list))
-		wb_do_writeback(wb, 1);
-
-	wb->task = NULL;
-	return ret;
-}
-
 int bdi_has_dirty_io(struct backing_dev_info *bdi)
 {
 	return wb_has_dirty_io(&bdi->wb);
@@ -391,7 +322,13 @@ static int bdi_forker_task(void *ptr)
 {
 	struct bdi_writeback *me = ptr;
 
-	bdi_task_init(me->bdi, me);
+	current->flags |= PF_FLUSHER | PF_SWAPWRITE;
+	set_freezable();
+
+	/*
+	 * Our parent may run at a different priority, just set us to normal
+	 */
+	set_user_nice(current, 0);
 
 	for (;;) {
 		struct backing_dev_info *bdi, *tmp;
@@ -447,7 +384,7 @@ static int bdi_forker_task(void *ptr)
 		spin_unlock_bh(&bdi_lock);
 
 		wb = &bdi->wb;
-		wb->task = kthread_run(bdi_start_fn, wb, "flush-%s",
+		wb->task = kthread_run(bdi_writeback_thread, wb, "flush-%s",
 					dev_name(bdi->dev));
 		/*
 		 * If task creation fails, then readd the bdi to
@@ -582,6 +519,7 @@ int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 
 	bdi_debug_register(bdi, dev_name(dev));
 	set_bit(BDI_registered, &bdi->state);
+	trace_writeback_bdi_register(bdi);
 exit:
 	return ret;
 }
@@ -598,8 +536,6 @@ EXPORT_SYMBOL(bdi_register_dev);
  */
 static void bdi_wb_shutdown(struct backing_dev_info *bdi)
 {
-	struct bdi_writeback *wb;
-
 	if (!bdi_cap_writeback_dirty(bdi))
 		return;
 
@@ -615,14 +551,14 @@ static void bdi_wb_shutdown(struct backing_dev_info *bdi)
 	bdi_remove_from_list(bdi);
 
 	/*
-	 * Finally, kill the kernel threads. We don't need to be RCU
+	 * Finally, kill the kernel thread. We don't need to be RCU
 	 * safe anymore, since the bdi is gone from visibility. Force
 	 * unfreeze of the thread before calling kthread_stop(), otherwise
 	 * it would never exet if it is currently stuck in the refrigerator.
 	 */
-	list_for_each_entry(wb, &bdi->wb_list, list) {
-		thaw_process(wb->task);
-		kthread_stop(wb->task);
+	if (bdi->wb.task) {
+		thaw_process(bdi->wb.task);
+		kthread_stop(bdi->wb.task);
 	}
 }
 
@@ -644,6 +580,7 @@ static void bdi_prune_sb(struct backing_dev_info *bdi)
 void bdi_unregister(struct backing_dev_info *bdi)
 {
 	if (bdi->dev) {
+		trace_writeback_bdi_unregister(bdi);
 		bdi_prune_sb(bdi);
 
 		if (!bdi_cap_flush_forker(bdi))
@@ -667,7 +604,6 @@ int bdi_init(struct backing_dev_info *bdi)
 	spin_lock_init(&bdi->wb_lock);
 	INIT_RCU_HEAD(&bdi->rcu_head);
 	INIT_LIST_HEAD(&bdi->bdi_list);
-	INIT_LIST_HEAD(&bdi->wb_list);
 	INIT_LIST_HEAD(&bdi->work_list);
 
 	bdi_wb_init(&bdi->wb, bdi);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 37498ef..d556cd8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -34,6 +34,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
+#include <trace/events/writeback.h>
 
 /*
  * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
@@ -535,11 +536,13 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * threshold otherwise wait until the disk writes catch
 		 * up.
 		 */
+		trace_wbc_balance_dirty_start(&wbc, bdi);
 		if (bdi_nr_reclaimable > bdi_thresh) {
 			writeback_inodes_wb(&bdi->wb, &wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
 			get_dirty_limits(&background_thresh, &dirty_thresh,
 				       &bdi_thresh, bdi);
+			trace_wbc_balance_dirty_written(&wbc, bdi);
 		}
 
 		/*
@@ -565,6 +568,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		if (pages_written >= write_chunk)
 			break;		/* We've done our duty */
 
+		trace_wbc_balance_dirty_wait(&wbc, bdi);
 		__set_current_state(TASK_INTERRUPTIBLE);
 		io_schedule_timeout(pause);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
