Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5316B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:03:27 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d8so16070680pgt.1
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:03:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si4202656pgc.223.2017.09.17.23.03.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 23:03:25 -0700 (PDT)
Date: Mon, 18 Sep 2017 08:03:10 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
Message-ID: <20170918060310.wv2r2yob22d2pgpr@dhcp22.suse.cz>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
 <20170915143732.GA8397@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170915143732.GA8397@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: wang Yu <yuwang668899@gmail.com>, penguin-kernel@i-love.sakura.ne.jp, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>

On Fri 15-09-17 07:37:32, Johannes Weiner wrote:
> On Fri, Sep 15, 2017 at 05:58:49PM +0800, wang Yu wrote:
> > From: "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>
> > 
> > I found a softlockup when running some stress testcase in 4.9.x,
> > but i think the mainline have the same problem.
> > 
> > call trace:
> > [365724.502896] NMI watchdog: BUG: soft lockup - CPU#31 stuck for 22s!
> > [jbd2/sda3-8:1164]
> 
> We've started seeing the same thing on 4.11. Tons and tons of
> allocation stall warnings followed by the soft lock-ups.

Is the RIP consistent? Where it is reported?

> These allocation stalls happen when the allocating task reclaims
> successfully yet isn't able to allocate, meaning other threads are
> stealing those pages.
> 
> Now, it *looks* like something changed recently to make this race
> window wider, and there might well be a bug there. But regardless, we
> have a real livelock or at least starvation window here, where
> reclaimers have their bounty continuously stolen by concurrent allocs;
> but instead of recognizing and handling the situation, we flood the
> console which in many cases adds fuel to the fire.
> 
> When threads cannibalize each other to the point where one of them can
> reclaim but not allocate for 10s, it's safe to say we are out of
> memory. I think we need something like the below regardless of any
> other investigations and fixes into the root cause here.
> 
> But Michal, this needs an answer. We don't want to paper over bugs,
> but we also cannot continue to ship a kernel that has a known issue
> and for which there are mitigation fixes, root-caused or not.

I am more than happy to ack a fix that actually makes sense. I haven't
seen any so far to be honest. All of them were puting locks around this
stall warning path which is imho not the right way forward. Seeing soft
lockups just because of stall warning is really bad and if it happens
during your normal workloads then I am perfectly happy to ditch the
whole stall warning thingy.
 
> How can we figure out if there is a bug here? Can we time the calls to
> __alloc_pages_direct_reclaim() and __alloc_pages_direct_compact() and
> drill down from there? Print out the number of times we have retried?
> We're counting no_progress_loops, but we are also very much interested
> in progress_loops that didn't result in a successful allocation. Too
> many of those and I think we want to OOM kill as per above.

I do not think so. Low priority thread not making progress you get us
easily into OOM and we do not want to kill in that case.

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
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
