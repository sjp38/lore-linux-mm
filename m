Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8DE8590013E
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 07:47:54 -0400 (EDT)
Message-Id: <20110826114619.923651827@intel.com>
Date: Fri, 26 Aug 2011 19:38:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/10] trace task_io
References: <20110826113813.895522398@intel.com>
Content-Disposition: inline; filename=writeback-trace-task-total-dirtied.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The "write_bytes" curve over time is very handy for viewing the
smoothness and fairness of page dirties for each task.

XXX: It looks not a good fit for writeback traces, shall we create a
include/trace/events/vfs.h for this?

XXX: the other fields of struct task_io_accounting are not dumped.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   32 +++++++++++++++++++++++++++++
 mm/page-writeback.c              |    1 
 2 files changed, 33 insertions(+)

--- linux-next.orig/include/trace/events/writeback.h	2011-08-22 11:58:21.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-08-22 12:22:38.000000000 +0800
@@ -180,6 +180,38 @@ TRACE_EVENT(writeback_queue_io,
 		__entry->moved)
 );
 
+TRACE_EVENT(task_io,
+	TP_PROTO(struct task_struct *task),
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(unsigned long long,	read_bytes)
+		__field(unsigned long long,	write_bytes)
+		__field(unsigned long long,	cancelled_write_bytes)
+	),
+
+	TP_fast_assign(
+		struct task_io_accounting *ioac = &task->ioac;
+
+#ifdef CONFIG_TASK_IO_ACCOUNTING
+		__entry->read_bytes		= ioac->read_bytes;
+		__entry->write_bytes		= ioac->write_bytes;
+		__entry->cancelled_write_bytes	= ioac->cancelled_write_bytes;
+#else
+		__entry->read_bytes		= 0;
+		__entry->write_bytes		= 0;
+		__entry->cancelled_write_bytes	= 0;
+#endif
+	),
+
+	TP_printk("read=%llu write=%llu cancelled_write=%llu",
+		  __entry->read_bytes,
+		  __entry->write_bytes,
+		  __entry->cancelled_write_bytes
+	)
+);
+
+
 TRACE_EVENT(global_dirty_state,
 
 	TP_PROTO(unsigned long background_thresh,
--- linux-next.orig/mm/page-writeback.c	2011-08-22 12:10:33.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-22 12:20:33.000000000 +0800
@@ -407,6 +407,7 @@ void global_dirty_limits(unsigned long *
 	*pbackground = background;
 	*pdirty = dirty;
 	trace_global_dirty_state(background, dirty);
+	trace_task_io(current);
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
