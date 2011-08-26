Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4FA5990013B
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 07:47:54 -0400 (EDT)
Message-Id: <20110826114619.661085405@intel.com>
Date: Fri, 26 Aug 2011 19:38:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 08/10] writeback: trace balance_dirty_pages
References: <20110826113813.895522398@intel.com>
Content-Disposition: inline; filename=writeback-trace-balance_dirty_pages.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Useful for analyzing the dynamics of the throttling algorithms and
debugging user reported problems.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   79 +++++++++++++++++++++++++++++
 mm/page-writeback.c              |   24 ++++++++
 2 files changed, 103 insertions(+)

--- linux-next.orig/include/trace/events/writeback.h	2011-08-12 18:21:07.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-08-12 18:21:07.000000000 +0800
@@ -270,6 +270,85 @@ TRACE_EVENT(dirty_ratelimit,
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
+		 unsigned long base_rate,
+		 unsigned long task_ratelimit,
+		 unsigned long dirtied,
+		 unsigned long period,
+		 long pause,
+		 unsigned long start_time),
+
+	TP_ARGS(bdi, thresh, bg_thresh, dirty, bdi_thresh, bdi_dirty,
+		base_rate, task_ratelimit, dirtied, period, pause, start_time),
+
+	TP_STRUCT__entry(
+		__array(	 char,	bdi, 32)
+		__field(unsigned long,	limit)
+		__field(unsigned long,	goal)
+		__field(unsigned long,	dirty)
+		__field(unsigned long,	bdi_goal)
+		__field(unsigned long,	bdi_dirty)
+		__field(unsigned long,	base_rate)
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
+		__entry->goal		= (global_dirty_limit + freerun) / 2;
+		__entry->dirty		= dirty;
+		__entry->bdi_goal	= __entry->goal * bdi_thresh / (thresh|1);
+		__entry->bdi_dirty	= bdi_dirty;
+		__entry->base_rate	= KBps(base_rate);
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
+		  "limit=%lu goal=%lu dirty=%lu "
+		  "bdi_goal=%lu bdi_dirty=%lu "
+		  "base_rate=%lu task_ratelimit=%lu "
+		  "dirtied=%u dirtied_pause=%u "
+		  "period=%lu think=%ld pause=%ld paused=%lu",
+		  __entry->bdi,
+		  __entry->limit,
+		  __entry->goal,
+		  __entry->dirty,
+		  __entry->bdi_goal,
+		  __entry->bdi_dirty,
+		  __entry->base_rate,	/* bdi base throttle bandwidth */
+		  __entry->task_ratelimit,	/* task throttle bandwidth */
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
--- linux-next.orig/mm/page-writeback.c	2011-08-12 18:21:07.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-12 18:22:01.000000000 +0800
@@ -946,6 +946,18 @@ static void balance_dirty_pages(struct a
 		 * do a reset, as it may be a light dirtier.
 		 */
 		if (unlikely(pause <= 0)) {
+			trace_balance_dirty_pages(bdi,
+						  dirty_thresh,
+						  background_thresh,
+						  nr_dirty,
+						  bdi_thresh,
+						  bdi_dirty,
+						  base_rate,
+						  task_ratelimit,
+						  pages_dirtied,
+						  period,
+						  pause,
+						  start_time);
 			if (pause < -HZ) {
 				current->dirty_paused_when = now;
 				current->nr_dirtied = 0;
@@ -959,6 +971,18 @@ static void balance_dirty_pages(struct a
 		pause = min(pause, MAX_PAUSE);
 
 pause:
+		trace_balance_dirty_pages(bdi,
+					  dirty_thresh,
+					  background_thresh,
+					  nr_dirty,
+					  bdi_thresh,
+					  bdi_dirty,
+					  base_rate,
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
