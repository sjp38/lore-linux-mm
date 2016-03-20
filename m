Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 47E5082F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:35 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id x3so237582271pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id c90si10337078pfd.233.2016.03.20.11.41.53
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 64/71] xfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:11 +0300
Message-Id: <1458499278-1516-65-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Chinner <david@fromorbit.com>

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
Cc: Dave Chinner <david@fromorbit.com>
---
 fs/xfs/libxfs/xfs_bmap.c |  4 ++--
 fs/xfs/xfs_aops.c        | 38 +++++++++++++++++++-------------------
 fs/xfs/xfs_bmap_util.c   |  4 ++--
 fs/xfs/xfs_file.c        | 12 ++++++------
 fs/xfs/xfs_linux.h       |  2 +-
 fs/xfs/xfs_mount.c       |  2 +-
 fs/xfs/xfs_mount.h       |  4 ++--
 fs/xfs/xfs_pnfs.c        |  4 ++--
 fs/xfs/xfs_super.c       |  8 ++++----
 9 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/fs/xfs/libxfs/xfs_bmap.c b/fs/xfs/libxfs/xfs_bmap.c
index ef00156f4f96..aafecc12a8e2 100644
--- a/fs/xfs/libxfs/xfs_bmap.c
+++ b/fs/xfs/libxfs/xfs_bmap.c
@@ -3745,11 +3745,11 @@ xfs_bmap_btalloc(
 		args.prod = align;
 		if ((args.mod = (xfs_extlen_t)do_mod(ap->offset, args.prod)))
 			args.mod = (xfs_extlen_t)(args.prod - args.mod);
-	} else if (mp->m_sb.sb_blocksize >= PAGE_CACHE_SIZE) {
+	} else if (mp->m_sb.sb_blocksize >= PAGE_SIZE) {
 		args.prod = 1;
 		args.mod = 0;
 	} else {
-		args.prod = PAGE_CACHE_SIZE >> mp->m_sb.sb_blocklog;
+		args.prod = PAGE_SIZE >> mp->m_sb.sb_blocklog;
 		if ((args.mod = (xfs_extlen_t)(do_mod(ap->offset, args.prod))))
 			args.mod = (xfs_extlen_t)(args.prod - args.mod);
 	}
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 5c57b7b40728..d12dfcfd0cc8 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -719,14 +719,14 @@ xfs_convert_page(
 	 * Derivation:
 	 *
 	 * End offset is the highest offset that this page should represent.
-	 * If we are on the last page, (end_offset & (PAGE_CACHE_SIZE - 1))
-	 * will evaluate non-zero and be less than PAGE_CACHE_SIZE and
+	 * If we are on the last page, (end_offset & (PAGE_SIZE - 1))
+	 * will evaluate non-zero and be less than PAGE_SIZE and
 	 * hence give us the correct page_dirty count. On any other page,
 	 * it will be zero and in that case we need page_dirty to be the
 	 * count of buffers on the page.
 	 */
 	end_offset = min_t(unsigned long long,
-			(xfs_off_t)(page->index + 1) << PAGE_CACHE_SHIFT,
+			(xfs_off_t)(page->index + 1) << PAGE_SHIFT,
 			i_size_read(inode));
 
 	/*
@@ -749,9 +749,9 @@ xfs_convert_page(
 		goto fail_unlock_page;
 
 	len = 1 << inode->i_blkbits;
-	p_offset = min_t(unsigned long, end_offset & (PAGE_CACHE_SIZE - 1),
-					PAGE_CACHE_SIZE);
-	p_offset = p_offset ? roundup(p_offset, len) : PAGE_CACHE_SIZE;
+	p_offset = min_t(unsigned long, end_offset & (PAGE_SIZE - 1),
+					PAGE_SIZE);
+	p_offset = p_offset ? roundup(p_offset, len) : PAGE_SIZE;
 	page_dirty = p_offset / len;
 
 	/*
@@ -927,7 +927,7 @@ next_buffer:
 
 	xfs_iunlock(ip, XFS_ILOCK_EXCL);
 out_invalidate:
-	xfs_vm_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+	xfs_vm_invalidatepage(page, 0, PAGE_SIZE);
 	return;
 }
 
@@ -984,8 +984,8 @@ xfs_vm_writepage(
 
 	/* Is this page beyond the end of the file? */
 	offset = i_size_read(inode);
-	end_index = offset >> PAGE_CACHE_SHIFT;
-	last_index = (offset - 1) >> PAGE_CACHE_SHIFT;
+	end_index = offset >> PAGE_SHIFT;
+	last_index = (offset - 1) >> PAGE_SHIFT;
 
 	/*
 	 * The page index is less than the end_index, adjust the end_offset
@@ -999,7 +999,7 @@ xfs_vm_writepage(
 	 * ---------------------------------^------------------|
 	 */
 	if (page->index < end_index)
-		end_offset = (xfs_off_t)(page->index + 1) << PAGE_CACHE_SHIFT;
+		end_offset = (xfs_off_t)(page->index + 1) << PAGE_SHIFT;
 	else {
 		/*
 		 * Check whether the page to write out is beyond or straddles
@@ -1012,7 +1012,7 @@ xfs_vm_writepage(
 		 * |				    |      Straddles     |
 		 * ---------------------------------^-----------|--------|
 		 */
-		unsigned offset_into_page = offset & (PAGE_CACHE_SIZE - 1);
+		unsigned offset_into_page = offset & (PAGE_SIZE - 1);
 
 		/*
 		 * Skip the page if it is fully outside i_size, e.g. due to a
@@ -1043,7 +1043,7 @@ xfs_vm_writepage(
 		 * memory is zeroed when mapped, and writes to that region are
 		 * not written out to the file."
 		 */
-		zero_user_segment(page, offset_into_page, PAGE_CACHE_SIZE);
+		zero_user_segment(page, offset_into_page, PAGE_SIZE);
 
 		/* Adjust the end_offset to the end of file */
 		end_offset = offset;
@@ -1162,7 +1162,7 @@ xfs_vm_writepage(
 		end_index <<= inode->i_blkbits;
 
 		/* to pages */
-		end_index = (end_index - 1) >> PAGE_CACHE_SHIFT;
+		end_index = (end_index - 1) >> PAGE_SHIFT;
 
 		/* check against file size */
 		if (end_index > last_index)
@@ -1753,7 +1753,7 @@ xfs_vm_write_failed(
 	loff_t			block_offset;
 	loff_t			block_start;
 	loff_t			block_end;
-	loff_t			from = pos & (PAGE_CACHE_SIZE - 1);
+	loff_t			from = pos & (PAGE_SIZE - 1);
 	loff_t			to = from + len;
 	struct buffer_head	*bh, *head;
 
@@ -1768,7 +1768,7 @@ xfs_vm_write_failed(
 	 * start of the page by using shifts rather than masks the mismatch
 	 * problem.
 	 */
-	block_offset = (pos >> PAGE_CACHE_SHIFT) << PAGE_CACHE_SHIFT;
+	block_offset = (pos >> PAGE_SHIFT) << PAGE_SHIFT;
 
 	ASSERT(block_offset + from == pos);
 
@@ -1825,11 +1825,11 @@ xfs_vm_write_begin(
 	struct page		**pagep,
 	void			**fsdata)
 {
-	pgoff_t			index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t			index = pos >> PAGE_SHIFT;
 	struct page		*page;
 	int			status;
 
-	ASSERT(len <= PAGE_CACHE_SIZE);
+	ASSERT(len <= PAGE_SIZE);
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
@@ -1854,7 +1854,7 @@ xfs_vm_write_begin(
 			truncate_pagecache_range(inode, start, pos + len);
 		}
 
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 
@@ -1882,7 +1882,7 @@ xfs_vm_write_end(
 {
 	int			ret;
 
-	ASSERT(len <= PAGE_CACHE_SIZE);
+	ASSERT(len <= PAGE_SIZE);
 
 	ret = generic_write_end(file, mapping, pos, len, copied, page, fsdata);
 	if (unlikely(ret < len)) {
diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index 6c876012b2e5..d788858da5e1 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -1235,7 +1235,7 @@ xfs_free_file_space(
 	/* wait for the completion of any pending DIOs */
 	inode_dio_wait(VFS_I(ip));
 
-	rounding = max_t(xfs_off_t, 1 << mp->m_sb.sb_blocklog, PAGE_CACHE_SIZE);
+	rounding = max_t(xfs_off_t, 1 << mp->m_sb.sb_blocklog, PAGE_SIZE);
 	ioffset = round_down(offset, rounding);
 	iendoffset = round_up(offset + len, rounding) - 1;
 	error = filemap_write_and_wait_range(VFS_I(ip)->i_mapping, ioffset,
@@ -1464,7 +1464,7 @@ xfs_shift_file_space(
 	if (error)
 		return error;
 	error = invalidate_inode_pages2_range(VFS_I(ip)->i_mapping,
-					offset >> PAGE_CACHE_SHIFT, -1);
+					offset >> PAGE_SHIFT, -1);
 	if (error)
 		return error;
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 52883ac3cf84..aab748adf273 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -106,8 +106,8 @@ xfs_iozero(
 		unsigned offset, bytes;
 		void *fsdata;
 
-		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
-		bytes = PAGE_CACHE_SIZE - offset;
+		offset = (pos & (PAGE_SIZE -1)); /* Within page */
+		bytes = PAGE_SIZE - offset;
 		if (bytes > count)
 			bytes = count;
 
@@ -799,8 +799,8 @@ xfs_file_dio_aio_write(
 	/* see generic_file_direct_write() for why this is necessary */
 	if (mapping->nrpages) {
 		invalidate_inode_pages2_range(mapping,
-					      pos >> PAGE_CACHE_SHIFT,
-					      end >> PAGE_CACHE_SHIFT);
+					      pos >> PAGE_SHIFT,
+					      end >> PAGE_SHIFT);
 	}
 
 	if (ret > 0) {
@@ -1207,9 +1207,9 @@ xfs_find_get_desired_pgoff(
 
 	pagevec_init(&pvec, 0);
 
-	index = startoff >> PAGE_CACHE_SHIFT;
+	index = startoff >> PAGE_SHIFT;
 	endoff = XFS_FSB_TO_B(mp, map->br_startoff + map->br_blockcount);
-	end = endoff >> PAGE_CACHE_SHIFT;
+	end = endoff >> PAGE_SHIFT;
 	do {
 		int		want;
 		unsigned	nr_pages;
diff --git a/fs/xfs/xfs_linux.h b/fs/xfs/xfs_linux.h
index ec0e239a0fa9..a8192dc797dc 100644
--- a/fs/xfs/xfs_linux.h
+++ b/fs/xfs/xfs_linux.h
@@ -135,7 +135,7 @@ typedef __u32			xfs_nlink_t;
  * Size of block device i/o is parameterized here.
  * Currently the system supports page-sized i/o.
  */
-#define	BLKDEV_IOSHIFT		PAGE_CACHE_SHIFT
+#define	BLKDEV_IOSHIFT		PAGE_SHIFT
 #define	BLKDEV_IOSIZE		(1<<BLKDEV_IOSHIFT)
 /* number of BB's per block device block */
 #define	BLKDEV_BB		BTOBB(BLKDEV_IOSIZE)
diff --git a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
index bb753b359bee..9091e2fe1e0c 100644
--- a/fs/xfs/xfs_mount.c
+++ b/fs/xfs/xfs_mount.c
@@ -171,7 +171,7 @@ xfs_sb_validate_fsb_count(
 	ASSERT(sbp->sb_blocklog >= BBSHIFT);
 
 	/* Limited by ULONG_MAX of page cache index */
-	if (nblocks >> (PAGE_CACHE_SHIFT - sbp->sb_blocklog) > ULONG_MAX)
+	if (nblocks >> (PAGE_SHIFT - sbp->sb_blocklog) > ULONG_MAX)
 		return -EFBIG;
 	return 0;
 }
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index b57098481c10..cd2cb5ef4c08 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -221,12 +221,12 @@ static inline unsigned long
 xfs_preferred_iosize(xfs_mount_t *mp)
 {
 	if (mp->m_flags & XFS_MOUNT_COMPAT_IOSIZE)
-		return PAGE_CACHE_SIZE;
+		return PAGE_SIZE;
 	return (mp->m_swidth ?
 		(mp->m_swidth << mp->m_sb.sb_blocklog) :
 		((mp->m_flags & XFS_MOUNT_DFLT_IOSIZE) ?
 			(1 << (int)MAX(mp->m_readio_log, mp->m_writeio_log)) :
-			PAGE_CACHE_SIZE));
+			PAGE_SIZE));
 }
 
 #define XFS_LAST_UNMOUNT_WAS_CLEAN(mp)	\
diff --git a/fs/xfs/xfs_pnfs.c b/fs/xfs/xfs_pnfs.c
index ade236e90bb3..51ddaf2c2b8c 100644
--- a/fs/xfs/xfs_pnfs.c
+++ b/fs/xfs/xfs_pnfs.c
@@ -293,8 +293,8 @@ xfs_fs_commit_blocks(
 		 * Make sure reads through the pagecache see the new data.
 		 */
 		error = invalidate_inode_pages2_range(inode->i_mapping,
-					start >> PAGE_CACHE_SHIFT,
-					(end - 1) >> PAGE_CACHE_SHIFT);
+					start >> PAGE_SHIFT,
+					(end - 1) >> PAGE_SHIFT);
 		WARN_ON_ONCE(error);
 
 		error = xfs_iomap_write_unwritten(ip, start, length);
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 59c9b7bd958d..89f1d5e064a9 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -547,10 +547,10 @@ xfs_max_file_offset(
 	/* Figure out maximum filesize, on Linux this can depend on
 	 * the filesystem blocksize (on 32 bit platforms).
 	 * __block_write_begin does this in an [unsigned] long...
-	 *      page->index << (PAGE_CACHE_SHIFT - bbits)
+	 *      page->index << (PAGE_SHIFT - bbits)
 	 * So, for page sized blocks (4K on 32 bit platforms),
 	 * this wraps at around 8Tb (hence MAX_LFS_FILESIZE which is
-	 *      (((u64)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1)
+	 *      (((u64)PAGE_SIZE << (BITS_PER_LONG-1))-1)
 	 * but for smaller blocksizes it is less (bbits = log2 bsize).
 	 * Note1: get_block_t takes a long (implicit cast from above)
 	 * Note2: The Large Block Device (LBD and HAVE_SECTOR_T) patch
@@ -561,10 +561,10 @@ xfs_max_file_offset(
 #if BITS_PER_LONG == 32
 # if defined(CONFIG_LBDAF)
 	ASSERT(sizeof(sector_t) == 8);
-	pagefactor = PAGE_CACHE_SIZE;
+	pagefactor = PAGE_SIZE;
 	bitshift = BITS_PER_LONG;
 # else
-	pagefactor = PAGE_CACHE_SIZE >> (PAGE_CACHE_SHIFT - blockshift);
+	pagefactor = PAGE_SIZE >> (PAGE_SHIFT - blockshift);
 # endif
 #endif
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
