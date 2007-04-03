From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070403003837.829.31019.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/1] Generic Virtual Memmap suport for SPARSEMEM V2
Date: Mon,  2 Apr 2007 17:38:37 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Hansen <hansendc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Spare Virtual: Virtual Memmap support for SPARSEMEM V2

V1->V2
 - Support for PAGE_SIZE vmemmap which allows the general use of
   of virtual memmap on any MMU capable platform (enabled IA64
   support).
 - Fix various issues as suggested by Dave Hansen.
 - Add comments and error handling.

SPARSEMEM is a pretty nice framework that unifies quite a bit of
code over all the arches. It would be great if it could be the default
so that we can get rid of various forms of DISCONTIG and other variations
on memory maps. So far what has hindered this are the additional lookups
that SPARSEMEM introduces for virt_to_page and page_address. This goes
so far that the code to do this has to be kept in a separate function
and cannot be used inline.

This patch introduces virtual memmap support for sparsemem. virt_to_page
page_address and consorts become simple shift/add operations. No page flag
fields, no table lookups, nothing involving memory is required.

The two key operations pfn_to_page and page_to_page become:

#define pfn_to_page(pfn)     (vmemmap + (pfn))
#define page_to_pfn(page)    ((page) - vmemmap)

In order for this to work we will have to use a virtual mapping.
These are usually for free since kernel memory is already mapped
via a 1-1 mapping requiring a page tabld. The virtual mapping must
be big enough to span all of memory that an arch can support which
may make a virtual memmap difficult to use on 32 bit platforms
that support 36 address bits.

However, if there is enough virtual space available and the arch
already maps its 1-1 kernel space using TLBs (f.e. true of IA64
and x86_64) then this technique makes sparsemem lookups even more
effiecient than CONFIG_FLATMEM. FLATMEM still needs to read the
contents of mem_map. mem_map is constant for a virtual memory map.

Maybe this patch will allow us to make SPARSEMEM the default
configuration that will work on UP, SMP and NUMA on most platforms?
Then we may hopefully be able to remove the various forms of support
for FLATMEM, DISCONTIG etc etc.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc5-mm2/include/asm-generic/memory_model.h
===================================================================
--- linux-2.6.21-rc5-mm2.orig/include/asm-generic/memory_model.h	2007-04-02 15:13:20.000000000 -0700
+++ linux-2.6.21-rc5-mm2/include/asm-generic/memory_model.h	2007-04-02 17:15:45.000000000 -0700
@@ -46,6 +46,14 @@
 	 __pgdat->node_start_pfn;					\
 })
 
+#elif defined(CONFIG_SPARSE_VIRTUAL)
+
+/*
+ * We have a virtual memmap that makes lookups very simple
+ */
+#define __pfn_to_page(pfn)	(vmemmap + (pfn))
+#define __page_to_pfn(page)	((page) - vmemmap)
+
 #elif defined(CONFIG_SPARSEMEM)
 /*
  * Note: section's mem_map is encorded to reflect its start_pfn.
Index: linux-2.6.21-rc5-mm2/mm/sparse.c
===================================================================
--- linux-2.6.21-rc5-mm2.orig/mm/sparse.c	2007-04-02 15:58:23.000000000 -0700
+++ linux-2.6.21-rc5-mm2/mm/sparse.c	2007-04-02 17:19:13.000000000 -0700
@@ -9,6 +9,8 @@
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
 #include <asm/dma.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
 
 /*
  * Permanent SPARSEMEM data:
@@ -101,7 +103,7 @@ static inline int sparse_index_init(unsi
 
 /*
  * Although written for the SPARSEMEM_EXTREME case, this happens
- * to also work for the flat array case becase
+ * to also work for the flat array case because
  * NR_SECTION_ROOTS==NR_MEM_SECTIONS.
  */
 int __section_nr(struct mem_section* ms)
@@ -211,6 +213,214 @@ static int sparse_init_one_section(struc
 	return 1;
 }
 
+#ifdef CONFIG_SPARSE_VIRTUAL
+/*
+ * Virtual Memory Map support
+ *
+ * (C) 2007 sgi. Christoph Lameter <clameter@sgi.com>.
+ *
+ * Virtual memory maps allow VM primitives pfn_to_page, page_to_pfn,
+ * virt_to_page, page_address() etc that involve no memory accesses at all.
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
+ * CONFIG_ARCH_POPULATES_VIRTUAL_MEMMAP
+ *
+ * 	The architecture has its own functions to populate the memory
+ * 	map and provides a vmemmap_populate function.
+ *
+ * CONFIG_ARCH_SUPPORTS_PMD_MAPPING
+ *
+ * 	If not set then PAGE_SIZE mappings are generated which
+ * 	require one PTE/TLB per PAGE_SIZE chunk of the virtual memory map.
+ *
+ * 	If set then PMD_SIZE mappings are generated which are much
+ * 	lighter on the TLB. On some platforms these generate
+ * 	the same overhead as the 1-1 mappings.
+ */
+
+/*
+ * Allocate a block of memory to be used for the virtual memory map
+ * or the page tables that are used to create the mapping.
+ */
+void *vmemmap_alloc_block(unsigned long size, int node)
+{
+	if (slab_is_available()) {
+		struct page *page =
+			alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO,
+				get_order(size));
+
+		if (page)
+			return page_address(page);
+		return NULL;
+	} else {
+		void *p = __alloc_bootmem_node(NODE_DATA(node), size, size,
+				__pa(MAX_DMA_ADDRESS));
+		if (p)
+			memset(p, 0, size);
+		return p;
+	}
+}
+
+#ifndef CONFIG_ARCH_POPULATES_VIRTUAL_MEMMAP
+
+#ifndef CONFIG_ARCH_SUPPORTS_PMD_MAPPING
+
+static int vmemmap_pte_setup(pte_t *pte,  int node)
+{
+	void *block;
+	pte_t entry;
+
+	block = vmemmap_alloc_block(PAGE_SIZE, node);
+	if (!block)
+		return -ENOMEM;
+
+	entry = pfn_pte(__pa(block) >> PAGE_SHIFT, PAGE_KERNEL);
+	set_pte(pte, entry);
+	return 0;
+}
+
+static int vmemmap_pop_pte(pmd_t *pmd, unsigned long addr,
+				unsigned long end, int node)
+{
+	pte_t *pte;
+	int error = 0;
+
+	for (pte = pte_offset_map(pmd, addr); addr < end && !error;
+			pte++, addr += PAGE_SIZE)
+  		if (pte_none(*pte))
+			error =	vmemmap_pte_setup(pte, node);
+	return error;
+}
+
+#else /* CONFIG_ARCH_SUPPORTS_PMD_MAPPING */
+
+static int vmemmap_pmd_setup(pmd_t *pmd, int node)
+{
+	void *block;
+	pte_t entry;
+
+	block = vmemmap_alloc_block(PMD_SIZE, node);
+	if (!block)
+		return -ENOMEM;
+
+	entry = pfn_pte(__pa(block) >> PAGE_SHIFT, PAGE_KERNEL);
+	mk_pte_huge(entry);
+	set_pmd(pmd, __pmd(pte_val(entry)));
+	return 0;
+}
+
+static int vmemmap_pop_pte(pmd_t *pmd, unsigned long addr,
+				unsigned long end, int node)
+{
+	return 0;
+}
+#endif /* CONFIG_ARCH_SUPPORTS_PMD_MAPPING */
+
+static int vmemmap_pop_pmd(pud_t *pud, unsigned long addr,
+				unsigned long end, int node)
+{
+	pmd_t *pmd;
+	int error = 0;
+
+	end = pmd_addr_end(addr, end);
+
+	for (pmd = pmd_offset(pud, addr); addr < end && !error;
+			pmd++, addr += PMD_SIZE) {
+  		if (pmd_none(*pmd)) {
+#ifdef CONFIG_ARCH_SUPPORTS_PMD_MAPPING
+				error = vmemmap_pmd_setup(pmd, node);
+#else
+				void *p =
+					vmemmap_alloc_block(PAGE_SIZE, node);
+
+				if (!p)
+					return -ENOMEM;
+
+				pmd_populate_kernel(&init_mm, pmd, p);
+#endif
+		}
+		error = vmemmap_pop_pte(pmd, addr, end, node);
+	}
+	return error;
+}
+
+static int vmemmap_pop_pud(pgd_t *pgd, unsigned long addr,
+					unsigned long end, int node)
+{
+	pud_t *pud;
+	int error = 0;
+
+	end = pud_addr_end(addr, end);
+	for (pud = pud_offset(pgd, addr); addr < end && !error;
+				pud++, addr += PUD_SIZE) {
+
+		if (pud_none(*pud)) {
+			void *p =
+				vmemmap_alloc_block(PAGE_SIZE, node);
+
+			if (!p)
+				return -ENOMEM;
+
+			pud_populate(&init_mm, pud, p);
+		}
+		error = vmemmap_pop_pmd(pud, addr, end, node);
+	}
+	return error;
+}
+
+int vmemmap_populate(struct page *start_page, unsigned long nr,
+								int node)
+{
+	pgd_t *pgd;
+	unsigned long addr = (unsigned long)start_page;
+	unsigned long end = pgd_addr_end(addr,
+			(unsigned long)(start_page + nr));
+	int error = 0;
+
+	for (pgd = pgd_offset_k(addr); addr < end && !error;
+				pgd++, addr += PGDIR_SIZE) {
+
+		if (pgd_none(*pgd)) {
+			void *p =
+				vmemmap_alloc_block(PAGE_SIZE, node);
+
+			pgd_populate(&init_mm, pgd, p);
+		}
+		error = vmemmap_pop_pud(pgd, addr, end, node);
+	}
+	return error;
+}
+#endif /* !CONFIG_ARCH_POPULATES_VIRTUAL_MEMMAP */
+
+static struct page *sparse_early_mem_map_alloc(unsigned long pnum)
+{
+	struct page *map;
+	struct mem_section *ms = __nr_to_section(pnum);
+	int nid = sparse_early_nid(ms);
+	int error;
+
+	map = pfn_to_page(pnum * PAGES_PER_SECTION);
+	error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
+
+	if (error) {
+		printk(KERN_ERR "%s: allocation failed. Error=%d\n",
+				__FUNCTION__, error);
+		ms->section_mem_map = 0;
+		return NULL;
+	}
+	return map;
+}
+
+#else /* CONFIG_SPARSE_VIRTUAL */
+
 static struct page *sparse_early_mem_map_alloc(unsigned long pnum)
 {
 	struct page *map;
@@ -231,6 +441,8 @@ static struct page *sparse_early_mem_map
 	return NULL;
 }
 
+#endif /* CONFIG_SPARSE_VIRTUAL */
+
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 {
 	struct page *page, *ret;
Index: linux-2.6.21-rc5-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.21-rc5-mm2.orig/include/linux/mmzone.h	2007-04-02 15:58:23.000000000 -0700
+++ linux-2.6.21-rc5-mm2/include/linux/mmzone.h	2007-04-02 16:15:44.000000000 -0700
@@ -836,6 +836,8 @@ void sparse_init(void);
 
 void memory_present(int nid, unsigned long start, unsigned long end);
 unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
+int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
+void *vmemmap_alloc_block(unsigned long size, int node);
 
 /*
  * If it is possible to have holes within a MAX_ORDER_NR_PAGES, then we

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
