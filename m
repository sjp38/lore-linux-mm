Date: Thu, 19 Oct 2006 17:21:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-Id: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is a patch for virtual memmap on sparsemem against 2.6.19-rc2.
booted well on my Tiger4.

In this time, this is just a RFC. comments on patch and advises for benchmarking
is welcome. (memory hotplug case is not well handled yet.)

ia64's SPARSEMEM uses SPARSEMEM_EXTREME. This requires 2-level table lookup by
software for page_to_pfn()/pfn_to_page(). virtual memmap can remove that costs.
But will consume more TLBs.

For make patches simple, pfn_valid() uses sparsemem's logic. 

- Kame
==
This patch maps sparsemem's *sparse* memmap into contiguous virtual address range
starting from virt_memmap_start.

By this, pfn_to_page, page_to_pfn can be implemented as 
#define pfn_to_page(pfn)		(virt_memmap_start + (pfn))
#define page_to_pfn(pg)			(pg - virt_memmap_start)


Difference from ia64's VIRTUAL_MEMMAP are
* pfn_valid() uses sparsemem's logic.
* memmap is allocated per SECTION_SIZE, so there will be some of RESERVED pages.
* no holes in MAX_ORDER range. so HOLE_IN_ZONE=n here.

Todo
- fix vmalloc() case in memory hotadd. (maybe __get_vm_area() can be used.)

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/asm-generic/memory_model.h |    7 +++
 include/linux/mmzone.h             |    8 +++
 mm/Kconfig                         |    8 +++
 mm/sparse.c                        |   85 +++++++++++++++++++++++++++++++++++--
 4 files changed, 104 insertions(+), 4 deletions(-)

Index: linux-2.6.19-rc2/mm/Kconfig
===================================================================
--- linux-2.6.19-rc2.orig/mm/Kconfig	2006-10-18 18:13:39.000000000 +0900
+++ linux-2.6.19-rc2/mm/Kconfig	2006-10-18 18:14:07.000000000 +0900
@@ -77,6 +77,14 @@
 	def_bool y
 	depends on !SPARSEMEM
 
+config VMEMMAP_SPARSEMEM
+	bool "memmap in virtual space"
+	default y
+	depends on SPARSEMEM && ARCH_VMEMMAP_SPARSEMEM_SUPPORT
+	help
+	  If this option is selected, you can speed up some kernel execution.
+	  But this consumes large amount of virtual memory area in kernel.
+
 #
 # Both the NUMA code and DISCONTIGMEM use arrays of pg_data_t's
 # to represent different areas of memory.  This variable allows
Index: linux-2.6.19-rc2/include/asm-generic/memory_model.h
===================================================================
--- linux-2.6.19-rc2.orig/include/asm-generic/memory_model.h	2006-09-20 12:42:06.000000000 +0900
+++ linux-2.6.19-rc2/include/asm-generic/memory_model.h	2006-10-18 18:14:07.000000000 +0900
@@ -47,6 +47,7 @@
 })
 
 #elif defined(CONFIG_SPARSEMEM)
+#ifndef CONFIG_VMEMMAP_SPARSEMEM
 /*
  * Note: section's mem_map is encorded to reflect its start_pfn.
  * section[i].section_mem_map == mem_map's address - start_pfn;
@@ -62,6 +63,12 @@
 	struct mem_section *__sec = __pfn_to_section(__pfn);	\
 	__section_mem_map_addr(__sec) + __pfn;		\
 })
+#else /* CONFIG_VMEMMAP_SPARSEMEM */
+
+#define __pfn_to_page(pfn)	(virt_memmap_start + (pfn))
+#define __page_to_pfn(pg)	((unsigned long)((pg) - virt_memmap_start))
+
+#endif /* CONFIG_VMEMMAP_SPARSEMEM */
 #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
 
 #ifdef CONFIG_OUT_OF_LINE_PFN_TO_PAGE
Index: linux-2.6.19-rc2/include/linux/mmzone.h
===================================================================
--- linux-2.6.19-rc2.orig/include/linux/mmzone.h	2006-10-18 18:13:39.000000000 +0900
+++ linux-2.6.19-rc2/include/linux/mmzone.h	2006-10-18 18:14:07.000000000 +0900
@@ -599,6 +599,14 @@
 extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
 #endif
 
+
+#ifdef CONFIG_VMEMMAP_SPARSEMEM
+extern struct page *virt_memmap_start;
+extern void init_vmemmap_sparsemem(void *addr);
+#else
+#define init_vmemmap_sparsemem(addr)	do{}while(0)
+#endif
+
 static inline struct mem_section *__nr_to_section(unsigned long nr)
 {
 	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
Index: linux-2.6.19-rc2/mm/sparse.c
===================================================================
--- linux-2.6.19-rc2.orig/mm/sparse.c	2006-09-20 12:42:06.000000000 +0900
+++ linux-2.6.19-rc2/mm/sparse.c	2006-10-19 16:58:06.000000000 +0900
@@ -9,7 +9,81 @@
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
 #include <asm/dma.h>
+#include <asm/pgalloc.h>
 
+#ifdef CONFIG_VMEMMAP_SPARSEMEM
+struct page *virt_memmap_start;
+EXPORT_SYMBOL_GPL(virt_memmap_start);
+
+void init_vmemmap_sparsemem(void *start_addr)
+{
+	virt_memmap_start = start_addr;
+}
+
+void *pte_alloc_vmemmap(int node)
+{
+	void *ret;
+	if (system_state == SYSTEM_BOOTING) {
+		ret = alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE);
+	} else {
+		ret = kmalloc_node(PAGE_SIZE, GFP_KERNEL, node);
+		memset(ret, 0 , PAGE_SIZE);
+	}
+	BUG_ON(!ret);
+	return ret;
+}
+/*
+ * At Hot-add, vmalloc'ed memmap will never call this.
+ * They have been already in suitable address.
+ * Called only when map is allocated by alloc_bootmem()/alloc_pages()
+ */
+static void map_virtual_memmap(unsigned long section, void *map, int node)
+{
+	unsigned long vmap_start, vmap_end, vmap;
+	unsigned long pfn;
+	void *pg;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	BUG_ON (!virt_memmap_start);
+
+	pfn = section_nr_to_pfn(section);
+	vmap_start = (unsigned long)(virt_memmap_start + pfn);
+	vmap_end   = (unsigned long)(vmap_start + sizeof(struct page) * PAGES_PER_SECTION);
+
+	for (vmap = vmap_start; vmap < vmap_end; vmap += PAGE_SIZE, map += PAGE_SIZE)
+	{
+		pgd = pgd_offset_k(vmap);
+		if (pgd_none(*pgd)) {
+			pg = pte_alloc_vmemmap(node);
+			pgd_populate(&init_mm, pgd, pg);
+		}
+		pud = pud_offset(pgd, vmap);
+		if (pud_none(*pud)) {
+			pg = pte_alloc_vmemmap(node);
+			pud_populate(&init_mm, pud, pg);
+		}
+		pmd = pmd_offset(pud, vmap);
+		if (pmd_none(*pmd)) {
+			pg = pte_alloc_vmemmap(node);
+			pmd_populate_kernel(&init_mm, pmd, pg);
+		}
+		pte = pte_offset_kernel(pmd, vmap);
+		if (pte_none(*pte))
+			set_pte(pte, pfn_pte(__pa(map) >> PAGE_SHIFT, PAGE_KERNEL));
+	}
+	return;
+}
+#else /* CONFIG_VMEMMAP_SPARSEMEM */
+
+static inline void map_virtual_memmap(unsigned long section, void *map, int nid)
+{
+	return;
+}
+
+#endif /* CONFIG_VMEMMAP_SPARSEMEM */
 /*
  * Permanent SPARSEMEM data:
  *
@@ -175,13 +249,14 @@
 }
 
 static int sparse_init_one_section(struct mem_section *ms,
-		unsigned long pnum, struct page *mem_map)
+		unsigned long pnum, struct page *mem_map, int nid)
 {
 	if (!valid_section(ms))
 		return -EINVAL;
 
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum);
+	map_virtual_memmap(pnum, mem_map, nid);
 
 	return 1;
 }
@@ -214,10 +289,11 @@
 	page = alloc_pages(GFP_KERNEL, get_order(memmap_size));
 	if (page)
 		goto got_map_page;
-
+#ifndef CONFIG_VMEMMAP_SPARSEMEM
 	ret = vmalloc(memmap_size);
 	if (ret)
 		goto got_map_ptr;
+#endif
 
 	return NULL;
 got_map_page:
@@ -261,7 +337,8 @@
 		map = sparse_early_mem_map_alloc(pnum);
 		if (!map)
 			continue;
-		sparse_init_one_section(__nr_to_section(pnum), pnum, map);
+		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
+					sparse_early_nid(__nr_to_section(pnum)));
 	}
 }
 
@@ -296,7 +373,7 @@
 	}
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
-	ret = sparse_init_one_section(ms, section_nr, memmap);
+	ret = sparse_init_one_section(ms, section_nr, memmap, zone->zone_pgdat->node_id);
 
 out:
 	pgdat_resize_unlock(pgdat, &flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
