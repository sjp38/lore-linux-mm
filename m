From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/35] writeback: IO-less balance_dirty_pages()
Date: Mon, 13 Dec 2010 22:46:51 +0800
Message-ID: <20101213150326.967671717@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA2i-0002Pd-Px
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:10:25 +0100
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 477776B00AF
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:09:03 -0500 (EST)
Content-Disposition: inline; filename=writeback-bw-throttle.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <axboe@kernel.dk>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

As proposed by Chris, Dave and Jan, don't start foreground writeback IO
inside balance_dirty_pages(). Instead, simply let it idle sleep for some
time to throttle the dirtying task. In the mean while, kick off the
per-bdi flusher thread to do background writeback IO.

This patch introduces the basic framework, which will be further
consolidated by the next patches.

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

CONTROL SYSTEM
==============

The current task_dirty_limit() adjusts bdi_dirty_limit to get
task_dirty_limit according to the dirty "weight" of the current task,
which is the percent of pages recently dirtied by the task. If 100%
pages are recently dirtied by the task, it will lower bdi_dirty_limit by
1/8. If only 1% pages are dirtied by the task, it will return almost
unmodified bdi_dirty_limit. In this way, a heavy dirtier will get
blocked at task_dirty_limit=(bdi_dirty_limit-bdi_dirty_limit/8) while
allowing a light dirtier to progress (the latter won't be blocked
because R << B in fig.1).

Fig.1 before patch, a heavy dirtier and a light dirtier
                                                R
----------------------------------------------+-o---------------------------*--|
                                              L A                           B  T
  T: bdi_dirty_limit, as returned by bdi_dirty_limit()
  L: T - T/8

  R: bdi_reclaimable + bdi_writeback

  A: task_dirty_limit for a heavy dirtier ~= R ~= L
  B: task_dirty_limit for a light dirtier ~= T

Since each process has its own dirty limit, we reuse A/B for the tasks as
well as their dirty limits.

If B is a newly started heavy dirtier, then it will slowly gain weight
and A will lose weight.  The task_dirty_limit for A and B will be
approaching the center of region (L, T) and eventually stabilize there.

Fig.2 before patch, two heavy dirtiers converging to the same threshold
                                                             R
----------------------------------------------+--------------o-*---------------|
                                              L              A B               T

Fig.3 after patch, one heavy dirtier
                                                |
    throttle_bandwidth ~= bdi_bandwidth  =>     o
                                                | o
                                                |   o
                                                |     o
                                                |       o
                                                |         o
                                              La|           o
----------------------------------------------+-+-------------o----------------|
                                                R             A                T
  T: bdi_dirty_limit
  A: task_dirty_limit      = T - Wa * T/16
  La: task_throttle_thresh = A - A/16

  R: bdi_dirty_pages = bdi_reclaimable + bdi_writeback ~= La

Now for IO-less balance_dirty_pages(), let's do it in a "bandwidth control"
way. In fig.3, a soft dirty limit region (La, A) is introduced. When R enters
this region, the task may be throttled for J jiffies on every N pages it dirtied.
Let's call (N/J) the "throttle bandwidth". It is computed by the following formula:

        throttle_bandwidth = bdi_bandwidth * (A - R) / (A - La)
where
	A = T - Wa * T/16
        La = A - A/16
where Wa is task weight for A. It's 0 for very light dirtier and 1 for
the one heavy dirtier (that consumes 100% bdi write bandwidth).  The
task weight will be updated independently by task_dirty_inc() at
set_page_dirty() time.

When R < La, we don't throttle it at all.
When R > A, the code will detect the negativeness and choose to pause
200ms (the upper pause boundary), then loop over again.

The 200ms max pause time helps reduce overheads in server workloads
with lots of concurrent dirtier tasks.

PSEUDO CODE
===========

balance_dirty_pages():

	/* soft throttling */
	if (task_throttle_thresh exceeded)
		sleep (task_dirtied_pages / throttle_bandwidth)

	/* hard throttling */
	while (task_dirty_limit exceeded) {
		sleep 200ms
		if (bdi_dirty_pages dropped more than task_dirtied_pages)
			break
	}

	/* global hard limit */
	while (dirty_limit exceeded)
		sleep 200ms

Basically there are three level of throttling now.

- normally the dirtier will be adaptively throttled with good timing

- when task_dirty_limit is exceeded, the task will be throttled until
  bdi dirty/writeback pages go down reasonably large

- when dirty_thresh is exceeded, the task can be throttled for arbitrary
  long time


BEHAVIOR CHANGE
===============

Users will notice that the applications will get throttled once the
crossing the global (background + dirty)/2=15% threshold. For a single
"cp", it could be soft throttled at 8*bdi->write_bandwidth around 15%
dirty pages, and be balanced at speed bdi->write_bandwidth around 17.5%
dirty pages. Before patch, the behavior is to just throttle it at 17.5%
dirty pages.

Since the task will be soft throttled earlier than before, it may be
perceived by end users as performance "slow down" if his application
happens to dirty more than ~15% memory.


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
- 100 dirtiers case: CPU system time is reduced to 10%, IO size and throughput increases by 10%

			2.6.37-rc2				2.6.37-rc1-next-20101115+
        ----------------------------------------        ----------------------------------------
	%system		wkB/s		avgrq-sz	%system		wkB/s		avgrq-sz
100dd	30.916		37843.000	748.670		3.079		41654.853	822.322
100dd	30.501		37227.521	735.754		3.744		41531.725	820.360

10dd	39.442		47745.021	900.935		20.756		47951.702	901.006
10dd	39.204		47484.616	899.330		20.550		47970.093	900.247

1dd	13.046		57357.468	910.659		13.060		57632.715	909.212
1dd	12.896		56433.152	909.861		12.467		56294.440	909.644

The CPU overheads in 2.6.37-rc1-next-20101115+ is higher than
2.6.36-rc2-mm1+balance_dirty_pages, this may be due to the pause time
stablizing at lower values due to some algorithm adjustments (eg.
reduce the minimal pause time from 10ms to 1jiffy in new version)
leading to much more balance_dirty_pages() calls. The different pause
time also explains the different system time for 1/10/100dd cases on
the same 2.6.37-rc1-next-20101115+.

Andrew Morton <akpm@linux-foundation.org>:

Using TASK_INTERRUPTIBLE in balance_dirty_pages() seems wrong.  If it's
going to do that then it must break out if signal_pending(), otherwise
it's pretty much guaranteed to degenerate into a busywait loop.  Plus
we *do* want these processes to appear in D state and to contribute to
load average.

So it should be TASK_UNINTERRUPTIBLE.

CC: Chris Mason <chris.mason@oracle.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Jan Kara <jack@suse.cz>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/filesystems/writeback-throttling-design.txt |  210 ++++++++++
 include/linux/writeback.h                                 |   10 
 mm/page-writeback.c                                       |   84 +---
 3 files changed, 251 insertions(+), 53 deletions(-)

--- linux-next.orig/include/linux/writeback.h	2010-12-13 21:46:10.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-12-13 21:46:12.000000000 +0800
@@ -12,6 +12,16 @@ struct backing_dev_info;
 extern spinlock_t inode_lock;
 
 /*
+ * The 1/8 region under the bdi dirty threshold is set aside for elastic
+ * throttling. In rare cases when the threshold is exceeded, more rigid
+ * throttling will be imposed, which will inevitably stall the dirtier task
+ * for seconds (or more) at _one_ time. The rare case could be a fork bomb
+ * where every new task dirties some more pages.
+ */
+#define BDI_SOFT_DIRTY_LIMIT	8
+#define TASK_SOFT_DIRTY_LIMIT	(BDI_SOFT_DIRTY_LIMIT * 2)
+
+/*
  * fs/fs-writeback.c
  */
 enum writeback_sync_modes {
--- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:11.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-13 21:46:12.000000000 +0800
@@ -43,18 +43,9 @@
 static long ratelimit_pages = 32;
 
 /*
- * When balance_dirty_pages decides that the caller needs to perform some
- * non-background writeback, this is how many pages it will attempt to write.
- * It should be somewhat larger than dirtied pages to ensure that reasonably
- * large amounts of I/O are submitted.
+ * Don't sleep more than 200ms at a time in balance_dirty_pages().
  */
-static inline long sync_writeback_pages(unsigned long dirtied)
-{
-	if (dirtied < ratelimit_pages)
-		dirtied = ratelimit_pages;
-
-	return dirtied + dirtied / 2;
-}
+#define MAX_PAUSE	max(HZ/5, 1)
 
 /* The following parameters are exported via /proc/sys/vm */
 
@@ -279,7 +270,7 @@ static unsigned long task_dirty_limit(st
 {
 	long numerator, denominator;
 	unsigned long dirty = bdi_dirty;
-	u64 inv = dirty >> 3;
+	u64 inv = dirty / TASK_SOFT_DIRTY_LIMIT;
 
 	task_dirties_fraction(tsk, &numerator, &denominator);
 	inv *= numerator;
@@ -509,26 +500,25 @@ unsigned long bdi_dirty_limit(struct bac
  * perform some writeout.
  */
 static void balance_dirty_pages(struct address_space *mapping,
-				unsigned long write_chunk)
+				unsigned long pages_dirtied)
 {
 	long nr_reclaimable, bdi_nr_reclaimable;
 	long nr_writeback, bdi_nr_writeback;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
-	unsigned long pages_written = 0;
-	unsigned long pause = 1;
+	unsigned long bw;
+	unsigned long pause;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
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
 		nr_writeback = global_page_state(NR_WRITEBACK);
@@ -566,6 +556,23 @@ static void balance_dirty_pages(struct a
 			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		if (bdi_nr_reclaimable + bdi_nr_writeback >= bdi_thresh) {
+			pause = MAX_PAUSE;
+			goto pause;
+		}
+
+		bw = 100 << 20; /* use static 100MB/s for the moment */
+
+		bw = bw * (bdi_thresh - (bdi_nr_reclaimable + bdi_nr_writeback));
+		do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
+
+		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
+		pause = clamp_val(pause, 1, MAX_PAUSE);
+
+pause:
+		__set_current_state(TASK_UNINTERRUPTIBLE);
+		io_schedule_timeout(pause);
+
 		/*
 		 * The bdi thresh is somehow "soft" limit derived from the
 		 * global "hard" limit. The former helps to prevent heavy IO
@@ -581,35 +588,6 @@ static void balance_dirty_pages(struct a
 
 		if (!bdi->dirty_exceeded)
 			bdi->dirty_exceeded = 1;
-
-		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
-		 * Unstable writes are a feature of certain networked
-		 * filesystems (i.e. NFS) in which data may have been
-		 * written to the server's write cache, but has not yet
-		 * been flushed to permanent storage.
-		 * Only move pages to writeback if this bdi is over its
-		 * threshold otherwise wait until the disk writes catch
-		 * up.
-		 */
-		trace_wbc_balance_dirty_start(&wbc, bdi);
-		if (bdi_nr_reclaimable > bdi_thresh) {
-			writeback_inodes_wb(&bdi->wb, &wbc);
-			pages_written += write_chunk - wbc.nr_to_write;
-			trace_wbc_balance_dirty_written(&wbc, bdi);
-			if (pages_written >= write_chunk)
-				break;		/* We've done our duty */
-		}
-		trace_wbc_balance_dirty_wait(&wbc, bdi);
-		__set_current_state(TASK_INTERRUPTIBLE);
-		io_schedule_timeout(pause);
-
-		/*
-		 * Increase the delay for each loop, up to our previous
-		 * default of taking a 100ms nap.
-		 */
-		pause <<= 1;
-		if (pause > HZ / 10)
-			pause = HZ / 10;
 	}
 
 	if (!dirty_exceeded && bdi->dirty_exceeded)
@@ -626,7 +604,7 @@ static void balance_dirty_pages(struct a
 	 * In normal mode, we start background writeout at the lower
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
-	if ((laptop_mode && pages_written) ||
+	if ((laptop_mode && dirty_exceeded) ||
 	    (!laptop_mode && (nr_reclaimable > background_thresh)))
 		bdi_start_background_writeback(bdi);
 }
@@ -675,7 +653,7 @@ void balance_dirty_pages_ratelimited_nr(
 	p =  &__get_cpu_var(bdp_ratelimits);
 	*p += nr_pages_dirtied;
 	if (unlikely(*p >= ratelimit)) {
-		ratelimit = sync_writeback_pages(*p);
+		ratelimit = *p;
 		*p = 0;
 		preempt_enable();
 		balance_dirty_pages(mapping, ratelimit);
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-next/Documentation/filesystems/writeback-throttling-design.txt	2010-12-13 21:46:12.000000000 +0800
@@ -0,0 +1,210 @@
+writeback throttling design
+---------------------------
+
+introduction to dirty throttling
+--------------------------------
+
+The write(2) is normally buffered write that creates dirty page cache pages
+for holding the data and return immediately. The dirty pages will eventually
+be written to disk, or be dropped by unlink()/truncate().
+
+The delayed writeback of dirty pages enables the kernel to optimize the IO:
+
+- turn IO into async ones, which avoids blocking the tasks
+- submit IO as a batch for better throughput
+- avoid IO at all for temp files
+
+However, there have to be some limits on the number of allowable dirty pages.
+Typically applications are able to dirty pages more quickly than storage
+devices can write them. When approaching the dirty limits, the dirtier tasks
+will be throttled (put to brief sleeps from time to time) by
+balance_dirty_pages() in order to balance the dirty speed and writeback speed.
+
+dirty limits
+------------
+
+The dirty limit defaults to 20% reclaimable memory, and can be tuned via one of
+the following sysctl interfaces:
+
+	/proc/sys/vm/dirty_ratio
+	/proc/sys/vm/dirty_bytes
+
+The ultimate goal of balance_dirty_pages() is to keep the global dirty pages
+under control.
+
+	dirty_limit = dirty_ratio * free_reclaimable_pages
+
+However a global threshold may create deadlock for stacked BDIs (loop, FUSE and
+local NFS mounts). When A writes to B, and A generates enough dirty pages to
+get throttled, B will never start writeback until the dirty pages go away.
+
+Another problem is inter device starvation. When there are concurrent writes to
+a slow device and a fast one, the latter may well be starved due to unnecessary
+throttling on its dirtier tasks, leading to big IO performance drop.
+
+The solution is to split the global dirty limit into per-bdi limits among all
+the backing devices and scale writeback cache per backing device, proportional
+to its writeout speed.
+
+	bdi_dirty_limit = bdi_weight * dirty_limit
+
+where bdi_weight (ranging from 0 to 1) reflects the recent writeout speed of
+the BDI.
+
+We further scale the bdi dirty limit inversly with the task's dirty rate.
+This makes heavy writers have a lower dirty limit than the occasional writer,
+to prevent a heavy dd from slowing down all other light writers in the system.
+
+	task_dirty_limit = bdi_dirty_limit - task_weight * bdi_dirty_limit/16
+
+pause time
+----------
+
+The main task of dirty throttling is to determine when and how long to pause
+the current dirtier task.  Basically we want to
+
+- avoid too small pause time (less than 1 jiffy, which burns CPU power)
+- avoid too large pause time (more than 200ms, which hurts responsiveness)
+- avoid big fluctuations of pause times
+
+To smoothly control the pause time, we do soft throttling in a small region
+under task_dirty_limit, starting from
+
+	task_throttle_thresh = task_dirty_limit - task_dirty_limit/16
+
+In fig.1, when bdi_dirty_pages falls into
+
+    [0, La]:    do nothing
+    [La, A]:    do soft throttling
+    [A, inf]:   do hard throttling
+
+Where hard throttling is to wait until bdi_dirty_pages falls more than
+task_dirtied_pages (the pages dirtied by the task since its last throttle
+time). It's "hard" because it may end up waiting for long time.
+
+Fig.1 dirty throttling regions
+                                              o
+                                                o
+                                                  o
+                                                    o
+                                                      o
+                                                        o
+                                                          o
+                                                            o
+----------------------------------------------+---------------o----------------|
+                                              La              A                T
+                no throttle                     soft throttle   hard throttle
+  T: bdi_dirty_limit
+  A: task_dirty_limit      = T - task_weight * T/16
+  La: task_throttle_thresh = A - A/16
+
+Soft dirty throttling is to pause the dirtier task for J:pause_time jiffies on
+every N:task_dirtied_pages pages it dirtied.  Let's call (N/J) the "throttle
+bandwidth". It is computed by the following formula:
+
+                                     task_dirty_limit - bdi_dirty_pages
+throttle_bandwidth = bdi_bandwidth * ----------------------------------
+                                           task_dirty_limit/16
+
+where bdi_bandwidth is the BDI's estimated write speed.
+
+Given the throttle_bandwidth for a task, we select a suitable N, so that when
+the task dirties so much pages, it enters balance_dirty_pages() to sleep for
+roughly J jiffies. N is adaptive to storage and task write speeds, so that the
+task always get suitable (not too long or small) pause time.
+
+dynamics
+--------
+
+When there is one heavy dirtier, bdi_dirty_pages will keep growing until
+exceeding the low threshold of the task's soft throttling region [La, A].
+At which point (La) the task will be controlled under speed
+throttle_bandwidth=bdi_bandwidth (fig.2) and remain stable there.
+
+Fig.2 one heavy dirtier
+
+    throttle_bandwidth ~= bdi_bandwidth  =>   o
+                                              | o
+                                              |   o
+                                              |     o
+                                              |       o
+                                              |         o
+                                              |           o
+                                            La|             o
+----------------------------------------------+---------------o----------------|
+                                              R               A                T
+  R: bdi_dirty_pages ~= La
+
+When there comes a new dd task B, task_weight_B will gradually grow from 0 to
+50% while task_weight_A will decrease from 100% to 50%.  When task_weight_B is
+still small, B is considered a light dirtier and is allowed to dirty pages much
+faster than the bdi write bandwidth. In fact initially it won't be throttled at
+all when R < Lb where Lb = B - B/16 and B ~= T.
+
+Fig.3 an old dd (A) + a newly started dd (B)
+
+                      throttle bandwidth  =>    *
+                                                | *
+                                                |   *
+                                                |     *
+                                                |       *
+                                                |         *
+                                                |           *
+                                                |             *
+                      throttle bandwidth  =>    o               *
+                                                | o               *
+                                                |   o               *
+                                                |     o               *
+                                                |       o               *
+                                                |         o               *
+                                                |           o               *
+------------------------------------------------+-------------o---------------*|
+                                                R             A               BT
+
+So R:bdi_dirty_pages will grow large. As task_weight_A and task_weight_B
+converge to 50%, the points A, B will go towards each other (fig.4) and
+eventually coincide with each other. R will stabilize around A-A/32 where
+A=B=T-0.5*T/16.  throttle_bandwidth will stabilize around bdi_bandwidth/2.
+
+Note that the application "think+dirty time" is ignored for simplicity in the
+above discussions. With non-zero user space think time, the balance point will
+slightly drift and not a big deal otherwise.
+
+Fig.4 the two dd's converging to the same bandwidth
+
+                                                         |
+                                 throttle bandwidth  =>  *
+                                                         | *
+                                 throttle bandwidth  =>  o   *
+                                                         | o   *
+                                                         |   o   *
+                                                         |     o   *
+                                                         |       o   *
+                                                         |         o   *
+---------------------------------------------------------+-----------o---*-----|
+                                                         R           A   B     T
+
+There won't be big oscillations between A and B, because as soon as A coincides
+with B, their throttle_bandwidth and hence dirty speed will be equal, A's
+weight will stop decreasing and B's weight will stop growing, so the two points
+won't keep moving and cross each other.
+
+Sure there are always oscillations of bdi_dirty_pages as long as the dirtier
+task alternatively do dirty and pause. But it will be bounded. When there is 1
+heavy dirtier, the error bound will be (pause_time * bdi_bandwidth). When there
+are 2 heavy dirtiers, the max error is 2 * (pause_time * bdi_bandwidth/2),
+which remains the same as 1 dirtier case (given the same pause time). In fact
+the more dirtier tasks, the less errors will be, since the dirtier tasks are
+not likely going to sleep at the same time.
+
+References
+----------
+
+Smarter write throttling
+http://lwn.net/Articles/245600/
+
+Flushing out pdflush
+http://lwn.net/Articles/326552/
+
+Dirty throttling slides
+http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling.pdf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
