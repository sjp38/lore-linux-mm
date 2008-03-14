Date: Fri, 14 Mar 2008 23:41:59 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH 2/3 (RFC)](memory hotplug) free pages allocated by bootmem for hotremove
In-Reply-To: <20080314231112.20D7.E1E9C6FF@jp.fujitsu.com>
References: <20080314231112.20D7.E1E9C6FF@jp.fujitsu.com>
Message-Id: <20080314233901.20DB.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This patch is to free memmap and usemap by using registered information.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 mm/internal.h   |    3 +--
 mm/page_alloc.c |    2 +-
 mm/sparse.c     |   47 +++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 43 insertions(+), 9 deletions(-)

Index: current/mm/sparse.c
===================================================================
--- current.orig/mm/sparse.c	2008-03-10 22:24:46.000000000 +0900
+++ current/mm/sparse.c	2008-03-10 22:31:03.000000000 +0900
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
+#include "internal.h"
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
@@ -361,28 +362,62 @@
 		free_pages((unsigned long)memmap,
 			   get_order(sizeof(struct page) * nr_pages));
 }
+
+static void free_maps_by_bootmem(struct page *map, unsigned long nr_pages)
+{
+	unsigned long maps_section_nr, removing_section_nr, i;
+	struct page *page = map;
+
+	for (i = 0; i < nr_pages; i++, page++) {
+		maps_section_nr = pfn_to_section_nr(page_to_pfn(page));
+		removing_section_nr = page->private;
+
+		/*
+		 * If removing section's memmap is placed on other section,
+		 * it must be free.
+		 * Else, nothing is necessary. the memmap is already isolated
+		 * against page allocator, and it is not used any more.
+		 */
+		if (maps_section_nr != removing_section_nr) {
+			clear_page_bootmem_info(page);
+			__free_pages_bootmem(page, 0);
+		}
+	}
+}
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
 static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 {
+	struct page *usemap_page;
+	unsigned long nr_pages;
+
 	if (!usemap)
 		return;
 
+	usemap_page = virt_to_page(usemap);
 	/*
 	 * Check to see if allocation came from hot-plug-add
 	 */
-	if (PageSlab(virt_to_page(usemap))) {
+	if (PageSlab(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
 			__kfree_section_memmap(memmap, PAGES_PER_SECTION);
 		return;
 	}
 
-	/*
-	 * TODO: Allocations came from bootmem - how do I free up ?
-	 */
-	printk(KERN_WARNING "Not freeing up allocations from bootmem "
-			"- leaking memory\n");
+	/* free maps came from bootmem */
+	nr_pages = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
+	free_maps_by_bootmem(usemap_page, nr_pages);
+
+	if (memmap) {
+		struct page *memmap_page;
+		memmap_page = virt_to_page(memmap);
+
+		nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
+			>> PAGE_SHIFT;
+
+		free_maps_by_bootmem(memmap_page, nr_pages);
+	}
 }
 
 /*
Index: current/mm/page_alloc.c
===================================================================
--- current.orig/mm/page_alloc.c	2008-03-10 22:24:46.000000000 +0900
+++ current/mm/page_alloc.c	2008-03-10 22:29:20.000000000 +0900
@@ -564,7 +564,7 @@
 /*
  * permit the bootmem allocator to evade page validation on high-order frees
  */
-void __init __free_pages_bootmem(struct page *page, unsigned int order)
+void __free_pages_bootmem(struct page *page, unsigned int order)
 {
 	if (order == 0) {
 		__ClearPageReserved(page);
Index: current/mm/internal.h
===================================================================
--- current.orig/mm/internal.h	2008-03-10 22:24:46.000000000 +0900
+++ current/mm/internal.h	2008-03-10 22:29:20.000000000 +0900
@@ -34,8 +34,7 @@
 	atomic_dec(&page->_count);
 }
 
-extern void __init __free_pages_bootmem(struct page *page,
-						unsigned int order);
+extern void __free_pages_bootmem(struct page *page, unsigned int order);
 
 /*
  * function for dealing with page's order in buddy system.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
