Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 184A56B005A
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 04:56:12 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so7381217wes.15
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 01:56:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id by4si19389652wib.73.2014.08.04.01.56.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 01:56:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 06/13] mm, compaction: reduce zone checking frequency in the migration scanner
Date: Mon,  4 Aug 2014 10:55:17 +0200
Message-Id: <1407142524-2025-7-git-send-email-vbabka@suse.cz>
In-Reply-To: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

The unification of the migrate and free scanner families of function has
highlighted a difference in how the scanners ensure they only isolate pages
of the intended zone. This is important for taking zone lock or lru lock of
the correct zone. Due to nodes overlapping, it is however possible to
encounter a different zone within the range of the zone being compacted.

The free scanner, since its inception by commit 748446bb6b5a ("mm: compaction:
memory compaction core"), has been checking the zone of the first valid page
in a pageblock, and skipping the whole pageblock if the zone does not match.

This checking was completely missing from the migration scanner at first, and
later added by commit dc9086004b3d ("mm: compaction: check for overlapping
nodes during isolation for migration") in a reaction to a bug report.
But the zone comparison in migration scanner is done once per a single scanned
page, which is more defensive and thus more costly than a check per pageblock.

This patch unifies the checking done in both scanners to once per pageblock,
through a new pageblock_pfn_to_page() function, which also includes pfn_valid()
checks. It is more defensive than the current free scanner checks, as it checks
both the first and last page of the pageblock, but less defensive by the
migration scanner per-page checks. It assumes that node overlapping may result
(on some architecture) in a boundary between two nodes falling into the middle
of a pageblock, but that there cannot be a node0 node1 node0 interleaving
within a single pageblock.

The result is more code being shared and a bit less per-page CPU cost in the
migration scanner.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 91 ++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 57 insertions(+), 34 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0168786..606c119 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -67,6 +67,49 @@ static inline bool migrate_async_suitable(int migratetype)
 	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
 }
 
+/*
+ * Check that the whole (or subset of) a pageblock given by the interval of
+ * [start_pfn, end_pfn) is valid and within the same zone, before scanning it
+ * with the migration of free compaction scanner. The scanners then need to
+ * use only pfn_valid_within() check for arches that allow holes within
+ * pageblocks.
+ *
+ * Return struct page pointer of start_pfn, or NULL if checks were not passed.
+ *
+ * It's possible on some configurations to have a setup like node0 node1 node0
+ * i.e. it's possible that all pages within a zones range of pages do not
+ * belong to a single zone. We assume that a border between node0 and node1
+ * can occur within a single pageblock, but not a node0 node1 node0
+ * interleaving within a single pageblock. It is therefore sufficient to check
+ * the first and last page of a pageblock and avoid checking each individual
+ * page in a pageblock.
+ */
+static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
+				unsigned long end_pfn, struct zone *zone)
+{
+	struct page *start_page;
+	struct page *end_page;
+
+	/* end_pfn is one past the range we are checking */
+	end_pfn--;
+
+	if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
+		return NULL;
+
+	start_page = pfn_to_page(start_pfn);
+
+	if (page_zone(start_page) != zone)
+		return NULL;
+
+	end_page = pfn_to_page(end_pfn);
+
+	/* This gives a shorter code than deriving page_zone(end_page) */
+	if (page_zone_id(start_page) != page_zone_id(end_page))
+		return NULL;
+
+	return start_page;
+}
+
 #ifdef CONFIG_COMPACTION
 /* Returns true if the pageblock should be scanned for pages to isolate. */
 static inline bool isolation_suitable(struct compact_control *cc,
@@ -368,17 +411,17 @@ isolate_freepages_range(struct compact_control *cc,
 	unsigned long isolated, pfn, block_end_pfn;
 	LIST_HEAD(freelist);
 
-	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
-		if (!pfn_valid(pfn) || cc->zone != page_zone(pfn_to_page(pfn)))
-			break;
+	pfn = start_pfn;
+	block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+
+	for (; pfn < end_pfn; pfn += isolated,
+				block_end_pfn += pageblock_nr_pages) {
 
-		/*
-		 * On subsequent iterations ALIGN() is actually not needed,
-		 * but we keep it that we not to complicate the code.
-		 */
-		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
+		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
+			break;
+
 		isolated = isolate_freepages_block(cc, pfn, block_end_pfn,
 						   &freelist, true);
 
@@ -507,15 +550,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			continue;
 		nr_scanned++;
 
-		/*
-		 * Get the page and ensure the page is within the same zone.
-		 * See the comment in isolate_freepages about overlapping
-		 * nodes. It is deliberate that the new zone lock is not taken
-		 * as memory compaction should not move pages between nodes.
-		 */
 		page = pfn_to_page(low_pfn);
-		if (page_zone(page) != zone)
-			continue;
 
 		if (!valid_page)
 			valid_page = page;
@@ -655,8 +690,7 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		/* Skip whole pageblock in case of a memory hole */
-		if (!pfn_valid(pfn))
+		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
 			continue;
 
 		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
@@ -728,18 +762,9 @@ static void isolate_freepages(struct compact_control *cc)
 						&& compact_should_abort(cc))
 			break;
 
-		if (!pfn_valid(block_start_pfn))
-			continue;
-
-		/*
-		 * Check for overlapping nodes/zones. It's possible on some
-		 * configurations to have a setup like
-		 * node0 node1 node0
-		 * i.e. it's possible that all pages within a zones range of
-		 * pages do not belong to a single zone.
-		 */
-		page = pfn_to_page(block_start_pfn);
-		if (page_zone(page) != zone)
+		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
+									zone);
+		if (!page)
 			continue;
 
 		/* Check the block is suitable for migration */
@@ -874,12 +899,10 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 						&& compact_should_abort(cc))
 			break;
 
-		/* Skip whole pageblock in case of a memory hole */
-		if (!pfn_valid(low_pfn))
+		page = pageblock_pfn_to_page(low_pfn, end_pfn, zone);
+		if (!page)
 			continue;
 
-		page = pfn_to_page(low_pfn);
-
 		/* If isolation recently failed, do not retry */
 		if (!isolation_suitable(cc, page))
 			continue;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
