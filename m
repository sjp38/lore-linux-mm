Date: Tue, 5 Dec 2006 21:49:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] vmemmap on sparsemem v2 [1/5] generic vmemmap on
 sparsemem
Message-Id: <20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

This patch implements arch-independent-part of virtuam mem_map for sparsemem.
memory-hotplug is not supproted. (supported by later patch.)

Declarations which an arch has to add to use vmem_map/sparsemem is

* declare 'struct page *vmem_map or vmem_map[] and setup its value.
* set ARCH_SPARSEMEM_VMEMMAP in Kconfig

maybe asm/sparsemem.h is suitable as ia64 patch(later) does.

We can assume that total size of mem_map per section is aligned to PAGE_SIZE.
By this, pfn_valid()(of sparsemem) works fine.

This code has its own page-mapping routine just because it has to be called
before page struct is available.

Consideration:
I know some people tries to use large page for vmem_map. It seems attractive
but this patch doesn't support hooks for that.
Maybe rewriting map_virtual_mem_map() is enough. (if you doesn't consider
memory hotplug.)
IMO, generic interface to map large pages in the kernel should be discussed
before doing such special hack.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/mmzone.h |    8 +++
 mm/Kconfig             |    9 ++++
 mm/sparse.c            |  101 ++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 113 insertions(+), 5 deletions(-)

Index: devel-2.6.19-rc6-mm2/mm/Kconfig
===================================================================
--- devel-2.6.19-rc6-mm2.orig/mm/Kconfig	2006-12-05 17:24:30.000000000 +0900
+++ devel-2.6.19-rc6-mm2/mm/Kconfig	2006-12-05 17:24:58.000000000 +0900
@@ -112,6 +112,15 @@
 	def_bool y
 	depends on SPARSEMEM && !SPARSEMEM_STATIC
 
+config SPARSEMEM_VMEMMAP
+	bool	"virtual memmap support for sparsemem"
+	depends on SPARSEMEM && !SPARSEMEM_STATIC && ARCH_SPARSEMEM_VMEMMAP
+	help
+	  If selected, sparsemem uses virtually contiguous address for mem_map.
+	  Some functions of sparsemem (pfn_to_page/page_to_pfn) can be very
+	  very simple and fast. But this will consume huge amount of virtual
+	  address space.
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
Index: devel-2.6.19-rc6-mm2/include/linux/mmzone.h
===================================================================
--- devel-2.6.19-rc6-mm2.orig/include/linux/mmzone.h	2006-12-05 17:24:28.000000000 +0900
+++ devel-2.6.19-rc6-mm2/include/linux/mmzone.h	2006-12-05 19:53:41.000000000 +0900
@@ -714,12 +714,23 @@
 #define SECTION_MAP_MASK	(~(SECTION_MAP_LAST_BIT-1))
 #define SECTION_NID_SHIFT	2
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+/*
+ * sparse_vmem_map_start is defined by each arch.
+ * vmem_map is declared by each arch.
+ */
+static inline struct page *__section_mem_map_addr(struct mem_section *section)
+{
+	return vmem_map;
+}
+#else
 static inline struct page *__section_mem_map_addr(struct mem_section *section)
 {
 	unsigned long map = section->section_mem_map;
 	map &= SECTION_MAP_MASK;
 	return (struct page *)map;
 }
+#endif
 
 static inline int valid_section(struct mem_section *section)
 {
Index: devel-2.6.19-rc6-mm2/mm/sparse.c
===================================================================
--- devel-2.6.19-rc6-mm2.orig/mm/sparse.c	2006-12-05 17:24:30.000000000 +0900
+++ devel-2.6.19-rc6-mm2/mm/sparse.c	2006-12-05 19:53:13.000000000 +0900
@@ -9,6 +9,7 @@
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
 #include <asm/dma.h>
+#include <asm/pgalloc.h>
 
 /*
  * Permanent SPARSEMEM data:
@@ -99,6 +100,105 @@
 }
 #endif
 
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+
+static void* __init pte_alloc_vmem_map(int node)
+{
+	return alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE);
+}
+
+/*
+ * We can expect mem_map in section is always contigous.
+ */
+static unsigned long
+__init sparse_phys_mem_map_get(unsigned long section,
+				    unsigned long vmap,
+				    int node)
+{
+	struct mem_section *ms = __nr_to_section(section);
+	unsigned long map = ms->section_mem_map & SECTION_MAP_MASK;
+	unsigned long vmap_start;
+
+	vmap_start = (unsigned long)pfn_to_page(section_nr_to_pfn(section));
+
+	if (system_state == SYSTEM_BOOTING) {
+		unsigned long offset;
+		map = (unsigned long)((struct page*)(map) +
+				       section_nr_to_pfn(section));
+		offset = (vmap - vmap_start) >> PAGE_SHIFT;
+		map = __pa(map);
+		return (map >> PAGE_SHIFT) + offset;
+	}
+	BUG(); /* handled by memory hotplug */
+}
+
+/*
+ * map_pos(section,offset) returns pfn of physical address of mem_map
+ * in section at index. (see boot_memmap_pos()).
+ * Returns 1 if succeed.
+ */
+static int __meminit map_virtual_mem_map(unsigned long section, int node)
+{
+	unsigned long vmap_start, vmap_end, vmap;
+	void *pg;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	vmap_start = (unsigned long)pfn_to_page(section_nr_to_pfn(section));
+	vmap_end = vmap_start + PAGES_PER_SECTION * sizeof(struct page);
+
+	for (vmap = vmap_start;
+	     vmap != vmap_end;
+	     vmap += PAGE_SIZE)
+	{
+		pgd = pgd_offset_k(vmap);
+		if (pgd_none(*pgd)) {
+			pg = pte_alloc_vmem_map(node);
+			if (!pg)
+				goto error_out;
+			pgd_populate(&init_mm, pgd, pg);
+		}
+		pud = pud_offset(pgd, vmap);
+		if (pud_none(*pud)) {
+			pg = pte_alloc_vmem_map(node);
+			if (!pg)
+				goto error_out;
+			pud_populate(&init_mm, pud, pg);
+		}
+		pmd = pmd_offset(pud, vmap);
+		if (pmd_none(*pmd)) {
+			pg = pte_alloc_vmem_map(node);
+			if (!pg)
+				goto error_out;
+			pmd_populate_kernel(&init_mm, pmd, pg);
+		}
+		pte = pte_offset_kernel(pmd, vmap);
+		if (pte_none(*pte)) {
+			unsigned long pfn;
+			pfn = sparse_phys_mem_map_get(section, vmap, node);
+			if (!pfn)
+				goto error_out;
+			set_pte(pte, pfn_pte(pfn, PAGE_KERNEL));
+		}
+	}
+	flush_cache_vmap(vmap_start, vmap_end);
+	return 1;
+error_out:
+	return -ENOMEM;
+}
+
+#else
+
+static inline int map_virtual_mem_map(int section, int node)
+{
+	return 1;
+}
+
+#endif
+
 /*
  * Although written for the SPARSEMEM_EXTREME case, this happens
  * to also work for the flat array case becase
@@ -198,15 +298,14 @@
 }
 
 static int sparse_init_one_section(struct mem_section *ms,
-		unsigned long pnum, struct page *mem_map)
+		unsigned long pnum, struct page *mem_map, int nid)
 {
 	if (!valid_section(ms))
 		return -EINVAL;
 
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum);
-
-	return 1;
+	return map_virtual_mem_map(pnum, nid);
 }
 
 static struct page *sparse_early_mem_map_alloc(unsigned long pnum)
@@ -284,7 +383,8 @@
 		map = sparse_early_mem_map_alloc(pnum);
 		if (!map)
 			continue;
-		sparse_init_one_section(__nr_to_section(pnum), pnum, map);
+		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
+				sparse_early_nid(__nr_to_section(pnum)));
 	}
 }
 
@@ -319,7 +419,7 @@
 	}
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
-	ret = sparse_init_one_section(ms, section_nr, memmap);
+	ret = sparse_init_one_section(ms, section_nr, memmap, pgdat->node_id);
 
 out:
 	pgdat_resize_unlock(pgdat, &flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
