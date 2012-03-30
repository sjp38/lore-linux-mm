Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2991A6B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 15:41:55 -0400 (EDT)
Message-Id: <201203301941.q2UJfo11007111@farm-0012.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Fri, 30 Mar 2012 15:37:42 -0400
Subject: [PATCH] arch/tile: support multiple huge page sizes dynamically
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lucas De Marchi <lucas.demarchi@profusion.mobi>, Arnd Bergmann <arnd@arndb.de>, Jiri Kosina <jkosina@suse.cz>, Joe Perches <joe@perches.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Paul E. McKenney" <paul.mckenney@linaro.org>, Josh Triplett <josh@joshtriplett.org>, Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <julia@diku.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michal Hocko <mhocko@suse.cz>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

This change adds support for a new "super" bit in the tile PTE, and a
new arch_make_huge_pte() method called from make_huge_pte().
The Tilera hypervisor sees the bit set at a given level of the page
table and gangs together 4, 16, or 64 consecutive pages from
that level of the hierarchy to create a larger TLB entry.

One extra "super" page size can be specified at each of the
three levels of the page table hierarchy on tilegx, using the
"hugepagesz" argument on the boot command line.  A new hypervisor
API is added to allow Linux to tell the hypervisor how many PTEs
to gang together at each level of the page table.

To allow pre-allocating huge pages larger than the buddy allocator
can handle, this change modifies the Tilera bootmem support to
put all of memory on tilegx platforms into bootmem.

As part of this change I eliminate the vestigial CONFIG_HIGHPTE
support, which never worked anyway, and eliminate the hv_page_size()
API in favor of the standard vma_kernel_pagesize() API.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 arch/tile/Kconfig                 |    8 ++
 arch/tile/include/asm/hugetlb.h   |   21 ++++
 arch/tile/include/asm/page.h      |    5 +-
 arch/tile/include/asm/pgtable.h   |   12 +-
 arch/tile/include/asm/tlbflush.h  |   17 +--
 arch/tile/include/hv/hypervisor.h |   70 ++++++++++-
 arch/tile/kernel/hvglue.lds       |    3 +-
 arch/tile/kernel/proc.c           |    1 +
 arch/tile/kernel/setup.c          |  152 ++++++++++++++++--------
 arch/tile/kernel/tlb.c            |   11 +-
 arch/tile/mm/fault.c              |    2 +-
 arch/tile/mm/homecache.c          |    1 +
 arch/tile/mm/hugetlbpage.c        |  241 +++++++++++++++++++++++++++----------
 arch/tile/mm/init.c               |    4 +
 arch/tile/mm/pgtable.c            |   13 --
 mm/hugetlb.c                      |    3 +
 16 files changed, 408 insertions(+), 156 deletions(-)

diff --git a/arch/tile/Kconfig b/arch/tile/Kconfig
index bbbe71f..0fa5085 100644
--- a/arch/tile/Kconfig
+++ b/arch/tile/Kconfig
@@ -46,6 +46,14 @@ config NEED_PER_CPU_PAGE_FIRST_CHUNK
 config SYS_SUPPORTS_HUGETLBFS
 	def_bool y
 
+# Support for additional huge page sizes besides HPAGE_SIZE.
+# The software support is currently only present in the TILE-Gx
+# hypervisor. TILEPro in any case does not support page sizes
+# larger than the default HPAGE_SIZE.
+config HUGETLB_SUPER_PAGES
+	depends on HUGETLB_PAGE && TILEGX
+	def_bool y
+
 config GENERIC_CLOCKEVENTS
 	def_bool y
 
diff --git a/arch/tile/include/asm/hugetlb.h b/arch/tile/include/asm/hugetlb.h
index d396d18..b204238 100644
--- a/arch/tile/include/asm/hugetlb.h
+++ b/arch/tile/include/asm/hugetlb.h
@@ -106,4 +106,25 @@ static inline void arch_release_hugepage(struct page *page)
 {
 }
 
+#ifdef CONFIG_HUGETLB_SUPER_PAGES
+static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
+				       struct page *page, int writable)
+{
+	size_t pagesize = huge_page_size(hstate_vma(vma));
+	if (pagesize != PUD_SIZE && pagesize != PMD_SIZE)
+		entry = pte_mksuper(entry);
+	return entry;
+}
+#define arch_make_huge_pte arch_make_huge_pte
+
+/* Sizes to scale up page size for PTEs with HV_PTE_SUPER bit. */
+enum {
+	HUGE_SHIFT_PGDIR = 0,
+	HUGE_SHIFT_PMD = 1,
+	HUGE_SHIFT_PAGE = 2,
+	HUGE_SHIFT_ENTRIES
+};
+extern int huge_shift[HUGE_SHIFT_ENTRIES];
+#endif
+
 #endif /* _ASM_TILE_HUGETLB_H */
diff --git a/arch/tile/include/asm/page.h b/arch/tile/include/asm/page.h
index c750943..9d9131e 100644
--- a/arch/tile/include/asm/page.h
+++ b/arch/tile/include/asm/page.h
@@ -87,8 +87,7 @@ typedef HV_PTE pgprot_t;
 /*
  * User L2 page tables are managed as one L2 page table per page,
  * because we use the page allocator for them.  This keeps the allocation
- * simple and makes it potentially useful to implement HIGHPTE at some point.
- * However, it's also inefficient, since L2 page tables are much smaller
+ * simple, but it's also inefficient, since L2 page tables are much smaller
  * than pages (currently 2KB vs 64KB).  So we should revisit this.
  */
 typedef struct page *pgtable_t;
@@ -137,7 +136,7 @@ static inline __attribute_const__ int get_order(unsigned long size)
 
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
 
-#define HUGE_MAX_HSTATE		2
+#define HUGE_MAX_HSTATE		6
 
 #ifdef CONFIG_HUGETLB_PAGE
 #define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
index ae43301..ff01704 100644
--- a/arch/tile/include/asm/pgtable.h
+++ b/arch/tile/include/asm/pgtable.h
@@ -72,6 +72,7 @@ extern void set_page_homes(void);
 
 #define _PAGE_PRESENT           HV_PTE_PRESENT
 #define _PAGE_HUGE_PAGE         HV_PTE_PAGE
+#define _PAGE_SUPER_PAGE        HV_PTE_SUPER
 #define _PAGE_READABLE          HV_PTE_READABLE
 #define _PAGE_WRITABLE          HV_PTE_WRITABLE
 #define _PAGE_EXECUTABLE        HV_PTE_EXECUTABLE
@@ -88,6 +89,7 @@ extern void set_page_homes(void);
 #define _PAGE_ALL (\
   _PAGE_PRESENT | \
   _PAGE_HUGE_PAGE | \
+  _PAGE_SUPER_PAGE | \
   _PAGE_READABLE | \
   _PAGE_WRITABLE | \
   _PAGE_EXECUTABLE | \
@@ -198,6 +200,7 @@ static inline void __pte_clear(pte_t *ptep)
 #define pte_write hv_pte_get_writable
 #define pte_exec hv_pte_get_executable
 #define pte_huge hv_pte_get_page
+#define pte_super hv_pte_get_super
 #define pte_rdprotect hv_pte_clear_readable
 #define pte_exprotect hv_pte_clear_executable
 #define pte_mkclean hv_pte_clear_dirty
@@ -210,6 +213,7 @@ static inline void __pte_clear(pte_t *ptep)
 #define pte_mkyoung hv_pte_set_accessed
 #define pte_mkwrite hv_pte_set_writable
 #define pte_mkhuge hv_pte_set_page
+#define pte_mksuper hv_pte_set_super
 
 #define pte_special(pte) 0
 #define pte_mkspecial(pte) (pte)
@@ -339,13 +343,8 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
  */
 #define pgd_offset_k(address) pgd_offset(&init_mm, address)
 
-#if defined(CONFIG_HIGHPTE)
-extern pte_t *pte_offset_map(pmd_t *, unsigned long address);
-#define pte_unmap(pte) kunmap_atomic(pte)
-#else
 #define pte_offset_map(dir, address) pte_offset_kernel(dir, address)
 #define pte_unmap(pte) do { } while (0)
-#endif
 
 /* Clear a non-executable kernel PTE and flush it from the TLB. */
 #define kpte_clear_flush(ptep, vaddr)		\
@@ -538,7 +537,8 @@ static inline pte_t *pte_offset_kernel(pmd_t *pmd, unsigned long address)
 /* Support /proc/NN/pgtable API. */
 struct seq_file;
 int arch_proc_pgtable_show(struct seq_file *m, struct mm_struct *mm,
-			   unsigned long vaddr, pte_t *ptep, void **datap);
+			   unsigned long vaddr, unsigned long pagesize,
+			   pte_t *ptep, void **datap);
 
 #endif /* !__ASSEMBLY__ */
 
diff --git a/arch/tile/include/asm/tlbflush.h b/arch/tile/include/asm/tlbflush.h
index 96199d2..dcf91b2 100644
--- a/arch/tile/include/asm/tlbflush.h
+++ b/arch/tile/include/asm/tlbflush.h
@@ -38,16 +38,11 @@ DECLARE_PER_CPU(int, current_asid);
 /* The hypervisor tells us what ASIDs are available to us. */
 extern int min_asid, max_asid;
 
-static inline unsigned long hv_page_size(const struct vm_area_struct *vma)
-{
-	return (vma->vm_flags & VM_HUGETLB) ? HPAGE_SIZE : PAGE_SIZE;
-}
-
 /* Pass as vma pointer for non-executable mapping, if no vma available. */
-#define FLUSH_NONEXEC ((const struct vm_area_struct *)-1UL)
+#define FLUSH_NONEXEC ((struct vm_area_struct *)-1UL)
 
 /* Flush a single user page on this cpu. */
-static inline void local_flush_tlb_page(const struct vm_area_struct *vma,
+static inline void local_flush_tlb_page(struct vm_area_struct *vma,
 					unsigned long addr,
 					unsigned long page_size)
 {
@@ -60,7 +55,7 @@ static inline void local_flush_tlb_page(const struct vm_area_struct *vma,
 }
 
 /* Flush range of user pages on this cpu. */
-static inline void local_flush_tlb_pages(const struct vm_area_struct *vma,
+static inline void local_flush_tlb_pages(struct vm_area_struct *vma,
 					 unsigned long addr,
 					 unsigned long page_size,
 					 unsigned long len)
@@ -117,10 +112,10 @@ extern void flush_tlb_all(void);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 extern void flush_tlb_current_task(void);
 extern void flush_tlb_mm(struct mm_struct *);
-extern void flush_tlb_page(const struct vm_area_struct *, unsigned long);
-extern void flush_tlb_page_mm(const struct vm_area_struct *,
+extern void flush_tlb_page(struct vm_area_struct *, unsigned long);
+extern void flush_tlb_page_mm(struct vm_area_struct *,
 			      struct mm_struct *, unsigned long);
-extern void flush_tlb_range(const struct vm_area_struct *,
+extern void flush_tlb_range(struct vm_area_struct *,
 			    unsigned long start, unsigned long end);
 
 #define flush_tlb()     flush_tlb_current_task()
diff --git a/arch/tile/include/hv/hypervisor.h b/arch/tile/include/hv/hypervisor.h
index 16c18e4..3bc4045 100644
--- a/arch/tile/include/hv/hypervisor.h
+++ b/arch/tile/include/hv/hypervisor.h
@@ -66,6 +66,22 @@
 #define HV_DEFAULT_PAGE_SIZE_LARGE \
   (__HV_SIZE_ONE << HV_LOG2_DEFAULT_PAGE_SIZE_LARGE)
 
+#if CHIP_VA_WIDTH() > 32
+
+/** The log2 of the initial size of jumbo pages, in bytes.
+ * See HV_DEFAULT_PAGE_SIZE_JUMBO.
+ */
+#define HV_LOG2_DEFAULT_PAGE_SIZE_JUMBO 32
+
+/** The initial size of jumbo pages, in bytes. This value should
+ * be verified at runtime by calling hv_sysconf(HV_SYSCONF_PAGE_SIZE_JUMBO).
+ * It may also be modified when installing a new context.
+ */
+#define HV_DEFAULT_PAGE_SIZE_JUMBO \
+  (__HV_SIZE_ONE << HV_LOG2_DEFAULT_PAGE_SIZE_JUMBO)
+
+#endif
+
 /** The log2 of the granularity at which page tables must be aligned;
  *  in other words, the CPA for a page table must have this many zero
  *  bits at the bottom of the address.
@@ -284,8 +300,11 @@
 #define HV_DISPATCH_GET_IPI_PTE                   56
 #endif
 
+/** hv_set_pte_super_shift */
+#define HV_DISPATCH_SET_PTE_SUPER_SHIFT           57
+
 /** One more than the largest dispatch value */
-#define _HV_DISPATCH_END                          57
+#define _HV_DISPATCH_END                          58
 
 
 #ifndef __ASSEMBLER__
@@ -413,6 +432,11 @@ typedef enum {
    */
   HV_SYSCONF_VALID_PAGE_SIZES = 7,
 
+  /** The size of jumbo pages, in bytes.
+   * If no jumbo pages are available, zero will be returned.
+   */
+  HV_SYSCONF_PAGE_SIZE_JUMBO = 8,
+
 } HV_SysconfQuery;
 
 /** Offset to subtract from returned Kelvin temperature to get degrees
@@ -690,6 +714,29 @@ int hv_install_context(HV_PhysAddr page_table, HV_PTE access, HV_ASID asid,
 
 #ifndef __ASSEMBLER__
 
+
+/** Set the number of pages ganged together by HV_PTE_SUPER at a
+ * particular level of the page table.
+ *
+ * The current TILE-Gx hardware only supports powers of four
+ * (i.e. log2_count must be a multiple of two), and the requested
+ * "super" page size must be less than the span of the next level in
+ * the page table.  The largest size that can be requested is 64GB.
+ *
+ * The shift value is initially "0" for all page table levels,
+ * indicating that the HV_PTE_SUPER bit is effectively ignored.
+ *
+ * If you change the count from one non-zero value to another, the
+ * hypervisor will flush the entire TLB and TSB to avoid confusion.
+ *
+ * @param level Page table level (0, 1, or 2)
+ * @param log2_count Base-2 log of the number of pages to gang together,
+ * i.e. how much to shift left the base page size for the super page size.
+ * @return Zero on success, or a hypervisor error code on failure.
+ */
+int hv_set_pte_super_shift(int level, int log2_count);
+
+
 /** Value returned from hv_inquire_context(). */
 typedef struct
 {
@@ -1875,8 +1922,9 @@ int hv_flush_remote(HV_PhysAddr cache_pa, unsigned long cache_control,
 #define HV_PTE_INDEX_USER            10  /**< Page is user-accessible */
 #define HV_PTE_INDEX_ACCESSED        11  /**< Page has been accessed */
 #define HV_PTE_INDEX_DIRTY           12  /**< Page has been written */
-                                         /*   Bits 13-15 are reserved for
+                                         /*   Bits 13-14 are reserved for
                                               future use. */
+#define HV_PTE_INDEX_SUPER           15  /**< Pages ganged together for TLB */
 #define HV_PTE_INDEX_MODE            16  /**< Page mode; see HV_PTE_MODE_xxx */
 #define HV_PTE_MODE_BITS              3  /**< Number of bits in mode */
 #define HV_PTE_INDEX_CLIENT2         19  /**< Page client state 2 */
@@ -1971,7 +2019,10 @@ int hv_flush_remote(HV_PhysAddr cache_pa, unsigned long cache_control,
 
 /** Does this PTE map a page?
  *
- * If this bit is set in the level-1 page table, the entry should be
+ * If this bit is set in a level-0 page table, the entry should be
+ * interpreted as a level-2 page table entry mapping a jumbo page.
+ *
+ * If this bit is set in a level-1 page table, the entry should be
  * interpreted as a level-2 page table entry mapping a large page.
  *
  * This bit should not be modified by the client while PRESENT is set, as
@@ -1981,6 +2032,18 @@ int hv_flush_remote(HV_PhysAddr cache_pa, unsigned long cache_control,
  */
 #define HV_PTE_PAGE                  (__HV_PTE_ONE << HV_PTE_INDEX_PAGE)
 
+/** Does this PTE implicitly reference multiple pages?
+ *
+ * If this bit is set in the page table (either in the level-2 page table,
+ * or in a higher level page table in conjunction with the PAGE bit)
+ * then the PTE specifies a range of contiguous pages, not a single page.
+ * The hv_set_pte_super_shift() allows you to specify the count for
+ * each level of the page table.
+ *
+ * Note: this bit is not supported on TILEPro systems.
+ */
+#define HV_PTE_SUPER                 (__HV_PTE_ONE << HV_PTE_INDEX_SUPER)
+
 /** Is this a global (non-ASID) mapping?
  *
  * If this bit is set, the translations established by this PTE will
@@ -2199,6 +2262,7 @@ hv_pte_clear_##name(HV_PTE pte)                                 \
  */
 _HV_BIT(present,         PRESENT)
 _HV_BIT(page,            PAGE)
+_HV_BIT(super,           SUPER)
 _HV_BIT(client0,         CLIENT0)
 _HV_BIT(client1,         CLIENT1)
 _HV_BIT(client2,         CLIENT2)
diff --git a/arch/tile/kernel/hvglue.lds b/arch/tile/kernel/hvglue.lds
index 2b7cd0a..d44c5a6 100644
--- a/arch/tile/kernel/hvglue.lds
+++ b/arch/tile/kernel/hvglue.lds
@@ -55,4 +55,5 @@ hv_store_mapping = TEXT_OFFSET + 0x106a0;
 hv_inquire_realpa = TEXT_OFFSET + 0x106c0;
 hv_flush_all = TEXT_OFFSET + 0x106e0;
 hv_get_ipi_pte = TEXT_OFFSET + 0x10700;
-hv_glue_internals = TEXT_OFFSET + 0x10720;
+hv_set_pte_super_shift = TEXT_OFFSET + 0x10720;
+hv_glue_internals = TEXT_OFFSET + 0x10740;
diff --git a/arch/tile/kernel/proc.c b/arch/tile/kernel/proc.c
index 62d8208..663c97c 100644
--- a/arch/tile/kernel/proc.c
+++ b/arch/tile/kernel/proc.c
@@ -22,6 +22,7 @@
 #include <linux/proc_fs.h>
 #include <linux/sysctl.h>
 #include <linux/hardirq.h>
+#include <linux/hugetlb.h>
 #include <linux/mman.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
diff --git a/arch/tile/kernel/setup.c b/arch/tile/kernel/setup.c
index 90251dc..825bc64 100644
--- a/arch/tile/kernel/setup.c
+++ b/arch/tile/kernel/setup.c
@@ -28,6 +28,7 @@
 #include <linux/highmem.h>
 #include <linux/smp.h>
 #include <linux/timex.h>
+#include <linux/hugetlb.h>
 #include <asm/setup.h>
 #include <asm/sections.h>
 #include <asm/cacheflush.h>
@@ -49,9 +50,6 @@ char chip_model[64] __write_once;
 struct pglist_data node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
 
-/* We only create bootmem data on node 0. */
-static bootmem_data_t __initdata node0_bdata;
-
 /* Information on the NUMA nodes that we compute early */
 unsigned long __cpuinitdata node_start_pfn[MAX_NUMNODES];
 unsigned long __cpuinitdata node_end_pfn[MAX_NUMNODES];
@@ -518,37 +516,96 @@ static void __init setup_memory(void)
 #endif
 }
 
-static void __init setup_bootmem_allocator(void)
+/*
+ * On 32-bit machines, we only put bootmem on the low controller,
+ * since PAs > 4GB can't be used in bootmem.  In principle one could
+ * imagine, e.g., multiple 1 GB controllers all of which could support
+ * bootmem, but in practice using controllers this small isn't a
+ * particularly interesting scenario, so we just keep it simple and
+ * use only the first controller for bootmem on 32-bit machines.
+ */
+static inline int node_has_bootmem(int nid)
+{
+#ifdef CONFIG_64BIT
+	return 1;
+#else
+	return nid == 0;
+#endif
+}
+
+static inline unsigned long alloc_bootmem_pfn(int nid,
+					      unsigned long size,
+					      unsigned long goal)
+{
+	void *kva = __alloc_bootmem_node(NODE_DATA(nid), size,
+					 PAGE_SIZE, goal);
+	unsigned long pfn = kaddr_to_pfn(kva);
+	BUG_ON(goal && PFN_PHYS(pfn) != goal);
+	return pfn;
+}
+
+static void __init setup_bootmem_allocator_node(int i)
 {
-	unsigned long bootmap_size, first_alloc_pfn, last_alloc_pfn;
+	unsigned long start, end, mapsize, mapstart;
+
+	if (node_has_bootmem(i)) {
+		NODE_DATA(i)->bdata = &bootmem_node_data[i];
+	} else {
+		/* Share controller zero's bdata for now. */
+		NODE_DATA(i)->bdata = &bootmem_node_data[0];
+		return;
+	}
 
-	/* Provide a node 0 bdata. */
-	NODE_DATA(0)->bdata = &node0_bdata;
+	/* Skip up to after the bss in node 0. */
+	start = (i == 0) ? min_low_pfn : node_start_pfn[i];
 
-#ifdef CONFIG_PCI
-	/* Don't let boot memory alias the PCI region. */
-	last_alloc_pfn = min(max_low_pfn, pci_reserve_start_pfn);
+	/* Only lowmem, if we're a HIGHMEM build. */
+#ifdef CONFIG_HIGHMEM
+	end = node_lowmem_end_pfn[i];
 #else
-	last_alloc_pfn = max_low_pfn;
+	end = node_end_pfn[i];
 #endif
 
-	/*
-	 * Initialize the boot-time allocator (with low memory only):
-	 * The first argument says where to put the bitmap, and the
-	 * second says where the end of allocatable memory is.
-	 */
-	bootmap_size = init_bootmem(min_low_pfn, last_alloc_pfn);
+	/* No memory here. */
+	if (end == start)
+		return;
 
+	/* Figure out where the bootmem bitmap is located. */
+	mapsize = bootmem_bootmap_pages(end - start);
+	if (i == 0) {
+		/* Use some space right before the heap on node 0. */
+		mapstart = start;
+		start += mapsize;
+	} else {
+		/* Allocate bitmap on node 0 to avoid page table issues. */
+		mapstart = alloc_bootmem_pfn(0, PFN_PHYS(mapsize), 0);
+	}
+
+	/* Initialize a node. */
+	init_bootmem_node(NODE_DATA(i), mapstart, start, end);
+
+	/* Free all the space back into the allocator. */
+	free_bootmem(PFN_PHYS(start), PFN_PHYS(end - start));
+
+#if defined(CONFIG_PCI)
 	/*
-	 * Let the bootmem allocator use all the space we've given it
-	 * except for its own bitmap.
+	 * Throw away any memory aliased by the PCI region.  FIXME: this
+	 * is a temporary hack to work around bug 10502, and needs to be
+	 * fixed properly.
 	 */
-	first_alloc_pfn = min_low_pfn + PFN_UP(bootmap_size);
-	if (first_alloc_pfn >= last_alloc_pfn)
-		early_panic("Not enough memory on controller 0 for bootmem\n");
+	if (pci_reserve_start_pfn < end && pci_reserve_end_pfn > start)
+		reserve_bootmem(PFN_PHYS(pci_reserve_start_pfn),
+				PFN_PHYS(pci_reserve_end_pfn -
+					 pci_reserve_start_pfn),
+				BOOTMEM_EXCLUSIVE);
+#endif
+}
 
-	free_bootmem(PFN_PHYS(first_alloc_pfn),
-		     PFN_PHYS(last_alloc_pfn - first_alloc_pfn));
+static void __init setup_bootmem_allocator(void)
+{
+	int i;
+	for (i = 0; i < MAX_NUMNODES; ++i)
+		setup_bootmem_allocator_node(i);
 
 #ifdef CONFIG_KEXEC
 	if (crashk_res.start != crashk_res.end)
@@ -579,14 +636,6 @@ static int __init percpu_size(void)
 	return size;
 }
 
-static inline unsigned long alloc_bootmem_pfn(int size, unsigned long goal)
-{
-	void *kva = __alloc_bootmem(size, PAGE_SIZE, goal);
-	unsigned long pfn = kaddr_to_pfn(kva);
-	BUG_ON(goal && PFN_PHYS(pfn) != goal);
-	return pfn;
-}
-
 static void __init zone_sizes_init(void)
 {
 	unsigned long zones_size[MAX_NR_ZONES] = { 0 };
@@ -624,21 +673,22 @@ static void __init zone_sizes_init(void)
 		 * though, there'll be no lowmem, so we just alloc_bootmem
 		 * the memmap.  There will be no percpu memory either.
 		 */
-		if (__pfn_to_highbits(start) == 0) {
-			/* In low PAs, allocate via bootmem. */
+		if (i != 0 && cpu_isset(i, isolnodes)) {
+			node_memmap_pfn[i] =
+				alloc_bootmem_pfn(0, memmap_size, 0);
+			BUG_ON(node_percpu[i] != 0);
+		} else if (node_has_bootmem(start)) {
 			unsigned long goal = 0;
 			node_memmap_pfn[i] =
-				alloc_bootmem_pfn(memmap_size, goal);
+				alloc_bootmem_pfn(i, memmap_size, 0);
 			if (kdata_huge)
 				goal = PFN_PHYS(lowmem_end) - node_percpu[i];
 			if (node_percpu[i])
 				node_percpu_pfn[i] =
-				    alloc_bootmem_pfn(node_percpu[i], goal);
-		} else if (cpu_isset(i, isolnodes)) {
-			node_memmap_pfn[i] = alloc_bootmem_pfn(memmap_size, 0);
-			BUG_ON(node_percpu[i] != 0);
+					alloc_bootmem_pfn(i, node_percpu[i],
+							  goal);
 		} else {
-			/* In high PAs, just reserve some pages. */
+			/* In non-bootmem zones, just reserve some pages. */
 			node_memmap_pfn[i] = node_free_pfn[i];
 			node_free_pfn[i] += PFN_UP(memmap_size);
 			if (!kdata_huge) {
@@ -662,16 +712,9 @@ static void __init zone_sizes_init(void)
 		zones_size[ZONE_NORMAL] = end - start;
 #endif
 
-		/*
-		 * Everyone shares node 0's bootmem allocator, but
-		 * we use alloc_remap(), above, to put the actual
-		 * struct page array on the individual controllers,
-		 * which is most of the data that we actually care about.
-		 * We can't place bootmem allocators on the other
-		 * controllers since the bootmem allocator can only
-		 * operate on 32-bit physical addresses.
-		 */
-		NODE_DATA(i)->bdata = NODE_DATA(0)->bdata;
+		/* Take zone metadata from controller 0 if we're isolnode. */
+		if (node_isset(i, isolnodes))
+			NODE_DATA(i)->bdata = &bootmem_node_data[0];
 
 		free_area_init_node(i, zones_size, start, NULL);
 		printk(KERN_DEBUG "  Normal zone: %ld per-cpu pages\n",
@@ -908,6 +951,15 @@ void __cpuinit setup_cpu(int boot)
 	/* Reset the network state on this cpu. */
 	reset_network_state();
 #endif
+
+#ifdef CONFIG_HUGETLB_SUPER_PAGES
+	/* Initialize hugepage support on this cpu. */
+	if (!boot) {
+		int i;
+		for (i = 0; i < HUGE_SHIFT_ENTRIES; ++i)
+			hv_set_pte_super_shift(i, huge_shift[i]);
+	}
+#endif
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
diff --git a/arch/tile/kernel/tlb.c b/arch/tile/kernel/tlb.c
index a5f241c..3fd54d5 100644
--- a/arch/tile/kernel/tlb.c
+++ b/arch/tile/kernel/tlb.c
@@ -15,6 +15,7 @@
 
 #include <linux/cpumask.h>
 #include <linux/module.h>
+#include <linux/hugetlb.h>
 #include <asm/tlbflush.h>
 #include <asm/homecache.h>
 #include <hv/hypervisor.h>
@@ -49,25 +50,25 @@ void flush_tlb_current_task(void)
 	flush_tlb_mm(current->mm);
 }
 
-void flush_tlb_page_mm(const struct vm_area_struct *vma, struct mm_struct *mm,
+void flush_tlb_page_mm(struct vm_area_struct *vma, struct mm_struct *mm,
 		       unsigned long va)
 {
-	unsigned long size = hv_page_size(vma);
+	unsigned long size = vma_kernel_pagesize(vma);
 	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
 	flush_remote(0, cache, mm_cpumask(mm),
 		     va, size, size, mm_cpumask(mm), NULL, 0);
 }
 
-void flush_tlb_page(const struct vm_area_struct *vma, unsigned long va)
+void flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 {
 	flush_tlb_page_mm(vma, vma->vm_mm, va);
 }
 EXPORT_SYMBOL(flush_tlb_page);
 
-void flush_tlb_range(const struct vm_area_struct *vma,
+void flush_tlb_range(struct vm_area_struct *vma,
 		     unsigned long start, unsigned long end)
 {
-	unsigned long size = hv_page_size(vma);
+	unsigned long size = vma_kernel_pagesize(vma);
 	struct mm_struct *mm = vma->vm_mm;
 	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
 	flush_remote(0, cache, mm_cpumask(mm), start, end - start, size,
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index 5d10a74..7cea0fc 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -188,7 +188,7 @@ static pgd_t *get_current_pgd(void)
 	HV_Context ctx = hv_inquire_context();
 	unsigned long pgd_pfn = ctx.page_table >> PAGE_SHIFT;
 	struct page *pgd_page = pfn_to_page(pgd_pfn);
-	BUG_ON(PageHighMem(pgd_page));   /* oops, HIGHPTE? */
+	BUG_ON(PageHighMem(pgd_page));
 	return (pgd_t *) __va(ctx.page_table);
 }
 
diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
index 499f737..dbcbdf7 100644
--- a/arch/tile/mm/homecache.c
+++ b/arch/tile/mm/homecache.c
@@ -30,6 +30,7 @@
 #include <linux/cache.h>
 #include <linux/smp.h>
 #include <linux/module.h>
+#include <linux/hugetlb.h>
 
 #include <asm/page.h>
 #include <asm/sections.h>
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index 42cfcba..75716eb 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -27,85 +27,145 @@
 #include <linux/mman.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
+#include <asm/setup.h>
+
+#ifdef CONFIG_HUGETLB_SUPER_PAGES
+/* "Extra" page-size multipliers, one per level of the page table. */
+int huge_shift[HUGE_SHIFT_ENTRIES];
+
+/*
+ * This routine is a hybrid of pte_alloc_map() and pte_alloc_kernel().
+ * It assumes that L2 PTEs are never in HIGHMEM (we don't support that).
+ * It locks the user pagetable, and bumps up the mm->nr_ptes field,
+ * but otherwise allocate the page table using the kernel versions.
+ */
+static pte_t *pte_alloc_hugetlb(struct mm_struct *mm, pmd_t *pmd,
+				unsigned long address)
+{
+	pte_t *new;
+
+	if (pmd_none(*pmd)) {
+		new = pte_alloc_one_kernel(mm, address);
+		if (!new)
+			return NULL;
+
+		smp_wmb(); /* See comment in __pte_alloc */
+
+		spin_lock(&mm->page_table_lock);
+		if (likely(pmd_none(*pmd))) {  /* Has another populated it ? */
+			mm->nr_ptes++;
+			pmd_populate_kernel(mm, pmd, new);
+			new = NULL;
+		} else
+			VM_BUG_ON(pmd_trans_splitting(*pmd));
+		spin_unlock(&mm->page_table_lock);
+		if (new)
+			pte_free_kernel(mm, new);
+	}
+
+	return pte_offset_kernel(pmd, address);
+}
+#endif
 
 pte_t *huge_pte_alloc(struct mm_struct *mm,
 		      unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
-	pte_t *pte = NULL;
 
-	/* We do not yet support multiple huge page sizes. */
-	BUG_ON(sz != PMD_SIZE);
+	addr &= -sz;   /* Mask off any low bits in the address. */
 
 	pgd = pgd_offset(mm, addr);
 	pud = pud_alloc(mm, pgd, addr);
-	if (pud)
-		pte = (pte_t *) pmd_alloc(mm, pud, addr);
-	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
-	return pte;
+#ifdef CONFIG_HUGETLB_SUPER_PAGES
+	if (sz >= PGDIR_SIZE) {
+		BUG_ON(sz != PGDIR_SIZE &&
+		       sz != PGDIR_SIZE << huge_shift[HUGE_SHIFT_PGDIR]);
+		return (pte_t *)pud;
+	} else {
+		pmd_t *pmd = pmd_alloc(mm, pud, addr);
+		if (sz >= PMD_SIZE) {
+			BUG_ON(sz != PMD_SIZE &&
+			       sz != (PMD_SIZE << huge_shift[HUGE_SHIFT_PMD]));
+			return (pte_t *)pmd;
+		}
+		else {
+			if (sz != PAGE_SIZE << huge_shift[HUGE_SHIFT_PAGE])
+				panic("Unexpected page size %#lx\n", sz);
+			return pte_alloc_hugetlb(mm, pmd, addr);
+		}
+	}
+#else
+	BUG_ON(sz != PMD_SIZE);
+	return (pte_t *) pmd_alloc(mm, pud, addr);
+#endif
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+static pte_t *get_pte(pte_t *base, int index, int level)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd = NULL;
-
-	pgd = pgd_offset(mm, addr);
-	if (pgd_present(*pgd)) {
-		pud = pud_offset(pgd, addr);
-		if (pud_present(*pud))
-			pmd = pmd_offset(pud, addr);
+	pte_t *ptep = base + index;
+#ifdef CONFIG_HUGETLB_SUPER_PAGES
+	if (!pte_present(*ptep) && huge_shift[level] != 0) {
+		unsigned long mask = -1UL << huge_shift[level];
+		pte_t *super_ptep = base + (index & mask);
+		pte_t pte = *super_ptep;
+		if (pte_present(pte) && pte_super(pte))
+			ptep = super_ptep;
 	}
-	return (pte_t *) pmd;
+#endif
+	return ptep;
 }
 
-#ifdef HUGETLB_TEST
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
-			      int write)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {
-	unsigned long start = address;
-	int length = 1;
-	int nr;
-	struct page *page;
-	struct vm_area_struct *vma;
-
-	vma = find_vma(mm, addr);
-	if (!vma || !is_vm_hugetlb_page(vma))
-		return ERR_PTR(-EINVAL);
-
-	pte = huge_pte_offset(mm, address);
-
-	/* hugetlb should be locked, and hence, prefaulted */
-	WARN_ON(!pte || pte_none(*pte));
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+#ifdef CONFIG_HUGETLB_SUPER_PAGES
+	pte_t *pte;
+#endif
 
-	page = &pte_page(*pte)[vpfn % (HPAGE_SIZE/PAGE_SIZE)];
+	/* Get the top-level page table entry. */
+	pgd = (pgd_t *)get_pte((pte_t *)mm->pgd, pgd_index(addr), 0);
+	if (!pgd_present(*pgd))
+		return NULL;
 
-	WARN_ON(!PageHead(page));
+	/* We don't have four levels. */
+	pud = pud_offset(pgd, addr);
+#ifndef __PAGETABLE_PUD_FOLDED
+# error support fourth page table level
+#endif
 
-	return page;
-}
+	/* Check for an L0 huge PTE, if we have three levels. */
+#ifndef __PAGETABLE_PMD_FOLDED
+	if (pud_huge(*pud))
+		return (pte_t *)pud;
 
-int pmd_huge(pmd_t pmd)
-{
-	return 0;
-}
+	pmd = (pmd_t *)get_pte((pte_t *)pud_page_vaddr(*pud),
+			       pmd_index(addr), 1);
+	if (!pmd_present(*pmd))
+		return NULL;
+#else
+	pmd = pmd_offset(pud, addr);
+#endif
 
-int pud_huge(pud_t pud)
-{
-	return 0;
-}
+	/* Check for an L1 huge PTE. */
+	if (pmd_huge(*pmd))
+		return (pte_t *)pmd;
+
+#ifdef CONFIG_HUGETLB_SUPER_PAGES
+	/* Check for an L2 huge PTE. */
+	pte = get_pte((pte_t *)pmd_page_vaddr(*pmd), pte_index(addr), 2);
+	if (!pte_present(*pte))
+		return NULL;
+	if (pte_super(*pte))
+		return pte;
+#endif
 
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
-{
 	return NULL;
 }
 
-#else
-
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write)
 {
@@ -149,8 +209,6 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
 	return 0;
 }
 
-#endif
-
 #ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 		unsigned long addr, unsigned long len,
@@ -323,20 +381,77 @@ unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 				pgoff, flags);
 }
 
-static __init int setup_hugepagesz(char *opt)
+#ifdef CONFIG_HUGETLB_SUPER_PAGES
+static void add_super_size(unsigned long ps, int level, int base_shift)
 {
-	unsigned long ps = memparse(opt, &opt);
-	if (ps == PMD_SIZE) {
-		hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
-	} else if (ps == PUD_SIZE) {
-		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
+	int log_ps = __builtin_ctzl(ps);
+	if ((1UL << log_ps) != ps || (log_ps & 1) != 0) {
+		pr_warn("Not enabling %ld byte huge pages;"
+			" must be a power of four.\n", ps);
+		return;
+	}
+	if (log_ps != base_shift) {
+		if (huge_shift[level] != 0) {
+			int old_shift = base_shift + huge_shift[level];
+			pr_warn("Not enabling %ld MB huge pages;"
+				" already have size %ld MB.\n",
+				ps >> 20, (1UL << old_shift) >> 20);
+			return;
+		}
+		if (hv_set_pte_super_shift(level, log_ps - base_shift) != 0) {
+			pr_warn("Not enabling %ld MB huge pages;"
+				" no hypervisor support.\n", ps >> 20);
+			return;
+		}
+		printk(KERN_DEBUG "Enabled %ld MB huge pages\n", ps >> 20);
+		huge_shift[level] = log_ps - base_shift;
+	}
+	hugetlb_add_hstate(log_ps - PAGE_SHIFT);
+}
+
+static __init int __setup_hugepagesz(unsigned long ps)
+{
+	if (ps > 64*1024*1024*1024UL) {
+		pr_warn("Not enabling %ld MB huge pages;"
+			" largest legal value is 64 GB .\n", ps >> 20);
+	}
+	else if (ps >= PUD_SIZE) {
+		static long hv_jpage_size;
+		if (hv_jpage_size == 0)
+			hv_jpage_size = hv_sysconf(HV_SYSCONF_PAGE_SIZE_JUMBO);
+		if (hv_jpage_size != PUD_SIZE) {
+			pr_warn("Not enabling >= %ld MB huge pages:"
+				" hypervisor reports size %ld\n",
+				PUD_SIZE >> 20, hv_jpage_size);
+		}
+		add_super_size(ps, 0, PUD_SHIFT);
+	} else if (ps >= PMD_SIZE) {
+		add_super_size(ps, 1, PMD_SHIFT);
+	} else if (ps > PAGE_SIZE) {
+		add_super_size(ps, 2, PAGE_SHIFT);
 	} else {
-		pr_err("hugepagesz: Unsupported page size %lu M\n",
-			ps >> 20);
-		return 0;
+		pr_err("hugepagesz: Unsupported page size %ld\n", ps);
 	}
 	return 1;
 }
+
+bool saw_hugepagesz;
+
+static __init int setup_hugepagesz(char *opt)
+{
+	saw_hugepagesz = true;
+	return __setup_hugepagesz(memparse(opt, NULL));
+}
 __setup("hugepagesz=", setup_hugepagesz);
 
+/* Provide 1MB size as a standard default if nothing specified. */
+static __init int add_default_hugepagesz(void)
+{
+	if (!saw_hugepagesz)
+		__setup_hugepagesz(1 * 1024 * 1024UL);
+	return 1;
+}
+arch_initcall(add_default_hugepagesz);
+#endif
+
 #endif /*HAVE_ARCH_HUGETLB_UNMAPPED_AREA*/
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index 6119f46..5276f05 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -704,6 +704,7 @@ static void __init permanent_kmaps_init(pgd_t *pgd_base)
 #endif /* CONFIG_HIGHMEM */
 
 
+#ifndef CONFIG_64BIT
 static void __init init_free_pfn_range(unsigned long start, unsigned long end)
 {
 	unsigned long pfn;
@@ -776,6 +777,7 @@ static void __init set_non_bootmem_pages_init(void)
 		init_free_pfn_range(start, end);
 	}
 }
+#endif
 
 /*
  * paging_init() sets up the page tables - note that all of lowmem is
@@ -864,8 +866,10 @@ void __init mem_init(void)
 	/* this will put all bootmem onto the freelists */
 	totalram_pages += free_all_bootmem();
 
+#ifndef CONFIG_64BIT
 	/* count all remaining LOWMEM and give all HIGHMEM to page allocator */
 	set_non_bootmem_pages_init();
+#endif
 
 	codesize =  (unsigned long)&_etext - (unsigned long)&_text;
 	datasize =  (unsigned long)&_end - (unsigned long)&_sdata;
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 9c6985f..e52bfc8 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -133,15 +133,6 @@ void __set_fixmap(enum fixed_addresses idx, unsigned long phys, pgprot_t flags)
 	set_pte_pfn(address, phys >> PAGE_SHIFT, flags);
 }
 
-#if defined(CONFIG_HIGHPTE)
-pte_t *_pte_offset_map(pmd_t *dir, unsigned long address)
-{
-	pte_t *pte = kmap_atomic(pmd_page(*dir)) +
-		(pmd_ptfn(*dir) << HV_LOG2_PAGE_TABLE_ALIGN) & ~PAGE_MASK;
-	return &pte[pte_index(address)];
-}
-#endif
-
 /**
  * shatter_huge_page() - ensure a given address is mapped by a small page.
  *
@@ -297,10 +288,6 @@ struct page *pgtable_alloc_one(struct mm_struct *mm, unsigned long address,
 	struct page *p;
 	int i;
 
-#ifdef CONFIG_HIGHPTE
-	flags |= __GFP_HIGHMEM;
-#endif
-
 	p = alloc_pages(flags, L2_USER_PGTABLE_ORDER);
 	if (p == NULL)
 		return NULL;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a876871..4531be2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2123,6 +2123,9 @@ static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
 	}
 	entry = pte_mkyoung(entry);
 	entry = pte_mkhuge(entry);
+#ifdef arch_make_huge_pte
+	entry = arch_make_huge_pte(entry, vma, page, writable);
+#endif
 
 	return entry;
 }
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
