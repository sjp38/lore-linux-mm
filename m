Received: from toomuch.toronto.redhat.com (toomuch.toronto.redhat.com [172.16.14.22])
	by touchme.toronto.redhat.com (Postfix) with ESMTP id B109E800075
	for <linux-mm@kvack.org>; Mon, 25 Nov 2002 17:12:23 -0500 (EST)
Received: (from bcrl@localhost)
	by toomuch.toronto.redhat.com (8.11.6/8.11.6) id gAPMCNg04831
	for linux-mm@kvack.org; Mon, 25 Nov 2002 17:12:23 -0500
Date: Mon, 25 Nov 2002 17:12:23 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: [RFT] rmap15-ptehighmem
Message-ID: <20021125171223.A4824@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hey folks,

Below is a backport of ptehighmem from 2.5 against rmap15.  So far it has 
passed a few quick and dirty tests, but it's looking reasonably good.  I 
tried to stick as close to 2.5 as possible -- rmap.c and pgtable.c are both 
almost unmodified from the code that is in 2.5, so we get the direct rmap 
pointer optimization from 2.5 for free.  The one last niggle that needs to 
be sorted is the disabling of the fast page table cache.  I'm going on 
vacation for a couple of weeks, so unless someone else wants to fix that 
up, I'll do so on return.  Bug reports and fixes welcome!

		-ben
-- 
"Do you seek knowledge in time travel?"

:r ~/patches/v2.4/v2.4.19-rmap15-ptehighmem.diff
diff -urN linux-2.4-rmap/Changelog.rmap work/Changelog.rmap
--- linux-2.4-rmap/Changelog.rmap	Mon Nov 25 17:05:26 2002
+++ work/Changelog.rmap	Mon Nov 25 17:03:42 2002
@@ -10,12 +10,15 @@
 
 My big TODO items for a next release are:
   - backport speedups from 2.5
-  - pte-highmem
 
+rmap 15ptehighmem:
+  - merge with rmap 14c-ptehighmem			  (Benjamin LaHaise)
 rmap 15:
   - small code cleanups and spelling fixes for O(1) VM    (me)
   - O(1) page launder, O(1) page aging                    (Arjan van de Ven)
   - resync code with -ac (12 small patches)               (me)
+rmap 14c-ptehighmem:
+  - incorporate ptehighmem based on 2.5			  (Benjamin LaHaise)
 rmap 14c:
   - fold page_over_rsslimit() into page_referenced()      (me)
   - 2.5 backport: get pte_chains from the slab cache      (William Lee Irwin)
diff -urN linux-2.4-rmap/Makefile work/Makefile
--- linux-2.4-rmap/Makefile	Mon Nov 25 17:05:26 2002
+++ work/Makefile	Mon Nov 25 17:03:42 2002
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 4
 SUBLEVEL = 19
-EXTRAVERSION = -rmap15
+EXTRAVERSION = -rmap15ptehighmem
 
 KERNELRELEASE=$(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)
 
diff -urN linux-2.4-rmap/arch/i386/config.in work/arch/i386/config.in
--- linux-2.4-rmap/arch/i386/config.in	Mon Nov 25 17:05:28 2002
+++ work/arch/i386/config.in	Mon Nov 25 17:03:44 2002
@@ -179,10 +179,12 @@
 	 64GB   CONFIG_HIGHMEM64G" off
 if [ "$CONFIG_HIGHMEM4G" = "y" ]; then
    define_bool CONFIG_HIGHMEM y
+   define_bool CONFIG_HIGHPTE y
 fi
 if [ "$CONFIG_HIGHMEM64G" = "y" ]; then
    define_bool CONFIG_HIGHMEM y
    define_bool CONFIG_X86_PAE y
+   define_bool CONFIG_HIGHPTE y
 fi
 
 bool 'Math emulation' CONFIG_MATH_EMULATION
diff -urN linux-2.4-rmap/arch/i386/kernel/traps.c work/arch/i386/kernel/traps.c
--- linux-2.4-rmap/arch/i386/kernel/traps.c	Mon Nov 25 17:05:28 2002
+++ work/arch/i386/kernel/traps.c	Mon Nov 25 17:03:44 2002
@@ -773,7 +773,7 @@
 	page = (unsigned long) vmalloc(PAGE_SIZE);
 	pgd = pgd_offset(&init_mm, page);
 	pmd = pmd_offset(pgd, page);
-	pte = pte_offset(pmd, page);
+	pte = pte_offset_kernel(pmd, page);
 	__free_page(pte_page(*pte));
 	*pte = mk_pte_phys(__pa(&idt_table), PAGE_KERNEL_RO);
 	/*
diff -urN linux-2.4-rmap/arch/i386/kernel/vm86.c work/arch/i386/kernel/vm86.c
--- linux-2.4-rmap/arch/i386/kernel/vm86.c	Mon Nov 25 17:05:28 2002
+++ work/arch/i386/kernel/vm86.c	Mon Nov 25 17:03:44 2002
@@ -39,6 +39,7 @@
 #include <linux/mm.h>
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
+#include <linux/highmem.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
@@ -121,7 +122,7 @@
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
-	pte_t *pte;
+	pte_t *pte, *mapped;
 	int i;
 
 	spin_lock(&tsk->mm->page_table_lock);
@@ -141,12 +142,13 @@
 		pmd_clear(pmd);
 		goto out;
 	}
-	pte = pte_offset(pmd, 0xA0000);
+	mapped = pte = pte_offset_map(pmd, 0xA0000);
 	for (i = 0; i < 32; i++) {
 		if (pte_present(*pte))
-			set_pte(pte, pte_wrprotect(*pte));
+			ptep_set_wrprotect(pte);
 		pte++;
 	}
+	pte_unmap(mapped);
 out:
 	spin_unlock(&tsk->mm->page_table_lock);
 	flush_tlb();
diff -urN linux-2.4-rmap/arch/i386/mm/Makefile work/arch/i386/mm/Makefile
--- linux-2.4-rmap/arch/i386/mm/Makefile	Mon Nov 25 17:05:28 2002
+++ work/arch/i386/mm/Makefile	Mon Nov 25 17:03:44 2002
@@ -10,5 +10,6 @@
 O_TARGET := mm.o
 
 obj-y	 := init.o fault.o ioremap.o extable.o
+obj-y += pgtable.o
 
 include $(TOPDIR)/Rules.make
diff -urN linux-2.4-rmap/arch/i386/mm/fault.c work/arch/i386/mm/fault.c
--- linux-2.4-rmap/arch/i386/mm/fault.c	Mon Nov 25 17:05:28 2002
+++ work/arch/i386/mm/fault.c	Mon Nov 25 17:03:44 2002
@@ -395,7 +395,7 @@
 			goto no_context;
 		set_pmd(pmd, *pmd_k);
 
-		pte_k = pte_offset(pmd_k, address);
+		pte_k = pte_offset_kernel(pmd_k, address);
 		if (!pte_present(*pte_k))
 			goto no_context;
 		return;
diff -urN linux-2.4-rmap/arch/i386/mm/init.c work/arch/i386/mm/init.c
--- linux-2.4-rmap/arch/i386/mm/init.c	Mon Nov 25 17:05:28 2002
+++ work/arch/i386/mm/init.c	Mon Nov 25 17:03:44 2002
@@ -45,6 +45,8 @@
 
 int do_check_pgt_cache(int low, int high)
 {
+	return 0;	/* FIXME! */
+#if 0
 	int freed = 0;
 	if(pgtable_cache_size > high) {
 		do {
@@ -63,6 +65,7 @@
 		} while(pgtable_cache_size > low);
 	}
 	return freed;
+#endif
 }
 
 /*
@@ -76,7 +79,7 @@
 pgprot_t kmap_prot;
 
 #define kmap_get_fixmap_pte(vaddr)					\
-	pte_offset(pmd_offset(pgd_offset_k(vaddr), (vaddr)), (vaddr))
+	pte_offset_kernel(pmd_offset(pgd_offset_k(vaddr), (vaddr)), (vaddr))
 
 void __init kmap_init(void)
 {
@@ -90,36 +93,6 @@
 }
 #endif /* CONFIG_HIGHMEM */
 
-void show_mem(void)
-{
-	int i, total = 0, reserved = 0;
-	int shared = 0, cached = 0;
-	int highmem = 0;
-
-	printk("Mem-info:\n");
-	show_free_areas();
-	printk("Free swap:       %6dkB\n",nr_swap_pages<<(PAGE_SHIFT-10));
-	i = max_mapnr;
-	while (i-- > 0) {
-		total++;
-		if (PageHighMem(mem_map+i))
-			highmem++;
-		if (PageReserved(mem_map+i))
-			reserved++;
-		else if (PageSwapCache(mem_map+i))
-			cached++;
-		else if (page_count(mem_map+i))
-			shared += page_count(mem_map+i) - 1;
-	}
-	printk("%d pages of RAM\n", total);
-	printk("%d pages of HIGHMEM\n",highmem);
-	printk("%d reserved pages\n",reserved);
-	printk("%d pages shared\n",shared);
-	printk("%d pages swap cached\n",cached);
-	printk("%ld pages in page table cache\n",pgtable_cache_size);
-	show_buffers();
-}
-
 /* References to section boundaries */
 
 extern char _text, _etext, _edata, __bss_start, _end;
@@ -142,7 +115,7 @@
 		printk("PAE BUG #01!\n");
 		return;
 	}
-	pte = pte_offset(pmd, vaddr);
+	pte = pte_offset_kernel(pmd, vaddr);
 	/* <phys,flags> stored as-is, to permit clearing entries */
 	set_pte(pte, mk_pte_phys(phys, flags));
 
@@ -153,17 +126,6 @@
 	__flush_tlb_one(vaddr);
 }
 
-void __set_fixmap (enum fixed_addresses idx, unsigned long phys, pgprot_t flags)
-{
-	unsigned long address = __fix_to_virt(idx);
-
-	if (idx >= __end_of_fixed_addresses) {
-		printk("Invalid __set_fixmap\n");
-		return;
-	}
-	set_pte_phys(address, phys, flags);
-}
-
 static void __init fixrange_init (unsigned long start, unsigned long end, pgd_t *pgd_base)
 {
 	pgd_t *pgd;
@@ -193,7 +155,7 @@
 			if (pmd_none(*pmd)) {
 				pte = (pte_t *) alloc_bootmem_low_pages(PAGE_SIZE);
 				set_pmd(pmd, __pmd(_KERNPG_TABLE + __pa(pte)));
-				if (pte != pte_offset(pmd, 0))
+				if (pte != pte_offset_kernel(pmd, 0))
 					BUG();
 			}
 			vaddr += PMD_SIZE;
@@ -264,7 +226,7 @@
 				*pte = mk_pte_phys(__pa(vaddr), PAGE_KERNEL);
 			}
 			set_pmd(pmd, __pmd(_KERNPG_TABLE + __pa(pte_base)));
-			if (pte_base != pte_offset(pmd, 0))
+			if (pte_base != pte_offset_kernel(pmd, 0))
 				BUG();
 
 		}
@@ -286,7 +248,7 @@
 
 	pgd = swapper_pg_dir + __pgd_offset(vaddr);
 	pmd = pmd_offset(pgd, vaddr);
-	pte = pte_offset(pmd, vaddr);
+	pte = pte_offset_kernel(pmd, vaddr);
 	pkmap_page_table = pte;
 #endif
 
@@ -395,7 +357,7 @@
 
 	pgd = swapper_pg_dir + __pgd_offset(vaddr);
 	pmd = pmd_offset(pgd, vaddr);
-	pte = pte_offset(pmd, vaddr);
+	pte = pte_offset_kernel(pmd, vaddr);
 	old_pte = *pte;
 	*pte = mk_pte_phys(0, PAGE_READONLY);
 	local_flush_tlb();
diff -urN linux-2.4-rmap/arch/i386/mm/ioremap.c work/arch/i386/mm/ioremap.c
--- linux-2.4-rmap/arch/i386/mm/ioremap.c	Mon Nov 25 17:05:28 2002
+++ work/arch/i386/mm/ioremap.c	Mon Nov 25 17:03:44 2002
@@ -49,7 +49,7 @@
 	if (address >= end)
 		BUG();
 	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
+		pte_t * pte = pte_alloc_kernel(&init_mm, pmd, address);
 		if (!pte)
 			return -ENOMEM;
 		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
diff -urN linux-2.4-rmap/arch/i386/mm/pgtable.c work/arch/i386/mm/pgtable.c
--- linux-2.4-rmap/arch/i386/mm/pgtable.c	Wed Dec 31 19:00:00 1969
+++ work/arch/i386/mm/pgtable.c	Mon Nov 25 17:03:44 2002
@@ -0,0 +1,226 @@
+/*
+ *  linux/arch/i386/mm/pgtable.c
+ */
+
+#include <linux/config.h>
+#include <linux/sched.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/smp.h>
+#include <linux/highmem.h>
+#include <linux/slab.h>
+
+#include <asm/system.h>
+#include <asm/pgtable.h>
+#include <asm/pgalloc.h>
+#include <asm/fixmap.h>
+#include <asm/e820.h>
+#include <asm/tlb.h>
+//#include <asm/tlbflush.h>
+
+void show_mem(void)
+{
+	int total = 0, reserved = 0;
+	int shared = 0, cached = 0;
+	int highmem = 0;
+	struct page *page;
+	pg_data_t *pgdat;
+	unsigned long i;
+
+	printk("Mem-info:\n");
+	show_free_areas();
+	printk("Free swap:       %6dkB\n",nr_swap_pages<<(PAGE_SHIFT-10));
+	for_each_pgdat(pgdat) {
+		for (i = 0; i < pgdat->node_size; ++i) {
+			page = pgdat->node_mem_map + i;
+			total++;
+			if (PageHighMem(page))
+				highmem++;
+			if (PageReserved(page))
+				reserved++;
+			else if (PageSwapCache(page))
+				cached++;
+			else if (page_count(page))
+				shared += page_count(page) - 1;
+		}
+	}
+	printk("%d pages of RAM\n", total);
+	printk("%d pages of HIGHMEM\n",highmem);
+	printk("%d reserved pages\n",reserved);
+	printk("%d pages shared\n",shared);
+	printk("%d pages swap cached\n",cached);
+}
+
+/*
+ * Associate a virtual page frame with a given physical page frame 
+ * and protection flags for that frame.
+ */ 
+static void set_pte_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	pgd = swapper_pg_dir + __pgd_offset(vaddr);
+	if (pgd_none(*pgd)) {
+		BUG();
+		return;
+	}
+	pmd = pmd_offset(pgd, vaddr);
+	if (pmd_none(*pmd)) {
+		BUG();
+		return;
+	}
+	pte = pte_offset_kernel(pmd, vaddr);
+	/* <pfn,flags> stored as-is, to permit clearing entries */
+	set_pte(pte, pfn_pte(pfn, flags));
+
+	/*
+	 * It's enough to flush this one mapping.
+	 * (PGE mappings get flushed as well)
+	 */
+	__flush_tlb_one(vaddr);
+}
+
+/*
+ * Associate a large virtual page frame with a given physical page frame 
+ * and protection flags for that frame. pfn is for the base of the page,
+ * vaddr is what the page gets mapped to - both must be properly aligned. 
+ * The pmd must already be instantiated. Assumes PAE mode.
+ */ 
+void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+
+	if (vaddr & (PMD_SIZE-1)) {		/* vaddr is misaligned */
+		printk ("set_pmd_pfn: vaddr misaligned\n");
+		return; /* BUG(); */
+	}
+	if (pfn & (PTRS_PER_PTE-1)) {		/* pfn is misaligned */
+		printk ("set_pmd_pfn: pfn misaligned\n");
+		return; /* BUG(); */
+	}
+	pgd = swapper_pg_dir + __pgd_offset(vaddr);
+	if (pgd_none(*pgd)) {
+		printk ("set_pmd_pfn: pgd_none\n");
+		return; /* BUG(); */
+	}
+	pmd = pmd_offset(pgd, vaddr);
+	set_pmd(pmd, pfn_pmd(pfn, flags));
+	/*
+	 * It's enough to flush this one mapping.
+	 * (PGE mappings get flushed as well)
+	 */
+	__flush_tlb_one(vaddr);
+}
+
+void __set_fixmap (enum fixed_addresses idx, unsigned long phys, pgprot_t flags)
+{
+	unsigned long address = __fix_to_virt(idx);
+
+	if (idx >= __end_of_fixed_addresses) {
+		BUG();
+		return;
+	}
+	set_pte_pfn(address, phys >> PAGE_SHIFT, flags);
+}
+
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+	int count = 0;
+	pte_t *pte;
+   
+   	do {
+		pte = (pte_t *) __get_free_page(GFP_KERNEL);
+		if (pte)
+			clear_page(pte);
+		else {
+			current->state = TASK_UNINTERRUPTIBLE;
+			schedule_timeout(HZ);
+		}
+	} while (!pte && (count++ < 10));
+	return pte;
+}
+
+struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+	int count = 0;
+	struct page *pte;
+   
+   	do {
+#if CONFIG_HIGHPTE
+		pte = alloc_pages(GFP_KERNEL | __GFP_HIGHMEM, 0);
+#else
+		pte = alloc_pages(GFP_KERNEL, 0);
+#endif
+		if (pte)
+			clear_highpage(pte);
+		else {
+			current->state = TASK_UNINTERRUPTIBLE;
+			schedule_timeout(HZ);
+		}
+	} while (!pte && (count++ < 10));
+	return pte;
+}
+
+#if CONFIG_X86_PAE
+
+pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	int i;
+	pgd_t *pgd = kmem_cache_alloc(pae_pgd_cachep, GFP_KERNEL);
+
+	if (pgd) {
+		for (i = 0; i < USER_PTRS_PER_PGD; i++) {
+			unsigned long pmd = __get_free_page(GFP_KERNEL);
+			if (!pmd)
+				goto out_oom;
+			clear_page(pmd);
+			set_pgd(pgd + i, __pgd(1 + __pa(pmd)));
+		}
+		memcpy(pgd + USER_PTRS_PER_PGD,
+			swapper_pg_dir + USER_PTRS_PER_PGD,
+			(PTRS_PER_PGD - USER_PTRS_PER_PGD) * sizeof(pgd_t));
+	}
+	return pgd;
+out_oom:
+	for (i--; i >= 0; i--)
+		free_page((unsigned long)__va(pgd_val(pgd[i])-1));
+	kmem_cache_free(pae_pgd_cachep, pgd);
+	return NULL;
+}
+
+void pgd_free(pgd_t *pgd)
+{
+	int i;
+
+	for (i = 0; i < USER_PTRS_PER_PGD; i++)
+		free_page((unsigned long)__va(pgd_val(pgd[i])-1));
+	kmem_cache_free(pae_pgd_cachep, pgd);
+}
+
+#else
+
+pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL);
+
+	if (pgd) {
+		memset(pgd, 0, USER_PTRS_PER_PGD * sizeof(pgd_t));
+		memcpy(pgd + USER_PTRS_PER_PGD,
+			swapper_pg_dir + USER_PTRS_PER_PGD,
+			(PTRS_PER_PGD - USER_PTRS_PER_PGD) * sizeof(pgd_t));
+	}
+	return pgd;
+}
+
+void pgd_free(pgd_t *pgd)
+{
+	free_page((unsigned long)pgd);
+}
+
+#endif /* CONFIG_X86_PAE */
+
diff -urN linux-2.4-rmap/drivers/char/drm/drm_proc.h work/drivers/char/drm/drm_proc.h
--- linux-2.4-rmap/drivers/char/drm/drm_proc.h	Mon Nov 25 17:05:31 2002
+++ work/drivers/char/drm/drm_proc.h	Mon Nov 25 17:03:47 2002
@@ -449,7 +449,7 @@
 		for (i = vma->vm_start; i < vma->vm_end; i += PAGE_SIZE) {
 			pgd = pgd_offset(vma->vm_mm, i);
 			pmd = pmd_offset(pgd, i);
-			pte = pte_offset(pmd, i);
+			pte = pte_offset_map(pmd, i);
 			if (pte_present(*pte)) {
 				address = __pa(pte_page(*pte))
 					+ (i & (PAGE_SIZE-1));
@@ -465,6 +465,7 @@
 			} else {
 				DRM_PROC_PRINT("      0x%08lx\n", i);
 			}
+			pte_unmap(pte);
 		}
 #endif
 	}
diff -urN linux-2.4-rmap/drivers/char/drm/drm_scatter.h work/drivers/char/drm/drm_scatter.h
--- linux-2.4-rmap/drivers/char/drm/drm_scatter.h	Mon Nov 25 17:05:31 2002
+++ work/drivers/char/drm/drm_scatter.h	Mon Nov 25 17:03:47 2002
@@ -68,7 +68,7 @@
 	unsigned long pages, i, j;
 	pgd_t *pgd;
 	pmd_t *pmd;
-	pte_t *pte;
+	pte_t *pte, pte_entry;
 
 	DRM_DEBUG( "%s\n", __FUNCTION__ );
 
@@ -143,11 +143,13 @@
 		if ( !pmd_present( *pmd ) )
 			goto failed;
 
-		pte = pte_offset( pmd, i );
-		if ( !pte_present( *pte ) )
+		pte = pte_offset_map( pmd, i );
+		pte_entry = *pte;
+		pte_unmap(pte);
+		if ( !pte_present( pte_entry ) )
 			goto failed;
 
-		entry->pagelist[j] = pte_page( *pte );
+		entry->pagelist[j] = pte_page(pte_entry);
 
 		SetPageReserved( entry->pagelist[j] );
 	}
diff -urN linux-2.4-rmap/drivers/char/drm/drm_vm.h work/drivers/char/drm/drm_vm.h
--- linux-2.4-rmap/drivers/char/drm/drm_vm.h	Mon Nov 25 17:05:31 2002
+++ work/drivers/char/drm/drm_vm.h	Mon Nov 25 17:03:47 2002
@@ -154,7 +154,7 @@
 	unsigned long	 i;
 	pgd_t		 *pgd;
 	pmd_t		 *pmd;
-	pte_t		 *pte;
+	pte_t		 *pte, pte_entry;
 	struct page	 *page;
 
 	if (address > vma->vm_end) return NOPAGE_SIGBUS; /* Disallow mremap */
@@ -169,10 +169,12 @@
 	if( !pgd_present( *pgd ) ) return NOPAGE_OOM;
 	pmd = pmd_offset( pgd, i );
 	if( !pmd_present( *pmd ) ) return NOPAGE_OOM;
-	pte = pte_offset( pmd, i );
-	if( !pte_present( *pte ) ) return NOPAGE_OOM;
+	pte = pte_offset_map(pmd, i);
+	pte_entry = *pte;
+	pte_unmap(pte);
+	if( !pte_present(pte_entry) ) return NOPAGE_OOM;
 
-	page = pte_page(*pte);
+	page = pte_page(pte_entry);
 	get_page(page);
 
 	DRM_DEBUG("shm_nopage 0x%lx\n", address);
diff -urN linux-2.4-rmap/drivers/sgi/char/graphics.c work/drivers/sgi/char/graphics.c
--- linux-2.4-rmap/drivers/sgi/char/graphics.c	Mon Nov 25 17:05:34 2002
+++ work/drivers/sgi/char/graphics.c	Mon Nov 25 17:03:51 2002
@@ -219,6 +219,7 @@
 {
 	pgd_t *pgd; pmd_t *pmd; pte_t *pte; 
 	int board = GRAPHICS_CARD (vma->vm_dentry->d_inode->i_rdev);
+	struct page *page;
 
 	unsigned long virt_add, phys_add;
 
@@ -247,8 +248,10 @@
 
 	pgd = pgd_offset(current->mm, address);
 	pmd = pmd_offset(pgd, address);
-	pte = pte_offset(pmd, address);
-	return pte_page(*pte);
+	pte = pte_offset_map(pmd, address);
+	page = pte_page(*pte);
+	pte_unmap(pte);
+	return page;
 }
 
 /*
diff -urN linux-2.4-rmap/drivers/usb/stv680.c work/drivers/usb/stv680.c
--- linux-2.4-rmap/drivers/usb/stv680.c	Mon Nov 25 17:05:35 2002
+++ work/drivers/usb/stv680.c	Mon Nov 25 17:03:51 2002
@@ -139,8 +139,9 @@
 	if (!pgd_none (*pgd)) {
 		pmd = pmd_offset (pgd, adr);
 		if (!pmd_none (*pmd)) {
-			ptep = pte_offset (pmd, adr);
+			ptep = pte_offset_map(pmd, adr);
 			pte = *ptep;
+			pte_unmap(ptep);
 			if (pte_present (pte)) {
 				ret = (unsigned long) page_address (pte_page (pte));
 				ret |= (adr & (PAGE_SIZE - 1));
diff -urN linux-2.4-rmap/drivers/usb/vicam.c work/drivers/usb/vicam.c
--- linux-2.4-rmap/drivers/usb/vicam.c	Mon Nov 25 17:05:35 2002
+++ work/drivers/usb/vicam.c	Mon Nov 25 17:03:51 2002
@@ -115,8 +115,9 @@
 	if (!pgd_none(*pgd)) {
 		pmd = pmd_offset(pgd, adr);
 		if (!pmd_none(*pmd)) {
-			ptep = pte_offset(pmd, adr);
+			ptep = pte_offset_map(pmd, adr);
 			pte = *ptep;
+			pte_unmap(ptep);
 			if(pte_present(pte)) {
 				ret  = (unsigned long) page_address(pte_page(pte));
 				ret |= (adr & (PAGE_SIZE - 1));
diff -urN linux-2.4-rmap/fs/exec.c work/fs/exec.c
--- linux-2.4-rmap/fs/exec.c	Mon Nov 25 17:05:37 2002
+++ work/fs/exec.c	Mon Nov 25 17:03:52 2002
@@ -271,17 +271,20 @@
 	pmd = pmd_alloc(tsk->mm, pgd, address);
 	if (!pmd)
 		goto out;
-	pte = pte_alloc(tsk->mm, pmd, address);
+	pte = pte_alloc_map(tsk->mm, pmd, address);
 	if (!pte)
 		goto out;
-	if (!pte_none(*pte))
+	if (!pte_none(*pte)) {
+		pte_unmap(pte);
 		goto out;
+	}
 	lru_cache_add(page);
 	flush_dcache_page(page);
 	flush_page_to_ram(page);
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(page, PAGE_COPY))));
 	page_add_rmap(page, pte);
 	tsk->mm->rss++;
+	pte_unmap(pte);
 	spin_unlock(&tsk->mm->page_table_lock);
 
 	/* no need for flush_tlb */
diff -urN linux-2.4-rmap/fs/proc/array.c work/fs/proc/array.c
--- linux-2.4-rmap/fs/proc/array.c	Mon Nov 25 17:05:37 2002
+++ work/fs/proc/array.c	Mon Nov 25 17:03:53 2002
@@ -399,7 +399,7 @@
 static inline void statm_pte_range(pmd_t * pmd, unsigned long address, unsigned long size,
 	int * pages, int * shared, int * dirty, int * total)
 {
-	pte_t * pte;
+	pte_t * pte, *mapping;
 	unsigned long end;
 
 	if (pmd_none(*pmd))
@@ -409,7 +409,7 @@
 		pmd_clear(pmd);
 		return;
 	}
-	pte = pte_offset(pmd, address);
+	mapping = pte = pte_offset_map(pmd, address);
 	address &= ~PMD_MASK;
 	end = address + size;
 	if (end > PMD_SIZE)
@@ -434,6 +434,7 @@
 		if (page_count(pte_page(page)) > 1)
 			++*shared;
 	} while (address < end);
+	pte_unmap(mapping);
 }
 
 static inline void statm_pmd_range(pgd_t * pgd, unsigned long address, unsigned long size,
diff -urN linux-2.4-rmap/include/asm-generic/rmap.h work/include/asm-generic/rmap.h
--- linux-2.4-rmap/include/asm-generic/rmap.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-generic/rmap.h	Mon Nov 25 14:58:36 2002
@@ -13,12 +13,21 @@
  * - page->index has the high bits of the address
  * - the lower bits of the address are calculated from the
  *   offset of the page table entry within the page table page
+ *
+ * For CONFIG_HIGHPTE, we need to represent the address of a pte in a
+ * scalar pte_addr_t.  The pfn of the pte's page is shifted left by PAGE_SIZE
+ * bits and is then ORed with the byte offset of the pte within its page.
+ *
+ * For CONFIG_HIGHMEM4G, the pte_addr_t is 32 bits.  20 for the pfn, 12 for
+ * the offset.
+ *
+ * For CONFIG_HIGHMEM64G, the pte_addr_t is 64 bits.  52 for the pfn, 12 for
+ * the offset.
  */
 #include <linux/mm.h>
 
-static inline void pgtable_add_rmap(pte_t * ptep, struct mm_struct * mm, unsigned long address)
+static inline void pgtable_add_rmap(struct page * page, struct mm_struct * mm, unsigned long address)
 {
-	struct page * page = virt_to_page(ptep);
 #ifdef BROKEN_PPC_PTE_ALLOC_ONE
 	/* OK, so PPC calls pte_alloc() before mem_map[] is setup ... ;( */
 	extern int mem_init_done;
@@ -28,30 +37,54 @@
 #endif
 	page->mapping = (void *)mm;
 	page->index = address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
+	//inc_page_state(nr_page_table_pages);
 }
 
-static inline void pgtable_remove_rmap(pte_t * ptep)
+static inline void pgtable_remove_rmap(struct page * page)
 {
-	struct page * page = virt_to_page(ptep);
-
 	page->mapping = NULL;
 	page->index = 0;
+	//dec_page_state(nr_page_table_pages);
 }
 
 static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
 {
-	struct page * page = virt_to_page(ptep);
-
+	struct page * page = kmap_atomic_to_page(ptep);
 	return (struct mm_struct *) page->mapping;
 }
 
 static inline unsigned long ptep_to_address(pte_t * ptep)
 {
-	struct page * page = virt_to_page(ptep);
+	struct page * page = kmap_atomic_to_page(ptep);
 	unsigned long low_bits;
-
 	low_bits = ((unsigned long)ptep & ~PAGE_MASK) * PTRS_PER_PTE;
 	return page->index + low_bits;
 }
 
+#if CONFIG_HIGHPTE
+static inline pte_addr_t ptep_to_paddr(pte_t *ptep)
+{
+	pte_addr_t paddr;
+	paddr = ((pte_addr_t)page_to_pfn(kmap_atomic_to_page(ptep))) << PAGE_SHIFT;
+	return paddr + (pte_addr_t)((unsigned long)ptep & ~PAGE_MASK);
+}
+#else
+static inline pte_addr_t ptep_to_paddr(pte_t *ptep)
+{
+	return (pte_addr_t)ptep;
+}
+#endif
+
+#ifndef CONFIG_HIGHPTE
+static inline pte_t *rmap_ptep_map(pte_addr_t pte_paddr)
+{
+	return (pte_t *)pte_paddr;
+}
+
+static inline void rmap_ptep_unmap(pte_t *pte)
+{
+	return;
+}
+#endif
+
 #endif /* _GENERIC_RMAP_H */
diff -urN linux-2.4-rmap/include/asm-i386/fixmap.h work/include/asm-i386/fixmap.h
--- linux-2.4-rmap/include/asm-i386/fixmap.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-i386/fixmap.h	Mon Nov 25 17:03:53 2002
@@ -95,6 +95,7 @@
 #define FIXADDR_START	(FIXADDR_TOP - __FIXADDR_SIZE)
 
 #define __fix_to_virt(x)	(FIXADDR_TOP - ((x) << PAGE_SHIFT))
+#define __virt_to_fix(x)	((FIXADDR_TOP - ((x)&PAGE_MASK)) >> PAGE_SHIFT)
 
 extern void __this_fixmap_does_not_exist(void);
 
@@ -120,4 +121,10 @@
         return __fix_to_virt(idx);
 }
 
+static inline unsigned long virt_to_fix(const unsigned long vaddr)
+{
+	BUG_ON(vaddr >= FIXADDR_TOP || vaddr < FIXADDR_START);
+	return __virt_to_fix(vaddr);
+}
+
 #endif
diff -urN linux-2.4-rmap/include/asm-i386/highmem.h work/include/asm-i386/highmem.h
--- linux-2.4-rmap/include/asm-i386/highmem.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-i386/highmem.h	Mon Nov 25 17:03:53 2002
@@ -124,6 +124,20 @@
 #endif
 }
 
+static inline struct page *kmap_atomic_to_page(void *ptr)
+{
+	unsigned long idx, vaddr = (unsigned long)ptr;
+	pte_t *pte;
+
+	if (vaddr < FIXADDR_START)
+		return virt_to_page(ptr);
+
+	idx = virt_to_fix(vaddr);
+	pte = kmap_pte - (idx - FIX_KMAP_BEGIN);
+	return pte_page(*pte);
+}
+
+
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_HIGHMEM_H */
diff -urN linux-2.4-rmap/include/asm-i386/kmap_types.h work/include/asm-i386/kmap_types.h
--- linux-2.4-rmap/include/asm-i386/kmap_types.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-i386/kmap_types.h	Mon Nov 25 17:03:53 2002
@@ -7,6 +7,9 @@
 	KM_SKB_DATA_SOFTIRQ,
 	KM_USER0,
 	KM_USER1,
+	KM_PTE0,
+	KM_PTE1,
+	KM_PTE2,
 	KM_TYPE_NR
 };
 
diff -urN linux-2.4-rmap/include/asm-i386/page.h work/include/asm-i386/page.h
--- linux-2.4-rmap/include/asm-i386/page.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-i386/page.h	Mon Nov 25 17:03:53 2002
@@ -131,7 +131,13 @@
 #define MAXMEM			((unsigned long)(-PAGE_OFFSET-VMALLOC_RESERVE))
 #define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
-#define virt_to_page(kaddr)	(mem_map + (__pa(kaddr) >> PAGE_SHIFT))
+#define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
+#ifndef CONFIG_DISCONTIGMEM
+#define pfn_to_page(pfn)	(mem_map + (pfn))
+#define page_to_pfn(page)	((unsigned long)((page) - mem_map))
+#define pfn_valid(pfn)		((pfn) < max_mapnr)
+#endif /* !CONFIG_DISCONTIGMEM */
+#define virt_to_page(kaddr)     pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define VALID_PAGE(page)	((page - mem_map) < max_mapnr)
 
 #define VM_DATA_DEFAULT_FLAGS	(VM_READ | VM_WRITE | VM_EXEC | \
diff -urN linux-2.4-rmap/include/asm-i386/pgalloc.h work/include/asm-i386/pgalloc.h
--- linux-2.4-rmap/include/asm-i386/pgalloc.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-i386/pgalloc.h	Mon Nov 25 17:03:53 2002
@@ -5,143 +5,47 @@
 #include <asm/processor.h>
 #include <asm/fixmap.h>
 #include <linux/threads.h>
+#include <linux/mm.h>		/* for struct page */
 
 #define pgd_quicklist (current_cpu_data.pgd_quick)
 #define pmd_quicklist (current_cpu_data.pmd_quick)
 #define pte_quicklist (current_cpu_data.pte_quick)
 #define pgtable_cache_size (current_cpu_data.pgtable_cache_sz)
 
-#define pmd_populate(mm, pmd, pte) \
+#define pmd_populate_kernel(mm, pmd, pte) \
 		set_pmd(pmd, __pmd(_PAGE_TABLE + __pa(pte)))
 
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *pte)
+{
+	set_pmd(pmd, __pmd(_PAGE_TABLE +
+		((unsigned long long)page_to_pfn(pte) <<
+			(unsigned long long) PAGE_SHIFT)));
+}
 /*
  * Allocate and free page tables.
  */
 
-#if defined (CONFIG_X86_PAE)
-/*
- * We can't include <linux/slab.h> here, thus these uglinesses.
- */
-struct kmem_cache_s;
-
-extern struct kmem_cache_s *pae_pgd_cachep;
-extern void *kmem_cache_alloc(struct kmem_cache_s *, int);
-extern void kmem_cache_free(struct kmem_cache_s *, void *);
-
-
-static inline pgd_t *get_pgd_slow(void)
-{
-	int i;
-	pgd_t *pgd = kmem_cache_alloc(pae_pgd_cachep, GFP_KERNEL);
-
-	if (pgd) {
-		for (i = 0; i < USER_PTRS_PER_PGD; i++) {
-			unsigned long pmd = __get_free_page(GFP_KERNEL);
-			if (!pmd)
-				goto out_oom;
-			clear_page(pmd);
-			set_pgd(pgd + i, __pgd(1 + __pa(pmd)));
-		}
-		memcpy(pgd + USER_PTRS_PER_PGD,
-			swapper_pg_dir + USER_PTRS_PER_PGD,
-			(PTRS_PER_PGD - USER_PTRS_PER_PGD) * sizeof(pgd_t));
-	}
-	return pgd;
-out_oom:
-	for (i--; i >= 0; i--)
-		free_page((unsigned long)__va(pgd_val(pgd[i])-1));
-	kmem_cache_free(pae_pgd_cachep, pgd);
-	return NULL;
-}
-
-#else
-
-static inline pgd_t *get_pgd_slow(void)
-{
-	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL);
-
-	if (pgd) {
-		memset(pgd, 0, USER_PTRS_PER_PGD * sizeof(pgd_t));
-		memcpy(pgd + USER_PTRS_PER_PGD,
-			swapper_pg_dir + USER_PTRS_PER_PGD,
-			(PTRS_PER_PGD - USER_PTRS_PER_PGD) * sizeof(pgd_t));
-	}
-	return pgd;
-}
-
-#endif /* CONFIG_X86_PAE */
-
-static inline pgd_t *get_pgd_fast(void)
-{
-	unsigned long *ret;
+extern pgd_t *pgd_alloc(struct mm_struct *);
+extern void pgd_free(pgd_t *pgd);
 
-	if ((ret = pgd_quicklist) != NULL) {
-		pgd_quicklist = (unsigned long *)(*ret);
-		ret[0] = 0;
-		pgtable_cache_size--;
-	} else
-		ret = (unsigned long *)get_pgd_slow();
-	return (pgd_t *)ret;
-}
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
 
-static inline void free_pgd_fast(pgd_t *pgd)
-{
-	*(unsigned long *)pgd = (unsigned long) pgd_quicklist;
-	pgd_quicklist = (unsigned long *) pgd;
-	pgtable_cache_size++;
-}
+#define pte_alloc_one_fast(mm, address)		(0)
+#define pmd_alloc_one_fast(mm, address)		(0)
 
-static inline void free_pgd_slow(pgd_t *pgd)
+static inline void pte_free_kernel(pte_t *pte)
 {
-#if defined(CONFIG_X86_PAE)
-	int i;
-
-	for (i = 0; i < USER_PTRS_PER_PGD; i++)
-		free_page((unsigned long)__va(pgd_val(pgd[i])-1));
-	kmem_cache_free(pae_pgd_cachep, pgd);
-#else
-	free_page((unsigned long)pgd);
-#endif
-}
-
-static inline pte_t *pte_alloc_one(struct mm_struct *mm, unsigned long address)
-{
-	pte_t *pte;
-
-	pte = (pte_t *) __get_free_page(GFP_KERNEL);
-	if (pte)
-		clear_page(pte);
-	return pte;
-}
-
-static inline pte_t *pte_alloc_one_fast(struct mm_struct *mm,
-					unsigned long address)
-{
-	unsigned long *ret;
-
-	if ((ret = (unsigned long *)pte_quicklist) != NULL) {
-		pte_quicklist = (unsigned long *)(*ret);
-		ret[0] = ret[1];
-		pgtable_cache_size--;
-	}
-	return (pte_t *)ret;
+	free_page((unsigned long)pte);
 }
 
-static inline void pte_free_fast(pte_t *pte)
+static inline void pte_free(struct page *pte)
 {
-	*(unsigned long *)pte = (unsigned long) pte_quicklist;
-	pte_quicklist = (unsigned long *) pte;
-	pgtable_cache_size++;
+	__free_page(pte);
 }
 
-static __inline__ void pte_free_slow(pte_t *pte)
-{
-	free_page((unsigned long)pte);
-}
 
-#define pte_free(pte)		pte_free_fast(pte)
-#define pgd_free(pgd)		free_pgd_slow(pgd)
-#define pgd_alloc(mm)		get_pgd_fast()
+#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -149,11 +53,9 @@
  * (In the PAE case we free the pmds as part of the pgd.)
  */
 
-#define pmd_alloc_one_fast(mm, addr)	({ BUG(); ((pmd_t *)1); })
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free_slow(x)		do { } while (0)
-#define pmd_free_fast(x)		do { } while (0)
 #define pmd_free(x)			do { } while (0)
+#define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 extern int do_check_pgt_cache(int, int);
diff -urN linux-2.4-rmap/include/asm-i386/pgtable-2level.h work/include/asm-i386/pgtable-2level.h
--- linux-2.4-rmap/include/asm-i386/pgtable-2level.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-i386/pgtable-2level.h	Mon Nov 25 17:03:53 2002
@@ -58,6 +58,10 @@
 #define pte_same(a, b)		((a).pte_low == (b).pte_low)
 #define pte_page(x)		(mem_map+((unsigned long)(((x).pte_low >> PAGE_SHIFT))))
 #define pte_none(x)		(!(x).pte_low)
-#define __mk_pte(page_nr,pgprot) __pte(((page_nr) << PAGE_SHIFT) | pgprot_val(pgprot))
+#define pte_pfn(x)		((unsigned long)(((x).pte_low >> PAGE_SHIFT)))
+#define pfn_pte(pfn, prot)	__pte(((pfn) << PAGE_SHIFT) | pgprot_val(prot))
+#define pfn_pmd(pfn, prot)	__pmd(((pfn) << PAGE_SHIFT) | pgprot_val(prot))
+
+#define __mk_pte(nr,prot)	pfn_pte(nr,prot)
 
 #endif /* _I386_PGTABLE_2LEVEL_H */
diff -urN linux-2.4-rmap/include/asm-i386/pgtable-3level.h work/include/asm-i386/pgtable-3level.h
--- linux-2.4-rmap/include/asm-i386/pgtable-3level.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-i386/pgtable-3level.h	Mon Nov 25 17:03:53 2002
@@ -86,10 +86,12 @@
 	return a.pte_low == b.pte_low && a.pte_high == b.pte_high;
 }
 
-#define pte_page(x)	(mem_map+(((x).pte_low >> PAGE_SHIFT) | ((x).pte_high << (32 - PAGE_SHIFT))))
+#define pte_page(x)	pfn_to_page(pte_pfn(x))
 #define pte_none(x)	(!(x).pte_low && !(x).pte_high)
+#define pte_pfn(x)	(((x).pte_low >> PAGE_SHIFT) | ((x).pte_high << (32 - PAGE_SHIFT)))
 
-static inline pte_t __mk_pte(unsigned long page_nr, pgprot_t pgprot)
+#define __mk_pte(nr,prot)	pfn_pte(nr,prot)
+static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
 {
 	pte_t pte;
 
@@ -98,4 +100,11 @@
 	return pte;
 }
 
+static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
+{
+	return __pmd(((unsigned long long)page_nr << PAGE_SHIFT) | pgprot_val(pgprot));
+}
+
+extern struct kmem_cache_s *pae_pgd_cachep;
+
 #endif /* _I386_PGTABLE_3LEVEL_H */
diff -urN linux-2.4-rmap/include/asm-i386/pgtable.h work/include/asm-i386/pgtable.h
--- linux-2.4-rmap/include/asm-i386/pgtable.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-i386/pgtable.h	Mon Nov 25 17:03:53 2002
@@ -312,9 +312,13 @@
 
 #define page_pte(page) page_pte_prot(page, __pgprot(0))
 
-#define pmd_page(pmd) \
+#define pmd_page_kernel(pmd) \
 ((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
 
+#ifndef CONFIG_DISCONTIGMEM
+#define pmd_page(pmd) (pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
+#endif /* !CONFIG_DISCONTIGMEM */
+
 /* to find an entry in a page-table-directory. */
 #define pgd_index(address) ((address >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
 
@@ -331,8 +335,35 @@
 /* Find an entry in the third-level page table.. */
 #define __pte_offset(address) \
 		((address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
-#define pte_offset(dir, address) ((pte_t *) pmd_page(*(dir)) + \
-			__pte_offset(address))
+#define pte_offset_kernel(dir, address) \
+	((pte_t *) pmd_page_kernel(*(dir)) +  __pte_offset(address))
+
+#if defined(CONFIG_HIGHPTE)
+#define pte_offset_map(dir, address) \
+	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0) + __pte_offset(address))
+#define pte_offset_map_nested(dir, address) \
+	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE1) + __pte_offset(address))
+#define pte_unmap(pte) kunmap_atomic(pte, KM_PTE0)
+#define pte_unmap_nested(pte) kunmap_atomic(pte, KM_PTE1)
+#else
+#define pte_offset_map(dir, address) \
+        ((pte_t *)page_address(pmd_page(*(dir))) + __pte_offset(address))
+#define pte_offset_map_nested(dir, address) pte_offset_map(dir, address)
+#define pte_unmap(pte) do { } while (0)
+#define pte_unmap_nested(pte) do { } while (0)
+#endif
+
+#if defined(CONFIG_HIGHPTE) && defined(CONFIG_HIGHMEM4G)
+typedef u32 pte_addr_t;
+#endif
+
+#if defined(CONFIG_HIGHPTE) && defined(CONFIG_HIGHMEM64G)
+typedef u64 pte_addr_t;
+#endif
+
+#if !defined(CONFIG_HIGHPTE)
+typedef pte_t *pte_addr_t;
+#endif
 
 /*
  * The i386 doesn't have any external MMU info: the kernel page
diff -urN linux-2.4-rmap/include/asm-i386/rmap.h work/include/asm-i386/rmap.h
--- linux-2.4-rmap/include/asm-i386/rmap.h	Mon Nov 25 17:05:38 2002
+++ work/include/asm-i386/rmap.h	Mon Nov 25 17:03:53 2002
@@ -4,4 +4,18 @@
 /* nothing to see, move along */
 #include <asm-generic/rmap.h>
 
+#ifdef CONFIG_HIGHPTE
+static inline pte_t *rmap_ptep_map(pte_addr_t pte_paddr)
+{
+	unsigned long pfn = (unsigned long)(pte_paddr >> PAGE_SHIFT);
+	unsigned long off = ((unsigned long)pte_paddr) & ~PAGE_MASK;
+	return (pte_t *)((char *)kmap_atomic(pfn_to_page(pfn), KM_PTE2) + off);
+}
+
+static inline void rmap_ptep_unmap(pte_t *pte)
+{
+	kunmap_atomic(pte, KM_PTE2);
+}
+#endif
+
 #endif
diff -urN linux-2.4-rmap/include/linux/highmem.h work/include/linux/highmem.h
--- linux-2.4-rmap/include/linux/highmem.h	Mon Nov 25 17:05:39 2002
+++ work/include/linux/highmem.h	Mon Nov 25 17:03:55 2002
@@ -36,6 +36,7 @@
 
 #define kmap_atomic(page,idx)		kmap(page)
 #define kunmap_atomic(page,idx)		kunmap(page)
+#define kmap_atomic_to_page(ptr)	virt_to_page(ptr)
 
 #define bh_kmap(bh)	((bh)->b_data)
 #define bh_kunmap(bh)	do { } while (0)
diff -urN linux-2.4-rmap/include/linux/mm.h work/include/linux/mm.h
--- linux-2.4-rmap/include/linux/mm.h	Mon Nov 25 17:05:40 2002
+++ work/include/linux/mm.h	Mon Nov 25 17:03:55 2002
@@ -182,6 +182,11 @@
 					   updated asynchronously */
 	struct list_head lru;		/* Pageout list, eg. active_list;
 					   protected by the lru lock !! */
+	union {
+		struct pte_chain *chain;/* Reverse pte mapping pointer.
+					 * protected by PG_chainlock */
+		pte_addr_t direct;
+	} pte;
 	unsigned char age;		/* Page aging counter. */
 	struct pte_chain * pte_chain;	/* Reverse pte mapping pointer.
 					 * protected by PG_chainlock
@@ -314,6 +319,7 @@
 #define PG_uptodate		 3
 #define PG_dirty		 4
 #define PG_active_anon		 5
+#define PG_direct		 6
 #define PG_inactive_dirty	 7
 #define PG_inactive_laundry	 8
 #define PG_inactive_clean	 9
@@ -434,6 +440,9 @@
  * the clear_bit and the read of the waitqueue (to avoid SMP races with a
  * parallel wait_on_page).
  */
+#define PageDirect(page)	test_bit(PG_direct, &(page)->flags)
+#define SetPageDirect(page)	set_bit(PG_direct, &(page)->flags)
+#define ClearPageDirect(page)	clear_bit(PG_direct, &(page)->flags)
 #define PageError(page)		test_bit(PG_error, &(page)->flags)
 #define SetPageError(page)	set_bit(PG_error, &(page)->flags)
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
@@ -484,6 +493,16 @@
 #define ClearPageReserved(page)		clear_bit(PG_reserved, &(page)->flags)
 
 /*
+ * Return true if this page is mapped into pagetables.  Subtle: test pte.direct
+ * rather than pte.chain.  Because sometimes pte.direct is 64-bit, and .chain
+ * is only 32-bit.
+ */
+static inline int page_mapped(struct page *page)
+{
+	return page->pte.direct != 0;
+}
+
+/*
  * Error return values for the *_nopage functions
  */
 #define NOPAGE_SIGBUS	(NULL)
@@ -556,7 +575,8 @@
 
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern pmd_t *FASTCALL(__pmd_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address));
-extern pte_t *FASTCALL(pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
+extern pte_t *FASTCALL(pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
+extern pte_t *FASTCALL(pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
 extern int handle_mm_fault(struct mm_struct *mm,struct vm_area_struct *vma, unsigned long address, int write_access);
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
diff -urN linux-2.4-rmap/mm/filemap.c work/mm/filemap.c
--- linux-2.4-rmap/mm/filemap.c	Mon Nov 25 17:05:40 2002
+++ work/mm/filemap.c	Fri Nov 22 21:24:56 2002
@@ -2150,7 +2150,8 @@
 		struct page *page = pte_page(pte);
 		if (VALID_PAGE(page) && !PageReserved(page) && ptep_test_and_clear_dirty(ptep)) {
 			flush_tlb_page(vma, address);
-			set_page_dirty(page);
+			set_page_dirty(page);	/* This actually does not sleep */
+			return 0;
 		}
 	}
 	return 0;
@@ -2160,7 +2161,7 @@
 	unsigned long address, unsigned long size, 
 	struct vm_area_struct *vma, unsigned long offset, unsigned int flags)
 {
-	pte_t * pte;
+	pte_t *pte, *mapping;
 	unsigned long end;
 	int error;
 
@@ -2171,7 +2172,7 @@
 		pmd_clear(pmd);
 		return 0;
 	}
-	pte = pte_offset(pmd, address);
+	mapping = pte = pte_offset_map(pmd, address);
 	offset += address & PMD_MASK;
 	address &= ~PMD_MASK;
 	end = address + size;
@@ -2183,6 +2184,7 @@
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
+	pte_unmap(mapping);
 	return error;
 }
 
diff -urN linux-2.4-rmap/mm/memory.c work/mm/memory.c
--- linux-2.4-rmap/mm/memory.c	Mon Nov 25 17:05:40 2002
+++ work/mm/memory.c	Mon Nov 25 17:03:55 2002
@@ -94,7 +94,7 @@
  */
 static inline void free_one_pmd(pmd_t * dir)
 {
-	pte_t * pte;
+	struct page *pte;
 
 	if (pmd_none(*dir))
 		return;
@@ -103,7 +103,7 @@
 		pmd_clear(dir);
 		return;
 	}
-	pte = pte_offset(dir, 0);
+	pte = pmd_page(*dir);
 	pmd_clear(dir);
 	pgtable_remove_rmap(pte);
 	pte_free(pte);
@@ -141,6 +141,62 @@
 	return do_check_pgt_cache(pgt_cache_water[0], pgt_cache_water[1]);
 }
 
+pte_t *pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
+{
+	if (!pmd_present(*pmd)) {
+		struct page *new;
+
+		new = pte_alloc_one_fast(mm, address);
+		if (!new) {
+			spin_unlock(&mm->page_table_lock);
+			new = pte_alloc_one(mm, address);
+			spin_lock(&mm->page_table_lock);
+		}
+		if (!new)
+			return NULL;
+
+		/*
+		 * Because we dropped the lock, we should re-check the
+		 * entry, as somebody else could have populated it..
+		 */
+		if (pmd_present(*pmd)) {
+			pte_free(new);
+			goto out;
+		}
+		pgtable_add_rmap(new, mm, address);
+		pmd_populate(mm, pmd, new);
+	}
+out:
+	if (pmd_present(*pmd))
+		return pte_offset_map(pmd, address);
+	return NULL;
+}
+
+pte_t *pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
+{
+	if (!pmd_present(*pmd)) {
+		pte_t *new;
+
+		spin_unlock(&mm->page_table_lock);
+		new = pte_alloc_one_kernel(mm, address);
+		spin_lock(&mm->page_table_lock);
+		if (!new)
+			return NULL;
+
+		/*
+		 * Because we dropped the lock, we should re-check the
+		 * entry, as somebody else could have populated it..
+		 */
+		if (pmd_present(*pmd)) {
+			pte_free_kernel(new);
+			goto out;
+		}
+		pmd_populate_kernel(mm, pmd, new);
+	}
+out:
+	return pte_offset_kernel(pmd, address);
+}
+
 
 /*
  * This function clears all user-level page tables of a process - this
@@ -177,7 +233,7 @@
  *         variable count and make things faster. -jj
  *
  * dst->page_table_lock is held on entry and exit,
- * but may be dropped within pmd_alloc() and pte_alloc().
+ * but may be dropped within pmd_alloc() and pte_alloc_map().
  */
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma)
@@ -229,12 +285,12 @@
 				goto cont_copy_pmd_range;
 			}
 
-			src_pte = pte_offset(src_pmd, address);
-			dst_pte = pte_alloc(dst, dst_pmd, address);
+			dst_pte = pte_alloc_map(dst, dst_pmd, address);
 			if (!dst_pte)
 				goto nomem;
 
 			spin_lock(&src->page_table_lock);			
+			src_pte = pte_offset_map_nested(src_pmd, address);
 			do {
 				pte_t pte = *src_pte;
 				struct page *ptepage;
@@ -255,7 +311,7 @@
 					goto cont_copy_pte_range;
 
 				/* If it's a COW mapping, write protect it both in the parent and the child */
-				if (cow) {
+				if (cow && pte_write(pte)) {
 					ptep_set_wrprotect(src_pte);
 					pte = *src_pte;
 				}
@@ -270,19 +326,23 @@
 cont_copy_pte_range:		set_pte(dst_pte, pte);
 				page_add_rmap(ptepage, dst_pte);
 cont_copy_pte_range_noset:	address += PAGE_SIZE;
-				if (address >= end)
-					goto out_unlock;
+				if (address >= end) {
+					pte_unmap_nested(src_pte);
+					pte_unmap(dst_pte);
+					spin_unlock(&src->page_table_lock);
+					goto out;
+				}
 				src_pte++;
 				dst_pte++;
 			} while ((unsigned long)src_pte & PTE_TABLE_MASK);
+			pte_unmap_nested(src_pte-1);
+			pte_unmap(dst_pte-1);
 			spin_unlock(&src->page_table_lock);
 		
 cont_copy_pmd_range:	src_pmd++;
 			dst_pmd++;
 		} while ((unsigned long)src_pmd & PMD_TABLE_MASK);
 	}
-out_unlock:
-	spin_unlock(&src->page_table_lock);
 out:
 	return 0;
 nomem:
@@ -303,7 +363,7 @@
 static inline int zap_pte_range(mmu_gather_t *tlb, pmd_t * pmd, unsigned long address, unsigned long size)
 {
 	unsigned long offset;
-	pte_t * ptep;
+	pte_t * ptep, *mapping;
 	int freed = 0;
 
 	if (pmd_none(*pmd))
@@ -313,7 +373,7 @@
 		pmd_clear(pmd);
 		return 0;
 	}
-	ptep = pte_offset(pmd, address);
+	mapping = ptep = pte_offset_map(pmd, address);
 	offset = address & ~PMD_MASK;
 	if (offset + size > PMD_SIZE)
 		size = PMD_SIZE - offset;
@@ -335,6 +395,7 @@
 			pte_clear(ptep);
 		}
 	}
+	pte_unmap(mapping);
 
 	return freed;
 }
@@ -434,6 +495,7 @@
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *ptep, pte;
+	struct page *page = NULL;
 
 	pgd = pgd_offset(mm, address);
 	if (pgd_none(*pgd) || pgd_bad(*pgd))
@@ -443,19 +505,19 @@
 	if (pmd_none(*pmd) || pmd_bad(*pmd))
 		goto out;
 
-	ptep = pte_offset(pmd, address);
+	ptep = pte_offset_map(pmd, address);
 	if (!ptep)
 		goto out;
 
 	pte = *ptep;
+	pte_unmap(ptep);
 	if (pte_present(pte)) {
 		if (!write ||
 		    (pte_write(pte) && pte_dirty(pte)))
-			return pte_page(pte);
+			page = pte_page(pte);
 	}
-
 out:
-	return 0;
+	return page;
 }
 
 /* 
@@ -802,10 +864,11 @@
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
 	do {
-		pte_t * pte = pte_alloc(mm, pmd, address);
+		pte_t * pte = pte_alloc_map(mm, pmd, address);
 		if (!pte)
 			return -ENOMEM;
 		zeromap_pte_range(pte, address, end - address, prot);
+		pte_unmap(pte);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
@@ -883,10 +946,11 @@
 		end = PGDIR_SIZE;
 	phys_addr -= address;
 	do {
-		pte_t * pte = pte_alloc(mm, pmd, address + base);
+		pte_t * pte = pte_alloc_map(mm, pmd, address + base);
 		if (!pte)
 			return -ENOMEM;
 		remap_pte_range(pte, base + address, end - address, address + phys_addr, prot);
+		pte_unmap(pte);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
@@ -972,7 +1036,7 @@
  * with the page_table_lock released.
  */
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct * vma,
-	unsigned long address, pte_t *page_table, pte_t pte)
+	unsigned long address, pte_t *page_table, pmd_t *pmd, pte_t pte)
 {
 	struct page *old_page, *new_page;
 
@@ -986,10 +1050,12 @@
 		if (reuse) {
 			flush_cache_page(vma, address);
 			establish_pte(vma, address, page_table, pte_mkyoung(pte_mkdirty(pte_mkwrite(pte))));
+			pte_unmap(page_table);
 			spin_unlock(&mm->page_table_lock);
 			return 1;	/* Minor fault */
 		}
 	}
+	pte_unmap(page_table);
 
 	/*
 	 * Ok, we need to copy. Oh, well..
@@ -1006,6 +1072,7 @@
 	 * Re-check the pte - we dropped the lock
 	 */
 	spin_lock(&mm->page_table_lock);
+	page_table = pte_offset_map(pmd, address);
 	if (pte_same(*page_table, pte)) {
 		if (PageReserved(old_page))
 			++mm->rss;
@@ -1017,12 +1084,14 @@
 		/* Free the old page.. */
 		new_page = old_page;
 	}
+	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
 	return 1;	/* Minor fault */
 
 bad_wp_page:
+	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 	printk("do_wp_page: bogus page at address %08lx (page 0x%lx)\n",address,(unsigned long)old_page);
 	return -1;
@@ -1148,13 +1217,14 @@
  */
 static int do_swap_page(struct mm_struct * mm,
 	struct vm_area_struct * vma, unsigned long address,
-	pte_t * page_table, pte_t orig_pte, int write_access)
+	pte_t * page_table, pmd_t *pmd, pte_t orig_pte, int write_access)
 {
 	struct page *page;
 	swp_entry_t entry = pte_to_swp_entry(orig_pte);
 	pte_t pte;
 	int ret = 1;
 
+	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 	page = lookup_swap_cache(entry);
 	if (!page) {
@@ -1167,7 +1237,9 @@
 			 */
 			int retval;
 			spin_lock(&mm->page_table_lock);
+			page_table = pte_offset_map(pmd, address);
 			retval = pte_same(*page_table, orig_pte) ? -1 : 1;
+			pte_unmap(page_table);
 			spin_unlock(&mm->page_table_lock);
 			return retval;
 		}
@@ -1185,7 +1257,9 @@
 	 * released the page table lock.
 	 */
 	spin_lock(&mm->page_table_lock);
+	page_table = pte_offset_map(pmd, address);
 	if (!pte_same(*page_table, orig_pte)) {
+		pte_unmap(page_table);
 		spin_unlock(&mm->page_table_lock);
 		unlock_page(page);
 		page_cache_release(page);
@@ -1211,6 +1285,7 @@
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
+	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 	return ret;
 }
@@ -1220,7 +1295,7 @@
  * spinlock held to protect against concurrent faults in
  * multithreaded programs. 
  */
-static int do_anonymous_page(struct mm_struct * mm, struct vm_area_struct * vma, pte_t *page_table, int write_access, unsigned long addr)
+static int do_anonymous_page(struct mm_struct * mm, struct vm_area_struct * vma, pte_t *page_table, pmd_t *pmd, int write_access, unsigned long addr)
 {
 	pte_t entry;
 	struct page * page = ZERO_PAGE(addr);
@@ -1231,6 +1306,7 @@
 	/* ..except if it's a write access */
 	if (write_access) {
 		/* Allocate our own private page. */
+		pte_unmap(page_table);
 		spin_unlock(&mm->page_table_lock);
 
 		page = alloc_page(GFP_HIGHUSER);
@@ -1239,8 +1315,10 @@
 		clear_user_highpage(page, addr);
 
 		spin_lock(&mm->page_table_lock);
+		page_table = pte_offset_map(pmd, addr);
 		if (!pte_none(*page_table)) {
 			page_cache_release(page);
+			pte_unmap(page_table);
 			spin_unlock(&mm->page_table_lock);
 			return 1;
 		}
@@ -1255,6 +1333,7 @@
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, entry);
+	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 	return 1;	/* Minor fault */
 
@@ -1275,13 +1354,14 @@
  * spinlock held. Exit with the spinlock released.
  */
 static int do_no_page(struct mm_struct * mm, struct vm_area_struct * vma,
-	unsigned long address, int write_access, pte_t *page_table)
+	unsigned long address, int write_access, pte_t *page_table, pmd_t *pmd)
 {
 	struct page * new_page;
 	pte_t entry;
 
 	if (!vma->vm_ops || !vma->vm_ops->nopage)
-		return do_anonymous_page(mm, vma, page_table, write_access, address);
+		return do_anonymous_page(mm, vma, page_table, pmd, write_access, address);
+	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 
 	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, 0);
@@ -1309,6 +1389,7 @@
 	mark_page_accessed(new_page);
 
 	spin_lock(&mm->page_table_lock);
+	page_table = pte_offset_map(pmd, address);
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
 	 * due to the bad i386 page protection. But it's valid
@@ -1329,8 +1410,10 @@
 			entry = pte_mkwrite(pte_mkdirty(entry));
 		set_pte(page_table, entry);
 		page_add_rmap(new_page, page_table);
+		pte_unmap(page_table);
 	} else {
 		/* One of our sibling threads was faster, back out. */
+		pte_unmap(page_table);
 		page_cache_release(new_page);
 		spin_unlock(&mm->page_table_lock);
 		return 1;
@@ -1365,7 +1448,7 @@
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 	struct vm_area_struct * vma, unsigned long address,
-	int write_access, pte_t * pte)
+	int write_access, pte_t *pte, pmd_t *pmd)
 {
 	pte_t entry;
 
@@ -1377,18 +1460,19 @@
 		 * drop the lock.
 		 */
 		if (pte_none(entry))
-			return do_no_page(mm, vma, address, write_access, pte);
-		return do_swap_page(mm, vma, address, pte, entry, write_access);
+			return do_no_page(mm, vma, address, write_access, pte, pmd);
+		return do_swap_page(mm, vma, address, pte, pmd, entry, write_access);
 	}
 
 	if (write_access) {
 		if (!pte_write(entry))
-			return do_wp_page(mm, vma, address, pte, entry);
+			return do_wp_page(mm, vma, address, pte, pmd, entry);
 
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
 	establish_pte(vma, address, pte, entry);
+	pte_unmap(pte);
 	spin_unlock(&mm->page_table_lock);
 	return 1;
 }
@@ -1421,9 +1505,9 @@
 	pmd = pmd_alloc(mm, pgd, address);
 
 	if (pmd) {
-		pte_t * pte = pte_alloc(mm, pmd, address);
+		pte_t * pte = pte_alloc_map(mm, pmd, address);
 		if (pte)
-			return handle_pte_fault(mm, vma, address, write_access, pte);
+			return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
 	}
 	spin_unlock(&mm->page_table_lock);
 	return -1;
@@ -1465,42 +1549,6 @@
 	return pmd_offset(pgd, address);
 }
 
-/*
- * Allocate the page table directory.
- *
- * We've already handled the fast-path in-line, and we own the
- * page table lock.
- */
-pte_t *pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
-{
-	if (pmd_none(*pmd)) {
-		pte_t *new;
-
-		/* "fast" allocation can happen without dropping the lock.. */
-		new = pte_alloc_one_fast(mm, address);
-		if (!new) {
-			spin_unlock(&mm->page_table_lock);
-			new = pte_alloc_one(mm, address);
-			spin_lock(&mm->page_table_lock);
-			if (!new)
-				return NULL;
-
-			/*
-			 * Because we dropped the lock, we should re-check the
-			 * entry, as somebody else could have populated it..
-			 */
-			if (!pmd_none(*pmd)) {
-				pte_free(new);
-				goto out;
-			}
-		}
-		pgtable_add_rmap(new, mm, address);
-		pmd_populate(mm, pmd, new);
-	}
-out:
-	return pte_offset(pmd, address);
-}
-
 int make_pages_present(unsigned long addr, unsigned long end)
 {
 	int ret, len, write;
@@ -1530,10 +1578,11 @@
 	if (!pgd_none(*pgd)) {
 		pmd = pmd_offset(pgd, addr);
 		if (!pmd_none(*pmd)) {
-			pte = pte_offset(pmd, addr);
+			pte = pte_offset_map(pmd, addr);
 			if (pte_present(*pte)) {
 				page = pte_page(*pte);
 			}
+			pte_unmap(pte);
 		}
 	}
 	return page;
diff -urN linux-2.4-rmap/mm/mprotect.c work/mm/mprotect.c
--- linux-2.4-rmap/mm/mprotect.c	Mon Nov 25 17:05:40 2002
+++ work/mm/mprotect.c	Mon Nov 25 17:03:55 2002
@@ -7,6 +7,7 @@
 #include <linux/smp_lock.h>
 #include <linux/shm.h>
 #include <linux/mman.h>
+#include <linux/highmem.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
@@ -15,7 +16,7 @@
 static inline void change_pte_range(pmd_t * pmd, unsigned long address,
 	unsigned long size, pgprot_t newprot)
 {
-	pte_t * pte;
+	pte_t *pte, *mapping;
 	unsigned long end;
 
 	if (pmd_none(*pmd))
@@ -25,7 +26,7 @@
 		pmd_clear(pmd);
 		return;
 	}
-	pte = pte_offset(pmd, address);
+	mapping = pte = pte_offset_map(pmd, address);
 	address &= ~PMD_MASK;
 	end = address + size;
 	if (end > PMD_SIZE)
@@ -44,6 +45,7 @@
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
+	pte_unmap(mapping);
 }
 
 static inline void change_pmd_range(pgd_t * pgd, unsigned long address,
diff -urN linux-2.4-rmap/mm/mremap.c work/mm/mremap.c
--- linux-2.4-rmap/mm/mremap.c	Mon Nov 25 17:05:40 2002
+++ work/mm/mremap.c	Mon Nov 25 17:03:55 2002
@@ -9,13 +9,14 @@
 #include <linux/shm.h>
 #include <linux/mman.h>
 #include <linux/swap.h>
+#include <linux/highmem.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
 
 extern int vm_enough_memory(long pages);
 
-static inline pte_t *get_one_pte(struct mm_struct *mm, unsigned long addr)
+static inline pte_t *get_one_pte_map_nested(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t * pgd;
 	pmd_t * pmd;
@@ -39,25 +40,43 @@
 		goto end;
 	}
 
-	pte = pte_offset(pmd, addr);
-	if (pte_none(*pte))
+	pte = pte_offset_map_nested(pmd, addr);
+	if (pte_none(*pte)) {
+		pte_unmap_nested(pte);
 		pte = NULL;
+	}
 end:
 	return pte;
 }
 
-static inline pte_t *alloc_one_pte(struct mm_struct *mm, unsigned long addr)
+#ifdef CONFIG_HIGHPTE	/* Save a few cycles on the sane machines */
+static inline int page_table_present(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, addr);
+	if (pgd_none(*pgd))
+		return 0;
+	pmd = pmd_offset(pgd, addr);
+	return pmd_present(*pmd);
+}
+#else
+#define page_table_present(mm, addr)	(1)
+#endif
+
+static inline pte_t *alloc_one_pte_map(struct mm_struct *mm, unsigned long addr)
 {
 	pmd_t * pmd;
 	pte_t * pte = NULL;
 
 	pmd = pmd_alloc(mm, pgd_offset(mm, addr), addr);
 	if (pmd)
-		pte = pte_alloc(mm, pmd, addr);
+		pte = pte_alloc_map(mm, pmd, addr);
 	return pte;
 }
 
-static inline int copy_one_pte(struct mm_struct *mm, pte_t * src, pte_t * dst)
+static int copy_one_pte(struct mm_struct *mm, pte_t * src, pte_t * dst)
 {
 	int error = 0;
 	pte_t pte;
@@ -82,25 +101,42 @@
 	return error;
 }
 
-static int move_one_page(struct mm_struct *mm, unsigned long old_addr, unsigned long new_addr)
+static int move_one_page(struct vm_area_struct *vma, unsigned long old_addr, unsigned long new_addr)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	int error = 0;
-	pte_t * src;
+	pte_t *src, *dst;
 
 	spin_lock(&mm->page_table_lock);
-	src = get_one_pte(mm, old_addr);
-	if (src)
-		error = copy_one_pte(mm, src, alloc_one_pte(mm, new_addr));
+	src = get_one_pte_map_nested(mm, old_addr);
+	if (src) {
+		/*
+		 * Look to see whether alloc_one_pte_map needs to perform a
+		 * memory allocation.  If it does then we need to drop the
+		 * atomic kmap
+		 */
+		if (!page_table_present(mm, new_addr)) {
+			pte_unmap_nested(src);
+			src = NULL;
+		}
+		dst = alloc_one_pte_map(mm, new_addr);
+		if (src == NULL)
+			src = get_one_pte_map_nested(mm, old_addr);
+		error = copy_one_pte(mm, src, dst);
+		pte_unmap_nested(src);
+		pte_unmap(dst);
+	}
+	flush_tlb_page(vma, old_addr);
 	spin_unlock(&mm->page_table_lock);
 	return error;
 }
 
-static int move_page_tables(struct mm_struct * mm,
+static int move_page_tables(struct vm_area_struct *vma,
 	unsigned long new_addr, unsigned long old_addr, unsigned long len)
 {
 	unsigned long offset = len;
 
-	flush_cache_range(mm, old_addr, old_addr + len);
+	flush_cache_range(vma, old_addr, old_addr + len);
 
 	/*
 	 * This is not the clever way to do this, but we're taking the
@@ -109,10 +145,9 @@
 	 */
 	while (offset) {
 		offset -= PAGE_SIZE;
-		if (move_one_page(mm, old_addr + offset, new_addr + offset))
+		if (move_one_page(vma, old_addr + offset, new_addr + offset))
 			goto oops_we_failed;
 	}
-	flush_tlb_range(mm, old_addr, old_addr + len);
 	return 0;
 
 	/*
@@ -123,14 +158,14 @@
 	 * the old page tables)
 	 */
 oops_we_failed:
-	flush_cache_range(mm, new_addr, new_addr + len);
+	flush_cache_range(vma, new_addr, new_addr + len);
 	while ((offset += PAGE_SIZE) < len)
-		move_one_page(mm, new_addr + offset, old_addr + offset);
-	zap_page_range(mm, new_addr, len);
+		move_one_page(vma, new_addr + offset, old_addr + offset);
+	zap_page_range(vma->vm_mm, new_addr, len);
 	return -1;
 }
 
-static inline unsigned long move_vma(struct vm_area_struct * vma,
+static unsigned long move_vma(struct vm_area_struct * vma,
 	unsigned long addr, unsigned long old_len, unsigned long new_len,
 	unsigned long new_addr)
 {
@@ -154,7 +189,8 @@
 				prev->vm_end = next->vm_end;
 				__vma_unlink(mm, next, prev);
 				spin_unlock(&mm->page_table_lock);
-
+				if (vma == next)
+					vma = prev;
 				mm->map_count--;
 				kmem_cache_free(vm_area_cachep, next);
 			}
@@ -184,7 +220,7 @@
 		allocated_vma = 1;
 	}
 
-	if (!move_page_tables(current->mm, new_addr, addr, old_len)) {
+	if (!move_page_tables(vma, new_addr, addr, old_len)) {
 		if (allocated_vma) {
 			*new_vma = *vma;
 			new_vma->vm_start = new_addr;
@@ -260,12 +296,14 @@
 	/*
 	 * Always allow a shrinking remap: that just unmaps
 	 * the unnecessary pages..
+	 * do_munmap does all the needed commit accounting
 	 */
 	ret = addr;
 	if (old_len >= new_len) {
 		do_munmap(current->mm, addr+new_len, old_len - new_len);
 		if (!(flags & MREMAP_FIXED) || (new_addr == addr))
 			goto out;
+		old_len = new_len;
 	}
 
 	/*
diff -urN linux-2.4-rmap/mm/rmap.c work/mm/rmap.c
--- linux-2.4-rmap/mm/rmap.c	Mon Nov 25 15:24:58 2002
+++ work/mm/rmap.c	Mon Nov 25 16:43:37 2002
@@ -14,6 +14,8 @@
 /*
  * Locking:
  * - the page->pte_chain is protected by the PG_chainlock bit,
+ *   which nests within the pagemap_lru_lock, then the
+ * - the page->pte.chain is protected by the PG_chainlock bit,
  *   which nests within the lru lock, then the
  *   mm->page_table_lock, and then the page lock.
  * - because swapout locking is opposite to the locking order
@@ -28,7 +30,7 @@
 
 #include <asm/pgalloc.h>
 #include <asm/rmap.h>
-#include <asm/smplock.h>
+#include <asm/tlb.h>
 
 /* #define DEBUG_RMAP */
 
@@ -38,22 +40,71 @@
  * here, the page struct for the page table page contains the process
  * it belongs to and the offset within that process.
  *
- * A singly linked list should be fine for most, if not all, workloads.
- * On fork-after-exec the mapping we'll be removing will still be near
- * the start of the list, on mixed application systems the short-lived
- * processes will have their mappings near the start of the list and
- * in systems with long-lived applications the relative overhead of
- * exit() will be lower since the applications are long-lived.
+ * We use an array of pte pointers in this structure to minimise cache misses
+ * while traversing reverse maps.
  */
+#define NRPTE ((L1_CACHE_BYTES - sizeof(void *))/sizeof(pte_addr_t))
+
 struct pte_chain {
-	struct pte_chain * next;
-	pte_t * ptep;
+	struct pte_chain *next;
+	pte_addr_t ptes[NRPTE];
 };
 
-static kmem_cache_t * pte_chain_cache;
-static inline struct pte_chain * pte_chain_alloc(void);
-static inline void pte_chain_free(struct pte_chain *, struct pte_chain *,
-		struct page *);
+static kmem_cache_t	*pte_chain_cache;
+
+/*
+ * pte_chain list management policy:
+ *
+ * - If a page has a pte_chain list then it is shared by at least two processes,
+ *   because a single sharing uses PageDirect. (Well, this isn't true yet,
+ *   coz this code doesn't collapse singletons back to PageDirect on the remove
+ *   path).
+ * - A pte_chain list has free space only in the head member - all succeeding
+ *   members are 100% full.
+ * - If the head element has free space, it occurs in its leading slots.
+ * - All free space in the pte_chain is at the start of the head member.
+ * - Insertion into the pte_chain puts a pte pointer in the last free slot of
+ *   the head member.
+ * - Removal from a pte chain moves the head pte of the head member onto the
+ *   victim pte and frees the head member if it became empty.
+ */
+
+/**
+ * pte_chain_alloc - allocate a pte_chain struct
+ *
+ * Returns a pointer to a fresh pte_chain structure. Allocates new
+ * pte_chain structures as required.
+ * Caller needs to hold the page's pte_chain_lock.
+ */
+static inline struct pte_chain *pte_chain_alloc(void)
+{
+	struct pte_chain *ret;
+
+	ret = kmem_cache_alloc(pte_chain_cache, GFP_ATOMIC);
+#ifdef DEBUG_RMAP
+	{
+		int i;
+		for (i = 0; i < NRPTE; i++)
+			BUG_ON(ret->ptes[i]);
+		BUG_ON(ret->next);
+	}
+#endif
+	return ret;
+}
+
+/**
+ * pte_chain_free - free pte_chain structure
+ * @pte_chain: pte_chain struct to free
+ */
+static inline void pte_chain_free(struct pte_chain *pte_chain)
+{
+	pte_chain->next = NULL;
+	kmem_cache_free(pte_chain_cache, pte_chain);
+}
+
+/**
+ ** VM stuff below this comment
+ **/
 
 /**
  * page_referenced - test if the page was referenced
@@ -65,6 +116,9 @@
  * In addition to this it checks if the processes holding the
  * page are over or under their RSS limit.
  * Caller needs to hold the pte_chain_lock.
+ *
+ * If the page has a single-entry pte_chain, collapse that back to a PageDirect
+ * representation.  This way, it's only done under memory pressure.
  */
 int page_referenced(struct page * page, int * rsslimit)
 {
@@ -75,16 +129,45 @@
 	if (PageTestandClearReferenced(page))
 		referenced++;
 
-	/* Check all the page tables mapping this page. */
-	for (pc = page->pte_chain; pc; pc = pc->next) {
-		pte_t * ptep = pc->ptep;
-
-		if (ptep_test_and_clear_young(ptep))
+	if (PageDirect(page)) {
+		pte_t *pte = rmap_ptep_map(page->pte.direct);
+		if (ptep_test_and_clear_young(pte))
 			referenced++;
 
-		mm = ptep_to_mm(ptep);
+		mm = ptep_to_mm(pte);
 		if (mm->rss < mm->rlimit_rss)
 			under_rsslimit++;
+		rmap_ptep_unmap(pte);
+	} else {
+		int nr_chains = 0;
+
+		/* Check all the page tables mapping this page. */
+		for (pc = page->pte.chain; pc; pc = pc->next) {
+			int i;
+
+			for (i = NRPTE-1; i >= 0; i--) {
+				pte_addr_t pte_paddr = pc->ptes[i];
+				pte_t *p;
+
+				if (!pte_paddr)
+					break;
+				p = rmap_ptep_map(pte_paddr);
+				if (ptep_test_and_clear_young(p))
+					referenced++;
+				mm = ptep_to_mm(p);
+				if (mm->rss < mm->rlimit_rss)
+					under_rsslimit++;
+				rmap_ptep_unmap(p);
+				nr_chains++;
+			}
+		}
+		if (nr_chains == 1) {
+			pc = page->pte.chain;
+			page->pte.direct = pc->ptes[NRPTE-1];
+			SetPageDirect(page);
+			pc->ptes[NRPTE-1] = 0;
+			pte_chain_free(pc);
+		}
 	}
 
 	/*
@@ -106,7 +189,9 @@
  */
 void page_add_rmap(struct page * page, pte_t * ptep)
 {
-	struct pte_chain * pte_chain;
+	pte_addr_t pte_paddr = ptep_to_paddr(ptep);
+	struct pte_chain *pte_chain;
+	int i;
 
 #ifdef DEBUG_RMAP
 	if (!page || !ptep)
@@ -117,31 +202,75 @@
 		BUG();
 #endif
 
-	if (!VALID_PAGE(page) || PageReserved(page))
+	if (!pfn_valid(page_to_pfn(page)) || PageReserved(page))
 		return;
 
-#ifdef DEBUG_RMAP
 	pte_chain_lock(page);
+
+#ifdef DEBUG_RMAP
+	/*
+	 * This stuff needs help to get up to highmem speed.
+	 */
 	{
 		struct pte_chain * pc;
-		for (pc = page->pte_chain; pc; pc = pc->next) {
-			if (pc->ptep == ptep)
+		if (PageDirect(page)) {
+			if (page->pte.direct == pte_paddr)
 				BUG();
+		} else {
+			for (pc = page->pte.chain; pc; pc = pc->next) {
+				for (i = 0; i < NRPTE; i++) {
+					pte_addr_t p = pc->ptes[i];
+
+					if (p && p == pte_paddr)
+						BUG();
+				}
+			}
 		}
 	}
-	pte_chain_unlock(page);
 #endif
 
-	pte_chain = pte_chain_alloc();
+	if (page->pte.direct == 0) {
+		page->pte.direct = pte_paddr;
+		SetPageDirect(page);
+		//inc_page_state(nr_mapped);
+		goto out;
+	}
 
-	pte_chain_lock(page);
+	if (PageDirect(page)) {
+		/* Convert a direct pointer into a pte_chain */
+		ClearPageDirect(page);
+		pte_chain = pte_chain_alloc();
+		pte_chain->ptes[NRPTE-1] = page->pte.direct;
+		pte_chain->ptes[NRPTE-2] = pte_paddr;
+		page->pte.direct = 0;
+		page->pte.chain = pte_chain;
+		goto out;
+	}
+
+	pte_chain = page->pte.chain;
+	if (pte_chain->ptes[0]) {	/* It's full */
+		struct pte_chain *new;
+
+		new = pte_chain_alloc();
+		new->next = pte_chain;
+		page->pte.chain = new;
+		new->ptes[NRPTE-1] = pte_paddr;
+		goto out;
+	}
 
-	/* Hook up the pte_chain to the page. */
-	pte_chain->ptep = ptep;
-	pte_chain->next = page->pte_chain;
-	page->pte_chain = pte_chain;
+	BUG_ON(!pte_chain->ptes[NRPTE-1]);
 
+	for (i = NRPTE-2; i >= 0; i--) {
+		if (!pte_chain->ptes[i]) {
+			pte_chain->ptes[i] = pte_paddr;
+			goto out;
+		}
+	}
+	BUG();
+out:
 	pte_chain_unlock(page);
+	//inc_page_state(nr_reverse_maps);
+	return;
 }
 
 /**
@@ -156,34 +285,79 @@
  */
 void page_remove_rmap(struct page * page, pte_t * ptep)
 {
-	struct pte_chain * pc, * prev_pc = NULL;
+	pte_addr_t pte_paddr = ptep_to_paddr(ptep);
+	struct pte_chain *pc;
 
 	if (!page || !ptep)
 		BUG();
-	if (!VALID_PAGE(page) || PageReserved(page))
+	if (!pfn_valid(page_to_pfn(page)) || PageReserved(page))
 		return;
+	if (!page_mapped(page))
+		return;		/* remap_page_range() from a driver? */
 
 	pte_chain_lock(page);
-	for (pc = page->pte_chain; pc; prev_pc = pc, pc = pc->next) {
-		if (pc->ptep == ptep) {
-			pte_chain_free(pc, prev_pc, page);
+
+	if (PageDirect(page)) {
+		if (page->pte.direct == pte_paddr) {
+			page->pte.direct = 0;
+			//dec_page_state(nr_reverse_maps);
+			ClearPageDirect(page);
 			goto out;
 		}
+	} else {
+		struct pte_chain *start = page->pte.chain;
+		int victim_i = -1;
+
+		for (pc = start; pc; pc = pc->next) {
+			int i;
+
+			if (pc->next)
+				prefetch(pc->next);
+			for (i = 0; i < NRPTE; i++) {
+				pte_addr_t pa = pc->ptes[i];
+
+				if (!pa)
+					continue;
+				if (victim_i == -1)
+					victim_i = i;
+				if (pa != pte_paddr)
+					continue;
+				pc->ptes[i] = start->ptes[victim_i];
+				//dec_page_state(nr_reverse_maps);
+				start->ptes[victim_i] = 0;
+				if (victim_i == NRPTE-1) {
+					/* Emptied a pte_chain */
+					page->pte.chain = start->next;
+					pte_chain_free(start);
+				} else {
+					/* Do singleton->PageDirect here */
+				}
+				goto out;
+			}
+		}
 	}
 #ifdef DEBUG_RMAP
 	/* Not found. This should NEVER happen! */
 	printk(KERN_ERR "page_remove_rmap: pte_chain %p not present.\n", ptep);
 	printk(KERN_ERR "page_remove_rmap: only found: ");
-	for (pc = page->pte_chain; pc; pc = pc->next)
-		printk("%p ", pc->ptep);
+	if (PageDirect(page)) {
+		printk("%llx", (u64)page->pte.direct);
+	} else {
+		for (pc = page->pte.chain; pc; pc = pc->next) {
+			int i;
+			for (i = 0; i < NRPTE; i++)
+				printk(" %d:%llx", i, (u64)pc->ptes[i]);
+		}
+	}
 	printk("\n");
 	printk(KERN_ERR "page_remove_rmap: driver cleared PG_reserved ?\n");
 #endif
 
 out:
 	pte_chain_unlock(page);
+	//if (!page_mapped(page))
+	//	dec_page_state(nr_mapped);
 	return;
-			
 }
 
 /**
@@ -195,14 +369,16 @@
  * table entry mapping a page. Because locking order here is opposite
  * to the locking order used by the page fault path, we use trylocks.
  * Locking:
+ *	pagemap_lru_lock		page_launder()
  *	   lru lock			page_launder()
  *	    page lock			page_launder(), trylock
  *		pte_chain_lock		page_launder()
  *		    mm->page_table_lock	try_to_unmap_one(), trylock
  */
-static int FASTCALL(try_to_unmap_one(struct page *, pte_t *));
-static int try_to_unmap_one(struct page * page, pte_t * ptep)
+static int FASTCALL(try_to_unmap_one(struct page *, pte_addr_t));
+static int try_to_unmap_one(struct page * page, pte_addr_t paddr)
 {
+	pte_t *ptep = rmap_ptep_map(paddr);
 	unsigned long address = ptep_to_address(ptep);
 	struct mm_struct * mm = ptep_to_mm(ptep);
 	struct vm_area_struct * vma;
@@ -216,8 +392,11 @@
 	 * We need the page_table_lock to protect us from page faults,
 	 * munmap, fork, etc...
 	 */
-	if (!spin_trylock(&mm->page_table_lock))
+	if (!spin_trylock(&mm->page_table_lock)) {
+		rmap_ptep_unmap(ptep);
 		return SWAP_AGAIN;
+	}
+
 
 	/* During mremap, it's possible pages are not in a VMA. */
 	vma = find_vma(mm, address);
@@ -239,8 +418,7 @@
 
 	/* Store the swap location in the pte. See handle_pte_fault() ... */
 	if (PageSwapCache(page)) {
-		swp_entry_t entry;
-		entry.val = page->index;
+		swp_entry_t entry = { .val = page->index };
 		swap_duplicate(entry);
 		set_pte(ptep, swp_entry_to_pte(entry));
 	}
@@ -254,6 +432,7 @@
 	ret = SWAP_SUCCESS;
 
 out_unlock:
+	rmap_ptep_unmap(ptep);
 	spin_unlock(&mm->page_table_lock);
 	return ret;
 }
@@ -263,6 +442,7 @@
  * @page: the page to get unmapped
  *
  * Tries to remove all the page table entries which are mapping this
+ * page, used in the pageout path.  Caller must hold pagemap_lru_lock
  * page, used in the pageout path.  Caller must hold lru lock
  * and the page lock.  Return values are:
  *
@@ -273,11 +453,12 @@
  */
 int try_to_unmap(struct page * page)
 {
-	struct pte_chain * pc, * next_pc, * prev_pc = NULL;
+	struct pte_chain *pc, *next_pc, *start;
 	int ret = SWAP_SUCCESS;
+	int victim_i = -1;
 
 	/* This page should not be on the pageout lists. */
-	if (!VALID_PAGE(page) || PageReserved(page))
+	if (PageReserved(page))
 		BUG();
 	if (!PageLocked(page))
 		BUG();
@@ -285,25 +466,66 @@
 	if (!page->mapping)
 		BUG();
 
-	for (pc = page->pte_chain; pc; pc = next_pc) {
+	if (PageDirect(page)) {
+		ret = try_to_unmap_one(page, page->pte.direct);
+		if (ret == SWAP_SUCCESS) {
+			page->pte.direct = 0;
+			//dec_page_state(nr_reverse_maps);
+			ClearPageDirect(page);
+		}
+		goto out;
+	}		
+
+	start = page->pte.chain;
+	for (pc = start; pc; pc = next_pc) {
+		int i;
+
 		next_pc = pc->next;
-		switch (try_to_unmap_one(page, pc->ptep)) {
+		if (next_pc)
+			prefetch(next_pc);
+		for (i = 0; i < NRPTE; i++) {
+			pte_addr_t pte_paddr = pc->ptes[i];
+
+			if (!pte_paddr)
+				continue;
+			if (victim_i == -1) 
+				victim_i = i;
+
+			switch (try_to_unmap_one(page, pte_paddr)) {
 			case SWAP_SUCCESS:
-				/* Free the pte_chain struct. */
-				pte_chain_free(pc, prev_pc, page);
+				/*
+				 * Release a slot.  If we're releasing the
+				 * first pte in the first pte_chain then
+				 * pc->ptes[i] and start->ptes[victim_i] both
+				 * refer to the same thing.  It works out.
+				 */
+				pc->ptes[i] = start->ptes[victim_i];
+				start->ptes[victim_i] = 0;
+				//dec_page_state(nr_reverse_maps);
+				victim_i++;
+				if (victim_i == NRPTE) {
+					page->pte.chain = start->next;
+					pte_chain_free(start);
+					start = page->pte.chain;
+					victim_i = 0;
+				}
 				break;
 			case SWAP_AGAIN:
 				/* Skip this pte, remembering status. */
-				prev_pc = pc;
 				ret = SWAP_AGAIN;
 				continue;
 			case SWAP_FAIL:
-				return SWAP_FAIL;
+				ret = SWAP_FAIL;
+				goto out;
 			case SWAP_ERROR:
-				return SWAP_ERROR;
+				ret = SWAP_ERROR;
+				goto out;
+			}
 		}
 	}
-
+out:
+	//if (!page_mapped(page))
+	//	dec_page_state(nr_mapped);
 	return ret;
 }
 
@@ -312,46 +534,11 @@
  ** functions.
  **/
 
-/**
- * pte_chain_free - free pte_chain structure
- * @pte_chain: pte_chain struct to free
- * @prev_pte_chain: previous pte_chain on the list (may be NULL)
- * @page: page this pte_chain hangs off (may be NULL)
- *
- * This function unlinks pte_chain from the singly linked list it
- * may be on and adds the pte_chain to the free list. May also be
- * called for new pte_chain structures which aren't on any list yet.
- * Caller needs to hold the pte_chain_lock if the page is non-NULL.
- */
-static inline void pte_chain_free(struct pte_chain * pte_chain,
-		struct pte_chain * prev_pte_chain, struct page * page)
+static void pte_chain_ctor(void *p, kmem_cache_t *cachep, unsigned long flags)
 {
-	if (prev_pte_chain)
-		prev_pte_chain->next = pte_chain->next;
-	else if (page)
-		page->pte_chain = pte_chain->next;
-
-	kmem_cache_free(pte_chain_cache, pte_chain);
-}
-
-/**
- * pte_chain_alloc - allocate a pte_chain struct
- *
- * Returns a pointer to a fresh pte_chain structure. Allocates new
- * pte_chain structures as required.
- * Caller needs to hold the page's pte_chain_lock.
- */
-static inline struct pte_chain * pte_chain_alloc(void)
-{
-	struct pte_chain * pte_chain;
-
-	pte_chain = kmem_cache_alloc(pte_chain_cache, GFP_ATOMIC);
-
-	/* I don't think anybody managed to trigger this one -- Rik */
-	if (unlikely(pte_chain == NULL))
-		panic("fix pte_chain OOM handling\n");
+	struct pte_chain *pc = p;
 
-	return pte_chain;
+	memset(pc, 0, sizeof(*pc));
 }
 
 void __init pte_chain_init(void)
@@ -360,7 +547,7 @@
 						sizeof(struct pte_chain),
 						0,
 						0,
-						NULL,
+						pte_chain_ctor,
 						NULL);
 
 	if (!pte_chain_cache)
diff -urN linux-2.4-rmap/mm/swapfile.c work/mm/swapfile.c
--- linux-2.4-rmap/mm/swapfile.c	Mon Nov 25 17:05:40 2002
+++ work/mm/swapfile.c	Mon Nov 25 17:03:55 2002
@@ -383,7 +383,7 @@
 	unsigned long address, unsigned long size, unsigned long offset,
 	swp_entry_t entry, struct page* page)
 {
-	pte_t * pte;
+	pte_t *pte, *mapping;
 	unsigned long end;
 
 	if (pmd_none(*dir))
@@ -393,7 +393,7 @@
 		pmd_clear(dir);
 		return;
 	}
-	pte = pte_offset(dir, address);
+	mapping = pte = pte_offset_map(dir, address);
 	offset += address & PMD_MASK;
 	address &= ~PMD_MASK;
 	end = address + size;
@@ -404,6 +404,7 @@
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
+	pte_unmap(mapping);
 }
 
 /* mmlist_lock and vma->vm_mm->page_table_lock are held */
diff -urN linux-2.4-rmap/mm/vmalloc.c work/mm/vmalloc.c
--- linux-2.4-rmap/mm/vmalloc.c	Mon Nov 25 17:05:40 2002
+++ work/mm/vmalloc.c	Mon Nov 25 17:03:55 2002
@@ -31,7 +31,7 @@
 		pmd_clear(pmd);
 		return;
 	}
-	pte = pte_offset(pmd, address);
+	pte = pte_offset_kernel(pmd, address);
 	address &= ~PMD_MASK;
 	end = address + size;
 	if (end > PMD_SIZE)
@@ -126,7 +126,7 @@
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
 	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
+		pte_t * pte = pte_alloc_kernel(&init_mm, pmd, address);
 		if (!pte)
 			return -ENOMEM;
 		if (alloc_area_pte(pte, address, end - address, gfp_mask, prot))
diff -urN linux-2.4-rmap/mm/vmscan.c work/mm/vmscan.c
--- linux-2.4-rmap/mm/vmscan.c	Mon Nov 25 17:05:40 2002
+++ work/mm/vmscan.c	Mon Nov 25 17:03:55 2002
@@ -1145,8 +1145,8 @@
  * no VM pressure at all it shouldn't age stuff either otherwise everything
  * ends up at the maximum age. 
  */
-#define MAX_AGING_INTERVAL 5*HZ
-#define MIN_AGING_INTERVAL HZ/2
+#define MAX_AGING_INTERVAL ((unsigned long)5*HZ)
+#define MIN_AGING_INTERVAL ((unsigned long)HZ/2)
 int kscand(void *unused)
 {
 	struct task_struct *tsk = current;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
