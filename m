Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B6FE96B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:20:55 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id g62so27883260wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:20:55 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id j187si40631264wma.69.2016.02.17.05.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 05:20:54 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id g62so27882743wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:20:54 -0800 (PST)
Date: Wed, 17 Feb 2016 14:20:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm,oom: Re-enable OOM killer using timers.
Message-ID: <20160217132052.GI29196@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171934.DGG57308.FOSFMQVLOtJFHO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602171934.DGG57308.FOSFMQVLOtJFHO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 19:34:46, Tetsuo Handa wrote:
> >From 6f07b71c97766ec111d26c3424bded465ca48195 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 17 Feb 2016 16:37:01 +0900
> Subject: [PATCH 5/6] mm,oom: Re-enable OOM killer using timers.
> 
> We are trying to reduce the possibility of hitting OOM livelock by
> introducing the OOM reaper, but there are situations where the OOM reaper
> cannot reap the victim's memory. We want to introduce the OOM reaper as
> simple as possible and make the OOM reaper better via incremental
> development.
> 
> This patch adds a timer for handling corner cases where a TIF_MEMDIE
> thread got stuck by reasons not handled by the initial version of the
> OOM reaper. Since "mm,oom: exclude TIF_MEMDIE processes from candidates."
> made sure that we won't choose the same OOM victim forever and this patch
> makes sure that the kernel automatically presses SysRq-f upon OOM stalls,
> we will not OOM stall forever as long as the OOM killer is called.

Can we actually start by incremental changes first and only get to this
after we cannot find a proper way to fix existing issues?

I would like to at least make mmap_sem taken for write killable
first. This should allow the oom_reaper to make a forward progress and
allow the OOM killer to select another task when necessary (e.g. the
victim wasn't sitting on a large amount of reclaimable memory). This
has an advantage that the TIF_MEMDIE release is bound to a clearly
defined action rather than a $RANDOM timemout which will always be hard
to justify. We can talk about timeout based solutions after we are able
to livelock the system even after all well defined actions will have
failed. I really consider it premature right now.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ebc6764..fba2c62 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -45,6 +45,11 @@ int sysctl_oom_dump_tasks = 1;
>  
>  DEFINE_MUTEX(oom_lock);
>  
> +static void oomkiller_reset(unsigned long arg)
> +{
> +}
> +static DEFINE_TIMER(oomkiller_victim_wait_timer, oomkiller_reset, 0, 0);
> +
>  #ifdef CONFIG_NUMA
>  /**
>   * has_intersects_mems_allowed() - check task eligiblity for kill
> @@ -299,7 +304,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	 */
>  	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
>  		if (!is_sysrq_oom(oc))
> -			return OOM_SCAN_ABORT;
> +			return timer_pending(&oomkiller_victim_wait_timer) ?
> +				OOM_SCAN_ABORT : OOM_SCAN_CONTINUE;
>  	}
>  	if (!task->mm)
>  		return OOM_SCAN_CONTINUE;
> @@ -452,6 +458,8 @@ void mark_oom_victim(struct task_struct *tsk)
>  	 */
>  	__thaw_task(tsk);
>  	atomic_inc(&oom_victims);
> +	/* Make sure that we won't wait for this task forever. */
> +	mod_timer(&oomkiller_victim_wait_timer, jiffies + 5 * HZ);
>  }
>  
>  /**
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
