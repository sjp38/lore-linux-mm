Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9ADF6B0299
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 00:15:30 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d200-v6so6969350qkc.22
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:15:30 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w198-v6si12864052qkb.168.2018.10.10.21.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 21:15:29 -0700 (PDT)
Subject: [PATCH 24/25] xfs: support returning partial reflink results
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 10 Oct 2018 21:15:19 -0700
Message-ID: <153923131946.5546.5209673711907751253.stgit@magnolia>
In-Reply-To: <153923113649.5546.9840926895953408273.stgit@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
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
 fs/xfs/xfs_reflink.c |   19 ++++++++++++++-----
 fs/xfs/xfs_reflink.h |    2 +-
 3 files changed, 16 insertions(+), 10 deletions(-)


diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index bc9e94bcb7a3..b2b15b8dc4a1 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -928,14 +928,11 @@ xfs_file_remap_range(
 	loff_t		len,
 	unsigned int	remap_flags)
 {
-	int		ret;
-
 	if (!remap_check_flags(remap_flags, RFR_SAME_DATA))
 		return -EINVAL;
 
-	ret = xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
+	return xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
 			len, remap_flags);
-	return ret < 0 ? ret : len;
 }
 
 STATIC int
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index e1592e751cc2..12a1fe92454e 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1123,6 +1123,7 @@ xfs_reflink_remap_blocks(
 	struct xfs_inode	*dest,
 	xfs_fileoff_t		destoff,
 	xfs_filblks_t		len,
+	xfs_filblks_t		*remapped,
 	xfs_off_t		new_isize)
 {
 	struct xfs_bmbt_irec	imap;
@@ -1130,6 +1131,7 @@ xfs_reflink_remap_blocks(
 	int			error = 0;
 	xfs_filblks_t		range_len;
 
+	*remapped = 0;
 	/* drange = (destoff, destoff + len); srange = (srcoff, srcoff + len) */
 	while (len) {
 		uint		lock_mode;
@@ -1168,6 +1170,7 @@ xfs_reflink_remap_blocks(
 		srcoff += range_len;
 		destoff += range_len;
 		len -= range_len;
+		*remapped += range_len;
 	}
 
 	return 0;
@@ -1391,7 +1394,7 @@ xfs_reflink_remap_prep(
 /*
  * Link a range of blocks from one file to another.
  */
-int
+loff_t
 xfs_reflink_remap_range(
 	struct file		*file_in,
 	loff_t			pos_in,
@@ -1406,9 +1409,9 @@ xfs_reflink_remap_range(
 	struct xfs_inode	*dest = XFS_I(inode_out);
 	struct xfs_mount	*mp = src->i_mount;
 	xfs_fileoff_t		sfsbno, dfsbno;
-	xfs_filblks_t		fsblen;
+	xfs_filblks_t		fsblen, remapped = 0;
 	xfs_extlen_t		cowextsize;
-	ssize_t			ret;
+	int			ret;
 
 	if (!xfs_sb_version_hasreflink(&mp->m_sb))
 		return -EOPNOTSUPP;
@@ -1424,11 +1427,17 @@ xfs_reflink_remap_range(
 
 	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
 
+	if (len == 0) {
+		ret = 0;
+		goto out_unlock;
+	}
+
 	dfsbno = XFS_B_TO_FSBT(mp, pos_out);
 	sfsbno = XFS_B_TO_FSBT(mp, pos_in);
 	fsblen = XFS_B_TO_FSB(mp, len);
 	ret = xfs_reflink_remap_blocks(src, sfsbno, dest, dfsbno, fsblen,
-			pos_out + len);
+			&remapped, pos_out + len);
+	remapped = min_t(int64_t, len, XFS_FSB_TO_B(mp, remapped));
 	if (ret)
 		goto out_unlock;
 
@@ -1451,7 +1460,7 @@ xfs_reflink_remap_range(
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
