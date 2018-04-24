Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A7E4D6B0007
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 01:35:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i127so7908959pgc.22
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 22:35:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r15sor4160942pfk.13.2018.04.23.22.35.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 22:35:08 -0700 (PDT)
Date: Mon, 23 Apr 2018 22:35:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaperunmap
In-Reply-To: <201804240511.w3O5BY4o090598@www262.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1804232231020.82340@chino.kir.corp.google.com>
References: <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp> <alpine.DEB.2.21.1804231706340.18716@chino.kir.corp.google.com> <201804240511.w3O5BY4o090598@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 24 Apr 2018, Tetsuo Handa wrote:

> > > We can call __oom_reap_task_mm() from exit_mmap() (or __mmput()) before
> > > exit_mmap() holds mmap_sem for write. Then, at least memory which could
> > > have been reclaimed if exit_mmap() did not hold mmap_sem for write will
> > > be guaranteed to be reclaimed before MMF_OOM_SKIP is set.
> > > 
> > 
> > I think that's an exceptionally good idea and will mitigate the concerns 
> > of others.
> > 
> > It can be done without holding mm->mmap_sem in exit_mmap() and uses the 
> > same criteria that the oom reaper uses to set MMF_OOM_SKIP itself, so we 
> > don't get dozens of unnecessary oom kills.
> > 
> > What do you think about this?  It passes preliminary testing on powerpc 
> > and I'm enqueued it for much more intensive testing.  (I'm wishing there 
> > was a better way to acknowledge your contribution to fixing this issue, 
> > especially since you brought up the exact problem this is addressing in 
> > previous emails.)
> > 
> 
> I don't think this patch is safe, for exit_mmap() is calling
> mmu_notifier_invalidate_range_{start,end}() which might block with oom_lock
> held when oom_reap_task_mm() is waiting for oom_lock held by exit_mmap().

One of the reasons that I extracted __oom_reap_task_mm() out of the new 
oom_reap_task_mm() is to avoid the checks that would be unnecessary when 
called from exit_mmap().  In this case, we can ignore the 
mm_has_blockable_invalidate_notifiers() check because exit_mmap() has 
already done mmu_notifier_release().  So I don't think there's a concern 
about __oom_reap_task_mm() blocking while holding oom_lock.  Unless you 
are referring to something else?

> exit_mmap() must not block while holding oom_lock in order to guarantee that
> oom_reap_task_mm() can give up.
> 
> Some suggestion on top of your patch:
> 
>  mm/mmap.c     | 13 +++++--------
>  mm/oom_kill.c | 51 ++++++++++++++++++++++++++-------------------------
>  2 files changed, 31 insertions(+), 33 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 981eed4..7b31357 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3019,21 +3019,18 @@ void exit_mmap(struct mm_struct *mm)
>  		/*
>  		 * Manually reap the mm to free as much memory as possible.
>  		 * Then, as the oom reaper, set MMF_OOM_SKIP to disregard this
> -		 * mm from further consideration.  Taking mm->mmap_sem for write
> -		 * after setting MMF_OOM_SKIP will guarantee that the oom reaper
> -		 * will not run on this mm again after mmap_sem is dropped.
> +		 * mm from further consideration. Setting MMF_OOM_SKIP under
> +		 * oom_lock held will guarantee that the OOM reaper will not
> +		 * run on this mm again.
>  		 *
>  		 * This needs to be done before calling munlock_vma_pages_all(),
>  		 * which clears VM_LOCKED, otherwise the oom reaper cannot
>  		 * reliably test it.
>  		 */
> -		mutex_lock(&oom_lock);
>  		__oom_reap_task_mm(mm);
> -		mutex_unlock(&oom_lock);
> -
> +		mutex_lock(&oom_lock);
>  		set_bit(MMF_OOM_SKIP, &mm->flags);
> -		down_write(&mm->mmap_sem);
> -		up_write(&mm->mmap_sem);
> +		mutex_unlock(&oom_lock);
>  	}
>  
>  	if (mm->locked_vm) {
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 8ba6cb8..9a29df8 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -523,21 +523,15 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  {
>  	bool ret = true;
>  
> +	mutex_lock(&oom_lock);
> +
>  	/*
> -	 * We have to make sure to not race with the victim exit path
> -	 * and cause premature new oom victim selection:
> -	 * oom_reap_task_mm		exit_mm
> -	 *   mmget_not_zero
> -	 *				  mmput
> -	 *				    atomic_dec_and_test
> -	 *				  exit_oom_victim
> -	 *				[...]
> -	 *				out_of_memory
> -	 *				  select_bad_process
> -	 *				    # no TIF_MEMDIE task selects new victim
> -	 *  unmap_page_range # frees some memory
> +	 * MMF_OOM_SKIP is set by exit_mmap() when the OOM reaper can't
> +	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
> +	 * under oom_lock held.
>  	 */
> -	mutex_lock(&oom_lock);
> +	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> +		goto unlock_oom;
>  
>  	if (!down_read_trylock(&mm->mmap_sem)) {
>  		ret = false;
> @@ -557,18 +551,6 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  		goto unlock_oom;
>  	}
>  
> -	/*
> -	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
> -	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
> -	 * under mmap_sem for reading because it serializes against the
> -	 * down_write();up_write() cycle in exit_mmap().
> -	 */
> -	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
> -		up_read(&mm->mmap_sem);
> -		trace_skip_task_reaping(tsk->pid);
> -		goto unlock_oom;
> -	}
> -
>  	trace_start_task_reaping(tsk->pid);
>  
>  	__oom_reap_task_mm(mm);
> @@ -610,8 +592,27 @@ static void oom_reap_task(struct task_struct *tsk)
>  	/*
>  	 * Hide this mm from OOM killer because it has been either reaped or
>  	 * somebody can't call up_write(mmap_sem).
> +	 *
> +	 * We have to make sure to not cause premature new oom victim selection:
> +	 *
> +	 * __alloc_pages_may_oom()     oom_reap_task_mm()/exit_mmap()
> +	 *   mutex_trylock(&oom_lock)
> +	 *   get_page_from_freelist(ALLOC_WMARK_HIGH) # fails
> +	 *                               unmap_page_range() # frees some memory
> +	 *                               set_bit(MMF_OOM_SKIP)
> +	 *   out_of_memory()
> +	 *     select_bad_process()
> +	 *       test_bit(MMF_OOM_SKIP) # selects new oom victim
> +	 *   mutex_unlock(&oom_lock)
> +	 *
> +	 * Setting MMF_OOM_SKIP under oom_lock held will guarantee that the
> +	 * last second alocation attempt is done by __alloc_pages_may_oom()
> +	 * before out_of_memory() selects next OOM victim by finding
> +	 * MMF_OOM_SKIP.
>  	 */
> +	mutex_lock(&oom_lock);
>  	set_bit(MMF_OOM_SKIP, &mm->flags);
> +	mutex_unlock(&oom_lock);
>  
>  	/* Drop a reference taken by wake_oom_reaper */
>  	put_task_struct(tsk);
