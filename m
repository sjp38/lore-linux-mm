Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9F136B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 09:43:52 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so53471728lfd.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 06:43:52 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id a71si16957151wma.36.2016.05.12.06.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 06:43:51 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r12so16272567wme.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 06:43:51 -0700 (PDT)
Date: Thu, 12 May 2016 15:43:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 05/13] mm, page_alloc: make THP-specific decisions more
 generic
Message-ID: <20160512134348.GK4200@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-6-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-6-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 10-05-16 09:35:55, Vlastimil Babka wrote:
> Since THP allocations during page faults can be costly, extra decisions are
> employed for them to avoid excessive reclaim and compaction, if the initial
> compaction doesn't look promising. The detection has never been perfect as
> there is no gfp flag specific to THP allocations. At this moment it checks the
> whole combination of flags that makes up GFP_TRANSHUGE, and hopes that no other
> users of such combination exist, or would mind being treated the same way.
> Extra care is also taken to separate allocations from khugepaged, where latency
> doesn't matter that much.
> 
> It is however possible to distinguish these allocations in a simpler and more
> reliable way. The key observation is that after the initial compaction followed
> by the first iteration of "standard" reclaim/compaction, both __GFP_NORETRY
> allocations and costly allocations without __GFP_REPEAT are declared as
> failures:
> 
>         /* Do not loop if specifically requested */
>         if (gfp_mask & __GFP_NORETRY)
>                 goto nopage;
> 
>         /*
>          * Do not retry costly high order allocations unless they are
>          * __GFP_REPEAT
>          */
>         if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>                 goto nopage;
> 
> This means we can further distinguish allocations that are costly order *and*
> additionally include the __GFP_NORETRY flag. As it happens, GFP_TRANSHUGE
> allocations do already fall into this category. This will also allow other
> costly allocations with similar high-order benefit vs latency considerations to
> use this semantic. Furthermore, we can distinguish THP allocations that should
> try a bit harder (such as from khugepageed) by removing __GFP_NORETRY, as will
> be done in the next patch.

Yes, using __GFP_NORETRY makes perfect sense. It is the weakest mode for
the costly allocation which includes both compaction and reclaim. I am
happy to see is_thp_gfp_mask going away.

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 22 +++++++++-------------
>  1 file changed, 9 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 88d680b3e7b6..f5d931e0854a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3182,7 +3182,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	return page;
>  }
>  
> -
>  /*
>   * Maximum number of compaction retries wit a progress before OOM
>   * killer is consider as the only way to move forward.
> @@ -3447,11 +3446,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
>  }
>  
> -static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
> -{
> -	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
> -}
> -
>  /*
>   * Maximum number of reclaim retries without any progress before OOM killer
>   * is consider as the only way to move forward.
> @@ -3610,8 +3604,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		if (page)
>  			goto got_pg;
>  
> -		/* Checks for THP-specific high-order allocations */
> -		if (is_thp_gfp_mask(gfp_mask)) {
> +		/*
> +		 * Checks for costly allocations with __GFP_NORETRY, which
> +		 * includes THP page fault allocations
> +		 */
> +		if (gfp_mask & __GFP_NORETRY) {
>  			/*
>  			 * If compaction is deferred for high-order allocations,
>  			 * it is because sync compaction recently failed. If
> @@ -3631,11 +3628,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  				goto nopage;
>  
>  			/*
> -			 * It can become very expensive to allocate transparent
> -			 * hugepages at fault, so use asynchronous memory
> -			 * compaction for THP unless it is khugepaged trying to
> -			 * collapse. All other requests should tolerate at
> -			 * least light sync migration.
> +			 * Looks like reclaim/compaction is worth trying, but
> +			 * sync compaction could be very expensive, so keep
> +			 * using async compaction, unless it's khugepaged
> +			 * trying to collapse.
>  			 */
>  			if (!(current->flags & PF_KTHREAD))
>  				migration_mode = MIGRATE_ASYNC;
> -- 
> 2.8.2
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
