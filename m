Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE1A96B02B4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:52:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id v193so16890696itc.10
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:52:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w65si2056371ita.22.2017.06.27.03.52.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 03:52:13 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170626130346.26314-1-mhocko@kernel.org>
In-Reply-To: <20170626130346.26314-1-mhocko@kernel.org>
Message-Id: <201706271952.FEB21375.SFJFHOQLOtVOMF@I-love.SAKURA.ne.jp>
Date: Tue, 27 Jun 2017 19:52:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, andrea@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> David has noticed that the oom killer might kill additional tasks while
> the existing victim hasn't terminated yet because the oom_reaper marks
> the curent victim MMF_OOM_SKIP too early when mm->mm_users dropped down
> to 0. The race is as follows
> 
> oom_reap_task				do_exit
> 					  exit_mm
>   __oom_reap_task_mm
> 					    mmput
> 					      __mmput
>     mmget_not_zero # fails
>     						exit_mmap # frees memory
>   set_bit(MMF_OOM_SKIP)
> 
> Currently we are try to reduce a risk of this race by taking oom_lock
> and wait for out_of_memory sleep while holding the lock to give the
> victim some time to exit. This is quite suboptimal approach because
> there is no guarantee the victim (especially a large one) will manage
> to unmap its address space and free enough memory to the particular oom
> domain which needs a memory (e.g. a specific NUMA node).
> 
> Fix this problem by allowing __oom_reap_task_mm and __mmput path to
> race. __oom_reap_task_mm is basically MADV_DONTNEED and that is allowed
> to run in parallel with other unmappers (hence the mmap_sem for read).
> The only tricky part is we have to exclude page tables tear down and all
> operations which modify the address space in the __mmput path. exit_mmap
> doesn't expect any other users so it doesn't use any locking. Nothing
> really forbids us to use mmap_sem for write, though. In fact we are
> already relying on this lock earlier in the __mmput path to synchronize
> with ksm and khugepaged.
> 
> Take the exclusive mmap_sem when calling free_pgtables and destroying
> vmas to sync with __oom_reap_task_mm which take the lock for read. All
> other operations can safely race with the parallel unmap.
> 
> Reported-by: David Rientjes <rientjes@google.com>
> Fixes: 26db62f179d1 ("oom: keep mm of the killed task available")
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> I am sending this as an RFC because I am not yet sure I haven't missed
> something subtle here but the appoach should work in principle. I have
> run it through some of my OOM stress tests to see if anything blows up
> and it all went smoothly.
> 
> The issue has been brought up by David [1]. There were some attempts to
> address it in oom proper [2][3] but the first one would cause problems
> on their own [4] while the later is just too hairy.
> 
> Thoughts, objections, alternatives?

I wonder why you prefer timeout based approach. Your patch will after all
set MMF_OOM_SKIP if operations between down_write() and up_write() took
more than one second. lock_anon_vma_root() from unlink_anon_vmas() from
free_pgtables() for example calls down_write()/up_write(). unlink_file_vma()
 from free_pgtables() for another example calls down_write()/up_write().
This means that it might happen that exit_mmap() takes more than one second
with mm->mmap_sem held for write, doesn't this?

The worst situation is that no memory is released by uprobe_clear_state(), exit_aio(),
ksm_exit(), khugepaged_exit() and operations before down_write(&mm->mmap_sem), and then
one second elapses before some memory is released after down_write(&mm->mmap_sem).
In that case, down_write()/up_write() in your patch helps nothing.

Less worst situation is that no memory is released by uprobe_clear_state(), exit_aio(),
ksm_exit(), khugepaged_exit() and operations before down_write(&mm->mmap_sem), and then
only some memory is released after down_write(&mm->mmap_sem) before one second elapses.
Someone might think that this is still premature.

More likely situation is that down_read_trylock(&mm->mmap_sem) in __oom_reap_task_mm()
succeeds before exit_mmap() calls down_write(&mm->mmap_sem) (especially true if we remove
mutex_lock(&oom_lock) from __oom_reap_task_mm()). In this case, your patch merely gives
uprobe_clear_state(), exit_aio(), ksm_exit(), khugepaged_exit() and operations before
down_write(&mm->mmap_sem) some time to release memory, for your patch will after all set
MMF_OOM_SKIP immediately after __oom_reap_task_mm() called up_read(&mm->mmap_sem). If we
assume that majority of memory is released by operations between
down_write(&mm->mmap_sem)/up_write(&mm->mmap_sem) in exit_mm(), this is not a preferable
behavior.

My patch [3] cannot give uprobe_clear_state(), exit_aio(), ksm_exit(), khugepaged_exit()
and exit_mm() some time to release memory. But [3] can guarantee that all memory which
the OOM reaper can reclaim is reclaimed before setting MMF_OOM_SKIP.

If we wait for another second after setting MMF_OOM_SKIP, we could give operations between
down_write(&mm->mmap_sem)/up_write(&mm->mmap_sem) in exit_mm() (in your patch) or __mmput()
(in my patch) some more chance to reclaim memory before next OOM victim is selected.

> 
> [1] http://lkml.kernel.org/r/alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com
> [2] http://lkml.kernel.org/r/201706171417.JHG48401.JOQLHMFSVOOFtF@I-love.SAKURA.ne.jp
> [3] http://lkml.kernel.org/r/201706220053.v5M0rmOU078764@www262.sakura.ne.jp
> [4] http://lkml.kernel.org/r/201706210217.v5L2HAZc081021@www262.sakura.ne.jp
> 
>  mm/mmap.c     |  7 +++++++
>  mm/oom_kill.c | 40 ++--------------------------------------
>  2 files changed, 9 insertions(+), 38 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 3bd5ecd20d4d..253808e716dc 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2962,6 +2962,11 @@ void exit_mmap(struct mm_struct *mm)
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>  	unmap_vmas(&tlb, vma, 0, -1);
>  
> +	/*
> +	 * oom reaper might race with exit_mmap so make sure we won't free
> +	 * page tables or unmap VMAs under its feet
> +	 */
> +	down_write(&mm->mmap_sem);
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>  	tlb_finish_mmu(&tlb, 0, -1);
>  
> @@ -2974,7 +2979,9 @@ void exit_mmap(struct mm_struct *mm)
>  			nr_accounted += vma_pages(vma);
>  		vma = remove_vma(vma);
>  	}
> +	mm->mmap = NULL;
>  	vm_unacct_memory(nr_accounted);
> +	up_write(&mm->mmap_sem);
>  }
>  
>  /* Insert vm structure into process list sorted by address
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0e2c925e7826..5dc0ff22d567 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -472,36 +472,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	struct vm_area_struct *vma;
>  	bool ret = true;

This "ret" is redundant.

>  
> -	/*
> -	 * We have to make sure to not race with the victim exit path
> -	 * and cause premature new oom victim selection:
> -	 * __oom_reap_task_mm		exit_mm
> -	 *   mmget_not_zero
> -	 *				  mmput
> -	 *				    atomic_dec_and_test
> -	 *				  exit_oom_victim
> -	 *				[...]
> -	 *				out_of_memory
> -	 *				  select_bad_process
> -	 *				    # no TIF_MEMDIE task selects new victim
> -	 *  unmap_page_range # frees some memory
> -	 */
> -	mutex_lock(&oom_lock);

You can remove mutex_lock(&oom_lock) here, but you should use mutex_lock(&oom_lock)
when setting MMF_OOM_SKIP, for below comment in [2] will be still valid.

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

Ideally, we should as well use mutex_lock(&oom_lock) when setting MMF_OOM_SKIP from
__mmput(), for an allocating task does not call get_page_from_freelist() after
confirming that there is no !MMF_OOM_SKIP mm. Or, it would be possible to
let select_bad_process() abort on MMF_OOM_SKIP mm once using another bit.

> -
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> -		ret = false;
> -		goto unlock_oom;
> -	}
> -
> -	/*
> -	 * increase mm_users only after we know we will reap something so
> -	 * that the mmput_async is called only when we have reaped something
> -	 * and delayed __mmput doesn't matter that much
> -	 */
> -	if (!mmget_not_zero(mm)) {
> -		up_read(&mm->mmap_sem);
> -		goto unlock_oom;
> -	}
> +	if (!down_read_trylock(&mm->mmap_sem))
> +		return false;
>  
>  	/*
>  	 * Tell all users of get_user/copy_from_user etc... that the content
> @@ -538,14 +510,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  			K(get_mm_counter(mm, MM_SHMEMPAGES)));
>  	up_read(&mm->mmap_sem);
>  
> -	/*
> -	 * Drop our reference but make sure the mmput slow path is called from a
> -	 * different context because we shouldn't risk we get stuck there and
> -	 * put the oom_reaper out of the way.
> -	 */
> -	mmput_async(mm);
> -unlock_oom:
> -	mutex_unlock(&oom_lock);
>  	return ret;

This is "return true;".

>  }
>  
> -- 
> 2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
