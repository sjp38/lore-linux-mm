Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A51F828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 07:44:14 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u201so340501518oie.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 04:44:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v127si1312260oia.69.2016.07.06.04.44.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Jul 2016 04:44:13 -0700 (PDT)
Subject: Re: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607042150.CIB00512.FSOtMHLOOVFFQJ@I-love.SAKURA.ne.jp>
	<20160704182549.GB8396@redhat.com>
	<201607051943.GHB86443.SOOFFFHJVLMQOt@I-love.SAKURA.ne.jp>
	<20160705205231.GA25340@redhat.com>
	<20160706085313.GA29921@redhat.com>
In-Reply-To: <20160706085313.GA29921@redhat.com>
Message-Id: <201607062043.FEC86485.JFFVLtFOQOSHMO@I-love.SAKURA.ne.jp>
Date: Wed, 6 Jul 2016 20:43:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

Oleg Nesterov wrote:
> On 07/05, Oleg Nesterov wrote:
> >
> > > I don't think so. Setting MMF_OOM_REAPED indicates that memory used by that
> > > mm is already reclaimed by the OOM reaper or by __mmput().
> >
> > Sure, this is clear,
> >
> > > mm->mm_users == 0
> > > alone does not mean memory used by that mm is already reclaimed.
> >   ^^^^^
> >
> > Of course! I meant that oom_has_pending_mm() can check _both_ mm_users and
> > MMF_OOM_REAPED and then we do not need to set MMF_OOM_REAPED in exit_mm() path.
> >
> > No?
> 
> OK, perhaps you meant that mm_users == 0 can't help because __mmput() can block
> after that and thus we should not assume this memory is already reclaimed...

Right.

> 
> So yes this probably needs more thinking. perhaps we can check mm->vma == NULL.
> 

Below patch is an example of removing exit_oom_mm() from __mmput().

> >
> > > Making exit_oom_mm() a no-op for CONFIG_MMU=y would be OK,
> >
> > Yes. Not only because this can simplify other changes. I do believe that the less
> > "oom" hooks we have the better, even if this needs some complications in oom_kill.c.
> >
> > For example, this series removes the extra try_to_freeze_tasks() from freeze_processes()
> > (which is in fact the "oom" hook) and personally I do like this fact.
> >
> > And. Of course I am not sure this is possible, but to me it would be very nice
> > to kill oom_reaper_list altogether if CONFIG_MMU=n.

If CONFIG_NUMA and CONFIG_CGROUP depend on CONFIG_MMU, oom_has_pending_mm() for
CONFIG_MMU=n will become as simple as

	bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
	{
		return atomic_read(&oom_victims);
	}

and we can remove oom_mm_list altogether. But it seems to me that CONFIG_CGROUP=y
with CONFIG_MMU=n is possible. I think calling exit_oom_mm() from __mmput() in
order to clear references immediately is better for CONFIG_MMU=n case.
(Or Michal's signal->oom_mm approach is better?)


 include/linux/oom.h |   3 +-
 kernel/fork.c       |   1 -
 mm/memcontrol.c     |   2 +-
 mm/oom_kill.c       | 117 ++++++++++++++++++++--------------------------------
 4 files changed, 47 insertions(+), 76 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 1a212c1..72a21a4 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -69,7 +69,7 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return p->signal->oom_flag_origin;
 }
 
-extern void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc);
+extern void mark_oom_victim(struct task_struct *tsk);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
@@ -82,7 +82,6 @@ extern void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 extern void check_panic_on_oom(struct oom_control *oc,
 			       enum oom_constraint constraint);
 
-extern void exit_oom_mm(struct mm_struct *mm);
 extern bool oom_has_pending_mm(struct mem_cgroup *memcg,
 			       const nodemask_t *nodemask);
 extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
diff --git a/kernel/fork.c b/kernel/fork.c
index b870dbc..7926993 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -722,7 +722,6 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
-	exit_oom_mm(mm);
 	mmdrop(mm);
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9acc840..6afe1c5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1235,7 +1235,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current, &oc);
+		mark_oom_victim(current);
 		goto unlock;
 	}
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bbd3138..f2b5ec2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -292,54 +292,40 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 }
 
 static LIST_HEAD(oom_mm_list);
-static DEFINE_SPINLOCK(oom_mm_lock);
 
-static inline void __exit_oom_mm(struct mm_struct *mm)
+static void exit_oom_mm(struct mm_struct *mm)
 {
-	struct task_struct *tsk;
-
-	spin_lock(&oom_mm_lock);
+	/* Drop references taken by mark_oom_victim() */
 	list_del(&mm->oom_mm.list);
-	tsk = mm->oom_mm.victim;
+	put_task_struct(mm->oom_mm.victim);
 	mm->oom_mm.victim = NULL;
-	spin_unlock(&oom_mm_lock);
-	/* Drop references taken by mark_oom_victim() */
-	put_task_struct(tsk);
 	mmdrop(mm);
 }
 
-void exit_oom_mm(struct mm_struct *mm)
-{
-	/* Nothing to do unless mark_oom_victim() was called with this mm. */
-	if (!mm->oom_mm.victim)
-		return;
-#ifdef CONFIG_MMU
-	/*
-	 * OOM reaper will eventually call __exit_oom_mm().
-	 * Allow oom_has_pending_mm() to ignore this mm.
-	 */
-	set_bit(MMF_OOM_REAPED, &mm->flags);
-#else
-	__exit_oom_mm(mm);
-#endif
-}
-
 bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 {
 	struct mm_struct *mm;
-	bool ret = false;
+	struct mm_struct *tmp;
 
-	spin_lock(&oom_mm_lock);
-	list_for_each_entry(mm, &oom_mm_list, oom_mm.list) {
-		if (oom_unkillable_task(mm->oom_mm.victim, memcg, nodemask))
+	list_for_each_entry_safe(mm, tmp, &oom_mm_list, oom_mm.list) {
+		/* Was set_mm_exe_file(mm, NULL) called from __mmput(mm) ? */
+		if (!rcu_dereference_raw(mm->exe_file)) {
+#ifndef CONFIG_MMU
+			/*
+			 * Note that a reference on mm and mm->oom_mm.victim
+			 * will remain until this function is called for the
+			 * next time after set_mm_exe_file(mm, NULL) was
+			 * called, for OOM reaper callback is not available.
+			 */
+			exit_oom_mm(mm);
+#endif
 			continue;
-		if (test_bit(MMF_OOM_REAPED, &mm->flags))
+		}
+		if (oom_unkillable_task(mm->oom_mm.victim, memcg, nodemask))
 			continue;
-		ret = true;
-		break;
+		return true;
 	}
-	spin_unlock(&oom_mm_lock);
-	return ret;
+	return false;
 }
 
 /*
@@ -550,16 +536,12 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 static void oom_reap_task(struct mm_struct *mm, struct task_struct *tsk)
 {
 	int attempts = 0;
-	bool ret;
 
 	/*
-	 * Check MMF_OOM_REAPED after holding oom_lock because
-	 * oom_kill_process() might find this mm pinned.
+	 * Check MMF_OOM_REAPED in case oom_kill_process() found this mm
+	 * pinned.
 	 */
-	mutex_lock(&oom_lock);
-	ret = test_bit(MMF_OOM_REAPED, &mm->flags);
-	mutex_unlock(&oom_lock);
-	if (ret)
+	if (test_bit(MMF_OOM_REAPED, &mm->flags))
 		return;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
@@ -589,8 +571,8 @@ static void oom_reap_task(struct mm_struct *mm, struct task_struct *tsk)
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct mm_struct *mm = NULL;
-		struct task_struct *victim = NULL;
+		struct mm_struct *mm;
+		struct task_struct *victim;
 
 		wait_event_freezable(oom_reaper_wait,
 				     !list_empty(&oom_mm_list));
@@ -599,19 +581,17 @@ static int oom_reaper(void *unused)
 		 * oom_reap_task() raced with mark_oom_victim() by
 		 * other threads sharing this mm.
 		 */
-		spin_lock(&oom_mm_lock);
-		if (!list_empty(&oom_mm_list)) {
-			mm = list_first_entry(&oom_mm_list, struct mm_struct,
-					      oom_mm.list);
-			victim = mm->oom_mm.victim;
-			get_task_struct(victim);
-		}
-		spin_unlock(&oom_mm_lock);
-		if (!mm)
-			continue;
+		mutex_lock(&oom_lock);
+		mm = list_first_entry(&oom_mm_list, struct mm_struct,
+				      oom_mm.list);
+		victim = mm->oom_mm.victim;
+		get_task_struct(victim);
+		mutex_unlock(&oom_lock);
 		oom_reap_task(mm, victim);
 		put_task_struct(victim);
-		__exit_oom_mm(mm);
+		mutex_lock(&oom_lock);
+		exit_oom_mm(mm);
+		mutex_unlock(&oom_lock);
 	}
 
 	return 0;
@@ -630,39 +610,32 @@ subsys_initcall(oom_init)
 /**
  * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
- * @oc: oom_control
  *
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
+void mark_oom_victim(struct task_struct *tsk)
 {
 	struct mm_struct *mm = tsk->mm;
-	struct task_struct *old_tsk;
+	struct task_struct *old_tsk = mm->oom_mm.victim;
 
 	WARN_ON(oom_killer_disabled);
-	/* OOM killer might race with memcg OOM */
-	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
+
 	/*
 	 * Since mark_oom_victim() is called from multiple threads,
 	 * connect this mm to oom_mm_list only if not yet connected.
-	 *
-	 * Since mark_oom_victim() is called with a stable mm (i.e.
-	 * mm->mm_users > 0), __exit_oom_mm() from __mmput() can't be called
-	 * before we add this mm to the list.
 	 */
-	spin_lock(&oom_mm_lock);
-	old_tsk = mm->oom_mm.victim;
 	get_task_struct(tsk);
 	mm->oom_mm.victim = tsk;
 	if (!old_tsk) {
 		atomic_inc(&mm->mm_count);
 		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
-	}
-	spin_unlock(&oom_mm_lock);
-	if (old_tsk)
+	} else
 		put_task_struct(old_tsk);
+
+	/* OOM killer might race with memcg OOM */
+	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
+		return;
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -820,7 +793,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 */
 	task_lock(p);
 	if (task_will_free_mem(p)) {
-		mark_oom_victim(p, oc);
+		mark_oom_victim(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -880,7 +853,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	mark_oom_victim(victim, oc);
+	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -994,7 +967,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current, oc);
+		mark_oom_victim(current);
 		return true;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
