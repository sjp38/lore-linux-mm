Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 46D788D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 20:39:22 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
Date: Fri,  4 Feb 2011 02:38:52 +0100
Message-Id: <1296783534-11585-4-git-send-email-jack@suse.cz>
In-Reply-To: <1296783534-11585-1-git-send-email-jack@suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

This patch changes balance_dirty_pages() throttling so that the function does
not submit writes on its own but rather waits for flusher thread to do enough
writes. This has an advantage that we have a single source of IO allowing for
better writeback locality. Also we do not have to reenter filesystems from a
non-trivial context.

The waiting is implemented as follows: Whenever we decide to throttle a task in
balance_dirty_pages(), task adds itself to a list of tasks that are throttled
against that bdi and goes to sleep waiting to receive specified amount of page
IO completions. Once in a while (currently HZ/10, later the interval should be
autotuned based on observed IO completion rate), accumulated page IO
completions are distributed equally among waiting tasks.

This waiting scheme has been chosen so that waiting time in
balance_dirty_pages() is proportional to
  number_waited_pages * number_of_waiters.
In particular it does not depend on the total number of pages being waited for,
thus providing possibly a fairer results. Note that the dependency on the
number of waiters is inevitable, since all the waiters compete for a common
resource so their number has to be somehow reflected in waiting time.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>
CC: Dave Chinner <david@fromorbit.com>
CC: Wu Fengguang <fengguang.wu@intel.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev.h      |    7 +
 include/linux/writeback.h        |    1 +
 include/trace/events/writeback.h |   66 +++++++-
 mm/backing-dev.c                 |    8 +
 mm/page-writeback.c              |  361 ++++++++++++++++++++++++++------------
 5 files changed, 327 insertions(+), 116 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 63ab4a5..65b6e61 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -89,6 +89,13 @@ struct backing_dev_info {
 
 	struct timer_list laptop_mode_wb_timer;
 
+	spinlock_t balance_lock;	/* lock protecting four entries below */
+	unsigned long written_start;	/* BDI_WRITTEN last time we scanned balance_list*/
+	struct list_head balance_list;	/* waiters in balance_dirty_pages */
+	unsigned int balance_waiters;	/* number of waiters in the list */
+	struct delayed_work balance_work;	/* work distributing page
+						   completions among waiters */
+
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *debug_dir;
 	struct dentry *debug_stats;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 0ead399..901c33f 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -129,6 +129,7 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
 			       unsigned long dirty);
 
 void page_writeback_init(void);
+void distribute_page_completions(struct work_struct *work);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 					unsigned long nr_pages_dirtied);
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 4e249b9..cf9f458 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -147,11 +147,71 @@ DEFINE_EVENT(wbc_class, name, \
 DEFINE_WBC_EVENT(wbc_writeback_start);
 DEFINE_WBC_EVENT(wbc_writeback_written);
 DEFINE_WBC_EVENT(wbc_writeback_wait);
-DEFINE_WBC_EVENT(wbc_balance_dirty_start);
-DEFINE_WBC_EVENT(wbc_balance_dirty_written);
-DEFINE_WBC_EVENT(wbc_balance_dirty_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+TRACE_EVENT(writeback_balance_dirty_pages_waiting,
+	TP_PROTO(struct backing_dev_info *bdi, unsigned long pages),
+	TP_ARGS(bdi, pages),
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long, pages)
+	),
+	TP_fast_assign(
+		strncpy(__entry->name, dev_name(bdi->dev), 32);
+		__entry->pages = pages;
+	),
+	TP_printk("bdi=%s, pages=%lu",
+		  __entry->name, __entry->pages
+	)
+);
+
+TRACE_EVENT(writeback_balance_dirty_pages_woken,
+	TP_PROTO(struct backing_dev_info *bdi),
+	TP_ARGS(bdi),
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+	),
+	TP_fast_assign(
+		strncpy(__entry->name, dev_name(bdi->dev), 32);
+	),
+	TP_printk("bdi=%s",
+		  __entry->name
+	)
+);
+
+TRACE_EVENT(writeback_distribute_page_completions,
+	TP_PROTO(struct backing_dev_info *bdi, unsigned long start,
+		 unsigned long written),
+	TP_ARGS(bdi, start, written),
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long, start)
+		__field(unsigned long, written)
+	),
+	TP_fast_assign(
+		strncpy(__entry->name, dev_name(bdi->dev), 32);
+		__entry->start = start;
+		__entry->written = written;
+	),
+	TP_printk("bdi=%s, written_start=%lu, to_distribute=%lu",
+		  __entry->name, __entry->start, __entry->written
+	)
+);
+
+TRACE_EVENT(writeback_distribute_page_completions_wakeall,
+	TP_PROTO(struct backing_dev_info *bdi),
+	TP_ARGS(bdi),
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+	),
+	TP_fast_assign(
+		strncpy(__entry->name, dev_name(bdi->dev), 32);
+	),
+	TP_printk("bdi=%s",
+		  __entry->name
+	)
+);
+
 DECLARE_EVENT_CLASS(writeback_congest_waited_template,
 
 	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 4d14072..2ecc3fe 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -652,6 +652,12 @@ int bdi_init(struct backing_dev_info *bdi)
 	INIT_LIST_HEAD(&bdi->bdi_list);
 	INIT_LIST_HEAD(&bdi->work_list);
 
+	spin_lock_init(&bdi->balance_lock);
+	INIT_LIST_HEAD(&bdi->balance_list);
+	bdi->written_start = 0;
+	bdi->balance_waiters = 0;
+	INIT_DELAYED_WORK(&bdi->balance_work, distribute_page_completions);
+
 	bdi_wb_init(&bdi->wb, bdi);
 
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++) {
@@ -691,6 +697,8 @@ void bdi_destroy(struct backing_dev_info *bdi)
 		spin_unlock(&inode_lock);
 	}
 
+	cancel_delayed_work_sync(&bdi->balance_work);
+	WARN_ON(!list_empty(&bdi->balance_list));
 	bdi_unregister(bdi);
 
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f388f70..8533032 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -132,6 +132,17 @@ static struct prop_descriptor vm_completions;
 static struct prop_descriptor vm_dirties;
 
 /*
+ * Item a process queues to bdi list in balance_dirty_pages() when it gets
+ * throttled
+ */
+struct balance_waiter {
+	struct list_head bw_list;
+	unsigned long bw_to_write;	/* Number of pages to wait for to
+					   get written */
+	struct task_struct *bw_task;	/* Task waiting for IO */
+};
+
+/*
  * couple the period to the dirty_ratio:
  *
  *   period/2 ~ roundup_pow_of_two(dirty limit)
@@ -476,140 +487,264 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
 	return bdi_dirty;
 }
 
-/*
- * balance_dirty_pages() must be called by processes which are generating dirty
- * data.  It looks at the number of dirty pages in the machine and will force
- * the caller to perform writeback if the system is over `vm_dirty_ratio'.
- * If we're over `background_thresh' then the writeback threads are woken to
- * perform some writeout.
- */
-static void balance_dirty_pages(struct address_space *mapping,
-				unsigned long write_chunk)
-{
-	long nr_reclaimable, bdi_nr_reclaimable;
-	long nr_writeback, bdi_nr_writeback;
+struct dirty_limit_state {
+	long nr_reclaimable;
+	long nr_writeback;
+	long bdi_nr_reclaimable;
+	long bdi_nr_writeback;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
-	unsigned long min_bdi_thresh = ULONG_MAX;
-	unsigned long pages_written = 0;
-	unsigned long pause = 1;
-	bool dirty_exceeded = false;
-	bool min_dirty_exceeded = false;
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
+};
 
-	for (;;) {
-		struct writeback_control wbc = {
-			.sync_mode	= WB_SYNC_NONE,
-			.older_than_this = NULL,
-			.nr_to_write	= write_chunk,
-			.range_cyclic	= 1,
-		};
+static void get_global_dirty_limit_state(struct dirty_limit_state *st)
+{
+	/*
+	 * Note: nr_reclaimable denotes nr_dirty + nr_unstable.  Unstable
+	 * writes are a feature of certain networked filesystems (i.e. NFS) in
+	 * which data may have been written to the server's write cache, but
+	 * has not yet been flushed to permanent storage.
+	 */
+	st->nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
+				global_page_state(NR_UNSTABLE_NFS);
+	st->nr_writeback = global_page_state(NR_WRITEBACK);
 
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
+	global_dirty_limits(&st->background_thresh, &st->dirty_thresh);
+}
 
-		global_dirty_limits(&background_thresh, &dirty_thresh);
+/* This function expects global state to be already filled in! */
+static void get_bdi_dirty_limit_state(struct backing_dev_info *bdi,
+				      struct dirty_limit_state *st)
+{
+	unsigned long min_bdi_thresh;
 
-		/*
-		 * Throttle it only when the background writeback cannot
-		 * catch-up. This avoids (excessively) small writeouts
-		 * when the bdi limits are ramping up.
-		 */
-		if (nr_reclaimable + nr_writeback <=
-				(background_thresh + dirty_thresh) / 2)
-			break;
+	st->bdi_thresh = bdi_dirty_limit(bdi, st->dirty_thresh);
+	min_bdi_thresh = task_min_dirty_limit(st->bdi_thresh);
+	/*
+	 * In order to avoid the stacked BDI deadlock we need to ensure we
+	 * accurately count the 'dirty' pages when the threshold is low.
+	 *
+	 * Otherwise it would be possible to get thresh+n pages reported dirty,
+	 * even though there are thresh-m pages actually dirty; with m+n
+	 * sitting in the percpu deltas.
+	 */
+	if (min_bdi_thresh < 2*bdi_stat_error(bdi)) {
+		st->bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
+		st->bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
+	} else {
+		st->bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
+		st->bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
+	}
+}
 
-		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
-		min_bdi_thresh = task_min_dirty_limit(bdi_thresh);
-		bdi_thresh = task_dirty_limit(current, bdi_thresh);
+/* Possibly states of dirty memory for BDI */
+enum {
+	DIRTY_OK,			/* Everything below limit */
+	DIRTY_EXCEED_BACKGROUND,	/* Backround writeback limit exceeded */
+	DIRTY_MAY_EXCEED_LIMIT,		/* Some task may exceed dirty limit */
+	DIRTY_EXCEED_LIMIT,		/* Current task exceeds dirty limit */
+};
 
-		/*
-		 * In order to avoid the stacked BDI deadlock we need
-		 * to ensure we accurately count the 'dirty' pages when
-		 * the threshold is low.
-		 *
-		 * Otherwise it would be possible to get thresh+n pages
-		 * reported dirty, even though there are thresh-m pages
-		 * actually dirty; with m+n sitting in the percpu
-		 * deltas.
-		 */
-		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
-			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
-		} else {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
-		}
+static int check_dirty_limits(struct backing_dev_info *bdi,
+			      struct dirty_limit_state *pst)
+{
+	struct dirty_limit_state st;
+	unsigned long bdi_thresh;
+	unsigned long min_bdi_thresh;
+	int ret = DIRTY_OK;
 
-		/*
-		 * The bdi thresh is somehow "soft" limit derived from the
-		 * global "hard" limit. The former helps to prevent heavy IO
-		 * bdi or process from holding back light ones; The latter is
-		 * the last resort safeguard.
-		 */
-		dirty_exceeded =
-			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
-			|| (nr_reclaimable + nr_writeback > dirty_thresh);
-		min_dirty_exceeded =
-			(bdi_nr_reclaimable + bdi_nr_writeback > min_bdi_thresh)
-			|| (nr_reclaimable + nr_writeback > dirty_thresh);
-
-		if (!dirty_exceeded)
-			break;
+	get_global_dirty_limit_state(&st);
+	/*
+	 * Throttle it only when the background writeback cannot catch-up. This
+	 * avoids (excessively) small writeouts when the bdi limits are ramping
+	 * up.
+	 */
+	if (st.nr_reclaimable + st.nr_writeback <=
+			(st.background_thresh + st.dirty_thresh) / 2)
+		goto out;
 
-		if (!bdi->dirty_exceeded)
-			bdi->dirty_exceeded = 1;
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
+	get_bdi_dirty_limit_state(bdi, &st);
+	min_bdi_thresh = task_min_dirty_limit(st.bdi_thresh);
+	bdi_thresh = task_dirty_limit(current, st.bdi_thresh);
+
+	/*
+	 * The bdi thresh is somehow "soft" limit derived from the global
+	 * "hard" limit. The former helps to prevent heavy IO bdi or process
+	 * from holding back light ones; The latter is the last resort
+	 * safeguard.
+	 */
+	if ((st.bdi_nr_reclaimable + st.bdi_nr_writeback > bdi_thresh)
+	    || (st.nr_reclaimable + st.nr_writeback > st.dirty_thresh)) {
+		ret = DIRTY_EXCEED_LIMIT;
+		goto out;
+	}
+	if (st.bdi_nr_reclaimable + st.bdi_nr_writeback > min_bdi_thresh) {
+		ret = DIRTY_MAY_EXCEED_LIMIT;
+		goto out;
+	}
+	if (st.nr_reclaimable > st.background_thresh)
+		ret = DIRTY_EXCEED_BACKGROUND;
+out:
+	if (pst)
+		*pst = st;
+	return ret;
+}
+
+static bool bdi_task_limit_exceeded(struct dirty_limit_state *st,
+				    struct task_struct *p)
+{
+	unsigned long bdi_thresh;
+
+	bdi_thresh = task_dirty_limit(p, st->bdi_thresh);
+
+	return st->bdi_nr_reclaimable + st->bdi_nr_writeback > bdi_thresh;
+}
+
+static void balance_waiter_done(struct backing_dev_info *bdi,
+				struct balance_waiter *bw)
+{
+	list_del_init(&bw->bw_list);
+	bdi->balance_waiters--;
+	wake_up_process(bw->bw_task);
+}
+
+void distribute_page_completions(struct work_struct *work)
+{
+	struct backing_dev_info *bdi =
+		container_of(work, struct backing_dev_info, balance_work.work);
+	unsigned long written = bdi_stat_sum(bdi, BDI_WRITTEN);
+	unsigned long pages_per_waiter, remainder_pages;
+	struct balance_waiter *waiter, *tmpw;
+	struct dirty_limit_state st;
+	int dirty_exceeded;
+
+	trace_writeback_distribute_page_completions(bdi, bdi->written_start,
+					  written - bdi->written_start);
+	dirty_exceeded = check_dirty_limits(bdi, &st);
+	if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT) {
+		/* Wakeup everybody */
+		trace_writeback_distribute_page_completions_wakeall(bdi);
+		spin_lock(&bdi->balance_lock);
+		list_for_each_entry_safe(
+				waiter, tmpw, &bdi->balance_list, bw_list)
+			balance_waiter_done(bdi, waiter);
+		spin_unlock(&bdi->balance_lock);
+		return;
+	}
+
+	spin_lock(&bdi->balance_lock);
+	/*
+	 * Note: This loop can have quadratic complexity in the number of
+	 * waiters. It can be changed to a linear one if we also maintained a
+	 * list sorted by number of pages. But for now that does not seem to be
+	 * worth the effort.
+	 */
+	remainder_pages = written - bdi->written_start;
+	bdi->written_start = written;
+	while (!list_empty(&bdi->balance_list)) {
+		pages_per_waiter = remainder_pages / bdi->balance_waiters;
+		if (!pages_per_waiter)
+			break;
+		remainder_pages %= bdi->balance_waiters;
+		list_for_each_entry_safe(
+				waiter, tmpw, &bdi->balance_list, bw_list) {
+			if (waiter->bw_to_write <= pages_per_waiter) {
+				remainder_pages += pages_per_waiter -
+						   waiter->bw_to_write;
+				balance_waiter_done(bdi, waiter);
+				continue;
+			}
+			waiter->bw_to_write -= pages_per_waiter;
 		}
-		trace_wbc_balance_dirty_wait(&wbc, bdi);
-		__set_current_state(TASK_UNINTERRUPTIBLE);
-		io_schedule_timeout(pause);
+	}
+	/* Distribute remaining pages */
+	list_for_each_entry_safe(waiter, tmpw, &bdi->balance_list, bw_list) {
+		if (remainder_pages > 0) {
+			waiter->bw_to_write--;
+			remainder_pages--;
+		}
+		if (waiter->bw_to_write == 0 ||
+		    (dirty_exceeded == DIRTY_MAY_EXCEED_LIMIT &&
+		     !bdi_task_limit_exceeded(&st, waiter->bw_task)))
+			balance_waiter_done(bdi, waiter);
+	}
+	/* More page completions needed? */
+	if (!list_empty(&bdi->balance_list))
+		schedule_delayed_work(&bdi->balance_work, HZ/10);
+	spin_unlock(&bdi->balance_lock);
+}
+
+/*
+ * balance_dirty_pages() must be called by processes which are generating dirty
+ * data.  It looks at the number of dirty pages in the machine and will force
+ * the caller to perform writeback if the system is over `vm_dirty_ratio'.
+ * If we're over `background_thresh' then the writeback threads are woken to
+ * perform some writeout.
+ */
+static void balance_dirty_pages(struct address_space *mapping,
+				unsigned long write_chunk)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct balance_waiter bw;
+	int dirty_exceeded = check_dirty_limits(bdi, NULL);
 
+	if (dirty_exceeded != DIRTY_EXCEED_LIMIT) {
+		if (bdi->dirty_exceeded &&
+		    dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT)
+			bdi->dirty_exceeded = 0;
 		/*
-		 * Increase the delay for each loop, up to our previous
-		 * default of taking a 100ms nap.
+		 * In laptop mode, we wait until hitting the higher threshold
+		 * before starting background writeout, and then write out all
+		 * the way down to the lower threshold.  So slow writers cause
+		 * minimal disk activity.
+		 *
+		 * In normal mode, we start background writeout at the lower
+		 * background_thresh, to keep the amount of dirty memory low.
 		 */
-		pause <<= 1;
-		if (pause > HZ / 10)
-			pause = HZ / 10;
+		if (!laptop_mode && dirty_exceeded == DIRTY_EXCEED_BACKGROUND)
+			bdi_start_background_writeback(bdi);
+		return;
 	}
 
-	/* Clear dirty_exceeded flag only when no task can exceed the limit */
-	if (!min_dirty_exceeded && bdi->dirty_exceeded)
-		bdi->dirty_exceeded = 0;
+	if (!bdi->dirty_exceeded)
+		bdi->dirty_exceeded = 1;
 
-	if (writeback_in_progress(bdi))
-		return;
+	trace_writeback_balance_dirty_pages_waiting(bdi, write_chunk);
+	/* Kick flusher thread to start doing work if it isn't already */
+	bdi_start_background_writeback(bdi);
 
+	bw.bw_to_write = write_chunk;
+	bw.bw_task = current;
+	spin_lock(&bdi->balance_lock);
 	/*
-	 * In laptop mode, we wait until hitting the higher threshold before
-	 * starting background writeout, and then write out all the way down
-	 * to the lower threshold.  So slow writers cause minimal disk activity.
-	 *
-	 * In normal mode, we start background writeout at the lower
-	 * background_thresh, to keep the amount of dirty memory low.
+	 * First item? Need to schedule distribution of IO completions among
+	 * items on balance_list
+	 */
+	if (list_empty(&bdi->balance_list)) {
+		bdi->written_start = bdi_stat_sum(bdi, BDI_WRITTEN);
+		/* FIXME: Delay should be autotuned based on dev throughput */
+		schedule_delayed_work(&bdi->balance_work, HZ/10);
+	}
+	/*
+	 * Add work to the balance list, from now on the structure is handled
+	 * by distribute_page_completions()
+	 */
+	list_add_tail(&bw.bw_list, &bdi->balance_list);
+	bdi->balance_waiters++;
+	/*
+	 * Setting task state must happen inside balance_lock to avoid races
+	 * with distribution function waking us.
+	 */
+	__set_current_state(TASK_UNINTERRUPTIBLE);
+	spin_unlock(&bdi->balance_lock);
+	/* Wait for pages to get written */
+	schedule();
+	/*
+	 * Enough page completions should have happened by now and we should
+	 * have been removed from the list
 	 */
-	if ((laptop_mode && pages_written) ||
-	    (!laptop_mode && (nr_reclaimable > background_thresh)))
-		bdi_start_background_writeback(bdi);
+	WARN_ON(!list_empty(&bw.bw_list));
+	trace_writeback_balance_dirty_pages_woken(bdi);
 }
 
 void set_page_dirty_balance(struct page *page, int page_mkwrite)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
