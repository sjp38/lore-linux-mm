Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABDBD6B0283
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:14:07 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z28-v6so3093609pff.4
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:14:07 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d31-v6si24205256pla.256.2018.10.09.17.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:14:06 -0700 (PDT)
Subject: [PATCH 17/25] vfs: make remapping to source file eof more explicit
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Tue, 09 Oct 2018 17:13:57 -0700
Message-ID: <153913043746.32295.17463515265798256890.stgit@magnolia>
In-Reply-To: <153913023835.32295.13962696655740190941.stgit@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Create a RFR_TO_SRC_EOF flag to explicitly declare that the caller wants
the remap implementation to remap to the end of the source file, once
the files are locked.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/ioctl.c         |    3 ++-
 fs/nfsd/vfs.c      |    3 ++-
 fs/read_write.c    |   13 +++++++------
 include/linux/fs.h |    2 ++
 4 files changed, 13 insertions(+), 8 deletions(-)


diff --git a/fs/ioctl.c b/fs/ioctl.c
index 505275ec5596..7fec997abd2f 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -224,6 +224,7 @@ static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
 {
 	struct fd src_file = fdget(srcfd);
 	loff_t cloned;
+	unsigned int flags = olen == 0 ? RFR_TO_SRC_EOF : 0;
 	int ret;
 
 	if (!src_file.file)
@@ -232,7 +233,7 @@ static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
 	if (src_file.file->f_path.mnt != dst_file->f_path.mnt)
 		goto fdput;
 	cloned = vfs_clone_file_range(src_file.file, off, dst_file, destoff,
-				      olen, 0);
+				      olen, flags);
 	if (cloned < 0)
 		ret = cloned;
 	else if (olen && cloned != olen)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 726fc5b2b27a..d1f2ae08adf6 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -542,8 +542,9 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
 		u64 dst_pos, u64 count)
 {
 	loff_t cloned;
+	unsigned int flags = count == 0 ? RFR_TO_SRC_EOF : 0;
 
-	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, 0);
+	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, flags);
 	if (count && cloned != count)
 		cloned = -EINVAL;
 	return nfserrno(cloned < 0 ? cloned : 0);
diff --git a/fs/read_write.c b/fs/read_write.c
index 479eb810c8e6..a628fd9a47cf 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1748,11 +1748,12 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 
 	isize = i_size_read(inode_in);
 
-	/* Zero length dedupe exits immediately; reflink goes to EOF. */
-	if (*len == 0) {
-		if (is_dedupe || pos_in == isize)
-			return 0;
-		if (pos_in > isize)
+	/*
+	 * If the caller asked to go all the way to the end of the source file,
+	 * set *len now that we have the file locked.
+	 */
+	if (remap_flags & RFR_TO_SRC_EOF) {
+		if (pos_in >= isize)
 			return -EINVAL;
 		*len = isize - pos_in;
 	}
@@ -1828,7 +1829,7 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
 	struct inode *inode_out = file_inode(file_out);
 	loff_t ret;
 
-	WARN_ON_ONCE(remap_flags);
+	WARN_ON_ONCE(remap_flags & ~(RFR_TO_SRC_EOF));
 
 	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
 		return -EISDIR;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5c1bf1c35bc6..9f90dcd4df3b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1725,8 +1725,10 @@ struct block_device_operations;
  * These flags control the behavior of the remap_file_range function pointer.
  *
  * RFR_IDENTICAL_DATA: only remap if contents identical (i.e. deduplicate)
+ * RFR_TO_SRC_EOF: remap to the end of the source file
  */
 #define RFR_IDENTICAL_DATA	(1 << 0)
+#define RFR_TO_SRC_EOF		(1 << 1)
 
 struct iov_iter;
 
