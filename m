Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1CEDE6B025E
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 15:53:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y77so943602pfd.2
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 12:53:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k127sor1198391pgc.280.2017.09.19.12.53.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 12:53:18 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 3/6] page-writeback: pass in '0' for nr_pages writeback in laptop mode
Date: Tue, 19 Sep 2017 13:53:04 -0600
Message-Id: <1505850787-18311-4-git-send-email-axboe@kernel.dk>
In-Reply-To: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz, Jens Axboe <axboe@kernel.dk>

Laptop mode really wants to writeback the number of dirty
pages and inodes. Instead of calculating this in the caller,
just pass in 0 and let wakeup_flusher_threads() handle it.

Use the new wakeup_flusher_threads_bdi() instead of rolling
our own.

Signed-off-by: Jens Axboe <axboe@kernel.dk>
---
 mm/page-writeback.c | 18 ++----------------
 1 file changed, 2 insertions(+), 16 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cbe8eba..1933778c52c4 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1980,23 +1980,9 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 void laptop_mode_timer_fn(unsigned long data)
 {
 	struct request_queue *q = (struct request_queue *)data;
-	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
-		global_node_page_state(NR_UNSTABLE_NFS);
-	struct bdi_writeback *wb;
 
-	/*
-	 * We want to write everything out, not just down to the dirty
-	 * threshold
-	 */
-	if (!bdi_has_dirty_io(q->backing_dev_info))
-		return;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(wb, &q->backing_dev_info->wb_list, bdi_node)
-		if (wb_has_dirty_io(wb))
-			wb_start_writeback(wb, nr_pages, true,
-					   WB_REASON_LAPTOP_TIMER);
-	rcu_read_unlock();
+	wakeup_flusher_threads_bdi(q->backing_dev_info, 0,
+					WB_REASON_LAPTOP_TIMER);
 }
 
 /*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
