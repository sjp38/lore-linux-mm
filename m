Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 113A96B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 09:23:34 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z91so28156wrc.4
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 06:23:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n71si870447wmd.255.2017.08.16.06.23.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Aug 2017 06:23:32 -0700 (PDT)
Date: Wed, 16 Aug 2017 15:23:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: +
 mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently.patch added to
 -mm tree
Message-ID: <20170816132329.GA32169@dhcp22.suse.cz>
References: <59936823.CQNWQErWJ8EAIG3q%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59936823.CQNWQErWJ8EAIG3q%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, hughd@google.com, kirill@shutemov.name, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue 15-08-17 14:31:15, Andrew Morton wrote:
[...]
> From: Andrea Arcangeli <aarcange@redhat.com>
> Subject: mm: oom: let oom_reap_task and exit_mmap run concurrently
> 
> This is purely required because exit_aio() may block and exit_mmap() may
> never start, if the oom_reap_task cannot start running on a mm with
> mm_users == 0.
> 
> At the same time if the OOM reaper doesn't wait at all for the memory of
> the current OOM candidate to be freed by exit_mmap->unmap_vmas, it would
> generate a spurious OOM kill.
> 
> If it wasn't because of the exit_aio or similar blocking functions in the
> last mmput, it would be enough to change the oom_reap_task() in the case
> it finds mm_users == 0, to wait for a timeout or to wait for __mmput to
> set MMF_OOM_SKIP itself, but it's not just exit_mmap the problem here so
> the concurrency of exit_mmap and oom_reap_task is apparently warranted.
> 
> It's a non standard runtime, exit_mmap() runs without mmap_sem, and
> oom_reap_task runs with the mmap_sem for reading as usual (kind of
> MADV_DONTNEED).
> 
> The race between the two is solved with a combination of
> tsk_is_oom_victim() (serialized by task_lock) and MMF_OOM_SKIP (serialized
> by a dummy down_write/up_write cycle on the same lines of the ksm_exit
> method).
> 
> If the oom_reap_task() may be running concurrently during exit_mmap,
> exit_mmap will wait it to finish in down_write (before taking down mm
> structures that would make the oom_reap_task fail with use after free).
> 
> If exit_mmap comes first, oom_reap_task() will skip the mm if MMF_OOM_SKIP
> is already set and in turn all memory is already freed and furthermore the
> mm data structures may already have been taken down by free_pgtables.

I find the changelog rather hard to understand but that is not critical.

> Link: http://lkml.kernel.org/r/20170726162912.GA29716@redhat.com
> Fixes: 26db62f179d1 ("oom: keep mm of the killed task available")
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: David Rientjes <rientjes@google.com>
> Tested-by: David Rientjes <rientjes@google.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  kernel/fork.c |    1 -
>  mm/mmap.c     |   17 +++++++++++++++++
>  mm/oom_kill.c |   15 +++++----------
>  3 files changed, 22 insertions(+), 11 deletions(-)
> 
> diff -puN kernel/fork.c~mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently kernel/fork.c
> --- a/kernel/fork.c~mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently
> +++ a/kernel/fork.c
> @@ -910,7 +910,6 @@ static inline void __mmput(struct mm_str
>  	}
>  	if (mm->binfmt)
>  		module_put(mm->binfmt->module);
> -	set_bit(MMF_OOM_SKIP, &mm->flags);
>  	mmdrop(mm);
>  }
>  
> diff -puN mm/mmap.c~mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently mm/mmap.c
> --- a/mm/mmap.c~mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently
> +++ a/mm/mmap.c
> @@ -3001,6 +3001,23 @@ void exit_mmap(struct mm_struct *mm)
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>  	unmap_vmas(&tlb, vma, 0, -1);
>  
> +	set_bit(MMF_OOM_SKIP, &mm->flags);
> +	if (tsk_is_oom_victim(current)) {
> +		/*
> +		 * Wait for oom_reap_task() to stop working on this
> +		 * mm. Because MMF_OOM_SKIP is already set before
> +		 * calling down_read(), oom_reap_task() will not run
> +		 * on this "mm" post up_write().
> +		 *
> +		 * tsk_is_oom_victim() cannot be set from under us
> +		 * either because current->mm is already set to NULL
> +		 * under task_lock before calling mmput and oom_mm is
> +		 * set not NULL by the OOM killer only if current->mm
> +		 * is found not NULL while holding the task_lock.
> +		 */
> +		down_write(&mm->mmap_sem);
> +		up_write(&mm->mmap_sem);
> +	}
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>  	tlb_finish_mmu(&tlb, 0, -1);
>  
> diff -puN mm/oom_kill.c~mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently mm/oom_kill.c
> --- a/mm/oom_kill.c~mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently
> +++ a/mm/oom_kill.c
> @@ -495,11 +495,12 @@ static bool __oom_reap_task_mm(struct ta
>  	}
>  
>  	/*
> -	 * increase mm_users only after we know we will reap something so
> -	 * that the mmput_async is called only when we have reaped something
> -	 * and delayed __mmput doesn't matter that much
> +	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
> +	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
> +	 * under mmap_sem for reading because it serializes against the
> +	 * down_write();up_write() cycle in exit_mmap().
>  	 */
> -	if (!mmget_not_zero(mm)) {
> +	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
>  		up_read(&mm->mmap_sem);
>  		trace_skip_task_reaping(tsk->pid);
>  		goto unlock_oom;
> @@ -542,12 +543,6 @@ static bool __oom_reap_task_mm(struct ta
>  			K(get_mm_counter(mm, MM_SHMEMPAGES)));
>  	up_read(&mm->mmap_sem);
>  
> -	/*
> -	 * Drop our reference but make sure the mmput slow path is called from a
> -	 * different context because we shouldn't risk we get stuck there and
> -	 * put the oom_reaper out of the way.
> -	 */
> -	mmput_async(mm);
>  	trace_finish_task_reaping(tsk->pid);
>  unlock_oom:
>  	mutex_unlock(&oom_lock);
> _
> 
> Patches currently in -mm which might be from aarcange@redhat.com are
> 
> userfaultfd-selftest-exercise-uffdio_copy-zeropage-eexist.patch
> userfaultfd-selftest-explicit-failure-if-the-sigbus-test-failed.patch
> userfaultfd-call-userfaultfd_unmap_prep-only-if-__split_vma-succeeds.patch
> userfaultfd-provide-pid-in-userfault-msg-add-feat-union.patch
> mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently.patch
> mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently-fix.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
