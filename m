Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 455406B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 07:16:58 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id av4so113237032igc.1
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 04:16:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id qm12si5739720igb.6.2016.03.16.04.16.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Mar 2016 04:16:56 -0700 (PDT)
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602201132.EFG90182.FOVtSOJHFOLFQM@I-love.SAKURA.ne.jp>
	<20160222094105.GD17938@dhcp22.suse.cz>
	<201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp>
	<20160315114300.GC6108@dhcp22.suse.cz>
	<20160315115001.GE6108@dhcp22.suse.cz>
In-Reply-To: <20160315115001.GE6108@dhcp22.suse.cz>
Message-Id: <201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
Date: Wed, 16 Mar 2016 20:16:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Tue 15-03-16 20:15:24, Tetsuo Handa wrote:
> [...]
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 23b8b06..0464727 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -543,7 +543,7 @@ static int oom_reaper(void *unused)
> >  
> >  static void wake_oom_reaper(struct task_struct *tsk)
> >  {
> > -	if (!oom_reaper_th)
> > +	if (!oom_reaper_th || tsk->oom_reaper_list)
> >  		return;
> >  
> >  	get_task_struct(tsk);
> 
> OK, this is indeed much simpler. Back then when the list_head was used
> this would be harder and I didn't realize moving away from the list_head
> would simplify this as well. Care to send a patch to replace the
> oom-oom_reaper-disable-oom_reaper-for-oom_kill_allocating_task.patch in
> the mmotm tree?

Sent as 1458124527-5441-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

> > Two thread groups sharing the same mm can disable the OOM reaper
> > when all threads in the former thread group (which will be chosen
> > as an OOM victim by the OOM killer) can immediately call exit_mm()
> > via do_exit() (e.g. simply sleeping in killable state when the OOM
> > killer chooses that thread group) and some thread in the latter thread
> > group is contended on unkillable locks (e.g. inode mutex), due to
> >
> > 	p = find_lock_task_mm(tsk);
> > 	if (!p)
> > 		return true;
> >
> > in __oom_reap_task() and
> >
> > 	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
> >
> > in oom_kill_process(). The OOM reaper is woken up in order to reap
> > the former thread group's memory, but it does nothing on the latter
> > thread group's memory because the former thread group can clear its mm
> > before the OOM reaper locks its mm. Even if subsequent out_of_memory()
> > call chose the latter thread group, the OOM reaper will not be woken up.
> > No memory is reaped. We need to queue all thread groups sharing that
> > memory if that memory should be reaped.
>
> Why it wouldn't be enough to wake the oom reaper only for the oom
> victims? If the oom reaper races with the victims exit path then
> the next round of the out_of_memory will select a different thread
> sharing the same mm.

If we use MMF_OOM_KILLED, we can hit below sequence.

(1) first round of out_of_memory() sends SIGKILL to both p0 and p1
    and sets TIF_MEMDIE on p0 and and sets MMF_OOM_KILLED on p0's mm.

(2) p0 releases its mm.

(3) oom_reap_task() does nothing on p1 because p0 released its mm.

(4) second round of out_of_memory() sends SIGKILL to p1 and sets
    TIF_MEMDIE on p1.

(5) oom_reap_task() is not called because p1's mm already has MMF_OOM_KILLED.

(6) oom_reap_task() won't clear TIF_MEMDIE on p1 even if p1 got stuck at
    unkillable lock.

If we get rid of MMF_OOM_KILLED, oom_reap_task() will be called upon
next round of out_of_memory() unless that hits the shortcuts.

>
> And just to prevent from a confusion. I mean waking up also when
> fatal_signal_pending and we do not really go down to selecting an oom
> victim. Which would be worth a separate patch on top of course.

I couldn't understand this part. The shortcut

        if (current->mm &&
            (fatal_signal_pending(current) || task_will_free_mem(current))) {
                mark_oom_victim(current);
                return true;
        }

is not used for !__GFP_FS && !__GFP_NOFAIL allocation requests. I think
we might go down to selecting an oom victim by out_of_memory() calls by
not-yet-killed processes.



Anyway, why do we want to let out_of_memory() try to choose p1 without
giving oom_reap_task() a chance to reap p1's mm?

Here is a pathological situation:

  There are 100 thread groups (p[0] to p[99]) sharing the same memory.
  They all have *p->signal->oom_score_adj == OOM_SCORE_ADJ_MAX.
  Any p[n+1] except p[0] is waiting for p[n] to call mutex_unlock() in

      mutex_lock(&lock);
      ptr = kmalloc(sizeof(*ptr), GFP_NOFS);
      if (ptr)
          do_something(ptr);
      mutex_unlock(&lock);

  sequence, and p[0] is doing kmalloc() before mutex_unlock().

  First round of out_of_memory() selects p[0].
  p[0..99] get SIGKILL and p[0] gets TIF_MEMDIE.
  p[0] releases unkillable lock and terminates and does p[0]->mm = NULL.
  oom_reap_task() did nothing due to p[0]->mm == NULL.
  Next round of out_of_memory() selects p[1].
  p[1..99] get SIGKILL and p[1] gets TIF_MEMDIE.
  p[1] releases unkillable lock and terminates and does p[1]->mm = NULL.
  oom_reap_task() did nothing due to p[1]->mm == NULL.
  Next round of out_of_memory() selects p[2].
  p[2..99] get SIGKILL and p[2] gets TIF_MEMDIE.
  p[2] releases unkillable lock and terminates and does p[2]->mm = NULL.
  oom_reap_task() did nothing due to p[2]->mm == NULL.
  (...snipped...)
  Next round of out_of_memory() selects p[99].
  p[99] gets SIGKILL and p[99] gets TIF_MEMDIE.
  p[99] releases unkillable lock and terminates and does p[99]->mm = NULL.
  oom_reap_task() did nothing due to p[99]->mm == NULL.
  p's memory is released, and out_of_memory() will no longer be called if OOM situation was resolved.

If we give p[0..99] a chance to terminate as soon as possible using
TIF_MEMDIE when first round of out_of_memory() selected p[0], we can
save a lot of out_of_memory() warning messages. I think that setting
TIF_MEMDIE on 100 threads does not increase possibility of depletion
of memory reserves because TIF_MEMDIE helps only if that thread is
doing memory allocation. If 100 threads were concurrently doing __GFP_FS
or __GFP_NOFAIL memory allocation, they will get TIF_MEMDIE after all.
(We can reduce possibility of depletion of memory reserves than now
if __GFP_KILLABLE were available.) Also, by queuing p[0..99] when p[0]
is selected, oom_reap_task() will likely be able to reap p's memory
before 100 times of failing oom_reap_task() attempt complete.

Therefore, I think we can do something like below patch (partial revert
of "oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address
space" with sysctl_oom_kill_allocating_task / oom_task_origin() / SysRq-f
fixes included).

----------
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 45993b8..03e6257 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -91,7 +91,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 
 extern bool out_of_memory(struct oom_control *oc);
 
-extern void exit_oom_victim(struct task_struct *tsk);
+extern void exit_oom_victim(void);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8fb187f..99b60ca 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -786,6 +786,18 @@ struct signal_struct {
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
+	/*
+	 * OOM-killer should ignore this process when selecting candidates
+	 * because this process was already OOM-killed. OOM-killer can wait
+	 * for existing TIF_MEMDIE threads unless SysRq-f is requested.
+	 */
+	bool oom_killed;
+	/*
+	 * OOM-killer should not wait for TIF_MEMDIE thread when selecting
+	 * candidates because OOM-reaper already reaped memory used by this
+	 * process.
+	 */
+	bool oom_reap_done;
 
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
diff --git a/kernel/exit.c b/kernel/exit.c
index fd90195..953d1a1 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -435,7 +435,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim(tsk);
+		exit_oom_victim();
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 31bbdc6..3261d4a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -149,6 +149,12 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
 
+#ifdef CONFIG_MMU
+	/* See __oom_reap_task(). */
+	if (p->signal->oom_reap_done)
+		return true;
+#endif
+
 	return false;
 }
 
@@ -167,7 +173,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	long points;
 	long adj;
 
-	if (oom_unkillable_task(p, memcg, nodemask))
+	if (oom_unkillable_task(p, memcg, nodemask) || p->signal->oom_killed)
 		return 0;
 
 	p = find_lock_task_mm(p);
@@ -487,14 +493,11 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	up_read(&mm->mmap_sem);
 
 	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore. OOM killer can continue
-	 * by selecting other victim if unmapping hasn't led to any
-	 * improvements. This also means that selecting this task doesn't
-	 * make any sense.
+	 * This task shouldn't be sitting on a reasonably reclaimable memory
+	 * anymore. OOM killer should consider selecting other victim if
+	 * unmapping hasn't led to any improvements.
 	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
-	exit_oom_victim(tsk);
+	tsk->signal->oom_reap_done = true;
 out:
 	mmput(mm);
 	return ret;
@@ -521,8 +524,6 @@ static void oom_reap_task(struct task_struct *tsk)
 
 static int oom_reaper(void *unused)
 {
-	set_freezable();
-
 	while (true) {
 		struct task_struct *tsk = NULL;
 
@@ -598,10 +599,9 @@ void mark_oom_victim(struct task_struct *tsk)
 /**
  * exit_oom_victim - note the exit of an OOM victim
  */
-void exit_oom_victim(struct task_struct *tsk)
+void exit_oom_victim(void)
 {
-	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
+	clear_thread_flag(TIF_MEMDIE);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -662,6 +662,142 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
+#ifdef CONFIG_MMU
+/*
+ * We cannot use oom_reaper if the memory is shared by OOM-unkillable process
+ * because OOM-unkillable process wouldn't get killed and so the memory might
+ * be still used.
+ */
+static bool oom_can_reap_mm(struct mm_struct *mm)
+{
+	bool can_oom_reap = true;
+	struct task_struct *p;
+
+	rcu_read_lock();
+	for_each_process(p) {
+		if (!process_shares_mm(p, mm))
+			continue;
+		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+			can_oom_reap = false;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return can_oom_reap;
+}
+#else
+static bool oom_can_reap_mm(struct mm_struct *mm)
+{
+	return false;
+}
+#endif
+
+/*
+ * Kill all OOM-killable user threads sharing this victim->mm.
+ *
+ * This mitigates mm->mmap_sem livelock caused by one thread being
+ * unable to release its mm due to being blocked at
+ * down_read(&mm->mmap_sem) in exit_mm() while another thread is doing
+ * __GFP_FS allocation with mm->mmap_sem held for write.
+ *
+ * They all get access to memory reserves.
+ *
+ * This prevents the OOM killer from choosing next OOM victim as soon
+ * as current victim thread released its mm. This also mitigates kernel
+ * log buffer being spammed by OOM killer messages due to choosing next
+ * OOM victim thread sharing the current OOM victim's memory.
+ *
+ * This mitigates the problem that a thread doing __GFP_FS allocation
+ * with mmap_sem held for write cannot call out_of_memory() for
+ * unpredictable duration due to oom_lock contention and/or scheduling
+ * priority, for the OOM reaper will not wait forever until such thread
+ * leaves memory allocating loop by calling out_of_memory(). This also
+ * mitigates the problem that a thread doing !__GFP_FS && !__GFP_NOFAIL
+ * allocation cannot leave memory allocating loop because it cannot
+ * call out_of_memory() even after it is killed.
+ *
+ * They all get excluded from OOM victim selection.
+ *
+ * This mitigates the problem that SysRq-f continues choosing the same
+ * process. We still need SysRq-f because it is possible that victim
+ * threads are blocked at unkillable locks inside memory allocating
+ * loop (e.g. fs writeback from direct reclaim) even after they got
+ * SIGKILL and TIF_MEMDIE.
+ */
+static void oom_kill_mm_users(struct mm_struct *mm)
+{
+	const bool can_oom_reap = oom_can_reap_mm(mm);
+	struct task_struct *p;
+	struct task_struct *t;
+
+	rcu_read_lock();
+	for_each_process(p) {
+		if (!process_shares_mm(p, mm))
+			continue;
+		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			continue;
+		/*
+		 * We should send SIGKILL before setting TIF_MEMDIE in order to
+		 * prevent the OOM victim from depleting the memory reserves
+		 * from the user space under its control.
+		 */
+		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		p->signal->oom_killed = true;
+		for_each_thread(p, t) {
+			task_lock(t);
+			if (t->mm)
+				mark_oom_victim(t);
+			task_unlock(t);
+		}
+		if (can_oom_reap)
+			wake_oom_reaper(p);
+	}
+	rcu_read_unlock();
+}
+
+/*
+ * If any of p's children has a different mm and is eligible for kill,
+ * the one with the highest oom_badness() score is sacrificed for its
+ * parent. This attempts to lose the minimal amount of work done while
+ * still freeing memory.
+ */
+static struct task_struct *oom_scan_children(struct task_struct *victim,
+					     struct oom_control *oc,
+					     unsigned long totalpages,
+					     struct mem_cgroup *memcg)
+{
+	struct task_struct *p = victim;
+	struct mm_struct *mm = p->mm;
+	struct task_struct *t;
+	struct task_struct *child;
+	unsigned int victim_points = 0;
+
+	read_lock(&tasklist_lock);
+	for_each_thread(p, t) {
+		list_for_each_entry(child, &t->children, sibling) {
+			unsigned int child_points;
+
+			if (process_shares_mm(child, mm))
+				continue;
+			/*
+			 * oom_badness() returns 0 if the thread is unkillable
+			 */
+			child_points = oom_badness(child, memcg, oc->nodemask,
+						   totalpages);
+			if (child_points > victim_points) {
+				put_task_struct(victim);
+				victim = child;
+				victim_points = child_points;
+				get_task_struct(victim);
+			}
+		}
+	}
+	read_unlock(&tasklist_lock);
+	return victim;
+}
+
 /*
  * Must be called while holding a reference to p, which will be released upon
  * returning.
@@ -671,13 +807,16 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		      struct mem_cgroup *memcg, const char *message)
 {
 	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t;
 	struct mm_struct *mm;
-	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
+	const bool kill_current = !p;
+
+	if (kill_current) {
+		p = current;
+		victim = p;
+		get_task_struct(p);
+	}
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -698,33 +837,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 
-	/*
-	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest oom_badness() score is sacrificed for its
-	 * parent.  This attempts to lose the minimal amount of work done while
-	 * still freeing memory.
-	 */
-	read_lock(&tasklist_lock);
-	for_each_thread(p, t) {
-		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
-
-			if (process_shares_mm(child, p->mm))
-				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
-			child_points = oom_badness(child, memcg, oc->nodemask,
-								totalpages);
-			if (child_points > victim_points) {
-				put_task_struct(victim);
-				victim = child;
-				victim_points = child_points;
-				get_task_struct(victim);
-			}
-		}
-	}
-	read_unlock(&tasklist_lock);
+	if (!kill_current && !oom_task_origin(victim))
+		victim = oom_scan_children(victim, oc, totalpages, memcg);
 
 	p = find_lock_task_mm(victim);
 	if (!p) {
@@ -739,54 +853,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
 	atomic_inc(&mm->mm_count);
-	/*
-	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
-	 * the OOM victim from depleting the memory reserves from the user
-	 * space under its control.
-	 */
-	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
 		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
 		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
 	task_unlock(victim);
+	put_task_struct(victim);
 
-	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
-	 */
-	rcu_read_lock();
-	for_each_process(p) {
-		if (!process_shares_mm(p, mm))
-			continue;
-		if (same_thread_group(p, victim))
-			continue;
-		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-			/*
-			 * We cannot use oom_reaper for the mm shared by this
-			 * process because it wouldn't get killed and so the
-			 * memory might be still used.
-			 */
-			can_oom_reap = false;
-			continue;
-		}
-		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
-	}
-	rcu_read_unlock();
-
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
+	oom_kill_mm_users(mm);
 
 	mmdrop(mm);
-	put_task_struct(victim);
 }
 #undef K
 
@@ -880,8 +957,7 @@ bool out_of_memory(struct oom_control *oc)
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-		get_task_struct(current);
-		oom_kill_process(oc, current, 0, totalpages, NULL,
+		oom_kill_process(oc, NULL, 0, totalpages, NULL,
 				 "Out of memory (oom_kill_allocating_task)");
 		return true;
 	}
----------

If we can tolerate lack of process name and its pid when reporting
success/failure (or we pass them via mm_struct or walk the process list or
whatever else), I think we can do something like below patch (most revert of
"oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space").

----------
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 944b2b3..a52ada1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -509,6 +509,14 @@ struct mm_struct {
 #ifdef CONFIG_HUGETLB_PAGE
 	atomic_long_t hugetlb_usage;
 #endif
+#ifdef CONFIG_MMU
+	/*
+	 * If this field refers self, OOM-killer should not wait for TIF_MEMDIE
+	 * thread using this mm_struct when selecting candidates, for
+	 * OOM-reaper already reaped memory used by this mm_struct.
+	 */
+	struct mm_struct *oom_reaper_list;
+#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 9f30cae..d13163a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -792,12 +792,6 @@ struct signal_struct {
 	 * for existing TIF_MEMDIE threads unless SysRq-f is requested.
 	 */
 	bool oom_killed;
-	/*
-	 * OOM-killer should not wait for TIF_MEMDIE thread when selecting
-	 * candidates because OOM-reaper already reaped memory used by this
-	 * process.
-	 */
-	bool oom_reap_done;
 
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
@@ -1861,9 +1855,6 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
-#ifdef CONFIG_MMU
-	struct task_struct *oom_reaper_list;
-#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3261d4a..2199c71 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -150,9 +150,15 @@ static bool oom_unkillable_task(struct task_struct *p,
 		return true;
 
 #ifdef CONFIG_MMU
-	/* See __oom_reap_task(). */
-	if (p->signal->oom_reap_done)
-		return true;
+	/* p's memory might be already reclaimed by the OOM reaper. */
+	p = find_lock_task_mm(p);
+	if (p) {
+		struct mm_struct *mm = p->mm;
+		const bool unkillable = (mm->oom_reaper_list == mm);
+
+		task_unlock(p);
+		return unkillable;
+	}
 #endif
 
 	return false;
@@ -425,37 +431,21 @@ bool oom_killer_disabled __read_mostly;
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
+static struct mm_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
 
-static bool __oom_reap_task(struct task_struct *tsk)
+static bool __oom_reap_vmas(struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	struct mm_struct *mm;
-	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
 	bool ret = true;
 
-	/*
-	 * Make sure we find the associated mm_struct even when the particular
-	 * thread has already terminated and cleared its mm.
-	 * We might have race with exit path so consider our work done if there
-	 * is no mm.
-	 */
-	p = find_lock_task_mm(tsk);
-	if (!p)
-		return true;
-
-	mm = p->mm;
-	if (!atomic_inc_not_zero(&mm->mm_users)) {
-		task_unlock(p);
+	/* We might have raced with exit path */
+	if (!atomic_inc_not_zero(&mm->mm_users))
 		return true;
-	}
-
-	task_unlock(p);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
@@ -485,73 +475,75 @@ static bool __oom_reap_task(struct task_struct *tsk)
 		}
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
-	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-			task_pid_nr(tsk), tsk->comm,
-			K(get_mm_counter(mm, MM_ANONPAGES)),
-			K(get_mm_counter(mm, MM_FILEPAGES)),
-			K(get_mm_counter(mm, MM_SHMEMPAGES)));
+	pr_info("oom_reaper: now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+		K(get_mm_counter(mm, MM_ANONPAGES)),
+		K(get_mm_counter(mm, MM_FILEPAGES)),
+		K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
 
 	/*
-	 * This task shouldn't be sitting on a reasonably reclaimable memory
-	 * anymore. OOM killer should consider selecting other victim if
+	 * This mm no longer has reasonably reclaimable memory.
+	 * OOM killer should consider selecting other victim if
 	 * unmapping hasn't led to any improvements.
 	 */
-	tsk->signal->oom_reap_done = true;
+	mm->oom_reaper_list = mm;
 out:
 	mmput(mm);
 	return ret;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-static void oom_reap_task(struct task_struct *tsk)
+static void oom_reap_vmas(struct mm_struct *mm)
 {
 	int attempts = 0;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk))
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_vmas(mm))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts > MAX_OOM_REAP_RETRIES) {
-		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-				task_pid_nr(tsk), tsk->comm);
+		pr_info("oom_reaper: unable to reap memory\n");
 		debug_show_all_locks();
 	}
 
 	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
+	mmdrop(mm);
 }
 
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct task_struct *tsk = NULL;
+		struct mm_struct *mm = NULL;
 
 		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
 		spin_lock(&oom_reaper_lock);
 		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
+			mm = oom_reaper_list;
+			oom_reaper_list = mm->oom_reaper_list;
 		}
 		spin_unlock(&oom_reaper_lock);
 
-		if (tsk)
-			oom_reap_task(tsk);
+		if (mm)
+			oom_reap_vmas(mm);
 	}
 
 	return 0;
 }
 
-static void wake_oom_reaper(struct task_struct *tsk)
+static void wake_oom_reaper(struct mm_struct *mm)
 {
-	if (!oom_reaper_th || tsk->oom_reaper_list)
+	if (!oom_reaper_th || mm->oom_reaper_list)
 		return;
 
-	get_task_struct(tsk);
+	/*
+	 * Pin the given mm. Use mm_count instead of mm_users because
+	 * we do not want to delay the address space tear down.
+	 */
+	atomic_inc(&mm->mm_count);
 
 	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
+	mm->oom_reaper_list = oom_reaper_list;
+	oom_reaper_list = mm;
 	spin_unlock(&oom_reaper_lock);
 	wake_up(&oom_reaper_wait);
 }
@@ -568,7 +560,7 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
-static void wake_oom_reaper(struct task_struct *tsk)
+static void wake_oom_reaper(struct mm_struct *mm)
 {
 }
 #endif
@@ -662,37 +654,6 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
-#ifdef CONFIG_MMU
-/*
- * We cannot use oom_reaper if the memory is shared by OOM-unkillable process
- * because OOM-unkillable process wouldn't get killed and so the memory might
- * be still used.
- */
-static bool oom_can_reap_mm(struct mm_struct *mm)
-{
-	bool can_oom_reap = true;
-	struct task_struct *p;
-
-	rcu_read_lock();
-	for_each_process(p) {
-		if (!process_shares_mm(p, mm))
-			continue;
-		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-			can_oom_reap = false;
-			break;
-		}
-	}
-	rcu_read_unlock();
-	return can_oom_reap;
-}
-#else
-static bool oom_can_reap_mm(struct mm_struct *mm)
-{
-	return false;
-}
-#endif
-
 /*
  * Kill all OOM-killable user threads sharing this victim->mm.
  *
@@ -727,7 +688,7 @@ static bool oom_can_reap_mm(struct mm_struct *mm)
  */
 static void oom_kill_mm_users(struct mm_struct *mm)
 {
-	const bool can_oom_reap = oom_can_reap_mm(mm);
+	bool can_oom_reap = true;
 	struct task_struct *p;
 	struct task_struct *t;
 
@@ -736,8 +697,16 @@ static void oom_kill_mm_users(struct mm_struct *mm)
 		if (!process_shares_mm(p, mm))
 			continue;
 		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+			/*
+			 * We cannot use oom_reaper if the memory is shared by
+			 * OOM-unkillable process because OOM-unkillable
+			 * process wouldn't get killed and so the memory might
+			 * be still used.
+			 */
+			can_oom_reap = false;
 			continue;
+		}
 		/*
 		 * We should send SIGKILL before setting TIF_MEMDIE in order to
 		 * prevent the OOM victim from depleting the memory reserves
@@ -751,10 +720,10 @@ static void oom_kill_mm_users(struct mm_struct *mm)
 				mark_oom_victim(t);
 			task_unlock(t);
 		}
-		if (can_oom_reap)
-			wake_oom_reaper(p);
 	}
 	rcu_read_unlock();
+	if (can_oom_reap)
+		wake_oom_reaper(mm);
 }
 
 /*
----------

Well, I wanted to split oom_kill_process() into several small
functions before we start applying OOM reaper patches...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
