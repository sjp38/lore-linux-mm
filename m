Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E06FD6B01AF
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 14:05:08 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH RFC] mm: Implement balance_dirty_pages() through waiting for flusher thread
Date: Thu, 17 Jun 2010 20:04:38 +0200
Message-Id: <1276797878-28893-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, hch@infradead.org, akpm@linux-foundation.org, peterz@infradead.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

This patch changes balance_dirty_pages() throttling so that the function does
not submit writes on its own but rather waits for flusher thread to do enough
writes. This has an advantage that we have a single source of IO allowing for
better writeback locality. Also we do not have to reenter filesystems from a
non-trivial context.

The waiting is implemented as follows: Each BDI has a FIFO of wait requests.
When balance_dirty_pages() finds it needs to throttle the writer, it adds a
request for writing write_chunk of pages to the FIFO and waits until the
request is fulfilled or we drop below dirty limits. A flusher thread tracks
amount of pages it has written and when enough pages are written since the
first request in the FIFO became first, it wakes up the waiter and removes
request from the FIFO (thus another request becomes first and flusher thread
starts writing out on behalf of this request).

CC: hch@infradead.org
CC: akpm@linux-foundation.org
CC: peterz@infradead.org
CC: wfg@mail.ustc.edu.cn
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev.h |   18 +++++
 include/linux/writeback.h   |    1 +
 mm/backing-dev.c            |  119 +++++++++++++++++++++++++++++++
 mm/page-writeback.c         |  164 +++++++++++++++----------------------------
 4 files changed, 195 insertions(+), 107 deletions(-)

 This is mostly a proof-of-concept patch. It's mostly untested and probably
doesn't completely work. I was just thinking about this for some time already
and would like to get some feedback on the approach...

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index aee5f6c..e8b5be8 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -39,6 +39,7 @@ typedef int (congested_fn)(void *, int);
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
 	BDI_WRITEBACK,
+	BDI_WRITTEN,
 	NR_BDI_STAT_ITEMS
 };
 
@@ -58,6 +59,11 @@ struct bdi_writeback {
 	struct list_head	b_more_io;	/* parked for more writeback */
 };
 
+struct bdi_written_count {
+	struct list_head list;
+	u64 written;
+};
+
 struct backing_dev_info {
 	struct list_head bdi_list;
 	struct rcu_head rcu_head;
@@ -85,6 +91,16 @@ struct backing_dev_info {
 	unsigned long wb_mask;	  /* bitmask of registered tasks */
 	unsigned int wb_cnt;	  /* number of registered tasks */
 
+	/*
+	 * We abuse wb_written_wait.lock to also guard consistency of
+	 * wb_written_wait together with wb_written_list and wb_written_head
+	 */
+	wait_queue_head_t wb_written_wait;  /* waitqueue of waiters for writeout */
+	struct list_head wb_written_list;   /* list with numbers of writes to
+					     * wait for */
+	u64 wb_written_head;	/* value of BDI_WRITTEN when we should check
+				 * the first waiter */
+
 	struct list_head work_list;
 
 	struct device *dev;
@@ -110,6 +126,8 @@ void bdi_start_writeback(struct backing_dev_info *bdi, struct super_block *sb,
 int bdi_writeback_task(struct bdi_writeback *wb);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
 void bdi_arm_supers_timer(void);
+void bdi_wakeup_writers(struct backing_dev_info *bdi);
+void bdi_wait_written(struct backing_dev_info *bdi, long write_chunk);
 
 extern spinlock_t bdi_lock;
 extern struct list_head bdi_list;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index d63ef8f..a822159 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -129,6 +129,7 @@ int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 
 void get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
 		      unsigned long *pbdi_dirty, struct backing_dev_info *bdi);
+int dirty_limits_exceeded(struct backing_dev_info *bdi);
 
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 660a87a..e2d0e1a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -390,6 +390,122 @@ static void sync_supers_timer_fn(unsigned long unused)
 	bdi_arm_supers_timer();
 }
 
+/*
+ * Remove writer from the list, update wb_written_head as needed
+ *
+ * Needs wb_written_wait.lock held
+ */
+static void bdi_remove_writer(struct backing_dev_info *bdi,
+			      struct bdi_written_count *wc)
+{
+	int first = 0;
+
+	if (bdi->wb_written_list.next == &wc->list)
+		first = 1;
+	/* Initialize list so that entry owner knows it's removed */
+	list_del_init(&wc->list);
+	if (first) {
+		if (list_empty(&bdi->wb_written_list)) {
+			bdi->wb_written_head = ~(u64)0;
+			return;
+		}
+		wc = list_entry(bdi->wb_written_list.next,
+				struct bdi_written_count,
+				list);
+		bdi->wb_written_head = bdi_stat(bdi, BDI_WRITTEN) + wc->written;
+	}
+}
+
+void bdi_wakeup_writers(struct backing_dev_info *bdi)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&bdi->wb_written_wait.lock, flags);
+	while (!list_empty(&bdi->wb_written_list)) {
+		struct bdi_written_count *wc =
+			list_entry(bdi->wb_written_list.next,
+				   struct bdi_written_count,
+				   list);
+		if (bdi_stat(bdi, BDI_WRITTEN) >= bdi->wb_written_head) {
+			bdi_remove_writer(bdi, wc);
+			/*
+			 * Now we can wakeup the writer which frees wc entry
+			 * The barrier is here so that woken task sees the
+			 * modification of wc.
+			 */
+			smp_wmb();
+			__wake_up_locked(&bdi->wb_written_wait, TASK_NORMAL);
+		} else
+			break;
+	}
+	spin_unlock_irqrestore(&bdi->wb_written_wait.lock, flags);
+}
+
+/* Adds wc structure and the task to the tail of list of waiters */
+static void bdi_add_writer(struct backing_dev_info *bdi,
+			   struct bdi_written_count *wc,
+			   wait_queue_t *wait)
+{
+	spin_lock_irq(&bdi->wb_written_wait.lock);
+	if (list_empty(&bdi->wb_written_list))
+		bdi->wb_written_head = bdi_stat(bdi, BDI_WRITTEN) + wc->written;
+	list_add_tail(&wc->list, &bdi->wb_written_list);
+	__add_wait_queue_tail_exclusive(&bdi->wb_written_wait, wait);
+	spin_unlock_irq(&bdi->wb_written_wait.lock);
+}
+
+/* Wait until write_chunk is written or we get below dirty limits */
+void bdi_wait_written(struct backing_dev_info *bdi, long write_chunk)
+{
+	struct bdi_written_count wc = {
+					.list = LIST_HEAD_INIT(wc.list),
+					.written = write_chunk,
+				};
+	DECLARE_WAITQUEUE(wait, current);
+	int pause = 1;
+
+	bdi_add_writer(bdi, &wc, &wait);
+	for (;;) {
+		if (signal_pending_state(TASK_KILLABLE, current))
+			break;
+
+		/*
+		 * Make the task just killable so that tasks cannot circumvent
+		 * throttling by sending themselves non-fatal signals...
+		 */
+		__set_current_state(TASK_KILLABLE);
+		io_schedule_timeout(pause);
+
+		/*
+		 * The following check is save without wb_written_wait.lock
+		 * because once bdi_remove_writer removes us from the list
+		 * noone will touch us and it's impossible for list_empty check
+		 * to trigger as false positive. The barrier is there to avoid
+		 * missing the wakeup when we are removed from the list.
+		 */
+		smp_rmb();
+		if (list_empty(&wc.list))
+			break;
+
+		if (!dirty_limits_exceeded(bdi))
+			break;
+
+		/*
+		 * Increase the delay for each loop, up to our previous
+		 * default of taking a 100ms nap.
+		 */
+		pause <<= 1;
+		if (pause > HZ / 10)
+			pause = HZ / 10;
+	}
+
+	spin_lock_irq(&bdi->wb_written_wait.lock);
+	__remove_wait_queue(&bdi->wb_written_wait, &wait);
+	if (!list_empty(&wc.list))
+		bdi_remove_writer(bdi, &wc);
+	spin_unlock_irq(&bdi->wb_written_wait.lock);
+}
+
 static int bdi_forker_task(void *ptr)
 {
 	struct bdi_writeback *me = ptr;
@@ -688,6 +804,9 @@ int bdi_init(struct backing_dev_info *bdi)
 	}
 
 	bdi->dirty_exceeded = 0;
+	bdi->wb_written_head = ~(u64)0;
+	init_waitqueue_head(&bdi->wb_written_wait);
+	INIT_LIST_HEAD(&bdi->wb_written_list);
 	err = prop_local_init_percpu(&bdi->completions);
 
 	if (err) {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index bbd396a..3a86a61 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -473,131 +473,78 @@ get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
 	}
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
+int dirty_limits_exceeded(struct backing_dev_info *bdi)
 {
 	long nr_reclaimable, bdi_nr_reclaimable;
 	long nr_writeback, bdi_nr_writeback;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
-	unsigned long pages_written = 0;
-	unsigned long pause = 1;
-
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
-
-	for (;;) {
-		struct writeback_control wbc = {
-			.bdi		= bdi,
-			.sync_mode	= WB_SYNC_NONE,
-			.older_than_this = NULL,
-			.nr_to_write	= write_chunk,
-			.range_cyclic	= 1,
-		};
-
-		get_dirty_limits(&background_thresh, &dirty_thresh,
-				&bdi_thresh, bdi);
-
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
 
+	get_dirty_limits(&background_thresh, &dirty_thresh, &bdi_thresh, bdi);
+	/*
+	 * In order to avoid the stacked BDI deadlock we need to ensure we
+	 * accurately count the 'dirty' pages when the threshold is low.
+	 *
+	 * Otherwise it would be possible to get thresh+n pages reported dirty,
+	 * even though there are thresh-m pages actually dirty; with m+n
+	 * sitting in the percpu deltas.
+	 */
+	if (bdi_thresh < 2*bdi_stat_error(bdi)) {
+		bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
+		bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
+	} else {
 		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
+	}
 
-		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
-			break;
-
-		/*
-		 * Throttle it only when the background writeback cannot
-		 * catch-up. This avoids (excessively) small writeouts
-		 * when the bdi limits are ramping up.
-		 */
-		if (nr_reclaimable + nr_writeback <
-				(background_thresh + dirty_thresh) / 2)
-			break;
-
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
-		if (bdi_nr_reclaimable > bdi_thresh) {
-			writeback_inodes_wbc(&wbc);
-			pages_written += write_chunk - wbc.nr_to_write;
-			get_dirty_limits(&background_thresh, &dirty_thresh,
-				       &bdi_thresh, bdi);
-		}
-
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
-		} else if (bdi_nr_reclaimable) {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
-		}
+	if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh) {
+		if (bdi->dirty_exceeded)
+			bdi->dirty_exceeded = 0;
+		return 0;
+	}
 
-		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
-			break;
-		if (pages_written >= write_chunk)
-			break;		/* We've done our duty */
+	nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
+					global_page_state(NR_UNSTABLE_NFS);
+	nr_writeback = global_page_state(NR_WRITEBACK);
+	/*
+	 * Throttle it only when the background writeback cannot
+	 * catch-up. This avoids (excessively) small writeouts
+	 * when the bdi limits are ramping up.
+	 */
+	if (nr_reclaimable + nr_writeback <
+			(background_thresh + dirty_thresh) / 2) {
+		if (bdi->dirty_exceeded)
+			bdi->dirty_exceeded = 0;
+		return 0;
+	}
 
-		__set_current_state(TASK_INTERRUPTIBLE);
-		io_schedule_timeout(pause);
+	if (!bdi->dirty_exceeded)
+		bdi->dirty_exceeded = 1;
 
-		/*
-		 * Increase the delay for each loop, up to our previous
-		 * default of taking a 100ms nap.
-		 */
-		pause <<= 1;
-		if (pause > HZ / 10)
-			pause = HZ / 10;
-	}
+	return 1;
+}
 
-	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
-			bdi->dirty_exceeded)
-		bdi->dirty_exceeded = 0;
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
 
-	if (writeback_in_progress(bdi))
+	if (!dirty_limits_exceeded(bdi))
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
-	    (!laptop_mode && ((global_page_state(NR_FILE_DIRTY)
-			       + global_page_state(NR_UNSTABLE_NFS))
-					  > background_thresh)))
+	/* FIXME: We could start writeback for all bdis get rid of dirty
+	 * data there ASAP and use all the paralelism we can get... */
+	if (!writeback_in_progress(bdi))
 		bdi_start_writeback(bdi, NULL, 0);
+	bdi_wait_written(bdi, write_chunk);
 }
 
 void set_page_dirty_balance(struct page *page, int page_mkwrite)
@@ -1295,10 +1242,13 @@ int test_clear_page_writeback(struct page *page)
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi)) {
 				__dec_bdi_stat(bdi, BDI_WRITEBACK);
+				__inc_bdi_stat(bdi, BDI_WRITTEN);
 				__bdi_writeout_inc(bdi);
 			}
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		if (bdi_stat(bdi, BDI_WRITTEN) >= bdi->wb_written_head)
+			bdi_wakeup_writers(bdi);
 	} else {
 		ret = TestClearPageWriteback(page);
 	}
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
