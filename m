Date: Wed, 28 Nov 2007 19:28:17 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 18/19] Use page_cache_xxx for fs/xfs
In-Reply-To: <20071129030314.GR119954183@sgi.com>
Message-ID: <Pine.LNX.4.64.0711281927520.20367@schroedinger.engr.sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011148.509714554@sgi.com>
 <20071129030314.GR119954183@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

In other words the following patch?


Fixes to the use of page_cache_xx functions in xfs

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/xfs/linux-2.6/xfs_aops.c |   17 ++++++-----------
 fs/xfs/linux-2.6/xfs_lrw.c  |    2 +-
 2 files changed, 7 insertions(+), 12 deletions(-)

Index: mm/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- mm.orig/fs/xfs/linux-2.6/xfs_aops.c	2007-11-28 19:13:13.323382722 -0800
+++ mm/fs/xfs/linux-2.6/xfs_aops.c	2007-11-28 19:22:15.686920219 -0800
@@ -75,7 +75,7 @@ xfs_page_trace(
 	xfs_inode_t	*ip;
 	bhv_vnode_t	*vp = vn_from_inode(inode);
 	loff_t		isize = i_size_read(inode);
-	loff_t		offset = page_cache_offset(page->mapping);
+	loff_t		offset = page_cache_pos(page->mapping, page->index, 0);
 	int		delalloc = -1, unmapped = -1, unwritten = -1;
 
 	if (page_has_buffers(page))
@@ -780,13 +780,11 @@ xfs_convert_page(
 	 * count of buffers on the page.
 	 */
 	end_offset = min_t(unsigned long long,
-			(xfs_off_t)(page->index + 1) << page_cache_shift(map),
+			(xfs_off_t)page_cache_pos(map, page->index + 1, 0),
 			i_size_read(inode));
 
 	len = 1 << inode->i_blkbits;
-	p_offset = min_t(unsigned long, page_cache_offset(map, end_offset),
-					page_cache_size(map));
-	p_offset = p_offset ? roundup(p_offset, len) : page_cache_size(map);
+	p_offset = page_cache_offset(map, end_offset);
 	page_dirty = p_offset / len;
 
 	bh = head = page_buffers(page);
@@ -943,7 +941,6 @@ xfs_page_state_convert(
 	int			trylock = 0;
 	int			all_bh = unmapped;
 	struct address_space	*map = inode->i_mapping;
-	int			pagesize = page_cache_size(map);
 
 	if (startio) {
 		if (wbc->sync_mode == WB_SYNC_NONE && wbc->nonblocking)
@@ -979,9 +976,7 @@ xfs_page_state_convert(
 	end_offset = min_t(unsigned long long,
 			(xfs_off_t)page_cache_pos(map, page->index + 1, 0), offset);
 	len = 1 << inode->i_blkbits;
-	p_offset = min_t(unsigned long, page_cache_offset(map, end_offset),
-					pagesize);
-	p_offset = p_offset ? roundup(p_offset, len) : pagesize;
+	p_offset = page_cache_offset(map, end_offset);
 	page_dirty = p_offset / len;
 
 	bh = head = page_buffers(page);
@@ -1132,8 +1127,8 @@ xfs_page_state_convert(
 		xfs_start_page_writeback(page, wbc, 1, count);
 
 	if (ioend && iomap_valid) {
-		offset = (iomap.iomap_offset + iomap.iomap_bsize - 1) >>
-					page_cache_shift(map);
+		offset = page_cache_index(map,
+			(iomap.iomap_offset + iomap.iomap_bsize - 1));
 		tlast = min_t(pgoff_t, offset, last_index);
 		xfs_cluster_write(inode, page->index + 1, &iomap, &ioend,
 					wbc, startio, all_bh, tlast);
Index: mm/fs/xfs/linux-2.6/xfs_lrw.c
===================================================================
--- mm.orig/fs/xfs/linux-2.6/xfs_lrw.c	2007-11-28 19:22:35.454383115 -0800
+++ mm/fs/xfs/linux-2.6/xfs_lrw.c	2007-11-28 19:22:59.222132796 -0800
@@ -142,7 +142,7 @@ xfs_iozero(
 		unsigned offset, bytes;
 		void *fsdata;
 
-		offset = page_cache_offset(mapping, pos); /* Within page */
+		offset = page_cache_offset(mapping, pos);
 		bytes = page_cache_size(mapping) - offset;
 		if (bytes > count)
 			bytes = count;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
