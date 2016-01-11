Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD8B828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 09:12:20 -0500 (EST)
Received: by mail-lf0-f43.google.com with SMTP id h129so18551494lfh.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 06:12:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a1si3200111lbg.155.2016.01.11.06.12.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 06:12:17 -0800 (PST)
Date: Mon, 11 Jan 2016 15:12:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom: make oom_killer_disable() killable.
Message-ID: <20160111141212.GE27317@dhcp22.suse.cz>
References: <1452337485-8273-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452337485-8273-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org

On Sat 09-01-16 20:04:45, Tetsuo Handa wrote:
> While oom_killer_disable() is called by freeze_processes() after all user
> threads except the current thread are frozen, it is possible that kernel
> threads invoke the OOM killer and sends SIGKILL to the current thread due
> to sharing the thawed victim's memory. Therefore, checking for SIGKILL is
> preferable than TIF_MEMDIE.

OK, this sounds like a good idea. Reducing TIF_MEMDIE usage outside of
the oom/mm proper is indeed desirable.

> Also, it is possible that the thawed victim fails to terminate due to
> invisible dependency. Therefore, waiting with timeout is preferable.
> The timeout is copied from __usermodehelper_disable() called by
> freeze_processes().

__usermodehelper_disable and oom_killer_disable do follow a similar
pattern so it is probably a good idea to handle them the same way. I
would just ask this to be in a separate patch and ideally share the same
constant rather than a magic constant.

Thanks!

> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b8a4210..bafa6b2 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -612,21 +612,19 @@ void exit_oom_victim(void)
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
> -	wait_event(oom_victims_wait, !atomic_read(&oom_victims));
> -
> -	return true;
> +	/* Do not wait forever in case existing victims got stuck. */
> +	if (!wait_event_timeout(oom_victims_wait, !atomic_read(&oom_victims),
> +				5 * HZ))
> +		oom_killer_disabled = false;
> +	return oom_killer_disabled;
>  }
>  
>  /**
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
