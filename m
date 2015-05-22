Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4CCD06B028D
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:23:48 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so23397775qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:48 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id i38si3855087qkh.110.2015.05.22.15.23.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:23:46 -0700 (PDT)
Received: by qget53 with SMTP id t53so17041804qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:45 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 03/19] writeback: reorganize [__]wb_update_bandwidth()
Date: Fri, 22 May 2015 18:23:20 -0400
Message-Id: <1432333416-6221-4-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

__wb_update_bandwidth() is called from two places -
fs/fs-writeback.c::balance_dirty_pages() and
mm/page-writeback.c::wb_writeback().  The latter updates only the
write bandwidth while the former also deals with the dirty ratelimit.
The two callsites are distinguished by whether @thresh parameter is
zero or not, which is cryptic.  In addition, the two files define
their own different versions of wb_update_bandwidth() on top of
__wb_update_bandwidth(), which is confusing to say the least.  This
patch cleans up [__]wb_update_bandwidth() in the following ways.

* __wb_update_bandwidth() now takes explicit @update_ratelimit
  parameter to gate dirty ratelimit handling.

* mm/page-writeback.c::wb_update_bandwidth() is flattened into its
  caller - balance_dirty_pages().

* fs/fs-writeback.c::wb_update_bandwidth() is moved to
  mm/page-writeback.c and __wb_update_bandwidth() is made static.

* While at it, add a lockdep assertion to __wb_update_bandwidth().

Except for the lockdep addition, this is pure reorganization and
doesn't introduce any behavioral changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c         | 10 ----------
 include/linux/writeback.h |  9 +--------
 mm/page-writeback.c       | 45 ++++++++++++++++++++++-----------------------
 3 files changed, 23 insertions(+), 41 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index b1b3b81..cd89484 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1088,16 +1088,6 @@ static bool over_bground_thresh(struct bdi_writeback *wb)
 }
 
 /*
- * Called under wb->list_lock. If there are multiple wb per bdi,
- * only the flusher working on the first wb should do it.
- */
-static void wb_update_bandwidth(struct bdi_writeback *wb,
-				unsigned long start_time)
-{
-	__wb_update_bandwidth(wb, 0, 0, 0, 0, 0, start_time);
-}
-
-/*
  * Explicit flushing or periodic writeback of "old" data.
  *
  * Define "old": the first time one of an inode's pages is dirtied, we mark the
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 0435c85..80adf3d 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -157,14 +157,7 @@ int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh);
 
-void __wb_update_bandwidth(struct bdi_writeback *wb,
-			   unsigned long thresh,
-			   unsigned long bg_thresh,
-			   unsigned long dirty,
-			   unsigned long bdi_thresh,
-			   unsigned long bdi_dirty,
-			   unsigned long start_time);
-
+void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time);
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited(struct address_space *mapping);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c7745a7..bebdd41 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1160,19 +1160,22 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
 	trace_bdi_dirty_ratelimit(wb->bdi, dirty_rate, task_ratelimit);
 }
 
-void __wb_update_bandwidth(struct bdi_writeback *wb,
-			   unsigned long thresh,
-			   unsigned long bg_thresh,
-			   unsigned long dirty,
-			   unsigned long wb_thresh,
-			   unsigned long wb_dirty,
-			   unsigned long start_time)
+static void __wb_update_bandwidth(struct bdi_writeback *wb,
+				  unsigned long thresh,
+				  unsigned long bg_thresh,
+				  unsigned long dirty,
+				  unsigned long wb_thresh,
+				  unsigned long wb_dirty,
+				  unsigned long start_time,
+				  bool update_ratelimit)
 {
 	unsigned long now = jiffies;
 	unsigned long elapsed = now - wb->bw_time_stamp;
 	unsigned long dirtied;
 	unsigned long written;
 
+	lockdep_assert_held(&wb->list_lock);
+
 	/*
 	 * rate-limit, only update once every 200ms.
 	 */
@@ -1189,7 +1192,7 @@ void __wb_update_bandwidth(struct bdi_writeback *wb,
 	if (elapsed > HZ && time_before(wb->bw_time_stamp, start_time))
 		goto snapshot;
 
-	if (thresh) {
+	if (update_ratelimit) {
 		global_update_bandwidth(thresh, dirty, now);
 		wb_update_dirty_ratelimit(wb, thresh, bg_thresh, dirty,
 					  wb_thresh, wb_dirty,
@@ -1203,20 +1206,9 @@ void __wb_update_bandwidth(struct bdi_writeback *wb,
 	wb->bw_time_stamp = now;
 }
 
-static void wb_update_bandwidth(struct bdi_writeback *wb,
-				unsigned long thresh,
-				unsigned long bg_thresh,
-				unsigned long dirty,
-				unsigned long wb_thresh,
-				unsigned long wb_dirty,
-				unsigned long start_time)
+void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time)
 {
-	if (time_is_after_eq_jiffies(wb->bw_time_stamp + BANDWIDTH_INTERVAL))
-		return;
-	spin_lock(&wb->list_lock);
-	__wb_update_bandwidth(wb, thresh, bg_thresh, dirty,
-			      wb_thresh, wb_dirty, start_time);
-	spin_unlock(&wb->list_lock);
+	__wb_update_bandwidth(wb, 0, 0, 0, 0, 0, start_time, false);
 }
 
 /*
@@ -1467,8 +1459,15 @@ static void balance_dirty_pages(struct address_space *mapping,
 		if (dirty_exceeded && !wb->dirty_exceeded)
 			wb->dirty_exceeded = 1;
 
-		wb_update_bandwidth(wb, dirty_thresh, background_thresh,
-				    nr_dirty, wb_thresh, wb_dirty, start_time);
+		if (time_is_before_jiffies(wb->bw_time_stamp +
+					   BANDWIDTH_INTERVAL)) {
+			spin_lock(&wb->list_lock);
+			__wb_update_bandwidth(wb, dirty_thresh,
+					      background_thresh, nr_dirty,
+					      wb_thresh, wb_dirty, start_time,
+					      true);
+			spin_unlock(&wb->list_lock);
+		}
 
 		dirty_ratelimit = wb->dirty_ratelimit;
 		pos_ratio = wb_position_ratio(wb, dirty_thresh,
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
