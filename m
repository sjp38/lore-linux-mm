Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 36C248D004F
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:59 -0500 (EST)
Message-Id: <20110303074951.568969627@intel.com>
Date: Thu, 03 Mar 2011 14:45:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 22/27] writeback: trace dirty_throttle_bandwidth
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-trace-throttle-bandwidth.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

It provides critical information to understand how various throttle
bandwidths are updated.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   49 +++++++++++++++++++++++++++++
 mm/page-writeback.c              |    1 
 2 files changed, 50 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:44:31.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:44:38.000000000 +0800
@@ -1068,6 +1068,7 @@ adjust:
 	bdi->throttle_bandwidth = bw;
 out:
 	bdi_update_reference_bandwidth(bdi, ref_bw);
+	trace_dirty_throttle_bandwidth(bdi, dirty_bw, pos_bw, ref_bw);
 }
 
 void bdi_update_bandwidth(struct backing_dev_info *bdi,
--- linux-next.orig/include/trace/events/writeback.h	2011-03-03 14:43:49.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-03-03 14:44:38.000000000 +0800
@@ -152,6 +152,55 @@ DEFINE_WBC_EVENT(wbc_balance_dirty_writt
 DEFINE_WBC_EVENT(wbc_balance_dirty_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+#define KBps(x)			((x) << (PAGE_SHIFT - 10))
+#define Bps(x)			((x) >> (BASE_BW_SHIFT - PAGE_SHIFT))
+
+TRACE_EVENT(dirty_throttle_bandwidth,
+
+	TP_PROTO(struct backing_dev_info *bdi,
+		 unsigned long dirty_bw,
+		 unsigned long long pos_bw,
+		 unsigned long long ref_bw),
+
+	TP_ARGS(bdi, dirty_bw, pos_bw, ref_bw),
+
+	TP_STRUCT__entry(
+		__array(char,			bdi, 32)
+		__field(unsigned long,		write_bw)
+		__field(unsigned long,		avg_bw)
+		__field(unsigned long,		dirty_bw)
+		__field(unsigned long long,	base_bw)
+		__field(unsigned long long,	pos_bw)
+		__field(unsigned long long,	ref_bw)
+		__field(unsigned long long,	avg_ref_bw)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
+		__entry->write_bw	= KBps(bdi->write_bandwidth);
+		__entry->avg_bw		= KBps(bdi->avg_bandwidth);
+		__entry->dirty_bw	= KBps(dirty_bw);
+		__entry->base_bw	= Bps(bdi->throttle_bandwidth);
+		__entry->pos_bw		= Bps(pos_bw);
+		__entry->ref_bw		= Bps(ref_bw);
+		__entry->avg_ref_bw	= Bps(bdi->reference_bandwidth);
+	),
+
+
+	TP_printk("bdi %s: "
+		  "write_bw=%lu avg_bw=%lu dirty_bw=%lu "
+		  "base_bw=%llu pos_bw=%llu ref_bw=%llu aref_bw=%llu",
+		  __entry->bdi,
+		  __entry->write_bw,	/* bdi write bandwidth */
+		  __entry->avg_bw,	/* bdi avg write bandwidth */
+		  __entry->dirty_bw,	/* bdi dirty bandwidth */
+		  __entry->base_bw,	/* base throttle bandwidth */
+		  __entry->pos_bw,	/* position control bandwidth */
+		  __entry->ref_bw,	/* reference throttle bandwidth */
+		  __entry->avg_ref_bw	/* smoothed reference bandwidth */
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
