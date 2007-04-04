From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/4] Generic Virtual Memmap suport for SPARSEMEM V3
Date: Wed,  4 Apr 2007 16:06:19 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Hansen <hansendc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Sparse Virtual: Virtual Memmap support for SPARSEMEM V4

V1->V3
 - Add IA64 16M vmemmap size support (reduces TLB pressure)
 - Add function to test for eventual node/node vmemmap overlaps
 - Upper / Lower boundary fix.

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

Index: linux-2.6.21-rc5-mm4/include/asm-generic/memory_model.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/asm-generic/memory_model.h	2007-04-04 15:45:48.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/asm-generic/memory_model.h	2007-04-04 15:45:52.000000000 -0700
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
Index: linux-2.6.21-rc5-mm4/mm/sparse.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/sparse.c	2007-04-04 15:45:48.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/sparse.c	2007-04-04 15:48:11.000000000 -0700
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
@@ -211,6 +213,253 @@ static int sparse_init_one_section(struc
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
+static int vmemmap_verify(pte_t *pte, int node,
+		unsigned long start, unsigned long end)
+{
+	unsigned long pfn = pte_pfn(*pte);
+	int actual_node = early_pfn_to_nid(pfn);
+
+	if (actual_node != node)
+		printk(KERN_WARNING "[%lx-%lx] potential offnode page_structs\n",
+			start, end - 1);
+	return 0;
+}
+
+#ifndef CONFIG_ARCH_SUPPORTS_PMD_MAPPING
+
+#define VIRTUAL_MEMMAP_SIZE PAGE_SIZE
+#define VIRTUAL_MEMMAP_MASK PAGE_MASK
+
+static int vmemmap_pte_setup(pte_t *pte,  int node, unsigned long addr)
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
+	addr &= ~(PAGE_SIZE - 1);
+	printk(KERN_INFO "[%lx-%lx] PTE ->%p on node %d\n",
+		addr, addr + PAGE_SIZE -1, block, node);
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
+			error =	vmemmap_pte_setup(pte, node, addr);
+		else
+			error = vmemmap_verify(pte, node,
+				addr + PAGE_SIZE, end);
+	return error;
+}
+
+static int vmemmap_pmd_setup(pmd_t *pmd, int node)
+{
+	void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+
+	if (!p)
+		return -ENOMEM;
+
+	pmd_populate_kernel(&init_mm, pmd, p);
+	return 0;
+}
+
+#else /* CONFIG_ARCH_SUPPORTS_PMD_MAPPING */
+
+#define VIRTUAL_MEMMAP_SIZE PMD_SIZE
+#define VIRTUAL_MEMMAP_MASK PMD_MASK
+
+static int vmemmap_pop_pte(pmd_t *pmd, unsigned long addr,
+				unsigned long end, int node)
+{
+	return 0;
+}
+
+static int vmemmap_pmd_setup(pmd_t *pmd, int node, unsigned long addr)
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
+	addr &= ~(PMD_SIZE - 1);
+	printk(KERN_INFO " [%lx-%lx] PMD ->%p on node %d\n",
+		addr, addr + PMD_SIZE - 1, block, node);
+	return 0;
+}
+
+#endif /* CONFIG_ARCH_SUPPORTS_PMD_MAPPING */
+
+static int vmemmap_pop_pmd(pud_t *pud, unsigned long addr,
+				unsigned long end, int node)
+{
+	pmd_t *pmd;
+	int error = 0;
+
+	for (pmd = pmd_offset(pud, addr); addr < end && !error;
+			pmd++, addr += PMD_SIZE) {
+  		if (pmd_none(*pmd))
+			error = vmemmap_pmd_setup(pmd, node, addr);
+		else
+			error = vmemmap_verify((pte_t *)pmd, node,
+				pmd_addr_end(addr, end), end);
+
+		if (!error)
+			error = vmemmap_pop_pte(pmd, addr,
+				pmd_addr_end(addr, end), node);
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
+		error = vmemmap_pop_pmd(pud, addr,
+			pud_addr_end(addr, end), node);
+	}
+	return error;
+}
+
+int vmemmap_populate(struct page *start_page, unsigned long nr,
+								int node)
+{
+	pgd_t *pgd;
+	unsigned long addr = (unsigned long)start_page & VIRTUAL_MEMMAP_MASK;
+	unsigned long end =
+		((unsigned long)(start_page + nr) & VIRTUAL_MEMMAP_MASK)
+				+ VIRTUAL_MEMMAP_SIZE;
+	int error = 0;
+
+	printk(KERN_INFO "[%lx-%lx] Virtual memory section"
+		" (%ld pages) node %d\n",
+		(unsigned long)start_page,
+		(unsigned long)(start_page + nr) - 1, nr, node);
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
+		error = vmemmap_pop_pud(pgd, addr,
+			pgd_addr_end(addr, end), node);
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
@@ -231,6 +480,8 @@ static struct page *sparse_early_mem_map
 	return NULL;
 }
 
+#endif /* !CONFIG_SPARSE_VIRTUAL */
+
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 {
 	struct page *page, *ret;
Index: linux-2.6.21-rc5-mm4/include/linux/mmzone.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/linux/mmzone.h	2007-04-04 15:45:48.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/linux/mmzone.h	2007-04-04 15:45:52.000000000 -0700
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
