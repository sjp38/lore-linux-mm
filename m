From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 23/47] writeback: spinlock protected bdi bandwidth update
Date: Mon, 13 Dec 2010 14:43:12 +0800
Message-ID: <20101213064839.785105287@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-trylock.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

The original plan is to use per-cpu vars for bdi->write_bandwidth.
However Peter suggested that it opens the window that some CPU see
outdated values. So switch to use spinlock protected global vars.

It tries to update the bandwidth only when disk is fully utilized.
Any inactive period of more than 500ms will be skipped.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           |    7 +--
 include/linux/backing-dev.h |    4 +
 include/linux/writeback.h   |   13 ++++-
 mm/backing-dev.c            |    4 +
 mm/page-writeback.c         |   74 +++++++++++++++++++---------------
 5 files changed, 62 insertions(+), 40 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-08 22:44:29.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 22:44:29.000000000 +0800
@@ -523,41 +523,54 @@ out:
 	return 1 + int_sqrt(dirty_thresh - dirty_pages);
 }
 
-void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
-				unsigned long *bw_time,
-				s64 *bw_written)
+static void __bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+					 unsigned long elapsed,
+					 unsigned long written)
+{
+	const unsigned long period = roundup_pow_of_two(HZ);
+	u64 bw;
+
+	bw = written - bdi->written_stamp;
+	bw *= HZ;
+	if (elapsed > period / 2) {
+		do_div(bw, elapsed);
+		elapsed = period / 2;
+		bw *= elapsed;
+	}
+	bw += (u64)bdi->write_bandwidth * (period - elapsed);
+	bdi->write_bandwidth = bw >> ilog2(period);
+}
+
+void bdi_update_bandwidth(struct backing_dev_info *bdi,
+			  unsigned long start_time,
+			  unsigned long bdi_dirty,
+			  unsigned long bdi_thresh)
 {
-	const unsigned long unit_time = max(HZ/100, 1);
-	unsigned long written;
 	unsigned long elapsed;
-	unsigned long bw;
-	unsigned long long w;
-
-	if (*bw_written == 0)
-		goto snapshot;
+	unsigned long written;
 
-	elapsed = jiffies - *bw_time;
-	if (elapsed < unit_time)
+	if (!spin_trylock(&bdi->bw_lock))
 		return;
 
-	/*
-	 * When there lots of tasks throttled in balance_dirty_pages(), they
-	 * will each try to update the bandwidth for the same period, making
-	 * the bandwidth drift much faster than the desired rate (as in the
-	 * single dirtier case). So do some rate limiting.
-	 */
-	if (jiffies - bdi->write_bandwidth_update_time < elapsed)
+	elapsed = jiffies - bdi->bw_time_stamp;
+	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
+
+	/* skip quiet periods when disk bandwidth is under-utilized */
+	if (elapsed > HZ/2 &&
+	    elapsed > jiffies - start_time)
 		goto snapshot;
 
-	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]) - *bw_written;
-	bw = (HZ * written + elapsed / 2) / elapsed;
-	w = min(elapsed / unit_time, 128UL);
-	bdi->write_bandwidth = (bdi->write_bandwidth * (1024-w) +
-				bw * w + 1023) >> 10;
-	bdi->write_bandwidth_update_time = jiffies;
+	/* rate-limit, only update once every 100ms */
+	if (elapsed <= HZ/10)
+		goto unlock;
+
+	__bdi_update_write_bandwidth(bdi, elapsed, written);
+
 snapshot:
-	*bw_written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
-	*bw_time = jiffies;
+	bdi->written_stamp = written;
+	bdi->bw_time_stamp = jiffies;
+unlock:
+	spin_unlock(&bdi->bw_lock);
 }
 
 /*
@@ -582,8 +595,7 @@ static void balance_dirty_pages(struct a
 	unsigned long pause = 0;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
-	unsigned long bw_time;
-	s64 bw_written = 0;
+	unsigned long start_time = jiffies;
 
 	for (;;) {
 		/*
@@ -645,6 +657,8 @@ static void balance_dirty_pages(struct a
 			break;
 		bdi_prev_dirty = bdi_dirty;
 
+		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
+
 		if (bdi_dirty >= task_thresh) {
 			pause = HZ/10;
 			goto pause;
@@ -674,10 +688,8 @@ pause:
 					  task_thresh,
 					  pages_dirtied,
 					  pause);
-		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
 		__set_current_state(TASK_UNINTERRUPTIBLE);
 		io_schedule_timeout(pause);
-		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
 
 		/*
 		 * The bdi thresh is somehow "soft" limit derived from the
--- linux-next.orig/include/linux/backing-dev.h	2010-12-08 22:44:29.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-12-08 22:44:29.000000000 +0800
@@ -74,8 +74,10 @@ struct backing_dev_info {
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
+	spinlock_t bw_lock;
+	unsigned long bw_time_stamp;
+	unsigned long written_stamp;
 	unsigned long write_bandwidth;
-	unsigned long write_bandwidth_update_time;
 
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
--- linux-next.orig/mm/backing-dev.c	2010-12-08 22:44:29.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-12-08 22:44:29.000000000 +0800
@@ -662,7 +662,9 @@ int bdi_init(struct backing_dev_info *bd
 			goto err;
 	}
 
-	bdi->write_bandwidth = (100 << 20) / PAGE_CACHE_SIZE;
+	spin_lock_init(&bdi->bw_lock);
+	bdi->write_bandwidth = 100 << (20 - PAGE_SHIFT);  /* 100 MB/s */
+
 	bdi->dirty_exceeded = 0;
 	err = prop_local_init_percpu(&bdi->completions);
 
--- linux-next.orig/fs/fs-writeback.c	2010-12-08 22:44:27.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-12-08 22:44:29.000000000 +0800
@@ -645,8 +645,6 @@ static long wb_writeback(struct bdi_writ
 		.range_cyclic		= work->range_cyclic,
 	};
 	unsigned long oldest_jif;
-	unsigned long bw_time;
-	s64 bw_written = 0;
 	long wrote = 0;
 	long write_chunk;
 	struct inode *inode;
@@ -680,7 +678,7 @@ static long wb_writeback(struct bdi_writ
 		write_chunk = LONG_MAX;
 
 	wbc.wb_start = jiffies; /* livelock avoidance */
-	bdi_update_write_bandwidth(wb->bdi, &bw_time, &bw_written);
+	bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
 
 	for (;;) {
 		/*
@@ -717,7 +715,8 @@ static long wb_writeback(struct bdi_writ
 		else
 			writeback_inodes_wb(wb, &wbc);
 		trace_wbc_writeback_written(&wbc, wb->bdi);
-		bdi_update_write_bandwidth(wb->bdi, &bw_time, &bw_written);
+
+		bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
 
 		work->nr_pages -= write_chunk - wbc.nr_to_write;
 		wrote += write_chunk - wbc.nr_to_write;
--- linux-next.orig/include/linux/writeback.h	2010-12-08 22:44:26.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-12-08 22:44:29.000000000 +0800
@@ -139,9 +139,16 @@ void global_dirty_limits(unsigned long *
 unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
 			       unsigned long dirty,
 			       unsigned long dirty_pages);
-void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
-				unsigned long *bw_time,
-				s64 *bw_written);
+
+void bdi_update_bandwidth(struct backing_dev_info *bdi,
+			  unsigned long start_time,
+			  unsigned long bdi_dirty,
+			  unsigned long bdi_thresh);
+static inline void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+					      unsigned long start_time)
+{
+	bdi_update_bandwidth(bdi, start_time, 0, 0);
+}
 
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,


