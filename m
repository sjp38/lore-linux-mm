Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 24EA46B0069
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 09:27:59 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so5796187pad.35
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 06:27:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id qe8si4906168pdb.213.2014.08.01.06.27.55
        for <linux-mm@kvack.org>;
        Fri, 01 Aug 2014 06:27:55 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v9 08/22] Replace ext2_clear_xip_target with dax_clear_blocks
Date: Fri,  1 Aug 2014 09:27:24 -0400
Message-Id: <dd6ce36814c5b0ecae961e37a3708ea06adb51eb.1406897885.git.willy@linux.intel.com>
In-Reply-To: <cover.1406897885.git.willy@linux.intel.com>
References: <cover.1406897885.git.willy@linux.intel.com>
In-Reply-To: <cover.1406897885.git.willy@linux.intel.com>
References: <cover.1406897885.git.willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

This is practically generic code; other filesystems will want to call
it from other places, but there's nothing ext2-specific about it.

Make it a little more generic by allowing it to take a count of the number
of bytes to zero rather than fixing it to a single page.  Thanks to Dave
Hansen for suggesting that I need to call cond_resched() if zeroing more
than one page.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c           | 35 +++++++++++++++++++++++++++++++++++
 fs/ext2/inode.c    |  8 +++++---
 fs/ext2/xip.c      | 14 --------------
 fs/ext2/xip.h      |  3 ---
 include/linux/fs.h |  6 ++++++
 5 files changed, 46 insertions(+), 20 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 108c68e..02e226f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -20,8 +20,43 @@
 #include <linux/fs.h>
 #include <linux/genhd.h>
 #include <linux/mutex.h>
+#include <linux/sched.h>
 #include <linux/uio.h>
 
+int dax_clear_blocks(struct inode *inode, sector_t block, long size)
+{
+	struct block_device *bdev = inode->i_sb->s_bdev;
+	sector_t sector = block << (inode->i_blkbits - 9);
+
+	might_sleep();
+	do {
+		void *addr;
+		unsigned long pfn;
+		long count;
+
+		count = bdev_direct_access(bdev, sector, &addr, &pfn, size);
+		if (count < 0)
+			return count;
+		while (count > 0) {
+			unsigned pgsz = PAGE_SIZE - offset_in_page(addr);
+			if (pgsz > count)
+				pgsz = count;
+			if (pgsz < PAGE_SIZE)
+				memset(addr, 0, pgsz);
+			else
+				clear_page(addr);
+			addr += pgsz;
+			size -= pgsz;
+			count -= pgsz;
+			sector += pgsz / 512;
+			cond_resched();
+		}
+	} while (size);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dax_clear_blocks);
+
 static long dax_get_addr(struct buffer_head *bh, void **addr, unsigned blkbits)
 {
 	unsigned long pfn;
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 3ccd5fd..52978b8 100644
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
+						1 << inode->i_blkbits);
 		if (err) {
 			mutex_unlock(&ei->truncate_mutex);
 			goto cleanup;
diff --git a/fs/ext2/xip.c b/fs/ext2/xip.c
index bbc5fec..8cfca3a 100644
--- a/fs/ext2/xip.c
+++ b/fs/ext2/xip.c
@@ -42,20 +42,6 @@ __ext2_get_block(struct inode *inode, pgoff_t pgoff, int create,
 	return rc;
 }
 
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
index 29be737..b2592f2 100644
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
@@ -19,6 +17,5 @@ int ext2_get_xip_mem(struct address_space *, pgoff_t, int,
 #else
 #define ext2_xip_verify_sb(sb)			do { } while (0)
 #define ext2_use_xip(sb)			0
-#define ext2_clear_xip_target(inode, chain)	0
 #define ext2_get_xip_mem			NULL
 #endif
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 87a135a..e38138b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2463,11 +2463,17 @@ extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
 #ifdef CONFIG_FS_XIP
+int dax_clear_blocks(struct inode *, sector_t block, long size);
 extern int xip_file_mmap(struct file * file, struct vm_area_struct * vma);
 extern int xip_truncate_page(struct address_space *mapping, loff_t from);
 ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
 		loff_t, get_block_t, dio_iodone_t, int flags);
 #else
+static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
+{
+	return 0;
+}
+
 static inline int xip_truncate_page(struct address_space *mapping, loff_t from)
 {
 	return 0;
-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
