Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id AEAB66B0266
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:14:17 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id f198so134579095wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:14:17 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id j9si17058536wma.95.2016.04.11.01.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:14:16 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 60CC41C18A6
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:14:16 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 07/22] mm, page_alloc: Avoid unnecessary zone lookups during pageblock operations
Date: Mon, 11 Apr 2016 09:13:30 +0100
Message-Id: <1460362424-26369-8-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Pageblocks have an associated bitmap to store migrate types and whether
the pageblock should be skipped during compaction. The bitmap may be
associated with a memory section or a zone but the zone is looked up
unconditionally. The compiler should optimise this away automatically so
this is a cosmetic patch only in many cases.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ab16560b76e6..d00847bb1612 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6759,23 +6759,23 @@ void *__init alloc_large_system_hash(const char *tablename,
 }
 
 /* Return a pointer to the bitmap storing bits affecting a block of pages */
-static inline unsigned long *get_pageblock_bitmap(struct zone *zone,
+static inline unsigned long *get_pageblock_bitmap(struct page *page,
 							unsigned long pfn)
 {
 #ifdef CONFIG_SPARSEMEM
 	return __pfn_to_section(pfn)->pageblock_flags;
 #else
-	return zone->pageblock_flags;
+	return page_zone(page)->pageblock_flags;
 #endif /* CONFIG_SPARSEMEM */
 }
 
-static inline int pfn_to_bitidx(struct zone *zone, unsigned long pfn)
+static inline int pfn_to_bitidx(struct page *page, unsigned long pfn)
 {
 #ifdef CONFIG_SPARSEMEM
 	pfn &= (PAGES_PER_SECTION-1);
 	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
 #else
-	pfn = pfn - round_down(zone->zone_start_pfn, pageblock_nr_pages);
+	pfn = pfn - round_down(page_zone(page)->zone_start_pfn, pageblock_nr_pages);
 	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
 #endif /* CONFIG_SPARSEMEM */
 }
@@ -6793,14 +6793,12 @@ unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
 					unsigned long end_bitidx,
 					unsigned long mask)
 {
-	struct zone *zone;
 	unsigned long *bitmap;
 	unsigned long bitidx, word_bitidx;
 	unsigned long word;
 
-	zone = page_zone(page);
-	bitmap = get_pageblock_bitmap(zone, pfn);
-	bitidx = pfn_to_bitidx(zone, pfn);
+	bitmap = get_pageblock_bitmap(page, pfn);
+	bitidx = pfn_to_bitidx(page, pfn);
 	word_bitidx = bitidx / BITS_PER_LONG;
 	bitidx &= (BITS_PER_LONG-1);
 
@@ -6822,20 +6820,18 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 					unsigned long end_bitidx,
 					unsigned long mask)
 {
-	struct zone *zone;
 	unsigned long *bitmap;
 	unsigned long bitidx, word_bitidx;
 	unsigned long old_word, word;
 
 	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
 
-	zone = page_zone(page);
-	bitmap = get_pageblock_bitmap(zone, pfn);
-	bitidx = pfn_to_bitidx(zone, pfn);
+	bitmap = get_pageblock_bitmap(page, pfn);
+	bitidx = pfn_to_bitidx(page, pfn);
 	word_bitidx = bitidx / BITS_PER_LONG;
 	bitidx &= (BITS_PER_LONG-1);
 
-	VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pfn), page);
+	VM_BUG_ON_PAGE(!zone_spans_pfn(page_zone(page), pfn), page);
 
 	bitidx += end_bitidx;
 	mask <<= (BITS_PER_LONG - bitidx - 1);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
