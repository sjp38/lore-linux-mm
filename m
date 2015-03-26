Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 543E86B0073
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:32:57 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so90774967wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 08:32:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jh6si28720917wid.94.2015.03.26.08.32.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 08:32:55 -0700 (PDT)
Date: Thu, 26 Mar 2015 16:32:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 12/12] mm: page_alloc: do not lock up low-order
 allocations upon OOM
Message-ID: <20150326153253.GO15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-13-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-13-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 02:17:16, Johannes Weiner wrote:
> When both page reclaim and the OOM killer fail to free memory, there
> are no more options for the allocator to make progress on its own.
> 
> Don't risk hanging these allocations.  Leave it to the allocation site
> to implement the fallback policy for failing allocations.

The changelog communicates the impact of this patch _very_ poorly. The
potential regression space is quite large. Every syscall which is not
allowed to return ENOMEM and it relies on an allocation would have to be
audited or a common mechanism to catch them deployed.

I really believe this is a good thing _longterm_ but I still do not
think it is the upstream material anytime soon without extensive testing
which is even not mentioned here.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/page_alloc.c | 19 ++++++-------------
>  1 file changed, 6 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9e45e97aa934..f2b1a17416c4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2331,12 +2331,10 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
>  
>  static inline struct page *
>  __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> -	const struct alloc_context *ac, unsigned long *did_some_progress)
> +		      const struct alloc_context *ac)
>  {
>  	struct page *page = NULL;
>  
> -	*did_some_progress = 0;
> -
>  	/*
>  	 * This allocating task can become the OOM victim itself at
>  	 * any point before acquiring the lock.  In that case, exit
> @@ -2376,13 +2374,9 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  			goto out;
>  	}
>  
> -	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)) {
> -		*did_some_progress = 1;
> -	} else {
> +	if (!out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false))
>  		/* Oops, these shouldn't happen with the OOM killer disabled */
> -		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> -			*did_some_progress = 1;
> -	}
> +		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
>  
>  	/*
>  	 * Allocate from the OOM killer reserves.
> @@ -2799,13 +2793,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	}
>  
>  	/* Reclaim has failed us, start killing things */
> -	page = __alloc_pages_may_oom(gfp_mask, order, alloc_flags, ac,
> -				     &did_some_progress);
> +	page = __alloc_pages_may_oom(gfp_mask, order, alloc_flags, ac);
>  	if (page)
>  		goto got_pg;
>  
> -	/* Retry as long as the OOM killer is making progress */
> -	if (did_some_progress)
> +	/* Wait for user to order more dimms, cuz these are done */
> +	if (gfp_mask & __GFP_NOFAIL)
>  		goto retry;
>  
>  noretry:
> -- 
> 2.3.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
