Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81DB86B0363
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:49:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x23so18346509pfm.7
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:49:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a23-v6si18078981pls.571.2018.05.09.00.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:49:57 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 21/33] xfs: simplify xfs_map_blocks by using xfs_iext_lookup_extent directly
Date: Wed,  9 May 2018 09:48:18 +0200
Message-Id: <20180509074830.16196-22-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

xfs_bmapi_read adds zero value in xfs_map_blocks.  Replace it with a
direct call to the low-level extent lookup function.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 09fb10be1256..07d5255a0f9f 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -387,7 +387,6 @@ xfs_map_blocks(
 	int			whichfork = XFS_DATA_FORK;
 	struct xfs_iext_cursor	icur;
 	int			error = 0;
-	int			nimaps = 1;
 	bool			cow_valid = false;
 
 	if (XFS_FORCED_SHUTDOWN(mp))
@@ -432,24 +431,16 @@ xfs_map_blocks(
 		goto done;
 	}
 
-	error = xfs_bmapi_read(ip, offset_fsb, end_fsb - offset_fsb,
-				imap, &nimaps, XFS_BMAPI_ENTIRE);
+	if (!xfs_iext_lookup_extent(ip, &ip->i_df, offset_fsb, &icur, imap))
+		imap->br_startoff = end_fsb;	/* fake a hole past EOF */
 	xfs_iunlock(ip, XFS_ILOCK_SHARED);
-	if (error)
-		return error;
 
-	if (!nimaps) {
-		/*
-		 * Lookup returns no match? Beyond eof? regardless,
-		 * return it as a hole so we don't write it
-		 */
+	if (imap->br_startoff > offset_fsb) {
+		/* landed in a hole or beyond EOF */
+		imap->br_blockcount = imap->br_startoff - offset_fsb;
 		imap->br_startoff = offset_fsb;
-		imap->br_blockcount = end_fsb - offset_fsb;
 		imap->br_startblock = HOLESTARTBLOCK;
 		*type = XFS_IO_HOLE;
-	} else if (imap->br_startblock == HOLESTARTBLOCK) {
-		/* landed in a hole */
-		*type = XFS_IO_HOLE;
 	} else if (isnullstartblock(imap->br_startblock)) {
 		/* got a delalloc extent */
 		*type = XFS_IO_DELALLOC;
-- 
2.17.0
