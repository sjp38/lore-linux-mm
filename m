Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C8F456B000E
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:45:33 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f35-v6so14244776plb.10
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:45:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t189-v6si15289304pgc.163.2018.05.23.07.45.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:45:32 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 29/34] xfs: don't look at buffer heads in xfs_add_to_ioend
Date: Wed, 23 May 2018 16:43:52 +0200
Message-Id: <20180523144357.18985-30-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Calculate all information for the bio based on the passed in information
without requiring a buffer_head structure.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 68 ++++++++++++++++++++++-------------------------
 1 file changed, 32 insertions(+), 36 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index f01c1dd737ec..592b33b35a30 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -44,7 +44,6 @@ struct xfs_writepage_ctx {
 	struct xfs_bmbt_irec    imap;
 	unsigned int		io_type;
 	struct xfs_ioend	*ioend;
-	sector_t		last_block;
 };
 
 void
@@ -545,11 +544,6 @@ xfs_start_page_writeback(
 	unlock_page(page);
 }
 
-static inline int xfs_bio_add_buffer(struct bio *bio, struct buffer_head *bh)
-{
-	return bio_add_page(bio, bh->b_page, bh->b_size, bh_offset(bh));
-}
-
 /*
  * Submit the bio for an ioend. We are passed an ioend with a bio attached to
  * it, and we submit that bio. The ioend may be used for multiple bio
@@ -604,27 +598,20 @@ xfs_submit_ioend(
 	return 0;
 }
 
-static void
-xfs_init_bio_from_bh(
-	struct bio		*bio,
-	struct buffer_head	*bh)
-{
-	bio->bi_iter.bi_sector = bh->b_blocknr * (bh->b_size >> 9);
-	bio_set_dev(bio, bh->b_bdev);
-}
-
 static struct xfs_ioend *
 xfs_alloc_ioend(
 	struct inode		*inode,
 	unsigned int		type,
 	xfs_off_t		offset,
-	struct buffer_head	*bh)
+	struct block_device	*bdev,
+	sector_t		sector)
 {
 	struct xfs_ioend	*ioend;
 	struct bio		*bio;
 
 	bio = bio_alloc_bioset(GFP_NOFS, BIO_MAX_PAGES, xfs_ioend_bioset);
-	xfs_init_bio_from_bh(bio, bh);
+	bio_set_dev(bio, bdev);
+	bio->bi_iter.bi_sector = sector;
 
 	ioend = container_of(bio, struct xfs_ioend, io_inline_bio);
 	INIT_LIST_HEAD(&ioend->io_list);
@@ -649,13 +636,14 @@ static void
 xfs_chain_bio(
 	struct xfs_ioend	*ioend,
 	struct writeback_control *wbc,
-	struct buffer_head	*bh)
+	struct block_device	*bdev,
+	sector_t		sector)
 {
 	struct bio *new;
 
 	new = bio_alloc(GFP_NOFS, BIO_MAX_PAGES);
-	xfs_init_bio_from_bh(new, bh);
-
+	bio_set_dev(new, bdev);
+	new->bi_iter.bi_sector = sector;
 	bio_chain(ioend->io_bio, new);
 	bio_get(ioend->io_bio);		/* for xfs_destroy_ioend */
 	ioend->io_bio->bi_opf = REQ_OP_WRITE | wbc_to_write_flags(wbc);
@@ -665,39 +653,45 @@ xfs_chain_bio(
 }
 
 /*
- * Test to see if we've been building up a completion structure for
- * earlier buffers -- if so, we try to append to this ioend if we
- * can, otherwise we finish off any current ioend and start another.
- * Return the ioend we finished off so that the caller can submit it
- * once it has finished processing the dirty page.
+ * Test to see if we have an existing ioend structure that we could append to
+ * first, otherwise finish off the current ioend and start another.
  */
 STATIC void
 xfs_add_to_ioend(
 	struct inode		*inode,
-	struct buffer_head	*bh,
 	xfs_off_t		offset,
+	struct page		*page,
 	struct xfs_writepage_ctx *wpc,
 	struct writeback_control *wbc,
 	struct list_head	*iolist)
 {
+	struct xfs_inode	*ip = XFS_I(inode);
+	struct xfs_mount	*mp = ip->i_mount;
+	struct block_device	*bdev = xfs_find_bdev_for_inode(inode);
+	unsigned		len = i_blocksize(inode);
+	unsigned		poff = offset & (PAGE_SIZE - 1);
+	sector_t		sector;
+
+	sector = xfs_fsb_to_db(ip, wpc->imap.br_startblock) +
+		((offset - XFS_FSB_TO_B(mp, wpc->imap.br_startoff)) >> 9);
+
 	if (!wpc->ioend || wpc->io_type != wpc->ioend->io_type ||
-	    bh->b_blocknr != wpc->last_block + 1 ||
+	    sector != bio_end_sector(wpc->ioend->io_bio) ||
 	    offset != wpc->ioend->io_offset + wpc->ioend->io_size) {
 		if (wpc->ioend)
 			list_add(&wpc->ioend->io_list, iolist);
-		wpc->ioend = xfs_alloc_ioend(inode, wpc->io_type, offset, bh);
+		wpc->ioend = xfs_alloc_ioend(inode, wpc->io_type, offset,
+				bdev, sector);
 	}
 
 	/*
-	 * If the buffer doesn't fit into the bio we need to allocate a new
-	 * one.  This shouldn't happen more than once for a given buffer.
+	 * If the block doesn't fit into the bio we need to allocate a new
+	 * one.  This shouldn't happen more than once for a given block.
 	 */
-	while (xfs_bio_add_buffer(wpc->ioend->io_bio, bh) != bh->b_size)
-		xfs_chain_bio(wpc->ioend, wbc, bh);
+	while (bio_add_page(wpc->ioend->io_bio, page, len, poff) != len)
+		xfs_chain_bio(wpc->ioend, wbc, bdev, sector);
 
-	wpc->ioend->io_size += bh->b_size;
-	wpc->last_block = bh->b_blocknr;
-	xfs_start_buffer_writeback(bh);
+	wpc->ioend->io_size += len;
 }
 
 STATIC void
@@ -893,7 +887,9 @@ xfs_writepage_map(
 
 		lock_buffer(bh);
 		xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
-		xfs_add_to_ioend(inode, bh, file_offset, wpc, wbc, &submit_list);
+		xfs_add_to_ioend(inode, file_offset, page, wpc, wbc,
+				&submit_list);
+		xfs_start_buffer_writeback(bh);
 		count++;
 	}
 
-- 
2.17.0
