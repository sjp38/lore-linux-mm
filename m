Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C18AC6B007B
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 06:47:39 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 03/10] writeback: Do not congestion sleep if there are no congested BDIs or significant writeback
Date: Mon,  6 Sep 2010 11:47:26 +0100
Message-Id: <1283770053-18833-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

If congestion_wait() is called with no BDIs congested, the caller will sleep
for the full timeout and this may be an unnecessary sleep. This patch adds
a wait_iff_congested() that checks congestion and only sleeps if a BDI is
congested or if there is a significant amount of writeback going on in an
interesting zone. Else, it calls cond_resched() to ensure the caller is
not hogging the CPU longer than its quota but otherwise will not sleep.

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
 include/trace/events/writeback.h |    7 ++++
 mm/backing-dev.c                 |   66 ++++++++++++++++++++++++++++++++++++-
 mm/page_alloc.c                  |    4 +-
 mm/vmscan.c                      |   26 ++++++++++++--
 5 files changed, 96 insertions(+), 9 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 35b0074..f1b402a 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -285,7 +285,7 @@ enum {
 void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
 void set_bdi_congested(struct backing_dev_info *bdi, int sync);
 long congestion_wait(int sync, long timeout);
-
+long wait_iff_congested(struct zone *zone, int sync, long timeout);
 
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
index 298975a..94b5433 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -724,6 +724,7 @@ static wait_queue_head_t congestion_wqh[2] = {
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
 	};
+static atomic_t nr_bdi_congested[2];
 
 void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
 {
@@ -731,7 +732,8 @@ void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
 	wait_queue_head_t *wqh = &congestion_wqh[sync];
 
 	bit = sync ? BDI_sync_congested : BDI_async_congested;
-	clear_bit(bit, &bdi->state);
+	if (test_and_clear_bit(bit, &bdi->state))
+		atomic_dec(&nr_bdi_congested[sync]);
 	smp_mb__after_clear_bit();
 	if (waitqueue_active(wqh))
 		wake_up(wqh);
@@ -743,7 +745,8 @@ void set_bdi_congested(struct backing_dev_info *bdi, int sync)
 	enum bdi_state bit;
 
 	bit = sync ? BDI_sync_congested : BDI_async_congested;
-	set_bit(bit, &bdi->state);
+	if (!test_and_set_bit(bit, &bdi->state))
+		atomic_inc(&nr_bdi_congested[sync]);
 }
 EXPORT_SYMBOL(set_bdi_congested);
 
@@ -774,3 +777,62 @@ long congestion_wait(int sync, long timeout)
 }
 EXPORT_SYMBOL(congestion_wait);
 
+/**
+ * congestion_wait - wait for a backing_dev to become uncongested
+ * @zone: A zone to consider the number of being being written back from
+ * @sync: SYNC or ASYNC IO
+ * @timeout: timeout in jiffies
+ *
+ * Waits for up to @timeout jiffies for a backing_dev (any backing_dev) to exit
+ * write congestion.  If no backing_devs are congested then the number of
+ * writeback pages in the zone are checked and compared to the inactive
+ * list. If there is no sigificant writeback or congestion, there is no point
+ * in sleeping but cond_resched() is called in case the current process has
+ * consumed its CPU quota.
+ */
+long wait_iff_congested(struct zone *zone, int sync, long timeout)
+{
+	long ret;
+	unsigned long start = jiffies;
+	DEFINE_WAIT(wait);
+	wait_queue_head_t *wqh = &congestion_wqh[sync];
+
+	/*
+	 * If there is no congestion, check the amount of writeback. If there
+	 * is no significant writeback and no congestion, just cond_resched
+	 */
+	if (atomic_read(&nr_bdi_congested[sync]) == 0) {
+		unsigned long inactive, writeback;
+
+		inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
+				zone_page_state(zone, NR_INACTIVE_ANON);
+		writeback = zone_page_state(zone, NR_WRITEBACK);
+
+		/*
+		 * If less than half the inactive list is being written back,
+		 * reclaim might as well continue
+		 */
+		if (writeback < inactive / 2) {
+			cond_resched();
+
+			/* In case we scheduled, work out time remaining */
+			ret = timeout - (jiffies - start);
+			if (ret < 0)
+				ret = 0;
+
+			goto out;
+		}
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
index a9649f4..641900a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1893,7 +1893,7 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 			preferred_zone, migratetype);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
-			congestion_wait(BLK_RW_ASYNC, HZ/50);
+			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
@@ -2081,7 +2081,7 @@ rebalance:
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 652650f..eabe987 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1341,7 +1341,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
 
 		/*
 		 * The attempt at page out may have made some
@@ -1913,10 +1913,28 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			sc->may_writepage = 1;
 		}
 
-		/* Take a nap, wait for some writeback to complete */
+		/* Take a nap if congested, wait for some writeback */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
-		    priority < DEF_PRIORITY - 2)
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+		    priority < DEF_PRIORITY - 2) {
+			struct zone *active_zone = NULL;
+			unsigned long max_writeback = 0;
+			for_each_zone_zonelist(zone, z, zonelist,
+					gfp_zone(sc->gfp_mask)) {
+				unsigned long writeback;
+
+				/* Initialise for first zone */
+				if (active_zone == NULL)
+					active_zone = zone;
+
+				writeback = zone_page_state(zone, NR_WRITEBACK);
+				if (writeback > max_writeback) {
+					max_writeback = writeback;
+					active_zone = zone;
+				}
+			}
+
+			wait_iff_congested(active_zone, BLK_RW_ASYNC, HZ/10);
+		}
 	}
 
 out:
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
