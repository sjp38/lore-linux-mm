From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/2] Generic Virtual Memmap suport for SPARSEMEM
Date: Sat, 31 Mar 2007 23:10:24 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Spare Virtual: Virtual Memmap support for SPARSEMEM

SPARSEMEM is a pretty nice framework that unifies quite a bit of
code over all the arches. It would be great if it could be the default
so that we can get rid of various forms of DISCONTIG and other variations
on memory maps. So far what has hindered this are the additional lookups
that SPARSEMEM introduces for virt_to_page and page_address. This goes
so far that the code to do this has to be kept in a separate function
and cannot be used inline.

This patch introduces virtual memmap support for sparsemem. virt_to_page
page_address and consorts become simple shift/add operations. No page flag
fields, no table lookups nothing involving memory is required.

The two key operations pfn_to_page and page_to_page become:

#define pfn_to_page(pfn)     (vmemmap + (pfn))
#define page_to_pfn(page)    ((page) - vmemmap)

In order for this to work we will have to use a virtual mapping.
These are usually for free since kernel memory is already mapped
via a 1-1 mapping requiring a page tabld. The virtual mapping must
be big enough to span all of memory that an arch support which may
make a virtual memmap difficult to use on funky 32 bit platforms
that support 36 address bits.

However, if there is enough virtual space available and the arch
already maps its 1-1 kernel space using TLBs (f.e. true of IA64
and x86_64) then this technique makes sparsemem lookups as efficient
as CONFIG_FLATMEM.

Maybe this patch will allow us to make SPARSEMEM the default
configuration that will work on UP, SMP and NUMA on most platforms?
Then we may hopefully be able to remove the various forms of support
for FLATMEM, DISCONTIG etc etc.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc5-mm2/include/asm-generic/memory_model.h
===================================================================
--- linux-2.6.21-rc5-mm2.orig/include/asm-generic/memory_model.h	2007-03-31 22:47:14.000000000 -0700
+++ linux-2.6.21-rc5-mm2/include/asm-generic/memory_model.h	2007-03-31 22:59:35.000000000 -0700
@@ -47,6 +47,13 @@
 })
 
 #elif defined(CONFIG_SPARSEMEM)
+#ifdef CONFIG_SPARSE_VIRTUAL
+/*
+ * We have a virtual memmap that makes lookups very simple
+ */
+#define __pfn_to_page(pfn)	(vmemmap + (pfn))
+#define __page_to_pfn(page)	((page) - vmemmap)
+#else
 /*
  * Note: section's mem_map is encorded to reflect its start_pfn.
  * section[i].section_mem_map == mem_map's address - start_pfn;
@@ -62,6 +69,7 @@
 	struct mem_section *__sec = __pfn_to_section(__pfn);	\
 	__section_mem_map_addr(__sec) + __pfn;		\
 })
+#endif
 #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
 
 #ifdef CONFIG_OUT_OF_LINE_PFN_TO_PAGE
Index: linux-2.6.21-rc5-mm2/mm/sparse.c
===================================================================
--- linux-2.6.21-rc5-mm2.orig/mm/sparse.c	2007-03-31 22:47:14.000000000 -0700
+++ linux-2.6.21-rc5-mm2/mm/sparse.c	2007-03-31 22:59:35.000000000 -0700
@@ -9,6 +9,7 @@
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
 #include <asm/dma.h>
+#include <asm/pgalloc.h>
 
 /*
  * Permanent SPARSEMEM data:
@@ -101,7 +102,7 @@ static inline int sparse_index_init(unsi
 
 /*
  * Although written for the SPARSEMEM_EXTREME case, this happens
- * to also work for the flat array case becase
+ * to also work for the flat array case because
  * NR_SECTION_ROOTS==NR_MEM_SECTIONS.
  */
 int __section_nr(struct mem_section* ms)
@@ -211,6 +212,90 @@ static int sparse_init_one_section(struc
 	return 1;
 }
 
+#ifdef CONFIG_SPARSE_VIRTUAL
+
+void *vmemmap_alloc_block(unsigned long size, int node)
+{
+	if (slab_is_available()) {
+		struct page *page =
+			alloc_pages_node(node, GFP_KERNEL,
+				get_order(size));
+
+		BUG_ON(!page);
+		return page_address(page);
+	} else
+		return __alloc_bootmem_node(NODE_DATA(node), size, size,
+					__pa(MAX_DMA_ADDRESS));
+}
+
+
+#ifndef ARCH_POPULATES_VIRTUAL_MEMMAP
+/*
+ * Virtual memmap populate functionality for architectures that support
+ * PMDs for huge pages like i386, x86_64 etc.
+ */
+static void vmemmap_pop_pmd(pud_t *pud, unsigned long addr,
+				unsigned long end, int node)
+{
+	pmd_t *pmd;
+
+	end = pmd_addr_end(addr, end);
+
+	for (pmd = pmd_offset(pud, addr); addr < end;
+			pmd++, addr += PMD_SIZE) {
+  		if (pmd_none(*pmd)) {
+  			void *block;
+			pte_t pte;
+
+			block = vmemmap_alloc_block(PMD_SIZE, node);
+			pte = pfn_pte(__pa(block) >> PAGE_SHIFT,
+						PAGE_KERNEL);
+			pte_mkdirty(pte);
+			pte_mkwrite(pte);
+			pte_mkyoung(pte);
+			mk_pte_huge(pte);
+			set_pmd(pmd, __pmd(pte_val(pte)));
+		}
+	}
+}
+
+static void vmemmap_pop_pud(pgd_t *pgd, unsigned long addr,
+					unsigned long end, int node)
+{
+	pud_t *pud;
+
+	end = pud_addr_end(addr, end);
+	for (pud = pud_offset(pgd, addr); addr < end;
+				pud++, addr += PUD_SIZE) {
+
+		if (pud_none(*pud))
+			pud_populate(&init_mm, pud,
+				vmemmap_alloc_block(PAGE_SIZE, node));
+
+		vmemmap_pop_pmd(pud, addr, end, node);
+	}
+}
+
+static void vmemmap_populate(struct page *start_page, unsigned long nr,
+								int node)
+{
+	pgd_t *pgd;
+	unsigned long addr = (unsigned long)(start_page);
+	unsigned long end = pgd_addr_end(addr,
+			(unsigned long)((start_page + nr)));
+
+	for (pgd = pgd_offset_k(addr); addr < end;
+				pgd++, addr += PGDIR_SIZE) {
+
+		if (pgd_none(*pgd))
+			pgd_populate(&init_mm, pgd,
+				vmemmap_alloc_block(PAGE_SIZE, node));
+		vmemmap_pop_pud(pgd, addr, end, node);
+	}
+}
+#endif
+#endif /* CONFIG_SPARSE_VIRTUAL */
+
 static struct page *sparse_early_mem_map_alloc(unsigned long pnum)
 {
 	struct page *map;
@@ -221,8 +306,13 @@ static struct page *sparse_early_mem_map
 	if (map)
 		return map;
 
+#ifdef CONFIG_SPARSE_VIRTUAL
+	map = pfn_to_page(pnum * PAGES_PER_SECTION);
+	vmemmap_populate(map, PAGES_PER_SECTION, nid);
+#else
 	map = alloc_bootmem_node(NODE_DATA(nid),
 			sizeof(struct page) * PAGES_PER_SECTION);
+#endif
 	if (map)
 		return map;
 
Index: linux-2.6.21-rc5-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.21-rc5-mm2.orig/include/linux/mmzone.h	2007-03-31 22:47:14.000000000 -0700
+++ linux-2.6.21-rc5-mm2/include/linux/mmzone.h	2007-03-31 23:01:03.000000000 -0700
@@ -836,6 +836,8 @@ void sparse_init(void);
 
 void memory_present(int nid, unsigned long start, unsigned long end);
 unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
+void vmemmap_populate(struct page *start_page, unsigned long pages, int node);
+void *vmemmap_alloc_block(unsigned long size, int node);
 
 /*
  * If it is possible to have holes within a MAX_ORDER_NR_PAGES, then we

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
