Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 697CA6B006C
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 17:26:10 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so7603478pab.6
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 14:26:10 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id oz9si5542107pdb.15.2015.01.07.14.26.07
        for <linux-mm@kvack.org>;
        Wed, 07 Jan 2015 14:26:08 -0800 (PST)
From: Dave Chinner <david@fromorbit.com>
Subject: [RFC PATCH 6/6] xfs: lock out page faults from extent swap operations
Date: Thu,  8 Jan 2015 09:25:43 +1100
Message-Id: <1420669543-8093-7-git-send-email-david@fromorbit.com>
In-Reply-To: <1420669543-8093-1-git-send-email-david@fromorbit.com>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xfs@oss.sgi.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

Extent swap operations are another extent manipulation operation
that we need to ensure does not race against mmap page faults. The
current code returns if the file is mapped prior to the swap being
done, but it could potentially race against new page faults while
the swap is in progress. Hence we should use the XFS_MMAPLOCK_EXCL
for this operation, too.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_bmap_util.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index 22a5dcb..1420caf 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -1599,13 +1599,6 @@ xfs_swap_extent_flush(
 	/* Verify O_DIRECT for ftmp */
 	if (VFS_I(ip)->i_mapping->nrpages)
 		return -EINVAL;
-
-	/*
-	 * Don't try to swap extents on mmap()d files because we can't lock
-	 * out races against page faults safely.
-	 */
-	if (mapping_mapped(VFS_I(ip)->i_mapping))
-		return -EBUSY;
 	return 0;
 }
 
@@ -1633,13 +1626,14 @@ xfs_swap_extents(
 	}
 
 	/*
-	 * Lock up the inodes against other IO and truncate to begin with.
-	 * Then we can ensure the inodes are flushed and have no page cache
-	 * safely. Once we have done this we can take the ilocks and do the rest
-	 * of the checks.
+	 * Lock the inodes against other IO, page faults and truncate to
+	 * begin with.  Then we can ensure the inodes are flushed and have no
+	 * page cache safely. Once we have done this we can take the ilocks and
+	 * do the rest of the checks.
 	 */
-	lock_flags = XFS_IOLOCK_EXCL;
+	lock_flags = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
 	xfs_lock_two_inodes(ip, tip, XFS_IOLOCK_EXCL);
+	xfs_lock_two_inodes(ip, tip, XFS_MMAPLOCK_EXCL);
 
 	/* Verify that both files have the same format */
 	if ((ip->i_d.di_mode & S_IFMT) != (tip->i_d.di_mode & S_IFMT)) {
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
