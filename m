Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 78F666B0036
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 23:32:15 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so1979068pab.1
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 20:32:15 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so1806003pbc.39
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 20:32:12 -0700 (PDT)
Message-ID: <524CE532.1030001@gmail.com>
Date: Thu, 03 Oct 2013 11:32:02 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm/sparsemem: Fix a bug in free_map_bootmem when CONFIG_SPARSEMEM_VMEMMAP
References: <524CE4C1.8060508@gmail.com>
In-Reply-To: <524CE4C1.8060508@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, isimatu.yasuaki@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

We pass the number of pages which hold page structs of a memory
section to function free_map_bootmem. This is right when
!CONFIG_SPARSEMEM_VMEMMAP but wrong when CONFIG_SPARSEMEM_VMEMMAP.
When CONFIG_SPARSEMEM_VMEMMAP, we should pass the number of pages
of a memory section to free_map_bootmem.

So the fix is removing the nr_pages parameter. When
CONFIG_SPARSEMEM_VMEMMAP, we directly use the prefined marco
PAGES_PER_SECTION in free_map_bootmem. When !CONFIG_SPARSEMEM_VMEMMAP,
we calculate page numbers needed to hold the page structs for a
memory section and use the value in free_map_bootmem.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/sparse.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index fbb9dbc..908c134 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -603,10 +603,10 @@ static void __kfree_section_memmap(struct page *memmap)
 	vmemmap_free(start, end);
 }
 #ifdef CONFIG_MEMORY_HOTREMOVE
-static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
+static void free_map_bootmem(struct page *memmap)
 {
 	unsigned long start = (unsigned long)memmap;
-	unsigned long end = (unsigned long)(memmap + nr_pages);
+	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
 
 	vmemmap_free(start, end);
 }
@@ -648,11 +648,13 @@ static void __kfree_section_memmap(struct page *memmap)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
+static void free_map_bootmem(struct page *memmap)
 {
 	unsigned long maps_section_nr, removing_section_nr, i;
 	unsigned long magic;
 	struct page *page = virt_to_page(memmap);
+	unsigned long nr_pages = get_order(sizeof(struct page) *
+					   PAGES_PER_SECTION);
 
 	for (i = 0; i < nr_pages; i++, page++) {
 		magic = (unsigned long) page->lru.next;
@@ -756,7 +758,6 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 {
 	struct page *usemap_page;
-	unsigned long nr_pages;
 
 	if (!usemap)
 		return;
@@ -777,12 +778,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 	 * on the section which has pgdat at boot time. Just keep it as is now.
 	 */
 
-	if (memmap) {
-		nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
-			>> PAGE_SHIFT;
-
-		free_map_bootmem(memmap, nr_pages);
-	}
+	if (memmap)
+		free_map_bootmem(memmap);
 }
 
 void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
