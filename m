Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 721C66B028D
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:01:20 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w6-v6so9079648plp.14
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:01:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 3-v6si35304391plf.84.2018.05.30.03.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 03:01:19 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 14/18] xfs: move all writeback buffer_head manipulation into xfs_map_at_offset
Date: Wed, 30 May 2018 12:00:09 +0200
Message-Id: <20180530100013.31358-15-hch@lst.de>
In-Reply-To: <20180530100013.31358-1-hch@lst.de>
References: <20180530100013.31358-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This keeps it in a single place so it can be made otional more easily.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 22 +++++-----------------
 1 file changed, 5 insertions(+), 17 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 7d02d04d5a5b..025f2acac100 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -495,21 +495,6 @@ xfs_imap_valid(
 		offset < imap->br_startoff + imap->br_blockcount;
 }
 
-STATIC void
-xfs_start_buffer_writeback(
-	struct buffer_head	*bh)
-{
-	ASSERT(buffer_mapped(bh));
-	ASSERT(buffer_locked(bh));
-	ASSERT(!buffer_delay(bh));
-	ASSERT(!buffer_unwritten(bh));
-
-	bh->b_end_io = NULL;
-	set_buffer_async_write(bh);
-	set_buffer_uptodate(bh);
-	clear_buffer_dirty(bh);
-}
-
 STATIC void
 xfs_start_page_writeback(
 	struct page		*page,
@@ -718,6 +703,7 @@ xfs_map_at_offset(
 	ASSERT(imap->br_startblock != HOLESTARTBLOCK);
 	ASSERT(imap->br_startblock != DELAYSTARTBLOCK);
 
+	lock_buffer(bh);
 	xfs_map_buffer(inode, bh, imap, offset);
 	set_buffer_mapped(bh);
 	clear_buffer_delay(bh);
@@ -730,6 +716,10 @@ xfs_map_at_offset(
 	 * set the bdev now.
 	 */
 	bh->b_bdev = xfs_find_bdev_for_inode(inode);
+	bh->b_end_io = NULL;
+	set_buffer_async_write(bh);
+	set_buffer_uptodate(bh);
+	clear_buffer_dirty(bh);
 }
 
 STATIC void
@@ -875,11 +865,9 @@ xfs_writepage_map(
 			continue;
 		}
 
-		lock_buffer(bh);
 		xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
 		xfs_add_to_ioend(inode, file_offset, page, wpc, wbc,
 				&submit_list);
-		xfs_start_buffer_writeback(bh);
 		count++;
 	}
 
-- 
2.17.0
