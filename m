Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 25BA76B00F9
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:19:23 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so7890995pde.28
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 06:19:22 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id gk3si20886893pac.234.2014.02.25.06.19.21
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 06:19:22 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v6 08/22] Replace xip_truncate_page with dax_truncate_page
Date: Tue, 25 Feb 2014 09:18:24 -0500
Message-Id: <1393337918-28265-9-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

It takes a get_block parameter just like nobh_truncate_page() and
block_truncate_page()

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c           | 52 ++++++++++++++++++++++++++++++++++++++++++++++++----
 fs/ext2/inode.c    |  2 +-
 include/linux/fs.h |  4 ++--
 mm/filemap_xip.c   | 40 ----------------------------------------
 4 files changed, 51 insertions(+), 47 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index ebcd8fd..a6a1adc 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -302,13 +302,13 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 }
 
 /**
- * dax_fault - handle a page fault on an XIP file
+ * dax_fault - handle a page fault on a DAX file
  * @vma: The virtual memory area where the fault occurred
  * @vmf: The description of the fault
  * @get_block: The filesystem method used to translate file offsets to blocks
  *
  * When a page fault occurs, filesystems may call this helper in their
- * fault handler for XIP files.
+ * fault handler for DAX files.
  */
 int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			get_block_t get_block)
@@ -326,12 +326,12 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 EXPORT_SYMBOL_GPL(dax_fault);
 
 /**
- * dax_mkwrite - convert a read-only page to read-write in an XIP file
+ * dax_mkwrite - convert a read-only page to read-write in a DAX file
  * @vma: The virtual memory area where the fault occurred
  * @vmf: The description of the fault
  * @get_block: The filesystem method used to translate file offsets to blocks
  *
- * XIP handles reads of holes by adding pages full of zeroes into the
+ * DAX handles reads of holes by adding pages full of zeroes into the
  * mapping.  If the page is subsequenty written to, we have to allocate
  * the page on media and free the page that was in the cache.
  */
@@ -357,3 +357,47 @@ int dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	return result;
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
+		err = dax_get_addr(inode, &bh, &addr);
+		if (err)
+			return err;
+		memset(addr + offset, 0, length);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dax_truncate_page);
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index f128ebf..252481f 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1207,7 +1207,7 @@ static int ext2_setsize(struct inode *inode, loff_t newsize)
 	inode_dio_wait(inode);
 
 	if (IS_DAX(inode))
-		error = xip_truncate_page(inode->i_mapping, newsize);
+		error = dax_truncate_page(inode, newsize, ext2_get_block);
 	else if (test_opt(inode->i_sb, NOBH))
 		error = nobh_truncate_page(inode->i_mapping,
 				newsize, ext2_get_block);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 00ad95e..02eeeb7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2518,13 +2518,13 @@ extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
 #ifdef CONFIG_FS_XIP
-extern int xip_truncate_page(struct address_space *mapping, loff_t from);
+int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
 		loff_t, unsigned segs, get_block_t, dio_iodone_t, int flags);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 int dax_mkwrite(struct vm_area_struct *, struct vm_fault *, get_block_t);
 #else
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
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
