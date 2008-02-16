Message-Id: <20080216004809.739860918@sgi.com>
References: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:36 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 18/18] Use page_cache_xxx for fs/xfs
Content-Disposition: inline; filename=0019-Use-page_cache_xxx-for-fs-xfs.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

- xfs_page_trace: Determine mapping from inode
- xfs_probe_page: Make mapping check easier to read

Use page_cache_xxx for fs/xfs

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/xfs/linux-2.6/xfs_aops.c |   58 ++++++++++++++++++++++----------------------
 fs/xfs/linux-2.6/xfs_lrw.c  |    4 +--
 2 files changed, 32 insertions(+), 30 deletions(-)

Index: linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_aops.c	2008-02-14 15:19:13.777516867 -0800
+++ linux-2.6/fs/xfs/linux-2.6/xfs_aops.c	2008-02-15 16:15:22.377251601 -0800
@@ -75,7 +75,7 @@ xfs_page_trace(
 	xfs_inode_t	*ip;
 	bhv_vnode_t	*vp = vn_from_inode(inode);
 	loff_t		isize = i_size_read(inode);
-	loff_t		offset = page_offset(page);
+	loff_t		offset = page_cache_pos(inode->i_mapping, page->index, 0);
 	int		delalloc = -1, unmapped = -1, unwritten = -1;
 
 	if (page_has_buffers(page))
@@ -599,11 +599,12 @@ xfs_probe_page(
 	int			mapped)
 {
 	int			ret = 0;
+	struct address_space	*mapping = page->mapping;
 
 	if (PageWriteback(page))
 		return 0;
 
-	if (page->mapping && PageDirty(page)) {
+	if (mapping && PageDirty(page)) {
 		if (page_has_buffers(page)) {
 			struct buffer_head	*bh, *head;
 
@@ -618,7 +619,7 @@ xfs_probe_page(
 					break;
 			} while ((bh = bh->b_this_page) != head);
 		} else
-			ret = mapped ? 0 : PAGE_CACHE_SIZE;
+			ret = mapped ? 0 : page_cache_size(mapping);
 	}
 
 	return ret;
@@ -645,7 +646,7 @@ xfs_probe_cluster(
 	} while ((bh = bh->b_this_page) != head);
 
 	/* if we reached the end of the page, sum forwards in following pages */
-	tlast = i_size_read(inode) >> PAGE_CACHE_SHIFT;
+	tlast = page_cache_index(inode->i_mapping, i_size_read(inode));
 	tindex = startpage->index + 1;
 
 	/* Prune this back to avoid pathological behavior */
@@ -663,14 +664,14 @@ xfs_probe_cluster(
 			size_t pg_offset, pg_len = 0;
 
 			if (tindex == tlast) {
-				pg_offset =
-				    i_size_read(inode) & (PAGE_CACHE_SIZE - 1);
+				pg_offset = page_cache_offset(inode->i_mapping,
+							i_size_read(inode));
 				if (!pg_offset) {
 					done = 1;
 					break;
 				}
 			} else
-				pg_offset = PAGE_CACHE_SIZE;
+				pg_offset = page_cache_size(inode->i_mapping);
 
 			if (page->index == tindex && !TestSetPageLocked(page)) {
 				pg_len = xfs_probe_page(page, pg_offset, mapped);
@@ -752,7 +753,8 @@ xfs_convert_page(
 	int			bbits = inode->i_blkbits;
 	int			len, page_dirty;
 	int			count = 0, done = 0, uptodate = 1;
- 	xfs_off_t		offset = page_offset(page);
+	struct address_space	*map = inode->i_mapping;
+	xfs_off_t		offset = page_cache_pos(map, page->index, 0);
 
 	if (page->index != tindex)
 		goto fail;
@@ -760,7 +762,7 @@ xfs_convert_page(
 		goto fail;
 	if (PageWriteback(page))
 		goto fail_unlock_page;
-	if (page->mapping != inode->i_mapping)
+	if (page->mapping != map)
 		goto fail_unlock_page;
 	if (!xfs_is_delayed_page(page, (*ioendp)->io_type))
 		goto fail_unlock_page;
@@ -772,20 +774,19 @@ xfs_convert_page(
 	 * Derivation:
 	 *
 	 * End offset is the highest offset that this page should represent.
-	 * If we are on the last page, (end_offset & (PAGE_CACHE_SIZE - 1))
-	 * will evaluate non-zero and be less than PAGE_CACHE_SIZE and
+	 * If we are on the last page, (end_offset & page_cache_mask())
+	 * will evaluate non-zero and be less than page_cache_size() and
 	 * hence give us the correct page_dirty count. On any other page,
 	 * it will be zero and in that case we need page_dirty to be the
 	 * count of buffers on the page.
 	 */
 	end_offset = min_t(unsigned long long,
-			(xfs_off_t)(page->index + 1) << PAGE_CACHE_SHIFT,
+			(xfs_off_t)page_cache_pos(map, page->index + 1, 0),
 			i_size_read(inode));
 
 	len = 1 << inode->i_blkbits;
-	p_offset = min_t(unsigned long, end_offset & (PAGE_CACHE_SIZE - 1),
-					PAGE_CACHE_SIZE);
-	p_offset = p_offset ? roundup(p_offset, len) : PAGE_CACHE_SIZE;
+	p_offset = page_cache_offset(map, end_offset);
+	p_offset = p_offset ? roundup(p_offset, len) : page_cache_size(map);
 	page_dirty = p_offset / len;
 
 	bh = head = page_buffers(page);
@@ -941,6 +942,7 @@ xfs_page_state_convert(
 	int			page_dirty, count = 0;
 	int			trylock = 0;
 	int			all_bh = unmapped;
+	struct address_space	*map = inode->i_mapping;
 
 	if (startio) {
 		if (wbc->sync_mode == WB_SYNC_NONE && wbc->nonblocking)
@@ -949,11 +951,11 @@ xfs_page_state_convert(
 
 	/* Is this page beyond the end of the file? */
 	offset = i_size_read(inode);
-	end_index = offset >> PAGE_CACHE_SHIFT;
-	last_index = (offset - 1) >> PAGE_CACHE_SHIFT;
+	end_index = page_cache_index(map, offset);
+	last_index = page_cache_index(map, (offset - 1));
 	if (page->index >= end_index) {
 		if ((page->index >= end_index + 1) ||
-		    !(i_size_read(inode) & (PAGE_CACHE_SIZE - 1))) {
+		    !(page_cache_offset(map, i_size_read(inode)))) {
 			if (startio)
 				unlock_page(page);
 			return 0;
@@ -967,22 +969,22 @@ xfs_page_state_convert(
 	 * Derivation:
 	 *
 	 * End offset is the highest offset that this page should represent.
-	 * If we are on the last page, (end_offset & (PAGE_CACHE_SIZE - 1))
-	 * will evaluate non-zero and be less than PAGE_CACHE_SIZE and
-	 * hence give us the correct page_dirty count. On any other page,
+	 * If we are on the last page, (page_cache_offset(mapping, end_offset))
+	 * will evaluate non-zero and be less than page_cache_size(mapping)
+	 * and hence give us the correct page_dirty count. On any other page,
 	 * it will be zero and in that case we need page_dirty to be the
 	 * count of buffers on the page.
  	 */
 	end_offset = min_t(unsigned long long,
-			(xfs_off_t)(page->index + 1) << PAGE_CACHE_SHIFT, offset);
+			(xfs_off_t)page_cache_pos(map, page->index + 1, 0), offset);
 	len = 1 << inode->i_blkbits;
-	p_offset = min_t(unsigned long, end_offset & (PAGE_CACHE_SIZE - 1),
-					PAGE_CACHE_SIZE);
-	p_offset = p_offset ? roundup(p_offset, len) : PAGE_CACHE_SIZE;
+	p_offset = page_cache_offset(map, end_offset);
+	p_offset = p_offset ? roundup(p_offset, len) : page_cache_size(map);
+
 	page_dirty = p_offset / len;
 
 	bh = head = page_buffers(page);
-	offset = page_offset(page);
+	offset = page_cache_pos(map, page->index, 0);
 	flags = BMAPI_READ;
 	type = IOMAP_NEW;
 
@@ -1129,8 +1131,8 @@ xfs_page_state_convert(
 		xfs_start_page_writeback(page, wbc, 1, count);
 
 	if (ioend && iomap_valid) {
-		offset = (iomap.iomap_offset + iomap.iomap_bsize - 1) >>
-					PAGE_CACHE_SHIFT;
+		offset = page_cache_index(map,
+			(iomap.iomap_offset + iomap.iomap_bsize - 1));
 		tlast = min_t(pgoff_t, offset, last_index);
 		xfs_cluster_write(inode, page->index + 1, &iomap, &ioend,
 					wbc, startio, all_bh, tlast);
Index: linux-2.6/fs/xfs/linux-2.6/xfs_lrw.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_lrw.c	2008-02-14 15:19:13.777516867 -0800
+++ linux-2.6/fs/xfs/linux-2.6/xfs_lrw.c	2008-02-15 16:15:22.381251625 -0800
@@ -141,8 +141,8 @@ xfs_iozero(
 		unsigned offset, bytes;
 		void *fsdata;
 
-		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
-		bytes = PAGE_CACHE_SIZE - offset;
+		offset = page_cache_offset(mapping, pos);
+		bytes = page_cache_size(mapping) - offset;
 		if (bytes > count)
 			bytes = count;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
