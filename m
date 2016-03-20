Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5B17682F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:02 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id 4so106644932pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:02 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id yw1si8191225pac.109.2016.03.20.11.41.53
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 69/71] vfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:16 +0300
Message-Id: <1458499278-1516-70-git-send-email-kirill.shutemov@linux.intel.com>
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
 Documentation/filesystems/vfs.txt |   4 +-
 fs/block_dev.c                    |   4 +-
 fs/buffer.c                       | 100 +++++++++++++++++++-------------------
 fs/dax.c                          |  34 ++++++-------
 fs/direct-io.c                    |  26 +++++-----
 fs/fs-writeback.c                 |   2 +-
 fs/libfs.c                        |  24 ++++-----
 fs/mpage.c                        |  22 ++++-----
 fs/pipe.c                         |   6 +--
 fs/splice.c                       |  32 ++++++------
 fs/sync.c                         |   4 +-
 include/linux/buffer_head.h       |   4 +-
 include/linux/fs.h                |   4 +-
 13 files changed, 133 insertions(+), 133 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index b02a7d598258..80b5cd1ab8c0 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -708,9 +708,9 @@ struct address_space_operations {
 	from the address space.  This generally corresponds to either a
 	truncation, punch hole  or a complete invalidation of the address
 	space (in the latter case 'offset' will always be 0 and 'length'
-	will be PAGE_CACHE_SIZE). Any private data associated with the page
+	will be PAGE_SIZE). Any private data associated with the page
 	should be updated to reflect this truncation.  If offset is 0 and
-	length is PAGE_CACHE_SIZE, then the private data should be released,
+	length is PAG__SIZE, then the private data should be released,
 	because the page must be able to be completely discarded.  This may
 	be done by calling the ->releasepage function, but in this case the
 	release MUST succeed.
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 3172c4e2f502..20a2c02b77c4 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -331,7 +331,7 @@ static int blkdev_write_end(struct file *file, struct address_space *mapping,
 	ret = block_write_end(file, mapping, pos, len, copied, page, fsdata);
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return ret;
 }
@@ -1149,7 +1149,7 @@ void bd_set_size(struct block_device *bdev, loff_t size)
 	inode_lock(bdev->bd_inode);
 	i_size_write(bdev->bd_inode, size);
 	inode_unlock(bdev->bd_inode);
-	while (bsize < PAGE_CACHE_SIZE) {
+	while (bsize < PAGE_SIZE) {
 		if (size & bsize)
 			break;
 		bsize <<= 1;
diff --git a/fs/buffer.c b/fs/buffer.c
index 33be29675358..af0d9a82a8ed 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -129,7 +129,7 @@ __clear_page_buffers(struct page *page)
 {
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static void buffer_io_error(struct buffer_head *bh, char *msg)
@@ -207,7 +207,7 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
 	struct page *page;
 	int all_mapped = 1;
 
-	index = block >> (PAGE_CACHE_SHIFT - bd_inode->i_blkbits);
+	index = block >> (PAGE_SHIFT - bd_inode->i_blkbits);
 	page = find_get_page_flags(bd_mapping, index, FGP_ACCESSED);
 	if (!page)
 		goto out;
@@ -245,7 +245,7 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
 	}
 out_unlock:
 	spin_unlock(&bd_mapping->private_lock);
-	page_cache_release(page);
+	put_page(page);
 out:
 	return ret;
 }
@@ -1040,7 +1040,7 @@ done:
 	ret = (block < end_block) ? 1 : -ENXIO;
 failed:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return ret;
 }
 
@@ -1533,7 +1533,7 @@ void block_invalidatepage(struct page *page, unsigned int offset,
 	/*
 	 * Check for overflow
 	 */
-	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
+	BUG_ON(stop > PAGE_SIZE || stop < length);
 
 	head = page_buffers(page);
 	bh = head;
@@ -1716,7 +1716,7 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 	blocksize = bh->b_size;
 	bbits = block_size_bits(blocksize);
 
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	block = (sector_t)page->index << (PAGE_SHIFT - bbits);
 	last_block = (i_size_read(inode) - 1) >> bbits;
 
 	/*
@@ -1894,7 +1894,7 @@ EXPORT_SYMBOL(page_zero_new_buffers);
 int __block_write_begin(struct page *page, loff_t pos, unsigned len,
 		get_block_t *get_block)
 {
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + len;
 	struct inode *inode = page->mapping->host;
 	unsigned block_start, block_end;
@@ -1904,15 +1904,15 @@ int __block_write_begin(struct page *page, loff_t pos, unsigned len,
 	struct buffer_head *bh, *head, *wait[2], **wait_bh=wait;
 
 	BUG_ON(!PageLocked(page));
-	BUG_ON(from > PAGE_CACHE_SIZE);
-	BUG_ON(to > PAGE_CACHE_SIZE);
+	BUG_ON(from > PAGE_SIZE);
+	BUG_ON(to > PAGE_SIZE);
 	BUG_ON(from > to);
 
 	head = create_page_buffers(page, inode, 0);
 	blocksize = head->b_size;
 	bbits = block_size_bits(blocksize);
 
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	block = (sector_t)page->index << (PAGE_SHIFT - bbits);
 
 	for(bh = head, block_start = 0; bh != head || !block_start;
 	    block++, block_start=block_end, bh = bh->b_this_page) {
@@ -2020,7 +2020,7 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
 		unsigned flags, struct page **pagep, get_block_t *get_block)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *page;
 	int status;
 
@@ -2031,7 +2031,7 @@ int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
 	status = __block_write_begin(page, pos, len, get_block);
 	if (unlikely(status)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 
@@ -2047,7 +2047,7 @@ int block_write_end(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	unsigned start;
 
-	start = pos & (PAGE_CACHE_SIZE - 1);
+	start = pos & (PAGE_SIZE - 1);
 
 	if (unlikely(copied < len)) {
 		/*
@@ -2099,7 +2099,7 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 	}
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (old_size < pos)
 		pagecache_isize_extended(inode, old_size, pos);
@@ -2136,9 +2136,9 @@ int block_is_partially_uptodate(struct page *page, unsigned long from,
 
 	head = page_buffers(page);
 	blocksize = head->b_size;
-	to = min_t(unsigned, PAGE_CACHE_SIZE - from, count);
+	to = min_t(unsigned, PAGE_SIZE - from, count);
 	to = from + to;
-	if (from < blocksize && to > PAGE_CACHE_SIZE - blocksize)
+	if (from < blocksize && to > PAGE_SIZE - blocksize)
 		return 0;
 
 	bh = head;
@@ -2181,7 +2181,7 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 	blocksize = head->b_size;
 	bbits = block_size_bits(blocksize);
 
-	iblock = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	iblock = (sector_t)page->index << (PAGE_SHIFT - bbits);
 	lblock = (i_size_read(inode)+blocksize-1) >> bbits;
 	bh = head;
 	nr = 0;
@@ -2295,16 +2295,16 @@ static int cont_expand_zero(struct file *file, struct address_space *mapping,
 	unsigned zerofrom, offset, len;
 	int err = 0;
 
-	index = pos >> PAGE_CACHE_SHIFT;
-	offset = pos & ~PAGE_CACHE_MASK;
+	index = pos >> PAGE_SHIFT;
+	offset = pos & ~PAGE_MASK;
 
-	while (index > (curidx = (curpos = *bytes)>>PAGE_CACHE_SHIFT)) {
-		zerofrom = curpos & ~PAGE_CACHE_MASK;
+	while (index > (curidx = (curpos = *bytes)>>PAGE_SHIFT)) {
+		zerofrom = curpos & ~PAGE_MASK;
 		if (zerofrom & (blocksize-1)) {
 			*bytes |= (blocksize-1);
 			(*bytes)++;
 		}
-		len = PAGE_CACHE_SIZE - zerofrom;
+		len = PAGE_SIZE - zerofrom;
 
 		err = pagecache_write_begin(file, mapping, curpos, len,
 						AOP_FLAG_UNINTERRUPTIBLE,
@@ -2329,7 +2329,7 @@ static int cont_expand_zero(struct file *file, struct address_space *mapping,
 
 	/* page covers the boundary, find the boundary offset */
 	if (index == curidx) {
-		zerofrom = curpos & ~PAGE_CACHE_MASK;
+		zerofrom = curpos & ~PAGE_MASK;
 		/* if we will expand the thing last block will be filled */
 		if (offset <= zerofrom) {
 			goto out;
@@ -2375,7 +2375,7 @@ int cont_write_begin(struct file *file, struct address_space *mapping,
 	if (err)
 		return err;
 
-	zerofrom = *bytes & ~PAGE_CACHE_MASK;
+	zerofrom = *bytes & ~PAGE_MASK;
 	if (pos+len > *bytes && zerofrom & (blocksize-1)) {
 		*bytes |= (blocksize-1);
 		(*bytes)++;
@@ -2430,10 +2430,10 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	}
 
 	/* page is wholly or partially inside EOF */
-	if (((page->index + 1) << PAGE_CACHE_SHIFT) > size)
-		end = size & ~PAGE_CACHE_MASK;
+	if (((page->index + 1) << PAGE_SHIFT) > size)
+		end = size & ~PAGE_MASK;
 	else
-		end = PAGE_CACHE_SIZE;
+		end = PAGE_SIZE;
 
 	ret = __block_write_begin(page, 0, end, get_block);
 	if (!ret)
@@ -2508,8 +2508,8 @@ int nobh_write_begin(struct address_space *mapping,
 	int ret = 0;
 	int is_mapped_to_disk = 1;
 
-	index = pos >> PAGE_CACHE_SHIFT;
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	index = pos >> PAGE_SHIFT;
+	from = pos & (PAGE_SIZE - 1);
 	to = from + len;
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
@@ -2543,7 +2543,7 @@ int nobh_write_begin(struct address_space *mapping,
 		goto out_release;
 	}
 
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 
 	/*
 	 * We loop across all blocks in the page, whether or not they are
@@ -2551,7 +2551,7 @@ int nobh_write_begin(struct address_space *mapping,
 	 * page is fully mapped-to-disk.
 	 */
 	for (block_start = 0, block_in_page = 0, bh = head;
-		  block_start < PAGE_CACHE_SIZE;
+		  block_start < PAGE_SIZE;
 		  block_in_page++, block_start += blocksize, bh = bh->b_this_page) {
 		int create;
 
@@ -2623,7 +2623,7 @@ failed:
 
 out_release:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	*pagep = NULL;
 
 	return ret;
@@ -2653,7 +2653,7 @@ int nobh_write_end(struct file *file, struct address_space *mapping,
 	}
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	while (head) {
 		bh = head;
@@ -2675,7 +2675,7 @@ int nobh_writepage(struct page *page, get_block_t *get_block,
 {
 	struct inode * const inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
-	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	const pgoff_t end_index = i_size >> PAGE_SHIFT;
 	unsigned offset;
 	int ret;
 
@@ -2684,7 +2684,7 @@ int nobh_writepage(struct page *page, get_block_t *get_block,
 		goto out;
 
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = i_size & (PAGE_SIZE-1);
 	if (page->index >= end_index+1 || !offset) {
 		/*
 		 * The page may have dirty, unmapped buffers.  For example,
@@ -2707,7 +2707,7 @@ int nobh_writepage(struct page *page, get_block_t *get_block,
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 out:
 	ret = mpage_writepage(page, get_block, wbc);
 	if (ret == -EAGAIN)
@@ -2720,8 +2720,8 @@ EXPORT_SYMBOL(nobh_writepage);
 int nobh_truncate_page(struct address_space *mapping,
 			loff_t from, get_block_t *get_block)
 {
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize;
 	sector_t iblock;
 	unsigned length, pos;
@@ -2738,7 +2738,7 @@ int nobh_truncate_page(struct address_space *mapping,
 		return 0;
 
 	length = blocksize - length;
-	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	iblock = (sector_t)index << (PAGE_SHIFT - inode->i_blkbits);
 
 	page = grab_cache_page(mapping, index);
 	err = -ENOMEM;
@@ -2748,7 +2748,7 @@ int nobh_truncate_page(struct address_space *mapping,
 	if (page_has_buffers(page)) {
 has_buffers:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		return block_truncate_page(mapping, from, get_block);
 	}
 
@@ -2772,7 +2772,7 @@ has_buffers:
 	if (!PageUptodate(page)) {
 		err = mapping->a_ops->readpage(NULL, page);
 		if (err) {
-			page_cache_release(page);
+			put_page(page);
 			goto out;
 		}
 		lock_page(page);
@@ -2789,7 +2789,7 @@ has_buffers:
 
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out:
 	return err;
 }
@@ -2798,8 +2798,8 @@ EXPORT_SYMBOL(nobh_truncate_page);
 int block_truncate_page(struct address_space *mapping,
 			loff_t from, get_block_t *get_block)
 {
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize;
 	sector_t iblock;
 	unsigned length, pos;
@@ -2816,7 +2816,7 @@ int block_truncate_page(struct address_space *mapping,
 		return 0;
 
 	length = blocksize - length;
-	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	iblock = (sector_t)index << (PAGE_SHIFT - inode->i_blkbits);
 	
 	page = grab_cache_page(mapping, index);
 	err = -ENOMEM;
@@ -2865,7 +2865,7 @@ int block_truncate_page(struct address_space *mapping,
 
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out:
 	return err;
 }
@@ -2879,7 +2879,7 @@ int block_write_full_page(struct page *page, get_block_t *get_block,
 {
 	struct inode * const inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
-	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	const pgoff_t end_index = i_size >> PAGE_SHIFT;
 	unsigned offset;
 
 	/* Is the page fully inside i_size? */
@@ -2888,14 +2888,14 @@ int block_write_full_page(struct page *page, get_block_t *get_block,
 					       end_buffer_async_write);
 
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = i_size & (PAGE_SIZE-1);
 	if (page->index >= end_index+1 || !offset) {
 		/*
 		 * The page may have dirty, unmapped buffers.  For example,
 		 * they may have been added in ext3_writepage().  Make them
 		 * freeable here, so the page does not leak.
 		 */
-		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		do_invalidatepage(page, 0, PAGE_SIZE);
 		unlock_page(page);
 		return 0; /* don't care */
 	}
@@ -2907,7 +2907,7 @@ int block_write_full_page(struct page *page, get_block_t *get_block,
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 	return __block_write_full_page(inode, page, get_block, wbc,
 							end_buffer_async_write);
 }
diff --git a/fs/dax.c b/fs/dax.c
index bbb2ad783770..1144c55561f5 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -318,7 +318,7 @@ static int dax_load_hole(struct address_space *mapping, struct page *page,
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		return VM_FAULT_SIGBUS;
 	}
 
@@ -346,7 +346,7 @@ static int copy_user_bh(struct page *to, struct inode *inode,
 }
 
 #define NO_SECTOR -1
-#define DAX_PMD_INDEX(page_index) (page_index & (PMD_MASK >> PAGE_CACHE_SHIFT))
+#define DAX_PMD_INDEX(page_index) (page_index & (PMD_MASK >> PAGE_SHIFT))
 
 static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
 		sector_t sector, bool pmd_entry, bool dirty)
@@ -501,8 +501,8 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 	if (!mapping->nrexceptional || wbc->sync_mode != WB_SYNC_ALL)
 		return 0;
 
-	start_index = wbc->range_start >> PAGE_CACHE_SHIFT;
-	end_index = wbc->range_end >> PAGE_CACHE_SHIFT;
+	start_index = wbc->range_start >> PAGE_SHIFT;
+	end_index = wbc->range_end >> PAGE_SHIFT;
 	pmd_index = DAX_PMD_INDEX(start_index);
 
 	rcu_read_lock();
@@ -637,12 +637,12 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	page = find_get_page(mapping, vmf->pgoff);
 	if (page) {
 		if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
-			page_cache_release(page);
+			put_page(page);
 			return VM_FAULT_RETRY;
 		}
 		if (unlikely(page->mapping != mapping)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
@@ -706,10 +706,10 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	if (page) {
 		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
-							PAGE_CACHE_SIZE, 0);
+							PAGE_SIZE, 0);
 		delete_from_page_cache(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 
@@ -742,7 +742,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
  unlock_page:
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	goto out;
 }
@@ -1089,7 +1089,7 @@ EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
  * you are truncating a file, the helper function dax_truncate_page() may be
  * more convenient.
  *
- * We work in terms of PAGE_CACHE_SIZE here for commonality with
+ * We work in terms of PAGE_SIZE here for commonality with
  * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
  * took care of disposing of the unnecessary blocks.  Even if the filesystem
  * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
@@ -1099,18 +1099,18 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 							get_block_t get_block)
 {
 	struct buffer_head bh;
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	int err;
 
 	/* Block boundary? Nothing to do */
 	if (!length)
 		return 0;
-	BUG_ON((offset + length) > PAGE_CACHE_SIZE);
+	BUG_ON((offset + length) > PAGE_SIZE);
 
 	memset(&bh, 0, sizeof(bh));
 	bh.b_bdev = inode->i_sb->s_bdev;
-	bh.b_size = PAGE_CACHE_SIZE;
+	bh.b_size = PAGE_SIZE;
 	err = get_block(inode, index, &bh, 0);
 	if (err < 0)
 		return err;
@@ -1118,7 +1118,7 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 		struct block_device *bdev = bh.b_bdev;
 		struct blk_dax_ctl dax = {
 			.sector = to_sector(&bh, inode),
-			.size = PAGE_CACHE_SIZE,
+			.size = PAGE_SIZE,
 		};
 
 		if (dax_map_atomic(bdev, &dax) < 0)
@@ -1141,7 +1141,7 @@ EXPORT_SYMBOL_GPL(dax_zero_page_range);
  * Similar to block_truncate_page(), this function can be called by a
  * filesystem when it is truncating a DAX file to handle the partial page.
  *
- * We work in terms of PAGE_CACHE_SIZE here for commonality with
+ * We work in terms of PAGE_SIZE here for commonality with
  * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
  * took care of disposing of the unnecessary blocks.  Even if the filesystem
  * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
@@ -1149,7 +1149,7 @@ EXPORT_SYMBOL_GPL(dax_zero_page_range);
  */
 int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 {
-	unsigned length = PAGE_CACHE_ALIGN(from) - from;
+	unsigned length = PAGE_ALIGN(from) - from;
 	return dax_zero_page_range(inode, from, length, get_block);
 }
 EXPORT_SYMBOL_GPL(dax_truncate_page);
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 0a8d937c6775..9a65345a57ad 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -172,7 +172,7 @@ static inline int dio_refill_pages(struct dio *dio, struct dio_submit *sdio)
 		 */
 		if (dio->page_errors == 0)
 			dio->page_errors = ret;
-		page_cache_get(page);
+		get_page(page);
 		dio->pages[0] = page;
 		sdio->head = 0;
 		sdio->tail = 1;
@@ -419,7 +419,7 @@ static inline void dio_bio_submit(struct dio *dio, struct dio_submit *sdio)
 static inline void dio_cleanup(struct dio *dio, struct dio_submit *sdio)
 {
 	while (sdio->head < sdio->tail)
-		page_cache_release(dio->pages[sdio->head++]);
+		put_page(dio->pages[sdio->head++]);
 }
 
 /*
@@ -482,7 +482,7 @@ static int dio_bio_complete(struct dio *dio, struct bio *bio)
 			if (dio->rw == READ && !PageCompound(page) &&
 					dio->should_dirty)
 				set_page_dirty_lock(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 		err = bio->bi_error;
 		bio_put(bio);
@@ -691,7 +691,7 @@ static inline int dio_bio_add_page(struct dio_submit *sdio)
 		 */
 		if ((sdio->cur_page_len + sdio->cur_page_offset) == PAGE_SIZE)
 			sdio->pages_in_io--;
-		page_cache_get(sdio->cur_page);
+		get_page(sdio->cur_page);
 		sdio->final_block_in_bio = sdio->cur_page_block +
 			(sdio->cur_page_len >> sdio->blkbits);
 		ret = 0;
@@ -805,13 +805,13 @@ submit_page_section(struct dio *dio, struct dio_submit *sdio, struct page *page,
 	 */
 	if (sdio->cur_page) {
 		ret = dio_send_cur_page(dio, sdio, map_bh);
-		page_cache_release(sdio->cur_page);
+		put_page(sdio->cur_page);
 		sdio->cur_page = NULL;
 		if (ret)
 			return ret;
 	}
 
-	page_cache_get(page);		/* It is in dio */
+	get_page(page);		/* It is in dio */
 	sdio->cur_page = page;
 	sdio->cur_page_offset = offset;
 	sdio->cur_page_len = len;
@@ -825,7 +825,7 @@ out:
 	if (sdio->boundary) {
 		ret = dio_send_cur_page(dio, sdio, map_bh);
 		dio_bio_submit(dio, sdio);
-		page_cache_release(sdio->cur_page);
+		put_page(sdio->cur_page);
 		sdio->cur_page = NULL;
 	}
 	return ret;
@@ -942,7 +942,7 @@ static int do_direct_IO(struct dio *dio, struct dio_submit *sdio,
 
 				ret = get_more_blocks(dio, sdio, map_bh);
 				if (ret) {
-					page_cache_release(page);
+					put_page(page);
 					goto out;
 				}
 				if (!buffer_mapped(map_bh))
@@ -983,7 +983,7 @@ do_holes:
 
 				/* AKPM: eargh, -ENOTBLK is a hack */
 				if (dio->rw & WRITE) {
-					page_cache_release(page);
+					put_page(page);
 					return -ENOTBLK;
 				}
 
@@ -996,7 +996,7 @@ do_holes:
 				if (sdio->block_in_file >=
 						i_size_aligned >> blkbits) {
 					/* We hit eof */
-					page_cache_release(page);
+					put_page(page);
 					goto out;
 				}
 				zero_user(page, from, 1 << blkbits);
@@ -1036,7 +1036,7 @@ do_holes:
 						  sdio->next_block_for_io,
 						  map_bh);
 			if (ret) {
-				page_cache_release(page);
+				put_page(page);
 				goto out;
 			}
 			sdio->next_block_for_io += this_chunk_blocks;
@@ -1052,7 +1052,7 @@ next_block:
 		}
 
 		/* Drop the ref which was taken in get_user_pages() */
-		page_cache_release(page);
+		put_page(page);
 	}
 out:
 	return ret;
@@ -1276,7 +1276,7 @@ do_blockdev_direct_IO(struct kiocb *iocb, struct inode *inode,
 		ret2 = dio_send_cur_page(dio, &sdio, &map_bh);
 		if (retval == 0)
 			retval = ret2;
-		page_cache_release(sdio.cur_page);
+		put_page(sdio.cur_page);
 		sdio.cur_page = NULL;
 	}
 	if (sdio.bio)
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 5c46ed9f3e14..671e1780afc3 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -33,7 +33,7 @@
 /*
  * 4MB minimal write chunk size
  */
-#define MIN_WRITEBACK_PAGES	(4096UL >> (PAGE_CACHE_SHIFT - 10))
+#define MIN_WRITEBACK_PAGES	(4096UL >> (PAGE_SHIFT - 10))
 
 struct wb_completion {
 	atomic_t		cnt;
diff --git a/fs/libfs.c b/fs/libfs.c
index 0ca80b2af420..f3fa82ce9b70 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -25,7 +25,7 @@ int simple_getattr(struct vfsmount *mnt, struct dentry *dentry,
 {
 	struct inode *inode = d_inode(dentry);
 	generic_fillattr(inode, stat);
-	stat->blocks = inode->i_mapping->nrpages << (PAGE_CACHE_SHIFT - 9);
+	stat->blocks = inode->i_mapping->nrpages << (PAGE_SHIFT - 9);
 	return 0;
 }
 EXPORT_SYMBOL(simple_getattr);
@@ -33,7 +33,7 @@ EXPORT_SYMBOL(simple_getattr);
 int simple_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	buf->f_type = dentry->d_sb->s_magic;
-	buf->f_bsize = PAGE_CACHE_SIZE;
+	buf->f_bsize = PAGE_SIZE;
 	buf->f_namelen = NAME_MAX;
 	return 0;
 }
@@ -395,7 +395,7 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
 	struct page *page;
 	pgoff_t index;
 
-	index = pos >> PAGE_CACHE_SHIFT;
+	index = pos >> PAGE_SHIFT;
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
@@ -403,10 +403,10 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
 
 	*pagep = page;
 
-	if (!PageUptodate(page) && (len != PAGE_CACHE_SIZE)) {
-		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	if (!PageUptodate(page) && (len != PAGE_SIZE)) {
+		unsigned from = pos & (PAGE_SIZE - 1);
 
-		zero_user_segments(page, 0, from, from + len, PAGE_CACHE_SIZE);
+		zero_user_segments(page, 0, from, from + len, PAGE_SIZE);
 	}
 	return 0;
 }
@@ -442,7 +442,7 @@ int simple_write_end(struct file *file, struct address_space *mapping,
 
 	/* zero the stale part of the page if we did a short copy */
 	if (copied < len) {
-		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+		unsigned from = pos & (PAGE_SIZE - 1);
 
 		zero_user(page, from + copied, len - copied);
 	}
@@ -458,7 +458,7 @@ int simple_write_end(struct file *file, struct address_space *mapping,
 
 	set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
@@ -477,8 +477,8 @@ int simple_fill_super(struct super_block *s, unsigned long magic,
 	struct dentry *dentry;
 	int i;
 
-	s->s_blocksize = PAGE_CACHE_SIZE;
-	s->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	s->s_blocksize = PAGE_SIZE;
+	s->s_blocksize_bits = PAGE_SHIFT;
 	s->s_magic = magic;
 	s->s_op = &simple_super_operations;
 	s->s_time_gran = 1;
@@ -994,12 +994,12 @@ int generic_check_addressable(unsigned blocksize_bits, u64 num_blocks)
 {
 	u64 last_fs_block = num_blocks - 1;
 	u64 last_fs_page =
-		last_fs_block >> (PAGE_CACHE_SHIFT - blocksize_bits);
+		last_fs_block >> (PAGE_SHIFT - blocksize_bits);
 
 	if (unlikely(num_blocks == 0))
 		return 0;
 
-	if ((blocksize_bits < 9) || (blocksize_bits > PAGE_CACHE_SHIFT))
+	if ((blocksize_bits < 9) || (blocksize_bits > PAGE_SHIFT))
 		return -EINVAL;
 
 	if ((last_fs_block > (sector_t)(~0ULL) >> (blocksize_bits - 9)) ||
diff --git a/fs/mpage.c b/fs/mpage.c
index 6bd9fd90964e..1a4076ba3e04 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -107,7 +107,7 @@ map_buffer_to_page(struct page *page, struct buffer_head *bh, int page_block)
 		 * don't make any buffers if there is only one buffer on
 		 * the page and the page just needs to be set up to date
 		 */
-		if (inode->i_blkbits == PAGE_CACHE_SHIFT && 
+		if (inode->i_blkbits == PAGE_SHIFT && 
 		    buffer_uptodate(bh)) {
 			SetPageUptodate(page);    
 			return;
@@ -145,7 +145,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 {
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	sector_t block_in_file;
 	sector_t last_block;
@@ -162,7 +162,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	if (page_has_buffers(page))
 		goto confused;
 
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 	last_block = block_in_file + nr_pages * blocks_per_page;
 	last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
 	if (last_block > last_block_in_file)
@@ -249,7 +249,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	}
 
 	if (first_hole != blocks_per_page) {
-		zero_user_segment(page, first_hole << blkbits, PAGE_CACHE_SIZE);
+		zero_user_segment(page, first_hole << blkbits, PAGE_SIZE);
 		if (first_hole == 0) {
 			SetPageUptodate(page);
 			unlock_page(page);
@@ -331,7 +331,7 @@ confused:
  *
  * then this code just gives up and calls the buffer_head-based read function.
  * It does handle a page which has holes at the end - that is a common case:
- * the end-of-file on blocksize < PAGE_CACHE_SIZE setups.
+ * the end-of-file on blocksize < PAGE_SIZE setups.
  *
  * BH_Boundary explanation:
  *
@@ -380,7 +380,7 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
 					&first_logical_block,
 					get_block, gfp);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 	BUG_ON(!list_empty(pages));
 	if (bio)
@@ -472,7 +472,7 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
 	unsigned long end_index;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
 	sector_t last_block;
 	sector_t block_in_file;
 	sector_t blocks[MAX_BUF_PER_PAGE];
@@ -542,7 +542,7 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 	 * The page has no buffers: map it to disk
 	 */
 	BUG_ON(!PageUptodate(page));
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 	last_block = (i_size - 1) >> blkbits;
 	map_bh.b_page = page;
 	for (page_block = 0; page_block < blocks_per_page; ) {
@@ -574,7 +574,7 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 	first_unmapped = page_block;
 
 page_is_mapped:
-	end_index = i_size >> PAGE_CACHE_SHIFT;
+	end_index = i_size >> PAGE_SHIFT;
 	if (page->index >= end_index) {
 		/*
 		 * The page straddles i_size.  It must be zeroed out on each
@@ -584,11 +584,11 @@ page_is_mapped:
 		 * is zeroed when mapped, and writes to that region are not
 		 * written out to the file."
 		 */
-		unsigned offset = i_size & (PAGE_CACHE_SIZE - 1);
+		unsigned offset = i_size & (PAGE_SIZE - 1);
 
 		if (page->index > end_index || !offset)
 			goto confused;
-		zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+		zero_user_segment(page, offset, PAGE_SIZE);
 	}
 
 	/*
diff --git a/fs/pipe.c b/fs/pipe.c
index ab8dad3ccb6a..0d3f5165cb0b 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -134,7 +134,7 @@ static void anon_pipe_buf_release(struct pipe_inode_info *pipe,
 	if (page_count(page) == 1 && !pipe->tmp_page)
 		pipe->tmp_page = page;
 	else
-		page_cache_release(page);
+		put_page(page);
 }
 
 /**
@@ -180,7 +180,7 @@ EXPORT_SYMBOL(generic_pipe_buf_steal);
  */
 void generic_pipe_buf_get(struct pipe_inode_info *pipe, struct pipe_buffer *buf)
 {
-	page_cache_get(buf->page);
+	get_page(buf->page);
 }
 EXPORT_SYMBOL(generic_pipe_buf_get);
 
@@ -211,7 +211,7 @@ EXPORT_SYMBOL(generic_pipe_buf_confirm);
 void generic_pipe_buf_release(struct pipe_inode_info *pipe,
 			      struct pipe_buffer *buf)
 {
-	page_cache_release(buf->page);
+	put_page(buf->page);
 }
 EXPORT_SYMBOL(generic_pipe_buf_release);
 
diff --git a/fs/splice.c b/fs/splice.c
index 9947b5c69664..b018eb485019 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -88,7 +88,7 @@ out_unlock:
 static void page_cache_pipe_buf_release(struct pipe_inode_info *pipe,
 					struct pipe_buffer *buf)
 {
-	page_cache_release(buf->page);
+	put_page(buf->page);
 	buf->flags &= ~PIPE_BUF_FLAG_LRU;
 }
 
@@ -268,7 +268,7 @@ EXPORT_SYMBOL_GPL(splice_to_pipe);
 
 void spd_release_page(struct splice_pipe_desc *spd, unsigned int i)
 {
-	page_cache_release(spd->pages[i]);
+	put_page(spd->pages[i]);
 }
 
 /*
@@ -328,9 +328,9 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 	if (splice_grow_spd(pipe, &spd))
 		return -ENOMEM;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	loff = *ppos & ~PAGE_CACHE_MASK;
-	req_pages = (len + loff + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	index = *ppos >> PAGE_SHIFT;
+	loff = *ppos & ~PAGE_MASK;
+	req_pages = (len + loff + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	nr_pages = min(req_pages, spd.nr_pages_max);
 
 	/*
@@ -365,7 +365,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 			error = add_to_page_cache_lru(page, mapping, index,
 				   mapping_gfp_constraint(mapping, GFP_KERNEL));
 			if (unlikely(error)) {
-				page_cache_release(page);
+				put_page(page);
 				if (error == -EEXIST)
 					continue;
 				break;
@@ -385,7 +385,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 	 * Now loop over the map and see if we need to start IO on any
 	 * pages, fill in the partial map, etc.
 	 */
-	index = *ppos >> PAGE_CACHE_SHIFT;
+	index = *ppos >> PAGE_SHIFT;
 	nr_pages = spd.nr_pages;
 	spd.nr_pages = 0;
 	for (page_nr = 0; page_nr < nr_pages; page_nr++) {
@@ -397,7 +397,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 		/*
 		 * this_len is the max we'll use from this page
 		 */
-		this_len = min_t(unsigned long, len, PAGE_CACHE_SIZE - loff);
+		this_len = min_t(unsigned long, len, PAGE_SIZE - loff);
 		page = spd.pages[page_nr];
 
 		if (PageReadahead(page))
@@ -426,7 +426,7 @@ retry_lookup:
 					error = -ENOMEM;
 					break;
 				}
-				page_cache_release(spd.pages[page_nr]);
+				put_page(spd.pages[page_nr]);
 				spd.pages[page_nr] = page;
 			}
 			/*
@@ -456,7 +456,7 @@ fill_it:
 		 * i_size must be checked after PageUptodate.
 		 */
 		isize = i_size_read(mapping->host);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		end_index = (isize - 1) >> PAGE_SHIFT;
 		if (unlikely(!isize || index > end_index))
 			break;
 
@@ -470,7 +470,7 @@ fill_it:
 			/*
 			 * max good bytes in this page
 			 */
-			plen = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			plen = ((isize - 1) & ~PAGE_MASK) + 1;
 			if (plen <= loff)
 				break;
 
@@ -494,8 +494,8 @@ fill_it:
 	 * we got, 'nr_pages' is how many pages are in the map.
 	 */
 	while (page_nr < nr_pages)
-		page_cache_release(spd.pages[page_nr++]);
-	in->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
+		put_page(spd.pages[page_nr++]);
+	in->f_ra.prev_pos = (loff_t)index << PAGE_SHIFT;
 
 	if (spd.nr_pages)
 		error = splice_to_pipe(pipe, &spd);
@@ -636,8 +636,8 @@ ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 			goto shrink_ret;
 	}
 
-	offset = *ppos & ~PAGE_CACHE_MASK;
-	nr_pages = (len + offset + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	offset = *ppos & ~PAGE_MASK;
+	nr_pages = (len + offset + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	for (i = 0; i < nr_pages && i < spd.nr_pages_max && len; i++) {
 		struct page *page;
@@ -647,7 +647,7 @@ ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 		if (!page)
 			goto err;
 
-		this_len = min_t(size_t, len, PAGE_CACHE_SIZE - offset);
+		this_len = min_t(size_t, len, PAGE_SIZE - offset);
 		vec[i].iov_base = (void __user *) page_address(page);
 		vec[i].iov_len = this_len;
 		spd.pages[i] = page;
diff --git a/fs/sync.c b/fs/sync.c
index dd5d1711c7ac..2a54c1f22035 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -302,7 +302,7 @@ SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
 		goto out;
 
 	if (sizeof(pgoff_t) == 4) {
-		if (offset >= (0x100000000ULL << PAGE_CACHE_SHIFT)) {
+		if (offset >= (0x100000000ULL << PAGE_SHIFT)) {
 			/*
 			 * The range starts outside a 32 bit machine's
 			 * pagecache addressing capabilities.  Let it "succeed"
@@ -310,7 +310,7 @@ SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
 			ret = 0;
 			goto out;
 		}
-		if (endbyte >= (0x100000000ULL << PAGE_CACHE_SHIFT)) {
+		if (endbyte >= (0x100000000ULL << PAGE_SHIFT)) {
 			/*
 			 * Out to EOF
 			 */
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index c67f052cc5e5..d48daa3f6f20 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -43,7 +43,7 @@ enum bh_state_bits {
 			 */
 };
 
-#define MAX_BUF_PER_PAGE (PAGE_CACHE_SIZE / 512)
+#define MAX_BUF_PER_PAGE (PAGE_SIZE / 512)
 
 struct page;
 struct buffer_head;
@@ -263,7 +263,7 @@ void buffer_init(void);
 static inline void attach_page_buffers(struct page *page,
 		struct buffer_head *head)
 {
-	page_cache_get(page);
+	get_page(page);
 	SetPagePrivate(page);
 	set_page_private(page, (unsigned long)head);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bb703ef728d1..8f30e69a8501 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -923,7 +923,7 @@ static inline struct file *get_file(struct file *f)
 /* Page cache limit. The filesystems should put that into their s_maxbytes 
    limits, otherwise bad things can happen in VM. */ 
 #if BITS_PER_LONG==32
-#define MAX_LFS_FILESIZE	(((loff_t)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1) 
+#define MAX_LFS_FILESIZE	(((loff_t)PAGE_SIZE << (BITS_PER_LONG-1))-1) 
 #elif BITS_PER_LONG==64
 #define MAX_LFS_FILESIZE 	((loff_t)0x7fffffffffffffffLL)
 #endif
@@ -2059,7 +2059,7 @@ extern int generic_update_time(struct inode *, struct timespec *, int);
 /* /sys/fs */
 extern struct kobject *fs_kobj;
 
-#define MAX_RW_COUNT (INT_MAX & PAGE_CACHE_MASK)
+#define MAX_RW_COUNT (INT_MAX & PAGE_MASK)
 
 #ifdef CONFIG_MANDATORY_FILE_LOCKING
 extern int locks_mandatory_locked(struct file *);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
