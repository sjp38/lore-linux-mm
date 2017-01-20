Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8C26B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:38:56 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c206so4675385wme.3
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:38:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i22si7475486wrc.81.2017.01.20.02.38.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 02:38:55 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/4] mm, page_alloc: fix fast-path race with cpuset update or removal
Date: Fri, 20 Jan 2017 11:38:41 +0100
Message-Id: <20170120103843.24587-3-vbabka@suse.cz>
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

One possible cause is that in the fast path we find the preferred zoneref
according to current mems_allowed, so that it points to the middle of the
zonelist, skipping e.g. zones of node 1 completely. If the mems_allowed is
updated to contain only node 1, we never reach it in the zonelist, and trigger
OOM before checking the cpuset_mems_cookie.

This patch fixes the particular case by redoing the preferred zoneref search
if we switch back to the original nodemask. The condition is also slightly
changed so that when the last non-root cpuset is removed, we don't miss it.

Note that this is not a full fix, and more patches will follow.

Reported-by: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Fixes: 682a3385e773 ("mm, page_alloc: inline the fast path of the zonelist iterator")
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d771f3fb835..3ca0c15deca4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3804,9 +3804,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	/*
 	 * Restore the original nodemask if it was potentially replaced with
 	 * &cpuset_current_mems_allowed to optimize the fast-path attempt.
+	 * Also recalculate the starting point for the zonelist iterator or
+	 * we could end up iterating over non-eligible zones endlessly.
 	 */
-	if (cpusets_enabled())
+	if (unlikely(ac.nodemask != nodemask)) {
 		ac.nodemask = nodemask;
+		ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
+						ac.high_zoneidx, ac.nodemask);
+		if (!ac.preferred_zoneref->zone)
+			goto no_zone;
+	}
+
 	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
 
 no_zone:
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
