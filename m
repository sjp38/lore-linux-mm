Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id EB1CA6B0005
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:09:00 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id 4so116847651pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 20:09:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ss1si8536771pab.18.2016.03.20.20.08.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 20 Mar 2016 20:09:00 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Set TIF_MEMDIE on all OOM-killed threads.
Date: Mon, 21 Mar 2016 12:07:14 +0900
Message-Id: <1458529634-5951-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

If the page allocator was able to declare OOM, and that was an allocation
request which can call the OOM killer, the OOM killer is called. The OOM
killer selects an OOM victim thread and sets TIF_MEMDIE only on that
thread based on assumption that threads with TIF_MEMDIE can terminate
shortly.

As we already know it is possible that TIF_MEMDIE threads cannot make
forward progress because they are blocked at unkillable locks waiting for
somebody else doing !__GFP_FS allocation requests in order to perform fs
writeback or storage I/O operations.

Since we use the same watermark for GFP_NOIO / GFP_NOFS / GFP_KERNEL
allocation requests, allocation requests for fs writeback (GFP_NOFS)
and storage I/O (GFP_NOIO) stop making forward progress when TIF_MEMDIE
threads started waiting for GFP_NOFS or GFP_NOIO allocation requests.

If the OOM reaper clears TIF_MEMDIE and mark that thread group as
OOM-unkillable (or does equivalent things) in order to let the OOM killer
select next OOM victim, allocation requests for fs writeback or storage
I/O operations will eventually succeed.

But current OOM reaper patch happily disables further reaping because it
clears TIF_MEMDIE of only one thread and marks only one thread group as
OOM-unkillable when more than one thread groups are sharing the victim's
memory. This results in OOM-livelock situation. (Though, this behavior is
really helpful for reproducing almost OOM situation for testing purpose.)

If the OOM reaper marks all thread groups as OOM-unkillable, such
situation can be avoided. But, it is a bad assumption that the OOM reaper
will mark all thread groups as OOM-unkillable because there is no
guarantee that the OOM reaper is always woken up. We can fail to avoid
such situation unless we wake up the OOM reaper whenever TIF_MEMDIE is
set regardless of whether the memory used by the victim is reapable (i.e.
let the OOM reaper check whether it is safe to reap the victim's memory)
and clear TIF_MEMDIE and mark as OOM-unkillable (i.e. let the OOM reaper
act as a timer).

Rather, it is more simpler that we do not depend on the OOM reaper for
marking as OOM-unkillable. The purpose of marking as OOM-unkillable is
to prevent the OOM killer from selecting the same thread group forever.
We can mark as OOM-unkillable as of setting TIF_MEMDIE.

Therefore, this patch sets TIF_MEMDIE on all threads of all thread groups
that are killed by oom_kill_process() and marks all thread groups that are
killed by oom_kill_process() as OOM-unkillable when oom_kill_process() is
called.

This patch also solves SysRq-f problem that it continues selecting the
same thread group forever when the OOM reaper was not woken up (likely
because somebody sharing the victim's mm was marked as OOM-unkillable) or
failed to reap that memory (likely because somebody sharing the victim's
mm was holding mm->mmap_sem for write) and we have to use SysRq-f.
(Though, it is really useless for production systems to require SysRq-f.
I really want to allow making forward progress if the OOM reaper was not
woken up or failed to reap that memory.)

This patch also changes sysctl_oom_kill_allocating_task behavior (i.e. all
children will be killed by oom_kill_process() when children are unable to
terminate before current thread calls out_of_memory() again). But given
that the purpose of sysctl_oom_kill_allocating_task is to kill quickly,
it is not a good thing to continue spamming the kernel buffer with OOM
messages (including the list of OOM-killable processes) forever when
the killed child cannot terminate soon.

Setting TIF_MEMDIE on all threads of all thread groups that are killed
by the OOM killer unlikely increases possibility of depletion of memory
reserves because TIF_MEMDIE helps only if that thread is doing memory
allocation. Instead, compared to setting TIF_MEMDIE on randomly chosen one
thread with an assumption that that thread is doing memory allocation that
can call out_of_memory() shortly while it is possible that thread is doing
!__GFP_FS && !__GFP_NOFAIL allocation or is blocked by some unkillable
lock, this change can increase possibility of leaving memory allocating
loop by allowing any victim thread doing memory allocation to access
memory reserves when one of threads which is not selected by current
approach can make forward progress if TIF_MEMDIE is set.

If we set TIF_MEMDIE on all threads of all thread groups that are killed
by oom_kill_process(), we no longer need shortcuts that set TIF_MEMDIE on
only one thread when the victim has pending SIGKILL or is exiting. This
increases the possibility of successfully waking up the OOM reaper by not
hitting the shortcuts.

As a summary, this patch does the following things.

  (1) Set TIF_MEMDIE on all threads which should be terminated
      when oom_kill_process() was called.

  (2) Update "struct signal_struct"->oom_score_adj to OOM_SCORE_ADJ_MIN
      when oom_kill_process() was called.

  (3) Call wake_oom_reaper() for all threads which should be terminated
      when oom_kill_process() was called, for oom_reap_task() is
      responsible for clearing TIF_MEMDIE from all threads after reaping
      the victim's memory completed.

  (4) Allow SysRq-f to select a different thread group when
      oom_reap_task() was not called or failed to reap the victim's
      memory.

  (5) Eliminate shortcuts which set TIF_MEMDIE on only one thread.

If we add a flag to "struct signal_struct" for remembering whether
this thread group was selected for OOM victim, we can stop playing with
"struct signal_struct"->oom_score_adj value. Also, if we add a flag to
"struct signal_struct" or "struct mm_struct" for remembering whether
oom_reap_task() completed reaping this memory, we can stop clearing
TIF_MEMDIE from remote threads. But these changes are outside of this
patch's scope.

Maybe we should make sure that sysctl_oom_kill_allocating_task case
selects the current thread and oom_task_origin() case selects that
thread. But these changes are outside of this patch's scope.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>

---
 include/linux/oom.h | 11 -------
 mm/memcontrol.c     | 10 ------
 mm/oom_kill.c       | 93 ++++++++++++++++++++++-------------------------------
 3 files changed, 38 insertions(+), 76 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 45993b8..9e2b524 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -102,17 +102,6 @@ extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
-static inline bool task_will_free_mem(struct task_struct *task)
-{
-	/*
-	 * A coredumping process may sleep for an extended period in exit_mm(),
-	 * so the oom killer cannot assume that the process will promptly exit
-	 * and release memory.
-	 */
-	return (task->flags & PF_EXITING) &&
-		!(task->signal->flags & SIGNAL_GROUP_COREDUMP);
-}
-
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 36db05f..c8433a8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1249,16 +1249,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 	mutex_lock(&oom_lock);
 
-	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		goto unlock;
-	}
-
 	check_panic_on_oom(&oc, CONSTRAINT_MEMCG, memcg);
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 23b8b06..bc6874b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -428,28 +428,17 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	struct mm_struct *mm;
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
+	task_lock(tsk);
+	mm = tsk->mm;
+	if (!mm || !atomic_inc_not_zero(&mm->mm_users)) {
+		task_unlock(tsk);
 		return true;
 	}
-
-	task_unlock(p);
+	task_unlock(tsk);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
@@ -493,7 +482,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * improvements. This also means that selecting this task doesn't
 	 * make any sense.
 	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
 	exit_oom_victim(tsk);
 out:
 	mmput(mm);
@@ -679,19 +667,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap;
 
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		task_unlock(p);
-		put_task_struct(p);
-		return;
-	}
-	task_unlock(p);
-
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p, memcg);
 
@@ -743,13 +718,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	/* Make sure we do not try to oom reap the mm multiple times */
 	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
 
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
@@ -770,8 +738,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	for_each_process(p) {
 		if (!process_shares_mm(p, mm))
 			continue;
-		if (same_thread_group(p, victim))
-			continue;
 		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
 		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
 			/*
@@ -782,12 +748,43 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			can_oom_reap = false;
 			continue;
 		}
+		/*
+		 * We should send SIGKILL before setting TIF_MEMDIE in order to
+		 * prevent the OOM victim from depleting the memory reserves
+		 * from the user space under its control.
+		 */
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		for_each_thread(p, t) {
+			task_lock(t);
+			if (t->mm)
+				mark_oom_victim(t);
+			task_unlock(t);
+		}
+		/*
+		 * Mark this process as no longer OOM-killable in order to
+		 * prevent the OOM killer (including SysRq-f) from selecting
+		 * the same process forever.
+		 */
+		task_lock(p);
+		p->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+		task_unlock(p);
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
+	/*
+	 * If we can call the OOM reaper, queue all TIF_MEMDIE threads because
+	 * the OOM reaper is responsible for clearing TIF_MEMDIE in order to
+	 * allow the OOM killer to select next victim if the OOM situation
+	 * still remains after reaping the mm completed.
+	 */
+	if (can_oom_reap) {
+		rcu_read_lock();
+		for_each_process_thread(p, t) {
+			if (t->mm == mm)
+				wake_oom_reaper(t);
+		}
+		rcu_read_unlock();
+	}
 
 	mmdrop(mm);
 	put_task_struct(victim);
@@ -859,20 +856,6 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 
 	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 *
-	 * But don't select if current has already released its mm and cleared
-	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
-	 */
-	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
-		mark_oom_victim(current);
-		return true;
-	}
-
-	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
