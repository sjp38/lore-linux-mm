Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 689066B00F5
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:05:08 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so15212210qcy.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:05:08 -0700 (PDT)
Received: from mail-qc0-x22e.google.com (mail-qc0-x22e.google.com. [2607:f8b0:400d:c01::22e])
        by mx.google.com with ESMTPS id z3si5145981qhd.94.2015.04.06.13.04.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:04:59 -0700 (PDT)
Received: by qcgx3 with SMTP id x3so15149582qcg.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:04:58 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 12/19] writeback: make __wb_writeout_inc() and hard_dirty_limit() take wb_domaas a parameter
Date: Mon,  6 Apr 2015 16:04:27 -0400
Message-Id: <1428350674-8303-13-git-send-email-tj@kernel.org>
In-Reply-To: <1428350674-8303-1-git-send-email-tj@kernel.org>
References: <1428350674-8303-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Currently __wb_writeout_inc() and hard_dirty_limit() assume
global_wb_domain; however, cgroup writeback support requires
considering per-memcg wb_domain too.

This patch separates out domain-specific part of __wb_writeout_inc()
into wb_domain_writeout_inc() which takes wb_domain as a parameter and
adds the parameter to hard_dirty_limit().  This will allow these two
functions to handle per-memcg wb_domains.

This patch doesn't introduce any behavioral changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 4024db1..2d718e6 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -445,17 +445,12 @@ static unsigned long wp_next_time(unsigned long cur_time)
 	return cur_time;
 }
 
-/*
- * Increment the wb's writeout completion count and the global writeout
- * completion count. Called from test_clear_page_writeback().
- */
-static inline void __wb_writeout_inc(struct bdi_writeback *wb)
+static void wb_domain_writeout_inc(struct wb_domain *dom,
+				   struct fprop_local_percpu *completions,
+				   unsigned int max_prop_frac)
 {
-	struct wb_domain *dom = &global_wb_domain;
-
-	__inc_wb_stat(wb, WB_WRITTEN);
-	__fprop_inc_percpu_max(&dom->completions, &wb->completions,
-			       wb->bdi->max_prop_frac);
+	__fprop_inc_percpu_max(&dom->completions, completions,
+			       max_prop_frac);
 	/* First event after period switching was turned off? */
 	if (!unlikely(dom->period_time)) {
 		/*
@@ -469,6 +464,17 @@ static inline void __wb_writeout_inc(struct bdi_writeback *wb)
 	}
 }
 
+/*
+ * Increment @wb's writeout completion count and the global writeout
+ * completion count. Called from test_clear_page_writeback().
+ */
+static inline void __wb_writeout_inc(struct bdi_writeback *wb)
+{
+	__inc_wb_stat(wb, WB_WRITTEN);
+	wb_domain_writeout_inc(&global_wb_domain, &wb->completions,
+			       wb->bdi->max_prop_frac);
+}
+
 void wb_writeout_inc(struct bdi_writeback *wb)
 {
 	unsigned long flags;
@@ -571,10 +577,9 @@ static unsigned long dirty_freerun_ceiling(unsigned long thresh,
 	return (thresh + bg_thresh) / 2;
 }
 
-static unsigned long hard_dirty_limit(unsigned long thresh)
+static unsigned long hard_dirty_limit(struct wb_domain *dom,
+				      unsigned long thresh)
 {
-	struct wb_domain *dom = &global_wb_domain;
-
 	return max(thresh, dom->dirty_limit);
 }
 
@@ -744,7 +749,7 @@ static void wb_position_ratio(struct dirty_throttle_control *dtc)
 	struct bdi_writeback *wb = dtc->wb;
 	unsigned long write_bw = wb->avg_write_bandwidth;
 	unsigned long freerun = dirty_freerun_ceiling(dtc->thresh, dtc->bg_thresh);
-	unsigned long limit = hard_dirty_limit(dtc->thresh);
+	unsigned long limit = hard_dirty_limit(dtc_dom(dtc), dtc->thresh);
 	unsigned long wb_thresh = dtc->wb_thresh;
 	unsigned long x_intercept;
 	unsigned long setpoint;		/* dirty pages' target balance point */
@@ -1029,7 +1034,7 @@ static void wb_update_dirty_ratelimit(struct dirty_throttle_control *dtc,
 	struct bdi_writeback *wb = dtc->wb;
 	unsigned long dirty = dtc->dirty;
 	unsigned long freerun = dirty_freerun_ceiling(dtc->thresh, dtc->bg_thresh);
-	unsigned long limit = hard_dirty_limit(dtc->thresh);
+	unsigned long limit = hard_dirty_limit(dtc_dom(dtc), dtc->thresh);
 	unsigned long setpoint = (freerun + limit) / 2;
 	unsigned long write_bw = wb->avg_write_bandwidth;
 	unsigned long dirty_ratelimit = wb->dirty_ratelimit;
@@ -1681,7 +1686,7 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 
         for ( ; ; ) {
 		global_dirty_limits(&background_thresh, &dirty_thresh);
-		dirty_thresh = hard_dirty_limit(dirty_thresh);
+		dirty_thresh = hard_dirty_limit(&global_wb_domain, dirty_thresh);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
