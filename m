Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDCC6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 18:17:38 -0500 (EST)
Received: by pacej9 with SMTP id ej9so95349204pac.2
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 15:17:37 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id j11si855631pbq.204.2015.11.19.15.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 15:17:37 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so98505023pab.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 15:17:37 -0800 (PST)
Date: Thu, 19 Nov 2015 15:17:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 3/3] mm: use watermak checks for __GFP_REPEAT high order
 allocations
In-Reply-To: <1447851840-15640-4-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1511191515170.17510@chino.kir.corp.google.com>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org> <1447851840-15640-4-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>

On Wed, 18 Nov 2015, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_slowpath retries costly allocations until at least
> order worth of pages were reclaimed or the watermark check for at least
> one zone would succeed after all reclaiming all pages if the reclaim
> hasn't made any progress.
> 
> The first condition was added by a41f24ea9fd6 ("page allocator: smarter
> retry of costly-order allocations) and it assumed that lumpy reclaim
> could have created a page of the sufficient order. Lumpy reclaim,
> has been removed quite some time ago so the assumption doesn't hold
> anymore. It would be more appropriate to check the compaction progress
> instead but this patch simply removes the check and relies solely
> on the watermark check.
> 
> To prevent from too many retries the stall_backoff is not reseted after
> a reclaim which made progress because we cannot assume it helped high
> order situation.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 20 ++++++++------------
>  1 file changed, 8 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e6271bc19e6a..999c8cdbe7b5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3006,7 +3006,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
>  	struct page *page = NULL;
>  	int alloc_flags;
> -	unsigned long pages_reclaimed = 0;
>  	unsigned long did_some_progress;
>  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
>  	bool deferred_compaction = false;
> @@ -3167,24 +3166,21 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  
>  	/*
>  	 * Do not retry high order allocations unless they are __GFP_REPEAT
> -	 * and even then do not retry endlessly unless explicitly told so
> +	 * unless explicitly told so.
>  	 */
> -	pages_reclaimed += did_some_progress;
> -	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> -		if (!(gfp_mask & __GFP_NOFAIL) &&
> -		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
> -			goto noretry;
> -
> -		if (did_some_progress)
> -			goto retry;
> -	}
> +	if (order > PAGE_ALLOC_COSTLY_ORDER &&
> +			!(gfp_mask & (__GFP_REPEAT|__GFP_NOFAIL)))
> +		goto noretry;

Who is allocating order > PAGE_ALLOC_COSTLY_ORDER with __GFP_REPEAT and 
would be affected by this change?

>  
>  	/*
>  	 * Be optimistic and consider all pages on reclaimable LRUs as usable
>  	 * but make sure we converge to OOM if we cannot make any progress after
>  	 * multiple consecutive failed attempts.
> +	 * Costly __GFP_REPEAT allocations might have made a progress but this
> +	 * doesn't mean their order will become available due to high fragmentation
> +	 * so do not reset the backoff for them
>  	 */
> -	if (did_some_progress)
> +	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
>  		stall_backoff = 0;
>  	else
>  		stall_backoff = min(stall_backoff+1, MAX_STALL_BACKOFF); 

This makes sense if there are high-order users of __GFP_REPEAT since 
only using a number of pages reclaimed by itself isn't helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
