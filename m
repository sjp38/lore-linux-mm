Message-Id: <20080216004805.937896919@sgi.com>
References: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:20 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 02/18] Use page_cache_xxx functions in mm/filemap.c
Content-Disposition: inline; filename=0003-Use-page_cache_xxx-functions-in-mm-filemap.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Convert the uses of PAGE_CACHE_xxx.

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/filemap.c |   91 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 46 insertions(+), 45 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2008-02-14 15:20:25.570017244 -0800
+++ linux-2.6/mm/filemap.c	2008-02-15 16:14:31.616843824 -0800
@@ -325,8 +325,8 @@ int wait_on_page_writeback_range(struct 
 int sync_page_range(struct inode *inode, struct address_space *mapping,
 			loff_t pos, loff_t count)
 {
-	pgoff_t start = pos >> PAGE_CACHE_SHIFT;
-	pgoff_t end = (pos + count - 1) >> PAGE_CACHE_SHIFT;
+	pgoff_t start = page_cache_index(mapping, pos);
+	pgoff_t end = page_cache_index(mapping, pos + count - 1);
 	int ret;
 
 	if (!mapping_cap_writeback_dirty(mapping) || !count)
@@ -357,8 +357,8 @@ EXPORT_SYMBOL(sync_page_range);
 int sync_page_range_nolock(struct inode *inode, struct address_space *mapping,
 			   loff_t pos, loff_t count)
 {
-	pgoff_t start = pos >> PAGE_CACHE_SHIFT;
-	pgoff_t end = (pos + count - 1) >> PAGE_CACHE_SHIFT;
+	pgoff_t start = page_cache_index(mapping, pos);
+	pgoff_t end = page_cache_index(mapping, pos + count - 1);
 	int ret;
 
 	if (!mapping_cap_writeback_dirty(mapping) || !count)
@@ -387,7 +387,7 @@ int filemap_fdatawait(struct address_spa
 		return 0;
 
 	return wait_on_page_writeback_range(mapping, 0,
-				(i_size - 1) >> PAGE_CACHE_SHIFT);
+				page_cache_index(mapping, i_size - 1));
 }
 EXPORT_SYMBOL(filemap_fdatawait);
 
@@ -435,8 +435,8 @@ int filemap_write_and_wait_range(struct 
 		/* See comment of filemap_write_and_wait() */
 		if (err != -EIO) {
 			int err2 = wait_on_page_writeback_range(mapping,
-						lstart >> PAGE_CACHE_SHIFT,
-						lend >> PAGE_CACHE_SHIFT);
+					page_cache_index(mapping, lstart),
+					page_cache_index(mapping, lend));
 			if (!err)
 				err = err2;
 		}
@@ -900,11 +900,11 @@ static void do_generic_file_read(struct 
 	unsigned int prev_offset;
 	int error;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	prev_index = ra->prev_pos >> PAGE_CACHE_SHIFT;
-	prev_offset = ra->prev_pos & (PAGE_CACHE_SIZE-1);
-	last_index = (*ppos + desc->count + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
+	index = page_cache_index(mapping, *ppos);
+	prev_index = page_cache_index(mapping, ra->prev_pos);
+	prev_offset = page_cache_offset(mapping, ra->prev_pos);
+	last_index = page_cache_next(mapping, *ppos + desc->count);
+	offset = page_cache_offset(mapping, *ppos);
 
 	for (;;) {
 		struct page *page;
@@ -941,16 +941,16 @@ page_ok:
 		 */
 
 		isize = i_size_read(inode);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		end_index = page_cache_index(mapping, isize - 1);
 		if (unlikely(!isize || index > end_index)) {
 			page_cache_release(page);
 			goto out;
 		}
 
 		/* nr is the maximum number of bytes to copy from this page */
-		nr = PAGE_CACHE_SIZE;
+		nr = page_cache_size(mapping);
 		if (index == end_index) {
-			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			nr = page_cache_offset(mapping, isize - 1) + 1;
 			if (nr <= offset) {
 				page_cache_release(page);
 				goto out;
@@ -985,8 +985,8 @@ page_ok:
 		 */
 		ret = actor(desc, page, offset, nr);
 		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		index += page_cache_index(mapping, offset);
+		offset = page_cache_offset(mapping, offset);
 		prev_offset = offset;
 
 		page_cache_release(page);
@@ -1076,11 +1076,8 @@ no_cached_page:
 	}
 
 out:
-	ra->prev_pos = prev_index;
-	ra->prev_pos <<= PAGE_CACHE_SHIFT;
-	ra->prev_pos |= prev_offset;
-
-	*ppos = ((loff_t)index << PAGE_CACHE_SHIFT) + offset;
+	ra->prev_pos = page_cache_pos(mapping, prev_index, prev_offset);
+	*ppos = page_cache_pos(mapping, index, offset);
 	if (filp)
 		file_accessed(filp);
 }
@@ -1259,8 +1256,8 @@ asmlinkage ssize_t sys_readahead(int fd,
 	if (file) {
 		if (file->f_mode & FMODE_READ) {
 			struct address_space *mapping = file->f_mapping;
-			pgoff_t start = offset >> PAGE_CACHE_SHIFT;
-			pgoff_t end = (offset + count - 1) >> PAGE_CACHE_SHIFT;
+			pgoff_t start = page_cache_index(mapping, offset);
+			pgoff_t end = page_cache_index(mapping, offset + count - 1);
 			unsigned long len = end - start + 1;
 			ret = do_readahead(mapping, file, start, len);
 		}
@@ -1328,7 +1325,7 @@ int filemap_fault(struct vm_area_struct 
 	int did_readaround = 0;
 	int ret = 0;
 
-	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	size = page_cache_next(mapping, i_size_read(inode));
 	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 
@@ -1403,7 +1400,7 @@ retry_find:
 		goto page_not_uptodate;
 
 	/* Must recheck i_size under page lock */
-	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	size = page_cache_next(mapping, i_size_read(inode));
 	if (unlikely(vmf->pgoff >= size)) {
 		unlock_page(page);
 		page_cache_release(page);
@@ -1414,7 +1411,7 @@ retry_find:
 	 * Found the page and have a reference on it.
 	 */
 	mark_page_accessed(page);
-	ra->prev_pos = (loff_t)page->index << PAGE_CACHE_SHIFT;
+	ra->prev_pos = page_cache_pos(mapping, page->index, 0);
 	vmf->page = page;
 	return ret | VM_FAULT_LOCKED;
 
@@ -1902,8 +1899,8 @@ int pagecache_write_begin(struct file *f
 							pagep, fsdata);
 	} else {
 		int ret;
-		pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-		unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+		pgoff_t index = page_cache_index(mapping, pos);
+		unsigned offset = page_cache_offset(mapping, pos);
 		struct inode *inode = mapping->host;
 		struct page *page;
 again:
@@ -1954,7 +1951,7 @@ int pagecache_write_end(struct file *fil
 		ret = aops->write_end(file, mapping, pos, len, copied,
 							page, fsdata);
 	} else {
-		unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+		unsigned offset = page_cache_offset(mapping, pos);
 		struct inode *inode = mapping->host;
 
 		flush_dcache_page(page);
@@ -2059,10 +2056,11 @@ static ssize_t generic_perform_write_2co
 		unsigned long bytes;	/* Bytes to write to page */
 		size_t copied;		/* Bytes copied from user */
 
-		offset = (pos & (PAGE_CACHE_SIZE - 1));
-		index = pos >> PAGE_CACHE_SHIFT;
-		bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
-						iov_iter_count(i));
+		offset = page_cache_offset(mapping, pos);
+		index = page_cache_index(mapping, pos);
+		bytes = min_t(unsigned long,
+				page_cache_size(mapping) - offset,
+				iov_iter_count(i));
 
 		/*
 		 * a non-NULL src_page indicates that we're doing the
@@ -2233,10 +2231,11 @@ static ssize_t generic_perform_write(str
 		size_t copied;		/* Bytes copied from user */
 		void *fsdata;
 
-		offset = (pos & (PAGE_CACHE_SIZE - 1));
-		index = pos >> PAGE_CACHE_SHIFT;
-		bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
-						iov_iter_count(i));
+		offset = page_cache_offset(mapping, pos);
+		index = page_cache_index(mapping, pos);
+		bytes = min_t(unsigned long,
+				page_cache_size(mapping) - offset,
+				iov_iter_count(i));
 
 again:
 
@@ -2283,8 +2282,9 @@ again:
 			 * because not all segments in the iov can be copied at
 			 * once without a pagefault.
 			 */
-			bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
-						iov_iter_single_seg_count(i));
+			bytes = min_t(unsigned long,
+					page_cache_size(mapping) - offset,
+					iov_iter_single_seg_count(i));
 			goto again;
 		}
 		pos += copied;
@@ -2425,8 +2425,8 @@ __generic_file_aio_write_nolock(struct k
 		if (err == 0) {
 			written = written_buffered;
 			invalidate_mapping_pages(mapping,
-						 pos >> PAGE_CACHE_SHIFT,
-						 endbyte >> PAGE_CACHE_SHIFT);
+						 page_cache_index(mapping, pos),
+						 page_cache_index(mapping, endbyte));
 		} else {
 			/*
 			 * We don't know how much we wrote, so just return
@@ -2513,7 +2513,7 @@ generic_file_direct_IO(int rw, struct ki
 	 */
 	if (rw == WRITE) {
 		write_len = iov_length(iov, nr_segs);
-		end = (offset + write_len - 1) >> PAGE_CACHE_SHIFT;
+		end = page_cache_index(mapping, offset + write_len - 1);
 	       	if (mapping_mapped(mapping))
 			unmap_mapping_range(mapping, offset, write_len, 0);
 	}
@@ -2530,7 +2530,7 @@ generic_file_direct_IO(int rw, struct ki
 	 */
 	if (rw == WRITE && mapping->nrpages) {
 		retval = invalidate_inode_pages2_range(mapping,
-					offset >> PAGE_CACHE_SHIFT, end);
+					page_cache_index(mapping, offset), end);
 		if (retval)
 			goto out;
 	}
@@ -2546,7 +2546,8 @@ generic_file_direct_IO(int rw, struct ki
 	 * fails, tough, the write still worked...
 	 */
 	if (rw == WRITE && mapping->nrpages) {
-		invalidate_inode_pages2_range(mapping, offset >> PAGE_CACHE_SHIFT, end);
+		invalidate_inode_pages2_range(mapping,
+				page_cache_index(mapping, offset), end);
 	}
 out:
 	return retval;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
