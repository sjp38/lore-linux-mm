Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4361A6B015F
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:25 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id f51so57426qge.36
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:25 -0800 (PST)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id n52si65701882qge.91.2015.01.06.13.27.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:24 -0800 (PST)
Received: by mail-qc0-f169.google.com with SMTP id w7so81714qcr.0
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:24 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 30/45] vfs, writeback: introduce struct inode_wb_link
Date: Tue,  6 Jan 2015 16:26:07 -0500
Message-Id: <1420579582-8516-31-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

An inode may be written to from more than one cgroups and for cgroup
writeback support to work properly the inode needs to be on the dirty
lists of all wb's (bdi_writeback's) corresponding to the dirtying
cgroups so that writeback on each cgroup can keep track of and process
the inode.

As the first step on enabling linking an inode on multiple wb's, this
patch introduces struct inode_wb_link, which represents the
association between an inode and a wb, and replaces inode->i_wb_list
with ->i_wb_link of this type.

struct inode_wb_link currently contains only struct list_head and the
conversions are mostly equivalent and of trivial nature.  The only
difference at this point is that some functions are converted to take
the pointer to inode->i_wb_link instead of inode and use
container_of() to recover the inode.

Later patches will expand inode_wb_link and its handling to support
linking on multiple wb's.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 104 ++++++++++++++++++++++-----------------
 fs/inode.c                       |   2 +-
 include/linux/backing-dev-defs.h |   8 +++
 include/linux/backing-dev.h      |   5 ++
 include/linux/fs.h               |   2 +-
 mm/backing-dev.c                 |   6 +--
 6 files changed, 78 insertions(+), 49 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 0fcdfe9..0a10dd8 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -72,9 +72,9 @@ struct wb_writeback_work {
 		.cnt		= ATOMIC_INIT(1),			\
 	}
 
-static inline struct inode *wb_inode(struct list_head *head)
+static struct inode_wb_link *dirty_list_to_iwbl(struct list_head *head)
 {
-	return list_entry(head, struct inode, i_wb_list);
+	return list_entry(head, struct inode_wb_link, dirty_list);
 }
 
 /*
@@ -452,21 +452,20 @@ void wb_start_background_writeback(struct bdi_writeback *wb)
 }
 
 /**
- * inode_wb_list_move_locked - move an inode onto a bdi_writeback IO list
- * @inode: inode to be moved
+ * iwbl_move_locked - move an inode_wb_link onto a bdi_writeback IO list
+ * @iwbl: inode_wb_link to be moved
  * @wb: target bdi_writeback
  * @head: one of @wb->b_{dirty|io|more_io}
  *
- * Move @inode->i_wb_list to @list of @wb and set %WB_has_dirty_io.
+ * Move @iwbl->dirty_list to @list of @wb and set %WB_has_dirty_io.
  * Returns %true if all IO lists were empty before; otherwise, %false.
  */
-static bool inode_wb_list_move_locked(struct inode *inode,
-				      struct bdi_writeback *wb,
-				      struct list_head *head)
+static bool iwbl_move_locked(struct inode_wb_link *iwbl,
+			     struct bdi_writeback *wb, struct list_head *head)
 {
 	assert_spin_locked(&wb->list_lock);
 
-	list_move(&inode->i_wb_list, head);
+	list_move(&iwbl->dirty_list, head);
 
 	if (wb_has_dirty_io(wb)) {
 		return false;
@@ -480,19 +479,19 @@ static bool inode_wb_list_move_locked(struct inode *inode,
 }
 
 /**
- * inode_wb_list_del_locked - remove an inode from its bdi_writeback IO list
- * @inode: inode to be removed
+ * iwbl_del_locked - remove an inode_wb_link from its bdi_writeback IO list
+ * @iwbl: inode_wb_link to be removed
  * @wb: bdi_writeback @inode is being removed from
  *
- * Remove @inode which may be on one of @wb->b_{dirty|io|more_io} lists and
+ * Remove @iwbl which may be on one of @wb->b_{dirty|io|more_io} lists and
  * clear %WB_has_dirty_io if all are empty afterwards.
  */
-static void inode_wb_list_del_locked(struct inode *inode,
-				     struct bdi_writeback *wb)
+static void iwbl_del_locked(struct inode_wb_link *iwbl,
+			    struct bdi_writeback *wb)
 {
 	assert_spin_locked(&wb->list_lock);
 
-	list_del_init(&inode->i_wb_list);
+	list_del_init(&iwbl->dirty_list);
 
 	if (wb_has_dirty_io(wb) && list_empty(&wb->b_dirty) &&
 	    list_empty(&wb->b_io) && list_empty(&wb->b_more_io)) {
@@ -507,14 +506,15 @@ static void inode_wb_list_del_locked(struct inode *inode,
  */
 void inode_wb_list_del(struct inode *inode)
 {
+	struct inode_wb_link *iwbl = &inode->i_wb_link;
 	struct backing_dev_info *bdi = inode_to_bdi(inode);
 	struct bdi_writeback *wb = &bdi->wb;
 
-	if (list_empty(&inode->i_wb_list))
+	if (list_empty(&iwbl->dirty_list))
 		return;
 
 	spin_lock(&wb->list_lock);
-	inode_wb_list_del_locked(inode, wb);
+	iwbl_del_locked(iwbl, wb);
 	spin_unlock(&wb->list_lock);
 }
 
@@ -527,24 +527,28 @@ void inode_wb_list_del(struct inode *inode)
  * the case then the inode must have been redirtied while it was being written
  * out and we don't reset its dirtied_when.
  */
-static void redirty_tail(struct inode *inode, struct bdi_writeback *wb)
+static void redirty_tail(struct inode_wb_link *iwbl, struct bdi_writeback *wb)
 {
+	struct inode *inode = iwbl_to_inode(iwbl);
+
 	if (!list_empty(&wb->b_dirty)) {
+		struct inode_wb_link *tail_iwbl;
 		struct inode *tail;
 
-		tail = wb_inode(wb->b_dirty.next);
+		tail_iwbl = dirty_list_to_iwbl(wb->b_dirty.next);
+		tail = iwbl_to_inode(tail_iwbl);
 		if (time_before(inode->dirtied_when, tail->dirtied_when))
 			inode->dirtied_when = jiffies;
 	}
-	inode_wb_list_move_locked(inode, wb, &wb->b_dirty);
+	iwbl_move_locked(iwbl, wb, &wb->b_dirty);
 }
 
 /*
  * requeue inode for re-scanning after bdi->b_io list is exhausted.
  */
-static void requeue_io(struct inode *inode, struct bdi_writeback *wb)
+static void requeue_io(struct inode_wb_link *iwbl, struct bdi_writeback *wb)
 {
-	inode_wb_list_move_locked(inode, wb, &wb->b_more_io);
+	iwbl_move_locked(iwbl, wb, &wb->b_more_io);
 }
 
 static void inode_sync_complete(struct inode *inode)
@@ -583,16 +587,19 @@ static int move_expired_inodes(struct list_head *delaying_queue,
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
+	struct inode_wb_link *iwbl;
 	struct inode *inode;
 	int do_sb_sort = 0;
 	int moved = 0;
 
 	while (!list_empty(delaying_queue)) {
-		inode = wb_inode(delaying_queue->prev);
+		iwbl = dirty_list_to_iwbl(delaying_queue->prev);
+		inode = iwbl_to_inode(iwbl);
+
 		if (work->older_than_this &&
 		    inode_dirtied_after(inode, *work->older_than_this))
 			break;
-		list_move(&inode->i_wb_list, &tmp);
+		list_move(&iwbl->dirty_list, &tmp);
 		moved++;
 		if (sb_is_blkdev_sb(inode->i_sb))
 			continue;
@@ -609,11 +616,12 @@ static int move_expired_inodes(struct list_head *delaying_queue,
 
 	/* Move inodes from one superblock together */
 	while (!list_empty(&tmp)) {
-		sb = wb_inode(tmp.prev)->i_sb;
+		sb = iwbl_to_inode(dirty_list_to_iwbl(tmp.prev))->i_sb;
 		list_for_each_prev_safe(pos, node, &tmp) {
-			inode = wb_inode(pos);
+			iwbl = dirty_list_to_iwbl(pos);
+			inode = iwbl_to_inode(iwbl);
 			if (inode->i_sb == sb)
-				list_move(&inode->i_wb_list, dispatch_queue);
+				list_move(&iwbl->dirty_list, dispatch_queue);
 		}
 	}
 out:
@@ -711,9 +719,11 @@ static void inode_sleep_on_writeback(struct inode *inode)
  * processes all inodes in writeback lists and requeueing inodes behind flusher
  * thread's back can have unexpected consequences.
  */
-static void requeue_inode(struct inode *inode, struct bdi_writeback *wb,
+static void requeue_inode(struct inode_wb_link *iwbl, struct bdi_writeback *wb,
 			  struct writeback_control *wbc)
 {
+	struct inode *inode = iwbl_to_inode(iwbl);
+
 	if (inode->i_state & I_FREEING)
 		return;
 
@@ -731,7 +741,7 @@ static void requeue_inode(struct inode *inode, struct bdi_writeback *wb,
 		 * writeback is not making progress due to locked
 		 * buffers. Skip this inode for now.
 		 */
-		redirty_tail(inode, wb);
+		redirty_tail(iwbl, wb);
 		return;
 	}
 
@@ -742,7 +752,7 @@ static void requeue_inode(struct inode *inode, struct bdi_writeback *wb,
 		 */
 		if (wbc->nr_to_write <= 0) {
 			/* Slice used up. Queue for next turn. */
-			requeue_io(inode, wb);
+			requeue_io(iwbl, wb);
 		} else {
 			/*
 			 * Writeback blocked by something other than
@@ -751,7 +761,7 @@ static void requeue_inode(struct inode *inode, struct bdi_writeback *wb,
 			 * retrying writeback of the dirty page/inode
 			 * that cannot be performed immediately.
 			 */
-			redirty_tail(inode, wb);
+			redirty_tail(iwbl, wb);
 		}
 	} else if (inode->i_state & I_DIRTY) {
 		/*
@@ -759,10 +769,10 @@ static void requeue_inode(struct inode *inode, struct bdi_writeback *wb,
 		 * such as delayed allocation during submission or metadata
 		 * updates after data IO completion.
 		 */
-		redirty_tail(inode, wb);
+		redirty_tail(iwbl, wb);
 	} else {
 		/* The inode is clean. Remove from writeback lists. */
-		inode_wb_list_del_locked(inode, wb);
+		iwbl_del_locked(iwbl, wb);
 	}
 }
 
@@ -848,6 +858,7 @@ static int
 writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 		       struct writeback_control *wbc)
 {
+	struct inode_wb_link *iwbl = &inode->i_wb_link;
 	int ret = 0;
 
 	spin_lock(&inode->i_lock);
@@ -891,7 +902,7 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	 * touch it. See comment above for explanation.
 	 */
 	if (!(inode->i_state & I_DIRTY))
-		inode_wb_list_del_locked(inode, wb);
+		iwbl_del_locked(iwbl, wb);
 	spin_unlock(&wb->list_lock);
 	inode_sync_complete(inode);
 out:
@@ -954,7 +965,8 @@ static long writeback_sb_inodes(struct super_block *sb,
 	long wrote = 0;  /* count both pages and inodes */
 
 	while (!list_empty(&wb->b_io)) {
-		struct inode *inode = wb_inode(wb->b_io.prev);
+		struct inode_wb_link *iwbl = dirty_list_to_iwbl(wb->b_io.prev);
+		struct inode *inode = iwbl_to_inode(iwbl);
 
 		if (inode->i_sb != sb) {
 			if (work->sb) {
@@ -963,7 +975,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 				 * superblock, move all inodes not belonging
 				 * to it back onto the dirty list.
 				 */
-				redirty_tail(inode, wb);
+				redirty_tail(iwbl, wb);
 				continue;
 			}
 
@@ -983,7 +995,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 		spin_lock(&inode->i_lock);
 		if (inode->i_state & (I_NEW | I_FREEING | I_WILL_FREE)) {
 			spin_unlock(&inode->i_lock);
-			redirty_tail(inode, wb);
+			redirty_tail(iwbl, wb);
 			continue;
 		}
 		if ((inode->i_state & I_SYNC) && wbc.sync_mode != WB_SYNC_ALL) {
@@ -997,7 +1009,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 			 * when we completed a full scan of b_io.
 			 */
 			spin_unlock(&inode->i_lock);
-			requeue_io(inode, wb);
+			requeue_io(iwbl, wb);
 			trace_writeback_sb_inodes_requeue(inode);
 			continue;
 		}
@@ -1034,7 +1046,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 		spin_lock(&inode->i_lock);
 		if (!(inode->i_state & I_DIRTY))
 			wrote++;
-		requeue_inode(inode, wb, &wbc);
+		requeue_inode(iwbl, wb, &wbc);
 		inode_sync_complete(inode);
 		spin_unlock(&inode->i_lock);
 		cond_resched_lock(&wb->list_lock);
@@ -1059,7 +1071,8 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 	long wrote = 0;
 
 	while (!list_empty(&wb->b_io)) {
-		struct inode *inode = wb_inode(wb->b_io.prev);
+		struct inode_wb_link *iwbl = dirty_list_to_iwbl(wb->b_io.prev);
+		struct inode *inode = iwbl_to_inode(iwbl);
 		struct super_block *sb = inode->i_sb;
 
 		if (!grab_super_passive(sb)) {
@@ -1068,7 +1081,7 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 			 * s_umount being grabbed by someone else. Don't use
 			 * requeue_io() to avoid busy retrying the inode/sb.
 			 */
-			redirty_tail(inode, wb);
+			redirty_tail(iwbl, wb);
 			continue;
 		}
 		wrote += writeback_sb_inodes(sb, wb, work);
@@ -1152,6 +1165,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 	unsigned long wb_start = jiffies;
 	long nr_pages = work->nr_pages;
 	unsigned long oldest_jif;
+	struct inode_wb_link *iwbl;
 	struct inode *inode;
 	long progress;
 
@@ -1228,7 +1242,8 @@ static long wb_writeback(struct bdi_writeback *wb,
 		 */
 		if (!list_empty(&wb->b_more_io))  {
 			trace_writeback_wait(wb->bdi, work);
-			inode = wb_inode(wb->b_more_io.prev);
+			iwbl = dirty_list_to_iwbl(wb->b_more_io.prev);
+			inode = iwbl_to_inode(iwbl);
 			spin_lock(&inode->i_lock);
 			spin_unlock(&wb->list_lock);
 			/* This function drops i_lock... */
@@ -1514,6 +1529,7 @@ void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 
 	spin_lock(&inode->i_lock);
 	if ((inode->i_state & flags) != flags) {
+		struct inode_wb_link *iwbl = &inode->i_wb_link;
 		const int was_dirty = inode->i_state & I_DIRTY;
 
 		inode->i_state |= flags;
@@ -1553,8 +1569,8 @@ void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 			     "bdi-%s not registered\n", bdi->name);
 
 			inode->dirtied_when = jiffies;
-			wakeup_bdi = inode_wb_list_move_locked(inode, &bdi->wb,
-							      &bdi->wb.b_dirty);
+			wakeup_bdi = iwbl_move_locked(iwbl, &bdi->wb,
+						      &bdi->wb.b_dirty);
 			spin_unlock(&bdi->wb.list_lock);
 
 			/*
diff --git a/fs/inode.c b/fs/inode.c
index 7fbfc00..7ec49ad 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -369,7 +369,7 @@ void inode_init_once(struct inode *inode)
 	memset(inode, 0, sizeof(*inode));
 	INIT_HLIST_NODE(&inode->i_hash);
 	INIT_LIST_HEAD(&inode->i_devices);
-	INIT_LIST_HEAD(&inode->i_wb_list);
+	INIT_LIST_HEAD(&inode->i_wb_link.dirty_list);
 	INIT_LIST_HEAD(&inode->i_lru);
 	address_space_init_once(&inode->i_data);
 	i_size_ordered_init(inode);
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index bc1b9e7..8bc80bd 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -123,6 +123,14 @@ struct backing_dev_info {
 };
 
 /*
+ * Used to link a dirty inode on a wb (bdi_writeback).  Each inode embeds
+ * one at ->i_wb_link which is used for the root wb.
+ */
+struct inode_wb_link {
+	struct list_head	dirty_list;
+};
+
+/*
  * The following structure carries context used during page and inode
  * dirtying.  Should be initialized with init_dirty_{inode|page}_context().
  */
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 4cdab7c..6ced0f4 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -274,6 +274,11 @@ void init_dirty_page_context(struct dirty_context *dctx, struct page *page,
 			     struct address_space *mapping);
 void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode);
 
+static inline struct inode *iwbl_to_inode(struct inode_wb_link *iwbl)
+{
+	return container_of(iwbl, struct inode, i_wb_link);
+}
+
 #ifdef CONFIG_CGROUP_WRITEBACK
 
 void cgwb_blkcg_released(struct cgroup_subsys_state *blkcg_css);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2f3df6a..ea0b68f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -610,7 +610,7 @@ struct inode {
 	unsigned long		dirtied_when;	/* jiffies of first dirtying */
 
 	struct hlist_node	i_hash;
-	struct list_head	i_wb_list;	/* backing dev IO list */
+	struct inode_wb_link	i_wb_link;	/* backing dev IO list */
 	struct list_head	i_lru;		/* inode LRU list */
 	struct list_head	i_sb_list;
 	union {
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 171fffd..cc8d21a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -73,11 +73,11 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 
 	nr_dirty = nr_io = nr_more_io = 0;
 	spin_lock(&wb->list_lock);
-	list_for_each_entry(inode, &wb->b_dirty, i_wb_list)
+	list_for_each_entry(inode, &wb->b_dirty, i_wb_link.dirty_list)
 		nr_dirty++;
-	list_for_each_entry(inode, &wb->b_io, i_wb_list)
+	list_for_each_entry(inode, &wb->b_io, i_wb_link.dirty_list)
 		nr_io++;
-	list_for_each_entry(inode, &wb->b_more_io, i_wb_list)
+	list_for_each_entry(inode, &wb->b_more_io, i_wb_link.dirty_list)
 		nr_more_io++;
 	spin_unlock(&wb->list_lock);
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
