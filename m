Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id E36436B0132
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:46 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id p6so60594qcv.34
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:46 -0800 (PST)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com. [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id h45si65730796qgd.59.2015.01.06.13.26.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:46 -0800 (PST)
Received: by mail-qa0-f53.google.com with SMTP id j7so187198qaq.12
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:45 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 09/45] writeback: make congestion functions per bdi_writeback
Date: Tue,  6 Jan 2015 16:25:46 -0500
Message-Id: <1420579582-8516-10-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

Currently, all congestion functions take bdi (backing_dev_info) and
always operate on the root wb (bdi->wb) and the congestion state from
the block layer is propagated only for the root blkcg.  This patch
introduces {set|clear}_wb_congested() and wb_congested() which take
@wb and operate on it.  The bdi counteparts are now wrappers invoking
the wb based functions on @bdi->wb.

While converting clear_bdi_congested() to clear_wb_congested(), the
local variable declaration order between @wqh and @bit is swapped for
cosmetic reason.

This patch just adds the new wb based functions.  The following
patches will apply them.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev-defs.h | 14 +++++++++++--
 include/linux/backing-dev.h      | 43 +++++++++++++++++++++++-----------------
 mm/backing-dev.c                 | 22 ++++++++++----------
 3 files changed, 48 insertions(+), 31 deletions(-)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 511066f..54a3a9c 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -122,7 +122,17 @@ enum {
 	BLK_RW_SYNC	= 1,
 };
 
-void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
-void set_bdi_congested(struct backing_dev_info *bdi, int sync);
+void clear_wb_congested(struct bdi_writeback *wb, int sync);
+void set_wb_congested(struct bdi_writeback *wb, int sync);
+
+static inline void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
+{
+	clear_wb_congested(&bdi->wb, sync);
+}
+
+static inline void set_bdi_congested(struct backing_dev_info *bdi, int sync)
+{
+	set_wb_congested(&bdi->wb, sync);
+}
 
 #endif	/* __LINUX_BACKING_DEV_DEFS_H */
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 3722796..be66668 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -182,27 +182,13 @@ extern struct backing_dev_info noop_backing_dev_info;
 
 int writeback_in_progress(struct backing_dev_info *bdi);
 
-static inline int bdi_congested(struct backing_dev_info *bdi, int bdi_bits)
+static inline int wb_congested(struct bdi_writeback *wb, int bdi_bits)
 {
+	struct backing_dev_info *bdi = wb->bdi;
+
 	if (bdi->congested_fn)
 		return bdi->congested_fn(bdi->congested_data, bdi_bits);
-	return (bdi->wb.state & bdi_bits);
-}
-
-static inline int bdi_read_congested(struct backing_dev_info *bdi)
-{
-	return bdi_congested(bdi, 1 << WB_sync_congested);
-}
-
-static inline int bdi_write_congested(struct backing_dev_info *bdi)
-{
-	return bdi_congested(bdi, 1 << WB_async_congested);
-}
-
-static inline int bdi_rw_congested(struct backing_dev_info *bdi)
-{
-	return bdi_congested(bdi, (1 << WB_sync_congested) |
-				  (1 << WB_async_congested));
+	return wb->state & bdi_bits;
 }
 
 long congestion_wait(int sync, long timeout);
@@ -422,4 +408,25 @@ static inline struct bdi_writeback *page_cgwb_wb(struct page *page)
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
+static inline int bdi_congested(struct backing_dev_info *bdi, int bdi_bits)
+{
+	return wb_congested(&bdi->wb, bdi_bits);
+}
+
+static inline int bdi_read_congested(struct backing_dev_info *bdi)
+{
+	return bdi_congested(bdi, 1 << WB_sync_congested);
+}
+
+static inline int bdi_write_congested(struct backing_dev_info *bdi)
+{
+	return bdi_congested(bdi, 1 << WB_async_congested);
+}
+
+static inline int bdi_rw_congested(struct backing_dev_info *bdi)
+{
+	return bdi_congested(bdi, (1 << WB_sync_congested) |
+				  (1 << WB_async_congested));
+}
+
 #endif		/* _LINUX_BACKING_DEV_H */
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index c6dda82..2851278 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -767,31 +767,31 @@ static wait_queue_head_t congestion_wqh[2] = {
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
 	};
-static atomic_t nr_bdi_congested[2];
+static atomic_t nr_wb_congested[2];
 
-void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
+void clear_wb_congested(struct bdi_writeback *wb, int sync)
 {
-	enum wb_state bit;
 	wait_queue_head_t *wqh = &congestion_wqh[sync];
+	enum wb_state bit;
 
 	bit = sync ? WB_sync_congested : WB_async_congested;
-	if (test_and_clear_bit(bit, &bdi->wb.state))
-		atomic_dec(&nr_bdi_congested[sync]);
+	if (test_and_clear_bit(bit, &wb->state))
+		atomic_dec(&nr_wb_congested[sync]);
 	smp_mb__after_atomic();
 	if (waitqueue_active(wqh))
 		wake_up(wqh);
 }
-EXPORT_SYMBOL(clear_bdi_congested);
+EXPORT_SYMBOL(clear_wb_congested);
 
-void set_bdi_congested(struct backing_dev_info *bdi, int sync)
+void set_wb_congested(struct bdi_writeback *wb, int sync)
 {
 	enum wb_state bit;
 
 	bit = sync ? WB_sync_congested : WB_async_congested;
-	if (!test_and_set_bit(bit, &bdi->wb.state))
-		atomic_inc(&nr_bdi_congested[sync]);
+	if (!test_and_set_bit(bit, &wb->state))
+		atomic_inc(&nr_wb_congested[sync]);
 }
-EXPORT_SYMBOL(set_bdi_congested);
+EXPORT_SYMBOL(set_wb_congested);
 
 /**
  * congestion_wait - wait for a backing_dev to become uncongested
@@ -850,7 +850,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 	 * encountered in the current zone, yield if necessary instead
 	 * of sleeping on the congestion queue
 	 */
-	if (atomic_read(&nr_bdi_congested[sync]) == 0 ||
+	if (atomic_read(&nr_wb_congested[sync]) == 0 ||
 	    !test_bit(ZONE_CONGESTED, &zone->flags)) {
 		cond_resched();
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
