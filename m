Date: Mon, 16 Feb 2004 10:36:58 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] 2.6.3-rc3-mm1: align scan_page per node
Message-ID: <30430000.1076956618@flay>
In-Reply-To: <20040216095746.5ad2656b.akpm@osdl.org>
References: <4030BB86.8060206@cyberone.com.au><7090000.1076946440@[10.10.2.4]> <20040216095746.5ad2656b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: piggin@cyberone.com.au, Nikita@Namesys.COM, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Monday, February 16, 2004 09:57:46 -0800 Andrew Morton <akpm@osdl.org> wrote:

> "Martin J. Bligh" <mbligh@aracnet.com> wrote:
>> 
>> --Nick Piggin <piggin@cyberone.com.au> wrote (on Monday, February 16, 2004 23:45:58 +1100):
>> 
>> > Ok ok, I'll do it... is this the right way to go about it?
>> > I'm assuming it is worth doing?
>> 
>> 
>> What were the include dependencies you ran into originally? Were they 
>> not fixable somehow? They probably need fixing anyway ;-)
>> 
> 
> We would need struct page in scope for mmzone.h.  Not nice.  It could be
> done: move the bare pageframe defn into its own header with appropriate
> forward decls.

Bah, not that *again* ;-) ... We've hit this several times before, and 
kludged around it. Here's an old fix from 2.5.58 ... if I do something
along these lines to current code, and test it, would you be interested
in taking it? I think most of the top section all got done already, so
it really shouldn't be too bad.

M.

diff -urpN -X /home/fletch/.diff.exclude virgin/include/asm-i386/mmzone.h struct_page/include/asm-i386/mmzone.h
--- virgin/include/asm-i386/mmzone.h	Sun Nov 17 20:29:46 2002
+++ struct_page/include/asm-i386/mmzone.h	Thu Jan 16 23:59:51 2003
@@ -22,24 +22,31 @@ extern struct pglist_data *node_data[];
  * Following are macros that are specific to this numa platform.
  */
 #define reserve_bootmem(addr, size) \
-	reserve_bootmem_node(NODE_DATA(0), (addr), (size))
+	reserve_bootmem_node(node_data[0], (addr), (size))
 #define alloc_bootmem(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node(node_data[0], (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_low(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, 0)
+	__alloc_bootmem_node(node_data[0], (x), SMP_CACHE_BYTES, 0)
 #define alloc_bootmem_pages(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node(node_data[0], (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_low_pages(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
+	__alloc_bootmem_node(node_data[0], (x), PAGE_SIZE, 0)
 #define alloc_bootmem_node(ignore, x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node(node_data[0], (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_pages_node(ignore, x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node(node_data[0], (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_low_pages_node(ignore, x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
+	__alloc_bootmem_node(node_data[0], (x), PAGE_SIZE, 0)
 
-#define node_size(nid)		(node_data[nid]->node_size)
-#define node_localnr(pfn, nid)	((pfn) - node_data[nid]->node_start_pfn)
+static inline unsigned long node_size(int nid)
+{
+	return node_data[nid]->node_size;
+}
+
+static inline unsigned long node_localnr(unsigned long pfn, int nid)
+{
+	return ((pfn) - node_data[nid]->node_start_pfn);
+}
 
 /*
  * Following are macros that each numa implmentation must define.
@@ -48,26 +55,54 @@ extern struct pglist_data *node_data[];
 /*
  * Given a kernel address, find the home node of the underlying memory.
  */
-#define kvaddr_to_nid(kaddr)	pfn_to_nid(__pa(kaddr) >> PAGE_SHIFT)
+#define kvaddr_to_pfn(kvaddr)	(__pa(kvaddr) >> PAGE_SHIFT)
+#define kvaddr_to_nid(kvaddr)	pfn_to_nid(kvaddr_to_pfn(kvaddr))
 
 /*
  * Return a pointer to the node data for node n.
  */
 #define NODE_DATA(nid)		(node_data[nid])
 
-#define node_mem_map(nid)	(NODE_DATA(nid)->node_mem_map)
-#define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
-#define node_end_pfn(nid)       (NODE_DATA(nid)->node_start_pfn + \
-				 NODE_DATA(nid)->node_size)
+static inline struct page *node_mem_map(int nid) 
+{
+	return node_data[nid]->node_mem_map;
+}
+
+static inline unsigned long node_start_pfn(int nid)
+{
+	return node_data[nid]->node_start_pfn;
+}
+
+static inline unsigned long node_end_pfn(int nid)
+{
+	return node_data[nid]->node_start_pfn + node_data[nid]->node_size;
+}
+
+static inline unsigned long local_mapnr(void *kvaddr)
+{
+	kvaddr_to_pfn(kvaddr) - node_start_pfn(kvaddr_to_nid(kvaddr));
+}
+
+static inline int kern_addr_valid(void *kvaddr)
+{
+	return test_bit(local_mapnr(kaddr), 
+			node_data[kvaddr_to_nid(kaddr)]->valid_addr_bitmap);
+}
+
+static inline struct page *pfn_to_page(unsigned long pfn)
+{
+	int node = pfn_to_nid(pfn);
+
+	return node_mem_map(node) + node_localnr(pfn, node);
+}
+
+static inline unsigned long page_to_pfn (struct page * page)
+{
+	struct zone *zone = page_zone(page);
 
-#define local_mapnr(kvaddr) \
-	( (__pa(kvaddr) >> PAGE_SHIFT) - node_start_pfn(kvaddr_to_nid(kvaddr)) )
+	return ((page - zone->zone_mem_map) + zone->zone_start_pfn);
+}
 
-#define kern_addr_valid(kaddr)	test_bit(local_mapnr(kaddr), \
-		 NODE_DATA(kvaddr_to_nid(kaddr))->valid_addr_bitmap)
-
-#define pfn_to_page(pfn)	(node_mem_map(pfn_to_nid(pfn)) + node_localnr(pfn, pfn_to_nid(pfn)))
-#define page_to_pfn(page)	((page - page_zone(page)->zone_mem_map) + page_zone(page)->zone_start_pfn)
 #define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 /*
  * pfn_valid should be made as fast as possible, and the current definition 
diff -urpN -X /home/fletch/.diff.exclude virgin/include/linux/mm.h g/include/linux/mm.h
--- virgin/include/linux/mm.h	Mon Jan 13 21:09:27 2003
+++ struct_page/include/linux/mm.h	Thu Jan 16 23:22:56 2003
@@ -144,53 +144,6 @@ struct pte_chain;
 struct mmu_gather;
 
 /*
- * Each physical page in the system has a struct page associated with
- * it to keep track of whatever it is we are using the page for at the
- * moment. Note that we have no way to track which tasks are using
- * a page.
- *
- * Try to keep the most commonly accessed fields in single cache lines
- * here (16 bytes or greater).  This ordering should be particularly
- * beneficial on 32-bit processors.
- *
- * The first line is data used in page cache lookup, the second line
- * is used for linear searches (eg. clock algorithm scans). 
- *
- * TODO: make this structure smaller, it could be as small as 32 bytes.
- */
-struct page {
-	unsigned long flags;		/* atomic flags, some possibly
-					   updated asynchronously */
-	atomic_t count;			/* Usage count, see below. */
-	struct list_head list;		/* ->mapping has some page lists. */
-	struct address_space *mapping;	/* The inode (or ...) we belong to. */
-	unsigned long index;		/* Our offset within mapping. */
-	struct list_head lru;		/* Pageout list, eg. active_list;
-					   protected by zone->lru_lock !! */
-	union {
-		struct pte_chain *chain;/* Reverse pte mapping pointer.
-					 * protected by PG_chainlock */
-		pte_addr_t direct;
-	} pte;
-	unsigned long private;		/* mapping-private opaque data */
-
-	/*
-	 * On machines where all RAM is mapped into kernel address space,
-	 * we can simply calculate the virtual address. On machines with
-	 * highmem some memory is mapped into kernel virtual memory
-	 * dynamically, so we need a place to store that address.
-	 * Note that this field could be 16 bits on x86 ... ;)
-	 *
-	 * Architectures with slow multiplication can define
-	 * WANT_PAGE_VIRTUAL in asm/page.h
-	 */
-#if defined(WANT_PAGE_VIRTUAL)
-	void *virtual;			/* Kernel virtual address (NULL if
-					   not kmapped, ie. highmem) */
-#endif /* CONFIG_HIGMEM || WANT_PAGE_VIRTUAL */
-};
-
-/*
  * FIXME: take this include out, include page-flags.h in
  * files which need it (119 of them)
  */
diff -urpN -X /home/fletch/.diff.exclude virgin/include/linux/struct_page.h struct_page/include/linux/struct_page.h
--- virgin/include/linux/struct_page.h	Wed Dec 31 16:00:00 1969
+++ struct_page/include/linux/struct_page.h	Thu Jan 16 23:24:48 2003
@@ -0,0 +1,57 @@
+#ifndef _LINUX_STRUCT_PAGE_H
+#define _LINUX_STRUCT_PAGE_H
+
+#include <asm/pgtable.h>
+
+/* forward declaration; pte_chain is meant to be internal to rmap.c */
+struct pte_chain;
+struct mmu_gather;
+
+/*
+ * Each physical page in the system has a struct page associated with
+ * it to keep track of whatever it is we are using the page for at the
+ * moment. Note that we have no way to track which tasks are using
+ * a page.
+ *
+ * Try to keep the most commonly accessed fields in single cache lines
+ * here (16 bytes or greater).  This ordering should be particularly
+ * beneficial on 32-bit processors.
+ *
+ * The first line is data used in page cache lookup, the second line
+ * is used for linear searches (eg. clock algorithm scans). 
+ *
+ * TODO: make this structure smaller, it could be as small as 32 bytes.
+ */
+struct page {
+	unsigned long flags;		/* atomic flags, some possibly
+					   updated asynchronously */
+	atomic_t count;			/* Usage count, see below. */
+	struct list_head list;		/* ->mapping has some page lists. */
+	struct address_space *mapping;	/* The inode (or ...) we belong to. */
+	unsigned long index;		/* Our offset within mapping. */
+	struct list_head lru;		/* Pageout list, eg. active_list;
+					   protected by zone->lru_lock !! */
+	union {
+		struct pte_chain *chain;/* Reverse pte mapping pointer.
+					 * protected by PG_chainlock */
+		pte_addr_t direct;
+	} pte;
+	unsigned long private;		/* mapping-private opaque data */
+
+	/*
+	 * On machines where all RAM is mapped into kernel address space,
+	 * we can simply calculate the virtual address. On machines with
+	 * highmem some memory is mapped into kernel virtual memory
+	 * dynamically, so we need a place to store that address.
+	 * Note that this field could be 16 bits on x86 ... ;)
+	 *
+	 * Architectures with slow multiplication can define
+	 * WANT_PAGE_VIRTUAL in asm/page.h
+	 */
+#if defined(WANT_PAGE_VIRTUAL)
+	void *virtual;			/* Kernel virtual address (NULL if
+					   not kmapped, ie. highmem) */
+#endif /* WANT_PAGE_VIRTUAL */
+};
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
