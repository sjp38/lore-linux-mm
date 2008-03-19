Subject: [RFC][PATCH 2/2]: MM: Make Page Tables Relocatable 
Message-Id: <20080319142016.E048DDC98D@localhost>
Date: Wed, 19 Mar 2008 07:20:16 -0700 (PDT)
From: rossb@google.com (Ross Biro)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rossb@google.com
List-ID: <linux-mm.kvack.org>

---
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/i386/mm/hugetlbpage.c 2.6.23a/arch/i386/mm/hugetlbpage.c
--- 2.6.23/arch/i386/mm/hugetlbpage.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/i386/mm/hugetlbpage.c	2007-10-29 09:48:48.000000000 -0700
@@ -87,6 +87,7 @@ static void huge_pmd_share(struct mm_str
 		goto out;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pud(&pud, mm, addr);
 	if (pud_none(*pud))
 		pud_populate(mm, pud, (unsigned long) spte & PAGE_MASK);
 	else
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/powerpc/mm/fault.c 2.6.23a/arch/powerpc/mm/fault.c
--- 2.6.23/arch/powerpc/mm/fault.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/powerpc/mm/fault.c	2007-10-29 09:38:09.000000000 -0700
@@ -301,6 +301,8 @@ good_area:
 		if (get_pteptr(mm, address, &ptep, &pmdp)) {
 			spinlock_t *ptl = pte_lockptr(mm, pmdp);
 			spin_lock(ptl);
+			delimbo_pte(&ptep, &ptl, &pmdp, mm, address);
+
 			if (pte_present(*ptep)) {
 				struct page *page = pte_page(*ptep);
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/powerpc/mm/hugetlbpage.c 2.6.23a/arch/powerpc/mm/hugetlbpage.c
--- 2.6.23/arch/powerpc/mm/hugetlbpage.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/powerpc/mm/hugetlbpage.c	2007-10-29 09:53:36.000000000 -0700
@@ -77,6 +77,7 @@ static int __hugepte_alloc(struct mm_str
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_hpd(&hpdp, mm, address);
 	if (!hugepd_none(*hpdp))
 		kmem_cache_free(huge_pgtable_cache, new);
 	else
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/ppc/mm/fault.c 2.6.23a/arch/ppc/mm/fault.c
--- 2.6.23/arch/ppc/mm/fault.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/ppc/mm/fault.c	2007-10-29 09:38:19.000000000 -0700
@@ -219,6 +219,7 @@ good_area:
 		if (get_pteptr(mm, address, &ptep, &pmdp)) {
 			spinlock_t *ptl = pte_lockptr(mm, pmdp);
 			spin_lock(ptl);
+			delimbo_pte(&ptep, &ptl, &pmdp, mm, address);
 			if (pte_present(*ptep)) {
 				struct page *page = pte_page(*ptep);
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/x86_64/kernel/smp.c 2.6.23a/arch/x86_64/kernel/smp.c
--- 2.6.23/arch/x86_64/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/x86_64/kernel/smp.c	2008-01-14 10:46:49.000000000 -0800
@@ -56,6 +56,7 @@ union smp_flush_state {
 		struct mm_struct *flush_mm;
 		unsigned long flush_va;
 #define FLUSH_ALL	-1ULL
+#define RELOAD_ALL	-2ULL
 		spinlock_t tlbstate_lock;
 	};
 	char pad[SMP_CACHE_BYTES];
@@ -155,6 +156,8 @@ asmlinkage void smp_invalidate_interrupt
 		if (read_pda(mmu_state) == TLBSTATE_OK) {
 			if (f->flush_va == FLUSH_ALL)
 				local_flush_tlb();
+			else if (f->flush_va == RELOAD_ALL)
+				local_reload_tlb_mm(f->flush_mm);
 			else
 				__flush_tlb_one(f->flush_va);
 		} else
@@ -225,10 +228,36 @@ void flush_tlb_current_task(void)
 }
 EXPORT_SYMBOL(flush_tlb_current_task);
 
+void reload_tlb_mm(struct mm_struct *mm)
+{
+	cpumask_t cpu_mask;
+
+	clear_bit(MMF_NEED_RELOAD, &mm->flags);
+	clear_bit(MMF_NEED_FLUSH, &mm->flags);
+
+	preempt_disable();
+	cpu_mask = mm->cpu_vm_mask;
+	cpu_clear(smp_processor_id(), cpu_mask);
+
+	if (current->active_mm == mm) {
+		if (current->mm)
+			local_reload_tlb_mm(mm);
+		else
+			leave_mm(smp_processor_id());
+	}
+	if (!cpus_empty(cpu_mask))
+		flush_tlb_others(cpu_mask, mm, RELOAD_ALL);
+
+	preempt_enable();
+
+}
+
 void flush_tlb_mm (struct mm_struct * mm)
 {
 	cpumask_t cpu_mask;
 
+	clear_bit(MMF_NEED_FLUSH, &mm->flags);
+
 	preempt_disable();
 	cpu_mask = mm->cpu_vm_mask;
 	cpu_clear(smp_processor_id(), cpu_mask);
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/x86_64/mm/fault.c 2.6.23a/arch/x86_64/mm/fault.c
--- 2.6.23/arch/x86_64/mm/fault.c	2008-01-02 09:17:13.000000000 -0800
+++ 2.6.23a/arch/x86_64/mm/fault.c	2007-10-29 06:21:57.000000000 -0700
@@ -32,7 +32,6 @@
 #include <asm/tlbflush.h>
 #include <asm/proto.h>
 #include <asm-generic/sections.h>
-#include <asm/mmu_context.h>
 
 /* Page fault error code bits */
 #define PF_PROT	(1<<0)		/* or no page found */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-alpha/tlbflush.h 2.6.23a/include/asm-alpha/tlbflush.h
--- 2.6.23/include/asm-alpha/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-alpha/tlbflush.h	2008-01-17 08:12:23.000000000 -0800
@@ -153,5 +153,5 @@ extern void flush_tlb_range(struct vm_ar
 #endif /* CONFIG_SMP */
 
 #define flush_tlb_kernel_range(start, end) flush_tlb_all()
-
+#include <asm-generic/tlbflush.h>
 #endif /* _ALPHA_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-arm/tlbflush.h 2.6.23a/include/asm-arm/tlbflush.h
--- 2.6.23/include/asm-arm/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-arm/tlbflush.h	2008-01-17 08:12:33.000000000 -0800
@@ -471,5 +471,6 @@ extern void update_mmu_cache(struct vm_a
 #endif
 
 #endif /* CONFIG_MMU */
+#include <asm-generic/tlbflush.h>
 
 #endif
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-avr32/tlbflush.h 2.6.23a/include/asm-avr32/tlbflush.h
--- 2.6.23/include/asm-avr32/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-avr32/tlbflush.h	2008-01-17 08:12:42.000000000 -0800
@@ -36,5 +36,6 @@ static inline void flush_tlb_pgtables(st
 }
 
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
+#include <asm-generic/tlbflush.h>
 
 #endif /* __ASM_AVR32_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-blackfin/tlbflush.h 2.6.23a/include/asm-blackfin/tlbflush.h
--- 2.6.23/include/asm-blackfin/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-blackfin/tlbflush.h	2008-01-17 08:12:49.000000000 -0800
@@ -59,4 +59,5 @@ static inline void flush_tlb_pgtables(st
 	BUG();
 }
 
+#include <asm-generic/tlbflush.h>
 #endif
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-cris/tlbflush.h 2.6.23a/include/asm-cris/tlbflush.h
--- 2.6.23/include/asm-cris/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-cris/tlbflush.h	2008-01-17 08:12:55.000000000 -0800
@@ -51,5 +51,6 @@ static inline void flush_tlb(void)
 }
 
 #define flush_tlb_kernel_range(start, end) flush_tlb_all()
+#include <asm-generic/tlbflush.h>
 
 #endif /* _CRIS_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-frv/tlbflush.h 2.6.23a/include/asm-frv/tlbflush.h
--- 2.6.23/include/asm-frv/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-frv/tlbflush.h	2008-01-17 08:13:10.000000000 -0800
@@ -71,6 +71,7 @@ do {								\
 #define flush_tlb_kernel_range(start, end)	BUG()
 
 #endif
+#include <asm-generic/tlbflush.h>
 
 
 #endif /* _ASM_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-generic/pgalloc.h 2.6.23a/include/asm-generic/pgalloc.h
--- 2.6.23/include/asm-generic/pgalloc.h	1969-12-31 16:00:00.000000000 -0800
+++ 2.6.23a/include/asm-generic/pgalloc.h	2008-03-19 06:48:01.000000000 -0700
@@ -0,0 +1,37 @@
+#ifndef _ASM_GENERIC_PGALLOC_H
+#define _ASM_GENERIC_PGALLOC_H
+
+
+
+/* Page Table Levels used for alloc_page_table. */
+#define PAGE_TABLE_PGD 0
+#define PAGE_TABLE_PUD 1
+#define PAGE_TABLE_PMD 2
+#define PAGE_TABLE_PTE 3
+
+static inline struct page *alloc_page_table_node(struct mm_struct *mm,
+						 unsigned long addr,
+						 int node,
+						 int page_table_level)
+{
+	switch (page_table_level) {
+	case PAGE_TABLE_PGD:
+		return virt_to_page(pgd_alloc_node(mm, node));
+
+	case PAGE_TABLE_PUD:
+		return virt_to_page(pud_alloc_one_node(mm, addr, node));
+
+	case PAGE_TABLE_PMD:
+		return virt_to_page(pmd_alloc_one_node(mm, addr, node));
+
+	case PAGE_TABLE_PTE:
+		return pte_alloc_one_node(mm, addr, node);
+
+	default:
+		BUG();
+		return NULL;
+	}
+}
+
+
+#endif /* _ASM_GENERIC_PGALLOC_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-generic/pgtable.h 2.6.23a/include/asm-generic/pgtable.h
--- 2.6.23/include/asm-generic/pgtable.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-generic/pgtable.h	2008-01-30 08:35:39.000000000 -0800
@@ -4,6 +4,8 @@
 #ifndef __ASSEMBLY__
 #ifdef CONFIG_MMU
 
+#include <linux/sched.h>
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
  * Largely same as above, but only sets the access flags (dirty,
@@ -199,6 +201,48 @@ static inline int pmd_none_or_clear_bad(
 	}
 	return 0;
 }
+
+
+/* Used to rewalk the page tables if after we grab the appropriate lock,
+   we end up with a page that's just waiting to go away. */
+static inline pgd_t *walk_page_table_pgd(struct mm_struct *mm,
+					  unsigned long addr)
+{
+	return pgd_offset(mm, addr);
+}
+
+static inline pud_t *walk_page_table_pud(struct mm_struct *mm,
+					 unsigned long addr) {
+	pgd_t *pgd;
+	pgd = walk_page_table_pgd(mm, addr);
+	BUG_ON(!pgd);
+	return pud_offset(pgd, addr);
+}
+
+static inline pmd_t *walk_page_table_pmd(struct mm_struct *mm,
+					 unsigned long addr)
+{
+	pud_t *pud;
+	pud = walk_page_table_pud(mm, addr);
+	BUG_ON(!pud);
+	return  pmd_offset(pud, addr);
+}
+
+static inline pte_t *walk_page_table_pte(struct mm_struct *mm,
+					 unsigned long addr)
+{
+	pmd_t *pmd;
+	pmd = walk_page_table_pmd(mm, addr);
+	BUG_ON(!pmd);
+	return pte_offset_map(pmd, addr);
+}
+
+static inline pte_t *walk_page_table_huge_pte(struct mm_struct *mm,
+					      unsigned long addr)
+{
+	return (pte_t *)walk_page_table_pmd(mm, addr);
+}
+
 #endif /* CONFIG_MMU */
 
 /*
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-generic/tlbflush.h 2.6.23a/include/asm-generic/tlbflush.h
--- 2.6.23/include/asm-generic/tlbflush.h	1969-12-31 16:00:00.000000000 -0800
+++ 2.6.23a/include/asm-generic/tlbflush.h	2008-03-05 11:33:25.000000000 -0800
@@ -0,0 +1,102 @@
+/* include/asm-generic/tlbflush.h
+ *
+ *	Generic TLB reload code and page table migration code that
+ *      depends on it.
+ *
+ * Copyright 2008 Google, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; version 2 of the
+ * License.
+ */
+
+#ifndef _ASM_GENERIC__TLBFLUSH_H
+#define _ASM_GENERIC__TLBFLUSH_H
+
+#include <asm/pgalloc.h>
+#include <asm/mmu_context.h>
+
+/* flush an mm that we messed with earlier, but delayed the flush
+   assuming that we would muck with it a whole lot more. */
+static inline void maybe_flush_tlb_mm(struct mm_struct *mm)
+{
+	if (test_and_clear_bit(MMF_NEED_FLUSH, &mm->flags))
+		flush_tlb_mm(mm);
+}
+
+/* possibly flag an mm as needing to be flushed. */
+static inline int maybe_need_flush_mm(struct mm_struct *mm)
+{
+	if (!cpus_empty(mm->cpu_vm_mask)) {
+		set_bit(MMF_NEED_FLUSH, &mm->flags);
+		return 1;
+	}
+	return 0;
+}
+
+
+
+#ifdef ARCH_HAS_RELOAD_TLB
+static inline void maybe_reload_tlb_mm(struct mm_struct *mm)
+{
+	if (test_and_clear_bit(MMF_NEED_RELOAD, &mm->flags))
+		reload_tlb_mm(mm);
+	else
+		maybe_flush_tlb_mm(mm);
+}
+
+static inline int maybe_need_tlb_reload_mm(struct mm_struct *mm)
+{
+	if (!cpus_empty(mm->cpu_vm_mask)) {
+		set_bit(MMF_NEED_RELOAD, &mm->flags);
+		return 1;
+	}
+	return 0;
+}
+
+static inline int migrate_top_level_page_table(struct mm_struct *mm,
+					       struct page *dest,
+					       struct list_head *old_pages)
+{
+	unsigned long flags;
+	void *dest_ptr;
+
+	dest_ptr = page_address(dest);
+
+	spin_lock_irqsave(&mm->page_table_lock, flags);
+	memcpy(dest_ptr, mm->pgd, PAGE_SIZE);
+
+	/* Must be done before adding the list to the page to be
+	 * freed. Should we take the pgd_lock through this entire
+	 * mess, or is it ok for the pgd to be missing from the list
+	 * for a bit?
+	 */
+	pgd_list_del(mm->pgd);
+
+	list_add_tail(&virt_to_page(mm->pgd)->lru, old_pages);
+
+	mm->pgd = (pgd_t *)dest_ptr;
+
+	maybe_need_tlb_reload_mm(mm);
+
+	spin_unlock_irqrestore(&mm->page_table_lock, flags);
+	return 0;
+}
+#else /* ARCH_HAS_RELOAD_TLB */
+static inline int migrate_top_level_page_table(struct mm_struct *mm,
+					       struct page *dest,
+					       struct list_head *old_pages) {
+	return 1;
+}
+
+static inline void maybe_reload_tlb_mm(struct mm_struct *mm)
+{
+	maybe_flush_tlb_mm(mm);
+}
+
+
+#endif /* ARCH_HAS_RELOAD_TLB */
+
+
+#endif /* _ASM_GENERIC__TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-h8300/tlbflush.h 2.6.23a/include/asm-h8300/tlbflush.h
--- 2.6.23/include/asm-h8300/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-h8300/tlbflush.h	2008-01-17 08:13:25.000000000 -0800
@@ -58,4 +58,6 @@ static inline void flush_tlb_pgtables(st
 	BUG();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _H8300_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-i386/tlbflush.h 2.6.23a/include/asm-i386/tlbflush.h
--- 2.6.23/include/asm-i386/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-i386/tlbflush.h	2008-01-17 08:13:32.000000000 -0800
@@ -172,4 +172,6 @@ static inline void flush_tlb_pgtables(st
 	/* i386 does not keep any page table caches in TLB */
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _I386_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-ia64/tlbflush.h 2.6.23a/include/asm-ia64/tlbflush.h
--- 2.6.23/include/asm-ia64/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-ia64/tlbflush.h	2008-01-17 08:13:37.000000000 -0800
@@ -106,5 +106,6 @@ void smp_local_flush_tlb(void);
 #endif
 
 #define flush_tlb_kernel_range(start, end)	flush_tlb_all()	/* XXX fix me */
+#include <asm-generic/tlbflush.h>
 
 #endif /* _ASM_IA64_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-m32r/tlbflush.h 2.6.23a/include/asm-m32r/tlbflush.h
--- 2.6.23/include/asm-m32r/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-m32r/tlbflush.h	2008-01-17 08:13:42.000000000 -0800
@@ -96,5 +96,6 @@ static __inline__ void __flush_tlb_all(v
 #define flush_tlb_pgtables(mm, start, end)	do { } while (0)
 
 extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t);
+#include <asm-generic/tlbflush.h>
 
 #endif	/* _ASM_M32R_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-m68k/tlbflush.h 2.6.23a/include/asm-m68k/tlbflush.h
--- 2.6.23/include/asm-m68k/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-m68k/tlbflush.h	2008-01-17 08:13:46.000000000 -0800
@@ -225,5 +225,6 @@ static inline void flush_tlb_pgtables(st
 }
 
 #endif
+#include <asm-generic/tlbflush.h>
 
 #endif /* _M68K_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-m68knommu/tlbflush.h 2.6.23a/include/asm-m68knommu/tlbflush.h
--- 2.6.23/include/asm-m68knommu/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-m68knommu/tlbflush.h	2008-01-17 08:13:51.000000000 -0800
@@ -58,4 +58,6 @@ static inline void flush_tlb_pgtables(st
 	BUG();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _M68KNOMMU_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-mips/tlbflush.h 2.6.23a/include/asm-mips/tlbflush.h
--- 2.6.23/include/asm-mips/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-mips/tlbflush.h	2008-01-17 08:13:56.000000000 -0800
@@ -50,5 +50,6 @@ static inline void flush_tlb_pgtables(st
 {
 	/* Nothing to do on MIPS.  */
 }
+#include <asm-generic/tlbflush.h>
 
 #endif /* __ASM_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-parisc/tlbflush.h 2.6.23a/include/asm-parisc/tlbflush.h
--- 2.6.23/include/asm-parisc/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-parisc/tlbflush.h	2008-01-17 08:14:01.000000000 -0800
@@ -80,5 +80,6 @@ void __flush_tlb_range(unsigned long sid
 #define flush_tlb_range(vma,start,end) __flush_tlb_range((vma)->vm_mm->context,start,end)
 
 #define flush_tlb_kernel_range(start, end) __flush_tlb_range(0,start,end)
+#include <asm-generic/tlbflush.h>
 
 #endif
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-powerpc/tlbflush.h 2.6.23a/include/asm-powerpc/tlbflush.h
--- 2.6.23/include/asm-powerpc/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-powerpc/tlbflush.h	2008-01-17 08:14:09.000000000 -0800
@@ -183,5 +183,7 @@ static inline void flush_tlb_pgtables(st
 {
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /*__KERNEL__ */
 #endif /* _ASM_POWERPC_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-s390/tlbflush.h 2.6.23a/include/asm-s390/tlbflush.h
--- 2.6.23/include/asm-s390/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-s390/tlbflush.h	2008-01-17 08:14:16.000000000 -0800
@@ -158,4 +158,6 @@ static inline void flush_tlb_pgtables(st
         /* S/390 does not keep any page table caches in TLB */
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _S390_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-sh/tlbflush.h 2.6.23a/include/asm-sh/tlbflush.h
--- 2.6.23/include/asm-sh/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-sh/tlbflush.h	2008-01-17 08:14:24.000000000 -0800
@@ -52,4 +52,7 @@ static inline void flush_tlb_pgtables(st
 {
 	/* Nothing to do */
 }
+
+#include <asm-generic/tlbflush.h>
+
 #endif /* __ASM_SH_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-sh64/tlbflush.h 2.6.23a/include/asm-sh64/tlbflush.h
--- 2.6.23/include/asm-sh64/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-sh64/tlbflush.h	2008-01-17 08:14:29.000000000 -0800
@@ -27,5 +27,7 @@ static inline void flush_tlb_pgtables(st
 
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* __ASM_SH64_TLBFLUSH_H */
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-sparc/tlbflush.h 2.6.23a/include/asm-sparc/tlbflush.h
--- 2.6.23/include/asm-sparc/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-sparc/tlbflush.h	2008-01-17 08:14:33.000000000 -0800
@@ -63,4 +63,6 @@ static inline void flush_tlb_kernel_rang
 	flush_tlb_all();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _SPARC_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-sparc64/tlbflush.h 2.6.23a/include/asm-sparc64/tlbflush.h
--- 2.6.23/include/asm-sparc64/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-sparc64/tlbflush.h	2008-01-17 08:14:37.000000000 -0800
@@ -48,4 +48,6 @@ static inline void flush_tlb_pgtables(st
 	 */
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _SPARC64_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-um/tlbflush.h 2.6.23a/include/asm-um/tlbflush.h
--- 2.6.23/include/asm-um/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-um/tlbflush.h	2008-01-17 08:14:45.000000000 -0800
@@ -47,4 +47,6 @@ static inline void flush_tlb_pgtables(st
 {
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-v850/tlbflush.h 2.6.23a/include/asm-v850/tlbflush.h
--- 2.6.23/include/asm-v850/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-v850/tlbflush.h	2008-01-17 08:14:51.000000000 -0800
@@ -67,4 +67,6 @@ static inline void flush_tlb_pgtables(st
 	BUG ();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* __V850_TLBFLUSH_H__ */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-x86_64/pgalloc.h 2.6.23a/include/asm-x86_64/pgalloc.h
--- 2.6.23/include/asm-x86_64/pgalloc.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-x86_64/pgalloc.h	2008-03-19 06:53:11.000000000 -0700
@@ -23,16 +23,6 @@ static inline void pmd_free(pmd_t *pmd)
 	free_page((unsigned long)pmd);
 }
 
-static inline pmd_t *pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
-{
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
-}
-
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
-{
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
-}
-
 static inline void pud_free (pud_t *pud)
 {
 	BUG_ON((unsigned long)pud & (PAGE_SIZE-1));
@@ -42,7 +32,7 @@ static inline void pud_free (pud_t *pud)
 static inline void pgd_list_add(pgd_t *pgd)
 {
 	struct page *page = virt_to_page(pgd);
-
+	INIT_LIST_HEAD(&page->lru);
 	spin_lock(&pgd_lock);
 	list_add(&page->lru, &pgd_list);
 	spin_unlock(&pgd_lock);
@@ -55,9 +45,105 @@ static inline void pgd_list_del(pgd_t *p
 	spin_lock(&pgd_lock);
 	list_del(&page->lru);
 	spin_unlock(&pgd_lock);
+	INIT_LIST_HEAD(&page->lru);
 }
 
-static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+static inline void pgd_free(pgd_t *pgd)
+{
+	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
+	pgd_list_del(pgd);
+	free_page((unsigned long)pgd);
+}
+
+/* Should really implement gc for free page table pages. This could be
+   done with a reference count in struct page. */
+
+static inline void pte_free_kernel(pte_t *pte)
+{
+	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
+	free_page((unsigned long)pte);
+}
+
+static inline void pte_free(struct page *pte)
+{
+	__free_page(pte);
+}
+
+#define __pte_free_tlb(tlb, pte) tlb_remove_page((tlb), (pte))
+
+#define __pmd_free_tlb(tlb, x)   tlb_remove_page((tlb), virt_to_page(x))
+#define __pud_free_tlb(tlb, x)   tlb_remove_page((tlb), virt_to_page(x))
+
+#ifdef CONFIG_NUMA
+#if 1
+static inline pud_t *pud_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr,
+					int node)
+{
+	struct page *page;
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	if (page)
+		return (pud_t *)page_address(page);
+	return NULL;
+}
+
+static inline pmd_t *pmd_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr,
+					int node)
+{
+	struct page *page;
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	if (page)
+		return (pmd_t *)page_address(page);
+	return NULL;
+}
+#else
+
+static inline pud_t *pud_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr, int node)
+{
+	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline pmd_t *pmd_alloc_one_node(struct mm_struct *mm,
+					unsigned long addr, int node)
+{
+	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+}
+
+#endif
+
+#if 1
+static inline pgd_t *pgd_alloc_node(struct mm_struct *mm, int node)
+{
+	unsigned boundary;
+	struct page *page;
+	pgd_t *pgd;
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT, 0);
+	if (!page)
+		return NULL;
+
+	pgd = (pgd_t *)page_address(page);
+
+	pgd_list_add(pgd);
+	/*
+	 * Copy kernel pointers in from init.
+	 * Could keep a freelist or slab cache of those because the kernel
+	 * part never changes.
+	 */
+	boundary = pgd_index(__PAGE_OFFSET);
+	memset(pgd, 0, boundary * sizeof(pgd_t));
+	memcpy(pgd + boundary,
+	       init_level4_pgt + boundary,
+	       (PTRS_PER_PGD - boundary) * sizeof(pgd_t));
+	return pgd;
+}
+#else
+
+static inline pgd_t *pgd_alloc_node(struct mm_struct *mm, int node)
 {
 	unsigned boundary;
 	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
@@ -76,44 +162,124 @@ static inline pgd_t *pgd_alloc(struct mm
 	       (PTRS_PER_PGD - boundary) * sizeof(pgd_t));
 	return pgd;
 }
+#endif
 
-static inline void pgd_free(pgd_t *pgd)
+#if 1
+static inline pte_t *pte_alloc_one_kernel_node(struct mm_struct *mm,
+					       unsigned long address,
+					       int node)
+{
+	struct page *page;
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	if (page)
+		return (pte_t *)page_address(page);
+	return NULL;
+}
+
+static inline struct page *pte_alloc_one_node(struct mm_struct *mm,
+					      unsigned long address,
+					      int node)
 {
-	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
-	pgd_list_del(pgd);
-	free_page((unsigned long)pgd);
+	struct page *page;
+
+	page = alloc_pages_node(node, GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	return page;
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+#else
+static inline pte_t *pte_alloc_one_kernel_node(struct mm_struct *mm,
+					       unsigned long address, int node)
 {
 	return (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline struct page *pte_alloc_one_node(struct mm_struct *mm,
+					      unsigned long address, int node)
 {
 	void *p = (void *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 	if (!p)
 		return NULL;
 	return virt_to_page(p);
 }
+#endif
 
-/* Should really implement gc for free page table pages. This could be
-   done with a reference count in struct page. */
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return pud_alloc_one_node(mm, addr, -1);
+}
 
-static inline void pte_free_kernel(pte_t *pte)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
-	free_page((unsigned long)pte); 
+	return pmd_alloc_one_node(mm, addr, -1);
 }
 
-static inline void pte_free(struct page *pte)
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	__free_page(pte);
+	return pgd_alloc_node(mm, -1);
 } 
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return pte_alloc_one_kernel_node(mm, address, -1);
+}
 
-#define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
-#define __pud_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
+static inline struct page *pte_alloc_one(struct mm_struct *mm,
+					 unsigned long address)
+{
+	return pte_alloc_one_node(mm, address, -1);
+}
+
+#else /* !CONFIG_NUMA */
+
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	unsigned boundary;
+	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	if (!pgd)
+		return NULL;
+	pgd_list_add(pgd);
+	/*
+	 * Copy kernel pointers in from init.
+	 * Could keep a freelist or slab cache of those because the kernel
+	 * part never changes.
+	 */
+	boundary = pgd_index(__PAGE_OFFSET);
+	memset(pgd, 0, boundary * sizeof(pgd_t));
+	memcpy(pgd + boundary,
+	       init_level4_pgt + boundary,
+	       (PTRS_PER_PGD - boundary) * sizeof(pgd_t));
+	return pgd;
+}
+
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline struct page *pte_alloc_one(struct mm_struct *mm,
+					 unsigned long address)
+{
+	void *p = (void *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	if (!p)
+		return NULL;
+	return virt_to_page(p);
+}
+
+#endif
+
+#include <asm-generic/pgalloc.h>
 
 #endif /* _X86_64_PGALLOC_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-x86_64/tlbflush.h 2.6.23a/include/asm-x86_64/tlbflush.h
--- 2.6.23/include/asm-x86_64/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-x86_64/tlbflush.h	2008-01-11 08:31:06.000000000 -0800
@@ -6,6 +6,13 @@
 #include <asm/processor.h>
 #include <asm/system.h>
 
+#define ARCH_HAS_RELOAD_TLB
+static inline void load_cr3(pgd_t *pgd);
+static inline void __reload_tlb_mm(struct mm_struct *mm)
+{
+	load_cr3(mm->pgd);
+}
+
 static inline void __flush_tlb(void)
 {
 	write_cr3(read_cr3());
@@ -44,6 +50,12 @@ static inline void __flush_tlb_all(void)
 #define flush_tlb_all() __flush_tlb_all()
 #define local_flush_tlb() __flush_tlb()
 
+static inline void reload_tlb_mm(struct mm_struct *mm)
+{
+	if (mm == current->active_mm)
+		__reload_tlb_mm(mm);
+}
+
 static inline void flush_tlb_mm(struct mm_struct *mm)
 {
 	if (mm == current->active_mm)
@@ -71,6 +83,10 @@ static inline void flush_tlb_range(struc
 #define local_flush_tlb() \
 	__flush_tlb()
 
+#define local_reload_tlb_mm(mm) \
+	__reload_tlb_mm(mm)
+
+extern void reload_tlb_mm(struct mm_struct *mm);
 extern void flush_tlb_all(void);
 extern void flush_tlb_current_task(void);
 extern void flush_tlb_mm(struct mm_struct *);
@@ -106,4 +122,6 @@ static inline void flush_tlb_pgtables(st
 	   by the normal TLB flushing algorithms. */
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _X8664_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-xtensa/tlbflush.h 2.6.23a/include/asm-xtensa/tlbflush.h
--- 2.6.23/include/asm-xtensa/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-xtensa/tlbflush.h	2008-01-17 08:15:09.000000000 -0800
@@ -197,6 +197,8 @@ static inline unsigned long read_itlb_tr
 	return tmp;
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif	/* __ASSEMBLY__ */
 #endif	/* __KERNEL__ */
 #endif	/* _XTENSA_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/linux/#gfp.h# 2.6.23a/include/linux/#gfp.h#
--- 2.6.23/include/linux/#gfp.h#	1969-12-31 16:00:00.000000000 -0800
+++ 2.6.23a/include/linux/#gfp.h#	2008-01-30 07:39:06.000000000 -0800
@@ -0,0 +1,198 @@
+#ifndef __LINUX_GFP_H
+#define __LINUX_GFP_H
+
+#include <linux/mmzone.h>
+#include <linux/stddef.h>
+#include <linux/linkage.h>
+
+struct vm_area_struct;
+
+/*
+ * GFP bitmasks..
+ *
+ * Zone modifiers (see linux/mmzone.h - low three bits)
+ *
+ * Do not put any conditional on these. If necessary modify the definitions
+ * without the underscores and use the consistently. The definitions here may
+ * be used in bit comparisons.
+ */
+#define __GFP_DMA	((__force gfp_t)0x01u)
+#define __GFP_HIGHMEM	((__force gfp_t)0x02u)
+#define __GFP_DMA32	((__force gfp_t)0x04u)
+
+/*
+ * Action modifiers - doesn't change the zoning
+ *
+ * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
+ * _might_ fail.  This depends upon the particular VM implementation.
+ *
+ * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
+ * cannot handle allocation failures.
+ *
+ * __GFP_NORETRY: The VM implementation must not retry indefinitely.
+ *
+ * __GFP_MOVABLE: Flag that this page will be movable by the page migration
+ * mechanism or reclaimed
+ */
+#define __GFP_WAIT	((__force gfp_t)0x10u)	/* Can wait and reschedule? */
+#define __GFP_HIGH	((__force gfp_t)0x20u)	/* Should access emergency pools? */
+#define __GFP_IO	((__force gfp_t)0x40u)	/* Can start physical IO? */
+#define __GFP_FS	((__force gfp_t)0x80u)	/* Can call down to low-level FS? */
+#define __GFP_COLD	((__force gfp_t)0x100u)	/* Cache-cold page required */
+#define __GFP_NOWARN	((__force gfp_t)0x200u)	/* Suppress page allocation failure warning */
+#define __GFP_REPEAT	((__force gfp_t)0x400u)	/* Retry the allocation.  Might fail */
+#define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* Retry for ever.  Cannot fail */
+#define __GFP_NORETRY	((__force gfp_t)0x1000u)/* Do not retry.  Might fail */
+#define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
+#define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
+#define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
+#define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
+#define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
+#define __GFP_MOVABLE	((__force gfp_t)0x80000u) /* Page is movable */
+
+#define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
+#define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
+
+/* if you forget to add the bitmask here kernel will crash, period */
+#define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
+			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
+			__GFP_NOFAIL|__GFP_NORETRY|__GFP_COMP| \
+			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE| \
+			__GFP_MOVABLE)
+
+/* This equals 0, but use constants in case they ever change */
+#define GFP_NOWAIT	(GFP_ATOMIC & ~__GFP_HIGH)
+/* GFP_ATOMIC means both !wait (__GFP_WAIT not set) and use emergency pool */
+#define GFP_ATOMIC	(__GFP_HIGH)
+#define GFP_NOIO	(__GFP_WAIT)
+#define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
+#define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
+#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
+#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
+			 __GFP_HIGHMEM)
+#define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+				 __GFP_HARDWALL | __GFP_HIGHMEM | \
+				 __GFP_MOVABLE)
+#define GFP_NOFS_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_MOVABLE)
+#define GFP_USER_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+				 __GFP_HARDWALL | __GFP_MOVABLE)
+#define GFP_HIGHUSER_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+				 __GFP_HARDWALL | __GFP_HIGHMEM | \
+				 __GFP_MOVABLE)
+
+#ifdef CONFIG_NUMA
+#define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
+#else
+#define GFP_THISNODE	((__force gfp_t)0)
+#endif
+
+
+/* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
+   platforms, used as appropriate on others */
+
+#define GFP_DMA		__GFP_DMA
+
+/* 4GB DMA on some platforms */
+#define GFP_DMA32	__GFP_DMA32
+
+
+static inline enum zone_type gfp_zone(gfp_t flags)
+{
+#ifdef CONFIG_ZONE_DMA
+	if (flags & __GFP_DMA)
+		return ZONE_DMA;
+#endif
+#ifdef CONFIG_ZONE_DMA32
+	if (flags & __GFP_DMA32)
+		return ZONE_DMA32;
+#endif
+	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
+			(__GFP_HIGHMEM | __GFP_MOVABLE))
+		return ZONE_MOVABLE;
+#ifdef CONFIG_HIGHMEM
+	if (flags & __GFP_HIGHMEM)
+		return ZONE_HIGHMEM;
+#endif
+	return ZONE_NORMAL;
+}
+
+/*
+ * There is only one page-allocator function, and two main namespaces to
+ * it. The alloc_page*() variants return 'struct page *' and as such
+ * can allocate highmem pages, the *get*page*() variants return
+ * virtual kernel addresses to the allocated page(s).
+ */
+
+/*
+ * We get the zone list from the current node and the gfp_mask.
+ * This zone list contains a maximum of MAXNODES*MAX_NR_ZONES zones.
+ *
+ * For the normal case of non-DISCONTIGMEM systems the NODE_DATA() gets
+ * optimized to &contig_page_data at compile-time.
+ */
+
+#ifndef HAVE_ARCH_FREE_PAGE
+static inline void arch_free_page(struct page *page, int order) { }
+#endif
+#ifndef HAVE_ARCH_ALLOC_PAGE
+static inline void arch_alloc_page(struct page *page, int order) { }
+#endif
+
+extern struct page *
+FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
+
+static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
+						unsigned int order)
+{
+	if (unlikely(order >= MAX_ORDER))
+		return NULL;
+
+	/* Unknown node is current node */
+	if (nid < 0)
+		nid = numa_node_id();
+
+	return __alloc_pages(gfp_mask, order,
+		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
+}
+
+#ifdef CONFIG_NUMA
+extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
+
+static inline struct page *
+alloc_pages(gfp_t gfp_mask, unsigned int order)
+{
+	if (unlikely(order >= MAX_ORDER))
+		return NULL;
+
+	return alloc_pages_current(gfp_mask, order);
+}
+extern struct page *alloc_page_vma(gfp_t gfp_mask,
+			struct vm_area_struct *vma, unsigned long addr);
+#else
+#define alloc_pages(gfp_mask, order) \
+		alloc_pages_node(numa_node_id(), gfp_mask, order)
+#define alloc_page_vma(gfp_mask, vma, addr) alloc_pages(gfp_mask, 0)
+#endif
+#define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
+
+extern unsigned long FASTCALL(__get_free_pages(gfp_t gfp_mask, unsigned int order));
+extern unsigned long FASTCALL(get_zeroed_page(gfp_t gfp_mask));
+
+#define __get_free_page(gfp_mask) \
+		__get_free_pages((gfp_mask),0)
+
+#define __get_dma_pages(gfp_mask, order) \
+		__get_free_pages((gfp_mask) | GFP_DMA,(order))
+
+extern void FASTCALL(__free_pages(struct page *page, unsigned int order));
+extern void FASTCALL(free_pages(unsigned long addr, unsigned int order));
+extern void FASTCALL(free_hot_page(struct page *page));
+extern void FASTCALL(free_cold_page(struct page *page));
+
+#define __free_page(page) __free_pages((page), 0)
+#define free_page(addr) free_pages((addr),0)
+
+void page_alloc_init(void);
+void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
+
+#endif /* __LINUX_GFP_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/linux/migrate.h 2.6.23a/include/linux/migrate.h
--- 2.6.23/include/linux/migrate.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/linux/migrate.h	2008-03-19 06:56:10.000000000 -0700
@@ -6,6 +6,10 @@
 #include <linux/pagemap.h>
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
+typedef struct page *new_page_table_t(struct mm_struct *,
+				      unsigned long addr,
+				      unsigned long private,
+				      int **, int page_table_level);
 
 #ifdef CONFIG_MIGRATION
 /* Check if a vma is migratable */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/linux/mm.h 2.6.23a/include/linux/mm.h
--- 2.6.23/include/linux/mm.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/linux/mm.h	2008-01-25 05:37:23.000000000 -0800
@@ -14,6 +14,7 @@
 #include <linux/debug_locks.h>
 #include <linux/backing-dev.h>
 #include <linux/mm_types.h>
+#include <asm/pgtable.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -935,6 +936,7 @@ static inline pmd_t *pmd_alloc(struct mm
 	pte_t *__pte = pte_offset_map(pmd, address);	\
 	*(ptlp) = __ptl;				\
 	spin_lock(__ptl);				\
+	delimbo_pte(&__pte, ptlp, &pmd, mm, address);	\
 	__pte;						\
 })
 
@@ -959,6 +962,86 @@ extern void free_area_init(unsigned long
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
 	unsigned long * zones_size, unsigned long zone_start_pfn, 
 	unsigned long *zholes_size);
+
+
+
+static inline void delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
+			  struct mm_struct *mm,
+			  unsigned long addr)
+{
+	if (!test_bit(MMF_NEED_REWALK, &mm->flags))
+		return;
+
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_unlock(*ptl);
+	spin_lock(&mm->page_table_lock);
+#endif
+	pte_unmap(*pte);
+	*pmd = walk_page_table_pmd(mm, addr);
+	*pte = pte_offset_map(*pmd, addr);
+	*ptl = pte_lockptr(mm, *pmd);
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_lock(*ptl);
+	spin_unlock(&mm->page_table_lock);
+#endif
+}
+
+static inline void delimbo_pte_nested(pte_t **pte, spinlock_t **ptl,
+				pmd_t **pmd,
+				struct mm_struct *mm,
+				unsigned long addr, int subclass)
+{
+	if (!test_bit(MMF_NEED_REWALK, &mm->flags))
+		return;
+
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_unlock(*ptl);
+	spin_lock(&mm->page_table_lock);
+#endif
+	*pmd = walk_page_table_pmd(mm, addr);
+	*pte = pte_offset_map(*pmd, addr);
+	*ptl = pte_lockptr(mm, *pmd);
+
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_lock_nested(*ptl, subclass);
+	spin_unlock(&mm->page_table_lock);
+#endif
+}
+
+static inline void delimbo_pud(pud_t **pud,  struct mm_struct *mm,
+			  unsigned long addr) {
+
+	if (!test_bit(MMF_NEED_REWALK, &mm->flags))
+		return;
+
+	*pud = walk_page_table_pud(mm, addr);
+}
+
+static inline void delimbo_pmd(pmd_t **pmd,  struct mm_struct *mm,
+			       unsigned long addr) {
+
+	if (!test_bit(MMF_NEED_REWALK, &mm->flags))
+		return;
+
+	*pmd = walk_page_table_pmd(mm, addr);
+}
+
+static inline void delimbo_pgd(pgd_t **pgd,  struct mm_struct *mm,
+			       unsigned long addr) {
+	if (!test_bit(MMF_NEED_REWALK, &mm->flags))
+		return;
+
+	*pgd = walk_page_table_pgd(mm, addr);
+}
+
+static inline void delimbo_huge_pte(pte_t **pte,  struct mm_struct *mm,
+				    unsigned long addr) {
+	if (!test_bit(MMF_NEED_REWALK, &mm->flags))
+		return;
+
+	*pte = walk_page_table_huge_pte(mm, addr);
+}
+
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
 /*
  * With CONFIG_ARCH_POPULATES_NODE_MAP set, an architecture may initialise its
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/linux/mm_types.h 2.6.23a/include/linux/mm_types.h
--- 2.6.23/include/linux/mm_types.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/linux/mm_types.h	2008-01-02 08:06:09.000000000 -0800
@@ -5,6 +5,7 @@
 #include <linux/threads.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <linux/rcupdate.h>
 
 struct address_space;
 
@@ -61,9 +62,18 @@ struct page {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
 	};
+
+	union {
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
 					 */
+		struct rcu_head rcu;	/* Used by page table relocation code
+					 * to remember page for later freeing,
+					 * after we are sure anyone
+					 * poking at the page tables is no
+					 * longer looking at this page.
+					 */
+	};
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/linux/sched.h 2.6.23a/include/linux/sched.h
--- 2.6.23/include/linux/sched.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/linux/sched.h	2008-01-24 07:37:27.000000000 -0800
@@ -366,6 +366,12 @@ extern int get_dumpable(struct mm_struct
 #define MMF_DUMP_FILTER_DEFAULT \
 	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED))
 
+/* Misc MM flags. */
+#define MMF_NEED_FLUSH		6
+#define MMF_NEED_RELOAD		7	/* Only meaningful on some archs. */
+#define MMF_NEED_REWALK		8	/* Must rewalk page tables with spin
+					 * lock held. */
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
@@ -384,6 +390,7 @@ struct mm_struct {
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
+	unsigned long flags; /* Must use atomic bitops to access the bits */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.  These are globally strung
 						 * together off init_mm.mmlist, and are protected
@@ -423,8 +430,6 @@ struct mm_struct {
 	unsigned int token_priority;
 	unsigned int last_interval;
 
-	unsigned long flags; /* Must use atomic bitops to access the bits */
-
 	/* coredumping support */
 	int core_waiters;
 	struct completion *core_startup_done, core_done;
@@ -432,6 +437,10 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
+
+	/* Page table relocation support. */
+	struct mutex		page_table_relocation_lock;
+	struct rcu_head		page_table_relocation_rcu;
 };
 
 struct sighand_struct {
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/kernel/fork.c 2.6.23a/kernel/fork.c
--- 2.6.23/kernel/fork.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/kernel/fork.c	2008-01-24 07:39:27.000000000 -0800
@@ -346,6 +346,9 @@ static struct mm_struct * mm_init(struct
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
 
+	INIT_RCU_HEAD(&mm->page_table_relocation_rcu);
+	mutex_init(&mm->page_table_relocation_lock);
+
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
 		return mm;
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/hugetlb.c 2.6.23a/mm/hugetlb.c
--- 2.6.23/mm/hugetlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/hugetlb.c	2007-10-30 07:32:50.000000000 -0700
@@ -379,6 +379,8 @@ int copy_hugetlb_page_range(struct mm_st
 			goto nomem;
 		spin_lock(&dst->page_table_lock);
 		spin_lock(&src->page_table_lock);
+		delimbo_huge_pte(&src_pte, src, addr);
+		delimbo_huge_pte(&dst_pte, dst, addr);
 		if (!pte_none(*src_pte)) {
 			if (cow)
 				ptep_set_wrprotect(src, addr, src_pte);
@@ -551,6 +553,7 @@ retry:
 	}
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_huge_pte(&ptep, mm, address);
 	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
 	if (idx >= size)
 		goto backout;
@@ -609,6 +612,7 @@ int hugetlb_fault(struct mm_struct *mm, 
 	ret = 0;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_huge_pte(&ptep, mm, address);
 	/* Check for a racing update before calling hugetlb_cow */
 	if (likely(pte_same(entry, *ptep)))
 		if (write_access && !pte_write(entry))
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/memory.c 2.6.23a/mm/memory.c
--- 2.6.23/mm/memory.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/memory.c	2008-01-11 10:50:42.000000000 -0800
@@ -306,6 +306,7 @@ int __pte_alloc(struct mm_struct *mm, pm
 
 	pte_lock_init(new);
 	spin_lock(&mm->page_table_lock);
+	delimbo_pmd(&pmd, mm, address);
 	if (pmd_present(*pmd)) {	/* Another has populated it */
 		pte_lock_deinit(new);
 		pte_free(new);
@@ -325,6 +326,7 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 		return -ENOMEM;
 
 	spin_lock(&init_mm.page_table_lock);
+	delimbo_pmd(&pmd, &init_mm, address);
 	if (pmd_present(*pmd))		/* Another has populated it */
 		pte_free_kernel(new);
 	else
@@ -504,6 +506,8 @@ again:
 	src_pte = pte_offset_map_nested(src_pmd, addr);
 	src_ptl = pte_lockptr(src_mm, src_pmd);
 	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
+
+	delimbo_pte(&src_pte, &src_ptl, &src_pmd, src_mm, addr);
 	arch_enter_lazy_mmu_mode();
 
 	do {
@@ -1558,13 +1562,15 @@ EXPORT_SYMBOL_GPL(apply_to_page_range);
  * and do_anonymous_page and do_no_page can safely check later on).
  */
 static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
-				pte_t *page_table, pte_t orig_pte)
+				pte_t *page_table, pte_t orig_pte,
+				unsigned long address)
 {
 	int same = 1;
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 	if (sizeof(pte_t) > sizeof(unsigned long)) {
 		spinlock_t *ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
+		delimbo_pte(&page_table, &ptl, &pmd, mm, address);
 		same = pte_same(*page_table, orig_pte);
 		spin_unlock(ptl);
 	}
@@ -2153,7 +2159,7 @@ static int do_swap_page(struct mm_struct
 	pte_t pte;
 	int ret = 0;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(mm, pmd, page_table, orig_pte, address))
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
@@ -2227,6 +2233,10 @@ static int do_swap_page(struct mm_struct
 	}
 
 	/* No need to invalidate - it was non-present before */
+	/* Unless of course the cpu might be looking at an old
+	   copy of the pte. */
+	maybe_reload_tlb_mm(mm);
+
 	update_mmu_cache(vma, address, pte);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
@@ -2279,6 +2289,7 @@ static int do_anonymous_page(struct mm_s
 
 		ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
+		delimbo_pte(&page_table, &ptl, &pmd, mm, address);
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, file_rss);
@@ -2288,6 +2299,10 @@ static int do_anonymous_page(struct mm_s
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
+	/* Unless of course the cpu might be looking at an old
+	   copy of the pte. */
+	maybe_reload_tlb_mm(mm);
+
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
 unlock:
@@ -2441,6 +2456,10 @@ static int __do_fault(struct mm_struct *
 		}
 
 		/* no need to invalidate: a not-present page won't be cached */
+		/* Unless of course the cpu could be looking at an old page
+		   table entry. */
+		maybe_reload_tlb_mm(mm);
+
 		update_mmu_cache(vma, address, entry);
 		lazy_mmu_prot_update(entry);
 	} else {
@@ -2544,7 +2563,7 @@ static int do_nonlinear_fault(struct mm_
 				(write_access ? FAULT_FLAG_WRITE : 0);
 	pgoff_t pgoff;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(mm, pmd, page_table, orig_pte, address))
 		return 0;
 
 	if (unlikely(!(vma->vm_flags & VM_NONLINEAR) ||
@@ -2603,6 +2622,7 @@ static inline int handle_pte_fault(struc
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
+	delimbo_pte(&pte, &ptl, &pmd, mm, address);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (write_access) {
@@ -2625,6 +2645,12 @@ static inline int handle_pte_fault(struc
 		if (write_access)
 			flush_tlb_page(vma, address);
 	}
+
+	/* if the cpu could be looking at an old page table, we need to
+	   flush out everything. */
+	maybe_reload_tlb_mm(mm);
+
+
 unlock:
 	pte_unmap_unlock(pte, ptl);
 	return 0;
@@ -2674,6 +2700,7 @@ int __pud_alloc(struct mm_struct *mm, pg
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pgd(&pgd, mm, address);
 	if (pgd_present(*pgd))		/* Another has populated it */
 		pud_free(new);
 	else
@@ -2695,6 +2722,7 @@ int __pmd_alloc(struct mm_struct *mm, pu
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pud(&pud, mm, address);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
 		pmd_free(new);
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/mempolicy.c 2.6.23a/mm/mempolicy.c
--- 2.6.23/mm/mempolicy.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/mempolicy.c	2008-03-19 06:53:35.000000000 -0700
@@ -101,6 +101,12 @@
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sn_cache;
 
+
+int migrate_page_tables_mm(struct mm_struct *mm,  int source,
+			   new_page_table_t get_new_page,
+			   unsigned long private);
+
+
 /* Highest zone. An specific allocation for a zone below that is not
    policied. */
 enum zone_type policy_zone = 0;
@@ -597,6 +603,17 @@ static struct page *new_node_page(struct
 	return alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
 }
 
+static struct page *new_node_page_page_tables(struct mm_struct *mm,
+					      unsigned long addr,
+					      unsigned long node,
+					      int **x,
+					      int level)
+{
+	struct page *p;
+	p = alloc_page_table_node(mm, addr, node, level);
+	return p;
+}
+
 /*
  * Migrate pages from one node to a target node.
  * Returns error or the number of pages not migrated.
@@ -616,6 +633,10 @@ int migrate_to_node(struct mm_struct *mm
 	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_node_page, dest);
 
+	if (!err)
+		err = migrate_page_tables_mm(mm, source,
+					     new_node_page_page_tables, dest);
+
 	return err;
 }
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/migrate.c 2.6.23a/mm/migrate.c
--- 2.6.23/mm/migrate.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/migrate.c	2008-03-19 06:56:34.000000000 -0700
@@ -28,9 +28,16 @@
 #include <linux/mempolicy.h>
 #include <linux/vmalloc.h>
 #include <linux/security.h>
-
+#include <linux/mm.h>
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+#include <asm/pgalloc.h>
 #include "internal.h"
 
+int migrate_page_tables_mm(struct mm_struct *mm, int source,
+			   new_page_table_t get_new_page,
+			   unsigned long private);
+
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
@@ -158,6 +165,7 @@ static void remove_migration_pte(struct 
 
  	ptl = pte_lockptr(mm, pmd);
  	spin_lock(ptl);
+	delimbo_pte(&ptep, &ptl, &pmd, mm, addr);
 	pte = *ptep;
 	if (!is_swap_pte(pte))
 		goto out;
@@ -859,9 +867,10 @@ set_status:
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm);
 	else
-		err = -ENOENT;
+		err = 0;
 
 	up_read(&mm->mmap_sem);
+
 	return err;
 }
 
@@ -1039,3 +1048,349 @@ int migrate_vmas(struct mm_struct *mm, c
  	}
  	return err;
 }
+
+static void rcu_free_pt(struct rcu_head *head)
+{
+	/* Need to know that the mm has been flushed before
+	 * we get here.  Otherwise we need a way to find
+	 * the appropriate mm to flush.
+	 */
+	struct page *page = container_of(head, struct page, rcu);
+	INIT_LIST_HEAD(&page->lru);
+	__free_page(page);
+}
+
+int migrate_pgd(pgd_t *pgd, struct mm_struct *mm,
+		unsigned long addr, struct page *dest,
+		struct list_head *old_pages)
+{
+	unsigned long flags;
+	void *dest_ptr;
+	pud_t *pud;
+
+	spin_lock_irqsave(&mm->page_table_lock, flags);
+
+	delimbo_pgd(&pgd, mm, addr);
+
+	pud = pud_offset(pgd, addr);
+	dest_ptr = page_address(dest);
+	memcpy(dest_ptr, pud, PAGE_SIZE);
+
+	list_add_tail(&(pgd_page(*pgd)->lru), old_pages);
+	pgd_populate(mm, pgd, dest_ptr);
+
+	flush_tlb_pgtables(mm, addr,
+			   addr + (1 << PMD_SHIFT)
+			   - 1);
+
+	maybe_need_flush_mm(mm);
+
+	spin_unlock_irqrestore(&mm->page_table_lock, flags);
+
+	return 0;
+
+}
+
+int migrate_pud(pud_t *pud, struct mm_struct *mm, unsigned long addr,
+		struct page *dest, struct list_head *old_pages)
+{
+	unsigned long flags;
+	void *dest_ptr;
+	pmd_t *pmd;
+
+	spin_lock_irqsave(&mm->page_table_lock, flags);
+
+	delimbo_pud(&pud, mm, addr);
+	pmd = pmd_offset(pud, addr);
+
+	dest_ptr = page_address(dest);
+	memcpy(dest_ptr, pmd, PAGE_SIZE);
+
+	list_add_tail(&(pud_page(*pud)->lru), old_pages);
+
+	pud_populate(mm, pud, dest_ptr);
+	flush_tlb_pgtables(mm, addr,
+			   addr + (1 << PMD_SHIFT)
+			   - 1);
+	maybe_need_flush_mm(mm);
+
+	spin_unlock_irqrestore(&mm->page_table_lock, flags);
+
+	return 0;
+}
+
+
+int migrate_pmd(pmd_t *pmd, struct mm_struct *mm, unsigned long addr,
+		struct page *dest, struct list_head *old_pages)
+{
+	unsigned long flags;
+	void *dest_ptr;
+	spinlock_t *ptl;
+	pte_t *pte;
+
+	spin_lock_irqsave(&mm->page_table_lock, flags);
+
+	delimbo_pmd(&pmd, mm, addr);
+
+	/* this could happen if the page table has been swapped out and we
+	   were looking at the old one. */
+	if (unlikely(!pmd_present(*pmd))) {
+		spin_unlock_irqrestore(&mm->page_table_lock, flags);
+		return 1;
+	}
+
+	ptl = pte_lockptr(mm, pmd);
+
+	/* We need the page lock as well. */
+	if (ptl != &mm->page_table_lock)
+		spin_lock(ptl);
+
+	pte = pte_offset_map(pmd, addr);
+
+	dest_ptr = kmap_atomic(dest, KM_USER0);
+	memcpy(dest_ptr, pte, PAGE_SIZE);
+	list_add_tail(&(pmd_page(*pmd)->lru), old_pages);
+
+	kunmap_atomic(dest, KM_USER0);
+	pte_unmap(pte);
+	pte_lock_init(dest);
+	pmd_populate(mm, pmd, dest);
+
+	flush_tlb_pgtables(mm, addr,
+			   addr + (1 << PMD_SHIFT)
+			   - 1);
+	maybe_need_flush_mm(mm);
+
+	if (ptl != &mm->page_table_lock)
+		spin_unlock(ptl);
+
+	spin_unlock_irqrestore(&mm->page_table_lock, flags);
+
+	return 0;
+}
+
+static int migrate_page_tables_pmd(pmd_t *pmd, struct mm_struct *mm,
+				   unsigned long *address, int source,
+				   new_page_table_t get_new_page,
+				   unsigned long private,
+				   struct list_head *old_pages)
+{
+	int pages_not_migrated = 0;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(pmd);
+	struct page *new_page;
+	int not_migrated;
+
+	if (!pmd_present(*pmd)) {
+		*address +=  (unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+		return 0;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(mm, *address, private, &result,
+					PAGE_TABLE_PTE);
+		if (!new_page)
+			return -ENOMEM;
+		not_migrated = migrate_pmd(pmd, mm, *address, new_page,
+					   old_pages);
+		if (not_migrated)
+			__free_page(new_page);
+
+		pages_not_migrated += not_migrated;
+	}
+
+
+	*address +=  (unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+
+	return pages_not_migrated;
+}
+
+static int migrate_page_tables_pud(pud_t *pud, struct mm_struct *mm,
+				   unsigned long *address, int source,
+				   new_page_table_t get_new_page,
+				   unsigned long private,
+				   struct list_head *old_pages)
+{
+	int pages_not_migrated = 0;
+	int i;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(pud);
+	struct page *new_page;
+	int not_migrated;
+
+	if (!pud_present(*pud)) {
+		*address += (unsigned long)PTRS_PER_PMD *
+				(unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+		return 0;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(mm, *address, private, &result,
+					PAGE_TABLE_PMD);
+		if (!new_page)
+			return -ENOMEM;
+
+		not_migrated = migrate_pud(pud, mm, *address, new_page,
+					   old_pages);
+
+		if (not_migrated)
+			__free_page(new_page);
+
+		pages_not_migrated += not_migrated;
+	}
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		int ret;
+		ret = migrate_page_tables_pmd(pmd_offset(pud, *address), mm,
+					      address, source,
+					      get_new_page, private,
+					      old_pages);
+		if (ret < 0)
+			return ret;
+		pages_not_migrated += ret;
+	}
+
+	return pages_not_migrated;
+}
+
+static int migrate_page_tables_pgd(pgd_t *pgd, struct mm_struct *mm,
+				   unsigned long *address, int source,
+				   new_page_table_t get_new_page,
+				   unsigned long private,
+				   struct list_head *old_pages)
+{
+	int pages_not_migrated = 0;
+	int i;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(pgd);
+	struct page *new_page;
+	int not_migrated;
+
+	if (!pgd_present(*pgd)) {
+		*address +=  (unsigned long)PTRS_PER_PUD *
+				(unsigned long)PTRS_PER_PMD *
+				(unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+		return 0;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(mm, *address,  private, &result,
+					PAGE_TABLE_PUD);
+		if (!new_page)
+			return -ENOMEM;
+
+		not_migrated = migrate_pgd(pgd, mm,  *address, new_page,
+					   old_pages);
+		if (not_migrated)
+			__free_page(new_page);
+
+		pages_not_migrated += not_migrated;
+
+	}
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		int ret;
+		ret = migrate_page_tables_pud(pud_offset(pgd, *address), mm,
+					      address, source,
+					      get_new_page, private,
+					      old_pages);
+		if (ret < 0)
+			return ret;
+		pages_not_migrated += ret;
+	}
+
+	return pages_not_migrated;
+}
+
+void enter_page_table_relocation_mode(struct mm_struct *mm)
+{
+	mutex_lock(&mm->page_table_relocation_lock);
+	set_bit(MMF_NEED_REWALK, &mm->flags);
+}
+
+void rcu_leave_page_table_relocation_mode(struct rcu_head *head)
+{
+	struct mm_struct *mm = container_of(head, struct mm_struct,
+					    page_table_relocation_rcu);
+	clear_bit(MMF_NEED_REWALK, &mm->flags);
+	mutex_unlock(&mm->page_table_relocation_lock);
+}
+
+/* similiar to migrate pages, but migrates the page tables. */
+int migrate_page_tables_mm(struct mm_struct *mm, int source,
+			   new_page_table_t get_new_page,
+			   unsigned long private)
+{
+	int pages_not_migrated = 0;
+	int i;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(mm->pgd);
+	struct page *new_page;
+	unsigned long address = 0UL;
+	int not_migrated;
+	int ret = 0;
+	LIST_HEAD(old_pages);
+
+	if (mm->pgd == NULL)
+		return 0;
+
+	enter_page_table_relocation_mode(mm);
+
+	for (i = 0; i < PTRS_PER_PGD && address < mm->task_size; i++) {
+		ret = migrate_page_tables_pgd(pgd_offset(mm, address), mm,
+					      &address, source,
+					      get_new_page, private,
+					      &old_pages);
+		if (ret < 0)
+			goto out_exit;
+
+		pages_not_migrated += ret;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(mm, address, private, &result,
+					PAGE_TABLE_PGD);
+		if (!new_page) {
+			ret = -ENOMEM;
+			goto out_exit;
+		}
+
+		not_migrated = migrate_top_level_page_table(mm, new_page,
+							&old_pages);
+		if (not_migrated) {
+			pgd_list_del(page_address(new_page));
+			__free_page(new_page);
+		}
+
+		pages_not_migrated += not_migrated;
+	}
+
+	/* reload or flush the tlbs if necessary. */
+	maybe_reload_tlb_mm(mm);
+
+	/* Add the pages freed up to the rcu list to be freed later.
+	 * We need to do this after we flush the mm to prevent
+	 * a possible race where the page is freed while one of
+	 * the cpus is still looking at it.
+	 */
+
+	while (!list_empty(&old_pages)) {
+		old_page = list_first_entry(&old_pages, struct page, lru);
+		list_del(&old_page->lru);
+		/* This is the same memory as the list
+		 * head we are using to maintain the list.
+		 * so we have to make sure the list_del
+		 * comes first.
+		 */
+		INIT_RCU_HEAD(&old_page->rcu);
+		call_rcu(&old_page->rcu, rcu_free_pt);
+	}
+
+ out_exit:
+	call_rcu(&mm->page_table_relocation_rcu,
+		 rcu_leave_page_table_relocation_mode);
+
+	if (ret < 0)
+		return ret;
+	return pages_not_migrated;
+}
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/mremap.c 2.6.23a/mm/mremap.c
--- 2.6.23/mm/mremap.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/mremap.c	2007-10-30 06:57:49.000000000 -0700
@@ -98,6 +98,7 @@ static void move_ptes(struct vm_area_str
 	new_ptl = pte_lockptr(mm, new_pmd);
 	if (new_ptl != old_ptl)
 		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+	delimbo_pte(&new_pte, &new_ptl, &new_pmd, mm, new_addr);
 	arch_enter_lazy_mmu_mode();
 
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/rmap.c 2.6.23a/mm/rmap.c
--- 2.6.23/mm/rmap.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/rmap.c	2007-10-29 09:46:25.000000000 -0700
@@ -254,6 +254,7 @@ pte_t *page_check_address(struct page *p
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
+	delimbo_pte(&pte, &ptl, &pmd, mm, address);
 	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
 		*ptlp = ptl;
 		return pte;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
