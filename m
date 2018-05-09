Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D1D8B6B036F
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:50:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r63so23962413pfl.12
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:50:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 38-v6si26185422pln.390.2018.05.09.00.50.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:50:22 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 26/33] xfs: allow writeback on pages without buffer heads
Date: Wed,  9 May 2018 09:48:23 +0200
Message-Id: <20180509074830.16196-27-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

We'll soon allow these through changes in the iomap write_begin and
page_mkwrite implementations, so get ready for them.  After the previous
refactoring this is as simple as not maintaining the bh variable if
the page doesn' thave private data, and skipping the non-uptodate buffer
check in this case for the writepage path, and adding a new per-page
I/O completion handler that skips all buffer head manipulation.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 47 ++++++++++++++++++++++++++++++++++-------------
 1 file changed, 34 insertions(+), 13 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index c76c943473be..879599f723b6 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -91,6 +91,19 @@ xfs_find_daxdev_for_inode(
 		return mp->m_ddev_targp->bt_daxdev;
 }
 
+static void
+xfs_finish_page_writeback(
+	struct inode		*inode,
+	struct bio_vec		*bvec,
+	int			error)
+{
+	if (error) {
+		SetPageError(bvec->bv_page);
+		mapping_set_error(inode->i_mapping, -EIO);
+	}
+	end_page_writeback(bvec->bv_page);
+}
+
 /*
  * We're now finished for good with this page.  Update the page state via the
  * associated buffer_heads, paying attention to the start and end offsets that
@@ -103,7 +116,7 @@ xfs_find_daxdev_for_inode(
  * and buffers potentially freed after every call to end_buffer_async_write.
  */
 static void
-xfs_finish_page_writeback(
+xfs_finish_buffer_writeback(
 	struct inode		*inode,
 	struct bio_vec		*bvec,
 	int			error)
@@ -178,9 +191,12 @@ xfs_destroy_ioend(
 			next = bio->bi_private;
 
 		/* walk each page on bio, ending page IO on them */
-		bio_for_each_segment_all(bvec, bio, i)
-			xfs_finish_page_writeback(inode, bvec, error);
-
+		bio_for_each_segment_all(bvec, bio, i) {
+			if (page_has_buffers(bvec->bv_page))
+				xfs_finish_buffer_writeback(inode, bvec, error);
+			else
+				xfs_finish_page_writeback(inode, bvec, error);
+		}
 		bio_put(bio);
 	}
 
@@ -816,7 +832,7 @@ xfs_writepage_map(
 {
 	LIST_HEAD(submit_list);
 	struct xfs_ioend	*ioend, *next;
-	struct buffer_head	*bh;
+	struct buffer_head	*bh = NULL;
 	ssize_t			len = i_blocksize(inode);
 	int			error = 0;
 	int			count = 0;
@@ -824,6 +840,9 @@ xfs_writepage_map(
 	loff_t			file_offset;	/* file offset of page */
 	unsigned		poffset;	/* offset into page */
 
+	if (page_has_buffers(page))
+		bh = page_buffers(page);
+
 	/*
 	 * Walk the blocks on the page, and we we run off then end of the
 	 * current map or find the current map invalid, grab a new one.
@@ -832,11 +851,9 @@ xfs_writepage_map(
 	 * replace the bufferhead with some other state tracking mechanism in
 	 * future.
 	 */
-	file_offset = page_offset(page);
-	bh = page_buffers(page);
-	for (poffset = 0;
+	for (poffset = 0, file_offset = page_offset(page);
 	     poffset < PAGE_SIZE;
-	     poffset += len, file_offset += len, bh = bh->b_this_page) {
+	     poffset += len, file_offset += len) {
 		/* past the range we are writing, so nothing more to write. */
 		if (file_offset >= end_offset)
 			break;
@@ -844,10 +861,11 @@ xfs_writepage_map(
 		/*
 		 * Block does not contain valid data, skip it.
 		 */
-		if (!buffer_uptodate(bh)) {
+		if (bh && !buffer_uptodate(bh)) {
 			if (PageUptodate(page))
 				ASSERT(buffer_mapped(bh));
 			uptodate = false;
+			bh = bh->b_this_page;
 			continue;
 		}
 
@@ -872,10 +890,15 @@ xfs_writepage_map(
 			 * meaningless for holes (!mapped && uptodate), so check we did
 			 * have a buffer covering a hole here and continue.
 			 */
+			if (bh)
+				bh = bh->b_this_page;
 			continue;
 		}
 
-		xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
+		if (bh) {
+			xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
+			bh = bh->b_this_page;
+		}
 		xfs_add_to_ioend(inode, file_offset, page, wpc, wbc,
 				&submit_list);
 		count++;
@@ -960,8 +983,6 @@ xfs_do_writepage(
 
 	trace_xfs_writepage(inode, page, 0, 0);
 
-	ASSERT(page_has_buffers(page));
-
 	/*
 	 * Refuse to write the page out if we are called from reclaim context.
 	 *
-- 
2.17.0
