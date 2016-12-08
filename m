Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CBD4B6B025E
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 08:32:33 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so6295828wme.5
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 05:32:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si29343099wjz.7.2016.12.08.05.32.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 05:32:32 -0800 (PST)
Date: Thu, 8 Dec 2016 14:32:30 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161208133229.GB26530@dhcp22.suse.cz>
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
Cc: vbabka@suse.cz, linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, aarcange@redhat.com, david@fromorbit.com, sergey.senozhatsky@gmail.com, akpm@linux-foundation.org

On Thu 08-12-16 20:00:39, Tetsuo Handa wrote:
> Cc'ing people involved in commit dc56401fc9f25e8f ("mm: oom_kill: simplify
> OOM killer locking") and Sergey as printk() expert. Topic started from
> http://lkml.kernel.org/r/1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
> 
> Vlastimil Babka wrote:
> > > May I? Something like below? With patch below, the OOM killer can send
> > > SIGKILL smoothly and printk() can report smoothly (the frequency of
> > > "** XXX printk messages dropped **" messages is significantly reduced).
> > >
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 2c6d5f6..ee0105b 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -3075,7 +3075,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
> > >  	 * Acquire the oom lock.  If that fails, somebody else is
> > >  	 * making progress for us.
> > >  	 */
> > 
> > The comment above could use some updating then. Although maybe "somebody 
> > killed us" is also technically "making progress for us" :)
> 
> I think we can update the comment. But since __GFP_KILLABLE does not exist,
> SIGKILL is pending does not imply that current thread will make progress by
> leaving the retry loop immediately. Therefore,

Although this is true I do not think that cluttering the code with this
case is anyhow useful. In the vast majority of cases SIGKILL pending
will be a result of the oom killer.

[...]
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

I am not really sure this is necessary. Just return outside and for
those unlikely cases where the current task was killed before entering
the page allocator simply do not matter imho. I would rather go with
simplicity here.

>  		return NULL;
>  	}
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
