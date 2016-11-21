Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83A696B04DB
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 01:03:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so32132712wmf.3
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 22:03:17 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id sc5si18493930wjb.155.2016.11.20.22.03.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 22:03:16 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u144so23913196wmu.0
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 22:03:15 -0800 (PST)
Date: Mon, 21 Nov 2016 07:03:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Don't fail costly __GFP_NOFAIL
 allocations.
Message-ID: <20161121060313.GB29816@dhcp22.suse.cz>
References: <1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, stable@vger.kernel.org

On Thu 17-11-16 21:50:04, Tetsuo Handa wrote:
> Filesystem code might request costly __GFP_NOFAIL !__GFP_REPEAT GFP_NOFS
> allocations. But commit 0a0337e0d1d13446 ("mm, oom: rework oom detection")
> overlooked that __GFP_NOFAIL allocation requests need to invoke the OOM
> killer and retry even if order > PAGE_ALLOC_COSTLY_ORDER && !__GFP_REPEAT.
> The caller will crash if such allocation request failed.

Could you point to such an allocation request please? Costly GFP_NOFAIL
requests are a really high requirement and I am even not sure we should
support them. buffered_rmqueue already warns about order > 1 NOFAIL
allocations.

I am not saying the patch is incorrect but it sounds more a theoretical
than practical issue which should be considered when involving the
stable tree here. To be honest I would rather see a single place which
handles all NOFAIL fallbacks rather than make the code even more
convoluted than it is already.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: <stable@vger.kernel.org> # 4.7+
> ---
>  mm/page_alloc.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440..b458f00 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3650,9 +3650,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  
>  	/*
>  	 * Do not retry costly high order allocations unless they are
> -	 * __GFP_REPEAT
> +	 * __GFP_REPEAT or __GFP_NOFAIL
>  	 */
> -	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
> +	if (order > PAGE_ALLOC_COSTLY_ORDER &&
> +	    !(gfp_mask & (__GFP_REPEAT | __GFP_NOFAIL)))
>  		goto nopage;
>  
>  	/* Make sure we know about allocations which stall for too long */
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
