Message-Id: <20070925233007.069128686@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:50 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 07/14] vmalloc: Clean up page array indexing
Content-Disposition: inline; filename=vcompound_array_indexes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The page array is repeatedly indexed both in vunmap and vmalloc_area_node().
Add a temporary variable to make it easier to read (and easier to patch
later).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmalloc.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

Index: linux-2.6.23-rc8-mm1/mm/vmalloc.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/vmalloc.c	2007-09-25 15:16:38.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/vmalloc.c	2007-09-25 15:21:29.000000000 -0700
@@ -384,8 +384,10 @@ static void __vunmap(const void *addr, i
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
@@ -489,15 +491,19 @@ void *__vmalloc_area_node(struct vm_stru
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
