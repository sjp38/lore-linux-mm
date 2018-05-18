Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6851C6B0601
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:48:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s16-v6so5065394pfm.1
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:48:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n14-v6si6247124pgu.688.2018.05.18.09.48.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:48:48 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 05/34] fs: use ->is_partially_uptodate in page_cache_seek_hole_data
Date: Fri, 18 May 2018 18:48:01 +0200
Message-Id: <20180518164830.1552-6-hch@lst.de>
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
References: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

This way the implementation doesn't depend on buffer_head internals.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c | 83 +++++++++++++++++++++++++++---------------------------
 1 file changed, 42 insertions(+), 41 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index bef5e91d40bf..0fecd5789d7b 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -594,31 +594,54 @@ EXPORT_SYMBOL_GPL(iomap_fiemap);
  *
  * Returns the offset within the file on success, and -ENOENT otherwise.
  */
-static loff_t
-page_seek_hole_data(struct page *page, loff_t lastoff, int whence)
+static bool
+page_seek_hole_data(struct inode *inode, struct page *page, loff_t *lastoff,
+		int whence)
 {
-	loff_t offset = page_offset(page);
-	struct buffer_head *bh, *head;
+	const struct address_space_operations *ops = inode->i_mapping->a_ops;
+	unsigned int bsize = i_blocksize(inode), off;
 	bool seek_data = whence == SEEK_DATA;
+	loff_t poff = page_offset(page);
 
-	if (lastoff < offset)
-		lastoff = offset;
-
-	bh = head = page_buffers(page);
-	do {
-		offset += bh->b_size;
-		if (lastoff >= offset)
-			continue;
+	if (WARN_ON_ONCE(*lastoff >= poff + PAGE_SIZE))
+		return false;
 
+	if (*lastoff < poff) {
 		/*
-		 * Any buffer with valid data in it should have BH_Uptodate set.
+		 * Last offset smaller than the start of the page means we found
+		 * a hole:
 		 */
-		if (buffer_uptodate(bh) == seek_data)
-			return lastoff;
+		if (whence == SEEK_HOLE)
+			return true;
+		*lastoff = poff;
+	}
 
-		lastoff = offset;
-	} while ((bh = bh->b_this_page) != head);
-	return -ENOENT;
+	/*
+	 * Just check the page unless we can and should check block ranges:
+	 */
+	if (bsize == PAGE_SIZE || !ops->is_partially_uptodate) {
+		if (PageUptodate(page) == seek_data)
+			return true;
+		return false;
+	}
+
+	lock_page(page);
+	if (unlikely(page->mapping != inode->i_mapping))
+		goto out_unlock_not_found;
+
+	for (off = 0; off < PAGE_SIZE; off += bsize) {
+		if ((*lastoff & ~PAGE_MASK) >= off + bsize)
+			continue;
+		if (ops->is_partially_uptodate(page, off, bsize) == seek_data) {
+			unlock_page(page);
+			return true;
+		}
+		*lastoff = poff + off + bsize;
+	}
+
+out_unlock_not_found:
+	unlock_page(page);
+	return false;
 }
 
 /*
@@ -655,30 +678,8 @@ page_cache_seek_hole_data(struct inode *inode, loff_t offset, loff_t length,
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			/*
-			 * At this point, the page may be truncated or
-			 * invalidated (changing page->mapping to NULL), or
-			 * even swizzled back from swapper_space to tmpfs file
-			 * mapping.  However, page->index will not change
-			 * because we have a reference on the page.
-                         *
-			 * If current page offset is beyond where we've ended,
-			 * we've found a hole.
-                         */
-			if (whence == SEEK_HOLE &&
-			    lastoff < page_offset(page))
+			if (page_seek_hole_data(inode, page, &lastoff, whence))
 				goto check_range;
-
-			lock_page(page);
-			if (likely(page->mapping == inode->i_mapping) &&
-			    page_has_buffers(page)) {
-				lastoff = page_seek_hole_data(page, lastoff, whence);
-				if (lastoff >= 0) {
-					unlock_page(page);
-					goto check_range;
-				}
-			}
-			unlock_page(page);
 			lastoff = page_offset(page) + PAGE_SIZE;
 		}
 		pagevec_release(&pvec);
-- 
2.17.0
