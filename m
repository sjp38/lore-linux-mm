From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/35] writeback: per-task rate limit on balance_dirty_pages()
Date: Mon, 13 Dec 2010 22:46:53 +0800
Message-ID: <20101213150327.215545584@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-per-task-dirty-count.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Try to limit the dirty throttle pause time in range [1 jiffy, 100 ms],
by controlling how many pages can be dirtied before inserting a pause.

The dirty count will be directly billed to the task struct. Slow start
and quick back off is employed, so that the stable range will be biased
towards less than 50ms. Another intention is for fine timing control of
slow devices, which may need to do full 100ms pauses for every 1 page.

The switch from per-cpu to per-task rate limit makes it easier to exceed
the global dirty limit with a fork bomb, where each new task dirties 1 page,
sleep 10m and continue to dirty 1000 more pages. The caveat is, when it
dirties the first page, it may be honoured a high nr_dirtied_pause
because nr_dirty is still low at that time. In this way lots of tasks
get the free tickets to dirty more pages than allowed. The solution is
to disable rate limiting (ie. to ignore nr_dirtied_pause) totally once
the bdi becomes dirty exceeded.

Note that some filesystems will dirty a batch of pages before calling
balance_dirty_pages_ratelimited_nr(). They saves a little CPU overheads
at the cost of possibly overrunning the dirty limits a bit and/or in the
case of very slow devices, pause the application for much more than
100ms at a time. This is a trade-off, and seems reasonable optimization
as long as the batch size is controlled within a dozen pages.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/sched.h |    7 ++
 mm/memory_hotplug.c   |    3 
 mm/page-writeback.c   |  126 ++++++++++++++++++----------------------
 3 files changed, 65 insertions(+), 71 deletions(-)

--- linux-next.orig/include/linux/sched.h	2010-12-13 21:45:57.000000000 +0800
+++ linux-next/include/linux/sched.h	2010-12-13 21:46:13.000000000 +0800
@@ -1471,6 +1471,13 @@ struct task_struct {
 	int make_it_fail;
 #endif
 	struct prop_local_single dirties;
+	/*
+	 * when (nr_dirtied >= nr_dirtied_pause), it's time to call
+	 * balance_dirty_pages() for some dirty throttling pause
+	 */
+	int nr_dirtied;
+	int nr_dirtied_pause;
+
 #ifdef CONFIG_LATENCYTOP
 	int latency_record_count;
 	struct latency_record latency_record[LT_SAVECOUNT];
--- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:12.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-13 21:46:13.000000000 +0800
@@ -37,12 +37,6 @@
 #include <trace/events/writeback.h>
 
 /*
- * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
- * will look to see if it needs to force writeback or throttling.
- */
-static long ratelimit_pages = 32;
-
-/*
  * Don't sleep more than 200ms at a time in balance_dirty_pages().
  */
 #define MAX_PAUSE	max(HZ/5, 1)
@@ -493,6 +487,40 @@ unsigned long bdi_dirty_limit(struct bac
 }
 
 /*
+ * After a task dirtied this many pages, balance_dirty_pages_ratelimited_nr()
+ * will look to see if it needs to start dirty throttling.
+ *
+ * If ratelimit_pages is too low then big NUMA machines will call the expensive
+ * global_page_state() too often. So scale it adaptively to the safety margin
+ * (the number of pages we may dirty without exceeding the dirty limits).
+ */
+static unsigned long ratelimit_pages(struct backing_dev_info *bdi)
+{
+	unsigned long background_thresh;
+	unsigned long dirty_thresh;
+	unsigned long dirty_pages;
+
+	global_dirty_limits(&background_thresh, &dirty_thresh);
+	dirty_pages = global_page_state(NR_FILE_DIRTY) +
+		      global_page_state(NR_WRITEBACK) +
+		      global_page_state(NR_UNSTABLE_NFS);
+
+	if (dirty_pages <= (dirty_thresh + background_thresh) / 2)
+		goto out;
+
+	dirty_thresh = bdi_dirty_limit(bdi, dirty_thresh, dirty_pages);
+	dirty_pages  = bdi_stat(bdi, BDI_RECLAIMABLE) +
+		       bdi_stat(bdi, BDI_WRITEBACK);
+
+	if (dirty_pages < dirty_thresh)
+		goto out;
+
+	return 1;
+out:
+	return 1 + int_sqrt(dirty_thresh - dirty_pages);
+}
+
+/*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
@@ -509,7 +537,7 @@ static void balance_dirty_pages(struct a
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
 	unsigned long bw;
-	unsigned long pause;
+	unsigned long pause = 0;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
@@ -591,6 +619,17 @@ pause:
 	if (!dirty_exceeded && bdi->dirty_exceeded)
 		bdi->dirty_exceeded = 0;
 
+	if (pause == 0 && nr_dirty < background_thresh)
+		current->nr_dirtied_pause = ratelimit_pages(bdi);
+	else if (pause == 1)
+		current->nr_dirtied_pause += current->nr_dirtied_pause / 32 + 1;
+	else if (pause >= MAX_PAUSE)
+		/*
+		 * when repeated, writing 1 page per 100ms on slow devices,
+		 * i-(i+2)/4 will be able to reach 1 but never reduce to 0.
+		 */
+		current->nr_dirtied_pause -= (current->nr_dirtied_pause+2) >> 2;
+
 	if (writeback_in_progress(bdi))
 		return;
 
@@ -617,8 +656,6 @@ void set_page_dirty_balance(struct page 
 	}
 }
 
-static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
-
 /**
  * balance_dirty_pages_ratelimited_nr - balance dirty memory state
  * @mapping: address_space which was dirtied
@@ -628,36 +665,30 @@ static DEFINE_PER_CPU(unsigned long, bdp
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
+	current->nr_dirtied += nr_pages_dirtied;
 
-	ratelimit = ratelimit_pages;
-	if (mapping->backing_dev_info->dirty_exceeded)
-		ratelimit = 8;
+	if (unlikely(!current->nr_dirtied_pause))
+		current->nr_dirtied_pause = ratelimit_pages(bdi);
 
 	/*
 	 * Check the rate limiting. Also, we do not want to throttle real-time
 	 * tasks in balance_dirty_pages(). Period.
 	 */
-	preempt_disable();
-	p =  &__get_cpu_var(bdp_ratelimits);
-	*p += nr_pages_dirtied;
-	if (unlikely(*p >= ratelimit)) {
-		ratelimit = *p;
-		*p = 0;
-		preempt_enable();
-		balance_dirty_pages(mapping, ratelimit);
-		return;
+	if (unlikely(current->nr_dirtied >= current->nr_dirtied_pause ||
+		     bdi->dirty_exceeded)) {
+		balance_dirty_pages(mapping, current->nr_dirtied);
+		current->nr_dirtied = 0;
 	}
-	preempt_enable();
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
@@ -745,44 +776,6 @@ void laptop_sync_completion(void)
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
@@ -804,9 +797,6 @@ void __init page_writeback_init(void)
 {
 	int shift;
 
-	writeback_set_ratelimit();
-	register_cpu_notifier(&ratelimit_nb);
-
 	shift = calc_period_shift();
 	prop_descriptor_init(&vm_completions, shift);
 	prop_descriptor_init(&vm_dirties, shift);
--- linux-next.orig/mm/memory_hotplug.c	2010-12-13 21:45:57.000000000 +0800
+++ linux-next/mm/memory_hotplug.c	2010-12-13 21:46:13.000000000 +0800
@@ -446,8 +446,6 @@ int online_pages(unsigned long pfn, unsi
 
 	vm_total_pages = nr_free_pagecache_pages();
 
-	writeback_set_ratelimit();
-
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
 
@@ -877,7 +875,6 @@ repeat:
 	}
 
 	vm_total_pages = nr_free_pagecache_pages();
-	writeback_set_ratelimit();
 
 	memory_notify(MEM_OFFLINE, &arg);
 	unlock_system_sleep();
