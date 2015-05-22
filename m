Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF936B0296
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:23:57 -0400 (EDT)
Received: by qgez61 with SMTP id z61so17114532qge.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:57 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id n5si1973633qgf.100.2015.05.22.15.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:23:54 -0700 (PDT)
Received: by qget53 with SMTP id t53so17043257qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:54 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 07/19] writeback: add dirty_throttle_control->wb_bg_thresh
Date: Fri, 22 May 2015 18:23:24 -0400
Message-Id: <1432333416-6221-8-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

wb_bg_thresh is currently treated as a second-class citizen.  It's
only used when BDI_CAP_STRICTLIMIT is set and balance_dirty_pages()
doesn't calculate it unless the cap is set.  When the cap is set, the
calculated value is not passed around but instead recalculated
whenever it's used.

wb_position_ratio() calculates it by scaling wb_thresh proportional to
bg_thresh / thresh.  wb_update_dirty_ratelimit() uses wb_dirty_limit()
on bg_thresh, which should generally lead to a similar result as the
proportional scaling but can also be way off in the presence of
max/min_ratio settings.

Avoiding wb_bg_thresh calculation saves us one u64 multiplication and
divsion when BDI_CAP_STRICTLIMIT is not set.  Given that
balance_dirty_pages() is already ratelimited, this doesn't justify the
incurred extra complexity.

This patch adds wb_bg_thresh to dirty_throttle_control and makes
wb_dirty_limits() always calculate it and updates the users to use the
pre-calculated value.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 27 +++++++++++----------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 126e3c8..3ec9223 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -134,6 +134,7 @@ struct dirty_throttle_control {
 
 	unsigned long		wb_dirty;	/* per-wb counterparts */
 	unsigned long		wb_thresh;
+	unsigned long		wb_bg_thresh;
 };
 
 #define GDTC_INIT(__wb)		.wb = (__wb)
@@ -761,7 +762,6 @@ static unsigned long wb_position_ratio(struct dirty_throttle_control *dtc)
 	 */
 	if (unlikely(wb->bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
 		long long wb_pos_ratio;
-		unsigned long wb_bg_thresh;
 
 		if (dtc->wb_dirty < 8)
 			return min_t(long long, pos_ratio * 2,
@@ -770,9 +770,8 @@ static unsigned long wb_position_ratio(struct dirty_throttle_control *dtc)
 		if (dtc->wb_dirty >= wb_thresh)
 			return 0;
 
-		wb_bg_thresh = div_u64((u64)wb_thresh * dtc->bg_thresh,
-				       dtc->thresh);
-		wb_setpoint = dirty_freerun_ceiling(wb_thresh, wb_bg_thresh);
+		wb_setpoint = dirty_freerun_ceiling(wb_thresh,
+						    dtc->wb_bg_thresh);
 
 		if (wb_setpoint == 0 || wb_setpoint == wb_thresh)
 			return 0;
@@ -1104,15 +1103,14 @@ static void wb_update_dirty_ratelimit(struct dirty_throttle_control *dtc,
 	 *
 	 * We rampup dirty_ratelimit forcibly if wb_dirty is low because
 	 * it's possible that wb_thresh is close to zero due to inactivity
-	 * of backing device (see the implementation of wb_calc_thresh()).
+	 * of backing device.
 	 */
 	if (unlikely(wb->bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
 		dirty = dtc->wb_dirty;
 		if (dtc->wb_dirty < 8)
 			setpoint = dtc->wb_dirty + 1;
 		else
-			setpoint = (dtc->wb_thresh +
-				    wb_calc_thresh(wb, dtc->bg_thresh)) / 2;
+			setpoint = (dtc->wb_thresh + dtc->wb_bg_thresh) / 2;
 	}
 
 	if (dirty < setpoint) {
@@ -1307,8 +1305,7 @@ static long wb_min_pause(struct bdi_writeback *wb,
 	return pages >= DIRTY_POLL_THRESH ? 1 + t / 2 : t;
 }
 
-static inline void wb_dirty_limits(struct dirty_throttle_control *dtc,
-				   unsigned long *wb_bg_thresh)
+static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
 {
 	struct bdi_writeback *wb = dtc->wb;
 	unsigned long wb_reclaimable;
@@ -1327,11 +1324,8 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc,
 	 *   at some rate <= (write_bw / 2) for bringing down wb_dirty.
 	 */
 	dtc->wb_thresh = wb_calc_thresh(dtc->wb, dtc->thresh);
-
-	if (wb_bg_thresh)
-		*wb_bg_thresh = dtc->thresh ? div_u64((u64)dtc->wb_thresh *
-						      dtc->bg_thresh,
-						      dtc->thresh) : 0;
+	dtc->wb_bg_thresh = dtc->thresh ?
+		div_u64((u64)dtc->wb_thresh * dtc->bg_thresh, dtc->thresh) : 0;
 
 	/*
 	 * In order to avoid the stacked BDI deadlock we need
@@ -1396,10 +1390,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 		global_dirty_limits(&gdtc->bg_thresh, &gdtc->thresh);
 
 		if (unlikely(strictlimit)) {
-			wb_dirty_limits(gdtc, &bg_thresh);
+			wb_dirty_limits(gdtc);
 
 			dirty = gdtc->wb_dirty;
 			thresh = gdtc->wb_thresh;
+			bg_thresh = gdtc->wb_bg_thresh;
 		} else {
 			dirty = gdtc->dirty;
 			thresh = gdtc->thresh;
@@ -1427,7 +1422,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			wb_start_background_writeback(wb);
 
 		if (!strictlimit)
-			wb_dirty_limits(gdtc, NULL);
+			wb_dirty_limits(gdtc);
 
 		dirty_exceeded = (gdtc->wb_dirty > gdtc->wb_thresh) &&
 			((gdtc->dirty > gdtc->thresh) || strictlimit);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
