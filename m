Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id D64636B00EB
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:56:30 -0500 (EST)
Message-Id: <20120228144747.274382545@intel.com>
Date: Tue, 28 Feb 2012 22:00:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 6/9] vmscan: dirty reclaim throttling
References: <20120228140022.614718843@intel.com>
Content-Disposition: inline; filename=vmscan-pgreclaim-throttle.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

1) OOM avoidance and scan rate control

Typically we do LRU scan w/o rate control and quickly get enough clean
pages for the LRU lists not full of dirty pages.

Or we can still get a number of freshly cleaned pages (moved to LRU tail
by end_page_writeback()) when the queued pageout I/O is completed within
tens of milli-seconds.

However if the LRU list is small and full of dirty pages, it can be quickly
fully scanned and go OOM before the flusher manages to clean enough pages.
Generally this does not happen for global reclaim which does dirty throttling
but happens easily with memcg LRUs.

A simple yet reliable scheme is employed to avoid OOM and keep scan rate
in sync with the I/O rate:

	if (encountered PG_reclaim pages)
		do some throttle wait

PG_reclaim plays the key role. When a dirty page is encountered, we
queue pageout writeback work for it, set PG_reclaim and put it back to
the LRU head. So if PG_reclaim pages are encountered again, it means
they have not yet been cleaned by the flusher after a full scan of the
inactive list. It indicates we are scanning faster than I/O and shall
take a snap.

The runtime behavior on a fully dirtied small LRU list would be:
It will start with a quick scan of the list, queuing all pages for I/O.
Then the scan will be slowed down by the PG_reclaim pages *adaptively*
to match the I/O bandwidth.

2) selective dirty reclaim throttling for interactive performance

For desktops, it's not just the USB writer, but also unrelated processes
that are allocating memory at the same time the writing happens. What we
want to avoid is a situation where something like firefox or evolution
or even gnome-terminal is performing a small read and gets either

a) started for IO bandwidth and stalls (not the focus here obviously)
b) enter page reclaim, finds PG_reclaim pages from the USB write and stalls

It's (b) we need to watch out for. So we try to only throttle the write
tasks by means of

- distinguish dirtier tasks and unrelated clean tasks by testing
   - whether __GFP_WRITE is set
   - whether current->nr_dirtied changed recently

- put dirtier tasks to wait at lower dirty fill levels (~50%) and
  clean tasks at much higher threshold (80%).

- slightly decrease wait threshold on decreased scan priority
  (which indicates long run of hard-to-reclaim pages)

3) test case

Run 2 dd tasks in a 100MB memcg (a very handy test case from Greg Thelen):

	mkdir /cgroup/x
	echo 100M > /cgroup/x/memory.limit_in_bytes
	echo $$ > /cgroup/x/tasks

	for i in `seq 2`
	do
		dd if=/dev/zero of=/fs/f$i bs=1k count=1M &
	done

Before patch, the dd tasks are quickly OOM killed.
After patch, they run well with reasonably good performance and overheads:

1073741824 bytes (1.1 GB) copied, 22.2196 s, 48.3 MB/s
1073741824 bytes (1.1 GB) copied, 22.4675 s, 47.8 MB/s

iostat -kx 1

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00  178.00     0.00 89568.00  1006.38    74.35  417.71   4.80  85.40
sda               0.00     2.00    0.00  191.00     0.00 94428.00   988.77    53.34  219.03   4.34  82.90
sda               0.00    20.00    0.00  196.00     0.00 97712.00   997.06    71.11  337.45   4.77  93.50
sda               0.00     5.00    0.00  175.00     0.00 84648.00   967.41    54.03  316.44   5.06  88.60
sda               0.00     0.00    0.00  186.00     0.00 92432.00   993.89    56.22  267.54   5.38 100.00
sda               0.00     1.00    0.00  183.00     0.00 90156.00   985.31    37.99  325.55   4.33  79.20
sda               0.00     0.00    0.00  175.00     0.00 88692.00  1013.62    48.70  218.43   4.69  82.10
sda               0.00     0.00    0.00  196.00     0.00 97528.00   995.18    43.38  236.87   5.10 100.00
sda               0.00     0.00    0.00  179.00     0.00 88648.00   990.48    45.83  285.43   5.59 100.00
sda               0.00     0.00    0.00  178.00     0.00 88500.00   994.38    28.28  158.89   4.99  88.80
sda               0.00     0.00    0.00  194.00     0.00 95852.00   988.16    32.58  167.39   5.15 100.00
sda               0.00     2.00    0.00  215.00     0.00 105996.00   986.01    41.72  201.43   4.65 100.00
sda               0.00     4.00    0.00  173.00     0.00 84332.00   974.94    50.48  260.23   5.76  99.60
sda               0.00     0.00    0.00  182.00     0.00 90312.00   992.44    36.83  212.07   5.49 100.00
sda               0.00     8.00    0.00  195.00     0.00 95940.50   984.01    50.18  221.06   5.13 100.00
sda               0.00     1.00    0.00  220.00     0.00 108852.00   989.56    40.99  202.68   4.55 100.00
sda               0.00     2.00    0.00  161.00     0.00 80384.00   998.56    37.19  268.49   6.21 100.00
sda               0.00     4.00    0.00  182.00     0.00 90830.00   998.13    50.58  239.77   5.49 100.00
sda               0.00     0.00    0.00  197.00     0.00 94877.00   963.22    36.68  196.79   5.08 100.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.25    0.00   15.08   33.92    0.00   50.75
           0.25    0.00   14.54   35.09    0.00   50.13
           0.50    0.00   13.57   32.41    0.00   53.52
           0.50    0.00   11.28   36.84    0.00   51.38
           0.50    0.00   15.75   32.00    0.00   51.75
           0.50    0.00   10.50   34.00    0.00   55.00
           0.50    0.00   17.63   27.46    0.00   54.41
           0.50    0.00   15.08   30.90    0.00   53.52
           0.50    0.00   11.28   32.83    0.00   55.39
           0.75    0.00   16.79   26.82    0.00   55.64
           0.50    0.00   16.08   29.15    0.00   54.27
           0.50    0.00   13.50   30.50    0.00   55.50
           0.50    0.00   14.32   35.18    0.00   50.00
           0.50    0.00   12.06   33.92    0.00   53.52
           0.50    0.00   17.29   30.58    0.00   51.63
           0.50    0.00   15.08   29.65    0.00   54.77
           0.50    0.00   12.53   29.32    0.00   57.64
           0.50    0.00   15.29   31.83    0.00   52.38

The global dd numbers for comparison:

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00  189.00     0.00 95752.00  1013.25   143.09  684.48   5.29 100.00
sda               0.00     0.00    0.00  208.00     0.00 105480.00  1014.23   143.06  733.29   4.81 100.00
sda               0.00     0.00    0.00  161.00     0.00 81924.00  1017.69   141.71  757.79   6.21 100.00
sda               0.00     0.00    0.00  217.00     0.00 109580.00  1009.95   143.09  749.55   4.61 100.10
sda               0.00     0.00    0.00  187.00     0.00 94728.00  1013.13   144.31  773.67   5.35 100.00
sda               0.00     0.00    0.00  189.00     0.00 95752.00  1013.25   144.14  742.00   5.29 100.00
sda               0.00     0.00    0.00  177.00     0.00 90032.00  1017.31   143.32  656.59   5.65 100.00
sda               0.00     0.00    0.00  215.00     0.00 108640.00  1010.60   142.90  817.54   4.65 100.00
sda               0.00     2.00    0.00  166.00     0.00 83858.00  1010.34   143.64  808.61   6.02 100.00
sda               0.00     0.00    0.00  186.00     0.00 92813.00   997.99   141.18  736.95   5.38 100.00
sda               0.00     0.00    0.00  206.00     0.00 104456.00  1014.14   146.27  729.33   4.85 100.00
sda               0.00     0.00    0.00  213.00     0.00 107024.00  1004.92   143.25  705.70   4.69 100.00
sda               0.00     0.00    0.00  188.00     0.00 95748.00  1018.60   141.82  764.78   5.32 100.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.51    0.00   11.22   52.30    0.00   35.97
           0.25    0.00   10.15   52.54    0.00   37.06
           0.25    0.00    5.01   56.64    0.00   38.10
           0.51    0.00   15.15   43.94    0.00   40.40
           0.25    0.00   12.12   48.23    0.00   39.39
           0.51    0.00   11.20   53.94    0.00   34.35
           0.26    0.00    9.72   51.41    0.00   38.62
           0.76    0.00    9.62   50.63    0.00   38.99
           0.51    0.00   10.46   53.32    0.00   35.71
           0.51    0.00    9.41   51.91    0.00   38.17
           0.25    0.00   10.69   49.62    0.00   39.44
           0.51    0.00   12.21   52.67    0.00   34.61
           0.51    0.00   11.45   53.18    0.00   34.86

XXX: commit NFS unstable pages via write_inode(). Well it's currently
not possible to specify range of pages to commit.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/mmzone.h        |    1 
 include/linux/sched.h         |    1 
 include/linux/writeback.h     |    2 
 include/trace/events/vmscan.h |   68 ++++++++++
 mm/internal.h                 |    2 
 mm/page-writeback.c           |    2 
 mm/page_alloc.c               |    1 
 mm/swap.c                     |    4 
 mm/vmscan.c                   |  211 ++++++++++++++++++++++++++++++--
 9 files changed, 278 insertions(+), 14 deletions(-)

--- linux.orig/include/linux/writeback.h	2012-02-28 20:50:01.855765353 +0800
+++ linux/include/linux/writeback.h	2012-02-28 20:50:06.411765461 +0800
@@ -136,6 +136,8 @@ static inline void laptop_sync_completio
 #endif
 void throttle_vm_writeout(gfp_t gfp_mask);
 bool zone_dirty_ok(struct zone *zone);
+unsigned long zone_dirtyable_memory(struct zone *zone);
+unsigned long global_dirtyable_memory(void);
 
 extern unsigned long global_dirty_limit;
 
--- linux.orig/mm/page-writeback.c	2012-02-28 20:50:01.799765351 +0800
+++ linux/mm/page-writeback.c	2012-02-28 20:50:06.411765461 +0800
@@ -263,7 +263,7 @@ void global_dirty_limits(unsigned long *
  * Returns the zone's number of pages potentially available for dirty
  * page cache.  This is the base value for the per-zone dirty limits.
  */
-static unsigned long zone_dirtyable_memory(struct zone *zone)
+unsigned long zone_dirtyable_memory(struct zone *zone)
 {
 	/*
 	 * The effective global number of dirtyable pages may exclude
--- linux.orig/mm/swap.c	2012-02-28 20:50:01.791765351 +0800
+++ linux/mm/swap.c	2012-02-28 20:50:06.411765461 +0800
@@ -270,8 +270,10 @@ void rotate_reclaimable_page(struct page
 		page_cache_get(page);
 		local_irq_save(flags);
 		pvec = &__get_cpu_var(lru_rotate_pvecs);
-		if (!pagevec_add(pvec, page))
+		if (!pagevec_add(pvec, page)) {
 			pagevec_move_tail(pvec);
+			reclaim_rotated(page);
+		}
 		local_irq_restore(flags);
 	}
 }
--- linux.orig/mm/vmscan.c	2012-02-28 20:50:01.815765352 +0800
+++ linux/mm/vmscan.c	2012-02-28 20:52:56.227769496 +0800
@@ -50,9 +50,6 @@
 
 #include "internal.h"
 
-#define CREATE_TRACE_POINTS
-#include <trace/events/vmscan.h>
-
 /*
  * reclaim_mode determines how the inactive list is shrunk
  * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
@@ -120,6 +117,40 @@ struct mem_cgroup_zone {
 	struct zone *zone;
 };
 
+/*
+ * page reclaim dirty throttle thresholds:
+ *
+ *              20%           40%    50%    60%           80%
+ * |------+------+------+------+------+------+------+------+------+------|
+ * 0             ^BALANCED     ^THROTTLE_WRITE	           ^THROTTLE_ALL
+ *
+ * The LRU dirty pages should normally be under the 20% global balance ratio.
+ * When exceeding 40%, the allocations for writes will be throttled; in case
+ * that failed to keep the dirty pages under control, we'll have to throttle
+ * all tasks when above 80%, to avoid spinning the CPU.
+ *
+ * We start throttling KSWAPD before ALL, hoping to trigger more direct reclaims
+ * to throttle the write tasks and keep dirty pages from growing up.
+ */
+enum reclaim_dirty_level {
+	DIRTY_LEVEL_BALANCED			= 2,
+	DIRTY_LEVEL_THROTTLE_WRITE		= 4,
+	DIRTY_LEVEL_THROTTLE_RECENT_WRITE	= 5,
+	DIRTY_LEVEL_THROTTLE_KSWAPD		= 6,
+	DIRTY_LEVEL_THROTTLE_ALL		= 8,
+	DIRTY_LEVEL_MAX				= 10
+};
+enum reclaim_throttle_type {
+	RTT_WRITE,
+	RTT_RECENT_WRITE,
+	RTT_KSWAPD,
+	RTT_CLEAN,
+	RTT_MAX
+};
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/vmscan.h>
+
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 #ifdef ARCH_HAS_PREFETCH
@@ -767,7 +798,8 @@ static unsigned long shrink_page_list(st
 				      struct scan_control *sc,
 				      int priority,
 				      unsigned long *ret_nr_dirty,
-				      unsigned long *ret_nr_writeback)
+				      unsigned long *ret_nr_writeback,
+				      unsigned long *ret_nr_pgreclaim)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -776,6 +808,7 @@ static unsigned long shrink_page_list(st
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_pgreclaim = 0;
 
 	cond_resched();
 
@@ -814,6 +847,14 @@ static unsigned long shrink_page_list(st
 		if (PageWriteback(page)) {
 			nr_writeback++;
 			/*
+			 * The pageout works do write around which may put
+			 * close-to-LRU-tail pages to writeback a bit earlier.
+			 */
+			if (PageReclaim(page))
+				nr_pgreclaim++;
+			else
+				SetPageReclaim(page);
+			/*
 			 * Synchronous reclaim cannot queue pages for
 			 * writeback due to the possibility of stack overflow
 			 * but if it encounters a page under writeback, wait
@@ -885,21 +926,45 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 
 			/*
+			 * The PG_reclaim page was put to I/O and moved to LRU
+			 * head sometime ago. If hit it again at LRU tail, we
+			 * may be scanning faster than the flusher can writeout
+			 * dirty pages. So suggest some reclaim_wait throttling
+			 * to match the I/O rate.
+			 */
+			if (page_is_file_cache(page) && PageReclaim(page)) {
+				nr_pgreclaim++;
+				goto keep_locked;
+			}
+
+			/*
 			 * Try relaying the pageout I/O to the flusher threads
 			 * for better I/O efficiency and avoid stack overflow.
 			 */
-			if (page_is_file_cache(page) && mapping &&
-			    queue_pageout_work(mapping, page) >= 0) {
+			if (page_is_file_cache(page) && mapping) {
+				int res = queue_pageout_work(mapping, page);
+
+				/*
+				 * It's not really PG_reclaim, but here we need
+				 * to trigger reclaim_wait to avoid overrunning
+				 * I/O when there are too many works queued, or
+				 * cannot queue new work at all.
+				 */
+				if (res < 0 || res > LOTS_OF_WRITEBACK_WORKS)
+					nr_pgreclaim++;
+
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
 				 * except we already have the page isolated
 				 * and know it's dirty
 				 */
-				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
-				SetPageReclaim(page);
-
-				goto keep_locked;
+				if (res >= 0) {
+					inc_zone_page_state(page,
+							NR_VMSCAN_IMMEDIATE);
+					SetPageReclaim(page);
+					goto keep_locked;
+				}
 			}
 
 			/*
@@ -1043,6 +1108,7 @@ keep_lumpy:
 	count_vm_events(PGACTIVATE, pgactivate);
 	*ret_nr_dirty += nr_dirty;
 	*ret_nr_writeback += nr_writeback;
+	*ret_nr_pgreclaim += nr_pgreclaim;
 	return nr_reclaimed;
 }
 
@@ -1508,6 +1574,117 @@ static inline bool should_reclaim_stall(
 	return priority <= lumpy_stall_priority;
 }
 
+static int reclaim_dirty_level(unsigned long dirty,
+			       unsigned long total)
+{
+	unsigned long limit = total * global_dirty_limit /
+					global_dirtyable_memory();
+	if (dirty <= limit)
+		return 0;
+
+	dirty -= limit;
+	total -= limit;
+
+	return 8 * dirty / (total | 1) + DIRTY_LEVEL_BALANCED;
+}
+
+static bool should_throttle_dirty(struct mem_cgroup_zone *mz,
+				  struct scan_control *sc,
+				  int priority)
+{
+	unsigned long nr_dirty;
+	unsigned long nr_dirtyable;
+	int dirty_level = -1;
+	int level;
+	int type;
+	bool wait;
+
+	if (global_reclaim(sc)) {
+		struct zone *zone = mz->zone;
+		nr_dirty = zone_page_state(zone, NR_FILE_DIRTY) +
+				zone_page_state(zone, NR_UNSTABLE_NFS) +
+				zone_page_state(zone, NR_WRITEBACK);
+		nr_dirtyable = zone_dirtyable_memory(zone);
+	} else {
+		struct mem_cgroup *memcg = mz->mem_cgroup;
+		nr_dirty = mem_cgroup_dirty_pages(memcg);
+		nr_dirtyable = mem_cgroup_page_stat(memcg,
+						    MEMCG_NR_DIRTYABLE_PAGES);
+		trace_printk("memcg nr_dirtyable=%lu nr_dirty=%lu\n",
+			     nr_dirtyable, nr_dirty);
+	}
+
+	dirty_level = reclaim_dirty_level(nr_dirty, nr_dirtyable);
+	/*
+	 * Take a snap when encountered a long contiguous run of dirty pages.
+	 * When under global dirty limit, kswapd will only wait on priority==0,
+	 * and the clean tasks will never wait.
+	 */
+	level = dirty_level + (DEF_PRIORITY - priority) / 2;
+
+	if (current_is_kswapd()) {
+		type = RTT_KSWAPD;
+		wait = level >= DIRTY_LEVEL_THROTTLE_KSWAPD;
+		goto out;
+	}
+
+	if (sc->gfp_mask & __GFP_WRITE) {
+		type = RTT_WRITE;
+		wait = level >= DIRTY_LEVEL_THROTTLE_WRITE;
+		goto out;
+	}
+
+	if (current->nr_dirtied != current->nr_dirtied_snapshot) {
+		type = RTT_RECENT_WRITE;
+		wait = level >= DIRTY_LEVEL_THROTTLE_RECENT_WRITE;
+		current->nr_dirtied_snapshot = current->nr_dirtied;
+		goto out;
+	}
+
+	type = RTT_CLEAN;
+	wait = level >= DIRTY_LEVEL_THROTTLE_ALL;
+out:
+	if (wait) {
+		trace_mm_vmscan_should_throttle_dirty(type, priority,
+						      dirty_level, wait);
+	}
+	return wait;
+}
+
+
+/*
+ * reclaim_wait - wait for some pages being rotated to the LRU tail
+ * @zone: the zone under page reclaim
+ * @timeout: timeout in jiffies
+ *
+ * Wait until @timeout, or when some (typically PG_reclaim under writeback)
+ * pages rotated to the LRU so that page reclaim can make progress.
+ */
+static long reclaim_wait(struct mem_cgroup_zone *mz, long timeout)
+{
+	unsigned long start = jiffies;
+	wait_queue_head_t *wqh;
+	DEFINE_WAIT(wait);
+	long ret;
+
+	wqh = &mz->zone->zone_pgdat->reclaim_wait;
+	prepare_to_wait(wqh, &wait, TASK_KILLABLE);
+	ret = io_schedule_timeout(timeout);
+	finish_wait(wqh, &wait);
+
+	trace_mm_vmscan_reclaim_wait(timeout, jiffies - start, mz);
+
+	return ret;
+}
+
+void reclaim_rotated(struct page *page)
+{
+	wait_queue_head_t *wqh = &NODE_DATA(page_to_nid(page))->reclaim_wait;
+
+	if (waitqueue_active(wqh))
+		wake_up(wqh);
+}
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
@@ -1524,6 +1701,7 @@ shrink_inactive_list(unsigned long nr_to
 	unsigned long nr_file;
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_pgreclaim = 0;
 	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
 	struct zone *zone = mz->zone;
 
@@ -1574,13 +1752,13 @@ shrink_inactive_list(unsigned long nr_to
 	spin_unlock_irq(&zone->lru_lock);
 
 	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
-						&nr_dirty, &nr_writeback);
+				&nr_dirty, &nr_writeback, &nr_pgreclaim);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
 		nr_reclaimed += shrink_page_list(&page_list, mz, sc,
-					priority, &nr_dirty, &nr_writeback);
+			priority, &nr_dirty, &nr_writeback, &nr_pgreclaim);
 	}
 
 	spin_lock_irq(&zone->lru_lock);
@@ -1623,6 +1801,15 @@ shrink_inactive_list(unsigned long nr_to
 	 */
 	if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+	/*
+	 * If reclaimed any pages, it's safe from busy scanning. Otherwise when
+	 * encountered PG_reclaim pages or writeback work queue congested,
+	 * consider I/O throttling. Try to throttle only the dirtier tasks by
+	 * honouring higher throttle thresholds to kswapd and other clean tasks.
+	 */
+	if (!nr_reclaimed && nr_pgreclaim &&
+	    should_throttle_dirty(mz, sc, priority))
+		reclaim_wait(mz, HZ/10);
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
--- linux.orig/include/trace/events/vmscan.h	2012-02-28 20:50:01.831765352 +0800
+++ linux/include/trace/events/vmscan.h	2012-02-28 20:50:06.415765461 +0800
@@ -25,6 +25,12 @@
 		{RECLAIM_WB_ASYNC,	"RECLAIM_WB_ASYNC"}	\
 		) : "RECLAIM_WB_NONE"
 
+#define RECLAIM_THROTTLE_TYPE					\
+		{RTT_WRITE,		"write"},		\
+		{RTT_RECENT_WRITE,	"recent_write"},	\
+		{RTT_KSWAPD,		"kswapd"},		\
+		{RTT_CLEAN,		"clean"}		\
+
 #define trace_reclaim_flags(page, sync) ( \
 	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
 	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
@@ -477,6 +483,68 @@ TRACE_EVENT_CONDITION(update_swap_token_
 		  __entry->swap_token_mm, __entry->swap_token_prio)
 );
 
+TRACE_EVENT(mm_vmscan_should_throttle_dirty,
+
+	TP_PROTO(int type, int priority, int dirty_level, bool wait),
+
+	TP_ARGS(type, priority, dirty_level, wait),
+
+	TP_STRUCT__entry(
+		__field(int, type)
+		__field(int, priority)
+		__field(int, dirty_level)
+		__field(bool, wait)
+	),
+
+	TP_fast_assign(
+		__entry->type = type;
+		__entry->priority = priority;
+		__entry->dirty_level = dirty_level;
+		__entry->wait = wait;
+	),
+
+	TP_printk("type=%s priority=%d dirty_level=%d wait=%d",
+		__print_symbolic(__entry->type, RECLAIM_THROTTLE_TYPE),
+		__entry->priority,
+		__entry->dirty_level,
+		__entry->wait)
+);
+
+struct mem_cgroup_zone;
+
+TRACE_EVENT(mm_vmscan_reclaim_wait,
+
+	TP_PROTO(unsigned long timeout,
+		 unsigned long delayed,
+		 struct mem_cgroup_zone *mz),
+
+	TP_ARGS(timeout, delayed, mz),
+
+	TP_STRUCT__entry(
+		__field(	unsigned int,	usec_timeout	)
+		__field(	unsigned int,	usec_delayed	)
+		__field(	unsigned int,	memcg		)
+		__field(	unsigned int,	node		)
+		__field(	unsigned int,	zone		)
+	),
+
+	TP_fast_assign(
+		__entry->usec_timeout	= jiffies_to_usecs(timeout);
+		__entry->usec_delayed	= jiffies_to_usecs(delayed);
+		__entry->memcg	= !mz->mem_cgroup ? 0 :
+					css_id(mem_cgroup_css(mz->mem_cgroup));
+		__entry->node	= zone_to_nid(mz->zone);
+		__entry->zone	= zone_idx(mz->zone);
+	),
+
+	TP_printk("usec_timeout=%u usec_delayed=%u memcg=%u node=%u zone=%u",
+			__entry->usec_timeout,
+			__entry->usec_delayed,
+			__entry->memcg,
+			__entry->node,
+			__entry->zone)
+);
+
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
--- linux.orig/include/linux/sched.h	2012-02-28 20:50:01.839765352 +0800
+++ linux/include/linux/sched.h	2012-02-28 20:50:06.415765461 +0800
@@ -1544,6 +1544,7 @@ struct task_struct {
 	 */
 	int nr_dirtied;
 	int nr_dirtied_pause;
+	int nr_dirtied_snapshot; /* for detecting recent dirty activities */
 	unsigned long dirty_paused_when; /* start of a write-and-pause period */
 
 #ifdef CONFIG_LATENCYTOP
--- linux.orig/include/linux/mmzone.h	2012-02-28 20:50:01.843765352 +0800
+++ linux/include/linux/mmzone.h	2012-02-28 20:50:06.415765461 +0800
@@ -662,6 +662,7 @@ typedef struct pglist_data {
 					     range, including holes */
 	int node_id;
 	wait_queue_head_t kswapd_wait;
+	wait_queue_head_t reclaim_wait;
 	struct task_struct *kswapd;
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
--- linux.orig/mm/page_alloc.c	2012-02-28 20:50:01.823765351 +0800
+++ linux/mm/page_alloc.c	2012-02-28 20:50:06.419765461 +0800
@@ -4256,6 +4256,7 @@ static void __paginginit free_area_init_
 	pgdat_resize_init(pgdat);
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
+	init_waitqueue_head(&pgdat->reclaim_wait);
 	pgdat->kswapd_max_order = 0;
 	pgdat_page_cgroup_init(pgdat);
 	
--- linux.orig/mm/internal.h	2012-02-28 20:50:01.807765351 +0800
+++ linux/mm/internal.h	2012-02-28 20:50:06.419765461 +0800
@@ -91,6 +91,8 @@ extern unsigned long highest_memmap_pfn;
 extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
 
+void reclaim_rotated(struct page *page);
+
 /*
  * in mm/page_alloc.c
  */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
