Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 327976B028B
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:23:46 -0400 (EDT)
Received: by qgew3 with SMTP id w3so17062016qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:46 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id z9si2539584qcn.27.2015.05.22.15.23.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:23:44 -0700 (PDT)
Received: by qgez61 with SMTP id z61so17112233qge.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:43 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 02/19] writeback: clean up wb_dirty_limit()
Date: Fri, 22 May 2015 18:23:19 -0400
Message-Id: <1432333416-6221-3-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

The function name wb_dirty_limit(), its argument @dirty and the local
variable @wb_dirty are mortally confusing given that the function
calculates per-wb threshold value not dirty pages, especially given
that @dirty and @wb_dirty are used elsewhere for dirty pages.

Let's rename the function to wb_calc_thresh() and wb_dirty to
wb_thresh.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c         |  2 +-
 include/linux/writeback.h |  2 +-
 mm/backing-dev.c          |  6 +++---
 mm/page-writeback.c       | 30 +++++++++++++++---------------
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 881ea5d..b1b3b81 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1081,7 +1081,7 @@ static bool over_bground_thresh(struct bdi_writeback *wb)
 	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
 		return true;
 
-	if (wb_stat(wb, WB_RECLAIMABLE) > wb_dirty_limit(wb, background_thresh))
+	if (wb_stat(wb, WB_RECLAIMABLE) > wb_calc_thresh(wb, background_thresh))
 		return true;
 
 	return false;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 23af355..0435c85 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -155,7 +155,7 @@ int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 				      void __user *, size_t *, loff_t *);
 
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
-unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty);
+unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh);
 
 void __wb_update_bandwidth(struct bdi_writeback *wb,
 			   unsigned long thresh,
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index ad5608d..9c8b7b5 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -49,7 +49,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	struct bdi_writeback *wb = &bdi->wb;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
-	unsigned long bdi_thresh;
+	unsigned long wb_thresh;
 	unsigned long nr_dirty, nr_io, nr_more_io, nr_dirty_time;
 	struct inode *inode;
 
@@ -67,7 +67,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	spin_unlock(&wb->list_lock);
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
-	bdi_thresh = wb_dirty_limit(wb, dirty_thresh);
+	wb_thresh = wb_calc_thresh(wb, dirty_thresh);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
@@ -87,7 +87,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "state:              %10lx\n",
 		   (unsigned long) K(wb_stat(wb, WB_WRITEBACK)),
 		   (unsigned long) K(wb_stat(wb, WB_RECLAIMABLE)),
-		   K(bdi_thresh),
+		   K(wb_thresh),
 		   K(dirty_thresh),
 		   K(background_thresh),
 		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 70cf98d..c7745a7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -556,7 +556,7 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
 }
 
 /**
- * wb_dirty_limit - @wb's share of dirty throttling threshold
+ * wb_calc_thresh - @wb's share of dirty throttling threshold
  * @wb: bdi_writeback to query
  * @dirty: global dirty limit in pages
  *
@@ -577,28 +577,28 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
  * The wb's share of dirty limit will be adapting to its throughput and
  * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
  */
-unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty)
+unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh)
 {
-	u64 wb_dirty;
+	u64 wb_thresh;
 	long numerator, denominator;
 	unsigned long wb_min_ratio, wb_max_ratio;
 
 	/*
-	 * Calculate this BDI's share of the dirty ratio.
+	 * Calculate this BDI's share of the thresh ratio.
 	 */
 	wb_writeout_fraction(wb, &numerator, &denominator);
 
-	wb_dirty = (dirty * (100 - bdi_min_ratio)) / 100;
-	wb_dirty *= numerator;
-	do_div(wb_dirty, denominator);
+	wb_thresh = (thresh * (100 - bdi_min_ratio)) / 100;
+	wb_thresh *= numerator;
+	do_div(wb_thresh, denominator);
 
 	wb_min_max_ratio(wb, &wb_min_ratio, &wb_max_ratio);
 
-	wb_dirty += (dirty * wb_min_ratio) / 100;
-	if (wb_dirty > (dirty * wb_max_ratio) / 100)
-		wb_dirty = dirty * wb_max_ratio / 100;
+	wb_thresh += (thresh * wb_min_ratio) / 100;
+	if (wb_thresh > (thresh * wb_max_ratio) / 100)
+		wb_thresh = thresh * wb_max_ratio / 100;
 
-	return wb_dirty;
+	return wb_thresh;
 }
 
 /*
@@ -750,7 +750,7 @@ static unsigned long wb_position_ratio(struct bdi_writeback *wb,
 	 * total amount of RAM is 16GB, bdi->max_ratio is equal to 1%, global
 	 * limits are set by default to 10% and 20% (background and throttle).
 	 * Then wb_thresh is 1% of 20% of 16GB. This amounts to ~8K pages.
-	 * wb_dirty_limit(wb, bg_thresh) is about ~4K pages. wb_setpoint is
+	 * wb_calc_thresh(wb, bg_thresh) is about ~4K pages. wb_setpoint is
 	 * about ~6K pages (as the average of background and throttle wb
 	 * limits). The 3rd order polynomial will provide positive feedback if
 	 * wb_dirty is under wb_setpoint and vice versa.
@@ -1115,7 +1115,7 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
 	 *
 	 * We rampup dirty_ratelimit forcibly if wb_dirty is low because
 	 * it's possible that wb_thresh is close to zero due to inactivity
-	 * of backing device (see the implementation of wb_dirty_limit()).
+	 * of backing device (see the implementation of wb_calc_thresh()).
 	 */
 	if (unlikely(wb->bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
 		dirty = wb_dirty;
@@ -1123,7 +1123,7 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
 			setpoint = wb_dirty + 1;
 		else
 			setpoint = (wb_thresh +
-				    wb_dirty_limit(wb, bg_thresh)) / 2;
+				    wb_calc_thresh(wb, bg_thresh)) / 2;
 	}
 
 	if (dirty < setpoint) {
@@ -1352,7 +1352,7 @@ static inline void wb_dirty_limits(struct bdi_writeback *wb,
 	 *   wb_position_ratio() will let the dirtier task progress
 	 *   at some rate <= (write_bw / 2) for bringing down wb_dirty.
 	 */
-	*wb_thresh = wb_dirty_limit(wb, dirty_thresh);
+	*wb_thresh = wb_calc_thresh(wb, dirty_thresh);
 
 	if (wb_bg_thresh)
 		*wb_bg_thresh = dirty_thresh ? div_u64((u64)*wb_thresh *
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
