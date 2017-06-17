Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96C6F6B02C3
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 01:17:32 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u127so48740683itg.11
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 22:17:32 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v12si5226702ita.52.2017.06.16.22.17.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 22:17:31 -0700 (PDT)
Subject: [PATCH] mm,oom_kill: Close race window of needlessly selecting new victims.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170615103909.GG1486@dhcp22.suse.cz>
	<alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com>
	<20170615214133.GB20321@dhcp22.suse.cz>
	<201706162122.ACE95321.tOFLOOVFFHMSJQ@I-love.SAKURA.ne.jp>
	<20170616141255.GN30580@dhcp22.suse.cz>
In-Reply-To: <20170616141255.GN30580@dhcp22.suse.cz>
Message-Id: <201706171417.JHG48401.JOQLHMFSVOOFtF@I-love.SAKURA.ne.jp>
Date: Sat, 17 Jun 2017 14:17:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 16-06-17 21:22:20, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > OK, could you play with the patch/idea suggested in
> > > http://lkml.kernel.org/r/20170615122031.GL1486@dhcp22.suse.cz?
> > 
> > I think we don't need to worry about mmap_sem dependency inside __mmput().
> > Since the OOM killer checks for !MMF_OOM_SKIP mm rather than TIF_MEMDIE thread,
> > we can keep the OOM killer disabled until we set MMF_OOM_SKIP to the victim's mm.
> > That is, elevating mm_users throughout the reaping procedure does not cause
> > premature victim selection, even after TIF_MEMDIE is cleared from the victim's
> > thread. Then, we don't need to use down_write()/up_write() for non OOM victim's mm
> > (nearly 100% of exit_mmap() calls), and can force partial reaping of OOM victim's mm
> > (nearly 0% of exit_mmap() calls) before __mmput() starts doing exit_aio() etc.
> > Patch is shown below. Only compile tested.
> 
> Yes, that would be another approach.
>  
> >  include/linux/sched/coredump.h |  1 +
> >  mm/oom_kill.c                  | 80 ++++++++++++++++++++----------------------
> >  2 files changed, 40 insertions(+), 41 deletions(-)
> > 
> > diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
> > index 98ae0d0..6b6237b 100644
> > --- a/include/linux/sched/coredump.h
> > +++ b/include/linux/sched/coredump.h
> > @@ -62,6 +62,7 @@ static inline int get_dumpable(struct mm_struct *mm)
> >   * on NFS restore
> >   */
> >  //#define MMF_EXE_FILE_CHANGED	18	/* see prctl_set_mm_exe_file() */
> > +#define MMF_OOM_REAPING		18	/* mm is supposed to be reaped */
> 
> A new flag is not really needed. We can increase it for _each_ reapable
> oom victim.

Yes if based on an assumption that number of mark_oom_victim() calls and
wake_oom_reaper() calls matches...

> 
> > @@ -658,6 +643,13 @@ static void mark_oom_victim(struct task_struct *tsk)
> >  	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
> >  		mmgrab(tsk->signal->oom_mm);
> >  
> > +#ifdef CONFIG_MMU
> > +	if (!test_bit(MMF_OOM_REAPING, &mm->flags)) {
> > +		set_bit(MMF_OOM_REAPING, &mm->flags);
> > +		mmget(mm);
> > +	}
> > +#endif
> 
> This would really need a big fat warning explaining why we do not need
> mmget_not_zero. We rely on exit_mm doing both mmput and tsk->mm = NULL
> under the task_lock and mark_oom_victim is called under this lock as
> well and task_will_free_mem resp. find_lock_task_mm makes sure we do not
> even consider tasks wihout mm.
> 
> I agree that a solution which is fully contained inside the oom proper
> would be preferable to touching __mmput path.

OK. Updated patch shown below.

----------------------------------------
>From 5ed8922bd281456793408328c8b27899ebdd298b Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 17 Jun 2017 14:04:09 +0900
Subject: [PATCH] mm,oom_kill: Close race window of needlessly selecting new
 victims.

David Rientjes has reported that the OOM killer can select next OOM victim
when existing OOM victims called __mmput() before the OOM reaper starts
trying to unmap pages. In his testing, 4.12-rc kernels are killing 1-4
processes unnecessarily for each OOM condition.

----------
  One oom kill shows the system to be oom:

  [22999.488705] Node 0 Normal free:90484kB min:90500kB ...
  [22999.488711] Node 1 Normal free:91536kB min:91948kB ...

  followed up by one or more unnecessary oom kills showing the oom killer
  racing with memory freeing of the victim:

  [22999.510329] Node 0 Normal free:229588kB min:90500kB ...
  [22999.510334] Node 1 Normal free:600036kB min:91948kB ...
----------

This is because commit e5e3f4c4f0e95ecb ("mm, oom_reaper: make sure that
mmput_async is called only when memory was reaped") kept not to set
MMF_OOM_REAPED flag when the OOM reaper found that mm_users == 0 but then
commit 26db62f179d112d3 ("oom: keep mm of the killed task available") by
error changed to always set MMF_OOM_REAPED flag. As a result, MMF_OOM_SKIP
flag is immediately set without waiting for __mmput() because __mmput()
might get stuck before setting MMF_OOM_SKIP flag, and led to above report.

A workaround is to let the OOM reaper wait for a while and give up via
timeout as if the OOM reaper was unable to take mmap_sem for read. But
we want to avoid timeout based approach if possible. Therefore, this
patch takes a different approach.

This patch elevates mm_users of an OOM victim's mm, and prevents the OOM
victim from calling __mmput() before the OOM reaper starts trying to unmap
pages. In this way, we can force the OOM reaper to try to reclaim some
memory before setting MMF_OOM_SKIP flag.

Since commit 862e3073b3eed13f ("mm, oom: get rid of
signal_struct::oom_victims") changed to keep the OOM killer disabled
until MMF_OOM_SKIP is set on the victim's mm rather than until TIF_MEMDIE
is cleared from the victim's thread, we can keep the OOM killer disabled
until __oom_reap_task_mm() or __mmput() reclaims some memory and sets
MMF_OOM_SKIP flag. That is, elevating mm_users throughout the reaping
procedure does not cause premature victim selection.

This patch also reduces the range of oom_lock protection in
__oom_reap_task_mm() introduced by commit e2fe14564d3316d1 ("oom_reaper:
close race with exiting task"). Since the OOM killer is kept disabled until
MMF_OOM_SKIP flag is set, we don't need to serialize throughout the reaping
procedure; serializing only setting MMF_OOM_SKIP flag is enough.
This allows the OOM reaper to start reclaiming memory as soon as
wake_oom_reaper() is called by the OOM killer in order to compensate for
delaying exit_mmap() call caused by elevating mm_users of the OOM victim's
mm when the OOM victim can exit smoothly, for currently the OOM killer
calls schedule_timeout_killable(1) at out_of_memory() with oom_lock held.
This might also allow direct OOM reaping (i.e. let the OOM killer call
__oom_reap_task_mm() because we would have 16KB kernel stack with stack
overflow detection) and replace the OOM reaper kernel thread with a
workqueue (i.e. save one kernel thread).

Reported-by: David Rientjes <rientjes@google.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Fixes: 26db62f179d112d3 ("oom: keep mm of the killed task available")
Cc: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 94 ++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 51 insertions(+), 43 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143..cf1d331 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -470,38 +470,9 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
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
@@ -537,16 +508,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
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
@@ -569,12 +531,31 @@ static void oom_reap_task(struct task_struct *tsk)
 
 done:
 	tsk->oom_reaper_list = NULL;
+	/*
+	 * Drop a mm_users reference taken by mark_oom_victim().
+	 * A mm_count reference taken by mark_oom_victim() remains.
+	 */
+	mmput_async(mm);
 
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
+	 *
+	 * Serialize setting of MMF_OOM_SKIP using oom_lock in order to
+	 * avoid race with select_bad_process() which causes premature
+	 * new oom victim selection.
+	 *
+	 * The OOM reaper:           An allocating task:
+	 *                             Failed get_page_from_freelist().
+	 *                             Enters into out_of_memory().
+	 *   Reaped memory enough to make get_page_from_freelist() succeed.
+	 *   Sets MMF_OOM_SKIP to mm.
+	 *                               Enters into select_bad_process().
+	 *                                 # MMF_OOM_SKIP mm selects new victim.
 	 */
+	mutex_lock(&oom_lock);
 	set_bit(MMF_OOM_SKIP, &mm->flags);
+	mutex_unlock(&oom_lock);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
@@ -602,12 +583,16 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th)
+	if (!oom_reaper_th) {
+		mmput_async(tsk->signal->oom_mm);
 		return;
+	}
 
 	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	if (tsk == oom_reaper_list || tsk->oom_reaper_list) {
+		mmput_async(tsk->signal->oom_mm);
 		return;
+	}
 
 	get_task_struct(tsk);
 
@@ -650,12 +635,32 @@ static void mark_oom_victim(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->mm;
 
 	WARN_ON(oom_killer_disabled);
+#ifdef CONFIG_MMU
+	/*
+	 * Take a mm_users reference so that __oom_reap_task_mm() can unmap
+	 * pages without risking a race condition where final mmput() from
+	 * exit_mm() from do_exit() triggered __mmput() and gets stuck there
+	 * (but __oom_reap_task_mm() cannot unmap pages due to mm_users == 0).
+	 *
+	 * Since all callers guarantee that this mm is stable (hold task_lock
+	 * or task is current), we can safely use mmget() here.
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
@@ -908,6 +913,9 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		if (is_global_init(p)) {
 			can_oom_reap = false;
 			set_bit(MMF_OOM_SKIP, &mm->flags);
+#ifdef CONFIG_MMU
+			mmput_async(mm);
+#endif
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
