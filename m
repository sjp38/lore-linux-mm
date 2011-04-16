Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E6FB2900087
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 10:03:33 -0400 (EDT)
Message-Id: <20110416134333.693350038@intel.com>
Date: Sat, 16 Apr 2011 21:25:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/12] writeback: trace dirty_ratelimit
References: <20110416132546.765212221@intel.com>
Content-Disposition: inline; filename=writeback-trace-throttle-bandwidth.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

It provides critical information to understand how various throttle
bandwidths are updated.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   51 +++++++++++++++++++++++++++--
 mm/page-writeback.c              |    1 
 2 files changed, 49 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-16 11:28:21.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-16 11:28:27.000000000 +0800
@@ -974,6 +974,7 @@ adjust:
 	bdi->dirty_ratelimit = bw;
 out:
 	bdi_update_reference_ratelimit(bdi, ref_bw);
+	trace_dirty_ratelimit(bdi, dirty_bw, pos_bw, ref_bw);
 }
 
 void bdi_update_bandwidth(struct backing_dev_info *bdi,
--- linux-next.orig/include/trace/events/writeback.h	2011-04-16 11:28:17.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-04-16 11:28:27.000000000 +0800
@@ -147,11 +147,56 @@ DEFINE_EVENT(wbc_class, name, \
 DEFINE_WBC_EVENT(wbc_writeback_start);
 DEFINE_WBC_EVENT(wbc_writeback_written);
 DEFINE_WBC_EVENT(wbc_writeback_wait);
-DEFINE_WBC_EVENT(wbc_balance_dirty_start);
-DEFINE_WBC_EVENT(wbc_balance_dirty_written);
-DEFINE_WBC_EVENT(wbc_balance_dirty_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+#define KBps(x)			((x) << (PAGE_SHIFT - 10))
+
+TRACE_EVENT(dirty_ratelimit,
+
+	TP_PROTO(struct backing_dev_info *bdi,
+		 unsigned long dirty_bw,
+		 unsigned long pos_bw,
+		 unsigned long ref_bw),
+
+	TP_ARGS(bdi, dirty_bw, pos_bw, ref_bw),
+
+	TP_STRUCT__entry(
+		__array(char,		bdi, 32)
+		__field(unsigned long,	write_bw)
+		__field(unsigned long,	avg_bw)
+		__field(unsigned long,	dirty_bw)
+		__field(unsigned long,	base_bw)
+		__field(unsigned long,	pos_bw)
+		__field(unsigned long,	ref_bw)
+		__field(unsigned long,	avg_ref_bw)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
+		__entry->write_bw	= KBps(bdi->write_bandwidth);
+		__entry->avg_bw		= KBps(bdi->avg_write_bandwidth);
+		__entry->dirty_bw	= KBps(dirty_bw);
+		__entry->base_bw	= KBps(bdi->dirty_ratelimit);
+		__entry->pos_bw		= KBps(pos_bw);
+		__entry->ref_bw		= KBps(ref_bw);
+		__entry->avg_ref_bw	= KBps(bdi->reference_ratelimit);
+	),
+
+
+	TP_printk("bdi %s: "
+		  "write_bw=%lu awrite_bw=%lu dirty_bw=%lu "
+		  "base_bw=%lu pos_bw=%lu ref_bw=%lu aref_bw=%lu",
+		  __entry->bdi,
+		  __entry->write_bw,	/* write bandwidth */
+		  __entry->avg_bw,	/* avg write bandwidth */
+		  __entry->dirty_bw,	/* dirty bandwidth */
+		  __entry->base_bw,	/* dirty ratelimit on each task */
+		  __entry->pos_bw,	/* position control ratelimit */
+		  __entry->ref_bw,	/* the reference ratelimit */
+		  __entry->avg_ref_bw	/* smoothed reference ratelimit */
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
