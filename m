Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 504F86B0273
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:38:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f81-v6so1158489pfd.7
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:38:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e65-v6si1257262pfc.336.2018.07.03.07.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:38:42 -0700 (PDT)
Date: Tue, 3 Jul 2018 16:38:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/8] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180703143837.GM16767@dhcp22.suse.cz>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1530627910-3415-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530627910-3415-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue 03-07-18 23:25:02, Tetsuo Handa wrote:
> When I was examining a bug which occurs under CPU + memory pressure, I
> observed that a thread which called out_of_memory() can sleep for minutes
> at schedule_timeout_killable(1) with oom_lock held when many threads are
> doing direct reclaim.
> 
> The whole point of the sleep is to give the OOM victim some time to exit.
> But since commit 27ae357fa82be5ab ("mm, oom: fix concurrent munlock and
> oom reaper unmap, v3") changed the OOM victim to wait for oom_lock in order
> to close race window at exit_mmap(), the whole point of this sleep is lost
> now. We need to make sure that the thread which called out_of_memory() will
> release oom_lock shortly. Therefore, this patch brings the sleep to outside
> of the OOM path.
> 
> Although the sleep will be after all removed by the last patch in this
> series, this patch is meant for ease of backport to stable kernels, for
> we are waiting for patches which can mitigate CVE-2016-10723.

Come on. This is beyond annoying. You have posted this patch few times
and received exactly the same feedback. Do not mindlessly move code
around just because you want to preserve the status quo which you even
demonstrated you do not care to understand.

So NO, NACK and stop this insanity. Even if you remove the move sleep in
a later patch I completely hate how you are trying to make a security
issue out of it.  It simply doesn't mitigate anything! It might help
with !PREEMPT but still doesn't solve any problem.

I have already told you that I am ok with removing the sleep. Not
because it tries to pretend to be a CVE fix. But rather because its
relevance is gone now. See the difference?

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Mitigates: CVE-2016-10723
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  mm/oom_kill.c   | 38 +++++++++++++++++---------------------
>  mm/page_alloc.c |  7 ++++++-
>  2 files changed, 23 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 84081e7..d3fb4e4 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -479,6 +479,21 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
>  static struct task_struct *oom_reaper_list;
>  static DEFINE_SPINLOCK(oom_reaper_lock);
>  
> +/*
> + * We have to make sure not to cause premature new oom victim selection.
> + *
> + * __alloc_pages_may_oom()     oom_reap_task_mm()/exit_mmap()
> + *   mutex_trylock(&oom_lock)
> + *   get_page_from_freelist(ALLOC_WMARK_HIGH) # fails
> + *                               unmap_page_range() # frees some memory
> + *                               set_bit(MMF_OOM_SKIP)
> + *   out_of_memory()
> + *     select_bad_process()
> + *       test_bit(MMF_OOM_SKIP) # selects new oom victim
> + *   mutex_unlock(&oom_lock)
> + *
> + * Therefore, the callers hold oom_lock when calling this function.
> + */
>  void __oom_reap_task_mm(struct mm_struct *mm)
>  {
>  	struct vm_area_struct *vma;
> @@ -523,20 +538,6 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  {
>  	bool ret = true;
>  
> -	/*
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
> -	 */
>  	mutex_lock(&oom_lock);
>  
>  	if (!down_read_trylock(&mm->mmap_sem)) {
> @@ -1077,15 +1078,9 @@ bool out_of_memory(struct oom_control *oc)
>  		dump_header(oc, NULL);
>  		panic("Out of memory and no killable processes...\n");
>  	}
> -	if (oc->chosen && oc->chosen != (void *)-1UL) {
> +	if (oc->chosen && oc->chosen != (void *)-1UL)
>  		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
>  				 "Memory cgroup out of memory");
> -		/*
> -		 * Give the killed process a good chance to exit before trying
> -		 * to allocate memory again.
> -		 */
> -		schedule_timeout_killable(1);
> -	}
>  	return !!oc->chosen;
>  }
>  
> @@ -1111,4 +1106,5 @@ void pagefault_out_of_memory(void)
>  		return;
>  	out_of_memory(&oc);
>  	mutex_unlock(&oom_lock);
> +	schedule_timeout_killable(1);
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1521100..6205d34 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3468,7 +3468,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	 */
>  	if (!mutex_trylock(&oom_lock)) {
>  		*did_some_progress = 1;
> -		schedule_timeout_uninterruptible(1);
>  		return NULL;
>  	}
>  
> @@ -4244,6 +4243,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	/* Retry as long as the OOM killer is making progress */
>  	if (did_some_progress) {
>  		no_progress_loops = 0;
> +		/*
> +		 * This schedule_timeout_*() serves as a guaranteed sleep for
> +		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> +		 */
> +		if (!tsk_is_oom_victim(current))
> +			schedule_timeout_uninterruptible(1);
>  		goto retry;
>  	}
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
