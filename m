Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9376B0286
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:46:18 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id h38-v6so17814341ywk.20
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:46:18 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m6-v6si6678408yba.340.2018.10.17.15.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:46:17 -0700 (PDT)
Subject: [PATCH 16/29] vfs: enable remap callers that can handle short
 operations
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 17 Oct 2018 15:46:12 -0700
Message-ID: <153981637217.5568.7500888859511338974.stgit@magnolia>
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

Plumb in a remap flag that enables the filesystem remap handler to
shorten remapping requests for callers that can handle it.  Now
copy_file_range can report partial success (in case we run up against
alignment problems, resource limits, etc.).

We also enable CAN_SHORTEN for fideduperange to maintain existing
userspace-visible behavior where xfs/btrfs shorten the dedupe range to
avoid stale post-eof data exposure.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/read_write.c    |   28 ++++++++++++++++++++--------
 include/linux/fs.h |    4 +++-
 mm/filemap.c       |   11 +++++++----
 3 files changed, 30 insertions(+), 13 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index ea30666013b0..c0bcc1a20650 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1593,7 +1593,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 
 		cloned = file_in->f_op->remap_file_range(file_in, pos_in,
 				file_out, pos_out,
-				min_t(loff_t, MAX_RW_COUNT, len), 0);
+				min_t(loff_t, MAX_RW_COUNT, len),
+				REMAP_FILE_CAN_SHORTEN);
 		if (cloned > 0) {
 			ret = cloned;
 			goto done;
@@ -1721,6 +1722,8 @@ static int remap_verify_area(struct file *file, loff_t pos, loff_t len,
  * can't meaningfully compare post-EOF contents.
  *
  * For clone we only link a partial EOF block above the destination file's EOF.
+ *
+ * Shorten the request if possible.
  */
 static int generic_remap_check_len(struct inode *inode_in,
 				   struct inode *inode_out,
@@ -1729,16 +1732,24 @@ static int generic_remap_check_len(struct inode *inode_in,
 				   unsigned int remap_flags)
 {
 	u64 blkmask = i_blocksize(inode_in) - 1;
+	loff_t new_len = *len;
 
 	if ((*len & blkmask) == 0)
 		return 0;
 
-	if (remap_flags & REMAP_FILE_DEDUP)
-		*len &= ~blkmask;
-	else if (pos_out + *len < i_size_read(inode_out))
-		return -EINVAL;
+	if ((remap_flags & REMAP_FILE_DEDUP) ||
+	    pos_out + *len < i_size_read(inode_out))
+		new_len &= ~blkmask;
 
-	return 0;
+	if (new_len == *len)
+		return 0;
+
+	if (remap_flags & REMAP_FILE_CAN_SHORTEN) {
+		*len = new_len;
+		return 0;
+	}
+
+	return (remap_flags & REMAP_FILE_DEDUP) ? -EBADE : -EINVAL;
 }
 
 /*
@@ -2014,7 +2025,8 @@ loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 {
 	loff_t ret;
 
-	WARN_ON_ONCE(remap_flags & ~(REMAP_FILE_DEDUP));
+	WARN_ON_ONCE(remap_flags & ~(REMAP_FILE_DEDUP |
+				     REMAP_FILE_CAN_SHORTEN));
 
 	ret = mnt_want_write_file(dst_file);
 	if (ret)
@@ -2115,7 +2127,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 
 		deduped = vfs_dedupe_file_range_one(file, off, dst_file,
 						    info->dest_offset, len,
-						    0);
+						    REMAP_FILE_CAN_SHORTEN);
 		if (deduped == -EBADE)
 			info->status = FILE_DEDUPE_RANGE_DIFFERS;
 		else if (deduped < 0)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ea2c2f673ecb..0b750e3f8f20 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1726,14 +1726,16 @@ struct block_device_operations;
  * If it is called with len == 0 that means "remap to end of source file".
  *
  * REMAP_FILE_DEDUP: only remap if contents identical (i.e. deduplicate)
+ * REMAP_FILE_CAN_SHORTEN: caller can handle a shortened request
  */
 #define REMAP_FILE_DEDUP		(1 << 0)
+#define REMAP_FILE_CAN_SHORTEN		(1 << 1)
 
 /*
  * These flags should be taken care of by the implementation (possibly using
  * vfs helpers) but can be ignored by the implementation.
  */
-#define REMAP_FILE_ADVISORY		(0)
+#define REMAP_FILE_ADVISORY		(REMAP_FILE_CAN_SHORTEN)
 
 struct iov_iter;
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 1e93269efafe..0731869541ce 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3052,8 +3052,7 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 		bcount = ALIGN(size_in, bs) - pos_in;
 	} else {
 		if (!IS_ALIGNED(count, bs))
-			return -EINVAL;
-
+			count = ALIGN_DOWN(count, bs);
 		bcount = count;
 	}
 
@@ -3063,10 +3062,14 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 	    pos_out < pos_in + bcount)
 		return -EINVAL;
 
-	/* For now we don't support changing the length. */
-	if (*req_count != count)
+	/*
+	 * We shortened the request but the caller can't deal with that, so
+	 * bounce the request back to userspace.
+	 */
+	if (*req_count != count && !(remap_flags & REMAP_FILE_CAN_SHORTEN))
 		return -EINVAL;
 
+	*req_count = count;
 	return 0;
 }
 
