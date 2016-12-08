Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 482336B0261
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:18:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a8so645550090pfg.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:18:08 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id g22si29419884pgn.93.2016.12.08.08.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:18:07 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 3so27287749pgd.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:18:06 -0800 (PST)
Date: Fri, 9 Dec 2016 01:18:01 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161208161801.GA445@tigerII.localdomain>
References: <1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161207081555.GB17136@dhcp22.suse.cz>
 <201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
 <5c3ddf50-ca19-2cae-a3ce-b10eafe8363c@suse.cz>
 <201612082000.FBB00003.FFMQSVHJOFLOtO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612082000.FBB00003.FFMQSVHJOFLOtO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: vbabka@suse.cz, mhocko@suse.com, linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, aarcange@redhat.com, david@fromorbit.com, sergey.senozhatsky@gmail.com, akpm@linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>

Hello,

On (12/08/16 20:00), Tetsuo Handa wrote:
[..]
> Theread-1 was trying to flush printk log buffer by printk() from
> oom_kill_process() with oom_lock held. Thread-2 was appending to printk
> log buffer by printk() from warn_alloc() because Thread-2 cannot hold
> oom_lock held by Thread-1. As a result, this formed an AB-BA livelock.
> 
> Although warn_alloc() calls printk() aggressively enough to livelock is
> problematic, at least we can say that it is wasteful to spend CPU time for
> pointless "direct reclaim and warn_alloc()" calls when waiting for the OOM
> killer to send SIGKILL. Therefore, this patch replaces mutex_trylock()
> with mutex_lock_killable().
> 
> Replacing mutex_trylock() with mutex_lock_killable() should be safe, for
> if somebody by error called __alloc_pages_may_oom() with oom_lock held,
> it will livelock because did_some_progress will be set to 1 despite
> mutex_trylock() failure.

so I have some patches in my own/personal/secret tree. the patches were
not yet published to the kernel-list (well, not all of them. I'll do it
a bit later). we are moving towards the "printk() just appends the messages
to the logbuf" idea:

https://gitlab.com/senozhatsky/linux-next-ss/commits/printk-safe-deferred


	-ss

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/page_alloc.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440..6c43d8e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3037,12 +3037,16 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
>  	*did_some_progress = 0;
>  
>  	/*
> -	 * Acquire the oom lock.  If that fails, somebody else is
> -	 * making progress for us.
> +	 * Give the OOM killer enough CPU time for sending SIGKILL.
> +	 * Do not return without a short sleep unless TIF_MEMDIE is set, for
> +	 * currently tsk_is_oom_victim(current) == true does not make
> +	 * gfp_pfmemalloc_allowed() == true via TIF_MEMDIE until
> +	 * mark_oom_victim(current) is called.
>  	 */
> -	if (!mutex_trylock(&oom_lock)) {
> +	if (mutex_lock_killable(&oom_lock)) {
>  		*did_some_progress = 1;
> -		schedule_timeout_uninterruptible(1);
> +		if (!test_thread_flag(TIF_MEMDIE))
> +			schedule_timeout_uninterruptible(1);
>  		return NULL;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
