Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9786B005A
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:09 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id r10so1883887pdi.20
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:09 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ai8si5303034pad.270.2014.01.15.17.25.06
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:25:07 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 11/22] Replace ext2_clear_xip_target with xip_clear_blocks
Date: Wed, 15 Jan 2014 20:24:29 -0500
Message-Id: <1d3615d35c7f12637f4e55bd6c772a35ea4be220.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

This is practically generic code; other filesystems will want to call
it from other places, but there's nothing ext2-specific about it.

Make it a little more generic by allowing it to take a count of the number
of bytes to zero rather than fixing it to a single page.  Thanks to Dave
Hansen for suggesting that I need to call cond_resched() if zeroing more
than one page.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/ext2/inode.c    |  8 +++++---
 fs/ext2/xip.c      | 23 -----------------------
 fs/ext2/xip.h      |  3 ---
 fs/xip.c           | 34 ++++++++++++++++++++++++++++++++++
 include/linux/fs.h |  6 ++++++
 5 files changed, 45 insertions(+), 29 deletions(-)

diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 57726ab..946ed65 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -733,10 +733,12 @@ static int ext2_get_blocks(struct inode *inode,
 
 	if (IS_XIP(inode)) {
 		/*
-		 * we need to clear the block
+		 * block must be initialised before we put it in the tree
+		 * so that it's not found by another thread before it's
+		 * initialised
 		 */
-		err = ext2_clear_xip_target (inode,
-			le32_to_cpu(chain[depth-1].key));
+		err = xip_clear_blocks(inode, le32_to_cpu(chain[depth-1].key),
+						count << inode->i_blkbits);
 		if (err) {
 			mutex_unlock(&ei->truncate_mutex);
 			goto cleanup;
diff --git a/fs/ext2/xip.c b/fs/ext2/xip.c
index ca745ff..132d4da 100644
--- a/fs/ext2/xip.c
+++ b/fs/ext2/xip.c
@@ -13,29 +13,6 @@
 #include "ext2.h"
 #include "xip.h"
 
-static inline long __inode_direct_access(struct inode *inode, sector_t block,
-				void **kaddr, unsigned long *pfn, long size)
-{
-	struct block_device *bdev = inode->i_sb->s_bdev;
-	const struct block_device_operations *ops = bdev->bd_disk->fops;
-	sector_t sector = block * (PAGE_SIZE / 512);
-	return ops->direct_access(bdev, sector, kaddr, pfn, size);
-}
-
-int
-ext2_clear_xip_target(struct inode *inode, sector_t block)
-{
-	void *kaddr;
-	unsigned long pfn;
-	long size;
-
-	size = __inode_direct_access(inode, block, &kaddr, &pfn, PAGE_SIZE);
-	if (size < 0)
-		return size;
-	clear_page(kaddr);
-	return 0;
-}
-
 void ext2_xip_verify_sb(struct super_block *sb)
 {
 	struct ext2_sb_info *sbi = EXT2_SB(sb);
diff --git a/fs/ext2/xip.h b/fs/ext2/xip.h
index 0fa8b7f..e7b9f0a 100644
--- a/fs/ext2/xip.h
+++ b/fs/ext2/xip.h
@@ -7,8 +7,6 @@
 
 #ifdef CONFIG_EXT2_FS_XIP
 extern void ext2_xip_verify_sb (struct super_block *);
-extern int ext2_clear_xip_target (struct inode *, sector_t);
-
 static inline int ext2_use_xip (struct super_block *sb)
 {
 	struct ext2_sb_info *sbi = EXT2_SB(sb);
@@ -17,5 +15,4 @@ static inline int ext2_use_xip (struct super_block *sb)
 #else
 #define ext2_xip_verify_sb(sb)			do { } while (0)
 #define ext2_use_xip(sb)			0
-#define ext2_clear_xip_target(inode, chain)	0
 #endif
diff --git a/fs/xip.c b/fs/xip.c
index aacb6a8..3f5f081 100644
--- a/fs/xip.c
+++ b/fs/xip.c
@@ -21,8 +21,42 @@
 #include <linux/highmem.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
+#include <linux/sched.h>
 #include <linux/uio.h>
 
+int xip_clear_blocks(struct inode *inode, sector_t block, long size)
+{
+	struct block_device *bdev = inode->i_sb->s_bdev;
+	const struct block_device_operations *ops = bdev->bd_disk->fops;
+	sector_t sector = block << (inode->i_blkbits - 9);
+	unsigned long pfn;
+
+	might_sleep();
+	do {
+		void *addr;
+		long count = ops->direct_access(bdev, sector, &addr, &pfn,
+									size);
+		if (count < 0)
+			return count;
+		while (count >= PAGE_SIZE) {
+			clear_page(addr);
+			addr += PAGE_SIZE;
+			size -= PAGE_SIZE;
+			count -= PAGE_SIZE;
+			sector += PAGE_SIZE / 512;
+			cond_resched();
+		}
+		if (count > 0) {
+			memset(addr, 0, count);
+			sector += count / 512;
+			size -= count;
+		}
+	} while (size);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(xip_clear_blocks);
+
 static long xip_get_addr(struct inode *inode, struct buffer_head *bh,
 								void **addr)
 {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7c10319..c93671a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2508,12 +2508,18 @@ extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
 #ifdef CONFIG_FS_XIP
+int xip_clear_blocks(struct inode *, sector_t block, long size);
 int xip_truncate_page(struct inode *, loff_t from, get_block_t);
 ssize_t xip_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
 		loff_t, unsigned segs, get_block_t, dio_iodone_t, int flags);
 int xip_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 int xip_mkwrite(struct vm_area_struct *, struct vm_fault *, get_block_t);
 #else
+static inline int xip_clear_blocks(struct inode *i, sector_t blk, long sz)
+{
+	return 0;
+}
+
 static inline int xip_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
 {
 	return 0;
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
