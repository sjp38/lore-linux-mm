Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id E263F6B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:23:21 -0400 (EDT)
Received: by oiko83 with SMTP id o83so113381251oik.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 04:23:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i13si15710134oes.19.2015.04.28.04.23.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 04:23:20 -0700 (PDT)
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Message-Id: <201504281934.IIH81695.LOHJQMOFStFFVO@I-love.SAKURA.ne.jp>
Date: Tue, 28 Apr 2015 19:34:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, mhocko@suse.cz, aarcange@redhat.com, david@fromorbit.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Johannes Weiner wrote:
> There is a possible deadlock scenario between the page allocator and
> the OOM killer.  Most allocations currently retry forever inside the
> page allocator, but when the OOM killer is invoked the chosen victim
> might try taking locks held by the allocating task.  This series, on
> top of many cleanups in the allocator & OOM killer, grants such OOM-
> killing allocations access to the system's memory reserves in order
> for them to make progress without relying on their own kill to exit.

I don't think

  [PATCH 8/9] mm: page_alloc: wait for OOM killer progress before retrying

and

  [PATCH 9/9] mm: page_alloc: memory reserve access for OOM-killing allocations

will work.

[PATCH 8/9] makes the speed of allocating __GFP_FS pages extremely slow (5
seconds / page) because out_of_memory() serialized by the oom_lock sleeps for
5 seconds before returning true when the OOM victim got stuck. This throttling
also slows down !__GFP_FS allocations when there is a thread doing a __GFP_FS
allocation, for __alloc_pages_may_oom() is serialized by the oom_lock
regardless of gfp_mask. How long will the OOM victim is blocked when the
allocating task needs to allocate e.g. 1000 !__GFP_FS pages before allowing
the OOM victim waiting at mutex_lock(&inode->i_mutex) to continue? It will be
a too-long-to-wait stall which is effectively a deadlock for users. I think
we should not sleep with the oom_lock held.

Also, allowing any !fatal_signal_pending() threads doing __GFP_FS allocations
(e.g. malloc() + memset()) to dip into the reserves will deplete them when the
OOM victim is blocked for a thread doing a !__GFP_FS allocation, for
[PATCH 9/9] does not allow !test_thread_flag(TIF_MEMDIE) threads doing
!__GFP_FS allocations to access the reserves. Of course, updating [PATCH 9/9]
like

-+     if (*did_some_progress)
-+          alloc_flags |= ALLOC_NO_WATERMARKS;
  out:
++     if (*did_some_progress)
++          alloc_flags |= ALLOC_NO_WATERMARKS;
       mutex_unlock(&oom_lock);

(which means use of "no watermark" without invoking the OOM killer) is
obviously wrong. I think we should not allow __GFP_FS allocations to
access to the reserves when the OOM victim is blocked.



By the way, I came up with an idea (incomplete patch on top of patches up to
7/9 is shown below) while trying to avoid sleeping with the oom_lock held.
This patch is meant for

  (1) blocking_notifier_call_chain(&oom_notify_list) is called after
      the OOM killer is disabled in order to increase possibility of
      memory allocation to succeed.

  (2) oom_kill_process() can determine when to kill next OOM victim.

  (3) oom_scan_process_thread() can take TIF_MEMDIE timeout into
      account when choosing an OOM victim.

What do you think?



diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index b20d2c0..843f2cd 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -356,11 +356,9 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
-	mutex_lock(&oom_lock);
 	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
 			   GFP_KERNEL, 0, NULL, true))
 		pr_info("OOM request ignored because killer is disabled\n");
-	mutex_unlock(&oom_lock);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 7deecb7..ed8c53b 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -32,8 +32,6 @@ enum oom_scan_t {
 /* Thread is the potential origin of an oom condition; kill first on oom */
 #define OOM_FLAG_ORIGIN		((__force oom_flags_t)0x1)
 
-extern struct mutex oom_lock;
-
 static inline void set_current_oom_origin(void)
 {
 	current->signal->oom_flags |= OOM_FLAG_ORIGIN;
@@ -49,8 +47,6 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return !!(p->signal->oom_flags & OOM_FLAG_ORIGIN);
 }
 
-extern void mark_oom_victim(struct task_struct *tsk);
-
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5fd273d..06a7a9f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1530,16 +1530,16 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned int points = 0;
 	struct task_struct *chosen = NULL;
 
-	mutex_lock(&oom_lock);
-
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
 	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		goto unlock;
+		get_task_struct(current);
+		oom_kill_process(current, gfp_mask, order, 0, 0, memcg, NULL,
+				 "Out of memory (killing exiting task)");
+		return;
 	}
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL, memcg);
@@ -1566,7 +1566,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				mem_cgroup_iter_break(memcg, iter);
 				if (chosen)
 					put_task_struct(chosen);
-				goto unlock;
+				return;
 			case OOM_SCAN_OK:
 				break;
 			};
@@ -1587,13 +1587,11 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		css_task_iter_end(&it);
 	}
 
-	if (chosen) {
-		points = chosen_points * 1000 / totalpages;
-		oom_kill_process(chosen, gfp_mask, order, points, totalpages,
-				 memcg, NULL, "Memory cgroup out of memory");
-	}
-unlock:
-	mutex_unlock(&oom_lock);
+	if (!chosen)
+		return;
+	points = chosen_points * 1000 / totalpages;
+	oom_kill_process(chosen, gfp_mask, order, points, totalpages,
+			 memcg, NULL, "Memory cgroup out of memory");
 }
 
 #if MAX_NUMNODES > 1
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5cfda39..9a8e430 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -43,7 +43,7 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 
-DEFINE_MUTEX(oom_lock);
+static DEFINE_SPINLOCK(oom_lock);
 
 #ifdef CONFIG_NUMA
 /**
@@ -414,9 +414,10 @@ bool oom_killer_disabled __read_mostly;
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk)
+static void mark_oom_victim(struct task_struct *tsk)
 {
 	WARN_ON(oom_killer_disabled);
+	assert_spin_locked(&oom_lock);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
@@ -456,22 +457,15 @@ void exit_oom_victim(void)
  */
 bool oom_killer_disable(void)
 {
-	/*
-	 * Make sure to not race with an ongoing OOM killer
-	 * and that the current is not the victim.
-	 */
-	mutex_lock(&oom_lock);
-	if (test_thread_flag(TIF_MEMDIE)) {
-		mutex_unlock(&oom_lock);
-		return false;
-	}
-
+	/* Make sure to not race with an ongoing OOM killer. */
+	spin_lock(&oom_lock);
 	oom_killer_disabled = true;
-	mutex_unlock(&oom_lock);
-
-	wait_event(oom_victims_wait, !atomic_read(&oom_victims));
-
-	return true;
+	spin_unlock(&oom_lock);
+	/* Prepare for stuck TIF_MEMDIE threads. */
+	if (!wait_event_timeout(oom_victims_wait, !atomic_read(&oom_victims),
+				60 * HZ))
+		oom_killer_disabled = false;
+	return oom_killer_disabled;
 }
 
 /**
@@ -482,6 +476,15 @@ void oom_killer_enable(void)
 	oom_killer_disabled = false;
 }
 
+static bool oom_kill_ok = true;
+
+static void oom_wait_expire(struct work_struct *unused)
+{
+	oom_kill_ok = true;
+}
+
+static DECLARE_DELAYED_WORK(oom_wait_work, oom_wait_expire);
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /*
  * Must be called while holding a reference to p, which will be released upon
@@ -500,6 +503,13 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
+	spin_lock(&oom_lock);
+	/*
+	 * Did we race with oom_killer_disable() or another oom_kill_process()?
+	 */
+	if (oom_killer_disabled || !oom_kill_ok)
+		goto unlock;
+
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
@@ -508,8 +518,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	if (p->mm && task_will_free_mem(p)) {
 		mark_oom_victim(p);
 		task_unlock(p);
-		put_task_struct(p);
-		return;
+		goto unlock;
 	}
 	task_unlock(p);
 
@@ -551,8 +560,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	p = find_lock_task_mm(victim);
 	if (!p) {
-		put_task_struct(victim);
-		return;
+		p = victim;
+		goto unlock;
 	} else if (victim != p) {
 		get_task_struct(p);
 		put_task_struct(victim);
@@ -593,7 +602,20 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	rcu_read_unlock();
 
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	put_task_struct(victim);
+	p = victim;
+	/*
+	 * Since choosing an OOM victim is done asynchronously, someone might
+	 * have chosen an extra victim which would not have been chosen if we
+	 * waited the previous victim to die. Therefore, wait for a while
+	 * before trying to kill the next victim. If oom_scan_process_thread()
+	 * uses oom_kill_ok than force_kill, it will act like TIF_MEMDIE
+	 * timeout.
+	 */
+	oom_kill_ok = false;
+	schedule_delayed_work(&oom_wait_work, HZ);
+unlock:
+	spin_unlock(&oom_lock);
+	put_task_struct(p);
 }
 #undef K
 
@@ -658,9 +680,6 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 	int killed = 0;
 
-	if (oom_killer_disabled)
-		return false;
-
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
 		/* Got some memory back in the last second. */
@@ -676,7 +695,9 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 */
 	if (current->mm &&
 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
-		mark_oom_victim(current);
+		get_task_struct(current);
+		oom_kill_process(current, gfp_mask, order, 0, 0, NULL, nodemask,
+				 "Out of memory (killing exiting task)");
 		goto out;
 	}
 
@@ -731,9 +752,6 @@ void pagefault_out_of_memory(void)
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	if (!mutex_trylock(&oom_lock))
-		return;
-
 	if (!out_of_memory(NULL, 0, 0, NULL, false)) {
 		/*
 		 * There shouldn't be any user tasks runnable while the
@@ -743,6 +761,4 @@ void pagefault_out_of_memory(void)
 		 */
 		WARN_ON(test_thread_flag(TIF_MEMDIE));
 	}
-
-	mutex_unlock(&oom_lock);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b4e4f81..2b69467 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2331,16 +2331,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	*did_some_progress = 0;
 
 	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
-	 */
-	if (!mutex_trylock(&oom_lock)) {
-		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
-		return NULL;
-	}
-
-	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
 	 * we're still under heavy pressure.
@@ -2381,7 +2371,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
 		*did_some_progress = 1;
 out:
-	mutex_unlock(&oom_lock);
 	return page;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
