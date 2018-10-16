Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D36C6B0280
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 23:20:01 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e6-v6so16117803pge.5
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:20:01 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id m63-v6si11832523pld.379.2018.10.15.20.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 20:20:00 -0700 (PDT)
Subject: [PATCH 17/26] vfs: enable remap callers that can handle short
 operations
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Mon, 15 Oct 2018 20:19:54 -0700
Message-ID: <153965999426.3607.3221368918901209000.stgit@magnolia>
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
 include/linux/fs.h |    7 +++++--
 mm/filemap.c       |   16 ++++++++++++----
 3 files changed, 37 insertions(+), 14 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index f6ab5beb935a..ee9314b7bfc3 100644
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
 
 /* Update inode timestamps and remove security privileges when remapping. */
@@ -2023,7 +2034,8 @@ loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 {
 	loff_t ret;
 
-	WARN_ON_ONCE(remap_flags & ~(REMAP_FILE_DEDUP));
+	WARN_ON_ONCE(remap_flags & ~(REMAP_FILE_DEDUP |
+				     REMAP_FILE_CAN_SHORTEN));
 
 	ret = mnt_want_write_file(dst_file);
 	if (ret)
@@ -2124,7 +2136,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 
 		deduped = vfs_dedupe_file_range_one(file, off, dst_file,
 						    info->dest_offset, len,
-						    0);
+						    REMAP_FILE_CAN_SHORTEN);
 		if (deduped == -EBADE)
 			info->status = FILE_DEDUPE_RANGE_DIFFERS;
 		else if (deduped < 0)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c0ae85a7bd9d..594fe4ba0b15 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1726,14 +1726,17 @@ struct block_device_operations;
  * If it is called with len == 0 that means "remap to end of source file".
  *
  * REMAP_FILE_DEDUP: only remap if contents identical (i.e. deduplicate)
+ * REMAP_FILE_CAN_SHORTEN: caller can handle a shortened request
  */
 #define REMAP_FILE_DEDUP		(1 << 0)
+#define REMAP_FILE_CAN_SHORTEN		(1 << 1)
 
 /* All valid REMAP_FILE flags */
-#define REMAP_FILE_VALID_FLAGS		(REMAP_FILE_DEDUP)
+#define REMAP_FILE_VALID_FLAGS		(REMAP_FILE_DEDUP | \
+					 REMAP_FILE_CAN_SHORTEN)
 
 /* REMAP_FILE flags taken care of by the vfs. */
-#define REMAP_FILE_ADVISORY		(0)
+#define REMAP_FILE_ADVISORY		(REMAP_FILE_CAN_SHORTEN)
 
 struct iov_iter;
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 1e93269efafe..898eb358f7d2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3051,8 +3051,12 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 	if (pos_in + count == size_in) {
 		bcount = ALIGN(size_in, bs) - pos_in;
 	} else {
-		if (!IS_ALIGNED(count, bs))
-			return -EINVAL;
+		if (!IS_ALIGNED(count, bs)) {
+			if (remap_flags & REMAP_FILE_CAN_SHORTEN)
+				count = ALIGN_DOWN(count, bs);
+			else
+				return -EINVAL;
+		}
 
 		bcount = count;
 	}
@@ -3063,10 +3067,14 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
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
 
