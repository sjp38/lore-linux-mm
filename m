Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCBqYa021407
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:52 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCBq9w512964
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:52 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCBqe9025105
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:52 -0400
Date: Thu, 24 May 2007 08:11:52 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121152.13533.37381.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 004/012] Replace PAGE_CACHE_SIZE with page_data_size()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Replace PAGE_CACHE_SIZE with page_data_size()

Code that zeroes an entire page needs to be aware that tail pages may not
be PAGE_CACHE_SIZE bytes long.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 fs/buffer.c             |   28 ++++++++++++++++------------
 fs/mpage.c              |    4 ++--
 fs/reiserfs/inode.c     |    3 ++-
 include/linux/pagemap.h |   28 ++++++++++++++++++++++++++++
 mm/truncate.c           |    2 +-
 5 files changed, 49 insertions(+), 16 deletions(-)

diff -Nurp linux003/fs/buffer.c linux004/fs/buffer.c
--- linux003/fs/buffer.c	2007-05-21 15:15:32.000000000 -0500
+++ linux004/fs/buffer.c	2007-05-23 22:53:11.000000000 -0500
@@ -875,7 +875,7 @@ struct buffer_head *alloc_page_buffers(s
 
 try_again:
 	head = NULL;
-	offset = PAGE_SIZE;
+	offset = page_data_size(page);
 	while ((offset -= size) >= 0) {
 		bh = alloc_buffer_head(GFP_NOFS);
 		if (!bh)
@@ -1411,7 +1411,7 @@ void set_bh_page(struct buffer_head *bh,
 		struct page *page, unsigned long offset)
 {
 	bh->b_page = page;
-	BUG_ON(offset >= PAGE_SIZE);
+	BUG_ON(offset >= page_data_size(page));
 	if (PageHighMem(page))
 		/*
 		 * This catches illegal uses and preserves the offset:
@@ -1752,8 +1752,10 @@ static int __block_prepare_write(struct 
 	struct buffer_head *bh, *head, *wait[2], **wait_bh=wait;
 
 	BUG_ON(!PageLocked(page));
-	BUG_ON(from > PAGE_CACHE_SIZE);
+	BUG_ON(from > page_data_size(page));
 	BUG_ON(to > PAGE_CACHE_SIZE);
+	if (to > page_data_size(page))
+		to = page_data_size(page);
 	BUG_ON(from > to);
 
 	blocksize = 1 << inode->i_blkbits;
@@ -2098,12 +2100,14 @@ int cont_prepare_write(struct page *page
 			(*bytes)++;
 		}
 		status = __block_prepare_write(inode, new_page, zerofrom,
-						PAGE_CACHE_SIZE, get_block);
+						page_data_size(new_page),
+						get_block);
 		if (status)
 			goto out_unmap;
-		zero_user_page(page, zerofrom, PAGE_CACHE_SIZE - zerofrom,
-				KM_USER0);
-		generic_commit_write(NULL, new_page, zerofrom, PAGE_CACHE_SIZE);
+		zero_user_page(page, zerofrom,
+			       page_data_size(new_page) - zerofrom, KM_USER0);
+		generic_commit_write(NULL, new_page, zerofrom,
+				     page_data_size(new_page));
 		unlock_page(new_page);
 		page_cache_release(new_page);
 	}
@@ -2234,7 +2238,7 @@ int nobh_prepare_write(struct page *page
 	 * page is fully mapped-to-disk.
 	 */
 	for (block_start = 0, block_in_page = 0;
-		  block_start < PAGE_CACHE_SIZE;
+		  block_start < page_data_size(page);
 		  block_in_page++, block_start += blocksize) {
 		unsigned block_end = block_start + blocksize;
 		int create;
@@ -2328,7 +2332,7 @@ failed:
 	 * Error recovery is pretty slack.  Clear the page and mark it dirty
 	 * so we'll later zero out any blocks which _were_ allocated.
 	 */
-	zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+	zero_user_page(page, 0, page_data_size(page), KM_USER0);
 	SetPageUptodate(page);
 	set_page_dirty(page);
 	return ret;
@@ -2397,7 +2401,7 @@ int nobh_writepage(struct page *page, ge
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_page(page, offset, PAGE_CACHE_SIZE - offset, KM_USER0);
+	zero_user_page(page, offset, page_data_size(page) - offset, KM_USER0);
 out:
 	ret = mpage_writepage(page, get_block, wbc);
 	if (ret == -EAGAIN)
@@ -2431,7 +2435,7 @@ int nobh_truncate_page(struct address_sp
 	to = (offset + blocksize) & ~(blocksize - 1);
 	ret = a_ops->prepare_write(NULL, page, offset, to);
 	if (ret == 0) {
-		zero_user_page(page, offset, PAGE_CACHE_SIZE - offset,
+		zero_user_page(page, offset, page_data_size(page) - offset,
 				KM_USER0);
 		/*
 		 * It would be more correct to call aops->commit_write()
@@ -2557,7 +2561,7 @@ int block_write_full_page(struct page *p
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_page(page, offset, PAGE_CACHE_SIZE - offset, KM_USER0);
+	zero_user_page(page, offset, page_data_size(page) - offset, KM_USER0);
 	return __block_write_full_page(inode, page, get_block, wbc);
 }
 
diff -Nurp linux003/fs/mpage.c linux004/fs/mpage.c
--- linux003/fs/mpage.c	2007-05-21 15:15:35.000000000 -0500
+++ linux004/fs/mpage.c	2007-05-23 22:53:11.000000000 -0500
@@ -285,7 +285,7 @@ do_mpage_readpage(struct bio *bio, struc
 
 	if (first_hole != blocks_per_page) {
 		zero_user_page(page, first_hole << blkbits,
-				PAGE_CACHE_SIZE - (first_hole << blkbits),
+				page_data_size(page) - (first_hole << blkbits),
 				KM_USER0);
 		if (first_hole == 0) {
 			SetPageUptodate(page);
@@ -585,7 +585,7 @@ page_is_mapped:
 
 		if (page->index > end_index || !offset)
 			goto confused;
-		zero_user_page(page, offset, PAGE_CACHE_SIZE - offset,
+		zero_user_page(page, offset, page_data_size(page) - offset,
 				KM_USER0);
 	}
 
diff -Nurp linux003/fs/reiserfs/inode.c linux004/fs/reiserfs/inode.c
--- linux003/fs/reiserfs/inode.c	2007-05-21 15:15:36.000000000 -0500
+++ linux004/fs/reiserfs/inode.c	2007-05-23 22:53:11.000000000 -0500
@@ -2373,7 +2373,8 @@ static int reiserfs_write_full_page(stru
 			unlock_page(page);
 			return 0;
 		}
-		zero_user_page(page, last_offset, PAGE_CACHE_SIZE - last_offset, KM_USER0);
+		zero_user_page(page, last_offset,
+			       page_data_size(page) - last_offset, KM_USER0);
 	}
 	bh = head;
 	block = page->index << (PAGE_CACHE_SHIFT - s->s_blocksize_bits);
diff -Nurp linux003/include/linux/pagemap.h linux004/include/linux/pagemap.h
--- linux003/include/linux/pagemap.h	2007-05-21 15:15:44.000000000 -0500
+++ linux004/include/linux/pagemap.h	2007-05-23 22:53:11.000000000 -0500
@@ -58,6 +58,34 @@ static inline void mapping_set_gfp_mask(
 #define PAGE_CACHE_MASK		PAGE_MASK
 #define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)
 
+#ifdef CONFIG_VM_FILE_TAILS
+static inline pgoff_t file_tail_index(struct address_space *mapping)
+{
+	return (pgoff_t) (i_size_read(mapping->host) >> PAGE_CACHE_SHIFT);
+}
+
+/*
+ * Round up to file system block size so that we can read
+ * directly into the buffer
+ */
+static inline int file_tail_buf_size(struct address_space *mapping)
+{
+	int block_mask = (1 << mapping->host->i_blkbits) - 1;
+	int tail_bytes = i_size_read(mapping->host) & (PAGE_CACHE_SIZE - 1);
+	return ALIGN(tail_bytes, block_mask);
+}
+
+static inline int page_data_size(struct page *page)
+{
+	if (PageFileTail(page))
+		return file_tail_buf_size(page->mapping);
+	else
+		return PAGE_CACHE_SIZE;
+}
+#else
+#define page_data_size(page) PAGE_CACHE_SIZE
+#endif
+
 #define page_cache_get(page)		get_page(page)
 #define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
diff -Nurp linux003/mm/truncate.c linux004/mm/truncate.c
--- linux003/mm/truncate.c	2007-05-21 15:15:48.000000000 -0500
+++ linux004/mm/truncate.c	2007-05-23 22:53:11.000000000 -0500
@@ -47,7 +47,7 @@ void do_invalidatepage(struct page *page
 
 static inline void truncate_partial_page(struct page *page, unsigned partial)
 {
-	zero_user_page(page, partial, PAGE_CACHE_SIZE - partial, KM_USER0);
+	zero_user_page(page, partial, page_data_size(page) - partial, KM_USER0);
 	if (PagePrivate(page))
 		do_invalidatepage(page, partial);
 }

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
