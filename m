Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 132CF6B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 06:59:22 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so12563583wme.5
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 03:59:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c62si27997246wmc.109.2016.12.12.03.59.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 03:59:20 -0800 (PST)
Date: Mon, 12 Dec 2016 12:59:18 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, oom_reaper: Move oom_lock from __oom_reap_task_mm()
 to oom_reap_task().
Message-ID: <20161212115918.GI18163@dhcp22.suse.cz>
References: <1481540152-7599-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481540152-7599-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Mon 12-12-16 19:55:52, Tetsuo Handa wrote:
> Since commit 862e3073b3eed13f
> ("mm, oom: get rid of signal_struct::oom_victims")
> changed to wait until MMF_OOM_SKIP is set rather than wait while
> TIF_MEMDIE is set, rationale comment for commit e2fe14564d3316d1
> ("oom_reaper: close race with exiting task") needs to be updated.

True.

> While holding oom_lock can make sure that other threads waiting for
> oom_lock at __alloc_pages_may_oom() are given a chance to call
> get_page_from_freelist() after the OOM reaper called unmap_page_range()
> via __oom_reap_task_mm(), it can defer calling of __oom_reap_task_mm().
> 
> Therefore, this patch moves oom_lock from __oom_reap_task_mm() to
> oom_reap_task() (without any functional change). By doing so, the OOM
> killer can call __oom_reap_task_mm() if we don't want to defer calling
> of __oom_reap_task_mm() (e.g. when oom_evaluate_task() aborted by
> finding existing OOM victim's mm without MMF_OOM_SKIP).

But I fail to understand this part of the changelog. It sounds like a
preparatory for other changes. There doesn't seem to be any other user
of __oom_reap_task_mm in the current tree.

Please send a patch which removes the comment which is no longer true
on its own and feel free to add

Acked-by: Michal Hocko <mhocko@suse.com>

but do not make other changes if you do not have any follow up patch
which would benefit from that.

Thanks!


> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 39 +++++++++++++--------------------------
>  1 file changed, 13 insertions(+), 26 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ec9f11d..53b6e0c 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -467,28 +467,9 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	struct vm_area_struct *vma;
>  	struct zap_details details = {.check_swap_entries = true,
>  				      .ignore_dirty = true};
> -	bool ret = true;
> -
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
>  
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> -		ret = false;
> -		goto unlock_oom;
> -	}
> +	if (!down_read_trylock(&mm->mmap_sem))
> +		return false;
>  
>  	/*
>  	 * increase mm_users only after we know we will reap something so
> @@ -497,7 +478,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	 */
>  	if (!mmget_not_zero(mm)) {
>  		up_read(&mm->mmap_sem);
> -		goto unlock_oom;
> +		return true;
>  	}
>  
>  	/*
> @@ -548,9 +529,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	 * put the oom_reaper out of the way.
>  	 */
>  	mmput_async(mm);
> -unlock_oom:
> -	mutex_unlock(&oom_lock);
> -	return ret;
> +	return true;
>  }
>  
>  #define MAX_OOM_REAP_RETRIES 10
> @@ -560,8 +539,16 @@ static void oom_reap_task(struct task_struct *tsk)
>  	struct mm_struct *mm = tsk->signal->oom_mm;
>  
>  	/* Retry the down_read_trylock(mmap_sem) a few times */
> -	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
> +	while (attempts++ < MAX_OOM_REAP_RETRIES) {
> +		bool ret;
> +
> +		mutex_lock(&oom_lock);
> +		ret = __oom_reap_task_mm(tsk, mm);
> +		mutex_unlock(&oom_lock);
> +		if (ret)
> +			break;
>  		schedule_timeout_idle(HZ/10);
> +	}
>  
>  	if (attempts <= MAX_OOM_REAP_RETRIES)
>  		goto done;
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
