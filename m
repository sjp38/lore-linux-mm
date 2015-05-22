Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 30CAC829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:32 -0400 (EDT)
Received: by qkx62 with SMTP id 62so22154101qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:32 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id 23si3730402qhc.26.2015.05.22.14.15.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:31 -0700 (PDT)
Received: by qkdn188 with SMTP id n188so22252139qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:31 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 38/51] writeback: make laptop_mode_timer_fn() handle multiple bdi_writeback's
Date: Fri, 22 May 2015 17:13:52 -0400
Message-Id: <1432329245-5844-39-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

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
index 6301af2..682e3a6 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1723,14 +1723,20 @@ void laptop_mode_timer_fn(unsigned long data)
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
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
