Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08DB66B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:51:51 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d3-v6so4159533iod.22
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:51:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w20-v6si3091431iod.66.2018.04.19.04.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 04:51:49 -0700 (PDT)
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180418075051.GO17484@dhcp22.suse.cz>
	<alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
	<20180419063556.GK17484@dhcp22.suse.cz>
	<201804191945.BBF87517.FVMLOQFOHSFJOt@I-love.SAKURA.ne.jp>
	<20180419110419.GQ17484@dhcp22.suse.cz>
In-Reply-To: <20180419110419.GQ17484@dhcp22.suse.cz>
Message-Id: <201804192051.JDE35992.OLFOQFMOtJHFSV@I-love.SAKURA.ne.jp>
Date: Thu, 19 Apr 2018 20:51:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, aarcange@redhat.com, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> > We need to teach the OOM reaper stop reaping as soon as entering exit_mmap().
> > Maybe let the OOM reaper poll for progress (e.g. none of get_mm_counter(mm, *)
> > decreased for last 1 second) ?
> 
> Can we start simple and build a more elaborate heuristics on top _please_?
> In other words holding the mmap_sem for write for oom victims in
> exit_mmap should handle the problem. We can then enhance this to probe
> for progress or any other clever tricks if we find out that the race
> happens too often and we kill more than necessary.
> 
> Let's not repeat the error of trying to be too clever from the beginning
> as we did previously. This are is just too subtle and obviously error
> prone.
> 
Something like this?

---
 mm/mmap.c     | 41 +++++++++++++++++++++++------------------
 mm/oom_kill.c | 29 +++++++++++------------------
 2 files changed, 34 insertions(+), 36 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 188f195..3edb7da 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3015,6 +3015,28 @@ void exit_mmap(struct mm_struct *mm)
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
 
+	if (unlikely(mm_is_oom_victim(mm))) {
+		/*
+		 * Tell oom_reap_task() not to start reaping this mm.
+		 *
+		 * oom_reap_task() depends on a stable VM_LOCKED flag to
+		 * indicate it should not unmap during munlock_vma_pages_all().
+		 *
+		 * Since MMF_UNSTABLE is set before calling down_write(),
+		 * oom_reap_task() which calls down_read() before testing
+		 * MMF_UNSTABLE will not run on this mm after up_write().
+		 *
+		 * mm_is_oom_victim() cannot be set from under us because
+		 * victim->mm is already set to NULL under task_lock before
+		 * calling mmput() and victim->signal->oom_mm is set by the oom
+		 * killer only if victim->mm is non-NULL while holding
+		 * task_lock().
+		 */
+		set_bit(MMF_UNSTABLE, &mm->flags);
+		down_write(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
+	}
+
 	if (mm->locked_vm) {
 		vma = mm->mmap;
 		while (vma) {
@@ -3036,26 +3058,9 @@ void exit_mmap(struct mm_struct *mm)
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
-
-	if (unlikely(mm_is_oom_victim(mm))) {
-		/*
-		 * Wait for oom_reap_task() to stop working on this
-		 * mm. Because MMF_OOM_SKIP is already set before
-		 * calling down_read(), oom_reap_task() will not run
-		 * on this "mm" post up_write().
-		 *
-		 * mm_is_oom_victim() cannot be set from under us
-		 * either because victim->mm is already set to NULL
-		 * under task_lock before calling mmput and oom_mm is
-		 * set not NULL by the OOM killer only if victim->mm
-		 * is found not NULL while holding the task_lock.
-		 */
-		set_bit(MMF_OOM_SKIP, &mm->flags);
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
-	}
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ff992fa..1fef1b6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -510,25 +510,16 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	/*
 	 * If the mm has invalidate_{start,end}() notifiers that could block,
+	 * or if the mm is in exit_mmap() which has unpredictable dependencies,
 	 * sleep to give the oom victim some more time.
 	 * TODO: we really want to get rid of this ugly hack and make sure that
 	 * notifiers cannot block for unbounded amount of time
 	 */
-	if (mm_has_blockable_invalidate_notifiers(mm)) {
-		up_read(&mm->mmap_sem);
-		schedule_timeout_idle(HZ);
-		goto unlock_oom;
-	}
-
-	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
-	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
-	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+	if (mm_has_blockable_invalidate_notifiers(mm) ||
+	    test_bit(MMF_UNSTABLE, &mm->flags)) {
 		up_read(&mm->mmap_sem);
 		trace_skip_task_reaping(tsk->pid);
+		schedule_timeout_idle(HZ);
 		goto unlock_oom;
 	}
 
@@ -590,11 +581,9 @@ static void oom_reap_task(struct task_struct *tsk)
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
-	if (attempts <= MAX_OOM_REAP_RETRIES ||
-	    test_bit(MMF_OOM_SKIP, &mm->flags))
+	if (test_bit(MMF_UNSTABLE, &mm->flags))
 		goto done;
 
-
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
 	debug_show_all_locks();
@@ -603,8 +592,12 @@ static void oom_reap_task(struct task_struct *tsk)
 	tsk->oom_reaper_list = NULL;
 
 	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
+	 * Hide this mm from the OOM killer because:
+	 *   the OOM reaper completed reaping
+	 * or
+	 *   exit_mmap() told the OOM reaper not to start reaping
+	 * or
+	 *   neither exit_mmap() nor the OOM reaper started reaping
 	 */
 	set_bit(MMF_OOM_SKIP, &mm->flags);
 
-- 
1.8.3.1
