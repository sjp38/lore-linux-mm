Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1275D6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:21:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l6so50110477wml.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:21:49 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id l125si6231869wmg.18.2016.04.14.04.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 04:21:47 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n3so21939048wmn.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:21:47 -0700 (PDT)
Date: Thu, 14 Apr 2016 13:21:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom_reaper: Use try_oom_reaper() for reapability test.
Message-ID: <20160414112146.GD2850@dhcp22.suse.cz>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu 14-04-16 19:56:30, Tetsuo Handa wrote:
> Assuming that try_oom_reaper() is correctly implemented, we should use
> try_oom_reaper() for testing "whether the OOM reaper is allowed to reap
> the OOM victim's memory" rather than "whether the OOM killer is allowed
> to send SIGKILL to thread groups sharing the OOM victim's memory",
> for the OOM reaper is allowed to reap the OOM victim's memory even if
> that memory is shared by OOM_SCORE_ADJ_MIN but already-killed-or-exiting
> thread groups.

So you prefer to crawl over the whole task list again just to catch a
really unlikely case where the OOM_SCORE_ADJ_MIN mm sharing task was
already exiting? Under which workload does this matter?

The patch seems correct I just do not see any point in it because I do
not think it handles any real life situation. I basically consider any
workload where only _certain_ thread(s) or process(es) sharing the mm have
OOM_SCORE_ADJ_MIN set as invalid. Why should we care about those? This
requires root to cripple the system. Or am I missing a valid
configuration where this would make any sense?

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7098104..e78818d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -648,10 +648,6 @@ subsys_initcall(oom_init)
>  static void try_oom_reaper(struct task_struct *tsk)
>  {
>  }
> -
> -static void wake_oom_reaper(struct task_struct *tsk)
> -{
> -}
>  #endif
>  
>  /**
> @@ -741,7 +737,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	unsigned int victim_points = 0;
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
> -	bool can_oom_reap = true;
>  
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
> @@ -833,22 +828,18 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			continue;
>  		if (same_thread_group(p, victim))
>  			continue;
> -		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
> -		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> -			/*
> -			 * We cannot use oom_reaper for the mm shared by this
> -			 * process because it wouldn't get killed and so the
> -			 * memory might be still used.
> -			 */
> -			can_oom_reap = false;
> +		if (unlikely(p->flags & PF_KTHREAD))
>  			continue;
> -		}
> +		if (is_global_init(p))
> +			continue;
> +		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +			continue;
> +
>  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>  	}
>  	rcu_read_unlock();
>  
> -	if (can_oom_reap)
> -		wake_oom_reaper(victim);
> +	try_oom_reaper(victim);
>  
>  	mmdrop(mm);
>  	put_task_struct(victim);
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
