From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 12/13] writeback: add trace event for balance_dirty_pages()
Date: Wed, 17 Nov 2010 11:58:33 +0800
Message-ID: <20101117035906.840703610@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PIZK7-0007hA-Fb
	for glkm-linux-mm-2@m.gmane.org; Wed, 17 Nov 2010 05:08:43 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E989D6B010A
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:08:10 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Andrew,
References: <20101117035821.000579293@intel.com>
Content-Disposition: inline; filename=writeback-trace-balance_dirty_pages.patch

Here is an interesting test to verify the theory with balance_dirty_pages()
tracing. On a partition that can do ~60MB/s, a sparse file is created and
4 rsync tasks with different write bandwidth started:

	dd if=/dev/zero of=/mnt/1T bs=1M count=1 seek=1024000
	echo 1 > /debug/tracing/events/writeback/balance_dirty_pages/enable

	rsync localhost:/mnt/1T /mnt/a --bwlimit 10000&
	rsync localhost:/mnt/1T /mnt/A --bwlimit 10000&
	rsync localhost:/mnt/1T /mnt/b --bwlimit 20000&
	rsync localhost:/mnt/1T /mnt/c --bwlimit 30000&

Trace outputs within 0.1 second, grouped by tasks:

rsync-3824  [004] 15002.076447: balance_dirty_pages: bdi=btrfs-2 weight=15% limit=130876 gap=5340 dirtied=192 pause=20

rsync-3822  [003] 15002.091701: balance_dirty_pages: bdi=btrfs-2 weight=15% limit=130777 gap=5113 dirtied=192 pause=20

rsync-3821  [006] 15002.004667: balance_dirty_pages: bdi=btrfs-2 weight=30% limit=129570 gap=3714 dirtied=64 pause=8
rsync-3821  [006] 15002.012654: balance_dirty_pages: bdi=btrfs-2 weight=30% limit=129589 gap=3733 dirtied=64 pause=8
rsync-3821  [006] 15002.021838: balance_dirty_pages: bdi=btrfs-2 weight=30% limit=129604 gap=3748 dirtied=64 pause=8
rsync-3821  [004] 15002.091193: balance_dirty_pages: bdi=btrfs-2 weight=29% limit=129583 gap=3983 dirtied=64 pause=8
rsync-3821  [004] 15002.102729: balance_dirty_pages: bdi=btrfs-2 weight=29% limit=129594 gap=3802 dirtied=64 pause=8
rsync-3821  [000] 15002.109252: balance_dirty_pages: bdi=btrfs-2 weight=29% limit=129619 gap=3827 dirtied=64 pause=8

rsync-3823  [002] 15002.009029: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128762 gap=2842 dirtied=64 pause=12
rsync-3823  [002] 15002.021598: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128813 gap=3021 dirtied=64 pause=12
rsync-3823  [003] 15002.032973: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128805 gap=2885 dirtied=64 pause=12
rsync-3823  [003] 15002.048800: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128823 gap=2967 dirtied=64 pause=12
rsync-3823  [003] 15002.060728: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128821 gap=3221 dirtied=64 pause=12
rsync-3823  [000] 15002.073152: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128825 gap=3225 dirtied=64 pause=12
rsync-3823  [005] 15002.090111: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128782 gap=3214 dirtied=64 pause=12
rsync-3823  [004] 15002.102520: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128764 gap=3036 dirtied=64 pause=12

The data vividly show that

- the heaviest writer is throttled a bit (weight=39%)

- the lighter writers run at full speed (weight=15%,15%,30%)
  rsync is smart enough to compensate for the in-kernel pause time

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   61 +++++++++++++++++++++++++++--
 mm/page-writeback.c              |    6 ++
 2 files changed, 64 insertions(+), 3 deletions(-)

--- linux-next.orig/include/trace/events/writeback.h	2010-11-15 18:59:00.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2010-11-15 21:31:46.000000000 +0800
@@ -147,11 +147,66 @@ DEFINE_EVENT(wbc_class, name, \
 DEFINE_WBC_EVENT(wbc_writeback_start);
 DEFINE_WBC_EVENT(wbc_writeback_written);
 DEFINE_WBC_EVENT(wbc_writeback_wait);
-DEFINE_WBC_EVENT(wbc_balance_dirty_start);
-DEFINE_WBC_EVENT(wbc_balance_dirty_written);
-DEFINE_WBC_EVENT(wbc_balance_dirty_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+#define BDP_PERCENT(a, b, c)	((__entry->a - __entry->b) * 100 * c + \
+				  __entry->bdi_limit/2) / (__entry->bdi_limit|1)
+TRACE_EVENT(balance_dirty_pages,
+
+	TP_PROTO(struct backing_dev_info *bdi,
+		 long bdi_dirty,
+		 long bdi_limit,
+		 long task_limit,
+		 long pages_dirtied,
+		 long pause),
+
+	TP_ARGS(bdi, bdi_dirty, bdi_limit, task_limit,
+		pages_dirtied, pause),
+
+	TP_STRUCT__entry(
+		__array(char,	bdi, 32)
+		__field(long,	bdi_dirty)
+		__field(long,	bdi_limit)
+		__field(long,	task_limit)
+		__field(long,	pages_dirtied)
+		__field(long,	pause)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
+		__entry->bdi_dirty	= bdi_dirty;
+		__entry->bdi_limit	= bdi_limit;
+		__entry->task_limit	= task_limit;
+		__entry->pages_dirtied	= pages_dirtied;
+		__entry->pause		= pause * 1000 / HZ;
+	),
+
+
+	/*
+	 *           [..................soft throttling range.........]
+	 *           ^                |<=========== bdi_gap =========>|
+	 * background_thresh          |<== task_gap ==>|
+	 * -------------------|-------+----------------|--------------|
+	 *   (bdi_limit * 7/8)^       ^bdi_dirty       ^task_limit    ^bdi_limit
+	 *
+	 * Reasonable large gaps help produce smooth pause times.
+	 */
+	TP_printk("bdi=%s bdi_dirty=%lu bdi_limit=%lu task_limit=%lu "
+		  "task_weight=%ld%% task_gap=%ld%% bdi_gap=%ld%% "
+		  "pages_dirtied=%lu pause=%lu",
+		  __entry->bdi,
+		  __entry->bdi_dirty,
+		  __entry->bdi_limit,
+		  __entry->task_limit,
+		  /* task weight: proportion of recent dirtied pages */
+		  BDP_PERCENT(bdi_limit, task_limit, TASK_SOFT_DIRTY_LIMIT),
+		  BDP_PERCENT(task_limit, bdi_dirty, TASK_SOFT_DIRTY_LIMIT),
+		  BDP_PERCENT(bdi_limit, bdi_dirty, BDI_SOFT_DIRTY_LIMIT),
+		  __entry->pages_dirtied,
+		  __entry->pause
+		  )
+);
+
 DECLARE_EVENT_CLASS(writeback_congest_waited_template,
 
 	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
--- linux-next.orig/mm/page-writeback.c	2010-11-15 21:30:45.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-11-15 21:31:46.000000000 +0800
@@ -629,6 +629,12 @@ static void balance_dirty_pages(struct a
 		pause = clamp_val(pause, 1, HZ/10);
 
 pause:
+		trace_balance_dirty_pages(bdi,
+					  bdi_dirty,
+					  bdi_thresh,
+					  task_thresh,
+					  pages_dirtied,
+					  pause);
 		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
 		__set_current_state(TASK_INTERRUPTIBLE);
 		io_schedule_timeout(pause);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
