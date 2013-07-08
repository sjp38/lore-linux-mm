Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 41D4A6B0034
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 02:34:29 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH] [MMOTM] xfs: fix dquot isolation hang
Date: Mon,  8 Jul 2013 16:34:21 +1000
Message-Id: <1373265261-30314-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, glommer@openvz.org, mhocko@suze.cz

From: Dave Chinner <dchinner@redhat.com>

The new LRU list isolation code in xfs_qm_dquot_isolate() isn't
completely up to date.  Firstly, it needs conversion to return enum
lru_status values, not raw numbers. Secondly - most importantly - it
fails to unlock the dquot and relock the LRU in the LRU_RETRY path.
This leads to deadlocks in xfstests generic/232. Fix them.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_qm.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 46743cf..a10a720 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -659,7 +659,7 @@ xfs_qm_dquot_isolate(
 		trace_xfs_dqreclaim_want(dqp);
 		list_del_init(&dqp->q_lru);
 		XFS_STATS_DEC(xs_qm_dquot_unused);
-		return 0;
+		return LRU_REMOVED;
 	}
 
 	/*
@@ -705,17 +705,19 @@ xfs_qm_dquot_isolate(
 	XFS_STATS_DEC(xs_qm_dquot_unused);
 	trace_xfs_dqreclaim_done(dqp);
 	XFS_STATS_INC(xs_qm_dqreclaims);
-	return 0;
+	return LRU_REMOVED;
 
 out_miss_busy:
 	trace_xfs_dqreclaim_busy(dqp);
 	XFS_STATS_INC(xs_qm_dqreclaim_misses);
-	return 2;
+	return LRU_SKIP;
 
 out_unlock_dirty:
 	trace_xfs_dqreclaim_busy(dqp);
 	XFS_STATS_INC(xs_qm_dqreclaim_misses);
-	return 3;
+	xfs_dqunlock(dqp);
+	spin_lock(lru_lock);
+	return LRU_RETRY;
 }
 
 static unsigned long
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
