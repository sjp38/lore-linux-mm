Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 62F308D004B
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:58 -0500 (EST)
Message-Id: <20110303074951.315304132@intel.com>
Date: Thu, 03 Mar 2011 14:45:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 20/27] writeback: IO-less balance_dirty_pages() 
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-ioless-balance_dirty_pages.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

As proposed by Chris, Dave and Jan, don't start foreground writeback IO
inside balance_dirty_pages(). Instead, simply let it idle sleep for some
time to throttle the dirtying task. In the mean while, kick off the
per-bdi flusher thread to do background writeback IO.

RATIONALS
=========

The current balance_dirty_pages() is rather IO inefficient.

- concurrent writeback of multiple inodes (Dave Chinner)

  If every thread doing writes and being throttled start foreground
  writeback, it leads to N IO submitters from at least N different
  inodes at the same time, end up with N different sets of IO being
  issued with potentially zero locality to each other, resulting in
  much lower elevator sort/merge efficiency and hence we seek the disk
  all over the place to service the different sets of IO.
  OTOH, if there is only one submission thread, it doesn't jump between
  inodes in the same way when congestion clears - it keeps writing to
  the same inode, resulting in large related chunks of sequential IOs
  being issued to the disk. This is more efficient than the above
  foreground writeback because the elevator works better and the disk
  seeks less.

- IO size too small for fast arrays and too large for slow USB sticks

  The write_chunk used by current balance_dirty_pages() cannot be
  directly set to some large value (eg. 128MB) for better IO efficiency.
  Because it could lead to more than 1 second user perceivable stalls.
  Even the current 4MB write size may be too large for slow USB sticks.
  The fact that balance_dirty_pages() starts IO on itself couples the
  IO size to wait time, which makes it hard to do suitable IO size while
  keeping the wait time under control.

For the above two reasons, it's much better to shift IO to the flusher
threads and let balance_dirty_pages() just wait for enough time or progress.

Jan Kara, Dave Chinner and me explored the scheme to let
balance_dirty_pages() wait for enough writeback IO completions to
safeguard the dirty limit. However it's found to have two problems:

- in large NUMA systems, the per-cpu counters may have big accounting
  errors, leading to big throttle wait time and jitters.

- NFS may kill large amount of unstable pages with one single COMMIT.
  Because NFS server serves COMMIT with expensive fsync() IOs, it is
  desirable to delay and reduce the number of COMMITs. So it's not
  likely to optimize away such kind of bursty IO completions, and the
  resulted large (and tiny) stall times in IO completion based throttling.

So here is a pause time oriented approach, which tries to control the
pause time in each balance_dirty_pages() invocations, by controlling
the number of pages dirtied before calling balance_dirty_pages(), for
smooth and efficient dirty throttling:

- avoid useless (eg. zero pause time) balance_dirty_pages() calls
- avoid too small pause time (less than  10ms, which burns CPU power)
- avoid too large pause time (more than 200ms, which hurts responsiveness)
- avoid big fluctuations of pause times

For example, when doing a simple cp on ext4 with mem=4G HZ=250.

before patch, the pause time fluctuates from 0 to 324ms
(and the stall time may grow very large for slow devices)

[ 1237.139962] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=56
[ 1237.207489] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0
[ 1237.225190] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0
[ 1237.234488] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0
[ 1237.244692] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0
[ 1237.375231] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=31
[ 1237.443035] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=15
[ 1237.574630] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=31
[ 1237.642394] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=15
[ 1237.666320] balance_dirty_pages: write_chunk=1536 pages_written=57 pause=5
[ 1237.973365] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=81
[ 1238.212626] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=56
[ 1238.280431] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=15
[ 1238.412029] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=31
[ 1238.412791] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0

after patch, the pause time remains stable around 32ms

cp-2687  [002]  1452.237012: balance_dirty_pages: weight=56% dirtied=128 pause=8
cp-2687  [002]  1452.246157: balance_dirty_pages: weight=56% dirtied=128 pause=8
cp-2687  [006]  1452.253043: balance_dirty_pages: weight=56% dirtied=128 pause=8
cp-2687  [006]  1452.261899: balance_dirty_pages: weight=57% dirtied=128 pause=8
cp-2687  [006]  1452.268939: balance_dirty_pages: weight=57% dirtied=128 pause=8
cp-2687  [002]  1452.276932: balance_dirty_pages: weight=57% dirtied=128 pause=8
cp-2687  [002]  1452.285889: balance_dirty_pages: weight=57% dirtied=128 pause=8


PSEUDO THROTTLE CODE
====================

balance_dirty_pages():

	/* soft throttling */
	if (within dirty control scope)
		sleep (dirtied_pages / throttle_bandwidth)

	/* max throttling */
	if (dirty_limit exceeded)
		sleep 200ms

	/* block waiting */
	while (dirty_limit+dirty_limit/32 exceeded)
		sleep 200ms


BEHAVIOR CHANGE
===============

Users will notice that the applications will get throttled once crossing
the global (background + dirty)/2=15% threshold, and be balanced around
17.5%. Before patch, the behavior is to just throttle it at 20%
dirtyable memory.

Since the task will be soft throttled earlier than before, it may be
perceived by end users as performance "slow down" if his application
happens to dirty more than 15% dirtyable memory.

THINK TIME
==========

The task's think time is into account when computing the final pause time.
This will make accurate throttle bandwidth. In the rare case that the task
slept longer than the period time, the extra sleep time will also be
compensated in next period if it's not too big (<500ms).  Accumulated
errors are carefully avoided as long as the task don't sleep for too
long time.

case 1: period > think

                pause = period - think
                paused_when += pause

                             period time
              |======================================>|
                  think time
              |===============>|
        ------|----------------|----------------------|-----------
        paused_when         jiffies


case 2: period <= think

                don't pause and reduce future pause time by:
                paused_when += period

                       period time
              |=========================>|
                             think time
              |======================================>|
        ------|--------------------------+------------|-----------
        paused_when                                jiffies


BENCHMARKS
==========

The test box has a 4-core 3.2GHz CPU, 4GB mem and a SATA disk.

For each filesystem, the following command is run 3 times.

time (dd if=/dev/zero of=/tmp/10G bs=1M count=10240; sync); rm /tmp/10G

	    2.6.36-rc2-mm1	2.6.36-rc2-mm1+balance_dirty_pages
average real time
ext2        236.377s            232.144s              -1.8%
ext3        226.245s            225.751s              -0.2%
ext4        178.742s            179.343s              +0.3%
xfs         183.562s            179.808s              -2.0%
btrfs       179.044s            179.461s              +0.2%
NFS         645.627s            628.937s              -2.6%

average system time
ext2         22.142s             19.656s             -11.2%
ext3         34.175s             32.462s              -5.0%
ext4         23.440s             21.162s              -9.7%
xfs          19.089s             16.069s             -15.8%
btrfs        12.212s             11.670s              -4.4%
NFS          16.807s             17.410s              +3.6%

total user time
sum           0.136s              0.084s             -38.2%

In a more recent run of the tests, it's in fact slightly slower.

ext2         49.500 MB/s         49.200 MB/s          -0.6%
ext3         50.133 MB/s         50.000 MB/s          -0.3%
ext4         64.000 MB/s         63.200 MB/s          -1.2%
xfs          63.500 MB/s         63.167 MB/s          -0.5%
btrfs        63.133 MB/s         63.033 MB/s          -0.2%
NFS          16.833 MB/s         16.867 MB/s          +0.2%

In general there are no big IO performance changes for desktop users,
except for some noticeable reduction of CPU overheads. It mainly
benefits file servers with heavy concurrent writers on fast storage
arrays. As can be demonstrated by 10/100 concurrent dd's on xfs:

- 1 dirtier case:    the same
- 10 dirtiers case:  CPU system time is reduced to 50%
- 100 dirtiers case: CPU system time is reduced to 10%,
  		     IO size and throughput increases by 10%

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    1 
 include/linux/sched.h       |    8 
 mm/backing-dev.c            |    2 
 mm/memory_hotplug.c         |    3 
 mm/page-writeback.c         |  354 +++++++++++++++-------------------
 5 files changed, 169 insertions(+), 199 deletions(-)

--- linux-next.orig/include/linux/sched.h	2011-03-03 14:43:49.000000000 +0800
+++ linux-next/include/linux/sched.h	2011-03-03 14:44:23.000000000 +0800
@@ -1487,6 +1487,14 @@ struct task_struct {
 	int make_it_fail;
 #endif
 	struct prop_local_single dirties;
+	/*
+	 * when (nr_dirtied >= nr_dirtied_pause), it's time to call
+	 * balance_dirty_pages() for some dirty throttling pause
+	 */
+	int nr_dirtied;
+	int nr_dirtied_pause;
+	unsigned long paused_when;	/* start of a write-and-pause period */
+
 #ifdef CONFIG_LATENCYTOP
 	int latency_record_count;
 	struct latency_record latency_record[LT_SAVECOUNT];
--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:44:23.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:44:23.000000000 +0800
@@ -37,24 +37,9 @@
 #include <trace/events/writeback.h>
 
 /*
- * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
- * will look to see if it needs to force writeback or throttling.
+ * Don't sleep more than 200ms at a time in balance_dirty_pages().
  */
-static long ratelimit_pages = 32;
-
-/*
- * When balance_dirty_pages decides that the caller needs to perform some
- * non-background writeback, this is how many pages it will attempt to write.
- * It should be somewhat larger than dirtied pages to ensure that reasonably
- * large amounts of I/O are submitted.
- */
-static inline long sync_writeback_pages(unsigned long dirtied)
-{
-	if (dirtied < ratelimit_pages)
-		dirtied = ratelimit_pages;
-
-	return dirtied + dirtied / 2;
-}
+#define MAX_PAUSE	max(HZ/5, 1)
 
 /* The following parameters are exported via /proc/sys/vm */
 
@@ -257,36 +242,6 @@ static inline void task_dirties_fraction
 }
 
 /*
- * task_dirty_limit - scale down dirty throttling threshold for one task
- *
- * task specific dirty limit:
- *
- *   dirty -= (dirty/8) * p_{t}
- *
- * To protect light/slow dirtying tasks from heavier/fast ones, we start
- * throttling individual tasks before reaching the bdi dirty limit.
- * Relatively low thresholds will be allocated to heavy dirtiers. So when
- * dirty pages grow large, heavy dirtiers will be throttled first, which will
- * effectively curb the growth of dirty pages. Light dirtiers with high enough
- * dirty threshold may never get throttled.
- */
-static unsigned long task_dirty_limit(struct task_struct *tsk,
-				       unsigned long bdi_dirty)
-{
-	long numerator, denominator;
-	unsigned long dirty = bdi_dirty;
-	u64 inv = dirty >> 3;
-
-	task_dirties_fraction(tsk, &numerator, &denominator);
-	inv *= numerator;
-	do_div(inv, denominator);
-
-	dirty -= inv;
-
-	return max(dirty, bdi_dirty/2);
-}
-
-/*
  *
  */
 static unsigned int bdi_min_ratio;
@@ -399,8 +354,6 @@ unsigned long determine_dirtyable_memory
  * Calculate the dirty thresholds based on sysctl parameters
  * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
  * - vm.dirty_ratio             or  vm.dirty_bytes
- * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
- * real-time tasks.
  */
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 {
@@ -431,10 +384,6 @@ void global_dirty_limits(unsigned long *
 		background = dirty - dirty / (DIRTY_SCOPE / 2);
 
 	tsk = current;
-	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
-		background += background / 4;
-		dirty += dirty / 4;
-	}
 	*pbackground = background;
 	*pdirty = dirty;
 }
@@ -497,6 +446,23 @@ static unsigned long dirty_rampup_size(u
 }
 
 /*
+ * After a task dirtied this many pages, balance_dirty_pages_ratelimited_nr()
+ * will look to see if it needs to start dirty throttling.
+ *
+ * If ratelimit_pages is too low then big NUMA machines will call the expensive
+ * global_page_state() too often. So scale it near-sqrt to the safety margin
+ * (the number of pages we may dirty without exceeding the dirty limits).
+ */
+static unsigned long ratelimit_pages(unsigned long dirty,
+				     unsigned long thresh)
+{
+	if (thresh > dirty)
+		return 1UL << (ilog2(thresh - dirty) >> 1);
+
+	return 1;
+}
+
+/*
  * last time exceeded (limit - limit/DIRTY_MARGIN)
  */
 static bool dirty_exceeded_recently(struct backing_dev_info *bdi,
@@ -1158,6 +1124,43 @@ unlock:
 }
 
 /*
+ * Limit pause time for small memory systems. If sleeping for too long time,
+ * the small pool of dirty/writeback pages may go empty and disk go idle.
+ */
+static unsigned long max_pause(struct backing_dev_info *bdi,
+			       unsigned long bdi_dirty)
+{
+	unsigned long t;  /* jiffies */
+
+	/* 1ms for every 1MB; may further consider bdi bandwidth */
+	t = bdi_dirty >> (30 - PAGE_CACHE_SHIFT - ilog2(HZ));
+	t += 2;
+
+	return min_t(unsigned long, t, MAX_PAUSE);
+}
+
+/*
+ * Scale up pause time for concurrent dirtiers in order to reduce CPU overheads.
+ * But ensure reasonably large [min_pause, max_pause] range size, so that
+ * nr_dirtied_pause (and hence future pause time) can stay reasonably stable.
+ */
+static unsigned long min_pause(struct backing_dev_info *bdi,
+			       unsigned long max)
+{
+	unsigned long hi = ilog2(bdi->write_bandwidth);
+	unsigned long lo = ilog2(bdi->throttle_bandwidth) - BASE_BW_SHIFT;
+	unsigned long t = 1 + max / 8;  /* jiffies */
+
+	if (lo >= hi)
+		return t;
+
+	/* (N * 10ms) on 2^N concurrent tasks */
+	t += (hi - lo) * (10 * HZ) / 1024;
+
+	return min(t, max / 2);
+}
+
+/*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
@@ -1165,49 +1168,34 @@ unlock:
  * perform some writeout.
  */
 static void balance_dirty_pages(struct address_space *mapping,
-				unsigned long write_chunk)
+				unsigned long pages_dirtied)
 {
-	long nr_reclaimable, bdi_nr_reclaimable;
-	long nr_writeback, bdi_nr_writeback;
+	unsigned long nr_reclaimable;
+	unsigned long nr_dirty;
+	unsigned long bdi_dirty;  /* = file_dirty + writeback + unstable_nfs */
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
-	unsigned long bdi_thresh;
-	unsigned long pages_written = 0;
-	unsigned long pause = 1;
-	bool dirty_exceeded = false;
+	unsigned long bw;
+	unsigned long period;
+	unsigned long pause = 0;
+	unsigned long pause_max;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	unsigned long start_time = jiffies;
 
-	if (!bdi_cap_account_dirty(bdi))
-		return;
-
 	for (;;) {
-		struct writeback_control wbc = {
-			.sync_mode	= WB_SYNC_NONE,
-			.older_than_this = NULL,
-			.nr_to_write	= write_chunk,
-			.range_cyclic	= 1,
-		};
-
+		/*
+		 * Unstable writes are a feature of certain networked
+		 * filesystems (i.e. NFS) in which data may have been
+		 * written to the server's write cache, but has not yet
+		 * been flushed to permanent storage.
+		 */
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
 					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
+		nr_dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
 
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 
 		/*
-		 * Throttle it only when the background writeback cannot
-		 * catch-up. This avoids (excessively) small writeouts
-		 * when the bdi limits are ramping up.
-		 */
-		if (nr_reclaimable + nr_writeback <=
-				(background_thresh + dirty_thresh) / 2)
-			break;
-
-		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
-		bdi_thresh = task_dirty_limit(current, bdi_thresh);
-
-		/*
 		 * In order to avoid the stacked BDI deadlock we need
 		 * to ensure we accurately count the 'dirty' pages when
 		 * the threshold is low.
@@ -1217,67 +1205,89 @@ static void balance_dirty_pages(struct a
 		 * actually dirty; with m+n sitting in the percpu
 		 * deltas.
 		 */
-		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
-			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
+		if (bdi->dirty_threshold < 2*bdi_stat_error(bdi)) {
+			bdi_dirty = bdi_stat_sum(bdi, BDI_RECLAIMABLE) +
+				    bdi_stat_sum(bdi, BDI_WRITEBACK);
 		} else {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
+			bdi_dirty = bdi_stat(bdi, BDI_RECLAIMABLE) +
+				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
-		bdi_update_bandwidth(bdi, dirty_thresh,
-				     nr_reclaimable + nr_writeback,
-				     bdi_nr_reclaimable + bdi_nr_writeback,
-				     start_time);
-
 		/*
-		 * The bdi thresh is somehow "soft" limit derived from the
-		 * global "hard" limit. The former helps to prevent heavy IO
-		 * bdi or process from holding back light ones; The latter is
-		 * the last resort safeguard.
+		 * Throttle it only when the background writeback cannot
+		 * catch-up. This avoids (excessively) small writeouts
+		 * when the bdi limits are ramping up.
 		 */
-		dirty_exceeded =
-			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
-			|| (nr_reclaimable + nr_writeback > dirty_thresh);
-
-		if (!dirty_exceeded)
+		if (nr_dirty <= (background_thresh + dirty_thresh) / 2) {
+			current->paused_when = jiffies;
+			current->nr_dirtied = 0;
 			break;
+		}
 
-		if (!bdi->dirty_exceeded)
-			bdi->dirty_exceeded = 1;
+		bdi_update_bandwidth(bdi, dirty_thresh, nr_dirty,
+				     bdi_dirty, start_time);
 
-		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
-		 * Unstable writes are a feature of certain networked
-		 * filesystems (i.e. NFS) in which data may have been
-		 * written to the server's write cache, but has not yet
-		 * been flushed to permanent storage.
-		 * Only move pages to writeback if this bdi is over its
-		 * threshold otherwise wait until the disk writes catch
-		 * up.
+		if (unlikely(!writeback_in_progress(bdi)))
+			bdi_start_background_writeback(bdi);
+
+		pause_max = max_pause(bdi, bdi_dirty);
+
+		bw = dirty_throttle_bandwidth(bdi, dirty_thresh, nr_dirty,
+					      bdi_dirty, current);
+		if (unlikely(bw == 0)) {
+			period = pause_max;
+			pause = pause_max;
+			goto pause;
+		}
+		period = (HZ * pages_dirtied + bw / 2) / bw;
+		pause = current->paused_when + period - jiffies;
+		/*
+		 * Take it as long think time if pause falls into (-10s, 0).
+		 * If it's less than 500ms (ext2 blocks the dirtier task for
+		 * up to 400ms from time to time on 1-HDD; so does xfs, however
+		 * at much less frequency), try to compensate it in future by
+		 * updating the virtual time; otherwise just reset the time, as
+		 * it may be a light dirtier.
 		 */
-		trace_wbc_balance_dirty_start(&wbc, bdi);
-		if (bdi_nr_reclaimable > bdi_thresh) {
-			writeback_inodes_wb(&bdi->wb, &wbc);
-			pages_written += write_chunk - wbc.nr_to_write;
-			trace_wbc_balance_dirty_written(&wbc, bdi);
-			if (pages_written >= write_chunk)
-				break;		/* We've done our duty */
+		if (unlikely(-pause < HZ*10)) {
+			if (-pause > HZ/2) {
+				current->paused_when = jiffies;
+				current->nr_dirtied = 0;
+				pause = 0;
+			} else if (period) {
+				current->paused_when += period;
+				current->nr_dirtied = 0;
+				pause = 1;
+			} else
+				current->nr_dirtied_pause <<= 1;
+			break;
 		}
-		trace_wbc_balance_dirty_wait(&wbc, bdi);
+		if (pause > pause_max)
+			pause = pause_max;
+
+pause:
+		current->paused_when = jiffies;
 		__set_current_state(TASK_UNINTERRUPTIBLE);
 		io_schedule_timeout(pause);
+		current->paused_when += pause;
+		current->nr_dirtied = 0;
 
-		/*
-		 * Increase the delay for each loop, up to our previous
-		 * default of taking a 100ms nap.
-		 */
-		pause <<= 1;
-		if (pause > HZ / 10)
-			pause = HZ / 10;
+		if (nr_dirty < default_backing_dev_info.dirty_threshold +
+		    default_backing_dev_info.dirty_threshold / DIRTY_MARGIN)
+			break;
 	}
 
-	if (!dirty_exceeded && bdi->dirty_exceeded)
-		bdi->dirty_exceeded = 0;
+	if (pause == 0)
+		current->nr_dirtied_pause =
+				ratelimit_pages(nr_dirty, dirty_thresh);
+	else if (pause <= min_pause(bdi, pause_max))
+		current->nr_dirtied_pause += current->nr_dirtied_pause / 32 + 1;
+	else if (pause >= pause_max)
+		/*
+		 * when repeated, writing 1 page per 100ms on slow devices,
+		 * i-(i+2)/4 will be able to reach 1 but never reduce to 0.
+		 */
+		current->nr_dirtied_pause -= (current->nr_dirtied_pause+2) >> 2;
 
 	if (writeback_in_progress(bdi))
 		return;
@@ -1290,8 +1300,10 @@ static void balance_dirty_pages(struct a
 	 * In normal mode, we start background writeout at the lower
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
-	if ((laptop_mode && pages_written) ||
-	    (!laptop_mode && (nr_reclaimable > background_thresh)))
+	if (laptop_mode)
+		return;
+
+	if (nr_reclaimable > background_thresh)
 		bdi_start_background_writeback(bdi);
 }
 
@@ -1305,8 +1317,6 @@ void set_page_dirty_balance(struct page 
 	}
 }
 
-static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
-
 /**
  * balance_dirty_pages_ratelimited_nr - balance dirty memory state
  * @mapping: address_space which was dirtied
@@ -1316,36 +1326,35 @@ static DEFINE_PER_CPU(unsigned long, bdp
  * which was newly dirtied.  The function will periodically check the system's
  * dirty state and will initiate writeback if needed.
  *
- * On really big machines, get_writeback_state is expensive, so try to avoid
+ * On really big machines, global_page_state() is expensive, so try to avoid
  * calling it too often (ratelimiting).  But once we're over the dirty memory
- * limit we decrease the ratelimiting by a lot, to prevent individual processes
- * from overshooting the limit by (ratelimit_pages) each.
+ * limit we disable the ratelimiting, to prevent individual processes from
+ * overshooting the limit by (ratelimit_pages) each.
  */
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 					unsigned long nr_pages_dirtied)
 {
-	unsigned long ratelimit;
-	unsigned long *p;
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
-	ratelimit = ratelimit_pages;
-	if (mapping->backing_dev_info->dirty_exceeded)
-		ratelimit = 8;
+	if (!bdi_cap_account_dirty(bdi))
+		return;
+
+	current->nr_dirtied += nr_pages_dirtied;
+
+	if (dirty_exceeded_recently(bdi, MAX_PAUSE)) {
+		unsigned long max = current->nr_dirtied +
+						(128 >> (PAGE_SHIFT - 10));
+
+		if (current->nr_dirtied_pause > max)
+			current->nr_dirtied_pause = max;
+	}
 
 	/*
 	 * Check the rate limiting. Also, we do not want to throttle real-time
 	 * tasks in balance_dirty_pages(). Period.
 	 */
-	preempt_disable();
-	p =  &__get_cpu_var(bdp_ratelimits);
-	*p += nr_pages_dirtied;
-	if (unlikely(*p >= ratelimit)) {
-		ratelimit = sync_writeback_pages(*p);
-		*p = 0;
-		preempt_enable();
-		balance_dirty_pages(mapping, ratelimit);
-		return;
-	}
-	preempt_enable();
+	if (unlikely(current->nr_dirtied >= current->nr_dirtied_pause))
+		balance_dirty_pages(mapping, current->nr_dirtied);
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
@@ -1433,44 +1442,6 @@ void laptop_sync_completion(void)
 #endif
 
 /*
- * If ratelimit_pages is too high then we can get into dirty-data overload
- * if a large number of processes all perform writes at the same time.
- * If it is too low then SMP machines will call the (expensive)
- * get_writeback_state too often.
- *
- * Here we set ratelimit_pages to a level which ensures that when all CPUs are
- * dirtying in parallel, we cannot go more than 3% (1/32) over the dirty memory
- * thresholds before writeback cuts in.
- *
- * But the limit should not be set too high.  Because it also controls the
- * amount of memory which the balance_dirty_pages() caller has to write back.
- * If this is too large then the caller will block on the IO queue all the
- * time.  So limit it to four megabytes - the balance_dirty_pages() caller
- * will write six megabyte chunks, max.
- */
-
-void writeback_set_ratelimit(void)
-{
-	ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
-	if (ratelimit_pages < 16)
-		ratelimit_pages = 16;
-	if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
-		ratelimit_pages = (4096 * 1024) / PAGE_CACHE_SIZE;
-}
-
-static int __cpuinit
-ratelimit_handler(struct notifier_block *self, unsigned long u, void *v)
-{
-	writeback_set_ratelimit();
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block __cpuinitdata ratelimit_nb = {
-	.notifier_call	= ratelimit_handler,
-	.next		= NULL,
-};
-
-/*
  * Called early on to tune the page writeback dirty limits.
  *
  * We used to scale dirty pages according to how total memory
@@ -1492,9 +1463,6 @@ void __init page_writeback_init(void)
 {
 	int shift;
 
-	writeback_set_ratelimit();
-	register_cpu_notifier(&ratelimit_nb);
-
 	shift = calc_period_shift();
 	prop_descriptor_init(&vm_completions, shift);
 	prop_descriptor_init(&vm_dirties, shift);
--- linux-next.orig/include/linux/backing-dev.h	2011-03-03 14:44:23.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-03-03 14:44:23.000000000 +0800
@@ -89,7 +89,6 @@ struct backing_dev_info {
 	unsigned long old_dirty_threshold;
 
 	struct prop_local_percpu completions;
-	int dirty_exceeded;
 
 	/* last time exceeded (limit - limit/DIRTY_MARGIN) */
 	unsigned long dirty_exceed_time;
--- linux-next.orig/mm/memory_hotplug.c	2011-03-03 14:43:49.000000000 +0800
+++ linux-next/mm/memory_hotplug.c	2011-03-03 14:44:23.000000000 +0800
@@ -468,8 +468,6 @@ int online_pages(unsigned long pfn, unsi
 
 	vm_total_pages = nr_free_pagecache_pages();
 
-	writeback_set_ratelimit();
-
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
 	unlock_memory_hotplug();
@@ -901,7 +899,6 @@ repeat:
 	}
 
 	vm_total_pages = nr_free_pagecache_pages();
-	writeback_set_ratelimit();
 
 	memory_notify(MEM_OFFLINE, &arg);
 	unlock_memory_hotplug();
--- linux-next.orig/mm/backing-dev.c	2011-03-03 14:44:23.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-03-03 14:44:23.000000000 +0800
@@ -667,8 +667,6 @@ int bdi_init(struct backing_dev_info *bd
 			goto err;
 	}
 
-	bdi->dirty_exceeded = 0;
-
 	bdi->bw_time_stamp = jiffies;
 	bdi->written_stamp = 0;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
