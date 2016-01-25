Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6D16B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:03:43 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id r129so67733870wmr.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:03:43 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id u127si24931579wmd.36.2016.01.25.07.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 07:03:42 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id u188so69437602wmu.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:03:42 -0800 (PST)
Date: Mon, 25 Jan 2016 16:03:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: make oom_killer_disable() killable.
Message-ID: <20160125150340.GE23939@dhcp22.suse.cz>
References: <1453564040-7492-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453564040-7492-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

[CCing Andrew]

On Sun 24-01-16 00:47:20, Tetsuo Handa wrote:
> While oom_killer_disable() is called by freeze_processes() after all user
> threads except the current thread are frozen, it is possible that kernel
> threads invoke the OOM killer and sends SIGKILL to the current thread due
> to sharing the thawed victim's memory. Therefore, checking for SIGKILL is
> preferable than TIF_MEMDIE.

This alone wouldn't cause any issue wrt. oom_killer_disable expected
behavior ATM because the only user of this functionality is the PM
freezer itself and that is a sync context so it cannot unexpectedly
race with the suspend progress but it is true that this check is more
robust. Even though this is _really_ unlikely because the suspend
usually doesn't share the mm with a large task it doesn't make any sense
to continue with the suspend if the trigger itself has been killed by
the OOM killer so this is a minor improvement.
 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 6ebc0351..914451a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -613,15 +613,11 @@ void exit_oom_victim(struct task_struct *tsk)
>  bool oom_killer_disable(void)
>  {
>  	/*
> -	 * Make sure to not race with an ongoing OOM killer
> -	 * and that the current is not the victim.
> +	 * Make sure to not race with an ongoing OOM killer. Check that the
> +	 * current is not killed (possibly due to sharing the victim's memory).
>  	 */
> -	mutex_lock(&oom_lock);
> -	if (test_thread_flag(TIF_MEMDIE)) {
> -		mutex_unlock(&oom_lock);
> +	if (mutex_lock_killable(&oom_lock))
>  		return false;
> -	}
> -
>  	oom_killer_disabled = true;
>  	mutex_unlock(&oom_lock);
>  
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
