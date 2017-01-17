Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 93C706B025E
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 17:16:27 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so36182694wme.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 14:16:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 17si17467067wmo.84.2017.01.17.14.16.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 14:16:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 4/4] mm, page_alloc: fix premature OOM when racing with cpuset mems update
Date: Tue, 17 Jan 2017 23:16:10 +0100
Message-Id: <20170117221610.22505-5-vbabka@suse.cz>
In-Reply-To: <20170117221610.22505-1-vbabka@suse.cz>
References: <20170117221610.22505-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Ganapatrao Kulkarni reported that the LTP test cpuset01 in stress mode triggers
OOM killer in few seconds, despite lots of free memory. The test attemps to
repeatedly fault in memory in one process in a cpuset, while changing allowed
nodes of the cpuset between 0 and 1 in another process.

The problem comes from insufficient protection against cpuset changes, which
can cause get_page_from_freelist() to consider all zones as non-eligible due to
nodemask and/or current->mems_allowed. This was masked in the past by
sufficient retries, but since commit 682a3385e773 ("mm, page_alloc: inline the
fast path of the zonelist iterator") we fix the preferred_zoneref once, and
don't iterate the whole zonelist in further attempts.

A previous patch fixed this problem for current->mems_allowed. However, cpuset
changes also update the policy nodemasks. The fix has two parts. We have to
repeat the preferred_zoneref search when we detect cpuset update by way of
seqcount, and we have to check the seqcount before considering OOM.

Reported-by: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Fixes: 682a3385e773 ("mm, page_alloc: inline the fast path of the zonelist iterator")
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bbc3f015f796..4db451270b08 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3534,6 +3534,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	no_progress_loops = 0;
 	compact_priority = DEF_COMPACT_PRIORITY;
 	cpuset_mems_cookie = read_mems_allowed_begin();
+	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
+					ac->high_zoneidx, ac->nodemask);
+	if (!ac->preferred_zoneref->zone)
+		goto nopage;
+
 
 	/*
 	 * The fast path uses conservative alloc_flags to succeed only until
@@ -3694,6 +3699,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				&compaction_retries))
 		goto retry;
 
+	if (read_mems_allowed_retry(cpuset_mems_cookie))
+		goto retry_cpuset;
+
 	/* Reclaim has failed us, start killing things */
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
 	if (page)
@@ -3789,6 +3797,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (likely(page))
 		goto out;
 
+no_zone:
 	/*
 	 * Runtime PM, block IO and its error handling path can deadlock
 	 * because I/O on the device might not complete.
@@ -3802,13 +3811,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	 * Also recalculate the starting point for the zonelist iterator or
 	 * we could end up iterating over non-eligible zones endlessly.
 	 */
-	if (unlikely(ac.nodemask != nodemask)) {
-no_zone:
+	if (unlikely(ac.nodemask != nodemask))
 		ac.nodemask = nodemask;
-		ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
-						ac.high_zoneidx, ac.nodemask);
-		/* If we have NULL preferred zone, slowpath wll handle that */
-	}
 
 	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
