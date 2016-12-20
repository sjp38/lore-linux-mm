Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8776B0331
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:32:10 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id b202so339208887oii.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 07:32:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 94si11346717oti.202.2016.12.20.07.32.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Dec 2016 07:32:09 -0800 (PST)
Subject: Re: [PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161220134904.21023-1-mhocko@kernel.org>
	<20161220134904.21023-3-mhocko@kernel.org>
In-Reply-To: <20161220134904.21023-3-mhocko@kernel.org>
Message-Id: <201612210031.BFD48914.VMtHSFFJOLQFOO@I-love.SAKURA.ne.jp>
Date: Wed, 21 Dec 2016 00:31:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c8eed66d8abb..2dda7c3eba52 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3098,32 +3098,31 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	if (page)
>  		goto out;
>  
> -	if (!(gfp_mask & __GFP_NOFAIL)) {
> -		/* Coredumps can quickly deplete all memory reserves */
> -		if (current->flags & PF_DUMPCORE)
> -			goto out;
> -		/* The OOM killer will not help higher order allocs */
> -		if (order > PAGE_ALLOC_COSTLY_ORDER)
> -			goto out;
> -		/* The OOM killer does not needlessly kill tasks for lowmem */
> -		if (ac->high_zoneidx < ZONE_NORMAL)
> -			goto out;
> -		if (pm_suspended_storage())
> -			goto out;
> -		/*
> -		 * XXX: GFP_NOFS allocations should rather fail than rely on
> -		 * other request to make a forward progress.
> -		 * We are in an unfortunate situation where out_of_memory cannot
> -		 * do much for this context but let's try it to at least get
> -		 * access to memory reserved if the current task is killed (see
> -		 * out_of_memory). Once filesystems are ready to handle allocation
> -		 * failures more gracefully we should just bail out here.
> -		 */
> +	/* Coredumps can quickly deplete all memory reserves */
> +	if (current->flags & PF_DUMPCORE)
> +		goto out;
> +	/* The OOM killer will not help higher order allocs */
> +	if (order > PAGE_ALLOC_COSTLY_ORDER)
> +		goto out;
> +	/* The OOM killer does not needlessly kill tasks for lowmem */
> +	if (ac->high_zoneidx < ZONE_NORMAL)
> +		goto out;
> +	if (pm_suspended_storage())
> +		goto out;
> +	/*
> +	 * XXX: GFP_NOFS allocations should rather fail than rely on
> +	 * other request to make a forward progress.
> +	 * We are in an unfortunate situation where out_of_memory cannot
> +	 * do much for this context but let's try it to at least get
> +	 * access to memory reserved if the current task is killed (see
> +	 * out_of_memory). Once filesystems are ready to handle allocation
> +	 * failures more gracefully we should just bail out here.
> +	 */
> +
> +	/* The OOM killer may not free memory on a specific node */
> +	if (gfp_mask & __GFP_THISNODE)
> +		goto out;
>  
> -		/* The OOM killer may not free memory on a specific node */
> -		if (gfp_mask & __GFP_THISNODE)
> -			goto out;
> -	}
>  	/* Exhausted what can be done so it's blamo time */
>  	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
>  		*did_some_progress = 1;

Why do we need to change this part in this patch?

This change silently prohibits invoking the OOM killer for e.g. costly
GFP_KERNEL allocation. While it would be better if vmalloc() can be used,
there might be users who cannot accept vmalloc() as a fallback (e.g.
CONFIG_MMU=n where vmalloc() == kmalloc() ?).

This change is not "do not enforce OOM killer automatically" but "never allow
OOM killer". No exception is allowed. If we change this part, title for this part
should be something strong like "mm,oom: Never allow OOM killer for coredumps,
costly allocations, lowmem etc.".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
