Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 948B46B027F
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:45:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t2-v6so558826pgo.0
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:45:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 2-v6si19258755pfk.287.2018.05.23.07.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:45:16 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 24/34] xfs: remove xfs_reflink_find_cow_mapping
Date: Wed, 23 May 2018 16:43:47 +0200
Message-Id: <20180523144357.18985-25-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

We only have one caller left, and open coding the simple extent list
lookup in it allows us to make the code both more understandable and
reuse calculations and variables already present.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c    | 17 ++++++++++++-----
 fs/xfs/xfs_reflink.c | 30 ------------------------------
 fs/xfs/xfs_reflink.h |  2 --
 fs/xfs/xfs_trace.h   |  1 -
 4 files changed, 12 insertions(+), 38 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index a50f69c2c602..a4b4a7037deb 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -385,6 +385,7 @@ xfs_map_blocks(
 	ssize_t			count = i_blocksize(inode);
 	xfs_fileoff_t		offset_fsb, end_fsb;
 	int			whichfork = XFS_DATA_FORK;
+	struct xfs_iext_cursor	icur;
 	int			error = 0;
 	int			nimaps = 1;
 
@@ -396,8 +397,18 @@ xfs_map_blocks(
 	       (ip->i_df.if_flags & XFS_IFEXTENTS));
 	ASSERT(offset <= mp->m_super->s_maxbytes);
 
+	if (offset > mp->m_super->s_maxbytes - count)
+		count = mp->m_super->s_maxbytes - offset;
+	end_fsb = XFS_B_TO_FSB(mp, (xfs_ufsize_t)offset + count);
+	offset_fsb = XFS_B_TO_FSBT(mp, offset);
+
+	/*
+	 * Check if this is offset is covered by a COW extents, and if yes use
+	 * it directly instead of looking up anything in the data fork.
+	 */
 	if (xfs_is_reflink_inode(ip) &&
-	    xfs_reflink_find_cow_mapping(ip, offset, imap)) {
+	    xfs_iext_lookup_extent(ip, ip->i_cowfp, offset_fsb, &icur, imap) &&
+	    imap->br_startoff <= offset_fsb) {
 		xfs_iunlock(ip, XFS_ILOCK_SHARED);
 		/*
 		 * Truncate can race with writeback since writeback doesn't
@@ -417,10 +428,6 @@ xfs_map_blocks(
 		goto done;
 	}
 
-	if (offset > mp->m_super->s_maxbytes - count)
-		count = mp->m_super->s_maxbytes - offset;
-	end_fsb = XFS_B_TO_FSB(mp, (xfs_ufsize_t)offset + count);
-	offset_fsb = XFS_B_TO_FSBT(mp, offset);
 	error = xfs_bmapi_read(ip, offset_fsb, end_fsb - offset_fsb,
 				imap, &nimaps, XFS_BMAPI_ENTIRE);
 	if (!nimaps) {
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index 713e857d9ffa..8e5eb8e70c89 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -484,36 +484,6 @@ xfs_reflink_allocate_cow(
 	return error;
 }
 
-/*
- * Find the CoW reservation for a given byte offset of a file.
- */
-bool
-xfs_reflink_find_cow_mapping(
-	struct xfs_inode		*ip,
-	xfs_off_t			offset,
-	struct xfs_bmbt_irec		*imap)
-{
-	struct xfs_ifork		*ifp = XFS_IFORK_PTR(ip, XFS_COW_FORK);
-	xfs_fileoff_t			offset_fsb;
-	struct xfs_bmbt_irec		got;
-	struct xfs_iext_cursor		icur;
-
-	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL | XFS_ILOCK_SHARED));
-
-	if (!xfs_is_reflink_inode(ip))
-		return false;
-	offset_fsb = XFS_B_TO_FSBT(ip->i_mount, offset);
-	if (!xfs_iext_lookup_extent(ip, ifp, offset_fsb, &icur, &got))
-		return false;
-	if (got.br_startoff > offset_fsb)
-		return false;
-
-	trace_xfs_reflink_find_cow_mapping(ip, offset, 1, XFS_IO_OVERWRITE,
-			&got);
-	*imap = got;
-	return true;
-}
-
 /*
  * Trim an extent to end at the next CoW reservation past offset_fsb.
  */
diff --git a/fs/xfs/xfs_reflink.h b/fs/xfs/xfs_reflink.h
index 701487bab468..15a456492667 100644
--- a/fs/xfs/xfs_reflink.h
+++ b/fs/xfs/xfs_reflink.h
@@ -32,8 +32,6 @@ extern int xfs_reflink_allocate_cow(struct xfs_inode *ip,
 		struct xfs_bmbt_irec *imap, bool *shared, uint *lockmode);
 extern int xfs_reflink_convert_cow(struct xfs_inode *ip, xfs_off_t offset,
 		xfs_off_t count);
-extern bool xfs_reflink_find_cow_mapping(struct xfs_inode *ip, xfs_off_t offset,
-		struct xfs_bmbt_irec *imap);
 extern void xfs_reflink_trim_irec_to_next_cow(struct xfs_inode *ip,
 		xfs_fileoff_t offset_fsb, struct xfs_bmbt_irec *imap);
 
diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
index 9d4c4ca24fe6..ed8f774944ba 100644
--- a/fs/xfs/xfs_trace.h
+++ b/fs/xfs/xfs_trace.h
@@ -3227,7 +3227,6 @@ DEFINE_INODE_IREC_EVENT(xfs_reflink_convert_cow);
 DEFINE_RW_EVENT(xfs_reflink_reserve_cow);
 
 DEFINE_SIMPLE_IO_EVENT(xfs_reflink_bounce_dio_write);
-DEFINE_IOMAP_EVENT(xfs_reflink_find_cow_mapping);
 DEFINE_INODE_IREC_EVENT(xfs_reflink_trim_irec);
 
 DEFINE_SIMPLE_IO_EVENT(xfs_reflink_cancel_cow_range);
-- 
2.17.0
