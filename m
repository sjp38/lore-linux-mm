Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 660EA900155
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:26 -0400 (EDT)
Message-Id: <20110904020915.240747479@intel.com>
Date: Sun, 04 Sep 2011 09:53:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/18] writeback: per task dirty rate limit
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=per-task-ratelimit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add two fields to task_struct.

1) account dirtied pages in the individual tasks, for accuracy
2) per-task balance_dirty_pages() call intervals, for flexibility

The balance_dirty_pages() call interval (ie. nr_dirtied_pause) will
scale near-sqrt to the safety gap between dirty pages and threshold.

The main problem of per-task nr_dirtied is, if 1k+ tasks start dirtying
pages at exactly the same time, each task will be assigned a large
initial nr_dirtied_pause, so that the dirty threshold will be exceeded
long before each task reached its nr_dirtied_pause and hence call
balance_dirty_pages().

The solution is to watch for the number of pages dirtied on each CPU in
between the calls into balance_dirty_pages(). If it exceeds ratelimit_pages
(3% dirty threshold), force call balance_dirty_pages() for a chance to
set bdi->dirty_exceeded. In normal situations, this safeguarding
condition is not expected to trigger at all.

peter: keep the per-CPU ratelimit for safeguarding the 1k+ tasks case

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: Andrea Righi <andrea@betterlinux.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/sched.h |    7 +++
 kernel/fork.c         |    3 +
 mm/page-writeback.c   |   89 ++++++++++++++++++++++------------------
 3 files changed, 60 insertions(+), 39 deletions(-)

--- linux-next.orig/include/linux/sched.h	2011-08-29 19:07:56.000000000 +0800
+++ linux-next/include/linux/sched.h	2011-08-29 19:08:19.000000000 +0800
@@ -1521,6 +1521,13 @@ struct task_struct {
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
--- linux-next.orig/mm/page-writeback.c	2011-08-29 19:08:05.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-29 19:08:19.000000000 +0800
@@ -54,20 +54,6 @@
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
@@ -229,6 +215,8 @@ static void update_completion_period(voi
 	int shift = calc_period_shift();
 	prop_change_shift(&vm_completions, shift);
 	prop_change_shift(&vm_dirties, shift);
+
+	writeback_set_ratelimit();
 }
 
 int dirty_background_ratio_handler(struct ctl_table *table, int write,
@@ -982,6 +970,23 @@ static void bdi_update_bandwidth(struct 
 }
 
 /*
+ * After a task dirtied this many pages, balance_dirty_pages_ratelimited_nr()
+ * will look to see if it needs to start dirty throttling.
+ *
+ * If dirty_poll_interval is too low, big NUMA machines will call the expensive
+ * global_page_state() too often. So scale it near-sqrt to the safety margin
+ * (the number of pages we may dirty without exceeding the dirty limits).
+ */
+static unsigned long dirty_poll_interval(unsigned long dirty,
+					 unsigned long thresh)
+{
+	if (thresh > dirty)
+		return 1UL << (ilog2(thresh - dirty) >> 1);
+
+	return 1;
+}
+
+/*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
@@ -1113,6 +1118,9 @@ static void balance_dirty_pages(struct a
 	if (clear_dirty_exceeded && bdi->dirty_exceeded)
 		bdi->dirty_exceeded = 0;
 
+	current->nr_dirtied = 0;
+	current->nr_dirtied_pause = dirty_poll_interval(nr_dirty, dirty_thresh);
+
 	if (writeback_in_progress(bdi))
 		return;
 
@@ -1139,7 +1147,7 @@ void set_page_dirty_balance(struct page 
 	}
 }
 
-static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
+static DEFINE_PER_CPU(int, bdp_ratelimits);
 
 /**
  * balance_dirty_pages_ratelimited_nr - balance dirty memory state
@@ -1159,31 +1167,39 @@ void balance_dirty_pages_ratelimited_nr(
 					unsigned long nr_pages_dirtied)
 {
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
-	unsigned long ratelimit;
-	unsigned long *p;
+	int ratelimit;
+	int *p;
 
 	if (!bdi_cap_account_dirty(bdi))
 		return;
 
-	ratelimit = ratelimit_pages;
-	if (mapping->backing_dev_info->dirty_exceeded)
-		ratelimit = 8;
+	ratelimit = current->nr_dirtied_pause;
+	if (bdi->dirty_exceeded)
+		ratelimit = min(ratelimit, 32 >> (PAGE_SHIFT - 10));
+
+	current->nr_dirtied += nr_pages_dirtied;
 
+	preempt_disable();
 	/*
-	 * Check the rate limiting. Also, we do not want to throttle real-time
-	 * tasks in balance_dirty_pages(). Period.
+	 * This prevents one CPU to accumulate too many dirtied pages without
+	 * calling into balance_dirty_pages(), which can happen when there are
+	 * 1000+ tasks, all of them start dirtying pages at exactly the same
+	 * time, hence all honoured too large initial task->nr_dirtied_pause.
 	 */
-	preempt_disable();
 	p =  &__get_cpu_var(bdp_ratelimits);
-	*p += nr_pages_dirtied;
-	if (unlikely(*p >= ratelimit)) {
-		ratelimit = sync_writeback_pages(*p);
+	if (unlikely(current->nr_dirtied >= ratelimit))
 		*p = 0;
-		preempt_enable();
-		balance_dirty_pages(mapping, ratelimit);
-		return;
+	else {
+		*p += nr_pages_dirtied;
+		if (unlikely(*p >= ratelimit_pages)) {
+			*p = 0;
+			ratelimit = 0;
+		}
 	}
 	preempt_enable();
+
+	if (unlikely(current->nr_dirtied >= ratelimit))
+		balance_dirty_pages(mapping, current->nr_dirtied);
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
@@ -1278,22 +1294,17 @@ void laptop_sync_completion(void)
  *
  * Here we set ratelimit_pages to a level which ensures that when all CPUs are
  * dirtying in parallel, we cannot go more than 3% (1/32) over the dirty memory
- * thresholds before writeback cuts in.
- *
- * But the limit should not be set too high.  Because it also controls the
- * amount of memory which the balance_dirty_pages() caller has to write back.
- * If this is too large then the caller will block on the IO queue all the
- * time.  So limit it to four megabytes - the balance_dirty_pages() caller
- * will write six megabyte chunks, max.
+ * thresholds.
  */
 
 void writeback_set_ratelimit(void)
 {
-	ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
+	unsigned long background_thresh;
+	unsigned long dirty_thresh;
+	global_dirty_limits(&background_thresh, &dirty_thresh);
+	ratelimit_pages = dirty_thresh / (num_online_cpus() * 32);
 	if (ratelimit_pages < 16)
 		ratelimit_pages = 16;
-	if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
-		ratelimit_pages = (4096 * 1024) / PAGE_CACHE_SIZE;
 }
 
 static int __cpuinit
--- linux-next.orig/kernel/fork.c	2011-08-29 19:07:56.000000000 +0800
+++ linux-next/kernel/fork.c	2011-08-29 19:08:19.000000000 +0800
@@ -1329,6 +1329,9 @@ static struct task_struct *copy_process(
 	p->pdeath_signal = 0;
 	p->exit_state = 0;
 
+	p->nr_dirtied = 0;
+	p->nr_dirtied_pause = 128 >> (PAGE_SHIFT - 10);
+
 	/*
 	 * Ok, make it visible to the rest of the system.
 	 * We dont wake it up yet.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
