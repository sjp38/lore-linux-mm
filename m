Message-Id: <20080216004807.844649681@sgi.com>
References: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:28 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 10/18] Use page_cache_xxx in fs/buffer.c
Content-Disposition: inline; filename=0011-Use-page_cache_xxx-in-fs-buffer.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

- alloc_page_buffers(): Add comment to explain use of page->mapping
- Consistently determine mapping if there is a reference chain
  page->mapping->host to determine the inode.

Use page_cache_xxx in fs/buffer.c.

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/buffer.c |  112 ++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 65 insertions(+), 47 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2008-02-15 16:11:18.567307640 -0800
+++ linux-2.6/fs/buffer.c	2008-02-15 16:14:54.753021832 -0800
@@ -270,7 +270,7 @@ __find_get_block_slow(struct block_devic
 	struct page *page;
 	int all_mapped = 1;
 
-	index = block >> (PAGE_CACHE_SHIFT - bd_inode->i_blkbits);
+	index = block >> (page_cache_shift(bd_mapping) - bd_inode->i_blkbits);
 	page = find_get_page(bd_mapping, index);
 	if (!page)
 		goto out;
@@ -712,7 +712,7 @@ static int __set_page_dirty(struct page 
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
 			__inc_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
-			task_io_account_write(PAGE_CACHE_SIZE);
+			task_io_account_write(page_cache_size(mapping));
 		}
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
@@ -924,7 +924,13 @@ struct buffer_head *alloc_page_buffers(s
 
 try_again:
 	head = NULL;
-	offset = PAGE_SIZE;
+
+	/*
+	 * Page is locked to serialize alloc_page_buffers()
+	 * so we can use page->mapping here.
+	 */
+	offset = page_cache_size(page->mapping);
+
 	while ((offset -= size) >= 0) {
 		bh = alloc_buffer_head(GFP_NOFS);
 		if (!bh)
@@ -1636,6 +1642,7 @@ static int __block_write_full_page(struc
 	struct buffer_head *bh, *head;
 	const unsigned blocksize = 1 << inode->i_blkbits;
 	int nr_underway = 0;
+	struct address_space *mapping = inode->i_mapping;
 
 	BUG_ON(!PageLocked(page));
 
@@ -1656,7 +1663,8 @@ static int __block_write_full_page(struc
 	 * handle that here by just cleaning them.
 	 */
 
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	block = (sector_t)page->index <<
+		(page_cache_shift(mapping) - inode->i_blkbits);
 	head = page_buffers(page);
 	bh = head;
 
@@ -1772,7 +1780,7 @@ recover:
 	} while ((bh = bh->b_this_page) != head);
 	SetPageError(page);
 	BUG_ON(PageWriteback(page));
-	mapping_set_error(page->mapping, err);
+	mapping_set_error(mapping, err);
 	set_page_writeback(page);
 	do {
 		struct buffer_head *next = bh->b_this_page;
@@ -1839,8 +1847,8 @@ static int __block_prepare_write(struct 
 	struct buffer_head *bh, *head, *wait[2], **wait_bh=wait;
 
 	BUG_ON(!PageLocked(page));
-	BUG_ON(from > PAGE_CACHE_SIZE);
-	BUG_ON(to > PAGE_CACHE_SIZE);
+	BUG_ON(from > page_cache_size(inode->i_mapping));
+	BUG_ON(to > page_cache_size(inode->i_mapping));
 	BUG_ON(from > to);
 
 	blocksize = 1 << inode->i_blkbits;
@@ -1849,7 +1857,8 @@ static int __block_prepare_write(struct 
 	head = page_buffers(page);
 
 	bbits = inode->i_blkbits;
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	block = (sector_t)page->index <<
+		(page_cache_shift(inode->i_mapping) - bbits);
 
 	for(bh = head, block_start = 0; bh != head || !block_start;
 	    block++, block_start=block_end, bh = bh->b_this_page) {
@@ -1964,8 +1973,8 @@ int block_write_begin(struct file *file,
 	unsigned start, end;
 	int ownpage = 0;
 
-	index = pos >> PAGE_CACHE_SHIFT;
-	start = pos & (PAGE_CACHE_SIZE - 1);
+	index = page_cache_index(mapping, pos);
+	start = page_cache_offset(mapping, pos);
 	end = start + len;
 
 	page = *pagep;
@@ -2012,7 +2021,7 @@ int block_write_end(struct file *file, s
 	struct inode *inode = mapping->host;
 	unsigned start;
 
-	start = pos & (PAGE_CACHE_SIZE - 1);
+	start = page_cache_offset(mapping, pos);
 
 	if (unlikely(copied < len)) {
 		/*
@@ -2077,7 +2086,8 @@ EXPORT_SYMBOL(generic_write_end);
  */
 int block_read_full_page(struct page *page, get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
 	sector_t iblock, lblock;
 	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
 	unsigned int blocksize;
@@ -2090,7 +2100,8 @@ int block_read_full_page(struct page *pa
 		create_empty_buffers(page, blocksize, 0);
 	head = page_buffers(page);
 
-	iblock = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	iblock = (sector_t)page->index <<
+		(page_cache_shift(mapping) - inode->i_blkbits);
 	lblock = (i_size_read(inode)+blocksize-1) >> inode->i_blkbits;
 	bh = head;
 	nr = 0;
@@ -2208,16 +2219,17 @@ int cont_expand_zero(struct file *file, 
 	unsigned zerofrom, offset, len;
 	int err = 0;
 
-	index = pos >> PAGE_CACHE_SHIFT;
-	offset = pos & ~PAGE_CACHE_MASK;
+	index = page_cache_index(mapping, pos);
+	offset = page_cache_offset(mapping, pos);
 
-	while (index > (curidx = (curpos = *bytes)>>PAGE_CACHE_SHIFT)) {
-		zerofrom = curpos & ~PAGE_CACHE_MASK;
+	while (curpos = *bytes, curidx = page_cache_index(mapping, curpos),
+			index > curidx) {
+		zerofrom = page_cache_offset(mapping, curpos);
 		if (zerofrom & (blocksize-1)) {
 			*bytes |= (blocksize-1);
 			(*bytes)++;
 		}
-		len = PAGE_CACHE_SIZE - zerofrom;
+		len = page_cache_size(mapping) - zerofrom;
 
 		err = pagecache_write_begin(file, mapping, curpos, len,
 						AOP_FLAG_UNINTERRUPTIBLE,
@@ -2235,7 +2247,7 @@ int cont_expand_zero(struct file *file, 
 
 	/* page covers the boundary, find the boundary offset */
 	if (index == curidx) {
-		zerofrom = curpos & ~PAGE_CACHE_MASK;
+		zerofrom = page_cache_offset(mapping, curpos);
 		/* if we will expand the thing last block will be filled */
 		if (offset <= zerofrom) {
 			goto out;
@@ -2281,7 +2293,7 @@ int cont_write_begin(struct file *file, 
 	if (err)
 		goto out;
 
-	zerofrom = *bytes & ~PAGE_CACHE_MASK;
+	zerofrom = page_cache_offset(mapping, *bytes);
 	if (pos+len > *bytes && zerofrom & (blocksize-1)) {
 		*bytes |= (blocksize-1);
 		(*bytes)++;
@@ -2314,8 +2326,9 @@ int block_commit_write(struct page *page
 int generic_commit_write(struct file *file, struct page *page,
 		unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
-	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	loff_t pos = page_cache_pos(mapping, page->index, to);
 	__block_commit_write(inode,page,from,to);
 	/*
 	 * No need to use i_size_read() here, the i_size
@@ -2351,20 +2364,22 @@ block_page_mkwrite(struct vm_area_struct
 	unsigned long end;
 	loff_t size;
 	int ret = -EINVAL;
+	struct address_space *mapping;
 
 	lock_page(page);
+	mapping = page->mapping;
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
-	    (page_offset(page) > size)) {
+	if ((mapping != inode->i_mapping) ||
+	    (page_cache_pos(mapping, page->index, 0) > size)) {
 		/* page got truncated out from underneath us */
 		goto out_unlock;
 	}
 
 	/* page is wholly or partially inside EOF */
-	if (((page->index + 1) << PAGE_CACHE_SHIFT) > size)
-		end = size & ~PAGE_CACHE_MASK;
+	if (page_cache_pos(mapping, page->index + 1, 0) > size)
+		end = page_cache_offset(mapping, size);
 	else
-		end = PAGE_CACHE_SIZE;
+		end = page_cache_size(mapping);
 
 	ret = block_prepare_write(page, 0, end, get_block);
 	if (!ret)
@@ -2432,8 +2447,8 @@ int nobh_write_begin(struct file *file, 
 	int ret = 0;
 	int is_mapped_to_disk = 1;
 
-	index = pos >> PAGE_CACHE_SHIFT;
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	index = page_cache_index(mapping, pos);
+	from = page_cache_offset(mapping, pos);
 	to = from + len;
 
 	page = __grab_cache_page(mapping, index);
@@ -2468,7 +2483,8 @@ int nobh_write_begin(struct file *file, 
 		goto out_release;
 	}
 
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index <<
+			(page_cache_shift(mapping) - blkbits);
 
 	/*
 	 * We loop across all blocks in the page, whether or not they are
@@ -2476,7 +2492,7 @@ int nobh_write_begin(struct file *file, 
 	 * page is fully mapped-to-disk.
 	 */
 	for (block_start = 0, block_in_page = 0, bh = head;
-		  block_start < PAGE_CACHE_SIZE;
+		  block_start < page_cache_size(mapping);
 		  block_in_page++, block_start += blocksize, bh = bh->b_this_page) {
 		int create;
 
@@ -2602,9 +2618,10 @@ EXPORT_SYMBOL(nobh_write_end);
 int nobh_writepage(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
+	struct address_space *mapping = page->mapping;
+	struct inode * const inode = mapping->host;
 	loff_t i_size = i_size_read(inode);
-	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	const pgoff_t end_index = page_cache_index(mapping, i_size);
 	unsigned offset;
 	int ret;
 
@@ -2613,7 +2630,7 @@ int nobh_writepage(struct page *page, ge
 		goto out;
 
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = page_cache_offset(mapping, i_size);
 	if (page->index >= end_index+1 || !offset) {
 		/*
 		 * The page may have dirty, unmapped buffers.  For example,
@@ -2636,7 +2653,7 @@ int nobh_writepage(struct page *page, ge
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, page_cache_size(mapping));
 out:
 	ret = mpage_writepage(page, get_block, wbc);
 	if (ret == -EAGAIN)
@@ -2648,8 +2665,8 @@ EXPORT_SYMBOL(nobh_writepage);
 int nobh_truncate_page(struct address_space *mapping,
 			loff_t from, get_block_t *get_block)
 {
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = page_cache_index(mapping, from);
+	unsigned offset = page_cache_offset(mapping, from);
 	unsigned blocksize;
 	sector_t iblock;
 	unsigned length, pos;
@@ -2666,7 +2683,7 @@ int nobh_truncate_page(struct address_sp
 		return 0;
 
 	length = blocksize - length;
-	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	iblock = (sector_t)index << (page_cache_shift(mapping) - inode->i_blkbits);
 
 	page = grab_cache_page(mapping, index);
 	err = -ENOMEM;
@@ -2724,8 +2741,8 @@ EXPORT_SYMBOL(nobh_truncate_page);
 int block_truncate_page(struct address_space *mapping,
 			loff_t from, get_block_t *get_block)
 {
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = page_cache_index(mapping, from);
+	unsigned offset = page_cache_offset(mapping, from);
 	unsigned blocksize;
 	sector_t iblock;
 	unsigned length, pos;
@@ -2742,8 +2759,8 @@ int block_truncate_page(struct address_s
 		return 0;
 
 	length = blocksize - length;
-	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
-	
+	iblock = (sector_t)index <<
+			(page_cache_shift(mapping) - inode->i_blkbits);
 	page = grab_cache_page(mapping, index);
 	err = -ENOMEM;
 	if (!page)
@@ -2802,9 +2819,10 @@ out:
 int block_write_full_page(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
+	struct address_space *mapping = page->mapping;
+	struct inode * const inode = mapping->host;
 	loff_t i_size = i_size_read(inode);
-	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	const pgoff_t end_index = page_cache_index(mapping, i_size);
 	unsigned offset;
 
 	/* Is the page fully inside i_size? */
@@ -2812,7 +2830,7 @@ int block_write_full_page(struct page *p
 		return __block_write_full_page(inode, page, get_block, wbc);
 
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = page_cache_offset(mapping, i_size);
 	if (page->index >= end_index+1 || !offset) {
 		/*
 		 * The page may have dirty, unmapped buffers.  For example,
@@ -2831,7 +2849,7 @@ int block_write_full_page(struct page *p
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, page_cache_size(mapping));
 	return __block_write_full_page(inode, page, get_block, wbc);
 }
 
@@ -3081,7 +3099,7 @@ int try_to_free_buffers(struct page *pag
 	 * dirty bit from being lost.
 	 */
 	if (ret)
-		cancel_dirty_page(page, PAGE_CACHE_SIZE);
+		cancel_dirty_page(page, page_cache_size(mapping));
 	spin_unlock(&mapping->private_lock);
 out:
 	if (buffers_to_free) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
