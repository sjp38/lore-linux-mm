Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3BECF6B0105
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 14:29:56 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x3so17595209qcv.29
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:56 -0800 (PST)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id 15si65286134qgt.127.2015.01.06.11.29.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 11:29:48 -0800 (PST)
Received: by mail-qg0-f48.google.com with SMTP id j5so6024774qga.7
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:48 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 14/16] writeback: cosmetic change in account_page_dirtied()
Date: Tue,  6 Jan 2015 14:29:15 -0500
Message-Id: <1420572557-11572-15-git-send-email-tj@kernel.org>
In-Reply-To: <1420572557-11572-1-git-send-email-tj@kernel.org>
References: <1420572557-11572-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Flip the polarity of mapping_cap_account_dirty() test so that the body
of page accounting can be moved outside the if () block.  This will
help adding cgroup writeback support.

This causes no logic changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 026c91b..d73539f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2094,15 +2094,16 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	trace_writeback_dirty_page(page, mapping);
 
-	if (mapping_cap_account_dirty(mapping)) {
-		__inc_zone_page_state(page, NR_FILE_DIRTY);
-		__inc_zone_page_state(page, NR_DIRTIED);
-		__inc_wb_stat(&mapping->backing_dev_info->wb, WB_RECLAIMABLE);
-		__inc_wb_stat(&mapping->backing_dev_info->wb, WB_DIRTIED);
-		task_io_account_write(PAGE_CACHE_SIZE);
-		current->nr_dirtied++;
-		this_cpu_inc(bdp_ratelimits);
-	}
+	if (!mapping_cap_account_dirty(mapping))
+		return;
+
+	__inc_zone_page_state(page, NR_FILE_DIRTY);
+	__inc_zone_page_state(page, NR_DIRTIED);
+	__inc_wb_stat(&mapping->backing_dev_info->wb, WB_RECLAIMABLE);
+	__inc_wb_stat(&mapping->backing_dev_info->wb, WB_DIRTIED);
+	task_io_account_write(PAGE_CACHE_SIZE);
+	current->nr_dirtied++;
+	this_cpu_inc(bdp_ratelimits);
 }
 EXPORT_SYMBOL(account_page_dirtied);
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
