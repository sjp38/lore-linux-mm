Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6CA06B0275
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 00:13:10 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y201-v6so7152950qka.1
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:13:10 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id l9-v6si571189qtq.254.2018.10.10.21.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 21:13:09 -0700 (PDT)
Subject: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 10 Oct 2018 21:12:54 -0700
Message-ID: <153923117420.5546.13317703807467393934.stgit@magnolia>
In-Reply-To: <153923113649.5546.9840926895953408273.stgit@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

A deduplication data corruption is exposed by fstests generic/505 on
XFS. It is caused by extending the block match range to include the
partial EOF block, but then allowing unknown data beyond EOF to be
considered a "match" to data in the destination file because the
comparison is only made to the end of the source file. This corrupts the
destination file when the source extent is shared with it.

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
---
 fs/read_write.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)


diff --git a/fs/read_write.c b/fs/read_write.c
index d6e8e242a15f..8498991e2f33 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1723,6 +1723,7 @@ int vfs_clone_file_prep(struct file *file_in, loff_t pos_in,
 {
 	struct inode *inode_in = file_inode(file_in);
 	struct inode *inode_out = file_inode(file_out);
+	u64 blkmask = i_blocksize(inode_in) - 1;
 	bool same_inode = (inode_in == inode_out);
 	int ret;
 
@@ -1785,6 +1786,27 @@ int vfs_clone_file_prep(struct file *file_in, loff_t pos_in,
 			return -EBADE;
 	}
 
+	/* Are we doing a partial EOF block remapping of some kind? */
+	if (*len & blkmask) {
+		/*
+		 * If the dedupe data matches, don't try to dedupe the partial
+		 * EOF block.
+		 *
+		 * If the user is attempting to remap a partial EOF block and
+		 * it's inside the destination EOF then reject it.
+		 *
+		 * We don't support shortening requests, so we can only reject
+		 * them.
+		 */
+		if (is_dedupe)
+			ret = -EBADE;
+		else if (pos_out + *len < i_size_read(inode_out))
+			ret = -EINVAL;
+
+		if (ret)
+			return ret;
+	}
+
 	return 1;
 }
 EXPORT_SYMBOL(vfs_clone_file_prep);
