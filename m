Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8D86B00EE
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:04:57 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so31109949qkh.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:04:57 -0700 (PDT)
Received: from mail-qk0-x229.google.com (mail-qk0-x229.google.com. [2607:f8b0:400d:c09::229])
        by mx.google.com with ESMTPS id u16si5137423qge.116.2015.04.06.13.04.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:04:52 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so31172546qkg.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:04:51 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 08/19] writeback: make __wb_calc_thresh() take dirty_throttle_control
Date: Mon,  6 Apr 2015 16:04:23 -0400
Message-Id: <1428350674-8303-9-git-send-email-tj@kernel.org>
In-Reply-To: <1428350674-8303-1-git-send-email-tj@kernel.org>
References: <1428350674-8303-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

wb_calc_thresh() calculates wb_thresh by scaling thresh according to
the wb's portion in the system-wide write bandwidth.  cgroup writeback
support would need to calculate wb_thresh against memcg domain too.
This patch renames wb_calc_thresh() to __wb_calc_thresh() and makes it
take dirty_throttle_control so that the function can later be updated
to calculate against different domains according to
dirty_throttle_control.

wb_calc_thresh() is now a thin wrapper around __wb_calc_thresh().

v2: The original version was incorrectly scaling dtc->dirty instead of
    dtc->thresh.  This was due to the extremely confusing function and
    variable names.  Added a rename patch and fixed this one.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0fe7e60..33b1536 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -557,9 +557,8 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
 }
 
 /**
- * wb_calc_thresh - @wb's share of dirty throttling threshold
- * @wb: bdi_writeback to query
- * @dirty: global dirty limit in pages
+ * __wb_calc_thresh - @wb's share of dirty throttling threshold
+ * @dtc: dirty_throttle_context of interest
  *
  * Returns @wb's dirty limit in pages. The term "dirty" in the context of
  * dirty balancing includes all PG_dirty, PG_writeback and NFS unstable pages.
@@ -578,9 +577,10 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
  * The wb's share of dirty limit will be adapting to its throughput and
  * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
  */
-unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh)
+static unsigned long __wb_calc_thresh(struct dirty_throttle_control *dtc)
 {
 	struct wb_domain *dom = &global_wb_domain;
+	unsigned long thresh = dtc->thresh;
 	u64 wb_thresh;
 	long numerator, denominator;
 	unsigned long wb_min_ratio, wb_max_ratio;
@@ -588,14 +588,14 @@ unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh)
 	/*
 	 * Calculate this BDI's share of the thresh ratio.
 	 */
-	fprop_fraction_percpu(&dom->completions, &wb->completions,
+	fprop_fraction_percpu(&dom->completions, &dtc->wb->completions,
 			      &numerator, &denominator);
 
 	wb_thresh = (thresh * (100 - bdi_min_ratio)) / 100;
 	wb_thresh *= numerator;
 	do_div(wb_thresh, denominator);
 
-	wb_min_max_ratio(wb, &wb_min_ratio, &wb_max_ratio);
+	wb_min_max_ratio(dtc->wb, &wb_min_ratio, &wb_max_ratio);
 
 	wb_thresh += (thresh * wb_min_ratio) / 100;
 	if (wb_thresh > (thresh * wb_max_ratio) / 100)
@@ -604,6 +604,13 @@ unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh)
 	return wb_thresh;
 }
 
+unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh)
+{
+	struct dirty_throttle_control gdtc = { GDTC_INIT(wb),
+					       .thresh = thresh };
+	return __wb_calc_thresh(&gdtc);
+}
+
 /*
  *                           setpoint - dirty 3
  *        f(dirty) := 1.0 + (----------------)
@@ -1323,7 +1330,7 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
 	 *   wb_position_ratio() will let the dirtier task progress
 	 *   at some rate <= (write_bw / 2) for bringing down wb_dirty.
 	 */
-	dtc->wb_thresh = wb_calc_thresh(dtc->wb, dtc->thresh);
+	dtc->wb_thresh = __wb_calc_thresh(dtc);
 	dtc->wb_bg_thresh = dtc->thresh ?
 		div_u64((u64)dtc->wb_thresh * dtc->bg_thresh, dtc->thresh) : 0;
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
