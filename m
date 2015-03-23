Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id EB2B6828FD
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:07:57 -0400 (EDT)
Received: by qcbkw5 with SMTP id kw5so136951793qcb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:07:57 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com. [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id 1si11183921qgh.89.2015.03.22.22.07.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 22:07:57 -0700 (PDT)
Received: by qcay5 with SMTP id y5so46455468qca.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:07:57 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 02/18] writeback: reorganize [__]wb_update_bandwidth()
Date: Mon, 23 Mar 2015 01:07:31 -0400
Message-Id: <1427087267-16592-3-git-send-email-tj@kernel.org>
In-Reply-To: <1427087267-16592-1-git-send-email-tj@kernel.org>
References: <1427087267-16592-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

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
index 890cff1..3d9b360 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1079,16 +1079,6 @@ static bool over_bground_thresh(struct bdi_writeback *wb)
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
index 75349bb..82e0e39 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -154,14 +154,7 @@ int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty);
 
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
index fd441ea..d9ebabe 100644
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
@@ -1203,20 +1206,9 @@ snapshot:
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
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
