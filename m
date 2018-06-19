Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE1F16B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 20:27:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u16-v6so9365637pfm.15
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 17:27:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s65-v6si15964384pfe.290.2018.06.18.17.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 17:27:34 -0700 (PDT)
Date: Mon, 18 Jun 2018 17:27:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional
 processes
Message-Id: <20180618172733.39322643725b196ff4e64703@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
	<alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 14 Jun 2018 13:42:59 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
> it cannot reap an mm.  This can happen for a variety of reasons,
> including:
> 
>  - the inability to grab mm->mmap_sem in a sufficient amount of time,
> 
>  - when the mm has blockable mmu notifiers that could cause the oom reaper
>    to stall indefinitely,

Maybe we should have more than one oom reaper thread?  I assume the
probability of the oom reaper thread blocking on an mmu notifier is
small, so perhaps just dive in and hope for the best.  If the oom
reaper gets stuck then there's another thread ready to take over.  And
revisit the decision to use a kernel thread instead of workqueues.

> but we can also add a third when the oom reaper can "reap" an mm but doing
> so is unlikely to free any amount of memory:
> 
>  - when the mm's memory is fully mlocked.
> 
> When all memory is mlocked, the oom reaper will not be able to free any
> substantial amount of memory.  It sets MMF_OOM_SKIP before the victim can
> unmap and free its memory in exit_mmap() and subsequent oom victims are
> chosen unnecessarily.  This is trivial to reproduce if all eligible
> processes on the system have mlocked their memory: the oom killer calls
> panic() even though forward progress can be made.
> 
> This is the same issue where the exit path sets MMF_OOM_SKIP before
> unmapping memory and additional processes can be chosen unnecessarily
> because the oom killer is racing with exit_mmap().

So what's actually happening here.  A process has a large amount of
mlocked memory, it has been oom-killed and it is in the process of
releasing its memory and exiting, yes?

If so, why does this task set MMF_OOM_SKIP on itself?  Why aren't we
just patiently waiting for its attempt to release meory?

> We can't simply defer setting MMF_OOM_SKIP, however, because if there is
> a true oom livelock in progress, it never gets set and no additional
> killing is possible.

I guess that's my answer.  What causes this livelock?  Process looping
in alloc_pages while holding a lock the oom victim wants?

> To fix this, this patch introduces a per-mm reaping timeout, initially set
> at 10s.  It requires that the oom reaper's list becomes a properly linked
> list so that other mm's may be reaped while waiting for an mm's timeout to
> expire.
> 
> This replaces the current timeouts in the oom reaper: (1) when trying to
> grab mm->mmap_sem 10 times in a row with HZ/10 sleeps in between and (2)
> a HZ sleep if there are blockable mmu notifiers.  It extends it with
> timeout to allow an oom victim to reach exit_mmap() before choosing
> additional processes unnecessarily.
> 
> The exit path will now set MMF_OOM_SKIP only after all memory has been
> freed, so additional oom killing is justified,

That seems sensible, but why set MMF_OOM_SKIP at all?

> and rely on MMF_UNSTABLE to
> determine when it can race with the oom reaper.
> 
> The oom reaper will now set MMF_OOM_SKIP only after the reap timeout has
> lapsed because it can no longer guarantee forward progress.
> 
> The reaping timeout is intentionally set for a substantial amount of time
> since oom livelock is a very rare occurrence and it's better to optimize
> for preventing additional (unnecessary) oom killing than a scenario that
> is much more unlikely.

What happened to the old idea of permitting the task which is blocking
the oom victim to access additional reserves?

Come to that, what happened to the really really old Andreaidea of not
looping in the page allocator anyway?  Return NULL instead...

I dunno, I'm thrashing around here.  We seem to be piling mess on top
of mess and then being surprised that the result is a mess.

> +#ifdef CONFIG_MMU
> +	/* When to give up on oom reaping this mm */
> +	unsigned long reap_timeout;

"timeout" implies "interval".  To me, anyway.  This is an absolute
time, so something like reap_time would be clearer.  Along with a
comment explaining that the units are in jiffies.

> +#endif
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>  	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
>  #endif
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1163,7 +1163,7 @@ struct task_struct {
>  #endif
>  	int				pagefault_disabled;
>  #ifdef CONFIG_MMU
> -	struct task_struct		*oom_reaper_list;
> +	struct list_head		oom_reap_list;

Can we have a comment explaining its locking.

>  #endif
>  #ifdef CONFIG_VMAP_STACK
>  	struct vm_struct		*stack_vm_area;
>
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3059,11 +3059,10 @@ void exit_mmap(struct mm_struct *mm)
>  	if (unlikely(mm_is_oom_victim(mm))) {
>  		/*
>  		 * Manually reap the mm to free as much memory as possible.
> -		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
> -		 * this mm from further consideration.  Taking mm->mmap_sem for
> -		 * write after setting MMF_OOM_SKIP will guarantee that the oom
> -		 * reaper will not run on this mm again after mmap_sem is
> -		 * dropped.
> +		 * Then, set MMF_UNSTABLE to avoid racing with the oom reaper.
> +		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
> +		 * guarantee that the oom reaper will not run on this mm again
> +		 * after mmap_sem is dropped.

Comment should explain *why* we don't want the reaper to run on this mm
again.

>
> ...
>
