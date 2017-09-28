Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8966B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 14:10:02 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y17so2969778pgc.2
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 11:10:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t2sor322324pgb.272.2017.09.28.11.10.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 11:10:00 -0700 (PDT)
Subject: Re: [PATCH 7/7] fs-writeback: only allow one inflight and pending
 full flush
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-8-git-send-email-axboe@kernel.dk>
 <20170921150510.GH8839@infradead.org>
 <728d4141-8d73-97fb-de08-90671c2897da@kernel.dk>
 <3682c4c2-6e8a-e883-9f62-455ea2944496@kernel.dk>
 <20170925093532.GC5741@quack2.suse.cz>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <214d2bcb-0697-c051-0f36-20cd0d8702b0@kernel.dk>
Date: Thu, 28 Sep 2017 20:09:50 +0200
MIME-Version: 1.0
In-Reply-To: <20170925093532.GC5741@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com

On 09/25/2017 11:35 AM, Jan Kara wrote:
> On Thu 21-09-17 10:00:25, Jens Axboe wrote:
>> On 09/21/2017 09:36 AM, Jens Axboe wrote:
>>>> But more importantly once we are not guaranteed that we only have
>>>> a single global wb_writeback_work per bdi_writeback we should just
>>>> embedd that into struct bdi_writeback instead of dynamically
>>>> allocating it.
>>>
>>> We could do this as a followup. But right now the logic is that we
>>> can have on started (inflight), and still have one new queued.
>>
>> Something like the below would fit on top to do that. Gets rid of the
>> allocation and embeds the work item for global start-all in the
>> bdi_writeback structure.
> 
> Hum, so when we consider stuff like embedded work item, I would somewhat
> prefer to handle this like we do for for_background and for_kupdate style
> writeback so that we don't have another special case. For these don't queue
> any item, we just queue writeback work into the workqueue (via
> wb_wakeup()). When flusher work gets processed wb_do_writeback() checks
> (after processing all normal writeback requests) whether conditions for
> these special writeback styles are met and if yes, it creates on-stack work
> item and processes it (see wb_check_old_data_flush() and
> wb_check_background_flush()).
> 
> So in this case we would just set some flag in bdi_writeback when memory
> reclaim needs help and wb_do_writeback() would check for this flag and
> create and process writeback-all style writeback work. Granted this does
> not preserve ordering of requests (basically any specific request gets
> priority over writeback-whole-world request) but memory gets cleaned in
> either case so flusher should be doing what is needed.

How about something like the below? It's on top of the latest series,
which is in my wb-start-all branch. It handles start_all like the
background/kupdate style writeback, reusing the WB_start_all bit for
that.

On a plane, so untested, but it seems pretty straight forward. It
changes the logic a little bit, as the WB_start_all bit isn't cleared
until after we're done with a flush-all request. At this point it's
truly on inflight at any point in time, not one inflight and one
potentially queued.

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 399619c97567..9e24d604c59c 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -53,7 +53,6 @@ struct wb_writeback_work {
 	unsigned int for_background:1;
 	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
 	unsigned int auto_free:1;	/* free on completion */
-	unsigned int start_all:1;	/* nr_pages == 0 (all) writeback */
 	enum wb_reason reason;		/* why was writeback initiated? */
 
 	struct list_head list;		/* pending work list */
@@ -947,8 +946,6 @@ static unsigned long get_nr_dirty_pages(void)
 
 static void wb_start_writeback(struct bdi_writeback *wb, enum wb_reason reason)
 {
-	struct wb_writeback_work *work;
-
 	if (!wb_has_dirty_io(wb))
 		return;
 
@@ -958,35 +955,14 @@ static void wb_start_writeback(struct bdi_writeback *wb, enum wb_reason reason)
 	 * high frequency, causing pointless allocations of tons of
 	 * work items and keeping the flusher threads busy retrieving
 	 * that work. Ensure that we only allow one of them pending and
-	 * inflight at the time. It doesn't matter if we race a little
-	 * bit on this, so use the faster separate test/set bit variants.
+	 * inflight at the time.
 	 */
-	if (test_bit(WB_start_all, &wb->state))
+	if (test_bit(WB_start_all, &wb->state) ||
+	    test_and_set_bit(WB_start_all, &wb->state))
 		return;
 
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
-		return;
-	}
-
-	work->sync_mode	= WB_SYNC_NONE;
-	work->nr_pages	= wb_split_bdi_pages(wb, get_nr_dirty_pages());
-	work->range_cyclic = 1;
-	work->reason	= reason;
-	work->auto_free	= 1;
-	work->start_all = 1;
-
-	wb_queue_work(wb, work);
+	wb->start_all_reason = reason;
+	wb_wakeup(wb);
 }
 
 /**
@@ -1838,14 +1814,6 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
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
 
@@ -1901,6 +1869,30 @@ static long wb_check_old_data_flush(struct bdi_writeback *wb)
 	return 0;
 }
 
+static long wb_check_start_all(struct bdi_writeback *wb)
+{
+	long nr_pages;
+
+	if (!test_bit(WB_start_all, &wb->state))
+		return 0;
+
+	nr_pages = get_nr_dirty_pages();
+	if (nr_pages) {
+		struct wb_writeback_work work = {
+			.nr_pages	= wb_split_bdi_pages(wb, nr_pages),
+			.sync_mode	= WB_SYNC_NONE,
+			.range_cyclic	= 1,
+			.reason		= wb->start_all_reason,
+		};
+
+		nr_pages = wb_writeback(wb, &work);
+	}
+
+	clear_bit(WB_start_all, &wb->state);
+	return nr_pages;
+}
+
+
 /*
  * Retrieve work items and do the writeback they describe
  */
@@ -1917,6 +1909,11 @@ static long wb_do_writeback(struct bdi_writeback *wb)
 	}
 
 	/*
+	 * Check for a flush-everything request
+	 */
+	wrote += wb_check_start_all(wb);
+
+	/*
 	 * Check for periodic writeback, kupdated() style
 	 */
 	wrote += wb_check_old_data_flush(wb);
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 420de5c7c7f9..f0f1df29d6b8 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -116,6 +116,7 @@ struct bdi_writeback {
 
 	struct fprop_local_percpu completions;
 	int dirty_exceeded;
+	int start_all_reason;
 
 	spinlock_t work_lock;		/* protects work_list & dwork scheduling */
 	struct list_head work_list;
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 9b57f014d79d..19a0ea08e098 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -286,7 +286,6 @@ DEFINE_EVENT(writeback_class, name, \
 	TP_PROTO(struct bdi_writeback *wb), \
 	TP_ARGS(wb))
 
-DEFINE_WRITEBACK_EVENT(writeback_nowork);
 DEFINE_WRITEBACK_EVENT(writeback_wake_background);
 
 TRACE_EVENT(writeback_bdi_register,

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
