Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3E06B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 03:12:13 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yl2so146455273pac.2
        for <linux-mm@kvack.org>; Fri, 20 May 2016 00:12:13 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n11si25983342pfa.84.2016.05.20.00.12.11
        for <linux-mm@kvack.org>;
        Fri, 20 May 2016 00:12:12 -0700 (PDT)
Date: Fri, 20 May 2016 16:12:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the
 oom reaper context
Message-ID: <20160520071211.GC6808@bbox>
References: <20160520013053.GB2224@bbox>
 <20160520061658.GB19172@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20160520061658.GB19172@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, May 20, 2016 at 08:16:59AM +0200, Michal Hocko wrote:
> On Fri 20-05-16 10:30:53, Minchan Kim wrote:
> > Forking new thread because my comment is not related to this patch's
> > purpose but found a thing during reading this patch.
> > 
> > On Tue, Apr 26, 2016 at 04:04:30PM +0200, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > Tetsuo has properly noted that mmput slow path might get blocked waiting
> > > for another party (e.g. exit_aio waits for an IO). If that happens the
> > > oom_reaper would be put out of the way and will not be able to process
> > > next oom victim. We should strive for making this context as reliable
> > > and independent on other subsystems as much as possible.
> > > 
> > > Introduce mmput_async which will perform the slow path from an async
> > > (WQ) context. This will delay the operation but that shouldn't be a
> > > problem because the oom_reaper has reclaimed the victim's address space
> > > for most cases as much as possible and the remaining context shouldn't
> > > bind too much memory anymore. The only exception is when mmap_sem
> > > trylock has failed which shouldn't happen too often.
> > > 
> > > The issue is only theoretical but not impossible.
> > 
> > The mmput_async is used for only OOM reaper which is enabled on CONFIG_MMU.
> > So until someone who want to use mmput_async in !CONFIG_MMU come out,
> > we could save sizeof(struct work_struct) per mm in !CONFIG_MMU.
> 
> You are right. What about the following?
> ---
> From 8f8a34bf00882bfc0b557ed79e0e9e956ac9d217 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 20 May 2016 08:14:39 +0200
> Subject: [PATCH] mmotm:
>  mm-oom_reaper-do-not-mmput-synchronously-from-the-oom-reaper-context-fix
> 
> mmput_async is currently used only from the oom_reaper which is defined
> only for CONFIG_MMU. We can save work_struct in mm_struct for
> !CONFIG_MMU.
> 
> Reported-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Found a typo below although it was not caused by this patch.
My brand new glasses are really good for me.

> ---
>  include/linux/mm_types.h | 2 ++
>  include/linux/sched.h    | 2 ++
>  kernel/fork.c            | 2 ++
>  3 files changed, 6 insertions(+)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index ab142ace96f3..a16dcb2efca4 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -514,7 +514,9 @@ struct mm_struct {
>  #ifdef CONFIG_HUGETLB_PAGE
>  	atomic_long_t hugetlb_usage;
>  #endif
> +#ifdef CONFIG_MMU
>  	struct work_struct async_put_work;
> +#endif
>  };
>  
>  static inline void mm_init_cpumask(struct mm_struct *mm)
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index df8778e72211..11b31ded65cf 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2604,10 +2604,12 @@ static inline void mmdrop(struct mm_struct * mm)
>  
>  /* mmput gets rid of the mappings and all user-space */
>  extern void mmput(struct mm_struct *);
> +#ifdef CONFIG_MMU
>  /* same as above but performs the slow path from the async kontext. Can

                                                              c

>   * be called from the atomic context as well
>   */
>  extern void mmput_async(struct mm_struct *);
> +#endif
>  
>  /* Grab a reference to a task's mm, if it is not already going away */
>  extern struct mm_struct *get_task_mm(struct task_struct *task);
> diff --git a/kernel/fork.c b/kernel/fork.c
> index e1dc6b02ac8b..1e3dc3af6845 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -732,6 +732,7 @@ void mmput(struct mm_struct *mm)
>  }
>  EXPORT_SYMBOL_GPL(mmput);
>  
> +#ifdef CONFIG_MMU
>  static void mmput_async_fn(struct work_struct *work)
>  {
>  	struct mm_struct *mm = container_of(work, struct mm_struct, async_put_work);
> @@ -745,6 +746,7 @@ void mmput_async(struct mm_struct *mm)
>  		schedule_work(&mm->async_put_work);
>  	}
>  }
> +#endif
>  
>  /**
>   * set_mm_exe_file - change a reference to the mm's executable file
> -- 
> 2.8.1
> 
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
