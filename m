Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E55856B0268
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:33:26 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id c195so4514889itb.5
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:33:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p69sor1940627ite.91.2017.09.20.08.33.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:33:25 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 4/7] page-writeback: pass in '0' for nr_pages writeback in laptop mode
Date: Wed, 20 Sep 2017 09:32:59 -0600
Message-Id: <1505921582-26709-5-git-send-email-axboe@kernel.dk>
In-Reply-To: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz, Jens Axboe <axboe@kernel.dk>

Laptop mode really wants to writeback the number of dirty
pages and inodes. Instead of calculating this in the caller,
just pass in 0 and let wakeup_flusher_threads() handle it.

Use the new wakeup_flusher_threads_bdi() instead of rolling
our own. This changes the writeback to not be range cyclic,
but that should not matter for laptop mode flush-all
semantics.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Tested-by: Chris Mason <clm@fb.com>
Signed-off-by: Jens Axboe <axboe@kernel.dk>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jens Axboe <axboe@kernel.dk>
---
 mm/page-writeback.c | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cbe8eba..8d1fc593bce8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1980,23 +1980,8 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
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
+	wakeup_flusher_threads_bdi(q->backing_dev_info, WB_REASON_LAPTOP_TIMER);
 }
 
 /*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
