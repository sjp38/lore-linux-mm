Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 37EB26B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 20:54:01 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j200so14207809ioe.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 17:54:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i191si310394iti.147.2017.06.21.17.53.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 17:53:59 -0700 (PDT)
Message-Id: <201706220053.v5M0rmOU078764@www262.sakura.ne.jp>
Subject: Re: [PATCH] =?ISO-2022-JP?B?bW0sb29tX2tpbGw6IENsb3NlIHJhY2Ugd2luZG93IG9m?=
 =?ISO-2022-JP?B?IG5lZWRsZXNzbHkgc2VsZWN0aW5nIG5ldyB2aWN0aW1zLg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 22 Jun 2017 09:53:48 +0900
References: <201706210217.v5L2HAZc081021@www262.sakura.ne.jp> <alpine.DEB.2.10.1706211325340.101895@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1706211325340.101895@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> On Wed, 21 Jun 2017, Tetsuo Handa wrote:
> > Umm... So, you are pointing out that select_bad_process() aborts based on
> > TIF_MEMDIE or MMF_OOM_SKIP is broken because victim threads can be removed
> >  from global task list or cgroup's task list. Then, the OOM killer will have to
> > wait until all mm_struct of interested OOM domain (system wide or some cgroup)
> > is reaped by the OOM reaper. Simplest way is to wait until all mm_struct are
> > reaped by the OOM reaper, for currently we are not tracking which memory cgroup
> > each mm_struct belongs to, are we? But that can cause needless delay when
> > multiple OOM events occurred in different OOM domains. Do we want to (and can we)
> > make it possible to tell whether each mm_struct queued to the OOM reaper's list
> > belongs to the thread calling out_of_memory() ?
> > 
> 
> I am saying that taking mmget() in mark_oom_victim() and then only 
> dropping it with mmput_async() after it can grab mm->mmap_sem, which the 
> exit path itself takes, or the oom reaper happens to schedule, causes 
> __mmput() to be called much later and thus we remove the process from the 
> tasklist or call cgroup_exit() earlier than the memory can be unmapped 
> with your patch.  As a result, subsequent calls to the oom killer kills 
> everything before the original victim's mm can undergo __mmput() because 
> the oom reaper still holds the reference.

Here is "wait for all mm_struct are reaped by the OOM reaper" version.

 include/linux/sched.h |   3 -
 mm/oom_kill.c         | 150 ++++++++++++++++++++++++--------------------------
 2 files changed, 71 insertions(+), 82 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2b69fc6..0d9904e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1034,9 +1034,6 @@ struct task_struct {
 	unsigned long			task_state_change;
 #endif
 	int				pagefault_disabled;
-#ifdef CONFIG_MMU
-	struct task_struct		*oom_reaper_list;
-#endif
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
 #endif
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143..fb0b8dc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -296,6 +296,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
 		goto next;
 
+#ifndef CONFIG_MMU
 	/*
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves unless
@@ -307,6 +308,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 			goto next;
 		goto abort;
 	}
+#endif
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -332,11 +334,13 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	oc->chosen_points = points;
 next:
 	return 0;
+#ifndef CONFIG_MMU
 abort:
 	if (oc->chosen)
 		put_task_struct(oc->chosen);
 	oc->chosen = (void *)-1UL;
 	return 1;
+#endif
 }
 
 /*
@@ -463,45 +467,17 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
-static DEFINE_SPINLOCK(oom_reaper_lock);
+static struct mm_struct *oom_mm;
+static char oom_mm_owner_comm[TASK_COMM_LEN];
+static pid_t oom_mm_owner_pid;
 
-static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+static bool __oom_reap_mm(struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	bool ret = true;
-
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
-	mutex_lock(&oom_lock);
-
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
-		goto unlock_oom;
-	}
 
-	/*
-	 * increase mm_users only after we know we will reap something so
-	 * that the mmput_async is called only when we have reaped something
-	 * and delayed __mmput doesn't matter that much
-	 */
-	if (!mmget_not_zero(mm)) {
-		up_read(&mm->mmap_sem);
-		goto unlock_oom;
-	}
+	if (!down_read_trylock(&mm->mmap_sem))
+		return false;
 
 	/*
 	 * Tell all users of get_user/copy_from_user etc... that the content
@@ -532,89 +508,71 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-			task_pid_nr(tsk), tsk->comm,
+			oom_mm_owner_pid, oom_mm_owner_comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
-
-	/*
-	 * Drop our reference but make sure the mmput slow path is called from a
-	 * different context because we shouldn't risk we get stuck there and
-	 * put the oom_reaper out of the way.
-	 */
-	mmput_async(mm);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-static void oom_reap_task(struct task_struct *tsk)
+static void oom_reap_mm(struct mm_struct *mm)
 {
 	int attempts = 0;
-	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_mm(mm))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
 
-
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
+		oom_mm_owner_pid, oom_mm_owner_comm);
 	debug_show_all_locks();
 
 done:
-	tsk->oom_reaper_list = NULL;
-
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
 	 */
 	set_bit(MMF_OOM_SKIP, &mm->flags);
 
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
+	/*
+	 * Drop a mm_users reference taken by mark_oom_victim().
+	 * A mm_count reference taken by mark_oom_victim() remains.
+	 */
+	mmput_async(mm);
 }
 
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct task_struct *tsk = NULL;
-
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
-		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
-		}
-		spin_unlock(&oom_reaper_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
+		wait_event(oom_reaper_wait, oom_mm);
+		oom_reap_mm(oom_mm);
+		mutex_lock(&oom_lock);
+		oom_mm = NULL;
+		mutex_unlock(&oom_lock);
 	}
-
 	return 0;
 }
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th)
-		return;
-
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	/*
+	 * Since only tsk == current case can reach here when oom_mm != NULL,
+	 * the OOM reaper will reap current->mm on behalf of current thread if
+	 * oom_mm != NULL. Thus, just drop a mm_users reference taken by
+	 * mark_oom_victim().
+	 */
+	if (!oom_reaper_th || oom_mm) {
+		mmput_async(tsk->signal->oom_mm);
 		return;
-
-	get_task_struct(tsk);
-
-	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
-	spin_unlock(&oom_reaper_lock);
+	}
+	strlcpy(oom_mm_owner_comm, tsk->comm, sizeof(oom_mm_owner_comm));
+	oom_mm_owner_pid = task_pid_nr(tsk);
+	oom_mm = tsk->signal->oom_mm;
 	wake_up(&oom_reaper_wait);
 }
 
@@ -650,12 +608,32 @@ static void mark_oom_victim(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->mm;
 
 	WARN_ON(oom_killer_disabled);
+#ifdef CONFIG_MMU
+	/*
+	 * Take a mm_users reference so that __oom_reap_mm() can unmap
+	 * pages without risking a race condition where final mmput() from
+	 * exit_mm() from do_exit() triggered __mmput() and gets stuck there
+	 * (but __oom_reap_mm() cannot unmap pages due to mm_users == 0).
+	 *
+	 * Since all callers guarantee that this mm is stable (hold task_lock
+	 * or tsk == current), we can safely use mmget() here.
+	 *
+	 * When dropping this reference, mmput_async() has to be used because
+	 * __mmput() can get stuck which in turn keeps the OOM killer/reaper
+	 * disabled forever.
+	 */
+	mmget(mm);
+#endif
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
 
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
+		/*
+		 * Take a mm_count reference so that we can examine flags value
+		 * when tsk_is_oom_victim() is true.
+		 */
 		mmgrab(tsk->signal->oom_mm);
 
 	/*
@@ -908,6 +886,9 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		if (is_global_init(p)) {
 			can_oom_reap = false;
 			set_bit(MMF_OOM_SKIP, &mm->flags);
+#ifdef CONFIG_MMU
+			mmput_async(mm);
+#endif
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
@@ -1005,6 +986,17 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+#ifdef CONFIG_MMU
+	/*
+	 * Wait for the OOM reaper to reap existing OOM victim's mm in order
+	 * to avoid selecting next OOM victims prematurely. This will block
+	 * OOM events in different domains and SysRq-f, but this should be no
+	 * problem because the OOM reaper is guaranteed not to wait forever.
+	 */
+	if (oom_mm)
+		return true;
+#endif
+
 	/*
 	 * The OOM killer does not compensate for IO-less reclaim.
 	 * pagefault_out_of_memory lost its gfp context so we have to
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
