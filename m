Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2FE26B025F
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:57:04 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id 8so17070877qtv.11
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:57:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s17sor5860476qta.39.2017.11.14.13.57.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 13:57:04 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 05/10] writeback: convert the flexible prop stuff to bytes
Date: Tue, 14 Nov 2017 16:56:51 -0500
Message-Id: <1510696616-8489-5-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
References: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

The flexible proportions were all page based, but now that we are doing
metadata writeout that can be smaller or larger than page size we need
to account for this in bytes instead of number of pages.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/backing-dev.c    |  2 +-
 mm/page-writeback.c | 19 ++++++++++++-------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 62a332a91b38..e0d7c62dc0ad 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -832,7 +832,7 @@ static int bdi_init(struct backing_dev_info *bdi)
 	kref_init(&bdi->refcnt);
 	bdi->min_ratio = 0;
 	bdi->max_ratio = 100;
-	bdi->max_prop_frac = FPROP_FRAC_BASE;
+	bdi->max_prop_frac = FPROP_FRAC_BASE * PAGE_SIZE;
 	INIT_LIST_HEAD(&bdi->bdi_list);
 	INIT_LIST_HEAD(&bdi->wb_list);
 	init_waitqueue_head(&bdi->wb_waitq);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e4563645749a..c491dee711a8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -574,11 +574,11 @@ static unsigned long wp_next_time(unsigned long cur_time)
 	return cur_time;
 }
 
-static void wb_domain_writeout_inc(struct wb_domain *dom,
+static void wb_domain_writeout_add(struct wb_domain *dom,
 				   struct fprop_local_percpu *completions,
-				   unsigned int max_prop_frac)
+				   long bytes, unsigned int max_prop_frac)
 {
-	__fprop_inc_percpu_max(&dom->completions, completions,
+	__fprop_add_percpu_max(&dom->completions, completions, bytes,
 			       max_prop_frac);
 	/* First event after period switching was turned off? */
 	if (unlikely(!dom->period_time)) {
@@ -602,12 +602,12 @@ static inline void __wb_writeout_add(struct bdi_writeback *wb, long bytes)
 	struct wb_domain *cgdom;
 
 	__add_wb_stat(wb, WB_WRITTEN_BYTES, bytes);
-	wb_domain_writeout_inc(&global_wb_domain, &wb->completions,
+	wb_domain_writeout_add(&global_wb_domain, &wb->completions, bytes,
 			       wb->bdi->max_prop_frac);
 
 	cgdom = mem_cgroup_wb_domain(wb);
 	if (cgdom)
-		wb_domain_writeout_inc(cgdom, wb_memcg_completions(wb),
+		wb_domain_writeout_add(cgdom, wb_memcg_completions(wb), bytes,
 				       wb->bdi->max_prop_frac);
 }
 
@@ -646,6 +646,7 @@ static void writeout_period(unsigned long t)
 
 int wb_domain_init(struct wb_domain *dom, gfp_t gfp)
 {
+	int ret;
 	memset(dom, 0, sizeof(*dom));
 
 	spin_lock_init(&dom->lock);
@@ -655,7 +656,10 @@ int wb_domain_init(struct wb_domain *dom, gfp_t gfp)
 
 	dom->dirty_limit_tstamp = jiffies;
 
-	return fprop_global_init(&dom->completions, gfp);
+	ret = fprop_global_init(&dom->completions, gfp);
+	if (!ret)
+		dom->completions.batch_size *= PAGE_SIZE;
+	return ret;
 }
 
 #ifdef CONFIG_CGROUP_WRITEBACK
@@ -706,7 +710,8 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
 		ret = -EINVAL;
 	} else {
 		bdi->max_ratio = max_ratio;
-		bdi->max_prop_frac = (FPROP_FRAC_BASE * max_ratio) / 100;
+		bdi->max_prop_frac = ((FPROP_FRAC_BASE * max_ratio) / 100) *
+			PAGE_SIZE;
 	}
 	spin_unlock_bh(&bdi_lock);
 
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
