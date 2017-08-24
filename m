Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC6C2440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:03:49 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y64so666916wmd.6
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:03:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si3332331wrk.131.2017.08.24.06.03.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 06:03:48 -0700 (PDT)
Date: Thu, 24 Aug 2017 15:03:45 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/2] mm,page_alloc: Don't call __node_reclaim() with
 oom_lock held.
Message-ID: <20170824130345.GM5943@dhcp22.suse.cz>
References: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

On Thu 24-08-17 21:18:25, Tetsuo Handa wrote:
> We are doing last second memory allocation attempt before calling
> out_of_memory(). But since slab shrinker functions might indirectly
> wait for other thread's __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory
> allocations via sleeping locks, calling slab shrinker functions from
> node_reclaim() from get_page_from_freelist() with oom_lock held has
> possibility of deadlock. Therefore, make sure that last second memory
> allocation attempt does not call slab shrinker functions.

OK, I have previously missed that node_reclaim does
gfpflags_allow_blocking

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b983ee..788318f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3303,10 +3303,13 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	/*
>  	 * Go through the zonelist yet one more time, keep very high watermark
>  	 * here, this is only to catch a parallel oom killing, we must fail if
> -	 * we're still under heavy pressure.
> +	 * we're still under heavy pressure. But make sure that this reclaim
> +	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> +	 * allocation which will never fail due to oom_lock already held.
>  	 */
> -	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
> -					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
> +	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
> +				      ~__GFP_DIRECT_RECLAIM, order,
> +				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
>  	if (page)
>  		goto out;
>  
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
