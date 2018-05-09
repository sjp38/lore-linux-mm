Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB6D86B0355
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:49:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e16so1029056pfn.5
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:49:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i6-v6si20717035pgs.637.2018.05.09.00.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:49:23 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 14/33] xfs: simplify xfs_bmap_punch_delalloc_range
Date: Wed,  9 May 2018 09:48:11 +0200
Message-Id: <20180509074830.16196-15-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Instead of using xfs_bmapi_read to find delalloc extents and then punch
them out using xfs_bunmapi, opencode the loop to iterate over the extents
and call xfs_bmap_del_extent_delay directly.  This both simplifies the
code and reduces the number of extent tree lookups required.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_bmap_util.c | 78 ++++++++++++++----------------------------
 1 file changed, 25 insertions(+), 53 deletions(-)

diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index 8cd8c412f52d..7d2ba4cc8fba 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -695,12 +695,10 @@ xfs_getbmap(
 }
 
 /*
- * dead simple method of punching delalyed allocation blocks from a range in
- * the inode. Walks a block at a time so will be slow, but is only executed in
- * rare error cases so the overhead is not critical. This will always punch out
- * both the start and end blocks, even if the ranges only partially overlap
- * them, so it is up to the caller to ensure that partial blocks are not
- * passed in.
+ * Dead simple method of punching delalyed allocation blocks from a range in
+ * the inode.  This will always punch out both the start and end blocks, even
+ * if the ranges only partially overlap them, so it is up to the caller to
+ * ensure that partial blocks are not passed in.
  */
 int
 xfs_bmap_punch_delalloc_range(
@@ -708,63 +706,37 @@ xfs_bmap_punch_delalloc_range(
 	xfs_fileoff_t		start_fsb,
 	xfs_fileoff_t		length)
 {
-	xfs_fileoff_t		remaining = length;
+	struct xfs_ifork	*ifp = &ip->i_df;
+	struct xfs_bmbt_irec	got, del;
+	struct xfs_iext_cursor	icur;
 	int			error = 0;
 
 	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
 
-	do {
-		int		done;
-		xfs_bmbt_irec_t	imap;
-		int		nimaps = 1;
-		xfs_fsblock_t	firstblock;
-		struct xfs_defer_ops dfops;
+	if (!(ifp->if_flags & XFS_IFEXTENTS)) {
+		error = xfs_iread_extents(NULL, ip, XFS_DATA_FORK);
+		if (error)
+			return error;
+	}
 
-		/*
-		 * Map the range first and check that it is a delalloc extent
-		 * before trying to unmap the range. Otherwise we will be
-		 * trying to remove a real extent (which requires a
-		 * transaction) or a hole, which is probably a bad idea...
-		 */
-		error = xfs_bmapi_read(ip, start_fsb, 1, &imap, &nimaps,
-				       XFS_BMAPI_ENTIRE);
+	if (!xfs_iext_lookup_extent(ip, ifp, start_fsb, &icur, &got))
+		return 0;
 
-		if (error) {
-			/* something screwed, just bail */
-			if (!XFS_FORCED_SHUTDOWN(ip->i_mount)) {
-				xfs_alert(ip->i_mount,
-			"Failed delalloc mapping lookup ino %lld fsb %lld.",
-						ip->i_ino, start_fsb);
-			}
+	do {
+		if (got.br_startoff >= start_fsb + length)
 			break;
-		}
-		if (!nimaps) {
-			/* nothing there */
-			goto next_block;
-		}
-		if (imap.br_startblock != DELAYSTARTBLOCK) {
-			/* been converted, ignore */
-			goto next_block;
-		}
-		WARN_ON(imap.br_blockcount == 0);
+		if (!isnullstartblock(got.br_startblock))
+			continue;
 
-		/*
-		 * Note: while we initialise the firstblock/dfops pair, they
-		 * should never be used because blocks should never be
-		 * allocated or freed for a delalloc extent and hence we need
-		 * don't cancel or finish them after the xfs_bunmapi() call.
-		 */
-		xfs_defer_init(&dfops, &firstblock);
-		error = xfs_bunmapi(NULL, ip, start_fsb, 1, 0, 1, &firstblock,
-					&dfops, &done);
+		del = got;
+		xfs_trim_extent(&del, start_fsb, length);
+		error = xfs_bmap_del_extent_delay(ip, XFS_DATA_FORK, &icur,
+				&got, &del);
 		if (error)
 			break;
-
-		ASSERT(!xfs_defer_has_unfinished_work(&dfops));
-next_block:
-		start_fsb++;
-		remaining--;
-	} while(remaining > 0);
+		if (!xfs_iext_get_extent(ifp, &icur, &got))
+			break;
+	} while (xfs_iext_next_extent(ifp, &icur, &got));
 
 	return error;
 }
-- 
2.17.0
