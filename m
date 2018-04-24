Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA266B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 09:04:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j18so13098135pfn.17
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 06:04:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a16si6667393pgn.39.2018.04.24.06.04.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 06:04:39 -0700 (PDT)
Date: Tue, 24 Apr 2018 07:04:32 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaperunmap
Message-ID: <20180424130432.GB17484@dhcp22.suse.cz>
References: <20180419063556.GK17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com>
 <20180420082349.GW17484@dhcp22.suse.cz>
 <20180420124044.GA17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804212019400.84222@chino.kir.corp.google.com>
 <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1804231706340.18716@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1804231706340.18716@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 23-04-18 19:31:05, David Rientjes wrote:
[...]
> diff --git a/mm/mmap.c b/mm/mmap.c
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3015,6 +3015,27 @@ void exit_mmap(struct mm_struct *mm)
>  	/* mm's last user has gone, and its about to be pulled down */
>  	mmu_notifier_release(mm);
>  
> +	if (unlikely(mm_is_oom_victim(mm))) {
> +		/*
> +		 * Manually reap the mm to free as much memory as possible.
> +		 * Then, as the oom reaper, set MMF_OOM_SKIP to disregard this
> +		 * mm from further consideration.  Taking mm->mmap_sem for write
> +		 * after setting MMF_OOM_SKIP will guarantee that the oom reaper
> +		 * will not run on this mm again after mmap_sem is dropped.
> +		 *
> +		 * This needs to be done before calling munlock_vma_pages_all(),
> +		 * which clears VM_LOCKED, otherwise the oom reaper cannot
> +		 * reliably test it.
> +		 */
> +		mutex_lock(&oom_lock);
> +		__oom_reap_task_mm(mm);
> +		mutex_unlock(&oom_lock);
> +
> +		set_bit(MMF_OOM_SKIP, &mm->flags);
> +		down_write(&mm->mmap_sem);
> +		up_write(&mm->mmap_sem);
> +	}
> +

Is there any reason why we cannot simply call __oom_reap_task_mm as we
have it now? mmap_sem for read shouldn't fail here because this is the
last reference of the mm and we are past the ksm and khugepaged
synchronizations. So unless my jed laged brain fools me the patch should
be as simple as the following (I haven't tested it at all).

diff --git a/mm/mmap.c b/mm/mmap.c
index faf85699f1a1..a8f170f53872 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3008,6 +3008,13 @@ void exit_mmap(struct mm_struct *mm)
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
 
+	/*
+	 * The mm is not accessible for anybody except for the oom reaper
+	 * which cannot race with munlocking so reap the task direct.
+	 */
+	if (unlikely(mm_is_oom_victim(mm)))
+		__oom_reap_task_mm(current, mm);
+
 	if (mm->locked_vm) {
 		vma = mm->mmap;
 		while (vma) {
@@ -3030,23 +3037,6 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
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
 
@@ -3060,6 +3050,7 @@ void exit_mmap(struct mm_struct *mm)
 		vma = remove_vma(vma);
 	}
 	vm_unacct_memory(nr_accounted);
+
 }
 
 /* Insert vm structure into process list sorted by address
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dfd370526909..e39ceb127e8e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -524,7 +524,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
 	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
 	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
+	 * exit_mmap().
 	 */
 	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
 		up_read(&mm->mmap_sem);
@@ -567,12 +567,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			tlb_finish_mmu(&tlb, start, end);
 		}
 	}
-	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+	pr_info("%s: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+			current->comm,
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	trace_finish_task_reaping(tsk->pid);
 unlock_oom:
@@ -590,10 +592,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
-	if (attempts <= MAX_OOM_REAP_RETRIES ||
-	    test_bit(MMF_OOM_SKIP, &mm->flags))
+	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
 
+	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+		goto put_task;
 
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
@@ -609,6 +612,7 @@ static void oom_reap_task(struct task_struct *tsk)
 	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/* Drop a reference taken by wake_oom_reaper */
+put_task:
 	put_task_struct(tsk);
 }
-- 
Michal Hocko
SUSE Labs
