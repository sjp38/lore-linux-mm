Message-Id: <20080321061725.476134262@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:09 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [06/14] vcompound: Virtual fallback for sparsemem
Content-Disposition: inline; filename=0009-vcompound-Virtual-fallback-for-sparsemem.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Sparsemem currently attempts to do a physically contiguous mapping
and then falls back to vmalloc. The same thing can now be accomplished
using virtual compound pages.

Cc: apw@shadowen.org
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/sparse.c |   25 ++-----------------------
 1 file changed, 2 insertions(+), 23 deletions(-)

Index: linux-2.6.25-rc5-mm1/mm/sparse.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/sparse.c	2008-03-20 18:04:45.345133447 -0700
+++ linux-2.6.25-rc5-mm1/mm/sparse.c	2008-03-20 19:32:53.361317058 -0700
@@ -327,24 +327,7 @@ static void __kfree_section_memmap(struc
 #else
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 {
-	struct page *page, *ret;
-	unsigned long memmap_size = sizeof(struct page) * nr_pages;
-
-	page = alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(memmap_size));
-	if (page)
-		goto got_map_page;
-
-	ret = vmalloc(memmap_size);
-	if (ret)
-		goto got_map_ptr;
-
-	return NULL;
-got_map_page:
-	ret = (struct page *)pfn_to_kaddr(page_to_pfn(page));
-got_map_ptr:
-	memset(ret, 0, memmap_size);
-
-	return ret;
+	return __alloc_vcompound(GFP_KERNEL, get_order(memmap_size)));
 }
 
 static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
@@ -355,11 +338,7 @@ static inline struct page *kmalloc_secti
 
 static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
 {
-	if (is_vmalloc_addr(memmap))
-		vfree(memmap);
-	else
-		free_pages((unsigned long)memmap,
-			   get_order(sizeof(struct page) * nr_pages));
+	__free_vcompound(memmap);
 }
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
