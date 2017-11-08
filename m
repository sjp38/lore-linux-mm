Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CAAE9440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 10:01:26 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y83so2449628wmc.8
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 07:01:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u34si186484edc.94.2017.11.08.07.01.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 07:01:25 -0800 (PST)
Date: Wed, 8 Nov 2017 16:01:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom_reaper: Remove pointless kthread_run() error
 check.
Message-ID: <20171108150124.6hwyizrlbh5frfrb@dhcp22.suse.cz>
References: <1510137800-4602-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510137800-4602-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

Thank you that you have CCed me (as an author of the code)

On Wed 08-11-17 19:43:20, Tetsuo Handa wrote:
> Since oom_init() is called before userspace processes start, memory
> allocation failure for creating the OOM reaper kernel thread will let
> the OOM killer call panic() rather than wake up the OOM reaper.

Which is what I've tried to actually point out back then IIRC but you
have insisted hard so I've added the change to make a forward progress
on the whole work. The check is not harmful because this is not a
fast path but as you say we are likely to panic anyway.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/oom_kill.c | 8 --------
>  1 file changed, 8 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 8dd0e08..85eced9 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -641,9 +641,6 @@ static int oom_reaper(void *unused)
>  
>  static void wake_oom_reaper(struct task_struct *tsk)
>  {
> -	if (!oom_reaper_th)
> -		return;
> -
>  	/* tsk is already queued? */
>  	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
>  		return;
> @@ -661,11 +658,6 @@ static void wake_oom_reaper(struct task_struct *tsk)
>  static int __init oom_init(void)
>  {
>  	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> -	if (IS_ERR(oom_reaper_th)) {
> -		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> -				PTR_ERR(oom_reaper_th));
> -		oom_reaper_th = NULL;
> -	}
>  	return 0;
>  }
>  subsys_initcall(oom_init)
> -- 
> 1.8.3.1
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
