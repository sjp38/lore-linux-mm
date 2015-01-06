Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id C30796B0163
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:28 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id z60so76337qgd.9
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:28 -0800 (PST)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com. [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id f11si47901636qgf.1.2015.01.06.13.27.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:27 -0800 (PST)
Received: by mail-qc0-f170.google.com with SMTP id x3so64698qcv.29
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:27 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 32/45] vfs, writeback: move inode->dirtied_when into inode->i_wb_link
Date: Tue,  6 Jan 2015 16:26:09 -0500
Message-Id: <1420579582-8516-33-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

With cgroup writeback support, an inode may be dirtied by multiple
wb's (bdi_writeback's) belonging to different cgroups and each should
be tracked separately.  iwbl (inode_wb_link) will be used to establish
the associations between an inode and the wb's that it's dirtied
against.

This patch moves inode->dirtied_when into iwbl so that the dirtied
timestamp can be tracked separately for each associated wb.

Other than relocation of the timestamp field in struct inode, this
doesn't cause any functional changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 28 ++++++++++++----------------
 fs/inode.c                       |  2 +-
 include/linux/backing-dev-defs.h |  1 +
 include/linux/fs.h               |  2 --
 include/trace/events/writeback.h |  4 ++--
 5 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 2a5e400..6851088 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -521,23 +521,19 @@ void inode_wb_list_del(struct inode *inode)
  * Redirty an inode: set its when-it-was dirtied timestamp and move it to the
  * furthest end of its superblock's dirty-inode list.
  *
- * Before stamping the inode's ->dirtied_when, we check to see whether it is
+ * Before stamping the iwbl's ->dirtied_when, we check to see whether it is
  * already the most-recently-dirtied inode on the b_dirty list.  If that is
  * the case then the inode must have been redirtied while it was being written
  * out and we don't reset its dirtied_when.
  */
 static void redirty_tail(struct inode_wb_link *iwbl, struct bdi_writeback *wb)
 {
-	struct inode *inode = iwbl_to_inode(iwbl);
-
 	if (!list_empty(&wb->b_dirty)) {
-		struct inode_wb_link *tail_iwbl;
-		struct inode *tail;
+		struct inode_wb_link *tail;
 
-		tail_iwbl = dirty_list_to_iwbl(wb->b_dirty.next);
-		tail = iwbl_to_inode(tail_iwbl);
-		if (time_before(inode->dirtied_when, tail->dirtied_when))
-			inode->dirtied_when = jiffies;
+		tail = dirty_list_to_iwbl(wb->b_dirty.next);
+		if (time_before(iwbl->dirtied_when, tail->dirtied_when))
+			iwbl->dirtied_when = jiffies;
 	}
 	iwbl_move_locked(iwbl, wb, &wb->b_dirty);
 }
@@ -560,9 +556,9 @@ static void inode_sync_complete(struct inode *inode)
 	wake_up_bit(&inode->i_state, __I_SYNC);
 }
 
-static bool inode_dirtied_after(struct inode *inode, unsigned long t)
+static bool iwbl_dirtied_after(struct inode_wb_link *iwbl, unsigned long t)
 {
-	bool ret = time_after(inode->dirtied_when, t);
+	bool ret = time_after(iwbl->dirtied_when, t);
 #ifndef CONFIG_64BIT
 	/*
 	 * For inodes being constantly redirtied, dirtied_when can get stuck.
@@ -570,7 +566,7 @@ static bool inode_dirtied_after(struct inode *inode, unsigned long t)
 	 * This test is necessary to prevent such wrapped-around relative times
 	 * from permanently stopping the whole bdi writeback.
 	 */
-	ret = ret && time_before_eq(inode->dirtied_when, jiffies);
+	ret = ret && time_before_eq(iwbl->dirtied_when, jiffies);
 #endif
 	return ret;
 }
@@ -596,7 +592,7 @@ static int move_expired_inodes(struct list_head *delaying_queue,
 		inode = iwbl_to_inode(iwbl);
 
 		if (work->older_than_this &&
-		    inode_dirtied_after(inode, *work->older_than_this))
+		    iwbl_dirtied_after(iwbl, *work->older_than_this))
 			break;
 		list_move(&iwbl->dirty_list, &tmp);
 		moved++;
@@ -733,7 +729,7 @@ static void requeue_inode(struct inode_wb_link *iwbl, struct bdi_writeback *wb,
 	 */
 	if ((inode->i_state & I_DIRTY) &&
 	    (wbc->sync_mode == WB_SYNC_ALL || wbc->tagged_writepages))
-		inode->dirtied_when = jiffies;
+		iwbl->dirtied_when = jiffies;
 
 	if (wbc->pages_skipped) {
 		/*
@@ -1488,7 +1484,7 @@ static noinline void block_dump___mark_inode_dirty(struct inode *inode)
  * In short, make sure you hash any inodes _before_ you start marking
  * them dirty.
  *
- * Note that for blockdevs, inode->dirtied_when represents the dirtying time of
+ * Note that for blockdevs, iwbl->dirtied_when represents the dirtying time of
  * the block-special inode (/dev/hda1) itself.  And the ->dirtied_when field of
  * the kernel-internal blockdev inode represents the dirtying time of the
  * blockdev's pages.  This is why for I_DIRTY_PAGES we always use
@@ -1567,7 +1563,7 @@ void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 			     !test_bit(WB_registered, &bdi->wb.state),
 			     "bdi-%s not registered\n", bdi->name);
 
-			inode->dirtied_when = jiffies;
+			iwbl->dirtied_when = jiffies;
 			wakeup_bdi = iwbl_move_locked(iwbl, &bdi->wb,
 						      &bdi->wb.b_dirty);
 			spin_unlock(&bdi->wb.list_lock);
diff --git a/fs/inode.c b/fs/inode.c
index b38d7d6..66c9b68 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -152,7 +152,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	inode->i_bdev = NULL;
 	inode->i_cdev = NULL;
 	inode->i_rdev = 0;
-	inode->dirtied_when = 0;
+	inode->i_wb_link.dirtied_when = 0;
 
 	if (security_inode_alloc(inode))
 		goto out;
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 9720cac..01f27e3 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -152,6 +152,7 @@ struct inode_wb_link {
 	 */
 	unsigned long		data;
 #endif
+	unsigned long		dirtied_when;
 	struct list_head	dirty_list;
 };
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ea0b68f..fb261b4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -607,8 +607,6 @@ struct inode {
 	unsigned long		i_state;
 	struct mutex		i_mutex;
 
-	unsigned long		dirtied_when;	/* jiffies of first dirtying */
-
 	struct hlist_node	i_hash;
 	struct inode_wb_link	i_wb_link;	/* backing dev IO list */
 	struct list_head	i_lru;		/* inode LRU list */
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 8622b5b..8bc68ac 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -494,7 +494,7 @@ TRACE_EVENT(writeback_sb_inodes_requeue,
 		        dev_name(inode_to_bdi(inode)->dev), 32);
 		__entry->ino		= inode->i_ino;
 		__entry->state		= inode->i_state;
-		__entry->dirtied_when	= inode->dirtied_when;
+		__entry->dirtied_when	= inode->i_wb_link.dirtied_when;
 	),
 
 	TP_printk("bdi %s: ino=%lu state=%s dirtied_when=%lu age=%lu",
@@ -565,7 +565,7 @@ DECLARE_EVENT_CLASS(writeback_single_inode_template,
 			dev_name(inode_to_bdi(inode)->dev), 32);
 		__entry->ino		= inode->i_ino;
 		__entry->state		= inode->i_state;
-		__entry->dirtied_when	= inode->dirtied_when;
+		__entry->dirtied_when	= inode->i_wb_link.dirtied_when;
 		__entry->writeback_index = inode->i_mapping->writeback_index;
 		__entry->nr_to_write	= nr_to_write;
 		__entry->wrote		= nr_to_write - wbc->nr_to_write;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
