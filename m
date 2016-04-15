Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3F026B0260
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 08:11:15 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id z8so21399894igl.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:11:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c48si4738788otd.224.2016.04.15.05.11.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 05:11:14 -0700 (PDT)
Subject: Re: [PATCH] mm,oom_reaper: Use try_oom_reaper() for reapability test.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160414112146.GD2850@dhcp22.suse.cz>
In-Reply-To: <20160414112146.GD2850@dhcp22.suse.cz>
Message-Id: <201604152111.JBD95763.LMFOOHQOtFSFJV@I-love.SAKURA.ne.jp>
Date: Fri, 15 Apr 2016 21:11:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Thu 14-04-16 19:56:30, Tetsuo Handa wrote:
> > Assuming that try_oom_reaper() is correctly implemented, we should use
> > try_oom_reaper() for testing "whether the OOM reaper is allowed to reap
> > the OOM victim's memory" rather than "whether the OOM killer is allowed
> > to send SIGKILL to thread groups sharing the OOM victim's memory",
> > for the OOM reaper is allowed to reap the OOM victim's memory even if
> > that memory is shared by OOM_SCORE_ADJ_MIN but already-killed-or-exiting
> > thread groups.
>
> So you prefer to crawl over the whole task list again just to catch a
> really unlikely case where the OOM_SCORE_ADJ_MIN mm sharing task was
> already exiting? Under which workload does this matter?
>
> The patch seems correct I just do not see any point in it because I do
> not think it handles any real life situation. I basically consider any
> workload where only _certain_ thread(s) or process(es) sharing the mm have
> OOM_SCORE_ADJ_MIN set as invalid. Why should we care about those? This
> requires root to cripple the system. Or am I missing a valid
> configuration where this would make any sense?

You think that this patch seems correct is sufficient. This patch is just
a preparation for applying the patches shown bottom on top of this patch.

Quoting from http://lkml.kernel.org/r/20160414113108.GE2850@dhcp22.suse.cz :
| > +	 * Also, it is possible that a thread which shares victim->mm and is
| > +	 * doing memory allocation with victim->mm->mmap_sem held for write
| > +	 * (possibly the victim thread itself which got TIF_MEMDIE) is blocked
| > +	 * at unkillable locks from direct reclaim paths because nothing
| > +	 * prevents TIF_MEMDIE threads which already started direct reclaim
| > +	 * paths from being blocked at unkillable locks. In such cases, the
| > +	 * OOM reaper will be unable to reap victim->mm and we will need to
| > +	 * select a different OOM victim.
|
| This is a more general problem and not related to this particular code.
| Whenever we select a victim and call mark_oom_victim we hope it will
| eventually get out of its kernel code path (unless it was running in the
| userspace) so I am not sure this is placed properly.

So, can we get away from "where only _certain_ thread(s) or process(es)
sharing the mm have OOM_SCORE_ADJ_MIN set as invalid" discussion?

Let's consider how to handle "TIF_MEMDIE thread can fall into unkillable
waits inside the direct reclaim paths while allocating memory with mmap_sem
held for write" problem.

Quoting from http://lkml.kernel.org/r/1459951996-12875-3-git-send-email-mhocko@kernel.org :
| If either the current task is already killed or PF_EXITING or a selected
| task is PF_EXITING then the oom killer is suppressed and so is the oom
| reaper. This patch adds try_oom_reaper which checks the given task
| and queues it for the oom reaper if that is safe to be done meaning
| that the task doesn't share the mm with an alive process.

So, you proposed making the OOM killer try to wake up the OOM reaper
whenever TIF_MEMDIE is set.

Quoting from http://lkml.kernel.org/r/1460452756-15491-1-git-send-email-mhocko@kernel.org :
| The check can still do better though. We shouldn't consider the task
| unless the whole thread group is going down. This is rather unlikely
| but not impossible. A single exiting thread would surely leave all the
| address space behind. If we are really unlucky it might get stuck on the
| exit path and keep its TIF_MEMDIE and so block the oom killer.

So, you proposed making sure that we don't use task_will_free_mem() shortcut
unless all threads in that thread group are going down. This change allows us
to mark such thread group as no longer suitable for OOM victims when the OOM
killer cannot make forward progress (rather than that TIF_MEMDIE thread as
no longer suitable for OOM victims), for you proposed making the OOM killer
try to wake up the OOM reaper whenever TIF_MEMDIE is set.

Quoting from http://lkml.kernel.org/r/201604082019.EDH52671.OJHQFMStOFLVOF@I-love.SAKURA.ne.jp :
| My perspective on the OOM reaper is to behave as a guaranteed unlocking
| mechanism than a preemptive memory reaping mechanism. Therefore, it is
| critically important that the OOM reaper kernel thread is always woken up
| and unlock TIF_MEMDIE some time later, even if it is known that the memory
| used by the caller of try_oom_reaper() is not reapable.

So, I propose making sure that we use bounded wait for TIF_MEMDIE threads.
And now, all parts for providing a guaranteed unlocking mechanism which
handles "TIF_MEMDIE thread can fall into unkillable waits inside the direct
reclaim paths while allocating memory with mmap_sem held for write" problem
are ready. Below patches implement that mechanism.

Since this approach is much deterministic compared to timer based approach,
I do hope you will accept this approach for handling the slowpath.
------------------------------------------------------------
>From 2d4fd6475ac9a0cb64855a7d6e1cf8a02569d8e8 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 15 Apr 2016 13:11:24 +0900
Subject: [PATCH] mm,oom_reaper: Use set_bit() for setting MMF_OOM_REAPED

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ecbad1e..35158b7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -518,7 +518,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * This task can be safely ignored because we cannot do much more
 	 * to release its memory.
 	 */
-	test_bit(MMF_OOM_REAPED, &mm->flags);
+	set_bit(MMF_OOM_REAPED, &mm->flags);
 out:
 	mmput(mm);
 	return ret;
-- 
1.8.3.1
------------------------------------------------------------
>From c38c5abf3431ebefbd945bb4cfb6067678b266c7 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 15 Apr 2016 13:07:56 +0900
Subject: [PATCH] mm,oom_reaper: Defer reapability test to the OOM reaper.

This patch defers testing whether the OOM victim's memory is reapable
till the OOM reaper successfully takes the victim's mmap_sem for reading
because

  Majority of out_of_memory() calls is expected to terminate victim
  processes within a second without using the OOM reaper. The OOM
  reaper needs to take over the role of making forward progress
  only when out_of_memory() cannot terminate the victim processes.
  Therefore, in most cases, we don't need to test whether the OOM
  victim's memory is reapable at oom_kill_process().

and

  But the OOM reaper cannot reap the victim's memory if mmap_sem is
  held for write. Therefore, we don't need to test whether the OOM
  victim's memory is reapable unless the OOM reaper can successfully
  take the victim's mmap_sem for reading.

. After the OOM reaper successfully took the victim's mmap_sem for
reading, the OOM reaper tests whether the OOM victim's memory is
reapable, and reaps that memory only if reapable.

By waking up the OOM reaper from mark_oom_victim(), it is guaranteed
that the OOM reaper is waken up whenever TIF_MEMDIE is set. And unless
the OOM reaper is blocked forever inside __oom_reap_task(), it is also
guaranteed that the OOM reaper can take next action for making forward
progress.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 33 ++++++++++++++-------------------
 1 file changed, 14 insertions(+), 19 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c1e2816..ecbad1e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -446,6 +446,7 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
+static bool can_oom_reap(struct mm_struct *mm);
 
 static bool __oom_reap_task(struct task_struct *tsk)
 {
@@ -480,6 +481,12 @@ static bool __oom_reap_task(struct task_struct *tsk)
 		goto out;
 	}
 
+	if (!can_oom_reap(mm)) {
+		up_read(&mm->mmap_sem);
+		ret = false;
+		goto out;
+	}
+
 	tlb_gather_mmu(&tlb, mm, 0, -1);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (is_vm_hugetlb_page(vma))
@@ -594,27 +601,21 @@ static void wake_oom_reaper(struct task_struct *tsk)
 /* Check if we can reap the given task. This has to be called with stable
  * tsk->mm
  */
-static void try_oom_reaper(struct task_struct *tsk)
+static bool can_oom_reap(struct mm_struct *mm)
 {
-	struct mm_struct *mm = tsk->mm;
 	struct task_struct *p;
 
-	if (!mm)
-		return;
-
 	/*
 	 * There might be other threads/processes which are either not
 	 * dying or even not killable.
 	 */
-	if (atomic_read(&mm->mm_users) > 1) {
+	if (atomic_read(&mm->mm_users) > 2) {
 		rcu_read_lock();
 		for_each_process(p) {
 			bool exiting;
 
 			if (!process_shares_mm(p, mm))
 				continue;
-			if (same_thread_group(p, tsk))
-				continue;
 			if (fatal_signal_pending(p))
 				continue;
 
@@ -630,12 +631,11 @@ static void try_oom_reaper(struct task_struct *tsk)
 
 			/* Give up */
 			rcu_read_unlock();
-			return;
+			return false;
 		}
 		rcu_read_unlock();
 	}
-
-	wake_oom_reaper(tsk);
+	return true;
 }
 
 static int __init oom_init(void)
@@ -649,10 +649,6 @@ static int __init oom_init(void)
 	return 0;
 }
 subsys_initcall(oom_init)
-#else
-static void try_oom_reaper(struct task_struct *tsk)
-{
-}
 #endif
 
 /**
@@ -676,6 +672,9 @@ void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+#ifdef CONFIG_MMU
+	wake_oom_reaper(tsk);
+#endif
 }
 
 /**
@@ -750,7 +749,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_lock(p);
 	if (p->mm && task_will_free_mem(p)) {
 		mark_oom_victim(p);
-		try_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -844,8 +842,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	rcu_read_unlock();
 
-	try_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -926,7 +922,6 @@ bool out_of_memory(struct oom_control *oc)
 	if (current->mm &&
 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
 		mark_oom_victim(current);
-		try_oom_reaper(current);
 		return true;
 	}
 
-- 
1.8.3.1
------------------------------------------------------------
>From 00864f683d75fe1b125edb976b8563d67a85902b Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 15 Apr 2016 13:14:17 +0900
Subject: [PATCH] mm,oom_reaper: Do not allow selecting the same victim forever

If the OOM reaper cannot reap the OOM victim's memory for more than
a second (MAX_OOM_REAP_RETRIES retries with HZ/10 jiffies sleep),
we assume that the OOM reaper won't be able to make forward progress
and allow the OOM killer to select a new victim.

But clearing TIF_MEMDIE does not help making forward progress because
the OOM killer will select the same victim again. Therefore, this patch
excludes a thread group which the TIF_MEMDIE thread belongs to by marking
as no longer suitable as OOM victims. This way, we can handle the
"TIF_MEMDIE thread can fall into unkillable waits inside the direct
reclaim paths while allocating memory with mmap_sem held for write"
problem.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/sched.h |  2 ++
 mm/oom_kill.c         | 20 ++++++++++----------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index fa8a74d..fc44910 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -787,6 +787,8 @@ struct signal_struct {
 	 * oom
 	 */
 	bool oom_flag_origin;
+	/* Already OOM-killed but cannot terminate. Don't count on me. */
+	bool oom_skip_me;
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 35158b7..0421986 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -167,7 +167,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	long points;
 	long adj;
 
-	if (oom_unkillable_task(p, memcg, nodemask))
+	if (oom_unkillable_task(p, memcg, nodemask) || p->signal->oom_skip_me)
 		return 0;
 
 	p = find_lock_task_mm(p);
@@ -179,8 +179,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * unkillable or have been already oom reaped.
 	 */
 	adj = (long)p->signal->oom_score_adj;
-	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_REAPED, &p->mm->flags)) {
+	if (adj == OOM_SCORE_ADJ_MIN) {
 		task_unlock(p);
 		return 0;
 	}
@@ -276,7 +275,8 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 			struct task_struct *task, unsigned long totalpages)
 {
-	if (oom_unkillable_task(task, NULL, oc->nodemask))
+	if (oom_unkillable_task(task, NULL, oc->nodemask) ||
+	    task->signal->oom_skip_me)
 		return OOM_SCAN_CONTINUE;
 
 	/*
@@ -469,7 +469,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
 		return true;
 
 	mm = p->mm;
-	if (!atomic_inc_not_zero(&mm->mm_users)) {
+	if (test_bit(MMF_OOM_REAPED, &mm->flags) ||
+	    !atomic_inc_not_zero(&mm->mm_users)) {
 		task_unlock(p);
 		return true;
 	}
@@ -547,12 +548,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	}
 
 	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore or it is not a good candidate
-	 * for the oom victim right now because it cannot release its memory
-	 * itself nor by the oom reaper.
+	 * Tell the OOM killer to ignore this thread group, for the memory
+	 * used by this thread group is already reaped or cannot be reaped
+	 * due to mmap_sem contention.
 	 */
-	exit_oom_victim(tsk);
+	tsk->signal->oom_skip_me = true;
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
