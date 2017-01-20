Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5588B6B025E
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:38:58 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so14051317wjb.5
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:38:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si7479882wrg.54.2017.01.20.02.38.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 02:38:57 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 4/4] mm, page_alloc: fix premature OOM when racing with cpuset mems update
Date: Fri, 20 Jan 2017 11:38:43 +0100
Message-Id: <20170120103843.24587-5-vbabka@suse.cz>
In-Reply-To: <20170120103843.24587-1-vbabka@suse.cz>
References: <20170120103843.24587-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

Ganapatrao Kulkarni reported that the LTP test cpuset01 in stress mode triggers
OOM killer in few seconds, despite lots of free memory. The test attempts to
repeatedly fault in memory in one process in a cpuset, while changing allowed
nodes of the cpuset between 0 and 1 in another process.

The problem comes from insufficient protection against cpuset changes, which
can cause get_page_from_freelist() to consider all zones as non-eligible due to
nodemask and/or current->mems_allowed. This was masked in the past by
sufficient retries, but since commit 682a3385e773 ("mm, page_alloc: inline the
fast path of the zonelist iterator") we fix the preferred_zoneref once, and
don't iterate over the whole zonelist in further attempts, thus the only
eligible zones might be placed in the zonelist before our starting point and we
always miss them.

A previous patch fixed this problem for current->mems_allowed. However, cpuset
changes also update the task's mempolicy nodemask. The fix has two parts. We
have to repeat the preferred_zoneref search when we detect cpuset update by way
of seqcount, and we have to check the seqcount before considering OOM.

Reported-by: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Fixes: c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in a zonelist twice")
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 35 ++++++++++++++++++++++++-----------
 1 file changed, 24 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fd3b9839a355..1c331ff6fdc4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3555,6 +3555,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	no_progress_loops = 0;
 	compact_priority = DEF_COMPACT_PRIORITY;
 	cpuset_mems_cookie = read_mems_allowed_begin();
+	/*
+	 * We need to recalculate the starting point for the zonelist iterator
+	 * because we might have used different nodemask in the fast path, or
+	 * there was a cpuset modification and we are retrying - otherwise we
+	 * could end up iterating over non-eligible zones endlessly.
+	 */
+	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
+					ac->high_zoneidx, ac->nodemask);
+	if (!ac->preferred_zoneref->zone)
+		goto nopage;
+
 
 	/*
 	 * The fast path uses conservative alloc_flags to succeed only until
@@ -3715,6 +3726,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				&compaction_retries))
 		goto retry;
 
+	/*
+	 * It's possible we raced with cpuset update so the OOM would be
+	 * premature (see below the nopage: label for full explanation).
+	 */
+	if (read_mems_allowed_retry(cpuset_mems_cookie))
+		goto retry_cpuset;
+
 	/* Reclaim has failed us, start killing things */
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
 	if (page)
@@ -3728,10 +3746,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 nopage:
 	/*
-	 * When updating a task's mems_allowed, it is possible to race with
-	 * parallel threads in such a way that an allocation can fail while
-	 * the mask is being updated. If a page allocation is about to fail,
-	 * check if the cpuset changed during allocation and if so, retry.
+	 * When updating a task's mems_allowed or mempolicy nodeask, it is
+	 * possible to race with parallel threads in such a way that our
+	 * allocation can fail while the mask is being updated. If we are about
+	 * to fail, check if the cpuset changed during allocation and if so,
+	 * retry.
 	 */
 	if (read_mems_allowed_retry(cpuset_mems_cookie))
 		goto retry_cpuset;
@@ -3822,15 +3841,9 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	/*
 	 * Restore the original nodemask if it was potentially replaced with
 	 * &cpuset_current_mems_allowed to optimize the fast-path attempt.
-	 * Also recalculate the starting point for the zonelist iterator or
-	 * we could end up iterating over non-eligible zones endlessly.
 	 */
-	if (unlikely(ac.nodemask != nodemask)) {
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
