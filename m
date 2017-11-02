Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE5AE6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 08:17:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r79so2882762wrb.7
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 05:17:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l33si2051894edl.265.2017.11.02.05.17.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 05:17:26 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/3] mm, compaction: extend pageblock_skip_persistent() to all compound pages
Date: Thu,  2 Nov 2017 13:17:04 +0100
Message-Id: <20171102121706.21504-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

The pageblock_skip_persistent() function checks for HugeTLB pages of pageblock
order. When clearing pageblock skip bits for compaction, the bits are not
cleared for such pageblocks, because they cannot contain base pages suitable
for migration, nor free pages to use as migration targets.

This optimization can be simply extended to all compound pages of order equal
or larger than pageblock order, because migrating such pages (if they support
it) cannot help sub-pageblock fragmentation. This includes THP's and also
gigantic HugeTLB pages, which the current implementation doesn't persistently
skip due to a strict pageblock_order equality check and not recognizing tail
pages.

While THP pages are generally less "persistent" than HugeTLB, we can still
expect that if a THP exists at the point of __reset_isolation_suitable(), it
will exist also during the subsequent compaction run. The time difference here
could be actually smaller than between a compaction run that sets a
(non-persistent) skip bit on a THP, and the next compaction run that observes
it.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 445490ab2603..be7ab160f251 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -218,17 +218,21 @@ static void reset_cached_positions(struct zone *zone)
 }
 
 /*
- * Hugetlbfs pages should consistenly be skipped until updated by the hugetlb
- * subsystem.  It is always pointless to compact pages of pageblock_order and
- * the free scanner can reconsider when no longer huge.
+ * Compound pages of >= pageblock_order should consistenly be skipped until
+ * released. It is always pointless to compact pages of such order (if they are
+ * migratable), and the pageblocks they occupy cannot contain any free pages.
  */
-static bool pageblock_skip_persistent(struct page *page, unsigned int order)
+static bool pageblock_skip_persistent(struct page *page)
 {
-	if (!PageHuge(page))
+	if (!PageCompound(page))
 		return false;
-	if (order != pageblock_order)
-		return false;
-	return true;
+
+	page = compound_head(page);
+
+	if (compound_order(page) >= pageblock_order)
+		return true;
+
+	return false;
 }
 
 /*
@@ -255,7 +259,7 @@ static void __reset_isolation_suitable(struct zone *zone)
 			continue;
 		if (zone != page_zone(page))
 			continue;
-		if (pageblock_skip_persistent(page, compound_order(page)))
+		if (pageblock_skip_persistent(page))
 			continue;
 
 		clear_pageblock_skip(page);
@@ -322,8 +326,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
 	return true;
 }
 
-static inline bool pageblock_skip_persistent(struct page *page,
-					     unsigned int order)
+static inline bool pageblock_skip_persistent(struct page *page)
 {
 	return false;
 }
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
