Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E80D26B027B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 12:05:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r67-v6so8408376pfd.21
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:05:39 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q1-v6si31427717pfb.258.2018.10.11.09.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 09:05:38 -0700 (PDT)
Date: Thu, 11 Oct 2018 09:05:28 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: [PATCH v2 17/25] vfs: enable remap callers that can handle short
 operations
Message-ID: <20181011160528.GB28243@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923126628.5546.3484461137192547927.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153923126628.5546.3484461137192547927.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
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
v2: fix missing WARN_ON_ONCE and update changelog
---
 fs/read_write.c    |   17 ++++++++++-------
 include/linux/fs.h |    7 +++++--
 mm/filemap.c       |   16 ++++++++++++----
 3 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 6ec908f9a69b..9d33f0a14720 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1593,7 +1593,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 
 		cloned = file_in->f_op->remap_file_range(file_in, pos_in,
 				file_out, pos_out,
-				min_t(loff_t, MAX_RW_COUNT, len), 0);
+				min_t(loff_t, MAX_RW_COUNT, len),
+				RFR_CAN_SHORTEN);
 		if (cloned > 0) {
 			ret = cloned;
 			goto done;
@@ -1804,16 +1805,18 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 		 * If the user is attempting to remap a partial EOF block and
 		 * it's inside the destination EOF then reject it.
 		 *
-		 * We don't support shortening requests, so we can only reject
-		 * them.
+		 * If possible, shorten the request instead of rejecting it.
 		 */
 		if (is_dedupe)
 			ret = -EBADE;
 		else if (pos_out + *len < i_size_read(inode_out))
 			ret = -EINVAL;
 
-		if (ret)
-			return ret;
+		if (ret) {
+			if (!(remap_flags & RFR_CAN_SHORTEN))
+				return ret;
+			*len &= ~blkmask;
+		}
 	}
 
 	return 1;
@@ -2011,7 +2014,7 @@ loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 {
 	loff_t ret;
 
-	WARN_ON_ONCE(remap_flags & ~(RFR_SAME_DATA));
+	WARN_ON_ONCE(remap_flags & ~(RFR_SAME_DATA | RFR_CAN_SHORTEN));
 
 	ret = mnt_want_write_file(dst_file);
 	if (ret)
@@ -2112,7 +2115,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 
 		deduped = vfs_dedupe_file_range_one(file, off, dst_file,
 						    info->dest_offset, len,
-						    0);
+						    RFR_CAN_SHORTEN);
 		if (deduped == -EBADE)
 			info->status = FILE_DEDUPE_RANGE_DIFFERS;
 		else if (deduped < 0)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b9c314f9d5a4..57cb56bbc30a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1726,14 +1726,17 @@ struct block_device_operations;
  *
  * RFR_SAME_DATA: only remap if contents identical (i.e. deduplicate)
  * RFR_TO_SRC_EOF: remap to the end of the source file
+ * RFR_CAN_SHORTEN: caller can handle a shortened request
  */
 #define RFR_SAME_DATA		(1 << 0)
 #define RFR_TO_SRC_EOF		(1 << 1)
+#define RFR_CAN_SHORTEN		(1 << 2)
 
-#define RFR_VALID_FLAGS		(RFR_SAME_DATA | RFR_TO_SRC_EOF)
+#define RFR_VALID_FLAGS		(RFR_SAME_DATA | RFR_TO_SRC_EOF | \
+				 RFR_CAN_SHORTEN)
 
 /* Implemented by the VFS, so these are advisory. */
-#define RFR_VFS_FLAGS		(RFR_TO_SRC_EOF)
+#define RFR_VFS_FLAGS		(RFR_TO_SRC_EOF | RFR_CAN_SHORTEN)
 
 /*
  * Filesystem remapping implementations should call this helper on their
diff --git a/mm/filemap.c b/mm/filemap.c
index 369cfd164e90..bccbd3621238 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3051,8 +3051,12 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 	if (pos_in + count == size_in) {
 		bcount = ALIGN(size_in, bs) - pos_in;
 	} else {
-		if (!IS_ALIGNED(count, bs))
-			return -EINVAL;
+		if (!IS_ALIGNED(count, bs)) {
+			if (remap_flags & RFR_CAN_SHORTEN)
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
+	if (*req_count != count && !(remap_flags & RFR_CAN_SHORTEN))
 		return -EINVAL;
 
+	*req_count = count;
 	return 0;
 }
 
