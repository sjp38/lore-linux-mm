Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5F16B02B4
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:23:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so5041178wrf.5
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:23:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i9si1304962wmb.164.2017.06.22.07.23.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 07:23:33 -0700 (PDT)
From: Nikolay Borisov <nborisov@suse.com>
Subject: [PATCH 2/4] writeback: convert WB_WRITTEN/WB_DIRITED counters to bytes
Date: Thu, 22 Jun 2017 17:23:22 +0300
Message-Id: <1498141404-18807-3-git-send-email-nborisov@suse.com>
In-Reply-To: <1498141404-18807-1-git-send-email-nborisov@suse.com>
References: <1498141404-18807-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: jbacik@fb.com, jack@suse.cz, jeffm@suse.com, chandan@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, axboe@kernel.dk, Nikolay Borisov <nborisov@suse.com>

From: Josef Bacik <jbacik@fb.com>

These are counters that constantly go up in order to do bandwidth calculations.
It isn't important what the units are in, as long as they are consistent between
the two of them, so convert them to count bytes written/dirtied, and allow the
metadata accounting stuff to change the counters as well. Additionally, scale
WB_STAT_BATCH based on whether we are incrementing byte-based or page-based
counters.

Signed-off-by: Josef Bacik <jbacik@fb.com>
Signed-off-by: Nikolay Borisov <nborisov@suse.com>
---

Changes since previous posting [1]:

 - Incorporated Jan Kara's feedback to rename __wb_writeout_inc to 
 __wb_writeout_add. 

 - Eliminated IRQ clustering in account_page_dirtied() by  converting
 inc_wb_stat to __add_wb_stat since the latter is already irq-safe. This was 
 requested by Tejun. 

 - After talking privately with Jan he mentioned that the way the percpu 
 counters were used to account bytes could lead to constant hit of the slow 
 path. This is due to the WB_STAT_BATCH not being scaled for bytes. I've 
 implemented a very simple logic to do that in __add_wb_stat

 - Forward ported to 4.12.-rc6

One thing which will likely have to change with this patch is the fact that 
currently wb_completion count assume that each completion has done 4k worth of 
pages. With subpage blocksize however a completion needn't have written 4k. As
such he suggested to convert the accounting in wb_domain to explicitly track 
number of bytes written in a period and not completions per-period. He was 
afraid of skewing happening. Tejun, what's your take on that ? 

This patch had an ack from Tejun previously but due to my changes I haven't 
added it. 

[1] https://patchwork.kernel.org/patch/9395219/

 fs/fuse/file.c                   |  4 ++--
 include/linux/backing-dev-defs.h |  4 ++--
 include/linux/backing-dev.h      | 20 ++++++++++++++++++--
 mm/backing-dev.c                 |  9 +++++----
 mm/page-writeback.c              | 20 ++++++++++----------
 5 files changed, 37 insertions(+), 20 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 3ee4fdc3da9e..2521f70ab8a6 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1463,7 +1463,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
 	for (i = 0; i < req->num_pages; i++) {
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
 		dec_node_page_state(req->pages[i], NR_WRITEBACK_TEMP);
-		wb_writeout_inc(&bdi->wb);
+		wb_writeout_add(&bdi->wb, PAGE_SIZE);
 	}
 	wake_up(&fi->page_waitq);
 }
@@ -1767,7 +1767,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 
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
index bdedea9be0a6..8b5a2e98b779 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -66,7 +66,23 @@ static inline bool bdi_has_dirty_io(struct backing_dev_info *bdi)
 static inline void __add_wb_stat(struct bdi_writeback *wb,
 				 enum wb_stat_item item, s64 amount)
 {
-	percpu_counter_add_batch(&wb->stat[item], amount, WB_STAT_BATCH);
+	s32 batch_size;
+
+	/*
+	 * When woring with bytes scale the batch size to reduce hitting
+	 * the slow path in the percpu counter
+	 */
+	switch (item) {
+	case WB_DIRTIED_BYTES:
+	case WB_WRITTEN_BYTES:
+		batch_size = WB_STAT_BATCH << PAGE_SHIFT;
+		break;
+	default:
+		batch_size = WB_STAT_BATCH;
+		break;
+
+	}
+	percpu_counter_add_batch(&wb->stat[item], amount, batch_size);
 }
 
 static inline void inc_wb_stat(struct bdi_writeback *wb, enum wb_stat_item item)
@@ -102,7 +118,7 @@ static inline s64 wb_stat_sum(struct bdi_writeback *wb, enum wb_stat_item item)
 	return sum;
 }
 
-extern void wb_writeout_inc(struct bdi_writeback *wb);
+extern void wb_writeout_add(struct bdi_writeback *wb, long bytes);
 
 /*
  * maximal error of a stat counter.
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 0c09dd103109..2eef55428654 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -67,14 +67,15 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	global_dirty_limits(&background_thresh, &dirty_thresh);
 	wb_thresh = wb_calc_thresh(wb, dirty_thresh);
 
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
@@ -87,8 +88,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   PtoK(wb_thresh),
 		   PtoK(dirty_thresh),
 		   PtoK(background_thresh),
-		   (unsigned long) PtoK(wb_stat(wb, WB_DIRTIED)),
-		   (unsigned long) PtoK(wb_stat(wb, WB_WRITTEN)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_DIRTIED_BYTES)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_WRITTEN_BYTES)),
 		   (unsigned long) PtoK(wb->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b96198926a1e..7e9fa012797f 100644
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
@@ -2437,7 +2437,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
 		inc_wb_stat(wb, WB_RECLAIMABLE);
-		inc_wb_stat(wb, WB_DIRTIED);
+		__add_wb_stat(wb, WB_DIRTIED_BYTES, PAGE_SIZE);
 		task_io_account_write(PAGE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
@@ -2525,7 +2525,7 @@ void account_page_redirty(struct page *page)
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		current->nr_dirtied--;
 		dec_node_page_state(page, NR_DIRTIED);
-		dec_wb_stat(wb, WB_DIRTIED);
+		__add_wb_stat(wb, WB_DIRTIED_BYTES, -(long)PAGE_SIZE);
 		unlocked_inode_to_wb_end(inode, locked);
 	}
 }
@@ -2745,7 +2745,7 @@ int test_clear_page_writeback(struct page *page)
 				struct bdi_writeback *wb = inode_to_wb(inode);
 
 				dec_wb_stat(wb, WB_WRITEBACK);
-				__wb_writeout_inc(wb);
+				__wb_writeout_add(wb, PAGE_SIZE);
 			}
 		}
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
