Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id CDA9F6B013D
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:53 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id k15so206123qaq.7
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:53 -0800 (PST)
Received: from mail-qa0-x22e.google.com (mail-qa0-x22e.google.com. [2607:f8b0:400d:c00::22e])
        by mx.google.com with ESMTPS id m8si2717742qay.103.2015.01.06.13.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:52 -0800 (PST)
Received: by mail-qa0-f46.google.com with SMTP id w8so219077qac.5
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:52 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 13/45] writeback: implement WB_has_dirty_io wb_state flag
Date: Tue,  6 Jan 2015 16:25:50 -0500
Message-Id: <1420579582-8516-14-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

Currently, wb_has_dirty_io() determines whether a wb (bdi_writeback)
has any dirty inode by testing all three IO lists on each invocation
without actively keeping track.  For cgroup writeback support, a
single bdi will host multiple wb's each of which will host dirty
inodes separately and we'll need to make bdi_has_dirty_io(), which
currently only represents the root wb, aggregate has_dirty_io from all
member wb's, which requires tracking transitions in has_dirty_io state
on each wb.

This patch adds inode_wb_list_move_locked() and
inode_wb_list_del_locked() replace direct inode->i_wb_list operations
with them.  In addition to the list operations, the two functions keep
track of whether the wb has dirty inodes or not and record it using
the new WB_has_dirty_io flag.  inode_wb_list_moved_locked()'s return
value indicates whether the wb had no dirty inodes before.

mark_inode_dirty_dctx() is restructured so that the return value of
inode_wb_list_move_locked() can be used for deciding whether to wake
up the wb.

While at it, change {bdi|wb}_has_dirty_io()'s return values to bool.
These functions were returning 0 and 1 before.  Also, add a comment
explaining the synchronization of wb_state flags.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 88 +++++++++++++++++++++++++++++-----------
 include/linux/backing-dev-defs.h |  8 ++++
 include/linux/backing-dev.h      |  8 ++--
 mm/backing-dev.c                 |  2 +-
 4 files changed, 77 insertions(+), 29 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 43c1fb2..1718f5f 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -291,16 +291,62 @@ void bdi_start_background_writeback(struct backing_dev_info *bdi)
 	wb_wakeup(&bdi->wb);
 }
 
+/**
+ * inode_wb_list_move_locked - move an inode onto a bdi_writeback IO list
+ * @inode: inode to be moved
+ * @wb: target bdi_writeback
+ * @head: one of @wb->b_{dirty|io|more_io}
+ *
+ * Move @inode->i_wb_list to @list of @wb and set %WB_has_dirty_io.
+ * Returns %true if all IO lists were empty before; otherwise, %false.
+ */
+static bool inode_wb_list_move_locked(struct inode *inode,
+				      struct bdi_writeback *wb,
+				      struct list_head *head)
+{
+	assert_spin_locked(&wb->list_lock);
+
+	list_move(&inode->i_wb_list, head);
+
+	if (wb_has_dirty_io(wb)) {
+		return false;
+	} else {
+		set_bit(WB_has_dirty_io, &wb->state);
+		return true;
+	}
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
+
+	if (wb_has_dirty_io(wb) && list_empty(&wb->b_dirty) &&
+	    list_empty(&wb->b_io) && list_empty(&wb->b_more_io))
+		clear_bit(WB_has_dirty_io, &wb->state);
+}
+
 /*
  * Remove the inode from the writeback list it is on.
  */
 void inode_wb_list_del(struct inode *inode)
 {
 	struct backing_dev_info *bdi = inode_to_bdi(inode);
+	struct bdi_writeback *wb = &bdi->wb;
 
-	spin_lock(&bdi->wb.list_lock);
-	list_del_init(&inode->i_wb_list);
-	spin_unlock(&bdi->wb.list_lock);
+	spin_lock(&wb->list_lock);
+	inode_wb_list_del_locked(inode, wb);
+	spin_unlock(&wb->list_lock);
 }
 
 /*
@@ -314,7 +360,6 @@ void inode_wb_list_del(struct inode *inode)
  */
 static void redirty_tail(struct inode *inode, struct bdi_writeback *wb)
 {
-	assert_spin_locked(&wb->list_lock);
 	if (!list_empty(&wb->b_dirty)) {
 		struct inode *tail;
 
@@ -322,7 +367,7 @@ static void redirty_tail(struct inode *inode, struct bdi_writeback *wb)
 		if (time_before(inode->dirtied_when, tail->dirtied_when))
 			inode->dirtied_when = jiffies;
 	}
-	list_move(&inode->i_wb_list, &wb->b_dirty);
+	inode_wb_list_move_locked(inode, wb, &wb->b_dirty);
 }
 
 /*
@@ -330,8 +375,7 @@ static void redirty_tail(struct inode *inode, struct bdi_writeback *wb)
  */
 static void requeue_io(struct inode *inode, struct bdi_writeback *wb)
 {
-	assert_spin_locked(&wb->list_lock);
-	list_move(&inode->i_wb_list, &wb->b_more_io);
+	inode_wb_list_move_locked(inode, wb, &wb->b_more_io);
 }
 
 static void inode_sync_complete(struct inode *inode)
@@ -549,7 +593,7 @@ static void requeue_inode(struct inode *inode, struct bdi_writeback *wb,
 		redirty_tail(inode, wb);
 	} else {
 		/* The inode is clean. Remove from writeback lists. */
-		list_del_init(&inode->i_wb_list);
+		inode_wb_list_del_locked(inode, wb);
 	}
 }
 
@@ -678,7 +722,7 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	 * touch it. See comment above for explanation.
 	 */
 	if (!(inode->i_state & I_DIRTY))
-		list_del_init(&inode->i_wb_list);
+		inode_wb_list_del_locked(inode, wb);
 	spin_unlock(&wb->list_lock);
 	inode_sync_complete(inode);
 out:
@@ -1319,25 +1363,23 @@ void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 
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
-			list_move(&inode->i_wb_list, &bdi->wb.b_dirty);
+			wakeup_bdi = inode_wb_list_move_locked(inode, &bdi->wb,
+							      &bdi->wb.b_dirty);
 			spin_unlock(&bdi->wb.list_lock);
 
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
index 54a3a9c..d1c0bf4 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -17,10 +17,18 @@ struct dentry;
  * Bits in bdi_writeback.state
  */
 enum wb_state {
+	/*
+	 * The two congested flags are modified asynchronously and must be
+	 * atomic.  The other flags are protected either by wb->list_lock
+	 * or ->work_lock and don't need to be atomic if placed on separate
+	 * fields.  The extra atomic operations don't really matter here.
+	 * Let's keep them together and use atomic bitops.
+	 */
 	WB_async_congested,	/* The async (write) queue is getting full */
 	WB_sync_congested,	/* The sync queue is getting full */
 	WB_registered,		/* bdi_register() was done */
 	WB_writeback_running,	/* Writeback is in progress */
+	WB_has_dirty_io,	/* Dirty inodes on ->b_{dirty|io|more_io} */
 };
 
 typedef int (congested_fn)(void *, int);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 0b1ac4b..533ff86 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -30,7 +30,7 @@ void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 			enum wb_reason reason);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
 void wb_workfn(struct work_struct *work);
-int bdi_has_dirty_io(struct backing_dev_info *bdi);
+bool bdi_has_dirty_io(struct backing_dev_info *bdi);
 void wb_wakeup_delayed(struct bdi_writeback *wb);
 
 extern spinlock_t bdi_lock;
@@ -38,11 +38,9 @@ extern struct list_head bdi_list;
 
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
index 2851278..9d69e7c 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -307,7 +307,7 @@ static int __init default_bdi_init(void)
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
