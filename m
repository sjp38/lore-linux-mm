Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 69D336B0071
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:33:29 -0400 (EDT)
Received: by labpy14 with SMTP id py14so28946071lab.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:33:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lg1si16712278wjc.136.2015.06.10.02.33.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 02:33:19 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/6] mm, compaction: always skip compound pages by order in migrate scanner
Date: Wed, 10 Jun 2015 11:32:32 +0200
Message-Id: <1433928754-966-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1433928754-966-1-git-send-email-vbabka@suse.cz>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

The compaction migrate scanner tries to skip compound pages by their order, to
reduce number of iterations for pages it cannot isolate. The check is only done
if PageLRU() is true, which means it applies to THP pages, but not e.g.
hugetlbfs pages or any other non-LRU compound pages, which we have to iterate
by base pages.

This limitation comes from the assumption that it's only safe to read
compound_order() when we have the zone's lru_lock and THP cannot be split under
us. But the only danger (after filtering out order values that are not below
MAX_ORDER, to prevent overflows) is that we skip too much or too little after
reading a bogus compound_order() due to a rare race. This is the same reasoning
as patch 99c0fd5e51c4 ("mm, compaction: skip buddy pages by their order in the
migrate scanner") introduced for unsafely reading PageBuddy() order.

After this patch, all pages are tested for PageCompound() and we skip them by
compound_order().  The test is done after the test for balloon_page_movable()
as we don't want to assume if balloon pages (or other pages with own isolation
and migration implementation if a generic API gets implemented) are compound
or not.

When tested with stress-highalloc from mmtests on 4GB system with 1GB hugetlbfs
pages, the vmstat compact_migrate_scanned count decreased by 15%.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 36 +++++++++++++++++-------------------
 1 file changed, 17 insertions(+), 19 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index d334bb3..e37d361 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -680,6 +680,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
+		bool is_lru;
+
 		/*
 		 * Periodically drop the lock (if held) regardless of its
 		 * contention, to give chance to IRQs. Abort async compaction
@@ -723,39 +725,35 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * It's possible to migrate LRU pages and balloon pages
 		 * Skip any other type of page
 		 */
-		if (!PageLRU(page)) {
+		is_lru = PageLRU(page);
+		if (!is_lru) {
 			if (unlikely(balloon_page_movable(page))) {
 				if (balloon_page_isolate(page)) {
 					/* Successfully isolated */
 					goto isolate_success;
 				}
 			}
-			continue;
 		}
 
 		/*
-		 * PageLRU is set. lru_lock normally excludes isolation
-		 * splitting and collapsing (collapsing has already happened
-		 * if PageLRU is set) but the lock is not necessarily taken
-		 * here and it is wasteful to take it just to check transhuge.
-		 * Check PageCompound without lock and skip the whole pageblock
-		 * if it's a transhuge page, as calling compound_order()
-		 * without preventing THP from splitting the page underneath us
-		 * may return surprising results.
-		 * If we happen to check a THP tail page, compound_order()
-		 * returns 0. It should be rare enough to not bother with
-		 * using compound_head() in that case.
+		 * Regardless of being on LRU, compound pages such as THP and
+		 * hugetlbfs are not to be compacted. We can potentially save
+		 * a lot of iterations if we skip them at once. The check is
+		 * racy, but we can consider only valid values and the only
+		 * danger is skipping too much.
 		 */
 		if (PageCompound(page)) {
-			int nr;
-			if (locked)
-				nr = 1 << compound_order(page);
-			else
-				nr = pageblock_nr_pages;
-			low_pfn += nr - 1;
+			unsigned int comp_order = compound_order(page);
+
+			if (comp_order > 0 && comp_order < MAX_ORDER)
+				low_pfn += (1UL << comp_order) - 1;
+
 			continue;
 		}
 
+		if (!is_lru)
+			continue;
+
 		/*
 		 * Migration will fail if an anonymous page is pinned in memory,
 		 * so avoid taking lru_lock and isolating it unnecessarily in an
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
