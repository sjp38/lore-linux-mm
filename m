Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id C06706B0071
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:20 -0400 (EDT)
Received: by widjs5 with SMTP id js5so60824073wid.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id op3si13232124wic.73.2015.04.13.03.17.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:14 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/14] mm: page_alloc: Pass PFN to __free_pages_bootmem
Date: Mon, 13 Apr 2015 11:16:56 +0100
Message-Id: <1428920226-18147-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

__free_pages_bootmem prepares a page for release to the buddy allocator and
assumes that the struct page is already properly initialised. Parallel
initialisation of pages will mean that __free_pages_bootmem will be
called for pages with uninitalised structs. This patch passes PFN to
__free_pages_bootmem because until the struct page is initialised we cannot
use page_to_pfn() on all memory models. Functionally this patch does nothing
useful.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/bootmem.c    | 6 +++---
 mm/internal.h   | 3 ++-
 mm/memblock.c   | 2 +-
 mm/nobootmem.c  | 4 ++--
 mm/page_alloc.c | 3 ++-
 5 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 477be696511d..1d017ab3b0c8 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -210,7 +210,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 		if (IS_ALIGNED(start, BITS_PER_LONG) && vec == ~0UL) {
 			int order = ilog2(BITS_PER_LONG);
 
-			__free_pages_bootmem(pfn_to_page(start), order);
+			__free_pages_bootmem(pfn_to_page(start), cursor, order);
 			count += BITS_PER_LONG;
 			start += BITS_PER_LONG;
 		} else {
@@ -220,7 +220,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 			while (vec && cur != start) {
 				if (vec & 1) {
 					page = pfn_to_page(cur);
-					__free_pages_bootmem(page, 0);
+					__free_pages_bootmem(page, cur, 0);
 					count++;
 				}
 				vec >>= 1;
@@ -234,7 +234,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 	pages = bootmem_bootmap_pages(pages);
 	count += pages;
 	while (pages--)
-		__free_pages_bootmem(page++, 0);
+		__free_pages_bootmem(page++, cur++, 0);
 
 	bdebug("nid=%td released=%lx\n", bdata - bootmem_node_data, count);
 
diff --git a/mm/internal.h b/mm/internal.h
index a96da5b0029d..76b605139c7a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -155,7 +155,8 @@ __find_buddy_index(unsigned long page_idx, unsigned int order)
 }
 
 extern int __isolate_free_page(struct page *page, unsigned int order);
-extern void __free_pages_bootmem(struct page *page, unsigned int order);
+extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
+					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
diff --git a/mm/memblock.c b/mm/memblock.c
index e0cc2d174f74..f3e97d8eeb5c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1334,7 +1334,7 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 	end = PFN_DOWN(base + size);
 
 	for (; cursor < end; cursor++) {
-		__free_pages_bootmem(pfn_to_page(cursor), 0);
+		__free_pages_bootmem(pfn_to_page(cursor), cursor, 0);
 		totalram_pages++;
 	}
 }
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 396f9e450dc1..bae652713ee5 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -77,7 +77,7 @@ void __init free_bootmem_late(unsigned long addr, unsigned long size)
 	end = PFN_DOWN(addr + size);
 
 	for (; cursor < end; cursor++) {
-		__free_pages_bootmem(pfn_to_page(cursor), 0);
+		__free_pages_bootmem(pfn_to_page(cursor), cursor, 0);
 		totalram_pages++;
 	}
 }
@@ -92,7 +92,7 @@ static void __init __free_pages_memory(unsigned long start, unsigned long end)
 		while (start + (1UL << order) > end)
 			order--;
 
-		__free_pages_bootmem(pfn_to_page(start), order);
+		__free_pages_bootmem(pfn_to_page(start), start, order);
 
 		start += (1UL << order);
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2abb3b861e70..0a0e0f280d87 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -886,7 +886,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
-void __init __free_pages_bootmem(struct page *page, unsigned int order)
+void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
+							unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
 	struct page *p = page;
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
