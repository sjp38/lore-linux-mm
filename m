Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6E16B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 03:22:23 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w95so5610592wrc.20
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 00:22:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o27si5440718wra.417.2017.12.08.00.22.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 00:22:22 -0800 (PST)
Date: Fri, 8 Dec 2017 09:22:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
Message-ID: <20171208082220.GQ20234@dhcp22.suse.cz>
References: <20171208012305.83134-1-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208012305.83134-1-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On Thu 07-12-17 17:23:05, Suren Baghdasaryan wrote:
> Slab shrinkers can be quite time consuming and when signal
> is pending they can delay handling of the signal. If fatal
> signal is pending there is no point in shrinking that process
> since it will be killed anyway.

The thing is that we are _not_ shrinking _that_ process. We are
shrinking globally shared objects and the fact that the memory pressure
is so large that the kswapd doesn't keep pace with it means that we have
to throttle all allocation sites by doing this direct reclaim. I agree
that expediting killed task is a good thing in general because such a
process should free at least some memory.

> This change checks for pending
> fatal signals inside shrink_slab loop and if one is detected
> terminates this loop early.

This changelog doesn't really address my previous review feedback, I am
afraid. You should mention more details about problems you are seeing
and what causes them. If we have a shrinker which takes considerable
amount of time them we should be addressing that. If that is not
possible then it should be documented at least.

The changelog also should describe how does this play along with the
rest of the allocation path.

The patch is not mergeable in this form I am afraid.

> Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> 
> ---
> V2:
> Sergey Senozhatsky:
>   - Fix missing parentheses
> ---
>  mm/vmscan.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c02c850ea349..28e4bdc72c16 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -486,6 +486,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  			.memcg = memcg,
>  		};
>  
> +		/*
> +		 * We are about to die and free our memory.
> +		 * Stop shrinking which might delay signal handling.
> +		 */
> +		if (unlikely(fatal_signal_pending(current)))
> +			break;
> +
>  		/*
>  		 * If kernel memory accounting is disabled, we ignore
>  		 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
> -- 
> 2.15.1.424.g9478a66081-goog
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
