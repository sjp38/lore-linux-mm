Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E618A6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:47:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e64so11530766wmi.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 03:47:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j30si6852530wrd.19.2017.09.26.03.47.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 03:47:54 -0700 (PDT)
Date: Tue, 26 Sep 2017 12:47:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/2] Try to use HighAtomic if try to alloc umovable page
 that order is not 0
Message-ID: <20170926104752.e5jyygwyqhqqvmjl@dhcp22.suse.cz>
References: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com>
 <1506415604-4310-2-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506415604-4310-2-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com

On Tue 26-09-17 16:46:43, Hui Zhu wrote:
> The page add a new condition to let gfp_to_alloc_flags return
> alloc_flags with ALLOC_HARDER if the order is not 0 and migratetype is
> MIGRATE_UNMOVABLE.

Apart from what Mel has already said this changelog is really lacking
the crucial information. It says what but it doesn't explain why we need
this and why it is safe to do. What kind of workload will benefit from
this change and how much. What about those users who are relying on high
atomic reserves currently and now would need to share it with other
users.

Without knowing all that background and from a quick look this looks
like a very crude hack to me, to be completely honest.

> Then alloc umovable page that order is not 0 will try to use HighAtomic.
> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> ---
>  mm/page_alloc.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c841af8..b54e94a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3642,7 +3642,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
>  }
>  
>  static inline unsigned int
> -gfp_to_alloc_flags(gfp_t gfp_mask)
> +gfp_to_alloc_flags(gfp_t gfp_mask, int order, int migratetype)
>  {
>  	unsigned int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
>  
> @@ -3671,6 +3671,8 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
>  		alloc_flags &= ~ALLOC_CPUSET;
>  	} else if (unlikely(rt_task(current)) && !in_interrupt())
>  		alloc_flags |= ALLOC_HARDER;
> +	else if (order > 0 && migratetype == MIGRATE_UNMOVABLE)
> +		alloc_flags |= ALLOC_HARDER;
>  
>  #ifdef CONFIG_CMA
>  	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
> @@ -3903,7 +3905,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	 * kswapd needs to be woken up, and to avoid the cost of setting up
>  	 * alloc_flags precisely. So we do that now.
>  	 */
> -	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> +	alloc_flags = gfp_to_alloc_flags(gfp_mask, order, ac->migratetype);
>  
>  	/*
>  	 * We need to recalculate the starting point for the zonelist iterator
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
