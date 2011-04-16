Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5E8DF900090
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 10:03:38 -0400 (EDT)
Message-Id: <20110416134333.436845422@intel.com>
Date: Sat, 16 Apr 2011 21:25:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 08/12] writeback: IO-less balance_dirty_pages() 
References: <20110416132546.765212221@intel.com>
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

- disk seeks on concurrent writeback of multiple inodes (Dave Chinner)

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

- lock contention and cache bouncing on concurrent IO submitters (Dave Chinner)
  
  With this patchset, the fs_mark benchmark on a 12-drive software RAID0 goes
  from CPU bound to IO bound, freeing "3-4 CPUs worth of spinlock contention".

  * "CPU usage has dropped by ~55%", "it certainly appears that most of
    the CPU time saving comes from the removal of contention on the
    inode_wb_list_lock" (IMHO at least 10% comes from the reduction of
    cacheline bouncing, because the new code is able to call much less
    frequently into balance_dirty_pages() and hence access the global
    page states)

  * the user space "App overhead" is reduced by 20%, by avoiding the
    cacheline pollution by the complex writeback code path

  * "for a ~5% throughput reduction", "the number of write IOs have
    dropped by ~25%", and the elapsed time reduced from 41:42.17 to
    40:53.23.

  * On a simple test of 100 dd, it reduces the CPU %system time from 30% to 3%,
    and improves IO throughput from 38MB/s to 42MB/s.

- IO size too small for fast arrays and too large for slow USB sticks

  The write_chunk used by current balance_dirty_pages() cannot be
  directly set to some large value (eg. 128MB) for better IO efficiency.
  Because it could lead to more than 1 second user perceivable stalls.
  Even the current 4MB write size may be too large for slow USB sticks.
  The fact that balance_dirty_pages() starts IO on itself couples the
  IO size to wait time, which makes it hard to do suitable IO size while
  keeping the wait time under control.

  Now it's possible to increase writeback chunk size proportional to the
  disk bandwidth. In a simple test of 50 dd's on XFS, 1-HDD, 3GB ram,
  the larger writeback size dramatically reduces the seek count to 1/10
  (far beyond my expectation) and improves the write throughput by 24%.

- long block time in balance_dirty_pages() hurts desktop responsiveness

  Many of us may have the experience: it often takes a couple of seconds
  or even long time to stop a heavy writing dd/cp/tar command with
  Ctrl-C or "kill -9".

- IO pipeline broken by bumpy write() progress

  There are a broad class of "loop {read(buf); write(buf);}" applications
  whose read() pipeline will be under-utilized or even come to a stop if
  the write()s have long latencies _or_ don't progress in a constant rate.
  The current threshold based throttling inherently transfers the large
  low level IO completion fluctuations to bumpy application write()s,
  and further deteriorates with increasing number of dirtiers and/or bdi's.

  For example, when doing 50 dd's + 1 remote rsync to an XFS partition,
  the rsync progresses very bumpy in legacy kernel, and throughput is
  improved by 67% by this patchset. (plus the larger write chunk size,
  it will be 93% speedup).

  The new rate based throttling can support 1000+ dd's with excellent
  smoothness, low latency and low overheads.

For the above reasons, it's much better to do IO-less and low latency
pauses in balance_dirty_pages().

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
- avoid too small pause time (less than   4ms, which burns CPU power)
- avoid too large pause time (more than 200ms, which hurts responsiveness)
- avoid big fluctuations of pause times

It can control pause times at will. The default policy is to do ~10ms
pauses in 1-dd case, and increase to ~100ms in 1000-dd case.

BOUNDARY CONTROL REGIONS
========================

The pause time scheme can only throttle a task to 1 page per 200ms, or
about 20KB/s in x86. The max-pause, pass-good and loop boundary control
regions are setup to stop huge number of slow dirtiers, sudden workload
changes or other unknown abnormalities.

balance_dirty_pages():

	/* free run */
	if (below (dirty_thresh + background_thresh) / 2)
		quit

	/* smooth throttling */
	if (within dirty control scope)
		sleep (dirtied_pages / task_ratelimit)

	/* max pause */
	if (dirty_limit exceeded)
		nap and quit

	/* pass good bdi */
	if (dirty_limit+dirty_limit/8 exceeded && bdi_thresh not exceeded)
		nap and quit

	/* loop */
	while (dirty_limit+dirty_limit/4 exceeded)
		nap

BEHAVIOR CHANGE
===============

(1) dirty threshold

Users will notice that the applications will get throttled once crossing
the global (background + dirty)/2=15% threshold, and then balanced around
17.5%. Before patch, the behavior is to just throttle it at 20% dirtyable
memory in 1-dd case.

Since the task will be soft throttled earlier than before, it may be
perceived by end users as performance "slow down" if his application
happens to dirty more than 15% dirtyable memory.

(2) fast rampup

The dirty pages will now rampup to the balance point much faster.

(3) smoothness/responsiveness

Users will notice a more responsive system during heavy writeback.
"killall dd" will take effect very fast.

THINK TIME
==========

The task's think time is compensated when computing the final pause time,
so that throttle bandwidth will be executed accurately. In the rare case
that the task slept longer than the period time (result in negative
pause time), the extra sleep time will be compensated in next period if
it's not too big (<500ms).  Accumulated errors are carefully avoided as
long as the task does not sleep for long time.

	period = task_bw / pages_dirtied;
	think = jiffies - paused_when;
	pause = period - think;

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

                don't pause; reduce future pause time by:
                paused_when += period

                       period time
              |=========================>|
                             think time
              |======================================>|
        ------|--------------------------+------------|-----------
        paused_when                                jiffies

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    1 
 include/linux/sched.h       |    8 
 mm/backing-dev.c            |    2 
 mm/memory_hotplug.c         |    3 
 mm/page-writeback.c         |  367 +++++++++++++++-------------------
 5 files changed, 175 insertions(+), 206 deletions(-)

--- linux-next.orig/include/linux/sched.h	2011-04-15 14:18:29.000000000 +0800
+++ linux-next/include/linux/sched.h	2011-04-15 14:23:00.000000000 +0800
@@ -1493,6 +1493,14 @@ struct task_struct {
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
--- linux-next.orig/mm/page-writeback.c	2011-04-15 14:22:55.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-15 14:23:00.000000000 +0800
@@ -36,27 +36,12 @@
 #include <linux/pagevec.h>
 #include <trace/events/writeback.h>
 
-#define RATIO_SHIFT	10
-
 /*
- * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
- * will look to see if it needs to force writeback or throttling.
+ * Sleep at most 200ms at a time in balance_dirty_pages().
  */
-static long ratelimit_pages = 32;
+#define MAX_PAUSE	max(HZ/5, 1)
 
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
+#define RATIO_SHIFT	10
 
 /* The following parameters are exported via /proc/sys/vm */
 
@@ -251,43 +236,6 @@ static void bdi_writeout_fraction(struct
 				numerator, denominator);
 }
 
-static inline void task_dirties_fraction(struct task_struct *tsk,
-		long *numerator, long *denominator)
-{
-	prop_fraction_single(&vm_dirties, &tsk->dirties,
-				numerator, denominator);
-}
-
-/*
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
 /*
  *
  */
@@ -407,8 +355,6 @@ static unsigned long hard_dirty_limit(un
  * Calculate the dirty thresholds based on sysctl parameters
  * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
  * - vm.dirty_ratio             or  vm.dirty_bytes
- * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
- * real-time tasks.
  */
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 {
@@ -439,10 +385,6 @@ void global_dirty_limits(unsigned long *
 		background = dirty - dirty / DIRTY_FULL_SCOPE;
 
 	tsk = current;
-	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
-		background += background / 4;
-		dirty += dirty / 4;
-	}
 	*pbackground = background;
 	*pdirty = dirty;
 }
@@ -486,6 +428,23 @@ unsigned long bdi_dirty_limit(struct bac
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
  * last time exceeded (limit - limit/DIRTY_BRAKE)
  */
 static bool dirty_exceeded_recently(struct backing_dev_info *bdi,
@@ -1037,7 +996,7 @@ void bdi_update_bandwidth(struct backing
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
 
 	/* skip quiet periods when disk bandwidth is under-utilized */
-	if (elapsed > HZ &&
+	if (elapsed > 5 * MAX_PAUSE &&
 	    elapsed > now - start_time)
 		goto snapshot;
 
@@ -1045,13 +1004,13 @@ void bdi_update_bandwidth(struct backing
 	 * rate-limit, only update once every 200ms. Demand higher threshold
 	 * on the flusher so that the throttled task(s) can do most updates.
 	 */
-	if (!thresh && elapsed <= HZ / 3)
+	if (!thresh && elapsed <= 2 * MAX_PAUSE)
 		goto unlock;
-	if (elapsed <= HZ / 5)
+	if (elapsed <= MAX_PAUSE)
 		goto unlock;
 
 	if (thresh &&
-	    now - default_backing_dev_info.bw_time_stamp >= HZ / 5) {
+	    now - default_backing_dev_info.bw_time_stamp >= MAX_PAUSE) {
 		update_dirty_limit(thresh, dirty);
 		bdi_update_dirty_smooth(&default_backing_dev_info, dirty);
 		default_backing_dev_info.bw_time_stamp = now;
@@ -1072,6 +1031,38 @@ unlock:
 	spin_unlock(&dirty_lock);
 }
 
+static unsigned long max_pause(struct backing_dev_info *bdi,
+			       unsigned long bdi_dirty)
+{
+	unsigned long hi = ilog2(bdi->write_bandwidth);
+	unsigned long lo = ilog2(bdi->dirty_ratelimit);
+	unsigned long t;
+
+	/* target for 10ms pause on 1-dd case */
+	t = HZ / 50;
+
+	/*
+	 * Scale up pause time for concurrent dirtiers in order to reduce CPU
+	 * overheads.
+	 *
+	 * (N * 20ms) on 2^N concurrent tasks.
+	 */
+	if (hi > lo)
+		t += (hi - lo) * (20 * HZ) / 1024;
+
+	/*
+	 * Limit pause time for small memory systems. If sleeping for too long
+	 * time, a small pool of dirty/writeback pages may go empty and disk go
+	 * idle.
+	 *
+	 * 1ms for every 1MB; may further consider bdi bandwidth.
+	 */
+	if (bdi_dirty)
+		t = min(t, bdi_dirty >> (30 - PAGE_CACHE_SHIFT - ilog2(HZ)));
+
+	return clamp_val(t, 4, MAX_PAUSE);
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -1080,33 +1071,32 @@ unlock:
  * perform some writeout.
  */
 static void balance_dirty_pages(struct address_space *mapping,
-				unsigned long write_chunk)
+				unsigned long pages_dirtied)
 {
-	long nr_reclaimable, bdi_nr_reclaimable;
-	long nr_writeback, bdi_nr_writeback;
+	unsigned long nr_reclaimable;
+	unsigned long nr_dirty;  /* = file_dirty + writeback + unstable_nfs */
+	unsigned long bdi_dirty;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
-	unsigned long bdi_thresh;
-	unsigned long pages_written = 0;
-	unsigned long pause = 1;
-	bool dirty_exceeded = false;
+	unsigned long bw;
+	unsigned long base_bw;
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
+		unsigned long now = jiffies;
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
 
@@ -1115,12 +1105,11 @@ static void balance_dirty_pages(struct a
 		 * catch-up. This avoids (excessively) small writeouts
 		 * when the bdi limits are ramping up.
 		 */
-		if (nr_reclaimable + nr_writeback <=
-				(background_thresh + dirty_thresh) / 2)
+		if (nr_dirty <= (background_thresh + dirty_thresh) / 2) {
+			current->paused_when = jiffies;
+			current->nr_dirtied = 0;
 			break;
-
-		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
-		bdi_thresh = task_dirty_limit(current, bdi_thresh);
+		}
 
 		/*
 		 * In order to avoid the stacked BDI deadlock we need
@@ -1132,67 +1121,87 @@ static void balance_dirty_pages(struct a
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
+		bdi_update_bandwidth(bdi, dirty_thresh, nr_dirty,
+				     bdi_dirty, start_time);
 
-		/*
-		 * The bdi thresh is somehow "soft" limit derived from the
-		 * global "hard" limit. The former helps to prevent heavy IO
-		 * bdi or process from holding back light ones; The latter is
-		 * the last resort safeguard.
-		 */
-		dirty_exceeded =
-			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
-			|| (nr_reclaimable + nr_writeback > dirty_thresh);
-
-		if (!dirty_exceeded)
-			break;
+		if (unlikely(!writeback_in_progress(bdi)))
+			bdi_start_background_writeback(bdi);
 
-		if (!bdi->dirty_exceeded)
-			bdi->dirty_exceeded = 1;
+		pause_max = max_pause(bdi, bdi_dirty);
 
-		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
-		 * Unstable writes are a feature of certain networked
-		 * filesystems (i.e. NFS) in which data may have been
-		 * written to the server's write cache, but has not yet
-		 * been flushed to permanent storage.
-		 * Only move pages to writeback if this bdi is over its
-		 * threshold otherwise wait until the disk writes catch
-		 * up.
+		base_bw = bdi->dirty_ratelimit;
+		/*
+		 * Double the bandwidth for PF_LESS_THROTTLE (ie. nfsd) and
+		 * real-time tasks.
 		 */
-		trace_wbc_balance_dirty_start(&wbc, bdi);
-		if (bdi_nr_reclaimable > bdi_thresh) {
-			writeback_inodes_wb(&bdi->wb, &wbc);
-			pages_written += write_chunk - wbc.nr_to_write;
-			trace_wbc_balance_dirty_written(&wbc, bdi);
-			if (pages_written >= write_chunk)
-				break;		/* We've done our duty */
+		if (current->flags & PF_LESS_THROTTLE || rt_task(current))
+			base_bw *= 2;
+		bw = bdi_position_ratio(bdi, dirty_thresh, nr_dirty, bdi_dirty);
+		if (unlikely(bw == 0)) {
+			period = pause_max;
+			pause = pause_max;
+			goto pause;
 		}
-		trace_wbc_balance_dirty_wait(&wbc, bdi);
+		bw = (u64)base_bw * bw >> RATIO_SHIFT;
+		period = (HZ * pages_dirtied + bw / 2) / (bw | 1);
+		pause = current->paused_when + period - now;
+		/*
+		 * Take it as long think time if pause falls into (-10s, 0).
+		 * If it's less than 500ms (ext2 blocks the dirtier task for
+		 * up to 400ms from time to time on 1-HDD; so does xfs, however
+		 * at much less frequency), try to compensate it in future by
+		 * updating the virtual time; otherwise just reset the time, as
+		 * it may be a light dirtier.
+		 */
+		if (unlikely(-pause < HZ*10)) {
+			if (-pause > HZ/2) {
+				current->paused_when = now;
+				current->nr_dirtied = 0;
+			} else if (period) {
+				current->paused_when += period;
+				current->nr_dirtied = 0;
+			}
+			pause = 1;
+			break;
+		}
+		pause = min(pause, pause_max);
+
+pause:
+		current->paused_when = now;
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
+		dirty_thresh = hard_dirty_limit(dirty_thresh);
+		if (nr_dirty < dirty_thresh + dirty_thresh / DIRTY_MAXPAUSE)
+			break;
+		if (nr_dirty < dirty_thresh + dirty_thresh / DIRTY_PASSGOOD &&
+		    bdi_dirty < bdi->dirty_threshold)
+			break;
 	}
 
-	if (!dirty_exceeded && bdi->dirty_exceeded)
-		bdi->dirty_exceeded = 0;
+	if (pause == 0)
+		current->nr_dirtied_pause =
+				ratelimit_pages(nr_dirty, dirty_thresh);
+	else if (period <= pause_max / 4)
+		current->nr_dirtied_pause = clamp_val(
+						base_bw * (pause_max/2) / HZ,
+						pages_dirtied + pages_dirtied/8,
+						pages_dirtied * 4);
+	else if (pause >= pause_max)
+		current->nr_dirtied_pause = 1 | clamp_val(
+						base_bw * (pause_max*3/8) / HZ,
+						current->nr_dirtied_pause / 4,
+						current->nr_dirtied_pause*7/8);
 
 	if (writeback_in_progress(bdi))
 		return;
@@ -1205,8 +1214,10 @@ static void balance_dirty_pages(struct a
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
 
@@ -1220,8 +1231,6 @@ void set_page_dirty_balance(struct page 
 	}
 }
 
-static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
-
 /**
  * balance_dirty_pages_ratelimited_nr - balance dirty memory state
  * @mapping: address_space which was dirtied
@@ -1231,36 +1240,35 @@ static DEFINE_PER_CPU(unsigned long, bdp
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
+
+	if (!bdi_cap_account_dirty(bdi))
+		return;
 
-	ratelimit = ratelimit_pages;
-	if (mapping->backing_dev_info->dirty_exceeded)
-		ratelimit = 8;
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
 
@@ -1348,44 +1356,6 @@ void laptop_sync_completion(void)
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
@@ -1407,9 +1377,6 @@ void __init page_writeback_init(void)
 {
 	int shift;
 
-	writeback_set_ratelimit();
-	register_cpu_notifier(&ratelimit_nb);
-
 	shift = calc_period_shift();
 	prop_descriptor_init(&vm_completions, shift);
 	prop_descriptor_init(&vm_dirties, shift);
--- linux-next.orig/include/linux/backing-dev.h	2011-04-15 14:22:55.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-04-15 14:23:00.000000000 +0800
@@ -89,7 +89,6 @@ struct backing_dev_info {
 	unsigned long old_dirty_threshold;
 
 	struct prop_local_percpu completions;
-	int dirty_exceeded;
 
 	/* last time exceeded (limit - limit/DIRTY_BRAKE) */
 	unsigned long dirty_exceed_time;
--- linux-next.orig/mm/memory_hotplug.c	2011-04-15 14:18:29.000000000 +0800
+++ linux-next/mm/memory_hotplug.c	2011-04-15 14:23:00.000000000 +0800
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
--- linux-next.orig/mm/backing-dev.c	2011-04-15 14:22:55.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-04-15 14:23:00.000000000 +0800
@@ -661,8 +661,6 @@ int bdi_init(struct backing_dev_info *bd
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
