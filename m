Subject: [PATCH/RFC] remove flush_tlb_pgtables
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 10:44:06 +1000
Message-Id: <1185497047.5495.159.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

After my frv patch, nobody uses flush_tlb_pgtables anymore, this patch
removes all remaining traces of it from all archs.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

This is part of a couple of pre-reqs cleanup for my mmu_gather work,
which makes things easier later on. I'll do more cleanup afterward, such
as removing flush_tlb_all() which isn't used anymore, etc...

Index: linux-work/include/asm-alpha/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-alpha/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-alpha/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -92,17 +92,6 @@ flush_tlb_other(struct mm_struct *mm)
 	if (*mmc) *mmc = 0;
 }
 
-/* Flush a specified range of user mapping page tables from TLB.
-   Although Alpha uses VPTE caches, this can be a nop, as Alpha does
-   not have finegrained tlb flushing, so it will flush VPTE stuff
-   during next flush_tlb_range.  */
-
-static inline void
-flush_tlb_pgtables(struct mm_struct *mm, unsigned long start,
-		   unsigned long end)
-{
-}
-
 #ifndef CONFIG_SMP
 /* Flush everything (kernel mapping may also have changed
    due to vmalloc/vfree).  */
Index: linux-work/include/asm-arm/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-arm/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-arm/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -463,11 +463,6 @@ extern void flush_tlb_kernel_range(unsig
  */
 extern void update_mmu_cache(struct vm_area_struct *vma, unsigned long addr, pte_t pte);
 
-/*
- * ARM processors do not cache TLB tables in RAM.
- */
-#define flush_tlb_pgtables(mm,start,end)	do { } while (0)
-
 #endif
 
 #endif /* CONFIG_MMU */
Index: linux-work/include/asm-arm26/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-arm26/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-arm26/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -15,7 +15,6 @@
 #define flush_tlb_page(vma, vmaddr)		do { printk("flush_tlb_page\n");} while (0)  // IS THIS RIGHT?
 #define flush_tlb_range(vma,start,end)		\
 		do { memc_update_mm(vma->vm_mm); (void)(start); (void)(end); } while (0)
-#define flush_tlb_pgtables(mm,start,end)        do { printk("flush_tlb_pgtables\n");} while (0)
 #define flush_tlb_kernel_range(s,e)             do { printk("flush_tlb_range\n");} while (0)
 
 /*
Index: linux-work/include/asm-avr32/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-avr32/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-avr32/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -19,7 +19,6 @@
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  */
 extern void flush_tlb(void);
 extern void flush_tlb_all(void);
@@ -29,12 +28,6 @@ extern void flush_tlb_range(struct vm_ar
 extern void flush_tlb_page(struct vm_area_struct *vma, unsigned long page);
 extern void __flush_tlb_page(unsigned long asid, unsigned long page);
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-	/* Nothing to do */
-}
-
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 
 #endif /* __ASM_AVR32_TLBFLUSH_H */
Index: linux-work/include/asm-blackfin/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-blackfin/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-blackfin/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -53,10 +53,4 @@ static inline void flush_tlb_kernel_page
 	BUG();
 }
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-	BUG();
-}
-
 #endif
Index: linux-work/include/asm-cris/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-cris/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-cris/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -38,13 +38,6 @@ static inline void flush_tlb_range(struc
 	flush_tlb_mm(vma->vm_mm);
 }
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-                                      unsigned long start, unsigned long end)
-{
-        /* CRIS does not keep any page table caches in TLB */
-}
-
-
 static inline void flush_tlb(void)
 {
 	flush_tlb_mm(current->mm);
Index: linux-work/include/asm-frv/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-frv/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-frv/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -57,7 +57,6 @@ do {								\
 #define __flush_tlb_global()			flush_tlb_all()
 #define flush_tlb()				flush_tlb_all()
 #define flush_tlb_kernel_range(start, end)	flush_tlb_all()
-#define flush_tlb_pgtables(mm,start,end)	do { } while(0)
 
 #else
 
@@ -66,7 +65,6 @@ do {								\
 #define flush_tlb_mm(mm)			BUG()
 #define flush_tlb_page(vma,addr)		BUG()
 #define flush_tlb_range(mm,start,end)		BUG()
-#define flush_tlb_pgtables(mm,start,end)	BUG()
 #define flush_tlb_kernel_range(start, end)	BUG()
 
 #endif
Index: linux-work/include/asm-h8300/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-h8300/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-h8300/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -52,10 +52,4 @@ static inline void flush_tlb_kernel_page
 	BUG();
 }
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-	BUG();
-}
-
 #endif /* _H8300_TLBFLUSH_H */
Index: linux-work/include/asm-i386/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-i386/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-i386/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -78,7 +78,6 @@
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  *  - flush_tlb_others(cpumask, mm, va) flushes a TLBs on other cpus
  *
  * ..but the i386 has somewhat limited tlb flushing capabilities,
@@ -166,10 +165,4 @@ static inline void flush_tlb_kernel_rang
 	flush_tlb_all();
 }
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-	/* i386 does not keep any page table caches in TLB */
-}
-
 #endif /* _I386_TLBFLUSH_H */
Index: linux-work/include/asm-ia64/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-ia64/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-ia64/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -84,19 +84,6 @@ flush_tlb_page (struct vm_area_struct *v
 }
 
 /*
- * Flush the TLB entries mapping the virtually mapped linear page
- * table corresponding to address range [START-END).
- */
-static inline void
-flush_tlb_pgtables (struct mm_struct *mm, unsigned long start, unsigned long end)
-{
-	/*
-	 * Deprecated.  The virtual page table is now flushed via the normal gather/flush
-	 * interface (see tlb.h).
-	 */
-}
-
-/*
  * Flush the local TLB. Invoked from another cpu using an IPI.
  */
 #ifdef CONFIG_SMP
Index: linux-work/include/asm-m32r/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-m32r/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-m32r/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -12,7 +12,6 @@
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  */
 
 extern void local_flush_tlb_all(void);
@@ -93,8 +92,6 @@ static __inline__ void __flush_tlb_all(v
 	);
 }
 
-#define flush_tlb_pgtables(mm, start, end)	do { } while (0)
-
 extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t);
 
 #endif	/* _ASM_M32R_TLBFLUSH_H */
Index: linux-work/include/asm-m68k/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-m68k/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-m68k/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -92,11 +92,6 @@ static inline void flush_tlb_kernel_rang
 	flush_tlb_all();
 }
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-}
-
 #else
 
 
@@ -219,11 +214,6 @@ static inline void flush_tlb_kernel_page
 	sun3_put_segmap (addr & ~(SUN3_PMEG_SIZE - 1), SUN3_INVALID_PMEG);
 }
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-}
-
 #endif
 
 #endif /* _M68K_TLBFLUSH_H */
Index: linux-work/include/asm-m68knommu/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-m68knommu/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-m68knommu/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -52,10 +52,4 @@ static inline void flush_tlb_kernel_page
 	BUG();
 }
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-	BUG();
-}
-
 #endif /* _M68KNOMMU_TLBFLUSH_H */
Index: linux-work/include/asm-mips/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-mips/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-mips/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -11,7 +11,6 @@
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  */
 extern void local_flush_tlb_all(void);
 extern void local_flush_tlb_mm(struct mm_struct *mm);
@@ -45,10 +44,4 @@ extern void flush_tlb_one(unsigned long 
 
 #endif /* CONFIG_SMP */
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-	unsigned long start, unsigned long end)
-{
-	/* Nothing to do on MIPS.  */
-}
-
 #endif /* __ASM_TLBFLUSH_H */
Index: linux-work/include/asm-parisc/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-parisc/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-parisc/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -57,10 +57,6 @@ static inline void flush_tlb_mm(struct m
 #endif
 }
 
-extern __inline__ void flush_tlb_pgtables(struct mm_struct *mm, unsigned long start, unsigned long end)
-{
-}
- 
 static inline void flush_tlb_page(struct vm_area_struct *vma,
 	unsigned long addr)
 {
Index: linux-work/include/asm-powerpc/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-powerpc/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-powerpc/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -8,7 +8,6 @@
  *  - flush_tlb_page_nohash(vma, vmaddr) flushes one page if SW loaded TLB
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  *
  *  This program is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU General Public License
@@ -173,15 +172,5 @@ extern void __flush_hash_table_range(str
  */
 extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t);
 
-/*
- * This is called in munmap when we have freed up some page-table
- * pages.  We don't need to do anything here, there's nothing special
- * about our page-table pages.  -- paulus
- */
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-}
-
 #endif /*__KERNEL__ */
 #endif /* _ASM_POWERPC_TLBFLUSH_H */
Index: linux-work/include/asm-s390/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-s390/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-s390/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -14,7 +14,6 @@
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  */
 
 /*
@@ -152,10 +151,4 @@ static inline void flush_tlb_range(struc
 
 #endif
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-                                      unsigned long start, unsigned long end)
-{
-        /* S/390 does not keep any page table caches in TLB */
-}
-
 #endif /* _S390_TLBFLUSH_H */
Index: linux-work/include/asm-sh/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-sh/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-sh/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -9,7 +9,6 @@
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  */
 extern void local_flush_tlb_all(void);
 extern void local_flush_tlb_mm(struct mm_struct *mm);
@@ -47,9 +46,4 @@ extern void flush_tlb_one(unsigned long 
 
 #endif /* CONFIG_SMP */
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-	/* Nothing to do */
-}
 #endif /* __ASM_SH_TLBFLUSH_H */
Index: linux-work/include/asm-sh64/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-sh64/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-sh64/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -20,10 +20,6 @@ extern void flush_tlb_mm(struct mm_struc
 extern void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
 			    unsigned long end);
 extern void flush_tlb_page(struct vm_area_struct *vma, unsigned long page);
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-}
 
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 
Index: linux-work/include/asm-sparc/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-sparc/tlbflush.h	2007-07-27 10:37:48.000000000 +1000
+++ linux-work/include/asm-sparc/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -13,7 +13,6 @@
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  */
 
 #ifdef CONFIG_SMP
@@ -42,11 +41,6 @@ BTFIXUPDEF_CALL(void, flush_tlb_mm, stru
 BTFIXUPDEF_CALL(void, flush_tlb_range, struct vm_area_struct *, unsigned long, unsigned long)
 BTFIXUPDEF_CALL(void, flush_tlb_page, struct vm_area_struct *, unsigned long)
 
-// Thanks to Anton Blanchard, our pagetables became uncached in 2.4. Wee!
-// extern void flush_tlb_pgtables(struct mm_struct *mm,
-//     unsigned long start, unsigned long end);
-#define flush_tlb_pgtables(mm, start, end)	do{ }while(0)
-
 #define flush_tlb_all() BTFIXUP_CALL(flush_tlb_all)()
 #define flush_tlb_mm(mm) BTFIXUP_CALL(flush_tlb_mm)(mm)
 #define flush_tlb_range(vma,start,end) BTFIXUP_CALL(flush_tlb_range)(vma,start,end)
Index: linux-work/include/asm-sparc64/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-sparc64/tlbflush.h	2007-07-27 10:37:49.000000000 +1000
+++ linux-work/include/asm-sparc64/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -41,11 +41,4 @@ do {	flush_tsb_kernel_range(start,end); 
 
 #endif /* ! CONFIG_SMP */
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm, unsigned long start, unsigned long end)
-{
-	/* We don't use virtual page tables for TLB miss processing
-	 * any more.  Nowadays we use the TSB.
-	 */
-}
-
 #endif /* _SPARC64_TLBFLUSH_H */
Index: linux-work/include/asm-um/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-um/tlbflush.h	2007-07-27 10:37:49.000000000 +1000
+++ linux-work/include/asm-um/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -18,7 +18,6 @@
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_kernel_vm() flushes the kernel vm area
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  */
 
 extern void flush_tlb_all(void);
@@ -42,9 +41,4 @@ extern void flush_tlb_kernel_vm(void);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 extern void __flush_tlb_one(unsigned long addr);
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-}
-
 #endif
Index: linux-work/include/asm-v850/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-v850/tlbflush.h	2007-07-27 10:37:49.000000000 +1000
+++ linux-work/include/asm-v850/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -61,10 +61,4 @@ static inline void flush_tlb_kernel_page
 	BUG ();
 }
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-	BUG ();
-}
-
 #endif /* __V850_TLBFLUSH_H__ */
Index: linux-work/include/asm-x86_64/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-x86_64/tlbflush.h	2007-07-27 10:37:49.000000000 +1000
+++ linux-work/include/asm-x86_64/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -31,7 +31,6 @@ static inline void __flush_tlb_all(void)
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_pgtables(mm, start, end) flushes a range of page tables
  *
  * x86-64 can only flush individual pages or full VMs. For a range flush
  * we always do the full VM. Might be worth trying if for a small
@@ -98,12 +97,4 @@ static inline void flush_tlb_kernel_rang
 	flush_tlb_all();
 }
 
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
-{
-	/* x86_64 does not keep any page table caches in a software TLB.
-	   The CPUs do in their hardware TLBs, but they are handled
-	   by the normal TLB flushing algorithms. */
-}
-
 #endif /* _X8664_TLBFLUSH_H */
Index: linux-work/include/asm-xtensa/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-xtensa/tlbflush.h	2007-07-27 10:37:49.000000000 +1000
+++ linux-work/include/asm-xtensa/tlbflush.h	2007-07-27 10:38:23.000000000 +1000
@@ -41,17 +41,6 @@ extern void flush_tlb_range(struct vm_ar
 
 #define flush_tlb_kernel_range(start,end) flush_tlb_all()
 
-
-/* This is calld in munmap when we have freed up some page-table pages.
- * We don't need to do anything here, there's nothing special about our
- * page-table pages.
- */
-
-static inline void flush_tlb_pgtables(struct mm_struct *mm,
-                                      unsigned long start, unsigned long end)
-{
-}
-
 /* TLB operations. */
 
 static inline unsigned long itlb_probe(unsigned long addr)
Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2007-07-27 10:37:49.000000000 +1000
+++ linux-work/mm/memory.c	2007-07-27 10:38:23.000000000 +1000
@@ -259,9 +259,6 @@ void free_pgd_range(struct mmu_gather **
 			continue;
 		free_pud_range(*tlb, pgd, addr, next, floor, ceiling);
 	} while (pgd++, addr = next, addr != end);
-
-	if (!(*tlb)->fullmm)
-		flush_tlb_pgtables((*tlb)->mm, start, end);
 }
 
 void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
Index: linux-work/Documentation/cachetlb.txt
===================================================================
--- linux-work.orig/Documentation/cachetlb.txt	2007-07-27 10:38:44.000000000 +1000
+++ linux-work/Documentation/cachetlb.txt	2007-07-27 10:39:00.000000000 +1000
@@ -87,30 +87,7 @@ changes occur:
 
 	This is used primarily during fault processing.
 
-5) void flush_tlb_pgtables(struct mm_struct *mm,
-			   unsigned long start, unsigned long end)
-
-   The software page tables for address space 'mm' for virtual
-   addresses in the range 'start' to 'end-1' are being torn down.
-
-   Some platforms cache the lowest level of the software page tables
-   in a linear virtually mapped array, to make TLB miss processing
-   more efficient.  On such platforms, since the TLB is caching the
-   software page table structure, it needs to be flushed when parts
-   of the software page table tree are unlinked/freed.
-
-   Sparc64 is one example of a platform which does this.
-
-   Usually, when munmap()'ing an area of user virtual address
-   space, the kernel leaves the page table parts around and just
-   marks the individual pte's as invalid.  However, if very large
-   portions of the address space are unmapped, the kernel frees up
-   those portions of the software page tables to prevent potential
-   excessive kernel memory usage caused by erratic mmap/mmunmap
-   sequences.  It is at these times that flush_tlb_pgtables will
-   be invoked.
-
-6) void update_mmu_cache(struct vm_area_struct *vma,
+5) void update_mmu_cache(struct vm_area_struct *vma,
 			 unsigned long address, pte_t pte)
 
 	At the end of every page fault, this routine is invoked to
@@ -123,7 +100,7 @@ changes occur:
 	translations for software managed TLB configurations.
 	The sparc64 port currently does this.
 
-7) void tlb_migrate_finish(struct mm_struct *mm)
+6) void tlb_migrate_finish(struct mm_struct *mm)
 
 	This interface is called at the end of an explicit
 	process migration. This interface provides a hook
@@ -133,7 +110,7 @@ changes occur:
 	The ia64 sn2 platform is one example of a platform
 	that uses this interface.
 
-8) void lazy_mmu_prot_update(pte_t pte)
+7) void lazy_mmu_prot_update(pte_t pte)
 	This interface is called whenever the protection on
 	any user PTEs change.  This interface provides a notification
 	to architecture specific code to take appropriate action.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
