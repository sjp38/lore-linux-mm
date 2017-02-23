Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC7D6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 06:16:14 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e15so3193297wmd.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 03:16:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m19si6035732wmg.107.2017.02.23.03.16.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 03:16:12 -0800 (PST)
Date: Thu, 23 Feb 2017 12:16:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm/vmscan: fix high cpu usage of kswapd if there
Message-ID: <20170223111609.hlncnvokhq3quxwz@dhcp22.suse.cz>
References: <1487754288-5149-1-git-send-email-hejianet@gmail.com>
 <20170222201657.GA6534@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222201657.GA6534@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jia He <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed 22-02-17 15:16:57, Johannes Weiner wrote:
[...]
> And a follow-up: once it gives up, when should kswapd return to work?
> We used to reset NR_PAGES_SCANNED whenever a page gets freed. But
> that's a branch in a common allocator path, just to recover kswapd - a
> latency tool, not a necessity for functional correctness - from a
> situation that's exceedingly pretty rare. How about we leave it
> disabled until a direct reclaimer manages to free something?

Hmm, I guess we also want to reset the counter after OOM invocation
which might free a lot of memory and we do not want to wait for the
direct reclaim to resurrect the kswapd. Something like the following on
top of yours
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ddf27c435225..6be11c18551f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3446,7 +3446,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
+static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac,
+		bool force)
 {
 	struct zoneref *z;
 	struct zone *zone;
@@ -3454,8 +3455,11 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 					ac->high_zoneidx, ac->nodemask) {
-		if (last_pgdat != zone->zone_pgdat)
+		if (last_pgdat != zone->zone_pgdat) {
+			if (force)
+				zone->zone_pgdat->kswapd_failed_runs = 0;
 			wakeup_kswapd(zone, order, ac->high_zoneidx);
+		}
 		last_pgdat = zone->zone_pgdat;
 	}
 }
@@ -3640,6 +3644,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
 	unsigned int cpuset_mems_cookie;
+	bool kick_kswapd = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3685,7 +3690,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
-		wake_all_kswapds(order, ac);
+		wake_all_kswapds(order, ac, false);
 
 	/*
 	 * The adjusted alloc_flags might result in immediate success, so try
@@ -3738,7 +3743,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 retry:
 	/* Ensure kswapd doesn't accidentally go to sleep as long as we loop */
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
-		wake_all_kswapds(order, ac);
+		wake_all_kswapds(order, ac, kick_kswapd);
+	kick_kswapd = false;
 
 	if (gfp_pfmemalloc_allowed(gfp_mask))
 		alloc_flags = ALLOC_NO_WATERMARKS;
@@ -3833,6 +3839,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
+		kick_kswapd = true;
 		goto retry;
 	}
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
