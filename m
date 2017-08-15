Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 416796B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 01:49:38 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y96so36789wrc.10
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 22:49:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l197si747217wma.183.2017.08.14.22.49.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 22:49:37 -0700 (PDT)
Date: Tue, 15 Aug 2017 07:49:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: remove unused mmput_async
Message-ID: <20170815054933.GA26114@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1708141733130.50317@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708141733130.50317@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 14-08-17 17:34:32, David Rientjes wrote:
> After "mm: oom: let oom_reap_task and exit_mmap to run concurrently", 
> mmput_async() is no longer used.  Remove it.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  include/linux/sched/mm.h |  6 ------
>  kernel/fork.c            | 16 ----------------
>  2 files changed, 22 deletions(-)
> 
> diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
> --- a/include/linux/sched/mm.h
> +++ b/include/linux/sched/mm.h
> @@ -84,12 +84,6 @@ static inline bool mmget_not_zero(struct mm_struct *mm)
>  
>  /* mmput gets rid of the mappings and all user-space */
>  extern void mmput(struct mm_struct *);
> -#ifdef CONFIG_MMU
> -/* same as above but performs the slow path from the async context. Can
> - * be called from the atomic context as well
> - */
> -extern void mmput_async(struct mm_struct *);
> -#endif
>  
>  /* Grab a reference to a task's mm, if it is not already going away */
>  extern struct mm_struct *get_task_mm(struct task_struct *task);
> diff --git a/kernel/fork.c b/kernel/fork.c
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -925,22 +925,6 @@ void mmput(struct mm_struct *mm)
>  }
>  EXPORT_SYMBOL_GPL(mmput);
>  
> -#ifdef CONFIG_MMU
> -static void mmput_async_fn(struct work_struct *work)
> -{
> -	struct mm_struct *mm = container_of(work, struct mm_struct, async_put_work);
> -	__mmput(mm);
> -}
> -
> -void mmput_async(struct mm_struct *mm)
> -{
> -	if (atomic_dec_and_test(&mm->mm_users)) {
> -		INIT_WORK(&mm->async_put_work, mmput_async_fn);
> -		schedule_work(&mm->async_put_work);
> -	}
> -}
> -#endif
> -
>  /**
>   * set_mm_exe_file - change a reference to the mm's executable file
>   *
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
