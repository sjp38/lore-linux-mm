Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id AA4916B0254
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 16:02:16 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id n186so7647100wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:02:16 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id gd1si33872151wjb.154.2016.02.29.13.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 13:02:15 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id p65so837508wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:02:15 -0800 (PST)
Date: Mon, 29 Feb 2016 22:02:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160229210213.GX16930@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160225092315.GD17573@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Andrew,
could you queue this one as well, please? This is more a band aid than a
real solution which I will be working on as soon as I am able to
reproduce the issue but the patch should help to some degree at least.

On Thu 25-02-16 10:23:15, Michal Hocko wrote:
> From d09de26cee148b4d8c486943b4e8f3bd7ad6f4be Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 4 Feb 2016 14:56:59 +0100
> Subject: [PATCH] mm, oom: protect !costly allocations some more
> 
> should_reclaim_retry will give up retries for higher order allocations
> if none of the eligible zones has any requested or higher order pages
> available even if we pass the watermak check for order-0. This is done
> because there is no guarantee that the reclaimable and currently free
> pages will form the required order.
> 
> This can, however, lead to situations were the high-order request (e.g.
> order-2 required for the stack allocation during fork) will trigger
> OOM too early - e.g. after the first reclaim/compaction round. Such a
> system would have to be highly fragmented and the OOM killer is just a
> matter of time but let's stick to our MAX_RECLAIM_RETRIES for the high
> order and not costly requests to make sure we do not fail prematurely.
> 
> This also means that we do not reset no_progress_loops at the
> __alloc_pages_slowpath for high order allocations to guarantee a bounded
> number of retries.
> 
> Longterm it would be much better to communicate with the compaction
> and retry only if the compaction considers it meaningfull.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 269a04f20927..f05aca36469b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3106,6 +3106,18 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		}
>  	}
>  
> +	/*
> +	 * OK, so the watermak check has failed. Make sure we do all the
> +	 * retries for !costly high order requests and hope that multiple
> +	 * runs of compaction will generate some high order ones for us.
> +	 *
> +	 * XXX: ideally we should teach the compaction to try _really_ hard
> +	 * if we are in the retry path - something like priority 0 for the
> +	 * reclaim
> +	 */
> +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER)
> +		return true;
> +
>  	return false;
>  }
>  
> @@ -3281,11 +3293,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto noretry;
>  
>  	/*
> -	 * Costly allocations might have made a progress but this doesn't mean
> -	 * their order will become available due to high fragmentation so do
> -	 * not reset the no progress counter for them
> +	 * High order allocations might have made a progress but this doesn't
> +	 * mean their order will become available due to high fragmentation so
> +	 * do not reset the no progress counter for them
>  	 */
> -	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
> +	if (did_some_progress && !order)
>  		no_progress_loops = 0;
>  	else
>  		no_progress_loops++;
> -- 
> 2.7.0
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
