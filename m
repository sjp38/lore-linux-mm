Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFE9E6B0368
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:50:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r63so23962158pfl.12
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:50:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f91-v6si26560397plf.23.2018.05.09.00.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:50:10 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 23/33] xfs: remove the imap_valid flag
Date: Wed,  9 May 2018 09:48:20 +0200
Message-Id: <20180509074830.16196-24-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Simplify the way we check for a valid imap - we know we have a valid
mapping after xfs_map_blocks returned successfully, and we know we can
call xfs_imap_valid on any imap, as it will always fail on a
zero-initialized map.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 5da2e99b0559..7ebd686cb723 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -42,7 +42,6 @@
  */
 struct xfs_writepage_ctx {
 	struct xfs_bmbt_irec    imap;
-	bool			imap_valid;
 	unsigned int		io_type;
 	struct xfs_ioend	*ioend;
 	sector_t		last_block;
@@ -868,10 +867,6 @@ xfs_writepage_map(
 			continue;
 		}
 
-		/* Check to see if current map spans this file offset */
-		if (wpc->imap_valid)
-			wpc->imap_valid = xfs_imap_valid(inode, &wpc->imap,
-							 file_offset);
 		/*
 		 * If we don't have a valid map, now it's time to get a new one
 		 * for this offset.  This will convert delayed allocations
@@ -879,16 +874,14 @@ xfs_writepage_map(
 		 * a valid map, it means we landed in a hole and we skip the
 		 * block.
 		 */
-		if (!wpc->imap_valid) {
+		if (!xfs_imap_valid(inode, &wpc->imap, file_offset)) {
 			error = xfs_map_blocks(inode, file_offset, &wpc->imap,
 					     &wpc->io_type);
 			if (error)
 				goto out;
-			wpc->imap_valid = xfs_imap_valid(inode, &wpc->imap,
-							 file_offset);
 		}
 
-		if (!wpc->imap_valid || wpc->io_type == XFS_IO_HOLE) {
+		if (wpc->io_type == XFS_IO_HOLE) {
 			/*
 			 * set_page_dirty dirties all buffers in a page, independent
 			 * of their state.  The dirty state however is entirely
-- 
2.17.0
