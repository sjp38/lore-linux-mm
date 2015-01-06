Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id E1EE26B014D
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:05 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j7so188416qaq.12
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:05 -0800 (PST)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id q8si65677291qco.8.2015.01.06.13.27.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:05 -0800 (PST)
Received: by mail-qg0-f54.google.com with SMTP id l89so64079qgf.27
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:04 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 20/45] writeback: make laptop_mode_timer_fn() handle multiple bdi_writeback's
Date: Tue,  6 Jan 2015 16:25:57 -0500
Message-Id: <1420579582-8516-21-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

For cgroup writeback support, all bdi-wide operations should be
distributed to all its wb's (bdi_writeback's).

This patch updates laptop_mode_timer_fn() so that it invokes
wb_start_writeback() on all wb's rather than just the root one.  As
the intent is writing out all dirty data, there's no reason to split
the number of pages to write.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 18bf51d..190e2a2 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1725,14 +1725,20 @@ void laptop_mode_timer_fn(unsigned long data)
 	struct request_queue *q = (struct request_queue *)data;
 	int nr_pages = global_page_state(NR_FILE_DIRTY) +
 		global_page_state(NR_UNSTABLE_NFS);
+	struct bdi_writeback *wb;
+	struct wb_iter iter;
 
 	/*
 	 * We want to write everything out, not just down to the dirty
 	 * threshold
 	 */
-	if (bdi_has_dirty_io(&q->backing_dev_info))
-		wb_start_writeback(&q->backing_dev_info.wb, nr_pages, true,
-				   WB_REASON_LAPTOP_TIMER);
+	if (!bdi_has_dirty_io(&q->backing_dev_info))
+		return;
+
+	bdi_for_each_wb(wb, &q->backing_dev_info, &iter, 0)
+		if (wb_has_dirty_io(wb))
+			wb_start_writeback(wb, nr_pages, true,
+					   WB_REASON_LAPTOP_TIMER);
 }
 
 /*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
