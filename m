Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB8A6B026A
	for <linux-mm@kvack.org>; Tue, 29 May 2018 17:17:44 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e4-v6so14574183qtp.15
        for <linux-mm@kvack.org>; Tue, 29 May 2018 14:17:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g206-v6sor8192663qke.44.2018.05.29.14.17.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 14:17:41 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 09/13] blk-rq-qos: refactor out common elements of blk-wbt
Date: Tue, 29 May 2018 17:17:20 -0400
Message-Id: <20180529211724.4531-10-josef@toxicpanda.com>
In-Reply-To: <20180529211724.4531-1-josef@toxicpanda.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

blkcg-qos is going to do essentially what wbt does, only on a cgroup
basis.  Break out the common code that will be shared between blkcg-qos
and wbt into blk-rq-qos.* so they can both utilize the same
infrastructure.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 block/Makefile         |   2 +-
 block/blk-core.c       |  12 +-
 block/blk-mq.c         |  12 +-
 block/blk-rq-qos.c     | 178 +++++++++++++++++++++++++++
 block/blk-rq-qos.h     |  91 ++++++++++++++
 block/blk-settings.c   |   4 +-
 block/blk-sysfs.c      |  22 ++--
 block/blk-wbt.c        | 326 ++++++++++++++++++++++---------------------------
 block/blk-wbt.h        |  63 ++++------
 include/linux/blkdev.h |   4 +-
 10 files changed, 463 insertions(+), 251 deletions(-)
 create mode 100644 block/blk-rq-qos.c
 create mode 100644 block/blk-rq-qos.h

diff --git a/block/Makefile b/block/Makefile
index 6a56303b9925..981605042cad 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_BLOCK) := bio.o elevator.o blk-core.o blk-tag.o blk-sysfs.o \
 			blk-lib.o blk-mq.o blk-mq-tag.o blk-stat.o \
 			blk-mq-sysfs.o blk-mq-cpumap.o blk-mq-sched.o ioctl.o \
 			genhd.o partition-generic.o ioprio.o \
-			badblocks.o partitions/
+			badblocks.o partitions/ blk-rq-qos.o
 
 obj-$(CONFIG_BOUNCE)		+= bounce.o
 obj-$(CONFIG_BLK_SCSI_REQUEST)	+= scsi_ioctl.o
diff --git a/block/blk-core.c b/block/blk-core.c
index 43370faee935..07594fb34c0f 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1653,7 +1653,7 @@ void blk_requeue_request(struct request_queue *q, struct request *rq)
 	blk_delete_timer(rq);
 	blk_clear_rq_complete(rq);
 	trace_block_rq_requeue(q, rq);
-	wbt_requeue(q->rq_wb, rq);
+	rq_qos_requeue(q, rq);
 
 	if (rq->rq_flags & RQF_QUEUED)
 		blk_queue_end_tag(q, rq);
@@ -1760,7 +1760,7 @@ void __blk_put_request(struct request_queue *q, struct request *req)
 	/* this is a bio leak */
 	WARN_ON(req->bio != NULL);
 
-	wbt_done(q->rq_wb, req);
+	rq_qos_done(q, req);
 
 	/*
 	 * Request may not have originated from ll_rw_blk. if not,
@@ -2052,7 +2052,7 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 	}
 
 get_rq:
-	wb_acct = wbt_wait(q->rq_wb, bio, q->queue_lock);
+	wb_acct = rq_qos_throttle(q, bio, q->queue_lock);
 
 	/*
 	 * Grab a free request. This is might sleep but can not fail.
@@ -2062,7 +2062,7 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 	req = get_request(q, bio->bi_opf, bio, 0, GFP_NOIO);
 	if (IS_ERR(req)) {
 		blk_queue_exit(q);
-		__wbt_done(q->rq_wb, wb_acct);
+		rq_qos_cleanup(q, wb_acct);
 		if (PTR_ERR(req) == -ENOMEM)
 			bio->bi_status = BLK_STS_RESOURCE;
 		else
@@ -2989,7 +2989,7 @@ void blk_start_request(struct request *req)
 		req->throtl_size = blk_rq_sectors(req);
 #endif
 		req->rq_flags |= RQF_STATS;
-		wbt_issue(req->q->rq_wb, req);
+		rq_qos_issue(req->q, req);
 	}
 
 	BUG_ON(blk_rq_is_complete(req));
@@ -3211,7 +3211,7 @@ void blk_finish_request(struct request *req, blk_status_t error)
 	blk_account_io_done(req, now);
 
 	if (req->end_io) {
-		wbt_done(req->q->rq_wb, req);
+		rq_qos_done(q, req);
 		req->end_io(req, error);
 	} else {
 		if (blk_bidi_rq(req))
diff --git a/block/blk-mq.c b/block/blk-mq.c
index df928200b17e..5308396ee22a 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -489,7 +489,7 @@ void blk_mq_free_request(struct request *rq)
 	if (unlikely(laptop_mode && !blk_rq_is_passthrough(rq)))
 		laptop_io_completion(q->backing_dev_info);
 
-	wbt_done(q->rq_wb, rq);
+	rq_qos_done(q, rq);
 
 	if (blk_rq_rl(rq))
 		blk_put_rl(blk_rq_rl(rq));
@@ -516,7 +516,7 @@ inline void __blk_mq_end_request(struct request *rq, blk_status_t error)
 	blk_account_io_done(rq, now);
 
 	if (rq->end_io) {
-		wbt_done(rq->q->rq_wb, rq);
+		rq_qos_done(rq->q, rq);
 		rq->end_io(rq, error);
 	} else {
 		if (unlikely(blk_bidi_rq(rq)))
@@ -678,7 +678,7 @@ void blk_mq_start_request(struct request *rq)
 		rq->throtl_size = blk_rq_sectors(rq);
 #endif
 		rq->rq_flags |= RQF_STATS;
-		wbt_issue(q->rq_wb, rq);
+		rq_qos_issue(q, rq);
 	}
 
 	WARN_ON_ONCE(blk_mq_rq_state(rq) != MQ_RQ_IDLE);
@@ -726,7 +726,7 @@ static void __blk_mq_requeue_request(struct request *rq)
 	blk_mq_put_driver_tag(rq);
 
 	trace_block_rq_requeue(q, rq);
-	wbt_requeue(q->rq_wb, rq);
+	rq_qos_requeue(q, rq);
 
 	if (blk_mq_rq_state(rq) != MQ_RQ_IDLE) {
 		blk_mq_rq_update_state(rq, MQ_RQ_IDLE);
@@ -1868,13 +1868,13 @@ static blk_qc_t blk_mq_make_request(struct request_queue *q, struct bio *bio)
 	if (blk_mq_sched_bio_merge(q, bio))
 		return BLK_QC_T_NONE;
 
-	wb_acct = wbt_wait(q->rq_wb, bio, NULL);
+	wb_acct = rq_qos_throttle(q, bio, NULL);
 
 	trace_block_getrq(q, bio, bio->bi_opf);
 
 	rq = blk_mq_get_request(q, bio, bio->bi_opf, &data);
 	if (unlikely(!rq)) {
-		__wbt_done(q->rq_wb, wb_acct);
+		rq_qos_cleanup(q, wb_acct);
 		if (bio->bi_opf & REQ_NOWAIT)
 			bio_wouldblock_error(bio);
 		return BLK_QC_T_NONE;
diff --git a/block/blk-rq-qos.c b/block/blk-rq-qos.c
new file mode 100644
index 000000000000..d2f2af8aa10c
--- /dev/null
+++ b/block/blk-rq-qos.c
@@ -0,0 +1,178 @@
+#include "blk-rq-qos.h"
+
+#include "blk-wbt.h"
+
+/*
+ * Increment 'v', if 'v' is below 'below'. Returns true if we succeeded,
+ * false if 'v' + 1 would be bigger than 'below'.
+ */
+static bool atomic_inc_below(atomic_t *v, int below)
+{
+	int cur = atomic_read(v);
+
+	for (;;) {
+		int old;
+
+		if (cur >= below)
+			return false;
+		old = atomic_cmpxchg(v, cur, cur + 1);
+		if (old == cur)
+			break;
+		cur = old;
+	}
+
+	return true;
+}
+
+bool rq_wait_inc_below(struct rq_wait *rq_wait, int limit)
+{
+	return atomic_inc_below(&rq_wait->inflight, limit);
+}
+
+void rq_qos_cleanup(struct request_queue *q, enum wbt_flags wb_acct)
+{
+	struct rq_qos *rqos;
+
+	for (rqos = q->rq_qos; rqos; rqos = rqos->next) {
+		if (rqos->ops->cleanup)
+			rqos->ops->cleanup(rqos, wb_acct);
+	}
+}
+
+void rq_qos_done(struct request_queue *q, struct request *rq)
+{
+	struct rq_qos *rqos;
+
+	for (rqos = q->rq_qos; rqos; rqos = rqos->next) {
+		if (rqos->ops->done)
+			rqos->ops->done(rqos, rq);
+	}
+}
+
+void rq_qos_issue(struct request_queue *q, struct request *rq)
+{
+	struct rq_qos *rqos;
+
+	for(rqos = q->rq_qos; rqos; rqos = rqos->next) {
+		if (rqos->ops->issue)
+			rqos->ops->issue(rqos, rq);
+	}
+}
+
+void rq_qos_requeue(struct request_queue *q, struct request *rq)
+{
+	struct rq_qos *rqos;
+
+	for(rqos = q->rq_qos; rqos; rqos = rqos->next) {
+		if (rqos->ops->requeue)
+			rqos->ops->requeue(rqos, rq);
+	}
+}
+
+enum wbt_flags rq_qos_throttle(struct request_queue *q, struct bio *bio,
+			       spinlock_t *lock)
+{
+	struct rq_qos *rqos;
+	enum wbt_flags flags = 0;
+
+	for(rqos = q->rq_qos; rqos; rqos = rqos->next) {
+		if (rqos->ops->throttle)
+			flags |= rqos->ops->throttle(rqos, bio, lock);
+	}
+	return flags;
+}
+
+/*
+ * Return true, if we can't increase the depth further by scaling
+ */
+bool rq_depth_calc_max_depth(struct rq_depth *rqd)
+{
+	unsigned int depth;
+	bool ret = false;
+
+	/*
+	 * For QD=1 devices, this is a special case. It's important for those
+	 * to have one request ready when one completes, so force a depth of
+	 * 2 for those devices. On the backend, it'll be a depth of 1 anyway,
+	 * since the device can't have more than that in flight. If we're
+	 * scaling down, then keep a setting of 1/1/1.
+	 */
+	if (rqd->queue_depth == 1) {
+		if (rqd->scale_step > 0)
+			rqd->max_depth = 1;
+		else {
+			rqd->max_depth = 2;
+			ret = true;
+		}
+	} else {
+		/*
+		 * scale_step == 0 is our default state. If we have suffered
+		 * latency spikes, step will be > 0, and we shrink the
+		 * allowed write depths. If step is < 0, we're only doing
+		 * writes, and we allow a temporarily higher depth to
+		 * increase performance.
+		 */
+		depth = min_t(unsigned int, rqd->default_depth,
+			      rqd->queue_depth);
+		if (rqd->scale_step > 0)
+			depth = 1 + ((depth - 1) >> min(31, rqd->scale_step));
+		else if (rqd->scale_step < 0) {
+			unsigned int maxd = 3 * rqd->queue_depth / 4;
+
+			depth = 1 + ((depth - 1) << -rqd->scale_step);
+			if (depth > maxd) {
+				depth = maxd;
+				ret = true;
+			}
+		}
+
+		rqd->max_depth = depth;
+	}
+
+	return ret;
+}
+
+void rq_depth_scale_up(struct rq_depth *rqd)
+{
+	/*
+	 * Hit max in previous round, stop here
+	 */
+	if (rqd->scaled_max)
+		return;
+
+	rqd->scale_step--;
+
+	rqd->scaled_max = rq_depth_calc_max_depth(rqd);
+}
+
+/*
+ * Scale rwb down. If 'hard_throttle' is set, do it quicker, since we
+ * had a latency violation.
+ */
+void rq_depth_scale_down(struct rq_depth *rqd, bool hard_throttle)
+{
+	/*
+	 * Stop scaling down when we've hit the limit. This also prevents
+	 * ->scale_step from going to crazy values, if the device can't
+	 * keep up.
+	 */
+	if (rqd->max_depth == 1)
+		return;
+
+	if (rqd->scale_step < 0 && hard_throttle)
+		rqd->scale_step = 0;
+	else
+		rqd->scale_step++;
+
+	rqd->scaled_max = false;
+	rq_depth_calc_max_depth(rqd);
+}
+
+void rq_qos_exit(struct request_queue *q)
+{
+	while (q->rq_qos) {
+		struct rq_qos *rqos = q->rq_qos;
+		q->rq_qos = rqos->next;
+		rqos->ops->exit(rqos);
+	}
+}
diff --git a/block/blk-rq-qos.h b/block/blk-rq-qos.h
new file mode 100644
index 000000000000..a321e9e2ba70
--- /dev/null
+++ b/block/blk-rq-qos.h
@@ -0,0 +1,91 @@
+#ifndef RQ_QOS_H
+#define RQ_QOS_H
+
+#include <linux/kernel.h>
+#include <linux/blkdev.h>
+#include <linux/blk_types.h>
+#include <linux/atomic.h>
+#include <linux/wait.h>
+
+enum rq_qos_id {
+	RQ_QOS_WBT,
+	RQ_QOS_CGROUP,
+};
+
+struct rq_wait {
+	wait_queue_head_t wait;
+	atomic_t inflight;
+};
+
+struct rq_qos {
+	struct rq_qos_ops *ops;
+	struct request_queue *q;
+	enum rq_qos_id id;
+	struct rq_qos *next;
+};
+
+struct rq_qos_ops {
+	enum wbt_flags (*throttle)(struct rq_qos *, struct bio *,
+				   spinlock_t *);
+	void (*issue)(struct rq_qos *, struct request *);
+	void (*requeue)(struct rq_qos *, struct request *);
+	void (*done)(struct rq_qos *, struct request *);
+	void (*cleanup)(struct rq_qos *, enum wbt_flags);
+	void (*exit)(struct rq_qos *);
+};
+
+struct rq_depth {
+	unsigned int max_depth;
+
+	int scale_step;
+	bool scaled_max;
+
+	unsigned int queue_depth;
+	unsigned int default_depth;
+};
+
+static inline struct rq_qos *rq_qos_id(struct request_queue *q,
+				       enum rq_qos_id id)
+{
+	struct rq_qos *rqos;
+	for (rqos = q->rq_qos; rqos; rqos = rqos->next) {
+		if (rqos->id == id)
+			break;
+	}
+	return rqos;
+}
+
+static inline struct rq_qos *wbt_rq_qos(struct request_queue *q)
+{
+	return rq_qos_id(q, RQ_QOS_WBT);
+}
+
+static inline struct rq_qos *blkcg_rq_qos(struct request_queue *q)
+{
+	return rq_qos_id(q, RQ_QOS_CGROUP);
+}
+
+static inline void rq_wait_init(struct rq_wait *rq_wait)
+{
+	atomic_set(&rq_wait->inflight, 0);
+	init_waitqueue_head(&rq_wait->wait);
+}
+
+static inline void rq_qos_add(struct request_queue *q, struct rq_qos *rqos)
+{
+	rqos->next = q->rq_qos;
+	q->rq_qos = rqos;
+}
+
+bool rq_wait_inc_below(struct rq_wait *rq_wait, int limit);
+void rq_depth_scale_up(struct rq_depth *rqd);
+void rq_depth_scale_down(struct rq_depth *rqd, bool hard_throttle);
+bool rq_depth_calc_max_depth(struct rq_depth *rqd);
+
+void rq_qos_cleanup(struct request_queue *, enum wbt_flags);
+void rq_qos_done(struct request_queue *, struct request *);
+void rq_qos_issue(struct request_queue *, struct request *);
+void rq_qos_requeue(struct request_queue *, struct request *);
+enum wbt_flags rq_qos_throttle(struct request_queue *, struct bio *, spinlock_t *);
+void rq_qos_exit(struct request_queue *);
+#endif
diff --git a/block/blk-settings.c b/block/blk-settings.c
index d1de71124656..053de87d1fda 100644
--- a/block/blk-settings.c
+++ b/block/blk-settings.c
@@ -875,7 +875,7 @@ EXPORT_SYMBOL_GPL(blk_queue_flush_queueable);
 void blk_set_queue_depth(struct request_queue *q, unsigned int depth)
 {
 	q->queue_depth = depth;
-	wbt_set_queue_depth(q->rq_wb, depth);
+	wbt_set_queue_depth(q, depth);
 }
 EXPORT_SYMBOL(blk_set_queue_depth);
 
@@ -900,7 +900,7 @@ void blk_queue_write_cache(struct request_queue *q, bool wc, bool fua)
 		queue_flag_clear(QUEUE_FLAG_FUA, q);
 	spin_unlock_irq(q->queue_lock);
 
-	wbt_set_write_cache(q->rq_wb, test_bit(QUEUE_FLAG_WC, &q->queue_flags));
+	wbt_set_write_cache(q, test_bit(QUEUE_FLAG_WC, &q->queue_flags));
 }
 EXPORT_SYMBOL_GPL(blk_queue_write_cache);
 
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index cae525b7aae6..6c23404c01db 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -422,16 +422,16 @@ static ssize_t queue_poll_store(struct request_queue *q, const char *page,
 
 static ssize_t queue_wb_lat_show(struct request_queue *q, char *page)
 {
-	if (!q->rq_wb)
+	if (!wbt_rq_qos(q))
 		return -EINVAL;
 
-	return sprintf(page, "%llu\n", div_u64(q->rq_wb->min_lat_nsec, 1000));
+	return sprintf(page, "%llu\n", div_u64(wbt_get_min_lat(q), 1000));
 }
 
 static ssize_t queue_wb_lat_store(struct request_queue *q, const char *page,
 				  size_t count)
 {
-	struct rq_wb *rwb;
+	struct rq_qos *rqos;
 	ssize_t ret;
 	s64 val;
 
@@ -441,23 +441,21 @@ static ssize_t queue_wb_lat_store(struct request_queue *q, const char *page,
 	if (val < -1)
 		return -EINVAL;
 
-	rwb = q->rq_wb;
-	if (!rwb) {
+	rqos = wbt_rq_qos(q);
+	if (!rqos) {
 		ret = wbt_init(q);
 		if (ret)
 			return ret;
 	}
 
-	rwb = q->rq_wb;
 	if (val == -1)
-		rwb->min_lat_nsec = wbt_default_latency_nsec(q);
+		val = wbt_default_latency_nsec(q);
 	else if (val >= 0)
-		rwb->min_lat_nsec = val * 1000ULL;
+		val *= 1000ULL;
 
-	if (rwb->enable_state == WBT_STATE_ON_DEFAULT)
-		rwb->enable_state = WBT_STATE_ON_MANUAL;
+	wbt_set_min_lat(q, val);
 
-	wbt_update_limits(rwb);
+	wbt_update_limits(q);
 	return count;
 }
 
@@ -965,7 +963,7 @@ void blk_unregister_queue(struct gendisk *disk)
 	kobject_del(&q->kobj);
 	blk_trace_remove_sysfs(disk_to_dev(disk));
 
-	wbt_exit(q);
+	rq_qos_exit(q);
 
 	mutex_lock(&q->sysfs_lock);
 	if (q->request_fn || (q->mq_ops && q->elevator))
diff --git a/block/blk-wbt.c b/block/blk-wbt.c
index 4f89b28fa652..6fe20fb823e4 100644
--- a/block/blk-wbt.c
+++ b/block/blk-wbt.c
@@ -25,6 +25,7 @@
 #include <linux/swap.h>
 
 #include "blk-wbt.h"
+#include "blk-rq-qos.h"
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/wbt.h>
@@ -78,28 +79,6 @@ static inline bool rwb_enabled(struct rq_wb *rwb)
 	return rwb && rwb->wb_normal != 0;
 }
 
-/*
- * Increment 'v', if 'v' is below 'below'. Returns true if we succeeded,
- * false if 'v' + 1 would be bigger than 'below'.
- */
-static bool atomic_inc_below(atomic_t *v, int below)
-{
-	int cur = atomic_read(v);
-
-	for (;;) {
-		int old;
-
-		if (cur >= below)
-			return false;
-		old = atomic_cmpxchg(v, cur, cur + 1);
-		if (old == cur)
-			break;
-		cur = old;
-	}
-
-	return true;
-}
-
 static void wb_timestamp(struct rq_wb *rwb, unsigned long *var)
 {
 	if (rwb_enabled(rwb)) {
@@ -116,7 +95,7 @@ static void wb_timestamp(struct rq_wb *rwb, unsigned long *var)
  */
 static bool wb_recent_wait(struct rq_wb *rwb)
 {
-	struct bdi_writeback *wb = &rwb->queue->backing_dev_info->wb;
+	struct bdi_writeback *wb = &rwb->rqos.q->backing_dev_info->wb;
 
 	return time_before(jiffies, wb->dirty_sleep + HZ);
 }
@@ -144,8 +123,9 @@ static void rwb_wake_all(struct rq_wb *rwb)
 	}
 }
 
-void __wbt_done(struct rq_wb *rwb, enum wbt_flags wb_acct)
+static void __wbt_done(struct rq_qos *rqos, enum wbt_flags wb_acct)
 {
+	struct rq_wb *rwb = RQWB(rqos);
 	struct rq_wait *rqw;
 	int inflight, limit;
 
@@ -194,10 +174,9 @@ void __wbt_done(struct rq_wb *rwb, enum wbt_flags wb_acct)
  * Called on completion of a request. Note that it's also called when
  * a request is merged, when the request gets freed.
  */
-void wbt_done(struct rq_wb *rwb, struct request *rq)
+static void wbt_done(struct rq_qos *rqos, struct request *rq)
 {
-	if (!rwb)
-		return;
+	struct rq_wb *rwb = RQWB(rqos);
 
 	if (!wbt_is_tracked(rq)) {
 		if (rwb->sync_cookie == rq) {
@@ -209,72 +188,11 @@ void wbt_done(struct rq_wb *rwb, struct request *rq)
 			wb_timestamp(rwb, &rwb->last_comp);
 	} else {
 		WARN_ON_ONCE(rq == rwb->sync_cookie);
-		__wbt_done(rwb, wbt_flags(rq));
+		__wbt_done(rqos, wbt_flags(rq));
 	}
 	wbt_clear_state(rq);
 }
 
-/*
- * Return true, if we can't increase the depth further by scaling
- */
-static bool calc_wb_limits(struct rq_wb *rwb)
-{
-	unsigned int depth;
-	bool ret = false;
-
-	if (!rwb->min_lat_nsec) {
-		rwb->wb_max = rwb->wb_normal = rwb->wb_background = 0;
-		return false;
-	}
-
-	/*
-	 * For QD=1 devices, this is a special case. It's important for those
-	 * to have one request ready when one completes, so force a depth of
-	 * 2 for those devices. On the backend, it'll be a depth of 1 anyway,
-	 * since the device can't have more than that in flight. If we're
-	 * scaling down, then keep a setting of 1/1/1.
-	 */
-	if (rwb->queue_depth == 1) {
-		if (rwb->scale_step > 0)
-			rwb->wb_max = rwb->wb_normal = 1;
-		else {
-			rwb->wb_max = rwb->wb_normal = 2;
-			ret = true;
-		}
-		rwb->wb_background = 1;
-	} else {
-		/*
-		 * scale_step == 0 is our default state. If we have suffered
-		 * latency spikes, step will be > 0, and we shrink the
-		 * allowed write depths. If step is < 0, we're only doing
-		 * writes, and we allow a temporarily higher depth to
-		 * increase performance.
-		 */
-		depth = min_t(unsigned int, RWB_DEF_DEPTH, rwb->queue_depth);
-		if (rwb->scale_step > 0)
-			depth = 1 + ((depth - 1) >> min(31, rwb->scale_step));
-		else if (rwb->scale_step < 0) {
-			unsigned int maxd = 3 * rwb->queue_depth / 4;
-
-			depth = 1 + ((depth - 1) << -rwb->scale_step);
-			if (depth > maxd) {
-				depth = maxd;
-				ret = true;
-			}
-		}
-
-		/*
-		 * Set our max/normal/bg queue depths based on how far
-		 * we have scaled down (->scale_step).
-		 */
-		rwb->wb_max = depth;
-		rwb->wb_normal = (rwb->wb_max + 1) / 2;
-		rwb->wb_background = (rwb->wb_max + 3) / 4;
-	}
-
-	return ret;
-}
-
 static inline bool stat_sample_valid(struct blk_rq_stat *stat)
 {
 	/*
@@ -307,7 +225,8 @@ enum {
 
 static int latency_exceeded(struct rq_wb *rwb, struct blk_rq_stat *stat)
 {
-	struct backing_dev_info *bdi = rwb->queue->backing_dev_info;
+	struct backing_dev_info *bdi = rwb->rqos.q->backing_dev_info;
+	struct rq_depth *rqd = &rwb->rq_depth;
 	u64 thislat;
 
 	/*
@@ -351,7 +270,7 @@ static int latency_exceeded(struct rq_wb *rwb, struct blk_rq_stat *stat)
 		return LAT_EXCEEDED;
 	}
 
-	if (rwb->scale_step)
+	if (rqd->scale_step)
 		trace_wbt_stat(bdi, stat);
 
 	return LAT_OK;
@@ -359,58 +278,48 @@ static int latency_exceeded(struct rq_wb *rwb, struct blk_rq_stat *stat)
 
 static void rwb_trace_step(struct rq_wb *rwb, const char *msg)
 {
-	struct backing_dev_info *bdi = rwb->queue->backing_dev_info;
+	struct backing_dev_info *bdi = rwb->rqos.q->backing_dev_info;
+	struct rq_depth *rqd = &rwb->rq_depth;
 
-	trace_wbt_step(bdi, msg, rwb->scale_step, rwb->cur_win_nsec,
-			rwb->wb_background, rwb->wb_normal, rwb->wb_max);
+	trace_wbt_step(bdi, msg, rqd->scale_step, rwb->cur_win_nsec,
+			rwb->wb_background, rwb->wb_normal, rqd->max_depth);
 }
 
-static void scale_up(struct rq_wb *rwb)
+static void calc_wb_limits(struct rq_wb *rwb)
 {
-	/*
-	 * Hit max in previous round, stop here
-	 */
-	if (rwb->scaled_max)
-		return;
+	if (rwb->min_lat_nsec == 0) {
+		rwb->wb_normal = rwb->wb_background = 0;
+	} else if (rwb->rq_depth.max_depth <= 2) {
+		rwb->wb_normal = rwb->rq_depth.max_depth;
+		rwb->wb_background = 1;
+	} else {
+		rwb->wb_normal = (rwb->rq_depth.max_depth + 1) / 2;
+		rwb->wb_background = (rwb->rq_depth.max_depth + 3) / 4;
+	}
+}
 
-	rwb->scale_step--;
+static void scale_up(struct rq_wb *rwb)
+{
+	rq_depth_scale_up(&rwb->rq_depth);
+	calc_wb_limits(rwb);
 	rwb->unknown_cnt = 0;
-
-	rwb->scaled_max = calc_wb_limits(rwb);
-
-	rwb_wake_all(rwb);
-
-	rwb_trace_step(rwb, "step up");
+	rwb_trace_step(rwb, "scale up");
 }
 
-/*
- * Scale rwb down. If 'hard_throttle' is set, do it quicker, since we
- * had a latency violation.
- */
 static void scale_down(struct rq_wb *rwb, bool hard_throttle)
 {
-	/*
-	 * Stop scaling down when we've hit the limit. This also prevents
-	 * ->scale_step from going to crazy values, if the device can't
-	 * keep up.
-	 */
-	if (rwb->wb_max == 1)
-		return;
-
-	if (rwb->scale_step < 0 && hard_throttle)
-		rwb->scale_step = 0;
-	else
-		rwb->scale_step++;
-
-	rwb->scaled_max = false;
-	rwb->unknown_cnt = 0;
+	rq_depth_scale_down(&rwb->rq_depth, hard_throttle);
 	calc_wb_limits(rwb);
-	rwb_trace_step(rwb, "step down");
+	rwb->unknown_cnt = 0;
+	rwb_wake_all(rwb);
+	rwb_trace_step(rwb, "scale down");
 }
 
 static void rwb_arm_timer(struct rq_wb *rwb)
 {
-	if (rwb->scale_step > 0) {
+	struct rq_depth *rqd = &rwb->rq_depth;
+
+	if (rqd->scale_step > 0) {
 		/*
 		 * We should speed this up, using some variant of a fast
 		 * integer inverse square root calculation. Since we only do
@@ -418,7 +327,7 @@ static void rwb_arm_timer(struct rq_wb *rwb)
 		 * though.
 		 */
 		rwb->cur_win_nsec = div_u64(rwb->win_nsec << 4,
-					int_sqrt((rwb->scale_step + 1) << 8));
+					int_sqrt((rqd->scale_step + 1) << 8));
 	} else {
 		/*
 		 * For step < 0, we don't want to increase/decrease the
@@ -433,12 +342,13 @@ static void rwb_arm_timer(struct rq_wb *rwb)
 static void wb_timer_fn(struct blk_stat_callback *cb)
 {
 	struct rq_wb *rwb = cb->data;
+	struct rq_depth *rqd = &rwb->rq_depth;
 	unsigned int inflight = wbt_inflight(rwb);
 	int status;
 
 	status = latency_exceeded(rwb, cb->stat);
 
-	trace_wbt_timer(rwb->queue->backing_dev_info, status, rwb->scale_step,
+	trace_wbt_timer(rwb->rqos.q->backing_dev_info, status, rqd->scale_step,
 			inflight);
 
 	/*
@@ -469,9 +379,9 @@ static void wb_timer_fn(struct blk_stat_callback *cb)
 		 * currently don't have a valid read/write sample. For that
 		 * case, slowly return to center state (step == 0).
 		 */
-		if (rwb->scale_step > 0)
+		if (rqd->scale_step > 0)
 			scale_up(rwb);
-		else if (rwb->scale_step < 0)
+		else if (rqd->scale_step < 0)
 			scale_down(rwb, false);
 		break;
 	default:
@@ -481,19 +391,50 @@ static void wb_timer_fn(struct blk_stat_callback *cb)
 	/*
 	 * Re-arm timer, if we have IO in flight
 	 */
-	if (rwb->scale_step || inflight)
+	if (rqd->scale_step || inflight)
 		rwb_arm_timer(rwb);
 }
 
-void wbt_update_limits(struct rq_wb *rwb)
+static void __wbt_update_limits(struct rq_wb *rwb)
 {
-	rwb->scale_step = 0;
-	rwb->scaled_max = false;
+	struct rq_depth *rqd = &rwb->rq_depth;
+
+	rqd->scale_step = 0;
+	rqd->scaled_max = false;
+
+	rq_depth_calc_max_depth(rqd);
 	calc_wb_limits(rwb);
 
 	rwb_wake_all(rwb);
 }
 
+void wbt_update_limits(struct request_queue *q)
+{
+	struct rq_qos *rqos = wbt_rq_qos(q);
+	if (!rqos)
+		return;
+	__wbt_update_limits(RQWB(rqos));
+}
+
+u64 wbt_get_min_lat(struct request_queue *q)
+{
+	struct rq_qos *rqos = wbt_rq_qos(q);
+	if (!rqos)
+		return 0;
+	return RQWB(rqos)->min_lat_nsec;
+}
+
+void wbt_set_min_lat(struct request_queue *q, u64 val)
+{
+	struct rq_qos *rqos = wbt_rq_qos(q);
+	if (!rqos)
+		return;
+	RQWB(rqos)->min_lat_nsec = val;
+	RQWB(rqos)->enable_state = WBT_STATE_ON_MANUAL;
+	__wbt_update_limits(RQWB(rqos));
+}
+
+
 static bool close_io(struct rq_wb *rwb)
 {
 	const unsigned long now = jiffies;
@@ -520,7 +461,7 @@ static inline unsigned int get_limit(struct rq_wb *rwb, unsigned long rw)
 	 * IO for a bit.
 	 */
 	if ((rw & REQ_HIPRIO) || wb_recent_wait(rwb) || current_is_kswapd())
-		limit = rwb->wb_max;
+		limit = rwb->rq_depth.max_depth;
 	else if ((rw & REQ_BACKGROUND) || close_io(rwb)) {
 		/*
 		 * If less than 100ms since we completed unrelated IO,
@@ -554,7 +495,7 @@ static inline bool may_queue(struct rq_wb *rwb, struct rq_wait *rqw,
 	    rqw->wait.head.next != &wait->entry)
 		return false;
 
-	return atomic_inc_below(&rqw->inflight, get_limit(rwb, rw));
+	return rq_wait_inc_below(rqw, get_limit(rwb, rw));
 }
 
 /*
@@ -614,8 +555,10 @@ static inline bool wbt_should_throttle(struct rq_wb *rwb, struct bio *bio)
  * in an irq held spinlock, if it holds one when calling this function.
  * If we do sleep, we'll release and re-grab it.
  */
-enum wbt_flags wbt_wait(struct rq_wb *rwb, struct bio *bio, spinlock_t *lock)
+static enum wbt_flags wbt_wait(struct rq_qos *rqos, struct bio *bio,
+			       spinlock_t *lock)
 {
+	struct rq_wb *rwb = RQWB(rqos);
 	enum wbt_flags ret = 0;
 
 	if (!rwb_enabled(rwb))
@@ -643,8 +586,10 @@ enum wbt_flags wbt_wait(struct rq_wb *rwb, struct bio *bio, spinlock_t *lock)
 	return ret | WBT_TRACKED;
 }
 
-void wbt_issue(struct rq_wb *rwb, struct request *rq)
+void wbt_issue(struct rq_qos *rqos, struct request *rq)
 {
+	struct rq_wb *rwb = RQWB(rqos);
+
 	if (!rwb_enabled(rwb))
 		return;
 
@@ -661,8 +606,9 @@ void wbt_issue(struct rq_wb *rwb, struct request *rq)
 	}
 }
 
-void wbt_requeue(struct rq_wb *rwb, struct request *rq)
+void wbt_requeue(struct rq_qos *rqos, struct request *rq)
 {
+	struct rq_wb *rwb = RQWB(rqos);
 	if (!rwb_enabled(rwb))
 		return;
 	if (rq == rwb->sync_cookie) {
@@ -671,39 +617,30 @@ void wbt_requeue(struct rq_wb *rwb, struct request *rq)
 	}
 }
 
-void wbt_set_queue_depth(struct rq_wb *rwb, unsigned int depth)
+void wbt_set_queue_depth(struct request_queue *q, unsigned int depth)
 {
-	if (rwb) {
-		rwb->queue_depth = depth;
-		wbt_update_limits(rwb);
+	struct rq_qos *rqos = wbt_rq_qos(q);
+	if (rqos) {
+		RQWB(rqos)->rq_depth.queue_depth = depth;
+		__wbt_update_limits(RQWB(rqos));
 	}
 }
 
-void wbt_set_write_cache(struct rq_wb *rwb, bool write_cache_on)
-{
-	if (rwb)
-		rwb->wc = write_cache_on;
-}
-
-/*
- * Disable wbt, if enabled by default.
- */
-void wbt_disable_default(struct request_queue *q)
+void wbt_set_write_cache(struct request_queue *q, bool write_cache_on)
 {
-	struct rq_wb *rwb = q->rq_wb;
-
-	if (rwb && rwb->enable_state == WBT_STATE_ON_DEFAULT)
-		wbt_exit(q);
+	struct rq_qos *rqos = wbt_rq_qos(q);
+	if (rqos)
+		RQWB(rqos)->wc = write_cache_on;
 }
-EXPORT_SYMBOL_GPL(wbt_disable_default);
 
 /*
  * Enable wbt if defaults are configured that way
  */
 void wbt_enable_default(struct request_queue *q)
 {
+	struct rq_qos *rqos = wbt_rq_qos(q);
 	/* Throttling already enabled? */
-	if (q->rq_wb)
+	if (rqos)
 		return;
 
 	/* Queue not registered? Maybe shutting down... */
@@ -741,6 +678,41 @@ static int wbt_data_dir(const struct request *rq)
 	return -1;
 }
 
+static void wbt_exit(struct rq_qos *rqos)
+{
+	struct rq_wb *rwb = RQWB(rqos);
+	struct request_queue *q = rqos->q;
+
+	blk_stat_remove_callback(q, rwb->cb);
+	blk_stat_free_callback(rwb->cb);
+	kfree(rwb);
+}
+
+/*
+ * Disable wbt, if enabled by default.
+ */
+void wbt_disable_default(struct request_queue *q)
+{
+	struct rq_qos *rqos = wbt_rq_qos(q);
+	struct rq_wb *rwb;
+	if (!rqos)
+		return;
+	rwb = RQWB(rqos);
+	if (rwb->enable_state == WBT_STATE_ON_DEFAULT)
+		rwb->wb_normal = 0;
+}
+EXPORT_SYMBOL_GPL(wbt_disable_default);
+
+
+static struct rq_qos_ops wbt_rqos_ops = {
+	.throttle = wbt_wait,
+	.issue = wbt_issue,
+	.requeue = wbt_requeue,
+	.done = wbt_done,
+	.cleanup = __wbt_done,
+	.exit = wbt_exit,
+};
+
 int wbt_init(struct request_queue *q)
 {
 	struct rq_wb *rwb;
@@ -756,39 +728,29 @@ int wbt_init(struct request_queue *q)
 		return -ENOMEM;
 	}
 
-	for (i = 0; i < WBT_NUM_RWQ; i++) {
-		atomic_set(&rwb->rq_wait[i].inflight, 0);
-		init_waitqueue_head(&rwb->rq_wait[i].wait);
-	}
+	for (i = 0; i < WBT_NUM_RWQ; i++)
+		rq_wait_init(&rwb->rq_wait[i]);
 
+	rwb->rqos.id = RQ_QOS_WBT;
+	rwb->rqos.ops = &wbt_rqos_ops;
+	rwb->rqos.q = q;
 	rwb->last_comp = rwb->last_issue = jiffies;
-	rwb->queue = q;
 	rwb->win_nsec = RWB_WINDOW_NSEC;
 	rwb->enable_state = WBT_STATE_ON_DEFAULT;
-	wbt_update_limits(rwb);
+	rwb->wc = 1;
+	rwb->rq_depth.default_depth = RWB_DEF_DEPTH;
+	__wbt_update_limits(rwb);
 
 	/*
 	 * Assign rwb and add the stats callback.
 	 */
-	q->rq_wb = rwb;
+	rq_qos_add(q, &rwb->rqos);
 	blk_stat_add_callback(q, rwb->cb);
 
 	rwb->min_lat_nsec = wbt_default_latency_nsec(q);
 
-	wbt_set_queue_depth(rwb, blk_queue_depth(q));
-	wbt_set_write_cache(rwb, test_bit(QUEUE_FLAG_WC, &q->queue_flags));
+	wbt_set_queue_depth(q, blk_queue_depth(q));
+	wbt_set_write_cache(q, test_bit(QUEUE_FLAG_WC, &q->queue_flags));
 
 	return 0;
 }
-
-void wbt_exit(struct request_queue *q)
-{
-	struct rq_wb *rwb = q->rq_wb;
-
-	if (rwb) {
-		blk_stat_remove_callback(q, rwb->cb);
-		blk_stat_free_callback(rwb->cb);
-		q->rq_wb = NULL;
-		kfree(rwb);
-	}
-}
diff --git a/block/blk-wbt.h b/block/blk-wbt.h
index 300df531d0a6..53b20a58c0a2 100644
--- a/block/blk-wbt.h
+++ b/block/blk-wbt.h
@@ -9,6 +9,7 @@
 #include <linux/ktime.h>
 
 #include "blk-stat.h"
+#include "blk-rq-qos.h"
 
 enum wbt_flags {
 	WBT_TRACKED		= 1,	/* write, tracked for throttling */
@@ -35,20 +36,12 @@ enum {
 	WBT_STATE_ON_MANUAL	= 2,
 };
 
-struct rq_wait {
-	wait_queue_head_t wait;
-	atomic_t inflight;
-};
-
 struct rq_wb {
 	/*
 	 * Settings that govern how we throttle
 	 */
 	unsigned int wb_background;		/* background writeback */
 	unsigned int wb_normal;			/* normal writeback */
-	unsigned int wb_max;			/* max throughput writeback */
-	int scale_step;
-	bool scaled_max;
 
 	short enable_state;			/* WBT_STATE_* */
 
@@ -67,15 +60,20 @@ struct rq_wb {
 	void *sync_cookie;
 
 	unsigned int wc;
-	unsigned int queue_depth;
 
 	unsigned long last_issue;		/* last non-throttled issue */
 	unsigned long last_comp;		/* last non-throttled comp */
 	unsigned long min_lat_nsec;
-	struct request_queue *queue;
+	struct rq_qos rqos;
 	struct rq_wait rq_wait[WBT_NUM_RWQ];
+	struct rq_depth rq_depth;
 };
 
+static inline struct rq_wb *RQWB(struct rq_qos *rqos)
+{
+	return container_of(rqos, struct rq_wb, rqos);
+}
+
 static inline unsigned int wbt_inflight(struct rq_wb *rwb)
 {
 	unsigned int i, ret = 0;
@@ -86,6 +84,7 @@ static inline unsigned int wbt_inflight(struct rq_wb *rwb)
 	return ret;
 }
 
+
 #ifdef CONFIG_BLK_WBT
 
 static inline void wbt_track(struct request *rq, enum wbt_flags flags)
@@ -93,19 +92,16 @@ static inline void wbt_track(struct request *rq, enum wbt_flags flags)
 	rq->wbt_flags |= flags;
 }
 
-void __wbt_done(struct rq_wb *, enum wbt_flags);
-void wbt_done(struct rq_wb *, struct request *);
-enum wbt_flags wbt_wait(struct rq_wb *, struct bio *, spinlock_t *);
 int wbt_init(struct request_queue *);
-void wbt_exit(struct request_queue *);
-void wbt_update_limits(struct rq_wb *);
-void wbt_requeue(struct rq_wb *, struct request *);
-void wbt_issue(struct rq_wb *, struct request *);
+void wbt_update_limits(struct request_queue *);
 void wbt_disable_default(struct request_queue *);
 void wbt_enable_default(struct request_queue *);
 
-void wbt_set_queue_depth(struct rq_wb *, unsigned int);
-void wbt_set_write_cache(struct rq_wb *, bool);
+u64 wbt_get_min_lat(struct request_queue *q);
+void wbt_set_min_lat(struct request_queue *q, u64 val);
+
+void wbt_set_queue_depth(struct request_queue *, unsigned int);
+void wbt_set_write_cache(struct request_queue *, bool);
 
 u64 wbt_default_latency_nsec(struct request_queue *);
 
@@ -114,43 +110,30 @@ u64 wbt_default_latency_nsec(struct request_queue *);
 static inline void wbt_track(struct request *rq, enum wbt_flags flags)
 {
 }
-static inline void __wbt_done(struct rq_wb *rwb, enum wbt_flags flags)
-{
-}
-static inline void wbt_done(struct rq_wb *rwb, struct request *rq)
-{
-}
-static inline enum wbt_flags wbt_wait(struct rq_wb *rwb, struct bio *bio,
-				      spinlock_t *lock)
-{
-	return 0;
-}
 static inline int wbt_init(struct request_queue *q)
 {
 	return -EINVAL;
 }
-static inline void wbt_exit(struct request_queue *q)
-{
-}
-static inline void wbt_update_limits(struct rq_wb *rwb)
+static inline void wbt_update_limits(struct request_queue *q)
 {
 }
-static inline void wbt_requeue(struct rq_wb *rwb, struct request *rq)
+static inline void wbt_disable_default(struct request_queue *q)
 {
 }
-static inline void wbt_issue(struct rq_wb *rwb, struct request *rq)
+static inline void wbt_enable_default(struct request_queue *q)
 {
 }
-static inline void wbt_disable_default(struct request_queue *q)
+static inline void wbt_set_queue_depth(struct request_queue *q, unsigned int depth)
 {
 }
-static inline void wbt_enable_default(struct request_queue *q)
+static inline void wbt_set_write_cache(struct request_queue *q, bool wc)
 {
 }
-static inline void wbt_set_queue_depth(struct rq_wb *rwb, unsigned int depth)
+static inline u64 wbt_get_min_lat(struct request_queue *q)
 {
+	return 0;
 }
-static inline void wbt_set_write_cache(struct rq_wb *rwb, bool wc)
+static inline void wbt_set_min_lat(struct request_queue *q, u64 val)
 {
 }
 static inline u64 wbt_default_latency_nsec(struct request_queue *q)
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index f3999719f828..30c60d049167 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -42,7 +42,7 @@ struct bsg_job;
 struct blkcg_gq;
 struct blk_flush_queue;
 struct pr_ops;
-struct rq_wb;
+struct rq_qos;
 struct blk_queue_stats;
 struct blk_stat_callback;
 
@@ -455,7 +455,7 @@ struct request_queue {
 	atomic_t		shared_hctx_restart;
 
 	struct blk_queue_stats	*stats;
-	struct rq_wb		*rq_wb;
+	struct rq_qos		*rq_qos;
 
 	/*
 	 * If blkcg is not used, @q->root_rl serves all requests.  If blkcg
-- 
2.14.3
