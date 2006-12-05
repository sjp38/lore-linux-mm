Date: Tue, 5 Dec 2006 21:53:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] vmemmap on sparsemem v2 [2/5] memory hotplug support
Message-Id: <20061205215315.fb6ad320.kamezawa.hiroyu@jp.fujitsu.com>
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

This patch is for memory hotplug support with sparsemem_vmemmap.
Implements on-demand mem_map allocation and unmap routine (used at
rollback from allocation failure now)
Not so complicated.

This patch defines 'only for vmem_map unmap routine. looks not good.
But there is no routine to free mapped page at unmap (for kernel).
And I'm thinking of allocating mem_map for hot-added section from itself,
some special page.
When I find cleaner way, I'll fix this.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Index: devel-2.6.19-rc6-mm2/mm/sparse.c
===================================================================
--- devel-2.6.19-rc6-mm2.orig/mm/sparse.c	2006-12-05 19:45:52.000000000 +0900
+++ devel-2.6.19-rc6-mm2/mm/sparse.c	2006-12-05 19:48:48.000000000 +0900
@@ -10,6 +10,7 @@
 #include <linux/vmalloc.h>
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
+#include <asm/tlbflush.h>
 
 /*
  * Permanent SPARSEMEM data:
@@ -103,22 +104,30 @@
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 
-static void* __init pte_alloc_vmem_map(int node)
+static void* __meminit pte_alloc_vmem_map(int node)
 {
-	return alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE);
+	struct page *page;
+	if (system_state == SYSTEM_BOOTING)
+		return alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE);
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_ZERO, 0);
+	if (!page)
+		return NULL;
+	return page_address(page);
 }
 
 /*
  * We can expect mem_map in section is always contigous.
  */
 static unsigned long
-__init sparse_phys_mem_map_get(unsigned long section,
-				    unsigned long vmap,
-				    int node)
+__meminit sparse_phys_mem_map_get(unsigned long section,
+				       unsigned long vmap,
+				       int node)
 {
 	struct mem_section *ms = __nr_to_section(section);
 	unsigned long map = ms->section_mem_map & SECTION_MAP_MASK;
 	unsigned long vmap_start;
+	struct page *page;
 
 	vmap_start = (unsigned long)pfn_to_page(section_nr_to_pfn(section));
 
@@ -130,7 +139,11 @@
 		map = __pa(map);
 		return (map >> PAGE_SHIFT) + offset;
 	}
-	BUG(); /* handled by memory hotplug */
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_ZERO, 0);
+	if (!page)
+		return 0;
+	return page_to_pfn(page);
 }
 
 /*
@@ -190,6 +203,81 @@
 	return -ENOMEM;
 }
 
+/*
+ * This function does the same ops as vumamp() except for freeing pages.
+ */
+static void
+unmap_virtual_mem_map_pte(pmd_t *pmd, unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+	unsigned long pfn;
+	struct page *page;
+	pte = pte_offset_kernel(pmd, addr);
+	do {
+		WARN_ON(!pte_none(*pte) && !pte_present(*pte));
+		pfn = pte_pfn(*pte);
+		page = pfn_to_page(pfn);
+		if (!PageReserved(page)) {
+			pte_clear(&init_mm, addr, pte);
+			__free_page(page);
+		} else {
+			/* allocated at boot, never reach here until
+			   memory hot-unplug is implemnted. */
+			BUG();
+		}
+	} while(pte++, addr += PAGE_SIZE, addr != end);
+}
+
+static void
+unmap_virutal_mem_map_pmd(pud_t *pud, unsigned long addr, unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		unmap_virtual_mem_map_pte(pmd, addr, next);
+	} while (pmd++, addr = next, addr != end);
+}
+static void
+unmap_virtual_mem_map_pud(pgd_t *pgd, unsigned long addr,unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		unmap_virutal_mem_map_pmd(pud, addr, next);
+	} while (pud++, addr = next, addr != end);
+}
+
+static void unmap_virtual_mem_map(int section)
+{
+	unsigned long start_addr, addr, end_addr, next;
+	unsigned long size = PAGES_PER_SECTION * sizeof(struct page);
+	pgd_t *pgd;
+	start_addr = (unsigned long)pfn_to_page(section_nr_to_pfn(section));
+	end_addr = start_addr + size;
+	addr = start_addr;
+
+	pgd = pgd_offset_k(start_addr);
+	flush_cache_vunmap(start_addr, end_addr);
+	do {
+		next = pgd_addr_end(addr, end_addr);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		unmap_virtual_mem_map_pud(pgd, addr, next);
+	}while(pgd++, addr = next, addr != end_addr);
+	flush_tlb_kernel_range((unsigned long)start_addr, end_addr);
+
+	return;
+}
+
 #else
 
 static inline int map_virtual_mem_map(int section, int node)
@@ -328,6 +416,18 @@
 	return NULL;
 }
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
+{
+	/* we allocate mem_map later */
+	return NULL;
+}
+static void __kfree_section_memmap(int section_nr,
+				   struct page *memmap, unsigned long nr_pages)
+{
+	unmap_virtual_mem_map(section_nr);
+}
+#else
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 {
 	struct page *page, *ret;
@@ -358,7 +458,8 @@
 	return 0;
 }
 
-static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
+static void __kfree_section_memmap(int section_nr,
+			struct page *memmap, unsigned long nr_pages)
 {
 	if (vaddr_in_vmalloc_area(memmap))
 		vfree(memmap);
@@ -366,7 +467,7 @@
 		free_pages((unsigned long)memmap,
 			   get_order(sizeof(struct page) * nr_pages));
 }
-
+#endif
 /*
  * Allocate the accumulated non-linear sections, allocate a mem_map
  * for each and record the physical to section mapping.
@@ -424,6 +525,6 @@
 out:
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret <= 0)
-		__kfree_section_memmap(memmap, nr_pages);
+		__kfree_section_memmap(section_nr, memmap, nr_pages);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
