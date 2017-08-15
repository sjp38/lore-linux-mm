Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C00B36B0292
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 19:39:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x189so42930696pgb.11
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 16:39:34 -0700 (PDT)
Received: from mail-pg0-x22a.google.com (mail-pg0-x22a.google.com. [2607:f8b0:400e:c05::22a])
        by mx.google.com with ESMTPS id c188si6157151pfb.46.2017.08.15.16.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 16:39:33 -0700 (PDT)
Received: by mail-pg0-x22a.google.com with SMTP id l64so14627668pge.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 16:39:33 -0700 (PDT)
Date: Tue, 15 Aug 2017 16:39:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, compaction: persistently skip hugetlbfs pageblocks
In-Reply-To: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It is pointless to migrate hugetlb memory as part of memory compaction if
the hugetlb size is equal to the pageblock order.  No defragmentation is
occurring in this condition.

It is also pointless to for the freeing scanner to scan a pageblock where
a hugetlb page is pinned.  Unconditionally skip these pageblocks, and do
so peristently so that they are not rescanned until it is observed that
these hugepages are no longer pinned.

It would also be possible to do this by involving the hugetlb subsystem
in marking pageblocks to no longer be skipped when they hugetlb pages are
freed.  This is a simple solution that doesn't involve any additional
subsystems in pageblock skip manipulation.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 48 +++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 37 insertions(+), 11 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -217,6 +217,20 @@ static void reset_cached_positions(struct zone *zone)
 				pageblock_start_pfn(zone_end_pfn(zone) - 1);
 }
 
+/*
+ * Hugetlbfs pages should consistenly be skipped until updated by the hugetlb
+ * subsystem.  It is always pointless to compact pages of pageblock_order and
+ * the free scanner can reconsider when no longer huge.
+ */
+static bool pageblock_skip_persistent(struct page *page, unsigned int order)
+{
+	if (!PageHuge(page))
+		return false;
+	if (order != pageblock_order)
+		return false;
+	return true;
+}
+
 /*
  * This function is called to clear all cached information on pageblocks that
  * should be skipped for page isolation when the migrate and free page scanner
@@ -241,6 +255,8 @@ static void __reset_isolation_suitable(struct zone *zone)
 			continue;
 		if (zone != page_zone(page))
 			continue;
+		if (pageblock_skip_persistent(page, compound_order(page)))
+			continue;
 
 		clear_pageblock_skip(page);
 	}
@@ -448,13 +464,15 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		 * and the only danger is skipping too much.
 		 */
 		if (PageCompound(page)) {
-			unsigned int comp_order = compound_order(page);
-
-			if (likely(comp_order < MAX_ORDER)) {
-				blockpfn += (1UL << comp_order) - 1;
-				cursor += (1UL << comp_order) - 1;
+			const unsigned int order = compound_order(page);
+
+			if (pageblock_skip_persistent(page, order)) {
+				set_pageblock_skip(page);
+				blockpfn = end_pfn;
+			} else if (likely(order < MAX_ORDER)) {
+				blockpfn += (1UL << order) - 1;
+				cursor += (1UL << order) - 1;
 			}
-
 			goto isolate_fail;
 		}
 
@@ -771,11 +789,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * danger is skipping too much.
 		 */
 		if (PageCompound(page)) {
-			unsigned int comp_order = compound_order(page);
-
-			if (likely(comp_order < MAX_ORDER))
-				low_pfn += (1UL << comp_order) - 1;
+			const unsigned int order = compound_order(page);
 
+			if (pageblock_skip_persistent(page, order)) {
+				set_pageblock_skip(page);
+				low_pfn = end_pfn;
+			} else if (likely(order < MAX_ORDER))
+				low_pfn += (1UL << order) - 1;
 			goto isolate_fail;
 		}
 
@@ -837,7 +857,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			 * is safe to read and it's 0 for tail pages.
 			 */
 			if (unlikely(PageCompound(page))) {
-				low_pfn += (1UL << compound_order(page)) - 1;
+				const unsigned int order = compound_order(page);
+
+				if (pageblock_skip_persistent(page, order)) {
+					set_pageblock_skip(page);
+					low_pfn = end_pfn;
+				} else
+					low_pfn += (1UL << order) - 1;
 				goto isolate_fail;
 			}
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
