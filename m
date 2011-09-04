Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8AFB66B0190
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:28 -0400 (EDT)
Message-Id: <20110904020915.819947322@intel.com>
Date: Sun, 04 Sep 2011 09:53:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 09/18] writeback: trace balance_dirty_pages
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=writeback-trace-balance_dirty_pages.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Useful for analyzing the dynamics of the throttling algorithms and
debugging user reported problems.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   81 +++++++++++++++++++++++++++++
 mm/page-writeback.c              |   24 ++++++++
 2 files changed, 105 insertions(+)

--- linux-next.orig/include/trace/events/writeback.h	2011-08-29 19:52:11.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-08-29 19:52:13.000000000 +0800
@@ -272,6 +272,87 @@ TRACE_EVENT(dirty_ratelimit,
 	)
 );
 
+TRACE_EVENT(balance_dirty_pages,
+
+	TP_PROTO(struct backing_dev_info *bdi,
+		 unsigned long thresh,
+		 unsigned long bg_thresh,
+		 unsigned long dirty,
+		 unsigned long bdi_thresh,
+		 unsigned long bdi_dirty,
+		 unsigned long dirty_ratelimit,
+		 unsigned long task_ratelimit,
+		 unsigned long dirtied,
+		 unsigned long period,
+		 long pause,
+		 unsigned long start_time),
+
+	TP_ARGS(bdi, thresh, bg_thresh, dirty, bdi_thresh, bdi_dirty,
+		dirty_ratelimit, task_ratelimit,
+		dirtied, period, pause, start_time),
+
+	TP_STRUCT__entry(
+		__array(	 char,	bdi, 32)
+		__field(unsigned long,	limit)
+		__field(unsigned long,	setpoint)
+		__field(unsigned long,	dirty)
+		__field(unsigned long,	bdi_setpoint)
+		__field(unsigned long,	bdi_dirty)
+		__field(unsigned long,	dirty_ratelimit)
+		__field(unsigned long,	task_ratelimit)
+		__field(unsigned int,	dirtied)
+		__field(unsigned int,	dirtied_pause)
+		__field(unsigned long,	period)
+		__field(	 long,	think)
+		__field(	 long,	pause)
+		__field(unsigned long,	paused)
+	),
+
+	TP_fast_assign(
+		unsigned long freerun = (thresh + bg_thresh) / 2;
+		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
+
+		__entry->limit		= global_dirty_limit;
+		__entry->setpoint	= (global_dirty_limit + freerun) / 2;
+		__entry->dirty		= dirty;
+		__entry->bdi_setpoint	= __entry->setpoint *
+						bdi_thresh / (thresh + 1);
+		__entry->bdi_dirty	= bdi_dirty;
+		__entry->dirty_ratelimit = KBps(dirty_ratelimit);
+		__entry->task_ratelimit	= KBps(task_ratelimit);
+		__entry->dirtied	= dirtied;
+		__entry->dirtied_pause	= current->nr_dirtied_pause;
+		__entry->think		= current->dirty_paused_when == 0 ? 0 :
+			 (long)(jiffies - current->dirty_paused_when) * 1000/HZ;
+		__entry->period		= period * 1000 / HZ;
+		__entry->pause		= pause * 1000 / HZ;
+		__entry->paused		= (jiffies - start_time) * 1000 / HZ;
+	),
+
+
+	TP_printk("bdi %s: "
+		  "limit=%lu setpoint=%lu dirty=%lu "
+		  "bdi_setpoint=%lu bdi_dirty=%lu "
+		  "dirty_ratelimit=%lu task_ratelimit=%lu "
+		  "dirtied=%u dirtied_pause=%u "
+		  "period=%lu think=%ld pause=%ld paused=%lu",
+		  __entry->bdi,
+		  __entry->limit,
+		  __entry->setpoint,
+		  __entry->dirty,
+		  __entry->bdi_setpoint,
+		  __entry->bdi_dirty,
+		  __entry->dirty_ratelimit,
+		  __entry->task_ratelimit,
+		  __entry->dirtied,
+		  __entry->dirtied_pause,
+		  __entry->period,	/* ms */
+		  __entry->think,	/* ms */
+		  __entry->pause,	/* ms */
+		  __entry->paused	/* ms */
+	  )
+);
+
 DECLARE_EVENT_CLASS(writeback_congest_waited_template,
 
 	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
--- linux-next.orig/mm/page-writeback.c	2011-08-29 19:52:11.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-29 19:52:13.000000000 +0800
@@ -1062,6 +1062,18 @@ static void balance_dirty_pages(struct a
 		 * do a reset, as it may be a light dirtier.
 		 */
 		if (unlikely(pause <= 0)) {
+			trace_balance_dirty_pages(bdi,
+						  dirty_thresh,
+						  background_thresh,
+						  nr_dirty,
+						  bdi_thresh,
+						  bdi_dirty,
+						  dirty_ratelimit,
+						  task_ratelimit,
+						  pages_dirtied,
+						  period,
+						  pause,
+						  start_time);
 			if (pause < -HZ) {
 				current->dirty_paused_when = now;
 				current->nr_dirtied = 0;
@@ -1075,6 +1087,18 @@ static void balance_dirty_pages(struct a
 		pause = min(pause, (long)MAX_PAUSE);
 
 pause:
+		trace_balance_dirty_pages(bdi,
+					  dirty_thresh,
+					  background_thresh,
+					  nr_dirty,
+					  bdi_thresh,
+					  bdi_dirty,
+					  dirty_ratelimit,
+					  task_ratelimit,
+					  pages_dirtied,
+					  period,
+					  pause,
+					  start_time);
 		__set_current_state(TASK_UNINTERRUPTIBLE);
 		io_schedule_timeout(pause);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
