Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 421AE8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 17:31:30 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 5/5] mm: Autotune interval between distribution of page completions
Date: Tue,  8 Mar 2011 23:31:15 +0100
Message-Id: <1299623475-5512-6-git-send-email-jack@suse.cz>
In-Reply-To: <1299623475-5512-1-git-send-email-jack@suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

To avoid throttling processes in balance_dirty_pages() for too long, it
is desirable to distribute page completions often enough. On the other
hand we do not want to distribute them too often so that we do not burn
too much CPU. Obviously, the proper interval depends on the amount of
pages we wait for and on the speed the underlying device can write them.
So we estimate the throughput of the device, compute the number of
pages we need to be completed, and from that compute desired time of
next distribution of page completions. To avoid extremities, we force
the computed sleep time to be in [HZ/50..HZ/4] interval.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>
CC: Dave Chinner <david@fromorbit.com>
CC: Wu Fengguang <fengguang.wu@intel.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev.h      |    6 ++-
 include/trace/events/writeback.h |   25 ++++++++++
 mm/backing-dev.c                 |    2 +
 mm/page-writeback.c              |   90 ++++++++++++++++++++++++++++++++-----
 4 files changed, 108 insertions(+), 15 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 65b6e61..a4f9133 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -89,12 +89,14 @@ struct backing_dev_info {
 
 	struct timer_list laptop_mode_wb_timer;
 
-	spinlock_t balance_lock;	/* lock protecting four entries below */
-	unsigned long written_start;	/* BDI_WRITTEN last time we scanned balance_list*/
+	spinlock_t balance_lock;	/* lock protecting entries below */
 	struct list_head balance_list;	/* waiters in balance_dirty_pages */
 	unsigned int balance_waiters;	/* number of waiters in the list */
 	struct delayed_work balance_work;	/* work distributing page
 						   completions among waiters */
+	unsigned long written_start;	/* BDI_WRITTEN last time we scanned balance_list*/
+	unsigned long start_jiffies;	/* time when we last scanned list */
+	unsigned long pages_per_s;	/* estimated throughput of bdi */
 
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *debug_dir;
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 74815fa..00b06a2 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -211,6 +211,31 @@ TRACE_EVENT(writeback_distribute_page_completions_wakeall,
 	)
 );
 
+TRACE_EVENT(writeback_distribute_page_completions_scheduled,
+	TP_PROTO(struct backing_dev_info *bdi, unsigned long nap,
+		 unsigned long pages),
+	TP_ARGS(bdi, nap, pages),
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long, nap)
+		__field(unsigned long, pages)
+		__field(unsigned long, waiters)
+		__field(unsigned long, pages_per_s)
+	),
+	TP_fast_assign(
+		strncpy(__entry->name, dev_name(bdi->dev), 32);
+		__entry->nap = nap;
+		__entry->pages = pages;
+		__entry->waiters = bdi->balance_waiters;
+		__entry->pages_per_s = bdi->pages_per_s;
+	),
+	TP_printk("bdi=%s sleep=%u ms want_pages=%lu waiters=%lu"
+		  " pages_per_s=%lu",
+		  __entry->name, jiffies_to_msecs(__entry->nap),
+		  __entry->pages, __entry->waiters, __entry->pages_per_s
+	)
+);
+
 DECLARE_EVENT_CLASS(writeback_congest_waited_template,
 
 	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 2ecc3fe..e2cbe5c 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -655,8 +655,10 @@ int bdi_init(struct backing_dev_info *bdi)
 	spin_lock_init(&bdi->balance_lock);
 	INIT_LIST_HEAD(&bdi->balance_list);
 	bdi->written_start = 0;
+	bdi->start_jiffies = 0;
 	bdi->balance_waiters = 0;
 	INIT_DELAYED_WORK(&bdi->balance_work, distribute_page_completions);
+	bdi->pages_per_s = 1;
 
 	bdi_wb_init(&bdi->wb, bdi);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ff07280..09f1adf 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -597,12 +597,65 @@ static void balance_waiter_done(struct backing_dev_info *bdi,
 	wake_up_process(bw->bw_task);
 }
 
+static unsigned long compute_distribute_time(struct backing_dev_info *bdi,
+					     unsigned long min_pages)
+{
+	unsigned long nap;
+
+	/*
+	 * Because of round robin distribution, every waiter has to get at
+	 * least min_pages pages.
+	 */
+	min_pages *= bdi->balance_waiters;
+	nap = msecs_to_jiffies(
+			((u64)min_pages) * MSEC_PER_SEC / bdi->pages_per_s);
+	/*
+	 * Force computed sleep time to be in interval (HZ/50..HZ/5)
+	 * so that we
+	 * a) don't wake too often and burn too much CPU
+	 * b) check dirty limits at least once in a while
+	 */
+	nap = max_t(unsigned long, HZ/50, nap);
+	nap = min_t(unsigned long, HZ/4, nap);
+	trace_writeback_distribute_page_completions_scheduled(bdi, nap,
+		min_pages);
+	return nap;
+}
+
+/*
+ * When the throughput is computed, we consider an imaginary WINDOW_MS
+ * miliseconds long window. In this window, we know that it took 'deltams'
+ * miliseconds to write 'written' pages and for the rest of the window we
+ * assume number of pages corresponding to the throughput we previously
+ * computed to have been written. Thus we obtain total number of pages
+ * written in the imaginary window and from it new throughput.
+ */
+#define WINDOW_MS 10000
+
+static void update_bdi_throughput(struct backing_dev_info *bdi,
+				 unsigned long written, unsigned long time)
+{
+	unsigned int deltams = jiffies_to_msecs(time - bdi->start_jiffies);
+
+	written -= bdi->written_start;
+	if (deltams > WINDOW_MS) {
+		/* Add 1 to avoid 0 result */
+		bdi->pages_per_s = 1 + ((u64)written) * MSEC_PER_SEC / deltams;
+		return;
+	}
+	bdi->pages_per_s = 1 +
+		(((u64)bdi->pages_per_s) * (WINDOW_MS - deltams) +
+		 ((u64)written) * MSEC_PER_SEC) / WINDOW_MS;
+}
+
 void distribute_page_completions(struct work_struct *work)
 {
 	struct backing_dev_info *bdi =
 		container_of(work, struct backing_dev_info, balance_work.work);
 	unsigned long written = bdi_stat_sum(bdi, BDI_WRITTEN);
 	unsigned long pages_per_waiter;
+	unsigned long cur_time = jiffies;
+	unsigned long min_pages = ULONG_MAX;
 	struct balance_waiter *waiter, *tmpw;
 	struct dirty_limit_state st;
 	int dirty_exceeded;
@@ -616,11 +669,14 @@ void distribute_page_completions(struct work_struct *work)
 		list_for_each_entry_safe(
 				waiter, tmpw, &bdi->balance_list, bw_list)
 			balance_waiter_done(bdi, waiter);
+		update_bdi_throughput(bdi, written, cur_time);
 		spin_unlock(&bdi->balance_lock);
 		return;
 	}
 
 	spin_lock(&bdi->balance_lock);
+	update_bdi_throughput(bdi, written, cur_time);
+	bdi->start_jiffies = cur_time;
 	/* Distribute pages equally among waiters */
 	while (!list_empty(&bdi->balance_list)) {
 		pages_per_waiter = (written - bdi->written_start) /
@@ -638,15 +694,22 @@ void distribute_page_completions(struct work_struct *work)
 				balance_waiter_done(bdi, waiter);
 		}
 	}
-	/* Wake tasks that might have gotten below their limits */
+	/*
+	 * Wake tasks that might have gotten below their limits and compute
+	 * the number of pages we wait for
+	 */
 	list_for_each_entry_safe(waiter, tmpw, &bdi->balance_list, bw_list) {
 		if (dirty_exceeded == DIRTY_MAY_EXCEED_LIMIT &&
-		     !bdi_task_limit_exceeded(&st, waiter->bw_task))
+		    !bdi_task_limit_exceeded(&st, waiter->bw_task))
 			balance_waiter_done(bdi, waiter);
+		else if (waiter->bw_wait_pages < min_pages)
+			min_pages = waiter->bw_wait_pages;
 	}
 	/* More page completions needed? */
-	if (!list_empty(&bdi->balance_list))
-		schedule_delayed_work(&bdi->balance_work, HZ/10);
+	if (!list_empty(&bdi->balance_list)) {
+		schedule_delayed_work(&bdi->balance_work,
+			      compute_distribute_time(bdi, min_pages));
+	}
 	spin_unlock(&bdi->balance_lock);
 }
 
@@ -696,21 +759,22 @@ static void balance_dirty_pages(struct address_space *mapping,
 	bw.bw_task = current;
 	spin_lock(&bdi->balance_lock);
 	/*
-	 * First item? Need to schedule distribution of IO completions among
-	 * items on balance_list
-	 */
-	if (list_empty(&bdi->balance_list)) {
-		bdi->written_start = bdi_stat_sum(bdi, BDI_WRITTEN);
-		/* FIXME: Delay should be autotuned based on dev throughput */
-		schedule_delayed_work(&bdi->balance_work, HZ/10);
-	}
-	/*
 	 * Add work to the balance list, from now on the structure is handled
 	 * by distribute_page_completions()
 	 */
 	list_add_tail(&bw.bw_list, &bdi->balance_list);
 	bdi->balance_waiters++;
 	/*
+	 * First item? Need to schedule distribution of IO completions among
+	 * items on balance_list
+	 */
+	if (bdi->balance_waiters == 1) {
+		bdi->written_start = bdi_stat_sum(bdi, BDI_WRITTEN);
+		bdi->start_jiffies = jiffies;
+		schedule_delayed_work(&bdi->balance_work,
+			compute_distribute_time(bdi, write_chunk));
+	}
+	/*
 	 * Setting task state must happen inside balance_lock to avoid races
 	 * with distribution function waking us.
 	 */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
