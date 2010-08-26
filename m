Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC476B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 11:14:20 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/3] writeback: Do not congestion sleep when there are no congested BDIs
Date: Thu, 26 Aug 2010 16:14:16 +0100
Message-Id: <1282835656-5638-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If congestion_wait() is called with no BDIs congested, the caller will
sleep for the full timeout and this is an unnecessary sleep. This patch
checks if there are BDIs congested. If so, it goes to sleep as normal.
If not, it calls cond_resched() to ensure the caller is not hogging the
CPU longer than its quota but otherwise will not sleep.

This is aimed at reducing some of the major desktop stalls reported during
IO. For example, while kswapd is operating, it calls congestion_wait()
but it could just have been reclaiming clean page cache pages with no
congestion. Without this patch, it would sleep for a full timeout but after
this patch, it'll just call schedule() if it has been on the CPU too long.
Similar logic applies to direct reclaimers that are not making enough
progress.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/backing-dev.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index a49167f..6abe860 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -767,13 +767,21 @@ long congestion_wait(int sync, long timeout)
 	DEFINE_WAIT(wait);
 	wait_queue_head_t *wqh = &congestion_wqh[sync];
 
-	/* Check if this call to congestion_wait was necessary */
-	if (atomic_read(&nr_bdi_congested[sync]) == 0)
+	/*
+	 * If there is no congestion, there is no point sleeping on the queue.
+	 * This call was unecessary but in case we are spinning due to a bad
+	 * caller, at least call cond_reched() and sleep if our CPU quota
+	 * has expired
+	 */
+	if (atomic_read(&nr_bdi_congested[sync]) == 0) {
 		unnecessary = true;
-
-	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
-	ret = io_schedule_timeout(timeout);
-	finish_wait(wqh, &wait);
+		cond_resched();
+		ret = 0;
+	} else {
+		prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
+		ret = io_schedule_timeout(timeout);
+		finish_wait(wqh, &wait);
+	}
 
 	trace_writeback_congest_waited(jiffies_to_usecs(jiffies - start),
 			unnecessary);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
