Message-Id: <20070925233005.603319475@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:44 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 01/14] Pagecache zeroing: zero_user_segment, zero_user_segments and zero_user
Content-Disposition: inline; filename=vcompound_zero_user_segment
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Simplify page cache zeroing of segments of pages through 3 functions

zero_user_segments(page, start1, end1, start2, end2)

        Zeros two segments of the page. It takes the position where to
        start and end the zeroing which avoids length calculations and
	makes code clearer.

zero_user_segment(page, start, end)

        Same for a single segment.

zero_user(page, start, length)

        Length variant for the case where we know the length.

We remove the zero_user_page macro. Issues:

1. Its a macro. Inline functions are preferable.

2. The KM_USER0 macro is only defined for HIGHMEM.

   Having to treat this special case everywhere makes the
   code needlessly complex. The parameter for zeroing is always
   KM_USER0 except in one single case that we open code.

Avoiding KM_USER0 makes a lot of code not having to be dealing
with the special casing for HIGHMEM anymore. Dealing with
kmap is only necessary for HIGHMEM configurations. In those
configurations we use KM_USER0 like we do for a series of other
functions defined in highmem.h.

Since KM_USER0 is depends on HIGHMEM the existing zero_user_page
function could not be a macro. zero_user_* functions introduced
here can be be inline because that constant is not used when these
functions are called.

Also extract the flushing of the caches to be outside of the kmap.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/buffer.c                |   47 +++++++++++++------------------------------
 fs/cifs/inode.c            |    2 -
 fs/direct-io.c             |    4 +--
 fs/ecryptfs/mmap.c         |    7 ++----
 fs/ext3/inode.c            |    4 +--
 fs/ext4/inode.c            |    4 +--
 fs/gfs2/bmap.c             |    2 -
 fs/gfs2/ops_address.c      |    2 -
 fs/libfs.c                 |   11 +++-------
 fs/mpage.c                 |    7 +-----
 fs/nfs/read.c              |   10 ++++-----
 fs/nfs/write.c             |    2 -
 fs/ntfs/aops.c             |   18 +++++++++-------
 fs/ntfs/file.c             |   32 +++++++++++++----------------
 fs/ocfs2/aops.c            |    6 ++---
 fs/reiserfs/inode.c        |    4 +--
 fs/xfs/linux-2.6/xfs_lrw.c |    2 -
 include/linux/highmem.h    |   49 ++++++++++++++++++++++++++++-----------------
 mm/filemap_xip.c           |    2 -
 mm/truncate.c              |    2 -
 20 files changed, 103 insertions(+), 114 deletions(-)

Index: linux-2.6.23-rc8-mm1/fs/buffer.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/buffer.c	2007-09-25 15:08:14.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/buffer.c	2007-09-25 15:14:40.000000000 -0700
@@ -1805,7 +1805,7 @@ void page_zero_new_buffers(struct page *
 					start = max(from, block_start);
 					size = min(to, block_end) - start;
 
-					zero_user_page(page, start, size, KM_USER0);
+					zero_user(page, start, size);
 					set_buffer_uptodate(bh);
 				}
 
@@ -1868,19 +1868,10 @@ static int __block_prepare_write(struct 
 					mark_buffer_dirty(bh);
 					continue;
 				}
-				if (block_end > to || block_start < from) {
-					void *kaddr;
-
-					kaddr = kmap_atomic(page, KM_USER0);
-					if (block_end > to)
-						memset(kaddr+to, 0,
-							block_end-to);
-					if (block_start < from)
-						memset(kaddr+block_start,
-							0, from-block_start);
-					flush_dcache_page(page);
-					kunmap_atomic(kaddr, KM_USER0);
-				}
+				if (block_end > to || block_start < from)
+					zero_user_segments(page,
+						to, block_end,
+						block_start, from);
 				continue;
 			}
 		}
@@ -2111,8 +2102,7 @@ int block_read_full_page(struct page *pa
 					SetPageError(page);
 			}
 			if (!buffer_mapped(bh)) {
-				zero_user_page(page, i * blocksize, blocksize,
-						KM_USER0);
+				zero_user(page, i * blocksize, blocksize);
 				if (!err)
 					set_buffer_uptodate(bh);
 				continue;
@@ -2225,7 +2215,7 @@ int cont_expand_zero(struct file *file, 
 						&page, &fsdata);
 		if (err)
 			goto out;
-		zero_user_page(page, zerofrom, len, KM_USER0);
+		zero_user(page, zerofrom, len);
 		err = pagecache_write_end(file, mapping, curpos, len, len,
 						page, fsdata);
 		if (err < 0)
@@ -2252,7 +2242,7 @@ int cont_expand_zero(struct file *file, 
 						&page, &fsdata);
 		if (err)
 			goto out;
-		zero_user_page(page, zerofrom, len, KM_USER0);
+		zero_user(page, zerofrom, len);
 		err = pagecache_write_end(file, mapping, curpos, len, len,
 						page, fsdata);
 		if (err < 0)
@@ -2400,7 +2390,6 @@ int nobh_prepare_write(struct page *page
 	unsigned block_in_page;
 	unsigned block_start, block_end;
 	sector_t block_in_file;
-	char *kaddr;
 	int nr_reads = 0;
 	int ret = 0;
 	int is_mapped_to_disk = 1;
@@ -2454,13 +2443,8 @@ int nobh_prepare_write(struct page *page
 			continue;
 		}
 		if (buffer_new(bh) || !buffer_mapped(bh)) {
-			kaddr = kmap_atomic(page, KM_USER0);
-			if (block_start < from)
-				memset(kaddr+block_start, 0, from-block_start);
-			if (block_end > to)
-				memset(kaddr + to, 0, block_end - to);
-			flush_dcache_page(page);
-			kunmap_atomic(kaddr, KM_USER0);
+			zero_user_segments(page, block_start, from,
+							to, block_end);
 			continue;
 		}
 		if (buffer_uptodate(bh))
@@ -2525,7 +2509,7 @@ failed:
 		if (buffer_new(bh)) {
 			clear_buffer_new(bh);
 			if (!buffer_uptodate(bh)) {
-				zero_user_page(page, block_start, bh->b_size, KM_USER0);
+				zero_user(page, block_start, bh->b_size);
 				set_buffer_uptodate(bh);
 			}
 			mark_buffer_dirty(bh);
@@ -2608,7 +2592,7 @@ int nobh_writepage(struct page *page, ge
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_page(page, offset, PAGE_CACHE_SIZE - offset, KM_USER0);
+	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
 out:
 	ret = mpage_writepage(page, get_block, wbc);
 	if (ret == -EAGAIN)
@@ -2642,8 +2626,7 @@ int nobh_truncate_page(struct address_sp
 	to = (offset + blocksize) & ~(blocksize - 1);
 	ret = a_ops->prepare_write(NULL, page, offset, to);
 	if (ret == 0) {
-		zero_user_page(page, offset, PAGE_CACHE_SIZE - offset,
-				KM_USER0);
+		zero_user_segment(page, offset, PAGE_CACHE_SIZE);
 		/*
 		 * It would be more correct to call aops->commit_write()
 		 * here, but this is more efficient.
@@ -2722,7 +2705,7 @@ int block_truncate_page(struct address_s
 			goto unlock;
 	}
 
-	zero_user_page(page, offset, length, KM_USER0);
+	zero_user(page, offset, length);
 	mark_buffer_dirty(bh);
 	err = 0;
 
@@ -2768,7 +2751,7 @@ int block_write_full_page(struct page *p
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_page(page, offset, PAGE_CACHE_SIZE - offset, KM_USER0);
+	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
 	return __block_write_full_page(inode, page, get_block, wbc);
 }
 
Index: linux-2.6.23-rc8-mm1/fs/cifs/inode.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/cifs/inode.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/cifs/inode.c	2007-09-25 15:08:45.000000000 -0700
@@ -1361,7 +1361,7 @@ static int cifs_truncate_page(struct add
 	if (!page)
 		return -ENOMEM;
 
-	zero_user_page(page, offset, PAGE_CACHE_SIZE - offset, KM_USER0);
+	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
 	unlock_page(page);
 	page_cache_release(page);
 	return rc;
Index: linux-2.6.23-rc8-mm1/fs/direct-io.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/direct-io.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/direct-io.c	2007-09-25 15:08:45.000000000 -0700
@@ -887,8 +887,8 @@ do_holes:
 					page_cache_release(page);
 					goto out;
 				}
-				zero_user_page(page, block_in_page << blkbits,
-						1 << blkbits, KM_USER0);
+				zero_user(page, block_in_page << blkbits,
+						1 << blkbits);
 				dio->block_in_file++;
 				block_in_page++;
 				goto next_block;
Index: linux-2.6.23-rc8-mm1/fs/ecryptfs/mmap.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/ecryptfs/mmap.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/ecryptfs/mmap.c	2007-09-25 15:08:45.000000000 -0700
@@ -251,8 +251,7 @@ static int fill_zeros_to_end_of_page(str
 	end_byte_in_page = i_size_read(inode) % PAGE_CACHE_SIZE;
 	if (to > end_byte_in_page)
 		end_byte_in_page = to;
-	zero_user_page(page, end_byte_in_page,
-		PAGE_CACHE_SIZE - end_byte_in_page, KM_USER0);
+	zero_user_segment(page, end_byte_in_page, PAGE_CACHE_SIZE);
 out:
 	return 0;
 }
@@ -284,7 +283,7 @@ static int ecryptfs_prepare_write(struct
 			}
 		}
 		if (end_of_prev_pg_pos + 1 > i_size_read(page->mapping->host))
-			zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+			zero_user(page, 0, PAGE_CACHE_SIZE);
 	}
 out:
 	return rc;
Index: linux-2.6.23-rc8-mm1/fs/ext3/inode.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/ext3/inode.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/ext3/inode.c	2007-09-25 15:08:45.000000000 -0700
@@ -1845,7 +1845,7 @@ static int ext3_block_truncate_page(hand
 	 */
 	if (!page_has_buffers(page) && test_opt(inode->i_sb, NOBH) &&
 	     ext3_should_writeback_data(inode) && PageUptodate(page)) {
-		zero_user_page(page, offset, length, KM_USER0);
+		zero_user(page, offset, length);
 		set_page_dirty(page);
 		goto unlock;
 	}
@@ -1898,7 +1898,7 @@ static int ext3_block_truncate_page(hand
 			goto unlock;
 	}
 
-	zero_user_page(page, offset, length, KM_USER0);
+	zero_user(page, offset, length);
 	BUFFER_TRACE(bh, "zeroed end of block");
 
 	err = 0;
Index: linux-2.6.23-rc8-mm1/fs/ext4/inode.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/ext4/inode.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/ext4/inode.c	2007-09-25 15:08:45.000000000 -0700
@@ -1873,7 +1873,7 @@ int ext4_block_truncate_page(handle_t *h
 	 */
 	if (!page_has_buffers(page) && test_opt(inode->i_sb, NOBH) &&
 	     ext4_should_writeback_data(inode) && PageUptodate(page)) {
-		zero_user_page(page, offset, length, KM_USER0);
+		zero_user(page, offset, length);
 		set_page_dirty(page);
 		goto unlock;
 	}
@@ -1926,7 +1926,7 @@ int ext4_block_truncate_page(handle_t *h
 			goto unlock;
 	}
 
-	zero_user_page(page, offset, length, KM_USER0);
+	zero_user(page, offset, length);
 
 	BUFFER_TRACE(bh, "zeroed end of block");
 
Index: linux-2.6.23-rc8-mm1/fs/gfs2/bmap.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/gfs2/bmap.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/gfs2/bmap.c	2007-09-25 15:08:45.000000000 -0700
@@ -934,7 +934,7 @@ static int gfs2_block_truncate_page(stru
 	if (sdp->sd_args.ar_data == GFS2_DATA_ORDERED || gfs2_is_jdata(ip))
 		gfs2_trans_add_bh(ip->i_gl, bh, 0);
 
-	zero_user_page(page, offset, length, KM_USER0);
+	zero_user(page, offset, length);
 
 unlock:
 	unlock_page(page);
Index: linux-2.6.23-rc8-mm1/fs/gfs2/ops_address.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/gfs2/ops_address.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/gfs2/ops_address.c	2007-09-25 15:08:45.000000000 -0700
@@ -209,7 +209,7 @@ static int stuffed_readpage(struct gfs2_
 	 * so we need to supply one here. It doesn't happen often.
 	 */
 	if (unlikely(page->index)) {
-		zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+		zero_user(page, 0, PAGE_CACHE_SIZE);
 		return 0;
 	}
 
Index: linux-2.6.23-rc8-mm1/fs/libfs.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/libfs.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/libfs.c	2007-09-25 15:08:45.000000000 -0700
@@ -341,13 +341,10 @@ int simple_prepare_write(struct file *fi
 			unsigned from, unsigned to)
 {
 	if (!PageUptodate(page)) {
-		if (to - from != PAGE_CACHE_SIZE) {
-			void *kaddr = kmap_atomic(page, KM_USER0);
-			memset(kaddr, 0, from);
-			memset(kaddr + to, 0, PAGE_CACHE_SIZE - to);
-			flush_dcache_page(page);
-			kunmap_atomic(kaddr, KM_USER0);
-		}
+		if (to - from != PAGE_CACHE_SIZE)
+			zero_user_segments(page,
+				0, from,
+				to, PAGE_CACHE_SIZE);
 	}
 	return 0;
 }
Index: linux-2.6.23-rc8-mm1/fs/mpage.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/mpage.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/mpage.c	2007-09-25 15:08:45.000000000 -0700
@@ -284,9 +284,7 @@ do_mpage_readpage(struct bio *bio, struc
 	}
 
 	if (first_hole != blocks_per_page) {
-		zero_user_page(page, first_hole << blkbits,
-				PAGE_CACHE_SIZE - (first_hole << blkbits),
-				KM_USER0);
+		zero_user_segment(page, first_hole << blkbits, PAGE_CACHE_SIZE);
 		if (first_hole == 0) {
 			SetPageUptodate(page);
 			unlock_page(page);
@@ -579,8 +577,7 @@ page_is_mapped:
 
 		if (page->index > end_index || !offset)
 			goto confused;
-		zero_user_page(page, offset, PAGE_CACHE_SIZE - offset,
-				KM_USER0);
+		zero_user_segment(page, offset, PAGE_CACHE_SIZE);
 	}
 
 	/*
Index: linux-2.6.23-rc8-mm1/fs/nfs/read.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/nfs/read.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/nfs/read.c	2007-09-25 15:08:45.000000000 -0700
@@ -79,7 +79,7 @@ void nfs_readdata_release(void *data)
 static
 int nfs_return_empty_page(struct page *page)
 {
-	zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+	zero_user(page, 0, PAGE_CACHE_SIZE);
 	SetPageUptodate(page);
 	unlock_page(page);
 	return 0;
@@ -103,10 +103,10 @@ static void nfs_readpage_truncate_uninit
 	pglen = PAGE_CACHE_SIZE - base;
 	for (;;) {
 		if (remainder <= pglen) {
-			zero_user_page(*pages, base, remainder, KM_USER0);
+			zero_user(*pages, base, remainder);
 			break;
 		}
-		zero_user_page(*pages, base, pglen, KM_USER0);
+		zero_user(*pages, base, pglen);
 		pages++;
 		remainder -= pglen;
 		pglen = PAGE_CACHE_SIZE;
@@ -130,7 +130,7 @@ static int nfs_readpage_async(struct nfs
 		return PTR_ERR(new);
 	}
 	if (len < PAGE_CACHE_SIZE)
-		zero_user_page(page, len, PAGE_CACHE_SIZE - len, KM_USER0);
+		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 
 	nfs_list_add_request(new, &one_request);
 	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
@@ -537,7 +537,7 @@ readpage_async_filler(void *data, struct
 		goto out_error;
 
 	if (len < PAGE_CACHE_SIZE)
-		zero_user_page(page, len, PAGE_CACHE_SIZE - len, KM_USER0);
+		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 	nfs_pageio_add_request(desc->pgio, new);
 	return 0;
 out_error:
Index: linux-2.6.23-rc8-mm1/fs/nfs/write.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/nfs/write.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/nfs/write.c	2007-09-25 15:08:45.000000000 -0700
@@ -175,7 +175,7 @@ static void nfs_mark_uptodate(struct pag
 	if (count != nfs_page_length(page))
 		return;
 	if (count != PAGE_CACHE_SIZE)
-		zero_user_page(page, count, PAGE_CACHE_SIZE - count, KM_USER0);
+		zero_user_segment(page, count, PAGE_CACHE_SIZE);
 	SetPageUptodate(page);
 }
 
Index: linux-2.6.23-rc8-mm1/fs/ntfs/aops.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/ntfs/aops.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/ntfs/aops.c	2007-09-25 15:08:45.000000000 -0700
@@ -87,13 +87,17 @@ static void ntfs_end_buffer_async_read(s
 		/* Check for the current buffer head overflowing. */
 		if (unlikely(file_ofs + bh->b_size > init_size)) {
 			int ofs;
+			void *kaddr;
 
 			ofs = 0;
 			if (file_ofs < init_size)
 				ofs = init_size - file_ofs;
 			local_irq_save(flags);
-			zero_user_page(page, bh_offset(bh) + ofs,
-					 bh->b_size - ofs, KM_BIO_SRC_IRQ);
+			kaddr = kmap_atomic(page, KM_BIO_SRC_IRQ);
+			memset(kaddr + bh_offset(bh) + ofs, 0,
+					bh->b_size - ofs);
+			flush_dcache_page(page);
+			kunmap_atomic(kaddr, KM_BIO_SRC_IRQ);
 			local_irq_restore(flags);
 		}
 	} else {
@@ -334,7 +338,7 @@ handle_hole:
 		bh->b_blocknr = -1UL;
 		clear_buffer_mapped(bh);
 handle_zblock:
-		zero_user_page(page, i * blocksize, blocksize, KM_USER0);
+		zero_user(page, i * blocksize, blocksize);
 		if (likely(!err))
 			set_buffer_uptodate(bh);
 	} while (i++, iblock++, (bh = bh->b_this_page) != head);
@@ -451,7 +455,7 @@ retry_readpage:
 	 * ok to ignore the compressed flag here.
 	 */
 	if (unlikely(page->index > 0)) {
-		zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+		zero_user(page, 0, PAGE_CACHE_SIZE);
 		goto done;
 	}
 	if (!NInoAttr(ni))
@@ -780,8 +784,7 @@ lock_retry_remap:
 		if (err == -ENOENT || lcn == LCN_ENOENT) {
 			bh->b_blocknr = -1;
 			clear_buffer_dirty(bh);
-			zero_user_page(page, bh_offset(bh), blocksize,
-					KM_USER0);
+			zero_user(page, bh_offset(bh), blocksize);
 			set_buffer_uptodate(bh);
 			err = 0;
 			continue;
@@ -1406,8 +1409,7 @@ retry_writepage:
 		if (page->index >= (i_size >> PAGE_CACHE_SHIFT)) {
 			/* The page straddles i_size. */
 			unsigned int ofs = i_size & ~PAGE_CACHE_MASK;
-			zero_user_page(page, ofs, PAGE_CACHE_SIZE - ofs,
-					KM_USER0);
+			zero_user_segment(page, ofs, PAGE_CACHE_SIZE);
 		}
 		/* Handle mst protected attributes. */
 		if (NInoMstProtected(ni))
Index: linux-2.6.23-rc8-mm1/fs/ntfs/file.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/ntfs/file.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/ntfs/file.c	2007-09-25 15:08:45.000000000 -0700
@@ -606,8 +606,8 @@ do_next_page:
 					ntfs_submit_bh_for_read(bh);
 					*wait_bh++ = bh;
 				} else {
-					zero_user_page(page, bh_offset(bh),
-							blocksize, KM_USER0);
+					zero_user(page, bh_offset(bh),
+							blocksize);
 					set_buffer_uptodate(bh);
 				}
 			}
@@ -682,9 +682,8 @@ map_buffer_cached:
 						ntfs_submit_bh_for_read(bh);
 						*wait_bh++ = bh;
 					} else {
-						zero_user_page(page,
-							bh_offset(bh),
-							blocksize, KM_USER0);
+						zero_user(page, bh_offset(bh),
+								blocksize);
 						set_buffer_uptodate(bh);
 					}
 				}
@@ -702,8 +701,8 @@ map_buffer_cached:
 			 */
 			if (bh_end <= pos || bh_pos >= end) {
 				if (!buffer_uptodate(bh)) {
-					zero_user_page(page, bh_offset(bh),
-							blocksize, KM_USER0);
+					zero_user(page, bh_offset(bh),
+							blocksize);
 					set_buffer_uptodate(bh);
 				}
 				mark_buffer_dirty(bh);
@@ -742,8 +741,7 @@ map_buffer_cached:
 				if (!buffer_uptodate(bh))
 					set_buffer_uptodate(bh);
 			} else if (!buffer_uptodate(bh)) {
-				zero_user_page(page, bh_offset(bh), blocksize,
-						KM_USER0);
+				zero_user(page, bh_offset(bh), blocksize);
 				set_buffer_uptodate(bh);
 			}
 			continue;
@@ -867,8 +865,8 @@ rl_not_mapped_enoent:
 					if (!buffer_uptodate(bh))
 						set_buffer_uptodate(bh);
 				} else if (!buffer_uptodate(bh)) {
-					zero_user_page(page, bh_offset(bh),
-							blocksize, KM_USER0);
+					zero_user(page, bh_offset(bh),
+						blocksize);
 					set_buffer_uptodate(bh);
 				}
 				continue;
@@ -1127,8 +1125,8 @@ rl_not_mapped_enoent:
 
 				if (likely(bh_pos < initialized_size))
 					ofs = initialized_size - bh_pos;
-				zero_user_page(page, bh_offset(bh) + ofs,
-						blocksize - ofs, KM_USER0);
+				zero_user_segment(page, bh_offset(bh) + ofs,
+						blocksize);
 			}
 		} else /* if (unlikely(!buffer_uptodate(bh))) */
 			err = -EIO;
@@ -1268,8 +1266,8 @@ rl_not_mapped_enoent:
 				if (PageUptodate(page))
 					set_buffer_uptodate(bh);
 				else {
-					zero_user_page(page, bh_offset(bh),
-							blocksize, KM_USER0);
+					zero_user(page, bh_offset(bh),
+							blocksize);
 					set_buffer_uptodate(bh);
 				}
 			}
@@ -1329,7 +1327,7 @@ err_out:
 		len = PAGE_CACHE_SIZE;
 		if (len > bytes)
 			len = bytes;
-		zero_user_page(*pages, 0, len, KM_USER0);
+		zero_user(*pages, 0, len);
 	}
 	goto out;
 }
@@ -1450,7 +1448,7 @@ err_out:
 		len = PAGE_CACHE_SIZE;
 		if (len > bytes)
 			len = bytes;
-		zero_user_page(*pages, 0, len, KM_USER0);
+		zero_user(*pages, 0, len);
 	}
 	goto out;
 }
Index: linux-2.6.23-rc8-mm1/fs/ocfs2/aops.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/ocfs2/aops.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/ocfs2/aops.c	2007-09-25 15:08:45.000000000 -0700
@@ -299,7 +299,7 @@ static int ocfs2_readpage(struct file *f
 	 * XXX sys_readahead() seems to get that wrong?
 	 */
 	if (start >= i_size_read(inode)) {
-		zero_user_page(page, 0, PAGE_SIZE, KM_USER0);
+		zero_user(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 		ret = 0;
 		goto out_alloc;
@@ -814,7 +814,7 @@ int ocfs2_map_page_blocks(struct page *p
 		if (block_start >= to)
 			break;
 
-		zero_user_page(page, block_start, bh->b_size, KM_USER0);
+		zero_user(page, block_start, bh->b_size);
 		set_buffer_uptodate(bh);
 		mark_buffer_dirty(bh);
 
@@ -979,7 +979,7 @@ static void ocfs2_zero_new_buffers(struc
 					start = max(from, block_start);
 					end = min(to, block_end);
 
-					zero_user_page(page, start, end - start, KM_USER0);
+					zero_user_segment(page, start, end);
 					set_buffer_uptodate(bh);
 				}
 
Index: linux-2.6.23-rc8-mm1/fs/reiserfs/inode.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/reiserfs/inode.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/reiserfs/inode.c	2007-09-25 15:08:45.000000000 -0700
@@ -2143,7 +2143,7 @@ int reiserfs_truncate_file(struct inode 
 		/* if we are not on a block boundary */
 		if (length) {
 			length = blocksize - length;
-			zero_user_page(page, offset, length, KM_USER0);
+			zero_user(page, offset, length);
 			if (buffer_mapped(bh) && bh->b_blocknr != 0) {
 				mark_buffer_dirty(bh);
 			}
@@ -2367,7 +2367,7 @@ static int reiserfs_write_full_page(stru
 			unlock_page(page);
 			return 0;
 		}
-		zero_user_page(page, last_offset, PAGE_CACHE_SIZE - last_offset, KM_USER0);
+		zero_user_segment(page, last_offset, PAGE_CACHE_SIZE);
 	}
 	bh = head;
 	block = page->index << (PAGE_CACHE_SHIFT - s->s_blocksize_bits);
Index: linux-2.6.23-rc8-mm1/fs/xfs/linux-2.6/xfs_lrw.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/xfs/linux-2.6/xfs_lrw.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/xfs/linux-2.6/xfs_lrw.c	2007-09-25 15:08:45.000000000 -0700
@@ -156,7 +156,7 @@ xfs_iozero(
 		if (status)
 			break;
 
-		zero_user_page(page, offset, bytes, KM_USER0);
+		zero_user(page, offset, bytes);
 
 		status = pagecache_write_end(NULL, mapping, pos, bytes, bytes,
 					page, fsdata);
Index: linux-2.6.23-rc8-mm1/include/linux/highmem.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/highmem.h	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/linux/highmem.h	2007-09-25 15:08:45.000000000 -0700
@@ -124,28 +124,41 @@ static inline void clear_highpage(struct
 	kunmap_atomic(kaddr, KM_USER0);
 }
 
-/*
- * Same but also flushes aliased cache contents to RAM.
- *
- * This must be a macro because KM_USER0 and friends aren't defined if
- * !CONFIG_HIGHMEM
- */
-#define zero_user_page(page, offset, size, km_type)		\
-	do {							\
-		void *kaddr;					\
-								\
-		BUG_ON((offset) + (size) > PAGE_SIZE);		\
-								\
-		kaddr = kmap_atomic(page, km_type);		\
-		memset((char *)kaddr + (offset), 0, (size));	\
-		flush_dcache_page(page);			\
-		kunmap_atomic(kaddr, (km_type));		\
-	} while (0)
+static inline void zero_user_segments(struct page *page,
+	unsigned start1, unsigned end1,
+	unsigned start2, unsigned end2)
+{
+	void *kaddr = kmap_atomic(page, KM_USER0);
+
+	BUG_ON(end1 > PAGE_SIZE ||
+		end2 > PAGE_SIZE);
+
+	if (end1 > start1)
+		memset(kaddr + start1, 0, end1 - start1);
+
+	if (end2 > start2)
+		memset(kaddr + start2, 0, end2 - start2);
+
+	kunmap_atomic(kaddr, KM_USER0);
+	flush_dcache_page(page);
+}
+
+static inline void zero_user_segment(struct page *page,
+	unsigned start, unsigned end)
+{
+	zero_user_segments(page, start, end, 0, 0);
+}
+
+static inline void zero_user(struct page *page,
+	unsigned start, unsigned size)
+{
+	zero_user_segments(page, start, start + size, 0, 0);
+}
 
 static inline void __deprecated memclear_highpage_flush(struct page *page,
 			unsigned int offset, unsigned int size)
 {
-	zero_user_page(page, offset, size, KM_USER0);
+	zero_user(page, offset, size);
 }
 
 #ifndef __HAVE_ARCH_COPY_USER_HIGHPAGE
Index: linux-2.6.23-rc8-mm1/mm/filemap_xip.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/filemap_xip.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/filemap_xip.c	2007-09-25 15:08:45.000000000 -0700
@@ -430,7 +430,7 @@ xip_truncate_page(struct address_space *
 		else
 			return PTR_ERR(page);
 	}
-	zero_user_page(page, offset, length, KM_USER0);
+	zero_user(page, offset, length);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xip_truncate_page);
Index: linux-2.6.23-rc8-mm1/mm/truncate.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/truncate.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/truncate.c	2007-09-25 15:08:45.000000000 -0700
@@ -48,7 +48,7 @@ void do_invalidatepage(struct page *page
 
 static inline void truncate_partial_page(struct page *page, unsigned partial)
 {
-	zero_user_page(page, partial, PAGE_CACHE_SIZE - partial, KM_USER0);
+	zero_user_segment(page, partial, PAGE_CACHE_SIZE);
 	if (PagePrivate(page))
 		do_invalidatepage(page, partial);
 }
Index: linux-2.6.23-rc8-mm1/fs/ocfs2/alloc.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/ocfs2/alloc.c	2007-09-25 15:14:39.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/ocfs2/alloc.c	2007-09-25 15:14:46.000000000 -0700
@@ -5646,7 +5646,7 @@ static void ocfs2_map_and_dirty_page(str
 		mlog_errno(ret);
 
 	if (zero)
-		zero_user_page(page, from, to - from, KM_USER0);
+		zero_user_segment(page, from, to);
 
 	/*
 	 * Need to set the buffers we zero'd into uptodate

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
