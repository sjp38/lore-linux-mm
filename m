Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 23A75829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:14:47 -0400 (EDT)
Received: by qgew3 with SMTP id w3so16200560qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:47 -0700 (PDT)
Received: from mail-qk0-x229.google.com (mail-qk0-x229.google.com. [2607:f8b0:400d:c09::229])
        by mx.google.com with ESMTPS id u5si3671420qgu.115.2015.05.22.14.14.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:14:45 -0700 (PDT)
Received: by qkgv12 with SMTP id v12so22221118qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:45 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 16/51] writeback: move backing_dev_info->wb_lock and ->worklist into bdi_writeback
Date: Fri, 22 May 2015 17:13:30 -0400
Message-Id: <1432329245-5844-17-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

Currently, a bdi (backing_dev_info) embeds single wb (bdi_writeback)
and the role of the separation is unclear.  For cgroup support for
writeback IOs, a bdi will be updated to host multiple wb's where each
wb serves writeback IOs of a different cgroup on the bdi.  To achieve
that, a wb should carry all states necessary for servicing writeback
IOs for a cgroup independently.

This patch moves bdi->wb_lock and ->worklist into wb.

* The lock protects bdi->worklist and bdi->wb.dwork scheduling.  While
  moving, rename it to wb->work_lock as wb->wb_lock is confusing.
  Also, move wb->dwork downwards so that it's colocated with the new
  ->work_lock and ->work_list fields.

* bdi_writeback_workfn()		-> wb_workfn()
  bdi_wakeup_thread_delayed(bdi)	-> wb_wakeup_delayed(wb)
  bdi_wakeup_thread(bdi)		-> wb_wakeup(wb)
  bdi_queue_work(bdi, ...)		-> wb_queue_work(wb, ...)
  __bdi_start_writeback(bdi, ...)	-> __wb_start_writeback(wb, ...)
  get_next_work_item(bdi)		-> get_next_work_item(wb)

* bdi_wb_shutdown() is renamed to wb_shutdown() and now takes @wb.
  The function contained parts which belong to the containing bdi
  rather than the wb itself - testing cap_writeback_dirty and
  bdi_remove_from_list() invocation.  Those are moved to
  bdi_unregister().

* bdi_wb_{init|exit}() are renamed to wb_{init|exit}().
  Initializations of the moved bdi->wb_lock and ->work_list are
  relocated from bdi_init() to wb_init().

* As there's still only one bdi_writeback per backing_dev_info, all
  uses of bdi->state are mechanically replaced with bdi->wb.state
  introducing no behavior changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           | 86 +++++++++++++++++++++------------------------
 include/linux/backing-dev.h | 12 +++----
 mm/backing-dev.c            | 59 +++++++++++++++----------------
 3 files changed, 75 insertions(+), 82 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1945cb9..a69d2e1 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -109,34 +109,33 @@ static inline struct inode *wb_inode(struct list_head *head)
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(wbc_writepage);
 
-static void bdi_wakeup_thread(struct backing_dev_info *bdi)
+static void wb_wakeup(struct bdi_writeback *wb)
 {
-	spin_lock_bh(&bdi->wb_lock);
-	if (test_bit(WB_registered, &bdi->wb.state))
-		mod_delayed_work(bdi_wq, &bdi->wb.dwork, 0);
-	spin_unlock_bh(&bdi->wb_lock);
+	spin_lock_bh(&wb->work_lock);
+	if (test_bit(WB_registered, &wb->state))
+		mod_delayed_work(bdi_wq, &wb->dwork, 0);
+	spin_unlock_bh(&wb->work_lock);
 }
 
-static void bdi_queue_work(struct backing_dev_info *bdi,
-			   struct wb_writeback_work *work)
+static void wb_queue_work(struct bdi_writeback *wb,
+			  struct wb_writeback_work *work)
 {
-	trace_writeback_queue(bdi, work);
+	trace_writeback_queue(wb->bdi, work);
 
-	spin_lock_bh(&bdi->wb_lock);
-	if (!test_bit(WB_registered, &bdi->wb.state)) {
+	spin_lock_bh(&wb->work_lock);
+	if (!test_bit(WB_registered, &wb->state)) {
 		if (work->done)
 			complete(work->done);
 		goto out_unlock;
 	}
-	list_add_tail(&work->list, &bdi->work_list);
-	mod_delayed_work(bdi_wq, &bdi->wb.dwork, 0);
+	list_add_tail(&work->list, &wb->work_list);
+	mod_delayed_work(bdi_wq, &wb->dwork, 0);
 out_unlock:
-	spin_unlock_bh(&bdi->wb_lock);
+	spin_unlock_bh(&wb->work_lock);
 }
 
-static void
-__bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
-		      bool range_cyclic, enum wb_reason reason)
+static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
+				 bool range_cyclic, enum wb_reason reason)
 {
 	struct wb_writeback_work *work;
 
@@ -146,8 +145,8 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 	 */
 	work = kzalloc(sizeof(*work), GFP_ATOMIC);
 	if (!work) {
-		trace_writeback_nowork(bdi);
-		bdi_wakeup_thread(bdi);
+		trace_writeback_nowork(wb->bdi);
+		wb_wakeup(wb);
 		return;
 	}
 
@@ -156,7 +155,7 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 	work->range_cyclic = range_cyclic;
 	work->reason	= reason;
 
-	bdi_queue_work(bdi, work);
+	wb_queue_work(wb, work);
 }
 
 /**
@@ -174,7 +173,7 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 			enum wb_reason reason)
 {
-	__bdi_start_writeback(bdi, nr_pages, true, reason);
+	__wb_start_writeback(&bdi->wb, nr_pages, true, reason);
 }
 
 /**
@@ -194,7 +193,7 @@ void bdi_start_background_writeback(struct backing_dev_info *bdi)
 	 * writeback as soon as there is no other work to do.
 	 */
 	trace_writeback_wake_background(bdi);
-	bdi_wakeup_thread(bdi);
+	wb_wakeup(&bdi->wb);
 }
 
 /*
@@ -898,7 +897,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 		 * after the other works are all done.
 		 */
 		if ((work->for_background || work->for_kupdate) &&
-		    !list_empty(&wb->bdi->work_list))
+		    !list_empty(&wb->work_list))
 			break;
 
 		/*
@@ -969,18 +968,17 @@ static long wb_writeback(struct bdi_writeback *wb,
 /*
  * Return the next wb_writeback_work struct that hasn't been processed yet.
  */
-static struct wb_writeback_work *
-get_next_work_item(struct backing_dev_info *bdi)
+static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
 {
 	struct wb_writeback_work *work = NULL;
 
-	spin_lock_bh(&bdi->wb_lock);
-	if (!list_empty(&bdi->work_list)) {
-		work = list_entry(bdi->work_list.next,
+	spin_lock_bh(&wb->work_lock);
+	if (!list_empty(&wb->work_list)) {
+		work = list_entry(wb->work_list.next,
 				  struct wb_writeback_work, list);
 		list_del_init(&work->list);
 	}
-	spin_unlock_bh(&bdi->wb_lock);
+	spin_unlock_bh(&wb->work_lock);
 	return work;
 }
 
@@ -1052,14 +1050,13 @@ static long wb_check_old_data_flush(struct bdi_writeback *wb)
  */
 static long wb_do_writeback(struct bdi_writeback *wb)
 {
-	struct backing_dev_info *bdi = wb->bdi;
 	struct wb_writeback_work *work;
 	long wrote = 0;
 
 	set_bit(WB_writeback_running, &wb->state);
-	while ((work = get_next_work_item(bdi)) != NULL) {
+	while ((work = get_next_work_item(wb)) != NULL) {
 
-		trace_writeback_exec(bdi, work);
+		trace_writeback_exec(wb->bdi, work);
 
 		wrote += wb_writeback(wb, work);
 
@@ -1087,43 +1084,42 @@ static long wb_do_writeback(struct bdi_writeback *wb)
  * Handle writeback of dirty data for the device backed by this bdi. Also
  * reschedules periodically and does kupdated style flushing.
  */
-void bdi_writeback_workfn(struct work_struct *work)
+void wb_workfn(struct work_struct *work)
 {
 	struct bdi_writeback *wb = container_of(to_delayed_work(work),
 						struct bdi_writeback, dwork);
-	struct backing_dev_info *bdi = wb->bdi;
 	long pages_written;
 
-	set_worker_desc("flush-%s", dev_name(bdi->dev));
+	set_worker_desc("flush-%s", dev_name(wb->bdi->dev));
 	current->flags |= PF_SWAPWRITE;
 
 	if (likely(!current_is_workqueue_rescuer() ||
 		   !test_bit(WB_registered, &wb->state))) {
 		/*
-		 * The normal path.  Keep writing back @bdi until its
+		 * The normal path.  Keep writing back @wb until its
 		 * work_list is empty.  Note that this path is also taken
-		 * if @bdi is shutting down even when we're running off the
+		 * if @wb is shutting down even when we're running off the
 		 * rescuer as work_list needs to be drained.
 		 */
 		do {
 			pages_written = wb_do_writeback(wb);
 			trace_writeback_pages_written(pages_written);
-		} while (!list_empty(&bdi->work_list));
+		} while (!list_empty(&wb->work_list));
 	} else {
 		/*
 		 * bdi_wq can't get enough workers and we're running off
 		 * the emergency worker.  Don't hog it.  Hopefully, 1024 is
 		 * enough for efficient IO.
 		 */
-		pages_written = writeback_inodes_wb(&bdi->wb, 1024,
+		pages_written = writeback_inodes_wb(wb, 1024,
 						    WB_REASON_FORKER_THREAD);
 		trace_writeback_pages_written(pages_written);
 	}
 
-	if (!list_empty(&bdi->work_list))
+	if (!list_empty(&wb->work_list))
 		mod_delayed_work(bdi_wq, &wb->dwork, 0);
 	else if (wb_has_dirty_io(wb) && dirty_writeback_interval)
-		bdi_wakeup_thread_delayed(bdi);
+		wb_wakeup_delayed(wb);
 
 	current->flags &= ~PF_SWAPWRITE;
 }
@@ -1143,7 +1139,7 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
 		if (!bdi_has_dirty_io(bdi))
 			continue;
-		__bdi_start_writeback(bdi, nr_pages, false, reason);
+		__wb_start_writeback(&bdi->wb, nr_pages, false, reason);
 	}
 	rcu_read_unlock();
 }
@@ -1174,7 +1170,7 @@ static void wakeup_dirtytime_writeback(struct work_struct *w)
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
 		if (list_empty(&bdi->wb.b_dirty_time))
 			continue;
-		bdi_wakeup_thread(bdi);
+		wb_wakeup(&bdi->wb);
 	}
 	rcu_read_unlock();
 	schedule_delayed_work(&dirtytime_work, dirtytime_expire_interval * HZ);
@@ -1347,7 +1343,7 @@ void __mark_inode_dirty(struct inode *inode, int flags)
 			trace_writeback_dirty_inode_enqueue(inode);
 
 			if (wakeup_bdi)
-				bdi_wakeup_thread_delayed(bdi);
+				wb_wakeup_delayed(&bdi->wb);
 			return;
 		}
 	}
@@ -1437,7 +1433,7 @@ void writeback_inodes_sb_nr(struct super_block *sb,
 	if (sb->s_bdi == &noop_backing_dev_info)
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
-	bdi_queue_work(sb->s_bdi, &work);
+	wb_queue_work(&sb->s_bdi->wb, &work);
 	wait_for_completion(&done);
 }
 EXPORT_SYMBOL(writeback_inodes_sb_nr);
@@ -1521,7 +1517,7 @@ void sync_inodes_sb(struct super_block *sb)
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
-	bdi_queue_work(sb->s_bdi, &work);
+	wb_queue_work(&sb->s_bdi->wb, &work);
 	wait_for_completion(&done);
 
 	wait_sb_inodes(sb);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 2ab0604..d796f49 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -52,7 +52,6 @@ struct bdi_writeback {
 	unsigned long state;		/* Always use atomic bitops on this */
 	unsigned long last_old_flush;	/* last old data flush */
 
-	struct delayed_work dwork;	/* work item used for writeback */
 	struct list_head b_dirty;	/* dirty inodes */
 	struct list_head b_io;		/* parked for writeback */
 	struct list_head b_more_io;	/* parked for more writeback */
@@ -78,6 +77,10 @@ struct bdi_writeback {
 
 	struct fprop_local_percpu completions;
 	int dirty_exceeded;
+
+	spinlock_t work_lock;		/* protects work_list & dwork scheduling */
+	struct list_head work_list;
+	struct delayed_work dwork;	/* work item used for writeback */
 };
 
 struct backing_dev_info {
@@ -93,9 +96,6 @@ struct backing_dev_info {
 	unsigned int max_ratio, max_prop_frac;
 
 	struct bdi_writeback wb;  /* default writeback info for this bdi */
-	spinlock_t wb_lock;	  /* protects work_list & wb.dwork scheduling */
-
-	struct list_head work_list;
 
 	struct device *dev;
 
@@ -121,9 +121,9 @@ int __must_check bdi_setup_and_register(struct backing_dev_info *, char *);
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 			enum wb_reason reason);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
-void bdi_writeback_workfn(struct work_struct *work);
+void wb_workfn(struct work_struct *work);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
-void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi);
+void wb_wakeup_delayed(struct bdi_writeback *wb);
 
 extern spinlock_t bdi_lock;
 extern struct list_head bdi_list;
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 9a6c472..597f0ce 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -261,7 +261,7 @@ int bdi_has_dirty_io(struct backing_dev_info *bdi)
 }
 
 /*
- * This function is used when the first inode for this bdi is marked dirty. It
+ * This function is used when the first inode for this wb is marked dirty. It
  * wakes-up the corresponding bdi thread which should then take care of the
  * periodic background write-out of dirty inodes. Since the write-out would
  * starts only 'dirty_writeback_interval' centisecs from now anyway, we just
@@ -274,15 +274,15 @@ int bdi_has_dirty_io(struct backing_dev_info *bdi)
  * We have to be careful not to postpone flush work if it is scheduled for
  * earlier. Thus we use queue_delayed_work().
  */
-void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi)
+void wb_wakeup_delayed(struct bdi_writeback *wb)
 {
 	unsigned long timeout;
 
 	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
-	spin_lock_bh(&bdi->wb_lock);
-	if (test_bit(WB_registered, &bdi->wb.state))
-		queue_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
-	spin_unlock_bh(&bdi->wb_lock);
+	spin_lock_bh(&wb->work_lock);
+	if (test_bit(WB_registered, &wb->state))
+		queue_delayed_work(bdi_wq, &wb->dwork, timeout);
+	spin_unlock_bh(&wb->work_lock);
 }
 
 /*
@@ -335,28 +335,24 @@ EXPORT_SYMBOL(bdi_register_dev);
 /*
  * Remove bdi from the global list and shutdown any threads we have running
  */
-static void bdi_wb_shutdown(struct backing_dev_info *bdi)
+static void wb_shutdown(struct bdi_writeback *wb)
 {
 	/* Make sure nobody queues further work */
-	spin_lock_bh(&bdi->wb_lock);
-	if (!test_and_clear_bit(WB_registered, &bdi->wb.state)) {
-		spin_unlock_bh(&bdi->wb_lock);
+	spin_lock_bh(&wb->work_lock);
+	if (!test_and_clear_bit(WB_registered, &wb->state)) {
+		spin_unlock_bh(&wb->work_lock);
 		return;
 	}
-	spin_unlock_bh(&bdi->wb_lock);
+	spin_unlock_bh(&wb->work_lock);
 
 	/*
-	 * Make sure nobody finds us on the bdi_list anymore
+	 * Drain work list and shutdown the delayed_work.  !WB_registered
+	 * tells wb_workfn() that @wb is dying and its work_list needs to
+	 * be drained no matter what.
 	 */
-	bdi_remove_from_list(bdi);
-
-	/*
-	 * Drain work list and shutdown the delayed_work.  At this point,
-	 * @bdi->bdi_list is empty telling bdi_Writeback_workfn() that @bdi
-	 * is dying and its work_list needs to be drained no matter what.
-	 */
-	mod_delayed_work(bdi_wq, &bdi->wb.dwork, 0);
-	flush_delayed_work(&bdi->wb.dwork);
+	mod_delayed_work(bdi_wq, &wb->dwork, 0);
+	flush_delayed_work(&wb->dwork);
+	WARN_ON(!list_empty(&wb->work_list));
 }
 
 /*
@@ -381,7 +377,7 @@ EXPORT_SYMBOL(bdi_unregister);
  */
 #define INIT_BW		(100 << (20 - PAGE_SHIFT))
 
-static int bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
+static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
 {
 	int i, err;
 
@@ -394,7 +390,6 @@ static int bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
 	INIT_LIST_HEAD(&wb->b_more_io);
 	INIT_LIST_HEAD(&wb->b_dirty_time);
 	spin_lock_init(&wb->list_lock);
-	INIT_DELAYED_WORK(&wb->dwork, bdi_writeback_workfn);
 
 	wb->bw_time_stamp = jiffies;
 	wb->balanced_dirty_ratelimit = INIT_BW;
@@ -402,6 +397,10 @@ static int bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
 	wb->write_bandwidth = INIT_BW;
 	wb->avg_write_bandwidth = INIT_BW;
 
+	spin_lock_init(&wb->work_lock);
+	INIT_LIST_HEAD(&wb->work_list);
+	INIT_DELAYED_WORK(&wb->dwork, wb_workfn);
+
 	err = fprop_local_init_percpu(&wb->completions, GFP_KERNEL);
 	if (err)
 		return err;
@@ -419,7 +418,7 @@ static int bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
 	return 0;
 }
 
-static void bdi_wb_exit(struct bdi_writeback *wb)
+static void wb_exit(struct bdi_writeback *wb)
 {
 	int i;
 
@@ -440,11 +439,9 @@ int bdi_init(struct backing_dev_info *bdi)
 	bdi->min_ratio = 0;
 	bdi->max_ratio = 100;
 	bdi->max_prop_frac = FPROP_FRAC_BASE;
-	spin_lock_init(&bdi->wb_lock);
 	INIT_LIST_HEAD(&bdi->bdi_list);
-	INIT_LIST_HEAD(&bdi->work_list);
 
-	err = bdi_wb_init(&bdi->wb, bdi);
+	err = wb_init(&bdi->wb, bdi);
 	if (err)
 		return err;
 
@@ -454,9 +451,9 @@ EXPORT_SYMBOL(bdi_init);
 
 void bdi_destroy(struct backing_dev_info *bdi)
 {
-	bdi_wb_shutdown(bdi);
-
-	WARN_ON(!list_empty(&bdi->work_list));
+	/* make sure nobody finds us on the bdi_list anymore */
+	bdi_remove_from_list(bdi);
+	wb_shutdown(&bdi->wb);
 
 	if (bdi->dev) {
 		bdi_debug_unregister(bdi);
@@ -464,7 +461,7 @@ void bdi_destroy(struct backing_dev_info *bdi)
 		bdi->dev = NULL;
 	}
 
-	bdi_wb_exit(&bdi->wb);
+	wb_exit(&bdi->wb);
 }
 EXPORT_SYMBOL(bdi_destroy);
 
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
