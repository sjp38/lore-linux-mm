Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 11712828FD
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:08:07 -0400 (EDT)
Received: by qgf74 with SMTP id 74so11565269qgf.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:08:06 -0700 (PDT)
Received: from mail-qg0-x235.google.com (mail-qg0-x235.google.com. [2607:f8b0:400d:c04::235])
        by mx.google.com with ESMTPS id 78si11238226qgk.31.2015.03.22.22.08.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 22:08:06 -0700 (PDT)
Received: by qgez102 with SMTP id z102so48466601qge.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:08:05 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 07/18] writeback: make __wb_dirty_limit() take dirty_throttle_control
Date: Mon, 23 Mar 2015 01:07:36 -0400
Message-Id: <1427087267-16592-8-git-send-email-tj@kernel.org>
In-Reply-To: <1427087267-16592-1-git-send-email-tj@kernel.org>
References: <1427087267-16592-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

wb_dirty_limit() calculates wb_dirty by scaling thresh according to
the wb's portion in the system-wide write bandwidth.  cgroup writeback
support would need to calculate wb_dirty against memcg domain too.
This patch renames wb_dirty_limit() to __wb_dirty_limit() and makes it
take dirty_throttle_control so that the function can later be updated
to calculate against different domains according to
dirty_throttle_control.

wb_dirty_limit() is now a thin wrapper around __wb_dirty_limit().

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 00218e9..a4b6dab 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -557,9 +557,8 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
 }
 
 /**
- * wb_dirty_limit - @wb's share of dirty throttling threshold
- * @wb: bdi_writeback to query
- * @dirty: global dirty limit in pages
+ * __wb_dirty_limit - @wb's share of dirty throttling threshold
+ * @dtc: dirty_throttle_context of interest
  *
  * Returns @wb's dirty limit in pages. The term "dirty" in the context of
  * dirty balancing includes all PG_dirty, PG_writeback and NFS unstable pages.
@@ -578,9 +577,10 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
  * The wb's share of dirty limit will be adapting to its throughput and
  * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
  */
-unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty)
+static unsigned long __wb_dirty_limit(struct dirty_throttle_control *dtc)
 {
 	struct wb_domain *dom = &global_wb_domain;
+	unsigned long dirty = dtc->dirty;
 	u64 wb_dirty;
 	long numerator, denominator;
 	unsigned long wb_min_ratio, wb_max_ratio;
@@ -588,14 +588,14 @@ unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty)
 	/*
 	 * Calculate this BDI's share of the dirty ratio.
 	 */
-	fprop_fraction_percpu(&dom->completions, &wb->completions,
+	fprop_fraction_percpu(&dom->completions, &dtc->wb->completions,
 			      &numerator, &denominator);
 
 	wb_dirty = (dirty * (100 - bdi_min_ratio)) / 100;
 	wb_dirty *= numerator;
 	do_div(wb_dirty, denominator);
 
-	wb_min_max_ratio(wb, &wb_min_ratio, &wb_max_ratio);
+	wb_min_max_ratio(dtc->wb, &wb_min_ratio, &wb_max_ratio);
 
 	wb_dirty += (dirty * wb_min_ratio) / 100;
 	if (wb_dirty > (dirty * wb_max_ratio) / 100)
@@ -604,6 +604,13 @@ unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty)
 	return wb_dirty;
 }
 
+unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty)
+{
+	struct dirty_throttle_control gdtc = { GDTC_INIT(wb), .dirty = dirty };
+
+	return __wb_dirty_limit(&gdtc);
+}
+
 /*
  *                           setpoint - dirty 3
  *        f(dirty) := 1.0 + (----------------)
@@ -1323,7 +1330,7 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
 	 *   wb_position_ratio() will let the dirtier task progress
 	 *   at some rate <= (write_bw / 2) for bringing down wb_dirty.
 	 */
-	dtc->wb_thresh = wb_dirty_limit(dtc->wb, dtc->thresh);
+	dtc->wb_thresh = __wb_dirty_limit(dtc);
 	dtc->wb_bg_thresh = dtc->thresh ?
 		div_u64((u64)dtc->wb_thresh * dtc->bg_thresh, dtc->thresh) : 0;
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
