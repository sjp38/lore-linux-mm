Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D49146B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 03:16:05 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so80806815wjc.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:16:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qj8si23349120wjb.165.2016.12.07.00.16.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 00:16:04 -0800 (PST)
Date: Wed, 7 Dec 2016 09:15:56 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161207081555.GB17136@dhcp22.suse.cz>
References: <1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Tue 06-12-16 19:33:59, Tetsuo Handa wrote:
> If the OOM killer is invoked when many threads are looping inside the
> page allocator, it is possible that the OOM killer is preempted by other
> threads.

Hmm, the only way I can see this would happen is when the task which
actually manages to take the lock is not invoking the OOM killer for
whatever reason. Is this what happens in your case? Are you able to
trigger this reliably?

> As a result, the OOM killer is unable to send SIGKILL to OOM
> victims and/or wake up the OOM reaper by releasing oom_lock for minutes
> because other threads consume a lot of CPU time for pointless direct
> reclaim.
> 
> ----------
> [ 2802.635229] Killed process 7267 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [ 2802.644296] oom_reaper: reaped process 7267 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [ 2802.650237] Out of memory: Kill process 7268 (a.out) score 999 or sacrifice child
> [ 2803.653052] Killed process 7268 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [ 2804.426183] oom_reaper: reaped process 7268 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [ 2804.432524] Out of memory: Kill process 7269 (a.out) score 999 or sacrifice child
> [ 2805.349380] a.out: page allocation stalls for 10047ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> [ 2805.349383] CPU: 2 PID: 7243 Comm: a.out Not tainted 4.9.0-rc8 #62
> (...snipped...)
> [ 3540.977499]           a.out  7269     22716.893359      5272   120
> [ 3540.977499]         0.000000      1447.601063         0.000000
> [ 3540.977499]  0 0
> [ 3540.977500]  /autogroup-155
> ----------
> 
> This patch adds extra sleeps which is effectively equivalent to
> 
>   if (mutex_lock_killable(&oom_lock) == 0)
>     mutex_unlock(&oom_lock);
> 
> before retrying allocation at __alloc_pages_may_oom() so that the
> OOM killer is not preempted by other threads waiting for the OOM
> killer/reaper to reclaim memory. Since the OOM reaper grabs oom_lock
> due to commit e2fe14564d3316d1 ("oom_reaper: close race with exiting
> task"), waking up other threads before the OOM reaper is woken up by
> directly waiting for oom_lock might not help so much.

So, why don't you simply s@mutex_trylock@mutex_lock_killable@ then?
The trylock is simply an optimistic heuristic to retry while the memory
is being freed. Making this part sync might help for the case you are
seeing.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/page_alloc.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 51cbe1e..e5c1102 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3060,6 +3060,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
>  		.order = order,
>  	};
>  	struct page *page;
> +	static bool wait_more;
>  
>  	*did_some_progress = 0;
>  
> @@ -3070,6 +3071,9 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
>  	if (!mutex_trylock(&oom_lock)) {
>  		*did_some_progress = 1;
>  		schedule_timeout_uninterruptible(1);
> +		while (wait_more)
> +			if (schedule_timeout_killable(1) < 0)
> +				break;
>  		return NULL;
>  	}
>  
> @@ -3109,6 +3113,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
>  		if (gfp_mask & __GFP_THISNODE)
>  			goto out;
>  	}
> +	wait_more = true;
>  	/* Exhausted what can be done so it's blamo time */
>  	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
>  		*did_some_progress = 1;
> @@ -3125,6 +3130,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
>  					ALLOC_NO_WATERMARKS, ac);
>  		}
>  	}
> +	wait_more = false;
>  out:
>  	mutex_unlock(&oom_lock);
>  	return page;

This is a joke, isn't it? Seriously, this made my eyes bleed.

violent NAK!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
