Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C19EB6B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 10:37:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b195so3325973wmb.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 07:37:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b26si1389185edj.541.2017.09.15.07.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Sep 2017 07:37:41 -0700 (PDT)
Date: Fri, 15 Sep 2017 07:37:32 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
Message-ID: <20170915143732.GA8397@cmpxchg.org>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170915095849.9927-1-yuwang668899@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wang Yu <yuwang668899@gmail.com>
Cc: mhocko@suse.com, penguin-kernel@i-love.sakura.ne.jp, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>

On Fri, Sep 15, 2017 at 05:58:49PM +0800, wang Yu wrote:
> From: "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>
> 
> I found a softlockup when running some stress testcase in 4.9.x,
> but i think the mainline have the same problem.
> 
> call trace:
> [365724.502896] NMI watchdog: BUG: soft lockup - CPU#31 stuck for 22s!
> [jbd2/sda3-8:1164]

We've started seeing the same thing on 4.11. Tons and tons of
allocation stall warnings followed by the soft lock-ups.

These allocation stalls happen when the allocating task reclaims
successfully yet isn't able to allocate, meaning other threads are
stealing those pages.

Now, it *looks* like something changed recently to make this race
window wider, and there might well be a bug there. But regardless, we
have a real livelock or at least starvation window here, where
reclaimers have their bounty continuously stolen by concurrent allocs;
but instead of recognizing and handling the situation, we flood the
console which in many cases adds fuel to the fire.

When threads cannibalize each other to the point where one of them can
reclaim but not allocate for 10s, it's safe to say we are out of
memory. I think we need something like the below regardless of any
other investigations and fixes into the root cause here.

But Michal, this needs an answer. We don't want to paper over bugs,
but we also cannot continue to ship a kernel that has a known issue
and for which there are mitigation fixes, root-caused or not.

How can we figure out if there is a bug here? Can we time the calls to
__alloc_pages_direct_reclaim() and __alloc_pages_direct_compact() and
drill down from there? Print out the number of times we have retried?
We're counting no_progress_loops, but we are also very much interested
in progress_loops that didn't result in a successful allocation. Too
many of those and I think we want to OOM kill as per above.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bec5e96f3b88..01736596389a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3830,6 +3830,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
 		stall_timeout += 10 * HZ;
+		goto oom;
 	}
 
 	/* Avoid recursion of direct reclaim */
@@ -3882,6 +3883,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (read_mems_allowed_retry(cpuset_mems_cookie))
 		goto retry_cpuset;
 
+oom:
 	/* Reclaim has failed us, start killing things */
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
 	if (page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
