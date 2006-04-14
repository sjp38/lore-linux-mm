Date: Fri, 14 Apr 2006 20:36:18 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] slab: cleanup kmem_getpages
Message-ID: <20060414183618.GA21144@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The last ifdef addition hit the ugliness treshold on this functions, so:

 - rename the varibale i to nr_pages so it's somewhat descriptive
 - remove the addr variable and do the page_address call at the very end
 - instead of ifdef'ing the whole alloc_pages_node call just make the
   __GFP_COMP addition to flags conditional
 - rewrite the __GFP_COMP comment to make sense


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2006-04-13 16:22:12.000000000 +0200
+++ linux-2.6/mm/slab.c	2006-04-13 16:53:15.000000000 +0200
@@ -1452,31 +1452,30 @@
 static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
 	struct page *page;
-	void *addr;
-	int i;
+	int nr_pages;
 
-	flags |= cachep->gfpflags;
 #ifndef CONFIG_MMU
-	/* nommu uses slab's for process anonymous memory allocations, so
-	 * requires __GFP_COMP to properly refcount higher order allocations"
+	/*
+	 * Nommu uses slab's for process anonymous memory allocations, and thus
+	 * requires __GFP_COMP to properly refcount higher order allocations
 	 */
-	page = alloc_pages_node(nodeid, (flags | __GFP_COMP), cachep->gfporder);
-#else
-	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
+	flags |= __GFP_COMP;
 #endif
+	flags |= cachep->gfpflags;
+
+	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
 	if (!page)
 		return NULL;
-	addr = page_address(page);
 
-	i = (1 << cachep->gfporder);
+	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		atomic_add(i, &slab_reclaim_pages);
-	add_page_state(nr_slab, i);
-	while (i--) {
+		atomic_add(nr_pages, &slab_reclaim_pages);
+	add_page_state(nr_slab, nr_pages);
+	while (nr_pages--) {
 		__SetPageSlab(page);
 		page++;
 	}
-	return addr;
+	return page_address(page);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
