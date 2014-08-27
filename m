Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DBFDE6B0075
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 00:35:05 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so23837118pde.11
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 21:35:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bp16si7391203pdb.34.2014.08.26.21.35.04
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 21:35:04 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v10 19/21] xip: Add xip_zero_page_range
Date: Tue, 26 Aug 2014 23:45:39 -0400
Message-Id: <80c8efc903971eb3a338f262fbd3ef135db63eb0.1409110741.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1409110741.git.matthew.r.wilcox@intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1409110741.git.matthew.r.wilcox@intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com, Ross Zwisler <ross.zwisler@linux.intel.com>

This new function allows us to support hole-punch for XIP files by zeroing
a partial page, as opposed to the xip_truncate_page() function which can
only truncate to the end of the page.  Reimplement xip_truncate_page() as
a macro that calls xip_zero_page_range().

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
[ported to 3.13-rc2]
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 Documentation/filesystems/dax.txt |  1 +
 fs/dax.c                          | 20 ++++++++++++++------
 include/linux/fs.h                |  9 ++++++++-
 3 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/Documentation/filesystems/dax.txt b/Documentation/filesystems/dax.txt
index 635adaa..ebcd97f 100644
--- a/Documentation/filesystems/dax.txt
+++ b/Documentation/filesystems/dax.txt
@@ -62,6 +62,7 @@ Filesystem support consists of
   for fault and page_mkwrite (which should probably call dax_fault() and
   dax_mkwrite(), passing the appropriate get_block() callback)
 - calling dax_truncate_page() instead of block_truncate_page() for DAX files
+- calling dax_zero_page_range() instead of zero_user() for DAX files
 - ensuring that there is sufficient locking between reads, writes,
   truncates and page faults
 
diff --git a/fs/dax.c b/fs/dax.c
index d54f7d3..96c4fed 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -445,13 +445,16 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 EXPORT_SYMBOL_GPL(dax_fault);
 
 /**
- * dax_truncate_page - handle a partial page being truncated in a DAX file
+ * dax_zero_page_range - zero a range within a page of a DAX file
  * @inode: The file being truncated
  * @from: The file offset that is being truncated to
+ * @length: The number of bytes to zero
  * @get_block: The filesystem method used to translate file offsets to blocks
  *
- * Similar to block_truncate_page(), this function can be called by a
- * filesystem when it is truncating an DAX file to handle the partial page.
+ * This function can be called by a filesystem when it is zeroing part of a
+ * page in a DAX file.  This is intended for hole-punch operations.  If
+ * you are truncating a file, the helper function dax_truncate_page() may be
+ * more convenient.
  *
  * We work in terms of PAGE_CACHE_SIZE here for commonality with
  * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
@@ -459,12 +462,12 @@ EXPORT_SYMBOL_GPL(dax_fault);
  * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
  * since the file might be mmaped.
  */
-int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
+int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
+							get_block_t get_block)
 {
 	struct buffer_head bh;
 	pgoff_t index = from >> PAGE_CACHE_SHIFT;
 	unsigned offset = from & (PAGE_CACHE_SIZE-1);
-	unsigned length = PAGE_CACHE_ALIGN(from) - from;
 	int err;
 
 	/* Block boundary? Nothing to do */
@@ -481,9 +484,14 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
 		if (err < 0)
 			return err;
+		/*
+		 * ext4 sometimes asks to zero past the end of a block.  It
+		 * really just wants to zero to the end of the block.
+		 */
+		length = min_t(unsigned, length, PAGE_CACHE_SIZE - offset);
 		memset(addr + offset, 0, length);
 	}
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(dax_truncate_page);
+EXPORT_SYMBOL_GPL(dax_zero_page_range);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e6b48cc..b0078df 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2490,6 +2490,7 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
 
 #ifdef CONFIG_FS_DAX
 int dax_clear_blocks(struct inode *, sector_t block, long size);
+int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
 		loff_t, get_block_t, dio_iodone_t, int flags);
@@ -2501,7 +2502,8 @@ static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
 	return 0;
 }
 
-static inline int dax_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
+static inline int dax_zero_page_range(struct inode *inode, loff_t from,
+						unsigned len, get_block_t gb)
 {
 	return 0;
 }
@@ -2514,6 +2516,11 @@ static inline ssize_t dax_do_io(int rw, struct kiocb *iocb,
 }
 #endif
 
+/* Can't be a function because PAGE_CACHE_SIZE is defined in pagemap.h */
+#define dax_truncate_page(inode, from, get_block)	\
+	dax_zero_page_range(inode, from, PAGE_CACHE_SIZE, get_block)
+
+
 #ifdef CONFIG_BLOCK
 typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,
 			    loff_t file_offset);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
