Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD54A6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 07:55:52 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so17717996wmi.6
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 04:55:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y62si14221459wmb.48.2017.01.23.04.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 04:55:51 -0800 (PST)
Subject: Re: [PATCH] mm: ensure alloc_flags in slow path are initialized
References: <20170123121649.3180300-1-arnd@arndb.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ffce0866-0233-c7c4-027a-a0a1caa26cf3@suse.cz>
Date: Mon, 23 Jan 2017 13:55:44 +0100
MIME-Version: 1.0
In-Reply-To: <20170123121649.3180300-1-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/23/2017 01:16 PM, Arnd Bergmann wrote:
> The __alloc_pages_slowpath() has gotten rather complex and gcc
> is no longer able to follow the gotos and prove that the
> alloc_flags variable is initialized at the time it is used:
>
> mm/page_alloc.c: In function '__alloc_pages_slowpath':
> mm/page_alloc.c:3565:15: error: 'alloc_flags' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
> To be honest, I can't figure that out either, maybe it is or
> maybe not,

Seems the report is correct and not false positive, in scenario when we goto 
nopage before the assignment, and then goto retry because of __GFP_NOFAIL.

> but moving the existing initialization up a little
> higher looks safe and makes it obvious to both me and gcc that
> the initialization comes before the first use.
>
> Fixes: 74eaa4a97e8e ("mm: consolidate GFP_NOFAIL checks in the allocator slowpath")

That's a non-stable -next commit ID for mmotm patch:
mm-consolidate-gfp_nofail-checks-in-the-allocator-slowpath.patch

The patch itself was OK, the problem only comes from integration with another 
mmotm patch (also independently OK):
mm-page_alloc-fix-premature-oom-when-racing-with-cpuset-mems-update.patch

By their ordering in mmotm, it would work to treat this as a fix for the 
GFP_NOFAIL patch, possibly merged into it.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cf641932c015..d9fa4564524f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3591,6 +3591,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
>  		gfp_mask &= ~__GFP_ATOMIC;
>
> +	/*
> +	 * The fast path uses conservative alloc_flags to succeed only until
> +	 * kswapd needs to be woken up, and to avoid the cost of setting up
> +	 * alloc_flags precisely. So we do that now.
> +	 */
> +	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> +
>  retry_cpuset:
>  	compaction_retries = 0;
>  	no_progress_loops = 0;
> @@ -3607,14 +3614,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (!ac->preferred_zoneref->zone)
>  		goto nopage;
>
> -
> -	/*
> -	 * The fast path uses conservative alloc_flags to succeed only until
> -	 * kswapd needs to be woken up, and to avoid the cost of setting up
> -	 * alloc_flags precisely. So we do that now.
> -	 */
> -	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> -
>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>  		wake_all_kswapds(order, ac);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
