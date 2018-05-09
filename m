Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 558E16B036D
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:50:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x23so18346981pfm.7
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:50:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a71-v6si21092589pge.159.2018.05.09.00.50.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:50:18 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 25/33] xfs: move all writeback buffer_head manipulation into xfs_map_at_offset
Date: Wed,  9 May 2018 09:48:22 +0200
Message-Id: <20180509074830.16196-26-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

This keeps it in a single place so it can be made otional more easily.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 22 +++++-----------------
 1 file changed, 5 insertions(+), 17 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index f6d28e6aa911..c76c943473be 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -505,21 +505,6 @@ xfs_imap_valid(
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
@@ -728,6 +713,7 @@ xfs_map_at_offset(
 	ASSERT(imap->br_startblock != HOLESTARTBLOCK);
 	ASSERT(imap->br_startblock != DELAYSTARTBLOCK);
 
+	lock_buffer(bh);
 	xfs_map_buffer(inode, bh, imap, offset);
 	set_buffer_mapped(bh);
 	clear_buffer_delay(bh);
@@ -740,6 +726,10 @@ xfs_map_at_offset(
 	 * set the bdev now.
 	 */
 	bh->b_bdev = xfs_find_bdev_for_inode(inode);
+	bh->b_end_io = NULL;
+	set_buffer_async_write(bh);
+	set_buffer_uptodate(bh);
+	clear_buffer_dirty(bh);
 }
 
 STATIC void
@@ -885,11 +875,9 @@ xfs_writepage_map(
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
