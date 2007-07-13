From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/7] Generic Virtual Memmap support for SPARSEMEM
References: <exportbomb.1184333503@pinky>
Message-Id: <E1I9LJY-00006o-GK@hellhawk.shadowen.org>
Date: Fri, 13 Jul 2007 14:36:08 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

SPARSEMEM is a pretty nice framework that unifies quite a bit of
code over all the arches. It would be great if it could be the
default so that we can get rid of various forms of DISCONTIG and
other variations on memory maps. So far what has hindered this are
the additional lookups that SPARSEMEM introduces for virt_to_page
and page_address. This goes so far that the code to do this has to
be kept in a separate function and cannot be used inline.

This patch introduces a virtual memmap mode for SPARSEMEM, in which
the memmap is mapped into a virtually contigious area, only the
active sections are physically backed.  This allows virt_to_page
page_address and cohorts become simple shift/add operations.
No page flag fields, no table lookups, nothing involving memory
is required.

The two key operations pfn_to_page and page_to_page become:

   #define __pfn_to_page(pfn)      (vmemmap + (pfn))
   #define __page_to_pfn(page)     ((page) - vmemmap)

By having a virtual mapping for the memmap we allow simple access
without wasting physical memory.  As kernel memory is typically
already mapped 1:1 this introduces no additional overhead.
The virtual mapping must be big enough to allow a struct page to
be allocated and mapped for all valid physical pages.  This vill
make a virtual memmap difficult to use on 32 bit platforms that
support 36 address bits.

However, if there is enough virtual space available and the arch
already maps its 1-1 kernel space using TLBs (f.e. true of IA64
and x86_64) then this technique makes SPARSEMEM lookups even more
efficient than CONFIG_FLATMEM.  FLATMEM needs to read the contents
of the mem_map variable to get the start of the memmap and then add
the offset to the required entry.  vmemmap is a constant to which
we can simply add the offset.

This patch has the potential to allow us to make SPARSMEM the default
(and even the only) option for most systems.  It should be optimal
on UP, SMP and NUMA on most platforms.  Then we may even be able
to remove the other memory models: FLATMEM, DISCONTIG etc.

[apw@shadowen.org: config cleanups, resplit code etc]
From: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/include/asm-generic/memory_model.h b/include/asm-generic/memory_model.h
index 30d8d33..52226e1 100644
--- a/include/asm-generic/memory_model.h
+++ b/include/asm-generic/memory_model.h
@@ -46,6 +46,12 @@
 	 __pgdat->node_start_pfn;					\
 })
 
+#elif defined(CONFIG_SPARSEMEM_VMEMMAP)
+
+/* memmap is virtually contigious.  */
+#define __pfn_to_page(pfn)	(vmemmap + (pfn))
+#define __page_to_pfn(page)	((page) - vmemmap)
+
 #elif defined(CONFIG_SPARSEMEM)
 /*
  * Note: section's mem_map is encorded to reflect its start_pfn.
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 69f4210..e9d8c32 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1261,5 +1261,10 @@ extern int randomize_va_space;
 
 __attribute__((weak)) const char *arch_vma_name(struct vm_area_struct *vma);
 
+int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
+int vmemmap_populate_pmd(pud_t *, unsigned long, unsigned long, int);
+void *vmemmap_alloc_block(unsigned long size, int node);
+void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/mm/sparse.c b/mm/sparse.c
index d6678ab..5cc6e74 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -9,6 +9,8 @@
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
 #include <asm/dma.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
 
 /*
  * Permanent SPARSEMEM data:
@@ -218,6 +220,192 @@ void *alloc_bootmem_high_node(pg_data_t *pgdat, unsigned long size)
 	return NULL;
 }
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+/*
+ * Virtual Memory Map support
+ *
+ * (C) 2007 sgi. Christoph Lameter <clameter@sgi.com>.
+ *
+ * Virtual memory maps allow VM primitives pfn_to_page, page_to_pfn,
+ * virt_to_page, page_address() to be implemented as a base offset
+ * calculation without memory access.
+ *
+ * However, virtual mappings need a page table and TLBs. Many Linux
+ * architectures already map their physical space using 1-1 mappings
+ * via TLBs. For those arches the virtual memmory map is essentially
+ * for free if we use the same page size as the 1-1 mappings. In that
+ * case the overhead consists of a few additional pages that are
+ * allocated to create a view of memory for vmemmap.
+ *
+ * Special Kconfig settings:
+ *
+ * CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
+ *
+ * 	The architecture has its own functions to populate the memory
+ * 	map and provides a vmemmap_populate function.
+ *
+ * CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD
+ *
+ * 	The architecture provides functions to populate the pmd level
+ * 	of the vmemmap mappings.  Allowing mappings using large pages
+ * 	where available.
+ *
+ * 	If neither are set then PAGE_SIZE mappings are generated which
+ * 	require one PTE/TLB per PAGE_SIZE chunk of the virtual memory map.
+ */
+
+/*
+ * Allocate a block of memory to be used to back the virtual memory map
+ * or to back the page tables that are used to create the mapping.
+ * Uses the main allocators if they are available, else bootmem.
+ */
+void * __meminit vmemmap_alloc_block(unsigned long size, int node)
+{
+	/* If the main allocator is up use that, fallback to bootmem. */
+	if (slab_is_available()) {
+		struct page *page = alloc_pages_node(node,
+				GFP_KERNEL | __GFP_ZERO, get_order(size));
+		if (page)
+			return page_address(page);
+		return NULL;
+	} else
+		return __alloc_bootmem_node(NODE_DATA(node), size, size,
+				__pa(MAX_DMA_ADDRESS));
+}
+
+#ifndef CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
+void __meminit vmemmap_verify(pte_t *pte, int node,
+				unsigned long start, unsigned long end)
+{
+	unsigned long pfn = pte_pfn(*pte);
+	int actual_node = early_pfn_to_nid(pfn);
+
+	if (actual_node != node)
+		printk(KERN_WARNING "[%lx-%lx] potential offnode "
+			"page_structs\n", start, end - 1);
+}
+
+#ifndef CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD
+static int __meminit vmemmap_populate_pte(pmd_t *pmd, unsigned long addr,
+					unsigned long end, int node)
+{
+	pte_t *pte;
+
+	for (pte = pte_offset_map(pmd, addr); addr < end;
+						pte++, addr += PAGE_SIZE)
+		if (pte_none(*pte)) {
+			pte_t entry;
+			void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+			if (!p)
+				return -ENOMEM;
+
+			entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);
+			set_pte(pte, entry);
+
+			printk(KERN_DEBUG "[%lx-%lx] PTE ->%p on node %d\n",
+				addr, addr + PAGE_SIZE - 1, p, node);
+
+		} else
+			vmemmap_verify(pte, node, addr + PAGE_SIZE, end);
+
+	return 0;
+}
+
+int __meminit vmemmap_populate_pmd(pud_t *pud, unsigned long addr,
+						unsigned long end, int node)
+{
+	pmd_t *pmd;
+	int error = 0;
+
+	for (pmd = pmd_offset(pud, addr); addr < end && !error;
+						pmd++, addr += PMD_SIZE) {
+		if (pmd_none(*pmd)) {
+			void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+			if (!p)
+				return -ENOMEM;
+
+			pmd_populate_kernel(&init_mm, pmd, p);
+		} else
+			vmemmap_verify((pte_t *)pmd, node,
+					pmd_addr_end(addr, end), end);
+
+		error = vmemmap_populate_pte(pmd, addr,
+					pmd_addr_end(addr, end), node);
+	}
+	return error;
+}
+#endif /* CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD */
+
+static int __meminit vmemmap_populate_pud(pgd_t *pgd, unsigned long addr,
+						unsigned long end, int node)
+{
+	pud_t *pud;
+	int error = 0;
+
+	for (pud = pud_offset(pgd, addr); addr < end && !error;
+						pud++, addr += PUD_SIZE) {
+		if (pud_none(*pud)) {
+			void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+			if (!p)
+				return -ENOMEM;
+
+			pud_populate(&init_mm, pud, p);
+		}
+		error = vmemmap_populate_pmd(pud, addr,
+					pud_addr_end(addr, end), node);
+	}
+	return error;
+}
+
+int __meminit vmemmap_populate(struct page *start_page,
+						unsigned long nr, int node)
+{
+	pgd_t *pgd;
+	unsigned long addr = (unsigned long)start_page;
+	unsigned long end = (unsigned long)(start_page + nr);
+	int error = 0;
+
+	printk(KERN_DEBUG "[%lx-%lx] Virtual memory section"
+		" (%ld pages) node %d\n", addr, end - 1, nr, node);
+
+	for (pgd = pgd_offset_k(addr); addr < end && !error;
+					pgd++, addr += PGDIR_SIZE) {
+		if (pgd_none(*pgd)) {
+			void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+			if (!p)
+				return -ENOMEM;
+
+			pgd_populate(&init_mm, pgd, p);
+		}
+		error = vmemmap_populate_pud(pgd, addr,
+					pgd_addr_end(addr, end), node);
+	}
+	return error;
+}
+#endif /* !CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP */
+
+static struct page * __init sparse_early_mem_map_alloc(unsigned long pnum)
+{
+	struct page *map;
+	struct mem_section *ms = __nr_to_section(pnum);
+	int nid = sparse_early_nid(ms);
+	int error;
+
+	map = pfn_to_page(pnum * PAGES_PER_SECTION);
+	error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
+	if (error) {
+		printk(KERN_ERR "%s: allocation failed. Error=%d\n",
+							__FUNCTION__, error);
+		printk(KERN_ERR "%s: virtual memory map backing failed "
+			"some memory will not be available.\n", __FUNCTION__);
+		ms->section_mem_map = 0;
+		return NULL;
+	}
+	return map;
+}
+
+#else /* CONFIG_SPARSEMEM_VMEMMAP */
+
 static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 {
 	struct page *map;
@@ -242,6 +430,7 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 	ms->section_mem_map = 0;
 	return NULL;
 }
+#endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
 static unsigned long usemap_size(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
