Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 047176B0613
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:49:19 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f35-v6so5355797plb.10
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:49:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 92-v6si7675683pli.280.2018.05.18.09.49.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:49:17 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 15/34] iomap: add an iomap-based readpage and readpages implementation
Date: Fri, 18 May 2018 18:48:11 +0200
Message-Id: <20180518164830.1552-16-hch@lst.de>
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
References: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Simply use iomap_apply to iterate over the file and a submit a bio for
each non-uptodate but mapped region and zero everything else.  Note that
as-is this can not be used for file systems with a blocksize smaller than
the page size, but that support will be added later.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c            | 200 +++++++++++++++++++++++++++++++++++++++++-
 include/linux/iomap.h |   4 +
 2 files changed, 203 insertions(+), 1 deletion(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index 7c1b071d115c..821671af2618 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2010 Red Hat, Inc.
- * Copyright (c) 2016 Christoph Hellwig.
+ * Copyright (c) 2016-2018 Christoph Hellwig.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -18,6 +18,7 @@
 #include <linux/uaccess.h>
 #include <linux/gfp.h>
 #include <linux/mm.h>
+#include <linux/mm_inline.h>
 #include <linux/swap.h>
 #include <linux/pagemap.h>
 #include <linux/pagevec.h>
@@ -103,6 +104,203 @@ iomap_sector(struct iomap *iomap, loff_t pos)
 	return (iomap->addr + pos - iomap->offset) >> SECTOR_SHIFT;
 }
 
+static inline bool
+iomap_block_needs_zeroing(struct inode *inode, loff_t pos, struct iomap *iomap)
+{
+       return iomap->type != IOMAP_MAPPED || pos > i_size_read(inode);
+}
+
+static void
+iomap_read_end_io(struct bio *bio)
+{
+	int error = blk_status_to_errno(bio->bi_status);
+	struct bio_vec *bvec;
+	int i;
+
+	bio_for_each_segment_all(bvec, bio, i)
+		page_endio(bvec->bv_page, false, error);
+	bio_put(bio);
+}
+
+static struct bio *
+iomap_read_bio_alloc(struct iomap *iomap, sector_t sector, loff_t length)
+{
+	int nr_vecs = (length + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	struct bio *bio = bio_alloc(GFP_NOFS, min(BIO_MAX_PAGES, nr_vecs));
+
+	bio->bi_opf = REQ_OP_READ;
+	bio->bi_iter.bi_sector = sector;
+	bio_set_dev(bio, iomap->bdev);
+	bio->bi_end_io = iomap_read_end_io;
+	return bio;
+}
+
+struct iomap_readpage_ctx {
+	struct page		*cur_page;
+	bool			cur_page_in_bio;
+	struct bio		*bio;
+	struct list_head	*pages;
+};
+
+static loff_t
+iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
+		struct iomap *iomap)
+{
+	struct iomap_readpage_ctx *ctx = data;
+	struct page *page = ctx->cur_page;
+	unsigned poff = pos & (PAGE_SIZE - 1);
+	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, length);
+	bool is_contig = false;
+	sector_t sector;
+
+	/* we don't support blocksize < PAGE_SIZE quite yet: */
+	WARN_ON_ONCE(pos != page_offset(page));
+	WARN_ON_ONCE(plen != PAGE_SIZE);
+
+	if (iomap_block_needs_zeroing(inode, pos, iomap)) {
+		zero_user(page, poff, plen);
+		SetPageUptodate(page);
+		goto done;
+	}
+
+	ctx->cur_page_in_bio = true;
+
+	/*
+	 * Try to merge into a previous segment if we can.
+	 */
+	sector = iomap_sector(iomap, pos);
+	if (ctx->bio && bio_end_sector(ctx->bio) == sector) {
+		if (__bio_try_merge_page(ctx->bio, page, plen, poff))
+			goto done;
+		is_contig = true;
+	}
+
+	if (!ctx->bio || !is_contig || bio_full(ctx->bio)) {
+		if (ctx->bio)
+			submit_bio(ctx->bio);
+		ctx->bio = iomap_read_bio_alloc(iomap, sector, length);
+	}
+
+	__bio_add_page(ctx->bio, page, plen, poff);
+done:
+	return plen;
+}
+
+int
+iomap_readpage(struct page *page, const struct iomap_ops *ops)
+{
+	struct iomap_readpage_ctx ctx = { .cur_page = page };
+	struct inode *inode = page->mapping->host;
+	unsigned poff;
+	loff_t ret;
+
+	WARN_ON_ONCE(page_has_buffers(page));
+
+	for (poff = 0; poff < PAGE_SIZE; poff += ret) {
+		ret = iomap_apply(inode, page_offset(page) + poff,
+				PAGE_SIZE - poff, 0, ops, &ctx,
+				iomap_readpage_actor);
+		if (ret <= 0) {
+			WARN_ON_ONCE(ret == 0);
+			SetPageError(page);
+			break;
+		}
+	}
+
+	if (ctx.bio) {
+		submit_bio(ctx.bio);
+		WARN_ON_ONCE(!ctx.cur_page_in_bio);
+	} else {
+		WARN_ON_ONCE(ctx.cur_page_in_bio);
+		unlock_page(page);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(iomap_readpage);
+
+static struct page *
+iomap_next_page(struct inode *inode, struct list_head *pages, loff_t pos,
+		loff_t length, loff_t *done)
+{
+	while (!list_empty(pages)) {
+		struct page *page = lru_to_page(pages);
+
+		if (page_offset(page) >= (u64)pos + length)
+			break;
+
+		list_del(&page->lru);
+		if (!add_to_page_cache_lru(page, inode->i_mapping, page->index,
+				GFP_NOFS))
+			return page;
+
+		*done += PAGE_SIZE;
+		put_page(page);
+	}
+
+	return NULL;
+}
+
+static loff_t
+iomap_readpages_actor(struct inode *inode, loff_t pos, loff_t length,
+		void *data, struct iomap *iomap)
+{
+	struct iomap_readpage_ctx *ctx = data;
+	loff_t done, ret;
+
+	for (done = 0; done < length; done += ret) {
+		if (ctx->cur_page && ((pos + done) & (PAGE_SIZE - 1)) == 0) {
+			if (!ctx->cur_page_in_bio)
+				unlock_page(ctx->cur_page);
+			put_page(ctx->cur_page);
+			ctx->cur_page = NULL;
+		}
+		if (!ctx->cur_page) {
+			ctx->cur_page = iomap_next_page(inode, ctx->pages,
+					pos, length, &done);
+			if (!ctx->cur_page)
+				break;
+			ctx->cur_page_in_bio = false;
+		}
+		ret = iomap_readpage_actor(inode, pos + done, length - done,
+				ctx, iomap);
+	}
+
+	return done;
+}
+
+int
+iomap_readpages(struct address_space *mapping, struct list_head *pages,
+		unsigned nr_pages, const struct iomap_ops *ops)
+{
+	struct iomap_readpage_ctx ctx = { .pages = pages };
+	loff_t pos = page_offset(list_entry(pages->prev, struct page, lru));
+	loff_t last = page_offset(list_entry(pages->next, struct page, lru));
+	loff_t length = last - pos + PAGE_SIZE, ret = 0;
+
+	while (length > 0) {
+		ret = iomap_apply(mapping->host, pos, length, 0, ops,
+				&ctx, iomap_readpages_actor);
+		if (ret <= 0) {
+			WARN_ON_ONCE(ret == 0);
+			goto done;
+		}
+		pos += ret;
+		length -= ret;
+	}
+	ret = 0;
+done:
+	if (ctx.bio)
+		submit_bio(ctx.bio);
+	if (ctx.cur_page) {
+		if (!ctx.cur_page_in_bio)
+			unlock_page(ctx.cur_page);
+		put_page(ctx.cur_page);
+	}
+	WARN_ON_ONCE(!ret && !list_empty(ctx.pages));
+	return ret;
+}
+EXPORT_SYMBOL_GPL(iomap_readpages);
+
 static void
 iomap_write_failed(struct inode *inode, loff_t pos, unsigned len)
 {
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index a044a824da85..7300d30ca495 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -9,6 +9,7 @@ struct fiemap_extent_info;
 struct inode;
 struct iov_iter;
 struct kiocb;
+struct page;
 struct vm_area_struct;
 struct vm_fault;
 
@@ -88,6 +89,9 @@ struct iomap_ops {
 
 ssize_t iomap_file_buffered_write(struct kiocb *iocb, struct iov_iter *from,
 		const struct iomap_ops *ops);
+int iomap_readpage(struct page *page, const struct iomap_ops *ops);
+int iomap_readpages(struct address_space *mapping, struct list_head *pages,
+		unsigned nr_pages, const struct iomap_ops *ops);
 int iomap_file_dirty(struct inode *inode, loff_t pos, loff_t len,
 		const struct iomap_ops *ops);
 int iomap_zero_range(struct inode *inode, loff_t pos, loff_t len,
-- 
2.17.0
