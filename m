Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1015B6B000E
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:15:44 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id c6-v6so23253544ybm.10
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:15:44 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g9-v6si2511560ybi.174.2018.10.21.09.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:15:42 -0700 (PDT)
Subject: [PATCH 05/28] vfs: avoid problematic remapping requests into
 partial EOF block
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:15:37 -0700
Message-ID: <154013853780.29026.5441191187672186537.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

A deduplication data corruption is exposed in XFS and btrfs. It is
caused by extending the block match range to include the partial EOF
block, but then allowing unknown data beyond EOF to be considered a
"match" to data in the destination file because the comparison is only
made to the end of the source file. This corrupts the destination file
when the source extent is shared with it.

The VFS remapping prep functions  only support whole block dedupe, but
we still need to appear to support whole file dedupe correctly.  Hence
if the dedupe request includes the last block of the souce file, don't
include it in the actual dedupe operation. If the rest of the range
dedupes successfully, then reject the entire request.  A subsequent
patch will enable us to shorten dedupe requests correctly.

When reflinking sub-file ranges, a data corruption can occur when the
source file range includes a partial EOF block. This shares the unknown
data beyond EOF into the second file at a position inside EOF, exposing
stale data in the second file.

If the reflink request includes the last block of the souce file, only
proceed with the reflink operation if it lands at or past the
destination file's current EOF. If it lands within the destination file
EOF, reject the entire request with -EINVAL and make the caller go the
hard way.  A subsequent patch will enable us to shorten reflink requests
correctly.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)


diff --git a/fs/read_write.c b/fs/read_write.c
index 2456da3f8a41..0f0a6efdd502 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1708,6 +1708,34 @@ static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
 
 	return security_file_permission(file, write ? MAY_WRITE : MAY_READ);
 }
+/*
+ * Ensure that we don't remap a partial EOF block in the middle of something
+ * else.  Assume that the offsets have already been checked for block
+ * alignment.
+ *
+ * For deduplication we always scale down to the previous block because we
+ * can't meaningfully compare post-EOF contents.
+ *
+ * For clone we only link a partial EOF block above the destination file's EOF.
+ */
+static int generic_remap_check_len(struct inode *inode_in,
+				   struct inode *inode_out,
+				   loff_t pos_out,
+				   u64 *len,
+				   bool is_dedupe)
+{
+	u64 blkmask = i_blocksize(inode_in) - 1;
+
+	if ((*len & blkmask) == 0)
+		return 0;
+
+	if (is_dedupe)
+		*len &= ~blkmask;
+	else if (pos_out + *len < i_size_read(inode_out))
+		return -EINVAL;
+
+	return 0;
+}
 
 /*
  * Check that the two inodes are eligible for cloning, the ranges make
@@ -1787,6 +1815,11 @@ int vfs_clone_file_prep(struct file *file_in, loff_t pos_in,
 			return -EBADE;
 	}
 
+	ret = generic_remap_check_len(inode_in, inode_out, pos_out, len,
+			is_dedupe);
+	if (ret)
+		return ret;
+
 	return 1;
 }
 EXPORT_SYMBOL(vfs_clone_file_prep);
