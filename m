Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7C26B0098
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 10:29:37 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so436271pdb.4
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 07:29:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id kp7si9719083pdb.137.2015.02.19.07.29.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 07:29:35 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150218104859.GM12722@dastard>
	<20150218121602.GC4478@dhcp22.suse.cz>
	<20150219110124.GC15569@phnom.home.cmpxchg.org>
	<20150219122914.GH28427@dhcp22.suse.cz>
	<20150219125844.GI28427@dhcp22.suse.cz>
In-Reply-To: <20150219125844.GI28427@dhcp22.suse.cz>
Message-Id: <201502200029.DEG78137.QFVLHFFOJMtOOS@I-love.SAKURA.ne.jp>
Date: Fri, 20 Feb 2015 00:29:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

Michal Hocko wrote:
> On Thu 19-02-15 13:29:14, Michal Hocko wrote:
> [...]
> > Something like the following.
> __GFP_HIGH doesn't seem to be sufficient so we would need something
> slightly else but the idea is still the same:
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8d52ab18fe0d..2d224bbdf8e8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2599,6 +2599,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
>  	bool deferred_compaction = false;
>  	int contended_compaction = COMPACT_CONTENDED_NONE;
> +	int oom = 0;
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -2635,6 +2636,15 @@ retry:
>  	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>  
>  	/*
> +	 * __GFP_NOFAIL allocations cannot fail but yet the current context
> +	 * might be blocking resources needed by the OOM victim to terminate.
> +	 * Allow the caller to dive into memory reserves to succeed the
> +	 * allocation and break out from a potential deadlock.
> +	 */

We don't know how many callers will pass __GFP_NOFAIL. But if 1000
threads are doing the same operation which requires __GFP_NOFAIL
allocation with a lock held, wouldn't memory reserves deplete?

This heuristic can't continue if memory reserves depleted or
continuous pages of requested order cannot be found.

> +	if (oom > 10 && (gfp_mask & __GFP_NOFAIL))
> +		alloc_flags |= ALLOC_NO_WATERMARKS;
> +
> +	/*
>  	 * Find the true preferred zone if the allocation is unconstrained by
>  	 * cpusets.
>  	 */
> @@ -2759,6 +2769,8 @@ retry:
>  				goto got_pg;
>  			if (!did_some_progress)
>  				goto nopage;
> +
> +			oom++;
>  		}
>  		/* Wait for some write requests to complete then retry */
>  		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
