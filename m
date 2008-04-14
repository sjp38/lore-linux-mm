Subject: [PATCH 1/2] MM: Make page tables relocatable -- conditional flush (rc9)
Message-Id: <20080414163933.A9628DCA48@localhost>
Date: Mon, 14 Apr 2008 09:39:33 -0700 (PDT)
From: rossb@google.com (Ross Biro)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rossb@google.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

These Patches make page tables relocatable for numa, memory
defragmentation, and memory hotblug.  The potential need to rewalk the
page tables before making any changes causes a 3% peformance
degredation in the lmbench page miss micro benchmark.

Signed-off-by:rossb@google.com

----

These patches are against 2.6.25-rc9.  There are no other differences between
this version and the last one.

diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/alpha/kernel/smp.c 2.6.25-rc9/arch/alpha/kernel/smp.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/alpha/kernel/smp.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/alpha/kernel/smp.c	2008-04-14 09:00:18.000000000 -0700
@@ -845,6 +845,8 @@ flush_tlb_mm(struct mm_struct *mm)
 {
 	preempt_disable();
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (mm == current->active_mm) {
 		flush_tlb_current(mm);
 		if (atomic_read(&mm->mm_users) <= 1) {
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/arm/kernel/smp.c 2.6.25-rc9/arch/arm/kernel/smp.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/arm/kernel/smp.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/arm/kernel/smp.c	2008-04-14 09:00:18.000000000 -0700
@@ -738,6 +738,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	cpumask_t mask = mm->cpu_vm_mask;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	on_each_cpu_mask(ipi_flush_tlb_mm, mm, 1, 1, mask);
 }
 
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/avr32/mm/tlb.c 2.6.25-rc9/arch/avr32/mm/tlb.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/avr32/mm/tlb.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/avr32/mm/tlb.c	2008-04-14 09:00:18.000000000 -0700
@@ -249,6 +249,8 @@ void flush_tlb_kernel_range(unsigned lon
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	/* Invalidate all TLB entries of this process by getting a new ASID */
 	if (mm->context != NO_CONTEXT) {
 		unsigned long flags;
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/cris/arch-v10/mm/tlb.c 2.6.25-rc9/arch/cris/arch-v10/mm/tlb.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/cris/arch-v10/mm/tlb.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/cris/arch-v10/mm/tlb.c	2008-04-14 09:00:18.000000000 -0700
@@ -69,6 +69,8 @@ flush_tlb_mm(struct mm_struct *mm)
 
 	D(printk("tlb: flush mm context %d (%p)\n", page_id, mm));
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if(page_id == NO_CONTEXT)
 		return;
 
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/cris/arch-v32/kernel/smp.c 2.6.25-rc9/arch/cris/arch-v32/kernel/smp.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/cris/arch-v32/kernel/smp.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/cris/arch-v32/kernel/smp.c	2008-04-14 09:00:18.000000000 -0700
@@ -252,6 +252,7 @@ void flush_tlb_all(void)
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
 	__flush_tlb_mm(mm);
 	flush_tlb_common(mm, FLUSH_ALL, 0);
 	/* No more mappings in other CPUs */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/ia64/kernel/smp.c 2.6.25-rc9/arch/ia64/kernel/smp.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/ia64/kernel/smp.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/ia64/kernel/smp.c	2008-04-14 09:00:18.000000000 -0700
@@ -325,6 +325,8 @@ smp_flush_tlb_all (void)
 void
 smp_flush_tlb_mm (struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	preempt_disable();
 	/* this happens for the common case of a single-threaded fork():  */
 	if (likely(mm == current->active_mm && atomic_read(&mm->mm_users) == 1))
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/m32r/kernel/smp.c 2.6.25-rc9/arch/m32r/kernel/smp.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/m32r/kernel/smp.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/m32r/kernel/smp.c	2008-04-14 09:00:18.000000000 -0700
@@ -280,6 +280,8 @@ void smp_flush_tlb_mm(struct mm_struct *
 	unsigned long *mmc;
 	unsigned long flags;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	preempt_disable();
 	cpu_id = smp_processor_id();
 	mmc = &mm->context[cpu_id];
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/mips/kernel/smp.c 2.6.25-rc9/arch/mips/kernel/smp.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/mips/kernel/smp.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/mips/kernel/smp.c	2008-04-14 09:00:18.000000000 -0700
@@ -408,6 +408,8 @@ static inline void smp_on_each_tlb(void 
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	preempt_disable();
 
 	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/tlb_32.c 2.6.25-rc9/arch/powerpc/mm/tlb_32.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/tlb_32.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/powerpc/mm/tlb_32.c	2008-04-14 09:00:18.000000000 -0700
@@ -144,6 +144,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *mp;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (Hash == 0) {
 		_tlbia();
 		return;
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/ppc/mm/tlb.c 2.6.25-rc9/arch/ppc/mm/tlb.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/ppc/mm/tlb.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/ppc/mm/tlb.c	2008-04-14 09:00:18.000000000 -0700
@@ -144,6 +144,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *mp;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (Hash == 0) {
 		_tlbia();
 		return;
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/sparc/kernel/smp.c 2.6.25-rc9/arch/sparc/kernel/smp.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/sparc/kernel/smp.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/sparc/kernel/smp.c	2008-04-14 09:00:18.000000000 -0700
@@ -163,6 +163,8 @@ void smp_flush_cache_mm(struct mm_struct
 
 void smp_flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if(mm->context != NO_CONTEXT) {
 		cpumask_t cpu_mask = mm->cpu_vm_mask;
 		cpu_clear(smp_processor_id(), cpu_mask);
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/sparc64/kernel/smp.c 2.6.25-rc9/arch/sparc64/kernel/smp.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/sparc64/kernel/smp.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/sparc64/kernel/smp.c	2008-04-14 09:00:18.000000000 -0700
@@ -1119,6 +1119,8 @@ void smp_flush_tlb_mm(struct mm_struct *
 	u32 ctx = CTX_HWBITS(mm->context);
 	int cpu = get_cpu();
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (atomic_read(&mm->mm_users) == 1) {
 		mm->cpu_vm_mask = cpumask_of_cpu(cpu);
 		goto local_flush_and_out;
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/um/kernel/tlb.c 2.6.25-rc9/arch/um/kernel/tlb.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/um/kernel/tlb.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/um/kernel/tlb.c	2008-04-14 09:00:18.000000000 -0700
@@ -517,6 +517,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma = mm->mmap;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	while (vma != NULL) {
 		fix_range(mm, vma->vm_start, vma->vm_end, 0);
 		vma = vma->vm_next;
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/x86/kernel/smp_32.c 2.6.25-rc9/arch/x86/kernel/smp_32.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/x86/kernel/smp_32.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/x86/kernel/smp_32.c	2008-04-14 09:00:18.000000000 -0700
@@ -332,6 +332,8 @@ void smp_invalidate_interrupt(struct pt_
 		if (per_cpu(cpu_tlbstate, cpu).state == TLBSTATE_OK) {
 			if (flush_va == TLB_FLUSH_ALL)
 				local_flush_tlb();
+			else if (f->flush_va == TLB_RELOAD_ALL)
+				local_reload_tlb_mm(f->flush_mm);
 			else
 				__flush_tlb_one(flush_va);
 		} else
@@ -408,10 +410,35 @@ void flush_tlb_current_task(void)
 	preempt_enable();
 }
 
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
+		flush_tlb_others(cpu_mask, mm, TLB_RELOAD_ALL);
+
+	preempt_enable();
+
+}
+
 void flush_tlb_mm (struct mm_struct * mm)
 {
 	cpumask_t cpu_mask;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
 	preempt_disable();
 	cpu_mask = mm->cpu_vm_mask;
 	cpu_clear(smp_processor_id(), cpu_mask);
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/x86/kernel/smp_64.c 2.6.25-rc9/arch/x86/kernel/smp_64.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/x86/kernel/smp_64.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/x86/kernel/smp_64.c	2008-04-14 09:00:18.000000000 -0700
@@ -155,6 +155,8 @@ asmlinkage void smp_invalidate_interrupt
 		if (read_pda(mmu_state) == TLBSTATE_OK) {
 			if (f->flush_va == TLB_FLUSH_ALL)
 				local_flush_tlb();
+			else if (f->flush_va == TLB_RELOAD_ALL)
+				local_reload_tlb_mm(f->flush_mm);
 			else
 				__flush_tlb_one(f->flush_va);
 		} else
@@ -228,10 +230,36 @@ void flush_tlb_current_task(void)
 	preempt_enable();
 }
 
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
+		flush_tlb_others(cpu_mask, mm, TLB_RELOAD_ALL);
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
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/x86/mach-voyager/voyager_smp.c 2.6.25-rc9/arch/x86/mach-voyager/voyager_smp.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/x86/mach-voyager/voyager_smp.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/x86/mach-voyager/voyager_smp.c	2008-04-14 09:00:18.000000000 -0700
@@ -909,6 +909,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	unsigned long cpu_mask;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	preempt_disable();
 
 	cpu_mask = cpus_addr(mm->cpu_vm_mask)[0] & ~(1 << smp_processor_id());
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/xtensa/mm/tlb.c 2.6.25-rc9/arch/xtensa/mm/tlb.c
--- /home/rossb/local/linux-2.6.25-rc9/arch/xtensa/mm/tlb.c	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/arch/xtensa/mm/tlb.c	2008-04-14 09:00:18.000000000 -0700
@@ -63,6 +63,8 @@ void flush_tlb_all (void)
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (mm == current->active_mm) {
 		int flags;
 		local_save_flags(flags);
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-alpha/tlbflush.h 2.6.25-rc9/include/asm-alpha/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-alpha/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-alpha/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -148,4 +148,6 @@ static inline void flush_tlb_kernel_rang
 	flush_tlb_all();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _ALPHA_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-arm/tlbflush.h 2.6.25-rc9/include/asm-arm/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-arm/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-arm/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -466,5 +466,6 @@ extern void update_mmu_cache(struct vm_a
 #endif
 
 #endif /* CONFIG_MMU */
+#include <asm-generic/tlbflush.h>
 
 #endif
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-avr32/tlbflush.h 2.6.25-rc9/include/asm-avr32/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-avr32/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-avr32/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -29,5 +29,6 @@ extern void flush_tlb_page(struct vm_are
 extern void __flush_tlb_page(unsigned long asid, unsigned long page);
 
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
+#include <asm-generic/tlbflush.h>
 
 #endif /* __ASM_AVR32_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-blackfin/tlbflush.h 2.6.25-rc9/include/asm-blackfin/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-blackfin/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-blackfin/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -53,4 +53,5 @@ static inline void flush_tlb_kernel_page
 	BUG();
 }
 
+#include <asm-generic/tlbflush.h>
 #endif
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-cris/tlbflush.h 2.6.25-rc9/include/asm-cris/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-cris/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-cris/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -44,5 +44,6 @@ static inline void flush_tlb(void)
 }
 
 #define flush_tlb_kernel_range(start, end) flush_tlb_all()
+#include <asm-generic/tlbflush.h>
 
 #endif /* _CRIS_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-frv/tlbflush.h 2.6.25-rc9/include/asm-frv/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-frv/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-frv/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -68,6 +68,7 @@ do {								\
 #define flush_tlb_kernel_range(start, end)	BUG()
 
 #endif
+#include <asm-generic/tlbflush.h>
 
 
 #endif /* _ASM_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/tlbflush.h 2.6.25-rc9/include/asm-generic/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/tlbflush.h	1969-12-31 16:00:00.000000000 -0800
+++ 2.6.25-rc9/include/asm-generic/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
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
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-h8300/tlbflush.h 2.6.25-rc9/include/asm-h8300/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-h8300/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-h8300/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -52,4 +52,6 @@ static inline void flush_tlb_kernel_page
 	BUG();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _H8300_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-ia64/tlbflush.h 2.6.25-rc9/include/asm-ia64/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-ia64/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-ia64/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -98,4 +98,6 @@ static inline void flush_tlb_kernel_rang
 	flush_tlb_all();	/* XXX fix me */
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _ASM_IA64_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-m32r/tlbflush.h 2.6.25-rc9/include/asm-m32r/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-m32r/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-m32r/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -93,5 +93,6 @@ static __inline__ void __flush_tlb_all(v
 }
 
 extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t);
+#include <asm-generic/tlbflush.h>
 
 #endif	/* _ASM_M32R_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-m68k/tlbflush.h 2.6.25-rc9/include/asm-m68k/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-m68k/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-m68k/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -215,5 +215,6 @@ static inline void flush_tlb_kernel_page
 }
 
 #endif
+#include <asm-generic/tlbflush.h>
 
 #endif /* _M68K_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-m68knommu/tlbflush.h 2.6.25-rc9/include/asm-m68knommu/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-m68knommu/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-m68knommu/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -52,4 +52,6 @@ static inline void flush_tlb_kernel_page
 	BUG();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _M68KNOMMU_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-mips/tlbflush.h 2.6.25-rc9/include/asm-mips/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-mips/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-mips/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -44,4 +44,6 @@ extern void flush_tlb_one(unsigned long 
 
 #endif /* CONFIG_SMP */
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* __ASM_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-parisc/tlbflush.h 2.6.25-rc9/include/asm-parisc/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-parisc/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-parisc/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -76,5 +76,6 @@ void __flush_tlb_range(unsigned long sid
 #define flush_tlb_range(vma,start,end) __flush_tlb_range((vma)->vm_mm->context,start,end)
 
 #define flush_tlb_kernel_range(start, end) __flush_tlb_range(0,start,end)
+#include <asm-generic/tlbflush.h>
 
 #endif
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-powerpc/tlbflush.h 2.6.25-rc9/include/asm-powerpc/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-powerpc/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-powerpc/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -173,5 +173,7 @@ extern void __flush_hash_table_range(str
  */
 extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t);
 
+#include <asm-generic/tlbflush.h>
+
 #endif /*__KERNEL__ */
 #endif /* _ASM_POWERPC_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-s390/tlbflush.h 2.6.25-rc9/include/asm-s390/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-s390/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-s390/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -126,4 +126,6 @@ static inline void flush_tlb_kernel_rang
 	__tlb_flush_mm(&init_mm);
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _S390_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-sh/tlbflush.h 2.6.25-rc9/include/asm-sh/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-sh/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-sh/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -46,4 +46,6 @@ extern void flush_tlb_one(unsigned long 
 
 #endif /* CONFIG_SMP */
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* __ASM_SH_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-sparc/tlbflush.h 2.6.25-rc9/include/asm-sparc/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-sparc/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-sparc/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -57,4 +57,6 @@ static inline void flush_tlb_kernel_rang
 	flush_tlb_all();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _SPARC_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-sparc64/tlbflush.h 2.6.25-rc9/include/asm-sparc64/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-sparc64/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-sparc64/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -41,4 +41,6 @@ do {	flush_tsb_kernel_range(start,end); 
 
 #endif /* ! CONFIG_SMP */
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _SPARC64_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-um/tlbflush.h 2.6.25-rc9/include/asm-um/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-um/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-um/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -28,4 +28,6 @@ extern void flush_tlb_kernel_vm(void);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 extern void __flush_tlb_one(unsigned long addr);
 
+#include <asm-generic/tlbflush.h>
+
 #endif
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-v850/tlbflush.h 2.6.25-rc9/include/asm-v850/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-v850/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-v850/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -61,4 +61,6 @@ static inline void flush_tlb_kernel_page
 	BUG ();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* __V850_TLBFLUSH_H__ */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/tlbflush.h 2.6.25-rc9/include/asm-x86/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-x86/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -35,6 +35,13 @@ static inline void __native_flush_tlb_si
 	__asm__ __volatile__("invlpg (%0)" ::"r" (addr) : "memory");
 }
 
+#define ARCH_HAS_RELOAD_TLB
+static inline void load_cr3(pgd_t *pgd);
+static inline void __reload_tlb_mm(struct mm_struct *mm)
+{
+	load_cr3(mm->pgd);
+}
+
 static inline void __flush_tlb_all(void)
 {
 	if (cpu_has_pge)
@@ -53,8 +60,10 @@ static inline void __flush_tlb_one(unsig
 
 #ifdef CONFIG_X86_32
 # define TLB_FLUSH_ALL	0xffffffff
+# define TLB_RELOAD_ALL 0xfffffffe
 #else
 # define TLB_FLUSH_ALL	-1ULL
+# define TLB_RELOAD_ALL -2ULL
 #endif
 
 /*
@@ -82,6 +91,12 @@ static inline void __flush_tlb_one(unsig
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
@@ -114,6 +129,10 @@ static inline void native_flush_tlb_othe
 
 #define local_flush_tlb() __flush_tlb()
 
+#define local_reload_tlb_mm(mm) \
+	__reload_tlb_mm(mm)
+
+extern void reload_tlb_mm(struct mm_struct *mm);
 extern void flush_tlb_all(void);
 extern void flush_tlb_current_task(void);
 extern void flush_tlb_mm(struct mm_struct *);
@@ -155,4 +174,6 @@ static inline void flush_tlb_kernel_rang
 	flush_tlb_all();
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _ASM_X86_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-xtensa/tlbflush.h 2.6.25-rc9/include/asm-xtensa/tlbflush.h
--- /home/rossb/local/linux-2.6.25-rc9/include/asm-xtensa/tlbflush.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/asm-xtensa/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
@@ -186,6 +186,8 @@ static inline unsigned long read_itlb_tr
 	return tmp;
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif	/* __ASSEMBLY__ */
 #endif	/* __KERNEL__ */
 #endif	/* _XTENSA_TLBFLUSH_H */
diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/linux/sched.h 2.6.25-rc9/include/linux/sched.h
--- /home/rossb/local/linux-2.6.25-rc9/include/linux/sched.h	2008-04-11 13:32:29.000000000 -0700
+++ 2.6.25-rc9/include/linux/sched.h	2008-04-14 09:00:18.000000000 -0700
@@ -408,6 +408,16 @@ extern int get_dumpable(struct mm_struct
 #define MMF_DUMP_FILTER_DEFAULT \
 	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED))
 
+/* Misc MM flags. */
+#define MMF_NEED_FLUSH		7
+#define MMF_NEED_RELOAD		8	/* Only meaningful on some archs. */
+
+#ifdef CONFIG_RELOCATE_PAGE_TABLES
+#define MMF_NEED_REWALK		9	/* Must rewalk page tables with spin
+					 * lock held. */
+#endif /*  CONFIG_RELOCATE_PAGE_TABLES  */
+
+
 struct sighand_struct {
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
