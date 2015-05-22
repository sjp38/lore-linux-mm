Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 973776B0299
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:24:01 -0400 (EDT)
Received: by qgew3 with SMTP id w3so17064725qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:01 -0700 (PDT)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id h13si268984qkh.83.2015.05.22.15.23.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:23:57 -0700 (PDT)
Received: by qgew3 with SMTP id w3so17064104qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:57 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 09/19] writeback: add dirty_throttle_control->pos_ratio
Date: Fri, 22 May 2015 18:23:26 -0400
Message-Id: <1432333416-6221-10-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

wb_position_ratio() is used to calculate pos_ratio, which is used for
two purposes.  wb_update_dirty_ratelimit() uses it to adjust
wb->[balanced_]dirty_ratelimit gradually and balance_dirty_pages() to
immediately adjust dirty_ratelimit right before applying it to
determine pause duration.

While wb_update_dirty_ratelimit() is separately rate limited from
balance_dirty_pages(), on the run where the ratelimit is updated, we
end up calculating pos_ratio twice with the same parameters.

This patch adds dirty_throttle_control->pos_ratio.
balance_dirty_pages() calculates it once per run and
wb_update_dirty_ratelimit() uses the value stored in
dirty_throttle_control.

This removes the duplicate calculation and also will help implementing
memcg wb_domain.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2352c69..fcebae7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -135,6 +135,8 @@ struct dirty_throttle_control {
 	unsigned long		wb_dirty;	/* per-wb counterparts */
 	unsigned long		wb_thresh;
 	unsigned long		wb_bg_thresh;
+
+	unsigned long		pos_ratio;
 };
 
 #define GDTC_INIT(__wb)		.wb = (__wb)
@@ -717,7 +719,7 @@ static long long pos_ratio_polynom(unsigned long setpoint,
  *   card's wb_dirty may rush to many times higher than wb_setpoint.
  * - the wb dirty thresh drops quickly due to change of JBOD workload
  */
-static unsigned long wb_position_ratio(struct dirty_throttle_control *dtc)
+static void wb_position_ratio(struct dirty_throttle_control *dtc)
 {
 	struct bdi_writeback *wb = dtc->wb;
 	unsigned long write_bw = wb->avg_write_bandwidth;
@@ -731,8 +733,10 @@ static unsigned long wb_position_ratio(struct dirty_throttle_control *dtc)
 	long long pos_ratio;		/* for scaling up/down the rate limit */
 	long x;
 
+	dtc->pos_ratio = 0;
+
 	if (unlikely(dtc->dirty >= limit))
-		return 0;
+		return;
 
 	/*
 	 * global setpoint
@@ -770,18 +774,20 @@ static unsigned long wb_position_ratio(struct dirty_throttle_control *dtc)
 	if (unlikely(wb->bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
 		long long wb_pos_ratio;
 
-		if (dtc->wb_dirty < 8)
-			return min_t(long long, pos_ratio * 2,
-				     2 << RATELIMIT_CALC_SHIFT);
+		if (dtc->wb_dirty < 8) {
+			dtc->pos_ratio = min_t(long long, pos_ratio * 2,
+					   2 << RATELIMIT_CALC_SHIFT);
+			return;
+		}
 
 		if (dtc->wb_dirty >= wb_thresh)
-			return 0;
+			return;
 
 		wb_setpoint = dirty_freerun_ceiling(wb_thresh,
 						    dtc->wb_bg_thresh);
 
 		if (wb_setpoint == 0 || wb_setpoint == wb_thresh)
-			return 0;
+			return;
 
 		wb_pos_ratio = pos_ratio_polynom(wb_setpoint, dtc->wb_dirty,
 						 wb_thresh);
@@ -807,7 +813,8 @@ static unsigned long wb_position_ratio(struct dirty_throttle_control *dtc)
 		 * is 2. We might want to tweak this if we observe the control
 		 * system is too slow to adapt.
 		 */
-		return min(pos_ratio, wb_pos_ratio);
+		dtc->pos_ratio = min(pos_ratio, wb_pos_ratio);
+		return;
 	}
 
 	/*
@@ -888,7 +895,7 @@ static unsigned long wb_position_ratio(struct dirty_throttle_control *dtc)
 			pos_ratio *= 8;
 	}
 
-	return pos_ratio;
+	dtc->pos_ratio = pos_ratio;
 }
 
 static void wb_update_write_bandwidth(struct bdi_writeback *wb,
@@ -1009,7 +1016,6 @@ static void wb_update_dirty_ratelimit(struct dirty_throttle_control *dtc,
 	unsigned long dirty_rate;
 	unsigned long task_ratelimit;
 	unsigned long balanced_dirty_ratelimit;
-	unsigned long pos_ratio;
 	unsigned long step;
 	unsigned long x;
 
@@ -1019,12 +1025,11 @@ static void wb_update_dirty_ratelimit(struct dirty_throttle_control *dtc,
 	 */
 	dirty_rate = (dirtied - wb->dirtied_stamp) * HZ / elapsed;
 
-	pos_ratio = wb_position_ratio(dtc);
 	/*
 	 * task_ratelimit reflects each dd's dirty rate for the past 200ms.
 	 */
 	task_ratelimit = (u64)dirty_ratelimit *
-					pos_ratio >> RATELIMIT_CALC_SHIFT;
+					dtc->pos_ratio >> RATELIMIT_CALC_SHIFT;
 	task_ratelimit++; /* it helps rampup dirty_ratelimit from tiny values */
 
 	/*
@@ -1375,7 +1380,6 @@ static void balance_dirty_pages(struct address_space *mapping,
 	bool dirty_exceeded = false;
 	unsigned long task_ratelimit;
 	unsigned long dirty_ratelimit;
-	unsigned long pos_ratio;
 	struct backing_dev_info *bdi = wb->bdi;
 	bool strictlimit = bdi->capabilities & BDI_CAP_STRICTLIMIT;
 	unsigned long start_time = jiffies;
@@ -1433,6 +1437,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 
 		dirty_exceeded = (gdtc->wb_dirty > gdtc->wb_thresh) &&
 			((gdtc->dirty > gdtc->thresh) || strictlimit);
+
+		wb_position_ratio(gdtc);
+
 		if (dirty_exceeded && !wb->dirty_exceeded)
 			wb->dirty_exceeded = 1;
 
@@ -1444,8 +1451,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		}
 
 		dirty_ratelimit = wb->dirty_ratelimit;
-		pos_ratio = wb_position_ratio(gdtc);
-		task_ratelimit = ((u64)dirty_ratelimit * pos_ratio) >>
+		task_ratelimit = ((u64)dirty_ratelimit * gdtc->pos_ratio) >>
 							RATELIMIT_CALC_SHIFT;
 		max_pause = wb_max_pause(wb, gdtc->wb_dirty);
 		min_pause = wb_min_pause(wb, max_pause,
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
