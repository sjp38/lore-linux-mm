Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7A956B0297
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 03:43:36 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w84so8807738wmg.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 00:43:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id li10si6335922wjb.23.2016.09.23.00.43.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 00:43:35 -0700 (PDT)
Date: Fri, 23 Sep 2016 09:43:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,page_alloc: Allow !__GFP_FS allocations to invoke the
 OOM killer
Message-ID: <20160923074333.GA4478@dhcp22.suse.cz>
References: <1474557777-8288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474557777-8288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 23-09-16 00:22:57, Tetsuo Handa wrote:
[...]
> As a first step, I do want to eliminate possibility of silent OOM livelock.

Absolutely no! Unless you have a clear evidence that the oom livelock is
real and easily triggerable from the userspace. Pre-mature OOM killer is
imho much worse problem than a theoretical GFP_NOFS livelock.

So NAK to this patch from me. We just have too many GFP_NOFS users
currently and the risk of pre-mature OOM is just too high wrt to gain
this will give us. I really think we need a real solution rather than
just blindly disable this code and hope everything will happen to work.
As I've said in the past I am not fond of this heuristic either but we
do not have anything better now.

I am all for warning when an allocation stalls for too long to identify
potential problems. Will post a patch later today.

> If this patch causes !__GFP_FS memory allocation requests to invoke the
> OOM killer trivially, at least we will be able to emit warning messages
> periodically as long as we are telling the lie instead of invoking the
> OOM killer. Without knowing which caller is falling into OOM livelock,
> we will remain too cowardly to determine when we can stop telling the
> lie and we will bother administrators with silent OOM livelock.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/oom_kill.c | 9 ---------
>  1 file changed, 9 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f284e92..7893c5c 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1005,15 +1005,6 @@ bool out_of_memory(struct oom_control *oc)
>  	}
>  
>  	/*
> -	 * The OOM killer does not compensate for IO-less reclaim.
> -	 * pagefault_out_of_memory lost its gfp context so we have to
> -	 * make sure exclude 0 mask - all other users should have at least
> -	 * ___GFP_DIRECT_RECLAIM to get here.
> -	 */
> -	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
> -		return true;
> -
> -	/*
>  	 * Check if there were limitations on the allocation (only relevant for
>  	 * NUMA and memcg) that may require different handling.
>  	 */
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
