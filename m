Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 023E56B005C
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 16:34:10 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id ft15so11379579pdb.9
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 13:34:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id m5si5535291pdi.216.2014.09.25.13.34.04
        for <linux-mm@kvack.org>;
        Thu, 25 Sep 2014 13:34:04 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v11 19/21] dax: Add dax_zero_page_range
Date: Thu, 25 Sep 2014 16:33:36 -0400
Message-Id: <1411677218-29146-20-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

This new function allows us to support hole-punch for DAX files by zeroing
a partial page, as opposed to the dax_truncate_page() function which can
only truncate to the end of the page.  Reimplement dax_truncate_page() to
call dax_zero_page_range().

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
[ported to 3.13-rc2]
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 Documentation/filesystems/dax.txt |  1 +
 fs/dax.c                          | 36 +++++++++++++++++++++++++++++++-----
 include/linux/fs.h                |  7 +++++++
 3 files changed, 39 insertions(+), 5 deletions(-)

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
index 6801be7..91b7561 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -462,13 +462,16 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
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
@@ -476,17 +479,18 @@ EXPORT_SYMBOL_GPL(dax_fault);
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
 	if (!length)
 		return 0;
+	BUG_ON((offset + length) > PAGE_CACHE_SIZE);
 
 	memset(&bh, 0, sizeof(bh));
 	bh.b_size = PAGE_CACHE_SIZE;
@@ -503,4 +507,26 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(dax_zero_page_range);
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
+	unsigned length = PAGE_CACHE_ALIGN(from) - from;
+	return dax_zero_page_range(inode, from, length, get_block);
+}
 EXPORT_SYMBOL_GPL(dax_truncate_page);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e6b48cc..105d0f0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2490,6 +2490,7 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
 
 #ifdef CONFIG_FS_DAX
 int dax_clear_blocks(struct inode *, sector_t block, long size);
+int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
 		loff_t, get_block_t, dio_iodone_t, int flags);
@@ -2506,6 +2507,12 @@ static inline int dax_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
 	return 0;
 }
 
+static inline int dax_zero_page_range(struct inode *i, loff_t frm,
+						unsigned len, get_block_t gb)
+{
+	return 0;
+}
+
 static inline ssize_t dax_do_io(int rw, struct kiocb *iocb,
 		struct inode *inode, struct iov_iter *iter, loff_t pos,
 		get_block_t get_block, dio_iodone_t end_io, int flags)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
