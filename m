Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5FFE6B1864
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 22:48:54 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id k125so19652840pga.5
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 19:48:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t186sor22208179pgd.63.2018.11.18.19.48.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 18 Nov 2018 19:48:53 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC PATCH] mm, meminit: remove init_reserved_page()
Date: Mon, 19 Nov 2018 11:48:45 +0800
Message-Id: <20181119034845.20469-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de, pavel.tatashin@microsoft.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Function init_reserved_page() is introduced in commit 7e18adb4f80b ("mm:
meminit: initialize remaining struct pages in parallel with kswapd").
While I am confused why it uses for_each_mem_pfn_range() in
deferred_init_memmap() to initialize deferred pages structure.

After commit 2f47a91f4dab ("mm: deferred_init_memmap improvements"),
deferred_init_memmap() uses for_each_free_mem_range() to initialize
page structure. This means the reserved memory is not touched.

The original context before commit 7e18adb4f80b ("mm: meminit: initialize
remaining struct pages in parallel with kswapd"), reserved memory's page
structure is just SetPageReserved, which means they are not necessary to be
initialized.

This patch removes init_reserved_page() to restore the original context.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---

I did bootup and kernel build test with the patched kernel, it looks good.

One of my confusion is the commit 7e18adb4f80b ("mm: meminit: initialize
remaining struct pages in parallel with kswapd") works fine. Does it eat some
reserved pages? Either I don't see the reason in commit 2f47a91f4dab ("mm:
deferred_init_memmap improvements") of changing pfn iteration from
for_each_mem_pfn_range() to for_each_free_mem_range().

Another question is in function reserve_bootmem_region(), we add a
INIT_LIST_HEAD() in commit 1d798ca3f164 ("mm: make compound_head() robust").
While the reserved page is never visible in page allocator. Do we still need
to do this step?

---
 mm/page_alloc.c | 28 ----------------------------
 1 file changed, 28 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2d3c54201255..48cf24766343 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1192,32 +1192,6 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 #endif
 }
 
-#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-static void __meminit init_reserved_page(unsigned long pfn)
-{
-	pg_data_t *pgdat;
-	int nid, zid;
-
-	if (!early_page_uninitialised(pfn))
-		return;
-
-	nid = early_pfn_to_nid(pfn);
-	pgdat = NODE_DATA(nid);
-
-	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-		struct zone *zone = &pgdat->node_zones[zid];
-
-		if (pfn >= zone->zone_start_pfn && pfn < zone_end_pfn(zone))
-			break;
-	}
-	__init_single_page(pfn_to_page(pfn), pfn, zid, nid);
-}
-#else
-static inline void init_reserved_page(unsigned long pfn)
-{
-}
-#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
-
 /*
  * Initialised pages do not have PageReserved set. This function is
  * called for each range allocated by the bootmem allocator and
@@ -1233,8 +1207,6 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
 		if (pfn_valid(start_pfn)) {
 			struct page *page = pfn_to_page(start_pfn);
 
-			init_reserved_page(start_pfn);
-
 			/* Avoid false-positive PageTail() */
 			INIT_LIST_HEAD(&page->lru);
 
-- 
2.15.1
