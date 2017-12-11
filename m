Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C35736B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 06:57:25 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g80so10144709wrd.17
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 03:57:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w203si5213974wmg.238.2017.12.11.03.57.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 03:57:24 -0800 (PST)
Date: Mon, 11 Dec 2017 12:57:23 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second
 allocation
Message-ID: <20171211115723.GC4779@dhcp22.suse.cz>
References: <1512646940-3388-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1512646940-3388-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Manish Jaggi <mjaggi@caviumnetworks.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

[I didn't get to this patch any sooner, sorry about that]

On Thu 07-12-17 20:42:20, Tetsuo Handa wrote:
> Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> count causes random kernel panics when an OOM victim which consumed memory
> in a way the OOM reaper does not help was selected by the OOM killer [1].
> Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
> to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
> victim's mm were not able to try allocation from memory reserves after the
> OOM reaper gave up reclaiming memory.
> 
> Therefore, this patch allows OOM victims to use ALLOC_OOM watermark for
> last second allocation attempt.

This changelog doesn't explain the problem, nor does it say why it
should help. I would even argue that mentioning the LTP test is more
confusing than helpful (also considering it a fix for 696453e66630ad45)
because granting access to memory reserves will only help partially.
Anyway, the patch makes some sense to me but I am not going to ack it
with a misleading changelog.

> [1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com
> 
> Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/page_alloc.c | 39 +++++++++++++++++++++++++++++----------
>  1 file changed, 29 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 73f5d45..5d054a4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3309,6 +3309,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	return page;
>  }
>  
> +static struct page *alloc_pages_before_oomkill(gfp_t gfp_mask,
> +					       unsigned int order,
> +					       const struct alloc_context *ac);
> +
>  static inline struct page *
>  __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	const struct alloc_context *ac, unsigned long *did_some_progress)
> @@ -3334,16 +3338,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  		return NULL;
>  	}
>  
> -	/*
> -	 * Go through the zonelist yet one more time, keep very high watermark
> -	 * here, this is only to catch a parallel oom killing, we must fail if
> -	 * we're still under heavy pressure. But make sure that this reclaim
> -	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> -	 * allocation which will never fail due to oom_lock already held.
> -	 */
> -	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
> -				      ~__GFP_DIRECT_RECLAIM, order,
> -				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
> +	page = alloc_pages_before_oomkill(gfp_mask, order, ac);
>  	if (page)
>  		goto out;
>  
> @@ -3755,6 +3750,30 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	return !!__gfp_pfmemalloc_flags(gfp_mask);
>  }
>  
> +static struct page *alloc_pages_before_oomkill(gfp_t gfp_mask,
> +					       unsigned int order,
> +					       const struct alloc_context *ac)
> +{
> +	/*
> +	 * Go through the zonelist yet one more time, keep very high watermark
> +	 * here, this is only to catch a parallel oom killing, we must fail if
> +	 * we're still under heavy pressure. But make sure that this reclaim
> +	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> +	 * allocation which will never fail due to oom_lock already held.
> +	 * Also, make sure that OOM victims can try ALLOC_OOM watermark
> +	 * in case they haven't tried ALLOC_OOM watermark.
> +	 */
> +	int alloc_flags = ALLOC_CPUSET | ALLOC_WMARK_HIGH;
> +	int reserve_flags;
> +
> +	gfp_mask |= __GFP_HARDWALL;
> +	gfp_mask &= ~__GFP_DIRECT_RECLAIM;
> +	reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
> +	if (reserve_flags)
> +		alloc_flags = reserve_flags;
> +	return get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
> +}
> +
>  /*
>   * Checks whether it makes sense to retry the reclaim to make a forward progress
>   * for the given allocation request.
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
