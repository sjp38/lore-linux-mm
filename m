Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B3F21830AE
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:50:12 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id n5so237585683pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:50:12 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id oi7si1467849pab.183.2016.03.20.11.41.50
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 52/71] ntfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:59 +0300
Message-Id: <1458499278-1516-53-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anton Altaparmakov <anton@tuxera.com>

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
Cc: Anton Altaparmakov <anton@tuxera.com>
---
 fs/ntfs/aops.c     | 50 +++++++++++++++++------------------
 fs/ntfs/aops.h     |  4 +--
 fs/ntfs/attrib.c   | 28 ++++++++++----------
 fs/ntfs/bitmap.c   | 10 +++----
 fs/ntfs/compress.c | 77 ++++++++++++++++++++++++------------------------------
 fs/ntfs/dir.c      | 56 +++++++++++++++++++--------------------
 fs/ntfs/file.c     | 56 +++++++++++++++++++--------------------
 fs/ntfs/index.c    | 14 +++++-----
 fs/ntfs/inode.c    | 12 ++++-----
 fs/ntfs/lcnalloc.c |  6 ++---
 fs/ntfs/logfile.c  | 16 ++++++------
 fs/ntfs/mft.c      | 34 ++++++++++++------------
 fs/ntfs/ntfs.h     |  2 +-
 fs/ntfs/super.c    | 72 +++++++++++++++++++++++++-------------------------
 14 files changed, 214 insertions(+), 223 deletions(-)

diff --git a/fs/ntfs/aops.c b/fs/ntfs/aops.c
index 7521e11db728..97768a1379f2 100644
--- a/fs/ntfs/aops.c
+++ b/fs/ntfs/aops.c
@@ -74,7 +74,7 @@ static void ntfs_end_buffer_async_read(struct buffer_head *bh, int uptodate)
 
 		set_buffer_uptodate(bh);
 
-		file_ofs = ((s64)page->index << PAGE_CACHE_SHIFT) +
+		file_ofs = ((s64)page->index << PAGE_SHIFT) +
 				bh_offset(bh);
 		read_lock_irqsave(&ni->size_lock, flags);
 		init_size = ni->initialized_size;
@@ -142,7 +142,7 @@ static void ntfs_end_buffer_async_read(struct buffer_head *bh, int uptodate)
 		u32 rec_size;
 
 		rec_size = ni->itype.index.block_size;
-		recs = PAGE_CACHE_SIZE / rec_size;
+		recs = PAGE_SIZE / rec_size;
 		/* Should have been verified before we got here... */
 		BUG_ON(!recs);
 		local_irq_save(flags);
@@ -229,7 +229,7 @@ static int ntfs_read_block(struct page *page)
 	 * fully truncated, truncate will throw it away as soon as we unlock
 	 * it so no need to worry what we do with it.
 	 */
-	iblock = (s64)page->index << (PAGE_CACHE_SHIFT - blocksize_bits);
+	iblock = (s64)page->index << (PAGE_SHIFT - blocksize_bits);
 	read_lock_irqsave(&ni->size_lock, flags);
 	lblock = (ni->allocated_size + blocksize - 1) >> blocksize_bits;
 	init_size = ni->initialized_size;
@@ -412,9 +412,9 @@ retry_readpage:
 	vi = page->mapping->host;
 	i_size = i_size_read(vi);
 	/* Is the page fully outside i_size? (truncate in progress) */
-	if (unlikely(page->index >= (i_size + PAGE_CACHE_SIZE - 1) >>
-			PAGE_CACHE_SHIFT)) {
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+	if (unlikely(page->index >= (i_size + PAGE_SIZE - 1) >>
+			PAGE_SHIFT)) {
+		zero_user(page, 0, PAGE_SIZE);
 		ntfs_debug("Read outside i_size - truncated?");
 		goto done;
 	}
@@ -463,7 +463,7 @@ retry_readpage:
 	 * ok to ignore the compressed flag here.
 	 */
 	if (unlikely(page->index > 0)) {
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+		zero_user(page, 0, PAGE_SIZE);
 		goto done;
 	}
 	if (!NInoAttr(ni))
@@ -509,7 +509,7 @@ retry_readpage:
 			le16_to_cpu(ctx->attr->data.resident.value_offset),
 			attr_len);
 	/* Zero the remainder of the page. */
-	memset(addr + attr_len, 0, PAGE_CACHE_SIZE - attr_len);
+	memset(addr + attr_len, 0, PAGE_SIZE - attr_len);
 	flush_dcache_page(page);
 	kunmap_atomic(addr);
 put_unm_err_out:
@@ -599,7 +599,7 @@ static int ntfs_write_block(struct page *page, struct writeback_control *wbc)
 	/* NOTE: Different naming scheme to ntfs_read_block()! */
 
 	/* The first block in the page. */
-	block = (s64)page->index << (PAGE_CACHE_SHIFT - blocksize_bits);
+	block = (s64)page->index << (PAGE_SHIFT - blocksize_bits);
 
 	read_lock_irqsave(&ni->size_lock, flags);
 	i_size = i_size_read(vi);
@@ -674,7 +674,7 @@ static int ntfs_write_block(struct page *page, struct writeback_control *wbc)
 				// in the inode.
 				// Again, for each page do:
 				//	__set_page_dirty_buffers();
-				// page_cache_release()
+				// put_page()
 				// We don't need to wait on the writes.
 				// Update iblock.
 			}
@@ -925,7 +925,7 @@ static int ntfs_write_mst_block(struct page *page,
 	ntfs_volume *vol = ni->vol;
 	u8 *kaddr;
 	unsigned int rec_size = ni->itype.index.block_size;
-	ntfs_inode *locked_nis[PAGE_CACHE_SIZE / rec_size];
+	ntfs_inode *locked_nis[PAGE_SIZE / rec_size];
 	struct buffer_head *bh, *head, *tbh, *rec_start_bh;
 	struct buffer_head *bhs[MAX_BUF_PER_PAGE];
 	runlist_element *rl;
@@ -949,7 +949,7 @@ static int ntfs_write_mst_block(struct page *page,
 			(NInoAttr(ni) && ni->type == AT_INDEX_ALLOCATION)));
 	bh_size = vol->sb->s_blocksize;
 	bh_size_bits = vol->sb->s_blocksize_bits;
-	max_bhs = PAGE_CACHE_SIZE / bh_size;
+	max_bhs = PAGE_SIZE / bh_size;
 	BUG_ON(!max_bhs);
 	BUG_ON(max_bhs > MAX_BUF_PER_PAGE);
 
@@ -961,13 +961,13 @@ static int ntfs_write_mst_block(struct page *page,
 	BUG_ON(!bh);
 
 	rec_size_bits = ni->itype.index.block_size_bits;
-	BUG_ON(!(PAGE_CACHE_SIZE >> rec_size_bits));
+	BUG_ON(!(PAGE_SIZE >> rec_size_bits));
 	bhs_per_rec = rec_size >> bh_size_bits;
 	BUG_ON(!bhs_per_rec);
 
 	/* The first block in the page. */
 	rec_block = block = (sector_t)page->index <<
-			(PAGE_CACHE_SHIFT - bh_size_bits);
+			(PAGE_SHIFT - bh_size_bits);
 
 	/* The first out of bounds block for the data size. */
 	dblock = (i_size_read(vi) + bh_size - 1) >> bh_size_bits;
@@ -1133,7 +1133,7 @@ lock_retry_remap:
 			unsigned long mft_no;
 
 			/* Get the mft record number. */
-			mft_no = (((s64)page->index << PAGE_CACHE_SHIFT) + ofs)
+			mft_no = (((s64)page->index << PAGE_SHIFT) + ofs)
 					>> rec_size_bits;
 			/* Check whether to write this mft record. */
 			tni = NULL;
@@ -1249,7 +1249,7 @@ do_mirror:
 				continue;
 			ofs = bh_offset(tbh);
 			/* Get the mft record number. */
-			mft_no = (((s64)page->index << PAGE_CACHE_SHIFT) + ofs)
+			mft_no = (((s64)page->index << PAGE_SHIFT) + ofs)
 					>> rec_size_bits;
 			if (mft_no < vol->mftmirr_size)
 				ntfs_sync_mft_mirror(vol, mft_no,
@@ -1300,7 +1300,7 @@ done:
 		 * Set page error if there is only one ntfs record in the page.
 		 * Otherwise we would loose per-record granularity.
 		 */
-		if (ni->itype.index.block_size == PAGE_CACHE_SIZE)
+		if (ni->itype.index.block_size == PAGE_SIZE)
 			SetPageError(page);
 		NVolSetErrors(vol);
 	}
@@ -1308,7 +1308,7 @@ done:
 		ntfs_debug("Page still contains one or more dirty ntfs "
 				"records.  Redirtying the page starting at "
 				"record 0x%lx.", page->index <<
-				(PAGE_CACHE_SHIFT - rec_size_bits));
+				(PAGE_SHIFT - rec_size_bits));
 		redirty_page_for_writepage(wbc, page);
 		unlock_page(page);
 	} else {
@@ -1365,13 +1365,13 @@ retry_writepage:
 	BUG_ON(!PageLocked(page));
 	i_size = i_size_read(vi);
 	/* Is the page fully outside i_size? (truncate in progress) */
-	if (unlikely(page->index >= (i_size + PAGE_CACHE_SIZE - 1) >>
-			PAGE_CACHE_SHIFT)) {
+	if (unlikely(page->index >= (i_size + PAGE_SIZE - 1) >>
+			PAGE_SHIFT)) {
 		/*
 		 * The page may have dirty, unmapped buffers.  Make them
 		 * freeable here, so the page does not leak.
 		 */
-		block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		block_invalidatepage(page, 0, PAGE_SIZE);
 		unlock_page(page);
 		ntfs_debug("Write outside i_size - truncated?");
 		return 0;
@@ -1414,10 +1414,10 @@ retry_writepage:
 	/* NInoNonResident() == NInoIndexAllocPresent() */
 	if (NInoNonResident(ni)) {
 		/* We have to zero every time due to mmap-at-end-of-file. */
-		if (page->index >= (i_size >> PAGE_CACHE_SHIFT)) {
+		if (page->index >= (i_size >> PAGE_SHIFT)) {
 			/* The page straddles i_size. */
-			unsigned int ofs = i_size & ~PAGE_CACHE_MASK;
-			zero_user_segment(page, ofs, PAGE_CACHE_SIZE);
+			unsigned int ofs = i_size & ~PAGE_MASK;
+			zero_user_segment(page, ofs, PAGE_SIZE);
 		}
 		/* Handle mst protected attributes. */
 		if (NInoMstProtected(ni))
@@ -1500,7 +1500,7 @@ retry_writepage:
 			le16_to_cpu(ctx->attr->data.resident.value_offset),
 			addr, attr_len);
 	/* Zero out of bounds area in the page cache page. */
-	memset(addr + attr_len, 0, PAGE_CACHE_SIZE - attr_len);
+	memset(addr + attr_len, 0, PAGE_SIZE - attr_len);
 	kunmap_atomic(addr);
 	flush_dcache_page(page);
 	flush_dcache_mft_record_page(ctx->ntfs_ino);
diff --git a/fs/ntfs/aops.h b/fs/ntfs/aops.h
index caecc58f529c..820d6eabf60f 100644
--- a/fs/ntfs/aops.h
+++ b/fs/ntfs/aops.h
@@ -40,7 +40,7 @@
 static inline void ntfs_unmap_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /**
@@ -49,7 +49,7 @@ static inline void ntfs_unmap_page(struct page *page)
  * @index:	index into the page cache for @mapping of the page to map
  *
  * Read a page from the page cache of the address space @mapping at position
- * @index, where @index is in units of PAGE_CACHE_SIZE, and not in bytes.
+ * @index, where @index is in units of PAGE_SIZE, and not in bytes.
  *
  * If the page is not in memory it is loaded from disk first using the readpage
  * method defined in the address space operations of @mapping and the page is
diff --git a/fs/ntfs/attrib.c b/fs/ntfs/attrib.c
index 250ed5b20c8f..44a39a099b54 100644
--- a/fs/ntfs/attrib.c
+++ b/fs/ntfs/attrib.c
@@ -152,7 +152,7 @@ int ntfs_map_runlist_nolock(ntfs_inode *ni, VCN vcn, ntfs_attr_search_ctx *ctx)
 			if (old_ctx.base_ntfs_ino && old_ctx.ntfs_ino !=
 					old_ctx.base_ntfs_ino) {
 				put_this_page = old_ctx.ntfs_ino->page;
-				page_cache_get(put_this_page);
+				get_page(put_this_page);
 			}
 			/*
 			 * Reinitialize the search context so we can lookup the
@@ -275,7 +275,7 @@ retry_map:
 		 * the pieces anyway.
 		 */
 		if (put_this_page)
-			page_cache_release(put_this_page);
+			put_page(put_this_page);
 	}
 	return err;
 }
@@ -1660,7 +1660,7 @@ int ntfs_attr_make_non_resident(ntfs_inode *ni, const u32 data_size)
 		memcpy(kaddr, (u8*)a +
 				le16_to_cpu(a->data.resident.value_offset),
 				attr_size);
-		memset(kaddr + attr_size, 0, PAGE_CACHE_SIZE - attr_size);
+		memset(kaddr + attr_size, 0, PAGE_SIZE - attr_size);
 		kunmap_atomic(kaddr);
 		flush_dcache_page(page);
 		SetPageUptodate(page);
@@ -1748,7 +1748,7 @@ int ntfs_attr_make_non_resident(ntfs_inode *ni, const u32 data_size)
 	if (page) {
 		set_page_dirty(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	ntfs_debug("Done.");
 	return 0;
@@ -1835,7 +1835,7 @@ rl_err_out:
 		ntfs_free(rl);
 page_err_out:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (err == -EINVAL)
 		err = -EIO;
@@ -2513,17 +2513,17 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 	BUG_ON(NInoEncrypted(ni));
 	mapping = VFS_I(ni)->i_mapping;
 	/* Work out the starting index and page offset. */
-	idx = ofs >> PAGE_CACHE_SHIFT;
-	start_ofs = ofs & ~PAGE_CACHE_MASK;
+	idx = ofs >> PAGE_SHIFT;
+	start_ofs = ofs & ~PAGE_MASK;
 	/* Work out the ending index and page offset. */
 	end = ofs + cnt;
-	end_ofs = end & ~PAGE_CACHE_MASK;
+	end_ofs = end & ~PAGE_MASK;
 	/* If the end is outside the inode size return -ESPIPE. */
 	if (unlikely(end > i_size_read(VFS_I(ni)))) {
 		ntfs_error(vol->sb, "Request exceeds end of attribute.");
 		return -ESPIPE;
 	}
-	end >>= PAGE_CACHE_SHIFT;
+	end >>= PAGE_SHIFT;
 	/* If there is a first partial page, need to do it the slow way. */
 	if (start_ofs) {
 		page = read_mapping_page(mapping, idx, NULL);
@@ -2536,7 +2536,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		 * If the last page is the same as the first page, need to
 		 * limit the write to the end offset.
 		 */
-		size = PAGE_CACHE_SIZE;
+		size = PAGE_SIZE;
 		if (idx == end)
 			size = end_ofs;
 		kaddr = kmap_atomic(page);
@@ -2544,7 +2544,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		flush_dcache_page(page);
 		kunmap_atomic(kaddr);
 		set_page_dirty(page);
-		page_cache_release(page);
+		put_page(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
 		if (idx == end)
@@ -2561,7 +2561,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 			return -ENOMEM;
 		}
 		kaddr = kmap_atomic(page);
-		memset(kaddr, val, PAGE_CACHE_SIZE);
+		memset(kaddr, val, PAGE_SIZE);
 		flush_dcache_page(page);
 		kunmap_atomic(kaddr);
 		/*
@@ -2585,7 +2585,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		set_page_dirty(page);
 		/* Finally unlock and release the page. */
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
 	}
@@ -2602,7 +2602,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		flush_dcache_page(page);
 		kunmap_atomic(kaddr);
 		set_page_dirty(page);
-		page_cache_release(page);
+		put_page(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
 	}
diff --git a/fs/ntfs/bitmap.c b/fs/ntfs/bitmap.c
index 0809cf876098..ec130c588d2b 100644
--- a/fs/ntfs/bitmap.c
+++ b/fs/ntfs/bitmap.c
@@ -67,8 +67,8 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 	 * Calculate the indices for the pages containing the first and last
 	 * bits, i.e. @start_bit and @start_bit + @cnt - 1, respectively.
 	 */
-	index = start_bit >> (3 + PAGE_CACHE_SHIFT);
-	end_index = (start_bit + cnt - 1) >> (3 + PAGE_CACHE_SHIFT);
+	index = start_bit >> (3 + PAGE_SHIFT);
+	end_index = (start_bit + cnt - 1) >> (3 + PAGE_SHIFT);
 
 	/* Get the page containing the first bit (@start_bit). */
 	mapping = vi->i_mapping;
@@ -82,7 +82,7 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 	kaddr = page_address(page);
 
 	/* Set @pos to the position of the byte containing @start_bit. */
-	pos = (start_bit >> 3) & ~PAGE_CACHE_MASK;
+	pos = (start_bit >> 3) & ~PAGE_MASK;
 
 	/* Calculate the position of @start_bit in the first byte. */
 	bit = start_bit & 7;
@@ -108,7 +108,7 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 	 * Depending on @value, modify all remaining whole bytes in the page up
 	 * to @cnt.
 	 */
-	len = min_t(s64, cnt >> 3, PAGE_CACHE_SIZE - pos);
+	len = min_t(s64, cnt >> 3, PAGE_SIZE - pos);
 	memset(kaddr + pos, value ? 0xff : 0, len);
 	cnt -= len << 3;
 
@@ -132,7 +132,7 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 		 * Depending on @value, modify all remaining whole bytes in the
 		 * page up to @cnt.
 		 */
-		len = min_t(s64, cnt >> 3, PAGE_CACHE_SIZE);
+		len = min_t(s64, cnt >> 3, PAGE_SIZE);
 		memset(kaddr, value ? 0xff : 0, len);
 		cnt -= len << 3;
 	}
diff --git a/fs/ntfs/compress.c b/fs/ntfs/compress.c
index f82498c35e78..f2b5e746f49b 100644
--- a/fs/ntfs/compress.c
+++ b/fs/ntfs/compress.c
@@ -104,16 +104,12 @@ static void zero_partial_compressed_page(struct page *page,
 	unsigned int kp_ofs;
 
 	ntfs_debug("Zeroing page region outside initialized size.");
-	if (((s64)page->index << PAGE_CACHE_SHIFT) >= initialized_size) {
-		/*
-		 * FIXME: Using clear_page() will become wrong when we get
-		 * PAGE_CACHE_SIZE != PAGE_SIZE but for now there is no problem.
-		 */
+	if (((s64)page->index << PAGE_SHIFT) >= initialized_size) {
 		clear_page(kp);
 		return;
 	}
-	kp_ofs = initialized_size & ~PAGE_CACHE_MASK;
-	memset(kp + kp_ofs, 0, PAGE_CACHE_SIZE - kp_ofs);
+	kp_ofs = initialized_size & ~PAGE_MASK;
+	memset(kp + kp_ofs, 0, PAGE_SIZE - kp_ofs);
 	return;
 }
 
@@ -123,7 +119,7 @@ static void zero_partial_compressed_page(struct page *page,
 static inline void handle_bounds_compressed_page(struct page *page,
 		const loff_t i_size, const s64 initialized_size)
 {
-	if ((page->index >= (initialized_size >> PAGE_CACHE_SHIFT)) &&
+	if ((page->index >= (initialized_size >> PAGE_SHIFT)) &&
 			(initialized_size < i_size))
 		zero_partial_compressed_page(page, initialized_size);
 	return;
@@ -160,7 +156,7 @@ static inline void handle_bounds_compressed_page(struct page *page,
  * @xpage_done indicates whether the target page (@dest_pages[@xpage]) was
  * completed during the decompression of the compression block (@cb_start).
  *
- * Warning: This function *REQUIRES* PAGE_CACHE_SIZE >= 4096 or it will blow up
+ * Warning: This function *REQUIRES* PAGE_SIZE >= 4096 or it will blow up
  * unpredicatbly! You have been warned!
  *
  * Note to hackers: This function may not sleep until it has finished accessing
@@ -241,7 +237,7 @@ return_error:
 				if (di == xpage)
 					*xpage_done = 1;
 				else
-					page_cache_release(dp);
+					put_page(dp);
 				dest_pages[di] = NULL;
 			}
 		}
@@ -274,7 +270,7 @@ return_error:
 		cb = cb_sb_end;
 
 		/* Advance destination position to next sub-block. */
-		*dest_ofs = (*dest_ofs + NTFS_SB_SIZE) & ~PAGE_CACHE_MASK;
+		*dest_ofs = (*dest_ofs + NTFS_SB_SIZE) & ~PAGE_MASK;
 		if (!*dest_ofs && (++*dest_index > dest_max_index))
 			goto return_overflow;
 		goto do_next_sb;
@@ -301,7 +297,7 @@ return_error:
 
 		/* Advance destination position to next sub-block. */
 		*dest_ofs += NTFS_SB_SIZE;
-		if (!(*dest_ofs &= ~PAGE_CACHE_MASK)) {
+		if (!(*dest_ofs &= ~PAGE_MASK)) {
 finalize_page:
 			/*
 			 * First stage: add current page index to array of
@@ -335,7 +331,7 @@ do_next_tag:
 			*dest_ofs += nr_bytes;
 		}
 		/* We have finished the current sub-block. */
-		if (!(*dest_ofs &= ~PAGE_CACHE_MASK))
+		if (!(*dest_ofs &= ~PAGE_MASK))
 			goto finalize_page;
 		goto do_next_sb;
 	}
@@ -462,7 +458,7 @@ return_overflow:
  * have been written to so that we would lose data if we were to just overwrite
  * them with the out-of-date uncompressed data.
  *
- * FIXME: For PAGE_CACHE_SIZE > cb_size we are not doing the Right Thing(TM) at
+ * FIXME: For PAGE_SIZE > cb_size we are not doing the Right Thing(TM) at
  * the end of the file I think. We need to detect this case and zero the out
  * of bounds remainder of the page in question and mark it as handled. At the
  * moment we would just return -EIO on such a page. This bug will only become
@@ -470,7 +466,7 @@ return_overflow:
  * clusters so is probably not going to be seen by anyone. Still this should
  * be fixed. (AIA)
  *
- * FIXME: Again for PAGE_CACHE_SIZE > cb_size we are screwing up both in
+ * FIXME: Again for PAGE_SIZE > cb_size we are screwing up both in
  * handling sparse and compressed cbs. (AIA)
  *
  * FIXME: At the moment we don't do any zeroing out in the case that
@@ -497,14 +493,14 @@ int ntfs_read_compressed_block(struct page *page)
 	u64 cb_size_mask = cb_size - 1UL;
 	VCN vcn;
 	LCN lcn;
-	/* The first wanted vcn (minimum alignment is PAGE_CACHE_SIZE). */
-	VCN start_vcn = (((s64)index << PAGE_CACHE_SHIFT) & ~cb_size_mask) >>
+	/* The first wanted vcn (minimum alignment is PAGE_SIZE). */
+	VCN start_vcn = (((s64)index << PAGE_SHIFT) & ~cb_size_mask) >>
 			vol->cluster_size_bits;
 	/*
 	 * The first vcn after the last wanted vcn (minimum alignment is again
-	 * PAGE_CACHE_SIZE.
+	 * PAGE_SIZE.
 	 */
-	VCN end_vcn = ((((s64)(index + 1UL) << PAGE_CACHE_SHIFT) + cb_size - 1)
+	VCN end_vcn = ((((s64)(index + 1UL) << PAGE_SHIFT) + cb_size - 1)
 			& ~cb_size_mask) >> vol->cluster_size_bits;
 	/* Number of compression blocks (cbs) in the wanted vcn range. */
 	unsigned int nr_cbs = (end_vcn - start_vcn) << vol->cluster_size_bits
@@ -515,7 +511,7 @@ int ntfs_read_compressed_block(struct page *page)
 	 * guarantees of start_vcn and end_vcn, no need to round up here.
 	 */
 	unsigned int nr_pages = (end_vcn - start_vcn) <<
-			vol->cluster_size_bits >> PAGE_CACHE_SHIFT;
+			vol->cluster_size_bits >> PAGE_SHIFT;
 	unsigned int xpage, max_page, cur_page, cur_ofs, i;
 	unsigned int cb_clusters, cb_max_ofs;
 	int block, max_block, cb_max_page, bhs_size, nr_bhs, err = 0;
@@ -549,7 +545,7 @@ int ntfs_read_compressed_block(struct page *page)
 	 * We have already been given one page, this is the one we must do.
 	 * Once again, the alignment guarantees keep it simple.
 	 */
-	offset = start_vcn << vol->cluster_size_bits >> PAGE_CACHE_SHIFT;
+	offset = start_vcn << vol->cluster_size_bits >> PAGE_SHIFT;
 	xpage = index - offset;
 	pages[xpage] = page;
 	/*
@@ -560,13 +556,13 @@ int ntfs_read_compressed_block(struct page *page)
 	i_size = i_size_read(VFS_I(ni));
 	initialized_size = ni->initialized_size;
 	read_unlock_irqrestore(&ni->size_lock, flags);
-	max_page = ((i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT) -
+	max_page = ((i_size + PAGE_SIZE - 1) >> PAGE_SHIFT) -
 			offset;
 	/* Is the page fully outside i_size? (truncate in progress) */
 	if (xpage >= max_page) {
 		kfree(bhs);
 		kfree(pages);
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+		zero_user(page, 0, PAGE_SIZE);
 		ntfs_debug("Compressed read outside i_size - truncated?");
 		SetPageUptodate(page);
 		unlock_page(page);
@@ -591,7 +587,7 @@ int ntfs_read_compressed_block(struct page *page)
 				continue;
 			}
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			pages[i] = NULL;
 		}
 	}
@@ -735,9 +731,9 @@ lock_retry_remap:
 	ntfs_debug("Successfully read the compression block.");
 
 	/* The last page and maximum offset within it for the current cb. */
-	cb_max_page = (cur_page << PAGE_CACHE_SHIFT) + cur_ofs + cb_size;
-	cb_max_ofs = cb_max_page & ~PAGE_CACHE_MASK;
-	cb_max_page >>= PAGE_CACHE_SHIFT;
+	cb_max_page = (cur_page << PAGE_SHIFT) + cur_ofs + cb_size;
+	cb_max_ofs = cb_max_page & ~PAGE_MASK;
+	cb_max_page >>= PAGE_SHIFT;
 
 	/* Catch end of file inside a compression block. */
 	if (cb_max_page > max_page)
@@ -753,16 +749,11 @@ lock_retry_remap:
 		for (; cur_page < cb_max_page; cur_page++) {
 			page = pages[cur_page];
 			if (page) {
-				/*
-				 * FIXME: Using clear_page() will become wrong
-				 * when we get PAGE_CACHE_SIZE != PAGE_SIZE but
-				 * for now there is no problem.
-				 */
 				if (likely(!cur_ofs))
 					clear_page(page_address(page));
 				else
 					memset(page_address(page) + cur_ofs, 0,
-							PAGE_CACHE_SIZE -
+							PAGE_SIZE -
 							cur_ofs);
 				flush_dcache_page(page);
 				kunmap(page);
@@ -771,10 +762,10 @@ lock_retry_remap:
 				if (cur_page == xpage)
 					xpage_done = 1;
 				else
-					page_cache_release(page);
+					put_page(page);
 				pages[cur_page] = NULL;
 			}
-			cb_pos += PAGE_CACHE_SIZE - cur_ofs;
+			cb_pos += PAGE_SIZE - cur_ofs;
 			cur_ofs = 0;
 			if (cb_pos >= cb_end)
 				break;
@@ -807,7 +798,7 @@ lock_retry_remap:
 		 * synchronous io for the majority of pages.
 		 * Or if we choose not to do the read-ahead/-behind stuff, we
 		 * could just return block_read_full_page(pages[xpage]) as long
-		 * as PAGE_CACHE_SIZE <= cb_size.
+		 * as PAGE_SIZE <= cb_size.
 		 */
 		if (cb_max_ofs)
 			cb_max_page--;
@@ -816,8 +807,8 @@ lock_retry_remap:
 			page = pages[cur_page];
 			if (page)
 				memcpy(page_address(page) + cur_ofs, cb_pos,
-						PAGE_CACHE_SIZE - cur_ofs);
-			cb_pos += PAGE_CACHE_SIZE - cur_ofs;
+						PAGE_SIZE - cur_ofs);
+			cb_pos += PAGE_SIZE - cur_ofs;
 			cur_ofs = 0;
 			if (cb_pos >= cb_end)
 				break;
@@ -850,10 +841,10 @@ lock_retry_remap:
 				if (cur2_page == xpage)
 					xpage_done = 1;
 				else
-					page_cache_release(page);
+					put_page(page);
 				pages[cur2_page] = NULL;
 			}
-			cb_pos2 += PAGE_CACHE_SIZE - cur_ofs2;
+			cb_pos2 += PAGE_SIZE - cur_ofs2;
 			cur_ofs2 = 0;
 			if (cb_pos2 >= cb_end)
 				break;
@@ -884,7 +875,7 @@ lock_retry_remap:
 					kunmap(page);
 					unlock_page(page);
 					if (prev_cur_page != xpage)
-						page_cache_release(page);
+						put_page(page);
 					pages[prev_cur_page] = NULL;
 				}
 			}
@@ -914,7 +905,7 @@ lock_retry_remap:
 			kunmap(page);
 			unlock_page(page);
 			if (cur_page != xpage)
-				page_cache_release(page);
+				put_page(page);
 			pages[cur_page] = NULL;
 		}
 	}
@@ -961,7 +952,7 @@ err_out:
 			kunmap(page);
 			unlock_page(page);
 			if (i != xpage)
-				page_cache_release(page);
+				put_page(page);
 		}
 	}
 	kfree(pages);
diff --git a/fs/ntfs/dir.c b/fs/ntfs/dir.c
index b2eff5816adc..a18613579001 100644
--- a/fs/ntfs/dir.c
+++ b/fs/ntfs/dir.c
@@ -315,11 +315,11 @@ found_it:
 descend_into_child_node:
 	/*
 	 * Convert vcn to index into the index allocation attribute in units
-	 * of PAGE_CACHE_SIZE and map the page cache page, reading it from
+	 * of PAGE_SIZE and map the page cache page, reading it from
 	 * disk if necessary.
 	 */
 	page = ntfs_map_page(ia_mapping, vcn <<
-			dir_ni->itype.index.vcn_size_bits >> PAGE_CACHE_SHIFT);
+			dir_ni->itype.index.vcn_size_bits >> PAGE_SHIFT);
 	if (IS_ERR(page)) {
 		ntfs_error(sb, "Failed to map directory index page, error %ld.",
 				-PTR_ERR(page));
@@ -331,9 +331,9 @@ descend_into_child_node:
 fast_descend_into_child_node:
 	/* Get to the index allocation block. */
 	ia = (INDEX_ALLOCATION*)(kaddr + ((vcn <<
-			dir_ni->itype.index.vcn_size_bits) & ~PAGE_CACHE_MASK));
+			dir_ni->itype.index.vcn_size_bits) & ~PAGE_MASK));
 	/* Bounds checks. */
-	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_CACHE_SIZE) {
+	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Out of bounds check failed. Corrupt directory "
 				"inode 0x%lx or driver bug.", dir_ni->mft_no);
 		goto unm_err_out;
@@ -366,7 +366,7 @@ fast_descend_into_child_node:
 		goto unm_err_out;
 	}
 	index_end = (u8*)ia + dir_ni->itype.index.block_size;
-	if (index_end > kaddr + PAGE_CACHE_SIZE) {
+	if (index_end > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Index buffer (VCN 0x%llx) of directory inode "
 				"0x%lx crosses page boundary. Impossible! "
 				"Cannot access! This is probably a bug in the "
@@ -559,9 +559,9 @@ found_it2:
 			/* If vcn is in the same page cache page as old_vcn we
 			 * recycle the mapped page. */
 			if (old_vcn << vol->cluster_size_bits >>
-					PAGE_CACHE_SHIFT == vcn <<
+					PAGE_SHIFT == vcn <<
 					vol->cluster_size_bits >>
-					PAGE_CACHE_SHIFT)
+					PAGE_SHIFT)
 				goto fast_descend_into_child_node;
 			unlock_page(page);
 			ntfs_unmap_page(page);
@@ -793,11 +793,11 @@ found_it:
 descend_into_child_node:
 	/*
 	 * Convert vcn to index into the index allocation attribute in units
-	 * of PAGE_CACHE_SIZE and map the page cache page, reading it from
+	 * of PAGE_SIZE and map the page cache page, reading it from
 	 * disk if necessary.
 	 */
 	page = ntfs_map_page(ia_mapping, vcn <<
-			dir_ni->itype.index.vcn_size_bits >> PAGE_CACHE_SHIFT);
+			dir_ni->itype.index.vcn_size_bits >> PAGE_SHIFT);
 	if (IS_ERR(page)) {
 		ntfs_error(sb, "Failed to map directory index page, error %ld.",
 				-PTR_ERR(page));
@@ -809,9 +809,9 @@ descend_into_child_node:
 fast_descend_into_child_node:
 	/* Get to the index allocation block. */
 	ia = (INDEX_ALLOCATION*)(kaddr + ((vcn <<
-			dir_ni->itype.index.vcn_size_bits) & ~PAGE_CACHE_MASK));
+			dir_ni->itype.index.vcn_size_bits) & ~PAGE_MASK));
 	/* Bounds checks. */
-	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_CACHE_SIZE) {
+	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Out of bounds check failed. Corrupt directory "
 				"inode 0x%lx or driver bug.", dir_ni->mft_no);
 		goto unm_err_out;
@@ -844,7 +844,7 @@ fast_descend_into_child_node:
 		goto unm_err_out;
 	}
 	index_end = (u8*)ia + dir_ni->itype.index.block_size;
-	if (index_end > kaddr + PAGE_CACHE_SIZE) {
+	if (index_end > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Index buffer (VCN 0x%llx) of directory inode "
 				"0x%lx crosses page boundary. Impossible! "
 				"Cannot access! This is probably a bug in the "
@@ -968,9 +968,9 @@ found_it2:
 			/* If vcn is in the same page cache page as old_vcn we
 			 * recycle the mapped page. */
 			if (old_vcn << vol->cluster_size_bits >>
-					PAGE_CACHE_SHIFT == vcn <<
+					PAGE_SHIFT == vcn <<
 					vol->cluster_size_bits >>
-					PAGE_CACHE_SHIFT)
+					PAGE_SHIFT)
 				goto fast_descend_into_child_node;
 			unlock_page(page);
 			ntfs_unmap_page(page);
@@ -1246,15 +1246,15 @@ skip_index_root:
 		goto iput_err_out;
 	}
 	/* Get the starting bit position in the current bitmap page. */
-	cur_bmp_pos = bmp_pos & ((PAGE_CACHE_SIZE * 8) - 1);
-	bmp_pos &= ~(u64)((PAGE_CACHE_SIZE * 8) - 1);
+	cur_bmp_pos = bmp_pos & ((PAGE_SIZE * 8) - 1);
+	bmp_pos &= ~(u64)((PAGE_SIZE * 8) - 1);
 get_next_bmp_page:
 	ntfs_debug("Reading bitmap with page index 0x%llx, bit ofs 0x%llx",
-			(unsigned long long)bmp_pos >> (3 + PAGE_CACHE_SHIFT),
+			(unsigned long long)bmp_pos >> (3 + PAGE_SHIFT),
 			(unsigned long long)bmp_pos &
-			(unsigned long long)((PAGE_CACHE_SIZE * 8) - 1));
+			(unsigned long long)((PAGE_SIZE * 8) - 1));
 	bmp_page = ntfs_map_page(bmp_mapping,
-			bmp_pos >> (3 + PAGE_CACHE_SHIFT));
+			bmp_pos >> (3 + PAGE_SHIFT));
 	if (IS_ERR(bmp_page)) {
 		ntfs_error(sb, "Reading index bitmap failed.");
 		err = PTR_ERR(bmp_page);
@@ -1270,9 +1270,9 @@ find_next_index_buffer:
 		 * If we have reached the end of the bitmap page, get the next
 		 * page, and put away the old one.
 		 */
-		if (unlikely((cur_bmp_pos >> 3) >= PAGE_CACHE_SIZE)) {
+		if (unlikely((cur_bmp_pos >> 3) >= PAGE_SIZE)) {
 			ntfs_unmap_page(bmp_page);
-			bmp_pos += PAGE_CACHE_SIZE * 8;
+			bmp_pos += PAGE_SIZE * 8;
 			cur_bmp_pos = 0;
 			goto get_next_bmp_page;
 		}
@@ -1285,8 +1285,8 @@ find_next_index_buffer:
 	ntfs_debug("Handling index buffer 0x%llx.",
 			(unsigned long long)bmp_pos + cur_bmp_pos);
 	/* If the current index buffer is in the same page we reuse the page. */
-	if ((prev_ia_pos & (s64)PAGE_CACHE_MASK) !=
-			(ia_pos & (s64)PAGE_CACHE_MASK)) {
+	if ((prev_ia_pos & (s64)PAGE_MASK) !=
+			(ia_pos & (s64)PAGE_MASK)) {
 		prev_ia_pos = ia_pos;
 		if (likely(ia_page != NULL)) {
 			unlock_page(ia_page);
@@ -1296,7 +1296,7 @@ find_next_index_buffer:
 		 * Map the page cache page containing the current ia_pos,
 		 * reading it from disk if necessary.
 		 */
-		ia_page = ntfs_map_page(ia_mapping, ia_pos >> PAGE_CACHE_SHIFT);
+		ia_page = ntfs_map_page(ia_mapping, ia_pos >> PAGE_SHIFT);
 		if (IS_ERR(ia_page)) {
 			ntfs_error(sb, "Reading index allocation data failed.");
 			err = PTR_ERR(ia_page);
@@ -1307,10 +1307,10 @@ find_next_index_buffer:
 		kaddr = (u8*)page_address(ia_page);
 	}
 	/* Get the current index buffer. */
-	ia = (INDEX_ALLOCATION*)(kaddr + (ia_pos & ~PAGE_CACHE_MASK &
-			~(s64)(ndir->itype.index.block_size - 1)));
+	ia = (INDEX_ALLOCATION*)(kaddr + (ia_pos & ~PAGE_MASK &
+					  ~(s64)(ndir->itype.index.block_size - 1)));
 	/* Bounds checks. */
-	if (unlikely((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_CACHE_SIZE)) {
+	if (unlikely((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_SIZE)) {
 		ntfs_error(sb, "Out of bounds check failed. Corrupt directory "
 				"inode 0x%lx or driver bug.", vdir->i_ino);
 		goto err_out;
@@ -1348,7 +1348,7 @@ find_next_index_buffer:
 		goto err_out;
 	}
 	index_end = (u8*)ia + ndir->itype.index.block_size;
-	if (unlikely(index_end > kaddr + PAGE_CACHE_SIZE)) {
+	if (unlikely(index_end > kaddr + PAGE_SIZE)) {
 		ntfs_error(sb, "Index buffer (VCN 0x%llx) of directory inode "
 				"0x%lx crosses page boundary. Impossible! "
 				"Cannot access! This is probably a bug in the "
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index bed4d427dfae..91117ada8528 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -220,8 +220,8 @@ do_non_resident_extend:
 		m = NULL;
 	}
 	mapping = vi->i_mapping;
-	index = old_init_size >> PAGE_CACHE_SHIFT;
-	end_index = (new_init_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	index = old_init_size >> PAGE_SHIFT;
+	end_index = (new_init_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	do {
 		/*
 		 * Read the page.  If the page is not present, this will zero
@@ -233,7 +233,7 @@ do_non_resident_extend:
 			goto init_err_out;
 		}
 		if (unlikely(PageError(page))) {
-			page_cache_release(page);
+			put_page(page);
 			err = -EIO;
 			goto init_err_out;
 		}
@@ -242,13 +242,13 @@ do_non_resident_extend:
 		 * enough to make ntfs_writepage() work.
 		 */
 		write_lock_irqsave(&ni->size_lock, flags);
-		ni->initialized_size = (s64)(index + 1) << PAGE_CACHE_SHIFT;
+		ni->initialized_size = (s64)(index + 1) << PAGE_SHIFT;
 		if (ni->initialized_size > new_init_size)
 			ni->initialized_size = new_init_size;
 		write_unlock_irqrestore(&ni->size_lock, flags);
 		/* Set the page dirty so it gets written out. */
 		set_page_dirty(page);
-		page_cache_release(page);
+		put_page(page);
 		/*
 		 * Play nice with the vm and the rest of the system.  This is
 		 * very much needed as we can potentially be modifying the
@@ -543,7 +543,7 @@ out:
 err_out:
 	while (nr > 0) {
 		unlock_page(pages[--nr]);
-		page_cache_release(pages[nr]);
+		put_page(pages[nr]);
 	}
 	goto out;
 }
@@ -573,7 +573,7 @@ static inline int ntfs_submit_bh_for_read(struct buffer_head *bh)
  * only partially being written to.
  *
  * If @nr_pages is greater than one, we are guaranteed that the cluster size is
- * greater than PAGE_CACHE_SIZE, that all pages in @pages are entirely inside
+ * greater than PAGE_SIZE, that all pages in @pages are entirely inside
  * the same cluster and that they are the entirety of that cluster, and that
  * the cluster is sparse, i.e. we need to allocate a cluster to fill the hole.
  *
@@ -653,7 +653,7 @@ static int ntfs_prepare_pages_for_non_resident_write(struct page **pages,
 	u = 0;
 do_next_page:
 	page = pages[u];
-	bh_pos = (s64)page->index << PAGE_CACHE_SHIFT;
+	bh_pos = (s64)page->index << PAGE_SHIFT;
 	bh = head = page_buffers(page);
 	do {
 		VCN cdelta;
@@ -810,11 +810,11 @@ map_buffer_cached:
 					
 				kaddr = kmap_atomic(page);
 				if (bh_pos < pos) {
-					pofs = bh_pos & ~PAGE_CACHE_MASK;
+					pofs = bh_pos & ~PAGE_MASK;
 					memset(kaddr + pofs, 0, pos - bh_pos);
 				}
 				if (bh_end > end) {
-					pofs = end & ~PAGE_CACHE_MASK;
+					pofs = end & ~PAGE_MASK;
 					memset(kaddr + pofs, 0, bh_end - end);
 				}
 				kunmap_atomic(kaddr);
@@ -942,7 +942,7 @@ rl_not_mapped_enoent:
 		 * unmapped.  This can only happen when the cluster size is
 		 * less than the page cache size.
 		 */
-		if (unlikely(vol->cluster_size < PAGE_CACHE_SIZE)) {
+		if (unlikely(vol->cluster_size < PAGE_SIZE)) {
 			bh_cend = (bh_end + vol->cluster_size - 1) >>
 					vol->cluster_size_bits;
 			if ((bh_cend <= cpos || bh_cpos >= cend)) {
@@ -1208,7 +1208,7 @@ rl_not_mapped_enoent:
 		wait_on_buffer(bh);
 		if (likely(buffer_uptodate(bh))) {
 			page = bh->b_page;
-			bh_pos = ((s64)page->index << PAGE_CACHE_SHIFT) +
+			bh_pos = ((s64)page->index << PAGE_SHIFT) +
 					bh_offset(bh);
 			/*
 			 * If the buffer overflows the initialized size, need
@@ -1350,7 +1350,7 @@ rl_not_mapped_enoent:
 		bh = head = page_buffers(page);
 		do {
 			if (u == nr_pages &&
-					((s64)page->index << PAGE_CACHE_SHIFT) +
+					((s64)page->index << PAGE_SHIFT) +
 					bh_offset(bh) >= end)
 				break;
 			if (!buffer_new(bh))
@@ -1422,7 +1422,7 @@ static inline int ntfs_commit_pages_after_non_resident_write(
 		bool partial;
 
 		page = pages[u];
-		bh_pos = (s64)page->index << PAGE_CACHE_SHIFT;
+		bh_pos = (s64)page->index << PAGE_SHIFT;
 		bh = head = page_buffers(page);
 		partial = false;
 		do {
@@ -1639,7 +1639,7 @@ static int ntfs_commit_pages_after_write(struct page **pages,
 		if (end < attr_len)
 			memcpy(kaddr + end, kattr + end, attr_len - end);
 		/* Zero the region outside the end of the attribute value. */
-		memset(kaddr + attr_len, 0, PAGE_CACHE_SIZE - attr_len);
+		memset(kaddr + attr_len, 0, PAGE_SIZE - attr_len);
 		flush_dcache_page(page);
 		SetPageUptodate(page);
 	}
@@ -1706,7 +1706,7 @@ static size_t ntfs_copy_from_user_iter(struct page **pages, unsigned nr_pages,
 	unsigned len, copied;
 
 	do {
-		len = PAGE_CACHE_SIZE - ofs;
+		len = PAGE_SIZE - ofs;
 		if (len > bytes)
 			len = bytes;
 		copied = iov_iter_copy_from_user_atomic(*pages, &data, ofs,
@@ -1724,14 +1724,14 @@ out:
 	return total;
 err:
 	/* Zero the rest of the target like __copy_from_user(). */
-	len = PAGE_CACHE_SIZE - copied;
+	len = PAGE_SIZE - copied;
 	do {
 		if (len > bytes)
 			len = bytes;
 		zero_user(*pages, copied, len);
 		bytes -= len;
 		copied = 0;
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 	} while (++pages < last_page);
 	goto out;
 }
@@ -1787,8 +1787,8 @@ static ssize_t ntfs_perform_write(struct file *file, struct iov_iter *i,
 	 * attributes.
 	 */
 	nr_pages = 1;
-	if (vol->cluster_size > PAGE_CACHE_SIZE && NInoNonResident(ni))
-		nr_pages = vol->cluster_size >> PAGE_CACHE_SHIFT;
+	if (vol->cluster_size > PAGE_SIZE && NInoNonResident(ni))
+		nr_pages = vol->cluster_size >> PAGE_SHIFT;
 	last_vcn = -1;
 	do {
 		VCN vcn;
@@ -1796,9 +1796,9 @@ static ssize_t ntfs_perform_write(struct file *file, struct iov_iter *i,
 		unsigned ofs, do_pages, u;
 		size_t copied;
 
-		start_idx = idx = pos >> PAGE_CACHE_SHIFT;
-		ofs = pos & ~PAGE_CACHE_MASK;
-		bytes = PAGE_CACHE_SIZE - ofs;
+		start_idx = idx = pos >> PAGE_SHIFT;
+		ofs = pos & ~PAGE_MASK;
+		bytes = PAGE_SIZE - ofs;
 		do_pages = 1;
 		if (nr_pages > 1) {
 			vcn = pos >> vol->cluster_size_bits;
@@ -1832,7 +1832,7 @@ static ssize_t ntfs_perform_write(struct file *file, struct iov_iter *i,
 				if (lcn == LCN_HOLE) {
 					start_idx = (pos & ~(s64)
 							vol->cluster_size_mask)
-							>> PAGE_CACHE_SHIFT;
+							>> PAGE_SHIFT;
 					bytes = vol->cluster_size - (pos &
 							vol->cluster_size_mask);
 					do_pages = nr_pages;
@@ -1871,12 +1871,12 @@ again:
 			if (unlikely(status)) {
 				do {
 					unlock_page(pages[--do_pages]);
-					page_cache_release(pages[do_pages]);
+					put_page(pages[do_pages]);
 				} while (do_pages);
 				break;
 			}
 		}
-		u = (pos >> PAGE_CACHE_SHIFT) - pages[0]->index;
+		u = (pos >> PAGE_SHIFT) - pages[0]->index;
 		copied = ntfs_copy_from_user_iter(pages + u, do_pages - u, ofs,
 					i, bytes);
 		ntfs_flush_dcache_pages(pages + u, do_pages - u);
@@ -1889,7 +1889,7 @@ again:
 		}
 		do {
 			unlock_page(pages[--do_pages]);
-			page_cache_release(pages[do_pages]);
+			put_page(pages[do_pages]);
 		} while (do_pages);
 		if (unlikely(status < 0))
 			break;
@@ -1921,7 +1921,7 @@ again:
 		}
 	} while (iov_iter_count(i));
 	if (cached_page)
-		page_cache_release(cached_page);
+		put_page(cached_page);
 	ntfs_debug("Done.  Returning %s (written 0x%lx, status %li).",
 			written ? "written" : "status", (unsigned long)written,
 			(long)status);
diff --git a/fs/ntfs/index.c b/fs/ntfs/index.c
index 096c135691ae..0d645f357930 100644
--- a/fs/ntfs/index.c
+++ b/fs/ntfs/index.c
@@ -272,11 +272,11 @@ done:
 descend_into_child_node:
 	/*
 	 * Convert vcn to index into the index allocation attribute in units
-	 * of PAGE_CACHE_SIZE and map the page cache page, reading it from
+	 * of PAGE_SIZE and map the page cache page, reading it from
 	 * disk if necessary.
 	 */
 	page = ntfs_map_page(ia_mapping, vcn <<
-			idx_ni->itype.index.vcn_size_bits >> PAGE_CACHE_SHIFT);
+			idx_ni->itype.index.vcn_size_bits >> PAGE_SHIFT);
 	if (IS_ERR(page)) {
 		ntfs_error(sb, "Failed to map index page, error %ld.",
 				-PTR_ERR(page));
@@ -288,9 +288,9 @@ descend_into_child_node:
 fast_descend_into_child_node:
 	/* Get to the index allocation block. */
 	ia = (INDEX_ALLOCATION*)(kaddr + ((vcn <<
-			idx_ni->itype.index.vcn_size_bits) & ~PAGE_CACHE_MASK));
+			idx_ni->itype.index.vcn_size_bits) & ~PAGE_MASK));
 	/* Bounds checks. */
-	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_CACHE_SIZE) {
+	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Out of bounds check failed.  Corrupt inode "
 				"0x%lx or driver bug.", idx_ni->mft_no);
 		goto unm_err_out;
@@ -323,7 +323,7 @@ fast_descend_into_child_node:
 		goto unm_err_out;
 	}
 	index_end = (u8*)ia + idx_ni->itype.index.block_size;
-	if (index_end > kaddr + PAGE_CACHE_SIZE) {
+	if (index_end > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Index buffer (VCN 0x%llx) of inode 0x%lx "
 				"crosses page boundary.  Impossible!  Cannot "
 				"access!  This is probably a bug in the "
@@ -427,9 +427,9 @@ ia_done:
 		 * the mapped page.
 		 */
 		if (old_vcn << vol->cluster_size_bits >>
-				PAGE_CACHE_SHIFT == vcn <<
+				PAGE_SHIFT == vcn <<
 				vol->cluster_size_bits >>
-				PAGE_CACHE_SHIFT)
+				PAGE_SHIFT)
 			goto fast_descend_into_child_node;
 		unlock_page(page);
 		ntfs_unmap_page(page);
diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
index d284f07eda77..f40972d6df90 100644
--- a/fs/ntfs/inode.c
+++ b/fs/ntfs/inode.c
@@ -868,12 +868,12 @@ skip_attr_list_load:
 					ni->itype.index.block_size);
 			goto unm_err_out;
 		}
-		if (ni->itype.index.block_size > PAGE_CACHE_SIZE) {
+		if (ni->itype.index.block_size > PAGE_SIZE) {
 			ntfs_error(vi->i_sb, "Index block size (%u) > "
-					"PAGE_CACHE_SIZE (%ld) is not "
+					"PAGE_SIZE (%ld) is not "
 					"supported.  Sorry.",
 					ni->itype.index.block_size,
-					PAGE_CACHE_SIZE);
+					PAGE_SIZE);
 			err = -EOPNOTSUPP;
 			goto unm_err_out;
 		}
@@ -1585,10 +1585,10 @@ static int ntfs_read_locked_index_inode(struct inode *base_vi, struct inode *vi)
 				"two.", ni->itype.index.block_size);
 		goto unm_err_out;
 	}
-	if (ni->itype.index.block_size > PAGE_CACHE_SIZE) {
-		ntfs_error(vi->i_sb, "Index block size (%u) > PAGE_CACHE_SIZE "
+	if (ni->itype.index.block_size > PAGE_SIZE) {
+		ntfs_error(vi->i_sb, "Index block size (%u) > PAGE_SIZE "
 				"(%ld) is not supported.  Sorry.",
-				ni->itype.index.block_size, PAGE_CACHE_SIZE);
+				ni->itype.index.block_size, PAGE_SIZE);
 		err = -EOPNOTSUPP;
 		goto unm_err_out;
 	}
diff --git a/fs/ntfs/lcnalloc.c b/fs/ntfs/lcnalloc.c
index 1711b710b641..27a24a42f712 100644
--- a/fs/ntfs/lcnalloc.c
+++ b/fs/ntfs/lcnalloc.c
@@ -283,15 +283,15 @@ runlist_element *ntfs_cluster_alloc(ntfs_volume *vol, const VCN start_vcn,
 			ntfs_unmap_page(page);
 		}
 		page = ntfs_map_page(mapping, last_read_pos >>
-				PAGE_CACHE_SHIFT);
+				PAGE_SHIFT);
 		if (IS_ERR(page)) {
 			err = PTR_ERR(page);
 			ntfs_error(vol->sb, "Failed to map page.");
 			goto out;
 		}
-		buf_size = last_read_pos & ~PAGE_CACHE_MASK;
+		buf_size = last_read_pos & ~PAGE_MASK;
 		buf = page_address(page) + buf_size;
-		buf_size = PAGE_CACHE_SIZE - buf_size;
+		buf_size = PAGE_SIZE - buf_size;
 		if (unlikely(last_read_pos + buf_size > i_size))
 			buf_size = i_size - last_read_pos;
 		buf_size <<= 3;
diff --git a/fs/ntfs/logfile.c b/fs/ntfs/logfile.c
index c71de292c5ad..9d71213ca81e 100644
--- a/fs/ntfs/logfile.c
+++ b/fs/ntfs/logfile.c
@@ -381,7 +381,7 @@ static int ntfs_check_and_load_restart_page(struct inode *vi,
 	 * completely inside @rp, just copy it from there.  Otherwise map all
 	 * the required pages and copy the data from them.
 	 */
-	size = PAGE_CACHE_SIZE - (pos & ~PAGE_CACHE_MASK);
+	size = PAGE_SIZE - (pos & ~PAGE_MASK);
 	if (size >= le32_to_cpu(rp->system_page_size)) {
 		memcpy(trp, rp, le32_to_cpu(rp->system_page_size));
 	} else {
@@ -394,8 +394,8 @@ static int ntfs_check_and_load_restart_page(struct inode *vi,
 		/* Copy the remaining data one page at a time. */
 		have_read = size;
 		to_read = le32_to_cpu(rp->system_page_size) - size;
-		idx = (pos + size) >> PAGE_CACHE_SHIFT;
-		BUG_ON((pos + size) & ~PAGE_CACHE_MASK);
+		idx = (pos + size) >> PAGE_SHIFT;
+		BUG_ON((pos + size) & ~PAGE_MASK);
 		do {
 			page = ntfs_map_page(vi->i_mapping, idx);
 			if (IS_ERR(page)) {
@@ -406,7 +406,7 @@ static int ntfs_check_and_load_restart_page(struct inode *vi,
 					err = -EIO;
 				goto err_out;
 			}
-			size = min_t(int, to_read, PAGE_CACHE_SIZE);
+			size = min_t(int, to_read, PAGE_SIZE);
 			memcpy((u8*)trp + have_read, page_address(page), size);
 			ntfs_unmap_page(page);
 			have_read += size;
@@ -509,11 +509,11 @@ bool ntfs_check_logfile(struct inode *log_vi, RESTART_PAGE_HEADER **rp)
 	 * log page size if the page cache size is between the default log page
 	 * size and twice that.
 	 */
-	if (PAGE_CACHE_SIZE >= DefaultLogPageSize && PAGE_CACHE_SIZE <=
+	if (PAGE_SIZE >= DefaultLogPageSize && PAGE_SIZE <=
 			DefaultLogPageSize * 2)
 		log_page_size = DefaultLogPageSize;
 	else
-		log_page_size = PAGE_CACHE_SIZE;
+		log_page_size = PAGE_SIZE;
 	log_page_mask = log_page_size - 1;
 	/*
 	 * Use ntfs_ffs() instead of ffs() to enable the compiler to
@@ -539,7 +539,7 @@ bool ntfs_check_logfile(struct inode *log_vi, RESTART_PAGE_HEADER **rp)
 	 * to be empty.
 	 */
 	for (pos = 0; pos < size; pos <<= 1) {
-		pgoff_t idx = pos >> PAGE_CACHE_SHIFT;
+		pgoff_t idx = pos >> PAGE_SHIFT;
 		if (!page || page->index != idx) {
 			if (page)
 				ntfs_unmap_page(page);
@@ -550,7 +550,7 @@ bool ntfs_check_logfile(struct inode *log_vi, RESTART_PAGE_HEADER **rp)
 				goto err_out;
 			}
 		}
-		kaddr = (u8*)page_address(page) + (pos & ~PAGE_CACHE_MASK);
+		kaddr = (u8*)page_address(page) + (pos & ~PAGE_MASK);
 		/*
 		 * A non-empty block means the logfile is not empty while an
 		 * empty block after a non-empty block has been encountered
diff --git a/fs/ntfs/mft.c b/fs/ntfs/mft.c
index 3014a36a255b..37b2501caaa4 100644
--- a/fs/ntfs/mft.c
+++ b/fs/ntfs/mft.c
@@ -61,16 +61,16 @@ static inline MFT_RECORD *map_mft_record_page(ntfs_inode *ni)
 	 * here if the volume was that big...
 	 */
 	index = (u64)ni->mft_no << vol->mft_record_size_bits >>
-			PAGE_CACHE_SHIFT;
-	ofs = (ni->mft_no << vol->mft_record_size_bits) & ~PAGE_CACHE_MASK;
+			PAGE_SHIFT;
+	ofs = (ni->mft_no << vol->mft_record_size_bits) & ~PAGE_MASK;
 
 	i_size = i_size_read(mft_vi);
 	/* The maximum valid index into the page cache for $MFT's data. */
-	end_index = i_size >> PAGE_CACHE_SHIFT;
+	end_index = i_size >> PAGE_SHIFT;
 
 	/* If the wanted index is out of bounds the mft record doesn't exist. */
 	if (unlikely(index >= end_index)) {
-		if (index > end_index || (i_size & ~PAGE_CACHE_MASK) < ofs +
+		if (index > end_index || (i_size & ~PAGE_MASK) < ofs +
 				vol->mft_record_size) {
 			page = ERR_PTR(-ENOENT);
 			ntfs_error(vol->sb, "Attempt to read mft record 0x%lx, "
@@ -487,7 +487,7 @@ int ntfs_sync_mft_mirror(ntfs_volume *vol, const unsigned long mft_no,
 	}
 	/* Get the page containing the mirror copy of the mft record @m. */
 	page = ntfs_map_page(vol->mftmirr_ino->i_mapping, mft_no >>
-			(PAGE_CACHE_SHIFT - vol->mft_record_size_bits));
+			(PAGE_SHIFT - vol->mft_record_size_bits));
 	if (IS_ERR(page)) {
 		ntfs_error(vol->sb, "Failed to map mft mirror page.");
 		err = PTR_ERR(page);
@@ -497,7 +497,7 @@ int ntfs_sync_mft_mirror(ntfs_volume *vol, const unsigned long mft_no,
 	BUG_ON(!PageUptodate(page));
 	ClearPageUptodate(page);
 	/* Offset of the mft mirror record inside the page. */
-	page_ofs = (mft_no << vol->mft_record_size_bits) & ~PAGE_CACHE_MASK;
+	page_ofs = (mft_no << vol->mft_record_size_bits) & ~PAGE_MASK;
 	/* The address in the page of the mirror copy of the mft record @m. */
 	kmirr = page_address(page) + page_ofs;
 	/* Copy the mst protected mft record to the mirror. */
@@ -1178,8 +1178,8 @@ static int ntfs_mft_bitmap_find_and_alloc_free_rec_nolock(ntfs_volume *vol,
 	for (; pass <= 2;) {
 		/* Cap size to pass_end. */
 		ofs = data_pos >> 3;
-		page_ofs = ofs & ~PAGE_CACHE_MASK;
-		size = PAGE_CACHE_SIZE - page_ofs;
+		page_ofs = ofs & ~PAGE_MASK;
+		size = PAGE_SIZE - page_ofs;
 		ll = ((pass_end + 7) >> 3) - ofs;
 		if (size > ll)
 			size = ll;
@@ -1190,7 +1190,7 @@ static int ntfs_mft_bitmap_find_and_alloc_free_rec_nolock(ntfs_volume *vol,
 		 */
 		if (size) {
 			page = ntfs_map_page(mftbmp_mapping,
-					ofs >> PAGE_CACHE_SHIFT);
+					ofs >> PAGE_SHIFT);
 			if (IS_ERR(page)) {
 				ntfs_error(vol->sb, "Failed to read mft "
 						"bitmap, aborting.");
@@ -1328,13 +1328,13 @@ static int ntfs_mft_bitmap_extend_allocation_nolock(ntfs_volume *vol)
 	 */
 	ll = lcn >> 3;
 	page = ntfs_map_page(vol->lcnbmp_ino->i_mapping,
-			ll >> PAGE_CACHE_SHIFT);
+			ll >> PAGE_SHIFT);
 	if (IS_ERR(page)) {
 		up_write(&mftbmp_ni->runlist.lock);
 		ntfs_error(vol->sb, "Failed to read from lcn bitmap.");
 		return PTR_ERR(page);
 	}
-	b = (u8*)page_address(page) + (ll & ~PAGE_CACHE_MASK);
+	b = (u8*)page_address(page) + (ll & ~PAGE_MASK);
 	tb = 1 << (lcn & 7ull);
 	down_write(&vol->lcnbmp_lock);
 	if (*b != 0xff && !(*b & tb)) {
@@ -2103,14 +2103,14 @@ static int ntfs_mft_record_format(const ntfs_volume *vol, const s64 mft_no)
 	 * The index into the page cache and the offset within the page cache
 	 * page of the wanted mft record.
 	 */
-	index = mft_no << vol->mft_record_size_bits >> PAGE_CACHE_SHIFT;
-	ofs = (mft_no << vol->mft_record_size_bits) & ~PAGE_CACHE_MASK;
+	index = mft_no << vol->mft_record_size_bits >> PAGE_SHIFT;
+	ofs = (mft_no << vol->mft_record_size_bits) & ~PAGE_MASK;
 	/* The maximum valid index into the page cache for $MFT's data. */
 	i_size = i_size_read(mft_vi);
-	end_index = i_size >> PAGE_CACHE_SHIFT;
+	end_index = i_size >> PAGE_SHIFT;
 	if (unlikely(index >= end_index)) {
 		if (unlikely(index > end_index || ofs + vol->mft_record_size >=
-				(i_size & ~PAGE_CACHE_MASK))) {
+				(i_size & ~PAGE_MASK))) {
 			ntfs_error(vol->sb, "Tried to format non-existing mft "
 					"record 0x%llx.", (long long)mft_no);
 			return -ENOENT;
@@ -2515,8 +2515,8 @@ mft_rec_already_initialized:
 	 * We now have allocated and initialized the mft record.  Calculate the
 	 * index of and the offset within the page cache page the record is in.
 	 */
-	index = bit << vol->mft_record_size_bits >> PAGE_CACHE_SHIFT;
-	ofs = (bit << vol->mft_record_size_bits) & ~PAGE_CACHE_MASK;
+	index = bit << vol->mft_record_size_bits >> PAGE_SHIFT;
+	ofs = (bit << vol->mft_record_size_bits) & ~PAGE_MASK;
 	/* Read, map, and pin the page containing the mft record. */
 	page = ntfs_map_page(vol->mft_ino->i_mapping, index);
 	if (IS_ERR(page)) {
diff --git a/fs/ntfs/ntfs.h b/fs/ntfs/ntfs.h
index c581e26a350d..12de47b96ca9 100644
--- a/fs/ntfs/ntfs.h
+++ b/fs/ntfs/ntfs.h
@@ -43,7 +43,7 @@ typedef enum {
 	NTFS_MAX_NAME_LEN	= 255,
 	NTFS_MAX_ATTR_NAME_LEN	= 255,
 	NTFS_MAX_CLUSTER_SIZE	= 64 * 1024,	/* 64kiB */
-	NTFS_MAX_PAGES_PER_CLUSTER = NTFS_MAX_CLUSTER_SIZE / PAGE_CACHE_SIZE,
+	NTFS_MAX_PAGES_PER_CLUSTER = NTFS_MAX_CLUSTER_SIZE / PAGE_SIZE,
 } NTFS_CONSTANTS;
 
 /* Global variables. */
diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
index 1b38abdaa3ed..ecb49870a680 100644
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -823,14 +823,14 @@ static bool parse_ntfs_boot_sector(ntfs_volume *vol, const NTFS_BOOT_SECTOR *b)
 	ntfs_debug("vol->mft_record_size_bits = %i (0x%x)",
 			vol->mft_record_size_bits, vol->mft_record_size_bits);
 	/*
-	 * We cannot support mft record sizes above the PAGE_CACHE_SIZE since
+	 * We cannot support mft record sizes above the PAGE_SIZE since
 	 * we store $MFT/$DATA, the table of mft records in the page cache.
 	 */
-	if (vol->mft_record_size > PAGE_CACHE_SIZE) {
+	if (vol->mft_record_size > PAGE_SIZE) {
 		ntfs_error(vol->sb, "Mft record size (%i) exceeds the "
-				"PAGE_CACHE_SIZE on your system (%lu).  "
+				"PAGE_SIZE on your system (%lu).  "
 				"This is not supported.  Sorry.",
-				vol->mft_record_size, PAGE_CACHE_SIZE);
+				vol->mft_record_size, PAGE_SIZE);
 		return false;
 	}
 	/* We cannot support mft record sizes below the sector size. */
@@ -1096,7 +1096,7 @@ static bool check_mft_mirror(ntfs_volume *vol)
 
 	ntfs_debug("Entering.");
 	/* Compare contents of $MFT and $MFTMirr. */
-	mrecs_per_page = PAGE_CACHE_SIZE / vol->mft_record_size;
+	mrecs_per_page = PAGE_SIZE / vol->mft_record_size;
 	BUG_ON(!mrecs_per_page);
 	BUG_ON(!vol->mftmirr_size);
 	mft_page = mirr_page = NULL;
@@ -1615,20 +1615,20 @@ static bool load_and_init_attrdef(ntfs_volume *vol)
 	if (!vol->attrdef)
 		goto iput_failed;
 	index = 0;
-	max_index = i_size >> PAGE_CACHE_SHIFT;
-	size = PAGE_CACHE_SIZE;
+	max_index = i_size >> PAGE_SHIFT;
+	size = PAGE_SIZE;
 	while (index < max_index) {
 		/* Read the attrdef table and copy it into the linear buffer. */
 read_partial_attrdef_page:
 		page = ntfs_map_page(ino->i_mapping, index);
 		if (IS_ERR(page))
 			goto free_iput_failed;
-		memcpy((u8*)vol->attrdef + (index++ << PAGE_CACHE_SHIFT),
+		memcpy((u8*)vol->attrdef + (index++ << PAGE_SHIFT),
 				page_address(page), size);
 		ntfs_unmap_page(page);
 	};
-	if (size == PAGE_CACHE_SIZE) {
-		size = i_size & ~PAGE_CACHE_MASK;
+	if (size == PAGE_SIZE) {
+		size = i_size & ~PAGE_MASK;
 		if (size)
 			goto read_partial_attrdef_page;
 	}
@@ -1684,20 +1684,20 @@ static bool load_and_init_upcase(ntfs_volume *vol)
 	if (!vol->upcase)
 		goto iput_upcase_failed;
 	index = 0;
-	max_index = i_size >> PAGE_CACHE_SHIFT;
-	size = PAGE_CACHE_SIZE;
+	max_index = i_size >> PAGE_SHIFT;
+	size = PAGE_SIZE;
 	while (index < max_index) {
 		/* Read the upcase table and copy it into the linear buffer. */
 read_partial_upcase_page:
 		page = ntfs_map_page(ino->i_mapping, index);
 		if (IS_ERR(page))
 			goto iput_upcase_failed;
-		memcpy((char*)vol->upcase + (index++ << PAGE_CACHE_SHIFT),
+		memcpy((char*)vol->upcase + (index++ << PAGE_SHIFT),
 				page_address(page), size);
 		ntfs_unmap_page(page);
 	};
-	if (size == PAGE_CACHE_SIZE) {
-		size = i_size & ~PAGE_CACHE_MASK;
+	if (size == PAGE_SIZE) {
+		size = i_size & ~PAGE_MASK;
 		if (size)
 			goto read_partial_upcase_page;
 	}
@@ -2471,14 +2471,14 @@ static s64 get_nr_free_clusters(ntfs_volume *vol)
 	down_read(&vol->lcnbmp_lock);
 	/*
 	 * Convert the number of bits into bytes rounded up, then convert into
-	 * multiples of PAGE_CACHE_SIZE, rounding up so that if we have one
+	 * multiples of PAGE_SIZE, rounding up so that if we have one
 	 * full and one partial page max_index = 2.
 	 */
-	max_index = (((vol->nr_clusters + 7) >> 3) + PAGE_CACHE_SIZE - 1) >>
-			PAGE_CACHE_SHIFT;
-	/* Use multiples of 4 bytes, thus max_size is PAGE_CACHE_SIZE / 4. */
+	max_index = (((vol->nr_clusters + 7) >> 3) + PAGE_SIZE - 1) >>
+			PAGE_SHIFT;
+	/* Use multiples of 4 bytes, thus max_size is PAGE_SIZE / 4. */
 	ntfs_debug("Reading $Bitmap, max_index = 0x%lx, max_size = 0x%lx.",
-			max_index, PAGE_CACHE_SIZE / 4);
+			max_index, PAGE_SIZE / 4);
 	for (index = 0; index < max_index; index++) {
 		unsigned long *kaddr;
 
@@ -2491,7 +2491,7 @@ static s64 get_nr_free_clusters(ntfs_volume *vol)
 		if (IS_ERR(page)) {
 			ntfs_debug("read_mapping_page() error. Skipping "
 					"page (index 0x%lx).", index);
-			nr_free -= PAGE_CACHE_SIZE * 8;
+			nr_free -= PAGE_SIZE * 8;
 			continue;
 		}
 		kaddr = kmap_atomic(page);
@@ -2503,9 +2503,9 @@ static s64 get_nr_free_clusters(ntfs_volume *vol)
 		 * ntfs_readpage().
 		 */
 		nr_free -= bitmap_weight(kaddr,
-					PAGE_CACHE_SIZE * BITS_PER_BYTE);
+					PAGE_SIZE * BITS_PER_BYTE);
 		kunmap_atomic(kaddr);
-		page_cache_release(page);
+		put_page(page);
 	}
 	ntfs_debug("Finished reading $Bitmap, last index = 0x%lx.", index - 1);
 	/*
@@ -2547,9 +2547,9 @@ static unsigned long __get_nr_free_mft_records(ntfs_volume *vol,
 	pgoff_t index;
 
 	ntfs_debug("Entering.");
-	/* Use multiples of 4 bytes, thus max_size is PAGE_CACHE_SIZE / 4. */
+	/* Use multiples of 4 bytes, thus max_size is PAGE_SIZE / 4. */
 	ntfs_debug("Reading $MFT/$BITMAP, max_index = 0x%lx, max_size = "
-			"0x%lx.", max_index, PAGE_CACHE_SIZE / 4);
+			"0x%lx.", max_index, PAGE_SIZE / 4);
 	for (index = 0; index < max_index; index++) {
 		unsigned long *kaddr;
 
@@ -2562,7 +2562,7 @@ static unsigned long __get_nr_free_mft_records(ntfs_volume *vol,
 		if (IS_ERR(page)) {
 			ntfs_debug("read_mapping_page() error. Skipping "
 					"page (index 0x%lx).", index);
-			nr_free -= PAGE_CACHE_SIZE * 8;
+			nr_free -= PAGE_SIZE * 8;
 			continue;
 		}
 		kaddr = kmap_atomic(page);
@@ -2574,9 +2574,9 @@ static unsigned long __get_nr_free_mft_records(ntfs_volume *vol,
 		 * ntfs_readpage().
 		 */
 		nr_free -= bitmap_weight(kaddr,
-					PAGE_CACHE_SIZE * BITS_PER_BYTE);
+					PAGE_SIZE * BITS_PER_BYTE);
 		kunmap_atomic(kaddr);
-		page_cache_release(page);
+		put_page(page);
 	}
 	ntfs_debug("Finished reading $MFT/$BITMAP, last index = 0x%lx.",
 			index - 1);
@@ -2618,17 +2618,17 @@ static int ntfs_statfs(struct dentry *dentry, struct kstatfs *sfs)
 	/* Type of filesystem. */
 	sfs->f_type   = NTFS_SB_MAGIC;
 	/* Optimal transfer block size. */
-	sfs->f_bsize  = PAGE_CACHE_SIZE;
+	sfs->f_bsize  = PAGE_SIZE;
 	/*
 	 * Total data blocks in filesystem in units of f_bsize and since
 	 * inodes are also stored in data blocs ($MFT is a file) this is just
 	 * the total clusters.
 	 */
 	sfs->f_blocks = vol->nr_clusters << vol->cluster_size_bits >>
-				PAGE_CACHE_SHIFT;
+				PAGE_SHIFT;
 	/* Free data blocks in filesystem in units of f_bsize. */
 	size	      = get_nr_free_clusters(vol) << vol->cluster_size_bits >>
-				PAGE_CACHE_SHIFT;
+				PAGE_SHIFT;
 	if (size < 0LL)
 		size = 0LL;
 	/* Free blocks avail to non-superuser, same as above on NTFS. */
@@ -2639,11 +2639,11 @@ static int ntfs_statfs(struct dentry *dentry, struct kstatfs *sfs)
 	size = i_size_read(vol->mft_ino) >> vol->mft_record_size_bits;
 	/*
 	 * Convert the maximum number of set bits into bytes rounded up, then
-	 * convert into multiples of PAGE_CACHE_SIZE, rounding up so that if we
+	 * convert into multiples of PAGE_SIZE, rounding up so that if we
 	 * have one full and one partial page max_index = 2.
 	 */
 	max_index = ((((mft_ni->initialized_size >> vol->mft_record_size_bits)
-			+ 7) >> 3) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+			+ 7) >> 3) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	read_unlock_irqrestore(&mft_ni->size_lock, flags);
 	/* Number of inodes in filesystem (at this point in time). */
 	sfs->f_files = size;
@@ -2765,15 +2765,15 @@ static int ntfs_fill_super(struct super_block *sb, void *opt, const int silent)
 	if (!parse_options(vol, (char*)opt))
 		goto err_out_now;
 
-	/* We support sector sizes up to the PAGE_CACHE_SIZE. */
-	if (bdev_logical_block_size(sb->s_bdev) > PAGE_CACHE_SIZE) {
+	/* We support sector sizes up to the PAGE_SIZE. */
+	if (bdev_logical_block_size(sb->s_bdev) > PAGE_SIZE) {
 		if (!silent)
 			ntfs_error(sb, "Device has unsupported sector size "
 					"(%i).  The maximum supported sector "
 					"size on this architecture is %lu "
 					"bytes.",
 					bdev_logical_block_size(sb->s_bdev),
-					PAGE_CACHE_SIZE);
+					PAGE_SIZE);
 		goto err_out_now;
 	}
 	/*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
