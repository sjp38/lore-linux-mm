Message-Id: <20071004040001.944050958@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:36 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [01/18] vmalloc: clean up page array indexing
Content-Disposition: inline; filename=vcompound_array_indexes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The page array is repeatedly indexed both in vunmap and vmalloc_area_node().
Add a temporary variable to make it easier to read (and easier to patch
later).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmalloc.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c	2007-10-02 09:26:16.000000000 -0700
+++ linux-2.6/mm/vmalloc.c	2007-10-02 21:35:34.000000000 -0700
@@ -345,8 +345,10 @@ static void __vunmap(void *addr, int dea
 		int i;
 
 		for (i = 0; i < area->nr_pages; i++) {
-			BUG_ON(!area->pages[i]);
-			__free_page(area->pages[i]);
+			struct page *page = area->pages[i];
+
+			BUG_ON(!page);
+			__free_page(page);
 		}
 
 		if (area->flags & VM_VPAGES)
@@ -450,15 +452,19 @@ void *__vmalloc_area_node(struct vm_stru
 	}
 
 	for (i = 0; i < area->nr_pages; i++) {
+		struct page *page;
+
 		if (node < 0)
-			area->pages[i] = alloc_page(gfp_mask);
+			page = alloc_page(gfp_mask);
 		else
-			area->pages[i] = alloc_pages_node(node, gfp_mask, 0);
-		if (unlikely(!area->pages[i])) {
+			page = alloc_pages_node(node, gfp_mask, 0);
+
+		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
 			area->nr_pages = i;
 			goto fail;
 		}
+		area->pages[i] = page;
 	}
 
 	if (map_vm_area(area, prot, &pages))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
