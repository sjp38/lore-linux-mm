Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB8236B0283
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:01:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t17-v6so9712269ply.13
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:01:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o7-v6si34415033pfh.103.2018.05.30.03.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 03:00:58 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/18] xfs: remove xfs_reflink_trim_irec_to_next_cow
Date: Wed, 30 May 2018 12:00:04 +0200
Message-Id: <20180530100013.31358-10-hch@lst.de>
In-Reply-To: <20180530100013.31358-1-hch@lst.de>
References: <20180530100013.31358-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

In the only caller we just did a lookup in the COW extent tree for
the same offset.  Reuse that result and save a lookup, as well as
shortening the ilock hold time.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c    | 25 ++++++++++++++++---------
 fs/xfs/xfs_reflink.c | 33 ---------------------------------
 fs/xfs/xfs_reflink.h |  2 --
 3 files changed, 16 insertions(+), 44 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index e2671b223409..587493e9c8a1 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -383,7 +383,7 @@ xfs_map_blocks(
 	struct xfs_inode	*ip = XFS_I(inode);
 	struct xfs_mount	*mp = ip->i_mount;
 	ssize_t			count = i_blocksize(inode);
-	xfs_fileoff_t		offset_fsb, end_fsb;
+	xfs_fileoff_t		offset_fsb, end_fsb, cow_fsb = NULLFILEOFF;
 	int			whichfork = XFS_DATA_FORK;
 	struct xfs_iext_cursor	icur;
 	int			error = 0;
@@ -407,8 +407,9 @@ xfs_map_blocks(
 	 * it directly instead of looking up anything in the data fork.
 	 */
 	if (xfs_is_reflink_inode(ip) &&
-	    xfs_iext_lookup_extent(ip, ip->i_cowfp, offset_fsb, &icur, imap) &&
-	    imap->br_startoff <= offset_fsb) {
+	    xfs_iext_lookup_extent(ip, ip->i_cowfp, offset_fsb, &icur, imap))
+		cow_fsb = imap->br_startoff;
+	if (cow_fsb != NULLFILEOFF && cow_fsb <= offset_fsb) {
 		xfs_iunlock(ip, XFS_ILOCK_SHARED);
 		/*
 		 * Truncate can race with writeback since writeback doesn't
@@ -430,6 +431,10 @@ xfs_map_blocks(
 
 	error = xfs_bmapi_read(ip, offset_fsb, end_fsb - offset_fsb,
 				imap, &nimaps, XFS_BMAPI_ENTIRE);
+	xfs_iunlock(ip, XFS_ILOCK_SHARED);
+	if (error)
+		return error;
+
 	if (!nimaps) {
 		/*
 		 * Lookup returns no match? Beyond eof? regardless,
@@ -454,21 +459,23 @@ xfs_map_blocks(
 		 * is a pending CoW reservation before the end of this extent,
 		 * so that we pick up the COW extents in the next iteration.
 		 */
-		xfs_reflink_trim_irec_to_next_cow(ip, offset_fsb, imap);
+		if (cow_fsb != NULLFILEOFF &&
+		    cow_fsb < imap->br_startoff + imap->br_blockcount) {
+			imap->br_blockcount = cow_fsb - imap->br_startoff;
+			trace_xfs_reflink_trim_irec(ip, imap);
+		}
+
 		if (imap->br_state == XFS_EXT_UNWRITTEN)
 			*type = XFS_IO_UNWRITTEN;
 		else
 			*type = XFS_IO_OVERWRITE;
 	}
-	xfs_iunlock(ip, XFS_ILOCK_SHARED);
 
 	trace_xfs_map_blocks_found(ip, offset, count, *type, imap);
-	return error;
+	return 0;
 
 allocate_blocks:
-	xfs_iunlock(ip, XFS_ILOCK_SHARED);
-	if (!error)
-		error = xfs_iomap_write_allocate(ip, whichfork, offset, imap);
+	error = xfs_iomap_write_allocate(ip, whichfork, offset, imap);
 	if (!error)
 		trace_xfs_map_blocks_alloc(ip, offset, count, *type, imap);
 	return error;
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index 8e5eb8e70c89..ff76bc56ff3d 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -484,39 +484,6 @@ xfs_reflink_allocate_cow(
 	return error;
 }
 
-/*
- * Trim an extent to end at the next CoW reservation past offset_fsb.
- */
-void
-xfs_reflink_trim_irec_to_next_cow(
-	struct xfs_inode		*ip,
-	xfs_fileoff_t			offset_fsb,
-	struct xfs_bmbt_irec		*imap)
-{
-	struct xfs_ifork		*ifp = XFS_IFORK_PTR(ip, XFS_COW_FORK);
-	struct xfs_bmbt_irec		got;
-	struct xfs_iext_cursor		icur;
-
-	if (!xfs_is_reflink_inode(ip))
-		return;
-
-	/* Find the extent in the CoW fork. */
-	if (!xfs_iext_lookup_extent(ip, ifp, offset_fsb, &icur, &got))
-		return;
-
-	/* This is the extent before; try sliding up one. */
-	if (got.br_startoff < offset_fsb) {
-		if (!xfs_iext_next_extent(ifp, &icur, &got))
-			return;
-	}
-
-	if (got.br_startoff >= imap->br_startoff + imap->br_blockcount)
-		return;
-
-	imap->br_blockcount = got.br_startoff - imap->br_startoff;
-	trace_xfs_reflink_trim_irec(ip, imap);
-}
-
 /*
  * Cancel CoW reservations for some block range of an inode.
  *
diff --git a/fs/xfs/xfs_reflink.h b/fs/xfs/xfs_reflink.h
index 15a456492667..e8d4d50c629f 100644
--- a/fs/xfs/xfs_reflink.h
+++ b/fs/xfs/xfs_reflink.h
@@ -32,8 +32,6 @@ extern int xfs_reflink_allocate_cow(struct xfs_inode *ip,
 		struct xfs_bmbt_irec *imap, bool *shared, uint *lockmode);
 extern int xfs_reflink_convert_cow(struct xfs_inode *ip, xfs_off_t offset,
 		xfs_off_t count);
-extern void xfs_reflink_trim_irec_to_next_cow(struct xfs_inode *ip,
-		xfs_fileoff_t offset_fsb, struct xfs_bmbt_irec *imap);
 
 extern int xfs_reflink_cancel_cow_blocks(struct xfs_inode *ip,
 		struct xfs_trans **tpp, xfs_fileoff_t offset_fsb,
-- 
2.17.0
