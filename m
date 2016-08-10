Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C19BA828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:12:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so53013064wmz.2
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:12:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e73si7147196wma.8.2016.08.10.02.12.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:42 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 05/11] mm, compaction: add the ultimate direct compaction priority
Date: Wed, 10 Aug 2016 11:12:20 +0200
Message-Id: <20160810091226.6709-6-vbabka@suse.cz>
In-Reply-To: <20160810091226.6709-1-vbabka@suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

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
index e88c037afe47..a1fba9994728 100644
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
index a144f58f7193..ae4f40afcca1 100644
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
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
