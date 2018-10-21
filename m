Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1946B028F
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:18:27 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id n143-v6so25632140ywd.6
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:18:27 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r15-v6si4109218ybm.475.2018.10.21.09.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:18:26 -0700 (PDT)
Subject: [PATCH 28/28] xfs: remove [cm]time update from reflink calls
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:18:17 -0700
Message-ID: <154013869780.29026.674362788764806472.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Now that the vfs remap helper dirties the inode [cm]time for us, xfs no
longer needs to do that on its own.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_reflink.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)


diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index 84f372f7ea04..e72218477bf2 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -927,8 +927,7 @@ xfs_reflink_update_dest(
 	struct xfs_trans	*tp;
 	int			error;
 
-	if ((remap_flags & REMAP_FILE_DEDUP) &&
-	    newlen <= i_size_read(VFS_I(dest)) && cowextsize == 0)
+	if (newlen <= i_size_read(VFS_I(dest)) && cowextsize == 0)
 		return 0;
 
 	error = xfs_trans_alloc(mp, &M_RES(mp)->tr_ichange, 0, 0, 0, &tp);
@@ -949,10 +948,6 @@ xfs_reflink_update_dest(
 		dest->i_d.di_flags2 |= XFS_DIFLAG2_COWEXTSIZE;
 	}
 
-	if (!(remap_flags & REMAP_FILE_DEDUP)) {
-		xfs_trans_ichgtime(tp, dest,
-				   XFS_ICHGTIME_MOD | XFS_ICHGTIME_CHG);
-	}
 	xfs_trans_log_inode(tp, dest, XFS_ILOG_CORE);
 
 	error = xfs_trans_commit(tp);
