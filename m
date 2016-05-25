Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90FD56B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 09:50:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so28705447wma.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 06:50:06 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id g198si12020088wmd.58.2016.05.25.06.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 06:50:05 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id f75so15738366wmf.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 06:50:04 -0700 (PDT)
Date: Wed, 25 May 2016 15:50:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the
 oom reaper context
Message-ID: <20160525135002.GI20132@dhcp22.suse.cz>
References: <1461679470-8364-1-git-send-email-mhocko@kernel.org>
 <1461679470-8364-3-git-send-email-mhocko@kernel.org>
 <201605192329.ABB17132.LFHOFJMVtOSFQO@I-love.SAKURA.ne.jp>
 <20160519172056.GA5290@dhcp22.suse.cz>
 <201605251952.EJF87514.SOJQMOVFOFHFLt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605251952.EJF87514.SOJQMOVFOFHFLt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org

On Wed 25-05-16 19:52:18, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > Just a random thought, but after this patch is applied, do we still need to use
> > > a dedicated kernel thread for OOM-reap operation? If I recall correctly, the
> > > reason we decided to use a dedicated kernel thread was that calling
> > > down_read(&mm->mmap_sem) / mmput() from the OOM killer context is unsafe due to
> > > dependency. By replacing mmput() with mmput_async(), since __oom_reap_task() will
> > > no longer do operations that might block, can't we try OOM-reap operation from
> > > current thread which called mark_oom_victim() or oom_scan_process_thread() ?
> > 
> > I was already thinking about that. It is true that the main blocker
> > was the mmput, as you say, but the dedicated kernel thread seems to be
> > more robust locking and stack wise. So I would prefer staying with the
> > current approach until we see that it is somehow limitting. One pid and
> > kernel stack doesn't seem to be a terrible price to me. But as I've said
> > I am not bound to the kernel thread approach...
> > 
> 
> It seems to me that async OOM reaping widens race window for needlessly
> selecting next OOM victim, for the OOM reaper holding a reference of a
> TIF_MEMDIE thread's mm expedites clearing TIF_MEMDIE from that thread
> by making atomic_dec_and_test() in mmput() from exit_mm() false.
 
AFAIU you mean
__oom_reap_task			exit_mm
  atomic_inc_not_zero
				  tsk->mm = NULL
				  mmput
  				    atomic_dec_and_test # > 0
				  exit_oom_victim # New victim will be
				  		  # selected
				<OOM killer invoked>
				  # no TIF_MEMDIE task so we can select a new one
  unmap_page_range # to release the memory

Previously we were kind of protected by PF_EXITING check in
oom_scan_process_thread which is not there anymore. The race is possible
even without the oom reaper because many other call sites might pin
the address space and be preempted for an unbounded amount of time. We
could widen the race window by reintroducing the check or moving
exit_oom_victim later in do_exit after exit_notify which then removes
the task from the task_list (in __unhash_process) so the OOM killer
wouldn't see it anyway. Sounds ugly to me though.

> Maybe we should wait for first OOM reap attempt from the OOM killer context
> before releasing oom_lock mutex (sync OOM reaping) ?

I do not think we want to wait inside the oom_lock as it is a global
lock shared by all OOM killer contexts. Another option would be to use
the oom_lock inside __oom_reap_task. It is not super cool either because
now we have a dependency on the lock but looks like reasonably easy
solution.
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5bb2f7698ad7..d0f42cc88f6a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -450,6 +450,22 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	bool ret = true;
 
 	/*
+	 * We have to make sure to not race with the victim exit path
+	 * and cause premature new oom victim selection:
+	 * __oom_reap_task		exit_mm
+	 *   atomic_inc_not_zero
+	 *   				  mmput
+	 *   				    atomic_dec_and_test
+	 *				  exit_oom_victim
+	 *				[...]
+	 *				out_of_memory
+	 *				  select_bad_process
+	 *				    # no TIF_MEMDIE task select new victim
+	 *  unmap_page_range # frees some memory
+	 */
+	mutex_lock(&oom_lock);
+
+	/*
 	 * Make sure we find the associated mm_struct even when the particular
 	 * thread has already terminated and cleared its mm.
 	 * We might have race with exit path so consider our work done if there
@@ -457,19 +473,19 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	p = find_lock_task_mm(tsk);
 	if (!p)
-		return true;
+		goto unlock_oom;
 
 	mm = p->mm;
 	if (!atomic_inc_not_zero(&mm->mm_users)) {
 		task_unlock(p);
-		return true;
+		goto unlock_oom;
 	}
 
 	task_unlock(p);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
-		goto out;
+		goto unlock_oom;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -511,7 +527,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * to release its memory.
 	 */
 	set_bit(MMF_OOM_REAPED, &mm->flags);
-out:
+unlock_oom:
+	mutex_unlock(&oom_lock);
 	/*
 	 * Drop our reference but make sure the mmput slow path is called from a
 	 * different context because we shouldn't risk we get stuck there and

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
