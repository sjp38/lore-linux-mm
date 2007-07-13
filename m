From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 7/7] ppc64: SPARSEMEM_VMEMMAP support
References: <exportbomb.1184333503@pinky>
Message-Id: <E1I9LLW-00009n-HH@hellhawk.shadowen.org>
Date: Fri, 13 Jul 2007 14:38:10 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Enable virtual memmap support for SPARSEMEM on PPC64 systems.
Slice a 16th off the end of the linear mapping space and use that
to hold the vmemmap.  Uses the same size mapping as uses in the
linear 1:1 kernel mapping.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 5c5c487..c1212f0 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -277,6 +277,14 @@ config ARCH_POPULATES_NODE_MAP
 
 source "mm/Kconfig"
 
+config SPARSEMEM_VMEMMAP
+	def_bool y
+	depends on SPARSEMEM
+
+config ARCH_POPULATES_SPARSEMEM_VMEMMAP
+	def_bool y
+	depends on SPARSEMEM_VMEMMAP
+
 config ARCH_MEMORY_PROBE
 	def_bool y
 	depends on MEMORY_HOTPLUG
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 1d6edf7..2de3b5d 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -182,3 +182,67 @@ void pgtable_cache_init(void)
 						     NULL);
 	}
 }
+
+#ifdef CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
+
+/*
+ * Convert an address within the vmemmap into a pfn.  Note that we have
+ * to do this by hand as the proffered address may not be correctly aligned.
+ * Subtraction of non-aligned pointers produces undefined results.
+ */
+#define VMM_SECTION(addr) \
+		(((((unsigned long)(addr)) - ((unsigned long)(vmemmap))) / \
+		sizeof(struct page)) >> PFN_SECTION_SHIFT)
+#define VMM_SECTION_PAGE(addr)	(VMM_SECTION(addr) << PFN_SECTION_SHIFT)
+
+/*
+ * Check if this vmemmap page is already initialised.  If any section
+ * which overlaps this vmemmap page is initialised then this page is
+ * initialised already.
+ */
+int __meminit vmemmap_populated(unsigned long start, int page_size)
+{
+	unsigned long end = start + page_size;
+
+	for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
+		if (pfn_valid(VMM_SECTION_PAGE(start)))
+			return 1;
+
+	return 0;
+}
+
+int __meminit vmemmap_populate(struct page *start_page,
+					unsigned long nr_pages, int node)
+{
+	unsigned long mode_rw;
+	unsigned long start = (unsigned long)start_page;
+	unsigned long end = (unsigned long)(start_page + nr_pages);
+	unsigned long page_size = 1 << mmu_psize_defs[mmu_linear_psize].shift;
+
+	mode_rw = _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_COHERENT | PP_RWXX;
+
+	/* Align to the page size of the linear mapping. */
+	start = _ALIGN_DOWN(start, page_size);
+
+	for (; start < end; start += page_size) {
+		int mapped;
+		void *p;
+
+		if (vmemmap_populated(start, page_size))
+			continue;
+
+		p = vmemmap_alloc_block(page_size, node);
+		if (!p)
+			return -ENOMEM;
+
+		printk(KERN_WARNING "vmemmap %08lx allocated at %p, "
+					"physical %p.\n", start, p, __pa(p));
+
+		mapped = htab_bolt_mapping(start, start + page_size,
+					__pa(p), mode_rw, mmu_linear_psize);
+		BUG_ON(mapped < 0);
+	}
+
+	return 0;
+}
+#endif
diff --git a/include/asm-powerpc/pgtable-ppc64.h b/include/asm-powerpc/pgtable-ppc64.h
index 7ca8b5c..9577650 100644
--- a/include/asm-powerpc/pgtable-ppc64.h
+++ b/include/asm-powerpc/pgtable-ppc64.h
@@ -68,6 +68,14 @@
 #define USER_REGION_ID		(0UL)
 
 /*
+ * Defines the address of the vmemap area, in the top 16th of the
+ * kernel region.
+ */
+#define VMEMMAP_BASE (ASM_CONST(CONFIG_KERNEL_START) + \
+					(0xfUL << (REGION_SHIFT - 4)))
+#define vmemmap ((struct page *)VMEMMAP_BASE)
+
+/*
  * Common bits in a linux-style PTE.  These match the bits in the
  * (hardware-defined) PowerPC PTE as closely as possible. Additional
  * bits may be defined in pgtable-*.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
