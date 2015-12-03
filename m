Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF1B6B0256
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 03:11:09 -0500 (EST)
Received: by wmec201 with SMTP id c201so14390488wme.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:11:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x67si10661044wmx.8.2015.12.03.00.11.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 00:11:02 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 1/3] mm, compaction: reduce spurious pcplist drains
Date: Thu,  3 Dec 2015 09:10:45 +0100
Message-Id: <1449130247-8040-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Aaron Lu <aaron.lu@intel.com>
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

Compaction drains the local pcplists each time migration scanner moves away
from a cc->order aligned block where it isolated pages for migration, so that
the pages freed by migrations can merge into highero orders.

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
index de3e1e71cd9f..9c14d10ad3e5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -815,6 +815,15 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
@@ -1104,7 +1113,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
-	unsigned long isolate_start_pfn;
 	struct page *page;
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
@@ -1153,7 +1161,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 
 		/* Perform the isolation */
-		isolate_start_pfn = low_pfn;
 		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
 								isolate_mode);
 
@@ -1163,15 +1170,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
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
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
