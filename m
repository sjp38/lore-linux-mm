From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/35] writeback: bdi write bandwidth estimation
Date: Mon, 13 Dec 2010 22:46:56 +0800
Message-ID: <20101213150327.573549251@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-bandwidth-estimation-in-flusher.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Li Shaohua <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

The estimation value will start from 100MB/s and adapt to the real
bandwidth in seconds.  It's pretty accurate for common filesystems.

As the first use case, it replaces the fixed 100MB/s value used for
throttle bandwidth calculation in balance_dirty_pages().

The overheads won't be high because the bdi bandwidth update only occurs
in >10ms intervals.

Initially it's only estimated in balance_dirty_pages() because this is
the most reliable place to get reasonable large bandwidth -- the bdi is
normally fully utilized when bdi_thresh is reached.

Then Shaohua recommends to also do it in the flusher thread, to keep the
value updated when there are only periodic/background writeback and no
tasks throttled.

The original plan is to use per-cpu vars for bdi->write_bandwidth.
However Peter suggested that it opens the window that some CPU see
outdated values. So switch to use spinlock protected global vars.

It tries to update the bandwidth only when disk is fully utilized.
Any inactive period of more than 500ms will be skipped.

The estimation is not done purely in the flusher thread because slow
devices may take dozens of seconds to write the initial 64MB chunk
(write_bandwidth starts with 100MB/s, this translates to 64MB
nr_to_write). So it may take more than 1 minute to adapt to the smallish
bandwidth if the bandwidth is only updated in the flusher thread.

CC: Li Shaohua <shaohua.li@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           |    4 ++
 include/linux/backing-dev.h |    5 ++
 include/linux/writeback.h   |   10 +++++
 mm/backing-dev.c            |    3 +
 mm/page-writeback.c         |   59 ++++++++++++++++++++++++++++++++--
 5 files changed, 78 insertions(+), 3 deletions(-)

--- linux-next.orig/include/linux/backing-dev.h	2010-12-13 21:46:13.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-12-13 21:46:14.000000000 +0800
@@ -74,6 +74,11 @@ struct backing_dev_info {
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
+	spinlock_t bw_lock;
+	unsigned long bw_time_stamp;
+	unsigned long written_stamp;
+	unsigned long write_bandwidth;
+
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
 
--- linux-next.orig/mm/backing-dev.c	2010-12-13 21:46:13.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-12-13 21:46:14.000000000 +0800
@@ -660,6 +660,9 @@ int bdi_init(struct backing_dev_info *bd
 			goto err;
 	}
 
+	spin_lock_init(&bdi->bw_lock);
+	bdi->write_bandwidth = 100 << (20 - PAGE_SHIFT);  /* 100 MB/s */
+
 	bdi->dirty_exceeded = 0;
 	err = prop_local_init_percpu(&bdi->completions);
 
--- linux-next.orig/fs/fs-writeback.c	2010-12-13 21:46:10.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-12-13 21:46:14.000000000 +0800
@@ -668,6 +668,8 @@ static long wb_writeback(struct bdi_writ
 		write_chunk = LONG_MAX;
 
 	wbc.wb_start = jiffies; /* livelock avoidance */
+	bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
+
 	for (;;) {
 		/*
 		 * Stop writeback when nr_pages has been consumed
@@ -703,6 +705,8 @@ static long wb_writeback(struct bdi_writ
 			writeback_inodes_wb(wb, &wbc);
 		trace_wbc_writeback_written(&wbc, wb->bdi);
 
+		bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
+
 		work->nr_pages -= write_chunk - wbc.nr_to_write;
 		wrote += write_chunk - wbc.nr_to_write;
 
--- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:13.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-13 21:46:14.000000000 +0800
@@ -521,6 +521,56 @@ out:
 	return 1 + int_sqrt(dirty_thresh - dirty_pages);
 }
 
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
+{
+	unsigned long elapsed;
+	unsigned long written;
+
+	if (!spin_trylock(&bdi->bw_lock))
+		return;
+
+	elapsed = jiffies - bdi->bw_time_stamp;
+	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
+
+	/* skip quiet periods when disk bandwidth is under-utilized */
+	if (elapsed > HZ/2 &&
+	    elapsed > jiffies - start_time)
+		goto snapshot;
+
+	/* rate-limit, only update once every 100ms */
+	if (elapsed <= HZ/10)
+		goto unlock;
+
+	__bdi_update_write_bandwidth(bdi, elapsed, written);
+
+snapshot:
+	bdi->written_stamp = written;
+	bdi->bw_time_stamp = jiffies;
+unlock:
+	spin_unlock(&bdi->bw_lock);
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -537,11 +587,12 @@ static void balance_dirty_pages(struct a
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
-	unsigned long bw;
+	unsigned long long bw;
 	unsigned long period;
 	unsigned long pause = 0;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	unsigned long start_time = jiffies;
 
 	for (;;) {
 		/*
@@ -585,17 +636,19 @@ static void balance_dirty_pages(struct a
 				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
+
 		if (bdi_dirty >= bdi_thresh || nr_dirty > dirty_thresh) {
 			pause = MAX_PAUSE;
 			goto pause;
 		}
 
-		bw = 100 << 20; /* use static 100MB/s for the moment */
+		bw = bdi->write_bandwidth;
 
 		bw = bw * (bdi_thresh - bdi_dirty);
 		do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
 
-		period = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1) + 1;
+		period = HZ * pages_dirtied / ((unsigned long)bw + 1) + 1;
 		pause = current->paused_when + period - jiffies;
 		/*
 		 * Take it as long think time if pause falls into (-10s, 0).
--- linux-next.orig/include/linux/writeback.h	2010-12-13 21:46:12.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-12-13 21:46:14.000000000 +0800
@@ -139,6 +139,16 @@ unsigned long bdi_dirty_limit(struct bac
 			       unsigned long dirty,
 			       unsigned long dirty_pages);
 
+void bdi_update_bandwidth(struct backing_dev_info *bdi,
+			  unsigned long start_time,
+			  unsigned long bdi_dirty,
+			  unsigned long bdi_thresh);
+static inline void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+					      unsigned long start_time)
+{
+	bdi_update_bandwidth(bdi, start_time, 0, 0);
+}
+
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 					unsigned long nr_pages_dirtied);
