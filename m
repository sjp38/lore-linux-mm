Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6F87D6B002B
	for <linux-mm@kvack.org>; Thu, 31 Dec 2015 08:05:55 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id 6so122923596qgy.1
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 05:05:55 -0800 (PST)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id o97si9290749qgd.69.2015.12.31.05.05.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Dec 2015 05:05:54 -0800 (PST)
Received: by mail-qg0-x236.google.com with SMTP id b35so71189237qge.0
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 05:05:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <005101d14158$b50842c0$1f18c840$@samsung.com>
References: <004001d14158$114be8d0$33e3ba70$@samsung.com>
	<005101d14158$b50842c0$1f18c840$@samsung.com>
Date: Thu, 31 Dec 2015 05:05:54 -0800
Message-ID: <CAJFHJrpgHmcXBwuV5i4nH4SOL-OwrY2-+Fe7x9W2c6GWW=F7bg@mail.gmail.com>
Subject: Re: [PATCH] ARM: mm: Speed up page list initialization during boot
From: Chirantan Ekbote <chirantan@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseung Lee <js07.lee@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org

On Mon, Dec 28, 2015 at 2:15 AM, Jungseung Lee <js07.lee@samsung.com> wrote:
> Hi,
>
>>During boot, we populate the page lists by using the page freeing
>>mechanism on every individual page.  Unfortunately, this is very
>>inefficient because the memory manager spends a lot of time coalescing
>>pairs of adjacent free pages into bigger blocks.
>>
>>Rather than adding a single order 0 page at a time, we can take
>>advantage of the fact that we know that all the pages are available and
>>free up big blocks of pages at a time instead.
>>
>>Signed-off-by: Chirantan Ekbote <chirantan at chromium.org>
>>---
>> arch/arm/mm/init.c  | 19 +++++++++++++++++--  include/linux/gfp.h |  1
>>+
>> mm/internal.h       |  1 -
>> 3 files changed, 18 insertions(+), 3 deletions(-)
>>
>>diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c index
>>97c293e..c7fc2d8 100644
>>--- a/arch/arm/mm/init.c
>>+++ b/arch/arm/mm/init.c
>>@@ -22,6 +22,7 @@
>> #include <linux/memblock.h>
>> #include <linux/dma-contiguous.h>
>> #include <linux/sizes.h>
>>+#include <linux/bitops.h>
>>
>> #include <asm/mach-types.h>
>> #include <asm/memblock.h>
>>@@ -469,8 +470,22 @@ static void __init free_unused_memmap(struct
>>meminfo
> *mi)
>> #ifdef CONFIG_HIGHMEM
>> static inline void free_area_high(unsigned long pfn, unsigned long
>>end)  {
>>-      for (; pfn < end; pfn++)
>>-              free_highmem_page(pfn_to_page(pfn));
>>+      while (pfn < end) {
>>+              struct page *page = pfn_to_page(pfn);
>>+              unsigned long order = min(__ffs(pfn), MAX_ORDER - 1);
>>+              unsigned long nr_pages = 1 << order;
>>+              unsigned long rem = end - pfn;
>>+
>>+              if (nr_pages > rem) {
>>+                      order = __fls(rem);
>>+                      nr_pages = 1 << order;
>>+              }
>>+
>>+              __free_pages_bootmem(page, order);
>>+              totalram_pages += nr_pages;
>>+              totalhigh_pages += nr_pages;
>>+              pfn += nr_pages;
>>+      }
>> }
>> #endif
>>
>>diff --git a/include/linux/gfp.h b/include/linux/gfp.h index
>>39b81dc..a63d666 100644
>>--- a/include/linux/gfp.h
>>+++ b/include/linux/gfp.h
>>@@ -367,6 +367,7 @@ void *alloc_pages_exact_nid(int nid, size_t size,
>>gfp_t
> gfp_mask);
>> #define __get_dma_pages(gfp_mask, order) \
>>               __get_free_pages((gfp_mask) | GFP_DMA, (order))
>>
>>+extern void __free_pages_bootmem(struct page *page, unsigned int
>>+order);
>> extern void __free_pages(struct page *page, unsigned int order);
>>extern void free_pages(unsigned long addr, unsigned int order);  extern
>>void free_hot_cold_page(struct page *page, int cold); diff --git
>>a/mm/internal.h b/mm/internal.h index 29e1e76..d2b8738 100644
>>--- a/mm/internal.h
>>+++ b/mm/internal.h
>>@@ -93,7 +93,6 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm,
>>unsigned
> long address);
>> /*
>>  * in mm/page_alloc.c
>>  */
>>-extern void __free_pages_bootmem(struct page *page, unsigned int
>>order);  extern void prep_compound_page(struct page *page, unsigned
>>long order);  #ifdef CONFIG_MEMORY_FAILURE  extern bool
>>is_free_buddy_page(struct page *page);
>>--
>>1.9.1.423.g4596e3a
>
> This patch really could save boot time.
> Is there any reason this patch is not merged to mainline kernel?
>

Well it was ignored when I originally posted it so I assumed mainline
developers weren't really interested.  I can re-spin and send a new
version if there's interest in getting it merged now.

> Best Regards,
> Jungseung Lee
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
