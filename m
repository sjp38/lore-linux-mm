Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF8E6B000D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:10:58 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e15-v6so3229494pfi.5
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:10:58 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id e8-v6si22985957pgh.447.2018.10.09.17.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:10:57 -0700 (PDT)
Subject: [PATCH 02/25] xfs: refactor clonerange preparation into a separate
 helper
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Tue, 09 Oct 2018 17:10:52 -0700
Message-ID: <153913025230.32295.8365539801924505278.stgit@magnolia>
In-Reply-To: <153913023835.32295.13962696655740190941.stgit@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Refactor all the reflink preparation steps into a separate helper that
we'll use to land all the upcoming fixes for insufficient input checks.

This rework also moves the invalidation of the destination range to the
prep function so that it is done before the range is remapped.  This
ensures that nobody can access the data in range being remapped until
the remap is complete.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_reflink.c |  101 +++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 74 insertions(+), 27 deletions(-)


diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index 5289e22cb081..ebd65d3e31f3 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1220,35 +1220,48 @@ xfs_iolock_two_inodes_and_break_layout(
 	return 0;
 }
 
+/* Unlock both inodes after they've been prepped for a range clone. */
+STATIC void
+xfs_reflink_remap_unlock(
+	struct file		*file_in,
+	struct file		*file_out)
+{
+	struct inode		*inode_in = file_inode(file_in);
+	struct xfs_inode	*src = XFS_I(inode_in);
+	struct inode		*inode_out = file_inode(file_out);
+	struct xfs_inode	*dest = XFS_I(inode_out);
+	bool			same_inode = (inode_in == inode_out);
+
+	xfs_iunlock(dest, XFS_MMAPLOCK_EXCL);
+	if (!same_inode)
+		xfs_iunlock(src, XFS_MMAPLOCK_SHARED);
+	inode_unlock(inode_out);
+	if (!same_inode)
+		inode_unlock_shared(inode_in);
+}
+
 /*
- * Link a range of blocks from one file to another.
+ * Prepare two files for range cloning.  Upon a successful return both inodes
+ * will have the iolock and mmaplock held, the page cache of the out file
+ * will be truncated, and any leases on the out file will have been broken.
+ * Returns negative for error, 0 for nothing to do, and 1 for success.
  */
-int
-xfs_reflink_remap_range(
+STATIC int
+xfs_reflink_remap_prep(
 	struct file		*file_in,
 	loff_t			pos_in,
 	struct file		*file_out,
 	loff_t			pos_out,
-	u64			len,
+	u64			*len,
 	bool			is_dedupe)
 {
 	struct inode		*inode_in = file_inode(file_in);
 	struct xfs_inode	*src = XFS_I(inode_in);
 	struct inode		*inode_out = file_inode(file_out);
 	struct xfs_inode	*dest = XFS_I(inode_out);
-	struct xfs_mount	*mp = src->i_mount;
 	bool			same_inode = (inode_in == inode_out);
-	xfs_fileoff_t		sfsbno, dfsbno;
-	xfs_filblks_t		fsblen;
-	xfs_extlen_t		cowextsize;
 	ssize_t			ret;
 
-	if (!xfs_sb_version_hasreflink(&mp->m_sb))
-		return -EOPNOTSUPP;
-
-	if (XFS_FORCED_SHUTDOWN(mp))
-		return -EIO;
-
 	/* Lock both files against IO */
 	ret = xfs_iolock_two_inodes_and_break_layout(inode_in, inode_out);
 	if (ret)
@@ -1270,7 +1283,7 @@ xfs_reflink_remap_range(
 		goto out_unlock;
 
 	ret = vfs_clone_file_prep_inodes(inode_in, pos_in, inode_out, pos_out,
-			&len, is_dedupe);
+			len, is_dedupe);
 	if (ret <= 0)
 		goto out_unlock;
 
@@ -1279,8 +1292,6 @@ xfs_reflink_remap_range(
 	if (ret)
 		goto out_unlock;
 
-	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
-
 	/*
 	 * Clear out post-eof preallocations because we don't have page cache
 	 * backing the delayed allocations and they'll never get freed on
@@ -1297,6 +1308,51 @@ xfs_reflink_remap_range(
 	if (ret)
 		goto out_unlock;
 
+	/* Zap any page cache for the destination file's range. */
+	truncate_inode_pages_range(&inode_out->i_data, pos_out,
+				   PAGE_ALIGN(pos_out + *len) - 1);
+	return 1;
+out_unlock:
+	xfs_reflink_remap_unlock(file_in, file_out);
+	return ret;
+}
+
+/*
+ * Link a range of blocks from one file to another.
+ */
+int
+xfs_reflink_remap_range(
+	struct file		*file_in,
+	loff_t			pos_in,
+	struct file		*file_out,
+	loff_t			pos_out,
+	u64			len,
+	bool			is_dedupe)
+{
+	struct inode		*inode_in = file_inode(file_in);
+	struct xfs_inode	*src = XFS_I(inode_in);
+	struct inode		*inode_out = file_inode(file_out);
+	struct xfs_inode	*dest = XFS_I(inode_out);
+	struct xfs_mount	*mp = src->i_mount;
+	xfs_fileoff_t		sfsbno, dfsbno;
+	xfs_filblks_t		fsblen;
+	xfs_extlen_t		cowextsize;
+	ssize_t			ret;
+
+	if (!xfs_sb_version_hasreflink(&mp->m_sb))
+		return -EOPNOTSUPP;
+
+	if (XFS_FORCED_SHUTDOWN(mp))
+		return -EIO;
+
+	/* Prepare and then clone file data. */
+	ret = xfs_reflink_remap_prep(file_in, pos_in, file_out, pos_out,
+			&len, is_dedupe);
+	if (ret <= 0)
+		return ret;
+
+	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
+
 	dfsbno = XFS_B_TO_FSBT(mp, pos_out);
 	sfsbno = XFS_B_TO_FSBT(mp, pos_in);
 	fsblen = XFS_B_TO_FSB(mp, len);
@@ -1305,10 +1361,6 @@ xfs_reflink_remap_range(
 	if (ret)
 		goto out_unlock;
 
-	/* Zap any page cache for the destination file's range. */
-	truncate_inode_pages_range(&inode_out->i_data, pos_out,
-				   PAGE_ALIGN(pos_out + len) - 1);
-
 	/*
 	 * Carry the cowextsize hint from src to dest if we're sharing the
 	 * entire source file to the entire destination file, the source file
@@ -1325,12 +1377,7 @@ xfs_reflink_remap_range(
 			is_dedupe);
 
 out_unlock:
-	xfs_iunlock(dest, XFS_MMAPLOCK_EXCL);
-	if (!same_inode)
-		xfs_iunlock(src, XFS_MMAPLOCK_SHARED);
-	inode_unlock(inode_out);
-	if (!same_inode)
-		inode_unlock_shared(inode_in);
+	xfs_reflink_remap_unlock(file_in, file_out);
 	if (ret)
 		trace_xfs_reflink_remap_range_error(dest, ret, _RET_IP_);
 	return ret;
