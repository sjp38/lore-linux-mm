Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7196B00CE
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:00:34 -0400 (EDT)
Received: by qkx62 with SMTP id 62so31096538qkx.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:34 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com. [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id h7si5139437qge.80.2015.04.06.13.00.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:00:31 -0700 (PDT)
Received: by qcyk17 with SMTP id k17so15133409qcy.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:31 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 41/49] writeback: add wb_writeback_work->auto_free
Date: Mon,  6 Apr 2015 15:58:30 -0400
Message-Id: <1428350318-8215-42-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Currently, a wb_writeback_work is freed automatically on completion if
it doesn't have ->done set.  Add wb_writeback_work->auto_free to make
the switch explicit.  This will help cgroup writeback support where
waiting for completion and whether to free automatically don't
necessarily move together.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d30bcd8..306229a 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -47,6 +47,7 @@ struct wb_writeback_work {
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
 	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
+	unsigned int auto_free:1;	/* free on completion */
 	enum wb_reason reason;		/* why was writeback initiated? */
 
 	struct list_head list;		/* pending work list */
@@ -246,6 +247,7 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
 	work->reason	= reason;
+	work->auto_free	= 1;
 
 	wb_queue_work(wb, work);
 }
@@ -1123,19 +1125,16 @@ static long wb_do_writeback(struct bdi_writeback *wb)
 
 	set_bit(WB_writeback_running, &wb->state);
 	while ((work = get_next_work_item(wb)) != NULL) {
+		struct completion *done = work->done;
 
 		trace_writeback_exec(wb->bdi, work);
 
 		wrote += wb_writeback(wb, work);
 
-		/*
-		 * Notify the caller of completion if this is a synchronous
-		 * work item, otherwise just free it.
-		 */
-		if (work->done)
-			complete(work->done);
-		else
+		if (work->auto_free)
 			kfree(work);
+		if (done)
+			complete(done);
 	}
 
 	/*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
