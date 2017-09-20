Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0FF6B026D
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:33:31 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g32so4866386ioj.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:33:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z2sor1619323iti.80.2017.09.20.08.33.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:33:30 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 7/7] fs-writeback: only allow one inflight and pending full flush
Date: Wed, 20 Sep 2017 09:33:02 -0600
Message-Id: <1505921582-26709-8-git-send-email-axboe@kernel.dk>
In-Reply-To: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz, Jens Axboe <axboe@kernel.dk>

When someone calls wakeup_flusher_threads() or
wakeup_flusher_threads_bdi(), they schedule writeback of all dirty
pages in the system (or on that bdi). If we are tight on memory, we
can get tons of these queued from kswapd/vmscan. This causes (at
least) two problems:

1) We consume a ton of memory just allocating writeback work items.
2) We spend so much time processing these work items, that we
   introduce a softlockup in writeback processing.

Fix this by adding a 'start_all' bit to the writeback structure, and
set that when someone attempts to flush all dirty page.  The bit is
cleared when we start writeback on that work item. If the bit is
already set when we attempt to queue !nr_pages writeback, then we
simply ignore it.

This provides us one full flush in flight, with one pending as well,
and makes for more efficient handling of this type of writeback.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Tested-by: Chris Mason <clm@fb.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jens Axboe <axboe@kernel.dk>
---
 fs/fs-writeback.c                | 24 ++++++++++++++++++++++++
 include/linux/backing-dev-defs.h |  1 +
 2 files changed, 25 insertions(+)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 3916ea2484ae..6205319d0c24 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -53,6 +53,7 @@ struct wb_writeback_work {
 	unsigned int for_background:1;
 	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
 	unsigned int auto_free:1;	/* free on completion */
+	unsigned int start_all:1;	/* nr_pages == 0 (all) writeback */
 	enum wb_reason reason;		/* why was writeback initiated? */
 
 	struct list_head list;		/* pending work list */
@@ -953,12 +954,26 @@ static void wb_start_writeback(struct bdi_writeback *wb, bool range_cyclic,
 		return;
 
 	/*
+	 * All callers of this function want to start writeback of all
+	 * dirty pages. Places like vmscan can call this at a very
+	 * high frequency, causing pointless allocations of tons of
+	 * work items and keeping the flusher threads busy retrieving
+	 * that work. Ensure that we only allow one of them pending and
+	 * inflight at the time
+	 */
+	if (test_bit(WB_start_all, &wb->state))
+		return;
+
+	set_bit(WB_start_all, &wb->state);
+
+	/*
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
 	work = kzalloc(sizeof(*work),
 		       GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
 	if (!work) {
+		clear_bit(WB_start_all, &wb->state);
 		trace_writeback_nowork(wb);
 		wb_wakeup(wb);
 		return;
@@ -969,6 +984,7 @@ static void wb_start_writeback(struct bdi_writeback *wb, bool range_cyclic,
 	work->range_cyclic = range_cyclic;
 	work->reason	= reason;
 	work->auto_free	= 1;
+	work->start_all = 1;
 
 	wb_queue_work(wb, work);
 }
@@ -1822,6 +1838,14 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
 		list_del_init(&work->list);
 	}
 	spin_unlock_bh(&wb->work_lock);
+
+	/*
+	 * Once we start processing a work item that had !nr_pages,
+	 * clear the wb state bit for that so we can allow more.
+	 */
+	if (work && work->start_all)
+		clear_bit(WB_start_all, &wb->state);
+
 	return work;
 }
 
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 866c433e7d32..420de5c7c7f9 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -24,6 +24,7 @@ enum wb_state {
 	WB_shutting_down,	/* wb_shutdown() in progress */
 	WB_writeback_running,	/* Writeback is in progress */
 	WB_has_dirty_io,	/* Dirty inodes on ->b_{dirty|io|more_io} */
+	WB_start_all,		/* nr_pages == 0 (all) work pending */
 };
 
 enum wb_congested_state {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
