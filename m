Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3789D6B0273
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 23:11:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g6-v6so17177038plo.0
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:11:13 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id s12-v6si12442156pfk.213.2018.10.15.20.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 20:11:11 -0700 (PDT)
Subject: [PATCH 10/26] vfs: combine the clone and dedupe into a single
 remap_file_range
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Mon, 15 Oct 2018 20:11:05 -0700
Message-ID: <153965946503.1256.14921970220584184352.stgit@magnolia>
In-Reply-To: <153965939489.1256.7400115244528045860.stgit@magnolia>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Combine the clone_file_range and dedupe_file_range operations into a
single remap_file_range file operation dispatch since they're
fundamentally the same operation.  The differences between the two can
be made in the prep functions.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 Documentation/filesystems/vfs.txt |   13 +++++------
 fs/btrfs/ctree.h                  |    8 ++-----
 fs/btrfs/file.c                   |    3 +-
 fs/btrfs/ioctl.c                  |   45 +++++++++++++++++++------------------
 fs/cifs/cifsfs.c                  |   22 +++++++++++-------
 fs/nfs/nfs4file.c                 |   10 ++++++--
 fs/ocfs2/file.c                   |   24 +++++++-------------
 fs/overlayfs/file.c               |   30 ++++++++++++++-----------
 fs/read_write.c                   |   18 +++++++--------
 fs/xfs/xfs_file.c                 |   23 ++++++-------------
 include/linux/fs.h                |   20 +++++++++++++---
 11 files changed, 110 insertions(+), 106 deletions(-)


diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index a6c6a8af48a2..bb3183334ab9 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -883,8 +883,9 @@ struct file_operations {
 	unsigned (*mmap_capabilities)(struct file *);
 #endif
 	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *, loff_t, size_t, unsigned int);
-	int (*clone_file_range)(struct file *, loff_t, struct file *, loff_t, u64);
-	int (*dedupe_file_range)(struct file *, loff_t, struct file *, loff_t, u64);
+	int (*remap_file_range)(struct file *file_in, loff_t pos_in,
+				struct file *file_out, loff_t pos_out,
+				u64 len, unsigned int remap_flags);
 	int (*fadvise)(struct file *, loff_t, loff_t, int);
 };
 
@@ -960,11 +961,9 @@ otherwise noted.
 
   copy_file_range: called by the copy_file_range(2) system call.
 
-  clone_file_range: called by the ioctl(2) system call for FICLONERANGE and
-	FICLONE commands.
-
-  dedupe_file_range: called by the ioctl(2) system call for FIDEDUPERANGE
-	command.
+  remap_file_range: called by the ioctl(2) system call for FICLONERANGE and
+	FICLONE and FIDEDUPERANGE commands to remap file ranges.  Note that
+	a zero length implies "remap to end of source file".
 
   fadvise: possibly called by the fadvise64() system call.
 
diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 2cddfe7806a4..124a05662fc2 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -3218,9 +3218,6 @@ void btrfs_get_block_group_info(struct list_head *groups_list,
 				struct btrfs_ioctl_space_info *space);
 void btrfs_update_ioctl_balance_args(struct btrfs_fs_info *fs_info,
 			       struct btrfs_ioctl_balance_args *bargs);
-int btrfs_dedupe_file_range(struct file *src_file, loff_t src_loff,
-			    struct file *dst_file, loff_t dst_loff,
-			    u64 olen);
 
 /* file.c */
 int __init btrfs_auto_defrag_init(void);
@@ -3250,8 +3247,9 @@ int btrfs_dirty_pages(struct inode *inode, struct page **pages,
 		      size_t num_pages, loff_t pos, size_t write_bytes,
 		      struct extent_state **cached);
 int btrfs_fdatawrite_range(struct inode *inode, loff_t start, loff_t end);
-int btrfs_clone_file_range(struct file *file_in, loff_t pos_in,
-			   struct file *file_out, loff_t pos_out, u64 len);
+int btrfs_remap_file_range(struct file *file_in, loff_t pos_in,
+			   struct file *file_out, loff_t pos_out, u64 len,
+			   unsigned int remap_flags);
 
 /* tree-defrag.c */
 int btrfs_defrag_leaves(struct btrfs_trans_handle *trans,
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 2be00e873e92..9a963f061393 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -3269,8 +3269,7 @@ const struct file_operations btrfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= btrfs_compat_ioctl,
 #endif
-	.clone_file_range = btrfs_clone_file_range,
-	.dedupe_file_range = btrfs_dedupe_file_range,
+	.remap_file_range = btrfs_remap_file_range,
 };
 
 void __cold btrfs_auto_defrag_exit(void)
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index d60b6caf09e8..bfd99c66723e 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -3627,26 +3627,6 @@ static int btrfs_extent_same(struct inode *src, u64 loff, u64 olen,
 	return ret;
 }
 
-int btrfs_dedupe_file_range(struct file *src_file, loff_t src_loff,
-			    struct file *dst_file, loff_t dst_loff,
-			    u64 olen)
-{
-	struct inode *src = file_inode(src_file);
-	struct inode *dst = file_inode(dst_file);
-	u64 bs = BTRFS_I(src)->root->fs_info->sb->s_blocksize;
-
-	if (WARN_ON_ONCE(bs < PAGE_SIZE)) {
-		/*
-		 * Btrfs does not support blocksize < page_size. As a
-		 * result, btrfs_cmp_data() won't correctly handle
-		 * this situation without an update.
-		 */
-		return -EINVAL;
-	}
-
-	return btrfs_extent_same(src, src_loff, olen, dst, dst_loff);
-}
-
 static int clone_finish_inode_update(struct btrfs_trans_handle *trans,
 				     struct inode *inode,
 				     u64 endoff,
@@ -4348,9 +4328,30 @@ static noinline int btrfs_clone_files(struct file *file, struct file *file_src,
 	return ret;
 }
 
-int btrfs_clone_file_range(struct file *src_file, loff_t off,
-		struct file *dst_file, loff_t destoff, u64 len)
+int btrfs_remap_file_range(struct file *src_file, loff_t off,
+		struct file *dst_file, loff_t destoff, u64 len,
+		unsigned int remap_flags)
 {
+	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
+		return -EINVAL;
+
+	if (remap_flags & REMAP_FILE_DEDUP) {
+		struct inode *src = file_inode(src_file);
+		struct inode *dst = file_inode(dst_file);
+		u64 bs = BTRFS_I(src)->root->fs_info->sb->s_blocksize;
+
+		if (WARN_ON_ONCE(bs < PAGE_SIZE)) {
+			/*
+			 * Btrfs does not support blocksize < page_size. As a
+			 * result, btrfs_cmp_data() won't correctly handle
+			 * this situation without an update.
+			 */
+			return -EINVAL;
+		}
+
+		return btrfs_extent_same(src, off, len, dst, destoff);
+	}
+
 	return btrfs_clone_files(dst_file, src_file, off, len, destoff);
 }
 
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 7065426b3280..e8144d0dcde2 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -975,8 +975,9 @@ const struct inode_operations cifs_symlink_inode_ops = {
 	.listxattr = cifs_listxattr,
 };
 
-static int cifs_clone_file_range(struct file *src_file, loff_t off,
-		struct file *dst_file, loff_t destoff, u64 len)
+static int cifs_remap_file_range(struct file *src_file, loff_t off,
+		struct file *dst_file, loff_t destoff, u64 len,
+		unsigned int remap_flags)
 {
 	struct inode *src_inode = file_inode(src_file);
 	struct inode *target_inode = file_inode(dst_file);
@@ -986,6 +987,9 @@ static int cifs_clone_file_range(struct file *src_file, loff_t off,
 	unsigned int xid;
 	int rc;
 
+	if (remap_flags & ~REMAP_FILE_ADVISORY)
+		return -EINVAL;
+
 	cifs_dbg(FYI, "clone range\n");
 
 	xid = get_xid();
@@ -1134,7 +1138,7 @@ const struct file_operations cifs_file_ops = {
 	.llseek = cifs_llseek,
 	.unlocked_ioctl	= cifs_ioctl,
 	.copy_file_range = cifs_copy_file_range,
-	.clone_file_range = cifs_clone_file_range,
+	.remap_file_range = cifs_remap_file_range,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
 };
@@ -1153,7 +1157,7 @@ const struct file_operations cifs_file_strict_ops = {
 	.llseek = cifs_llseek,
 	.unlocked_ioctl	= cifs_ioctl,
 	.copy_file_range = cifs_copy_file_range,
-	.clone_file_range = cifs_clone_file_range,
+	.remap_file_range = cifs_remap_file_range,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
 };
@@ -1172,7 +1176,7 @@ const struct file_operations cifs_file_direct_ops = {
 	.splice_write = iter_file_splice_write,
 	.unlocked_ioctl  = cifs_ioctl,
 	.copy_file_range = cifs_copy_file_range,
-	.clone_file_range = cifs_clone_file_range,
+	.remap_file_range = cifs_remap_file_range,
 	.llseek = cifs_llseek,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
@@ -1191,7 +1195,7 @@ const struct file_operations cifs_file_nobrl_ops = {
 	.llseek = cifs_llseek,
 	.unlocked_ioctl	= cifs_ioctl,
 	.copy_file_range = cifs_copy_file_range,
-	.clone_file_range = cifs_clone_file_range,
+	.remap_file_range = cifs_remap_file_range,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
 };
@@ -1209,7 +1213,7 @@ const struct file_operations cifs_file_strict_nobrl_ops = {
 	.llseek = cifs_llseek,
 	.unlocked_ioctl	= cifs_ioctl,
 	.copy_file_range = cifs_copy_file_range,
-	.clone_file_range = cifs_clone_file_range,
+	.remap_file_range = cifs_remap_file_range,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
 };
@@ -1227,7 +1231,7 @@ const struct file_operations cifs_file_direct_nobrl_ops = {
 	.splice_write = iter_file_splice_write,
 	.unlocked_ioctl  = cifs_ioctl,
 	.copy_file_range = cifs_copy_file_range,
-	.clone_file_range = cifs_clone_file_range,
+	.remap_file_range = cifs_remap_file_range,
 	.llseek = cifs_llseek,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
@@ -1239,7 +1243,7 @@ const struct file_operations cifs_dir_ops = {
 	.read    = generic_read_dir,
 	.unlocked_ioctl  = cifs_ioctl,
 	.copy_file_range = cifs_copy_file_range,
-	.clone_file_range = cifs_clone_file_range,
+	.remap_file_range = cifs_remap_file_range,
 	.llseek = generic_file_llseek,
 	.fsync = cifs_dir_fsync,
 };
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4288a6ecaf75..ae5780ce41dc 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -180,8 +180,9 @@ static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t
 	return nfs42_proc_allocate(filep, offset, len);
 }
 
-static int nfs42_clone_file_range(struct file *src_file, loff_t src_off,
-		struct file *dst_file, loff_t dst_off, u64 count)
+static int nfs42_remap_file_range(struct file *src_file, loff_t src_off,
+		struct file *dst_file, loff_t dst_off, u64 count,
+		unsigned int remap_flags)
 {
 	struct inode *dst_inode = file_inode(dst_file);
 	struct nfs_server *server = NFS_SERVER(dst_inode);
@@ -190,6 +191,9 @@ static int nfs42_clone_file_range(struct file *src_file, loff_t src_off,
 	bool same_inode = false;
 	int ret;
 
+	if (remap_flags & ~REMAP_FILE_ADVISORY)
+		return -EINVAL;
+
 	/* check alignment w.r.t. clone_blksize */
 	ret = -EINVAL;
 	if (bs) {
@@ -262,7 +266,7 @@ const struct file_operations nfs4_file_operations = {
 	.copy_file_range = nfs4_copy_file_range,
 	.llseek		= nfs4_file_llseek,
 	.fallocate	= nfs42_fallocate,
-	.clone_file_range = nfs42_clone_file_range,
+	.remap_file_range = nfs42_remap_file_range,
 #else
 	.llseek		= nfs_file_llseek,
 #endif
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 9fa35cb6f6e0..0b757a24567c 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -2527,24 +2527,18 @@ static loff_t ocfs2_file_llseek(struct file *file, loff_t offset, int whence)
 	return offset;
 }
 
-static int ocfs2_file_clone_range(struct file *file_in,
+static int ocfs2_remap_file_range(struct file *file_in,
 				  loff_t pos_in,
 				  struct file *file_out,
 				  loff_t pos_out,
-				  u64 len)
+				  u64 len,
+				  unsigned int remap_flags)
 {
-	return ocfs2_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-					 len, false);
-}
+	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
+		return -EINVAL;
 
-static int ocfs2_file_dedupe_range(struct file *file_in,
-				   loff_t pos_in,
-				   struct file *file_out,
-				   loff_t pos_out,
-				   u64 len)
-{
 	return ocfs2_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-					  len, true);
+					 len, remap_flags & REMAP_FILE_DEDUP);
 }
 
 const struct inode_operations ocfs2_file_iops = {
@@ -2586,8 +2580,7 @@ const struct file_operations ocfs2_fops = {
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 	.fallocate	= ocfs2_fallocate,
-	.clone_file_range = ocfs2_file_clone_range,
-	.dedupe_file_range = ocfs2_file_dedupe_range,
+	.remap_file_range = ocfs2_remap_file_range,
 };
 
 const struct file_operations ocfs2_dops = {
@@ -2633,8 +2626,7 @@ const struct file_operations ocfs2_fops_no_plocks = {
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 	.fallocate	= ocfs2_fallocate,
-	.clone_file_range = ocfs2_file_clone_range,
-	.dedupe_file_range = ocfs2_file_dedupe_range,
+	.remap_file_range = ocfs2_remap_file_range,
 };
 
 const struct file_operations ocfs2_dops_no_plocks = {
diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index 986313da0c88..fffb36fd5920 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -489,26 +489,31 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
 			    OVL_COPY);
 }
 
-static int ovl_clone_file_range(struct file *file_in, loff_t pos_in,
-				struct file *file_out, loff_t pos_out, u64 len)
+static int ovl_remap_file_range(struct file *file_in, loff_t pos_in,
+				struct file *file_out, loff_t pos_out,
+				u64 len, unsigned int remap_flags)
 {
-	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, 0,
-			    OVL_CLONE);
-}
+	enum ovl_copyop op;
+
+	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
+		return -EINVAL;
+
+	if (remap_flags & REMAP_FILE_DEDUP)
+		op = OVL_DEDUPE;
+	else
+		op = OVL_CLONE;
 
-static int ovl_dedupe_file_range(struct file *file_in, loff_t pos_in,
-				 struct file *file_out, loff_t pos_out, u64 len)
-{
 	/*
 	 * Don't copy up because of a dedupe request, this wouldn't make sense
 	 * most of the time (data would be duplicated instead of deduplicated).
 	 */
-	if (!ovl_inode_upper(file_inode(file_in)) ||
-	    !ovl_inode_upper(file_inode(file_out)))
+	if (op == OVL_DEDUPE &&
+	    (!ovl_inode_upper(file_inode(file_in)) ||
+	     !ovl_inode_upper(file_inode(file_out))))
 		return -EPERM;
 
 	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, 0,
-			    OVL_DEDUPE);
+			    op);
 }
 
 const struct file_operations ovl_file_operations = {
@@ -525,6 +530,5 @@ const struct file_operations ovl_file_operations = {
 	.compat_ioctl	= ovl_compat_ioctl,
 
 	.copy_file_range	= ovl_copy_file_range,
-	.clone_file_range	= ovl_clone_file_range,
-	.dedupe_file_range	= ovl_dedupe_file_range,
+	.remap_file_range	= ovl_remap_file_range,
 };
diff --git a/fs/read_write.c b/fs/read_write.c
index 734c5661fb69..766bdcb381f3 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1588,9 +1588,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	 * Try cloning first, this is supported by more file systems, and
 	 * more efficient if both clone and copy are supported (e.g. NFS).
 	 */
-	if (file_in->f_op->clone_file_range) {
-		ret = file_in->f_op->clone_file_range(file_in, pos_in,
-				file_out, pos_out, len);
+	if (file_in->f_op->remap_file_range) {
+		ret = file_in->f_op->remap_file_range(file_in, pos_in,
+				file_out, pos_out, len, 0);
 		if (ret == 0) {
 			ret = len;
 			goto done;
@@ -1849,7 +1849,7 @@ int do_clone_file_range(struct file *file_in, loff_t pos_in,
 	    (file_out->f_flags & O_APPEND))
 		return -EBADF;
 
-	if (!file_in->f_op->clone_file_range)
+	if (!file_in->f_op->remap_file_range)
 		return -EOPNOTSUPP;
 
 	ret = remap_verify_area(file_in, pos_in, len, false);
@@ -1860,8 +1860,8 @@ int do_clone_file_range(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
-	ret = file_in->f_op->clone_file_range(file_in, pos_in,
-			file_out, pos_out, len);
+	ret = file_in->f_op->remap_file_range(file_in, pos_in,
+			file_out, pos_out, len, 0);
 	if (!ret) {
 		fsnotify_access(file_in);
 		fsnotify_modify(file_out);
@@ -2006,7 +2006,7 @@ int vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 		goto out_drop_write;
 
 	ret = -EINVAL;
-	if (!dst_file->f_op->dedupe_file_range)
+	if (!dst_file->f_op->remap_file_range)
 		goto out_drop_write;
 
 	if (len == 0) {
@@ -2014,8 +2014,8 @@ int vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 		goto out_drop_write;
 	}
 
-	ret = dst_file->f_op->dedupe_file_range(src_file, src_pos,
-						dst_file, dst_pos, len);
+	ret = dst_file->f_op->remap_file_range(src_file, src_pos, dst_file,
+			dst_pos, len, REMAP_FILE_DEDUP);
 out_drop_write:
 	mnt_drop_write_file(dst_file);
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 61a5ad2600e8..2ad94d508f80 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -920,27 +920,19 @@ xfs_file_fallocate(
 }
 
 STATIC int
-xfs_file_clone_range(
+xfs_file_remap_range(
 	struct file	*file_in,
 	loff_t		pos_in,
 	struct file	*file_out,
 	loff_t		pos_out,
-	u64		len)
+	u64		len,
+	unsigned int	remap_flags)
 {
-	return xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-				     len, false);
-}
+	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
+		return -EINVAL;
 
-STATIC int
-xfs_file_dedupe_range(
-	struct file	*file_in,
-	loff_t		pos_in,
-	struct file	*file_out,
-	loff_t		pos_out,
-	u64		len)
-{
 	return xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-				     len, true);
+			len, remap_flags & REMAP_FILE_DEDUP);
 }
 
 STATIC int
@@ -1175,8 +1167,7 @@ const struct file_operations xfs_file_operations = {
 	.fsync		= xfs_file_fsync,
 	.get_unmapped_area = thp_get_unmapped_area,
 	.fallocate	= xfs_file_fallocate,
-	.clone_file_range = xfs_file_clone_range,
-	.dedupe_file_range = xfs_file_dedupe_range,
+	.remap_file_range = xfs_file_remap_range,
 };
 
 const struct file_operations xfs_dir_file_operations = {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 55729e1c2e75..794d1b83eded 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1721,6 +1721,19 @@ struct block_device_operations;
 #define NOMMU_VMFLAGS \
 	(NOMMU_MAP_READ | NOMMU_MAP_WRITE | NOMMU_MAP_EXEC)
 
+/*
+ * These flags control the behavior of the remap_file_range function pointer.
+ * If it is called with len == 0 that means "remap to end of source file".
+ *
+ * REMAP_FILE_DEDUP: only remap if contents identical (i.e. deduplicate)
+ */
+#define REMAP_FILE_DEDUP		(1 << 0)
+
+/* All valid REMAP_FILE flags */
+#define REMAP_FILE_VALID_FLAGS		(REMAP_FILE_DEDUP)
+
+/* REMAP_FILE flags taken care of by the vfs. */
+#define REMAP_FILE_ADVISORY		(0)
 
 struct iov_iter;
 
@@ -1759,10 +1772,9 @@ struct file_operations {
 #endif
 	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *,
 			loff_t, size_t, unsigned int);
-	int (*clone_file_range)(struct file *, loff_t, struct file *, loff_t,
-			u64);
-	int (*dedupe_file_range)(struct file *, loff_t, struct file *, loff_t,
-			u64);
+	int (*remap_file_range)(struct file *file_in, loff_t pos_in,
+				struct file *file_out, loff_t pos_out,
+				u64 len, unsigned int remap_flags);
 	int (*fadvise)(struct file *, loff_t, loff_t, int);
 } __randomize_layout;
 
