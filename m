Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0C96B028D
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:18:20 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id u42-v6so23375886ybi.3
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:18:20 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 63-v6si11130969ybm.25.2018.10.21.09.18.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:18:19 -0700 (PDT)
Subject: [PATCH 27/28] xfs: remove xfs_reflink_remap_range
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:18:11 -0700
Message-ID: <154013869100.29026.7543087084546497731.stgit@magnolia>
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

Since xfs_file_remap_range is a thin wrapper, move the contents of
xfs_reflink_remap_range into the shell.  This cuts down on the vfs
calls being made from internal xfs code.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_file.c    |   65 ++++++++++++++++++++++++++++++++++++++++------
 fs/xfs/xfs_reflink.c |   70 +++-----------------------------------------------
 fs/xfs/xfs_reflink.h |   10 +++++++
 3 files changed, 70 insertions(+), 75 deletions(-)


diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 7d42ab8fe6e1..53c9ab8fb777 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -919,20 +919,67 @@ xfs_file_fallocate(
 	return error;
 }
 
-STATIC loff_t
+
+loff_t
 xfs_file_remap_range(
-	struct file	*file_in,
-	loff_t		pos_in,
-	struct file	*file_out,
-	loff_t		pos_out,
-	loff_t		len,
-	unsigned int	remap_flags)
+	struct file		*file_in,
+	loff_t			pos_in,
+	struct file		*file_out,
+	loff_t			pos_out,
+	loff_t			len,
+	unsigned int		remap_flags)
 {
+	struct inode		*inode_in = file_inode(file_in);
+	struct xfs_inode	*src = XFS_I(inode_in);
+	struct inode		*inode_out = file_inode(file_out);
+	struct xfs_inode	*dest = XFS_I(inode_out);
+	struct xfs_mount	*mp = src->i_mount;
+	loff_t			remapped = 0;
+	xfs_extlen_t		cowextsize;
+	int			ret;
+
 	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
 		return -EINVAL;
 
-	return xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-			len, remap_flags);
+	if (!xfs_sb_version_hasreflink(&mp->m_sb))
+		return -EOPNOTSUPP;
+
+	if (XFS_FORCED_SHUTDOWN(mp))
+		return -EIO;
+
+	/* Prepare and then clone file data. */
+	ret = xfs_reflink_remap_prep(file_in, pos_in, file_out, pos_out,
+			&len, remap_flags);
+	if (ret < 0 || len == 0)
+		return ret;
+
+	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
+
+	ret = xfs_reflink_remap_blocks(src, pos_in, dest, pos_out, len,
+			&remapped);
+	if (ret)
+		goto out_unlock;
+
+	/*
+	 * Carry the cowextsize hint from src to dest if we're sharing the
+	 * entire source file to the entire destination file, the source file
+	 * has a cowextsize hint, and the destination file does not.
+	 */
+	cowextsize = 0;
+	if (pos_in == 0 && len == i_size_read(inode_in) &&
+	    (src->i_d.di_flags2 & XFS_DIFLAG2_COWEXTSIZE) &&
+	    pos_out == 0 && len >= i_size_read(inode_out) &&
+	    !(dest->i_d.di_flags2 & XFS_DIFLAG2_COWEXTSIZE))
+		cowextsize = src->i_d.di_cowextsize;
+
+	ret = xfs_reflink_update_dest(dest, pos_out + len, cowextsize,
+			remap_flags);
+
+out_unlock:
+	xfs_reflink_remap_unlock(file_in, file_out);
+	if (ret)
+		trace_xfs_reflink_remap_range_error(dest, ret, _RET_IP_);
+	return remapped > 0 ? remapped : ret;
 }
 
 STATIC int
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index bccc66316cc4..84f372f7ea04 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -916,7 +916,7 @@ xfs_reflink_set_inode_flag(
 /*
  * Update destination inode size & cowextsize hint, if necessary.
  */
-STATIC int
+int
 xfs_reflink_update_dest(
 	struct xfs_inode	*dest,
 	xfs_off_t		newlen,
@@ -1116,7 +1116,7 @@ xfs_reflink_remap_extent(
 /*
  * Iteratively remap one file's extents (and holes) to another's.
  */
-STATIC int
+int
 xfs_reflink_remap_blocks(
 	struct xfs_inode	*src,
 	loff_t			pos_in,
@@ -1232,7 +1232,7 @@ xfs_iolock_two_inodes_and_break_layout(
 }
 
 /* Unlock both inodes after they've been prepped for a range clone. */
-STATIC void
+void
 xfs_reflink_remap_unlock(
 	struct file		*file_in,
 	struct file		*file_out)
@@ -1300,7 +1300,7 @@ xfs_reflink_zero_posteof(
  * stale data in the destination file. Hence we reject these clone attempts with
  * -EINVAL in this case.
  */
-STATIC int
+int
 xfs_reflink_remap_prep(
 	struct file		*file_in,
 	loff_t			pos_in,
@@ -1370,68 +1370,6 @@ xfs_reflink_remap_prep(
 	return ret;
 }
 
-/*
- * Link a range of blocks from one file to another.
- */
-loff_t
-xfs_reflink_remap_range(
-	struct file		*file_in,
-	loff_t			pos_in,
-	struct file		*file_out,
-	loff_t			pos_out,
-	loff_t			len,
-	unsigned int		remap_flags)
-{
-	struct inode		*inode_in = file_inode(file_in);
-	struct xfs_inode	*src = XFS_I(inode_in);
-	struct inode		*inode_out = file_inode(file_out);
-	struct xfs_inode	*dest = XFS_I(inode_out);
-	struct xfs_mount	*mp = src->i_mount;
-	loff_t			remapped = 0;
-	xfs_extlen_t		cowextsize;
-	int			ret;
-
-	if (!xfs_sb_version_hasreflink(&mp->m_sb))
-		return -EOPNOTSUPP;
-
-	if (XFS_FORCED_SHUTDOWN(mp))
-		return -EIO;
-
-	/* Prepare and then clone file data. */
-	ret = xfs_reflink_remap_prep(file_in, pos_in, file_out, pos_out,
-			&len, remap_flags);
-	if (ret < 0 || len == 0)
-		return ret;
-
-	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
-
-	ret = xfs_reflink_remap_blocks(src, pos_in, dest, pos_out, len,
-			&remapped);
-	if (ret)
-		goto out_unlock;
-
-	/*
-	 * Carry the cowextsize hint from src to dest if we're sharing the
-	 * entire source file to the entire destination file, the source file
-	 * has a cowextsize hint, and the destination file does not.
-	 */
-	cowextsize = 0;
-	if (pos_in == 0 && len == i_size_read(inode_in) &&
-	    (src->i_d.di_flags2 & XFS_DIFLAG2_COWEXTSIZE) &&
-	    pos_out == 0 && len >= i_size_read(inode_out) &&
-	    !(dest->i_d.di_flags2 & XFS_DIFLAG2_COWEXTSIZE))
-		cowextsize = src->i_d.di_cowextsize;
-
-	ret = xfs_reflink_update_dest(dest, pos_out + len, cowextsize,
-			remap_flags);
-
-out_unlock:
-	xfs_reflink_remap_unlock(file_in, file_out);
-	if (ret)
-		trace_xfs_reflink_remap_range_error(dest, ret, _RET_IP_);
-	return remapped > 0 ? remapped : ret;
-}
-
 /*
  * The user wants to preemptively CoW all shared blocks in this file,
  * which enables us to turn off the reflink flag.  Iterate all
diff --git a/fs/xfs/xfs_reflink.h b/fs/xfs/xfs_reflink.h
index cbc26ff79a8f..28a84edda889 100644
--- a/fs/xfs/xfs_reflink.h
+++ b/fs/xfs/xfs_reflink.h
@@ -36,5 +36,15 @@ extern int xfs_reflink_clear_inode_flag(struct xfs_inode *ip,
 		struct xfs_trans **tpp);
 extern int xfs_reflink_unshare(struct xfs_inode *ip, xfs_off_t offset,
 		xfs_off_t len);
+extern int xfs_reflink_remap_prep(struct file *file_in, loff_t pos_in,
+		struct file *file_out, loff_t pos_out, loff_t *len,
+		unsigned int remap_flags);
+extern int xfs_reflink_remap_blocks(struct xfs_inode *src, loff_t pos_in,
+		struct xfs_inode *dest, loff_t pos_out, loff_t remap_len,
+		loff_t *remapped);
+extern int xfs_reflink_update_dest(struct xfs_inode *dest, xfs_off_t newlen,
+		xfs_extlen_t cowextsize, unsigned int remap_flags);
+extern void xfs_reflink_remap_unlock(struct file *file_in,
+		struct file *file_out);
 
 #endif /* __XFS_REFLINK_H */
