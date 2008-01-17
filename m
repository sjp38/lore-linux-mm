Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m0HGsqOQ008665
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 16:54:58 GMT
Subject: [RFC/Patch 1/2] mm: Make page tables relocatable
Message-Id: <20080117165439.D6911DC9EF@localhost>
Date: Thu, 17 Jan 2008 08:54:39 -0800 (PST)
From: rossb@google.com (Ross Biro)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: rossb@google.com
List-ID: <linux-mm.kvack.org>

These patches allow page tables to be migrated from node to node on
numa systems, for hot plug memory, and for memory defragmentation.

Signed-off-by: rossb@google.com

This patch contains most of the logic for conditional flush.  A few stray lines
are included the the following patch.  Please apply with -p 1.

---
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/alpha/kernel/smp.c 2.6.23a/arch/alpha/kernel/smp.c
--- 2.6.23/arch/alpha/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/alpha/kernel/smp.c	2007-10-29 13:50:06.000000000 -0700
@@ -850,6 +850,8 @@ flush_tlb_mm(struct mm_struct *mm)
 {
 	preempt_disable();
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	if (mm == current->active_mm) {
 		flush_tlb_current(mm);
 		if (atomic_read(&mm->mm_users) <= 1) {
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/arm/kernel/smp.c 2.6.23a/arch/arm/kernel/smp.c
--- 2.6.23/arch/arm/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/arm/kernel/smp.c	2007-10-29 13:50:21.000000000 -0700
@@ -713,6 +713,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	cpumask_t mask = mm->cpu_vm_mask;
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	on_each_cpu_mask(ipi_flush_tlb_mm, mm, 1, 1, mask);
 }
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/avr32/mm/tlb.c 2.6.23a/arch/avr32/mm/tlb.c
--- 2.6.23/arch/avr32/mm/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/avr32/mm/tlb.c	2007-10-29 13:50:39.000000000 -0700
@@ -249,6 +249,8 @@ void flush_tlb_kernel_range(unsigned lon
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	/* Invalidate all TLB entries of this process by getting a new ASID */
 	if (mm->context != NO_CONTEXT) {
 		unsigned long flags;
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/cris/arch-v10/mm/tlb.c 2.6.23a/arch/cris/arch-v10/mm/tlb.c
--- 2.6.23/arch/cris/arch-v10/mm/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/cris/arch-v10/mm/tlb.c	2007-10-29 13:50:55.000000000 -0700
@@ -69,6 +69,8 @@ flush_tlb_mm(struct mm_struct *mm)
 
 	D(printk("tlb: flush mm context %d (%p)\n", page_id, mm));
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	if(page_id == NO_CONTEXT)
 		return;
 	
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/cris/arch-v32/kernel/smp.c 2.6.23a/arch/cris/arch-v32/kernel/smp.c
--- 2.6.23/arch/cris/arch-v32/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/cris/arch-v32/kernel/smp.c	2007-10-29 13:51:06.000000000 -0700
@@ -237,6 +237,7 @@ void flush_tlb_all(void)
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
 	__flush_tlb_mm(mm);
 	flush_tlb_common(mm, FLUSH_ALL, 0);
 	/* No more mappings in other CPUs */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/i386/kernel/smp.c 2.6.23a/arch/i386/kernel/smp.c
--- 2.6.23/arch/i386/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/i386/kernel/smp.c	2007-10-29 13:51:47.000000000 -0700
@@ -410,6 +410,8 @@ void flush_tlb_mm (struct mm_struct * mm
 {
 	cpumask_t cpu_mask;
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	preempt_disable();
 	cpu_mask = mm->cpu_vm_mask;
 	cpu_clear(smp_processor_id(), cpu_mask);
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/i386/mach-voyager/voyager_smp.c 2.6.23a/arch/i386/mach-voyager/voyager_smp.c
--- 2.6.23/arch/i386/mach-voyager/voyager_smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/i386/mach-voyager/voyager_smp.c	2007-10-29 13:51:55.000000000 -0700
@@ -924,6 +924,8 @@ flush_tlb_mm (struct mm_struct * mm)
 {
 	unsigned long cpu_mask;
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	preempt_disable();
 
 	cpu_mask = cpus_addr(mm->cpu_vm_mask)[0] & ~(1 << smp_processor_id());
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/ia64/kernel/smp.c 2.6.23a/arch/ia64/kernel/smp.c
--- 2.6.23/arch/ia64/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/ia64/kernel/smp.c	2007-10-29 13:52:03.000000000 -0700
@@ -325,6 +325,8 @@ smp_flush_tlb_all (void)
 void
 smp_flush_tlb_mm (struct mm_struct *mm)
 {
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	preempt_disable();
 	/* this happens for the common case of a single-threaded fork():  */
 	if (likely(mm == current->active_mm && atomic_read(&mm->mm_users) == 1))
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/m32r/kernel/smp.c 2.6.23a/arch/m32r/kernel/smp.c
--- 2.6.23/arch/m32r/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/m32r/kernel/smp.c	2007-10-29 13:52:49.000000000 -0700
@@ -280,6 +280,8 @@ void smp_flush_tlb_mm(struct mm_struct *
 	unsigned long *mmc;
 	unsigned long flags;
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	preempt_disable();
 	cpu_id = smp_processor_id();
 	mmc = &mm->context[cpu_id];
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/mips/kernel/smp.c 2.6.23a/arch/mips/kernel/smp.c
--- 2.6.23/arch/mips/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/mips/kernel/smp.c	2007-10-29 13:53:21.000000000 -0700
@@ -387,6 +387,8 @@ static inline void smp_on_each_tlb(void 
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	preempt_disable();
 
 	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/powerpc/mm/tlb_32.c 2.6.23a/arch/powerpc/mm/tlb_32.c
--- 2.6.23/arch/powerpc/mm/tlb_32.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/powerpc/mm/tlb_32.c	2007-10-29 13:54:06.000000000 -0700
@@ -144,6 +144,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *mp;
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	if (Hash == 0) {
 		_tlbia();
 		return;
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/ppc/mm/tlb.c 2.6.23a/arch/ppc/mm/tlb.c
--- 2.6.23/arch/ppc/mm/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/ppc/mm/tlb.c	2007-10-29 13:54:21.000000000 -0700
@@ -144,6 +144,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *mp;
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	if (Hash == 0) {
 		_tlbia();
 		return;
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/sh64/mm/fault.c 2.6.23a/arch/sh64/mm/fault.c
--- 2.6.23/arch/sh64/mm/fault.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/sh64/mm/fault.c	2007-10-29 13:55:03.000000000 -0700
@@ -517,6 +517,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 	++calls_to_flush_tlb_mm;
 #endif
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	if (mm->context == NO_CONTEXT)
 		return;
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/sparc/kernel/smp.c 2.6.23a/arch/sparc/kernel/smp.c
--- 2.6.23/arch/sparc/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/sparc/kernel/smp.c	2007-10-29 13:55:22.000000000 -0700
@@ -163,6 +163,8 @@ void smp_flush_cache_mm(struct mm_struct
 
 void smp_flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	if(mm->context != NO_CONTEXT) {
 		cpumask_t cpu_mask = mm->cpu_vm_mask;
 		cpu_clear(smp_processor_id(), cpu_mask);
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/sparc64/kernel/smp.c 2.6.23a/arch/sparc64/kernel/smp.c
--- 2.6.23/arch/sparc64/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/sparc64/kernel/smp.c	2007-10-29 13:56:32.000000000 -0700
@@ -1112,6 +1112,8 @@ void smp_flush_tlb_mm(struct mm_struct *
 	u32 ctx = CTX_HWBITS(mm->context);
 	int cpu = get_cpu();
 
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	if (atomic_read(&mm->mm_users) == 1) {
 		mm->cpu_vm_mask = cpumask_of_cpu(cpu);
 		goto local_flush_and_out;
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/um/kernel/tlb.c 2.6.23a/arch/um/kernel/tlb.c
--- 2.6.23/arch/um/kernel/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/um/kernel/tlb.c	2007-10-29 13:57:05.000000000 -0700
@@ -402,6 +402,7 @@ void flush_tlb_range(struct vm_area_stru
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
 	CHOOSE_MODE_PROC(flush_tlb_mm_tt, flush_tlb_mm_skas, mm);
 }
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/xtensa/mm/tlb.c 2.6.23a/arch/xtensa/mm/tlb.c
--- 2.6.23/arch/xtensa/mm/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/xtensa/mm/tlb.c	2007-10-29 13:57:26.000000000 -0700
@@ -63,6 +63,8 @@ void flush_tlb_all (void)
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NNED_FLUSH, mm->flags);
+
 	if (mm == current->active_mm) {
 		int flags;
 		local_save_flags(flags);
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
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-generic/tlbflush.h 2.6.23a/include/asm-generic/tlbflush.h
--- 2.6.23/include/asm-generic/tlbflush.h	1969-12-31 16:00:00.000000000 -0800
+++ 2.6.23a/include/asm-generic/tlbflush.h	2008-01-17 07:36:27.000000000 -0800
@@ -0,0 +1,103 @@
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
+	spin_lock_irqsave(&mm->page_table_lock, flags);
+	dest_ptr = page_address(dest);
+	memcpy(dest_ptr, mm->pgd, PAGE_SIZE);
+
+	/* Must be done before adding the list to the page to be
+	 * freed. Should we take the pgd_lock through this entire
+	 * mess, or is it ok for the pgd to be missing from the list
+	 * for a bit?
+	 */
+	pgd_list_del(mm->pgd);
+
+	list_add_tail(&(virt_to_page(mm->pgd)->lru), old_pages);
+
+	mm->pgd = (pgd_t *)dest_ptr;
+
+	pgd_list_add(mm->pgd);
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
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/linux/sched.h 2.6.23a/include/linux/sched.h
--- 2.6.23/include/linux/sched.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/linux/sched.h	2008-01-02 08:49:40.000000000 -0800
@@ -366,6 +366,10 @@ extern int get_dumpable(struct mm_struct
 #define MMF_DUMP_FILTER_DEFAULT \
 	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED))
 
+/* Misc MM flags. */
+#define MMF_NEED_FLUSH		6
+#define MMF_NEED_RELOAD		7	/* Only meaningful on some archs. */
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
