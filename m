Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C28B76B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 06:20:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a66so13723715wme.1
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 03:20:05 -0700 (PDT)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id 10si1137433wmm.97.2016.06.28.03.20.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jun 2016 03:20:04 -0700 (PDT)
Received: by mail-wm0-f44.google.com with SMTP id v199so133126339wmv.0
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 03:20:04 -0700 (PDT)
Date: Tue, 28 Jun 2016 12:19:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160628101956.GA510@dhcp22.suse.cz>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160627175555.GA24370@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Mon 27-06-16 19:55:55, Oleg Nesterov wrote:
> On 06/27, Michal Hocko wrote:
> >
> > On Mon 27-06-16 17:51:20, Oleg Nesterov wrote:
> > >
> > > Yes I agree, it would be nice to remove find_lock_task_mm(). And in
> > > fact it would be nice to kill task_struct->mm (but this needs a lot
> > > of cleanups). We probably want signal_struct->mm, but this is a bit
> > > complicated (locking).
> >
> > Is there any hard requirement to reset task_struct::mm in the first
> > place?
> 
> Well, at least the scheduler needs this.

Could you point me to where it depends on that? I mean if we are past
exit_mm then we have unmapped the address space most probably but why
should we care about that in the scheduler? There shouldn't be any
further access to the address space by that point. I can see that
context_switch() checks task->mm but it should just work when it sees it
non NULL, right?

> And we need to audit every ->mm != NULL check.

Yes I have started looking and some of them would indeed need to be
updated. get_task_mm users are easily fixable because we can do
mmget_not_zero. Some others check ->mm just to be sure to not touch
kernel threads.

Do you think this would be a way to go, though? We would have to special
case this because the mm_struct is quite large (~900B with my config) so
we would keep and pin it only for oom victims.

> > I mean I could have added oom_mm pointer into the task_struct and that

sorry, meant to say s@task_struct@signal_struct@

> > would guarantee that we always have a valid pointer when it is needed
> > but having yet another mm pointer there.
> 
> and add another mmdrop(oom_mm) into free_task() ?

Well, I would bind it to the signal_struct life cycle. See the diff
below.

> This would be bad, we
> do not want to delay __mmdrop()... Look, we even want to make the
> free_thread_info() synchronous, so that we could free ->stack before the
> final put_task_struct ;)

Hmm, it is true that the mm_struct is quite large but that would be used
only when oom killed victims and they should release some memory so the
temporaly pinned mm shouldn't cause too much trouble.

> But could you remind why do you want this right now? I mean, the ability
> to find ->mm with mm_count != 0 even if the user memory was already freed?

I would like to drop exit_oom_victim() from oom_reap_task because that
causes other issues. It acts as a last resort to make sure that no
task will block the oom killer from selecting a new task for ever (see
oom_scan_process_thread) right now. That means I need to convey "skip
this task" somehow. mm_struct is ideal for that but we are losing it
during exit_mm while __mmput can block for an unbounded amount of time
and actually never reach exit_oom_victim right after that. I would like
to make oom_scan_process_thread robust enough to not care about 
unreachable exit_oom_victim as far as we know that the memory was freed
or at least attempted to do so. This will make the logic much more
simpler because we no longer have to think about the oom victim and its
state anymore and only rely on the oom reaping.

Does that make sense to you?

I haven't tested this at all so please take it only as a dump of my
current thinking.
---
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5bc0457ee3a8..10f6f42921f9 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -70,7 +70,7 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return p->signal->oom_flag_origin;
 }
 
-extern void mark_oom_victim(struct task_struct *tsk);
+extern void mark_oom_victim(struct task_struct *tsk, struct mm_struct *mm);
 
 #ifdef CONFIG_MMU
 extern void wake_oom_reaper(struct task_struct *tsk);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6d81a1eb974a..befdcc1cde3c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -793,6 +793,8 @@ struct signal_struct {
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
+	struct mm_struct *oom_mm;	/* recorded mm when the thread group got
+					 * killed by the oom killer */
 
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
diff --git a/kernel/fork.c b/kernel/fork.c
index 452fc864f2f6..2bd3cc73d103 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -245,6 +245,8 @@ static inline void free_signal_struct(struct signal_struct *sig)
 {
 	taskstats_tgid_free(sig);
 	sched_autogroup_exit(sig);
+	if (sig->oom_mm)
+		mmdrop(sig->oom_mm);
 	kmem_cache_free(signal_cachep, sig);
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 40dfca3ef4bb..e9fe52d95a15 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1235,7 +1235,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
+		mark_oom_victim(current, current->mm);
 		wake_oom_reaper(current);
 		goto unlock;
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f744daa6..bf62c50f8c65 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -286,16 +286,17 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * Don't allow any other task to have access to the reserves unless
 	 * the task has MMF_OOM_REAPED because chances that it would release
 	 * any memory is quite low.
+	 * MMF_OOM_NOT_REAPABLE means that the oom_reaper backed off last time
+	 * so let it try again.
 	 */
 	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
-		struct task_struct *p = find_lock_task_mm(task);
+		struct mm_struct *mm = task->signal->oom_mm;
 		enum oom_scan_t ret = OOM_SCAN_ABORT;
 
-		if (p) {
-			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
-				ret = OOM_SCAN_CONTINUE;
-			task_unlock(p);
-		}
+		if (test_bit(MMF_OOM_REAPED, &mm->flags))
+			ret = OOM_SCAN_CONTINUE;
+		else if (test_bit(MMF_OOM_NOT_REAPABLE, &mm->flags))
+			ret = OOM_SCAN_SELECT;
 
 		return ret;
 	}
@@ -457,7 +458,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = NULL;
-	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
 	bool ret = true;
@@ -478,22 +478,10 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	mutex_lock(&oom_lock);
 
-	/*
-	 * Make sure we find the associated mm_struct even when the particular
-	 * thread has already terminated and cleared its mm.
-	 * We might have race with exit path so consider our work done if there
-	 * is no mm.
-	 */
-	p = find_lock_task_mm(tsk);
-	if (!p)
-		goto unlock_oom;
-	mm = p->mm;
-	atomic_inc(&mm->mm_count);
-	task_unlock(p);
-
+	mm = tsk->signal->oom_mm;
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
-		goto mm_drop;
+		goto unlock_oom;
 	}
 
 	/*
@@ -503,7 +491,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
-		goto mm_drop;
+		goto unlock_oom;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -551,8 +539,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
-mm_drop:
-	mmdrop(mm);
 unlock_oom:
 	mutex_unlock(&oom_lock);
 	return ret;
@@ -568,7 +554,7 @@ static void oom_reap_task(struct task_struct *tsk)
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts > MAX_OOM_REAP_RETRIES) {
-		struct task_struct *p;
+		struct mm_struct *mm;
 
 		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 				task_pid_nr(tsk), tsk->comm);
@@ -579,27 +565,17 @@ static void oom_reap_task(struct task_struct *tsk)
 		 * so hide the mm from the oom killer so that it can move on
 		 * to another task with a different mm struct.
 		 */
-		p = find_lock_task_mm(tsk);
-		if (p) {
-			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
-				pr_info("oom_reaper: giving up pid:%d (%s)\n",
-						task_pid_nr(tsk), tsk->comm);
-				set_bit(MMF_OOM_REAPED, &p->mm->flags);
-			}
-			task_unlock(p);
+		mm = tsk->signal->oom_mm;
+		if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &mm->flags)) {
+			pr_info("oom_reaper: giving up pid:%d (%s)\n",
+					task_pid_nr(tsk), tsk->comm);
+			set_bit(MMF_OOM_REAPED, &mm->flags);
 		}
 
 		debug_show_all_locks();
 	}
 
-	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore or it is not a good candidate
-	 * for the oom victim right now because it cannot release its memory
-	 * itself nor by the oom reaper.
-	 */
 	tsk->oom_reaper_list = NULL;
-	exit_oom_victim(tsk);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
@@ -661,17 +637,29 @@ subsys_initcall(oom_init)
 /**
  * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
+ * @mm: tsk's mm
  *
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
+ *
+ * mm has to be non-NULL. We are not checking it in this function because
+ * races might have caused tsk->mm becoming NULL.
  */
-void mark_oom_victim(struct task_struct *tsk)
+void mark_oom_victim(struct task_struct *tsk, struct mm_struct *mm)
 {
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+
 	atomic_inc(&tsk->signal->oom_victims);
+
+	/* oom_mm is bound to the signal struct life time */
+	if (!tsk->signal->oom_mm) {
+		atomic_inc(&mm->mm_count);
+		tsk->signal->oom_mm = mm;
+	}
+
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -828,7 +816,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	struct task_struct *victim = p;
 	struct task_struct *child;
 	struct task_struct *t;
-	struct mm_struct *mm;
+	struct mm_struct *mm = READ_ONCE(p->mm);
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
@@ -838,8 +826,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
-	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
+	if (mm && task_will_free_mem(p)) {
+		mark_oom_victim(p, mm);
 		wake_oom_reaper(p);
 		put_task_struct(p);
 		return;
@@ -898,7 +886,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	mark_oom_victim(victim);
+	mark_oom_victim(victim, mm);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -1019,7 +1007,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
 	if (current->mm && task_will_free_mem(current)) {
-		mark_oom_victim(current);
+		mark_oom_victim(current, current->mm);
 		wake_oom_reaper(current);
 		return true;
 	}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
