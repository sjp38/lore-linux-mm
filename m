Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDE06B0289
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:18:07 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id h10-v6so4627112ybc.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:18:07 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 186-v6si9545696ybb.447.2018.10.21.09.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:18:06 -0700 (PDT)
Subject: [PATCH 25/28] xfs: support returning partial reflink results
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:17:57 -0700
Message-ID: <154013867727.29026.14417615066515846065.stgit@magnolia>
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

Back when the XFS reflink code only supported clone_file_range, we were
only able to return zero or negative error codes to userspace.  However,
now that copy_file_range (which returns bytes copied) can use XFS'
clone_file_range, we have the opportunity to return partial results.
For example, if userspace sends a 1GB clone request and we run out of
space halfway through, we at least can tell userspace that we completed
512M of that request like a regular write.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_file.c    |    5 +----
 fs/xfs/xfs_reflink.c |   17 ++++++++++++-----
 fs/xfs/xfs_reflink.h |    2 +-
 3 files changed, 14 insertions(+), 10 deletions(-)


diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 38fde4e11714..7d42ab8fe6e1 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -928,14 +928,11 @@ xfs_file_remap_range(
 	loff_t		len,
 	unsigned int	remap_flags)
 {
-	int		ret;
-
 	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
 		return -EINVAL;
 
-	ret = xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
+	return xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
 			len, remap_flags);
-	return ret < 0 ? ret : len;
 }
 
 STATIC int
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index 79dec457f7fb..4abb2aea8f31 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1122,13 +1122,15 @@ xfs_reflink_remap_blocks(
 	loff_t			pos_in,
 	struct xfs_inode	*dest,
 	loff_t			pos_out,
-	loff_t			remap_len)
+	loff_t			remap_len,
+	loff_t			*remapped)
 {
 	struct xfs_bmbt_irec	imap;
 	xfs_fileoff_t		srcoff;
 	xfs_fileoff_t		destoff;
 	xfs_filblks_t		len;
 	xfs_filblks_t		range_len;
+	xfs_filblks_t		remapped_len = 0;
 	xfs_off_t		new_isize = pos_out + remap_len;
 	int			nimaps;
 	int			error = 0;
@@ -1175,10 +1177,13 @@ xfs_reflink_remap_blocks(
 		srcoff += range_len;
 		destoff += range_len;
 		len -= range_len;
+		remapped_len += range_len;
 	}
 
 	if (error)
 		trace_xfs_reflink_remap_blocks_error(dest, error, _RET_IP_);
+	*remapped = min_t(loff_t, remap_len,
+			  XFS_FSB_TO_B(src->i_mount, remapped_len));
 	return error;
 }
 
@@ -1387,7 +1392,7 @@ xfs_reflink_remap_prep(
 /*
  * Link a range of blocks from one file to another.
  */
-int
+loff_t
 xfs_reflink_remap_range(
 	struct file		*file_in,
 	loff_t			pos_in,
@@ -1401,8 +1406,9 @@ xfs_reflink_remap_range(
 	struct inode		*inode_out = file_inode(file_out);
 	struct xfs_inode	*dest = XFS_I(inode_out);
 	struct xfs_mount	*mp = src->i_mount;
+	loff_t			remapped = 0;
 	xfs_extlen_t		cowextsize;
-	ssize_t			ret;
+	int			ret;
 
 	if (!xfs_sb_version_hasreflink(&mp->m_sb))
 		return -EOPNOTSUPP;
@@ -1418,7 +1424,8 @@ xfs_reflink_remap_range(
 
 	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
 
-	ret = xfs_reflink_remap_blocks(src, pos_in, dest, pos_out, len);
+	ret = xfs_reflink_remap_blocks(src, pos_in, dest, pos_out, len,
+			&remapped);
 	if (ret)
 		goto out_unlock;
 
@@ -1441,7 +1448,7 @@ xfs_reflink_remap_range(
 	xfs_reflink_remap_unlock(file_in, file_out);
 	if (ret)
 		trace_xfs_reflink_remap_range_error(dest, ret, _RET_IP_);
-	return ret;
+	return remapped > 0 ? remapped : ret;
 }
 
 /*
diff --git a/fs/xfs/xfs_reflink.h b/fs/xfs/xfs_reflink.h
index c3c46c276fe1..cbc26ff79a8f 100644
--- a/fs/xfs/xfs_reflink.h
+++ b/fs/xfs/xfs_reflink.h
@@ -27,7 +27,7 @@ extern int xfs_reflink_cancel_cow_range(struct xfs_inode *ip, xfs_off_t offset,
 extern int xfs_reflink_end_cow(struct xfs_inode *ip, xfs_off_t offset,
 		xfs_off_t count);
 extern int xfs_reflink_recover_cow(struct xfs_mount *mp);
-extern int xfs_reflink_remap_range(struct file *file_in, loff_t pos_in,
+extern loff_t xfs_reflink_remap_range(struct file *file_in, loff_t pos_in,
 		struct file *file_out, loff_t pos_out, loff_t len,
 		unsigned int remap_flags);
 extern int xfs_reflink_inode_has_shared_extents(struct xfs_trans *tp,
