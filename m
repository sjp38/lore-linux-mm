Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE346B029C
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 00:15:31 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k21-v6so7361759qtj.23
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:15:31 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t29-v6si2029355qvc.47.2018.10.10.21.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 21:15:30 -0700 (PDT)
Subject: [PATCH 25/25] xfs: remove redundant remap partial EOF block checks
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 10 Oct 2018 21:15:26 -0700
Message-ID: <153923132645.5546.97372209609060021.stgit@magnolia>
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

Now that we've moved the partial EOF block checks to the VFS helpers, we
can remove the redundantn functionality from XFS.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_reflink.c |   20 --------------------
 1 file changed, 20 deletions(-)


diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index 12a1fe92454e..4450443f1148 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1307,8 +1307,6 @@ xfs_reflink_remap_prep(
 	struct inode		*inode_out = file_inode(file_out);
 	struct xfs_inode	*dest = XFS_I(inode_out);
 	bool			same_inode = (inode_in == inode_out);
-	bool			is_dedupe = (remap_flags & RFR_SAME_DATA);
-	u64			blkmask = i_blocksize(inode_in) - 1;
 	ssize_t			ret;
 
 	/* Lock both files against IO */
@@ -1336,24 +1334,6 @@ xfs_reflink_remap_prep(
 	if (ret <= 0)
 		goto out_unlock;
 
-	/*
-	 * If the dedupe data matches, chop off the partial EOF block
-	 * from the source file so we don't try to dedupe the partial
-	 * EOF block.
-	 */
-	if (is_dedupe) {
-		*len &= ~blkmask;
-	} else if (*len & blkmask) {
-		/*
-		 * The user is attempting to share a partial EOF block,
-		 * if it's inside the destination EOF then reject it.
-		 */
-		if (pos_out + *len < i_size_read(inode_out)) {
-			ret = -EINVAL;
-			goto out_unlock;
-		}
-	}
-
 	/* Attach dquots to dest inode before changing block map */
 	ret = xfs_qm_dqattach(dest);
 	if (ret)
