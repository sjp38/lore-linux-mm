Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 345A96B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 07:15:35 -0400 (EDT)
Received: by mail-io0-f181.google.com with SMTP id n190so19610437iof.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 04:15:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l39si1399612iod.158.2016.03.15.04.15.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Mar 2016 04:15:33 -0700 (PDT)
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-6-git-send-email-mhocko@kernel.org>
	<20160217094855.GC29196@dhcp22.suse.cz>
	<20160219183419.GA30059@dhcp22.suse.cz>
	<201602201132.EFG90182.FOVtSOJHFOLFQM@I-love.SAKURA.ne.jp>
	<20160222094105.GD17938@dhcp22.suse.cz>
In-Reply-To: <20160222094105.GD17938@dhcp22.suse.cz>
Message-Id: <201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp>
Date: Tue, 15 Mar 2016 20:15:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org

I was trying to test side effect of "oom, oom_reaper: disable oom_reaper for
oom_kill_allocating_task" compared to "oom: clear TIF_MEMDIE after oom_reaper
managed to unmap the address space", and I consider that both patches are
doing wrong things.



Regarding the former patch, setting MMF_OOM_KILLED before checking whether
that mm is reapable is over-killing the OOM reaper. The intent of that patch
was to avoid oom_reaper_list list corruption. We can avoid list corruption
by doing like below.

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 23b8b06..0464727 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -543,7 +543,7 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th)
+	if (!oom_reaper_th || tsk->oom_reaper_list)
 		return;
 
 	get_task_struct(tsk);
@@ -677,7 +677,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap;
+	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -740,9 +740,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	mm = victim->mm;
 	atomic_inc(&mm->mm_count);
 
-	/* Make sure we do not try to oom reap the mm multiple times */
-	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
-
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
 	 * the OOM victim from depleting the memory reserves from the user
----------

Two thread groups sharing the same mm can disable the OOM reaper
when all threads in the former thread group (which will be chosen
as an OOM victim by the OOM killer) can immediately call exit_mm()
via do_exit() (e.g. simply sleeping in killable state when the OOM
killer chooses that thread group) and some thread in the latter thread
group is contended on unkillable locks (e.g. inode mutex), due to

	p = find_lock_task_mm(tsk);
	if (!p)
		return true;

in __oom_reap_task() and

	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);

in oom_kill_process(). The OOM reaper is woken up in order to reap
the former thread group's memory, but it does nothing on the latter
thread group's memory because the former thread group can clear its mm
before the OOM reaper locks its mm. Even if subsequent out_of_memory()
call chose the latter thread group, the OOM reaper will not be woken up.
No memory is reaped. We need to queue all thread groups sharing that
memory if that memory should be reaped.

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 23b8b06..93867d2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -543,7 +543,7 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th)
+	if (!oom_reaper_th || tsk->oom_reaper_list)
 		return;
 
 	get_task_struct(tsk);
@@ -677,7 +677,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap;
+	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -740,9 +740,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	mm = victim->mm;
 	atomic_inc(&mm->mm_count);
 
-	/* Make sure we do not try to oom reap the mm multiple times */
-	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
-
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
 	 * the OOM victim from depleting the memory reserves from the user
@@ -757,6 +754,25 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
 	task_unlock(victim);
 
+	rcu_read_lock();
+	for_each_process(p) {
+		if (!process_shares_mm(p, mm))
+			continue;
+		if (same_thread_group(p, victim))
+			continue;
+		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+			/*
+			 * We cannot use oom_reaper for the mm shared by this
+			 * process because it wouldn't get killed and so the
+			 * memory might be still used.
+			 */
+			can_oom_reap = false;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
 	/*
 	 * Kill all user processes sharing victim->mm in other thread groups, if
 	 * any.  They don't get access to memory reserves, though, to avoid
@@ -773,16 +789,11 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		if (same_thread_group(p, victim))
 			continue;
 		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-			/*
-			 * We cannot use oom_reaper for the mm shared by this
-			 * process because it wouldn't get killed and so the
-			 * memory might be still used.
-			 */
-			can_oom_reap = false;
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			continue;
-		}
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		if (can_oom_reap)
+			wake_oom_reaper(p);
 	}
 	rcu_read_unlock();
 
----------

Michal Hocko wrote:
> I find it much easier to to simply skip over tasks with MMF_OOM_KILLED
> when already selecting a victim. We won't need oom_score_adj games at
> all. This needs a deeper evaluation though. I didn't get to it yet,
> but the point of having MMF flag which is not oom_reaper specific
> was to have it reusable in other contexts as well.

Using MMF_OOM_KILLED for excluding from OOM victim candidates is also wrong.
It gives immunity against the OOM reaper when some thread group sharing the
OOM victim's mm switches its oom_score_adj value depending on its current
role. For example, when its role is to follow up OOM killed thread group
(as if init process that respawns applications), it would set oom_score_adj
to OOM_SCORE_ADJ_MIN. It can update oom_score_adj to !OOM_SCORE_ADJ_MIN when
its role changes. Well, what is the to-be-OOM-killed thread group's role?
I don't know. Such thread group might be living as a canary for detecting
OOM condition. Such thread group might be doing memory intensive operations
using pipe. What is important is that the kernel should not make assumptions
on what the userspace programs will do.

Like I wrote at http://lkml.kernel.org/r/201602291026.CJB64059.FtSLOOFFJHMOQV@I-love.SAKURA.ne.jp ,
we can correct sysctl_oom_kill_allocating_task = 1 to literally kill
the allocating task rather than needlessly disable the OOM reaper using
MMF_OOM_KILLED.



Regarding the latter patch (assuming that the former patch is reverted),
updating oom_score_adj to OOM_SCORE_ADJ_MIN only when reaping succeeded
is confusing the OOM killer.

Two thread groups sharing the same mm can disable the OOM reaper when
some thread's memory in the former thread group is reaped and the latter
thread group is contended on unkillable locks (e.g. inode mutex), due to

	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;

in __oom_reap_task(). The OOM reaper is woken up and reaps the former
thread group's memory, but it does not update the latter thread group's
oom_score_adj to OOM_SCORE_ADJ_MIN. Even if subsequent out_of_memory()
call chose the latter thread group, the OOM reaper will not be woken up
due to p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN check. Therefore, no
more memory is reaped. We should update all thread groups' oom_score_adj
sharing that memory to OOM_SCORE_ADJ_MIN as of calling wake_oom_reaper()
or as of leaving oom_reap_task().

If we queue all thread groups sharing that memory (as suggested above),
we will be able to update all thread groups' oom_score_adj sharing that
memory at oom_reap_task() regardless of whether the OOM reaper succeeded
to reap that memory. But I prefer updating oom_score_adj as of calling
wake_oom_reaper() as shown below.

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 23b8b06..fc389b8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -493,7 +493,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * improvements. This also means that selecting this task doesn't
 	 * make any sense.
 	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
 	exit_oom_victim(tsk);
 out:
 	mmput(mm);
@@ -543,7 +542,7 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th)
+	if (!oom_reaper_th || tsk->oom_reaper_list)
 		return;
 
 	get_task_struct(tsk);
@@ -677,7 +676,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap;
+	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -740,9 +739,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	mm = victim->mm;
 	atomic_inc(&mm->mm_count);
 
-	/* Make sure we do not try to oom reap the mm multiple times */
-	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
-
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
 	 * the OOM victim from depleting the memory reserves from the user
@@ -756,16 +752,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
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
 	rcu_read_lock();
 	for_each_process(p) {
 		if (!process_shares_mm(p, mm))
@@ -780,17 +768,70 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			 * memory might be still used.
 			 */
 			can_oom_reap = false;
-			continue;
+			break;
 		}
-		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
+	/*
+	 * Kill all OOM-killable user threads sharing victim->mm.
+	 *
+	 * This mitigates mm->mmap_sem livelock caused by one thread being
+	 * unable to release its mm due to being blocked at
+	 * down_read(&mm->mmap_sem) in exit_mm() while another thread is doing
+	 * __GFP_FS allocation with mm->mmap_sem held for write.
+	 *
+	 * They all get access to memory reserves.
+	 *
+	 * This prevents the OOM killer from choosing next OOM victim as soon
+	 * as current victim thread released its mm. This also mitigates kernel
+	 * log buffer being spammed by OOM killer messages due to choosing next
+	 * OOM victim thread sharing the current OOM victim's memory.
+	 *
+	 * This mitigates the problem that a thread doing __GFP_FS allocation
+	 * with mmap_sem held for write cannot call out_of_memory() for
+	 * unpredictable duration due to oom_lock contention and/or scheduling
+	 * priority, for the OOM reaper will not wait forever until such thread
+	 * leaves memory allocating loop by calling out_of_memory(). This also
+	 * mitigates the problem that a thread doing !__GFP_FS && !__GFP_NOFAIL
+	 * allocation cannot leave memory allocating loop because it cannot
+	 * call out_of_memory() even after it is killed.
+	 *
+	 * They are marked as OOM-unkillable. While it would be possible that
+	 * somebody marks them as OOM-killable again, it does not matter much
+	 * because they are already killed (and scheduled for OOM reap if
+	 * possible).
+	 *
+	 * This mitigates the problem that SysRq-f continues choosing the same
+	 * process. We still need SysRq-f because it is possible that victim
+	 * threads are blocked at unkillable locks inside memory allocating
+	 * loop (e.g. fs writeback from direct reclaim) even after they got
+	 * SIGKILL and TIF_MEMDIE.
+	 */
+	rcu_read_lock();
+	for_each_process(p) {
+		if (!process_shares_mm(p, mm))
+			continue;
+		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			continue;
+		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		for_each_thread(p, t) {
+			task_lock(t);
+			if (t->mm) {
+				mark_oom_victim(t);
+				if (can_oom_reap)
+					wake_oom_reaper(t);
+			}
+			task_unlock(t);
+		}
+		task_lock(p);
+		p->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+		task_unlock(p);
+	}
+	rcu_read_unlock();
 
 	mmdrop(mm);
-	put_task_struct(victim);
 }
 #undef K
 
----------

Like I wrote at http://lkml.kernel.org/r/201602182021.EEH86916.JOLtFFVHOOMQFS@I-love.SAKURA.ne.jp ,
TIF_MEMDIE heuristics are per a task_struct basis but OOM-kill operation
is per a signal_struct basis or per a mm_struct basis. If you don't like
oom_score_adj games, I'm fine with per a signal_struct flag (like
OOM_FLAG_ORIGIN) that acts as adj == OOM_SCORE_ADJ_MIN test in oom_badness().
I don't think over-killing the OOM reaper by using per a mm_struct flag (i.e.
MMF_OOM_KILLED) is a good approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
