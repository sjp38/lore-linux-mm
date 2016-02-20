Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6ECBB6B0005
	for <linux-mm@kvack.org>; Sat, 20 Feb 2016 02:15:08 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id y8so50461914igp.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 23:15:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 10si18514317igt.78.2016.02.19.23.15.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 23:15:07 -0800 (PST)
Subject: Re: [PATCH] mm,oom: kill duplicated oom_unkillable_task() checks.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160219151043.GI12690@dhcp22.suse.cz>
	<201602200101.IBE90199.OSOFMFOLVtJQHF@I-love.SAKURA.ne.jp>
	<20160219171533.GA23376@dhcp22.suse.cz>
	<201602200234.DGG56738.LQFMFJFtOOVSOH@I-love.SAKURA.ne.jp>
	<20160219184006.GB30059@dhcp22.suse.cz>
In-Reply-To: <20160219184006.GB30059@dhcp22.suse.cz>
Message-Id: <201602201614.CCF09839.HVtSJFQFFOOLOM@I-love.SAKURA.ne.jp>
Date: Sat, 20 Feb 2016 16:14:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

Michal Hocko wrote:
> > I'm trying to update select_bad_process() to use for_each_process() rather than
> > for_each_process_thread(). If we can do it, I think we can use is_oom_victim()
> > and respond to your concern
> 
> 3a5dda7a17cf ("oom: prevent unnecessary oom kills or kernel panics"). I
> would really recommend to look through the history (git blame is your
> friend) before suggesting any changes in this area. The code is really
> subtle and many times for good reasons.

I think the code is too subtle to touch.
I wish I were able to propose as simple OOM killing as shown below.

 (1) Do not clear TIF_MEMDIE until TASK_DEAD.
     This should help cases where memory allocations are needed after
     exit_mm().
 (2) Do not wait TIF_MEMDIE task forever using simple timeout.
     This should help cases where the victim task is unable to make
     forward progress.
 (3) Do not allow ALLOC_NO_WATERMARKS by TIF_MEMDIE tasks.
     This should help avoid depletion of memory reserves.
 (4) Allow any SIGKILL or PF_EXITING tasks access part of memory reserves.
     This should help exiting tasks to make forward progress.
 (5) Set TIF_MEMDIE to all threads chosen by the OOM killer.
     This should help reduce mmap_sem problem.
 (6) Select next task to set TIF_MEMDIE after timeout rather than
     give up TIF_MEMDIE task's memory allocations.
     This should help reduce possibility of unexpected failures by
     e.g. btrfs's BUG_ON() trap.
 (7) Allow GFP_KILLABLE. This should help quicker termination.

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 45993b8..87a004e 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -70,7 +70,7 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return !!(p->signal->oom_flags & OOM_FLAG_ORIGIN);
 }
 
-extern void mark_oom_victim(struct task_struct *tsk);
+extern bool mark_oom_victim(struct task_struct *tsk);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
diff --git a/kernel/exit.c b/kernel/exit.c
index fd90195..d4ff477 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -434,8 +434,6 @@ static void exit_mm(struct task_struct *tsk)
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
-	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim(tsk);
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
@@ -825,6 +823,7 @@ void do_exit(long code)
 	/* causes final put_task_struct in finish_task_switch(). */
 	tsk->state = TASK_DEAD;
 	tsk->flags |= PF_NOFREEZE;	/* tell freezer to ignore us */
+	exit_oom_victim(tsk);
 	schedule();
 	BUG();
 	/* Avoid "noreturn function does return".  */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c..5be5a85 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1258,10 +1258,9 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		mark_oom_victim(current);
+	if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
+	    mark_oom_victim(current))
 		goto unlock;
-	}
 
 	check_panic_on_oom(&oc, CONSTRAINT_MEMCG, memcg);
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d7bb9c1..6e7f5e4a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -50,6 +50,11 @@ int sysctl_oom_dump_tasks = 1;
 
 DEFINE_MUTEX(oom_lock);
 
+static void oomkiller_reset(unsigned long arg)
+{
+}
+static DEFINE_TIMER(oomkiller_victim_wait_timer, oomkiller_reset, 0, 0);
+
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -278,9 +283,10 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves.
 	 */
-	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
+	if (test_tsk_thread_flag(task, TIF_MEMDIE) && task->state != TASK_DEAD) {
 		if (!is_sysrq_oom(oc))
-			return OOM_SCAN_ABORT;
+			return timer_pending(&oomkiller_victim_wait_timer) ?
+				OOM_SCAN_ABORT : OOM_SCAN_CONTINUE;
 	}
 	if (!task->mm)
 		return OOM_SCAN_CONTINUE;
@@ -292,9 +298,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	if (oom_task_origin(task))
 		return OOM_SCAN_SELECT;
 
-	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
-		return OOM_SCAN_ABORT;
-
 	return OOM_SCAN_OK;
 }
 
@@ -584,12 +587,12 @@ static void wake_oom_reaper(struct task_struct *mm)
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk)
+bool mark_oom_victim(struct task_struct *tsk)
 {
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
+		return false;
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -598,6 +601,9 @@ void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+	/* Make sure that we won't wait for this task forever. */
+	mod_timer(&oomkiller_victim_wait_timer, jiffies + 5 * HZ);
+	return true;
 }
 
 /**
@@ -689,8 +695,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
-		mark_oom_victim(p);
+	if (task_will_free_mem(p) && mark_oom_victim(p)) {
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -759,20 +764,16 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_unlock(victim);
 
 	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
+	 * Kill all user processes sharing victim->mm. We give them access to
+	 * memory reserves because they are expected to terminate immediately.
+	 * Even if memory reserves were depleted, the OOM reaper takes care of
+	 * allowing the OOM killer to choose next victim by marking current
+	 * victim as OOM-unkillable and clearing TIF_MEMDIE.
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
 		if (!process_shares_mm(p, mm))
 			continue;
-		if (same_thread_group(p, victim))
-			continue;
 		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
 		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
 			/*
@@ -784,6 +785,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		}
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		for_each_thread(p, t) {
+			task_lock(t);
+			if (t->mm)
+				mark_oom_victim(t);
+			task_unlock(t);
+		}
 	}
 	rcu_read_unlock();
 
@@ -863,15 +870,10 @@ bool out_of_memory(struct oom_control *oc)
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
-	 *
-	 * But don't select if current has already released its mm and cleared
-	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
-		mark_oom_victim(current);
+	if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
+	    mark_oom_victim(current))
 		return true;
-	}
 
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 85e7588..8c9e707 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3065,10 +3065,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (!in_interrupt() &&
-				((current->flags & PF_MEMALLOC) ||
-				 unlikely(test_thread_flag(TIF_MEMDIE))))
+		else if (!in_interrupt() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (!in_interrupt() && (fatal_signal_pending(current) ||
+					     (current->flags & PF_EXITING)))
+			alloc_flags |= ALLOC_HARDER;
 	}
 #ifdef CONFIG_CMA
 	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
@@ -3291,10 +3292,6 @@ retry:
 		goto nopage;
 	}
 
-	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
-		goto nopage;
-
 	/*
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
