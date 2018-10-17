Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB4E6B0270
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:46:05 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 25-v6so24797028pfs.5
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:46:05 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n2-v6si18557000plk.255.2018.10.17.15.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:46:04 -0700 (PDT)
Subject: [PATCH 14/29] vfs: plumb remap flags through the vfs clone functions
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 17 Oct 2018 15:45:51 -0700
Message-ID: <153981635183.5568.14122129836747881883.stgit@magnolia>
In-Reply-To: <153981625504.5568.2708520119290577378.stgit@magnolia>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Plumb a remap_flags argument through the {do,vfs}_clone_file_range
functions so that clone can take advantage of it.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/ioctl.c             |    2 +-
 fs/nfsd/vfs.c          |    2 +-
 fs/overlayfs/copy_up.c |    2 +-
 fs/overlayfs/file.c    |    6 +++---
 fs/read_write.c        |   13 +++++++++----
 include/linux/fs.h     |    4 ++--
 6 files changed, 17 insertions(+), 12 deletions(-)


diff --git a/fs/ioctl.c b/fs/ioctl.c
index 72537b68c272..505275ec5596 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -232,7 +232,7 @@ static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
 	if (src_file.file->f_path.mnt != dst_file->f_path.mnt)
 		goto fdput;
 	cloned = vfs_clone_file_range(src_file.file, off, dst_file, destoff,
-				      olen);
+				      olen, 0);
 	if (cloned < 0)
 		ret = cloned;
 	else if (olen && cloned != olen)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ac6cb6101cbe..726fc5b2b27a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -543,7 +543,7 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
 {
 	loff_t cloned;
 
-	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count);
+	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, 0);
 	if (count && cloned != count)
 		cloned = -EINVAL;
 	return nfserrno(cloned < 0 ? cloned : 0);
diff --git a/fs/overlayfs/copy_up.c b/fs/overlayfs/copy_up.c
index 8750b7235516..5f82fece64a0 100644
--- a/fs/overlayfs/copy_up.c
+++ b/fs/overlayfs/copy_up.c
@@ -142,7 +142,7 @@ static int ovl_copy_up_data(struct path *old, struct path *new, loff_t len)
 	}
 
 	/* Try to use clone_file_range to clone up within the same fs */
-	cloned = do_clone_file_range(old_file, 0, new_file, 0, len);
+	cloned = do_clone_file_range(old_file, 0, new_file, 0, len, 0);
 	if (cloned == len)
 		goto out;
 	/* Couldn't clone, so now we try to copy the data */
diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index 6c3fec6168e9..0393815c8971 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -462,7 +462,7 @@ static loff_t ovl_copyfile(struct file *file_in, loff_t pos_in,
 
 	case OVL_CLONE:
 		ret = vfs_clone_file_range(real_in.file, pos_in,
-					   real_out.file, pos_out, len);
+					   real_out.file, pos_out, len, flags);
 		break;
 
 	case OVL_DEDUPE:
@@ -512,8 +512,8 @@ static loff_t ovl_remap_file_range(struct file *file_in, loff_t pos_in,
 	     !ovl_inode_upper(file_inode(file_out))))
 		return -EPERM;
 
-	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, 0,
-			    op);
+	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len,
+			    remap_flags, op);
 }
 
 const struct file_operations ovl_file_operations = {
diff --git a/fs/read_write.c b/fs/read_write.c
index 356641afa487..0d1ac1b9bc22 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1848,12 +1848,15 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 EXPORT_SYMBOL(generic_remap_file_range_prep);
 
 loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
-			   struct file *file_out, loff_t pos_out, loff_t len)
+			   struct file *file_out, loff_t pos_out,
+			   loff_t len, unsigned int remap_flags)
 {
 	struct inode *inode_in = file_inode(file_in);
 	struct inode *inode_out = file_inode(file_out);
 	loff_t ret;
 
+	WARN_ON_ONCE(remap_flags);
+
 	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
 		return -EISDIR;
 	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
@@ -1884,7 +1887,7 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
 		return ret;
 
 	ret = file_in->f_op->remap_file_range(file_in, pos_in,
-			file_out, pos_out, len, 0);
+			file_out, pos_out, len, remap_flags);
 	if (ret < 0)
 		return ret;
 
@@ -1895,12 +1898,14 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
 EXPORT_SYMBOL(do_clone_file_range);
 
 loff_t vfs_clone_file_range(struct file *file_in, loff_t pos_in,
-			    struct file *file_out, loff_t pos_out, loff_t len)
+			    struct file *file_out, loff_t pos_out,
+			    loff_t len, unsigned int remap_flags)
 {
 	loff_t ret;
 
 	file_start_write(file_out);
-	ret = do_clone_file_range(file_in, pos_in, file_out, pos_out, len);
+	ret = do_clone_file_range(file_in, pos_in, file_out, pos_out, len,
+				  remap_flags);
 	file_end_write(file_out);
 
 	return ret;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 80485efad457..bc78ad7e21b2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1843,10 +1843,10 @@ extern int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 					 unsigned int remap_flags);
 extern loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
 				  struct file *file_out, loff_t pos_out,
-				  loff_t len);
+				  loff_t len, unsigned int remap_flags);
 extern loff_t vfs_clone_file_range(struct file *file_in, loff_t pos_in,
 				   struct file *file_out, loff_t pos_out,
-				   loff_t len);
+				   loff_t len, unsigned int remap_flags);
 extern int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
 					 struct inode *dest, loff_t destoff,
 					 loff_t len, bool *is_same);
