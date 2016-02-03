Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C113B6B0253
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 05:32:01 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id cy9so11601248pac.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 02:32:01 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id vv1si8531185pab.34.2016.02.03.02.32.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 02:32:00 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1601271651530.17979@chino.kir.corp.google.com>
	<20160128214247.GD621@dhcp22.suse.cz>
	<alpine.DEB.2.10.1602011843250.31751@chino.kir.corp.google.com>
	<20160202085758.GE19910@dhcp22.suse.cz>
	<alpine.DEB.2.10.1602021437140.9118@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1602021437140.9118@chino.kir.corp.google.com>
Message-Id: <201602031931.CGJ56248.HMOQFOFLtJVFSO@I-love.SAKURA.ne.jp>
Date: Wed, 3 Feb 2016 19:31:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, mhocko@kernel.org, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> On Tue, 2 Feb 2016, Michal Hocko wrote:
> > > I'm baffled by any reference to "memcg oom heavy loads", I don't 
> > > understand this paragraph, sorry.  If a memcg is oom, we shouldn't be
> > > disrupting the global runqueue by running oom_reaper at a high priority.  
> > > The disruption itself is not only in first wakeup but also in how long the 
> > > reaper can run and when it is rescheduled: for a lot of memory this is 
> > > potentially long.  The reaper is best-effort, as the changelog indicates, 
> > > and we shouldn't have a reliance on this high priority: oom kill exiting 
> > > can't possibly be expected to be immediate.  This high priority should be 
> > > removed so memcg oom conditions are isolated and don't affect other loads.
> > 
> > If this is a concern then I would be tempted to simply disable oom
> > reaper for memcg oom altogether. For me it is much more important that
> > the reaper, even though a best effort, is guaranteed to schedule if
> > something goes terribly wrong on the machine.
> > 
> 
> I don't believe the higher priority guarantees it is able to schedule any 
> more than it was guaranteed to schedule before.  It will run, but it won't 
> preempt other innocent processes in disjoint memcgs or cpusets.  It's not 
> only a memcg issue, but it also impacts disjoint cpuset mems and mempolicy 
> nodemasks.  I think it would be disappointing to leave those out.  I think 
> the higher priority should simply be removed in terms of fairness.
> 
> Other than these issues, I don't see any reason why a refreshed series 
> wouldn't be immediately acked.  Thanks very much for continuing to work on 
> this!
> 

Excuse me, but I came to think that we should try to wake up the OOM reaper at

    if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
        if (!is_sysrq_oom(oc))
            return OOM_SCAN_ABORT;
    }

in oom_scan_process_thread() rather than at oom_kill_process() or at
mark_oom_victim(). Waking up the OOM reaper there will try to reap
task->mm, and give up eventually which will in turn naturally allow the
OOM killer to choose next OOM victim. The key point is PATCH 2/5 shown
below. What do you think?

PATCH 1/5 is (I think) a bug fix.
PATCH 2/5 is for waking up the OOM reaper from victim selection loop.
PATCH 3/5 is for helping the OOM killer to choose next OOM victim.
PATCH 4/5 is for handling corner cases.
PATCH 5/5 is for changing the OOM reaper to use default priority.

 include/linux/oom.h |    3
 mm/oom_kill.c       |  173 ++++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 136 insertions(+), 40 deletions(-)

----------------------------------------
>From e1c0a78fbfd0a76f367efac269cbcf22c7df9292 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 3 Feb 2016 14:18:19 +0900
Subject: [PATCH 1/5] mm,oom: Fix incorrect oom_task_origin check.

Currently, the OOM killer unconditionally selects p if oom_task_origin(p)
is true, but p should not be OOM-killed if p is marked as OOM-unkillable.

This patch does not fix a race condition where p is selected when p was
by chance between set_current_oom_origin() and actually start operations
that might trigger an OOM event when an OOM event is triggered for some
reason other than operations by p.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 45993b8..59481e6 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -67,7 +67,8 @@ static inline void clear_current_oom_origin(void)
 
 static inline bool oom_task_origin(const struct task_struct *p)
 {
-	return !!(p->signal->oom_flags & OOM_FLAG_ORIGIN);
+	return (p->signal->oom_flags & OOM_FLAG_ORIGIN) &&
+		p->signal->oom_score_adj != OOM_SCORE_ADJ_MIN;
 }
 
 extern void mark_oom_victim(struct task_struct *tsk);
-- 
1.8.3.1

>From 76cf60d33e4e1daa475e4c1e39087415a309c6e9 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 3 Feb 2016 14:20:07 +0900
Subject: [PATCH 2/5] mm,oom: Change timing of waking up the OOM reaper

Currently, the OOM reaper kernel thread is woken up when we set TIF_MEMDIE
on a task. But it is not easy to build a reliable OOM-reap queuing chain.

Since the OOM livelock problem occurs when we find TIF_MEMDIE on a task
which cannot terminate, waking up the OOM reaper when we found TIF_MEMDIE
on a task can simplify handling of the chain. Also, we don't need to wake
up the OOM reaper if the victim can smoothly terminate. Therefore, this
patch replaces wake_oom_reaper() called from oom_kill_process() with
try_oom_reap() called from oom_scan_process_thread().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 99 +++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 79 insertions(+), 20 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b51bcce..07c6389 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -268,6 +268,8 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
+static bool try_oom_reap(struct task_struct *tsk);
+
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 			struct task_struct *task, unsigned long totalpages)
 {
@@ -279,7 +281,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * Don't allow any other task to have access to the reserves.
 	 */
 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (!is_sysrq_oom(oc))
+		if (!is_sysrq_oom(oc) && try_oom_reap(task))
 			return OOM_SCAN_ABORT;
 	}
 	if (!task->mm)
@@ -420,6 +422,40 @@ static struct task_struct *oom_reaper_th;
 static struct task_struct *task_to_reap;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 
+static bool mm_is_reapable(struct mm_struct *mm)
+{
+	struct task_struct *g;
+	struct task_struct *p;
+
+	/*
+	 * Since it is possible that p voluntarily called do_exit() or
+	 * somebody other than the OOM killer sent SIGKILL on p, this mm used
+	 * by p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN is reapable if p
+	 * has pending SIGKILL or already reached do_exit().
+	 *
+	 * On the other hand, it is possible that mark_oom_victim(p) is called
+	 * without sending SIGKILL to all tasks using this mm. In this case,
+	 * the OOM reaper cannot reap this mm unless p is the only task using
+	 * this mm.
+	 *
+	 * Therefore, determine whether this mm is reapable by testing whether
+	 * all tasks using this mm are dying or already exiting rather than
+	 * depending on p->signal->oom_score_adj value which is updated by the
+	 * OOM reaper.
+	 */
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (mm != READ_ONCE(p->mm) ||
+		    fatal_signal_pending(p) || (p->flags & PF_EXITING))
+			continue;
+		mm = NULL;
+		goto out;
+	}
+ out:
+	rcu_read_unlock();
+	return mm != NULL;
+}
+
 static bool __oom_reap_task(struct task_struct *tsk)
 {
 	struct mmu_gather tlb;
@@ -448,7 +484,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 
 	task_unlock(p);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_is_reapable(mm) || !down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		goto out;
 	}
@@ -500,7 +536,7 @@ static void oom_reap_task(struct task_struct *tsk)
 	while (attempts++ < 10 && !__oom_reap_task(tsk))
 		schedule_timeout_idle(HZ/10);
 
-	/* Drop a reference taken by wake_oom_reaper */
+	/* Drop a reference taken by try_oom_reap */
 	put_task_struct(tsk);
 }
 
@@ -512,18 +548,44 @@ static int oom_reaper(void *unused)
 		wait_event_freezable(oom_reaper_wait,
 				     (tsk = READ_ONCE(task_to_reap)));
 		oom_reap_task(tsk);
+		/*
+		 * The OOM killer might be about to call try_oom_reap() after
+		 * seeing TIF_MEMDIE.
+		 */
+		smp_wmb();
 		WRITE_ONCE(task_to_reap, NULL);
 	}
 
 	return 0;
 }
 
-static void wake_oom_reaper(struct task_struct *tsk)
+static bool try_oom_reap(struct task_struct *tsk)
 {
 	struct task_struct *old_tsk;
 
+	/*
+	 * We will livelock if we unconditionally return true.
+	 * We will kill all tasks if we unconditionally return false.
+	 */
 	if (!oom_reaper_th)
-		return;
+		return true;
+
+	/*
+	 * Wait for the OOM reaper to reap this task and mark this task
+	 * as OOM-unkillable and clear TIF_MEMDIE. Since the OOM reaper
+	 * has high scheduling priority, we can unconditionally wait for
+	 * completion.
+	 */
+	if (task_to_reap)
+		return true;
+
+	/*
+	 * The OOM reaper might be about to clear task_to_reap after
+	 * clearing TIF_MEMDIE.
+	 */
+	smp_rmb();
+	if (!test_tsk_thread_flag(tsk, TIF_MEMDIE))
+		return false;
 
 	get_task_struct(tsk);
 
@@ -537,6 +599,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
 		wake_up(&oom_reaper_wait);
 	else
 		put_task_struct(tsk);
+	return true;
 }
 
 static int __init oom_init(void)
@@ -559,8 +622,13 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
-static void wake_oom_reaper(struct task_struct *mm)
+static bool try_oom_reap(struct task_struct *tsk)
 {
+	/*
+	 * We will livelock if we unconditionally return true.
+	 * We will kill all tasks if we unconditionally return false.
+	 */
+	return true;
 }
 #endif
 
@@ -592,7 +660,8 @@ void mark_oom_victim(struct task_struct *tsk)
  */
 void exit_oom_victim(struct task_struct *tsk)
 {
-	clear_tsk_thread_flag(tsk, TIF_MEMDIE);
+	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
+		return;
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -669,7 +738,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -762,23 +830,14 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (is_global_init(p))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-			/*
-			 * We cannot use oom_reaper for the mm shared by this
-			 * process because it wouldn't get killed and so the
-			 * memory might be still used.
-			 */
-			can_oom_reap = false;
+		if (unlikely(p->flags & PF_KTHREAD))
+			continue;
+		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			continue;
-		}
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
-- 
1.8.3.1

>From 8c6024b963d5b4e8d38a3416e14b458e1e073607 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 3 Feb 2016 14:42:28 +0900
Subject: [PATCH 3/5] mm,oom: Always update OOM score and clear TIF_MEMDIE
 after OOM reap.

This patch updates victim's oom_score_adj and clear TIF_MEMDIE
even if the OOM reaper failed to reap victim's memory. This is
needed for handling corner cases where TIF_MEMDIE is set on a victim
without sending SIGKILL to all tasks sharing the same memory.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 50 ++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 40 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 07c6389..a0ae8dc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -413,6 +413,44 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
 bool oom_killer_disabled __read_mostly;
 
+static void update_victim_score(struct task_struct *tsk, bool reap_success)
+{
+	/*
+	 * If we succeeded to reap a mm, mark that task using it as
+	 * OOM-unkillable and clear TIF_MEMDIE, for the task shouldn't be
+	 * sitting on a reasonably reclaimable memory anymore.
+	 * OOM killer can continue by selecting other victim if unmapping
+	 * hasn't led to any improvements. This also means that selecting
+	 * this task doesn't make any sense.
+	 */
+	if (reap_success)
+		tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+	/*
+	 * If we failed to reap a mm, mark that task using it as almost
+	 * OOM-unkillable and clear TIF_MEMDIE. This will help future
+	 * select_bad_process() try to select other OOM-killable tasks
+	 * before selecting that task again.
+	 */
+	else if (tsk->signal->oom_score_adj > OOM_SCORE_ADJ_MIN + 1)
+		tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN + 1;
+	/*
+	 * But if that task got TIF_MEMDIE when that task is already marked as
+	 * almost OOM-unkillable, mark that task completely OOM-unkillable.
+	 * Otherwise, we cannot make progress when all OOM-killable tasks are
+	 * marked as almost OOM-unkillable.
+	 *
+	 * Note that the reason we fail to reap a mm might be that there are
+	 * tasks using this mm without neither pending SIGKILL nor PF_EXITING
+	 * which means that we set TIF_MEMDIE on a task without sending SIGKILL
+	 * to tasks sharing this mm. In this case, we will call panic() without
+	 * sending SIGKILL to tasks sharing this mm when all OOM-killable tasks
+	 * are marked as completely OOM-unkillable.
+	 */
+	else
+		tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+	exit_oom_victim(tsk);
+}
+
 #ifdef CONFIG_MMU
 /*
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
@@ -513,16 +551,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	up_read(&mm->mmap_sem);
-
-	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore. OOM killer can continue
-	 * by selecting other victim if unmapping hasn't led to any
-	 * improvements. This also means that selecting this task doesn't
-	 * make any sense.
-	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
-	exit_oom_victim(tsk);
 out:
 	mmput(mm);
 	return ret;
@@ -536,6 +564,8 @@ static void oom_reap_task(struct task_struct *tsk)
 	while (attempts++ < 10 && !__oom_reap_task(tsk))
 		schedule_timeout_idle(HZ/10);
 
+	update_victim_score(tsk, attempts < 10);
+
 	/* Drop a reference taken by try_oom_reap */
 	put_task_struct(tsk);
 }
-- 
1.8.3.1

>From d6254acc565af7456fb21c0bb7568452fb227f3c Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 3 Feb 2016 14:44:47 +0900
Subject: [PATCH 4/5] mm,oom: Add timeout counter for handling corner cases.

Currently, we can hit OOM livelock if the OOM reaper kernel thread is
not available. This patch adds a simple timeout based next victim
selection logic in case the OOM reaper kernel thread is unavailable.

Future patch will add hooks for allowing global access to memory
reserves before this timeout counter expires.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index a0ae8dc..e4e955b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -451,6 +451,11 @@ static void update_victim_score(struct task_struct *tsk, bool reap_success)
 	exit_oom_victim(tsk);
 }
 
+static void oomkiller_reset(unsigned long arg)
+{
+}
+static DEFINE_TIMER(oomkiller_victim_wait_timer, oomkiller_reset, 0, 0);
+
 #ifdef CONFIG_MMU
 /*
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
@@ -596,9 +601,14 @@ static bool try_oom_reap(struct task_struct *tsk)
 	/*
 	 * We will livelock if we unconditionally return true.
 	 * We will kill all tasks if we unconditionally return false.
+	 * Thus, use a simple timeout counter if the OOM reaper is unavailable.
 	 */
-	if (!oom_reaper_th)
-		return true;
+	if (!oom_reaper_th) {
+		if (timer_pending(&oomkiller_victim_wait_timer))
+			return true;
+		update_victim_score(tsk, false);
+		return false;
+	}
 
 	/*
 	 * Wait for the OOM reaper to reap this task and mark this task
@@ -654,11 +664,11 @@ subsys_initcall(oom_init)
 #else
 static bool try_oom_reap(struct task_struct *tsk)
 {
-	/*
-	 * We will livelock if we unconditionally return true.
-	 * We will kill all tasks if we unconditionally return false.
-	 */
-	return true;
+	/* Use a simple timeout counter, for the OOM reaper is unavailable. */
+	if (timer_pending(&oomkiller_victim_wait_timer))
+		return true;
+	update_victim_score(tsk, false);
+	return false;
 }
 #endif

@@ -683,6 +693,8 @@ void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+	/* Make sure that we won't wait for this task forever. */
+	mod_timer(&oomkiller_victim_wait_timer, jiffies + 5 * HZ);
 }
 
 /**
-- 
1.8.3.1

>From 6156462d2db03bfc9fe76ca5a3f0ebcc5a88a12e Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 3 Feb 2016 14:45:29 +0900
Subject: [PATCH 5/5] mm,oom: Use normal scheduling priority for the OOM reaper

Currently, the OOM reaper kernel thread has high scheduling priority
in order to make sure that OOM-reap operation occurs immediately.

This patch changes the scheduling priority to normal, and fallback to
a simple timeout based next victim selection logic if the OOM reaper
fails to get enough CPU resource.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index e4e955b..b55159f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -604,6 +604,7 @@ static bool try_oom_reap(struct task_struct *tsk)
 	 * Thus, use a simple timeout counter if the OOM reaper is unavailable.
 	 */
 	if (!oom_reaper_th) {
+check_timeout:
 		if (timer_pending(&oomkiller_victim_wait_timer))
 			return true;
 		update_victim_score(tsk, false);
@@ -613,11 +614,12 @@ static bool try_oom_reap(struct task_struct *tsk)
 	/*
 	 * Wait for the OOM reaper to reap this task and mark this task
 	 * as OOM-unkillable and clear TIF_MEMDIE. Since the OOM reaper
-	 * has high scheduling priority, we can unconditionally wait for
-	 * completion.
+	 * has normal scheduling priority, we can't wait for completion
+	 * forever. Thus, use a simple timeout counter in case the OOM
+	 * reaper fails to get enough CPU resource.
 	 */
 	if (task_to_reap)
-		return true;
+		goto check_timeout;
 
 	/*
 	 * The OOM reaper might be about to clear task_to_reap after
@@ -649,14 +651,6 @@ static int __init oom_init(void)
 		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
 				PTR_ERR(oom_reaper_th));
 		oom_reaper_th = NULL;
-	} else {
-		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
-
-		/*
-		 * Make sure our oom reaper thread will get scheduled when
-		 * ASAP and that it won't get preempted by malicious userspace.
-		 */
-		sched_setscheduler(oom_reaper_th, SCHED_FIFO, &param);
 	}
 	return 0;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
