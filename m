Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB4DavHk139596
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:36:57 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB4Dav4k1937498
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:36:57 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB4Dau3P001896
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:36:56 GMT
Date: Mon, 4 Dec 2006 14:36:56 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH/RFC 2/5] basic vmemmap support
Message-ID: <20061204133656.GD9209@osiris.boeblingen.de.ibm.com>
References: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This adds the basic vmem_map support as seen on ia64. As nice side
effect this unifies 31 and 64 bit paging_init().

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/Kconfig          |    3 
 arch/s390/mm/Makefile      |    2 
 arch/s390/mm/init.c        |  140 ++++---------------------------
 arch/s390/mm/vmem.c        |  202 +++++++++++++++++++++++++++++++++++++++++++++
 include/asm-s390/page.h    |   22 ++++
 include/asm-s390/pgalloc.h |    3 
 include/asm-s390/pgtable.h |   13 ++
 7 files changed, 256 insertions(+), 129 deletions(-)

Index: linux-2.6.19-rc6-mm2/arch/s390/mm/init.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/mm/init.c
+++ linux-2.6.19-rc6-mm2/arch/s390/mm/init.c
@@ -85,66 +85,31 @@ void show_mem(void)
 }
 
 extern unsigned long __initdata zholes_size[];
+extern void vmem_map_init(void);
 /*
  * paging_init() sets up the page tables
  */
-
-#ifndef CONFIG_64BIT
 void __init paging_init(void)
 {
-        pgd_t * pg_dir;
-        pte_t * pg_table;
-        pte_t   pte;
-	int     i;
-        unsigned long tmp;
-        unsigned long pfn = 0;
-        unsigned long pgdir_k = (__pa(swapper_pg_dir) & PAGE_MASK) | _KERNSEG_TABLE;
-        static const int ssm_mask = 0x04000000L;
-	unsigned long ro_start_pfn, ro_end_pfn;
+	pgd_t *pg_dir;
+	int i;
+	unsigned long pgdir_k;
+	static const int ssm_mask = 0x04000000L;
 	unsigned long zones_size[MAX_NR_ZONES];
+	unsigned long dma_pfn, high_pfn;
 
-	ro_start_pfn = PFN_DOWN((unsigned long)&__start_rodata);
-	ro_end_pfn = PFN_UP((unsigned long)&__end_rodata);
-
-	memset(zones_size, 0, sizeof(zones_size));
-	zones_size[ZONE_DMA] = max_low_pfn;
-	free_area_init_node(0, &contig_page_data, zones_size,
-			    __pa(PAGE_OFFSET) >> PAGE_SHIFT,
-			    zholes_size);
-
-	/* unmap whole virtual address space */
+	pg_dir = swapper_pg_dir;
 	
-        pg_dir = swapper_pg_dir;
-
+#ifdef CONFIG_64BIT
+	pgdir_k = (__pa(swapper_pg_dir) & PAGE_MASK) | _KERN_REGION_TABLE;
 	for (i = 0; i < PTRS_PER_PGD; i++)
-		pmd_clear((pmd_t *) pg_dir++);
-		
-	/*
-	 * map whole physical memory to virtual memory (identity mapping) 
-	 */
-
-        pg_dir = swapper_pg_dir;
-
-        while (pfn < max_low_pfn) {
-                /*
-                 * pg_table is physical at this point
-                 */
-		pg_table = (pte_t *) alloc_bootmem_pages(PAGE_SIZE);
-
-		pmd_populate_kernel(&init_mm, (pmd_t *) pg_dir, pg_table);
-                pg_dir++;
-
-                for (tmp = 0 ; tmp < PTRS_PER_PTE ; tmp++,pg_table++) {
-			if (pfn >= ro_start_pfn && pfn < ro_end_pfn)
-				pte = pfn_pte(pfn, __pgprot(_PAGE_RO));
-			else
-				pte = pfn_pte(pfn, PAGE_KERNEL);
-                        if (pfn >= max_low_pfn)
-				pte_val(pte) = _PAGE_TYPE_EMPTY;
-			set_pte(pg_table, pte);
-                        pfn++;
-                }
-        }
+		pgd_clear(pg_dir + i);
+#else
+	pgdir_k = (__pa(swapper_pg_dir) & PAGE_MASK) | _KERNSEG_TABLE;
+	for (i = 0; i < PTRS_PER_PGD; i++)
+		pmd_clear((pmd_t *)(pg_dir + i));
+#endif
+	vmem_map_init();
 
 	S390_lowcore.kernel_asce = pgdir_k;
 
@@ -154,31 +119,9 @@ void __init paging_init(void)
 	__ctl_load(pgdir_k, 13, 13);
 	__raw_local_irq_ssm(ssm_mask);
 
-        local_flush_tlb();
-}
-
-#else /* CONFIG_64BIT */
-
-void __init paging_init(void)
-{
-        pgd_t * pg_dir;
-	pmd_t * pm_dir;
-        pte_t * pt_dir;
-        pte_t   pte;
-	int     i,j,k;
-        unsigned long pfn = 0;
-        unsigned long pgdir_k = (__pa(swapper_pg_dir) & PAGE_MASK) |
-          _KERN_REGION_TABLE;
-	static const int ssm_mask = 0x04000000L;
-	unsigned long zones_size[MAX_NR_ZONES];
-	unsigned long dma_pfn, high_pfn;
-	unsigned long ro_start_pfn, ro_end_pfn;
-
 	memset(zones_size, 0, sizeof(zones_size));
 	dma_pfn = MAX_DMA_ADDRESS >> PAGE_SHIFT;
 	high_pfn = max_low_pfn;
-	ro_start_pfn = PFN_DOWN((unsigned long)&__start_rodata);
-	ro_end_pfn = PFN_UP((unsigned long)&__end_rodata);
 
 	if (dma_pfn > high_pfn)
 		zones_size[ZONE_DMA] = high_pfn;
@@ -190,56 +133,7 @@ void __init paging_init(void)
 	/* Initialize mem_map[].  */
 	free_area_init_node(0, &contig_page_data, zones_size,
 			    __pa(PAGE_OFFSET) >> PAGE_SHIFT, zholes_size);
-
-	/*
-	 * map whole physical memory to virtual memory (identity mapping) 
-	 */
-
-        pg_dir = swapper_pg_dir;
-	
-        for (i = 0 ; i < PTRS_PER_PGD ; i++,pg_dir++) {
-	
-                if (pfn >= max_low_pfn) {
-                        pgd_clear(pg_dir);
-                        continue;
-                }          
-        
-		pm_dir = (pmd_t *) alloc_bootmem_pages(PAGE_SIZE * 4);
-                pgd_populate(&init_mm, pg_dir, pm_dir);
-
-                for (j = 0 ; j < PTRS_PER_PMD ; j++,pm_dir++) {
-                        if (pfn >= max_low_pfn) {
-                                pmd_clear(pm_dir);
-                                continue; 
-                        }          
-                        
-			pt_dir = (pte_t *) alloc_bootmem_pages(PAGE_SIZE);
-                        pmd_populate_kernel(&init_mm, pm_dir, pt_dir);
-	
-                        for (k = 0 ; k < PTRS_PER_PTE ; k++,pt_dir++) {
-				if (pfn >= ro_start_pfn && pfn < ro_end_pfn)
-					pte = pfn_pte(pfn, __pgprot(_PAGE_RO));
-				else
-					pte = pfn_pte(pfn, PAGE_KERNEL);
-				if (pfn >= max_low_pfn)
-					pte_val(pte) = _PAGE_TYPE_EMPTY;
-                                set_pte(pt_dir, pte);
-                                pfn++;
-                        }
-                }
-        }
-
-	S390_lowcore.kernel_asce = pgdir_k;
-
-        /* enable virtual mapping in kernel mode */
-	__ctl_load(pgdir_k, 1, 1);
-	__ctl_load(pgdir_k, 7, 7);
-	__ctl_load(pgdir_k, 13, 13);
-	__raw_local_irq_ssm(ssm_mask);
-
-        local_flush_tlb();
 }
-#endif /* CONFIG_64BIT */
 
 void __init mem_init(void)
 {
@@ -269,6 +163,8 @@ void __init mem_init(void)
 	printk("Write protected kernel read-only data: %#lx - %#lx\n",
 	       (unsigned long)&__start_rodata,
 	       PFN_ALIGN((unsigned long)&__end_rodata) - 1);
+	printk("Virtual mem_map size: %ldk\n",
+	       (max_pfn * sizeof(struct page)) >> 10);
 }
 
 void free_initmem(void)
Index: linux-2.6.19-rc6-mm2/include/asm-s390/pgtable.h
===================================================================
--- linux-2.6.19-rc6-mm2.orig/include/asm-s390/pgtable.h
+++ linux-2.6.19-rc6-mm2/include/asm-s390/pgtable.h
@@ -107,23 +107,25 @@ extern char empty_zero_page[PAGE_SIZE];
  * The vmalloc() routines leaves a hole of 4kB between each vmalloced
  * area for the same reason. ;)
  */
+extern unsigned long vmalloc_end;
 #define VMALLOC_OFFSET  (8*1024*1024)
 #define VMALLOC_START   (((unsigned long) high_memory + VMALLOC_OFFSET) \
 			 & ~(VMALLOC_OFFSET-1))
+#define VMALLOC_END	vmalloc_end
 
 /*
  * We need some free virtual space to be able to do vmalloc.
  * VMALLOC_MIN_SIZE defines the minimum size of the vmalloc
  * area. On a machine with 2GB memory we make sure that we
  * have at least 128MB free space for vmalloc. On a machine
- * with 4TB we make sure we have at least 1GB.
+ * with 4TB we make sure we have at least 128GB.
  */
 #ifndef __s390x__
 #define VMALLOC_MIN_SIZE	0x8000000UL
-#define VMALLOC_END		0x80000000UL
+#define VMALLOC_END_INIT	0x80000000UL
 #else /* __s390x__ */
-#define VMALLOC_MIN_SIZE	0x40000000UL
-#define VMALLOC_END		0x40000000000UL
+#define VMALLOC_MIN_SIZE	0x2000000000UL
+#define VMALLOC_END_INIT	0x40000000000UL
 #endif /* __s390x__ */
 
 /*
@@ -820,6 +822,9 @@ static inline pte_t mk_swap_pte(unsigned
  */
 #define pgtable_cache_init()	do { } while (0)
 
+#define __HAVE_ARCH_MEMMAP_INIT
+extern void memmap_init(unsigned long, int, unsigned long, unsigned long);
+
 #define __HAVE_ARCH_PTEP_ESTABLISH
 #define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
Index: linux-2.6.19-rc6-mm2/include/asm-s390/page.h
===================================================================
--- linux-2.6.19-rc6-mm2.orig/include/asm-s390/page.h
+++ linux-2.6.19-rc6-mm2/include/asm-s390/page.h
@@ -127,6 +127,26 @@ page_get_storage_key(unsigned long addr)
 	return skey;
 }
 
+extern unsigned long max_pfn;
+
+static inline int pfn_valid(unsigned long pfn)
+{
+	unsigned long dummy;
+	int ccode;
+
+	if (pfn >= max_pfn)
+		return 0;
+
+	asm volatile(
+		"	lra	%0,0(%2)\n"
+		"	ipm	%1\n"
+		"	srl	%1,28\n"
+		: "=d" (dummy), "=d" (ccode)
+		: "a" (pfn << PAGE_SHIFT)
+		: "cc");
+	return !ccode;
+}
+
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
@@ -138,8 +158,6 @@ page_get_storage_key(unsigned long addr)
 #define __va(x)                 (void *)(unsigned long)(x)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
-
-#define pfn_valid(pfn)		((pfn) < max_mapnr)
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
 #define VM_DATA_DEFAULT_FLAGS	(VM_READ | VM_WRITE | VM_EXEC | \
Index: linux-2.6.19-rc6-mm2/arch/s390/Kconfig
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/Kconfig
+++ linux-2.6.19-rc6-mm2/arch/s390/Kconfig
@@ -247,6 +247,9 @@ config WARN_STACK_SIZE
 
 source "mm/Kconfig"
 
+config HOLES_IN_ZONE
+	def_bool y
+
 comment "I/O subsystem configuration"
 
 config MACHCHK_WARNING
Index: linux-2.6.19-rc6-mm2/arch/s390/mm/Makefile
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/mm/Makefile
+++ linux-2.6.19-rc6-mm2/arch/s390/mm/Makefile
@@ -2,6 +2,6 @@
 # Makefile for the linux s390-specific parts of the memory manager.
 #
 
-obj-y	 := init.o fault.o ioremap.o extmem.o mmap.o
+obj-y	 := init.o fault.o ioremap.o extmem.o mmap.o vmem.o
 obj-$(CONFIG_CMM) += cmm.o
 
Index: linux-2.6.19-rc6-mm2/arch/s390/mm/vmem.c
===================================================================
--- /dev/null
+++ linux-2.6.19-rc6-mm2/arch/s390/mm/vmem.c
@@ -0,0 +1,202 @@
+/*
+ *  arch/s390/mm/vmem.c
+ *
+ *    Copyright IBM Corp. 2006
+ *    Author(s): Heiko Carstens <heiko.carstens@de.ibm.com>
+ */
+
+#include <linux/bootmem.h>
+#include <linux/pfn.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/list.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
+#include <asm/setup.h>
+
+unsigned long vmalloc_end;
+EXPORT_SYMBOL(vmalloc_end);
+
+static struct page *vmem_map;
+
+void memmap_init(unsigned long size, int nid, unsigned long zone,
+		 unsigned long start_pfn)
+{
+	struct page *start, *end;
+	struct page *map_start, *map_end;
+	int i;
+
+	start = pfn_to_page(start_pfn);
+	end = start + size;
+
+	for (i = 0; i < MEMORY_CHUNKS && memory_chunk[i].size > 0; i++) {
+		unsigned long cstart, cend;
+
+		cstart = __pa(memory_chunk[i].addr) >> PAGE_SHIFT;
+		cend = cstart + (memory_chunk[i].size >> PAGE_SHIFT);
+
+		map_start = mem_map + cstart;
+		map_end = mem_map + cend;
+
+		if (map_start < start)
+			map_start = start;
+		if (map_end > end)
+			map_end = end;
+
+		map_start -= ((unsigned long) map_start & (PAGE_SIZE - 1))
+			/ sizeof(struct page);
+		map_end += ((PAGE_ALIGN((unsigned long) map_end)
+			     - (unsigned long) map_end)
+			    / sizeof(struct page));
+
+		if (map_start < map_end)
+			memmap_init_zone((unsigned long)(map_end - map_start),
+					 nid, zone, page_to_pfn(map_start));
+	}
+}
+
+static inline void *vmem_alloc_pages(unsigned int order)
+{
+	if (slab_is_available())
+		return (void *)__get_free_pages(GFP_KERNEL, order);
+	return alloc_bootmem_pages((1 << order) * PAGE_SIZE);
+}
+
+static inline pmd_t *vmem_pmd_alloc(void)
+{
+	pmd_t *pmd;
+	int i;
+
+	pmd = vmem_alloc_pages(PMD_ALLOC_ORDER);
+	if (!pmd)
+		return NULL;
+	for (i = 0; i < PTRS_PER_PMD; i++)
+		pmd_clear(pmd + i);
+	return pmd;
+}
+
+static inline pte_t *vmem_pte_alloc(void)
+{
+	pte_t *pte;
+	pte_t empty_pte;
+	int i;
+
+	pte = vmem_alloc_pages(PTE_ALLOC_ORDER);
+	if (!pte)
+		return NULL;
+	pte_val(empty_pte) = _PAGE_TYPE_EMPTY;
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		set_pte(pte + i, empty_pte);
+	return pte;
+}
+
+/*
+ * Add a physical memory range to the 1:1 mapping.
+ */
+static int vmem_add_range(unsigned long start, unsigned long size)
+{
+	unsigned long address;
+	pgd_t *pg_dir;
+	pmd_t *pm_dir;
+	pte_t *pt_dir;
+	pte_t  pte;
+
+	for (address = start; address < start + size; address += PAGE_SIZE) {
+		pg_dir = pgd_offset_k(address);
+		if (pgd_none(*pg_dir)) {
+			pm_dir = vmem_pmd_alloc();
+			if (!pm_dir)
+				return -ENOMEM;
+			pgd_populate(&init_mm, pg_dir, pm_dir);
+		}
+
+		pm_dir = pmd_offset(pg_dir, address);
+		if (pmd_none(*pm_dir)) {
+			pt_dir = vmem_pte_alloc();
+			if (!pt_dir)
+				return -ENOMEM;
+			pmd_populate_kernel(&init_mm, pm_dir, pt_dir);
+		}
+
+		pt_dir = pte_offset_kernel(pm_dir, address);
+		pte = pfn_pte(address >> PAGE_SHIFT, PAGE_KERNEL);
+		set_pte(pt_dir, pte);
+	}
+	return 0;
+}
+
+/*
+ * Add a backed mem_map array to the virtual mem_map array.
+ */
+static int vmem_add_mem_map(unsigned long start, unsigned long size)
+{
+	unsigned long address, start_page, end_page;
+	struct page *map_start, *map_end;
+	pgd_t *pg_dir;
+	pmd_t *pm_dir;
+	pte_t *pt_dir;
+	pte_t  pte;
+
+	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
+	map_end	= vmem_map + (__pa(start + size) >> PAGE_SHIFT);
+
+	start_page = (unsigned long) map_start & PAGE_MASK;
+	end_page = PAGE_ALIGN((unsigned long) map_end);
+
+	for (address = start_page; address < end_page; address += PAGE_SIZE) {
+		pg_dir = pgd_offset_k(address);
+		if (pgd_none(*pg_dir)) {
+			pm_dir = vmem_pmd_alloc();
+			if (!pm_dir)
+				return -ENOMEM;
+			pgd_populate(&init_mm, pg_dir, pm_dir);
+		}
+
+		pm_dir = pmd_offset(pg_dir, address);
+		if (pmd_none(*pm_dir)) {
+			pt_dir = vmem_pte_alloc();
+			if (!pt_dir)
+				return -ENOMEM;
+			pmd_populate_kernel(&init_mm, pm_dir, pt_dir);
+		}
+
+		pt_dir = pte_offset_kernel(pm_dir, address);
+		if (pte_none(*pt_dir)) {
+			unsigned long new_page;
+
+			new_page =__pa(vmem_alloc_pages(0));
+			if (!new_page)
+				return -ENOMEM;
+			pte = pfn_pte(new_page >> PAGE_SHIFT, PAGE_KERNEL);
+			set_pte(pt_dir, pte);
+		}
+	}
+	return 0;
+}
+
+static int vmem_add_mem(unsigned long start, unsigned long size)
+{
+	int ret;
+
+	ret = vmem_add_range(start, size);
+	if (ret)
+		return ret;
+	return vmem_add_mem_map(start, size);
+}
+
+/*
+ * map whole physical memory to virtual memory (identity mapping)
+ */
+void __init vmem_map_init(void)
+{
+	unsigned long map_size;
+	int i;
+
+	map_size = max_pfn * sizeof(struct page);
+	vmalloc_end = PFN_ALIGN(VMALLOC_END_INIT) - PFN_ALIGN(map_size);
+	vmem_map = (struct page *) vmalloc_end;
+	NODE_DATA(0)->node_mem_map = vmem_map;
+
+	for (i = 0; i < MEMORY_CHUNKS && memory_chunk[i].size > 0; i++)
+		vmem_add_mem(memory_chunk[i].addr, memory_chunk[i].size);
+}
Index: linux-2.6.19-rc6-mm2/include/asm-s390/pgalloc.h
===================================================================
--- linux-2.6.19-rc6-mm2.orig/include/asm-s390/pgalloc.h
+++ linux-2.6.19-rc6-mm2/include/asm-s390/pgalloc.h
@@ -25,8 +25,11 @@ extern void diag10(unsigned long addr);
  * Page allocation orders.
  */
 #ifndef __s390x__
+# define PTE_ALLOC_ORDER	0
+# define PMD_ALLOC_ORDER	0
 # define PGD_ALLOC_ORDER	1
 #else /* __s390x__ */
+# define PTE_ALLOC_ORDER	0
 # define PMD_ALLOC_ORDER	2
 # define PGD_ALLOC_ORDER	2
 #endif /* __s390x__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
