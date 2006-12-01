Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB1EA52F075804
	for <linux-mm@kvack.org>; Fri, 1 Dec 2006 14:10:05 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB1EA3sF2658346
	for <linux-mm@kvack.org>; Fri, 1 Dec 2006 14:10:03 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB1EA2wI015476
	for <linux-mm@kvack.org>; Fri, 1 Dec 2006 14:10:03 GMT
Date: Fri, 1 Dec 2006 15:08:25 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [patch/rfc 2/2] vmemmap implementation for s390.
Message-ID: <20061201140825.GC8788@osiris.boeblingen.de.ibm.com>
References: <20061201140542.GA8788@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061201140542.GA8788@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Carsten Otte <cotte@de.ibm.com>
List-ID: <linux-mm.kvack.org>

[S390] vmemmap.

vmemmap implementation for s390 based on ia64's implementation.

Unlike ia64 we need a mechanism which allows us to dynamically attach
shared memory regions.
These memory regions are accessed via the dcss device driver. dcss
implements the 'direct_access' operation, which requires struct pages
for every single shared page.
Therefore this implementation provides an interface to attach/detach
shared memory:

int add_shared_memory(unsigned long start, unsigned long size);
int remove_shared_memory(unsigned long start, unsigned long size);

The purpose of the add_shared_memory function is to add the given
memory range to the 1:1 mapping and to make sure that the
corresponding range in the vmemmap is backed with physical pages.
And of course to initialize the new struct pages.

remove_shared_memory in turn only invalidates the page table
entries in the 1:1 mapping. The page tables and the memory used for
struct pages in the vmemmap are currently not freed. They will be
reused when the next segment will be attached.
Given that the maximum size of shared memory region will be 2GB and
in addition all regions must reside below 2GB this is not too much of
a restriction, but there is room for improvement :)

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/Kconfig          |    3 
 arch/s390/kernel/setup.c   |    2 
 arch/s390/mm/Makefile      |    2 
 arch/s390/mm/extmem.c      |  106 +++---------
 arch/s390/mm/init.c        |  161 ++++---------------
 arch/s390/mm/vmem.c        |  371 +++++++++++++++++++++++++++++++++++++++++++++
 include/asm-s390/page.h    |   22 ++
 include/asm-s390/pgalloc.h |    3 
 include/asm-s390/pgtable.h |   16 +
 9 files changed, 476 insertions(+), 210 deletions(-)

Index: linux-2.6.19-rc6-mm2/arch/s390/mm/init.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/mm/init.c
+++ linux-2.6.19-rc6-mm2/arch/s390/mm/init.c
@@ -84,67 +84,53 @@ void show_mem(void)
         printk("%d pages swap cached\n",cached);
 }
 
+static __init void setup_ro_region(void)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	pte_t new_pte;
+	unsigned long address, end;
+
+	address = ((unsigned long)&__start_rodata) & PAGE_MASK;
+	end = PFN_ALIGN((unsigned long)&__end_rodata);
+
+	for (; address < end; address += PAGE_SIZE) {
+		pgd = pgd_offset_k(address);
+		pmd = pmd_offset(pgd, address);
+		pte = pte_offset_kernel(pmd, address);
+		new_pte = mk_pte_phys(address, __pgprot(_PAGE_RO));
+		set_pte(pte, new_pte);
+	}
+}
+
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
+	setup_ro_region();
 
 	S390_lowcore.kernel_asce = pgdir_k;
 
@@ -154,31 +140,9 @@ void __init paging_init(void)
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
@@ -190,56 +154,7 @@ void __init paging_init(void)
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
@@ -269,6 +184,8 @@ void __init mem_init(void)
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
@@ -815,11 +817,17 @@ static inline pte_t mk_swap_pte(unsigned
 
 #define kern_addr_valid(addr)   (1)
 
+extern int add_shared_memory(unsigned long start, unsigned long size);
+extern int remove_shared_memory(unsigned long start, unsigned long size);
+
 /*
  * No page table caches to initialise
  */
 #define pgtable_cache_init()	do { } while (0)
 
+#define __HAVE_ARCH_MEMMAP_INIT
+extern void memmap_init(unsigned long, int, unsigned long, unsigned long);
+
 #define __HAVE_ARCH_PTEP_ESTABLISH
 #define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
Index: linux-2.6.19-rc6-mm2/arch/s390/mm/extmem.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/mm/extmem.c
+++ linux-2.6.19-rc6-mm2/arch/s390/mm/extmem.c
@@ -16,6 +16,7 @@
 #include <linux/bootmem.h>
 #include <linux/ctype.h>
 #include <asm/page.h>
+#include <asm/pgtable.h>
 #include <asm/ebcdic.h>
 #include <asm/errno.h>
 #include <asm/extmem.h>
@@ -238,65 +239,6 @@ query_segment_type (struct dcss_segment 
 }
 
 /*
- * check if the given segment collides with guest storage.
- * returns 1 if this is the case, 0 if no collision was found
- */
-static int
-segment_overlaps_storage(struct dcss_segment *seg)
-{
-	int i;
-
-	for (i = 0; i < MEMORY_CHUNKS && memory_chunk[i].size > 0; i++) {
-		if (memory_chunk[i].type != CHUNK_READ_WRITE)
-			continue;
-		if ((memory_chunk[i].addr >> 20) > (seg->end >> 20))
-			continue;
-		if (((memory_chunk[i].addr + memory_chunk[i].size - 1) >> 20)
-				< (seg->start_addr >> 20))
-			continue;
-		return 1;
-	}
-	return 0;
-}
-
-/*
- * check if segment collides with other segments that are currently loaded
- * returns 1 if this is the case, 0 if no collision was found
- */
-static int
-segment_overlaps_others (struct dcss_segment *seg)
-{
-	struct list_head *l;
-	struct dcss_segment *tmp;
-
-	BUG_ON(!mutex_is_locked(&dcss_lock));
-	list_for_each(l, &dcss_list) {
-		tmp = list_entry(l, struct dcss_segment, list);
-		if ((tmp->start_addr >> 20) > (seg->end >> 20))
-			continue;
-		if ((tmp->end >> 20) < (seg->start_addr >> 20))
-			continue;
-		if (seg == tmp)
-			continue;
-		return 1;
-	}
-	return 0;
-}
-
-/*
- * check if segment exceeds the kernel mapping range (detected or set via mem=)
- * returns 1 if this is the case, 0 if segment fits into the range
- */
-static inline int
-segment_exceeds_range (struct dcss_segment *seg)
-{
-	int seg_last_pfn = (seg->end) >> PAGE_SHIFT;
-	if (seg_last_pfn > max_pfn)
-		return 1;
-	return 0;
-}
-
-/*
  * get info about a segment
  * possible return values:
  * -ENOSYS  : we are not running on VM
@@ -341,24 +283,26 @@ __segment_load (char *name, int do_nonsh
 	rc = query_segment_type (seg);
 	if (rc < 0)
 		goto out_free;
-	if (segment_exceeds_range(seg)) {
-		PRINT_WARN ("segment_load: not loading segment %s - exceeds"
-				" kernel mapping range\n",name);
-		rc = -ERANGE;
+
+	rc = add_shared_memory(seg->start_addr, seg->end - seg->start_addr + 1);
+
+	switch (rc) {
+	case 0:
+		break;
+	case -ENOSPC:
+		PRINT_WARN("segment_load: not loading segment %s - overlaps "
+			   "storage/segment\n", name);
 		goto out_free;
-	}
-	if (segment_overlaps_storage(seg)) {
-		PRINT_WARN ("segment_load: not loading segment %s - overlaps"
-				" storage\n",name);
-		rc = -ENOSPC;
+	case -ERANGE:
+		PRINT_WARN("segment_load: not loading segment %s - exceeds "
+			   "kernel mapping range\n", name);
 		goto out_free;
-	}
-	if (segment_overlaps_others(seg)) {
-		PRINT_WARN ("segment_load: not loading segment %s - overlaps"
-				" other segments\n",name);
-		rc = -EBUSY;
+	default:
+		PRINT_WARN("segment_load: not loading segment %s (rc: %d)\n",
+			   name, rc);
 		goto out_free;
 	}
+
 	if (do_nonshared)
 		dcss_command = DCSS_LOADNSR;
 	else
@@ -372,7 +316,7 @@ __segment_load (char *name, int do_nonsh
 		rc = dcss_diag_translate_rc (seg->end);
 		dcss_diag(DCSS_PURGESEG, seg->dcss_name,
 				&seg->start_addr, &seg->end);
-		goto out_free;
+		goto out_shared;
 	}
 	seg->do_nonshared = do_nonshared;
 	atomic_set(&seg->ref_count, 1);
@@ -391,6 +335,8 @@ __segment_load (char *name, int do_nonsh
 				(void*)seg->start_addr, (void*)seg->end,
 				segtype_string[seg->vm_segtype]);
 	goto out;
+ out_shared:
+	remove_shared_memory(seg->start_addr, seg->end - seg->start_addr + 1);
  out_free:
 	kfree(seg);
  out:
@@ -530,12 +476,12 @@ segment_unload(char *name)
 				"please report to linux390@de.ibm.com\n",name);
 		goto out_unlock;
 	}
-	if (atomic_dec_return(&seg->ref_count) == 0) {
-		list_del(&seg->list);
-		dcss_diag(DCSS_PURGESEG, seg->dcss_name,
-			  &dummy, &dummy);
-		kfree(seg);
-	}
+	if (atomic_dec_return(&seg->ref_count) != 0)
+		goto out_unlock;
+	remove_shared_memory(seg->start_addr, seg->end - seg->start_addr + 1);
+	list_del(&seg->list);
+	dcss_diag(DCSS_PURGESEG, seg->dcss_name, &dummy, &dummy);
+	kfree(seg);
 out_unlock:
 	mutex_unlock(&dcss_lock);
 }
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
@@ -0,0 +1,371 @@
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
+static DEFINE_MUTEX(vmem_mutex);
+
+struct memory_segment {
+	struct list_head list;
+	unsigned long start;
+	unsigned long size;
+};
+
+static LIST_HEAD(mem_segs);
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
+ * Remove a physical memory range from the 1:1 mapping.
+ * Currently only invalidates page table entries.
+ */
+static void vmem_remove_range(unsigned long start, unsigned long size)
+{
+	unsigned long address;
+	pgd_t *pg_dir;
+	pmd_t *pm_dir;
+	pte_t *pt_dir;
+	pte_t  pte;
+
+	pte_val(pte) = _PAGE_TYPE_EMPTY;
+	for (address = start; address < start + size; address += PAGE_SIZE) {
+		pg_dir = pgd_offset_k(address);
+		if (pgd_none(*pg_dir))
+			continue;
+		pm_dir = pmd_offset(pg_dir, address);
+		if (pmd_none(*pm_dir))
+			continue;
+		pt_dir = pte_offset_kernel(pm_dir, address);
+		set_pte(pt_dir, pte);
+	}
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
+ * Add memory segment to the segment list if it doesn't overlap with
+ * an already present segment.
+ */
+static int insert_memory_segment(struct memory_segment *seg)
+{
+	struct memory_segment *tmp;
+
+	if (PFN_DOWN(seg->start + seg->size) > max_pfn ||
+	    seg->start + seg->size < seg->start)
+		return -ERANGE;
+
+	list_for_each_entry(tmp, &mem_segs, list) {
+		if (seg->start >= tmp->start + tmp->size)
+			continue;
+		if (seg->start + seg->size <= tmp->start)
+			continue;
+		return -ENOSPC;
+	}
+	list_add(&seg->list, &mem_segs);
+	return 0;
+}
+
+/*
+ * Remove memory segment from the segment list.
+ */
+static void remove_memory_segment(struct memory_segment *seg)
+{
+	list_del(&seg->list);
+}
+
+static void __remove_shared_memory(struct memory_segment *seg)
+{
+	remove_memory_segment(seg);
+	vmem_remove_range(seg->start, seg->size);
+}
+
+int remove_shared_memory(unsigned long start, unsigned long size)
+{
+	struct memory_segment *seg;
+	int ret;
+
+	mutex_lock(&vmem_mutex);
+
+	ret = -ENOENT;
+	list_for_each_entry(seg, &mem_segs, list) {
+		if (seg->start == start && seg->size == size)
+			break;
+	}
+
+	if (seg->start != start || seg->size != size)
+		goto out;
+
+	ret = 0;
+	__remove_shared_memory(seg);
+	kfree(seg);
+out:
+	mutex_unlock(&vmem_mutex);
+	return ret;
+}
+
+int add_shared_memory(unsigned long start, unsigned long size)
+{
+	struct memory_segment *seg;
+	struct page *page;
+	unsigned long pfn, num_pfn, end_pfn;
+	int ret;
+
+	mutex_lock(&vmem_mutex);
+	ret = -ENOMEM;
+	seg = kzalloc(sizeof(*seg), GFP_KERNEL);
+	if (!seg)
+		goto out;
+	seg->start = start;
+	seg->size = size;
+
+	ret = insert_memory_segment(seg);
+	if (ret)
+		goto out_free;
+
+	ret = vmem_add_mem(start, size);
+	if (ret)
+		goto out_remove;
+
+	pfn = PFN_DOWN(start);
+	num_pfn = PFN_DOWN(size);
+	end_pfn = pfn + num_pfn;
+
+	page = pfn_to_page(pfn);
+	memset(page, 0, num_pfn * sizeof(struct page));
+
+	for (; pfn < end_pfn; pfn++) {
+		page = pfn_to_page(pfn);
+		init_page_count(page);
+		reset_page_mapcount(page);
+		SetPageReserved(page);
+		INIT_LIST_HEAD(&page->lru);
+	}
+	goto out;
+
+out_remove:
+	__remove_shared_memory(seg);
+out_free:
+	kfree(seg);
+out:
+	mutex_unlock(&vmem_mutex);
+	return ret;
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
+
+/*
+ * Convert memory chunk array to a memory segment list so there is a single
+ * list that contains both r/w memory and shared memory segments.
+ */
+static __init int vmem_convert_memory_chunk(void)
+{
+	struct memory_segment *seg;
+	int i;
+
+	mutex_lock(&vmem_mutex);
+	for (i = 0; i < MEMORY_CHUNKS && memory_chunk[i].size > 0; i++) {
+		if (!memory_chunk[i].size)
+			continue;
+		seg = kzalloc(sizeof(*seg), GFP_KERNEL);
+		if (!seg)
+			panic("Out of memory...\n");
+		seg->start = memory_chunk[i].addr;
+		seg->size = memory_chunk[i].size;
+		insert_memory_segment(seg);
+	}
+	mutex_unlock(&vmem_mutex);
+	return 0;
+}
+
+core_initcall(vmem_convert_memory_chunk);
Index: linux-2.6.19-rc6-mm2/arch/s390/kernel/setup.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/kernel/setup.c
+++ linux-2.6.19-rc6-mm2/arch/s390/kernel/setup.c
@@ -64,7 +64,7 @@ unsigned int console_devno = -1;
 unsigned int console_irq = -1;
 unsigned long machine_flags = 0;
 
-struct mem_chunk memory_chunk[MEMORY_CHUNKS];
+struct mem_chunk __initdata memory_chunk[MEMORY_CHUNKS];
 volatile int __cpu_logical_map[NR_CPUS]; /* logical cpu to cpu address */
 unsigned long __initdata zholes_size[MAX_NR_ZONES];
 static unsigned long __initdata memory_end;
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
