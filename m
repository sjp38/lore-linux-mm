Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5F66B0293
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:23:55 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so23417871qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:55 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id gu9si1638416qcb.24.2015.05.22.15.23.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:23:52 -0700 (PDT)
Received: by qgfa63 with SMTP id a63so17133658qgf.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:52 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 06/19] writeback: consolidate dirty throttle parameters into dirty_throttle_control
Date: Fri, 22 May 2015 18:23:23 -0400
Message-Id: <1432333416-6221-7-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

Dirty throttling implemented in balance_dirty_pages() and its
subroutines makes use of a number of parameters which are passed
around individually.  This renders these functions somewhat unwieldy
and makes it difficult to add or change the involved parameters.  Also
some functions use different or conflicting naming schemes for the
same parameters making the code confusing to follow.

This patch consolidates the main parameters into struct
dirty_throttle_control so that they can be passed around easily and
adding new paramters isn't painful.  This also unifies how a given
parameter is named and accessed.  The drawback of using this type of
control structure rather than explicit paramters is that it isn't
immediately obvious which function accesses and modifies what;
however, it's fairly clear that the benefits outweigh in this case.

GDTC_INIT() macro is provided to ease initializing
dirty_throttle_control for the global_wb_domain and
balance_dirty_pages() uses a separate pointer to point to its global
dirty_throttle_control.  This is to make it uniform with memcg domain
handling which will be added later.

This patch doesn't introduce any behavioral changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 212 +++++++++++++++++++++++++---------------------------
 1 file changed, 101 insertions(+), 111 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 27e60ba..126e3c8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -124,6 +124,20 @@ EXPORT_SYMBOL(laptop_mode);
 
 struct wb_domain global_wb_domain;
 
+/* consolidated parameters for balance_dirty_pages() and its subroutines */
+struct dirty_throttle_control {
+	struct bdi_writeback	*wb;
+
+	unsigned long		dirty;		/* file_dirty + write + nfs */
+	unsigned long		thresh;		/* dirty threshold */
+	unsigned long		bg_thresh;	/* dirty background threshold */
+
+	unsigned long		wb_dirty;	/* per-wb counterparts */
+	unsigned long		wb_thresh;
+};
+
+#define GDTC_INIT(__wb)		.wb = (__wb)
+
 /*
  * Length of period for aging writeout fractions of bdis. This is an
  * arbitrarily chosen number. The longer the period, the slower fractions will
@@ -695,16 +709,13 @@ static long long pos_ratio_polynom(unsigned long setpoint,
  *   card's wb_dirty may rush to many times higher than wb_setpoint.
  * - the wb dirty thresh drops quickly due to change of JBOD workload
  */
-static unsigned long wb_position_ratio(struct bdi_writeback *wb,
-				       unsigned long thresh,
-				       unsigned long bg_thresh,
-				       unsigned long dirty,
-				       unsigned long wb_thresh,
-				       unsigned long wb_dirty)
+static unsigned long wb_position_ratio(struct dirty_throttle_control *dtc)
 {
+	struct bdi_writeback *wb = dtc->wb;
 	unsigned long write_bw = wb->avg_write_bandwidth;
-	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
-	unsigned long limit = hard_dirty_limit(thresh);
+	unsigned long freerun = dirty_freerun_ceiling(dtc->thresh, dtc->bg_thresh);
+	unsigned long limit = hard_dirty_limit(dtc->thresh);
+	unsigned long wb_thresh = dtc->wb_thresh;
 	unsigned long x_intercept;
 	unsigned long setpoint;		/* dirty pages' target balance point */
 	unsigned long wb_setpoint;
@@ -712,7 +723,7 @@ static unsigned long wb_position_ratio(struct bdi_writeback *wb,
 	long long pos_ratio;		/* for scaling up/down the rate limit */
 	long x;
 
-	if (unlikely(dirty >= limit))
+	if (unlikely(dtc->dirty >= limit))
 		return 0;
 
 	/*
@@ -721,7 +732,7 @@ static unsigned long wb_position_ratio(struct bdi_writeback *wb,
 	 * See comment for pos_ratio_polynom().
 	 */
 	setpoint = (freerun + limit) / 2;
-	pos_ratio = pos_ratio_polynom(setpoint, dirty, limit);
+	pos_ratio = pos_ratio_polynom(setpoint, dtc->dirty, limit);
 
 	/*
 	 * The strictlimit feature is a tool preventing mistrusted filesystems
@@ -752,20 +763,21 @@ static unsigned long wb_position_ratio(struct bdi_writeback *wb,
 		long long wb_pos_ratio;
 		unsigned long wb_bg_thresh;
 
-		if (wb_dirty < 8)
+		if (dtc->wb_dirty < 8)
 			return min_t(long long, pos_ratio * 2,
 				     2 << RATELIMIT_CALC_SHIFT);
 
-		if (wb_dirty >= wb_thresh)
+		if (dtc->wb_dirty >= wb_thresh)
 			return 0;
 
-		wb_bg_thresh = div_u64((u64)wb_thresh * bg_thresh, thresh);
+		wb_bg_thresh = div_u64((u64)wb_thresh * dtc->bg_thresh,
+				       dtc->thresh);
 		wb_setpoint = dirty_freerun_ceiling(wb_thresh, wb_bg_thresh);
 
 		if (wb_setpoint == 0 || wb_setpoint == wb_thresh)
 			return 0;
 
-		wb_pos_ratio = pos_ratio_polynom(wb_setpoint, wb_dirty,
+		wb_pos_ratio = pos_ratio_polynom(wb_setpoint, dtc->wb_dirty,
 						 wb_thresh);
 
 		/*
@@ -823,8 +835,8 @@ static unsigned long wb_position_ratio(struct bdi_writeback *wb,
 	 * own size, so move the slope over accordingly and choose a slope that
 	 * yields 100% pos_ratio fluctuation on suddenly doubled wb_thresh.
 	 */
-	if (unlikely(wb_thresh > thresh))
-		wb_thresh = thresh;
+	if (unlikely(wb_thresh > dtc->thresh))
+		wb_thresh = dtc->thresh;
 	/*
 	 * It's very possible that wb_thresh is close to 0 not because the
 	 * device is slow, but that it has remained inactive for long time.
@@ -832,12 +844,12 @@ static unsigned long wb_position_ratio(struct bdi_writeback *wb,
 	 * threshold, so that the occasional writes won't be blocked and active
 	 * writes can rampup the threshold quickly.
 	 */
-	wb_thresh = max(wb_thresh, (limit - dirty) / 8);
+	wb_thresh = max(wb_thresh, (limit - dtc->dirty) / 8);
 	/*
 	 * scale global setpoint to wb's:
 	 *	wb_setpoint = setpoint * wb_thresh / thresh
 	 */
-	x = div_u64((u64)wb_thresh << 16, thresh + 1);
+	x = div_u64((u64)wb_thresh << 16, dtc->thresh + 1);
 	wb_setpoint = setpoint * (u64)x >> 16;
 	/*
 	 * Use span=(8*write_bw) in single wb case as indicated by
@@ -847,12 +859,12 @@ static unsigned long wb_position_ratio(struct bdi_writeback *wb,
 	 * span = --------- * (8 * write_bw) + ------------------ * wb_thresh
 	 *         thresh                           thresh
 	 */
-	span = (thresh - wb_thresh + 8 * write_bw) * (u64)x >> 16;
+	span = (dtc->thresh - wb_thresh + 8 * write_bw) * (u64)x >> 16;
 	x_intercept = wb_setpoint + span;
 
-	if (wb_dirty < x_intercept - span / 4) {
-		pos_ratio = div64_u64(pos_ratio * (x_intercept - wb_dirty),
-				    x_intercept - wb_setpoint + 1);
+	if (dtc->wb_dirty < x_intercept - span / 4) {
+		pos_ratio = div64_u64(pos_ratio * (x_intercept - dtc->wb_dirty),
+				      x_intercept - wb_setpoint + 1);
 	} else
 		pos_ratio /= 4;
 
@@ -862,9 +874,10 @@ static unsigned long wb_position_ratio(struct bdi_writeback *wb,
 	 * than setpoint.
 	 */
 	x_intercept = wb_thresh / 2;
-	if (wb_dirty < x_intercept) {
-		if (wb_dirty > x_intercept / 8)
-			pos_ratio = div_u64(pos_ratio * x_intercept, wb_dirty);
+	if (dtc->wb_dirty < x_intercept) {
+		if (dtc->wb_dirty > x_intercept / 8)
+			pos_ratio = div_u64(pos_ratio * x_intercept,
+					    dtc->wb_dirty);
 		else
 			pos_ratio *= 8;
 	}
@@ -922,9 +935,10 @@ static void wb_update_write_bandwidth(struct bdi_writeback *wb,
 	wb->avg_write_bandwidth = avg;
 }
 
-static void update_dirty_limit(unsigned long thresh, unsigned long dirty)
+static void update_dirty_limit(struct dirty_throttle_control *dtc)
 {
 	struct wb_domain *dom = &global_wb_domain;
+	unsigned long thresh = dtc->thresh;
 	unsigned long limit = dom->dirty_limit;
 
 	/*
@@ -940,7 +954,7 @@ static void update_dirty_limit(unsigned long thresh, unsigned long dirty)
 	 * may drop below dirty. This is exactly the reason to introduce
 	 * dom->dirty_limit which is guaranteed to lie above the dirty pages.
 	 */
-	thresh = max(thresh, dirty);
+	thresh = max(thresh, dtc->dirty);
 	if (limit > thresh) {
 		limit -= (limit - thresh) >> 5;
 		goto update;
@@ -950,8 +964,7 @@ static void update_dirty_limit(unsigned long thresh, unsigned long dirty)
 	dom->dirty_limit = limit;
 }
 
-static void global_update_bandwidth(unsigned long thresh,
-				    unsigned long dirty,
+static void global_update_bandwidth(struct dirty_throttle_control *dtc,
 				    unsigned long now)
 {
 	struct wb_domain *dom = &global_wb_domain;
@@ -964,7 +977,7 @@ static void global_update_bandwidth(unsigned long thresh,
 
 	spin_lock(&dom->lock);
 	if (time_after_eq(now, dom->dirty_limit_tstamp + BANDWIDTH_INTERVAL)) {
-		update_dirty_limit(thresh, dirty);
+		update_dirty_limit(dtc);
 		dom->dirty_limit_tstamp = now;
 	}
 	spin_unlock(&dom->lock);
@@ -976,17 +989,14 @@ static void global_update_bandwidth(unsigned long thresh,
  * Normal wb tasks will be curbed at or below it in long term.
  * Obviously it should be around (write_bw / N) when there are N dd tasks.
  */
-static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
-				      unsigned long thresh,
-				      unsigned long bg_thresh,
-				      unsigned long dirty,
-				      unsigned long wb_thresh,
-				      unsigned long wb_dirty,
+static void wb_update_dirty_ratelimit(struct dirty_throttle_control *dtc,
 				      unsigned long dirtied,
 				      unsigned long elapsed)
 {
-	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
-	unsigned long limit = hard_dirty_limit(thresh);
+	struct bdi_writeback *wb = dtc->wb;
+	unsigned long dirty = dtc->dirty;
+	unsigned long freerun = dirty_freerun_ceiling(dtc->thresh, dtc->bg_thresh);
+	unsigned long limit = hard_dirty_limit(dtc->thresh);
 	unsigned long setpoint = (freerun + limit) / 2;
 	unsigned long write_bw = wb->avg_write_bandwidth;
 	unsigned long dirty_ratelimit = wb->dirty_ratelimit;
@@ -1003,8 +1013,7 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
 	 */
 	dirty_rate = (dirtied - wb->dirtied_stamp) * HZ / elapsed;
 
-	pos_ratio = wb_position_ratio(wb, thresh, bg_thresh, dirty,
-				      wb_thresh, wb_dirty);
+	pos_ratio = wb_position_ratio(dtc);
 	/*
 	 * task_ratelimit reflects each dd's dirty rate for the past 200ms.
 	 */
@@ -1098,12 +1107,12 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
 	 * of backing device (see the implementation of wb_calc_thresh()).
 	 */
 	if (unlikely(wb->bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
-		dirty = wb_dirty;
-		if (wb_dirty < 8)
-			setpoint = wb_dirty + 1;
+		dirty = dtc->wb_dirty;
+		if (dtc->wb_dirty < 8)
+			setpoint = dtc->wb_dirty + 1;
 		else
-			setpoint = (wb_thresh +
-				    wb_calc_thresh(wb, bg_thresh)) / 2;
+			setpoint = (dtc->wb_thresh +
+				    wb_calc_thresh(wb, dtc->bg_thresh)) / 2;
 	}
 
 	if (dirty < setpoint) {
@@ -1140,15 +1149,11 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
 	trace_bdi_dirty_ratelimit(wb->bdi, dirty_rate, task_ratelimit);
 }
 
-static void __wb_update_bandwidth(struct bdi_writeback *wb,
-				  unsigned long thresh,
-				  unsigned long bg_thresh,
-				  unsigned long dirty,
-				  unsigned long wb_thresh,
-				  unsigned long wb_dirty,
+static void __wb_update_bandwidth(struct dirty_throttle_control *dtc,
 				  unsigned long start_time,
 				  bool update_ratelimit)
 {
+	struct bdi_writeback *wb = dtc->wb;
 	unsigned long now = jiffies;
 	unsigned long elapsed = now - wb->bw_time_stamp;
 	unsigned long dirtied;
@@ -1173,10 +1178,8 @@ static void __wb_update_bandwidth(struct bdi_writeback *wb,
 		goto snapshot;
 
 	if (update_ratelimit) {
-		global_update_bandwidth(thresh, dirty, now);
-		wb_update_dirty_ratelimit(wb, thresh, bg_thresh, dirty,
-					  wb_thresh, wb_dirty,
-					  dirtied, elapsed);
+		global_update_bandwidth(dtc, now);
+		wb_update_dirty_ratelimit(dtc, dirtied, elapsed);
 	}
 	wb_update_write_bandwidth(wb, elapsed, written);
 
@@ -1188,7 +1191,9 @@ static void __wb_update_bandwidth(struct bdi_writeback *wb,
 
 void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time)
 {
-	__wb_update_bandwidth(wb, 0, 0, 0, 0, 0, start_time, false);
+	struct dirty_throttle_control gdtc = { GDTC_INIT(wb) };
+
+	__wb_update_bandwidth(&gdtc, start_time, false);
 }
 
 /*
@@ -1302,13 +1307,10 @@ static long wb_min_pause(struct bdi_writeback *wb,
 	return pages >= DIRTY_POLL_THRESH ? 1 + t / 2 : t;
 }
 
-static inline void wb_dirty_limits(struct bdi_writeback *wb,
-				   unsigned long dirty_thresh,
-				   unsigned long background_thresh,
-				   unsigned long *wb_dirty,
-				   unsigned long *wb_thresh,
+static inline void wb_dirty_limits(struct dirty_throttle_control *dtc,
 				   unsigned long *wb_bg_thresh)
 {
+	struct bdi_writeback *wb = dtc->wb;
 	unsigned long wb_reclaimable;
 
 	/*
@@ -1324,12 +1326,12 @@ static inline void wb_dirty_limits(struct bdi_writeback *wb,
 	 *   wb_position_ratio() will let the dirtier task progress
 	 *   at some rate <= (write_bw / 2) for bringing down wb_dirty.
 	 */
-	*wb_thresh = wb_calc_thresh(wb, dirty_thresh);
+	dtc->wb_thresh = wb_calc_thresh(dtc->wb, dtc->thresh);
 
 	if (wb_bg_thresh)
-		*wb_bg_thresh = dirty_thresh ? div_u64((u64)*wb_thresh *
-						       background_thresh,
-						       dirty_thresh) : 0;
+		*wb_bg_thresh = dtc->thresh ? div_u64((u64)dtc->wb_thresh *
+						      dtc->bg_thresh,
+						      dtc->thresh) : 0;
 
 	/*
 	 * In order to avoid the stacked BDI deadlock we need
@@ -1341,12 +1343,12 @@ static inline void wb_dirty_limits(struct bdi_writeback *wb,
 	 * actually dirty; with m+n sitting in the percpu
 	 * deltas.
 	 */
-	if (*wb_thresh < 2 * wb_stat_error(wb)) {
+	if (dtc->wb_thresh < 2 * wb_stat_error(wb)) {
 		wb_reclaimable = wb_stat_sum(wb, WB_RECLAIMABLE);
-		*wb_dirty = wb_reclaimable + wb_stat_sum(wb, WB_WRITEBACK);
+		dtc->wb_dirty = wb_reclaimable + wb_stat_sum(wb, WB_WRITEBACK);
 	} else {
 		wb_reclaimable = wb_stat(wb, WB_RECLAIMABLE);
-		*wb_dirty = wb_reclaimable + wb_stat(wb, WB_WRITEBACK);
+		dtc->wb_dirty = wb_reclaimable + wb_stat(wb, WB_WRITEBACK);
 	}
 }
 
@@ -1361,10 +1363,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 				struct bdi_writeback *wb,
 				unsigned long pages_dirtied)
 {
+	struct dirty_throttle_control gdtc_stor = { GDTC_INIT(wb) };
+	struct dirty_throttle_control * const gdtc = &gdtc_stor;
 	unsigned long nr_reclaimable;	/* = file_dirty + unstable_nfs */
-	unsigned long nr_dirty;  /* = file_dirty + writeback + unstable_nfs */
-	unsigned long background_thresh;
-	unsigned long dirty_thresh;
 	long period;
 	long pause;
 	long max_pause;
@@ -1380,11 +1381,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 
 	for (;;) {
 		unsigned long now = jiffies;
-		unsigned long uninitialized_var(wb_thresh);
-		unsigned long thresh;
-		unsigned long uninitialized_var(wb_dirty);
-		unsigned long dirty;
-		unsigned long bg_thresh;
+		unsigned long dirty, thresh, bg_thresh;
 
 		/*
 		 * Unstable writes are a feature of certain networked
@@ -1394,20 +1391,19 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 */
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
 					global_page_state(NR_UNSTABLE_NFS);
-		nr_dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
+		gdtc->dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
 
-		global_dirty_limits(&background_thresh, &dirty_thresh);
+		global_dirty_limits(&gdtc->bg_thresh, &gdtc->thresh);
 
 		if (unlikely(strictlimit)) {
-			wb_dirty_limits(wb, dirty_thresh, background_thresh,
-					&wb_dirty, &wb_thresh, &bg_thresh);
+			wb_dirty_limits(gdtc, &bg_thresh);
 
-			dirty = wb_dirty;
-			thresh = wb_thresh;
+			dirty = gdtc->wb_dirty;
+			thresh = gdtc->wb_thresh;
 		} else {
-			dirty = nr_dirty;
-			thresh = dirty_thresh;
-			bg_thresh = background_thresh;
+			dirty = gdtc->dirty;
+			thresh = gdtc->thresh;
+			bg_thresh = gdtc->bg_thresh;
 		}
 
 		/*
@@ -1431,31 +1427,25 @@ static void balance_dirty_pages(struct address_space *mapping,
 			wb_start_background_writeback(wb);
 
 		if (!strictlimit)
-			wb_dirty_limits(wb, dirty_thresh, background_thresh,
-					&wb_dirty, &wb_thresh, NULL);
+			wb_dirty_limits(gdtc, NULL);
 
-		dirty_exceeded = (wb_dirty > wb_thresh) &&
-				 ((nr_dirty > dirty_thresh) || strictlimit);
+		dirty_exceeded = (gdtc->wb_dirty > gdtc->wb_thresh) &&
+			((gdtc->dirty > gdtc->thresh) || strictlimit);
 		if (dirty_exceeded && !wb->dirty_exceeded)
 			wb->dirty_exceeded = 1;
 
 		if (time_is_before_jiffies(wb->bw_time_stamp +
 					   BANDWIDTH_INTERVAL)) {
 			spin_lock(&wb->list_lock);
-			__wb_update_bandwidth(wb, dirty_thresh,
-					      background_thresh, nr_dirty,
-					      wb_thresh, wb_dirty, start_time,
-					      true);
+			__wb_update_bandwidth(gdtc, start_time, true);
 			spin_unlock(&wb->list_lock);
 		}
 
 		dirty_ratelimit = wb->dirty_ratelimit;
-		pos_ratio = wb_position_ratio(wb, dirty_thresh,
-					      background_thresh, nr_dirty,
-					      wb_thresh, wb_dirty);
+		pos_ratio = wb_position_ratio(gdtc);
 		task_ratelimit = ((u64)dirty_ratelimit * pos_ratio) >>
 							RATELIMIT_CALC_SHIFT;
-		max_pause = wb_max_pause(wb, wb_dirty);
+		max_pause = wb_max_pause(wb, gdtc->wb_dirty);
 		min_pause = wb_min_pause(wb, max_pause,
 					 task_ratelimit, dirty_ratelimit,
 					 &nr_dirtied_pause);
@@ -1478,11 +1468,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 */
 		if (pause < min_pause) {
 			trace_balance_dirty_pages(bdi,
-						  dirty_thresh,
-						  background_thresh,
-						  nr_dirty,
-						  wb_thresh,
-						  wb_dirty,
+						  gdtc->thresh,
+						  gdtc->bg_thresh,
+						  gdtc->dirty,
+						  gdtc->wb_thresh,
+						  gdtc->wb_dirty,
 						  dirty_ratelimit,
 						  task_ratelimit,
 						  pages_dirtied,
@@ -1507,11 +1497,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 
 pause:
 		trace_balance_dirty_pages(bdi,
-					  dirty_thresh,
-					  background_thresh,
-					  nr_dirty,
-					  wb_thresh,
-					  wb_dirty,
+					  gdtc->thresh,
+					  gdtc->bg_thresh,
+					  gdtc->dirty,
+					  gdtc->wb_thresh,
+					  gdtc->wb_dirty,
 					  dirty_ratelimit,
 					  task_ratelimit,
 					  pages_dirtied,
@@ -1526,8 +1516,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 		current->nr_dirtied_pause = nr_dirtied_pause;
 
 		/*
-		 * This is typically equal to (nr_dirty < dirty_thresh) and can
-		 * also keep "1000+ dd on a slow USB stick" under control.
+		 * This is typically equal to (dirty < thresh) and can also
+		 * keep "1000+ dd on a slow USB stick" under control.
 		 */
 		if (task_ratelimit)
 			break;
@@ -1542,7 +1532,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * more page. However wb_dirty has accounting errors.  So use
 		 * the larger and more IO friendly wb_stat_error.
 		 */
-		if (wb_dirty <= wb_stat_error(wb))
+		if (gdtc->wb_dirty <= wb_stat_error(wb))
 			break;
 
 		if (fatal_signal_pending(current))
@@ -1566,7 +1556,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	if (laptop_mode)
 		return;
 
-	if (nr_reclaimable > background_thresh)
+	if (nr_reclaimable > gdtc->bg_thresh)
 		wb_start_background_writeback(wb);
 }
 
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
