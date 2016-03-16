Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD0E6B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 08:03:02 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id l68so69019357wml.1
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 05:03:02 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id g139si4391209wmd.7.2016.03.16.05.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Mar 2016 05:03:00 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id p65so69028144wmp.0
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 05:03:00 -0700 (PDT)
Date: Wed, 16 Mar 2016 13:02:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom, oom_reaper: protect oom_reaper_list using simpler
 way
Message-ID: <20160316120258.GB21228@dhcp22.suse.cz>
References: <1458124527-5441-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458124527-5441-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On Wed 16-03-16 19:35:27, Tetsuo Handa wrote:
> "oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task" tried
> to protect oom_reaper_list using MMF_OOM_KILLED flag. But we can do it
> by simply checking tsk->oom_reaper_list != NULL.

I thought you would go with a replacement of the original patch but an
incremental one is also OK. Thanks this looks much more simpler

One could wonder why we do not have to check for oom_reaper_list under
the spinlock but this is not needed because the context calling
wake_oom_reaper is already synchronized.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  include/linux/sched.h | 2 --
>  mm/oom_kill.c         | 8 ++------
>  2 files changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 888bc15..e4dc0c9 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -512,8 +512,6 @@ static inline int get_dumpable(struct mm_struct *mm)
>  #define MMF_HAS_UPROBES		19	/* has uprobes */
>  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
>  
> -#define MMF_OOM_KILLED		21	/* OOM killer has chosen this mm */
> -
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
>  
>  struct sighand_struct {
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 23b8b06..31bbdc6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -543,7 +543,7 @@ static int oom_reaper(void *unused)
>  
>  static void wake_oom_reaper(struct task_struct *tsk)
>  {
> -	if (!oom_reaper_th)
> +	if (!oom_reaper_th || tsk->oom_reaper_list)
>  		return;
>  
>  	get_task_struct(tsk);
> @@ -677,7 +677,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	unsigned int victim_points = 0;
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
> -	bool can_oom_reap;
> +	bool can_oom_reap = true;
>  
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
> @@ -739,10 +739,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	/* Get a reference to safely compare mm after task_unlock(victim) */
>  	mm = victim->mm;
>  	atomic_inc(&mm->mm_count);
> -
> -	/* Make sure we do not try to oom reap the mm multiple times */
> -	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
> -
>  	/*
>  	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
>  	 * the OOM victim from depleting the memory reserves from the user
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
