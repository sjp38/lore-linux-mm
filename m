Message-Id: <20071227053403.478128326@sgi.com>
References: <20071227053246.902699851@sgi.com>
Date: Wed, 26 Dec 2007 21:33:03 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 17/18] Use page_cache_xxx in fs/reiserfs
Content-Disposition: inline; filename=0018-Use-page_cache_xxx-in-fs-reiserfs.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

- reiserfs_commit_write(): Use common method to extract mapping from
  page->mapping->host chain

Use page_cache_xxx in fs/reiserfs

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/reiserfs/file.c            |    5 +++--
 fs/reiserfs/inode.c           |   36 ++++++++++++++++++++++--------------
 fs/reiserfs/ioctl.c           |    2 +-
 fs/reiserfs/stree.c           |    5 +++--
 fs/reiserfs/tail_conversion.c |    5 +++--
 fs/reiserfs/xattr.c           |   19 ++++++++++---------
 6 files changed, 42 insertions(+), 30 deletions(-)

Index: linux-2.6.24-rc6-mm1/fs/reiserfs/file.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/reiserfs/file.c	2007-12-26 20:14:13.130250237 -0800
+++ linux-2.6.24-rc6-mm1/fs/reiserfs/file.c	2007-12-26 21:05:14.432903071 -0800
@@ -161,11 +161,12 @@ int reiserfs_commit_page(struct inode *i
 	int partial = 0;
 	unsigned blocksize;
 	struct buffer_head *bh, *head;
-	unsigned long i_size_index = inode->i_size >> PAGE_CACHE_SHIFT;
+	unsigned long i_size_index =
+		page_cache_index(inode->i_mapping, inode->i_size);
 	int new;
 	int logit = reiserfs_file_data_log(inode);
 	struct super_block *s = inode->i_sb;
-	int bh_per_page = PAGE_CACHE_SIZE / s->s_blocksize;
+	int bh_per_page = page_cache_size(inode->i_mapping) / s->s_blocksize;
 	struct reiserfs_transaction_handle th;
 	int ret = 0;
 
Index: linux-2.6.24-rc6-mm1/fs/reiserfs/inode.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/reiserfs/inode.c	2007-12-26 20:14:13.142250082 -0800
+++ linux-2.6.24-rc6-mm1/fs/reiserfs/inode.c	2007-12-26 21:07:16.172906276 -0800
@@ -337,7 +337,8 @@ static int _get_block_create_0(struct in
 		goto finished;
 	}
 	// read file tail into part of page
-	offset = (cpu_key_k_offset(&key) - 1) & (PAGE_CACHE_SIZE - 1);
+	offset = page_cache_offset(inode->i_mapping,
+				cpu_key_k_offset(&key) - 1);
 	fs_gen = get_generation(inode->i_sb);
 	copy_item_head(&tmp_ih, ih);
 
@@ -523,10 +524,10 @@ static int convert_tail_for_hole(struct 
 		return -EIO;
 
 	/* always try to read until the end of the block */
-	tail_start = tail_offset & (PAGE_CACHE_SIZE - 1);
+	tail_start = page_cache_offset(inode->i_mapping, tail_offset);
 	tail_end = (tail_start | (bh_result->b_size - 1)) + 1;
 
-	index = tail_offset >> PAGE_CACHE_SHIFT;
+	index = page_cache_index(inode->i_mapping, tail_offset);
 	/* hole_page can be zero in case of direct_io, we are sure
 	   that we cannot get here if we write with O_DIRECT into
 	   tail page */
@@ -2000,11 +2001,13 @@ static int grab_tail_page(struct inode *
 	/* we want the page with the last byte in the file,
 	 ** not the page that will hold the next byte for appending
 	 */
-	unsigned long index = (p_s_inode->i_size - 1) >> PAGE_CACHE_SHIFT;
+	unsigned long index = page_cache_index(p_s_inode->i_mapping,
+						p_s_inode->i_size - 1);
 	unsigned long pos = 0;
 	unsigned long start = 0;
 	unsigned long blocksize = p_s_inode->i_sb->s_blocksize;
-	unsigned long offset = (p_s_inode->i_size) & (PAGE_CACHE_SIZE - 1);
+	unsigned long offset = page_cache_offset(p_s_inode->i_mapping,
+							p_s_inode->i_size);
 	struct buffer_head *bh;
 	struct buffer_head *head;
 	struct page *page;
@@ -2076,7 +2079,8 @@ int reiserfs_truncate_file(struct inode 
 {
 	struct reiserfs_transaction_handle th;
 	/* we want the offset for the first byte after the end of the file */
-	unsigned long offset = p_s_inode->i_size & (PAGE_CACHE_SIZE - 1);
+	unsigned long offset = page_cache_offset(p_s_inode->i_mapping,
+							p_s_inode->i_size);
 	unsigned blocksize = p_s_inode->i_sb->s_blocksize;
 	unsigned length;
 	struct page *page = NULL;
@@ -2225,7 +2229,7 @@ static int map_block_for_writepage(struc
 	} else if (is_direct_le_ih(ih)) {
 		char *p;
 		p = page_address(bh_result->b_page);
-		p += (byte_offset - 1) & (PAGE_CACHE_SIZE - 1);
+		p += page_cache_offset(inode->i_mapping, byte_offset - 1);
 		copy_size = ih_item_len(ih) - pos_in_item;
 
 		fs_gen = get_generation(inode->i_sb);
@@ -2324,7 +2328,8 @@ static int reiserfs_write_full_page(stru
 				    struct writeback_control *wbc)
 {
 	struct inode *inode = page->mapping->host;
-	unsigned long end_index = inode->i_size >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = page_cache_index(inode->i_mapping,
+							inode->i_size);
 	int error = 0;
 	unsigned long block;
 	sector_t last_block;
@@ -2334,7 +2339,7 @@ static int reiserfs_write_full_page(stru
 	int checked = PageChecked(page);
 	struct reiserfs_transaction_handle th;
 	struct super_block *s = inode->i_sb;
-	int bh_per_page = PAGE_CACHE_SIZE / s->s_blocksize;
+	int bh_per_page = page_cache_size(inode->i_mapping) / s->s_blocksize;
 	th.t_trans_id = 0;
 
 	/* no logging allowed when nonblocking or from PF_MEMALLOC */
@@ -2361,16 +2366,18 @@ static int reiserfs_write_full_page(stru
 	if (page->index >= end_index) {
 		unsigned last_offset;
 
-		last_offset = inode->i_size & (PAGE_CACHE_SIZE - 1);
+		last_offset = page_cache_offset(inode->i_mapping, inode->i_size);
 		/* no file contents in this page */
 		if (page->index >= end_index + 1 || !last_offset) {
 			unlock_page(page);
 			return 0;
 		}
-		zero_user_segment(page, last_offset, PAGE_CACHE_SIZE);
+		zero_user_segment(page, last_offset,
+				page_cache_size(inode->i_mapping));
 	}
 	bh = head;
-	block = page->index << (PAGE_CACHE_SHIFT - s->s_blocksize_bits);
+	block = page->index << (page_cache_shift(inode->i_mapping)
+						- s->s_blocksize_bits);
 	last_block = (i_size_read(inode) - 1) >> inode->i_blkbits;
 	/* first map all the buffers, logging any direct items we find */
 	do {
@@ -2764,8 +2771,9 @@ static int reiserfs_write_end(struct fil
 int reiserfs_commit_write(struct file *f, struct page *page,
 			  unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
-	loff_t pos = ((loff_t) page->index << PAGE_CACHE_SHIFT) + to;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	loff_t pos = page_cache_pos(mapping, page->index, to);
 	int ret = 0;
 	int update_sd = 0;
 	struct reiserfs_transaction_handle *th = NULL;
Index: linux-2.6.24-rc6-mm1/fs/reiserfs/ioctl.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/reiserfs/ioctl.c	2007-12-26 20:14:13.150250325 -0800
+++ linux-2.6.24-rc6-mm1/fs/reiserfs/ioctl.c	2007-12-26 21:05:14.432903071 -0800
@@ -194,8 +194,8 @@ static int reiserfs_unpack(struct inode 
 	 ** reiserfs_prepare_write on that page.  This will force a 
 	 ** reiserfs_get_block to unpack the tail for us.
 	 */
-	index = inode->i_size >> PAGE_CACHE_SHIFT;
 	mapping = inode->i_mapping;
+	index = page_cache_index(mapping, inode->i_size);
 	page = grab_cache_page(mapping, index);
 	retval = -ENOMEM;
 	if (!page) {
Index: linux-2.6.24-rc6-mm1/fs/reiserfs/stree.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/reiserfs/stree.c	2007-12-26 20:14:13.162250141 -0800
+++ linux-2.6.24-rc6-mm1/fs/reiserfs/stree.c	2007-12-26 21:05:14.436902769 -0800
@@ -1283,7 +1283,8 @@ int reiserfs_delete_item(struct reiserfs
 		 */
 
 		data = kmap_atomic(p_s_un_bh->b_page, KM_USER0);
-		off = ((le_ih_k_offset(&s_ih) - 1) & (PAGE_CACHE_SIZE - 1));
+		off = page_cache_offset(p_s_inode->i_mapping,
+					le_ih_k_offset(&s_ih) - 1);
 		memcpy(data + off,
 		       B_I_PITEM(PATH_PLAST_BUFFER(p_s_path), &s_ih),
 		       n_ret_value);
@@ -1439,7 +1440,7 @@ static void unmap_buffers(struct page *p
 
 	if (page) {
 		if (page_has_buffers(page)) {
-			tail_index = pos & (PAGE_CACHE_SIZE - 1);
+			tail_index = page_cache_offset(page_mapping(page), pos);
 			cur_index = 0;
 			head = page_buffers(page);
 			bh = head;
Index: linux-2.6.24-rc6-mm1/fs/reiserfs/tail_conversion.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/reiserfs/tail_conversion.c	2007-12-26 20:14:13.170250484 -0800
+++ linux-2.6.24-rc6-mm1/fs/reiserfs/tail_conversion.c	2007-12-26 21:05:14.436902769 -0800
@@ -128,7 +128,8 @@ int direct2indirect(struct reiserfs_tran
 	 */
 	if (up_to_date_bh) {
 		unsigned pgoff =
-		    (tail_offset + total_tail - 1) & (PAGE_CACHE_SIZE - 1);
+			page_cache_offset(inode->i_mapping,
+			tail_offset + total_tail - 1);
 		char *kaddr = kmap_atomic(up_to_date_bh->b_page, KM_USER0);
 		memset(kaddr + pgoff, 0, n_blk_size - total_tail);
 		kunmap_atomic(kaddr, KM_USER0);
@@ -238,7 +239,7 @@ int indirect2direct(struct reiserfs_tran
 	 ** the page was locked and this part of the page was up to date when
 	 ** indirect2direct was called, so we know the bytes are still valid
 	 */
-	tail = tail + (pos & (PAGE_CACHE_SIZE - 1));
+	tail = tail + page_cache_offset(p_s_inode->i_mapping, pos);
 
 	PATH_LAST_POSITION(p_s_path)++;
 
Index: linux-2.6.24-rc6-mm1/fs/reiserfs/xattr.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/reiserfs/xattr.c	2007-12-26 20:14:13.186250483 -0800
+++ linux-2.6.24-rc6-mm1/fs/reiserfs/xattr.c	2007-12-26 21:05:14.436902769 -0800
@@ -468,13 +468,13 @@ reiserfs_xattr_set(struct inode *inode, 
 	while (buffer_pos < buffer_size || buffer_pos == 0) {
 		size_t chunk;
 		size_t skip = 0;
-		size_t page_offset = (file_pos & (PAGE_CACHE_SIZE - 1));
-		if (buffer_size - buffer_pos > PAGE_CACHE_SIZE)
-			chunk = PAGE_CACHE_SIZE;
+		size_t page_offset = page_cache_offset(mapping, file_pos);
+		if (buffer_size - buffer_pos > page_cache_size(mapping))
+			chunk = page_cache_size(mapping);
 		else
 			chunk = buffer_size - buffer_pos;
 
-		page = reiserfs_get_page(xinode, file_pos >> PAGE_CACHE_SHIFT);
+		page = reiserfs_get_page(xinode, page_cache_index(mapping, file_pos));
 		if (IS_ERR(page)) {
 			err = PTR_ERR(page);
 			goto out_filp;
@@ -486,8 +486,8 @@ reiserfs_xattr_set(struct inode *inode, 
 		if (file_pos == 0) {
 			struct reiserfs_xattr_header *rxh;
 			skip = file_pos = sizeof(struct reiserfs_xattr_header);
-			if (chunk + skip > PAGE_CACHE_SIZE)
-				chunk = PAGE_CACHE_SIZE - skip;
+			if (chunk + skip > page_cache_size(mapping))
+				chunk = page_cache_size(mapping) - skip;
 			rxh = (struct reiserfs_xattr_header *)data;
 			rxh->h_magic = cpu_to_le32(REISERFS_XATTR_MAGIC);
 			rxh->h_hash = cpu_to_le32(xahash);
@@ -577,12 +577,13 @@ reiserfs_xattr_get(const struct inode *i
 		size_t chunk;
 		char *data;
 		size_t skip = 0;
-		if (isize - file_pos > PAGE_CACHE_SIZE)
-			chunk = PAGE_CACHE_SIZE;
+		if (isize - file_pos > page_cache_size(xinode->i_mapping))
+			chunk = page_cache_size(xinode->i_mapping);
 		else
 			chunk = isize - file_pos;
 
-		page = reiserfs_get_page(xinode, file_pos >> PAGE_CACHE_SHIFT);
+		page = reiserfs_get_page(xinode,
+				page_cache_index(xinode->i_mapping, file_pos));
 		if (IS_ERR(page)) {
 			err = PTR_ERR(page);
 			goto out_dput;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
