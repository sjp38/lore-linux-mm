Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 376AB6B0069
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:48:48 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so176631pad.7
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:48:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rq15si52299pac.50.2014.07.22.12.48.46
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 12:48:46 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v8 11/22] Replace xip_truncate_page with dax_truncate_page
Date: Tue, 22 Jul 2014 15:47:59 -0400
Message-Id: <ca229b46f3e0903cd7aa1e9745af104c655cce8a.1406058387.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1406058387.git.matthew.r.wilcox@intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1406058387.git.matthew.r.wilcox@intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

It takes a get_block parameter just like nobh_truncate_page() and
block_truncate_page()

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c           | 44 ++++++++++++++++++++++++++++++++++++++++++++
 fs/ext2/inode.c    |  2 +-
 include/linux/fs.h |  4 ++--
 mm/filemap_xip.c   | 40 ----------------------------------------
 4 files changed, 47 insertions(+), 43 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 4ab4890..b9bc5e2 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -449,3 +449,47 @@ int dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	return dax_fault(vma, vmf, get_block);
 }
 EXPORT_SYMBOL_GPL(dax_mkwrite);
+
+/**
+ * dax_truncate_page - handle a partial page being truncated in a DAX file
+ * @inode: The file being truncated
+ * @from: The file offset that is being truncated to
+ * @get_block: The filesystem method used to translate file offsets to blocks
+ *
+ * Similar to block_truncate_page(), this function can be called by a
+ * filesystem when it is truncating an DAX file to handle the partial page.
+ *
+ * We work in terms of PAGE_CACHE_SIZE here for commonality with
+ * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
+ * took care of disposing of the unnecessary blocks.  Even if the filesystem
+ * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
+ * since the file might be mmaped.
+ */
+int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
+{
+	struct buffer_head bh;
+	pgoff_t index = from >> PAGE_CACHE_SHIFT;
+	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	unsigned length = PAGE_CACHE_ALIGN(from) - from;
+	int err;
+
+	/* Block boundary? Nothing to do */
+	if (!length)
+		return 0;
+
+	memset(&bh, 0, sizeof(bh));
+	bh.b_size = PAGE_CACHE_SIZE;
+	err = get_block(inode, index, &bh, 0);
+	if (err < 0)
+		return err;
+	if (buffer_written(&bh)) {
+		void *addr;
+		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
+		if (err < 0)
+			return err;
+		memset(addr + offset, 0, length);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dax_truncate_page);
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 52978b8..5ac0a34 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1210,7 +1210,7 @@ static int ext2_setsize(struct inode *inode, loff_t newsize)
 	inode_dio_wait(inode);
 
 	if (IS_DAX(inode))
-		error = xip_truncate_page(inode->i_mapping, newsize);
+		error = dax_truncate_page(inode, newsize, ext2_get_block);
 	else if (test_opt(inode->i_sb, NOBH))
 		error = nobh_truncate_page(inode->i_mapping,
 				newsize, ext2_get_block);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index d4259e1..29fafaf 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2465,7 +2465,7 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
 
 #ifdef CONFIG_FS_XIP
 int dax_clear_blocks(struct inode *, sector_t block, long size);
-extern int xip_truncate_page(struct address_space *mapping, loff_t from);
+int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
 		loff_t, get_block_t, dio_iodone_t, int flags);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
@@ -2476,7 +2476,7 @@ static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
 	return 0;
 }
 
-static inline int xip_truncate_page(struct address_space *mapping, loff_t from)
+static inline int dax_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
 {
 	return 0;
 }
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 9dd45f3..6316578 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -21,43 +21,3 @@
 #include <asm/tlbflush.h>
 #include <asm/io.h>
 
-/*
- * truncate a page used for execute in place
- * functionality is analog to block_truncate_page but does use get_xip_mem
- * to get the page instead of page cache
- */
-int
-xip_truncate_page(struct address_space *mapping, loff_t from)
-{
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
-	unsigned blocksize;
-	unsigned length;
-	void *xip_mem;
-	unsigned long xip_pfn;
-	int err;
-
-	BUG_ON(!mapping->a_ops->get_xip_mem);
-
-	blocksize = 1 << mapping->host->i_blkbits;
-	length = offset & (blocksize - 1);
-
-	/* Block boundary? Nothing to do */
-	if (!length)
-		return 0;
-
-	length = blocksize - length;
-
-	err = mapping->a_ops->get_xip_mem(mapping, index, 0,
-						&xip_mem, &xip_pfn);
-	if (unlikely(err)) {
-		if (err == -ENODATA)
-			/* Hole? No need to truncate */
-			return 0;
-		else
-			return err;
-	}
-	memset(xip_mem + offset, 0, length);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(xip_truncate_page);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
