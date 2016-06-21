Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2A0828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 11:32:47 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id at7so34647872obd.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 08:32:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f13si398436otd.224.2016.06.21.08.32.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 08:32:45 -0700 (PDT)
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160613111943.GB6518@dhcp22.suse.cz>
	<20160621083154.GA30848@dhcp22.suse.cz>
	<201606212003.FFB35429.QtMOJFFFOLSHVO@I-love.SAKURA.ne.jp>
	<20160621114643.GE30848@dhcp22.suse.cz>
	<20160621132736.GF30848@dhcp22.suse.cz>
In-Reply-To: <20160621132736.GF30848@dhcp22.suse.cz>
Message-Id: <201606220032.EGD09344.VOSQOMFJOLHtFF@I-love.SAKURA.ne.jp>
Date: Wed, 22 Jun 2016 00:32:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 21-06-16 13:46:43, Michal Hocko wrote:
> > On Tue 21-06-16 20:03:17, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Mon 13-06-16 13:19:43, Michal Hocko wrote:
> > > > [...]
> > > > > I am trying to remember why we are disabling oom killer before kernel
> > > > > threads are frozen but not really sure about that right away.
> > > > 
> > > > OK, I guess I remember now. Say that a task would depend on a freezable
> > > > kernel thread to get to do_exit (stuck in wait_event etc...). We would
> > > > simply get stuck in oom_killer_disable for ever. So we need to address
> > > > it a different way.
> > > > 
> > > > One way would be what you are proposing but I guess it would be more
> > > > systematic to never call exit_oom_victim on a remote task.  After [1] we
> > > > have a solid foundation to rely only on MMF_REAPED even when TIF_MEMDIE
> > > > is set. It is more code than your patch so I can see a reason to go with
> > > > yours if the following one seems too large or ugly.
> > > > 
> > > > [1] http://lkml.kernel.org/r/1466426628-15074-1-git-send-email-mhocko@kernel.org
> > > > 
> > > > What do you think about the following?
> > > 
> > > I'm OK with not clearing TIF_MEMDIE from a remote task. But this patch is racy.
> > > 
> > > > @@ -567,40 +612,23 @@ static void oom_reap_task(struct task_struct *tsk)
> > > >  	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk))
> > > >  		schedule_timeout_idle(HZ/10);
> > > >  
> > > > -	if (attempts > MAX_OOM_REAP_RETRIES) {
> > > > -		struct task_struct *p;
> > > > +	tsk->oom_reaper_list = NULL;
> > > >  
> > > > +	if (attempts > MAX_OOM_REAP_RETRIES) {
> > > 
> > > attempts > MAX_OOM_REAP_RETRIES would mean that down_read_trylock()
> > > continuously failed. But it does not guarantee that the offending task
> > > shall not call up_write(&mm->mmap_sem) and arrives at mmput() from exit_mm()
> > > (as well as other threads which are blocked at down_read(&mm->mmap_sem) in
> > > exit_mm() by the offending task arrive at mmput() from exit_mm()) when the
> > > OOM reaper was preempted at this point.
> > > 
> > > Therefore, find_lock_task_mm() in requeue_oom_victim() could return NULL and
> > > the OOM reaper could fail to set MMF_OOM_REAPED (and find_lock_task_mm() in
> > > oom_scan_process_thread() could return NULL and the OOM killer could fail to
> > > select next OOM victim as well) when __mmput() got stuck.
> > 
> > Fair enough. As this would break no-lockup requirement we cannot go that
> > way. Let me think about it more.
> 
> Hmm, what about the following instead. It is rather a workaround than a
> full flaged fix but it seems much more easier and shouldn't introduce
> new issues.

Yes, I think that will work. But I think below patch (marking signal_struct
to ignore TIF_MEMDIE instead of clearing TIF_MEMDIE from task_struct) on top of
current linux.git will implement no-lockup requirement. No race is possible unlike
"[PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init".

 include/linux/oom.h   |  1 +
 include/linux/sched.h |  2 ++
 mm/memcontrol.c       |  3 ++-
 mm/oom_kill.c         | 60 ++++++++++++++++++++++++++++++---------------------
 4 files changed, 40 insertions(+), 26 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8346952..f072c6c 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -69,6 +69,7 @@ static inline bool oom_task_origin(const struct task_struct *p)
 
 extern void mark_oom_victim(struct task_struct *tsk);
 
+extern bool task_is_reapable(struct task_struct *tsk);
 #ifdef CONFIG_MMU
 extern void try_oom_reaper(struct task_struct *tsk);
 #else
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6e42ada..9248f90 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -799,6 +799,7 @@ struct signal_struct {
 	 * oom
 	 */
 	bool oom_flag_origin;
+	bool oom_ignore_me;
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
@@ -1545,6 +1546,7 @@ struct task_struct {
 	/* unserialized, strictly 'current' */
 	unsigned in_execve:1; /* bit to tell LSMs we're in execve */
 	unsigned in_iowait:1;
+	unsigned oom_shortcut_done:1;
 #ifdef CONFIG_MEMCG
 	unsigned memcg_may_oom:1;
 #ifndef CONFIG_SLOB
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 75e7440..af162f6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1275,7 +1275,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if (task_is_reapable(current) && !current->oom_shortcut_done) {
+		current->oom_shortcut_done = true;
 		mark_oom_victim(current);
 		try_oom_reaper(current);
 		goto unlock;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index acbc432..e20d889 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -149,7 +149,7 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
 
-	return false;
+	return p->signal->oom_ignore_me;
 }
 
 /**
@@ -555,15 +555,15 @@ static void oom_reap_task(struct task_struct *tsk)
 	}
 
 	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
+	 * Ignore TIF_MEMDIE because the task shouldn't be sitting on a
 	 * reasonably reclaimable memory anymore or it is not a good candidate
 	 * for the oom victim right now because it cannot release its memory
 	 * itself nor by the oom reaper.
 	 */
 	tsk->oom_reaper_list = NULL;
-	exit_oom_victim(tsk);
+	tsk->signal->oom_ignore_me = true;
 
-	/* Drop a reference taken by wake_oom_reaper */
+	/* Drop a reference taken by try_oom_reaper */
 	put_task_struct(tsk);
 }
 
@@ -589,7 +589,7 @@ static int oom_reaper(void *unused)
 	return 0;
 }
 
-static void wake_oom_reaper(struct task_struct *tsk)
+void try_oom_reaper(struct task_struct *tsk)
 {
 	if (!oom_reaper_th)
 		return;
@@ -610,13 +610,13 @@ static void wake_oom_reaper(struct task_struct *tsk)
 /* Check if we can reap the given task. This has to be called with stable
  * tsk->mm
  */
-void try_oom_reaper(struct task_struct *tsk)
+bool task_is_reapable(struct task_struct *tsk)
 {
 	struct mm_struct *mm = tsk->mm;
 	struct task_struct *p;
 
 	if (!mm)
-		return;
+		return false;
 
 	/*
 	 * There might be other threads/processes which are either not
@@ -639,12 +639,11 @@ void try_oom_reaper(struct task_struct *tsk)
 
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
@@ -659,8 +658,10 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
-static void wake_oom_reaper(struct task_struct *tsk)
+bool task_is_reapable(struct task_struct *tsk)
 {
+	return tsk->mm &&
+		(fatal_signal_pending(tsk) || task_will_free_mem(tsk));
 }
 #endif
 
@@ -753,20 +754,28 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
+#ifdef CONFIG_MMU
+	if (task_is_reapable(p)) {
 		mark_oom_victim(p);
 		try_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
 	}
+#else
+	if (p->mm && task_will_free_mem(p)) {
+		mark_oom_victim(p);
+		task_unlock(p);
+		put_task_struct(p);
+		return;
+	}
+#endif
 	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
@@ -846,21 +855,22 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
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
+
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
+#ifdef CONFIG_MMU
+	p = find_lock_task_mm(victim);
+	if (p && task_is_reapable(p))
+		try_oom_reaper(victim);
+	else
+		victim->signal->oom_ignore_me = true;
+	if (p)
+		task_unlock(p);
+#endif
 
 	mmdrop(mm);
 	put_task_struct(victim);
@@ -939,8 +949,8 @@ bool out_of_memory(struct oom_control *oc)
 	 * But don't select if current has already released its mm and cleared
 	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
+	if (!current->oom_shortcut_done && task_is_reapable(current)) {
+		current->oom_shortcut_done = true;
 		mark_oom_victim(current);
 		try_oom_reaper(current);
 		return true;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
