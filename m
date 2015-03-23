Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id A3E7E828FD
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:08:11 -0400 (EDT)
Received: by qcbjx9 with SMTP id jx9so98131302qcb.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:08:11 -0700 (PDT)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com. [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id 195si11161246qhw.115.2015.03.22.22.08.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 22:08:11 -0700 (PDT)
Received: by qcbkw5 with SMTP id kw5so136954002qcb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:08:10 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 10/18] writeback: add dirty_throttle_control->dom
Date: Mon, 23 Mar 2015 01:07:39 -0400
Message-Id: <1427087267-16592-11-git-send-email-tj@kernel.org>
In-Reply-To: <1427087267-16592-1-git-send-email-tj@kernel.org>
References: <1427087267-16592-1-git-send-email-tj@kernel.org>
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
index 1f216cf..840b8f2 100644
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
 static unsigned long __wb_dirty_limit(struct dirty_throttle_control *dtc)
 {
-	struct wb_domain *dom = &global_wb_domain;
+	struct wb_domain *dom = dtc_dom(dtc);
 	unsigned long dirty = dtc->dirty;
 	u64 wb_dirty;
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
