Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4DF6B0260
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 16:58:33 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s64so24312312lfs.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:58:33 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id n187si9568946wmf.44.2016.09.20.13.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 13:58:27 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 3/4] writeback: convert WB_WRITTEN/WB_DIRITED counters to bytes
Date: Tue, 20 Sep 2016 16:57:47 -0400
Message-ID: <1474405068-27841-4-git-send-email-jbacik@fb.com>
In-Reply-To: <1474405068-27841-1-git-send-email-jbacik@fb.com>
References: <1474405068-27841-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org, hannes@cmpxchg.org

These are counters that constantly go up in order to do bandwidth calculations.
It isn't important what the units are in, as long as they are consistent between
the two of them, so convert them to count bytes written/dirtied, and allow the
metadata accounting stuff to change the counters as well.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 fs/fuse/file.c                   |  4 ++--
 include/linux/backing-dev-defs.h |  4 ++--
 include/linux/backing-dev.h      |  2 +-
 mm/backing-dev.c                 |  8 ++++----
 mm/page-writeback.c              | 26 ++++++++++++++++----------
 5 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index f394aff..3f5991e 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1466,7 +1466,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
 	for (i = 0; i < req->num_pages; i++) {
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
 		dec_node_page_state(req->pages[i], NR_WRITEBACK_TEMP);
-		wb_writeout_inc(&bdi->wb);
+		wb_writeout_inc(&bdi->wb, PAGE_SIZE);
 	}
 	wake_up(&fi->page_waitq);
 }
@@ -1770,7 +1770,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK_TEMP);
-		wb_writeout_inc(&bdi->wb);
+		wb_writeout_inc(&bdi->wb, PAGE_SIZE);
 		fuse_writepage_free(fc, new_req);
 		fuse_request_free(new_req);
 		goto out;
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 1a7c3c1..cef0f24 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -36,8 +36,8 @@ enum wb_stat_item {
 	WB_WRITEBACK,
 	WB_METADATA_DIRTY_BYTES,
 	WB_METADATA_WRITEBACK_BYTES,
-	WB_DIRTIED,
-	WB_WRITTEN,
+	WB_DIRTIED_BYTES,
+	WB_WRITTEN_BYTES,
 	NR_WB_STAT_ITEMS
 };
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 089acf6..742238a 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -113,7 +113,7 @@ static inline s64 wb_stat_sum(struct bdi_writeback *wb, enum wb_stat_item item)
 	return sum;
 }
 
-extern void wb_writeout_inc(struct bdi_writeback *wb);
+extern void wb_writeout_inc(struct bdi_writeback *wb, long bytes);
 
 /*
  * maximal error of a stat counter.
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index d76f432..f0695b0 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -77,8 +77,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BdiDirtyThresh:     %10lu kB\n"
 		   "DirtyThresh:        %10lu kB\n"
 		   "BackgroundThresh:   %10lu kB\n"
-		   "BdiDirtied:         %10lu kB\n"
-		   "BdiWritten:         %10lu kB\n"
+		   "BdiDirtiedBytes:    %10lu kB\n"
+		   "BdiWrittenBytes:    %10lu kB\n"
 		   "BdiMetadataDirty:   %10lu kB\n"
 		   "BdiMetaWriteback:	%10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
@@ -93,8 +93,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(wb_thresh),
 		   K(dirty_thresh),
 		   K(background_thresh),
-		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
-		   (unsigned long) K(wb_stat(wb, WB_WRITTEN)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_DIRTIED_BYTES)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_WRITTEN_BYTES)),
 		   (unsigned long) BtoK(wb_stat(wb, WB_METADATA_DIRTY_BYTES)),
 		   (unsigned long) BtoK(wb_stat(wb, WB_METADATA_WRITEBACK_BYTES)),
 		   (unsigned long) K(wb->write_bandwidth),
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 423d2f5..6d08673 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -624,11 +624,11 @@ static void wb_domain_writeout_inc(struct wb_domain *dom,
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
 
@@ -638,12 +638,12 @@ static inline void __wb_writeout_inc(struct bdi_writeback *wb)
 				       wb->bdi->max_prop_frac);
 }
 
-void wb_writeout_inc(struct bdi_writeback *wb)
+void wb_writeout_inc(struct bdi_writeback *wb, long bytes)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__wb_writeout_inc(wb);
+	__wb_writeout_inc(wb, bytes);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL_GPL(wb_writeout_inc);
@@ -1390,8 +1390,8 @@ static void __wb_update_bandwidth(struct dirty_throttle_control *gdtc,
 	if (elapsed < BANDWIDTH_INTERVAL)
 		return;
 
-	dirtied = percpu_counter_read(&wb->stat[WB_DIRTIED]);
-	written = percpu_counter_read(&wb->stat[WB_WRITTEN]);
+	dirtied = percpu_counter_read(&wb->stat[WB_DIRTIED_BYTES]);
+	written = percpu_counter_read(&wb->stat[WB_WRITTEN_BYTES]);
 
 	/*
 	 * Skip quiet periods when disk bandwidth is under-utilized.
@@ -2497,7 +2497,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
-		__inc_wb_stat(wb, WB_DIRTIED);
+		__add_wb_stat(wb, WB_DIRTIED_BYTES, PAGE_SIZE);
 		task_io_account_write(PAGE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
@@ -2523,6 +2523,7 @@ void account_metadata_dirtied(struct page *page, struct backing_dev_info *bdi,
 	__mod_node_page_state(page_pgdat(page), NR_METADATA_DIRTY_BYTES,
 			      bytes);
 	__add_wb_stat(&bdi->wb, WB_METADATA_DIRTY_BYTES, bytes);
+	__add_wb_stat(&bdi->wb, WB_DIRTIED_BYTES, bytes);
 	current->nr_dirtied++;
 	task_io_account_write(bytes);
 	this_cpu_inc(bdp_ratelimits);
@@ -2593,6 +2594,7 @@ void account_metadata_end_writeback(struct page *page,
 	__add_wb_stat(&bdi->wb, WB_METADATA_WRITEBACK_BYTES, -bytes);
 	__mod_node_page_state(page_pgdat(page), NR_METADATA_WRITEBACK_BYTES,
 					 -bytes);
+	__add_wb_stat(&bdi->wb, WB_WRITTEN_BYTES, bytes);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(account_metadata_end_writeback);
@@ -2672,12 +2674,16 @@ void account_page_redirty(struct page *page)
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
+		__add_wb_stat(wb, WB_DIRTIED_BYTES, -PAGE_SIZE);
+		local_irq_restore(flags);
 		unlocked_inode_to_wb_end(inode, locked);
 	}
 }
@@ -2897,7 +2903,7 @@ int test_clear_page_writeback(struct page *page)
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
