Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 917856B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 03:34:39 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v184so9170240wmf.1
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 00:34:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si3003816wrr.461.2017.12.07.00.34.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 00:34:38 -0800 (PST)
Date: Thu, 7 Dec 2017 09:34:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Message-ID: <20171207083436.GC20234@dhcp22.suse.cz>
References: <20171206192026.25133-1-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206192026.25133-1-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On Wed 06-12-17 11:20:26, Suren Baghdasaryan wrote:
> Slab shrinkers can be quite time consuming and when signal
> is pending they can delay handling of the signal. If fatal
> signal is pending there is no point in shrinking that process
> since it will be killed anyway. This change checks for pending
> fatal signals inside shrink_slab loop and if one is detected
> terminates this loop early.

This is not enough. You would have to make sure the direct reclaim will
bail out immeditally which is not at all that simple. We do check fatal
signals in throttle_direct_reclaim and conditionally in shrink_inactive_list
so even if you bail out from shrinkers we could still finish the full
reclaim cycle.

Besides that shrinkers shouldn't really take very long so this looks
like it papers over a real bug somewhere else. I am not saying the patch
is wrong but it would deserve much more details to judge wether this is
the right way to go for your particular problem.

> Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> ---
>  mm/vmscan.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c02c850ea349..69296528ff33 100644
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
> +		if (unlikely(fatal_signal_pending(current))
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
