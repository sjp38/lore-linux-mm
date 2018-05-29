Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C91816B0010
	for <linux-mm@kvack.org>; Tue, 29 May 2018 17:17:37 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q13-v6so14262809qtk.8
        for <linux-mm@kvack.org>; Tue, 29 May 2018 14:17:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a2-v6sor21770404qtd.74.2018.05.29.14.17.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 14:17:36 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 06/13] blkcg: add generic throttling mechanism
Date: Tue, 29 May 2018 17:17:17 -0400
Message-Id: <20180529211724.4531-7-josef@toxicpanda.com>
In-Reply-To: <20180529211724.4531-1-josef@toxicpanda.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

Since IO can be issued from literally anywhere it's almost impossible to
do throttling without having some sort of adverse effect somewhere else
in the system because of locking or other dependencies.  The best way to
solve this is to do the throttling when we know we aren't holding any
other kernel resources.  Do this by tracking throttling in a per-blkg
basis, and if we require throttling flag the task that it needs to check
before it returns to user space and possibly sleep there.

This is to address the case where a process is doing work that is
generating IO that can't be throttled, whether that is directly with a
lot of REQ_META IO, or indirectly by allocating so much memory that it
is swamping the disk with REQ_SWAP.  We can't use task_add_work as we
don't want to induce a memory allocation in the IO path, so simply
saving the request queue in the task and flagging it to do the
notify_resume thing achieves the same result without the overhead of a
memory allocation.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 block/blk-cgroup.c          | 135 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/blk-cgroup.h  |  49 ++++++++++++++++
 include/linux/cgroup-defs.h |   3 +
 include/linux/sched.h       |   5 ++
 include/linux/tracehook.h   |   2 +
 5 files changed, 194 insertions(+)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 9e767e4a852d..5249059d0cff 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -27,6 +27,7 @@
 #include <linux/atomic.h>
 #include <linux/ctype.h>
 #include <linux/blk-cgroup.h>
+#include <linux/tracehook.h>
 #include "blk.h"
 
 #define MAX_KEY_LEN 100
@@ -1334,6 +1335,13 @@ static void blkcg_bind(struct cgroup_subsys_state *root_css)
 	mutex_unlock(&blkcg_pol_mutex);
 }
 
+static void blkcg_exit(struct task_struct *tsk)
+{
+	if (tsk->throttle_queue)
+		blk_put_queue(tsk->throttle_queue);
+	tsk->throttle_queue = NULL;
+}
+
 struct cgroup_subsys io_cgrp_subsys = {
 	.css_alloc = blkcg_css_alloc,
 	.css_offline = blkcg_css_offline,
@@ -1343,6 +1351,7 @@ struct cgroup_subsys io_cgrp_subsys = {
 	.dfl_cftypes = blkcg_files,
 	.legacy_cftypes = blkcg_legacy_files,
 	.legacy_name = "blkio",
+	.exit = blkcg_exit,
 #ifdef CONFIG_MEMCG
 	/*
 	 * This ensures that, if available, memcg is automatically enabled
@@ -1593,3 +1602,129 @@ void blkcg_policy_unregister(struct blkcg_policy *pol)
 	mutex_unlock(&blkcg_pol_register_mutex);
 }
 EXPORT_SYMBOL_GPL(blkcg_policy_unregister);
+
+static void blkcg_scale_delay(struct blkcg_gq *blkg, u64 now)
+{
+	u64 old = atomic64_read(&blkg->delay_start);
+
+	if (old + NSEC_PER_SEC <= now &&
+	    atomic64_cmpxchg(&blkg->delay_start, old, now) == old) {
+		u64 cur = atomic64_read(&blkg->delay_nsec);
+		u64 sub = min_t(u64, blkg->last_delay, now - old);
+		int cur_use = atomic_read(&blkg->use_delay);
+
+		if (cur_use < blkg->last_use)
+			sub = max_t(u64, sub, blkg->last_delay >> 1);
+
+		/* This shouldn't happen, but handle it anyway. */
+		if (unlikely(cur < sub)) {
+			atomic64_set(&blkg->delay_nsec, 0);
+			blkg->last_delay = 0;
+		} else {
+			atomic64_sub(sub, &blkg->delay_nsec);
+			blkg->last_delay = cur - sub;
+		}
+		blkg->last_use = cur_use;
+	}
+}
+
+static void blkcg_maybe_throttle_blkg(struct blkcg_gq *blkg, bool use_memdelay)
+{
+	u64 now = ktime_to_ns(ktime_get());
+	u64 exp;
+	u64 delay_nsec = 0;
+	int tok;
+
+	while (blkg->parent) {
+		if (atomic_read(&blkg->use_delay)) {
+			blkcg_scale_delay(blkg, now);
+			delay_nsec = max_t(u64, delay_nsec,
+					   atomic64_read(&blkg->delay_nsec));
+		}
+		blkg = blkg->parent;
+	}
+
+	if (!delay_nsec)
+		return;
+
+	/* Let's not sleep for all eternity if we've amassed a huge delay. */
+	delay_nsec = min_t(u64, delay_nsec, NSEC_PER_SEC);
+
+	/*
+	 * TODO: the use_memdelay flag is going to be for the upcoming psi stuff
+	 * that hasn't landed upstream yet.  Once that stuff is in place we need
+	 * to do a psi_memstall_enter/leave if memdelay is set.
+	 */
+
+	exp = ktime_add_ns(now, delay_nsec);
+	tok = io_schedule_prepare();
+	do {
+		__set_current_state(TASK_KILLABLE);
+		if (!schedule_hrtimeout(&exp, HRTIMER_MODE_ABS))
+			break;
+	} while (!fatal_signal_pending(current));
+	io_schedule_finish(tok);
+}
+
+void blkcg_maybe_throttle_current(void)
+{
+	struct request_queue *q = current->throttle_queue;
+	struct cgroup_subsys_state *css;
+	struct blkcg *blkcg;
+	struct blkcg_gq *blkg;
+	bool use_memdelay = current->use_memdelay;
+
+	if (!q)
+		return;
+
+	current->throttle_queue = NULL;
+	current->use_memdelay = false;
+
+	rcu_read_lock();
+	css = kthread_blkcg();
+	if (css)
+		blkcg = css_to_blkcg(css);
+	else
+		blkcg = css_to_blkcg(task_css(current, io_cgrp_id));
+
+	if (!blkcg)
+		goto out;
+	blkg = blkg_lookup(blkcg, q);
+	if (!blkg)
+		goto out;
+	blkg_get(blkg);
+	rcu_read_unlock();
+	blk_put_queue(q);
+
+	blkcg_maybe_throttle_blkg(blkg, use_memdelay);
+	blkg_put(blkg);
+	return;
+out:
+	rcu_read_unlock();
+	blk_put_queue(q);
+}
+EXPORT_SYMBOL_GPL(blkcg_maybe_throttle_current);
+
+void blkcg_schedule_throttle(struct request_queue *q, bool use_memdelay)
+{
+	if (unlikely(current->flags & PF_KTHREAD))
+		return;
+
+	if (!blk_get_queue(q))
+		return;
+
+	if (current->throttle_queue)
+		blk_put_queue(current->throttle_queue);
+	current->throttle_queue = q;
+	if (use_memdelay)
+		current->use_memdelay = use_memdelay;
+	set_notify_resume(current);
+}
+EXPORT_SYMBOL_GPL(blkcg_schedule_throttle);
+
+void blkcg_add_delay(struct blkcg_gq *blkg, u64 now, u64 delta)
+{
+	blkcg_scale_delay(blkg, now);
+	atomic64_add(delta, &blkg->delay_nsec);
+}
+EXPORT_SYMBOL_GPL(blkcg_add_delay);
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index a8f9ba8f33a4..fd73e2b4ea5f 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -136,6 +136,12 @@ struct blkcg_gq {
 	struct blkg_policy_data		*pd[BLKCG_MAX_POLS];
 
 	struct rcu_head			rcu_head;
+
+	atomic_t			use_delay;
+	atomic64_t			delay_nsec;
+	atomic64_t			delay_start;
+	u64				last_delay;
+	int				last_use;
 };
 
 typedef struct blkcg_policy_data *(blkcg_pol_alloc_cpd_fn)(gfp_t gfp);
@@ -734,6 +740,45 @@ static inline bool blkcg_bio_issue_check(struct request_queue *q,
 	return !throtl;
 }
 
+static inline void blkcg_use_delay(struct blkcg_gq *blkg)
+{
+	if (atomic_inc_and_test(&blkg->use_delay))
+		atomic_inc(&blkg->blkcg->css.cgroup->congestion_count);
+}
+
+static inline int blkcg_unuse_delay(struct blkcg_gq *blkg)
+{
+	int old = atomic_read(&blkg->use_delay);
+
+	if (old == 0)
+		return 0;
+
+	while (old) {
+		int cur = atomic_cmpxchg(&blkg->use_delay, old, old - 1);
+		if (cur == old)
+			break;
+		cur = old;
+	}
+
+	if (old == 0)
+		return 0;
+	if (old == 1)
+		atomic_dec(&blkg->blkcg->css.cgroup->congestion_count);
+	return 1;
+}
+
+static inline void blkcg_clear_delay(struct blkcg_gq *blkg)
+{
+	int old = atomic_read(&blkg->use_delay);
+	if (!old)
+		return;
+	if (atomic_cmpxchg(&blkg->use_delay, old, 0) == old)
+		atomic_dec(&blkg->blkcg->css.cgroup->congestion_count);
+}
+
+void blkcg_add_delay(struct blkcg_gq *blkg, u64 now, u64 delta);
+void blkcg_schedule_throttle(struct request_queue *q, bool use_memdelay);
+void blkcg_maybe_throttle_current(void);
 #else	/* CONFIG_BLK_CGROUP */
 
 struct blkcg {
@@ -753,8 +798,12 @@ struct blkcg_policy {
 
 #define blkcg_root_css	((struct cgroup_subsys_state *)ERR_PTR(-EINVAL))
 
+static inline void blkcg_maybe_throttle_current(void) { }
+
 #ifdef CONFIG_BLOCK
 
+static inline void blkcg_schedule_throttle(struct request_queue *q, bool use_memdelay) { }
+
 static inline struct blkcg_gq *blkg_lookup(struct blkcg *blkcg, void *key) { return NULL; }
 static inline int blkcg_init_queue(struct request_queue *q) { return 0; }
 static inline void blkcg_drain_queue(struct request_queue *q) { }
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index dc5b70449dc6..b3ab17d53f3d 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -427,6 +427,9 @@ struct cgroup {
 	/* used to store eBPF programs */
 	struct cgroup_bpf bpf;
 
+	/* If there is block congestion on this cgroup. */
+	atomic_t congestion_count;
+
 	/* ids of the ancestors at each level including self */
 	int ancestor_ids[];
 };
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b3d697f3b573..b672ead16518 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1099,6 +1099,11 @@ struct task_struct {
 	unsigned int			memcg_nr_pages_over_high;
 #endif
 
+#ifdef CONFIG_BLK_CGROUP
+	struct request_queue		*throttle_queue;
+	bool				use_memdelay;
+#endif
+
 #ifdef CONFIG_UPROBES
 	struct uprobe_task		*utask;
 #endif
diff --git a/include/linux/tracehook.h b/include/linux/tracehook.h
index 26c152122a42..4e24930306b9 100644
--- a/include/linux/tracehook.h
+++ b/include/linux/tracehook.h
@@ -51,6 +51,7 @@
 #include <linux/security.h>
 #include <linux/task_work.h>
 #include <linux/memcontrol.h>
+#include <linux/blk-cgroup.h>
 struct linux_binprm;
 
 /*
@@ -191,6 +192,7 @@ static inline void tracehook_notify_resume(struct pt_regs *regs)
 		task_work_run();
 
 	mem_cgroup_handle_over_high();
+	blkcg_maybe_throttle_current();
 }
 
 #endif	/* <linux/tracehook.h> */
-- 
2.14.3
