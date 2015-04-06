Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 645286B00F3
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:05:04 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so14972109qge.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:05:04 -0700 (PDT)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id w7si5154554qha.66.2015.04.06.13.04.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:04:57 -0700 (PDT)
Received: by qcbii10 with SMTP id ii10so15224999qcb.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:04:56 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 11/19] writeback: add dirty_throttle_control->dom
Date: Mon,  6 Apr 2015 16:04:26 -0400
Message-Id: <1428350674-8303-12-git-send-email-tj@kernel.org>
In-Reply-To: <1428350674-8303-1-git-send-email-tj@kernel.org>
References: <1428350674-8303-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Currently all dirty throttle operations use global_wb_domain; however,
cgroup writeback support requires considering per-memcg wb_domain too.
This patch adds dirty_throttle_control->dom and updates functions
which are directly using globabl_wb_domain to use it instead.

As this makes global_update_bandwidth() a misnomer, the function is
renamed to domain_update_bandwidth().

This patch doesn't introduce any behavioral changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 30 ++++++++++++++++++++++++------
 1 file changed, 24 insertions(+), 6 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 15771a6..4024db1 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -126,6 +126,9 @@ struct wb_domain global_wb_domain;
 
 /* consolidated parameters for balance_dirty_pages() and its subroutines */
 struct dirty_throttle_control {
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct wb_domain	*dom;
+#endif
 	struct bdi_writeback	*wb;
 	struct fprop_local_percpu *wb_completions;
 
@@ -140,7 +143,7 @@ struct dirty_throttle_control {
 	unsigned long		pos_ratio;
 };
 
-#define GDTC_INIT(__wb)		.wb = (__wb),				\
+#define DTC_INIT_COMMON(__wb)	.wb = (__wb),				\
 				.wb_completions = &(__wb)->completions
 
 /*
@@ -152,6 +155,14 @@ struct dirty_throttle_control {
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
+#define GDTC_INIT(__wb)		.dom = &global_wb_domain,		\
+				DTC_INIT_COMMON(__wb)
+
+static struct wb_domain *dtc_dom(struct dirty_throttle_control *dtc)
+{
+	return dtc->dom;
+}
+
 static void wb_min_max_ratio(struct bdi_writeback *wb,
 			     unsigned long *minp, unsigned long *maxp)
 {
@@ -181,6 +192,13 @@ static void wb_min_max_ratio(struct bdi_writeback *wb,
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
+#define GDTC_INIT(__wb)		DTC_INIT_COMMON(__wb)
+
+static struct wb_domain *dtc_dom(struct dirty_throttle_control *dtc)
+{
+	return &global_wb_domain;
+}
+
 static void wb_min_max_ratio(struct bdi_writeback *wb,
 			     unsigned long *minp, unsigned long *maxp)
 {
@@ -583,7 +601,7 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
  */
 static unsigned long __wb_calc_thresh(struct dirty_throttle_control *dtc)
 {
-	struct wb_domain *dom = &global_wb_domain;
+	struct wb_domain *dom = dtc_dom(dtc);
 	unsigned long thresh = dtc->thresh;
 	u64 wb_thresh;
 	long numerator, denominator;
@@ -952,7 +970,7 @@ out:
 
 static void update_dirty_limit(struct dirty_throttle_control *dtc)
 {
-	struct wb_domain *dom = &global_wb_domain;
+	struct wb_domain *dom = dtc_dom(dtc);
 	unsigned long thresh = dtc->thresh;
 	unsigned long limit = dom->dirty_limit;
 
@@ -979,10 +997,10 @@ update:
 	dom->dirty_limit = limit;
 }
 
-static void global_update_bandwidth(struct dirty_throttle_control *dtc,
+static void domain_update_bandwidth(struct dirty_throttle_control *dtc,
 				    unsigned long now)
 {
-	struct wb_domain *dom = &global_wb_domain;
+	struct wb_domain *dom = dtc_dom(dtc);
 
 	/*
 	 * check locklessly first to optimize away locking for the most time
@@ -1190,7 +1208,7 @@ static void __wb_update_bandwidth(struct dirty_throttle_control *dtc,
 		goto snapshot;
 
 	if (update_ratelimit) {
-		global_update_bandwidth(dtc, now);
+		domain_update_bandwidth(dtc, now);
 		wb_update_dirty_ratelimit(dtc, dirtied, elapsed);
 	}
 	wb_update_write_bandwidth(wb, elapsed, written);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
