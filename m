Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 20AFF6B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 05:18:28 -0400 (EDT)
Received: by wijp15 with SMTP id p15so52708027wij.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 02:18:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gs3si9849890wib.29.2015.08.07.02.18.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Aug 2015 02:18:26 -0700 (PDT)
Subject: Re: [PATCH v2 4/5] mm, compaction: always skip compound pages by
 order in migrate scanner
References: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
 <1438356487-7082-5-git-send-email-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55C477DC.90503@suse.cz>
Date: Fri, 7 Aug 2015 11:18:20 +0200
MIME-Version: 1.0
In-Reply-To: <1438356487-7082-5-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>

As requested, here's a rebased version that doesn't depend on the page-flags
changes from Kirill. This obsoletes the following patches from that series:

page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix.patch
page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix-fix.patch

They were effectively squashed into this patch. Other than that, I've changed
the changelog a bit to reflect that, and added comment to the recheck-after-locking
part along with minor code tweaks there.

------8<------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 7 Aug 2015 11:12:33 +0200
Subject: [PATCH] mm, compaction: always skip all compound pages by order in
 migrate scanner

The compaction migrate scanner tries to skip THP pages by their order, to
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

[Patch from Kirill A. Shutemov <kirill.shutemov@linux.intel.com> that changed
 PageTransHuge checks to PageCompound for different series was squashed here]

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 47 +++++++++++++++++++++++++++--------------------
 1 file changed, 27 insertions(+), 20 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index e51b56a..8f64d35 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -705,6 +705,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
+		bool is_lru;
+
 		/*
 		 * Periodically drop the lock (if held) regardless of its
 		 * contention, to give chance to IRQs. Abort async compaction
@@ -748,36 +750,35 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
-		 * Check TransHuge without lock and skip the whole pageblock if
-		 * it's either a transhuge or hugetlbfs page, as calling
-		 * compound_order() without preventing THP from splitting the
-		 * page underneath us may return surprising results.
+		 * Regardless of being on LRU, compound pages such as THP and
+		 * hugetlbfs are not to be compacted. We can potentially save
+		 * a lot of iterations if we skip them at once. The check is
+		 * racy, but we can consider only valid values and the only
+		 * danger is skipping too much.
 		 */
-		if (PageTransHuge(page)) {
-			if (!locked)
-				low_pfn = ALIGN(low_pfn + 1,
-						pageblock_nr_pages) - 1;
-			else
-				low_pfn += (1 << compound_order(page)) - 1;
+		if (PageCompound(page)) {
+			unsigned int comp_order = compound_order(page);
+
+			if (likely(comp_order < MAX_ORDER))
+				low_pfn += (1UL << comp_order) - 1;
 
 			continue;
 		}
 
+		if (!is_lru)
+			continue;
+
 		/*
 		 * Migration will fail if an anonymous page is pinned in memory,
 		 * so avoid taking lru_lock and isolating it unnecessarily in an
@@ -794,11 +795,17 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			if (!locked)
 				break;
 
-			/* Recheck PageLRU and PageTransHuge under lock */
+			/* Recheck PageLRU and PageCompound under lock */
 			if (!PageLRU(page))
 				continue;
-			if (PageTransHuge(page)) {
-				low_pfn += (1 << compound_order(page)) - 1;
+
+			/*
+			 * Page become compound since the non-locked check,
+			 * and it's on LRU. It can only be a THP so the order
+			 * is safe to read and it's 0 for tail pages.
+			 */
+			if (unlikely(PageCompound(page))) {
+				low_pfn += (1UL << compound_order(page)) - 1;
 				continue;
 			}
 		}
@@ -809,7 +816,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		if (__isolate_lru_page(page, isolate_mode) != 0)
 			continue;
 
-		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+		VM_BUG_ON_PAGE(PageCompound(page), page);
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
