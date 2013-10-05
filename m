Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id D2A416B0031
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 01:54:45 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so4887454pbb.33
        for <linux-mm@kvack.org>; Fri, 04 Oct 2013 22:54:45 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 5 Oct 2013 15:54:40 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id D03162BB0040
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 15:54:37 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r955bT6R65601606
	for <linux-mm@kvack.org>; Sat, 5 Oct 2013 15:37:37 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r955sSJX018258
	for <linux-mm@kvack.org>; Sat, 5 Oct 2013 15:54:29 +1000
Date: Sat, 5 Oct 2013 13:54:26 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm/sparsemem: Fix a bug in free_map_bootmem when
 CONFIG_SPARSEMEM_VMEMMAP
Message-ID: <524fa9a4.e7fd440a.035a.1cf3SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <524CE4C1.8060508@gmail.com>
 <524CE532.1030001@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524CE532.1030001@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, isimatu.yasuaki@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Hi Yanfei,
On Thu, Oct 03, 2013 at 11:32:02AM +0800, Zhang Yanfei wrote:
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
>---
> mm/sparse.c |   17 +++++++----------
> 1 files changed, 7 insertions(+), 10 deletions(-)
>
>diff --git a/mm/sparse.c b/mm/sparse.c
>index fbb9dbc..908c134 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -603,10 +603,10 @@ static void __kfree_section_memmap(struct page *memmap)
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
>@@ -648,11 +648,13 @@ static void __kfree_section_memmap(struct page *memmap)
> }
>
> #ifdef CONFIG_MEMORY_HOTREMOVE
>-static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
>+static void free_map_bootmem(struct page *memmap)
> {
> 	unsigned long maps_section_nr, removing_section_nr, i;
> 	unsigned long magic;
> 	struct page *page = virt_to_page(memmap);
>+	unsigned long nr_pages = get_order(sizeof(struct page) *
>+					   PAGES_PER_SECTION);

Why replace PAGE_ALIGN(XXX) >> PAGE_SHIFT by get_order(XXX)? This will result 
in memory leak.

Regards,
Wanpeng Li 

>
> 	for (i = 0; i < nr_pages; i++, page++) {
> 		magic = (unsigned long) page->lru.next;
>@@ -756,7 +758,6 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> static void free_section_usemap(struct page *memmap, unsigned long *usemap)
> {
> 	struct page *usemap_page;
>-	unsigned long nr_pages;
>
> 	if (!usemap)
> 		return;
>@@ -777,12 +778,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
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
