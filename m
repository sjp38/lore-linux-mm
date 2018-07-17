Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B178B6B000C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 17:09:42 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k204-v6so2909467ite.1
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:09:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k70-v6si341250ita.20.2018.07.17.14.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 14:09:40 -0700 (PDT)
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp>
Date: Wed, 18 Jul 2018 06:09:24 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch should be dropped from linux-next because it is incorrectly
using MMF_UNSTABLE.

On 2018/06/22 6:35, David Rientjes wrote:
> diff --git a/mm/mmap.c b/mm/mmap.c
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3059,25 +3059,28 @@ void exit_mmap(struct mm_struct *mm)
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
> -		 *
> -		 * This needs to be done before calling munlock_vma_pages_all(),
> -		 * which clears VM_LOCKED, otherwise the oom reaper cannot
> -		 * reliably test it.
>  		 */
>  		mutex_lock(&oom_lock);
>  		__oom_reap_task_mm(mm);
>  		mutex_unlock(&oom_lock);
>  
> -		set_bit(MMF_OOM_SKIP, &mm->flags);
> +		/*
> +		 * Now, set MMF_UNSTABLE to avoid racing with the oom reaper.
> +		 * This needs to be done before calling munlock_vma_pages_all(),
> +		 * which clears VM_LOCKED, otherwise the oom reaper cannot
> +		 * reliably test for it.  If the oom reaper races with
> +		 * munlock_vma_pages_all(), this can result in a kernel oops if
> +		 * a pmd is zapped, for example, after follow_page_mask() has
> +		 * checked pmd_none().
> +		 *
> +		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
> +		 * guarantee that the oom reaper will not run on this mm again
> +		 * after mmap_sem is dropped.
> +		 */
> +		set_bit(MMF_UNSTABLE, &mm->flags);

Since MMF_UNSTABLE is set by __oom_reap_task_mm() from exit_mmap() before start reaping
(because the purpose of MMF_UNSTABLE is to "tell all users of get_user/copy_from_user
etc... that the content is no longer stable"), it cannot be used for a flag for indicating
that the OOM reaper can't work on the mm anymore.

If the oom_lock serialization is removed, the OOM reaper will give up after (by default)
1 second even if current thread is immediately after set_bit(MMF_UNSTABLE, &mm->flags) from
__oom_reap_task_mm() from exit_mmap(). Thus, this patch and the other patch which removes
oom_lock serialization should be dropped.

>  		down_write(&mm->mmap_sem);
>  		up_write(&mm->mmap_sem);
>  	}

> @@ -637,25 +649,57 @@ static int oom_reaper(void *unused)
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
> +	/*
> +	 * Set the reap timeout; if it's already set, the mm is enqueued and
> +	 * this tsk can be ignored.
> +	 */
> +	if (cmpxchg(&tsk->signal->oom_mm->oom_free_expire, 0UL,
> +			jiffies + msecs_to_jiffies(oom_free_timeout_ms)))
>  		return;

"expire" must not be 0 in order to avoid double list_add(). See
https://lore.kernel.org/lkml/201807130620.w6D6KiAJ093010@www262.sakura.ne.jp/T/#u .

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
