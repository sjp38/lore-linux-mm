Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC1026B0263
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 16:44:32 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id s7so4835286pal.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:44:32 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x123si17266638pgb.17.2016.10.24.13.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 13:44:32 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 2/5] writeback: convert WB_WRITTEN/WB_DIRITED counters to bytes
Date: Mon, 24 Oct 2016 16:43:46 -0400
Message-ID: <1477341829-18673-3-git-send-email-jbacik@fb.com>
In-Reply-To: <1477341829-18673-1-git-send-email-jbacik@fb.com>
References: <1477341829-18673-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, kernel-team@fb.com, david@fromorbit.org, jack@suse.cz, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, hch@infradead.org, jweiner@fb.com

These are counters that constantly go up in order to do bandwidth calculations.
It isn't important what the units are in, as long as they are consistent between
the two of them, so convert them to count bytes written/dirtied, and allow the
metadata accounting stuff to change the counters as well.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 fs/fuse/file.c                   |  4 ++--
 include/linux/backing-dev-defs.h |  4 ++--
 include/linux/backing-dev.h      |  2 +-
 mm/backing-dev.c                 |  9 +++++----
 mm/page-writeback.c              | 26 +++++++++++++++-----------
 5 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 3988b43..81eee7e 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1467,7 +1467,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
 	for (i = 0; i < req->num_pages; i++) {
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
 		dec_node_page_state(req->pages[i], NR_WRITEBACK_TEMP);
-		wb_writeout_inc(&bdi->wb);
+		wb_writeout_add(&bdi->wb, PAGE_SIZE);
 	}
 	wake_up(&fi->page_waitq);
 }
@@ -1771,7 +1771,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK_TEMP);
-		wb_writeout_inc(&bdi->wb);
+		wb_writeout_add(&bdi->wb, PAGE_SIZE);
 		fuse_writepage_free(fc, new_req);
 		fuse_request_free(new_req);
 		goto out;
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index c357f27..71ea5a6 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -34,8 +34,8 @@ typedef int (congested_fn)(void *, int);
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
index 9eb2cf2..edddcb8 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -114,7 +114,7 @@ static inline s64 wb_stat_sum(struct bdi_writeback *wb, enum wb_stat_item item)
 	return sum;
 }
 
-extern void wb_writeout_inc(struct bdi_writeback *wb);
+extern void wb_writeout_add(struct bdi_writeback *wb, long bytes);
 
 /*
  * maximal error of a stat counter.
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 8fde443..433db42 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -70,14 +70,15 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
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
@@ -90,8 +91,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
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
index 121a6e3..e09b3ad 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -596,11 +596,11 @@ static void wb_domain_writeout_inc(struct wb_domain *dom,
  * Increment @wb's writeout completion count and the global writeout
  * completion count. Called from test_clear_page_writeback().
  */
-static inline void __wb_writeout_inc(struct bdi_writeback *wb)
+static inline void __wb_writeout_inc(struct bdi_writeback *wb, long bytes)
 {
 	struct wb_domain *cgdom;
 
-	__inc_wb_stat(wb, WB_WRITTEN);
+	__add_wb_stat(wb, WB_WRITTEN_BYTES, bytes);
 	wb_domain_writeout_inc(&global_wb_domain, &wb->completions,
 			       wb->bdi->max_prop_frac);
 
@@ -610,15 +610,15 @@ static inline void __wb_writeout_inc(struct bdi_writeback *wb)
 				       wb->bdi->max_prop_frac);
 }
 
-void wb_writeout_inc(struct bdi_writeback *wb)
+void wb_writeout_add(struct bdi_writeback *wb, long bytes)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__wb_writeout_inc(wb);
+	__wb_writeout_inc(wb, bytes);
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
@@ -2464,7 +2464,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
-		__inc_wb_stat(wb, WB_DIRTIED);
+		__add_wb_stat(wb, WB_DIRTIED_BYTES, PAGE_SIZE);
 		task_io_account_write(PAGE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
@@ -2547,12 +2547,16 @@ void account_page_redirty(struct page *page)
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
+		unsigned long flags;
 		bool locked;
 
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		current->nr_dirtied--;
-		dec_node_page_state(page, NR_DIRTIED);
-		dec_wb_stat(wb, WB_DIRTIED);
+
+		local_irq_save(flags);
+		__dec_node_page_state(page, NR_DIRTIED);
+		__add_wb_stat(wb, WB_DIRTIED_BYTES, -(long)PAGE_SIZE);
+		local_irq_restore(flags);
 		unlocked_inode_to_wb_end(inode, locked);
 	}
 }
@@ -2772,7 +2776,7 @@ int test_clear_page_writeback(struct page *page)
 				struct bdi_writeback *wb = inode_to_wb(inode);
 
 				__dec_wb_stat(wb, WB_WRITEBACK);
-				__wb_writeout_inc(wb);
+				__wb_writeout_inc(wb, PAGE_SIZE);
 			}
 		}
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
