Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65E456B026B
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 20:06:27 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q6-v6so13962098qtb.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:06:27 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id e55-v6si2490465qvd.50.2018.10.12.17.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 17:06:26 -0700 (PDT)
Subject: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Fri, 12 Oct 2018 17:06:17 -0700
Message-ID: <153938917765.8361.15966712047859994604.stgit@magnolia>
In-Reply-To: <153938912912.8361.13446310416406388958.stgit@magnolia>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

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
---
 fs/read_write.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)


diff --git a/fs/read_write.c b/fs/read_write.c
index d6e8e242a15f..067ff5698e0b 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1723,6 +1723,7 @@ int vfs_clone_file_prep(struct file *file_in, loff_t pos_in,
 {
 	struct inode *inode_in = file_inode(file_in);
 	struct inode *inode_out = file_inode(file_out);
+	u64 blkmask = i_blocksize(inode_in) - 1;
 	bool same_inode = (inode_in == inode_out);
 	int ret;
 
@@ -1785,6 +1786,22 @@ int vfs_clone_file_prep(struct file *file_in, loff_t pos_in,
 			return -EBADE;
 	}
 
+	/* Are we doing a partial EOF block remapping of some kind? */
+	if (*len & blkmask) {
+		/*
+		 * If the dedupe data matches, chop off the partial EOF block
+		 * from the source file so we don't try to dedupe the partial
+		 * EOF block.
+		 *
+		 * If the user is attempting to remap a partial EOF block and
+		 * it's inside the destination EOF then reject it.
+		 */
+		if (is_dedupe)
+			*len &= ~blkmask;
+		else if (pos_out + *len < i_size_read(inode_out))
+			return -EINVAL;
+	}
+
 	return 1;
 }
 EXPORT_SYMBOL(vfs_clone_file_prep);
