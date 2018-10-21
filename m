Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id B96256B0283
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:17:41 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id c8-v6so4937591ybs.2
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:17:41 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n126-v6si6051974ywe.31.2018.10.21.09.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:17:40 -0700 (PDT)
Subject: [PATCH 22/28] ocfs2: remove ocfs2_reflink_remap_range
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:17:36 -0700
Message-ID: <154013865665.29026.16826908431108353571.stgit@magnolia>
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

Since ocfs2_remap_file_range is a thin shell around
ocfs2_remap_remap_range, move everything from the latter into the
former.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/ocfs2/file.c         |   68 +++++++++++++++++++++++++++-
 fs/ocfs2/refcounttree.c |  113 +++++++----------------------------------------
 fs/ocfs2/refcounttree.h |   24 +++++++---
 3 files changed, 102 insertions(+), 103 deletions(-)


diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 8125c5ccf821..fe570824b991 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -2531,11 +2531,75 @@ static loff_t ocfs2_remap_file_range(struct file *file_in, loff_t pos_in,
 				     struct file *file_out, loff_t pos_out,
 				     loff_t len, unsigned int remap_flags)
 {
+	struct inode *inode_in = file_inode(file_in);
+	struct inode *inode_out = file_inode(file_out);
+	struct ocfs2_super *osb = OCFS2_SB(inode_in->i_sb);
+	struct buffer_head *in_bh = NULL, *out_bh = NULL;
+	bool same_inode = (inode_in == inode_out);
+	loff_t remapped = 0;
+	ssize_t ret;
+
 	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
 		return -EINVAL;
+	if (!ocfs2_refcount_tree(osb))
+		return -EOPNOTSUPP;
+	if (ocfs2_is_hard_readonly(osb) || ocfs2_is_soft_readonly(osb))
+		return -EROFS;
 
-	return ocfs2_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-			len, remap_flags);
+	/* Lock both files against IO */
+	ret = ocfs2_reflink_inodes_lock(inode_in, &in_bh, inode_out, &out_bh);
+	if (ret)
+		return ret;
+
+	/* Check file eligibility and prepare for block sharing. */
+	ret = -EINVAL;
+	if ((OCFS2_I(inode_in)->ip_flags & OCFS2_INODE_SYSTEM_FILE) ||
+	    (OCFS2_I(inode_out)->ip_flags & OCFS2_INODE_SYSTEM_FILE))
+		goto out_unlock;
+
+	ret = generic_remap_file_range_prep(file_in, pos_in, file_out, pos_out,
+			&len, remap_flags);
+	if (ret < 0 || len == 0)
+		goto out_unlock;
+
+	/* Lock out changes to the allocation maps and remap. */
+	down_write(&OCFS2_I(inode_in)->ip_alloc_sem);
+	if (!same_inode)
+		down_write_nested(&OCFS2_I(inode_out)->ip_alloc_sem,
+				  SINGLE_DEPTH_NESTING);
+
+	/* Zap any page cache for the destination file's range. */
+	truncate_inode_pages_range(&inode_out->i_data,
+				   round_down(pos_out, PAGE_SIZE),
+				   round_up(pos_out + len, PAGE_SIZE) - 1);
+
+	remapped = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in,
+			inode_out, out_bh, pos_out, len);
+	up_write(&OCFS2_I(inode_in)->ip_alloc_sem);
+	if (!same_inode)
+		up_write(&OCFS2_I(inode_out)->ip_alloc_sem);
+	if (remapped < 0) {
+		ret = remapped;
+		mlog_errno(ret);
+		goto out_unlock;
+	}
+
+	/*
+	 * Empty the extent map so that we may get the right extent
+	 * record from the disk.
+	 */
+	ocfs2_extent_map_trunc(inode_in, 0);
+	ocfs2_extent_map_trunc(inode_out, 0);
+
+	ret = ocfs2_reflink_update_dest(inode_out, out_bh, pos_out + len);
+	if (ret) {
+		mlog_errno(ret);
+		goto out_unlock;
+	}
+
+out_unlock:
+	ocfs2_reflink_inodes_unlock(inode_in, in_bh, inode_out, out_bh);
+	return remapped > 0 ? remapped : ret;
 }
 
 const struct inode_operations ocfs2_file_iops = {
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index c7409578657b..dc66b80585ec 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4468,9 +4468,9 @@ int ocfs2_reflink_ioctl(struct inode *inode,
 }
 
 /* Update destination inode size, if necessary. */
-static int ocfs2_reflink_update_dest(struct inode *dest,
-				     struct buffer_head *d_bh,
-				     loff_t newlen)
+int ocfs2_reflink_update_dest(struct inode *dest,
+			      struct buffer_head *d_bh,
+			      loff_t newlen)
 {
 	handle_t *handle;
 	int ret;
@@ -4621,13 +4621,13 @@ static loff_t ocfs2_reflink_remap_extent(struct inode *s_inode,
 }
 
 /* Set up refcount tree and remap s_inode to t_inode. */
-static loff_t ocfs2_reflink_remap_blocks(struct inode *s_inode,
-					 struct buffer_head *s_bh,
-					 loff_t pos_in,
-					 struct inode *t_inode,
-					 struct buffer_head *t_bh,
-					 loff_t pos_out,
-					 loff_t len)
+loff_t ocfs2_reflink_remap_blocks(struct inode *s_inode,
+				  struct buffer_head *s_bh,
+				  loff_t pos_in,
+				  struct inode *t_inode,
+				  struct buffer_head *t_bh,
+				  loff_t pos_out,
+				  loff_t len)
 {
 	struct ocfs2_cached_dealloc_ctxt dealloc;
 	struct ocfs2_super *osb;
@@ -4720,10 +4720,10 @@ static loff_t ocfs2_reflink_remap_blocks(struct inode *s_inode,
 }
 
 /* Lock an inode and grab a bh pointing to the inode. */
-static int ocfs2_reflink_inodes_lock(struct inode *s_inode,
-				     struct buffer_head **bh1,
-				     struct inode *t_inode,
-				     struct buffer_head **bh2)
+int ocfs2_reflink_inodes_lock(struct inode *s_inode,
+			      struct buffer_head **bh1,
+			      struct inode *t_inode,
+			      struct buffer_head **bh2)
 {
 	struct inode *inode1;
 	struct inode *inode2;
@@ -4808,10 +4808,10 @@ static int ocfs2_reflink_inodes_lock(struct inode *s_inode,
 }
 
 /* Unlock both inodes and release buffers. */
-static void ocfs2_reflink_inodes_unlock(struct inode *s_inode,
-					struct buffer_head *s_bh,
-					struct inode *t_inode,
-					struct buffer_head *t_bh)
+void ocfs2_reflink_inodes_unlock(struct inode *s_inode,
+				 struct buffer_head *s_bh,
+				 struct inode *t_inode,
+				 struct buffer_head *t_bh)
 {
 	ocfs2_inode_unlock(s_inode, 1);
 	ocfs2_rw_unlock(s_inode, 1);
@@ -4823,80 +4823,3 @@ static void ocfs2_reflink_inodes_unlock(struct inode *s_inode,
 	}
 	unlock_two_nondirectories(s_inode, t_inode);
 }
-
-/* Link a range of blocks from one file to another. */
-loff_t ocfs2_reflink_remap_range(struct file *file_in,
-				 loff_t pos_in,
-				 struct file *file_out,
-				 loff_t pos_out,
-				 loff_t len,
-				 unsigned int remap_flags)
-{
-	struct inode *inode_in = file_inode(file_in);
-	struct inode *inode_out = file_inode(file_out);
-	struct ocfs2_super *osb = OCFS2_SB(inode_in->i_sb);
-	struct buffer_head *in_bh = NULL, *out_bh = NULL;
-	bool same_inode = (inode_in == inode_out);
-	loff_t remapped = 0;
-	ssize_t ret;
-
-	if (!ocfs2_refcount_tree(osb))
-		return -EOPNOTSUPP;
-	if (ocfs2_is_hard_readonly(osb) || ocfs2_is_soft_readonly(osb))
-		return -EROFS;
-
-	/* Lock both files against IO */
-	ret = ocfs2_reflink_inodes_lock(inode_in, &in_bh, inode_out, &out_bh);
-	if (ret)
-		return ret;
-
-	/* Check file eligibility and prepare for block sharing. */
-	ret = -EINVAL;
-	if ((OCFS2_I(inode_in)->ip_flags & OCFS2_INODE_SYSTEM_FILE) ||
-	    (OCFS2_I(inode_out)->ip_flags & OCFS2_INODE_SYSTEM_FILE))
-		goto out_unlock;
-
-	ret = generic_remap_file_range_prep(file_in, pos_in, file_out, pos_out,
-			&len, remap_flags);
-	if (ret < 0 || len == 0)
-		goto out_unlock;
-
-	/* Lock out changes to the allocation maps and remap. */
-	down_write(&OCFS2_I(inode_in)->ip_alloc_sem);
-	if (!same_inode)
-		down_write_nested(&OCFS2_I(inode_out)->ip_alloc_sem,
-				  SINGLE_DEPTH_NESTING);
-
-	/* Zap any page cache for the destination file's range. */
-	truncate_inode_pages_range(&inode_out->i_data,
-				   round_down(pos_out, PAGE_SIZE),
-				   round_up(pos_out + len, PAGE_SIZE) - 1);
-
-	remapped = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in,
-			inode_out, out_bh, pos_out, len);
-	up_write(&OCFS2_I(inode_in)->ip_alloc_sem);
-	if (!same_inode)
-		up_write(&OCFS2_I(inode_out)->ip_alloc_sem);
-	if (remapped < 0) {
-		ret = remapped;
-		mlog_errno(ret);
-		goto out_unlock;
-	}
-
-	/*
-	 * Empty the extent map so that we may get the right extent
-	 * record from the disk.
-	 */
-	ocfs2_extent_map_trunc(inode_in, 0);
-	ocfs2_extent_map_trunc(inode_out, 0);
-
-	ret = ocfs2_reflink_update_dest(inode_out, out_bh, pos_out + len);
-	if (ret) {
-		mlog_errno(ret);
-		goto out_unlock;
-	}
-
-out_unlock:
-	ocfs2_reflink_inodes_unlock(inode_in, in_bh, inode_out, out_bh);
-	return remapped > 0 ? remapped : ret;
-}
diff --git a/fs/ocfs2/refcounttree.h b/fs/ocfs2/refcounttree.h
index 9e64daba395d..e9e862be4a1e 100644
--- a/fs/ocfs2/refcounttree.h
+++ b/fs/ocfs2/refcounttree.h
@@ -115,11 +115,23 @@ int ocfs2_reflink_ioctl(struct inode *inode,
 			const char __user *oldname,
 			const char __user *newname,
 			bool preserve);
-loff_t ocfs2_reflink_remap_range(struct file *file_in,
-				 loff_t pos_in,
-				 struct file *file_out,
-				 loff_t pos_out,
-				 loff_t len,
-				 unsigned int remap_flags);
+loff_t ocfs2_reflink_remap_blocks(struct inode *s_inode,
+				  struct buffer_head *s_bh,
+				  loff_t pos_in,
+				  struct inode *t_inode,
+				  struct buffer_head *t_bh,
+				  loff_t pos_out,
+				  loff_t len);
+int ocfs2_reflink_inodes_lock(struct inode *s_inode,
+			      struct buffer_head **bh1,
+			      struct inode *t_inode,
+			      struct buffer_head **bh2);
+void ocfs2_reflink_inodes_unlock(struct inode *s_inode,
+				 struct buffer_head *s_bh,
+				 struct inode *t_inode,
+				 struct buffer_head *t_bh);
+int ocfs2_reflink_update_dest(struct inode *dest,
+			      struct buffer_head *d_bh,
+			      loff_t newlen);
 
 #endif /* OCFS2_REFCOUNTTREE_H */
