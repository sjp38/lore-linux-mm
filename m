Message-Id: <20070423062131.114158637@sgi.com>
References: <20070423062107.843307112@sgi.com>
Date: Sun, 22 Apr 2007 23:21:20 -0700
From: clameter@sgi.com
Subject: [RFC 13/16] Variable Order Page Cache: Fixed to block layer
Content-Disposition: inline; filename=var_pc_buffer_head
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Adam Litke <aglitke@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>
List-ID: <linux-mm.kvack.org>

Fix up (at least some pieces of) the block layer. It already has some
flexibility. Extend that for larger page sizes.

set_blocksize is changed to allow to specify a blocksize larger than a
page. If that occurs then we switch the device to use compound pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/block_dev.c              |   22 ++++++---
 fs/buffer.c                 |  101 +++++++++++++++++++++++---------------------
 fs/inode.c                  |    5 +-
 fs/mpage.c                  |   34 +++++++-------
 include/linux/buffer_head.h |    9 +++
 5 files changed, 100 insertions(+), 71 deletions(-)

Index: linux-2.6.21-rc7/include/linux/buffer_head.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/buffer_head.h	2007-04-22 21:47:33.000000000 -0700
+++ linux-2.6.21-rc7/include/linux/buffer_head.h	2007-04-22 22:14:41.000000000 -0700
@@ -129,7 +129,14 @@ BUFFER_FNS(Ordered, ordered)
 BUFFER_FNS(Eopnotsupp, eopnotsupp)
 BUFFER_FNS(Unwritten, unwritten)
 
-#define bh_offset(bh)		((unsigned long)(bh)->b_data & ~PAGE_MASK)
+static inline unsigned long bh_offset(struct buffer_head *bh)
+{
+	/* Cannot use the mapping since it may be set to NULL. */
+	unsigned long mask = ~(PAGE_MASK << compound_order(bh->b_page));
+
+	return (unsigned long)bh->b_data & mask;
+}
+
 #define touch_buffer(bh)	mark_page_accessed(bh->b_page)
 
 /* If we *know* page->private refers to buffer_heads */
Index: linux-2.6.21-rc7/fs/block_dev.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/block_dev.c	2007-04-22 21:47:33.000000000 -0700
+++ linux-2.6.21-rc7/fs/block_dev.c	2007-04-22 22:11:44.000000000 -0700
@@ -60,12 +60,12 @@ static void kill_bdev(struct block_devic
 {
 	invalidate_bdev(bdev, 1);
 	truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
-}	
+}
 
 int set_blocksize(struct block_device *bdev, int size)
 {
-	/* Size must be a power of two, and between 512 and PAGE_SIZE */
-	if (size > PAGE_SIZE || size < 512 || (size & (size-1)))
+	/* Size must be a power of two, and greater than 512 */
+	if (size < 512 || (size & (size-1)))
 		return -EINVAL;
 
 	/* Size cannot be smaller than the size supported by the device */
@@ -74,10 +74,16 @@ int set_blocksize(struct block_device *b
 
 	/* Don't change the size if it is same as current */
 	if (bdev->bd_block_size != size) {
+		int bits = blksize_bits(size);
+		struct address_space *mapping =
+			bdev->bd_inode->i_mapping;
+
 		sync_blockdev(bdev);
-		bdev->bd_block_size = size;
-		bdev->bd_inode->i_blkbits = blksize_bits(size);
 		kill_bdev(bdev);
+		bdev->bd_block_size = size;
+		bdev->bd_inode->i_blkbits = bits;
+		set_mapping_order(mapping,
+			bits < PAGE_SHIFT ? 0 : bits - PAGE_SHIFT);
 	}
 	return 0;
 }
@@ -88,8 +94,10 @@ int sb_set_blocksize(struct super_block 
 {
 	if (set_blocksize(sb->s_bdev, size))
 		return 0;
-	/* If we get here, we know size is power of two
-	 * and it's value is between 512 and PAGE_SIZE */
+	/*
+	 * If we get here, we know size is power of two
+	 * and it's value is larger than 512
+	 */
 	sb->s_blocksize = size;
 	sb->s_blocksize_bits = blksize_bits(size);
 	return sb->s_blocksize;
Index: linux-2.6.21-rc7/fs/buffer.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/buffer.c	2007-04-22 21:47:33.000000000 -0700
+++ linux-2.6.21-rc7/fs/buffer.c	2007-04-22 22:11:44.000000000 -0700
@@ -259,7 +259,7 @@ __find_get_block_slow(struct block_devic
 	struct page *page;
 	int all_mapped = 1;
 
-	index = block >> (PAGE_CACHE_SHIFT - bd_inode->i_blkbits);
+	index = block >> (page_cache_shift(bd_mapping) - bd_inode->i_blkbits);
 	page = find_get_page(bd_mapping, index);
 	if (!page)
 		goto out;
@@ -733,7 +733,7 @@ int __set_page_dirty_buffers(struct page
 	if (page->mapping) {	/* Race with truncate? */
 		if (mapping_cap_account_dirty(mapping)) {
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
-			task_io_account_write(PAGE_CACHE_SIZE);
+			task_io_account_write(page_cache_size(mapping));
 		}
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
@@ -879,10 +879,13 @@ struct buffer_head *alloc_page_buffers(s
 {
 	struct buffer_head *bh, *head;
 	long offset;
+	unsigned page_size = page_cache_size(page->mapping);
+
+	BUG_ON(size > page_size);
 
 try_again:
 	head = NULL;
-	offset = PAGE_SIZE;
+	offset = page_size;
 	while ((offset -= size) >= 0) {
 		bh = alloc_buffer_head(GFP_NOFS);
 		if (!bh)
@@ -1080,7 +1083,7 @@ __getblk_slow(struct block_device *bdev,
 {
 	/* Size must be multiple of hard sectorsize */
 	if (unlikely(size & (bdev_hardsect_size(bdev)-1) ||
-			(size < 512 || size > PAGE_SIZE))) {
+			size < 512)) {
 		printk(KERN_ERR "getblk(): invalid block size %d requested\n",
 					size);
 		printk(KERN_ERR "hardsect size: %d\n",
@@ -1417,7 +1420,7 @@ void set_bh_page(struct buffer_head *bh,
 		struct page *page, unsigned long offset)
 {
 	bh->b_page = page;
-	BUG_ON(offset >= PAGE_SIZE);
+	VM_BUG_ON(offset >= page_cache_size(page->mapping));
 	if (PageHighMem(page))
 		/*
 		 * This catches illegal uses and preserves the offset:
@@ -1766,8 +1769,8 @@ static int __block_prepare_write(struct 
 	struct buffer_head *bh, *head, *wait[2], **wait_bh=wait;
 
 	BUG_ON(!PageLocked(page));
-	BUG_ON(from > PAGE_CACHE_SIZE);
-	BUG_ON(to > PAGE_CACHE_SIZE);
+	BUG_ON(from > page_cache_size(inode->i_mapping));
+	BUG_ON(to > page_cache_size(inode->i_mapping));
 	BUG_ON(from > to);
 
 	blocksize = 1 << inode->i_blkbits;
@@ -1776,7 +1779,7 @@ static int __block_prepare_write(struct 
 	head = page_buffers(page);
 
 	bbits = inode->i_blkbits;
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	block = (sector_t)page->index << (page_cache_shift(inode->i_mapping) - bbits);
 
 	for(bh = head, block_start = 0; bh != head || !block_start;
 	    block++, block_start=block_end, bh = bh->b_this_page) {
@@ -1934,7 +1937,7 @@ int block_read_full_page(struct page *pa
 		create_empty_buffers(page, blocksize, 0);
 	head = page_buffers(page);
 
-	iblock = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	iblock = (sector_t)page->index << (page_cache_shift(page->mapping) - inode->i_blkbits);
 	lblock = (i_size_read(inode)+blocksize-1) >> inode->i_blkbits;
 	bh = head;
 	nr = 0;
@@ -1957,7 +1960,7 @@ int block_read_full_page(struct page *pa
 			if (!buffer_mapped(bh)) {
 				void *kaddr = kmap_atomic(page, KM_USER0);
 				memset(kaddr + i * blocksize, 0, blocksize);
-				flush_dcache_page(page);
+				flush_mapping_page(page);
 				kunmap_atomic(kaddr, KM_USER0);
 				if (!err)
 					set_buffer_uptodate(bh);
@@ -2058,10 +2061,11 @@ out:
 
 int generic_cont_expand(struct inode *inode, loff_t size)
 {
+	struct address_space *mapping = inode->i_mapping;
 	pgoff_t index;
 	unsigned int offset;
 
-	offset = (size & (PAGE_CACHE_SIZE - 1)); /* Within page */
+	offset = page_cache_offset(mapping, size);
 
 	/* ugh.  in prepare/commit_write, if from==to==start of block, we
 	** skip the prepare.  make sure we never send an offset for the start
@@ -2071,7 +2075,7 @@ int generic_cont_expand(struct inode *in
 		/* caller must handle this extra byte. */
 		offset++;
 	}
-	index = size >> PAGE_CACHE_SHIFT;
+	index = page_cache_index(mapping, size);
 
 	return __generic_cont_expand(inode, size, index, offset);
 }
@@ -2079,8 +2083,8 @@ int generic_cont_expand(struct inode *in
 int generic_cont_expand_simple(struct inode *inode, loff_t size)
 {
 	loff_t pos = size - 1;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	unsigned int offset = (pos & (PAGE_CACHE_SIZE - 1)) + 1;
+	pgoff_t index = page_cache_index(inode->i_mapping, pos);
+	unsigned int offset = page_cache_offset(inode->i_mapping, pos) + 1;
 
 	/* prepare/commit_write can handle even if from==to==start of block. */
 	return __generic_cont_expand(inode, size, index, offset);
@@ -2103,31 +2107,32 @@ int cont_prepare_write(struct page *page
 	unsigned blocksize = 1 << inode->i_blkbits;
 	void *kaddr;
 
-	while(page->index > (pgpos = *bytes>>PAGE_CACHE_SHIFT)) {
+	while(page->index > (pgpos = page_cache_index(mapping, *bytes))) {
 		status = -ENOMEM;
 		new_page = grab_cache_page(mapping, pgpos);
 		if (!new_page)
 			goto out;
 		/* we might sleep */
-		if (*bytes>>PAGE_CACHE_SHIFT != pgpos) {
+		if (page_cache_index(mapping, *bytes) != pgpos) {
 			unlock_page(new_page);
 			page_cache_release(new_page);
 			continue;
 		}
-		zerofrom = *bytes & ~PAGE_CACHE_MASK;
+		zerofrom = page_cache_offset(mapping, *bytes);
 		if (zerofrom & (blocksize-1)) {
 			*bytes |= (blocksize-1);
 			(*bytes)++;
 		}
 		status = __block_prepare_write(inode, new_page, zerofrom,
-						PAGE_CACHE_SIZE, get_block);
+						page_cache_size(mapping), get_block);
 		if (status)
 			goto out_unmap;
+		/* Need higher order kmap?? */
 		kaddr = kmap_atomic(new_page, KM_USER0);
-		memset(kaddr+zerofrom, 0, PAGE_CACHE_SIZE-zerofrom);
+		memset(kaddr+zerofrom, 0, page_cache_size(mapping)-zerofrom);
 		flush_dcache_page(new_page);
 		kunmap_atomic(kaddr, KM_USER0);
-		generic_commit_write(NULL, new_page, zerofrom, PAGE_CACHE_SIZE);
+		generic_commit_write(NULL, new_page, zerofrom, page_cache_size(mapping));
 		unlock_page(new_page);
 		page_cache_release(new_page);
 	}
@@ -2137,7 +2142,7 @@ int cont_prepare_write(struct page *page
 		zerofrom = offset;
 	} else {
 		/* page covers the boundary, find the boundary offset */
-		zerofrom = *bytes & ~PAGE_CACHE_MASK;
+		zerofrom = page_cache_offset(mapping, *bytes);
 
 		/* if we will expand the thing last block will be filled */
 		if (to > zerofrom && (zerofrom & (blocksize-1))) {
@@ -2192,8 +2197,9 @@ int block_commit_write(struct page *page
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
@@ -2235,6 +2241,7 @@ static void end_buffer_read_nobh(struct 
 int nobh_prepare_write(struct page *page, unsigned from, unsigned to,
 			get_block_t *get_block)
 {
+	struct address_space *mapping = page->mapping;
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
 	const unsigned blocksize = 1 << blkbits;
@@ -2242,6 +2249,7 @@ int nobh_prepare_write(struct page *page
 	struct buffer_head *read_bh[MAX_BUF_PER_PAGE];
 	unsigned block_in_page;
 	unsigned block_start;
+	unsigned page_size = page_cache_size(mapping);
 	sector_t block_in_file;
 	char *kaddr;
 	int nr_reads = 0;
@@ -2252,7 +2260,7 @@ int nobh_prepare_write(struct page *page
 	if (PageMappedToDisk(page))
 		return 0;
 
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (page_cache_shift(mapping) - blkbits);
 	map_bh.b_page = page;
 
 	/*
@@ -2261,7 +2269,7 @@ int nobh_prepare_write(struct page *page
 	 * page is fully mapped-to-disk.
 	 */
 	for (block_start = 0, block_in_page = 0;
-		  block_start < PAGE_CACHE_SIZE;
+		  block_start < page_size;
 		  block_in_page++, block_start += blocksize) {
 		unsigned block_end = block_start + blocksize;
 		int create;
@@ -2288,7 +2296,7 @@ int nobh_prepare_write(struct page *page
 				memset(kaddr+block_start, 0, from-block_start);
 			if (block_end > to)
 				memset(kaddr + to, 0, block_end - to);
-			flush_dcache_page(page);
+			flush_mapping_page(page);
 			kunmap_atomic(kaddr, KM_USER0);
 			continue;
 		}
@@ -2356,8 +2364,8 @@ failed:
 	 * so we'll later zero out any blocks which _were_ allocated.
 	 */
 	kaddr = kmap_atomic(page, KM_USER0);
-	memset(kaddr, 0, PAGE_CACHE_SIZE);
-	flush_dcache_page(page);
+	memset(kaddr, 0, page_size);
+	flush_mapping_page(page);
 	kunmap_atomic(kaddr, KM_USER0);
 	SetPageUptodate(page);
 	set_page_dirty(page);
@@ -2372,8 +2380,9 @@ EXPORT_SYMBOL(nobh_prepare_write);
 int nobh_commit_write(struct file *file, struct page *page,
 		unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
-	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	loff_t pos = page_cache_pos(mapping, page->index, to);
 
 	SetPageUptodate(page);
 	set_page_dirty(page);
@@ -2395,7 +2404,7 @@ int nobh_writepage(struct page *page, ge
 {
 	struct inode * const inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
-	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	const pgoff_t end_index = page_cache_offset(page->mapping, i_size);
 	unsigned offset;
 	void *kaddr;
 	int ret;
@@ -2405,7 +2414,7 @@ int nobh_writepage(struct page *page, ge
 		goto out;
 
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = page_cache_offset(page->mapping, i_size);
 	if (page->index >= end_index+1 || !offset) {
 		/*
 		 * The page may have dirty, unmapped buffers.  For example,
@@ -2429,7 +2438,7 @@ int nobh_writepage(struct page *page, ge
 	 * writes to that region are not written out to the file."
 	 */
 	kaddr = kmap_atomic(page, KM_USER0);
-	memset(kaddr + offset, 0, PAGE_CACHE_SIZE - offset);
+	memset(kaddr + offset, 0, page_cache_size(page->mapping) - offset);
 	flush_dcache_page(page);
 	kunmap_atomic(kaddr, KM_USER0);
 out:
@@ -2447,8 +2456,8 @@ int nobh_truncate_page(struct address_sp
 {
 	struct inode *inode = mapping->host;
 	unsigned blocksize = 1 << inode->i_blkbits;
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = page_cache_index(mapping, from);
+	unsigned offset = page_cache_offset(mapping, from);
 	unsigned to;
 	struct page *page;
 	const struct address_space_operations *a_ops = mapping->a_ops;
@@ -2467,8 +2476,8 @@ int nobh_truncate_page(struct address_sp
 	ret = a_ops->prepare_write(NULL, page, offset, to);
 	if (ret == 0) {
 		kaddr = kmap_atomic(page, KM_USER0);
-		memset(kaddr + offset, 0, PAGE_CACHE_SIZE - offset);
-		flush_dcache_page(page);
+		memset(kaddr + offset, 0, page_cache_size(mapping) - offset);
+		flush_mapping_page(page);
 		kunmap_atomic(kaddr, KM_USER0);
 		/*
 		 * It would be more correct to call aops->commit_write()
@@ -2487,8 +2496,8 @@ EXPORT_SYMBOL(nobh_truncate_page);
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
@@ -2506,7 +2515,7 @@ int block_truncate_page(struct address_s
 		return 0;
 
 	length = blocksize - length;
-	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	iblock = (sector_t)index << (page_cache_shift(mapping) - inode->i_blkbits);
 	
 	page = grab_cache_page(mapping, index);
 	err = -ENOMEM;
@@ -2551,7 +2560,7 @@ int block_truncate_page(struct address_s
 
 	kaddr = kmap_atomic(page, KM_USER0);
 	memset(kaddr + offset, 0, length);
-	flush_dcache_page(page);
+	flush_mapping_page(page);
 	kunmap_atomic(kaddr, KM_USER0);
 
 	mark_buffer_dirty(bh);
@@ -2572,7 +2581,7 @@ int block_write_full_page(struct page *p
 {
 	struct inode * const inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
-	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	const pgoff_t end_index = page_cache_index(page->mapping, i_size);
 	unsigned offset;
 	void *kaddr;
 
@@ -2581,7 +2590,7 @@ int block_write_full_page(struct page *p
 		return __block_write_full_page(inode, page, get_block, wbc);
 
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = page_cache_offset(page->mapping, i_size);
 	if (page->index >= end_index+1 || !offset) {
 		/*
 		 * The page may have dirty, unmapped buffers.  For example,
@@ -2601,8 +2610,8 @@ int block_write_full_page(struct page *p
 	 * writes to that region are not written out to the file."
 	 */
 	kaddr = kmap_atomic(page, KM_USER0);
-	memset(kaddr + offset, 0, PAGE_CACHE_SIZE - offset);
-	flush_dcache_page(page);
+	memset(kaddr + offset, 0, page_cache_size(page->mapping) - offset);
+	flush_mapping_page(page);
 	kunmap_atomic(kaddr, KM_USER0);
 	return __block_write_full_page(inode, page, get_block, wbc);
 }
@@ -2857,7 +2866,7 @@ int try_to_free_buffers(struct page *pag
 	 * dirty bit from being lost.
 	 */
 	if (ret)
-		cancel_dirty_page(page, PAGE_CACHE_SIZE);
+		cancel_dirty_page(page, page_cache_size(mapping));
 	spin_unlock(&mapping->private_lock);
 out:
 	if (buffers_to_free) {
Index: linux-2.6.21-rc7/fs/inode.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/inode.c	2007-04-22 21:52:18.000000000 -0700
+++ linux-2.6.21-rc7/fs/inode.c	2007-04-22 22:11:44.000000000 -0700
@@ -145,7 +145,10 @@ static struct inode *alloc_inode(struct 
 		mapping->a_ops = &empty_aops;
  		mapping->host = inode;
 		mapping->flags = 0;
-		mapping->order = 0;
+		if (inode->i_blkbits > PAGE_SHIFT)
+			set_mapping_order(mapping, inode->i_blkbits - PAGE_SHIFT);
+		else
+			set_mapping_order(mapping, 0);
 		mapping_set_gfp_mask(mapping, GFP_HIGHUSER);
 		mapping->assoc_mapping = NULL;
 		mapping->backing_dev_info = &default_backing_dev_info;
Index: linux-2.6.21-rc7/fs/mpage.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/mpage.c	2007-04-22 21:47:33.000000000 -0700
+++ linux-2.6.21-rc7/fs/mpage.c	2007-04-22 22:11:44.000000000 -0700
@@ -133,7 +133,8 @@ mpage_alloc(struct block_device *bdev,
 static void 
 map_buffer_to_page(struct page *page, struct buffer_head *bh, int page_block) 
 {
-	struct inode *inode = page->mapping->host;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
 	struct buffer_head *page_bh, *head;
 	int block = 0;
 
@@ -142,9 +143,9 @@ map_buffer_to_page(struct page *page, st
 		 * don't make any buffers if there is only one buffer on
 		 * the page and the page just needs to be set up to date
 		 */
-		if (inode->i_blkbits == PAGE_CACHE_SHIFT && 
+		if (inode->i_blkbits == page_cache_shift(mapping) &&
 		    buffer_uptodate(bh)) {
-			SetPageUptodate(page);    
+			SetPageUptodate(page);
 			return;
 		}
 		create_empty_buffers(page, 1 << inode->i_blkbits, 0);
@@ -177,9 +178,10 @@ do_mpage_readpage(struct bio *bio, struc
 		sector_t *last_block_in_bio, struct buffer_head *map_bh,
 		unsigned long *first_logical_block, get_block_t get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = page_cache_size(mapping) >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	sector_t block_in_file;
 	sector_t last_block;
@@ -196,7 +198,7 @@ do_mpage_readpage(struct bio *bio, struc
 	if (page_has_buffers(page))
 		goto confused;
 
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (page_cache_shift(mapping) - blkbits);
 	last_block = block_in_file + nr_pages * blocks_per_page;
 	last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
 	if (last_block > last_block_in_file)
@@ -286,8 +288,8 @@ do_mpage_readpage(struct bio *bio, struc
 	if (first_hole != blocks_per_page) {
 		char *kaddr = kmap_atomic(page, KM_USER0);
 		memset(kaddr + (first_hole << blkbits), 0,
-				PAGE_CACHE_SIZE - (first_hole << blkbits));
-		flush_dcache_page(page);
+				page_cache_size(mapping) - (first_hole << blkbits));
+		flush_mapping_page(page);
 		kunmap_atomic(kaddr, KM_USER0);
 		if (first_hole == 0) {
 			SetPageUptodate(page);
@@ -465,7 +467,7 @@ __mpage_writepage(struct bio *bio, struc
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
 	unsigned long end_index;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = page_cache_size(mapping) >> blkbits;
 	sector_t last_block;
 	sector_t block_in_file;
 	sector_t blocks[MAX_BUF_PER_PAGE];
@@ -533,7 +535,7 @@ __mpage_writepage(struct bio *bio, struc
 	 * The page has no buffers: map it to disk
 	 */
 	BUG_ON(!PageUptodate(page));
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (page_cache_shift(mapping) - blkbits);
 	last_block = (i_size - 1) >> blkbits;
 	map_bh.b_page = page;
 	for (page_block = 0; page_block < blocks_per_page; ) {
@@ -565,7 +567,7 @@ __mpage_writepage(struct bio *bio, struc
 	first_unmapped = page_block;
 
 page_is_mapped:
-	end_index = i_size >> PAGE_CACHE_SHIFT;
+	end_index = page_cache_index(mapping, i_size);
 	if (page->index >= end_index) {
 		/*
 		 * The page straddles i_size.  It must be zeroed out on each
@@ -575,14 +577,14 @@ page_is_mapped:
 		 * is zeroed when mapped, and writes to that region are not
 		 * written out to the file."
 		 */
-		unsigned offset = i_size & (PAGE_CACHE_SIZE - 1);
+		unsigned offset = page_cache_offset(mapping, i_size);
 		char *kaddr;
 
 		if (page->index > end_index || !offset)
 			goto confused;
 		kaddr = kmap_atomic(page, KM_USER0);
-		memset(kaddr + offset, 0, PAGE_CACHE_SIZE - offset);
-		flush_dcache_page(page);
+		memset(kaddr + offset, 0, page_cache_size(mapping) - offset);
+		flush_mapping_page(page);
 		kunmap_atomic(kaddr, KM_USER0);
 	}
 
@@ -727,8 +729,8 @@ mpage_writepages(struct address_space *m
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = page_cache_index(mapping, wbc->range_start);
+		end = page_cache_index(mapping, wbc->range_end);
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		scanned = 1;

--
