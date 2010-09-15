Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D853A6B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 08:28:01 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 7/8] writeback: Do not sleep on the congestion queue if there are no congested BDIs
Date: Wed, 15 Sep 2010 13:27:50 +0100
Message-Id: <1284553671-31574-8-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1284553671-31574-1-git-send-email-mel@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

If congestion_wait() is called with no BDI congested, the caller will sleep
for the full timeout and this may be an unnecessary sleep. This patch adds
a wait_iff_congested() that checks congestion and only sleeps if a BDI is
congested else, it calls cond_resched() to ensure the caller is not hogging
the CPU longer than its quota but otherwise will not sleep.

This is aimed at reducing some of the major desktop stalls reported during
IO. For example, while kswapd is operating, it calls congestion_wait()
but it could just have been reclaiming clean page cache pages with no
congestion. Without this patch, it would sleep for a full timeout but after
this patch, it'll just call schedule() if it has been on the CPU too long.
Similar logic applies to direct reclaimers that are not making enough
progress.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/backing-dev.h      |    2 +-
 include/trace/events/writeback.h |    7 +++++
 mm/backing-dev.c                 |   54 ++++++++++++++++++++++++++++++++++++-
 mm/page_alloc.c                  |    4 +-
 4 files changed, 62 insertions(+), 5 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 35b0074..72bb510 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -285,7 +285,7 @@ enum {
 void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
 void set_bdi_congested(struct backing_dev_info *bdi, int sync);
 long congestion_wait(int sync, long timeout);
-
+long wait_iff_congested(int sync, long timeout);
 
 static inline bool bdi_cap_writeback_dirty(struct backing_dev_info *bdi)
 {
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 275d477..eeaf1f5 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -181,6 +181,13 @@ DEFINE_EVENT(writeback_congest_waited_template, writeback_congestion_wait,
 	TP_ARGS(usec_timeout, usec_delayed)
 );
 
+DEFINE_EVENT(writeback_congest_waited_template, writeback_wait_iff_congested,
+
+	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
+
+	TP_ARGS(usec_timeout, usec_delayed)
+);
+
 #endif /* _TRACE_WRITEBACK_H */
 
 /* This part must be outside protection */
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e891794..3caf679 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -727,6 +727,7 @@ static wait_queue_head_t congestion_wqh[2] = {
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
 	};
+static atomic_t nr_bdi_congested[2];
 
 void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
 {
@@ -734,7 +735,8 @@ void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
 	wait_queue_head_t *wqh = &congestion_wqh[sync];
 
 	bit = sync ? BDI_sync_congested : BDI_async_congested;
-	clear_bit(bit, &bdi->state);
+	if (test_and_clear_bit(bit, &bdi->state))
+		atomic_dec(&nr_bdi_congested[sync]);
 	smp_mb__after_clear_bit();
 	if (waitqueue_active(wqh))
 		wake_up(wqh);
@@ -746,7 +748,8 @@ void set_bdi_congested(struct backing_dev_info *bdi, int sync)
 	enum bdi_state bit;
 
 	bit = sync ? BDI_sync_congested : BDI_async_congested;
-	set_bit(bit, &bdi->state);
+	if (!test_and_set_bit(bit, &bdi->state))
+		atomic_inc(&nr_bdi_congested[sync]);
 }
 EXPORT_SYMBOL(set_bdi_congested);
 
@@ -777,3 +780,50 @@ long congestion_wait(int sync, long timeout)
 }
 EXPORT_SYMBOL(congestion_wait);
 
+/**
+ * wait_iff_congested - Conditionally wait for a backing_dev to become uncongested or a zone to complete writes
+ * @sync: SYNC or ASYNC IO
+ * @timeout: timeout in jiffies
+ *
+ * In the event of a congested backing_dev (any backing_dev), this waits for up
+ * to @timeout jiffies for either a BDI to exit congestion of the given @sync
+ * queue.
+ *
+ * If there is no congestion, then cond_resched() is called to yield the
+ * processor if necessary but otherwise does not sleep.
+ *
+ * The return value is 0 if the sleep is for the full timeout. Otherwise,
+ * it is the number of jiffies that were still remaining when the function
+ * returned. return_value == timeout implies the function did not sleep.
+ */
+long wait_iff_congested(int sync, long timeout)
+{
+	long ret;
+	unsigned long start = jiffies;
+	DEFINE_WAIT(wait);
+	wait_queue_head_t *wqh = &congestion_wqh[sync];
+
+	/* If there is no congestion, yield if necessary instead of sleeping */
+	if (atomic_read(&nr_bdi_congested[sync]) == 0) {
+		cond_resched();
+
+		/* In case we scheduled, work out time remaining */
+		ret = timeout - (jiffies - start);
+		if (ret < 0)
+			ret = 0;
+
+		goto out;
+	}
+
+	/* Sleep until uncongested or a write happens */
+	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
+	ret = io_schedule_timeout(timeout);
+	finish_wait(wqh, &wait);
+
+out:
+	trace_writeback_wait_iff_congested(jiffies_to_usecs(timeout),
+					jiffies_to_usecs(jiffies - start));
+
+	return ret;
+}
+EXPORT_SYMBOL(wait_iff_congested);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a8cfa9c..9b66c75 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1906,7 +1906,7 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 			preferred_zone, migratetype);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
-			congestion_wait(BLK_RW_ASYNC, HZ/50);
+			wait_iff_congested(BLK_RW_ASYNC, HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
@@ -2094,7 +2094,7 @@ rebalance:
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
