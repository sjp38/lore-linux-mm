Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 009046B0069
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 11:24:09 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d6so6713363itc.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 08:24:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x95si1025456ioi.147.2017.09.15.08.24.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 08:24:07 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
	<20170915143732.GA8397@cmpxchg.org>
In-Reply-To: <20170915143732.GA8397@cmpxchg.org>
Message-Id: <201709160023.CAE05229.MQHFSJFOOFOVtL@I-love.SAKURA.ne.jp>
Date: Sat, 16 Sep 2017 00:23:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, yuwang668899@gmail.com
Cc: mhocko@suse.com, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com, akpm@linux-foundation.org

Johannes Weiner wrote:
> How can we figure out if there is a bug here? Can we time the calls to
> __alloc_pages_direct_reclaim() and __alloc_pages_direct_compact() and
> drill down from there? Print out the number of times we have retried?
> We're counting no_progress_loops, but we are also very much interested
> in progress_loops that didn't result in a successful allocation. Too
> many of those and I think we want to OOM kill as per above.
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bec5e96f3b88..01736596389a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3830,6 +3830,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  			"page allocation stalls for %ums, order:%u",
>  			jiffies_to_msecs(jiffies-alloc_start), order);
>  		stall_timeout += 10 * HZ;
> +		goto oom;
>  	}
>  
>  	/* Avoid recursion of direct reclaim */
> @@ -3882,6 +3883,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (read_mems_allowed_retry(cpuset_mems_cookie))
>  		goto retry_cpuset;
>  
> +oom:
>  	/* Reclaim has failed us, start killing things */
>  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
>  	if (page)
> 

According to my stress tests, it is mutex_trylock() in __alloc_pages_may_oom()
that causes warn_alloc() to be called for so many times. The comment

	/*
	 * Acquire the oom lock.  If that fails, somebody else is
	 * making progress for us.
	 */

is true only if the owner of oom_lock can call out_of_memory() and is __GFP_FS
allocation. Consider a situation where there are 1 GFP_KERNEL allocating thread
and 99 GFP_NOFS/GFP_NOIO allocating threads contending the oom_lock. How likely
the OOM killer is invoked? It is very unlikely because GFP_KERNEL allocating thread
likely fails to grab oom_lock because GFP_NOFS/GFP_NOIO allocating threads is
grabing oom_lock. And GFP_KERNEL allocating thread yields CPU time for
GFP_NOFS/GFP_NOIO allocating threads to waste pointlessly.
s/!mutex_trylock(&oom_lock)/mutex_lock_killable()/ significantly improves
this situation for my stress tests. How is your case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
