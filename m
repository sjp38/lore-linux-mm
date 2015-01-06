Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id D0DFC6B0161
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:26 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i17so78905qcy.4
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:26 -0800 (PST)
Received: from mail-qc0-x22c.google.com (mail-qc0-x22c.google.com. [2607:f8b0:400d:c01::22c])
        by mx.google.com with ESMTPS id v6si65680611qag.104.2015.01.06.13.27.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:26 -0800 (PST)
Received: by mail-qc0-f172.google.com with SMTP id m20so71084qcx.17
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:25 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 31/45] vfs, writeback: add inode_wb_link->data point to the associated bdi_writeback
Date: Tue,  6 Jan 2015 16:26:08 -0500
Message-Id: <1420579582-8516-32-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

If CONFIG_CGROUP_WRITEBACK, add ->data to iwbl (inode_wb_link) which
is an unsigned long value which points to the associated wb
(bdi_writeback) with its upper bits and carries IWBL_* flags, none of
which is defined yet, in the lower.  iwbl_to_wb() is added to retrieve
the associated wb from a iwbl.

Places which were mapping inode to wb through inode_to_bdi() are
converted to use iwbl_to_wb(&inode->i_wb_link) instead.  ->data is set
by init_i_wb_link() function on inode initialization and when a bdev
inode changes its associated bdi.

When CONFIG_CGROUP_ENABLED is enabled, this adds a pointer to struct
inode.  This patch currently doesn't make any behavioral difference
but will allow associating a single inode with multiple wb's which is
necessary for cgroup writeback support.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/block_dev.c                   |  1 +
 fs/fs-writeback.c                |  8 ++++----
 fs/inode.c                       |  1 +
 include/linux/backing-dev-defs.h | 27 ++++++++++++++++++++++++++-
 include/linux/backing-dev.h      | 30 ++++++++++++++++++++++++++++++
 5 files changed, 62 insertions(+), 5 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 0413d3f..855f850 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -61,6 +61,7 @@ static void bdev_inode_switch_bdi(struct inode *inode,
 		spin_lock(&inode->i_lock);
 		if (!(inode->i_state & I_DIRTY)) {
 			inode->i_data.backing_dev_info = dst;
+			init_i_wb_link(inode);
 			spin_unlock(&inode->i_lock);
 			return;
 		}
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 0a10dd8..2a5e400 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -507,8 +507,7 @@ static void iwbl_del_locked(struct inode_wb_link *iwbl,
 void inode_wb_list_del(struct inode *inode)
 {
 	struct inode_wb_link *iwbl = &inode->i_wb_link;
-	struct backing_dev_info *bdi = inode_to_bdi(inode);
-	struct bdi_writeback *wb = &bdi->wb;
+	struct bdi_writeback *wb = iwbl_to_wb(iwbl);
 
 	if (list_empty(&iwbl->dirty_list))
 		return;
@@ -1787,7 +1786,7 @@ EXPORT_SYMBOL(sync_inodes_sb);
  */
 int write_inode_now(struct inode *inode, int sync)
 {
-	struct bdi_writeback *wb = &inode_to_bdi(inode)->wb;
+	struct bdi_writeback *wb = iwbl_to_wb(&inode->i_wb_link);
 	struct writeback_control wbc = {
 		.nr_to_write = LONG_MAX,
 		.sync_mode = sync ? WB_SYNC_ALL : WB_SYNC_NONE,
@@ -1816,7 +1815,8 @@ EXPORT_SYMBOL(write_inode_now);
  */
 int sync_inode(struct inode *inode, struct writeback_control *wbc)
 {
-	return writeback_single_inode(inode, &inode_to_bdi(inode)->wb, wbc);
+	return writeback_single_inode(inode, iwbl_to_wb(&inode->i_wb_link),
+				      wbc);
 }
 EXPORT_SYMBOL(sync_inode);
 
diff --git a/fs/inode.c b/fs/inode.c
index 7ec49ad..b38d7d6 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -195,6 +195,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	inode->i_fsnotify_mask = 0;
 #endif
 
+	init_i_wb_link(inode);
 	this_cpu_inc(nr_inodes);
 
 	return 0;
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 8bc80bd..9720cac 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -43,6 +43,24 @@ enum wb_stat_item {
 
 #define WB_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
 
+/*
+ * IWBL_* flags which occupy the lower bits of inode_wb_link->data.  The
+ * upper bits point to bdi_writeback, so the number of these flags
+ * determines the minimum alignment of bdi_writeback.
+ */
+enum {
+	IWBL_FLAGS_BITS,
+	IWBL_FLAGS_MASK		= (1UL << IWBL_FLAGS_BITS) - 1,
+};
+
+/*
+ * Align bdi_writeback so that inode_wb_link->data can carry IWBL_* flags
+ * in the lower bits but don't let it fall below that of ullong.
+ */
+#define BDI_WRITEBACK_ALIGN	\
+	((1UL << IWBL_FLAGS_BITS) > __alignof(unsigned long long) ?	\
+	 (1UL << IWBL_FLAGS_BITS) : __alignof(unsigned long long))
+
 struct bdi_writeback {
 	struct backing_dev_info *bdi;	/* our parent bdi */
 
@@ -86,7 +104,7 @@ struct bdi_writeback {
 		struct rcu_head rcu;
 	};
 #endif
-};
+} __aligned(BDI_WRITEBACK_ALIGN);
 
 struct backing_dev_info {
 	struct list_head bdi_list;
@@ -127,6 +145,13 @@ struct backing_dev_info {
  * one at ->i_wb_link which is used for the root wb.
  */
 struct inode_wb_link {
+#ifdef CONFIG_CGROUP_WRITEBACK
+	/*
+	 * Upper bits point to the associated bdi_writeback.  Lower carry
+	 * IWBL_* flags.  Use iwbl_to_wb() to reach the bdi_writeback.
+	 */
+	unsigned long		data;
+#endif
 	struct list_head	dirty_list;
 };
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 6ced0f4..bc69c7f 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -450,6 +450,25 @@ static inline struct bdi_writeback *__wb_iter_init(struct wb_iter *iter,
 	for ((wb_cur) = __wb_iter_init(iter, bdi, start_blkcg_id);	\
 	     (wb_cur); (wb_cur) = __wb_iter_next(iter, bdi))
 
+/**
+ * init_i_wb_link - (re)initialize inode->i_wb_link
+ * @inode: inode of interest
+ *
+ * Initialize @inode->i_wb_link.  Usually invoked on inode initialization.
+ * One special case is the bdev inodes which are associated with different
+ * bdi's over their lifetimes.  This function must be called each time the
+ * associated bdi changes.
+ */
+static inline void init_i_wb_link(struct inode *inode)
+{
+	inode->i_wb_link.data = (unsigned long)&inode_to_bdi(inode)->wb;
+}
+
+static inline struct bdi_writeback *iwbl_to_wb(struct inode_wb_link *iwbl)
+{
+	return (void *)(iwbl->data & ~IWBL_FLAGS_MASK);
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline bool mapping_cgwb_enabled(struct address_space *mapping)
@@ -499,6 +518,17 @@ struct wb_iter {
 	     ({	(wb_cur) = !(iter)->next_id++ ? &(bdi)->wb : NULL;	\
 	     }); )
 
+static inline void init_i_wb_link(struct inode *inode)
+{
+}
+
+static inline struct bdi_writeback *iwbl_to_wb(struct inode_wb_link *iwbl)
+{
+	struct inode *inode = iwbl_to_inode(iwbl);
+
+	return &inode_to_bdi(inode)->wb;
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline int mapping_read_congested(struct address_space *mapping,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
