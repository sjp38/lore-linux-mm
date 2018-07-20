Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA8A56B000A
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 17:40:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d10-v6so6678802pgv.8
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 14:40:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o3-v6si2484612pld.281.2018.07.20.14.40.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 14:40:38 -0700 (PDT)
Subject: Re: [patch v4] mm, oom: fix unnecessary killing of additional
 processes
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
 <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com>
 <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1807201314230.231119@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <ca34b123-5c81-569f-85ea-4851bc569962@i-love.sakura.ne.jp>
Date: Sat, 21 Jul 2018 05:43:15 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807201314230.231119@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/07/21 5:14, David Rientjes wrote:
> diff --git a/mm/mmap.c b/mm/mmap.c
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3066,25 +3066,27 @@ void exit_mmap(struct mm_struct *mm)
>  	if (unlikely(mm_is_oom_victim(mm))) {
>  		/*
>  		 * Manually reap the mm to free as much memory as possible.
> -		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
> -		 * this mm from further consideration.  Taking mm->mmap_sem for
> -		 * write after setting MMF_OOM_SKIP will guarantee that the oom
> -		 * reaper will not run on this mm again after mmap_sem is
> -		 * dropped.
> -		 *
>  		 * Nothing can be holding mm->mmap_sem here and the above call
>  		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
>  		 * __oom_reap_task_mm() will not block.
>  		 *
> +		 * This sets MMF_UNSTABLE to avoid racing with the oom reaper.
>  		 * This needs to be done before calling munlock_vma_pages_all(),
>  		 * which clears VM_LOCKED, otherwise the oom reaper cannot
> -		 * reliably test it.
> +		 * reliably test for it.  If the oom reaper races with
> +		 * munlock_vma_pages_all(), this can result in a kernel oops if
> +		 * a pmd is zapped, for example, after follow_page_mask() has
> +		 * checked pmd_none().
>  		 */
>  		mutex_lock(&oom_lock);
>  		__oom_reap_task_mm(mm);
>  		mutex_unlock(&oom_lock);

I don't like holding oom_lock for full teardown of an mm, for an OOM victim's mm
might have multiple TB memory which could take long time.

Of course, forcing someone who triggered __mmput() to pay the full cost is
not nice though, for it even can be a /proc/$pid/ reader, can't it?

>  
> -		set_bit(MMF_OOM_SKIP, &mm->flags);
> +		/*
> +		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
> +		 * guarantee that the oom reaper will not run on this mm again
> +		 * after mmap_sem is dropped.
> +		 */
>  		down_write(&mm->mmap_sem);
>  		up_write(&mm->mmap_sem);
>  	}



> -#define MAX_OOM_REAP_RETRIES 10
>  static void oom_reap_task(struct task_struct *tsk)
>  {
> -	int attempts = 0;
>  	struct mm_struct *mm = tsk->signal->oom_mm;
>  
> -	/* Retry the down_read_trylock(mmap_sem) a few times */
> -	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
> -		schedule_timeout_idle(HZ/10);
> +	/*
> +	 * If this mm has either been fully unmapped, or the oom reaper has
> +	 * given up on it, nothing left to do except drop the refcount.
> +	 */
> +	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> +		goto drop;
>  
> -	if (attempts <= MAX_OOM_REAP_RETRIES ||
> -	    test_bit(MMF_OOM_SKIP, &mm->flags))
> -		goto done;
> +	/*
> +	 * If this mm has already been reaped, doing so again will not likely
> +	 * free additional memory.
> +	 */
> +	if (!test_bit(MMF_UNSTABLE, &mm->flags))
> +		oom_reap_task_mm(tsk, mm);

This is still wrong. If preempted immediately after set_bit(MMF_UNSTABLE, &mm->flags) from
__oom_reap_task_mm() from exit_mmap(), oom_reap_task() can give up before reclaiming any memory.
test_bit(MMF_UNSTABLE, &mm->flags) has to be done under oom_lock serialization, and
I don't like holding oom_lock while calling __oom_reap_task_mm(mm).

>  
> -	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> -		task_pid_nr(tsk), tsk->comm);
> -	debug_show_all_locks();
> +	if (time_after_eq(jiffies, mm->oom_free_expire)) {
> +		if (!test_bit(MMF_OOM_SKIP, &mm->flags)) {
> +			pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> +				task_pid_nr(tsk), tsk->comm);
> +			debug_show_all_locks();
>  
> -done:
> -	tsk->oom_reaper_list = NULL;
> +			/*
> +			 * Reaping has failed for the timeout period, so give up
> +			 * and allow additional processes to be oom killed.
> +			 */
> +			set_bit(MMF_OOM_SKIP, &mm->flags);
> +		}
> +		goto drop;
> +	}



> @@ -645,25 +657,60 @@ static int oom_reaper(void *unused)
>  	return 0;
>  }
>  
> +/*
> + * Millisecs to wait for an oom mm to free memory before selecting another
> + * victim.
> + */
> +static u64 oom_free_timeout_ms = 1000;
>  static void wake_oom_reaper(struct task_struct *tsk)
>  {
> -	/* tsk is already queued? */
> -	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
> +	unsigned long expire = jiffies + msecs_to_jiffies(oom_free_timeout_ms);
> +
> +	if (!expire)
> +		expire++;
> +	/*
> +	 * Set the reap timeout; if it's already set, the mm is enqueued and
> +	 * this tsk can be ignored.
> +	 */
> +	if (cmpxchg(&tsk->signal->oom_mm->oom_free_expire, 0UL, expire))
>  		return;

We don't need this if we do from mark_oom_victim() like my series does.

>  
>  	get_task_struct(tsk);
>  
>  	spin_lock(&oom_reaper_lock);
> -	tsk->oom_reaper_list = oom_reaper_list;
> -	oom_reaper_list = tsk;
> +	list_add(&tsk->oom_reap_list, &oom_reaper_list);
>  	spin_unlock(&oom_reaper_lock);
>  	trace_wake_reaper(tsk->pid);
>  	wake_up(&oom_reaper_wait);
>  }
