Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CB9046B02A4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 10:04:46 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 1/2] xfs: fix shrinker build
Date: Sat, 24 Jul 2010 00:04:01 +1000
Message-Id: <1279893842-4246-2-git-send-email-david@fromorbit.com>
In-Reply-To: <20100723111310.GI32635@dastard>
References: <20100723111310.GI32635@dastard>
Sender: owner-linux-mm@kvack.org
To: npiggin@kernel.dk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fmayhar@google.com, johnstul@us.ibm.com
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Remove the stray mount list lock reference from the shrinker code.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/linux-2.6/xfs_sync.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index 7a5a368..05426bf 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -916,10 +916,8 @@ xfs_reclaim_inode_shrink(
 
 done:
 	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
-	if (!nr) {
-		up_read(&xfs_mount_list_lock);
+	if (!nr)
 		return 0;
-	}
 	xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
 				XFS_ICI_RECLAIM_TAG, 1, &nr);
 	/* if we don't exhaust the scan, don't bother coming back */
@@ -935,7 +933,6 @@ xfs_inode_shrinker_register(
 	struct xfs_mount	*mp)
 {
 	mp->m_inode_shrink.shrink = xfs_reclaim_inode_shrink;
-	mp->m_inode_shrink.seeks = DEFAULT_SEEKS;
 	register_shrinker(&mp->m_inode_shrink);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
