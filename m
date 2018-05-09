Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD076B0380
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:50:45 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id h32-v6so3306662pld.15
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:50:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h64-v6si21294976pge.206.2018.05.09.00.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:50:44 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 33/33] fs: remove __block_write_begin and iomap_to_bh
Date: Wed,  9 May 2018 09:48:30 +0200
Message-Id: <20180509074830.16196-34-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Now that the iomap buffered write code stopped using bufferheads these
aren't used anymore.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/buffer.c   | 76 ++++-----------------------------------------------
 fs/internal.h |  2 --
 2 files changed, 5 insertions(+), 73 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 71ea9a29e9d5..5cdcaa6230ed 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -22,7 +22,6 @@
 #include <linux/sched/signal.h>
 #include <linux/syscalls.h>
 #include <linux/fs.h>
-#include <linux/iomap.h>
 #include <linux/mm.h>
 #include <linux/percpu.h>
 #include <linux/slab.h>
@@ -1863,62 +1862,8 @@ void page_zero_new_buffers(struct page *page, unsigned from, unsigned to)
 }
 EXPORT_SYMBOL(page_zero_new_buffers);
 
-static void
-iomap_to_bh(struct inode *inode, sector_t block, struct buffer_head *bh,
-		struct iomap *iomap)
-{
-	loff_t offset = block << inode->i_blkbits;
-
-	bh->b_bdev = iomap->bdev;
-
-	/*
-	 * Block points to offset in file we need to map, iomap contains
-	 * the offset at which the map starts. If the map ends before the
-	 * current block, then do not map the buffer and let the caller
-	 * handle it.
-	 */
-	BUG_ON(offset >= iomap->offset + iomap->length);
-
-	switch (iomap->type) {
-	case IOMAP_HOLE:
-		/*
-		 * If the buffer is not up to date or beyond the current EOF,
-		 * we need to mark it as new to ensure sub-block zeroing is
-		 * executed if necessary.
-		 */
-		if (!buffer_uptodate(bh) ||
-		    (offset >= i_size_read(inode)))
-			set_buffer_new(bh);
-		break;
-	case IOMAP_DELALLOC:
-		if (!buffer_uptodate(bh) ||
-		    (offset >= i_size_read(inode)))
-			set_buffer_new(bh);
-		set_buffer_uptodate(bh);
-		set_buffer_mapped(bh);
-		set_buffer_delay(bh);
-		break;
-	case IOMAP_UNWRITTEN:
-		/*
-		 * For unwritten regions, we always need to ensure that
-		 * sub-block writes cause the regions in the block we are not
-		 * writing to are zeroed. Set the buffer as new to ensure this.
-		 */
-		set_buffer_new(bh);
-		set_buffer_unwritten(bh);
-		/* FALLTHRU */
-	case IOMAP_MAPPED:
-		if (offset >= i_size_read(inode))
-			set_buffer_new(bh);
-		bh->b_blocknr = (iomap->addr + offset - iomap->offset) >>
-				inode->i_blkbits;
-		set_buffer_mapped(bh);
-		break;
-	}
-}
-
-int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
-		get_block_t *get_block, struct iomap *iomap)
+int __block_write_begin(struct page *page, loff_t pos, unsigned len,
+		get_block_t *get_block)
 {
 	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + len;
@@ -1954,14 +1899,9 @@ int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
 			clear_buffer_new(bh);
 		if (!buffer_mapped(bh)) {
 			WARN_ON(bh->b_size != blocksize);
-			if (get_block) {
-				err = get_block(inode, block, bh, 1);
-				if (err)
-					break;
-			} else {
-				iomap_to_bh(inode, block, bh, iomap);
-			}
-
+			err = get_block(inode, block, bh, 1);
+			if (err)
+				break;
 			if (buffer_new(bh)) {
 				clean_bdev_bh_alias(bh);
 				if (PageUptodate(page)) {
@@ -2001,12 +1941,6 @@ int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
 		page_zero_new_buffers(page, from, to);
 	return err;
 }
-
-int __block_write_begin(struct page *page, loff_t pos, unsigned len,
-		get_block_t *get_block)
-{
-	return __block_write_begin_int(page, pos, len, get_block, NULL);
-}
 EXPORT_SYMBOL(__block_write_begin);
 
 static int __block_commit_write(struct inode *inode, struct page *page,
diff --git a/fs/internal.h b/fs/internal.h
index b955232d3d49..47764f739075 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -41,8 +41,6 @@ static inline int __sync_blockdev(struct block_device *bdev, int wait)
  * buffer.c
  */
 extern void guard_bio_eod(int rw, struct bio *bio);
-extern int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
-		get_block_t *get_block, struct iomap *iomap);
 int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
 		struct page *page);
 
-- 
2.17.0
