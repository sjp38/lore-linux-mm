Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3A9A06B0085
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:02 -0400 (EDT)
Message-Id: <20100912155203.668993282@intel.com>
Date: Sun, 12 Sep 2010 23:49:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/17] writeback: add trace event for balance_dirty_pages()
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=writeback-trace-balance_dirty_pages.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Here is an interesting test to verify the theory with balance_dirty_pages()
tracing. On a partition that can do ~60MB/s, a sparse file is created and
4 rsync tasks with different write bandwidth started:

	dd if=/dev/zero of=/mnt/1T bs=1M count=1 seek=1024000
	echo 1 > /debug/tracing/events/writeback/balance_dirty_pages/enable

	rsync localhost:/mnt/1T /mnt/a --bwlimit 10000&
	rsync localhost:/mnt/1T /mnt/A --bwlimit 10000&
	rsync localhost:/mnt/1T /mnt/b --bwlimit 20000&
	rsync localhost:/mnt/1T /mnt/c --bwlimit 30000&

	(btw, is there a dd that can do --bwlimit?
	 it's a bit twisted to use rsync, or lftp net:limit-rate)

Trace outputs within 0.1 second, grouped by tasks:

rsync-3824  [004] 15002.076447: balance_dirty_pages: bdi=btrfs-2 weight=15% thresh=130876 gap=5340 dirtied=192 pause=20 bw=34855512

rsync-3822  [003] 15002.091701: balance_dirty_pages: bdi=btrfs-2 weight=15% thresh=130777 gap=5113 dirtied=192 pause=20 bw=33419085

rsync-3821  [006] 15002.004667: balance_dirty_pages: bdi=btrfs-2 weight=30% thresh=129570 gap=3714 dirtied=64 pause=8 bw=24541625
rsync-3821  [006] 15002.012654: balance_dirty_pages: bdi=btrfs-2 weight=30% thresh=129589 gap=3733 dirtied=64 pause=8 bw=24651878
rsync-3821  [006] 15002.021838: balance_dirty_pages: bdi=btrfs-2 weight=30% thresh=129604 gap=3748 dirtied=64 pause=8 bw=24768628
rsync-3821  [004] 15002.091193: balance_dirty_pages: bdi=btrfs-2 weight=29% thresh=129583 gap=3983 dirtied=64 pause=8 bw=26274370
rsync-3821  [004] 15002.102729: balance_dirty_pages: bdi=btrfs-2 weight=29% thresh=129594 gap=3802 dirtied=64 pause=8 bw=25015422
rsync-3821  [000] 15002.109252: balance_dirty_pages: bdi=btrfs-2 weight=29% thresh=129619 gap=3827 dirtied=64 pause=8 bw=25179342

rsync-3823  [002] 15002.009029: balance_dirty_pages: bdi=btrfs-2 weight=39% thresh=128762 gap=2842 dirtied=64 pause=12 bw=18885024
rsync-3823  [002] 15002.021598: balance_dirty_pages: bdi=btrfs-2 weight=39% thresh=128813 gap=3021 dirtied=64 pause=12 bw=20088241
rsync-3823  [003] 15002.032973: balance_dirty_pages: bdi=btrfs-2 weight=39% thresh=128805 gap=2885 dirtied=64 pause=12 bw=19146453
rsync-3823  [003] 15002.048800: balance_dirty_pages: bdi=btrfs-2 weight=39% thresh=128823 gap=2967 dirtied=64 pause=12 bw=19673334
rsync-3823  [003] 15002.060728: balance_dirty_pages: bdi=btrfs-2 weight=39% thresh=128821 gap=3221 dirtied=64 pause=12 bw=21362280
rsync-3823  [000] 15002.073152: balance_dirty_pages: bdi=btrfs-2 weight=39% thresh=128825 gap=3225 dirtied=64 pause=12 bw=21385010
rsync-3823  [005] 15002.090111: balance_dirty_pages: bdi=btrfs-2 weight=39% thresh=128782 gap=3214 dirtied=64 pause=12 bw=21333266
rsync-3823  [004] 15002.102520: balance_dirty_pages: bdi=btrfs-2 weight=39% thresh=128764 gap=3036 dirtied=64 pause=12 bw=20104559

The data vividly show that
- the heaviest writer is throttled a bit (weight=39%)
- the lighter writers run at full speed (weight=15%,15%,30%)
  rsync is smart enough to compensate for the in-kernel pause time

Don't be confused by the 'bw=' field. It does not take user space
think time into account.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   47 +++++++++++++++++++++++++++--
 mm/page-writeback.c              |    5 +++
 2 files changed, 49 insertions(+), 3 deletions(-)

--- linux-next.orig/include/trace/events/writeback.h	2010-09-07 23:16:28.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2010-09-07 23:20:17.000000000 +0800
@@ -148,11 +148,52 @@ DEFINE_EVENT(wbc_class, name, \
 DEFINE_WBC_EVENT(wbc_writeback_start);
 DEFINE_WBC_EVENT(wbc_writeback_written);
 DEFINE_WBC_EVENT(wbc_writeback_wait);
-DEFINE_WBC_EVENT(wbc_balance_dirty_start);
-DEFINE_WBC_EVENT(wbc_balance_dirty_written);
-DEFINE_WBC_EVENT(wbc_balance_dirty_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+TRACE_EVENT(balance_dirty_pages,
+
+	TP_PROTO(struct backing_dev_info *bdi,
+		 unsigned long task_weight,
+		 unsigned long bdi_thresh,
+		 unsigned long gap,
+		 unsigned long bw,
+		 unsigned long pages_dirtied,
+		 unsigned long pause),
+
+	TP_ARGS(bdi, task_weight, bdi_thresh, gap, bw, pages_dirtied, pause),
+
+	TP_STRUCT__entry(
+		__array(char,		bdi, 32)
+		__field(unsigned long,	task_weight)
+		__field(unsigned long,	bdi_thresh)
+		__field(unsigned long,	gap)
+		__field(unsigned long,	bw)
+		__field(unsigned long,	pages_dirtied)
+		__field(unsigned long,	pause)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
+		__entry->task_weight	= task_weight;
+		__entry->bdi_thresh	= bdi_thresh;
+		__entry->gap		= gap;
+		__entry->bw		= bw;
+		__entry->pages_dirtied	= pages_dirtied;
+		__entry->pause		= pause * 1000 / HZ;
+	),
+
+	TP_printk("bdi=%s weight=%lu%% "
+		  "thresh=%lu gap=%lu dirtied=%lu pause=%lu bw=%lu",
+		  __entry->bdi,
+		  __entry->task_weight,
+		  __entry->bdi_thresh,
+		  __entry->gap,
+		  __entry->pages_dirtied,
+		  __entry->pause,
+		  __entry->bw
+		  )
+);
+
 #endif /* _TRACE_WRITEBACK_H */
 
 /* This part must be outside protection */
--- linux-next.orig/mm/page-writeback.c	2010-09-07 23:20:02.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-09-07 23:21:58.000000000 +0800
@@ -536,6 +536,11 @@ static void balance_dirty_pages(struct a
 		} else if (pause < HZ/100)
 			current->nr_dirtied_pause++;
 
+		trace_balance_dirty_pages(bdi,
+					  100 * numerator / denominator,
+					  bdi_thresh, gap, bw,
+					  pages_dirtied, pause);
+
 		__set_current_state(TASK_INTERRUPTIBLE);
 		io_schedule_timeout(pause);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
