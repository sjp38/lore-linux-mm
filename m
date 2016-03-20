Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7F32E828F4
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:03 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id u190so238305360pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:03 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id oi7si1467849pab.183.2016.03.20.11.41.51
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 58/71] reiserfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:05 +0300
Message-Id: <1458499278-1516-59-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/reiserfs/file.c            |  4 ++--
 fs/reiserfs/inode.c           | 44 +++++++++++++++++++++----------------------
 fs/reiserfs/ioctl.c           |  4 ++--
 fs/reiserfs/journal.c         |  6 +++---
 fs/reiserfs/stree.c           |  4 ++--
 fs/reiserfs/tail_conversion.c |  4 ++--
 fs/reiserfs/xattr.c           | 18 +++++++++---------
 7 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/fs/reiserfs/file.c b/fs/reiserfs/file.c
index 9424a4ba93a9..389773711de4 100644
--- a/fs/reiserfs/file.c
+++ b/fs/reiserfs/file.c
@@ -180,11 +180,11 @@ int reiserfs_commit_page(struct inode *inode, struct page *page,
 	int partial = 0;
 	unsigned blocksize;
 	struct buffer_head *bh, *head;
-	unsigned long i_size_index = inode->i_size >> PAGE_CACHE_SHIFT;
+	unsigned long i_size_index = inode->i_size >> PAGE_SHIFT;
 	int new;
 	int logit = reiserfs_file_data_log(inode);
 	struct super_block *s = inode->i_sb;
-	int bh_per_page = PAGE_CACHE_SIZE / s->s_blocksize;
+	int bh_per_page = PAGE_SIZE / s->s_blocksize;
 	struct reiserfs_transaction_handle th;
 	int ret = 0;
 
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index ae9e5b308cf9..d5c2e9c865de 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -386,7 +386,7 @@ static int _get_block_create_0(struct inode *inode, sector_t block,
 		goto finished;
 	}
 	/* read file tail into part of page */
-	offset = (cpu_key_k_offset(&key) - 1) & (PAGE_CACHE_SIZE - 1);
+	offset = (cpu_key_k_offset(&key) - 1) & (PAGE_SIZE - 1);
 	copy_item_head(&tmp_ih, ih);
 
 	/*
@@ -587,10 +587,10 @@ static int convert_tail_for_hole(struct inode *inode,
 		return -EIO;
 
 	/* always try to read until the end of the block */
-	tail_start = tail_offset & (PAGE_CACHE_SIZE - 1);
+	tail_start = tail_offset & (PAGE_SIZE - 1);
 	tail_end = (tail_start | (bh_result->b_size - 1)) + 1;
 
-	index = tail_offset >> PAGE_CACHE_SHIFT;
+	index = tail_offset >> PAGE_SHIFT;
 	/*
 	 * hole_page can be zero in case of direct_io, we are sure
 	 * that we cannot get here if we write with O_DIRECT into tail page
@@ -629,7 +629,7 @@ static int convert_tail_for_hole(struct inode *inode,
 unlock:
 	if (tail_page != hole_page) {
 		unlock_page(tail_page);
-		page_cache_release(tail_page);
+		put_page(tail_page);
 	}
 out:
 	return retval;
@@ -2189,11 +2189,11 @@ static int grab_tail_page(struct inode *inode,
 	 * we want the page with the last byte in the file,
 	 * not the page that will hold the next byte for appending
 	 */
-	unsigned long index = (inode->i_size - 1) >> PAGE_CACHE_SHIFT;
+	unsigned long index = (inode->i_size - 1) >> PAGE_SHIFT;
 	unsigned long pos = 0;
 	unsigned long start = 0;
 	unsigned long blocksize = inode->i_sb->s_blocksize;
-	unsigned long offset = (inode->i_size) & (PAGE_CACHE_SIZE - 1);
+	unsigned long offset = (inode->i_size) & (PAGE_SIZE - 1);
 	struct buffer_head *bh;
 	struct buffer_head *head;
 	struct page *page;
@@ -2251,7 +2251,7 @@ out:
 
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return error;
 }
 
@@ -2265,7 +2265,7 @@ int reiserfs_truncate_file(struct inode *inode, int update_timestamps)
 {
 	struct reiserfs_transaction_handle th;
 	/* we want the offset for the first byte after the end of the file */
-	unsigned long offset = inode->i_size & (PAGE_CACHE_SIZE - 1);
+	unsigned long offset = inode->i_size & (PAGE_SIZE - 1);
 	unsigned blocksize = inode->i_sb->s_blocksize;
 	unsigned length;
 	struct page *page = NULL;
@@ -2345,7 +2345,7 @@ int reiserfs_truncate_file(struct inode *inode, int update_timestamps)
 			}
 		}
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	reiserfs_write_unlock(inode->i_sb);
@@ -2354,7 +2354,7 @@ int reiserfs_truncate_file(struct inode *inode, int update_timestamps)
 out:
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	reiserfs_write_unlock(inode->i_sb);
@@ -2426,7 +2426,7 @@ research:
 	} else if (is_direct_le_ih(ih)) {
 		char *p;
 		p = page_address(bh_result->b_page);
-		p += (byte_offset - 1) & (PAGE_CACHE_SIZE - 1);
+		p += (byte_offset - 1) & (PAGE_SIZE - 1);
 		copy_size = ih_item_len(ih) - pos_in_item;
 
 		fs_gen = get_generation(inode->i_sb);
@@ -2525,7 +2525,7 @@ static int reiserfs_write_full_page(struct page *page,
 				    struct writeback_control *wbc)
 {
 	struct inode *inode = page->mapping->host;
-	unsigned long end_index = inode->i_size >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = inode->i_size >> PAGE_SHIFT;
 	int error = 0;
 	unsigned long block;
 	sector_t last_block;
@@ -2535,7 +2535,7 @@ static int reiserfs_write_full_page(struct page *page,
 	int checked = PageChecked(page);
 	struct reiserfs_transaction_handle th;
 	struct super_block *s = inode->i_sb;
-	int bh_per_page = PAGE_CACHE_SIZE / s->s_blocksize;
+	int bh_per_page = PAGE_SIZE / s->s_blocksize;
 	th.t_trans_id = 0;
 
 	/* no logging allowed when nonblocking or from PF_MEMALLOC */
@@ -2564,16 +2564,16 @@ static int reiserfs_write_full_page(struct page *page,
 	if (page->index >= end_index) {
 		unsigned last_offset;
 
-		last_offset = inode->i_size & (PAGE_CACHE_SIZE - 1);
+		last_offset = inode->i_size & (PAGE_SIZE - 1);
 		/* no file contents in this page */
 		if (page->index >= end_index + 1 || !last_offset) {
 			unlock_page(page);
 			return 0;
 		}
-		zero_user_segment(page, last_offset, PAGE_CACHE_SIZE);
+		zero_user_segment(page, last_offset, PAGE_SIZE);
 	}
 	bh = head;
-	block = page->index << (PAGE_CACHE_SHIFT - s->s_blocksize_bits);
+	block = page->index << (PAGE_SHIFT - s->s_blocksize_bits);
 	last_block = (i_size_read(inode) - 1) >> inode->i_blkbits;
 	/* first map all the buffers, logging any direct items we find */
 	do {
@@ -2774,7 +2774,7 @@ static int reiserfs_write_begin(struct file *file,
 		*fsdata = (void *)(unsigned long)flags;
 	}
 
-	index = pos >> PAGE_CACHE_SHIFT;
+	index = pos >> PAGE_SHIFT;
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
@@ -2822,7 +2822,7 @@ static int reiserfs_write_begin(struct file *file,
 	}
 	if (ret) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		/* Truncate allocated blocks */
 		reiserfs_truncate_failed_write(inode);
 	}
@@ -2909,7 +2909,7 @@ static int reiserfs_write_end(struct file *file, struct address_space *mapping,
 	else
 		th = NULL;
 
-	start = pos & (PAGE_CACHE_SIZE - 1);
+	start = pos & (PAGE_SIZE - 1);
 	if (unlikely(copied < len)) {
 		if (!PageUptodate(page))
 			copied = 0;
@@ -2974,7 +2974,7 @@ out:
 	if (locked)
 		reiserfs_write_unlock(inode->i_sb);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (pos + len > inode->i_size)
 		reiserfs_truncate_failed_write(inode);
@@ -2996,7 +2996,7 @@ int reiserfs_commit_write(struct file *f, struct page *page,
 			  unsigned from, unsigned to)
 {
 	struct inode *inode = page->mapping->host;
-	loff_t pos = ((loff_t) page->index << PAGE_CACHE_SHIFT) + to;
+	loff_t pos = ((loff_t) page->index << PAGE_SHIFT) + to;
 	int ret = 0;
 	int update_sd = 0;
 	struct reiserfs_transaction_handle *th = NULL;
@@ -3181,7 +3181,7 @@ static void reiserfs_invalidatepage(struct page *page, unsigned int offset,
 	struct inode *inode = page->mapping->host;
 	unsigned int curr_off = 0;
 	unsigned int stop = offset + length;
-	int partial_page = (offset || length < PAGE_CACHE_SIZE);
+	int partial_page = (offset || length < PAGE_SIZE);
 	int ret = 1;
 
 	BUG_ON(!PageLocked(page));
diff --git a/fs/reiserfs/ioctl.c b/fs/reiserfs/ioctl.c
index 036a1fc0a8c3..57045f423893 100644
--- a/fs/reiserfs/ioctl.c
+++ b/fs/reiserfs/ioctl.c
@@ -203,7 +203,7 @@ int reiserfs_unpack(struct inode *inode, struct file *filp)
 	 * __reiserfs_write_begin on that page.  This will force a
 	 * reiserfs_get_block to unpack the tail for us.
 	 */
-	index = inode->i_size >> PAGE_CACHE_SHIFT;
+	index = inode->i_size >> PAGE_SHIFT;
 	mapping = inode->i_mapping;
 	page = grab_cache_page(mapping, index);
 	retval = -ENOMEM;
@@ -221,7 +221,7 @@ int reiserfs_unpack(struct inode *inode, struct file *filp)
 
 out_unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 out:
 	inode_unlock(inode);
diff --git a/fs/reiserfs/journal.c b/fs/reiserfs/journal.c
index 44c2bdced1c8..2ace90e981f0 100644
--- a/fs/reiserfs/journal.c
+++ b/fs/reiserfs/journal.c
@@ -599,18 +599,18 @@ static int journal_list_still_alive(struct super_block *s,
  * This does a check to see if the buffer belongs to one of these
  * lost pages before doing the final put_bh.  If page->mapping was
  * null, it tries to free buffers on the page, which should make the
- * final page_cache_release drop the page from the lru.
+ * final put_page drop the page from the lru.
  */
 static void release_buffer_page(struct buffer_head *bh)
 {
 	struct page *page = bh->b_page;
 	if (!page->mapping && trylock_page(page)) {
-		page_cache_get(page);
+		get_page(page);
 		put_bh(bh);
 		if (!page->mapping)
 			try_to_free_buffers(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	} else {
 		put_bh(bh);
 	}
diff --git a/fs/reiserfs/stree.c b/fs/reiserfs/stree.c
index 24cbe013240f..5feacd689241 100644
--- a/fs/reiserfs/stree.c
+++ b/fs/reiserfs/stree.c
@@ -1342,7 +1342,7 @@ int reiserfs_delete_item(struct reiserfs_transaction_handle *th,
 		 */
 
 		data = kmap_atomic(un_bh->b_page);
-		off = ((le_ih_k_offset(&s_ih) - 1) & (PAGE_CACHE_SIZE - 1));
+		off = ((le_ih_k_offset(&s_ih) - 1) & (PAGE_SIZE - 1));
 		memcpy(data + off,
 		       ih_item_body(PATH_PLAST_BUFFER(path), &s_ih),
 		       ret_value);
@@ -1511,7 +1511,7 @@ static void unmap_buffers(struct page *page, loff_t pos)
 
 	if (page) {
 		if (page_has_buffers(page)) {
-			tail_index = pos & (PAGE_CACHE_SIZE - 1);
+			tail_index = pos & (PAGE_SIZE - 1);
 			cur_index = 0;
 			head = page_buffers(page);
 			bh = head;
diff --git a/fs/reiserfs/tail_conversion.c b/fs/reiserfs/tail_conversion.c
index f41e19b4bb42..2d5489b0a269 100644
--- a/fs/reiserfs/tail_conversion.c
+++ b/fs/reiserfs/tail_conversion.c
@@ -151,7 +151,7 @@ int direct2indirect(struct reiserfs_transaction_handle *th, struct inode *inode,
 	 */
 	if (up_to_date_bh) {
 		unsigned pgoff =
-		    (tail_offset + total_tail - 1) & (PAGE_CACHE_SIZE - 1);
+		    (tail_offset + total_tail - 1) & (PAGE_SIZE - 1);
 		char *kaddr = kmap_atomic(up_to_date_bh->b_page);
 		memset(kaddr + pgoff, 0, blk_size - total_tail);
 		kunmap_atomic(kaddr);
@@ -271,7 +271,7 @@ int indirect2direct(struct reiserfs_transaction_handle *th,
 	 * the page was locked and this part of the page was up to date when
 	 * indirect2direct was called, so we know the bytes are still valid
 	 */
-	tail = tail + (pos & (PAGE_CACHE_SIZE - 1));
+	tail = tail + (pos & (PAGE_SIZE - 1));
 
 	PATH_LAST_POSITION(path)++;
 
diff --git a/fs/reiserfs/xattr.c b/fs/reiserfs/xattr.c
index 57e0b2310532..28f5f8b11370 100644
--- a/fs/reiserfs/xattr.c
+++ b/fs/reiserfs/xattr.c
@@ -415,7 +415,7 @@ out:
 static inline void reiserfs_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static struct page *reiserfs_get_page(struct inode *dir, size_t n)
@@ -427,7 +427,7 @@ static struct page *reiserfs_get_page(struct inode *dir, size_t n)
 	 * and an unlink/rmdir has just occurred - GFP_NOFS avoids this
 	 */
 	mapping_set_gfp_mask(mapping, GFP_NOFS);
-	page = read_mapping_page(mapping, n >> PAGE_CACHE_SHIFT, NULL);
+	page = read_mapping_page(mapping, n >> PAGE_SHIFT, NULL);
 	if (!IS_ERR(page)) {
 		kmap(page);
 		if (PageError(page))
@@ -526,10 +526,10 @@ reiserfs_xattr_set_handle(struct reiserfs_transaction_handle *th,
 	while (buffer_pos < buffer_size || buffer_pos == 0) {
 		size_t chunk;
 		size_t skip = 0;
-		size_t page_offset = (file_pos & (PAGE_CACHE_SIZE - 1));
+		size_t page_offset = (file_pos & (PAGE_SIZE - 1));
 
-		if (buffer_size - buffer_pos > PAGE_CACHE_SIZE)
-			chunk = PAGE_CACHE_SIZE;
+		if (buffer_size - buffer_pos > PAGE_SIZE)
+			chunk = PAGE_SIZE;
 		else
 			chunk = buffer_size - buffer_pos;
 
@@ -546,8 +546,8 @@ reiserfs_xattr_set_handle(struct reiserfs_transaction_handle *th,
 			struct reiserfs_xattr_header *rxh;
 
 			skip = file_pos = sizeof(struct reiserfs_xattr_header);
-			if (chunk + skip > PAGE_CACHE_SIZE)
-				chunk = PAGE_CACHE_SIZE - skip;
+			if (chunk + skip > PAGE_SIZE)
+				chunk = PAGE_SIZE - skip;
 			rxh = (struct reiserfs_xattr_header *)data;
 			rxh->h_magic = cpu_to_le32(REISERFS_XATTR_MAGIC);
 			rxh->h_hash = cpu_to_le32(xahash);
@@ -675,8 +675,8 @@ reiserfs_xattr_get(struct inode *inode, const char *name, void *buffer,
 		char *data;
 		size_t skip = 0;
 
-		if (isize - file_pos > PAGE_CACHE_SIZE)
-			chunk = PAGE_CACHE_SIZE;
+		if (isize - file_pos > PAGE_SIZE)
+			chunk = PAGE_SIZE;
 		else
 			chunk = isize - file_pos;
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
