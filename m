Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCD7B6B0253
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 12:05:49 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g32so11228886ioj.0
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 09:05:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u24sor769025ioi.301.2017.09.21.09.05.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 09:05:48 -0700 (PDT)
Subject: Re: [PATCH 7/7] fs-writeback: only allow one inflight and pending
 full flush
From: Jens Axboe <axboe@kernel.dk>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-8-git-send-email-axboe@kernel.dk>
 <20170921150510.GH8839@infradead.org>
 <728d4141-8d73-97fb-de08-90671c2897da@kernel.dk>
Message-ID: <3682c4c2-6e8a-e883-9f62-455ea2944496@kernel.dk>
Date: Thu, 21 Sep 2017 10:00:25 -0600
MIME-Version: 1.0
In-Reply-To: <728d4141-8d73-97fb-de08-90671c2897da@kernel.dk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On 09/21/2017 09:36 AM, Jens Axboe wrote:
>> But more importantly once we are not guaranteed that we only have
>> a single global wb_writeback_work per bdi_writeback we should just
>> embedd that into struct bdi_writeback instead of dynamically
>> allocating it.
>
> We could do this as a followup. But right now the logic is that we
> can have on started (inflight), and still have one new queued.

Something like the below would fit on top to do that. Gets rid of the
allocation and embeds the work item for global start-all in the
bdi_writeback structure.

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 6205319d0c24..9f3872e28c3f 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -40,27 +40,6 @@ struct wb_completion {
 };
 
 /*
- * Passed into wb_writeback(), essentially a subset of writeback_control
- */
-struct wb_writeback_work {
-	long nr_pages;
-	struct super_block *sb;
-	unsigned long *older_than_this;
-	enum writeback_sync_modes sync_mode;
-	unsigned int tagged_writepages:1;
-	unsigned int for_kupdate:1;
-	unsigned int range_cyclic:1;
-	unsigned int for_background:1;
-	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
-	unsigned int auto_free:1;	/* free on completion */
-	unsigned int start_all:1;	/* nr_pages == 0 (all) writeback */
-	enum wb_reason reason;		/* why was writeback initiated? */
-
-	struct list_head list;		/* pending work list */
-	struct wb_completion *done;	/* set if the caller waits */
-};
-
-/*
  * If one wants to wait for one or more wb_writeback_works, each work's
  * ->done should be set to a wb_completion defined using the following
  * macro.  Once all work items are issued with wb_queue_work(), the caller
@@ -181,6 +160,8 @@ static void finish_writeback_work(struct bdi_writeback *wb,
 
 	if (work->auto_free)
 		kfree(work);
+	else if (work->start_all)
+		clear_bit(WB_start_all, &wb->state);
 	if (done && atomic_dec_and_test(&done->cnt))
 		wake_up_all(&wb->bdi->wb_waitq);
 }
@@ -945,8 +926,7 @@ static unsigned long get_nr_dirty_pages(void)
 		get_nr_dirty_inodes();
 }
 
-static void wb_start_writeback(struct bdi_writeback *wb, bool range_cyclic,
-			       enum wb_reason reason)
+static void wb_start_writeback(struct bdi_writeback *wb, enum wb_reason reason)
 {
 	struct wb_writeback_work *work;
 
@@ -961,29 +941,16 @@ static void wb_start_writeback(struct bdi_writeback *wb, bool range_cyclic,
 	 * that work. Ensure that we only allow one of them pending and
 	 * inflight at the time
 	 */
-	if (test_bit(WB_start_all, &wb->state))
-		return;
-
-	set_bit(WB_start_all, &wb->state);
-
-	/*
-	 * This is WB_SYNC_NONE writeback, so if allocation fails just
-	 * wakeup the thread for old dirty data writeback
-	 */
-	work = kzalloc(sizeof(*work),
-		       GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
-	if (!work) {
-		clear_bit(WB_start_all, &wb->state);
-		trace_writeback_nowork(wb);
-		wb_wakeup(wb);
+	if (test_bit(WB_start_all, &wb->state) ||
+	    test_and_set_bit(WB_start_all, &wb->state))
 		return;
-	}
 
+	work = &wb->wb_all_work;
+	memset(work, 0, sizeof(*work));
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= wb_split_bdi_pages(wb, get_nr_dirty_pages());
-	work->range_cyclic = range_cyclic;
+	work->range_cyclic = false;
 	work->reason	= reason;
-	work->auto_free	= 1;
 	work->start_all = 1;
 
 	wb_queue_work(wb, work);
@@ -1838,14 +1805,6 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
 		list_del_init(&work->list);
 	}
 	spin_unlock_bh(&wb->work_lock);
-
-	/*
-	 * Once we start processing a work item that had !nr_pages,
-	 * clear the wb state bit for that so we can allow more.
-	 */
-	if (work && work->start_all)
-		clear_bit(WB_start_all, &wb->state);
-
 	return work;
 }
 
@@ -1983,7 +1942,7 @@ static void __wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
 		return;
 
 	list_for_each_entry_rcu(wb, &bdi->wb_list, bdi_node)
-		wb_start_writeback(wb, false, reason);
+		wb_start_writeback(wb, reason);
 }
 
 void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 420de5c7c7f9..4e1146ce5584 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -24,7 +24,7 @@ enum wb_state {
 	WB_shutting_down,	/* wb_shutdown() in progress */
 	WB_writeback_running,	/* Writeback is in progress */
 	WB_has_dirty_io,	/* Dirty inodes on ->b_{dirty|io|more_io} */
-	WB_start_all,		/* nr_pages == 0 (all) work pending */
+	WB_start_all,		/* wb->wb_all_work queued/allocated */
 };
 
 enum wb_congested_state {
@@ -65,6 +65,58 @@ struct bdi_writeback_congested {
 };
 
 /*
+ * fs/fs-writeback.c
+ */
+enum writeback_sync_modes {
+	WB_SYNC_NONE,	/* Don't wait on anything */
+	WB_SYNC_ALL,	/* Wait on every mapping */
+};
+
+/*
+ * why some writeback work was initiated
+ */
+enum wb_reason {
+	WB_REASON_BACKGROUND,
+	WB_REASON_VMSCAN,
+	WB_REASON_SYNC,
+	WB_REASON_PERIODIC,
+	WB_REASON_LAPTOP_TIMER,
+	WB_REASON_FREE_MORE_MEM,
+	WB_REASON_FS_FREE_SPACE,
+	/*
+	 * There is no bdi forker thread any more and works are done
+	 * by emergency worker, however, this is TPs userland visible
+	 * and we'll be exposing exactly the same information,
+	 * so it has a mismatch name.
+	 */
+	WB_REASON_FORKER_THREAD,
+
+	WB_REASON_MAX,
+};
+
+/*
+ * Passed into wb_writeback(), essentially a subset of writeback_control
+ */
+struct wb_completion;
+struct wb_writeback_work {
+	long nr_pages;
+	struct super_block *sb;
+	unsigned long *older_than_this;
+	enum writeback_sync_modes sync_mode;
+	unsigned int tagged_writepages:1;
+	unsigned int for_kupdate:1;
+	unsigned int range_cyclic:1;
+	unsigned int for_background:1;
+	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
+	unsigned int auto_free:1;	/* free on completion */
+	unsigned int start_all:1;	/* nr_pages == 0 (all) writeback */
+	enum wb_reason reason;		/* why was writeback initiated? */
+
+	struct list_head list;		/* pending work list */
+	struct wb_completion *done;	/* set if the caller waits */
+};
+
+/*
  * Each wb (bdi_writeback) can perform writeback operations, is measured
  * and throttled, independently.  Without cgroup writeback, each bdi
  * (bdi_writeback) is served by its embedded bdi->wb.
@@ -125,6 +177,8 @@ struct bdi_writeback {
 
 	struct list_head bdi_node;	/* anchored at bdi->wb_list */
 
+	struct wb_writeback_work wb_all_work;
+
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct percpu_ref refcnt;	/* used only for !root wb's */
 	struct fprop_local_percpu memcg_completions;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 9c0091678af4..f4b52ab328b2 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -34,36 +34,6 @@ DECLARE_PER_CPU(int, dirty_throttle_leaks);
 struct backing_dev_info;
 
 /*
- * fs/fs-writeback.c
- */
-enum writeback_sync_modes {
-	WB_SYNC_NONE,	/* Don't wait on anything */
-	WB_SYNC_ALL,	/* Wait on every mapping */
-};
-
-/*
- * why some writeback work was initiated
- */
-enum wb_reason {
-	WB_REASON_BACKGROUND,
-	WB_REASON_VMSCAN,
-	WB_REASON_SYNC,
-	WB_REASON_PERIODIC,
-	WB_REASON_LAPTOP_TIMER,
-	WB_REASON_FREE_MORE_MEM,
-	WB_REASON_FS_FREE_SPACE,
-	/*
-	 * There is no bdi forker thread any more and works are done
-	 * by emergency worker, however, this is TPs userland visible
-	 * and we'll be exposing exactly the same information,
-	 * so it has a mismatch name.
-	 */
-	WB_REASON_FORKER_THREAD,
-
-	WB_REASON_MAX,
-};
-
-/*
  * A control structure which tells the writeback code what to do.  These are
  * always on the stack, and hence need no locking.  They are always initialised
  * in a manner such that unspecified fields are set to zero.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
