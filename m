Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA2E6B025E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 04:51:05 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id p65so104882111wmp.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 01:51:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z205si28744933wmb.97.2016.03.31.01.51.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 01:51:01 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/4] mm, compaction: reduce spurious pcplist drains
Date: Thu, 31 Mar 2016 10:50:34 +0200
Message-Id: <1459414236-9219-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
References: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

Compaction drains the local pcplists each time migration scanner moves away
from a cc->order aligned block where it isolated pages for migration, so that
the pages freed by migrations can merge into higher orders.

The detection is currently coarser than it could be. The cc->last_migrated_pfn
variable should track the lowest pfn that was isolated for migration. But it
is set to the pfn where isolate_migratepages_block() starts scanning, which is
typically the first pfn of the pageblock. There, the scanner might fail to
isolate several order-aligned blocks, and then isolate COMPACT_CLUSTER_MAX in
another block. This would cause the pcplists drain to be performed, although
the scanner didn't yet finish the block where it isolated from.

This patch thus makes cc->last_migrated_pfn handling more accurate by setting
it to the pfn of an actually isolated page in isolate_migratepages_block().
Although practical effects of this patch are likely low, it arguably makes the
intent of the code more obvious. Also the next patch will make async direct
compaction skip blocks more aggressively, and draining pcplists due to skipped
blocks is wasteful.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 3319145a387d..74b4b775459e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -787,6 +787,15 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		cc->nr_migratepages++;
 		nr_isolated++;
 
+		/*
+		 * Record where we could have freed pages by migration and not
+		 * yet flushed them to buddy allocator.
+		 * - this is the lowest page that was isolated and likely be
+		 * then freed by migration.
+		 */
+		if (!cc->last_migrated_pfn)
+			cc->last_migrated_pfn = low_pfn;
+
 		/* Avoid isolating too much */
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
 			++low_pfn;
@@ -1083,7 +1092,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	unsigned long block_start_pfn;
 	unsigned long block_end_pfn;
 	unsigned long low_pfn;
-	unsigned long isolate_start_pfn;
 	struct page *page;
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
@@ -1138,7 +1146,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 
 		/* Perform the isolation */
-		isolate_start_pfn = low_pfn;
 		low_pfn = isolate_migratepages_block(cc, low_pfn,
 						block_end_pfn, isolate_mode);
 
@@ -1148,15 +1155,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		}
 
 		/*
-		 * Record where we could have freed pages by migration and not
-		 * yet flushed them to buddy allocator.
-		 * - this is the lowest page that could have been isolated and
-		 * then freed by migration.
-		 */
-		if (cc->nr_migratepages && !cc->last_migrated_pfn)
-			cc->last_migrated_pfn = isolate_start_pfn;
-
-		/*
 		 * Either we isolated something and proceed with migration. Or
 		 * we failed and compact_zone should decide if we should
 		 * continue or not.
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
