Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 286936B0008
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:46:55 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h9-v6so21061556pgs.11
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:46:55 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d18-v6si20338634plj.82.2018.10.17.15.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:46:53 -0700 (PDT)
Subject: [PATCH 21/29] ocfs2: support partial clone range and dedupe range
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 17 Oct 2018 15:46:46 -0700
Message-ID: <153981640612.5568.3581451993357141348.stgit@magnolia>
In-Reply-To: <153981625504.5568.2708520119290577378.stgit@magnolia>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Change the ocfs2 remap code to allow for returning partial results.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/ocfs2/file.c         |    7 +----
 fs/ocfs2/refcounttree.c |   72 +++++++++++++++++++++++++----------------------
 fs/ocfs2/refcounttree.h |   12 ++++----
 3 files changed, 46 insertions(+), 45 deletions(-)


diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index fbaeafe44b5f..8125c5ccf821 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -2531,14 +2531,11 @@ static loff_t ocfs2_remap_file_range(struct file *file_in, loff_t pos_in,
 				     struct file *file_out, loff_t pos_out,
 				     loff_t len, unsigned int remap_flags)
 {
-	int ret;
-
 	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
 		return -EINVAL;
 
-	ret = ocfs2_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-					len, remap_flags);
-	return ret < 0 ? ret : len;
+	return ocfs2_reflink_remap_range(file_in, pos_in, file_out, pos_out,
+			len, remap_flags);
 }
 
 const struct inode_operations ocfs2_file_iops = {
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 7c709229e108..c7409578657b 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4507,14 +4507,14 @@ static int ocfs2_reflink_update_dest(struct inode *dest,
 }
 
 /* Remap the range pos_in:len in s_inode to pos_out:len in t_inode. */
-static int ocfs2_reflink_remap_extent(struct inode *s_inode,
-				      struct buffer_head *s_bh,
-				      loff_t pos_in,
-				      struct inode *t_inode,
-				      struct buffer_head *t_bh,
-				      loff_t pos_out,
-				      loff_t len,
-				      struct ocfs2_cached_dealloc_ctxt *dealloc)
+static loff_t ocfs2_reflink_remap_extent(struct inode *s_inode,
+					 struct buffer_head *s_bh,
+					 loff_t pos_in,
+					 struct inode *t_inode,
+					 struct buffer_head *t_bh,
+					 loff_t pos_out,
+					 loff_t len,
+					 struct ocfs2_cached_dealloc_ctxt *dealloc)
 {
 	struct ocfs2_extent_tree s_et;
 	struct ocfs2_extent_tree t_et;
@@ -4522,8 +4522,9 @@ static int ocfs2_reflink_remap_extent(struct inode *s_inode,
 	struct buffer_head *ref_root_bh = NULL;
 	struct ocfs2_refcount_tree *ref_tree;
 	struct ocfs2_super *osb;
+	loff_t remapped_bytes = 0;
 	loff_t pstart, plen;
-	u32 p_cluster, num_clusters, slast, spos, tpos;
+	u32 p_cluster, num_clusters, slast, spos, tpos, remapped_clus = 0;
 	unsigned int ext_flags;
 	int ret = 0;
 
@@ -4605,30 +4606,34 @@ static int ocfs2_reflink_remap_extent(struct inode *s_inode,
 next_loop:
 		spos += num_clusters;
 		tpos += num_clusters;
+		remapped_clus += num_clusters;
 	}
 
-out:
-	return ret;
+	goto out;
 out_unlock_refcount:
 	ocfs2_unlock_refcount_tree(osb, ref_tree, 1);
 	brelse(ref_root_bh);
-	return ret;
+out:
+	remapped_bytes = ocfs2_clusters_to_bytes(t_inode->i_sb, remapped_clus);
+	remapped_bytes = min_t(loff_t, len, remapped_bytes);
+
+	return remapped_bytes > 0 ? remapped_bytes : ret;
 }
 
 /* Set up refcount tree and remap s_inode to t_inode. */
-static int ocfs2_reflink_remap_blocks(struct inode *s_inode,
-				      struct buffer_head *s_bh,
-				      loff_t pos_in,
-				      struct inode *t_inode,
-				      struct buffer_head *t_bh,
-				      loff_t pos_out,
-				      loff_t len)
+static loff_t ocfs2_reflink_remap_blocks(struct inode *s_inode,
+					 struct buffer_head *s_bh,
+					 loff_t pos_in,
+					 struct inode *t_inode,
+					 struct buffer_head *t_bh,
+					 loff_t pos_out,
+					 loff_t len)
 {
 	struct ocfs2_cached_dealloc_ctxt dealloc;
 	struct ocfs2_super *osb;
 	struct ocfs2_dinode *dis;
 	struct ocfs2_dinode *dit;
-	int ret;
+	loff_t ret;
 
 	osb = OCFS2_SB(s_inode->i_sb);
 	dis = (struct ocfs2_dinode *)s_bh->b_data;
@@ -4700,7 +4705,7 @@ static int ocfs2_reflink_remap_blocks(struct inode *s_inode,
 	/* Actually remap extents now. */
 	ret = ocfs2_reflink_remap_extent(s_inode, s_bh, pos_in, t_inode, t_bh,
 					 pos_out, len, &dealloc);
-	if (ret) {
+	if (ret < 0) {
 		mlog_errno(ret);
 		goto out;
 	}
@@ -4820,18 +4825,19 @@ static void ocfs2_reflink_inodes_unlock(struct inode *s_inode,
 }
 
 /* Link a range of blocks from one file to another. */
-int ocfs2_reflink_remap_range(struct file *file_in,
-			      loff_t pos_in,
-			      struct file *file_out,
-			      loff_t pos_out,
-			      loff_t len,
-			      unsigned int remap_flags)
+loff_t ocfs2_reflink_remap_range(struct file *file_in,
+				 loff_t pos_in,
+				 struct file *file_out,
+				 loff_t pos_out,
+				 loff_t len,
+				 unsigned int remap_flags)
 {
 	struct inode *inode_in = file_inode(file_in);
 	struct inode *inode_out = file_inode(file_out);
 	struct ocfs2_super *osb = OCFS2_SB(inode_in->i_sb);
 	struct buffer_head *in_bh = NULL, *out_bh = NULL;
 	bool same_inode = (inode_in == inode_out);
+	loff_t remapped = 0;
 	ssize_t ret;
 
 	if (!ocfs2_refcount_tree(osb))
@@ -4866,12 +4872,13 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 				   round_down(pos_out, PAGE_SIZE),
 				   round_up(pos_out + len, PAGE_SIZE) - 1);
 
-	ret = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in, inode_out,
-					 out_bh, pos_out, len);
+	remapped = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in,
+			inode_out, out_bh, pos_out, len);
 	up_write(&OCFS2_I(inode_in)->ip_alloc_sem);
 	if (!same_inode)
 		up_write(&OCFS2_I(inode_out)->ip_alloc_sem);
-	if (ret) {
+	if (remapped < 0) {
+		ret = remapped;
 		mlog_errno(ret);
 		goto out_unlock;
 	}
@@ -4889,10 +4896,7 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 		goto out_unlock;
 	}
 
-	ocfs2_reflink_inodes_unlock(inode_in, in_bh, inode_out, out_bh);
-	return 0;
-
 out_unlock:
 	ocfs2_reflink_inodes_unlock(inode_in, in_bh, inode_out, out_bh);
-	return ret;
+	return remapped > 0 ? remapped : ret;
 }
diff --git a/fs/ocfs2/refcounttree.h b/fs/ocfs2/refcounttree.h
index eb65c1d0843c..9e64daba395d 100644
--- a/fs/ocfs2/refcounttree.h
+++ b/fs/ocfs2/refcounttree.h
@@ -115,11 +115,11 @@ int ocfs2_reflink_ioctl(struct inode *inode,
 			const char __user *oldname,
 			const char __user *newname,
 			bool preserve);
-int ocfs2_reflink_remap_range(struct file *file_in,
-			      loff_t pos_in,
-			      struct file *file_out,
-			      loff_t pos_out,
-			      loff_t len,
-			      unsigned int remap_flags);
+loff_t ocfs2_reflink_remap_range(struct file *file_in,
+				 loff_t pos_in,
+				 struct file *file_out,
+				 loff_t pos_out,
+				 loff_t len,
+				 unsigned int remap_flags);
 
 #endif /* OCFS2_REFCOUNTTREE_H */
