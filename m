Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8176B026C
	for <linux-mm@kvack.org>; Tue, 29 May 2018 17:17:48 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d5-v6so14232666qtg.17
        for <linux-mm@kvack.org>; Tue, 29 May 2018 14:17:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5-v6sor10192165qtp.21.2018.05.29.14.17.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 14:17:46 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 12/13] block: introduce blk-iolatency io controller
Date: Tue, 29 May 2018 17:17:23 -0400
Message-Id: <20180529211724.4531-13-josef@toxicpanda.com>
In-Reply-To: <20180529211724.4531-1-josef@toxicpanda.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

Current IO controllers for the block layer are less than ideal for our
use case.  The io.max controller is great at hard limiting, but it is
not work conserving.  This patch introduces io.latency.  You provide a
latency target for your group and we monitor the io in short windows to
make sure we are not exceeding those latency targets.  This makes use of
the rq-qos infrastructure and works much like the wbt stuff.  There are
a few differences from wbt

 - It's bio based, so the latency covers the whole block layer in addition to
   the actual io.
 - We will throttle all IO types that comes in here if we need to.
 - We use the mean latency over the 100ms window.  This is because writes can
   be particularly fast, which could give us a false sense of the impact of
   other workloads on our protected workload.
 - By default there's no throttling, we set the queue_depth to INT_MAX so that
   we can have as many outstanding bio's as we're allowed to.  Only at
   throttle time do we pay attention to the actual queue depth.
 - We backcharge cgroups for root cg issued IO and induce artificial
   delays in order to deal with cases like metadata only or swap heavy
   workloads.

In testing this has worked out relatively well.  Protected workloads
will throttle noisy workloads down to 1 io at time if they are doing
normal IO on their own, or induce up to a 1 second delay per syscall if
they are doing a lot of root issued IO (metadata/swap IO).

Our testing has revolved mostly around our production web servers where
we have hhvm (the web server application) in a protected group and
everything else in another group.  We see slightly higher requests per
second (RPS) on the test tier vs the control tier, and much more stable
RPS across all machines in the test tier vs the control tier.

Another test we run is a slow memory allocator in the unprotected group.
Before this would eventually push us into swap and cause the whole box
to die and not recover at all.  With these patches we see slight RPS
drops (usually 10-15%) before the memory consumer is properly killed and
things recover within seconds.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 block/Kconfig             |  12 +
 block/Makefile            |   1 +
 block/blk-iolatency.c     | 844 ++++++++++++++++++++++++++++++++++++++++++++++
 block/blk-sysfs.c         |   2 +
 block/blk.h               |   6 +
 include/linux/blk_types.h |   2 -
 6 files changed, 865 insertions(+), 2 deletions(-)
 create mode 100644 block/blk-iolatency.c

diff --git a/block/Kconfig b/block/Kconfig
index 28ec55752b68..a4e800f57688 100644
--- a/block/Kconfig
+++ b/block/Kconfig
@@ -149,6 +149,18 @@ config BLK_WBT
 	dynamically on an algorithm loosely based on CoDel, factoring in
 	the realtime performance of the disk.
 
+config BLK_CGROUP_IOLATENCY
+	bool "Enable support for latency based cgroup io protection"
+	depends on BLK_CGROUP=y
+	default n
+	---help---
+	Enabling this option enables the .latency interface for io throttling.
+	The io controller will attempt to maintain average io latencies below
+	the configured latency target, throttling anybody with a higher latency
+	target than the victimized group.
+
+	Note, this is an experimental interface and could be changed someday.
+
 config BLK_WBT_SQ
 	bool "Single queue writeback throttling"
 	default n
diff --git a/block/Makefile b/block/Makefile
index 981605042cad..645fdabe6a8e 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -17,6 +17,7 @@ obj-$(CONFIG_BLK_DEV_BSG)	+= bsg.o
 obj-$(CONFIG_BLK_DEV_BSGLIB)	+= bsg-lib.o
 obj-$(CONFIG_BLK_CGROUP)	+= blk-cgroup.o
 obj-$(CONFIG_BLK_DEV_THROTTLING)	+= blk-throttle.o
+obj-$(CONFIG_BLK_CGROUP_IOLATENCY)	+= blk-iolatency.o
 obj-$(CONFIG_IOSCHED_NOOP)	+= noop-iosched.o
 obj-$(CONFIG_IOSCHED_DEADLINE)	+= deadline-iosched.o
 obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
diff --git a/block/blk-iolatency.c b/block/blk-iolatency.c
new file mode 100644
index 000000000000..66bed2fa3b42
--- /dev/null
+++ b/block/blk-iolatency.c
@@ -0,0 +1,844 @@
+/*
+ * Block rq-qos base io controller
+ *
+ * This works similar to wbt with a few exceptions
+ *
+ * - It's bio based, so the latency covers the whole block layer in addition to
+ *   the actual io.
+ * - We will throttle all IO that comes in here if we need to.
+ * - We use the mean latency over the 100ms window.  This is because writes can
+ *   be particularly fast, which could give us a false sense of the impact of
+ *   other workloads on our protected workload.
+ * - By default there's no throttling, we set the queue_depth to INT_MAX so that
+ *   we can have as many outstanding bio's as we're allowed to.  Only at
+ *   throttle time do we pay attention to the actual queue depth.
+ *
+ * The hierarchy works like the cpu controller does, we track the latency at
+ * every configured node, and each configured node has it's own independent
+ * queue depth.  This means that we only care about our latency targets at the
+ * peer level.  Some group at the bottom of the hierarchy isn't going to affect
+ * a group at the end of some other path if we're only configred at leaf level.
+ *
+ * Consider the following
+ *
+ *                   root blkg
+ *             /                     \
+ *        fast (target=5ms)     slow (target=10ms)
+ *         /     \                  /        \
+ *       a        b          normal(15ms)   unloved
+ *
+ * "a" and "b" have no target, but their combined io under "fast" cannot exceed
+ * an average latency of 5ms.  If it does then we will throttle the "slow"
+ * group.  In the case of "normal", if it exceeds its 15ms target, we will
+ * throttle "unloved", but nobody else.
+ *
+ * In this example "fast", "slow", and "normal" will be the only groups actually
+ * accounting their io latencies.  We have to walk up the heirarchy to the root
+ * on every submit and complete so we can do the appropriate stat recording and
+ * adjust the queue depth of ourselves if needed.
+ *
+ * There are 2 ways we throttle IO.
+ *
+ * 1) Queue depth throttling.  As we throttle down we will adjust the maximum
+ * number of IO's we're allowed to have in flight.  This starts at (u64)-1 down
+ * to 1.  If the group is only ever submitting IO for itself then this is the
+ * only way we throttle.
+ *
+ * 2) Induced delay throttling.  This is for the case that a group is generating
+ * IO that has to be issued by the root cg to avoid priority inversion. So think
+ * REQ_META or REQ_SWAP.  If we are already at qd == 1 and we're getting a lot
+ * of work done for us on behalf of the root cg and are being asked to scale
+ * down more then we induce a latency at userspace return.  We accumulate the
+ * total amount of time we need to be punished by doing
+ *
+ * total_time += min_lat_nsec - actual_io_completion
+ *
+ * and then at throttle time will do
+ *
+ * throttle_time = min(total_time, NSEC_PER_SEC)
+ *
+ * This induced delay will throttle back the activity that is generating the
+ * root cg issued io's, wethere that's some metadata intensive operation or the
+ * group is using so much memory that it is pushing us into swap.
+ *
+ * Copyright (C) 2018 Josef Bacik
+ */
+#include <linux/kernel.h>
+#include <linux/blk_types.h>
+#include <linux/backing-dev.h>
+#include <linux/module.h>
+#include <linux/timer.h>
+#include <linux/memcontrol.h>
+#include <trace/events/block.h>
+#include "blk-wbt.h"
+
+#define DEFAULT_SCALE_COOKIE 1000000U
+
+static struct blkcg_policy blkcg_policy_iolatency;
+struct iolatency_grp;
+
+struct blk_iolatency {
+	struct rq_qos rqos;
+	struct timer_list timer;
+	atomic_t enabled;
+};
+
+static inline struct blk_iolatency *BLKIOLATENCY(struct rq_qos *rqos)
+{
+	return container_of(rqos, struct blk_iolatency, rqos);
+}
+
+static inline bool blk_iolatency_enabled(struct blk_iolatency *blkiolat)
+{
+	return atomic_read(&blkiolat->enabled) > 0;
+}
+
+struct child_latency_info {
+	spinlock_t lock;
+
+	/* Last time we adjusted the scale of everybody. */
+	u64 last_scale_event;
+
+	/* The latency that we missed. */
+	u64 scale_lat;
+
+	/* The guy who actually changed the latency numbers. */
+	struct iolatency_grp *scale_grp;
+
+	/* Cookie to tell if we need to scale up or down. */
+	atomic_t scale_cookie;
+};
+
+struct iolatency_grp {
+	struct blkg_policy_data pd;
+	struct blk_rq_stat __percpu *stats;
+	struct blk_iolatency *blkiolat;
+	struct rq_depth rq_depth;
+	struct rq_wait rq_wait;
+	atomic64_t window_start;
+	atomic_t scale_cookie;
+	u64 min_lat_nsec;
+	u64 cur_win_nsec;
+
+	/* total running average of our io latency. */
+	u64 total_lat_avg;
+	u64 total_lat_nr;
+
+	struct child_latency_info child_lat;
+};
+
+static inline struct iolatency_grp *pd_to_lat(struct blkg_policy_data *pd)
+{
+	return container_of(pd, struct iolatency_grp, pd);
+}
+
+static inline struct iolatency_grp *blkg_to_lat(struct blkcg_gq *blkg)
+{
+	return pd_to_lat(blkg_to_pd(blkg, &blkcg_policy_iolatency));
+}
+
+static inline struct blkcg_gq *lat_to_blkg(struct iolatency_grp *iolat)
+{
+	return pd_to_blkg(&iolat->pd);
+}
+
+static inline bool iolatency_may_queue(struct iolatency_grp *iolat,
+				       wait_queue_entry_t *wait)
+{
+	struct rq_wait *rqw = &iolat->rq_wait;
+
+	if (waitqueue_active(&rqw->wait) &&
+	    rqw->wait.head.next != &wait->entry)
+		return false;
+	return rq_wait_inc_below(rqw, iolat->rq_depth.max_depth);
+}
+
+static void __blkcg_iolatency_throttle(struct rq_qos *rqos,
+				       struct iolatency_grp *iolat,
+				       spinlock_t *lock, bool issue_as_root,
+				       bool use_memdelay)
+	__releases(lock)
+	__acquires(lock)
+{
+	struct rq_wait *rqw = &iolat->rq_wait;
+	unsigned use_delay = atomic_read(&lat_to_blkg(iolat)->use_delay);
+	DEFINE_WAIT(wait);
+
+	if (use_delay)
+		blkcg_schedule_throttle(rqos->q, use_memdelay);
+
+	/* We don't wait for a qd slot, we just take what we want. */
+	if (issue_as_root) {
+		atomic_inc(&rqw->inflight);
+		return;
+	}
+
+	if (iolatency_may_queue(iolat, &wait))
+		return;
+
+	do {
+		prepare_to_wait_exclusive(&rqw->wait, &wait,
+					  TASK_UNINTERRUPTIBLE);
+		if (iolatency_may_queue(iolat, &wait))
+			break;
+
+		if (lock) {
+			spin_unlock_irq(lock);
+			io_schedule();
+			spin_lock_irq(lock);
+		} else {
+			io_schedule();
+		}
+	} while (1);
+
+	finish_wait(&rqw->wait, &wait);
+}
+
+#define SCALE_DOWN_FACTOR 2
+#define SCALE_UP_FACTOR 4
+
+static inline unsigned long scale_amount(unsigned long qd, bool up)
+{
+	return max(up ? qd >> SCALE_UP_FACTOR : qd >> SCALE_DOWN_FACTOR, 1UL);
+}
+
+/*
+ * We scale the qd down faster than we scale up, so we need to use this helper
+ * to adjust the scale_cookie accordingly so we don't prematurely get
+ * scale_cookie at DEFAULT_SCALE_COOKIE and unthrottle too much.
+ */
+static void scale_cookie_change(struct blk_iolatency *blkiolat,
+				struct child_latency_info *lat_info,
+				bool up)
+{
+	unsigned long qd = blk_queue_depth(blkiolat->rqos.q);
+	unsigned long scale = scale_amount(qd, up);
+	unsigned long old = atomic_read(&lat_info->scale_cookie);
+
+	if (up) {
+		if (scale + old > DEFAULT_SCALE_COOKIE)
+			atomic_set(&lat_info->scale_cookie,
+				   DEFAULT_SCALE_COOKIE);
+		else if (DEFAULT_SCALE_COOKIE - old > qd)
+			atomic_inc(&lat_info->scale_cookie);
+		else
+			atomic_add(scale, &lat_info->scale_cookie);
+	} else {
+		if (DEFAULT_SCALE_COOKIE - old > qd)
+			atomic_dec(&lat_info->scale_cookie);
+		else
+			atomic_sub(scale, &lat_info->scale_cookie);
+	}
+}
+
+/*
+ * Change the queue depth of the iolatency_grp.  We add/subtract 1/16th of the
+ * queue depth at a time so we don't get wild swings and hopefully dial in to
+ * fairer distribution of the overall queue depth.
+ */
+static void scale_change(struct iolatency_grp *iolat, bool up)
+{
+	unsigned long qd = blk_queue_depth(iolat->blkiolat->rqos.q);
+	unsigned long scale = scale_amount(qd, up);
+	unsigned long old = iolat->rq_depth.max_depth;
+	bool changed = false;
+
+	if (old > qd)
+		old = qd;
+
+	if (up) {
+		if (old == 1 && blkcg_unuse_delay(lat_to_blkg(iolat)))
+			return;
+
+		if (old < qd) {
+			changed = true;
+			old += scale;
+			old = min(old, qd);
+			iolat->rq_depth.max_depth = old;
+			wake_up_all(&iolat->rq_wait.wait);
+		}
+	} else if (old > 1) {
+		old >>= 1;
+		changed = true;
+		iolat->rq_depth.max_depth = max(old, 1UL);
+	}
+}
+
+/* Check our parent and see if the scale cookie has changed. */
+static void check_scale_change(struct iolatency_grp *iolat)
+{
+	struct iolatency_grp *parent;
+	struct child_latency_info *lat_info;
+	unsigned int cur_cookie;
+	unsigned int our_cookie = atomic_read(&iolat->scale_cookie);
+	u64 scale_lat;
+	unsigned int old;
+	int direction = 0;
+
+	if (lat_to_blkg(iolat)->parent == NULL)
+		return;
+
+	parent = blkg_to_lat(lat_to_blkg(iolat)->parent);
+	lat_info = &parent->child_lat;
+	cur_cookie = atomic_read(&lat_info->scale_cookie);
+	scale_lat = READ_ONCE(lat_info->scale_lat);
+
+	if (cur_cookie < our_cookie)
+		direction = -1;
+	else if (cur_cookie > our_cookie)
+		direction = 1;
+	else
+		return;
+
+	old = atomic_cmpxchg(&iolat->scale_cookie, our_cookie, cur_cookie);
+
+	/* Somebody beat us to the punch, just bail. */
+	if (old != our_cookie)
+		return;
+
+	if (direction < 0 && (!scale_lat || iolat->min_lat_nsec <= scale_lat))
+		return;
+
+	/* We're as low as we can go. */
+	if (iolat->rq_depth.max_depth == 1 && direction < 0) {
+		blkcg_use_delay(lat_to_blkg(iolat));
+		return;
+	}
+
+	/* We're back to the default cookie, unthrottle all the things. */
+	if (cur_cookie == DEFAULT_SCALE_COOKIE) {
+		blkcg_clear_delay(lat_to_blkg(iolat));
+		iolat->rq_depth.max_depth = INT_MAX;
+		wake_up_all(&iolat->rq_wait.wait);
+		return;
+	}
+
+	scale_change(iolat, direction > 0);
+}
+
+static void blkcg_iolatency_throttle(struct rq_qos *rqos, struct bio *bio,
+				     spinlock_t *lock)
+{
+	struct blk_iolatency *blkiolat = BLKIOLATENCY(rqos);
+	struct blkcg *blkcg;
+	struct blkcg_gq *blkg;
+	struct request_queue *q = rqos->q;
+	bool issue_as_root = bio_issue_as_root_blkg(bio);
+
+	if (!blk_iolatency_enabled(blkiolat))
+		return;
+
+	rcu_read_lock();
+	blkcg = bio_blkcg(bio);
+	bio_associate_blkcg(bio, &blkcg->css);
+	blkg = blkg_lookup(blkcg, q);
+	if (unlikely(!blkg)) {
+		if (!lock)
+			spin_lock_irq(q->queue_lock);
+		blkg = blkg_lookup_create(blkcg, q);
+		if (IS_ERR(blkg))
+			blkg = NULL;
+		if (!lock)
+			spin_unlock_irq(q->queue_lock);
+	}
+	if (!blkg)
+		goto out;
+
+	bio_issue_init(&bio->bi_issue, bio_sectors(bio));
+	bio_associate_blkg(bio, blkg);
+out:
+	rcu_read_unlock();
+	while (blkg && blkg->parent) {
+		struct iolatency_grp *iolat = blkg_to_lat(blkg);
+
+		check_scale_change(iolat);
+		__blkcg_iolatency_throttle(rqos, iolat, lock, issue_as_root,
+				     (bio->bi_opf & REQ_SWAP) == REQ_SWAP);
+		blkg = blkg->parent;
+	}
+	if (!timer_pending(&blkiolat->timer))
+		mod_timer(&blkiolat->timer, jiffies + HZ);
+}
+
+static void iolatency_record_time(struct iolatency_grp *iolat,
+				  struct bio_issue *issue, u64 now,
+				  bool issue_as_root)
+{
+	struct blk_rq_stat *rq_stat;
+	u64 start = bio_issue_time(issue);
+
+	if (now <= start)
+		return;
+
+	/*
+	 * We don't want to count issue_as_root bio's in the cgroups latency
+	 * statistics as it could skew the numbers downwards.
+	 */
+	if (unlikely(issue_as_root && iolat->rq_depth.max_depth != (u64)-1)) {
+		u64 sub = iolat->min_lat_nsec;
+		now -= start;
+		if (now < sub)
+			blkcg_add_delay(lat_to_blkg(iolat), now, sub - now);
+		return;
+	}
+
+	rq_stat = get_cpu_ptr(iolat->stats);
+	blk_rq_stat_add(rq_stat, now - start);
+	put_cpu_ptr(rq_stat);
+}
+
+#define BLKIOLATENCY_MIN_ADJUST_TIME (500 * NSEC_PER_MSEC)
+#define BLKIOLATENCY_MIN_GOOD_SAMPLES 5
+
+static void iolatency_check_latencies(struct iolatency_grp *iolat, u64 now)
+{
+	struct blkcg_gq *blkg = lat_to_blkg(iolat);
+	struct iolatency_grp *parent;
+	struct child_latency_info *lat_info;
+	struct blk_rq_stat stat;
+	unsigned long flags;
+	int cpu;
+
+	blk_rq_stat_init(&stat);
+	preempt_disable();
+	for_each_online_cpu(cpu) {
+		struct blk_rq_stat *s;
+		s = per_cpu_ptr(iolat->stats, cpu);
+		blk_rq_stat_sum(&stat, s);
+		blk_rq_stat_init(s);
+	}
+	preempt_enable();
+
+	/*
+	 * Our average exceeded our window, scale up our window so we are more
+	 * accurate, but not more than the global timer.
+	 */
+	if (stat.mean > iolat->cur_win_nsec) {
+		iolat->cur_win_nsec <<= 1;
+		iolat->cur_win_nsec =
+			max_t(u64, iolat->cur_win_nsec, NSEC_PER_SEC);
+	}
+
+	if (!blkg->parent)
+		return;
+
+	parent = blkg_to_lat(blkg->parent);
+	lat_info = &parent->child_lat;
+
+	iolat->total_lat_avg =
+		div64_u64((iolat->total_lat_avg * iolat->total_lat_nr) +
+			  stat.mean, iolat->total_lat_nr + 1);
+
+	iolat->total_lat_nr++;
+
+	/* Everything is ok and we don't need to adjust the scale. */
+	if (stat.mean <= iolat->min_lat_nsec &&
+	    atomic_read(&lat_info->scale_cookie) == DEFAULT_SCALE_COOKIE)
+		return;
+
+	/* Somebody beat us to the punch, just bail. */
+	spin_lock_irqsave(&lat_info->lock, flags);
+	if ((lat_info->last_scale_event >= now ||
+	    now - lat_info->last_scale_event < BLKIOLATENCY_MIN_ADJUST_TIME) &&
+	    lat_info->scale_lat <= iolat->min_lat_nsec)
+		goto out;
+
+	if (stat.mean <= iolat->min_lat_nsec &&
+	    stat.nr_samples >= BLKIOLATENCY_MIN_GOOD_SAMPLES) {
+		lat_info->last_scale_event = now;
+		if (lat_info->scale_grp == iolat)
+			scale_cookie_change(iolat->blkiolat, lat_info, true);
+	} else if (stat.mean > iolat->min_lat_nsec) {
+		lat_info->last_scale_event = now;
+		if (!lat_info->scale_grp ||
+		    lat_info->scale_lat > iolat->min_lat_nsec) {
+			WRITE_ONCE(lat_info->scale_lat, iolat->min_lat_nsec);
+			lat_info->scale_grp = iolat;
+		}
+		scale_cookie_change(iolat->blkiolat, lat_info, false);
+	}
+out:
+	spin_unlock_irqrestore(&lat_info->lock, flags);
+}
+
+static void blkcg_iolatency_done_bio(struct rq_qos *rqos, struct bio *bio)
+{
+	struct blkcg_gq *blkg;
+	struct rq_wait *rqw;
+	struct iolatency_grp *iolat;
+	u64 window_start;
+	u64 now = ktime_to_ns(ktime_get());
+	bool issue_as_root = bio_issue_as_root_blkg(bio);
+	bool enabled = false;
+
+	blkg = bio->bi_blkg;
+	if (!blkg)
+		return;
+
+	iolat = blkg_to_lat(blkg);
+	enabled = blk_iolatency_enabled(iolat->blkiolat);
+
+	while (blkg->parent) {
+		iolat = blkg_to_lat(blkg);
+		rqw = &iolat->rq_wait;
+
+		atomic_dec(&rqw->inflight);
+		if (!enabled || iolat->min_lat_nsec == 0)
+			goto next;
+		iolatency_record_time(iolat, &bio->bi_issue, now,
+				      issue_as_root);
+		window_start = atomic64_read(&iolat->window_start);
+		if (now > window_start &&
+		    (now - window_start) >= iolat->cur_win_nsec) {
+			if (atomic64_cmpxchg(&iolat->window_start,
+					window_start, now) == window_start)
+				iolatency_check_latencies(iolat, now);
+		}
+next:
+		wake_up_all(&rqw->wait);
+		blkg = blkg->parent;
+	}
+}
+
+static void blkcg_iolatency_cleanup(struct rq_qos *rqos, struct bio *bio)
+{
+	struct blkcg_gq *blkg;
+
+	blkg = bio->bi_blkg;
+	while (blkg && blkg->parent) {
+		struct rq_wait *rqw;
+		struct iolatency_grp *iolat;
+
+		iolat = blkg_to_lat(blkg);
+		rqw = &iolat->rq_wait;
+
+		atomic_dec(&rqw->inflight);
+		wake_up_all(&rqw->wait);
+		blkg = blkg->parent;
+	}
+}
+
+static void blkcg_iolatency_exit(struct rq_qos *rqos)
+{
+	struct blk_iolatency *blkiolat = BLKIOLATENCY(rqos);
+
+	del_timer_sync(&blkiolat->timer);
+	blkcg_deactivate_policy(rqos->q, &blkcg_policy_iolatency);
+	kfree(blkiolat);
+}
+
+static struct rq_qos_ops blkcg_iolatency_ops = {
+	.throttle = blkcg_iolatency_throttle,
+	.cleanup = blkcg_iolatency_cleanup,
+	.done_bio = blkcg_iolatency_done_bio,
+	.exit = blkcg_iolatency_exit,
+};
+
+static void blkiolatency_timer_fn(struct timer_list *t)
+{
+	struct blk_iolatency *blkiolat = from_timer(blkiolat, t, timer);
+	struct blkcg_gq *blkg;
+	struct cgroup_subsys_state *pos_css;
+	u64 now = ktime_to_ns(ktime_get());
+
+	rcu_read_lock();
+	blkg_for_each_descendant_pre(blkg, pos_css,
+				     blkiolat->rqos.q->root_blkg) {
+		struct iolatency_grp *iolat = blkg_to_lat(blkg);
+		struct child_latency_info *lat_info = &iolat->child_lat;
+		unsigned long flags;
+		u64 cookie = atomic_read(&lat_info->scale_cookie);
+
+		if (cookie >= DEFAULT_SCALE_COOKIE)
+			continue;
+
+		spin_lock_irqsave(&lat_info->lock, flags);
+		if (lat_info->last_scale_event >= now)
+			goto next;
+
+		/*
+		 * We scaled down but don't have a scale_grp, scale up and carry
+		 * on.
+		 */
+		if (lat_info->scale_grp == NULL) {
+			scale_cookie_change(iolat->blkiolat, lat_info, true);
+			goto next;
+		}
+
+		/*
+		 * It's been 5 seconds since our last scale event, clear the
+		 * scale grp in case the group that needed the scale down isn't
+		 * doing any IO currently.
+		 */
+		if (now - lat_info->last_scale_event >=
+		    ((u64)NSEC_PER_SEC * 5))
+			lat_info->scale_grp = NULL;
+next:
+		spin_unlock_irqrestore(&lat_info->lock, flags);
+	}
+	rcu_read_unlock();
+}
+
+int blk_iolatency_init(struct request_queue *q)
+{
+	struct blk_iolatency *blkiolat;
+	struct rq_qos *rqos;
+	int ret;
+
+	blkiolat = kzalloc(sizeof(*blkiolat), GFP_KERNEL);
+	if (!blkiolat)
+		return -ENOMEM;
+
+	rqos = &blkiolat->rqos;
+	rqos->id = RQ_QOS_CGROUP;
+	rqos->ops = &blkcg_iolatency_ops;
+	rqos->q = q;
+
+	rq_qos_add(q, rqos);
+
+	ret = blkcg_activate_policy(q, &blkcg_policy_iolatency);
+	if (ret) {
+		kfree(blkiolat);
+		return ret;
+	}
+
+	timer_setup(&blkiolat->timer, blkiolatency_timer_fn,
+		    (unsigned long)blkiolat);
+
+	return 0;
+}
+
+static void iolatency_set_min_lat_nsec(struct blkcg_gq *blkg, u64 val)
+{
+	struct iolatency_grp *iolat = blkg_to_lat(blkg);
+	struct blk_iolatency *blkiolat = iolat->blkiolat;
+	u64 oldval = iolat->min_lat_nsec;
+
+	iolat->min_lat_nsec = val;
+	iolat->cur_win_nsec = max_t(u64, val << 4, 100 * NSEC_PER_MSEC);
+	iolat->cur_win_nsec = min_t(u64, iolat->cur_win_nsec, NSEC_PER_SEC);
+
+	if (!oldval && val)
+		atomic_inc(&blkiolat->enabled);
+	if (oldval && !val)
+		atomic_dec(&blkiolat->enabled);
+}
+
+static void iolatency_clear_scaling(struct blkcg_gq *blkg)
+{
+	if (blkg->parent) {
+		struct iolatency_grp *iolat = blkg_to_lat(blkg->parent);
+		struct child_latency_info *lat_info = &iolat->child_lat;
+
+		spin_lock_irq(&lat_info->lock);
+		atomic_set(&lat_info->scale_cookie, DEFAULT_SCALE_COOKIE);
+		lat_info->last_scale_event = 0;
+		lat_info->scale_grp = NULL;
+		lat_info->scale_lat = 0;
+		spin_unlock_irq(&lat_info->lock);
+	}
+}
+
+static ssize_t iolatency_set_limit(struct kernfs_open_file *of, char *buf,
+			     size_t nbytes, loff_t off)
+{
+	struct blkcg *blkcg = css_to_blkcg(of_css(of));
+	struct blkcg_gq *blkg;
+	struct blk_iolatency *blkiolat;
+	struct blkg_conf_ctx ctx;
+	struct iolatency_grp *iolat;
+	char *p, *tok;
+	u64 lat_val = 0;
+	u64 oldval;
+	int ret;
+
+	ret = blkg_conf_prep(blkcg, &blkcg_policy_iolatency, buf, &ctx);
+	if (ret)
+		return ret;
+
+	iolat = blkg_to_lat(ctx.blkg);
+	blkiolat = iolat->blkiolat;
+	p = ctx.body;
+
+	ret = -EINVAL;
+	while ((tok = strsep(&p, " "))) {
+		char key[16];
+		char val[21];	/* 18446744073709551616 */
+
+		if (sscanf(tok, "%15[^=]=%20s", key, val) != 2)
+			goto out;
+
+		if (!strcmp(key, "target")) {
+			u64 v;
+
+			if (!strcmp(val, "max"))
+				lat_val = 0;
+			else if (sscanf(val, "%llu", &v) == 1)
+				lat_val = v * NSEC_PER_USEC;
+			else
+				goto out;
+		} else {
+			goto out;
+		}
+	}
+
+	/* Walk up the tree to see if our new val is lower than it should be. */
+	blkg = ctx.blkg;
+	oldval = iolat->min_lat_nsec;
+
+	iolatency_set_min_lat_nsec(blkg, lat_val);
+	if (oldval != iolat->min_lat_nsec)
+		iolatency_clear_scaling(blkg);
+
+	ret = 0;
+out:
+	blkg_conf_finish(&ctx);
+	return ret ?: nbytes;
+}
+
+static u64 iolatency_prfill_limit(struct seq_file *sf,
+				  struct blkg_policy_data *pd, int off)
+{
+	struct iolatency_grp *iolat = pd_to_lat(pd);
+	const char *dname = blkg_dev_name(pd->blkg);
+
+	if (!dname || !iolat->min_lat_nsec)
+		return 0;
+	seq_printf(sf, "%s target=%llu\n",
+		   dname,
+		   (unsigned long long)iolat->min_lat_nsec / NSEC_PER_USEC);
+	return 0;
+}
+
+static int iolatency_print_limit(struct seq_file *sf, void *v)
+{
+	blkcg_print_blkgs(sf, css_to_blkcg(seq_css(sf)),
+			  iolatency_prfill_limit,
+			  &blkcg_policy_iolatency, seq_cft(sf)->private, false);
+	return 0;
+}
+
+static size_t iolatency_pd_stat(struct blkg_policy_data *pd, char *buf,
+				size_t size)
+{
+	struct iolatency_grp *iolat = pd_to_lat(pd);
+	struct blkcg_gq *blkg = pd_to_blkg(pd);
+	unsigned use_delay = atomic_read(&blkg->use_delay);
+
+	if (!iolat->min_lat_nsec)
+		return 0;
+
+	return snprintf(buf, size,
+			" depth=%u delay=%llu use_delay=%u total_lat_avg=%llu",
+			iolat->rq_depth.max_depth,
+			(unsigned long long)(use_delay ?
+				atomic64_read(&blkg->delay_nsec) /
+				NSEC_PER_USEC : 0),
+			use_delay,
+			(unsigned long long)iolat->total_lat_avg /
+			NSEC_PER_USEC);
+}
+
+
+static struct blkg_policy_data *iolatency_pd_alloc(gfp_t gfp, int node)
+{
+	struct iolatency_grp *iolat;
+
+	iolat = kzalloc_node(sizeof(*iolat), gfp, node);
+	if (!iolat)
+		return NULL;
+	iolat->stats = __alloc_percpu_gfp(sizeof(struct blk_rq_stat),
+				       __alignof__(struct blk_rq_stat), gfp);
+	if (!iolat->stats) {
+		kfree(iolat);
+		return NULL;
+	}
+	return &iolat->pd;
+}
+
+static void iolatency_pd_init(struct blkg_policy_data *pd)
+{
+	struct iolatency_grp *iolat = pd_to_lat(pd);
+	struct blkcg_gq *blkg = lat_to_blkg(iolat);
+	struct rq_qos *rqos = blkcg_rq_qos(blkg->q);
+	struct blk_iolatency *blkiolat = BLKIOLATENCY(rqos);
+	u64 now = ktime_to_ns(ktime_get());
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct blk_rq_stat *stat;
+		stat = per_cpu_ptr(iolat->stats, cpu);
+		blk_rq_stat_init(stat);
+	}
+
+	rq_wait_init(&iolat->rq_wait);
+	spin_lock_init(&iolat->child_lat.lock);
+	iolat->rq_depth.queue_depth = blk_queue_depth(blkg->q);
+	iolat->rq_depth.max_depth = INT_MAX;
+	iolat->rq_depth.default_depth = iolat->rq_depth.queue_depth;
+	iolat->blkiolat = blkiolat;
+	iolat->cur_win_nsec = 100 * NSEC_PER_MSEC;
+	atomic64_set(&iolat->window_start, now);
+
+	/*
+	 * We init things in list order, so the pd for the parent may not be
+	 * init'ed yet for whatever reason.
+	 */
+	if (blkg->parent && blkg_to_pd(blkg->parent, &blkcg_policy_iolatency)) {
+		struct iolatency_grp *parent = blkg_to_lat(blkg->parent);
+		atomic_set(&iolat->scale_cookie,
+			   atomic_read(&parent->child_lat.scale_cookie));
+	} else {
+		atomic_set(&iolat->scale_cookie, DEFAULT_SCALE_COOKIE);
+	}
+
+	atomic_set(&iolat->child_lat.scale_cookie, DEFAULT_SCALE_COOKIE);
+}
+
+static void iolatency_pd_offline(struct blkg_policy_data *pd)
+{
+	struct iolatency_grp *iolat = pd_to_lat(pd);
+	struct blkcg_gq *blkg = lat_to_blkg(iolat);
+
+	iolatency_set_min_lat_nsec(blkg, 0);
+	iolatency_clear_scaling(blkg);
+}
+
+static void iolatency_pd_free(struct blkg_policy_data *pd)
+{
+	struct iolatency_grp *iolat = pd_to_lat(pd);
+	free_percpu(iolat->stats);
+	kfree(iolat);
+}
+
+static struct cftype iolatency_files[] = {
+	{
+		.name = "latency",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = iolatency_print_limit,
+		.write = iolatency_set_limit,
+	},
+	{}
+};
+
+static struct blkcg_policy blkcg_policy_iolatency = {
+	.dfl_cftypes	= iolatency_files,
+	.pd_alloc_fn	= iolatency_pd_alloc,
+	.pd_init_fn	= iolatency_pd_init,
+	.pd_offline_fn	= iolatency_pd_offline,
+	.pd_free_fn	= iolatency_pd_free,
+	.pd_stat_fn	= iolatency_pd_stat,
+};
+
+static int __init iolatency_init(void)
+{
+	return blkcg_policy_register(&blkcg_policy_iolatency);
+}
+
+static void __exit iolatency_exit(void)
+{
+	return blkcg_policy_unregister(&blkcg_policy_iolatency);
+}
+
+module_init(iolatency_init);
+module_exit(iolatency_exit);
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 6c23404c01db..05f3a8ba564f 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -904,6 +904,8 @@ int blk_register_queue(struct gendisk *disk)
 
 	wbt_enable_default(q);
 
+	blk_iolatency_init(q);
+
 	blk_throtl_register_queue(q);
 
 	if (q->request_fn || (q->mq_ops && q->elevator)) {
diff --git a/block/blk.h b/block/blk.h
index eaf1a8e87d11..f4752eb0eb56 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -409,4 +409,10 @@ static inline void blk_queue_bounce(struct request_queue *q, struct bio **bio)
 
 extern void blk_drain_queue(struct request_queue *q);
 
+#ifdef CONFIG_BLK_CGROUP_IOLATENCY
+extern void blk_iolatency_init(struct request_queue *q);
+#else
+static inline void blk_iolatency_init(struct request_queue *q) { }
+#endif
+
 #endif /* BLK_INTERNAL_H */
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 4f7ba397d37d..f91f8334000a 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -180,9 +180,7 @@ struct bio {
 	struct io_context	*bi_ioc;
 	struct cgroup_subsys_state *bi_css;
 	struct blkcg_gq		*bi_blkg;
-#ifdef CONFIG_BLK_DEV_THROTTLING_LOW
 	struct bio_issue	bi_issue;
-#endif
 #endif
 	union {
 #if defined(CONFIG_BLK_DEV_INTEGRITY)
-- 
2.14.3
