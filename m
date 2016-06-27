Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0870A6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 06:36:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a66so68902823wme.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 03:36:12 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id md4si25490272wjb.246.2016.06.27.03.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 03:36:11 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 187so23387922wmz.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 03:36:11 -0700 (PDT)
Date: Mon, 27 Jun 2016 12:36:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160627103609.GE31799@dhcp22.suse.cz>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160627092326.GD31799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

Oleg,

On Mon 27-06-16 11:23:26, Michal Hocko wrote:
[...]
> I was thinking about this some more and I think that a better approach
> would be to not forget the mm during the exit. The whole find_lock_task_mm
> sounds like a workaround than a real solution. I am trying to understand
> why do we really have to reset the current->mm to NULL during the exit.
> If we cannot change this then we can at least keep a stable mm
> somewhere. The code would get so much easier that way.

I am trying to wrap my head around active_mm semantic. It is not
reset on the exit and it should refer the to same mm pointer for regular
processes AFAICS. [1] mentions that even regular processes can borrow an
anonymous address space. It used to be bdflush but this doesn't seem to
be the case anymore AFAICS.

Can we (ab)use it for places where we know we are dealing with OOM
victims (aka regular processes) and replace the find_task_lock_mm by
active_mm? I mean something like (not even compile tested so most
probably incomplete as well) the below?

We would have to drop the last reference to the mm later but that
shouldn't pin much memory. If this works as intended then we can
reliably use per-mm heuristics to break out of the oom lockup.

[1] https://www.kernel.org/doc/Documentation/vm/active_mm.txt
---
diff --git a/kernel/fork.c b/kernel/fork.c
index 452fc864f2f6..6198371573c7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -237,6 +237,8 @@ void free_task(struct task_struct *tsk)
 	ftrace_graph_exit_task(tsk);
 	put_seccomp_filter(tsk);
 	arch_release_task_struct(tsk);
+	if (tsk->active_mm)
+		mmdrop(tsk->active_mm);
 	free_task_struct(tsk);
 }
 EXPORT_SYMBOL(free_task);
@@ -1022,6 +1024,8 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 good_mm:
 	tsk->mm = mm;
 	tsk->active_mm = mm;
+	/* to be release in the final task_put */
+	atomic_inc(&mm->mm_count);
 	return 0;
 
 fail_nomem:
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f744daa6..18282423e7cb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -166,13 +166,14 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 {
 	long points;
 	long adj;
+	struct mm_struct *mm;
 
 	if (oom_unkillable_task(p, memcg, nodemask))
 		return 0;
 
+	task_lock(p);
 	p = find_lock_task_mm(p);
-	if (!p)
-		return 0;
+	mm = p->active_mm;
 
 	/*
 	 * Do not even consider tasks which are explicitly marked oom
@@ -181,7 +182,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 */
 	adj = (long)p->signal->oom_score_adj;
 	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_REAPED, &p->mm->flags) ||
+			test_bit(MMF_OOM_REAPED, &mm->flags) ||
 			in_vfork(p)) {
 		task_unlock(p);
 		return 0;
@@ -191,8 +192,8 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		atomic_long_read(&p->mm->nr_ptes) + mm_nr_pmds(p->mm);
+	points = get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS) +
+		atomic_long_read(&mm->nr_ptes) + mm_nr_pmds(mm);
 	task_unlock(p);
 
 	/*
@@ -288,14 +289,12 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * any memory is quite low.
 	 */
 	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
-		struct task_struct *p = find_lock_task_mm(task);
 		enum oom_scan_t ret = OOM_SCAN_ABORT;
 
-		if (p) {
-			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
-				ret = OOM_SCAN_CONTINUE;
-			task_unlock(p);
-		}
+		task_lock(task);
+		if (test_bit(MMF_OOM_REAPED, &task->active_mm->flags))
+			ret = OOM_SCAN_CONTINUE;
+		task_unlock(task);
 
 		return ret;
 	}
@@ -367,32 +366,25 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 {
 	struct task_struct *p;
-	struct task_struct *task;
 
 	pr_info("[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name\n");
 	rcu_read_lock();
 	for_each_process(p) {
+		struct mm_struct *mm;
 		if (oom_unkillable_task(p, memcg, nodemask))
 			continue;
 
-		task = find_lock_task_mm(p);
-		if (!task) {
-			/*
-			 * This is a kthread or all of p's threads have already
-			 * detached their mm's.  There's no need to report
-			 * them; they can't be oom killed anyway.
-			 */
-			continue;
-		}
+		task_lock(p);
+		mm = p->mm;
 
 		pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %8lu         %5hd %s\n",
-			task->pid, from_kuid(&init_user_ns, task_uid(task)),
-			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-			atomic_long_read(&task->mm->nr_ptes),
-			mm_nr_pmds(task->mm),
-			get_mm_counter(task->mm, MM_SWAPENTS),
-			task->signal->oom_score_adj, task->comm);
-		task_unlock(task);
+			p->pid, from_kuid(&init_user_ns, task_uid(p)),
+			p->tgid, mm->total_vm, get_mm_rss(mm),
+			atomic_long_read(&mm->nr_ptes),
+			mm_nr_pmds(mm),
+			get_mm_counter(mm, MM_SWAPENTS),
+			p->signal->oom_score_adj, p->comm);
+		task_unlock(p);
 	}
 	rcu_read_unlock();
 }
@@ -457,7 +449,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = NULL;
-	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
 	bool ret = true;
@@ -484,12 +475,10 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * We might have race with exit path so consider our work done if there
 	 * is no mm.
 	 */
-	p = find_lock_task_mm(tsk);
-	if (!p)
-		goto unlock_oom;
-	mm = p->mm;
+	task_lock(tsk);
+	mm = tsk->active_mm;
 	atomic_inc(&mm->mm_count);
-	task_unlock(p);
+	task_unlock(tsk);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
@@ -553,7 +542,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	mmput_async(mm);
 mm_drop:
 	mmdrop(mm);
-unlock_oom:
 	mutex_unlock(&oom_lock);
 	return ret;
 }
@@ -579,15 +567,13 @@ static void oom_reap_task(struct task_struct *tsk)
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
+		task_lock(tsk);
+		if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &tsk->active_mm->flags)) {
+			pr_info("oom_reaper: giving up pid:%d (%s)\n",
+					task_pid_nr(tsk), tsk->comm);
+			set_bit(MMF_OOM_REAPED, &tsk->active_mm->flags);
 		}
+		task_unlock(p);
 
 		debug_show_all_locks();
 	}
@@ -879,18 +865,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	read_unlock(&tasklist_lock);
 
-	p = find_lock_task_mm(victim);
-	if (!p) {
-		put_task_struct(victim);
-		return;
-	} else if (victim != p) {
-		get_task_struct(p);
-		put_task_struct(victim);
-		victim = p;
-	}
-
+	task_lock(victim);
 	/* Get a reference to safely compare mm after task_unlock(victim) */
-	mm = victim->mm;
+	mm = victim->active_mm;
 	atomic_inc(&mm->mm_count);
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
