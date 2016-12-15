Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0566B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 02:54:57 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a8so62744112pfg.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 23:54:57 -0800 (PST)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id d23si1188635plj.286.2016.12.14.23.54.54
        for <linux-mm@kvack.org>;
        Wed, 14 Dec 2016 23:54:56 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161214150706.27412-1-mhocko@kernel.org>
In-Reply-To: <20161214150706.27412-1-mhocko@kernel.org>
Subject: Re: [PATCH] mm: consolidate GFP_NOFAIL checks in the allocator slowpath
Date: Thu, 15 Dec 2016 15:54:37 +0800
Message-ID: <04b001d256a8$7bc813d0$73583b70$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Vlastimil Babka' <vbabka@suse.cz>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

On Wednesday, December 14, 2016 11:07 PM Michal Hocko wrote: 
> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo Handa has pointed out that 0a0337e0d1d1 ("mm, oom: rework oom
> detection") has subtly changed semantic for costly high order requests
> with __GFP_NOFAIL and withtout __GFP_REPEAT and those can fail right now.
> My code inspection didn't reveal any such users in the tree but it is
> true that this might lead to unexpected allocation failures and
> subsequent OOPs.
> 
> __alloc_pages_slowpath wrt. GFP_NOFAIL is hard to follow currently.
> There are few special cases but we are lacking a catch all place to be
> sure we will not miss any case where the non failing allocation might
> fail. This patch reorganizes the code a bit and puts all those special
> cases under nopage label which is the generic go-to-fail path. Non
> failing allocations are retried or those that cannot retry like
> non-sleeping allocation go to the failure point directly. This should
> make the code flow much easier to follow and make it less error prone
> for future changes.
> 
> While we are there we have to move the stall check up to catch
> potentially looping non-failing allocations.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
> Hi Andrew,
> this has been posted previously as a 2 patch series [1]. This is the first patch.
> The second one has generated a lot of discussion and Tetsuo has naked it based
> because he is worried about a potential lockups. I have argued [2] that there
> are other aspects to consider but then later realized that there is a different
> risk in place which hasn't been considered before. There are some users who are
> performing a lot of __GFP_NOFAIL|GFP_NOFS requests and we certainly do not want to
> give them full access to memory reserves without invoking the OOM killer [3].
> 
> For that reason I have dropped the second patch for now and think about
> this some more. The first patch still makes some sense and I find it as
> a useful cleanup so I would ask you to merge it before I find a better
> solution for the other issue. There was no opposition this this patch so I guess
> it should be good to go.
> 
> [1] http://lkml.kernel.org/r/20161201152517.27698-1-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20161212084837.GB18163@dhcp22.suse.cz
> [3] http://lkml.kernel.org/r/20161214103418.GH25573@dhcp22.suse.cz
> 
>  mm/page_alloc.c | 68 ++++++++++++++++++++++++++++++++++-----------------------
>  1 file changed, 41 insertions(+), 27 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3f2c9e535f7f..79b327d9c9a6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3640,32 +3640,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto got_pg;
> 
>  	/* Caller is not willing to reclaim, we can't balance anything */
> -	if (!can_direct_reclaim) {
> -		/*
> -		 * All existing users of the __GFP_NOFAIL are blockable, so warn
> -		 * of any new users that actually allow this type of allocation
> -		 * to fail.
> -		 */
> -		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
> +	if (!can_direct_reclaim)
>  		goto nopage;
> +
> +	/* Make sure we know about allocations which stall for too long */
> +	if (time_after(jiffies, alloc_start + stall_timeout)) {
> +		warn_alloc(gfp_mask,
> +			"page alloction stalls for %ums, order:%u",
> +			jiffies_to_msecs(jiffies-alloc_start), order);
> +		stall_timeout += 10 * HZ;
>  	}
> 
>  	/* Avoid recursion of direct reclaim */
> -	if (current->flags & PF_MEMALLOC) {
> -		/*
> -		 * __GFP_NOFAIL request from this context is rather bizarre
> -		 * because we cannot reclaim anything and only can loop waiting
> -		 * for somebody to do a work for us.
> -		 */
> -		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> -			cond_resched();
> -			goto retry;
> -		}
> +	if (current->flags & PF_MEMALLOC)
>  		goto nopage;
> -	}
> 
>  	/* Avoid allocations with no watermarks from looping endlessly */
> -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> +	if (test_thread_flag(TIF_MEMDIE))
>  		goto nopage;
> 
Nit: currently we allow TIF_MEMDIE & __GFP_NOFAIL request to
try direct reclaim. Are you intentionally reclaiming that chance?

Other than that, feel free to add
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

> 
> @@ -3692,14 +3683,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>  		goto nopage;
> 
> -	/* Make sure we know about allocations which stall for too long */
> -	if (time_after(jiffies, alloc_start + stall_timeout)) {
> -		warn_alloc(gfp_mask,
> -			"page allocation stalls for %ums, order:%u",
> -			jiffies_to_msecs(jiffies-alloc_start), order);
> -		stall_timeout += 10 * HZ;
> -	}
> -
>  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
>  				 did_some_progress > 0, &no_progress_loops))
>  		goto retry;
> @@ -3728,6 +3711,37 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	}
> 
>  nopage:
> +	/*
> +	 * Make sure that __GFP_NOFAIL request doesn't leak out and make sure
> +	 * we always retry
> +	 */
> +	if (gfp_mask & __GFP_NOFAIL) {
> +		/*
> +		 * All existing users of the __GFP_NOFAIL are blockable, so warn
> +		 * of any new users that actually require GFP_NOWAIT
> +		 */
> +		if (WARN_ON_ONCE(!can_direct_reclaim))
> +			goto fail;
> +
> +		/*
> +		 * PF_MEMALLOC request from this context is rather bizarre
> +		 * because we cannot reclaim anything and only can loop waiting
> +		 * for somebody to do a work for us
> +		 */
> +		WARN_ON_ONCE(current->flags & PF_MEMALLOC);
> +
> +		/*
> +		 * non failing costly orders are a hard requirement which we
> +		 * are not prepared for much so let's warn about these users
> +		 * so that we can identify them and convert them to something
> +		 * else.
> +		 */
> +		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
> +
> +		cond_resched();
> +		goto retry;
> +	}
> +fail:
>  	warn_alloc(gfp_mask,
>  			"page allocation failure: order:%u", order);
>  got_pg:
> --
> 2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
