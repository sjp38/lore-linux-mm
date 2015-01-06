Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id BFD896B0169
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:33 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id i50so56130qgf.38
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:33 -0800 (PST)
Received: from mail-qc0-x236.google.com (mail-qc0-x236.google.com. [2607:f8b0:400d:c01::236])
        by mx.google.com with ESMTPS id d33si40541194qge.52.2015.01.06.13.27.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:33 -0800 (PST)
Received: by mail-qc0-f182.google.com with SMTP id r5so67196qcx.27
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:32 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 35/45] vfs, writeback: implement inode->i_nr_syncs
Date: Tue,  6 Jan 2015 16:26:12 -0500
Message-Id: <1420579582-8516-36-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

Currently, I_SYNC is used to keep track of whether writeback is in
progress on the inode or not.  With cgroup writeback support, multiple
writebacks could be in progress simultaneously and a single bit in
inode->i_state isn't sufficient.

If CONFIG_CGROUP_WRITEBACK, this patch makes each iwbl (inode_wb_link)
track whether writeback is in progress using the new IWBL_SYNC flag on
iwbl->data and inode->i_nr_syncs aggregate total number of writebacks
in progress on the inode.  New helpers, iwbl_{test|set|clear}_sync(),
iwbl_sync_wakeup() and __iwbl_wait_for_writeback() are added to
manipulate these states and inode_sleep_on_writeback() is converted to
iwbl_sleep_on_writeback().  I_SYNC retains the same meaning - it's set
if any writeback is in progress and cleared if none.

If !CONFIG_CGROUP_WRITEBACK, the helpers simply operate on I_SYNC
directly and there's no behavioral changes compared to before.  When
CONFIG_CGROUP_WRITEBACK, this adds an atomic_t to struct inode.  This
competes for the same left over 4 byte slot w/ i_readcount from
CONFIG_IMA on 64 bit, and, as long as CONFIG_IMA isn't enabled, it
doesn't increase the size of struct inode on 64 bit.

This allows keeping track of writeback in-progress state per cgroup
bdi_writeback.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 172 +++++++++++++++++++++++++++++++++------
 include/linux/backing-dev-defs.h |   7 ++
 include/linux/fs.h               |   3 +
 mm/backing-dev.c                 |   1 +
 4 files changed, 160 insertions(+), 23 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d10c231..df99b5b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -430,26 +430,113 @@ restart:
 	rcu_read_unlock();
 }
 
+/**
+ * iwbl_test_sync - test whether writeback is in progress on an inode_wb_link
+ * @iwbl: target inode_wb_link
+ *
+ * Test whether writeback is in progress for the inode on the bdi_writeback
+ * specified by @iwbl.  The caller is responsible for synchornization.
+ */
+static bool iwbl_test_sync(struct inode_wb_link *iwbl)
+{
+	return test_bit(IWBL_SYNC, &iwbl->data);
+}
+
+/**
+ * iwbl_set_sync - mark an inode_wb_link that writeback is in progress
+ * @iwbl: target inode_wb_link
+ * @inode: inode @iwbl is associated with
+ *
+ * Mark that writeback is in progress for @inode on the bdi_writeback
+ * specified by @iwbl.  iwbl_test_sync() will return %true on @iwbl and
+ * %I_SYNC is set on @inode while there's any writeback in progress on it.
+ */
+static void iwbl_set_sync(struct inode_wb_link *iwbl, struct inode *inode)
+{
+	lockdep_assert_held(&inode->i_lock);
+	WARN_ON_ONCE(iwbl_test_sync(iwbl));
+
+	set_bit(IWBL_SYNC, &iwbl->data);
+	inode->i_nr_syncs++;
+	inode->i_state |= I_SYNC;
+}
+
+/**
+ * iwbl_clear_sync - undo iwbl_set_sync()
+ * @iwbl: target inode_wb_link
+ * @inode: inode @iwbl is associated with
+ *
+ * Returns %true if this was the last writeback in progress on @inode;
+ * %false, otherwise.
+ */
+static bool iwbl_clear_sync(struct inode_wb_link *iwbl, struct inode *inode)
+{
+	bool sync_complete;
+
+	lockdep_assert_held(&inode->i_lock);
+	WARN_ON_ONCE(!iwbl_test_sync(iwbl));
+
+	clear_bit(IWBL_SYNC, &iwbl->data);
+	sync_complete = !--inode->i_nr_syncs;
+	if (sync_complete)
+		inode->i_state &= ~I_SYNC;
+	return sync_complete;
+}
+
+/**
+ * iwbl_wait_for_writeback - wait for writeback in progree on an inode_wb_link
+ * @iwbl: target inode_wb_link
+ *
+ * Wait for the writeback in progress for the inode on the bdi_writeback
+ * specified by @iwbl.
+ */
+static void iwbl_wait_for_writeback(struct inode_wb_link *iwbl)
+	__releases(inode->i_lock)
+	__acquires(inode->i_lock)
+{
+	struct inode *inode = iwbl_to_inode(iwbl);
+	DEFINE_WAIT_BIT(wq, &iwbl->data, IWBL_SYNC);
+	wait_queue_head_t *wqh;
+
+	lockdep_assert_held(&inode->i_lock);
+
+	wqh = bit_waitqueue(&iwbl->data, IWBL_SYNC);
+	while (test_bit(IWBL_SYNC, &iwbl->data)) {
+		spin_unlock(&inode->i_lock);
+		__wait_on_bit(wqh, &wq, bit_wait, TASK_UNINTERRUPTIBLE);
+		spin_lock(&inode->i_lock);
+	}
+}
+
 /*
  * Sleep until I_SYNC is cleared. This function must be called with i_lock
  * held and drops it. It is aimed for callers not holding any inode reference
  * so once i_lock is dropped, inode can go away.
  */
-static void inode_sleep_on_writeback(struct inode *inode)
-	__releases(inode->i_lock)
+static void iwbl_sleep_on_writeback(struct inode_wb_link *iwbl)
 {
 	DEFINE_WAIT(wait);
-	wait_queue_head_t *wqh = bit_waitqueue(&inode->i_state, __I_SYNC);
+	struct inode *inode = iwbl_to_inode(iwbl);
+	wait_queue_head_t *wqh = bit_waitqueue(&iwbl->data, IWBL_SYNC);
 	int sleep;
 
 	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
-	sleep = inode->i_state & I_SYNC;
+	sleep = test_bit(IWBL_SYNC, &iwbl->data);
 	spin_unlock(&inode->i_lock);
 	if (sleep)
 		schedule();
 	finish_wait(wqh, &wait);
 }
 
+/**
+ * iwbl_sync_wakeup - wakeup iwbl_{wait_for|sleep_on}_writeback() waiter
+ * @iwbl: target inode_wb_link
+ */
+static void iwbl_sync_wakeup(struct inode_wb_link *iwbl)
+{
+	wake_up_bit(&iwbl->data, IWBL_SYNC);
+}
+
 static inline struct inode_cgwb_link *icgwbl_first(struct inode *inode)
 {
 	struct hlist_node *node =
@@ -504,6 +591,7 @@ static void inode_icgwbls_del(struct inode *inode)
 	 * bdi->icgwbls_lock.
 	 */
 	inode_for_each_icgwbl(icgwbl, next, inode) {
+		WARN_ON_ONCE(test_bit(IWBL_SYNC, &icgwbl->iwbl.data));
 		hlist_del_rcu(&icgwbl->inode_node);
 		list_move(&icgwbl->wb_node, &to_free);
 	}
@@ -544,15 +632,39 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 	}
 }
 
+static bool iwbl_test_sync(struct inode_wb_link *iwbl)
+{
+	struct inode *inode = iwbl_to_inode(iwbl);
+
+	return inode->i_state & I_SYNC;
+}
+
+static void iwbl_set_sync(struct inode_wb_link *iwbl, struct inode *inode)
+{
+	inode->i_state |= I_SYNC;
+}
+
+static bool iwbl_clear_sync(struct inode_wb_link *iwbl, struct inode *inode)
+{
+	inode->i_state &= ~I_SYNC;
+	return true;
+}
+
+static void iwbl_wait_for_writeback(struct inode_wb_link *iwbl)
+{
+	__inode_wait_for_writeback(iwbl_to_inode(iwbl));
+}
+
 /*
  * Sleep until I_SYNC is cleared. This function must be called with i_lock
  * held and drops it. It is aimed for callers not holding any inode reference
  * so once i_lock is dropped, inode can go away.
  */
-static void inode_sleep_on_writeback(struct inode *inode)
+static void iwbl_sleep_on_writeback(struct inode_wb_link *iwbl)
 	__releases(inode->i_lock)
 {
 	DEFINE_WAIT(wait);
+	struct inode *inode = iwbl_to_inode(iwbl);
 	wait_queue_head_t *wqh = bit_waitqueue(&inode->i_state, __I_SYNC);
 	int sleep;
 
@@ -564,6 +676,11 @@ static void inode_sleep_on_writeback(struct inode *inode)
 	finish_wait(wqh, &wait);
 }
 
+static void iwbl_sync_wakeup(struct inode_wb_link *iwbl)
+{
+	/* noop, __I_SYNC wakeup is enough */
+}
+
 static void inode_icgwbls_del(struct inode *inode)
 {
 }
@@ -700,14 +817,22 @@ static void requeue_io(struct inode_wb_link *iwbl, struct bdi_writeback *wb)
 	iwbl_move_locked(iwbl, wb, &wb->b_more_io);
 }
 
-static void inode_sync_complete(struct inode *inode)
+static void iwbl_sync_complete(struct inode_wb_link *iwbl)
 {
-	inode->i_state &= ~I_SYNC;
+	struct inode *inode = iwbl_to_inode(iwbl);
+	bool sync_complete;
+
+	sync_complete = iwbl_clear_sync(iwbl, inode);
 	/* If inode is clean an unused, put it into LRU now... */
-	inode_add_lru(inode);
+	if (sync_complete)
+		inode_add_lru(inode);
+
 	/* Waiters must see I_SYNC cleared before being woken up */
 	smp_mb();
-	wake_up_bit(&inode->i_state, __I_SYNC);
+
+	iwbl_sync_wakeup(iwbl);
+	if (sync_complete)
+		wake_up_bit(&inode->i_state, __I_SYNC);
 }
 
 static bool iwbl_dirtied_after(struct inode_wb_link *iwbl, unsigned long t)
@@ -888,17 +1013,18 @@ static void requeue_inode(struct inode_wb_link *iwbl, struct bdi_writeback *wb,
 /*
  * Write out an inode and its dirty pages. Do not update the writeback list
  * linkage. That is left to the caller. The caller is also responsible for
- * setting I_SYNC flag and calling inode_sync_complete() to clear it.
+ * setting I_SYNC flag and calling iwbl_sync_complete() to clear it.
  */
 static int
 __writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 {
 	struct address_space *mapping = inode->i_mapping;
+	struct inode_wb_link *iwbl = &inode->i_wb_link;
 	long nr_to_write = wbc->nr_to_write;
 	unsigned dirty;
 	int ret;
 
-	WARN_ON(!(inode->i_state & I_SYNC));
+	WARN_ON(!iwbl_test_sync(iwbl));
 
 	trace_writeback_single_inode_start(inode, wbc, nr_to_write);
 
@@ -976,7 +1102,7 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	else
 		WARN_ON(inode->i_state & I_WILL_FREE);
 
-	if (inode->i_state & I_SYNC) {
+	if (iwbl_test_sync(iwbl)) {
 		if (wbc->sync_mode != WB_SYNC_ALL)
 			goto out;
 		/*
@@ -984,9 +1110,9 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 		 * inode reference or inode has I_WILL_FREE set, it cannot go
 		 * away under us.
 		 */
-		__inode_wait_for_writeback(inode);
+		iwbl_wait_for_writeback(iwbl);
 	}
-	WARN_ON(inode->i_state & I_SYNC);
+	WARN_ON(iwbl_test_sync(iwbl));
 	/*
 	 * Skip inode if it is clean and we have no outstanding writeback in
 	 * WB_SYNC_ALL mode. We don't want to mess with writeback lists in this
@@ -999,7 +1125,7 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	    (wbc->sync_mode != WB_SYNC_ALL ||
 	     !mapping_tagged(inode->i_mapping, PAGECACHE_TAG_WRITEBACK)))
 		goto out;
-	inode->i_state |= I_SYNC;
+	iwbl_set_sync(iwbl, inode);
 	spin_unlock(&inode->i_lock);
 
 	ret = __writeback_single_inode(inode, wbc);
@@ -1013,7 +1139,7 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	if (!(inode->i_state & I_DIRTY))
 		iwbl_del_locked(iwbl, wb);
 	spin_unlock(&wb->list_lock);
-	inode_sync_complete(inode);
+	iwbl_sync_complete(iwbl);
 out:
 	spin_unlock(&inode->i_lock);
 	return ret;
@@ -1107,7 +1233,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 			redirty_tail(iwbl, wb);
 			continue;
 		}
-		if ((inode->i_state & I_SYNC) && wbc.sync_mode != WB_SYNC_ALL) {
+		if (iwbl_test_sync(iwbl) && wbc.sync_mode != WB_SYNC_ALL) {
 			/*
 			 * If this inode is locked for writeback and we are not
 			 * doing writeback-for-data-integrity, move it to
@@ -1129,14 +1255,14 @@ static long writeback_sb_inodes(struct super_block *sb,
 		 * are doing WB_SYNC_NONE writeback. So this catches only the
 		 * WB_SYNC_ALL case.
 		 */
-		if (inode->i_state & I_SYNC) {
+		if (iwbl_test_sync(iwbl)) {
 			/* Wait for I_SYNC. This function drops i_lock... */
-			inode_sleep_on_writeback(inode);
+			iwbl_sleep_on_writeback(iwbl);
 			/* Inode may be gone, start again */
 			spin_lock(&wb->list_lock);
 			continue;
 		}
-		inode->i_state |= I_SYNC;
+		iwbl_set_sync(iwbl, inode);
 		spin_unlock(&inode->i_lock);
 
 		write_chunk = writeback_chunk_size(wb, work);
@@ -1156,7 +1282,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 		if (!(inode->i_state & I_DIRTY))
 			wrote++;
 		requeue_inode(iwbl, wb, &wbc);
-		inode_sync_complete(inode);
+		iwbl_sync_complete(iwbl);
 		spin_unlock(&inode->i_lock);
 		cond_resched_lock(&wb->list_lock);
 		/*
@@ -1356,7 +1482,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 			spin_lock(&inode->i_lock);
 			spin_unlock(&wb->list_lock);
 			/* This function drops i_lock... */
-			inode_sleep_on_writeback(inode);
+			iwbl_sleep_on_writeback(iwbl);
 			spin_lock(&wb->list_lock);
 		}
 	}
@@ -1648,7 +1774,7 @@ void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 		 * The unlocker will place the inode on the appropriate
 		 * superblock list, based upon its state.
 		 */
-		if (inode->i_state & I_SYNC)
+		if (iwbl_test_sync(iwbl))
 			goto out_unlock_inode;
 
 		/*
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index e448edc..e3b18f3 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -47,8 +47,15 @@ enum wb_stat_item {
  * IWBL_* flags which occupy the lower bits of inode_wb_link->data.  The
  * upper bits point to bdi_writeback, so the number of these flags
  * determines the minimum alignment of bdi_writeback.
+ *
+ * IWBL_SYNC
+ *
+ *  Tracks whether writeback is in progress for an iwbl.  If this bit is
+ *  set for any iwbl on an inode, the inode's I_SYNC is set too.
  */
 enum {
+	IWBL_SYNC		= 0,
+
 	IWBL_FLAGS_BITS,
 	IWBL_FLAGS_MASK		= (1UL << IWBL_FLAGS_BITS) - 1,
 };
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b394821..4c22824 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -625,6 +625,9 @@ struct inode {
 #ifdef CONFIG_IMA
 	atomic_t		i_readcount; /* struct files open RO */
 #endif
+#ifdef CONFIG_CGROUP_WRITEBACK
+	unsigned int		i_nr_syncs;
+#endif
 	const struct file_operations	*i_fop;	/* former ->i_op->default_file_ops */
 	struct file_lock	*i_flock;
 	struct address_space	i_data;
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e4db465..1399ad6 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -539,6 +539,7 @@ static void cgwb_exit(struct bdi_writeback *wb)
 	spin_lock_irqsave(&wb->bdi->icgwbls_lock, flags);
 	list_for_each_entry_safe(icgwbl, next, &wb->icgwbls, wb_node) {
 		WARN_ON_ONCE(!list_empty(&icgwbl->iwbl.dirty_list));
+		WARN_ON_ONCE(test_bit(IWBL_SYNC, &icgwbl->iwbl.data));
 		hlist_del_rcu(&icgwbl->inode_node);
 		list_del(&icgwbl->wb_node);
 		kfree_rcu(icgwbl, rcu);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
