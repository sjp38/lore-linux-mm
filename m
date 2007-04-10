From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070410160404.10742.4024.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070410160244.10742.42187.sendpatchset@skynet.skynet.ie>
References: <20070410160244.10742.42187.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/4] Do not block align PFN when looking up the pageblock PFN
Date: Tue, 10 Apr 2007 17:04:04 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The pageblock flags store bits representing a MAX_ORDER_NR_PAGES block of
pages. When calling get_pageblock_bitmap(), a non-aligned PFN is passed
which is then aligned to the MAX_ORDER_NR_PAGES block. This alignment
is unnecessary.

This patch should be considered a fix to the patch
add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages.patch .

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 page_alloc.c |    4 +---
 1 files changed, 1 insertion(+), 3 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-003_streamline_percpu/mm/page_alloc.c linux-2.6.21-rc6-mm1-004_noblockpfn_sparsemem/mm/page_alloc.c
--- linux-2.6.21-rc6-mm1-003_streamline_percpu/mm/page_alloc.c	2007-04-10 11:35:34.000000000 +0100
+++ linux-2.6.21-rc6-mm1-004_noblockpfn_sparsemem/mm/page_alloc.c	2007-04-10 11:37:28.000000000 +0100
@@ -4169,9 +4169,7 @@ static inline unsigned long *get_pageblo
 							unsigned long pfn)
 {
 #ifdef CONFIG_SPARSEMEM
-	unsigned long blockpfn;
-	blockpfn = pfn & ~(MAX_ORDER_NR_PAGES - 1);
-	return __pfn_to_section(blockpfn)->pageblock_flags;
+	return __pfn_to_section(pfn)->pageblock_flags;
 #else
 	return zone->pageblock_flags;
 #endif /* CONFIG_SPARSEMEM */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
