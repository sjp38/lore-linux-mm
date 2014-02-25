Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D12416B00FF
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:19:24 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id y10so2194521pdj.25
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 06:19:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id gk3si20886893pac.234.2014.02.25.06.19.22
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 06:19:23 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v6 11/22] Replace ext2_clear_xip_target with dax_clear_blocks
Date: Tue, 25 Feb 2014 09:18:27 -0500
Message-Id: <1393337918-28265-12-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

This is practically generic code; other filesystems will want to call
it from other places, but there's nothing ext2-specific about it.

Make it a little more generic by allowing it to take a count of the number
of bytes to zero rather than fixing it to a single page.  Thanks to Dave
Hansen for suggesting that I need to call cond_resched() if zeroing more
than one page.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c           | 34 ++++++++++++++++++++++++++++++++++
 fs/ext2/inode.c    |  8 +++++---
 fs/ext2/xip.c      | 23 -----------------------
 fs/ext2/xip.h      |  3 ---
 include/linux/fs.h |  6 ++++++
 5 files changed, 45 insertions(+), 29 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index a6a1adc..75328bf 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -22,8 +22,42 @@
 #include <linux/highmem.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
+#include <linux/sched.h>
 #include <linux/uio.h>
 
+int dax_clear_blocks(struct inode *inode, sector_t block, long size)
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
+EXPORT_SYMBOL_GPL(dax_clear_blocks);
+
 static long dax_get_addr(struct inode *inode, struct buffer_head *bh,
 								void **addr)
 {
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index b156fe8..a9346a9 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -733,10 +733,12 @@ static int ext2_get_blocks(struct inode *inode,
 
 	if (IS_DAX(inode)) {
 		/*
-		 * we need to clear the block
+		 * block must be initialised before we put it in the tree
+		 * so that it's not found by another thread before it's
+		 * initialised
 		 */
-		err = ext2_clear_xip_target (inode,
-			le32_to_cpu(chain[depth-1].key));
+		err = dax_clear_blocks(inode, le32_to_cpu(chain[depth-1].key),
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
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c7945fd..6f7f445 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2516,12 +2516,18 @@ extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
 #ifdef CONFIG_FS_XIP
+int dax_clear_blocks(struct inode *, sector_t block, long size);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
 		loff_t, unsigned segs, get_block_t, dio_iodone_t, int flags);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 int dax_mkwrite(struct vm_area_struct *, struct vm_fault *, get_block_t);
 #else
+static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
+{
+	return 0;
+}
+
 static inline int dax_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
 {
 	return 0;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
