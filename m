Message-Id: <20080430044320.303065251@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:42:57 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [06/11] sparsemem: Use virtualizable compound page
Content-Disposition: inline; filename=vcp_sparsemem_fallback
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Sparsemem currently attempts to allocate a physically contiguous memmap
and then falls back to vmalloc. The same can now be accomplished
using a request for a virtualizable compound pages.

Cc: apw@shadowen.org
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/sparse.c |   25 ++-----------------------
 1 file changed, 2 insertions(+), 23 deletions(-)

Index: linux-2.6/mm/sparse.c
===================================================================
--- linux-2.6.orig/mm/sparse.c	2008-04-29 16:50:39.761208362 -0700
+++ linux-2.6/mm/sparse.c	2008-04-29 17:07:42.773707952 -0700
@@ -383,24 +383,7 @@ static void free_map_bootmem(struct page
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
@@ -411,11 +394,7 @@ static inline struct page *kmalloc_secti
 
 static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
 {
-	if (is_vmalloc_addr(memmap))
-		vfree(memmap);
-	else
-		free_pages((unsigned long)memmap,
-			   get_order(sizeof(struct page) * nr_pages));
+	__free_vcompound(memmap);
 }
 
 static void free_map_bootmem(struct page *page, unsigned long nr_pages)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
