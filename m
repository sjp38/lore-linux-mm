Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 400DC6B0089
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:55:47 -0400 (EDT)
Received: by qcbjx9 with SMTP id jx9so98004096qcb.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:47 -0700 (PDT)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com. [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id 63si11166414qkw.108.2015.03.22.21.55.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:55:38 -0700 (PDT)
Received: by qcay5 with SMTP id y5so46329997qca.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:38 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 17/48] bdi: make inode_to_bdi() inline
Date: Mon, 23 Mar 2015 00:54:28 -0400
Message-Id: <1427086499-15657-18-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Now that bdi definitions are moved to backing-dev-defs.h,
backing-dev.h can include blkdev.h and inline inode_to_bdi() without
worrying about introducing circular include dependency.  The function
gets called from hot paths and fairly trivial.

This patch makes inode_to_bdi() and sb_is_blkdev_sb() that the
function calls inline.  blockdev_superblock and noop_backing_dev_info
are EXPORT_GPL'd to allow the inline functions to be used from
modules.

While at it, maske sb_is_blkdev_sb() return bool instead of int.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@infradead.org>
---
 fs/block_dev.c              |  8 ++------
 fs/fs-writeback.c           | 16 ----------------
 include/linux/backing-dev.h | 18 ++++++++++++++++--
 include/linux/fs.h          |  8 +++++++-
 mm/backing-dev.c            |  1 +
 5 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index e4f5f71..875d41a 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -549,7 +549,8 @@ static struct file_system_type bd_type = {
 	.kill_sb	= kill_anon_super,
 };
 
-static struct super_block *blockdev_superblock __read_mostly;
+struct super_block *blockdev_superblock __read_mostly;
+EXPORT_SYMBOL_GPL(blockdev_superblock);
 
 void __init bdev_cache_init(void)
 {
@@ -690,11 +691,6 @@ static struct block_device *bd_acquire(struct inode *inode)
 	return bdev;
 }
 
-int sb_is_blkdev_sb(struct super_block *sb)
-{
-	return sb == blockdev_superblock;
-}
-
 /* Call when you free inode */
 
 void bd_forget(struct inode *inode)
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 7c2f0bd..4fd264d 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -66,22 +66,6 @@ int writeback_in_progress(struct backing_dev_info *bdi)
 }
 EXPORT_SYMBOL(writeback_in_progress);
 
-struct backing_dev_info *inode_to_bdi(struct inode *inode)
-{
-	struct super_block *sb;
-
-	if (!inode)
-		return &noop_backing_dev_info;
-
-	sb = inode->i_sb;
-#ifdef CONFIG_BLOCK
-	if (sb_is_blkdev_sb(sb))
-		return blk_get_backing_dev_info(I_BDEV(inode));
-#endif
-	return sb->s_bdi;
-}
-EXPORT_SYMBOL_GPL(inode_to_bdi);
-
 static inline struct inode *wb_inode(struct list_head *head)
 {
 	return list_entry(head, struct inode, i_wb_list);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 5e39f7a..7857820 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -11,11 +11,10 @@
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/sched.h>
+#include <linux/blkdev.h>
 #include <linux/writeback.h>
 #include <linux/backing-dev-defs.h>
 
-struct backing_dev_info *inode_to_bdi(struct inode *inode);
-
 int __must_check bdi_init(struct backing_dev_info *bdi);
 void bdi_destroy(struct backing_dev_info *bdi);
 
@@ -149,6 +148,21 @@ extern struct backing_dev_info noop_backing_dev_info;
 
 int writeback_in_progress(struct backing_dev_info *bdi);
 
+static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
+{
+	struct super_block *sb;
+
+	if (!inode)
+		return &noop_backing_dev_info;
+
+	sb = inode->i_sb;
+#ifdef CONFIG_BLOCK
+	if (sb_is_blkdev_sb(sb))
+		return blk_get_backing_dev_info(I_BDEV(inode));
+#endif
+	return sb->s_bdi;
+}
+
 static inline int bdi_congested(struct backing_dev_info *bdi, int bdi_bits)
 {
 	if (bdi->congested_fn)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b4d71b5..ccf4b64 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2205,7 +2205,13 @@ extern struct super_block *freeze_bdev(struct block_device *);
 extern void emergency_thaw_all(void);
 extern int thaw_bdev(struct block_device *bdev, struct super_block *sb);
 extern int fsync_bdev(struct block_device *);
-extern int sb_is_blkdev_sb(struct super_block *sb);
+
+extern struct super_block *blockdev_superblock;
+
+static inline bool sb_is_blkdev_sb(struct super_block *sb)
+{
+	return sb == blockdev_superblock;
+}
 #else
 static inline void bd_forget(struct inode *inode) {}
 static inline int sync_blockdev(struct block_device *bdev) { return 0; }
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index ff85ecb..b0707d1 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -18,6 +18,7 @@ struct backing_dev_info noop_backing_dev_info = {
 	.name		= "noop",
 	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
 };
+EXPORT_SYMBOL_GPL(noop_backing_dev_info);
 
 static struct class *bdi_class;
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
