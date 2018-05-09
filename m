Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E524D6B037B
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:50:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a12-v6so4052591pgu.20
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:50:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a21si24969175pfo.31.2018.05.09.00.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:50:37 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 31/33] iomap: add support for sub-pagesize buffered I/O without buffer heads
Date: Wed,  9 May 2018 09:48:28 +0200
Message-Id: <20180509074830.16196-32-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

After already supporting a simple implementation of buffered writes for
the blocksize == PAGE_SIZE case in the last commit this adds full support
even for smaller block sizes.   There are three bits of per-block
information in the buffer_head structure that really matter for the iomap
read and write path:

 - uptodate status (BH_uptodate)
 - marked as currently under read I/O (BH_Async_Read)
 - marked as currently under write I/O (BH_Async_Write)

Instead of having new per-block structures this now adds a per-page
structure called struct iomap_page to track this information in a slightly
different form:

 - a bitmap for the per-block uptodate status.  For worst case of a 64k
   page size system this bitmap needs to contain 128 bits.  For the
   typical 4k page size case it only needs 8 bits, although we still
   need a full unsigned long due to the way the atomic bitmap API works.
 - two atomic_t counters are used to track the outstanding read and write
   counts

There is quite a bit of boilerplate code as the buffered I/O path uses
various helper methods, but the actual code is very straight forward.

In this commit the code can't actually be used yet, as we need to
switch from the old implementation to the new one together with the
XFS writeback code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c            | 262 +++++++++++++++++++++++++++++++++++++-----
 include/linux/iomap.h |  32 ++++++
 2 files changed, 264 insertions(+), 30 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index a3861945504f..4e7ac6aa88ef 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -17,6 +17,7 @@
 #include <linux/iomap.h>
 #include <linux/uaccess.h>
 #include <linux/gfp.h>
+#include <linux/migrate.h>
 #include <linux/mm.h>
 #include <linux/mm_inline.h>
 #include <linux/swap.h>
@@ -109,6 +110,107 @@ iomap_block_needs_zeroing(struct inode *inode, loff_t pos, struct iomap *iomap)
        return iomap->type != IOMAP_MAPPED || pos > i_size_read(inode);
 }
 
+static struct iomap_page *
+iomap_page_create(struct inode *inode, struct page *page)
+{
+	struct iomap_page *iop = to_iomap_page(page);
+
+	if (iop || i_blocksize(inode) == PAGE_SIZE)
+		return iop;
+
+	iop = kmalloc(sizeof(*iop), GFP_NOFS | __GFP_NOFAIL);
+	atomic_set(&iop->read_count, 0);
+	atomic_set(&iop->write_count, 0);
+	bitmap_zero(iop->uptodate, PAGE_SIZE / SECTOR_SIZE);
+	set_page_private(page, (unsigned long)iop);
+	SetPagePrivate(page);
+	return iop;
+}
+
+/*
+ * Calculate the range inside the page that we actually need to read.
+ */
+static void
+iomap_read_calculate_range(struct inode *inode, struct iomap_page *iop,
+		loff_t *pos, loff_t length, unsigned *offp, unsigned *lenp)
+{
+	unsigned poff = *pos & (PAGE_SIZE - 1);
+	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, length);
+
+	if (iop) {
+		unsigned block_size = i_blocksize(inode);
+		unsigned first = poff >> inode->i_blkbits;
+		unsigned last = (poff + plen - 1) >> inode->i_blkbits;
+		unsigned int i;
+
+		/* move forward for each leading block marked uptodate */
+		for (i = first; i <= last; i++) {
+			if (!test_bit(i, iop->uptodate))
+				break;
+			*pos += block_size;
+			poff += block_size;
+			plen -= block_size;
+		}
+
+		/* truncate len if we find any trailing uptodate block(s) */
+		for ( ; i <= last; i++) {
+			if (test_bit(i, iop->uptodate)) {
+				plen -= (last - i + 1) * block_size;
+				break;
+			}
+		}
+	}
+
+	*offp = poff;
+	*lenp = plen;
+}
+
+static void
+iomap_set_range_uptodate(struct page *page, unsigned off, unsigned len)
+{
+	struct iomap_page *iop = to_iomap_page(page);
+	struct inode *inode = page->mapping->host;
+	unsigned first = off >> inode->i_blkbits;
+	unsigned last = (off + len - 1) >> inode->i_blkbits;
+	unsigned int i;
+	bool uptodate = true;
+
+	if (iop) {
+		for (i = 0; i < PAGE_SIZE / i_blocksize(inode); i++) {
+			if (i >= first && i <= last)
+				set_bit(i, iop->uptodate);
+			else if (!test_bit(i, iop->uptodate))
+				uptodate = false;
+		}
+	}
+
+	if (uptodate && !PageError(page))
+		SetPageUptodate(page);
+}
+
+static void
+iomap_read_finish(struct iomap_page *iop, struct page *page)
+{
+	if (!iop || atomic_dec_and_test(&iop->read_count))
+		unlock_page(page);
+}
+
+static void
+iomap_read_page_end_io(struct bio_vec *bvec, int error)
+{
+	struct page *page = bvec->bv_page;
+	struct iomap_page *iop = to_iomap_page(page);
+
+	if (unlikely(error)) {
+		ClearPageUptodate(page);
+		SetPageError(page);
+	} else {
+		iomap_set_range_uptodate(page, bvec->bv_offset, bvec->bv_len);
+	}
+
+	iomap_read_finish(iop, page);
+}
+
 static void
 iomap_read_end_io(struct bio *bio)
 {
@@ -117,7 +219,7 @@ iomap_read_end_io(struct bio *bio)
 	int i;
 
 	bio_for_each_segment_all(bvec, bio, i)
-		page_endio(bvec->bv_page, false, error);
+		iomap_read_page_end_io(bvec, error);
 	bio_put(bio);
 }
 
@@ -147,18 +249,19 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 {
 	struct iomap_readpage_ctx *ctx = data;
 	struct page *page = ctx->cur_page;
-	unsigned poff = pos & (PAGE_SIZE - 1);
-	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, length);
+	struct iomap_page *iop = iomap_page_create(inode, page);
 	bool is_contig = false;
+	loff_t orig_pos = pos;
+	unsigned poff, plen;
 	sector_t sector;
 
-	/* we don't support blocksize < PAGE_SIZE quite yet: */
-	WARN_ON_ONCE(pos != page_offset(page));
-	WARN_ON_ONCE(plen != PAGE_SIZE);
+	iomap_read_calculate_range(inode, iop, &pos, length, &poff, &plen);
+	if (plen == 0)
+		goto done;
 
 	if (iomap_block_needs_zeroing(inode, pos, iomap)) {
 		zero_user(page, poff, plen);
-		SetPageUptodate(page);
+		iomap_set_range_uptodate(page, poff, plen);
 		goto done;
 	}
 
@@ -174,6 +277,14 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		is_contig = true;
 	}
 
+	/*
+	 * If we start a new segment we need to increase the read count, and we
+	 * need to do so before submitting any previous full bio to make sure
+	 * that we don't prematurely unlock the page.
+	 */
+	if (iop)
+		atomic_inc(&iop->read_count);
+
 	if (!ctx->bio || !is_contig || bio_full(ctx->bio)) {
 		if (ctx->bio)
 			submit_bio(ctx->bio);
@@ -182,7 +293,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 
 	__bio_add_page(ctx->bio, page, plen, poff);
 done:
-	return plen;
+	return pos - orig_pos + plen;
 }
 
 int
@@ -193,8 +304,6 @@ iomap_readpage(struct page *page, const struct iomap_ops *ops)
 	unsigned poff;
 	loff_t ret;
 
-	WARN_ON_ONCE(page_has_buffers(page));
-
 	for (poff = 0; poff < PAGE_SIZE; poff += ret) {
 		ret = iomap_apply(inode, page_offset(page) + poff,
 				PAGE_SIZE - poff, 0, ops, &ctx,
@@ -295,6 +404,90 @@ iomap_readpages(struct address_space *mapping, struct list_head *pages,
 }
 EXPORT_SYMBOL_GPL(iomap_readpages);
 
+int
+iomap_is_partially_uptodate(struct page *page, unsigned long from,
+		unsigned long count)
+{
+	struct iomap_page *iop = to_iomap_page(page);
+	struct inode *inode = page->mapping->host;
+	unsigned first = from >> inode->i_blkbits;
+	unsigned last = (from + count - 1) >> inode->i_blkbits;
+	unsigned i;
+
+	if (iop) {
+		for (i = first; i <= last; i++)
+			if (!test_bit(i, iop->uptodate))
+				return 0;
+		return 1;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(iomap_is_partially_uptodate);
+
+int
+iomap_releasepage(struct page *page, gfp_t gfp_mask)
+{
+	struct iomap_page *iop = to_iomap_page(page);
+
+	/*
+	 * mm accommodates an old ext3 case where clean pages might not have had
+	 * the dirty bit cleared. Thus, it can send actual dirty pages to
+	 * ->releasepage() via shrink_active_list(), skip those here.
+	 */
+	if (PageDirty(page) || PageWriteback(page))
+		return 0;
+
+	if (iop) {
+		ClearPagePrivate(page);
+		set_page_private(page, 0);
+		kfree(iop);
+	}
+	return 1;
+}
+EXPORT_SYMBOL_GPL(iomap_releasepage);
+
+void
+iomap_invalidatepage(struct page *page, unsigned int offset, unsigned int len)
+{
+	/*
+	 * If we are invalidating the entire page, clear the dirty state from it
+	 * and release it to avoid unnecessary buildup of the LRU.
+	 */
+	if (offset == 0 && len == PAGE_SIZE) {
+		cancel_dirty_page(page);
+		iomap_releasepage(page, 0);
+	}
+}
+EXPORT_SYMBOL_GPL(iomap_invalidatepage);
+
+#ifdef CONFIG_MIGRATION
+int
+iomap_migrate_page(struct address_space *mapping, struct page *newpage,
+		struct page *page, enum migrate_mode mode)
+{
+	int ret;
+
+	ret = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
+	if (ret != MIGRATEPAGE_SUCCESS)
+		return ret;
+
+	if (page_has_private(page)) {
+		ClearPagePrivate(page);
+		set_page_private(newpage, page_private(page));
+		set_page_private(page, 0);
+		SetPagePrivate(newpage);
+	}
+
+	if (mode != MIGRATE_SYNC_NO_COPY)
+		migrate_page_copy(newpage, page);
+	else
+		migrate_page_states(newpage, page);
+	return MIGRATEPAGE_SUCCESS;
+}
+EXPORT_SYMBOL_GPL(iomap_migrate_page);
+#endif /* CONFIG_MIGRATION */
+
 static void
 iomap_write_failed(struct inode *inode, loff_t pos, unsigned len)
 {
@@ -331,28 +524,37 @@ static int
 __iomap_write_begin(struct inode *inode, loff_t pos, unsigned len,
 		struct page *page, struct iomap *iomap)
 {
+	struct iomap_page *iop = iomap_page_create(inode, page);
 	loff_t block_size = i_blocksize(inode);
 	loff_t block_start = pos & ~(block_size - 1);
 	loff_t block_end = (pos + len + block_size - 1) & ~(block_size - 1);
-	unsigned poff = block_start & (PAGE_SIZE - 1);
-	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, block_end - block_start);
-	int status;
+	int status = 0;
 
-	if (PageUptodate(page))
-		return 0;
+	while (!PageUptodate(page)) {
+		unsigned poff, plen;
 
-	if (iomap_block_needs_zeroing(inode, block_start, iomap)) {
-		unsigned from = pos & (PAGE_SIZE - 1), to = from + len;
-		unsigned pend = poff + plen;
+		iomap_read_calculate_range(inode, iop, &block_start,
+				block_end - block_start, &poff, &plen);
+		if (plen == 0)
+			break;
 
-		if (poff < from || pend > to)
-			zero_user_segments(page, poff, from, to, pend);
-	} else {
-		status = iomap_read_page_sync(inode, block_start, page,
-				poff, plen, iomap);
-		if (status < 0)
-			return status;
-		SetPageUptodate(page);
+		if (iomap_block_needs_zeroing(inode, block_start, iomap)) {
+			unsigned from = pos & (PAGE_SIZE - 1), to = from + len;
+			unsigned pend = poff + plen;
+
+			if (poff < from || pend > to)
+				zero_user_segments(page, poff, from, to, pend);
+		} else {
+			status = iomap_read_page_sync(inode, block_start,
+					page, poff, plen, iomap);
+			if (status)
+				return status;
+			iomap_set_range_uptodate(page, poff, plen);
+		}
+
+		if (poff + plen >= PAGE_SIZE)
+			break;
+		block_start += plen;
 	}
 
 	return 0;
@@ -391,7 +593,7 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 	return status;
 }
 
-static int
+int
 iomap_set_page_dirty(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
@@ -414,6 +616,7 @@ iomap_set_page_dirty(struct page *page)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	return newly_dirty;
 }
+EXPORT_SYMBOL_GPL(iomap_set_page_dirty);
 
 static int
 __iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
@@ -431,7 +634,7 @@ __iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 	}
 
 	flush_dcache_page(page);
-	SetPageUptodate(page);
+	iomap_set_range_uptodate(page, start, len);
 	iomap_set_page_dirty(page);
 	ret = __generic_write_end(inode, pos, copied, page);
 	if (ret < len)
@@ -771,8 +974,7 @@ int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops)
 	else
 		length = PAGE_SIZE;
 
-	if (i_blocksize(inode) == PAGE_SIZE)
-		WARN_ON_ONCE(!PageUptodate(page));
+	WARN_ON_ONCE(!PageUptodate(page));
 
 	offset = page_offset(page);
 	while (length > 0) {
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 4710789620e7..fe432a0f02aa 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -2,6 +2,9 @@
 #ifndef LINUX_IOMAP_H
 #define LINUX_IOMAP_H 1
 
+#include <linux/atomic.h>
+#include <linux/bitmap.h>
+#include <linux/mm.h>
 #include <linux/types.h>
 
 struct address_space;
@@ -82,11 +85,40 @@ struct iomap_ops {
 			ssize_t written, unsigned flags, struct iomap *iomap);
 };
 
+/*
+ * Structure allocate for each page when block size < PAGE_SIZE to track
+ * sub-page uptodate status and I/O completions.
+ */
+struct iomap_page {
+	atomic_t		read_count;
+	atomic_t		write_count;
+	DECLARE_BITMAP(uptodate, PAGE_SIZE / 512);
+};
+
+static inline struct iomap_page *to_iomap_page(struct page *page)
+{
+	if (page_has_private(page))
+		return (struct iomap_page *)page_private(page);
+	return NULL;
+}
+
 ssize_t iomap_file_buffered_write(struct kiocb *iocb, struct iov_iter *from,
 		const struct iomap_ops *ops);
 int iomap_readpage(struct page *page, const struct iomap_ops *ops);
 int iomap_readpages(struct address_space *mapping, struct list_head *pages,
 		unsigned nr_pages, const struct iomap_ops *ops);
+int iomap_set_page_dirty(struct page *page);
+int iomap_is_partially_uptodate(struct page *page, unsigned long from,
+		unsigned long count);
+int iomap_releasepage(struct page *page, gfp_t gfp_mask);
+void iomap_invalidatepage(struct page *page, unsigned int offset,
+		unsigned int len);
+#ifdef CONFIG_MIGRATION
+int iomap_migrate_page(struct address_space *mapping, struct page *newpage,
+		struct page *page, enum migrate_mode mode);
+#else
+#define iomap_migrate_page NULL
+#endif
 int iomap_file_dirty(struct inode *inode, loff_t pos, loff_t len,
 		const struct iomap_ops *ops);
 int iomap_zero_range(struct inode *inode, loff_t pos, loff_t len,
-- 
2.17.0
