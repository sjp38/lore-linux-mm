Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0329F6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:38:04 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so18714603wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:38:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n8si3861974wiz.102.2015.08.25.08.38.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 08:38:02 -0700 (PDT)
Subject: Re: [PATCH 07/12] mm, page_alloc: Distinguish between being unable to
 sleep, unwilling to sleep and avoiding waking kswapd
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DC8BD7.602@suse.cz>
Date: Tue, 25 Aug 2015 17:37:59 +0200
MIME-Version: 1.0
In-Reply-To: <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/24/2015 02:09 PM, Mel Gorman wrote:
> __GFP_WAIT has been used to identify atomic context in callers that hold
> spinlocks or are in interrupts. They are expected to be high priority and
> have access one of two watermarks lower than "min" which can be referred
> to as the "atomic reserve". __GFP_HIGH users get access to the first lower
> watermark and can be called the "high priority reserve".
>
> Over time, callers had a requirement to not block when fallback options
> were available. Some have abused __GFP_WAIT leading to a situation where
> an optimisitic allocation with a fallback option can access atomic reserves.
>
> This patch uses __GFP_ATOMIC to identify callers that are truely atomic,
> cannot sleep and have no alternative. High priority users continue to use
> __GFP_HIGH. __GFP_DIRECT_RECLAIM identifies callers that can sleep and are
> willing to enter direct reclaim. __GFP_KSWAPD_RECLAIM to identify callers
> that want to wake kswapd for background reclaim. __GFP_WAIT is redefined
> as a caller that is willing to enter direct reclaim and wake kswapd for
> background reclaim.
>
> This patch then converts a number of sites
>
> o __GFP_ATOMIC is used by callers that are high priority and have memory
>    pools for those requests. GFP_ATOMIC uses this flag.
>
> o Callers that have a limited mempool to guarantee forward progress use
>    __GFP_DIRECT_RECLAIM. bio allocations fall into this category where

      ^ __GFP_KSWAPD_RECLAIM ? (missed it previously)

>    kswapd will still be woken but atomic reserves are not used as there
>    is a one-entry mempool to guarantee progress.
>
> o Callers that are checking if they are non-blocking should use the
>    helper gfpflags_allow_blocking() where possible. This is because
>    checking for __GFP_WAIT as was done historically now can trigger false
>    positives. Some exceptions like dm-crypt.c exist where the code intent
>    is clearer if __GFP_DIRECT_RECLAIM is used instead of the helper due to
>    flag manipulations.
>
> o Callers that built their own GFP flags instead of starting with GFP_KERNEL
>    and friends now also need to specify __GFP_KSWAPD_RECLAIM.
>
> The first key hazard to watch out for is callers that removed __GFP_WAIT
> and was depending on access to atomic reserves for inconspicuous reasons.
> In some cases it may be appropriate for them to use __GFP_HIGH.
>
> The second key hazard is callers that assembled their own combination of
> GFP flags instead of starting with something like GFP_KERNEL. They may
> now wish to specify __GFP_KSWAPD_RECLAIM. It's almost certainly harmless
> if it's missed in most cases as other activity will wake kswapd.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Thanks for the effort!

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Just last few bits:

> @@ -2158,7 +2158,7 @@ static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>   		return false;
>   	if (fail_page_alloc.ignore_gfp_highmem && (gfp_mask & __GFP_HIGHMEM))
>   		return false;
> -	if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & __GFP_WAIT))
> +	if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & (__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
>   		return false;
>
>   	return should_fail(&fail_page_alloc.attr, 1 << order);

IIUC ignore_gfp_wait tells it to assume that reclaimers will eventually 
succeed (for some reason?), so they shouldn't fail. Probably to focus 
the testing on atomic allocations. But your change makes atomic 
allocation never fail, so that goes against the knob IMHO?

> @@ -2660,7 +2660,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
>   		if (test_thread_flag(TIF_MEMDIE) ||
>   		    (current->flags & (PF_MEMALLOC | PF_EXITING)))
>   			filter &= ~SHOW_MEM_FILTER_NODES;
> -	if (in_interrupt() || !(gfp_mask & __GFP_WAIT))
> +	if (in_interrupt() || !(gfp_mask & __GFP_WAIT) || (gfp_mask & __GFP_ATOMIC))
>   		filter &= ~SHOW_MEM_FILTER_NODES;
>
>   	if (fmt) {

This caught me previously and I convinced myself that it's OK, but now 
I'm not anymore. IIUC this is to not filter nodes by mems_allowed during 
printing, if the allocation itself wasn't limited? In that case it 
should probably only look at __GFP_ATOMIC after this patch? As that's 
the only thing that determines ALLOC_CPUSET.
I don't know where in_interrupt() comes from, but it was probably 
considered in the past, as can be seen in zlc_setup()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
