Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 753F04403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 06:14:59 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so32658040pab.3
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 03:14:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bw10si23426839pab.22.2016.02.05.03.14.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 03:14:58 -0800 (PST)
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-4-git-send-email-mhocko@kernel.org>
	<201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
	<20160204144319.GD14425@dhcp22.suse.cz>
	<201602050008.HEG12919.FFOMOHVtQFSLJO@I-love.SAKURA.ne.jp>
	<20160204163113.GF14425@dhcp22.suse.cz>
In-Reply-To: <20160204163113.GF14425@dhcp22.suse.cz>
Message-Id: <201602052014.HBG52666.HFMOQVLFOSFJtO@I-love.SAKURA.ne.jp>
Date: Fri, 5 Feb 2016 20:14:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 05-02-16 00:08:25, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > > +	/*
> > > > > +	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> > > > > +	 * reasonably reclaimable memory anymore. OOM killer can continue
> > > > > +	 * by selecting other victim if unmapping hasn't led to any
> > > > > +	 * improvements. This also means that selecting this task doesn't
> > > > > +	 * make any sense.
> > > > > +	 */
> > > > > +	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
> > > > > +	exit_oom_victim(tsk);
> > > >
> > > > I noticed that updating only one thread group's oom_score_adj disables
> > > > further wake_oom_reaper() calls due to rough-grained can_oom_reap check at
> > > >
> > > >   p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN
> > > >
> > > > in oom_kill_process(). I think we need to either update all thread groups'
> > > > oom_score_adj using the reaped mm equally or use more fine-grained can_oom_reap
> > > > check which ignores OOM_SCORE_ADJ_MIN if all threads in that thread group are
> > > > dying or exiting.
> > >
> > > I do not understand. Why would you want to reap the mm again when
> > > this has been done already? The mm is shared, right?
> >
> > The mm is shared between previous victim and next victim, but these victims
> > are in different thread groups. The OOM killer selects next victim whose mm
> > was already reaped due to sharing previous victim's memory.
>
> OK, now I got your point. From your previous email it sounded like you
> were talking about oom_reaper and its invocation which is was confusing.
>
> > We don't want the OOM killer to select such next victim.
>
> Yes, selecting such a task doesn't make much sense. It has been killed
> so it has fatal_signal_pending. If it wanted to allocate it would get
> TIF_MEMDIE already and it's address space has been reaped so there is
> nothing to free left. These CLONE_VM without CLONE_SIGHAND is really
> crazy combo, it is just causing troubles all over and I am not convinced
> it is actually that helpful </rant>.
>

I think moving "whether a mm is reapable or not" check to the OOM reaper
is preferable (shown below). In most cases, mm_is_reapable() will return
true.

----------------------------------------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b42c6bc..fc114b3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -426,6 +426,39 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static LIST_HEAD(oom_reaper_list);
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
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
 
 static bool __oom_reap_task(struct task_struct *tsk)
 {
@@ -455,7 +488,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 
 	task_unlock(p);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_is_reapable(mm) || !down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		goto out;
 	}
@@ -596,6 +629,7 @@ void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+	wake_oom_reaper(tsk);
 }
 
 /**
@@ -680,7 +714,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -771,23 +804,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-			/*
-			 * We cannot use oom_reaper for the mm shared by this
-			 * process because it wouldn't get killed and so the
-			 * memory might be still used.
-			 */
-			can_oom_reap = false;
+		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
-		}
+		if (is_global_init(p))
+			continue;
+		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			continue;
+
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
----------------------------------------

Then, I think we need to kill two lies in allocation retry loop.

The first lie is that we pretend as if we are making forward progress
without hitting the OOM killer. This lie is preventing any OOM victim
(with SIGKILL and without TIF_MEMDIE) doing !__GFP_FS allocations from
hitting the OOM killer, which can prevent the OOM victim tasks from
reaching do_exit(), and which is conflicting with assumption

  * That thread will now get access to memory reserves since it has a
  * pending fatal signal.

in oom_kill_process() and similar assertions like this patch's description.

  The lack of TIF_MEMDIE also means that the victim cannot access memory
  reserves anymore but that shouldn't be a problem because it would get
  the access again if it needs to allocate and hits the OOM killer again
  due to the fatal_signal_pending resp. PF_EXITING check.

If the callers of !__GFP_FS allocation do not need to loop until somebody
else reclaims memory on behalf of them, they can add __GFP_NORETRY. Otherwise,
the callers of !__GFP_FS allocation can and should call out_of_memory().
That's all we need for killing this lie.

----------------------------------------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1668159..67591a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2772,20 +2772,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		/* The OOM killer does not needlessly kill tasks for lowmem */
 		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
-		/* The OOM killer does not compensate for IO-less reclaim */
-		if (!(gfp_mask & __GFP_FS)) {
-			/*
-			 * XXX: Page reclaim didn't yield anything,
-			 * and the OOM killer can't be invoked, but
-			 * keep looping as per tradition.
-			 *
-			 * But do not keep looping if oom_killer_disable()
-			 * was already called, for the system is trying to
-			 * enter a quiescent state during suspend.
-			 */
-			*did_some_progress = !oom_killer_disabled;
-			goto out;
-		}
 		if (pm_suspended_storage())
 			goto out;
 		/* The OOM killer may not free memory on a specific node */
----------------------------------------

The second lie is that we pretend as if we are making forward progress
without taking any action when the OOM killer found a TIF_MEMDIE task.
This lie is preventing any task (without SIGKILL and without TIF_MEMDIE)
which is blocking the OOM victim (which might be looping without getting
TIF_MEMDIE due to doing !__GFP_FS allocation) from making forward progress
if the OOM reaper does not clear TIF_MEMDIE.

----------------------------------------
	/* Retry as long as the OOM killer is making progress */
	if (did_some_progress) {
		no_progress_loops = 0;
		goto retry;
	}
----------------------------------------
        v.s.
----------------------------------------
	/*
	 * This task already has access to memory reserves and is being killed.
	 * Don't allow any other task to have access to the reserves.
	 */
	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
		if (!is_sysrq_oom(oc))
			return OOM_SCAN_ABORT;
	}
----------------------------------------

By moving "whether a mm is reapable or not" check to the OOM reaper, we can
delegate the duty of clearing TIF_MEMDIE to the OOM reaper because the OOM
reaper is tracking all TIF_MEMDIE tasks. Since mm_is_reapable() can return
true for most situations, it becomes an unlikely corner case that we need to
clear TIF_MEMDIE and prevent the OOM killer from setting TIF_MEMDIE on the
same task again when the OOM reaper gave up. Like you commented in [PATCH 5/5],
falling back to simple timer would be sufficient for handling such corner cases.

| I would really prefer to go a simpler way first and extend the code when
| we see the current approach insufficient for real life loads. Please do
| not get me wrong, of course the code can be enhanced in many different
| ways and optimize for lots of pathological cases but I really believe
| that we should start with correctness first and only later care about
| optimizing corner cases.

>
> > Maybe set MMF_OOM_REAP_DONE on
> > the previous victim's mm and check it instead of TIF_MEMDIE when selecting
> > a victim? That will also avoid problems caused by clearing TIF_MEMDIE?
>
> Hmm, it doesn't seem we are under MMF_ availabel bits pressure right now
> so using the flag sounds like the easiest way to go. Then we even do not
> have to play with OOM_SCORE_ADJ_MIN which might be updated from the
> userspace after the oom reaper has done that. Care to send a patch?

Not only we don't need to worry about ->oom_score_adj being modified from
outside the SIGKILL pending tasks, I think we also don't need to clear remote
TIF_MEMDIE if we use MMF_OOM_REAP_DONE. Something like below untested patch?

----------------------------------------
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
index 012dd6f..442ba46 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -515,6 +515,8 @@ static inline int get_dumpable(struct mm_struct *mm)
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
+#define MMF_OOM_REAP_DONE       21      /* set when OOM reap completed */
+
 struct sighand_struct {
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];
diff --git a/kernel/exit.c b/kernel/exit.c
index ba3bd29..10e0882 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -434,7 +434,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim(tsk);
+		exit_oom_victim();
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b42c6bc..b67d8bf 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -271,19 +271,24 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 			struct task_struct *task, unsigned long totalpages)
 {
+	struct mm_struct *mm;
+
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
 		return OOM_SCAN_CONTINUE;
 
+	mm = task->mm;
+	if (!mm)
+		return OOM_SCAN_CONTINUE;
 	/*
 	 * This task already has access to memory reserves and is being killed.
-	 * Don't allow any other task to have access to the reserves.
+	 * Don't allow any other task to have access to the reserves unless
+	 * this task's memory was OOM reaped.
 	 */
 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (!is_sysrq_oom(oc))
+		if (!is_sysrq_oom(oc) &&
+		    !test_bit(MMF_OOM_REAP_DONE, &mm->flags))
 			return OOM_SCAN_ABORT;
 	}
-	if (!task->mm)
-		return OOM_SCAN_CONTINUE;
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -448,7 +453,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
 		return true;
 
 	mm = p->mm;
-	if (!atomic_inc_not_zero(&mm->mm_users)) {
+	if (test_bit(MMF_OOM_REAP_DONE, &mm->flags) ||
+	    !atomic_inc_not_zero(&mm->mm_users)) {
 		task_unlock(p);
 		return true;
 	}
@@ -491,14 +497,11 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	up_read(&mm->mmap_sem);
 
 	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore. OOM killer can continue
-	 * by selecting other victim if unmapping hasn't led to any
-	 * improvements. This also means that selecting this task doesn't
-	 * make any sense.
+	 * Set MMF_OOM_REAP_DONE on this mm so that OOM killer can continue
+	 * by selecting other victim which does not use this mm if unmapping
+	 * this mm hasn't led to any improvements.
 	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
-	exit_oom_victim(tsk);
+	set_bit(MMF_OOM_REAP_DONE, &mm->flags);
 out:
 	mmput(mm);
 	return ret;
@@ -601,10 +604,9 @@ void mark_oom_victim(struct task_struct *tsk)
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
----------------------------------------

I suggested many changes in this post because [PATCH 3/5] and [PATCH 5/5]
made it possible for us to simplify [PATCH 1/5] like old versions. I think
you want to rebuild this series with these changes merged as appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
