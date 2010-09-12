Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EB5D76B007B
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:02 -0400 (EDT)
Message-Id: <20100912155204.944256600@intel.com>
Date: Sun, 12 Sep 2010 23:50:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 15/17] mm: lower soft dirty limits on memory pressure
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=mm-dynamic-dirty-throttle.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

When memory pressure increases, the LRU lists will be scanned faster and
hence more easily to hit dirty pages and trigger undesirable pageout()s.

Avoiding pageout() reduces a good number of problems, eg. IO efficiency,
responsiveness, vmscan efficiency, etc.

Introduce vm_dirty_pressure to keep track of the vmscan pressure in
dirty page out POV. It ranges from VM_DIRTY_PRESSURE to 0. Lower value
means more pageout() pressure.

The adaption rules are basically "fast down, slow up".

- when encountered dirty pages during vmscan, vm_dirty_pressure will be
  instantly lowered to
  - VM_DIRTY_PRESSURE/2 for priority=DEF_PRIORITY
  - VM_DIRTY_PRESSURE/4 for priority=DEF_PRIORITY-1
  ...
  - 0 for priority=3

- whenever kswapd (of the most pressured node) goes idle, add 1 to
  vm_dirty_pressure. If that node keeps idle, its kswapd will wakeup
  every second to increase vm_dirty_pressure over time.
  
The vm_dirty_pressure_node trick can avoid it being increased too fast
in large NUMA. On the other hand, it may still be decreased too much
when only one node is pressured in large NUMA. (XXX: easy ways to detect
that?)

The above heuristics will keep vm_dirty_pressure near 512 during a
simple write test: cp /dev/zero /tmp/. The test box has 4GB memory.

The ratio (vm_dirty_pressure : VM_DIRTY_PRESSURE) will be directly
multiplied to the _soft_ dirty limits.

- it's able to avoid abrupt change of the applications' progress speed

- it also tries to keep the bdi dirty throttle limit above 1 second
  worth of dirty pages, to avoid hurting IO efficiency

- the background dirty threshold can reach 0, so that when there are no
  heavy dirtiers, all dirty pages can be cleaned

Simply lowering the dirty limits may not immediately knock down the
number of dirty pages (still there are good chances the flusher thread
is running or will run soon).  The wake up of flusher thread will be
carried out in more patches -- maybe revised versions of

	http://lkml.org/lkml/2010/7/29/191
	http://lkml.org/lkml/2010/7/29/189

CC: Dave Chinner <david@fromorbit.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c         |    3 ++
 include/linux/writeback.h |    4 +++
 mm/page-writeback.c       |   38 +++++++++++++++++++++++++++++-------
 mm/vmscan.c               |   18 ++++++++++++++++-
 4 files changed, 55 insertions(+), 8 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-09-11 15:34:38.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-09-11 15:35:03.000000000 +0800
@@ -574,6 +574,9 @@ static inline bool over_bground_thresh(v
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
 
+	background_thresh = background_thresh *
+					vm_dirty_pressure / VM_DIRTY_PRESSURE;
+
 	return (global_page_state(NR_FILE_DIRTY) +
 		global_page_state(NR_UNSTABLE_NFS) > background_thresh);
 }
--- linux-next.orig/include/linux/writeback.h	2010-09-11 15:34:37.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-09-11 15:35:01.000000000 +0800
@@ -22,6 +22,8 @@ extern struct list_head inode_unused;
  */
 #define DIRTY_SOFT_THROTTLE_RATIO	16
 
+#define VM_DIRTY_PRESSURE		(1 << 10)
+
 /*
  * fs/fs-writeback.c
  */
@@ -107,6 +109,8 @@ void throttle_vm_writeout(gfp_t gfp_mask
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
 extern unsigned long dirty_background_bytes;
+extern int vm_dirty_pressure;
+extern int vm_dirty_pressure_node;
 extern int vm_dirty_ratio;
 extern unsigned long vm_dirty_bytes;
 extern unsigned int dirty_writeback_interval;
--- linux-next.orig/mm/page-writeback.c	2010-09-11 15:34:38.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-09-11 15:35:01.000000000 +0800
@@ -62,6 +62,14 @@ unsigned long dirty_background_bytes;
 int vm_highmem_is_dirtyable;
 
 /*
+ * The vm_dirty_pressure:VM_DIRTY_PRESSURE ratio is used to lower the soft
+ * dirty throttle limits under memory pressure, so as to reduce the number of
+ * dirty pages and hence undesirable pageout() calls in page reclaim.
+ */
+int vm_dirty_pressure = VM_DIRTY_PRESSURE;
+int vm_dirty_pressure_node;
+
+/*
  * The generator of dirty data starts writeback at this percentage
  */
 int vm_dirty_ratio = 20;
@@ -491,6 +499,7 @@ static void balance_dirty_pages(struct a
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
+	unsigned long thresh;
 	unsigned long pause;
 	unsigned long gap;
 	unsigned long bw;
@@ -519,8 +528,9 @@ static void balance_dirty_pages(struct a
 		 * catch-up. This avoids (excessively) small writeouts
 		 * when the bdi limits are ramping up.
 		 */
-		if (nr_reclaimable + nr_writeback <=
-				(background_thresh + dirty_thresh) / 2)
+		thresh = (background_thresh + dirty_thresh) / 2;
+		thresh = thresh * vm_dirty_pressure / VM_DIRTY_PRESSURE;
+		if (nr_reclaimable + nr_writeback <= thresh)
 			break;
 
 		task_dirties_fraction(current, &numerator, &denominator);
@@ -560,8 +570,22 @@ static void balance_dirty_pages(struct a
 			break;
 		bdi_prev_total = bdi_nr_reclaimable + bdi_nr_writeback;
 
-		if (bdi_nr_reclaimable + bdi_nr_writeback <=
-			bdi_thresh - bdi_thresh / DIRTY_SOFT_THROTTLE_RATIO)
+
+		thresh = bdi_thresh - bdi_thresh / DIRTY_SOFT_THROTTLE_RATIO;
+		/*
+		 * Lower the soft throttle thresh according to dirty pressure,
+		 * but keep a minimal pool of dirty pages that can be written
+		 * within 1 second to prevent hurting IO performance.
+		 */
+		if (vm_dirty_pressure < VM_DIRTY_PRESSURE) {
+			int dp = vm_dirty_pressure;
+			bw = bdi->write_bandwidth >> PAGE_CACHE_SHIFT;
+			if (thresh * dp / VM_DIRTY_PRESSURE > bw)
+				thresh = thresh * dp / VM_DIRTY_PRESSURE;
+			else if (thresh > bw)
+				thresh = bw;
+		}
+		if (bdi_nr_reclaimable + bdi_nr_writeback <= thresh)
 			goto check_exceeded;
 
 		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
@@ -569,8 +593,7 @@ static void balance_dirty_pages(struct a
 		gap = bdi_thresh > (bdi_nr_reclaimable + bdi_nr_writeback) ?
 		      bdi_thresh - (bdi_nr_reclaimable + bdi_nr_writeback) : 0;
 
-		bw = bdi->write_bandwidth * gap /
-				(bdi_thresh / DIRTY_SOFT_THROTTLE_RATIO + 1);
+		bw = bdi->write_bandwidth * gap / (bdi_thresh - thresh + 1);
 
 		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
 		pause = clamp_val(pause, 1, HZ/5);
@@ -617,7 +640,8 @@ check_exceeded:
 	if (writeback_in_progress(bdi))
 		return;
 
-	if (nr_reclaimable > background_thresh)
+	if (nr_reclaimable > background_thresh *
+					vm_dirty_pressure / VM_DIRTY_PRESSURE)
 		bdi_start_background_writeback(bdi);
 }
 
--- linux-next.orig/mm/vmscan.c	2010-09-11 15:34:39.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-09-11 15:35:01.000000000 +0800
@@ -745,6 +745,16 @@ static unsigned long shrink_page_list(st
 		}
 
 		if (PageDirty(page)) {
+
+			if (file && scanning_global_lru(sc)) {
+				int dp = VM_DIRTY_PRESSURE >>
+					(DEF_PRIORITY + 1 - sc->priority);
+				if (vm_dirty_pressure > dp) {
+					vm_dirty_pressure = dp;
+					vm_dirty_pressure_node = numa_node_id();
+				}
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
@@ -2354,8 +2364,14 @@ static int kswapd(void *p)
 				 * to sleep until explicitly woken up
 				 */
 				if (!sleeping_prematurely(pgdat, order, remaining)) {
+					int dp = vm_dirty_pressure;
 					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
-					schedule();
+					if (dp < VM_DIRTY_PRESSURE &&
+					    vm_dirty_pressure_node == numa_node_id()) {
+						vm_dirty_pressure = dp + 1;
+						schedule_timeout(HZ);
+					} else
+						schedule();
 				} else {
 					if (remaining)
 						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
