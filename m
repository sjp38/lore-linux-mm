From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 005/005](memory hotplug) free memmaps allocated by bootmem
Date: Thu, 03 Apr 2008 14:45:48 +0900
Message-ID: <20080403144426.D200.E1E9C6FF@jp.fujitsu.com>
References: <20080403140221.D1F2.E1E9C6FF@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760680AbYDCFvK@vger.kernel.org>
In-Reply-To: <20080403140221.D1F2.E1E9C6FF@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Yinghai Lu <yhlu.kernel@gmail.com>, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org


This patch is to free memmaps which is allocated by bootmem.

Freeing usemap is not necessary. The pages of usemap may be necessary
for other sections. If removing section is last section on the node,
its page must be isolated from page allocator to remove it.
Then it shouldn't be freed and kept as it is.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 mm/internal.h   |    3 +--
 mm/page_alloc.c |    2 +-
 mm/sparse.c     |   50 ++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 48 insertions(+), 7 deletions(-)

Index: current/mm/sparse.c
===================================================================
--- current.orig/mm/sparse.c	2008-04-01 20:58:52.000000000 +0900
+++ current/mm/sparse.c	2008-04-01 20:59:07.000000000 +0900
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
+#include "internal.h"
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
@@ -348,6 +349,10 @@
 {
 	return; /* XXX: Not implemented yet */
 }
+static void free_map_bootmem(struct page *page, unsigned long nr_pages)
+{
+	return; /* XXX: Not implemented yet */
+}
 #else
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 {
@@ -385,17 +390,45 @@
 		free_pages((unsigned long)memmap,
 			   get_order(sizeof(struct page) * nr_pages));
 }
+
+static void free_map_bootmem(struct page *page, unsigned long nr_pages)
+{
+	unsigned long maps_section_nr, removing_section_nr, i;
+	int magic;
+
+	for (i = 0; i < nr_pages; i++, page++) {
+		magic = atomic_read(&page->_mapcount);
+
+		BUG_ON(magic == NODE_INFO);
+
+		maps_section_nr = pfn_to_section_nr(page_to_pfn(page));
+		removing_section_nr = page->private;
+
+		/*
+		 * If removing section's memmap is placed on other section,
+		 * it must be free.
+		 * Else, nothing is necessary. the memmap is already isolated
+		 * against page allocator, and it is not used any more.
+		 */
+		if (maps_section_nr != removing_section_nr)
+			put_page_bootmem(page);
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
@@ -403,10 +436,19 @@
 	}
 
 	/*
-	 * TODO: Allocations came from bootmem - how do I free up ?
+	 * The usemap came from bootmem. This is packed with other usemaps
+	 * on the section which has pgdat at boot time. Just keep it as is now.
 	 */
-	printk(KERN_WARNING "Not freeing up allocations from bootmem "
-			"- leaking memory\n");
+
+	if (memmap) {
+		struct page *memmap_page;
+		memmap_page = virt_to_page(memmap);
+
+		nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
+			>> PAGE_SHIFT;
+
+		free_map_bootmem(memmap_page, nr_pages);
+	}
 }
 
 /*
Index: current/mm/page_alloc.c
===================================================================
--- current.orig/mm/page_alloc.c	2008-04-01 20:56:45.000000000 +0900
+++ current/mm/page_alloc.c	2008-04-01 20:59:07.000000000 +0900
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
--- current.orig/mm/internal.h	2008-04-01 20:56:45.000000000 +0900
+++ current/mm/internal.h	2008-04-01 20:59:07.000000000 +0900
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
