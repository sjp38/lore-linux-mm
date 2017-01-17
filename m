Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81A3A6B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 17:16:27 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so15841294wjb.7
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 14:16:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w81si17489666wmg.39.2017.01.17.14.16.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 14:16:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/4] mm, page_alloc: fix fast-path race with cpuset update or removal
Date: Tue, 17 Jan 2017 23:16:08 +0100
Message-Id: <20170117221610.22505-3-vbabka@suse.cz>
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
---
 mm/page_alloc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 593a11d8bc6b..dedadb4a779f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3783,9 +3783,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
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
