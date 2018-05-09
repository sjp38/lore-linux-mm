Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E239B6B0359
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:49:32 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bd7-v6so3308560plb.20
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:49:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g63-v6si16723452pgc.40.2018.05.09.00.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:49:31 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 16/33] xfs: move locking into xfs_bmap_punch_delalloc_range
Date: Wed,  9 May 2018 09:48:13 +0200
Message-Id: <20180509074830.16196-17-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Both callers want the same looking, so do it only once.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c      | 2 --
 fs/xfs/xfs_bmap_util.c | 7 ++++---
 fs/xfs/xfs_iomap.c     | 3 ---
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 313449ac0288..196c5daa6dce 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -761,10 +761,8 @@ xfs_aops_discard_page(
 		"page discard on page "PTR_FMT", inode 0x%llx, offset %llu.",
 			page, ip->i_ino, offset);
 
-	xfs_ilock(ip, XFS_ILOCK_EXCL);
 	error = xfs_bmap_punch_delalloc_range(ip, start_fsb,
 			PAGE_SIZE / i_blocksize(inode));
-	xfs_iunlock(ip, XFS_ILOCK_EXCL);
 	if (error && !XFS_FORCED_SHUTDOWN(mp))
 		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
 out_invalidate:
diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index 7d2ba4cc8fba..82189ea97319 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -711,12 +711,11 @@ xfs_bmap_punch_delalloc_range(
 	struct xfs_iext_cursor	icur;
 	int			error = 0;
 
-	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
-
+	xfs_ilock(ip, XFS_ILOCK_EXCL);
 	if (!(ifp->if_flags & XFS_IFEXTENTS)) {
 		error = xfs_iread_extents(NULL, ip, XFS_DATA_FORK);
 		if (error)
-			return error;
+			goto out_unlock;
 	}
 
 	if (!xfs_iext_lookup_extent(ip, ifp, start_fsb, &icur, &got))
@@ -738,6 +737,8 @@ xfs_bmap_punch_delalloc_range(
 			break;
 	} while (xfs_iext_next_extent(ifp, &icur, &got));
 
+out_unlock:
+	xfs_iunlock(ip, XFS_ILOCK_EXCL);
 	return error;
 }
 
diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
index 046469fcc1b8..407bbd978d1b 100644
--- a/fs/xfs/xfs_iomap.c
+++ b/fs/xfs/xfs_iomap.c
@@ -1167,11 +1167,8 @@ xfs_file_iomap_end_delalloc(
 		truncate_pagecache_range(VFS_I(ip), XFS_FSB_TO_B(mp, start_fsb),
 					 XFS_FSB_TO_B(mp, end_fsb) - 1);
 
-		xfs_ilock(ip, XFS_ILOCK_EXCL);
 		error = xfs_bmap_punch_delalloc_range(ip, start_fsb,
 					       end_fsb - start_fsb);
-		xfs_iunlock(ip, XFS_ILOCK_EXCL);
-
 		if (error && !XFS_FORCED_SHUTDOWN(mp)) {
 			xfs_alert(mp, "%s: unable to clean up ino %lld",
 				__func__, ip->i_ino);
-- 
2.17.0
