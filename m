Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 355B66B0031
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 19:41:35 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so5742796pad.9
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 16:41:34 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 6 Oct 2013 05:11:23 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 847F3394004E
	for <linux-mm@kvack.org>; Sun,  6 Oct 2013 05:11:01 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r95NfFfX41681046
	for <linux-mm@kvack.org>; Sun, 6 Oct 2013 05:11:16 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r95NfHV0020088
	for <linux-mm@kvack.org>; Sun, 6 Oct 2013 05:11:17 +0530
Date: Sun, 6 Oct 2013 07:41:15 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm/sparsemem: Fix a bug in free_map_bootmem when
 CONFIG_SPARSEMEM_VMEMMAP
Message-ID: <5250a3a9.e2bd440a.2508.ffffbc0cSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52504476.6060607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52504476.6060607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, isimatu.yasuaki@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Sun, Oct 06, 2013 at 12:55:18AM +0800, Zhang Yanfei wrote:
>From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>
>We pass the number of pages which hold page structs of a memory
>section to function free_map_bootmem. This is right when
>!CONFIG_SPARSEMEM_VMEMMAP but wrong when CONFIG_SPARSEMEM_VMEMMAP.
>When CONFIG_SPARSEMEM_VMEMMAP, we should pass the number of pages
>of a memory section to free_map_bootmem.
>
>So the fix is removing the nr_pages parameter. When
>CONFIG_SPARSEMEM_VMEMMAP, we directly use the prefined marco
>PAGES_PER_SECTION in free_map_bootmem. When !CONFIG_SPARSEMEM_VMEMMAP,
>we calculate page numbers needed to hold the page structs for a
>memory section and use the value in free_map_bootmem.
>
>Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
>v2: Fix a bug introduced in v1 patch. Thanks wanpeng!
>---
> mm/sparse.c |   20 +++++++++-----------
> 1 files changed, 9 insertions(+), 11 deletions(-)
>
>diff --git a/mm/sparse.c b/mm/sparse.c
>index 4ac1d7e..fe32b48 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -604,10 +604,10 @@ static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
> 	vmemmap_free(start, end);
> }
> #ifdef CONFIG_MEMORY_HOTREMOVE
>-static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
>+static void free_map_bootmem(struct page *memmap)
> {
> 	unsigned long start = (unsigned long)memmap;
>-	unsigned long end = (unsigned long)(memmap + nr_pages);
>+	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
>
> 	vmemmap_free(start, end);
> }
>@@ -650,12 +650,15 @@ static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
> }
>
> #ifdef CONFIG_MEMORY_HOTREMOVE
>-static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
>+static void free_map_bootmem(struct page *memmap)
> {
> 	unsigned long maps_section_nr, removing_section_nr, i;
>-	unsigned long magic;
>+	unsigned long magic, nr_pages;
> 	struct page *page = virt_to_page(memmap);
>
>+	nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
>+		>> PAGE_SHIFT;
>+
> 	for (i = 0; i < nr_pages; i++, page++) {
> 		magic = (unsigned long) page->lru.next;
>
>@@ -759,7 +762,6 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> static void free_section_usemap(struct page *memmap, unsigned long *usemap)
> {
> 	struct page *usemap_page;
>-	unsigned long nr_pages;
>
> 	if (!usemap)
> 		return;
>@@ -780,12 +782,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
> 	 * on the section which has pgdat at boot time. Just keep it as is now.
> 	 */
>
>-	if (memmap) {
>-		nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
>-			>> PAGE_SHIFT;
>-
>-		free_map_bootmem(memmap, nr_pages);
>-	}
>+	if (memmap)
>+		free_map_bootmem(memmap);
> }
>
> void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
>-- 
>1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
