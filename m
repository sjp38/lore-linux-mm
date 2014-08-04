Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6933B6B0037
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 16:35:16 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so8203617wgg.31
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 13:35:15 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id bx10si35967438wjc.63.2014.08.04.13.35.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 13:35:08 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: clean up reclaim size variable use in try_charge()
Date: Mon,  4 Aug 2014 16:35:02 -0400
Message-Id: <1407184502-20818-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Charge reclaim and OOM currently use the charge batch variable, but
batching is already disabled at that point.  To simplify the charge
logic, the batch variable is reset to the original request size when
reclaim is entered, so it's functionally equal, but it's misleading.

Switch reclaim/OOM to nr_pages, which is the original request size.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8d65dadeec1b..ec4dcf1b9562 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2574,7 +2574,7 @@ retry:
 
 	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
 
-	if (mem_cgroup_margin(mem_over_limit) >= batch)
+	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		goto retry;
 
 	if (gfp_mask & __GFP_NORETRY)
@@ -2588,7 +2588,7 @@ retry:
 	 * unlikely to succeed so close to the limit, and we fall back
 	 * to regular pages anyway in case of failure.
 	 */
-	if (nr_reclaimed && batch <= (1 << PAGE_ALLOC_COSTLY_ORDER))
+	if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
 		goto retry;
 	/*
 	 * At task move, charge accounts can be doubly counted. So, it's
@@ -2606,7 +2606,7 @@ retry:
 	if (fatal_signal_pending(current))
 		goto bypass;
 
-	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
+	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(nr_pages));
 nomem:
 	if (!(gfp_mask & __GFP_NOFAIL))
 		return -ENOMEM;
-- 
2.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
