Message-Id: <20071004040004.041950009@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:45 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [10/18] Sparsemem: Use fallback for the memmap.
Content-Disposition: inline; filename=vcompound_sparse_gfp_vfallback
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Sparsemem currently attempts first to do a physically contiguous mapping
and then falls back to vmalloc. The same thing can now be accomplished
using GFP_VFALLBACK.

Cc: apw@shadowen.org
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/sparse.c |   33 +++------------------------------
 1 file changed, 3 insertions(+), 30 deletions(-)

Index: linux-2.6/mm/sparse.c
===================================================================
--- linux-2.6.orig/mm/sparse.c	2007-10-02 22:02:58.000000000 -0700
+++ linux-2.6/mm/sparse.c	2007-10-02 22:19:58.000000000 -0700
@@ -269,40 +269,13 @@ void __init sparse_init(void)
 #ifdef CONFIG_MEMORY_HOTPLUG
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
-}
-
-static int vaddr_in_vmalloc_area(void *addr)
-{
-	if (addr >= (void *)VMALLOC_START &&
-	    addr < (void *)VMALLOC_END)
-		return 1;
-	return 0;
+	return (struct page *)__get_free_pages(GFP_VFALLBACK,
+			get_order(memmap_size));
 }
 
 static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
 {
-	if (vaddr_in_vmalloc_area(memmap))
-		vfree(memmap);
-	else
-		free_pages((unsigned long)memmap,
+	free_pages((unsigned long)memmap,
 			   get_order(sizeof(struct page) * nr_pages));
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
