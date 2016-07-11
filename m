Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1156B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 08:15:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so54465478wmr.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 05:15:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j73si8500917wmj.93.2016.07.11.05.15.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 05:15:52 -0700 (PDT)
Date: Mon, 11 Jul 2016 14:15:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/6] mm,oom_reaper: Do not attempt to reap a task twice.
Message-ID: <20160711121550.GE1811@dhcp22.suse.cz>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
 <201607080101.CCE57351.tQFOOVOFJSHMLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607080101.CCE57351.tQFOOVOFJSHMLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Fri 08-07-16 01:01:36, Tetsuo Handa wrote:
> >From 50b3a862b136c783be6ce25e0f22446f15a0ab03 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 8 Jul 2016 00:28:50 +0900
> Subject: [PATCH 2/6] mm,oom_reaper: Do not attempt to reap a task twice.
> 
> "mm, oom_reaper: do not attempt to reap a task twice" tried to give
> OOM reaper one more chance to retry. But since OOM killer or one of
> threads sharing that mm will queue that mm immediately, retrying
> MMF_OOM_NOT_REAPABLE mm is unlikely helpful.

I agree that the usefulness of the flag is rather limited and actually
never shown in practice. Considering it was added as a just-in-case
measure it is really hard to reason about. And I believe this should be
stated in the changelog.

> Let's always set MMF_OOM_REAPED.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

That being said, feel free to add my Acked-by after the changelog is
more clear about the motivation.

> ---
>  include/linux/sched.h |  1 -
>  mm/oom_kill.c         | 15 +++------------
>  2 files changed, 3 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 553af29..c0efd80 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -523,7 +523,6 @@ static inline int get_dumpable(struct mm_struct *mm)
>  #define MMF_HAS_UPROBES		19	/* has uprobes */
>  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
>  #define MMF_OOM_REAPED		21	/* mm has been already reaped */
> -#define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
>  
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 951eb1b..9f0022e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -567,20 +567,11 @@ static void oom_reap_task(struct task_struct *tsk)
>  	if (attempts <= MAX_OOM_REAP_RETRIES)
>  		goto done;
>  
> +	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
> +	set_bit(MMF_OOM_REAPED, &mm->flags);
> +
>  	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
>  		task_pid_nr(tsk), tsk->comm);
> -
> -	/*
> -	 * If we've already tried to reap this task in the past and
> -	 * failed it probably doesn't make much sense to try yet again
> -	 * so hide the mm from the oom killer so that it can move on
> -	 * to another task with a different mm struct.
> -	 */
> -	if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &mm->flags)) {
> -		pr_info("oom_reaper: giving up pid:%d (%s)\n",
> -			task_pid_nr(tsk), tsk->comm);
> -		set_bit(MMF_OOM_REAPED, &mm->flags);
> -	}
>  	debug_show_all_locks();
>  
>  done:
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
