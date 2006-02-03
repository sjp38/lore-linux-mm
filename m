Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137eA5d008149 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:40:10 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s12.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137e9Y7028762 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:40:09 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s12.gw.fujitsu.co.jp (s12 [127.0.0.1])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F7871CC00E
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:40:09 +0900 (JST)
Received: from fjm502.ms.jp.fujitsu.com (fjm502.ms.jp.fujitsu.com [10.56.99.74])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id AC94C1CC123
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:40:08 +0900 (JST)
Received: from [127.0.0.1] (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm502.ms.jp.fujitsu.com with ESMTP id k137e5e3001056
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:40:06 +0900
Message-ID: <43E30911.6060607@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:41:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] pearing off zone from physical memory layout [3/10] replace
 page_to_pfn()
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Replace page_to_pfn() functions which uses zone->zone_mem_map.

Although pfn_to_page() uses node->node_mem_map, page_to_pfn() uses
zone->zone_mem_map. I don't know why.

x86_64 arch seems to want not to make page_to_pfn() inlined.
So, CONFIG_DONT_INLINE_PAGE_TO_PFN is added.
I don't know whether all archs wants this or not.


Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: hogehoge/include/asm-i386/mmzone.h
===================================================================
--- hogehoge.orig/include/asm-i386/mmzone.h
+++ hogehoge/include/asm-i386/mmzone.h
@@ -93,14 +93,6 @@ static inline int pfn_to_nid(unsigned lo
  	&NODE_DATA(__node)->node_mem_map[node_localnr(__pfn,__node)];	\
  })

-#define page_to_pfn(pg)							\
-({									\
-	struct page *__page = pg;					\
-	struct zone *__zone = page_zone(__page);			\
-	(unsigned long)(__page - __zone->zone_mem_map)			\
-		+ __zone->zone_start_pfn;				\
-})
-
  #ifdef CONFIG_X86_NUMAQ            /* we have contiguous memory on NUMA-Q */
  #define pfn_valid(pfn)          ((pfn) < num_physpages)
  #else
Index: hogehoge/include/linux/mm.h
===================================================================
--- hogehoge.orig/include/linux/mm.h
+++ hogehoge/include/linux/mm.h
@@ -484,6 +484,17 @@ static inline struct pglist_data *page_n
  	return NODE_DATA(page_to_nid(page));
  }

+#if defined(CONFIG_FLAT_NODE_MEM_MAP) && !defined(HAVE_ARCH_PAGE_TO_PFN)
+#ifndef CONFIG_DONT_INLINE_PAGE_TO_PFN /* looks x86_64 people wants this */
+static inline unsigned long page_to_pfn(struct page *page)
+{
+	return (page - page_node(page)->node_mem_map) + page_node(page)->node_start_pfn;
+}
+#else
+extern unsigned long page_to_pfn(struct page *page);
+#endif
+#endif
+
  static inline unsigned long page_to_section(struct page *page)
  {
  	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
Index: hogehoge/include/asm-alpha/mmzone.h
===================================================================
--- hogehoge.orig/include/asm-alpha/mmzone.h
+++ hogehoge/include/asm-alpha/mmzone.h
@@ -86,8 +86,7 @@ PLAT_NODE_DATA_LOCALNR(unsigned long p,
  	pte_t pte;                                                           \
  	unsigned long pfn;                                                   \
  									     \
-	pfn = ((unsigned long)((page)-page_zone(page)->zone_mem_map)) << 32; \
-	pfn += page_zone(page)->zone_start_pfn << 32;			     \
+	pfn = page_to_pfn(page) << 32; \
  	pte_val(pte) = pfn | pgprot_val(pgprot);			     \
  									     \
  	pte;								     \
@@ -110,13 +109,9 @@ PLAT_NODE_DATA_LOCALNR(unsigned long p,
  	(NODE_DATA(kvaddr_to_nid(kaddr))->node_mem_map + local_mapnr(kaddr));	\
  })

-#define page_to_pfn(page)						\
-	((page) - page_zone(page)->zone_mem_map +			\
-	 (page_zone(page)->zone_start_pfn))

  #define page_to_pa(page)						\
-	((( (page) - page_zone(page)->zone_mem_map )			\
-	+ page_zone(page)->zone_start_pfn) << PAGE_SHIFT)
+	(page_to_pfn(page) << PAGE_SHIFT)

  #define pfn_to_nid(pfn)		pa_to_nid(((u64)(pfn) << PAGE_SHIFT))
  #define pfn_valid(pfn)							\
Index: hogehoge/include/asm-arm/memory.h
===================================================================
--- hogehoge.orig/include/asm-arm/memory.h
+++ hogehoge/include/asm-arm/memory.h
@@ -190,9 +190,7 @@ static inline __deprecated void *bus_to_
   */
  #include <linux/numa.h>

-#define page_to_pfn(page)					\
-	(( (page) - page_zone(page)->zone_mem_map)		\
-	  + page_zone(page)->zone_start_pfn)
+/* page_to_pfn is defined in include/linux/mm.h */

  #define pfn_to_page(pfn)					\
  	(PFN_TO_MAPBASE(pfn) + LOCAL_MAP_NR((pfn) << PAGE_SHIFT))
Index: hogehoge/include/asm-m32r/mmzone.h
===================================================================
--- hogehoge.orig/include/asm-m32r/mmzone.h
+++ hogehoge/include/asm-m32r/mmzone.h
@@ -28,13 +28,6 @@ extern struct pglist_data *node_data[];
  	&NODE_DATA(__node)->node_mem_map[node_localnr(__pfn,__node)];	\
  })

-#define page_to_pfn(pg)							\
-({									\
-	struct page *__page = pg;					\
-	struct zone *__zone = page_zone(__page);			\
-	(unsigned long)(__page - __zone->zone_mem_map)			\
-		+ __zone->zone_start_pfn;				\
-})
  #define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
  /*
   * pfn_valid should be made as fast as possible, and the current definition
Index: hogehoge/include/asm-mips/mmzone.h
===================================================================
--- hogehoge.orig/include/asm-mips/mmzone.h
+++ hogehoge/include/asm-mips/mmzone.h
@@ -29,13 +29,6 @@
  	__pg->node_mem_map + (__pfn - __pg->node_start_pfn);	\
  })

-#define page_to_pfn(p)						\
-({								\
-	struct page *__p = (p);					\
-	struct zone *__z = page_zone(__p);			\
-	((__p - __z->zone_mem_map) + __z->zone_start_pfn);	\
-})
-
  /* XXX: FIXME -- wli */
  #define kern_addr_valid(addr)	(0)

Index: hogehoge/include/asm-parisc/mmzone.h
===================================================================
--- hogehoge.orig/include/asm-parisc/mmzone.h
+++ hogehoge/include/asm-parisc/mmzone.h
@@ -34,14 +34,6 @@ extern struct node_map_data node_data[];
  	&NODE_DATA(__node)->node_mem_map[node_localnr(__pfn,__node)];	\
  })

-#define page_to_pfn(pg)							\
-({									\
-	struct page *__page = pg;					\
-	struct zone *__zone = page_zone(__page);			\
-	BUG_ON(__zone == NULL);						\
-	(unsigned long)(__page - __zone->zone_mem_map)			\
-		+ __zone->zone_start_pfn;				\
-})

  /* We have these possible memory map layouts:
   * Astro: 0-3.75, 67.75-68, 4-64
Index: hogehoge/arch/x86_64/Kconfig
===================================================================
--- hogehoge.orig/arch/x86_64/Kconfig
+++ hogehoge/arch/x86_64/Kconfig
@@ -321,6 +321,10 @@ config HAVE_ARCH_EARLY_PFN_TO_NID
  	def_bool y
  	depends on NUMA

+config DONT_INLINE_PAGE_TO_PFN
+	def_bool y
+	depends on NUMA
+
  config NR_CPUS
  	int "Maximum number of CPUs (2-256)"
  	range 2 256
Index: hogehoge/arch/x86_64/mm/numa.c
===================================================================
--- hogehoge.orig/arch/x86_64/mm/numa.c
+++ hogehoge/arch/x86_64/mm/numa.c
@@ -379,8 +379,8 @@ EXPORT_SYMBOL(pfn_to_page);

  unsigned long page_to_pfn(struct page *page)
  {
-	return (long)(((page) - page_zone(page)->zone_mem_map) +
-		      page_zone(page)->zone_start_pfn);
+	return (long)(((page) - page_node(page)->node_mem_map) +
+		      page_node(page)->node_start_pfn);
  }
  EXPORT_SYMBOL(page_to_pfn);

Index: hogehoge/mm/page_alloc.c
===================================================================
--- hogehoge.orig/mm/page_alloc.c
+++ hogehoge/mm/page_alloc.c
@@ -2712,3 +2712,13 @@ void *__init alloc_large_system_hash(con

  	return table;
  }
+
+/* inlined version is in include/linux/mm.h */
+#if defined(CONFIG_NODE_FLAT_MEM_MAP) && defined(CONFIG_DISCONTIG_MEM)
+#ifdef DONT_INLINE_PAGE_TO_PFN
+unsigned long page_to_pfn(struct page *page)
+{
+	return (page - page_node(page)->node_mem_map) + page_node(page)->node_start_pfn;
+}
+#endif
+#endif
Index: hogehoge/arch/ia64/Kconfig
===================================================================
--- hogehoge.orig/arch/ia64/Kconfig
+++ hogehoge/arch/ia64/Kconfig
@@ -330,6 +330,10 @@ config VIRTUAL_MEM_MAP
  	  require the DISCONTIGMEM option for your machine. If you are
  	  unsure, say Y.

+config HAVE_ARCH_PAGE_TO_PFN
+	default y
+	if VIRTUAL_MEM_MAP
+
  config HOLES_IN_ZONE
  	bool
  	default y if VIRTUAL_MEM_MAP
Index: hogehoge/mm/Kconfig
===================================================================
--- hogehoge.orig/mm/Kconfig
+++ hogehoge/mm/Kconfig
@@ -77,6 +77,10 @@ config FLAT_NODE_MEM_MAP
  	def_bool y
  	depends on !SPARSEMEM

+config HAVE_ARCH_PAGE_TO_PFN
+	def_bool y
+	depends on FLATMEM
+
  #
  # Both the NUMA code and DISCONTIGMEM use arrays of pg_data_t's
  # to represent different areas of memory.  This variable allows

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
