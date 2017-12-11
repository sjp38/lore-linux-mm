Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC116B025F
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 16:55:44 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id w3so7567497ybg.10
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 13:55:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 204sor4496724ywd.95.2017.12.11.13.55.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 13:55:41 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH v3 02/10] writeback: convert WB_WRITTEN/WB_DIRITED counters to bytes
Date: Mon, 11 Dec 2017 16:55:27 -0500
Message-Id: <1513029335-5112-3-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1513029335-5112-1-git-send-email-josef@toxicpanda.com>
References: <1513029335-5112-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

These are counters that constantly go up in order to do bandwidth calculations.
It isn't important what the units are in, as long as they are consistent between
the two of them, so convert them to count bytes written/dirtied, and allow the
metadata accounting stuff to change the counters as well.

Signed-off-by: Josef Bacik <jbacik@fb.com>
Acked-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/fuse/file.c                   |  4 ++--
 include/linux/backing-dev-defs.h |  4 ++--
 include/linux/backing-dev.h      |  2 +-
 mm/backing-dev.c                 |  9 +++++----
 mm/page-writeback.c              | 20 ++++++++++----------
 5 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index cb7dff5c45d7..67e7c4fac28d 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1471,7 +1471,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
 	for (i = 0; i < req->num_pages; i++) {
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
 		dec_node_page_state(req->pages[i], NR_WRITEBACK_TEMP);
-		wb_writeout_inc(&bdi->wb);
+		wb_writeout_add(&bdi->wb, PAGE_SIZE);
 	}
 	wake_up(&fi->page_waitq);
 }
@@ -1776,7 +1776,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK_TEMP);
-		wb_writeout_inc(&bdi->wb);
+		wb_writeout_add(&bdi->wb, PAGE_SIZE);
 		fuse_writepage_free(fc, new_req);
 		fuse_request_free(new_req);
 		goto out;
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 866c433e7d32..ded45ac2cec7 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -36,8 +36,8 @@ typedef int (congested_fn)(void *, int);
 enum wb_stat_item {
 	WB_RECLAIMABLE,
 	WB_WRITEBACK,
-	WB_DIRTIED,
-	WB_WRITTEN,
+	WB_DIRTIED_BYTES,
+	WB_WRITTEN_BYTES,
 	NR_WB_STAT_ITEMS
 };
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 14e266d12620..39b8dc486ea7 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -89,7 +89,7 @@ static inline s64 wb_stat_sum(struct bdi_writeback *wb, enum wb_stat_item item)
 	return percpu_counter_sum_positive(&wb->stat[item]);
 }
 
-extern void wb_writeout_inc(struct bdi_writeback *wb);
+extern void wb_writeout_add(struct bdi_writeback *wb, long bytes);
 
 /*
  * maximal error of a stat counter.
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e19606bb41a0..62a332a91b38 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -68,14 +68,15 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	wb_thresh = wb_calc_thresh(wb, dirty_thresh);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
+#define BtoK(x) ((x) >> 10)
 	seq_printf(m,
 		   "BdiWriteback:       %10lu kB\n"
 		   "BdiReclaimable:     %10lu kB\n"
 		   "BdiDirtyThresh:     %10lu kB\n"
 		   "DirtyThresh:        %10lu kB\n"
 		   "BackgroundThresh:   %10lu kB\n"
-		   "BdiDirtied:         %10lu kB\n"
-		   "BdiWritten:         %10lu kB\n"
+		   "BdiDirtiedBytes:    %10lu kB\n"
+		   "BdiWrittenBytes:    %10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
 		   "b_io:               %10lu\n"
@@ -88,8 +89,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(wb_thresh),
 		   K(dirty_thresh),
 		   K(background_thresh),
-		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
-		   (unsigned long) K(wb_stat(wb, WB_WRITTEN)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_DIRTIED_BYTES)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_WRITTEN_BYTES)),
 		   (unsigned long) K(wb->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 1a47d4296750..e4563645749a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -597,11 +597,11 @@ static void wb_domain_writeout_inc(struct wb_domain *dom,
  * Increment @wb's writeout completion count and the global writeout
  * completion count. Called from test_clear_page_writeback().
  */
-static inline void __wb_writeout_inc(struct bdi_writeback *wb)
+static inline void __wb_writeout_add(struct bdi_writeback *wb, long bytes)
 {
 	struct wb_domain *cgdom;
 
-	inc_wb_stat(wb, WB_WRITTEN);
+	__add_wb_stat(wb, WB_WRITTEN_BYTES, bytes);
 	wb_domain_writeout_inc(&global_wb_domain, &wb->completions,
 			       wb->bdi->max_prop_frac);
 
@@ -611,15 +611,15 @@ static inline void __wb_writeout_inc(struct bdi_writeback *wb)
 				       wb->bdi->max_prop_frac);
 }
 
-void wb_writeout_inc(struct bdi_writeback *wb)
+void wb_writeout_add(struct bdi_writeback *wb, long bytes)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__wb_writeout_inc(wb);
+	__wb_writeout_add(wb, bytes);
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL_GPL(wb_writeout_inc);
+EXPORT_SYMBOL_GPL(wb_writeout_add);
 
 /*
  * On idle system, we can be called long after we scheduled because we use
@@ -1362,8 +1362,8 @@ static void __wb_update_bandwidth(struct dirty_throttle_control *gdtc,
 	if (elapsed < BANDWIDTH_INTERVAL)
 		return;
 
-	dirtied = percpu_counter_read(&wb->stat[WB_DIRTIED]);
-	written = percpu_counter_read(&wb->stat[WB_WRITTEN]);
+	dirtied = percpu_counter_read(&wb->stat[WB_DIRTIED_BYTES]) >> PAGE_SHIFT;
+	written = percpu_counter_read(&wb->stat[WB_WRITTEN_BYTES]) >> PAGE_SHIFT;
 
 	/*
 	 * Skip quiet periods when disk bandwidth is under-utilized.
@@ -2435,7 +2435,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
 		inc_wb_stat(wb, WB_RECLAIMABLE);
-		inc_wb_stat(wb, WB_DIRTIED);
+		__add_wb_stat(wb, WB_DIRTIED_BYTES, PAGE_SIZE);
 		task_io_account_write(PAGE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
@@ -2522,7 +2522,7 @@ void account_page_redirty(struct page *page)
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		current->nr_dirtied--;
 		dec_node_page_state(page, NR_DIRTIED);
-		dec_wb_stat(wb, WB_DIRTIED);
+		__add_wb_stat(wb, WB_DIRTIED_BYTES, -(long)PAGE_SIZE);
 		unlocked_inode_to_wb_end(inode, locked);
 	}
 }
@@ -2744,7 +2744,7 @@ int test_clear_page_writeback(struct page *page)
 				struct bdi_writeback *wb = inode_to_wb(inode);
 
 				dec_wb_stat(wb, WB_WRITEBACK);
-				__wb_writeout_inc(wb);
+				__wb_writeout_add(wb, PAGE_SIZE);
 			}
 		}
 
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
