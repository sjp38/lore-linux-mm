Date: Wed, 10 May 2000 18:30:33 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: [PATCH] memory wastage in zoned allocator
Message-ID: <Pine.LNX.3.96.1000510182555.32678A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hey folks,

As near as I can tell, the fact that the zoned allocator is using the
priority/wait bits in the GFP_xxx flags is providing 0 benefit at a
substantial memory/cache cost.  If noone can give a good reason for this,
might I suggest the following patch?  If it really matters, we could pass
the flags in via the high bits of the order...

		-ben

diff -ur 2.3.99-pre7-8/include/linux/mm.h linux-test/include/linux/mm.h
--- 2.3.99-pre7-8/include/linux/mm.h	Tue May  9 15:15:11 2000
+++ linux-test/include/linux/mm.h	Wed May 10 17:58:08 2000
@@ -304,17 +304,57 @@
 extern mem_map_t * mem_map;
 
 /*
+ * GFP bitmasks..
+ */
+/* allocation flags -- "how" memory is allocated. */
+#define __GFP_WAIT	0x10
+#define __GFP_HIGH	0x20
+#define __GFP_IO	0x40
+
+
+/* allocation types -- "what" memory is allocated. */
+#define __GFP_TYPE_MASK	0x03
+
+#define __GFP_DMA	0x01
+#ifdef CONFIG_HIGHMEM
+#define __GFP_HIGHMEM	0x02
+#else
+#define __GFP_HIGHMEM	0x0 /* noop */
+#endif
+
+
+#define GFP_BUFFER	(__GFP_HIGH | __GFP_WAIT)
+#define GFP_ATOMIC	(__GFP_HIGH)
+#define GFP_USER	(__GFP_WAIT | __GFP_IO)
+#define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
+#define GFP_KERNEL	(__GFP_HIGH | __GFP_WAIT | __GFP_IO)
+#define GFP_NFS		(__GFP_HIGH | __GFP_WAIT | __GFP_IO)
+#define GFP_KSWAPD	(__GFP_IO)
+
+/* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
+   platforms, used as appropriate on others */
+
+#define GFP_DMA		__GFP_DMA
+
+/* Flag - indicates that the buffer can be taken from high memory which is not
+   permanently mapped by the kernel */
+
+#define GFP_HIGHMEM	__GFP_HIGHMEM
+
+/*
  * There is only one page-allocator function, and two main namespaces to
  * it. The alloc_page*() variants return 'struct page *' and as such
  * can allocate highmem pages, the *get*page*() variants return
  * virtual kernel addresses to the allocated page(s).
  */
-extern struct page * FASTCALL(__alloc_pages(zonelist_t *zonelist, unsigned long order));
+extern struct page * FASTCALL(__alloc_pages(zonelist_t *zonelist, unsigned long order, int flags));
 extern struct page * alloc_pages_node(int nid, int gfp_mask, unsigned long order);
 
 #ifndef CONFIG_DISCONTIGMEM
 static inline struct page * alloc_pages(int gfp_mask, unsigned long order)
 {
+	int flags = gfp_mask;
+	gfp_mask &= __GFP_TYPE_MASK;
 	/*  temporary check. */
 	if (contig_page_data.node_zonelists[gfp_mask].gfp_mask != (gfp_mask))
 		BUG();
@@ -323,7 +363,7 @@
 	 */
 	if (order >= MAX_ORDER)
 		return NULL;
-	return __alloc_pages(contig_page_data.node_zonelists+(gfp_mask), order);
+	return __alloc_pages(contig_page_data.node_zonelists+(gfp_mask), order, flags);
 }
 #else /* !CONFIG_DISCONTIGMEM */
 extern struct page * alloc_pages(int gfp_mask, unsigned long order);
@@ -466,38 +506,6 @@
 			size_t size, unsigned int flags);
 extern struct page *filemap_nopage(struct vm_area_struct * area,
 				    unsigned long address, int no_share);
-
-/*
- * GFP bitmasks..
- */
-#define __GFP_WAIT	0x01
-#define __GFP_HIGH	0x02
-#define __GFP_IO	0x04
-#define __GFP_DMA	0x08
-#ifdef CONFIG_HIGHMEM
-#define __GFP_HIGHMEM	0x10
-#else
-#define __GFP_HIGHMEM	0x0 /* noop */
-#endif
-
-
-#define GFP_BUFFER	(__GFP_HIGH | __GFP_WAIT)
-#define GFP_ATOMIC	(__GFP_HIGH)
-#define GFP_USER	(__GFP_WAIT | __GFP_IO)
-#define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
-#define GFP_KERNEL	(__GFP_HIGH | __GFP_WAIT | __GFP_IO)
-#define GFP_NFS		(__GFP_HIGH | __GFP_WAIT | __GFP_IO)
-#define GFP_KSWAPD	(__GFP_IO)
-
-/* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
-   platforms, used as appropriate on others */
-
-#define GFP_DMA		__GFP_DMA
-
-/* Flag - indicates that the buffer can be taken from high memory which is not
-   permanently mapped by the kernel */
-
-#define GFP_HIGHMEM	__GFP_HIGHMEM
 
 /* vma is the first one with  address < vma->vm_end,
  * and even  address < vma->vm_start. Have to extend vma. */
diff -ur 2.3.99-pre7-8/include/linux/mmzone.h linux-test/include/linux/mmzone.h
--- 2.3.99-pre7-8/include/linux/mmzone.h	Thu Apr 27 00:44:38 2000
+++ linux-test/include/linux/mmzone.h	Wed May 10 17:55:11 2000
@@ -72,7 +72,7 @@
 	int gfp_mask;
 } zonelist_t;
 
-#define NR_GFPINDEX		0x100
+#define NR_GFPINDEX		0x04
 
 struct bootmem_data;
 typedef struct pglist_data {
diff -ur 2.3.99-pre7-8/mm/numa.c linux-test/mm/numa.c
--- 2.3.99-pre7-8/mm/numa.c	Wed Apr 12 14:39:50 2000
+++ linux-test/mm/numa.c	Wed May 10 18:07:39 2000
@@ -33,7 +33,7 @@
 
 struct page * alloc_pages_node(int nid, int gfp_mask, unsigned long order)
 {
-	return __alloc_pages(NODE_DATA(nid)->node_zonelists + gfp_mask, order);
+	return __alloc_pages(NODE_DATA(nid)->node_zonelists + gfp_mask, order, gfp_mask);
 }
 
 #ifdef CONFIG_DISCONTIGMEM
diff -ur 2.3.99-pre7-8/mm/page_alloc.c linux-test/mm/page_alloc.c
--- 2.3.99-pre7-8/mm/page_alloc.c	Tue May  9 15:15:12 2000
+++ linux-test/mm/page_alloc.c	Wed May 10 18:00:18 2000
@@ -213,7 +213,7 @@
 /*
  * This is the 'heart' of the zoned buddy allocator:
  */
-struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
+struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order, int gfp_mask)
 {
 	zone_t **zone = zonelist->zones;
 	extern wait_queue_head_t kswapd_wait;
@@ -269,7 +269,6 @@
 	 * been able to cope..
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
-		int gfp_mask = zonelist->gfp_mask;
 		if (!try_to_free_pages(gfp_mask)) {
 			if (!(gfp_mask & __GFP_HIGH))
 				return NULL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
