Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CBEA66B026A
	for <linux-mm@kvack.org>; Tue, 29 May 2018 17:17:43 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w203-v6so11928053qkb.16
        for <linux-mm@kvack.org>; Tue, 29 May 2018 14:17:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x33-v6sor21139956qte.84.2018.05.29.14.17.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 14:17:42 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 10/13] block: remove external dependency on wbt_flags
Date: Tue, 29 May 2018 17:17:21 -0400
Message-Id: <20180529211724.4531-11-josef@toxicpanda.com>
In-Reply-To: <20180529211724.4531-1-josef@toxicpanda.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

We don't really need to save this stuff in the core block code, we can
just pass the bio back into the helpers later on to derive the same
flags and update the rq->wbt_flags appropriately.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 block/blk-core.c   |  9 ++++-----
 block/blk-mq.c     |  9 ++++-----
 block/blk-rq-qos.c | 24 +++++++++++++++---------
 block/blk-rq-qos.h | 11 ++++++-----
 block/blk-wbt.c    | 52 +++++++++++++++++++++++++++++++++++++++-------------
 block/blk-wbt.h    |  5 -----
 6 files changed, 68 insertions(+), 42 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 07594fb34c0f..af67fa68f635 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -42,7 +42,7 @@
 #include "blk.h"
 #include "blk-mq.h"
 #include "blk-mq-sched.h"
-#include "blk-wbt.h"
+#include "blk-rq-qos.h"
 
 #ifdef CONFIG_DEBUG_FS
 struct dentry *blk_debugfs_root;
@@ -1994,7 +1994,6 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 	int where = ELEVATOR_INSERT_SORT;
 	struct request *req, *free;
 	unsigned int request_count = 0;
-	unsigned int wb_acct;
 
 	/*
 	 * low level driver can indicate that it wants pages above a
@@ -2052,7 +2051,7 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 	}
 
 get_rq:
-	wb_acct = rq_qos_throttle(q, bio, q->queue_lock);
+	rq_qos_throttle(q, bio, q->queue_lock);
 
 	/*
 	 * Grab a free request. This is might sleep but can not fail.
@@ -2062,7 +2061,7 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 	req = get_request(q, bio->bi_opf, bio, 0, GFP_NOIO);
 	if (IS_ERR(req)) {
 		blk_queue_exit(q);
-		rq_qos_cleanup(q, wb_acct);
+		rq_qos_cleanup(q, bio);
 		if (PTR_ERR(req) == -ENOMEM)
 			bio->bi_status = BLK_STS_RESOURCE;
 		else
@@ -2071,7 +2070,7 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 		goto out_unlock;
 	}
 
-	wbt_track(req, wb_acct);
+	rq_qos_track(q, req, bio);
 
 	/*
 	 * After dropping the lock and possibly sleeping here, our request
diff --git a/block/blk-mq.c b/block/blk-mq.c
index 5308396ee22a..7c55c9d35492 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -34,8 +34,8 @@
 #include "blk-mq-debugfs.h"
 #include "blk-mq-tag.h"
 #include "blk-stat.h"
-#include "blk-wbt.h"
 #include "blk-mq-sched.h"
+#include "blk-rq-qos.h"
 
 static bool blk_mq_poll(struct request_queue *q, blk_qc_t cookie);
 static void blk_mq_poll_stats_start(struct request_queue *q);
@@ -1852,7 +1852,6 @@ static blk_qc_t blk_mq_make_request(struct request_queue *q, struct bio *bio)
 	struct blk_plug *plug;
 	struct request *same_queue_rq = NULL;
 	blk_qc_t cookie;
-	unsigned int wb_acct;
 
 	blk_queue_bounce(q, &bio);
 
@@ -1868,19 +1867,19 @@ static blk_qc_t blk_mq_make_request(struct request_queue *q, struct bio *bio)
 	if (blk_mq_sched_bio_merge(q, bio))
 		return BLK_QC_T_NONE;
 
-	wb_acct = rq_qos_throttle(q, bio, NULL);
+	rq_qos_throttle(q, bio, NULL);
 
 	trace_block_getrq(q, bio, bio->bi_opf);
 
 	rq = blk_mq_get_request(q, bio, bio->bi_opf, &data);
 	if (unlikely(!rq)) {
-		rq_qos_cleanup(q, wb_acct);
+		rq_qos_cleanup(q, bio);
 		if (bio->bi_opf & REQ_NOWAIT)
 			bio_wouldblock_error(bio);
 		return BLK_QC_T_NONE;
 	}
 
-	wbt_track(rq, wb_acct);
+	rq_qos_track(q, rq, bio);
 
 	cookie = request_to_qc_t(data.hctx, rq);
 
diff --git a/block/blk-rq-qos.c b/block/blk-rq-qos.c
index d2f2af8aa10c..b7b02e04f64f 100644
--- a/block/blk-rq-qos.c
+++ b/block/blk-rq-qos.c
@@ -1,7 +1,5 @@
 #include "blk-rq-qos.h"
 
-#include "blk-wbt.h"
-
 /*
  * Increment 'v', if 'v' is below 'below'. Returns true if we succeeded,
  * false if 'v' + 1 would be bigger than 'below'.
@@ -29,13 +27,13 @@ bool rq_wait_inc_below(struct rq_wait *rq_wait, int limit)
 	return atomic_inc_below(&rq_wait->inflight, limit);
 }
 
-void rq_qos_cleanup(struct request_queue *q, enum wbt_flags wb_acct)
+void rq_qos_cleanup(struct request_queue *q, struct bio *bio)
 {
 	struct rq_qos *rqos;
 
 	for (rqos = q->rq_qos; rqos; rqos = rqos->next) {
 		if (rqos->ops->cleanup)
-			rqos->ops->cleanup(rqos, wb_acct);
+			rqos->ops->cleanup(rqos, bio);
 	}
 }
 
@@ -69,17 +67,25 @@ void rq_qos_requeue(struct request_queue *q, struct request *rq)
 	}
 }
 
-enum wbt_flags rq_qos_throttle(struct request_queue *q, struct bio *bio,
-			       spinlock_t *lock)
+void rq_qos_throttle(struct request_queue *q, struct bio *bio,
+		     spinlock_t *lock)
 {
 	struct rq_qos *rqos;
-	enum wbt_flags flags = 0;
 
 	for(rqos = q->rq_qos; rqos; rqos = rqos->next) {
 		if (rqos->ops->throttle)
-			flags |= rqos->ops->throttle(rqos, bio, lock);
+			rqos->ops->throttle(rqos, bio, lock);
+	}
+}
+
+void rq_qos_track(struct request_queue *q, struct request *rq, struct bio *bio)
+{
+	struct rq_qos *rqos;
+
+	for(rqos = q->rq_qos; rqos; rqos = rqos->next) {
+		if (rqos->ops->track)
+			rqos->ops->track(rqos, rq, bio);
 	}
-	return flags;
 }
 
 /*
diff --git a/block/blk-rq-qos.h b/block/blk-rq-qos.h
index a321e9e2ba70..501253676dd8 100644
--- a/block/blk-rq-qos.h
+++ b/block/blk-rq-qos.h
@@ -25,12 +25,12 @@ struct rq_qos {
 };
 
 struct rq_qos_ops {
-	enum wbt_flags (*throttle)(struct rq_qos *, struct bio *,
-				   spinlock_t *);
+	void (*throttle)(struct rq_qos *, struct bio *, spinlock_t *);
+	void (*track)(struct rq_qos *, struct request *, struct bio *);
 	void (*issue)(struct rq_qos *, struct request *);
 	void (*requeue)(struct rq_qos *, struct request *);
 	void (*done)(struct rq_qos *, struct request *);
-	void (*cleanup)(struct rq_qos *, enum wbt_flags);
+	void (*cleanup)(struct rq_qos *, struct bio *);
 	void (*exit)(struct rq_qos *);
 };
 
@@ -82,10 +82,11 @@ void rq_depth_scale_up(struct rq_depth *rqd);
 void rq_depth_scale_down(struct rq_depth *rqd, bool hard_throttle);
 bool rq_depth_calc_max_depth(struct rq_depth *rqd);
 
-void rq_qos_cleanup(struct request_queue *, enum wbt_flags);
+void rq_qos_cleanup(struct request_queue *, struct bio *);
 void rq_qos_done(struct request_queue *, struct request *);
 void rq_qos_issue(struct request_queue *, struct request *);
 void rq_qos_requeue(struct request_queue *, struct request *);
-enum wbt_flags rq_qos_throttle(struct request_queue *, struct bio *, spinlock_t *);
+void rq_qos_throttle(struct request_queue *, struct bio *, spinlock_t *);
+void rq_qos_track(struct request_queue *q, struct request *, struct bio *);
 void rq_qos_exit(struct request_queue *);
 #endif
diff --git a/block/blk-wbt.c b/block/blk-wbt.c
index 6fe20fb823e4..461a9af11efe 100644
--- a/block/blk-wbt.c
+++ b/block/blk-wbt.c
@@ -549,41 +549,66 @@ static inline bool wbt_should_throttle(struct rq_wb *rwb, struct bio *bio)
 	}
 }
 
+static enum wbt_flags bio_to_wbt_flags(struct rq_wb *rwb, struct bio *bio)
+{
+	enum wbt_flags flags = 0;
+
+	if (bio_op(bio) == REQ_OP_READ) {
+		flags = WBT_READ;
+	} else if (wbt_should_throttle(rwb, bio)) {
+		if (current_is_kswapd())
+			flags |= WBT_KSWAPD;
+		if (bio_op(bio) == REQ_OP_DISCARD)
+			flags |= WBT_DISCARD;
+		flags |= WBT_TRACKED;
+	}
+	return flags;
+}
+
+static void wbt_cleanup(struct rq_qos *rqos, struct bio *bio)
+{
+	struct rq_wb *rwb = RQWB(rqos);
+	enum wbt_flags flags = bio_to_wbt_flags(rwb, bio);
+	__wbt_done(rqos, flags);
+}
+
 /*
  * Returns true if the IO request should be accounted, false if not.
  * May sleep, if we have exceeded the writeback limits. Caller can pass
  * in an irq held spinlock, if it holds one when calling this function.
  * If we do sleep, we'll release and re-grab it.
  */
-static enum wbt_flags wbt_wait(struct rq_qos *rqos, struct bio *bio,
-			       spinlock_t *lock)
+static void wbt_wait(struct rq_qos *rqos, struct bio *bio, spinlock_t *lock)
 {
 	struct rq_wb *rwb = RQWB(rqos);
-	enum wbt_flags ret = 0;
+	enum wbt_flags flags;
 
 	if (!rwb_enabled(rwb))
-		return 0;
+		return;
 
-	if (bio_op(bio) == REQ_OP_READ)
-		ret = WBT_READ;
+	flags = bio_to_wbt_flags(rwb, bio);
 
 	if (!wbt_should_throttle(rwb, bio)) {
-		if (ret & WBT_READ)
+		if (flags & WBT_READ)
 			wb_timestamp(rwb, &rwb->last_issue);
-		return ret;
+		return;
 	}
 
 	if (current_is_kswapd())
-		ret |= WBT_KSWAPD;
+		flags |= WBT_KSWAPD;
 	if (bio_op(bio) == REQ_OP_DISCARD)
-		ret |= WBT_DISCARD;
+		flags |= WBT_DISCARD;
 
-	__wbt_wait(rwb, ret, bio->bi_opf, lock);
+	__wbt_wait(rwb, flags, bio->bi_opf, lock);
 
 	if (!blk_stat_is_active(rwb->cb))
 		rwb_arm_timer(rwb);
+}
 
-	return ret | WBT_TRACKED;
+static void wbt_track(struct rq_qos *rqos, struct request *rq, struct bio *bio)
+{
+	struct rq_wb *rwb = RQWB(rqos);
+	rq->wbt_flags |= bio_to_wbt_flags(rwb, bio);
 }
 
 void wbt_issue(struct rq_qos *rqos, struct request *rq)
@@ -707,9 +732,10 @@ EXPORT_SYMBOL_GPL(wbt_disable_default);
 static struct rq_qos_ops wbt_rqos_ops = {
 	.throttle = wbt_wait,
 	.issue = wbt_issue,
+	.track = wbt_track,
 	.requeue = wbt_requeue,
 	.done = wbt_done,
-	.cleanup = __wbt_done,
+	.cleanup = wbt_cleanup,
 	.exit = wbt_exit,
 };
 
diff --git a/block/blk-wbt.h b/block/blk-wbt.h
index 53b20a58c0a2..f47218d5b3b2 100644
--- a/block/blk-wbt.h
+++ b/block/blk-wbt.h
@@ -87,11 +87,6 @@ static inline unsigned int wbt_inflight(struct rq_wb *rwb)
 
 #ifdef CONFIG_BLK_WBT
 
-static inline void wbt_track(struct request *rq, enum wbt_flags flags)
-{
-	rq->wbt_flags |= flags;
-}
-
 int wbt_init(struct request_queue *);
 void wbt_update_limits(struct request_queue *);
 void wbt_disable_default(struct request_queue *);
-- 
2.14.3
