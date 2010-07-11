From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/6] writeback: reduce calls to global_page_state in balance_dirty_pages()
Date: Sun, 11 Jul 2010 10:06:58 +0800
Message-ID: <20100711021748.735126772@intel.com>
References: <20100711020656.340075560@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1OXmQy-0002JF-QD
	for glkm-linux-mm-2@m.gmane.org; Sun, 11 Jul 2010 04:38:25 +0200
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C85F26B02A6
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 22:38:11 -0400 (EDT)
Content-Disposition: inline; filename=writeback-less-balance-calc.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Reducing the number of times balance_dirty_pages calls global_page_state
reduces the cache references and so improves write performance on a
variety of workloads.

'perf stats' of simple fio write tests shows the reduction in cache
access.  Where the test is fio 'write,mmap,600Mb,pre_read' on AMD
AthlonX2 with 3Gb memory (dirty_threshold approx 600 Mb) running each
test 10 times, dropping the fasted & slowest values then taking the
average & standard deviation

		average (s.d.) in millions (10^6)
2.6.31-rc8	648.6 (14.6)
+patch		620.1 (16.5)

Achieving this reduction is by dropping clip_bdi_dirty_limit as it
rereads the counters to apply the dirty_threshold and moving this check
up into balance_dirty_pages where it has already read the counters.

Also by rearrange the for loop to only contain one copy of the limit
tests allows the pdflush test after the loop to use the local copies of
the counters rather than rereading them.

In the common case with no throttling it now calls global_page_state 5
fewer times and bdi_stat 2 fewer.

Fengguang:

This patch slightly changes behavior by replacing clip_bdi_dirty_limit()
with the explicit check (nr_reclaimable + nr_writeback >= dirty_thresh)
to avoid exceeding the dirty limit. Since the bdi dirty limit is mostly
accurate we don't need to do routinely clip. A simple dirty limit check
would be enough.

The check is necessary because, in principle we should throttle
everything calling balance_dirty_pages() when we're over the total
limit, as said by Peter.

We now set and clear dirty_exceeded not only based on bdi dirty limits,
but also on the global dirty limits. This is a bit counterintuitive, but
the global limits are the ultimate goal and shall be always imposed.

We may now start background writeback work based on outdated conditions.
That's safe because the bdi flush thread will (and have to) double check
the states. It reduces overall overheads because the test based on old
states still have good chance to be right.

CC: Jan Kara <jack@suse.cz>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   95 ++++++++++++++----------------------------
 1 file changed, 33 insertions(+), 62 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-07-11 08:42:14.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-07-11 08:44:49.000000000 +0800
@@ -253,32 +253,6 @@ static void bdi_writeout_fraction(struct
 	}
 }
 
-/*
- * Clip the earned share of dirty pages to that which is actually available.
- * This avoids exceeding the total dirty_limit when the floating averages
- * fluctuate too quickly.
- */
-static void clip_bdi_dirty_limit(struct backing_dev_info *bdi,
-		unsigned long dirty, unsigned long *pbdi_dirty)
-{
-	unsigned long avail_dirty;
-
-	avail_dirty = global_page_state(NR_FILE_DIRTY) +
-		 global_page_state(NR_WRITEBACK) +
-		 global_page_state(NR_UNSTABLE_NFS) +
-		 global_page_state(NR_WRITEBACK_TEMP);
-
-	if (avail_dirty < dirty)
-		avail_dirty = dirty - avail_dirty;
-	else
-		avail_dirty = 0;
-
-	avail_dirty += bdi_stat(bdi, BDI_RECLAIMABLE) +
-		bdi_stat(bdi, BDI_WRITEBACK);
-
-	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
-}
-
 static inline void task_dirties_fraction(struct task_struct *tsk,
 		long *numerator, long *denominator)
 {
@@ -469,7 +443,6 @@ get_dirty_limits(unsigned long *pbackgro
 			bdi_dirty = dirty * bdi->max_ratio / 100;
 
 		*pbdi_dirty = bdi_dirty;
-		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
 		task_dirty_limit(current, pbdi_dirty);
 	}
 }
@@ -491,7 +464,7 @@ static void balance_dirty_pages(struct a
 	unsigned long bdi_thresh;
 	unsigned long pages_written = 0;
 	unsigned long pause = 1;
-
+	int dirty_exceeded;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
 	for (;;) {
@@ -510,10 +483,35 @@ static void balance_dirty_pages(struct a
 		nr_writeback = global_page_state(NR_WRITEBACK) +
 			       global_page_state(NR_WRITEBACK_TEMP);
 
-		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
-		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
+		/*
+		 * In order to avoid the stacked BDI deadlock we need
+		 * to ensure we accurately count the 'dirty' pages when
+		 * the threshold is low.
+		 *
+		 * Otherwise it would be possible to get thresh+n pages
+		 * reported dirty, even though there are thresh-m pages
+		 * actually dirty; with m+n sitting in the percpu
+		 * deltas.
+		 */
+		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
+			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
+			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
+		} else {
+			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
+			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
+		}
+
+		/*
+		 * The bdi thresh is somehow "soft" limit derived from the
+		 * global "hard" limit. The former helps to prevent heavy IO
+		 * bdi or process from holding back light ones; The latter is
+		 * the last resort safeguard.
+		 */
+		dirty_exceeded =
+			(bdi_nr_reclaimable + bdi_nr_writeback >= bdi_thresh)
+			|| (nr_reclaimable + nr_writeback >= dirty_thresh);
 
-		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
+		if (!dirty_exceeded)
 			break;
 
 		/*
@@ -541,34 +539,10 @@ static void balance_dirty_pages(struct a
 		if (bdi_nr_reclaimable > bdi_thresh) {
 			writeback_inodes_wb(&bdi->wb, &wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
-			get_dirty_limits(&background_thresh, &dirty_thresh,
-				       &bdi_thresh, bdi);
 			trace_wbc_balance_dirty_written(&wbc, bdi);
+			if (pages_written >= write_chunk)
+				break;		/* We've done our duty */
 		}
-
-		/*
-		 * In order to avoid the stacked BDI deadlock we need
-		 * to ensure we accurately count the 'dirty' pages when
-		 * the threshold is low.
-		 *
-		 * Otherwise it would be possible to get thresh+n pages
-		 * reported dirty, even though there are thresh-m pages
-		 * actually dirty; with m+n sitting in the percpu
-		 * deltas.
-		 */
-		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
-			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
-		} else if (bdi_nr_reclaimable) {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
-		}
-
-		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
-			break;
-		if (pages_written >= write_chunk)
-			break;		/* We've done our duty */
-
 		trace_wbc_balance_dirty_wait(&wbc, bdi);
 		__set_current_state(TASK_INTERRUPTIBLE);
 		io_schedule_timeout(pause);
@@ -582,8 +556,7 @@ static void balance_dirty_pages(struct a
 			pause = HZ / 10;
 	}
 
-	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
-			bdi->dirty_exceeded)
+	if (!dirty_exceeded && bdi->dirty_exceeded)
 		bdi->dirty_exceeded = 0;
 
 	if (writeback_in_progress(bdi))
@@ -598,9 +571,7 @@ static void balance_dirty_pages(struct a
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
 	if ((laptop_mode && pages_written) ||
-	    (!laptop_mode && ((global_page_state(NR_FILE_DIRTY)
-			       + global_page_state(NR_UNSTABLE_NFS))
-					  > background_thresh)))
+	    (!laptop_mode && (nr_reclaimable > background_thresh)))
 		bdi_start_background_writeback(bdi);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
