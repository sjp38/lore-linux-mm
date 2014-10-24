Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 148946B0095
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 17:22:03 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y10so2101789pdj.23
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 14:22:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id cd13si5025327pdb.188.2014.10.24.14.22.01
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 14:22:02 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v12 09/20] dax,ext2: Replace xip_truncate_page with dax_truncate_page
Date: Fri, 24 Oct 2014 17:20:41 -0400
Message-Id: <1414185652-28663-10-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>

It takes a get_block parameter just like nobh_truncate_page() and
block_truncate_page()

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
---
 fs/dax.c           | 44 ++++++++++++++++++++++++++++++++++++++++++++
 fs/ext2/inode.c    |  2 +-
 include/linux/fs.h | 10 +---------
 mm/filemap_xip.c   | 40 ----------------------------------------
 4 files changed, 46 insertions(+), 50 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 19b665e..e838ec8 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -458,3 +458,47 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	return result;
 }
 EXPORT_SYMBOL_GPL(dax_fault);
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
index 84ef250..d3787b5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2476,18 +2476,10 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
 ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
 		loff_t, get_block_t, dio_iodone_t, int flags);
 int dax_clear_blocks(struct inode *, sector_t block, long size);
+int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 #define dax_mkwrite(vma, vmf, gb)	dax_fault(vma, vmf, gb)
 
-#ifdef CONFIG_FS_XIP
-extern int xip_truncate_page(struct address_space *mapping, loff_t from);
-#else
-static inline int xip_truncate_page(struct address_space *mapping, loff_t from)
-{
-	return 0;
-}
-#endif
-
 #ifdef CONFIG_BLOCK
 typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,
 			    loff_t file_offset);
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
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
