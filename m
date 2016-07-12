Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 02DE86B0260
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:56:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so15378679wmr.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:56:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o82si3898995wmg.65.2016.07.12.07.56.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 07:56:49 -0700 (PDT)
Date: Tue, 12 Jul 2016 16:56:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 8/8] oom_reaper: Revert "oom_reaper: close race with
 exiting task".
Message-ID: <20160712145647.GR14586@dhcp22.suse.cz>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1468330163-4405-9-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468330163-4405-9-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Tue 12-07-16 22:29:23, Tetsuo Handa wrote:
> We can revert commit e2fe14564d3316d1 ("oom_reaper: close race with
> exiting task") because oom_has_pending_mm() which will return true until
> exit_oom_mm() is called after OOM victim's mm is reclaimed by __mmput()
> or oom_reap_task() can close that race.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 29 ++++-------------------------
>  1 file changed, 4 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index fab0bec..232c1ce 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -476,28 +476,9 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
>  	struct vm_area_struct *vma;
>  	struct zap_details details = {.check_swap_entries = true,
>  				      .ignore_dirty = true};
> -	bool ret = true;
>  
> -	/*
> -	 * We have to make sure to not race with the victim exit path
> -	 * and cause premature new oom victim selection:
> -	 * __oom_reap_task		exit_mm
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
> -
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> -		ret = false;
> -		goto unlock_oom;
> -	}
> +	if (!down_read_trylock(&mm->mmap_sem))
> +		return false;
>  
>  	/*
>  	 * increase mm_users only after we know we will reap something so
> @@ -506,7 +487,7 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
>  	 */
>  	if (!mmget_not_zero(mm)) {
>  		up_read(&mm->mmap_sem);
> -		goto unlock_oom;
> +		return true;
>  	}
>  
>  	tlb_gather_mmu(&tlb, mm, 0, -1);
> @@ -554,9 +535,7 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
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
