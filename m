Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7567190013C
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 07:47:54 -0400 (EDT)
Message-Id: <20110826114619.793951115@intel.com>
Date: Fri, 26 Aug 2011 19:38:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 09/10] writeback: trace dirty_ratelimit
References: <20110826113813.895522398@intel.com>
Content-Disposition: inline; filename=writeback-trace-throttle-bandwidth.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

It helps understand how various throttle bandwidths are updated.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   46 +++++++++++++++++++++++++++++
 mm/page-writeback.c              |    3 +
 2 files changed, 49 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-08-26 19:27:21.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-26 19:27:26.000000000 +0800
@@ -864,6 +864,9 @@ static void bdi_update_dirty_ratelimit(s
 		dirty_ratelimit -= step;
 
 	bdi->dirty_ratelimit = max(dirty_ratelimit, 1UL);
+
+	trace_dirty_ratelimit(bdi, dirty_rate, task_ratelimit,
+			      balanced_dirty_ratelimit);
 }
 
 void __bdi_update_bandwidth(struct backing_dev_info *bdi,
--- linux-next.orig/include/trace/events/writeback.h	2011-08-26 19:27:21.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-08-26 19:27:23.000000000 +0800
@@ -305,6 +305,52 @@ TRACE_EVENT(balance_dirty_pages,
 	  )
 );
 
+#define KBps(x)			((x) << (PAGE_SHIFT - 10))
+
+TRACE_EVENT(dirty_ratelimit,
+
+	TP_PROTO(struct backing_dev_info *bdi,
+		 unsigned long dirty_rate,
+		 unsigned long task_ratelimit,
+		 unsigned long balanced_dirty_ratelimit),
+
+	TP_ARGS(bdi, dirty_rate, task_ratelimit, balanced_dirty_ratelimit),
+
+	TP_STRUCT__entry(
+		__array(char,		bdi, 32)
+		__field(unsigned long,	write_bw)
+		__field(unsigned long,	avg_write_bw)
+		__field(unsigned long,	dirty_rate)
+		__field(unsigned long,	dirty_ratelimit)
+		__field(unsigned long,	task_ratelimit)
+		__field(unsigned long,	balanced_dirty_ratelimit)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
+		__entry->write_bw	= KBps(bdi->write_bandwidth);
+		__entry->avg_write_bw	= KBps(bdi->avg_write_bandwidth);
+		__entry->dirty_rate	= KBps(dirty_rate);
+		__entry->dirty_ratelimit = KBps(bdi->dirty_ratelimit);
+		__entry->task_ratelimit	= KBps(task_ratelimit);
+		__entry->balanced_dirty_ratelimit =
+					  KBps(balanced_dirty_ratelimit);
+	),
+
+	TP_printk("bdi %s: "
+		  "write_bw=%lu awrite_bw=%lu dirty_rate=%lu "
+		  "dirty_ratelimit=%lu task_ratelimit=%lu "
+		  "balanced_dirty_ratelimit=%lu",
+		  __entry->bdi,
+		  __entry->write_bw,		/* write bandwidth */
+		  __entry->avg_write_bw,	/* avg write bandwidth */
+		  __entry->dirty_rate,		/* bdi dirty rate */
+		  __entry->dirty_ratelimit,	/* base ratelimit */
+		  __entry->task_ratelimit, /* ratelimit with position control */
+		  __entry->balanced_dirty_ratelimit /* the balanced ratelimit */
+	)
+);
+
 DECLARE_EVENT_CLASS(writeback_congest_waited_template,
 
 	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
