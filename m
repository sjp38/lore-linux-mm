Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8596B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 08:22:31 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a9so24090976oih.3
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 05:22:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i22si1006290otd.322.2017.06.16.05.22.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 05:22:29 -0700 (PDT)
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is freed
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
	<20170615103909.GG1486@dhcp22.suse.cz>
	<alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com>
	<20170615214133.GB20321@dhcp22.suse.cz>
In-Reply-To: <20170615214133.GB20321@dhcp22.suse.cz>
Message-Id: <201706162122.ACE95321.tOFLOOVFFHMSJQ@I-love.SAKURA.ne.jp>
Date: Fri, 16 Jun 2017 21:22:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> OK, could you play with the patch/idea suggested in
> http://lkml.kernel.org/r/20170615122031.GL1486@dhcp22.suse.cz?

I think we don't need to worry about mmap_sem dependency inside __mmput().
Since the OOM killer checks for !MMF_OOM_SKIP mm rather than TIF_MEMDIE thread,
we can keep the OOM killer disabled until we set MMF_OOM_SKIP to the victim's mm.
That is, elevating mm_users throughout the reaping procedure does not cause
premature victim selection, even after TIF_MEMDIE is cleared from the victim's
thread. Then, we don't need to use down_write()/up_write() for non OOM victim's mm
(nearly 100% of exit_mmap() calls), and can force partial reaping of OOM victim's mm
(nearly 0% of exit_mmap() calls) before __mmput() starts doing exit_aio() etc.
Patch is shown below. Only compile tested.

 include/linux/sched/coredump.h |  1 +
 mm/oom_kill.c                  | 80 ++++++++++++++++++++----------------------
 2 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index 98ae0d0..6b6237b 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -62,6 +62,7 @@ static inline int get_dumpable(struct mm_struct *mm)
  * on NFS restore
  */
 //#define MMF_EXE_FILE_CHANGED	18	/* see prctl_set_mm_exe_file() */
+#define MMF_OOM_REAPING		18	/* mm is supposed to be reaped */
 
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0e2c925..bdcf658 100644
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
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
-		goto unlock_oom;
-	}
-
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
@@ -573,9 +535,32 @@ static void oom_reap_task(struct task_struct *tsk)
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
 
+	/*
+	 * Drop our reference but make sure the mmput slow path is called from a
+	 * different context because we shouldn't risk we get stuck there and
+	 * put the oom_reaper out of the way.
+	 */
+	if (test_bit(MMF_OOM_REAPING, &mm->flags)) {
+		clear_bit(MMF_OOM_REAPING, &mm->flags);
+		mmput_async(mm);
+	}
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
 }
@@ -658,6 +643,13 @@ static void mark_oom_victim(struct task_struct *tsk)
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
 		mmgrab(tsk->signal->oom_mm);
 
+#ifdef CONFIG_MMU
+	if (!test_bit(MMF_OOM_REAPING, &mm->flags)) {
+		set_bit(MMF_OOM_REAPING, &mm->flags);
+		mmget(mm);
+	}
+#endif
+
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -913,6 +905,12 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		if (is_global_init(p)) {
 			can_oom_reap = false;
 			set_bit(MMF_OOM_SKIP, &mm->flags);
+#ifdef CONFIG_MMU
+			if (test_bit(MMF_OOM_REAPING, &mm->flags)) {
+				clear_bit(MMF_OOM_REAPING, &mm->flags);
+				mmput_async(mm);
+			}
+#endif
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
