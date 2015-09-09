Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 696C86B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 18:23:10 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so22352907pad.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 15:23:10 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id y1si13900765pas.28.2015.09.09.15.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 15:23:09 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so22398063pac.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 15:23:09 -0700 (PDT)
Date: Wed, 9 Sep 2015 15:23:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [REPOST] [PATCH 2/2] mm: Fix potentially scheduling in GFP_ATOMIC
 allocations.
In-Reply-To: <201509031755.GGJ39045.JOFLOHOQtMVFSF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1509091521460.21685@chino.kir.corp.google.com>
References: <201508231623.DED13020.tFOHFVFQOSOLMJ@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1509011519170.11913@chino.kir.corp.google.com> <201509031755.GGJ39045.JOFLOHOQtMVFSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu, 3 Sep 2015, Tetsuo Handa wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b5240b..7358225 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3046,15 +3046,8 @@ retry:
>  	}
>  
>  	/* Atomic allocations - we can't balance anything */
> -	if (!wait) {
> -		/*
> -		 * All existing users of the deprecated __GFP_NOFAIL are
> -		 * blockable, so warn of any new users that actually allow this
> -		 * type of allocation to fail.
> -		 */
> -		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
> +	if (!wait)
>  		goto nopage;
> -	}
>  
>  	/* Avoid recursion of direct reclaim */
>  	if (current->flags & PF_MEMALLOC)
> @@ -3183,6 +3176,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  
>  	lockdep_trace_alloc(gfp_mask);
>  
> +	/*
> +	 * All existing users of the __GFP_NOFAIL have __GFP_WAIT.
> +	 * __GFP_NOFAIL allocations without __GFP_WAIT is unassured.
> +	 */
> +	WARN_ON_ONCE((gfp_mask & (__GFP_NOFAIL | __GFP_WAIT)) == __GFP_NOFAIL);
> +
>  	might_sleep_if(gfp_mask & __GFP_WAIT);
>  
>  	if (should_fail_alloc_page(gfp_mask, order))

This is correct, but since there are no GFP_ATOMIC | __GFP_NOFAIL callers 
in the tree, this would needlessly add the check to the fastpath and never 
trigger.  That's why it currently exists only in the slowpath.  It's more 
for documentation than actually triggering, although bug reports would 
always be welcome to report new callers.  Documentation can always be 
improved, however.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
