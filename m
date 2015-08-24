Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id DAB106B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:03:22 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so66795846wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:03:22 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id o5si20555995wiz.39.2015.08.24.03.03.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 03:03:21 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so67005610wic.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:03:20 -0700 (PDT)
Date: Mon, 24 Aug 2015 12:03:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 1/2] mm: Fix race between setting TIF_MEMDIE and
 __alloc_pages_high_priority().
Message-ID: <20150824100319.GG17078@dhcp22.suse.cz>
References: <201508231621.EGJ17658.FFQJtFSLVOOHMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508231621.EGJ17658.FFQJtFSLVOOHMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Sun 23-08-15 16:21:41, Tetsuo Handa wrote:
> >From 4a3cf5be07a66cf3906a380e77ba5e2ac1b2b3d5 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 1 Aug 2015 22:39:30 +0900
> Subject: [PATCH 1/2] mm: Fix race between setting TIF_MEMDIE and
>  __alloc_pages_high_priority().
> 
> Currently, TIF_MEMDIE is checked at gfp_to_alloc_flags() which is before
> calling __alloc_pages_high_priority() and at
> 
>   /* Avoid allocations with no watermarks from looping endlessly */
>   if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> 
> which is after returning from __alloc_pages_high_priority(). This means
> that if TIF_MEMDIE is set between returning from gfp_to_alloc_flags() and
> checking test_thread_flag(TIF_MEMDIE), the allocation can fail without
> calling __alloc_pages_high_priority(). We need to replace
> "test_thread_flag(TIF_MEMDIE)" with "whether TIF_MEMDIE was already set
> as of calling gfp_to_alloc_flags()" in order to close this race window.
> 
> Since gfp_to_alloc_flags() includes ALLOC_NO_WATERMARKS for several cases,
> it will be more correct to replace "test_thread_flag(TIF_MEMDIE)" with
> "whether gfp_to_alloc_flags() included ALLOC_NO_WATERMARKS" because the
> purpose of test_thread_flag(TIF_MEMDIE) is to give up immediately if
> __alloc_pages_high_priority() failed.

Yes TIF_MEMDIE setting is inherently racy. We will fail the allocation
without diving into reserves. Why is that a problem?
The comment above the check is misleading but now you are allowing to
fail all ALLOC_NO_WATERMARKS (without __GFP_NOFAIL) allocations before
entering the direct reclaim and compaction. This seems incorrect. What
about __GFP_MEMALLOC requests?

I think the check for TIF_MEMDIE makes more sense here.

> 
> Note that we could simply do
> 
>   if (alloc_flags & ALLOC_NO_WATERMARKS) {
>     ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
>     page = __alloc_pages_high_priority(gfp_mask, order, ac);
>     if (page)
>       goto got_pg;
>     WARN_ON_ONCE(!wait && (gfp_mask & __GFP_NOFAIL));
>     goto nopage;
>   }
> 
> instead of changing to
> 
>   if ((alloc_flags & ALLOC_NO_WATERMARKS) && !(gfp_mask & __GFP_NOFAIL))
>     goto nopage;
> 
> if we can duplicate
> 
>   if (!wait) {
>     WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
>     goto nopage;
>   }
> 
> .
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4b220cb..37a0390 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3085,7 +3085,7 @@ retry:
>  		goto nopage;
>  
>  	/* Avoid allocations with no watermarks from looping endlessly */
> -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> +	if ((alloc_flags & ALLOC_NO_WATERMARKS) && !(gfp_mask & __GFP_NOFAIL))
>  		goto nopage;
>  
>  	/*
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
