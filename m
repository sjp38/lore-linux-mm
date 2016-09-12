Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 647196B0261
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 07:51:12 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so56976975wmz.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:51:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yi10si3345536wjb.227.2016.09.12.04.51.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 04:51:11 -0700 (PDT)
Date: Mon, 12 Sep 2016 13:51:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Don't emit warning from pagefault_out_of_memory()
Message-ID: <20160912115104.GJ14524@dhcp22.suse.cz>
References: <1473442120-7246-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160912071651.GB14524@dhcp22.suse.cz>
 <201609122032.GCI56728.OJFHFtMLVOQSOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609122032.GCI56728.OJFHFtMLVOQSOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org

On Mon 12-09-16 20:32:13, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 10-09-16 02:28:40, Tetsuo Handa wrote:
> > > Commit c32b3cbe0d067a9c ("oom, PM: make OOM detection in the freezer path
> > > raceless") inserted a WARN_ON() into pagefault_out_of_memory() in order
> > > to warn when we raced with disabling the OOM killer. But emitting same
> > > backtrace forever after the OOM killer/reaper are disabled is pointless
> > > because the system is already OOM livelocked.
> > 
> > How that would that be forever? Pagefaults are not GFP_NOFAIL and the
> > killed task would just enter the exit path.
> 
> Indeed, there is
> 
> 	/* Avoid allocations with no watermarks from looping endlessly */
> 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> 		goto nopage;
> 
> check.
> 
> I don't know if pagefaults can happen after entering do_exit().

It can via g-u-p but callers should be able to handle the failure.
[...]
> Subject: [PATCH v2] mm: Don't emit warning from pagefault_out_of_memory()
> Date: Sat, 10 Sep 2016 02:28:40 +0900
> Message-Id: <1473442120-7246-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
> 
> Commit c32b3cbe0d067a9c ("oom, PM: make OOM detection in the freezer path
> raceless") inserted a WARN_ON() into pagefault_out_of_memory() in order
> to warn when we raced with disabling the OOM killer.
> 
> Now, patch "oom, suspend: fix oom_killer_disable vs. pm suspend properly"
> introduced a timeout for oom_killer_disable(). Even if we raced with
> disabling the OOM killer and the system is OOM livelocked, the OOM killer
> will be enabled eventually (in 20 seconds by default) and the OOM livelock
> will be solved. Therefore, we no longer need to warn when we raced with
> disabling the OOM killer.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/oom_kill.c | 12 +-----------
>  1 file changed, 1 insertion(+), 11 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0034baf..f284e92 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1069,16 +1069,6 @@ void pagefault_out_of_memory(void)
>  
>  	if (!mutex_trylock(&oom_lock))
>  		return;
> -
> -	if (!out_of_memory(&oc)) {
> -		/*
> -		 * There shouldn't be any user tasks runnable while the
> -		 * OOM killer is disabled, so the current task has to
> -		 * be a racing OOM victim for which oom_killer_disable()
> -		 * is waiting for.
> -		 */
> -		WARN_ON(test_thread_flag(TIF_MEMDIE));
> -	}
> -
> +	out_of_memory(&oc);
>  	mutex_unlock(&oom_lock);
>  }
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
