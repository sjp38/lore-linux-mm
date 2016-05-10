Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 421366B025F
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:43:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so6522346wme.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:43:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si1024975wjl.68.2016.05.10.00.37.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:37:09 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 11/13] mm, compaction: add the ultimate direct compaction priority
Date: Tue, 10 May 2016 09:36:01 +0200
Message-Id: <1462865763-22084-12-git-send-email-vbabka@suse.cz>
In-Reply-To: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

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
- use MIGRATE_SYNC migration mode

The new priority should get eventually picked up by should_compact_retry() and
this should improve success rates for costly allocations using __GFP_RETRY,
such as hugetlbfs allocations, and reduce some corner-case OOM's for non-costly
allocations.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h |  1 +
 mm/compaction.c            | 15 ++++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index eeaed24e87a8..af85c620c788 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -3,6 +3,7 @@
 
 // TODO: lower value means higher priority to match reclaim, makes sense?
 enum compact_priority {
+	COMPACT_PRIO_SYNC_FULL,
 	COMPACT_PRIO_SYNC_LIGHT,
 	DEF_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
 	COMPACT_PRIO_ASYNC,
diff --git a/mm/compaction.c b/mm/compaction.c
index 7d0935e1a195..9bc475dc4c99 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1580,12 +1580,20 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 		.order = order,
 		.gfp_mask = gfp_mask,
 		.zone = zone,
-		.mode = (prio == COMPACT_PRIO_ASYNC) ?
-					MIGRATE_ASYNC :	MIGRATE_SYNC_LIGHT,
 		.alloc_flags = alloc_flags,
 		.classzone_idx = classzone_idx,
 		.direct_compaction = true,
+		.whole_zone = (prio == COMPACT_PRIO_SYNC_FULL),
+		.ignore_skip_hint = (prio == COMPACT_PRIO_SYNC_FULL)
 	};
+
+	if (prio == COMPACT_PRIO_ASYNC)
+		cc.mode = MIGRATE_ASYNC;
+	else if (prio == COMPACT_PRIO_SYNC_LIGHT)
+		cc.mode = MIGRATE_SYNC_LIGHT;
+	else
+		cc.mode = MIGRATE_SYNC;
+
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
@@ -1631,7 +1639,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 								ac->nodemask) {
 		enum compact_result status;
 
-		if (compaction_deferred(zone, order)) {
+		if (prio > COMPACT_PRIO_SYNC_FULL
+					&& compaction_deferred(zone, order)) {
 			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
 			continue;
 		}
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
