Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id C74C86B00B5
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:00:04 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so14949642qgd.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:04 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id u6si5132921qhd.83.2015.04.06.12.59.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 12:59:43 -0700 (PDT)
Received: by qgdy78 with SMTP id y78so14944236qgd.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:43 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 30/49] writeback: implement WB_has_dirty_io wb_state flag
Date: Mon,  6 Apr 2015 15:58:19 -0400
Message-Id: <1428350318-8215-31-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Currently, wb_has_dirty_io() determines whether a wb (bdi_writeback)
has any dirty inode by testing all three IO lists on each invocation
without actively keeping track.  For cgroup writeback support, a
single bdi will host multiple wb's each of which will host dirty
inodes separately and we'll need to make bdi_has_dirty_io(), which
currently only represents the root wb, aggregate has_dirty_io from all
member wb's, which requires tracking transitions in has_dirty_io state
on each wb.

This patch introduces inode_wb_list_{move|del}_locked() to consolidate
IO list operations leaving queue_io() the only other function which
directly manipulates IO lists (via move_expired_inodes()).  All three
functions are updated to call wb_io_lists_[de]populated() which keep
track of whether the wb has dirty inodes or not and record it using
the new WB_has_dirty_io flag.  inode_wb_list_moved_locked()'s return
value indicates whether the wb had no dirty inodes before.

mark_inode_dirty() is restructured so that the return value of
inode_wb_list_move_locked() can be used for deciding whether to wake
up the wb.

While at it, change {bdi|wb}_has_dirty_io()'s return values to bool.
These functions were returning 0 and 1 before.  Also, add a comment
explaining the synchronization of wb_state flags.

v2: Updated to accommodate b_dirty_time.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 104 ++++++++++++++++++++++++++++++---------
 include/linux/backing-dev-defs.h |   1 +
 include/linux/backing-dev.h      |   8 ++-
 mm/backing-dev.c                 |   2 +-
 4 files changed, 86 insertions(+), 29 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1d30249..29b4f8f 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -81,6 +81,66 @@ static inline struct inode *wb_inode(struct list_head *head)
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(wbc_writepage);
 
+static bool wb_io_lists_populated(struct bdi_writeback *wb)
+{
+	if (wb_has_dirty_io(wb)) {
+		return false;
+	} else {
+		set_bit(WB_has_dirty_io, &wb->state);
+		return true;
+	}
+}
+
+static void wb_io_lists_depopulated(struct bdi_writeback *wb)
+{
+	if (wb_has_dirty_io(wb) && list_empty(&wb->b_dirty) &&
+	    list_empty(&wb->b_io) && list_empty(&wb->b_more_io))
+		clear_bit(WB_has_dirty_io, &wb->state);
+}
+
+/**
+ * inode_wb_list_move_locked - move an inode onto a bdi_writeback IO list
+ * @inode: inode to be moved
+ * @wb: target bdi_writeback
+ * @head: one of @wb->b_{dirty|io|more_io}
+ *
+ * Move @inode->i_wb_list to @list of @wb and set %WB_has_dirty_io.
+ * Returns %true if @inode is the first occupant of the !dirty_time IO
+ * lists; otherwise, %false.
+ */
+static bool inode_wb_list_move_locked(struct inode *inode,
+				      struct bdi_writeback *wb,
+				      struct list_head *head)
+{
+	assert_spin_locked(&wb->list_lock);
+
+	list_move(&inode->i_wb_list, head);
+
+	/* dirty_time doesn't count as dirty_io until expiration */
+	if (head != &wb->b_dirty_time)
+		return wb_io_lists_populated(wb);
+
+	wb_io_lists_depopulated(wb);
+	return false;
+}
+
+/**
+ * inode_wb_list_del_locked - remove an inode from its bdi_writeback IO list
+ * @inode: inode to be removed
+ * @wb: bdi_writeback @inode is being removed from
+ *
+ * Remove @inode which may be on one of @wb->b_{dirty|io|more_io} lists and
+ * clear %WB_has_dirty_io if all are empty afterwards.
+ */
+static void inode_wb_list_del_locked(struct inode *inode,
+				     struct bdi_writeback *wb)
+{
+	assert_spin_locked(&wb->list_lock);
+
+	list_del_init(&inode->i_wb_list);
+	wb_io_lists_depopulated(wb);
+}
+
 static void wb_wakeup(struct bdi_writeback *wb)
 {
 	spin_lock_bh(&wb->work_lock);
@@ -205,7 +265,7 @@ void inode_wb_list_del(struct inode *inode)
 	struct bdi_writeback *wb = inode_to_wb(inode);
 
 	spin_lock(&wb->list_lock);
-	list_del_init(&inode->i_wb_list);
+	inode_wb_list_del_locked(inode, wb);
 	spin_unlock(&wb->list_lock);
 }
 
@@ -220,7 +280,6 @@ void inode_wb_list_del(struct inode *inode)
  */
 static void redirty_tail(struct inode *inode, struct bdi_writeback *wb)
 {
-	assert_spin_locked(&wb->list_lock);
 	if (!list_empty(&wb->b_dirty)) {
 		struct inode *tail;
 
@@ -228,7 +287,7 @@ static void redirty_tail(struct inode *inode, struct bdi_writeback *wb)
 		if (time_before(inode->dirtied_when, tail->dirtied_when))
 			inode->dirtied_when = jiffies;
 	}
-	list_move(&inode->i_wb_list, &wb->b_dirty);
+	inode_wb_list_move_locked(inode, wb, &wb->b_dirty);
 }
 
 /*
@@ -236,8 +295,7 @@ static void redirty_tail(struct inode *inode, struct bdi_writeback *wb)
  */
 static void requeue_io(struct inode *inode, struct bdi_writeback *wb)
 {
-	assert_spin_locked(&wb->list_lock);
-	list_move(&inode->i_wb_list, &wb->b_more_io);
+	inode_wb_list_move_locked(inode, wb, &wb->b_more_io);
 }
 
 static void inode_sync_complete(struct inode *inode)
@@ -346,6 +404,8 @@ static void queue_io(struct bdi_writeback *wb, struct wb_writeback_work *work)
 	moved = move_expired_inodes(&wb->b_dirty, &wb->b_io, 0, work);
 	moved += move_expired_inodes(&wb->b_dirty_time, &wb->b_io,
 				     EXPIRE_DIRTY_ATIME, work);
+	if (moved)
+		wb_io_lists_populated(wb);
 	trace_writeback_queue_io(wb, work, moved);
 }
 
@@ -470,10 +530,10 @@ static void requeue_inode(struct inode *inode, struct bdi_writeback *wb,
 		 */
 		redirty_tail(inode, wb);
 	} else if (inode->i_state & I_DIRTY_TIME) {
-		list_move(&inode->i_wb_list, &wb->b_dirty_time);
+		inode_wb_list_move_locked(inode, wb, &wb->b_dirty_time);
 	} else {
 		/* The inode is clean. Remove from writeback lists. */
-		list_del_init(&inode->i_wb_list);
+		inode_wb_list_del_locked(inode, wb);
 	}
 }
 
@@ -610,7 +670,7 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	 * touch it. See comment above for explanation.
 	 */
 	if (!(inode->i_state & I_DIRTY_ALL))
-		list_del_init(&inode->i_wb_list);
+		inode_wb_list_del_locked(inode, wb);
 	spin_unlock(&wb->list_lock);
 	inode_sync_complete(inode);
 out:
@@ -1264,27 +1324,25 @@ void __mark_inode_dirty(struct inode *inode, int flags)
 
 			spin_unlock(&inode->i_lock);
 			spin_lock(&bdi->wb.list_lock);
-			if (bdi_cap_writeback_dirty(bdi)) {
-				WARN(!test_bit(WB_registered, &bdi->wb.state),
-				     "bdi-%s not registered\n", bdi->name);
 
-				/*
-				 * If this is the first dirty inode for this
-				 * bdi, we have to wake-up the corresponding
-				 * bdi thread to make sure background
-				 * write-back happens later.
-				 */
-				if (!wb_has_dirty_io(&bdi->wb))
-					wakeup_bdi = true;
-			}
+			WARN(bdi_cap_writeback_dirty(bdi) &&
+			     !test_bit(WB_registered, &bdi->wb.state),
+			     "bdi-%s not registered\n", bdi->name);
 
 			inode->dirtied_when = jiffies;
-			list_move(&inode->i_wb_list, dirtytime ?
-				  &bdi->wb.b_dirty_time : &bdi->wb.b_dirty);
+			wakeup_bdi = inode_wb_list_move_locked(inode, &bdi->wb,
+					dirtytime ? &bdi->wb.b_dirty_time :
+						    &bdi->wb.b_dirty);
 			spin_unlock(&bdi->wb.list_lock);
 			trace_writeback_dirty_inode_enqueue(inode);
 
-			if (wakeup_bdi)
+			/*
+			 * If this is the first dirty inode for this bdi,
+			 * we have to wake-up the corresponding bdi thread
+			 * to make sure background write-back happens
+			 * later.
+			 */
+			if (bdi_cap_writeback_dirty(bdi) && wakeup_bdi)
 				wb_wakeup_delayed(&bdi->wb);
 			return;
 		}
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index eb38676..7a94b78 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -21,6 +21,7 @@ struct dentry;
 enum wb_state {
 	WB_registered,		/* bdi_register() was done */
 	WB_writeback_running,	/* Writeback is in progress */
+	WB_has_dirty_io,	/* Dirty inodes on ->b_{dirty|io|more_io} */
 };
 
 enum wb_congested_state {
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 6f08821..3c8403c 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -29,7 +29,7 @@ void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 			enum wb_reason reason);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
 void wb_workfn(struct work_struct *work);
-int bdi_has_dirty_io(struct backing_dev_info *bdi);
+bool bdi_has_dirty_io(struct backing_dev_info *bdi);
 void wb_wakeup_delayed(struct bdi_writeback *wb);
 
 extern spinlock_t bdi_lock;
@@ -37,11 +37,9 @@ extern struct list_head bdi_list;
 
 extern struct workqueue_struct *bdi_wq;
 
-static inline int wb_has_dirty_io(struct bdi_writeback *wb)
+static inline bool wb_has_dirty_io(struct bdi_writeback *wb)
 {
-	return !list_empty(&wb->b_dirty) ||
-	       !list_empty(&wb->b_io) ||
-	       !list_empty(&wb->b_more_io);
+	return test_bit(WB_has_dirty_io, &wb->state);
 }
 
 static inline void __add_wb_stat(struct bdi_writeback *wb,
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 5029c4a..161ddf1 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -256,7 +256,7 @@ static int __init default_bdi_init(void)
 }
 subsys_initcall(default_bdi_init);
 
-int bdi_has_dirty_io(struct backing_dev_info *bdi)
+bool bdi_has_dirty_io(struct backing_dev_info *bdi)
 {
 	return wb_has_dirty_io(&bdi->wb);
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
