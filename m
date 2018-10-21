Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC6AD6B0287
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:17:55 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id n205-v6so25616424ywc.16
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:17:55 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 204-v6si603985ywf.99.2018.10.21.09.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:17:54 -0700 (PDT)
Subject: [PATCH 24/28] xfs: clean up xfs_reflink_remap_blocks call site
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:17:50 -0700
Message-ID: <154013867045.29026.12266020817835171751.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Move the offset <-> blocks unit conversions into
xfs_reflink_remap_blocks to make the call site less ugly.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_reflink.c |   37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)


diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index e8e86646bb4b..79dec457f7fb 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1119,16 +1119,23 @@ xfs_reflink_remap_extent(
 STATIC int
 xfs_reflink_remap_blocks(
 	struct xfs_inode	*src,
-	xfs_fileoff_t		srcoff,
+	loff_t			pos_in,
 	struct xfs_inode	*dest,
-	xfs_fileoff_t		destoff,
-	xfs_filblks_t		len,
-	xfs_off_t		new_isize)
+	loff_t			pos_out,
+	loff_t			remap_len)
 {
 	struct xfs_bmbt_irec	imap;
+	xfs_fileoff_t		srcoff;
+	xfs_fileoff_t		destoff;
+	xfs_filblks_t		len;
+	xfs_filblks_t		range_len;
+	xfs_off_t		new_isize = pos_out + remap_len;
 	int			nimaps;
 	int			error = 0;
-	xfs_filblks_t		range_len;
+
+	destoff = XFS_B_TO_FSBT(src->i_mount, pos_out);
+	srcoff = XFS_B_TO_FSBT(src->i_mount, pos_in);
+	len = XFS_B_TO_FSB(src->i_mount, remap_len);
 
 	/* drange = (destoff, destoff + len); srange = (srcoff, srcoff + len) */
 	while (len) {
@@ -1143,7 +1150,7 @@ xfs_reflink_remap_blocks(
 		error = xfs_bmapi_read(src, srcoff, len, &imap, &nimaps, 0);
 		xfs_iunlock(src, lock_mode);
 		if (error)
-			goto err;
+			break;
 		ASSERT(nimaps == 1);
 
 		trace_xfs_reflink_remap_imap(src, srcoff, len, XFS_IO_OVERWRITE,
@@ -1157,11 +1164,11 @@ xfs_reflink_remap_blocks(
 		error = xfs_reflink_remap_extent(dest, &imap, destoff,
 				new_isize);
 		if (error)
-			goto err;
+			break;
 
 		if (fatal_signal_pending(current)) {
 			error = -EINTR;
-			goto err;
+			break;
 		}
 
 		/* Advance drange/srange */
@@ -1170,10 +1177,8 @@ xfs_reflink_remap_blocks(
 		len -= range_len;
 	}
 
-	return 0;
-
-err:
-	trace_xfs_reflink_remap_blocks_error(dest, error, _RET_IP_);
+	if (error)
+		trace_xfs_reflink_remap_blocks_error(dest, error, _RET_IP_);
 	return error;
 }
 
@@ -1396,8 +1401,6 @@ xfs_reflink_remap_range(
 	struct inode		*inode_out = file_inode(file_out);
 	struct xfs_inode	*dest = XFS_I(inode_out);
 	struct xfs_mount	*mp = src->i_mount;
-	xfs_fileoff_t		sfsbno, dfsbno;
-	xfs_filblks_t		fsblen;
 	xfs_extlen_t		cowextsize;
 	ssize_t			ret;
 
@@ -1415,11 +1418,7 @@ xfs_reflink_remap_range(
 
 	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
 
-	dfsbno = XFS_B_TO_FSBT(mp, pos_out);
-	sfsbno = XFS_B_TO_FSBT(mp, pos_in);
-	fsblen = XFS_B_TO_FSB(mp, len);
-	ret = xfs_reflink_remap_blocks(src, sfsbno, dest, dfsbno, fsblen,
-			pos_out + len);
+	ret = xfs_reflink_remap_blocks(src, pos_in, dest, pos_out, len);
 	if (ret)
 		goto out_unlock;
 
