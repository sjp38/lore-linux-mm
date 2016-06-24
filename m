Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3A16B0264
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:55:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so13293377wmr.0
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:55:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t205si3228837wmb.32.2016.06.24.02.55.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 02:55:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 11/17] mm, compaction: add the ultimate direct compaction priority
Date: Fri, 24 Jun 2016 11:54:31 +0200
Message-Id: <20160624095437.16385-12-vbabka@suse.cz>
In-Reply-To: <20160624095437.16385-1-vbabka@suse.cz>
References: <20160624095437.16385-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

During reclaim/compaction loop, it's desirable to get a final answer from
unsuccessful compaction so we can either fail the allocation or invoke the OOM
killer. However, heuristics such as deferred compaction or pageblock skip bits
can cause compaction to skip parts or whole zones and lead to premature OOM's,
failures or excessive reclaim/compaction retries.

To remedy this, we introduce a new direct compaction priority called
COMPACT_PRIO_SYNC_FULL, which instructs direct compaction to:

- ignore deferred compaction status for a zone
- ignore pageblock skip hints
- ignore cached scanner positions and scan the whole zone

The new priority should get eventually picked up by should_compact_retry() and
this should improve success rates for costly allocations using __GFP_REPEAT,
such as hugetlbfs allocations, and reduce some corner-case OOM's for non-costly
allocations.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h | 3 ++-
 mm/compaction.c            | 5 ++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 0cc702ec80a2..869b594cf4ff 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -6,8 +6,9 @@
  * Lower value means higher priority, analogically to reclaim priority.
  */
 enum compact_priority {
+	COMPACT_PRIO_SYNC_FULL,
+	MIN_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_FULL,
 	COMPACT_PRIO_SYNC_LIGHT,
-	MIN_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
 	DEF_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
 	COMPACT_PRIO_ASYNC,
 	INIT_COMPACT_PRIORITY = COMPACT_PRIO_ASYNC
diff --git a/mm/compaction.c b/mm/compaction.c
index 5c15db0001a5..76897850c3c2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1644,6 +1644,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 		.alloc_flags = alloc_flags,
 		.classzone_idx = classzone_idx,
 		.direct_compaction = true,
+		.whole_zone = (prio == COMPACT_PRIO_SYNC_FULL),
+		.ignore_skip_hint = (prio == COMPACT_PRIO_SYNC_FULL)
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -1689,7 +1691,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 								ac->nodemask) {
 		enum compact_result status;
 
-		if (compaction_deferred(zone, order)) {
+		if (prio > COMPACT_PRIO_SYNC_FULL
+					&& compaction_deferred(zone, order)) {
 			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
 			continue;
 		}
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
