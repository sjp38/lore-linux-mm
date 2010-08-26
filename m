Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A1EB16B01F4
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 11:14:23 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/3] writeback: Record if the congestion was unnecessary
Date: Thu, 26 Aug 2010 16:14:15 +0100
Message-Id: <1282835656-5638-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If congestion_wait() is called when there is no congestion, the caller
will wait for the full timeout. This can cause unreasonable and
unnecessary stalls. There are a number of potential modifications that
could be made to wake sleepers but this patch measures how serious the
problem is. It keeps count of how many congested BDIs there are. If
congestion_wait() is called with no BDIs congested, the tracepoint will
record that the wait was unnecessary.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/writeback.h |   11 ++++++++---
 mm/backing-dev.c                 |   15 ++++++++++++---
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index e3bee61..03bb04b 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -155,19 +155,24 @@ DEFINE_WBC_EVENT(wbc_writepage);
 
 TRACE_EVENT(writeback_congest_waited,
 
-	TP_PROTO(unsigned int usec_delayed),
+	TP_PROTO(unsigned int usec_delayed, bool unnecessary),
 
-	TP_ARGS(usec_delayed),
+	TP_ARGS(usec_delayed, unnecessary),
 
 	TP_STRUCT__entry(
 		__field(	unsigned int,	usec_delayed	)
+		__field(	unsigned int,	unnecessary	)
 	),
 
 	TP_fast_assign(
 		__entry->usec_delayed	= usec_delayed;
+		__entry->unnecessary	= unnecessary;
 	),
 
-	TP_printk("usec_delayed=%u", __entry->usec_delayed)
+	TP_printk("usec_delayed=%u unnecessary=%d",
+		__entry->usec_delayed,
+		__entry->unnecessary
+	)
 );
 
 #endif /* _TRACE_WRITEBACK_H */
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 7ae33e2..a49167f 100644
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
 
@@ -760,14 +763,20 @@ long congestion_wait(int sync, long timeout)
 {
 	long ret;
 	unsigned long start = jiffies;
+	bool unnecessary = false;
 	DEFINE_WAIT(wait);
 	wait_queue_head_t *wqh = &congestion_wqh[sync];
 
+	/* Check if this call to congestion_wait was necessary */
+	if (atomic_read(&nr_bdi_congested[sync]) == 0)
+		unnecessary = true;
+
 	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
 	ret = io_schedule_timeout(timeout);
 	finish_wait(wqh, &wait);
 
-	trace_writeback_congest_waited(jiffies_to_usecs(jiffies - start));
+	trace_writeback_congest_waited(jiffies_to_usecs(jiffies - start),
+			unnecessary);
 
 	return ret;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
