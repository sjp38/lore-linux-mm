Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 987146B0071
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 17:26:13 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so7591884pac.8
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 14:26:13 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id sj1si5447303pbc.68.2015.01.07.14.26.10
        for <linux-mm@kvack.org>;
        Wed, 07 Jan 2015 14:26:12 -0800 (PST)
From: Dave Chinner <david@fromorbit.com>
Subject: [RFC PATCH 5/6] xfs: xfs_setattr_size no longer races with page faults
Date: Thu,  8 Jan 2015 09:25:42 +1100
Message-Id: <1420669543-8093-6-git-send-email-david@fromorbit.com>
In-Reply-To: <1420669543-8093-1-git-send-email-david@fromorbit.com>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xfs@oss.sgi.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

Now that truncate locks out new page faults, we no longer need to do
special writeback hacks in truncate to work around potential races
between page faults, page cache truncation and file size updates to
ensure we get write page faults for extending truncates on sub-page
block size filesystems. Hence we can remove the code in
xfs_setattr_size() that handles this and update the comments around
the code tha thandles page cache truncate and size updates to
reflect the new reality.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_iops.c | 56 ++++++++++++++-----------------------------------------
 1 file changed, 14 insertions(+), 42 deletions(-)

diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index f491860..a3b130f 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -841,55 +841,27 @@ xfs_setattr_size(
 	inode_dio_wait(inode);
 
 	/*
-	 * Do all the page cache truncate work outside the transaction context
-	 * as the "lock" order is page lock->log space reservation.  i.e.
-	 * locking pages inside the transaction can ABBA deadlock with
-	 * writeback. We have to do the VFS inode size update before we truncate
-	 * the pagecache, however, to avoid racing with page faults beyond the
-	 * new EOF they are not serialised against truncate operations except by
-	 * page locks and size updates.
+	 * We've already locked out new page faults, so now we can safely remove
+	 * pages from the page cache knowing they won't get refaulted until we
+	 * drop the XFS_MMAP_EXCL lock after the extent manipulations are
+	 * complete. The truncate_setsize() call also cleans partial EOF page
+	 * PTEs on extending truncates and hence ensures sub-page block size
+	 * filesystems are correctly handled, too.
 	 *
-	 * Hence we are in a situation where a truncate can fail with ENOMEM
-	 * from xfs_trans_reserve(), but having already truncated the in-memory
-	 * version of the file (i.e. made user visible changes). There's not
-	 * much we can do about this, except to hope that the caller sees ENOMEM
-	 * and retries the truncate operation.
+	 * We have to do all the page cache truncate work outside the
+	 * transaction context as the "lock" order is page lock->log space
+	 * reservation as defined by extent allocation in the writeback path.
+	 * Hence a truncate can fail with ENOMEM from xfs_trans_reserve(), but
+	 * having already truncated the in-memory version of the file (i.e. made
+	 * user visible changes). There's not much we can do about this, except
+	 * to hope that the caller sees ENOMEM and retries the truncate
+	 * operation.
 	 */
 	error = block_truncate_page(inode->i_mapping, newsize, xfs_get_blocks);
 	if (error)
 		return error;
 	truncate_setsize(inode, newsize);
 
-	/*
-	 * The "we can't serialise against page faults" pain gets worse.
-	 *
-	 * If the file is mapped then we have to clean the page at the old EOF
-	 * when extending the file. Extending the file can expose changes the
-	 * underlying page mapping (e.g. from beyond EOF to a hole or
-	 * unwritten), and so on the next attempt to write to that page we need
-	 * to remap it for write. i.e. we need .page_mkwrite() to be called.
-	 * Hence we need to clean the page to clean the pte and so a new write
-	 * fault will be triggered appropriately.
-	 *
-	 * If we do it before we change the inode size, then we can race with a
-	 * page fault that maps the page with exactly the same problem. If we do
-	 * it after we change the file size, then a new page fault can come in
-	 * and allocate space before we've run the rest of the truncate
-	 * transaction. That's kinda grotesque, but it's better than have data
-	 * over a hole, and so that's the lesser evil that has been chosen here.
-	 *
-	 * The real solution, however, is to have some mechanism for locking out
-	 * page faults while a truncate is in progress.
-	 */
-	if (newsize > oldsize && mapping_mapped(VFS_I(ip)->i_mapping)) {
-		error = filemap_write_and_wait_range(
-				VFS_I(ip)->i_mapping,
-				round_down(oldsize, PAGE_CACHE_SIZE),
-				round_up(oldsize, PAGE_CACHE_SIZE) - 1);
-		if (error)
-			return error;
-	}
-
 	tp = xfs_trans_alloc(mp, XFS_TRANS_SETATTR_SIZE);
 	error = xfs_trans_reserve(tp, &M_RES(mp)->tr_itruncate, 0, 0);
 	if (error)
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
