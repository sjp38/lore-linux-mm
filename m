Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 99D1E6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 09:11:28 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id n186so133464246wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 06:11:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 130si4631432wmj.112.2016.03.08.06.11.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 06:11:27 -0800 (PST)
Date: Tue, 8 Mar 2016 15:11:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm,oom: Do not sleep with oom_lock held.
Message-ID: <20160308141125.GI13542@dhcp22.suse.cz>
References: <1457434755-12531-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457434755-12531-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Tue 08-03-16 19:59:15, Tetsuo Handa wrote:
> out_of_memory() can stall effectively forever if a SCHED_IDLE thread
> called out_of_memory() when there are !SCHED_IDLE threads running on
> the same CPU, for schedule_timeout_killable(1) cannot return shortly
> due to scheduling priority on CONFIG_PREEMPT_NONE=y kernels.
> 
> Operations with oom_lock held should complete as soon as possible
> because we might be preserving OOM condition for most of that period
> if we are in OOM condition. SysRq-f can't work if oom_lock is held.
> 
> It would be possible to boost scheduling priority of current thread
> while holding oom_lock, but priority of current thread might be
> manipulated by other threads after boosting. Unless we offload
> operations with oom_lock held to a dedicated kernel thread with high
> priority, addressing this problem using priority manipulation is racy.

As already mentioned whe you posted a similar patch before, this all is
true but the patch doesn't really fixes it so do we really want to have
it in the patch description?
 
> This patch brings schedule_timeout_killable(1) out of oom_lock.

I am not against this change, though, but can we please have a changelog
which doesn't pretend to be a fix while it is not? Also the changelog
should tell us why oom vs. exit races are not more probable now because
the OOM killing context is basically throttling all others right now
which won't be the case anymore. While I believe this shouldn't matter
it should be considered and described.

> This patch does not address OOM notifiers which are blockable.

Also does it really make sense to post the patch alone without
addressing this part?

> Long term we should focus on making the OOM context not preemptible.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

my s-o-b is not really necessary, I have merely tried to show how your
previous patch could be simplified.

> ---
>  mm/oom_kill.c   | 14 +++++++-------
>  mm/page_alloc.c |  7 +++++++
>  2 files changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5d5eca9..c84e784 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -901,15 +901,9 @@ bool out_of_memory(struct oom_control *oc)
>  		dump_header(oc, NULL, NULL);
>  		panic("Out of memory and no killable processes...\n");
>  	}
> -	if (p && p != (void *)-1UL) {
> +	if (p && p != (void *)-1UL)
>  		oom_kill_process(oc, p, points, totalpages, NULL,
>  				 "Out of memory");
> -		/*
> -		 * Give the killed process a good chance to exit before trying
> -		 * to allocate memory again.
> -		 */
> -		schedule_timeout_killable(1);
> -	}
>  	return true;
>  }
>  
> @@ -944,4 +938,10 @@ void pagefault_out_of_memory(void)
>  	}
>  
>  	mutex_unlock(&oom_lock);
> +
> +	/*
> +	 * Give the killed process a good chance to exit before trying
> +	 * to allocate memory again.
> +	 */
> +	schedule_timeout_killable(1);
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1993894..378a346 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2888,6 +2888,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	}
>  out:
>  	mutex_unlock(&oom_lock);
> +	if (*did_some_progress && !page) {
> +		/*
> +		 * Give the killed process a good chance to exit before trying
> +		 * to allocate memory again.
> +		 */
> +		schedule_timeout_killable(1);
> +	}
>  	return page;
>  }
>  
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
