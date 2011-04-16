Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E58A0900093
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 10:03:46 -0400 (EDT)
Message-Id: <20110416134333.960669369@intel.com>
Date: Sat, 16 Apr 2011 21:25:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 12/12] writeback: trace global_dirty_state
References: <20110416132546.765212221@intel.com>
Content-Disposition: inline; filename=writeback-trace-global-dirty-states.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Add trace balance_dirty_state for showing the global dirty page counts
and thresholds at each balance_dirty_pages() loop.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   48 +++++++++++++++++++++++++++++
 mm/page-writeback.c              |    1 
 2 files changed, 49 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-04-16 11:28:28.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-16 11:28:30.000000000 +0800
@@ -387,6 +387,7 @@ void global_dirty_limits(unsigned long *
 	tsk = current;
 	*pbackground = background;
 	*pdirty = dirty;
+	trace_global_dirty_state(background, dirty);
 }
 
 /**
--- linux-next.orig/include/trace/events/writeback.h	2011-04-16 11:28:28.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-04-16 11:28:30.000000000 +0800
@@ -277,6 +277,54 @@ TRACE_EVENT(balance_dirty_pages,
 		  )
 );
 
+TRACE_EVENT(global_dirty_state,
+
+	TP_PROTO(unsigned long background_thresh,
+		 unsigned long dirty_thresh
+	),
+
+	TP_ARGS(background_thresh,
+		dirty_thresh
+	),
+
+	TP_STRUCT__entry(
+		__field(unsigned long,	nr_dirty)
+		__field(unsigned long,	nr_writeback)
+		__field(unsigned long,	nr_unstable)
+		__field(unsigned long,	background_thresh)
+		__field(unsigned long,	dirty_thresh)
+		__field(unsigned long,	dirty_limit)
+		__field(unsigned long,	nr_dirtied)
+		__field(unsigned long,	nr_written)
+	),
+
+	TP_fast_assign(
+		__entry->nr_dirty	= global_page_state(NR_FILE_DIRTY);
+		__entry->nr_writeback	= global_page_state(NR_WRITEBACK);
+		__entry->nr_unstable	= global_page_state(NR_UNSTABLE_NFS);
+		__entry->nr_dirtied	= global_page_state(NR_DIRTIED);
+		__entry->nr_written	= global_page_state(NR_WRITTEN);
+		__entry->background_thresh = background_thresh;
+		__entry->dirty_thresh	= dirty_thresh;
+		__entry->dirty_limit = default_backing_dev_info.dirty_threshold;
+	),
+
+	TP_printk("dirty=%lu writeback=%lu unstable=%lu "
+		  "bg_thresh=%lu thresh=%lu limit=%lu gap=%ld "
+		  "dirtied=%lu written=%lu",
+		  __entry->nr_dirty,
+		  __entry->nr_writeback,
+		  __entry->nr_unstable,
+		  __entry->background_thresh,
+		  __entry->dirty_thresh,
+		  __entry->dirty_limit,
+		  __entry->dirty_thresh - __entry->nr_dirty -
+		  __entry->nr_writeback - __entry->nr_unstable,
+		  __entry->nr_dirtied,
+		  __entry->nr_written
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
