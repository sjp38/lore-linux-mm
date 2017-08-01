Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5B96B0561
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 11:30:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s21so1986454oie.5
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 08:30:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m11si10503459oib.497.2017.08.01.08.30.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 08:30:47 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm, oom: do not rely on TIF_MEMDIE for memory reserves access
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170727090357.3205-1-mhocko@kernel.org>
	<20170727090357.3205-2-mhocko@kernel.org>
In-Reply-To: <20170727090357.3205-2-mhocko@kernel.org>
Message-Id: <201708020030.ACB04683.JLHMFVOSFFOtOQ@I-love.SAKURA.ne.jp>
Date: Wed, 2 Aug 2017 00:30:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> CONFIG_MMU=n doesn't have oom reaper so let's stick to the original
> ALLOC_NO_WATERMARKS approach but be careful because they still might
> deplete all the memory reserves so keep the semantic as close to the
> original implementation as possible and give them access to memory
> reserves only up to exit_mm (when tsk->mm is cleared) rather than while
> tsk_is_oom_victim which is until signal struct is gone.

Currently memory allocations from __mmput() can use memory reserves but
this patch changes __mmput() not to use memory reserves. You say "keep
the semantic as close to the original implementation as possible" but
this change is not guaranteed to be safe.

> @@ -2943,10 +2943,19 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
>  	 * the high-atomic reserves. This will over-estimate the size of the
>  	 * atomic reserve but it avoids a search.
>  	 */
> -	if (likely(!alloc_harder))
> +	if (likely(!alloc_harder)) {
>  		free_pages -= z->nr_reserved_highatomic;
> -	else
> -		min -= min / 4;
> +	} else {
> +		/*
> +		 * OOM victims can try even harder than normal ALLOC_HARDER
> +		 * users
> +		 */
> +		if (alloc_flags & ALLOC_OOM)

ALLOC_OOM is ALLOC_NO_WATERMARKS if CONFIG_MMU=n.
I wonder this test makes sense for ALLOC_NO_WATERMARKS.

> +			min -= min / 2;
> +		else
> +			min -= min / 4;
> +	}
> +
>  
>  #ifdef CONFIG_CMA
>  	/* If allocation can't use CMA areas don't use free CMA pages */
> @@ -3603,6 +3612,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	return alloc_flags;
>  }
>  
> +static bool oom_reserves_allowed(struct task_struct *tsk)
> +{
> +	if (!tsk_is_oom_victim(tsk))
> +		return false;
> +
> +	/*
> +	 * !MMU doesn't have oom reaper so we shouldn't risk the memory reserves
> +	 * depletion and shouldn't give access to memory reserves passed the
> +	 * exit_mm
> +	 */
> +	if (!IS_ENABLED(CONFIG_MMU) && !tsk->mm)
> +		return false;

Branching based on CONFIG_MMU is ugly. I suggest timeout based next OOM
victim selection if CONFIG_MMU=n. Then, we no longer need to worry about
memory reserves depletion and we can treat equally.

> +
> +	return true;
> +}
> +
>  bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  {
>  	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))

> @@ -3770,6 +3795,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	unsigned long alloc_start = jiffies;
>  	unsigned int stall_timeout = 10 * HZ;
>  	unsigned int cpuset_mems_cookie;
> +	bool reserves;
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3875,15 +3901,24 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>  		wake_all_kswapds(order, ac);
>  
> -	if (gfp_pfmemalloc_allowed(gfp_mask))
> -		alloc_flags = ALLOC_NO_WATERMARKS;
> +	/*
> +	 * Distinguish requests which really need access to whole memory
> +	 * reserves from oom victims which can live with their own reserve
> +	 */
> +	reserves = gfp_pfmemalloc_allowed(gfp_mask);
> +	if (reserves) {
> +		if (tsk_is_oom_victim(current))
> +			alloc_flags = ALLOC_OOM;

If reserves == true due to reasons other than tsk_is_oom_victim(current) == true
(e.g. __GFP_MEMALLOC), why dare to reduce it?

> +		else
> +			alloc_flags = ALLOC_NO_WATERMARKS;
> +	}

If CONFIG_MMU=n, doing this test is silly.

if (tsk_is_oom_victim(current))
	alloc_flags = ALLOC_NO_WATERMARKS;
else
	alloc_flags = ALLOC_NO_WATERMARKS;

>  
>  	/*
>  	 * Reset the zonelist iterators if memory policies can be ignored.
>  	 * These allocations are high priority and system rather than user
>  	 * orientated.
>  	 */
> -	if (!(alloc_flags & ALLOC_CPUSET) || (alloc_flags & ALLOC_NO_WATERMARKS)) {
> +	if (!(alloc_flags & ALLOC_CPUSET) || reserves) {
>  		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
>  		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
>  					ac->high_zoneidx, ac->nodemask);
> @@ -3960,7 +3995,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto got_pg;
>  
>  	/* Avoid allocations with no watermarks from looping endlessly */
> -	if (test_thread_flag(TIF_MEMDIE) &&
> +	if (tsk_is_oom_victim(current) &&
>  	    (alloc_flags == ALLOC_NO_WATERMARKS ||
>  	     (gfp_mask & __GFP_NOMEMALLOC)))
>  		goto nopage;

And you are silently changing to "!costly __GFP_DIRECT_RECLAIM allocations never fail
(even selected for OOM victims)" (i.e. updating the too small to fail memory allocation
rule) by doing alloc_flags == ALLOC_NO_WATERMARKS if CONFIG_MMU=y.

Applying this change might disturb memory allocation behavior. I don't like this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
