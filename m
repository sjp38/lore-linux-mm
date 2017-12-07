Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4486B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 16:22:34 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id k186so313435ith.1
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 13:22:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h123sor62293itb.119.2017.12.07.13.22.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 13:22:33 -0800 (PST)
Date: Thu, 7 Dec 2017 13:22:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with
 exit_mmap
In-Reply-To: <20171207082801.GB20234@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1712071315570.135101@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com> <20171206090019.GE16386@dhcp22.suse.cz> <201712070720.vB77KlBQ009754@www262.sakura.ne.jp> <20171207082801.GB20234@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 7 Dec 2017, Michal Hocko wrote:

> Very well spotted! It could be any task in fact (e.g. somebody reading
> from /proc/<pid> file which requires mm_struct).
> 
> oom_reaper		oom_victim		task
> 						mmget_not_zero
> 			exit_mmap
> 			  mmput
> __oom_reap_task_mm				mmput
>   						  __mmput
> 						    exit_mmap
> 						      remove_vma
>   unmap_page_range
> 
> So we need a more robust test for the oom victim. Your suggestion is
> basically what I came up with originally [1] and which was deemed
> ineffective because we took the mmap_sem even for regular paths and
> Kirill was afraid this adds some unnecessary cycles to the exit path
> which is quite hot.
> 

Yes, I can confirm that in all crashes that we have analyzed so far that 
MMF_OOM_SKIP is actually set at the time that oom_reaper causes BUGs of 
various stack traces all originating from unmap_page_range() which is 
certainly not supposed to happen.

> So I guess we have to do something else instead. We have to store the
> oom flag to the mm struct as well. Something like the patch below.
> 
> [1] http://lkml.kernel.org/r/20170724072332.31903-1-mhocko@kernel.org
> ---
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 27cd36b762b5..b7668b5d3e14 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -77,6 +77,11 @@ static inline bool tsk_is_oom_victim(struct task_struct * tsk)
>  	return tsk->signal->oom_mm;
>  }
>  
> +static inline bool mm_is_oom_victim(struct mm_struct *mm)
> +{
> +	return test_bit(MMF_OOM_VICTIM, &mm->flags);
> +}
> +
>  /*
>   * Checks whether a page fault on the given mm is still reliable.
>   * This is no longer true if the oom reaper started to reap the
> diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
> index 9c8847395b5e..da673ca66e7a 100644
> --- a/include/linux/sched/coredump.h
> +++ b/include/linux/sched/coredump.h
> @@ -68,8 +68,9 @@ static inline int get_dumpable(struct mm_struct *mm)
>  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
>  #define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
>  #define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
> -#define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
> -#define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
> +#define MMF_OOM_VICTIM		23	/* mm is the oom victim */
> +#define MMF_HUGE_ZERO_PAGE	24      /* mm has ever used the global huge zero page */
> +#define MMF_DISABLE_THP		25	/* disable THP for all VMAs */
>  #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
>  
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\

Could we not adjust the bit values, but simply add new one for 
MMF_OOM_VICTIM?  We have automated tools that look at specific bits in 
mm->flags and it would be nice to not have them be inconsistent between 
kernel versions.  Not absolutely required, but nice to avoid.

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 476e810cf100..d00a06248ef1 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3005,7 +3005,7 @@ void exit_mmap(struct mm_struct *mm)
>  	unmap_vmas(&tlb, vma, 0, -1);
>  
>  	set_bit(MMF_OOM_SKIP, &mm->flags);
> -	if (unlikely(tsk_is_oom_victim(current))) {
> +	if (unlikely(mm_is_oom_victim(mm))) {
>  		/*
>  		 * Wait for oom_reap_task() to stop working on this
>  		 * mm. Because MMF_OOM_SKIP is already set before
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3b0d0fed8480..e4d290b6804b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -666,8 +666,10 @@ static void mark_oom_victim(struct task_struct *tsk)
>  		return;
>  
>  	/* oom_mm is bound to the signal struct life time. */
> -	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
> +	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
>  		mmgrab(tsk->signal->oom_mm);
> +		set_bit(MMF_OOM_VICTIM, &mm->flags);
> +	}
>  
>  	/*
>  	 * Make sure that the task is woken up from uninterruptible sleep

Looks good, I see the other email with the same functional change plus a 
follow-up based on a suggestion by Tetsuo.  I'll test it alongside a 
change to not adjust existing MMF_* bit numbers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
