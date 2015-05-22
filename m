Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 212246B0291
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:23:53 -0400 (EDT)
Received: by qgew3 with SMTP id w3so17063268qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:53 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id y15si3901050qky.39.2015.05.22.15.23.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:23:51 -0700 (PDT)
Received: by qget53 with SMTP id t53so17042640qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:50 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 05/19] writeback: move global_dirty_limit into wb_domain
Date: Fri, 22 May 2015 18:23:22 -0400
Message-Id: <1432333416-6221-6-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

This patch is a part of the series to define wb_domain which
represents a domain that wb's (bdi_writeback's) belong to and are
measured against each other in.  This will enable IO backpressure
propagation for cgroup writeback.

global_dirty_limit exists to regulate the global dirty threshold which
is a property of the wb_domain.  This patch moves hard_dirty_limit,
dirty_lock, and update_time into wb_domain.

This is pure reorganization and doesn't introduce any behavioral
changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c                |  2 +-
 include/linux/writeback.h        | 17 ++++++++++++++-
 include/trace/events/writeback.h |  7 +++---
 mm/page-writeback.c              | 46 ++++++++++++++++++++--------------------
 4 files changed, 44 insertions(+), 28 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index cd89484..51c8a5b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -887,7 +887,7 @@ static long writeback_chunk_size(struct bdi_writeback *wb,
 		pages = LONG_MAX;
 	else {
 		pages = min(wb->avg_write_bandwidth / 2,
-			    global_dirty_limit / DIRTY_SCOPE);
+			    global_wb_domain.dirty_limit / DIRTY_SCOPE);
 		pages = min(pages, work->nr_pages);
 		pages = round_down(pages + MIN_WRITEBACK_PAGES,
 				   MIN_WRITEBACK_PAGES);
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 3148db1..5fdd4e1 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -95,6 +95,8 @@ struct writeback_control {
  * dirtyable memory accordingly.
  */
 struct wb_domain {
+	spinlock_t lock;
+
 	/*
 	 * Scale the writeback cache size proportional to the relative
 	 * writeout speed.
@@ -115,6 +117,19 @@ struct wb_domain {
 	struct fprop_global completions;
 	struct timer_list period_timer;	/* timer for aging of completions */
 	unsigned long period_time;
+
+	/*
+	 * The dirtyable memory and dirty threshold could be suddenly
+	 * knocked down by a large amount (eg. on the startup of KVM in a
+	 * swapless system). This may throw the system into deep dirty
+	 * exceeded state and throttle heavy/light dirtiers alike. To
+	 * retain good responsiveness, maintain global_dirty_limit for
+	 * tracking slowly down to the knocked down dirty threshold.
+	 *
+	 * Both fields are protected by ->lock.
+	 */
+	unsigned long dirty_limit_tstamp;
+	unsigned long dirty_limit;
 };
 
 /*
@@ -153,7 +168,7 @@ void throttle_vm_writeout(gfp_t gfp_mask);
 bool zone_dirty_ok(struct zone *zone);
 int wb_domain_init(struct wb_domain *dom, gfp_t gfp);
 
-extern unsigned long global_dirty_limit;
+extern struct wb_domain global_wb_domain;
 
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 9b876f6..bec6999 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -361,7 +361,7 @@ TRACE_EVENT(global_dirty_state,
 		__entry->nr_written	= global_page_state(NR_WRITTEN);
 		__entry->background_thresh = background_thresh;
 		__entry->dirty_thresh	= dirty_thresh;
-		__entry->dirty_limit = global_dirty_limit;
+		__entry->dirty_limit	= global_wb_domain.dirty_limit;
 	),
 
 	TP_printk("dirty=%lu writeback=%lu unstable=%lu "
@@ -463,8 +463,9 @@ TRACE_EVENT(balance_dirty_pages,
 		unsigned long freerun = (thresh + bg_thresh) / 2;
 		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
 
-		__entry->limit		= global_dirty_limit;
-		__entry->setpoint	= (global_dirty_limit + freerun) / 2;
+		__entry->limit		= global_wb_domain.dirty_limit;
+		__entry->setpoint	= (global_wb_domain.dirty_limit +
+						freerun) / 2;
 		__entry->dirty		= dirty;
 		__entry->bdi_setpoint	= __entry->setpoint *
 						bdi_thresh / (thresh + 1);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 08e1737..27e60ba 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -122,9 +122,7 @@ EXPORT_SYMBOL(laptop_mode);
 
 /* End of sysctl-exported parameters */
 
-unsigned long global_dirty_limit;
-
-static struct wb_domain global_wb_domain;
+struct wb_domain global_wb_domain;
 
 /*
  * Length of period for aging writeout fractions of bdis. This is an
@@ -470,9 +468,15 @@ static void writeout_period(unsigned long t)
 int wb_domain_init(struct wb_domain *dom, gfp_t gfp)
 {
 	memset(dom, 0, sizeof(*dom));
+
+	spin_lock_init(&dom->lock);
+
 	init_timer_deferrable(&dom->period_timer);
 	dom->period_timer.function = writeout_period;
 	dom->period_timer.data = (unsigned long)dom;
+
+	dom->dirty_limit_tstamp = jiffies;
+
 	return fprop_global_init(&dom->completions, gfp);
 }
 
@@ -532,7 +536,9 @@ static unsigned long dirty_freerun_ceiling(unsigned long thresh,
 
 static unsigned long hard_dirty_limit(unsigned long thresh)
 {
-	return max(thresh, global_dirty_limit);
+	struct wb_domain *dom = &global_wb_domain;
+
+	return max(thresh, dom->dirty_limit);
 }
 
 /**
@@ -916,17 +922,10 @@ static void wb_update_write_bandwidth(struct bdi_writeback *wb,
 	wb->avg_write_bandwidth = avg;
 }
 
-/*
- * The global dirtyable memory and dirty threshold could be suddenly knocked
- * down by a large amount (eg. on the startup of KVM in a swapless system).
- * This may throw the system into deep dirty exceeded state and throttle
- * heavy/light dirtiers alike. To retain good responsiveness, maintain
- * global_dirty_limit for tracking slowly down to the knocked down dirty
- * threshold.
- */
 static void update_dirty_limit(unsigned long thresh, unsigned long dirty)
 {
-	unsigned long limit = global_dirty_limit;
+	struct wb_domain *dom = &global_wb_domain;
+	unsigned long limit = dom->dirty_limit;
 
 	/*
 	 * Follow up in one step.
@@ -939,7 +938,7 @@ static void update_dirty_limit(unsigned long thresh, unsigned long dirty)
 	/*
 	 * Follow down slowly. Use the higher one as the target, because thresh
 	 * may drop below dirty. This is exactly the reason to introduce
-	 * global_dirty_limit which is guaranteed to lie above the dirty pages.
+	 * dom->dirty_limit which is guaranteed to lie above the dirty pages.
 	 */
 	thresh = max(thresh, dirty);
 	if (limit > thresh) {
@@ -948,28 +947,27 @@ static void update_dirty_limit(unsigned long thresh, unsigned long dirty)
 	}
 	return;
 update:
-	global_dirty_limit = limit;
+	dom->dirty_limit = limit;
 }
 
 static void global_update_bandwidth(unsigned long thresh,
 				    unsigned long dirty,
 				    unsigned long now)
 {
-	static DEFINE_SPINLOCK(dirty_lock);
-	static unsigned long update_time = INITIAL_JIFFIES;
+	struct wb_domain *dom = &global_wb_domain;
 
 	/*
 	 * check locklessly first to optimize away locking for the most time
 	 */
-	if (time_before(now, update_time + BANDWIDTH_INTERVAL))
+	if (time_before(now, dom->dirty_limit_tstamp + BANDWIDTH_INTERVAL))
 		return;
 
-	spin_lock(&dirty_lock);
-	if (time_after_eq(now, update_time + BANDWIDTH_INTERVAL)) {
+	spin_lock(&dom->lock);
+	if (time_after_eq(now, dom->dirty_limit_tstamp + BANDWIDTH_INTERVAL)) {
 		update_dirty_limit(thresh, dirty);
-		update_time = now;
+		dom->dirty_limit_tstamp = now;
 	}
-	spin_unlock(&dirty_lock);
+	spin_unlock(&dom->lock);
 }
 
 /*
@@ -1761,10 +1759,12 @@ void laptop_sync_completion(void)
 
 void writeback_set_ratelimit(void)
 {
+	struct wb_domain *dom = &global_wb_domain;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
+
 	global_dirty_limits(&background_thresh, &dirty_thresh);
-	global_dirty_limit = dirty_thresh;
+	dom->dirty_limit = dirty_thresh;
 	ratelimit_pages = dirty_thresh / (num_online_cpus() * 32);
 	if (ratelimit_pages < 16)
 		ratelimit_pages = 16;
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
