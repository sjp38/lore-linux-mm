Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AC71B6B0078
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 04:36:43 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o1H9abio007908
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:36:37 GMT
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by kpbe11.cbf.corp.google.com with ESMTP id o1H9aZwJ029271
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 03:36:36 -0600
Received: by pwi6 with SMTP id 6so71026pwi.21
        for <linux-mm@kvack.org>; Wed, 17 Feb 2010 01:36:35 -0800 (PST)
Date: Wed, 17 Feb 2010 01:36:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] Kill existing current task quickly
In-Reply-To: <28c262361002162226k7ec561cenf84f494618fa8c54@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1002170128230.30931@chino.kir.corp.google.com>
References: <1266335957.1709.67.camel@barrios-desktop> <alpine.DEB.2.00.1002161357170.23037@chino.kir.corp.google.com> <28c262361002162226k7ec561cenf84f494618fa8c54@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, Minchan Kim wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3618be3..d5e3d70 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -32,6 +32,8 @@ int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
>  int sysctl_oom_dump_tasks;
>  static DEFINE_SPINLOCK(zone_scan_lock);
> +
> +unsigned int nr_memdie; /* count of TIF_MEMDIE processes */
>  /* #define DEBUG */
> 
>  /*
> @@ -295,6 +297,8 @@ static struct task_struct
> *select_bad_process(unsigned long *ppoints,
> 
>                         chosen = p;
>                         *ppoints = ULONG_MAX;
> +                       if (nr_memdie == 0)
> +                               break;
>                 }
> 
>                 if (p->signal->oom_adj == OOM_DISABLE)

Nack, finding a candidate task with TIF_MEMDIE set is not the only time we 
return ERR_PTR(-1UL) from select_bad_process(): we also do it if any other 
task other than current is PF_EXITING.  Thus, we _must_ continue the 
tasklist scan to avoid needlessly killing current simply because it was 
the first PF_EXITING task in the tasklist.

> @@ -403,8 +407,6 @@ static void __oom_kill_task(struct task_struct *p,
> int verbose)
>                        K(p->mm->total_vm),
>                        K(get_mm_counter(p->mm, MM_ANONPAGES)),
>                        K(get_mm_counter(p->mm, MM_FILEPAGES)));
> -       task_unlock(p);
> -
>         /*
>          * We give our sacrificial lamb high priority and access to
>          * all the memory it needs. That way it should be able to
> @@ -412,7 +414,11 @@ static void __oom_kill_task(struct task_struct
> *p, int verbose)
>          */
>         p->rt.time_slice = HZ;
>         set_tsk_thread_flag(p, TIF_MEMDIE);
> -
> +       /*
> +        * nr_memdie is protected by task_lock.
> +        */
> +       nr_memdie++;
> +       task_unlock(p);
>         force_sig(SIGKILL, p);
>  }
> 

task_lock() is a per-task entity, i.e. each task_struct has an alloc_lock 
spinlock.  This cannot protect a global variable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
