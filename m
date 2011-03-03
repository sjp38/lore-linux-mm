Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A07A18D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:56 -0500 (EST)
Message-Id: <20110303074950.582280612@intel.com>
Date: Thu, 03 Mar 2011 14:45:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 15/27] writeback: bdi write bandwidth estimation
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-write-bandwidth.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Li Shaohua <shaohua.li@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

The estimation value will start from 50MB/s and adapt to the real
bandwidth in seconds.  It's pretty accurate for common filesystems.

The overheads won't be high because the bdi bandwidth update only occurs
in >100ms intervals.

Initially it's only estimated in balance_dirty_pages() because this is
the most reliable place to get reasonable large bandwidth -- the bdi is
normally fully utilized when bdi_thresh is reached.

Then Shaohua recommends to also do it in the flusher thread, to keep the
value updated when there are only periodic/background writeback and no
tasks throttled.

The original plan is to use per-cpu vars for bdi->write_bandwidth.
However Peter suggested that it opens the window that some CPU see
outdated values. So switch to use spinlock protected global vars.
A global spinlock is used with intention to update global states in
subsequent patches as well.

It tries to update the bandwidth only when disk is fully utilized.
Any inactive period of more than 500ms will be skipped.

The estimation is not done purely in the flusher thread because slow
devices may take dozens of seconds to write the initial 64MB chunk
(write_bandwidth starts with 50MB/s, this translates to 64MB
nr_to_write). So it may take more than 1 minute to adapt to the smallish
bandwidth if the bandwidth is only updated in the flusher thread.

CC: Li Shaohua <shaohua.li@intel.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           |    3 +
 include/linux/backing-dev.h |    5 ++
 include/linux/writeback.h   |   11 ++++
 mm/backing-dev.c            |   12 +++++
 mm/page-writeback.c         |   79 ++++++++++++++++++++++++++++++++++
 5 files changed, 110 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2011-03-03 14:43:50.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-03-03 14:44:07.000000000 +0800
@@ -662,6 +662,7 @@ static long wb_writeback(struct bdi_writ
 		write_chunk = LONG_MAX;
 
 	wbc.wb_start = jiffies; /* livelock avoidance */
+	bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
 	for (;;) {
 		/*
 		 * Stop writeback when nr_pages has been consumed
@@ -697,6 +698,8 @@ static long wb_writeback(struct bdi_writ
 			writeback_inodes_wb(wb, &wbc);
 		trace_wbc_writeback_written(&wbc, wb->bdi);
 
+		bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
+
 		work->nr_pages -= write_chunk - wbc.nr_to_write;
 		wrote += write_chunk - wbc.nr_to_write;
 
--- linux-next.orig/include/linux/backing-dev.h	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-03-03 14:44:11.000000000 +0800
@@ -75,6 +75,11 @@ struct backing_dev_info {
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
+	unsigned long bw_time_stamp;
+	unsigned long written_stamp;
+	unsigned long write_bandwidth;
+	unsigned long avg_bandwidth;
+
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
 
--- linux-next.orig/include/linux/writeback.h	2011-03-03 14:43:50.000000000 +0800
+++ linux-next/include/linux/writeback.h	2011-03-03 14:44:10.000000000 +0800
@@ -128,6 +128,17 @@ void global_dirty_limits(unsigned long *
 unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
 			       unsigned long dirty);
 
+void bdi_update_bandwidth(struct backing_dev_info *bdi,
+			  unsigned long thresh,
+			  unsigned long dirty,
+			  unsigned long bdi_dirty,
+			  unsigned long start_time);
+static inline void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+					      unsigned long start_time)
+{
+	bdi_update_bandwidth(bdi, 0, 0, 0, start_time);
+}
+
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 					unsigned long nr_pages_dirtied);
--- linux-next.orig/mm/backing-dev.c	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-03-03 14:44:11.000000000 +0800
@@ -641,6 +641,11 @@ static void bdi_wb_init(struct bdi_write
 	setup_timer(&wb->wakeup_timer, wakeup_timer_fn, (unsigned long)bdi);
 }
 
+/*
+ * initial write bandwidth: 50 MB/s
+ */
+#define INIT_BW		(50 << (20 - PAGE_SHIFT))
+
 int bdi_init(struct backing_dev_info *bdi)
 {
 	int i, err;
@@ -663,6 +668,13 @@ int bdi_init(struct backing_dev_info *bd
 	}
 
 	bdi->dirty_exceeded = 0;
+
+	bdi->bw_time_stamp = jiffies;
+	bdi->written_stamp = 0;
+
+	bdi->write_bandwidth = INIT_BW;
+	bdi->avg_bandwidth = INIT_BW;
+
 	err = prop_local_init_percpu(&bdi->completions);
 
 	if (err) {
--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:44:11.000000000 +0800
@@ -472,6 +472,79 @@ unsigned long bdi_dirty_limit(struct bac
 	return bdi_dirty;
 }
 
+static void __bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+					 unsigned long elapsed,
+					 unsigned long written)
+{
+	const unsigned long period = roundup_pow_of_two(3 * HZ);
+	unsigned long avg = bdi->avg_bandwidth;
+	unsigned long old = bdi->write_bandwidth;
+	unsigned long cur;
+	u64 bw;
+
+	bw = written - bdi->written_stamp;
+	bw *= HZ;
+	if (unlikely(elapsed > period / 2)) {
+		do_div(bw, elapsed);
+		elapsed = period / 2;
+		bw *= elapsed;
+	}
+	bw += (u64)bdi->write_bandwidth * (period - elapsed);
+	cur = bw >> ilog2(period);
+	bdi->write_bandwidth = cur;
+
+	/*
+	 * one more level of smoothing
+	 */
+	if (avg > old && old > cur)
+		avg -= (avg - old) >> 5;
+
+	if (avg < old && old < cur)
+		avg += (old - avg) >> 5;
+
+	bdi->avg_bandwidth = avg;
+}
+
+void bdi_update_bandwidth(struct backing_dev_info *bdi,
+			  unsigned long thresh,
+			  unsigned long dirty,
+			  unsigned long bdi_dirty,
+			  unsigned long start_time)
+{
+	static DEFINE_SPINLOCK(dirty_lock);
+	unsigned long now = jiffies;
+	unsigned long elapsed;
+	unsigned long written;
+
+	if (!spin_trylock(&dirty_lock))
+		return;
+
+	elapsed = now - bdi->bw_time_stamp;
+	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
+
+	/* skip quiet periods when disk bandwidth is under-utilized */
+	if (elapsed > HZ/2 &&
+	    elapsed > now - start_time)
+		goto snapshot;
+
+	/*
+	 * rate-limit, only update once every 100ms. Demand higher threshold
+	 * on the flusher so that the throttled task(s) can do most updates.
+	 */
+	if (!thresh && elapsed <= HZ/4)
+		goto unlock;
+	if (elapsed <= HZ/10)
+		goto unlock;
+
+	__bdi_update_write_bandwidth(bdi, elapsed, written);
+
+snapshot:
+	bdi->written_stamp = written;
+	bdi->bw_time_stamp = now;
+unlock:
+	spin_unlock(&dirty_lock);
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -491,6 +564,7 @@ static void balance_dirty_pages(struct a
 	unsigned long pause = 1;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	unsigned long start_time = jiffies;
 
 	if (!bdi_cap_account_dirty(bdi))
 		return;
@@ -539,6 +613,11 @@ static void balance_dirty_pages(struct a
 			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		bdi_update_bandwidth(bdi, dirty_thresh,
+				     nr_reclaimable + nr_writeback,
+				     bdi_nr_reclaimable + bdi_nr_writeback,
+				     start_time);
+
 		/*
 		 * The bdi thresh is somehow "soft" limit derived from the
 		 * global "hard" limit. The former helps to prevent heavy IO


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
