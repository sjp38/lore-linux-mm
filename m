Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 407626B009B
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:03 -0400 (EDT)
Message-Id: <20100912155202.887304459@intel.com>
Date: Sun, 12 Sep 2010 23:49:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 02/17] writeback: IO-less balance_dirty_pages() 
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=writeback-bw-throttle.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <jens.axboe@oracle.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

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

- small nr_to_write for fast arrays

  The write_chunk used by current balance_dirty_pages() cannot be
  directly set to some large value (eg. 128MB) for better IO efficiency.
  Because it could lead to more than 1 second user perceivable stalls.
  This limits current balance_dirty_pages() to small inefficient IOs.

For the above two reasons, it's much better to shift IO to the flusher
threads and let balance_dirty_pages() just wait for enough time or progress.

Jan Kara, Dave Chinner and me explored the scheme to let
balance_dirty_pages() wait for enough writeback IO completions to
safeguard the dirty limit. This is found to have two problems:

- in large NUMA systems, the per-cpu counters may have big accounting
  errors, leading to big throttle wait time and jitters.

- NFS may kill large amount of unstable pages with one single COMMIT.
  Because NFS server serves COMMIT with expensive fsync() IOs, it is
  desirable to delay and reduce the number of COMMITs. So it's not
  likely to optimize away such kind of bursty IO completions, and the
  resulted large (and tiny) stall times in IO completion based throttling.

So here is a pause time oriented approach, which tries to control

- the pause time in each balance_dirty_pages() invocations
- the number of pages dirtied before calling balance_dirty_pages()

for smooth and efficient dirty throttling:

- avoid useless (eg. zero pause time) balance_dirty_pages() calls
- avoid too small pause time (less than  10ms, which burns CPU power)
- avoid too large pause time (more than 100ms, which hurts responsiveness)
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

cp-2687  [007]  1452.189182: balance_dirty_pages: bdi=8:0 weight=56% thresh=123892 gap=7700 dirtied=128 pause=8 bw=64494573
cp-2687  [007]  1452.198232: balance_dirty_pages: bdi=8:0 weight=56% thresh=123900 gap=7708 dirtied=128 pause=8 bw=64562234
cp-2687  [006]  1452.205170: balance_dirty_pages: bdi=8:0 weight=56% thresh=123907 gap=7715 dirtied=128 pause=8 bw=64613176
cp-2687  [006]  1452.213115: balance_dirty_pages: bdi=8:0 weight=56% thresh=123907 gap=7715 dirtied=128 pause=8 bw=64613829
cp-2687  [006]  1452.222154: balance_dirty_pages: bdi=8:0 weight=56% thresh=123908 gap=7716 dirtied=128 pause=8 bw=64622856
cp-2687  [002]  1452.229099: balance_dirty_pages: bdi=8:0 weight=56% thresh=123908 gap=7716 dirtied=128 pause=8 bw=64623508
cp-2687  [002]  1452.237012: balance_dirty_pages: bdi=8:0 weight=56% thresh=123915 gap=7723 dirtied=128 pause=8 bw=64682786
cp-2687  [002]  1452.246157: balance_dirty_pages: bdi=8:0 weight=56% thresh=123915 gap=7723 dirtied=128 pause=8 bw=64683437
cp-2687  [006]  1452.253043: balance_dirty_pages: bdi=8:0 weight=56% thresh=123922 gap=7730 dirtied=128 pause=8 bw=64734358
cp-2687  [006]  1452.261899: balance_dirty_pages: bdi=8:0 weight=57% thresh=123917 gap=7725 dirtied=128 pause=8 bw=64765323
cp-2687  [006]  1452.268939: balance_dirty_pages: bdi=8:0 weight=57% thresh=123924 gap=7732 dirtied=128 pause=8 bw=64816229
cp-2687  [002]  1452.276932: balance_dirty_pages: bdi=8:0 weight=57% thresh=123930 gap=7738 dirtied=128 pause=8 bw=64867113
cp-2687  [002]  1452.285889: balance_dirty_pages: bdi=8:0 weight=57% thresh=123931 gap=7739 dirtied=128 pause=8 bw=64876082


CONTROL SYSTEM
==============

The current task_dirty_limit() adjusts bdi_thresh according to the dirty
"weight" of the current task, which is the percent of pages recently
dirtied by the task. If 100% pages are recently dirtied by the task, it
will lower bdi_thresh by 1/8. If only 1% pages are dirtied by the task,
it will return almost unmodified bdi_thresh. In this way, a heavy
dirtier will get blocked at (bdi_thresh-bdi_thresh/8) while allowing a
light dirtier to progress (the latter won't be blocked because R << B in
fig.1).

Fig.1 before patch, a heavy dirtier and a light dirtier
                                                R
----------------------------------------------+-o---------------------------*--|
                                              L A                           B  T
  T: bdi_dirty_limit
  L: bdi_dirty_limit - bdi_dirty_limit/8

  R: bdi_reclaimable + bdi_writeback

  A: bdi_thresh for a heavy dirtier ~= R ~= L
  B: bdi_thresh for a light dirtier ~= T

If B is a newly started heavy dirtier, then it will slowly gain weight
and A will lose weight.  The bdi_thresh for A and B will be approaching
the center of region (L, T) and eventually stabilize there.

Fig.2 before patch, two heavy dirtiers converging to the same threshold
                                                             R
----------------------------------------------+--------------o-*---------------|
                                              L              A B               T

Now for IO-less balance_dirty_pages(), let's do it in a "bandwidth control"
way. In fig.3, a soft dirty limit region (L, A) is introduced. When R enters
this region, the task may be throttled for T seconds on every N pages it dirtied.
Let's call (N/T) the "throttle bandwidth". It is computed by the following fomula:

        throttle_bandwidth = bdi_bandwidth * (A - R) / (A - L)
where
        L = A - A/16
	A = T - T/16

So when there is only one heavy dirtier (fig.3),

        R ~= L
        throttle_bandwidth ~= bdi_bandwidth

It's a stable balance:
- when R > L, then throttle_bandwidth < bdi_bandwidth, so R will decrease to L
- when R < L, then throttle_bandwidth > bdi_bandwidth, so R will increase to L

Fig.3 after patch, one heavy dirtier

                                                |
    throttle_bandwidth ~= bdi_bandwidth  =>     o
                                                | o
                                                |   o
                                                |     o
                                                |       o
                                                |         o
                                              L |           o
----------------------------------------------+-+-------------o----------------|
                                                R             A                T
  T: bdi_dirty_limit
  A: task_dirty_limit = bdi_dirty_limit - bdi_dirty_limit/16
  L: task_dirty_limit - task_dirty_limit/16

  R: bdi_reclaimable + bdi_writeback ~= L

When there comes a new cp task, its weight will grow from 0 to 50%.
When the weight is still small, it's considered a light dirtier and it's
allowed to dirty pages much faster than the bdi write bandwidth. In fact
initially it won't be throttled at all when R < Lb where Lb=B-B/16 and B~=T.

Fig.4 after patch, an old cp + a newly started cp

                     (throttle bandwidth) =>    *
                                                | *
                                                |   *
                                                |     *
                                                |       *
                                                |         *
                                                |           *
                                                |             *
                      throttle bandwidth  =>    o               *
                                                | o               *
                                                |   o               *
                                                |     o               *
                                                |       o               *
                                                |         o               *
                                                |           o               *
------------------------------------------------+-------------o---------------*|
                                                R             A               BT

So R will quickly grow large (fig.5). As the two heavy dirtiers' weight
converge to 50%, the points A, B will go towards each other and
eventually become one in fig.5. R will stabilize around A-A/32 where
A=B=T-T/16. throttle_bandwidth will stabilize around bdi_bandwidth/2.
There won't be big oscillations between A and B, because as long as A
coincides with B, their throttle_bandwidth and dirtied pages will be
equal, A's weight will stop decreasing and B's weight will stop growing,
so the two points won't keep moving and cross each other. So it's a
pretty stable control system. The only problem is, it converges a bit
slow (except for really fast storage array).

Fig.5 after patch, the two heavy dirtiers converging to the same bandwidth

                                                         |
                                                         |
                                 throttle bandwidth  =>  *
                                                         | *
                                 throttle bandwidth  =>  o   *
                                                         | o   *
                                                         |   o   *
                                                         |     o   *
                                                         |       o   *
                                                         |         o   *
---------------------------------------------------------+-----------o---*-----|
                                                         R           A   B     T

Note that the application "think time" is ignored for simplicity in the
above discussions.  With non-zero user space think time, the balance
point will slightly drift and not a big deal otherwise.

PSEUDO CODE
===========

balance_dirty_pages():

	if (dirty_soft_thresh exceeded &&
	      bdi_soft_thresh exceeded)
		sleep (pages_dirtied / throttle_bandwidth)

	while (bdi_thresh exceeded) {
		sleep 200ms
		break if (bdi dirty/writeback pages) _dropped_ more than
			8 * (pages_dirtied by this task)
	}

	while (dirty_thresh exceeded)
		sleep 200ms

Basically there are three level of throttling now.

- normally the dirtier will be adaptively throttled with good timing

- when bdi_thresh is exceeded, the task will be throttled until bdi
  dirty/writeback pages go down reasonably large

- when dirty_thresh is exceeded, the task will be throttled for
  arbitrary long time

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
except for some noticeable reduction of CPU overheads. It should
mainly benefit file servers with heavy concurrent writers on fast
storage arrays.

CC: Chris Mason <chris.mason@oracle.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Jan Kara <jack@suse.cz>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Jens Axboe <jens.axboe@oracle.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/writeback.h |    9 +++
 mm/page-writeback.c       |   95 +++++++++++-------------------------
 2 files changed, 39 insertions(+), 65 deletions(-)

--- linux-next.orig/include/linux/writeback.h	2010-09-09 15:43:29.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-09-12 12:51:20.000000000 +0800
@@ -14,6 +14,15 @@ extern struct list_head inode_in_use;
 extern struct list_head inode_unused;
 
 /*
+ * The 1/16 region under the bdi dirty threshold is set aside for elastic
+ * throttling. In rare cases when the threshold is exceeded, more rigid
+ * throttling will be imposed, which will inevitably stall the dirtier task
+ * for seconds (or more) at _one_ time. The rare case could be a fork bomb
+ * where every new task dirties some more pages.
+ */
+#define DIRTY_SOFT_THROTTLE_RATIO	16
+
+/*
  * fs/fs-writeback.c
  */
 enum writeback_sync_modes {
--- linux-next.orig/mm/page-writeback.c	2010-09-09 15:43:29.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-09-12 13:18:08.000000000 +0800
@@ -42,20 +42,6 @@
  */
 static long ratelimit_pages = 32;
 
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
-
 /* The following parameters are exported via /proc/sys/vm */
 
 /*
@@ -279,7 +265,7 @@ static unsigned long task_dirty_limit(st
 {
 	long numerator, denominator;
 	unsigned long dirty = bdi_dirty;
-	u64 inv = dirty >> 3;
+	u64 inv = dirty / DIRTY_SOFT_THROTTLE_RATIO;
 
 	task_dirties_fraction(tsk, &numerator, &denominator);
 	inv *= numerator;
@@ -473,26 +459,26 @@ unsigned long bdi_dirty_limit(struct bac
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
+	unsigned long pause;
+	unsigned long gap;
+	unsigned long bw;
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
@@ -529,6 +515,23 @@ static void balance_dirty_pages(struct a
 			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		if (bdi_nr_reclaimable + bdi_nr_writeback <=
+			bdi_thresh - bdi_thresh / DIRTY_SOFT_THROTTLE_RATIO)
+			goto check_exceeded;
+
+		gap = bdi_thresh > (bdi_nr_reclaimable + bdi_nr_writeback) ?
+		      bdi_thresh - (bdi_nr_reclaimable + bdi_nr_writeback) : 0;
+
+		bw = (100 << 20) * gap /
+				(bdi_thresh / DIRTY_SOFT_THROTTLE_RATIO + 1);
+
+		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
+		pause = clamp_val(pause, 1, HZ/5);
+
+		__set_current_state(TASK_INTERRUPTIBLE);
+		io_schedule_timeout(pause);
+
+check_exceeded:
 		/*
 		 * The bdi thresh is somehow "soft" limit derived from the
 		 * global "hard" limit. The former helps to prevent heavy IO
@@ -544,35 +547,6 @@ static void balance_dirty_pages(struct a
 
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
@@ -581,16 +555,7 @@ static void balance_dirty_pages(struct a
 	if (writeback_in_progress(bdi))
 		return;
 
-	/*
-	 * In laptop mode, we wait until hitting the higher threshold before
-	 * starting background writeout, and then write out all the way down
-	 * to the lower threshold.  So slow writers cause minimal disk activity.
-	 *
-	 * In normal mode, we start background writeout at the lower
-	 * background_thresh, to keep the amount of dirty memory low.
-	 */
-	if ((laptop_mode && pages_written) ||
-	    (!laptop_mode && (nr_reclaimable > background_thresh)))
+	if (nr_reclaimable > background_thresh)
 		bdi_start_background_writeback(bdi);
 }
 
@@ -638,7 +603,7 @@ void balance_dirty_pages_ratelimited_nr(
 	p =  &__get_cpu_var(bdp_ratelimits);
 	*p += nr_pages_dirtied;
 	if (unlikely(*p >= ratelimit)) {
-		ratelimit = sync_writeback_pages(*p);
+		ratelimit = *p;
 		*p = 0;
 		preempt_enable();
 		balance_dirty_pages(mapping, ratelimit);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
