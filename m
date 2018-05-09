Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E74B6B0379
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:50:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m4-v6so5346101pgu.5
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:50:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c84si13333711pfd.89.2018.05.09.00.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:50:33 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 30/33] iomap: add initial support for writes without buffer heads
Date: Wed,  9 May 2018 09:48:27 +0200
Message-Id: <20180509074830.16196-31-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

For now just limited to blocksize == PAGE_SIZE, where we can simply read
in the full page in write begin, and just set the whole page dirty after
copying data into it.  This code is enabled by default and XFS will now
be feed pages without buffer heads in ->writepage and ->writepages.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c | 129 +++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 120 insertions(+), 9 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index 967bd31540fe..a3861945504f 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -308,6 +308,56 @@ iomap_write_failed(struct inode *inode, loff_t pos, unsigned len)
 		truncate_pagecache_range(inode, max(pos, i_size), pos + len);
 }
 
+static int
+iomap_read_page_sync(struct inode *inode, loff_t block_start, struct page *page,
+		unsigned poff, unsigned plen, struct iomap *iomap)
+{
+	struct bio_vec bvec;
+	struct bio bio;
+	int ret;
+
+	bio_init(&bio, &bvec, 1);
+	bio.bi_opf = REQ_OP_READ;
+	bio.bi_iter.bi_sector = iomap_sector(iomap, block_start);
+	bio_set_dev(&bio, iomap->bdev);
+	__bio_add_page(&bio, page, plen, poff);
+	ret = submit_bio_wait(&bio);
+	if (ret < 0 && iomap_block_needs_zeroing(inode, block_start, iomap))
+		zero_user(page, poff, plen);
+	return ret;
+}
+
+static int
+__iomap_write_begin(struct inode *inode, loff_t pos, unsigned len,
+		struct page *page, struct iomap *iomap)
+{
+	loff_t block_size = i_blocksize(inode);
+	loff_t block_start = pos & ~(block_size - 1);
+	loff_t block_end = (pos + len + block_size - 1) & ~(block_size - 1);
+	unsigned poff = block_start & (PAGE_SIZE - 1);
+	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, block_end - block_start);
+	int status;
+
+	if (PageUptodate(page))
+		return 0;
+
+	if (iomap_block_needs_zeroing(inode, block_start, iomap)) {
+		unsigned from = pos & (PAGE_SIZE - 1), to = from + len;
+		unsigned pend = poff + plen;
+
+		if (poff < from || pend > to)
+			zero_user_segments(page, poff, from, to, pend);
+	} else {
+		status = iomap_read_page_sync(inode, block_start, page,
+				poff, plen, iomap);
+		if (status < 0)
+			return status;
+		SetPageUptodate(page);
+	}
+
+	return 0;
+}
+
 static int
 iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, struct iomap *iomap)
@@ -325,7 +375,10 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 	if (!page)
 		return -ENOMEM;
 
-	status = __block_write_begin_int(page, pos, len, NULL, iomap);
+	if (i_blocksize(inode) == PAGE_SIZE)
+		status = __iomap_write_begin(inode, pos, len, page, iomap);
+	else
+		status = __block_write_begin_int(page, pos, len, NULL, iomap);
 	if (unlikely(status)) {
 		unlock_page(page);
 		put_page(page);
@@ -338,12 +391,63 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 	return status;
 }
 
+static int
+iomap_set_page_dirty(struct page *page)
+{
+	struct address_space *mapping = page_mapping(page);
+	int newly_dirty;
+
+	if (unlikely(!mapping))
+		return !TestSetPageDirty(page);
+
+	/*
+	 * Lock out page->mem_cgroup migration to keep PageDirty
+	 * synchronized with per-memcg dirty page counters.
+	 */
+	lock_page_memcg(page);
+	newly_dirty = !TestSetPageDirty(page);
+	if (newly_dirty)
+		__set_page_dirty(page, mapping, 0);
+	unlock_page_memcg(page);
+
+	if (newly_dirty)
+		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+	return newly_dirty;
+}
+
+static int
+__iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
+		unsigned copied, struct page *page, struct iomap *iomap)
+{
+	unsigned start = pos & (PAGE_SIZE - 1);
+	int ret;
+
+	if (unlikely(copied < len)) {
+		/* see block_write_end() for an explanation */
+		if (!PageUptodate(page))
+			copied = 0;
+		if (iomap_block_needs_zeroing(inode, pos, iomap))
+			zero_user(page, start + copied, len - copied);
+	}
+
+	flush_dcache_page(page);
+	SetPageUptodate(page);
+	iomap_set_page_dirty(page);
+	ret = __generic_write_end(inode, pos, copied, page);
+	if (ret < len)
+		iomap_write_failed(inode, pos, len);
+	return ret;
+}
+
 static int
 iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
-		unsigned copied, struct page *page)
+		unsigned copied, struct page *page, struct iomap *iomap)
 {
 	int ret;
 
+	if (i_blocksize(inode) == PAGE_SIZE)
+		return __iomap_write_end(inode, pos, len, copied, page, iomap);
+
 	ret = generic_write_end(NULL, inode->i_mapping, pos, len,
 			copied, page, NULL);
 	if (ret < len)
@@ -400,7 +504,8 @@ iomap_write_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 
 		flush_dcache_page(page);
 
-		status = iomap_write_end(inode, pos, bytes, copied, page);
+		status = iomap_write_end(inode, pos, bytes, copied, page,
+				iomap);
 		if (unlikely(status < 0))
 			break;
 		copied = status;
@@ -494,7 +599,7 @@ iomap_dirty_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 
 		WARN_ON_ONCE(!PageUptodate(page));
 
-		status = iomap_write_end(inode, pos, bytes, bytes, page);
+		status = iomap_write_end(inode, pos, bytes, bytes, page, iomap);
 		if (unlikely(status <= 0)) {
 			if (WARN_ON_ONCE(status == 0))
 				return -EIO;
@@ -546,7 +651,7 @@ static int iomap_zero(struct inode *inode, loff_t pos, unsigned offset,
 	zero_user(page, offset, bytes);
 	mark_page_accessed(page);
 
-	return iomap_write_end(inode, pos, bytes, bytes, page);
+	return iomap_write_end(inode, pos, bytes, bytes, page, iomap);
 }
 
 static int iomap_dax_zero(loff_t pos, unsigned offset, unsigned bytes,
@@ -632,11 +737,14 @@ iomap_page_mkwrite_actor(struct inode *inode, loff_t pos, loff_t length,
 	struct page *page = data;
 	int ret;
 
-	ret = __block_write_begin_int(page, pos, length, NULL, iomap);
-	if (ret)
-		return ret;
+	if (i_blocksize(inode) != PAGE_SIZE) {
+		ret = __block_write_begin_int(page, pos, length, NULL, iomap);
+		if (ret)
+			return ret;
+
+		block_commit_write(page, 0, length);
+	}
 
-	block_commit_write(page, 0, length);
 	return length;
 }
 
@@ -663,6 +771,9 @@ int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops)
 	else
 		length = PAGE_SIZE;
 
+	if (i_blocksize(inode) == PAGE_SIZE)
+		WARN_ON_ONCE(!PageUptodate(page));
+
 	offset = page_offset(page);
 	while (length > 0) {
 		ret = iomap_apply(inode, offset, length,
-- 
2.17.0
