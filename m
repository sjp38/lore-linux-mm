From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 22/35] writeback: trace global dirty page states
Date: Mon, 13 Dec 2010 22:47:08 +0800
Message-ID: <20101213150329.002158963@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA1o-0001uz-Cw
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:09:28 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C06EC6B00A3
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:08:50 -0500 (EST)
Content-Disposition: inline; filename=writeback-trace-global-dirty-states.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Add trace balance_dirty_state for showing the global dirty page counts
and thresholds at each balance_dirty_pages() loop.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   57 +++++++++++++++++++++++++++++
 mm/page-writeback.c              |   15 ++++++-
 2 files changed, 69 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:18.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-13 21:46:18.000000000 +0800
@@ -713,12 +713,21 @@ static void balance_dirty_pages(struct a
 		 * written to the server's write cache, but has not yet
 		 * been flushed to permanent storage.
 		 */
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
+		nr_reclaimable = global_page_state(NR_FILE_DIRTY);
+		bdi_dirty = global_page_state(NR_UNSTABLE_NFS);
+		nr_dirty = global_page_state(NR_WRITEBACK);
 
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 
+		trace_balance_dirty_state(mapping,
+					  nr_reclaimable,
+					  nr_dirty,
+					  bdi_dirty,
+					  background_thresh,
+					  dirty_thresh);
+		nr_reclaimable += bdi_dirty;
+		nr_dirty += nr_reclaimable;
+
 		/*
 		 * Throttle it only when the background writeback cannot
 		 * catch-up. This avoids (excessively) small writeouts
--- linux-next.orig/include/trace/events/writeback.h	2010-12-13 21:46:18.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2010-12-13 21:46:18.000000000 +0800
@@ -149,6 +149,63 @@ DEFINE_WBC_EVENT(wbc_writeback_written);
 DEFINE_WBC_EVENT(wbc_writeback_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+TRACE_EVENT(balance_dirty_state,
+
+	TP_PROTO(struct address_space *mapping,
+		 unsigned long nr_dirty,
+		 unsigned long nr_writeback,
+		 unsigned long nr_unstable,
+		 unsigned long background_thresh,
+		 unsigned long dirty_thresh
+	),
+
+	TP_ARGS(mapping,
+		nr_dirty,
+		nr_writeback,
+		nr_unstable,
+		background_thresh,
+		dirty_thresh
+	),
+
+	TP_STRUCT__entry(
+		__array(char,		bdi, 32)
+		__field(unsigned long,	ino)
+		__field(unsigned long,	nr_dirty)
+		__field(unsigned long,	nr_writeback)
+		__field(unsigned long,	nr_unstable)
+		__field(unsigned long,	background_thresh)
+		__field(unsigned long,	dirty_thresh)
+		__field(unsigned long,	task_dirtied_pause)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->bdi,
+			dev_name(mapping->backing_dev_info->dev), 32);
+		__entry->ino			= mapping->host->i_ino;
+		__entry->nr_dirty		= nr_dirty;
+		__entry->nr_writeback		= nr_writeback;
+		__entry->nr_unstable		= nr_unstable;
+		__entry->background_thresh	= background_thresh;
+		__entry->dirty_thresh		= dirty_thresh;
+		__entry->task_dirtied_pause	= current->nr_dirtied_pause;
+	),
+
+	TP_printk("bdi %s: dirty=%lu wb=%lu unstable=%lu "
+		  "bg_thresh=%lu thresh=%lu gap=%ld "
+		  "poll_thresh=%lu ino=%lu",
+		  __entry->bdi,
+		  __entry->nr_dirty,
+		  __entry->nr_writeback,
+		  __entry->nr_unstable,
+		  __entry->background_thresh,
+		  __entry->dirty_thresh,
+		  __entry->dirty_thresh - __entry->nr_dirty -
+		  __entry->nr_writeback - __entry->nr_unstable,
+		  __entry->task_dirtied_pause,
+		  __entry->ino
+	)
+);
+
 #define KBps(x)			((x) << (PAGE_SHIFT - 10))
 #define BDP_PERCENT(a, b, c)	(((__entry->a) - (__entry->b)) * 100 * (c) + \
 				  __entry->bdi_limit/2) / (__entry->bdi_limit|1)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
