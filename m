Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 69E946B02A3
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 05:15:44 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id e126so301455561ioa.1
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 02:15:44 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id 14si46219486ioi.168.2015.12.28.02.15.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Dec 2015 02:15:43 -0800 (PST)
Received: from epcpsbgm2new.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0O0201PQ9CI65N50@mailout2.samsung.com> for linux-mm@kvack.org;
 Mon, 28 Dec 2015 19:15:42 +0900 (KST)
Received: from TNRNDGASPAPP1.tn.corp.samsungelectronics.net ([165.213.149.150])
 by mmp2.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTPA id <0O02003GMCI6SF80@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 28 Dec 2015 19:15:42 +0900 (KST)
From: Jungseung Lee <js07.lee@samsung.com>
References: <004001d14158$114be8d0$33e3ba70$@samsung.com>
In-reply-to: <004001d14158$114be8d0$33e3ba70$@samsung.com>
Subject: RE: [PATCH] ARM: mm: Speed up page list initialization during boot
Date: Mon, 28 Dec 2015 19:15:42 +0900
Message-id: <005101d14158$b50842c0$1f18c840$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chirantan@chromium.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: js07.lee@samsung.com

Hi,

>During boot, we populate the page lists by using the page freeing 
>mechanism on every individual page.  Unfortunately, this is very 
>inefficient because the memory manager spends a lot of time coalescing 
>pairs of adjacent free pages into bigger blocks.
>
>Rather than adding a single order 0 page at a time, we can take 
>advantage of the fact that we know that all the pages are available and 
>free up big blocks of pages at a time instead.
>
>Signed-off-by: Chirantan Ekbote <chirantan at chromium.org>
>---
> arch/arm/mm/init.c  | 19 +++++++++++++++++--  include/linux/gfp.h |  1 
>+
> mm/internal.h       |  1 -
> 3 files changed, 18 insertions(+), 3 deletions(-)
>
>diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c index 
>97c293e..c7fc2d8 100644
>--- a/arch/arm/mm/init.c
>+++ b/arch/arm/mm/init.c
>@@ -22,6 +22,7 @@
> #include <linux/memblock.h>
> #include <linux/dma-contiguous.h>
> #include <linux/sizes.h>
>+#include <linux/bitops.h>
> 
> #include <asm/mach-types.h>
> #include <asm/memblock.h>
>@@ -469,8 +470,22 @@ static void __init free_unused_memmap(struct 
>meminfo
*mi)
> #ifdef CONFIG_HIGHMEM
> static inline void free_area_high(unsigned long pfn, unsigned long 
>end)  {
>-	for (; pfn < end; pfn++)
>-		free_highmem_page(pfn_to_page(pfn));
>+	while (pfn < end) {
>+		struct page *page = pfn_to_page(pfn);
>+		unsigned long order = min(__ffs(pfn), MAX_ORDER - 1);
>+		unsigned long nr_pages = 1 << order;
>+		unsigned long rem = end - pfn;
>+
>+		if (nr_pages > rem) {
>+			order = __fls(rem);
>+			nr_pages = 1 << order;
>+		}
>+
>+		__free_pages_bootmem(page, order);
>+		totalram_pages += nr_pages;
>+		totalhigh_pages += nr_pages;
>+		pfn += nr_pages;
>+	}
> }
> #endif
> 
>diff --git a/include/linux/gfp.h b/include/linux/gfp.h index 
>39b81dc..a63d666 100644
>--- a/include/linux/gfp.h
>+++ b/include/linux/gfp.h
>@@ -367,6 +367,7 @@ void *alloc_pages_exact_nid(int nid, size_t size, 
>gfp_t
gfp_mask);
> #define __get_dma_pages(gfp_mask, order) \
> 		__get_free_pages((gfp_mask) | GFP_DMA, (order))
> 
>+extern void __free_pages_bootmem(struct page *page, unsigned int 
>+order);
> extern void __free_pages(struct page *page, unsigned int order);  
>extern void free_pages(unsigned long addr, unsigned int order);  extern 
>void free_hot_cold_page(struct page *page, int cold); diff --git 
>a/mm/internal.h b/mm/internal.h index 29e1e76..d2b8738 100644
>--- a/mm/internal.h
>+++ b/mm/internal.h
>@@ -93,7 +93,6 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, 
>unsigned
long address);
> /*
>  * in mm/page_alloc.c
>  */
>-extern void __free_pages_bootmem(struct page *page, unsigned int 
>order);  extern void prep_compound_page(struct page *page, unsigned 
>long order);  #ifdef CONFIG_MEMORY_FAILURE  extern bool 
>is_free_buddy_page(struct page *page);
>--
>1.9.1.423.g4596e3a

This patch really could save boot time. 
Is there any reason this patch is not merged to mainline kernel?

Best Regards,
Jungseung Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
