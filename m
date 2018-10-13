Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10ABF6B0280
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 20:07:44 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v198-v6so13353484qka.16
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:07:44 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r141-v6si1939687qke.122.2018.10.12.17.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 17:07:43 -0700 (PDT)
Subject: [PATCH 16/25] vfs: make remapping to source file eof more explicit
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Fri, 12 Oct 2018 17:07:37 -0700
Message-ID: <153938925737.8361.3995899966552253527.stgit@magnolia>
In-Reply-To: <153938912912.8361.13446310416406388958.stgit@magnolia>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Create a RFR_TO_SRC_EOF flag to explicitly declare that the caller wants
the remap implementation to remap to the end of the source file, once
the files are locked.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/ioctl.c         |    3 ++-
 fs/nfsd/vfs.c      |    4 +++-
 fs/read_write.c    |   13 ++++++++-----
 include/linux/fs.h |    8 +++++++-
 4 files changed, 20 insertions(+), 8 deletions(-)


diff --git a/fs/ioctl.c b/fs/ioctl.c
index 505275ec5596..088cf240ca10 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -224,6 +224,7 @@ static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
 {
 	struct fd src_file = fdget(srcfd);
 	loff_t cloned;
+	unsigned int remap_flags = olen == 0 ? RFR_TO_SRC_EOF : 0;
 	int ret;
 
 	if (!src_file.file)
@@ -232,7 +233,7 @@ static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
 	if (src_file.file->f_path.mnt != dst_file->f_path.mnt)
 		goto fdput;
 	cloned = vfs_clone_file_range(src_file.file, off, dst_file, destoff,
-				      olen, 0);
+				      olen, remap_flags);
 	if (cloned < 0)
 		ret = cloned;
 	else if (olen && cloned != olen)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 726fc5b2b27a..0dc65047df1a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -542,8 +542,10 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
 		u64 dst_pos, u64 count)
 {
 	loff_t cloned;
+	unsigned int remap_flags = count == 0 ? RFR_TO_SRC_EOF : 0;
 
-	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, 0);
+	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count,
+				      remap_flags);
 	if (count && cloned != count)
 		cloned = -EINVAL;
 	return nfserrno(cloned < 0 ? cloned : 0);
diff --git a/fs/read_write.c b/fs/read_write.c
index 81e0f969da59..c02fc5144d15 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1746,15 +1746,18 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
 		return -EINVAL;
 
-	/* Zero length dedupe exits immediately; reflink goes to EOF. */
-	if (*len == 0) {
+	/*
+	 * If the caller asked to go all the way to the end of the source file,
+	 * set *len now that we have the file locked.
+	 */
+	if (remap_flags & RFR_TO_SRC_EOF) {
 		loff_t isize = i_size_read(inode_in);
 
-		if (is_dedupe || pos_in == isize)
-			return 0;
 		if (pos_in > isize)
 			return -EINVAL;
 		*len = isize - pos_in;
+		if (*len == 0)
+			return 0;
 	}
 
 	/* Check that we don't violate system file offset limits. */
@@ -1844,7 +1847,7 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
 	struct inode *inode_out = file_inode(file_out);
 	loff_t ret;
 
-	WARN_ON_ONCE(remap_flags);
+	WARN_ON_ONCE(remap_flags & ~(RFR_TO_SRC_EOF));
 
 	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
 		return -EISDIR;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index d77b8d90d65e..b9c314f9d5a4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1725,10 +1725,15 @@ struct block_device_operations;
  * These flags control the behavior of the remap_file_range function pointer.
  *
  * RFR_SAME_DATA: only remap if contents identical (i.e. deduplicate)
+ * RFR_TO_SRC_EOF: remap to the end of the source file
  */
 #define RFR_SAME_DATA		(1 << 0)
+#define RFR_TO_SRC_EOF		(1 << 1)
 
-#define RFR_VALID_FLAGS		(RFR_SAME_DATA)
+#define RFR_VALID_FLAGS		(RFR_SAME_DATA | RFR_TO_SRC_EOF)
+
+/* Implemented by the VFS, so these are advisory. */
+#define RFR_VFS_FLAGS		(RFR_TO_SRC_EOF)
 
 /*
  * Filesystem remapping implementations should call this helper on their
@@ -1739,6 +1744,7 @@ struct block_device_operations;
 static inline bool remap_check_flags(unsigned int remap_flags,
 				     unsigned int supported_flags)
 {
+	remap_flags &= ~RFR_VFS_FLAGS;
 	return (remap_flags & ~(supported_flags & RFR_VALID_FLAGS)) == 0;
 }
 
