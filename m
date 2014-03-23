Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 53D1A6B0104
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:09:03 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so4416126pde.15
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:09:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qe9si7627396pbb.141.2014.03.23.12.09.01
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:09:01 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v7 19/22] ext4: Make ext4_block_zero_page_range static
Date: Sun, 23 Mar 2014 15:08:45 -0400
Message-Id: <6ae0bcd05c2e114d3c4a7803415b6c2c8a8dadd7.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

It's only called within inode.c, so make it static, remove its prototype
from ext4.h and move it above all of its callers so it doesn't need a
prototype within inode.c.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/ext4/ext4.h  |  2 --
 fs/ext4/inode.c | 42 +++++++++++++++++++++---------------------
 2 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index d3a534f..e025c29 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2133,8 +2133,6 @@ extern int ext4_writepage_trans_blocks(struct inode *);
 extern int ext4_chunk_trans_blocks(struct inode *, int nrblocks);
 extern int ext4_block_truncate_page(handle_t *handle,
 		struct address_space *mapping, loff_t from);
-extern int ext4_block_zero_page_range(handle_t *handle,
-		struct address_space *mapping, loff_t from, loff_t length);
 extern int ext4_zero_partial_blocks(handle_t *handle, struct inode *inode,
 			     loff_t lstart, loff_t lend);
 extern int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 6e39895..ce7341c 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3312,33 +3312,13 @@ void ext4_set_aops(struct inode *inode)
 }
 
 /*
- * ext4_block_truncate_page() zeroes out a mapping from file offset `from'
- * up to the end of the block which corresponds to `from'.
- * This required during truncate. We need to physically zero the tail end
- * of that block so it doesn't yield old data if the file is later grown.
- */
-int ext4_block_truncate_page(handle_t *handle,
-		struct address_space *mapping, loff_t from)
-{
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
-	unsigned length;
-	unsigned blocksize;
-	struct inode *inode = mapping->host;
-
-	blocksize = inode->i_sb->s_blocksize;
-	length = blocksize - (offset & (blocksize - 1));
-
-	return ext4_block_zero_page_range(handle, mapping, from, length);
-}
-
-/*
  * ext4_block_zero_page_range() zeros out a mapping of length 'length'
  * starting from file offset 'from'.  The range to be zero'd must
  * be contained with in one block.  If the specified range exceeds
  * the end of the block it will be shortened to end of the block
  * that cooresponds to 'from'
  */
-int ext4_block_zero_page_range(handle_t *handle,
+static int ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
 	ext4_fsblk_t index = from >> PAGE_CACHE_SHIFT;
@@ -3428,6 +3408,26 @@ unlock:
 	return err;
 }
 
+/*
+ * ext4_block_truncate_page() zeroes out a mapping from file offset `from'
+ * up to the end of the block which corresponds to `from'.
+ * This required during truncate. We need to physically zero the tail end
+ * of that block so it doesn't yield old data if the file is later grown.
+ */
+int ext4_block_truncate_page(handle_t *handle,
+		struct address_space *mapping, loff_t from)
+{
+	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	unsigned length;
+	unsigned blocksize;
+	struct inode *inode = mapping->host;
+
+	blocksize = inode->i_sb->s_blocksize;
+	length = blocksize - (offset & (blocksize - 1));
+
+	return ext4_block_zero_page_range(handle, mapping, from, length);
+}
+
 int ext4_zero_partial_blocks(handle_t *handle, struct inode *inode,
 			     loff_t lstart, loff_t length)
 {
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
