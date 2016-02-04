Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 21B284403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 01:19:44 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id w123so33904205pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:19:44 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id p83si14484164pfj.121.2016.02.03.22.19.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 22:19:43 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id 65so33781567pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:19:43 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 2/3] mm/compaction: pass only pageblock aligned range to pageblock_pfn_to_page
Date: Thu,  4 Feb 2016 15:19:34 +0900
Message-Id: <1454566775-30973-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

pageblock_pfn_to_page() is used to check there is valid pfn and all pages
in the pageblock is in a single zone. If there is a hole in the pageblock,
passing arbitrary position to pageblock_pfn_to_page() could cause to skip
whole pageblock scanning, instead of just skipping the hole page. For
deterministic behaviour, it's better to always pass pageblock aligned
range to pageblock_pfn_to_page(). It will also help further optimization
on pageblock_pfn_to_page() in the following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 56fa321..8ce36eb 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -555,13 +555,17 @@ unsigned long
 isolate_freepages_range(struct compact_control *cc,
 			unsigned long start_pfn, unsigned long end_pfn)
 {
-	unsigned long isolated, pfn, block_end_pfn;
+	unsigned long isolated, pfn, block_start_pfn, block_end_pfn;
 	LIST_HEAD(freelist);
 
 	pfn = start_pfn;
+	block_start_pfn = pfn & ~(pageblock_nr_pages - 1);
+	if (block_start_pfn < cc->zone->zone_start_pfn)
+		block_start_pfn = cc->zone->zone_start_pfn;
 	block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 
 	for (; pfn < end_pfn; pfn += isolated,
+				block_start_pfn = block_end_pfn,
 				block_end_pfn += pageblock_nr_pages) {
 		/* Protect pfn from changing by isolate_freepages_block */
 		unsigned long isolate_start_pfn = pfn;
@@ -574,11 +578,13 @@ isolate_freepages_range(struct compact_control *cc,
 		 * scanning range to right one.
 		 */
 		if (pfn >= block_end_pfn) {
+			block_start_pfn = pfn & ~(pageblock_nr_pages - 1);
 			block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 			block_end_pfn = min(block_end_pfn, end_pfn);
 		}
 
-		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
+		if (!pageblock_pfn_to_page(block_start_pfn,
+					block_end_pfn, cc->zone))
 			break;
 
 		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
@@ -864,18 +870,23 @@ unsigned long
 isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 							unsigned long end_pfn)
 {
-	unsigned long pfn, block_end_pfn;
+	unsigned long pfn, block_start_pfn, block_end_pfn;
 
 	/* Scan block by block. First and last block may be incomplete */
 	pfn = start_pfn;
+	block_start_pfn = pfn & ~(pageblock_nr_pages - 1);
+	if (block_start_pfn < cc->zone->zone_start_pfn)
+		block_start_pfn = cc->zone->zone_start_pfn;
 	block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 
 	for (; pfn < end_pfn; pfn = block_end_pfn,
+				block_start_pfn = block_end_pfn,
 				block_end_pfn += pageblock_nr_pages) {
 
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
+		if (!pageblock_pfn_to_page(block_start_pfn,
+					block_end_pfn, cc->zone))
 			continue;
 
 		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
@@ -1104,7 +1115,9 @@ int sysctl_compact_unevictable_allowed __read_mostly = 1;
 static isolate_migrate_t isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
-	unsigned long low_pfn, end_pfn;
+	unsigned long block_start_pfn;
+	unsigned long block_end_pfn;
+	unsigned long low_pfn;
 	unsigned long isolate_start_pfn;
 	struct page *page;
 	const isolate_mode_t isolate_mode =
@@ -1116,16 +1129,21 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	 * initialized by compact_zone()
 	 */
 	low_pfn = cc->migrate_pfn;
+	block_start_pfn = cc->migrate_pfn & ~(pageblock_nr_pages - 1);
+	if (block_start_pfn < zone->zone_start_pfn)
+		block_start_pfn = zone->zone_start_pfn;
 
 	/* Only scan within a pageblock boundary */
-	end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
+	block_end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
 
 	/*
 	 * Iterate over whole pageblocks until we find the first suitable.
 	 * Do not cross the free scanner.
 	 */
-	for (; end_pfn <= cc->free_pfn;
-			low_pfn = end_pfn, end_pfn += pageblock_nr_pages) {
+	for (; block_end_pfn <= cc->free_pfn;
+			low_pfn = block_end_pfn,
+			block_start_pfn = block_end_pfn,
+			block_end_pfn += pageblock_nr_pages) {
 
 		/*
 		 * This can potentially iterate a massively long zone with
@@ -1136,7 +1154,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 						&& compact_should_abort(cc))
 			break;
 
-		page = pageblock_pfn_to_page(low_pfn, end_pfn, zone);
+		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
+									zone);
 		if (!page)
 			continue;
 
@@ -1155,8 +1174,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
 		/* Perform the isolation */
 		isolate_start_pfn = low_pfn;
-		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
-								isolate_mode);
+		low_pfn = isolate_migratepages_block(cc, low_pfn,
+						block_end_pfn, isolate_mode);
 
 		if (!low_pfn || cc->contended) {
 			acct_isolated(zone, cc);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
