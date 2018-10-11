Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 881D66B0288
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 00:14:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f4-v6so6747223pff.2
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:14:25 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u12-v6si27737269pfd.66.2018.10.10.21.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 21:14:24 -0700 (PDT)
Subject: [PATCH 16/25] vfs: make remapping to source file eof more explicit
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 10 Oct 2018 21:14:19 -0700
Message-ID: <153923125910.5546.5091507666171734847.stgit@magnolia>
In-Reply-To: <153923113649.5546.9840926895953408273.stgit@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
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
index a360274b0cdc..6ec908f9a69b 100644
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
@@ -1849,7 +1852,7 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
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
 
