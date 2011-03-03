Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D053F8D0050
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:59 -0500 (EST)
Message-Id: <20110303074950.846539981@intel.com>
Date: Thu, 03 Mar 2011 14:45:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 17/27] writeback: smoothed dirty threshold and limit
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-dirty-thresh-limit.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Both the global/bdi dirty thresholds may fluctuate undesirably.

- the start of a heavy weight application (ie. KVM) may instantly knock
  down determine_dirtyable_memory() and hence the global/bdi dirty thresholds.

- in JBOD setup, the bdi dirty thresholds are observed to fluctuate more

So maintain a version of smoothed bdi dirty threshold in
bdi->dirty_threshold and introduce the global dirty limit in
default_backing_dev_info.dirty_threshold.

The global limit can effectively mask out the impact of sudden drop of
dirtyable memory.  Without it, the dirtier tasks may be blocked in the
block area for 10s after someone eats 500MB memory; with the limit, the
dirtier tasks will be throttled at eg. 1/8 => 1/4 => 1/2 => original
dirty bandwith by the main control line and bring down the dirty pages
at reasonable speeds.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    3 +
 include/linux/writeback.h   |   34 +++++++++++++++++
 mm/backing-dev.c            |    1 
 mm/page-writeback.c         |   66 ++++++++++++++++++++++++++++++++++
 4 files changed, 104 insertions(+)

--- linux-next.orig/include/linux/writeback.h	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/include/linux/writeback.h	2011-03-03 14:44:07.000000000 +0800
@@ -12,6 +12,40 @@ struct backing_dev_info;
 extern spinlock_t inode_lock;
 
 /*
+ * 4MB minimal write chunk size
+ */
+#define MIN_WRITEBACK_PAGES	(4096UL >> (PAGE_CACHE_SHIFT - 10))
+
+/*
+ * The 1/4 region under the global dirty thresh is for smooth dirty throttling:
+ *
+ *		(thresh - 2*thresh/DIRTY_SCOPE, thresh)
+ *
+ * The 1/32 region under the global dirty limit will be more rigidly throttled:
+ *
+ *		(limit - limit/DIRTY_MARGIN, limit)
+ *
+ * The 1/32 region above the global dirty limit will be put to maximum pauses:
+ *
+ *		(limit, limit + limit/DIRTY_MARGIN)
+ *
+ * Further beyond, the dirtier task will enter a loop waiting (possibly long
+ * time) for the dirty pages to drop below (limit + limit/DIRTY_MARGIN).
+ *
+ * The last case may happen lightly when memory is very tight or at sudden
+ * workload rampup. Or under DoS situations such as a fork bomb where every new
+ * task dirties some more pages, or creating 10,000 tasks each writing to a USB
+ * key slowly in 4KB/s.
+ *
+ * The global dirty threshold is normally equal to global dirty limit, except
+ * when the system suddenly allocates a lot of anonymous memory and knocks down
+ * the global dirty threshold quickly, in which case the global dirty limit
+ * will follow down slowly to prevent livelocking all dirtier tasks.
+ */
+#define DIRTY_SCOPE		8
+#define DIRTY_MARGIN		(DIRTY_SCOPE * 4)
+
+/*
  * fs/fs-writeback.c
  */
 enum writeback_sync_modes {
--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:44:07.000000000 +0800
@@ -472,6 +472,24 @@ unsigned long bdi_dirty_limit(struct bac
 	return bdi_dirty;
 }
 
+/*
+ * If we can dirty N more pages globally, honour N/8 to the bdi that runs low,
+ * so as to help it ramp up.
+ *
+ * It helps the chicken and egg problem: when bdi A (eg. /pub) is heavy dirtied
+ * and bdi B (eg. /) is light dirtied hence has 0 dirty limit, tasks writing to
+ * B always get heavily throttled and bdi B's dirty limit might never be able
+ * to grow up from 0.
+ */
+static unsigned long dirty_rampup_size(unsigned long dirty,
+				       unsigned long thresh)
+{
+	if (thresh > dirty + MIN_WRITEBACK_PAGES)
+		return min(MIN_WRITEBACK_PAGES * 2, (thresh - dirty) / 8);
+
+	return MIN_WRITEBACK_PAGES / 8;
+}
+
 static void bdi_update_dirty_smooth(struct backing_dev_info *bdi,
 				    unsigned long dirty)
 {
@@ -563,6 +581,50 @@ static void __bdi_update_write_bandwidth
 	bdi->avg_bandwidth = avg;
 }
 
+static void update_dirty_limit(unsigned long thresh,
+			       unsigned long dirty)
+{
+	unsigned long limit = default_backing_dev_info.dirty_threshold;
+	unsigned long min = dirty + limit / DIRTY_MARGIN;
+
+	if (limit < thresh) {
+		limit = thresh;
+		goto out;
+	}
+
+	/* take care not to follow into the brake area */
+	if (limit > thresh + thresh / (DIRTY_MARGIN * 8) &&
+	    limit > min) {
+		limit -= (limit - max(thresh, min)) >> 3;
+		goto out;
+	}
+
+	return;
+out:
+	default_backing_dev_info.dirty_threshold = limit;
+}
+
+static void bdi_update_dirty_threshold(struct backing_dev_info *bdi,
+				       unsigned long thresh,
+				       unsigned long dirty)
+{
+	unsigned long old = bdi->old_dirty_threshold;
+	unsigned long avg = bdi->dirty_threshold;
+	unsigned long min;
+
+	min = dirty_rampup_size(dirty, thresh);
+	thresh = bdi_dirty_limit(bdi, thresh);
+
+	if (avg > old && old >= thresh)
+		avg -= (avg - old) >> 4;
+
+	if (avg < old && old <= thresh)
+		avg += (old - avg) >> 4;
+
+	bdi->dirty_threshold = max(avg, min);
+	bdi->old_dirty_threshold = thresh;
+}
+
 void bdi_update_bandwidth(struct backing_dev_info *bdi,
 			  unsigned long thresh,
 			  unsigned long dirty,
@@ -594,6 +656,10 @@ void bdi_update_bandwidth(struct backing
 	if (elapsed <= HZ/10)
 		goto unlock;
 
+	if (thresh) {
+		update_dirty_limit(thresh, dirty);
+		bdi_update_dirty_threshold(bdi, thresh, dirty);
+	}
 	__bdi_update_write_bandwidth(bdi, elapsed, written);
 	if (thresh) {
 		bdi_update_dirty_smooth(bdi, bdi_dirty);
--- linux-next.orig/include/linux/backing-dev.h	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-03-03 14:44:07.000000000 +0800
@@ -81,6 +81,9 @@ struct backing_dev_info {
 	unsigned long avg_bandwidth;
 	unsigned long avg_dirty;
 	unsigned long old_dirty;
+	unsigned long dirty_threshold;
+	unsigned long old_dirty_threshold;
+
 
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
--- linux-next.orig/mm/backing-dev.c	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-03-03 14:44:07.000000000 +0800
@@ -677,6 +677,7 @@ int bdi_init(struct backing_dev_info *bd
 
 	bdi->avg_dirty = 0;
 	bdi->old_dirty = 0;
+	bdi->dirty_threshold = MIN_WRITEBACK_PAGES;
 
 	err = prop_local_init_percpu(&bdi->completions);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
