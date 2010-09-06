Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A7E6C6B007E
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 06:47:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 02/10] writeback: Account for time spent congestion_waited
Date: Mon,  6 Sep 2010 11:47:25 +0100
Message-Id: <1283770053-18833-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

There is strong evidence to indicate a lot of time is being spent in
congestion_wait(), some of it unnecessarily. This patch adds a tracepoint
for congestion_wait to record when congestion_wait() was called, how long
the timeout was for and how long it actually slept.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/trace/events/writeback.h |   28 ++++++++++++++++++++++++++++
 mm/backing-dev.c                 |    5 +++++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index f345f66..275d477 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -153,6 +153,34 @@ DEFINE_WBC_EVENT(wbc_balance_dirty_written);
 DEFINE_WBC_EVENT(wbc_balance_dirty_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+DECLARE_EVENT_CLASS(writeback_congest_waited_template,
+
+	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
+
+	TP_ARGS(usec_timeout, usec_delayed),
+
+	TP_STRUCT__entry(
+		__field(	unsigned int,	usec_timeout	)
+		__field(	unsigned int,	usec_delayed	)
+	),
+
+	TP_fast_assign(
+		__entry->usec_timeout	= usec_timeout;
+		__entry->usec_delayed	= usec_delayed;
+	),
+
+	TP_printk("usec_timeout=%u usec_delayed=%u",
+			__entry->usec_timeout,
+			__entry->usec_delayed)
+);
+
+DEFINE_EVENT(writeback_congest_waited_template, writeback_congestion_wait,
+
+	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
+
+	TP_ARGS(usec_timeout, usec_delayed)
+);
+
 #endif /* _TRACE_WRITEBACK_H */
 
 /* This part must be outside protection */
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index eaa4a5b..298975a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -759,12 +759,17 @@ EXPORT_SYMBOL(set_bdi_congested);
 long congestion_wait(int sync, long timeout)
 {
 	long ret;
+	unsigned long start = jiffies;
 	DEFINE_WAIT(wait);
 	wait_queue_head_t *wqh = &congestion_wqh[sync];
 
 	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
 	ret = io_schedule_timeout(timeout);
 	finish_wait(wqh, &wait);
+
+	trace_writeback_congestion_wait(jiffies_to_usecs(timeout),
+					jiffies_to_usecs(jiffies - start));
+
 	return ret;
 }
 EXPORT_SYMBOL(congestion_wait);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
