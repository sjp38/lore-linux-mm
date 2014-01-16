Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B3CA16B006E
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:13 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id r10so1873189pdi.6
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:13 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sa6si5331861pbb.173.2014.01.15.17.25.11
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:25:11 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 17/22] xip: Add xip_zero_page_range
Date: Wed, 15 Jan 2014 20:24:35 -0500
Message-Id: <022dd796862790207b9734143cc5fe85138bc494.1389779962.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

This new function allows us to support hole-punch for XIP files by zeroing
a partial page, as opposed to the xip_truncate_page() function which can
only truncate to the end of the page.  Reimplement xip_truncate_page() as
a macro that calls xip_zero_page_range().

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
[ported to 3.13-rc2]
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 Documentation/filesystems/xip.txt |  1 +
 fs/xip.c                          | 15 +++++++++------
 include/linux/fs.h                | 11 +++++++++--
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/Documentation/filesystems/xip.txt b/Documentation/filesystems/xip.txt
index 520e73a..a8bccb6 100644
--- a/Documentation/filesystems/xip.txt
+++ b/Documentation/filesystems/xip.txt
@@ -55,6 +55,7 @@ Filesystem support consists of
   for fault and page_mkwrite (which should probably call xip_fault() and
   xip_mkwrite(), passing the appropriate get_block() callback)
 - calling xip_truncate_page() instead of block_truncate_page() for XIP files
+- calling xip_zero_page_range() instead of zero_user() for XIP files
 - ensuring that there is sufficient locking between reads, writes,
   truncates and page faults
 
diff --git a/fs/xip.c b/fs/xip.c
index 3f5f081..9087e0f 100644
--- a/fs/xip.c
+++ b/fs/xip.c
@@ -357,13 +357,16 @@ int xip_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 EXPORT_SYMBOL_GPL(xip_mkwrite);
 
 /**
- * xip_truncate_page - handle a partial page being truncated in an XIP file
+ * xip_zero_page_range - zero a range within a page of an XIP file
  * @inode: The file being truncated
  * @from: The file offset that is being truncated to
+ * @length: The number of bytes to zero
  * @get_block: The filesystem method used to translate file offsets to blocks
  *
- * Similar to block_truncate_page(), this function can be called by a
- * filesystem when it is truncating an XIP file to handle the partial page.
+ * This function can be called by a filesystem when it is zeroing part of a
+ * page in an XIP file.  This is intended for hole-punch operations.  If
+ * you are truncating a file, the helper function xip_truncate_page() may be
+ * more convenient.
  *
  * We work in terms of PAGE_CACHE_SIZE here for commonality with
  * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
@@ -371,12 +374,12 @@ EXPORT_SYMBOL_GPL(xip_mkwrite);
  * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
  * since the file might be mmaped.
  */
-int xip_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
+int xip_zero_page_range(struct inode *inode, loff_t from, unsigned length,
+							get_block_t get_block)
 {
 	struct buffer_head bh;
 	pgoff_t index = from >> PAGE_CACHE_SHIFT;
 	unsigned offset = from & (PAGE_CACHE_SIZE-1);
-	unsigned length = PAGE_CACHE_ALIGN(from) - from;
 	int err;
 
 	/* Block boundary? Nothing to do */
@@ -398,4 +401,4 @@ int xip_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(xip_truncate_page);
+EXPORT_SYMBOL_GPL(xip_zero_page_range);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c93671a..04338a3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2509,7 +2509,7 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
 
 #ifdef CONFIG_FS_XIP
 int xip_clear_blocks(struct inode *, sector_t block, long size);
-int xip_truncate_page(struct inode *, loff_t from, get_block_t);
+int xip_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 ssize_t xip_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
 		loff_t, unsigned segs, get_block_t, dio_iodone_t, int flags);
 int xip_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
@@ -2520,7 +2520,8 @@ static inline int xip_clear_blocks(struct inode *i, sector_t blk, long sz)
 	return 0;
 }
 
-static inline int xip_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
+static inline int xip_zero_page_range(struct inode *inode, loff_t from,
+						unsigned len, get_block_t gb)
 {
 	return 0;
 }
@@ -2533,6 +2534,12 @@ static inline ssize_t xip_do_io(int rw, struct kiocb *iocb, struct inode *inode,
 }
 #endif
 
+/* Can't be a function because PAGE_CACHE_ALIGN is defined in pagemap.h */
+#define xip_truncate_page(inode, from, get_block)	\
+	xip_zero_page_range(inode, from, PAGE_CACHE_ALIGN(from) - from, \
+					get_block)
+
+
 #ifdef CONFIG_BLOCK
 typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,
 			    loff_t file_offset);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
