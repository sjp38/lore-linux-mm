Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDC56B0282
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 15:15:32 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so2789517pbc.7
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 12:15:32 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id j4si4294784pad.63.2014.03.21.12.15.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Mar 2014 12:15:30 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id rd3so2807434pab.11
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 12:15:26 -0700 (PDT)
From: Chirantan Ekbote <chirantan@chromium.org>
Subject: [PATCH] ARM: mm: Speed up page list initialization during boot
Date: Fri, 21 Mar 2014 12:15:17 -0700
Message-Id: <1395429317-10084-1-git-send-email-chirantan@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, sonnyrao@chromium.org, dianders@chromium.org, Chirantan Ekbote <chirantan@chromium.org>

During boot, we populate the page lists by using the page freeing
mechanism on every individual page.  Unfortunately, this is very
inefficient because the memory manager spends a lot of time coalescing
pairs of adjacent free pages into bigger blocks.

Rather than adding a single order 0 page at a time, we can take
advantage of the fact that we know that all the pages are available and
free up big blocks of pages at a time instead.

Signed-off-by: Chirantan Ekbote <chirantan@chromium.org>
---
 arch/arm/mm/init.c  | 19 +++++++++++++++++--
 include/linux/gfp.h |  1 +
 mm/internal.h       |  1 -
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 97c293e..c7fc2d8 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -22,6 +22,7 @@
 #include <linux/memblock.h>
 #include <linux/dma-contiguous.h>
 #include <linux/sizes.h>
+#include <linux/bitops.h>
 
 #include <asm/mach-types.h>
 #include <asm/memblock.h>
@@ -469,8 +470,22 @@ static void __init free_unused_memmap(struct meminfo *mi)
 #ifdef CONFIG_HIGHMEM
 static inline void free_area_high(unsigned long pfn, unsigned long end)
 {
-	for (; pfn < end; pfn++)
-		free_highmem_page(pfn_to_page(pfn));
+	while (pfn < end) {
+		struct page *page = pfn_to_page(pfn);
+		unsigned long order = min(__ffs(pfn), MAX_ORDER - 1);
+		unsigned long nr_pages = 1 << order;
+		unsigned long rem = end - pfn;
+
+		if (nr_pages > rem) {
+			order = __fls(rem);
+			nr_pages = 1 << order;
+		}
+
+		__free_pages_bootmem(page, order);
+		totalram_pages += nr_pages;
+		totalhigh_pages += nr_pages;
+		pfn += nr_pages;
+	}
 }
 #endif
 
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 39b81dc..a63d666 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -367,6 +367,7 @@ void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 #define __get_dma_pages(gfp_mask, order) \
 		__get_free_pages((gfp_mask) | GFP_DMA, (order))
 
+extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_cold_page(struct page *page, int cold);
diff --git a/mm/internal.h b/mm/internal.h
index 29e1e76..d2b8738 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -93,7 +93,6 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
 /*
  * in mm/page_alloc.c
  */
-extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
-- 
1.9.1.423.g4596e3a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
