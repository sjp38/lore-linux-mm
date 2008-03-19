Subject: [RFC][PATCH 1/2]: MM: Make Page Tables Reloctable: Conditional TLB Flush
Message-Id: <20080319141829.1F2E4DC98D@localhost>
Date: Wed, 19 Mar 2008 07:18:29 -0700 (PDT)
From: rossb@google.com (Ross Biro)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rossb@google.com
List-ID: <linux-mm.kvack.org>

These Patches make page tables relocatable for numa, memory
defragmentation, and memory hotblug.  The potential need to rewalk the
page tables before making any changes causes a 3% peformance
degredation in the lmbench page miss micro benchmark.

Signed-off-by:rossb@google.com

----

These patches are against 2.6.23 kernel.org kernel.

The lmbech results are available if any wants to see them.  This
version of the patch is x86_64 specific.  The per archictecture part
of the patch is limited to allocating new page tables and reloading
the pgd. The main differences between this version and the previous
one is that a flag in the MM is used to determine if the page tables
need to be rewalked, a race when split page table locks were used was
fixed, and per-arch page table allocation functions were used to
allocate the new page tables.

If there are no complaints, I intend to make a new version of these
patches against the latest mm kernel, put some #ifdefs for supported vs
unsuportted archs and request inclusion in the mm kernel.

diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/arm/kernel/smp.c 2.6.23a/arch/arm/kernel/smp.c
--- 2.6.23/arch/arm/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/arm/kernel/smp.c	2008-01-24 07:16:31.000000000 -0800
@@ -713,6 +713,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	cpumask_t mask = mm->cpu_vm_mask;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	on_each_cpu_mask(ipi_flush_tlb_mm, mm, 1, 1, mask);
 }
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/avr32/mm/tlb.c 2.6.23a/arch/avr32/mm/tlb.c
--- 2.6.23/arch/avr32/mm/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/avr32/mm/tlb.c	2008-01-24 07:16:38.000000000 -0800
@@ -249,6 +249,8 @@ void flush_tlb_kernel_range(unsigned lon
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	/* Invalidate all TLB entries of this process by getting a new ASID */
 	if (mm->context != NO_CONTEXT) {
 		unsigned long flags;
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/cris/arch-v10/mm/tlb.c 2.6.23a/arch/cris/arch-v10/mm/tlb.c
--- 2.6.23/arch/cris/arch-v10/mm/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/cris/arch-v10/mm/tlb.c	2008-01-24 07:16:44.000000000 -0800
@@ -69,6 +69,8 @@ flush_tlb_mm(struct mm_struct *mm)
 
 	D(printk("tlb: flush mm context %d (%p)\n", page_id, mm));
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if(page_id == NO_CONTEXT)
 		return;
 	
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/cris/arch-v32/kernel/smp.c 2.6.23a/arch/cris/arch-v32/kernel/smp.c
--- 2.6.23/arch/cris/arch-v32/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/cris/arch-v32/kernel/smp.c	2008-01-24 07:16:50.000000000 -0800
@@ -237,6 +237,7 @@ void flush_tlb_all(void)
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
 	__flush_tlb_mm(mm);
 	flush_tlb_common(mm, FLUSH_ALL, 0);
 	/* No more mappings in other CPUs */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/i386/kernel/smp.c 2.6.23a/arch/i386/kernel/smp.c
--- 2.6.23/arch/i386/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/i386/kernel/smp.c	2008-01-24 07:16:55.000000000 -0800
@@ -410,6 +410,8 @@ void flush_tlb_mm (struct mm_struct * mm
 {
 	cpumask_t cpu_mask;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	preempt_disable();
 	cpu_mask = mm->cpu_vm_mask;
 	cpu_clear(smp_processor_id(), cpu_mask);
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/i386/mach-voyager/voyager_smp.c 2.6.23a/arch/i386/mach-voyager/voyager_smp.c
--- 2.6.23/arch/i386/mach-voyager/voyager_smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/i386/mach-voyager/voyager_smp.c	2008-01-24 07:17:01.000000000 -0800
@@ -924,6 +924,8 @@ flush_tlb_mm (struct mm_struct * mm)
 {
 	unsigned long cpu_mask;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	preempt_disable();
 
 	cpu_mask = cpus_addr(mm->cpu_vm_mask)[0] & ~(1 << smp_processor_id());
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/alpha/kernel/smp.c 2.6.23a/arch/alpha/kernel/smp.c
--- 2.6.23/arch/alpha/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/alpha/kernel/smp.c	2008-01-24 07:16:26.000000000 -0800
@@ -850,6 +850,8 @@ flush_tlb_mm(struct mm_struct *mm)
 {
 	preempt_disable();
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (mm == current->active_mm) {
 		flush_tlb_current(mm);
 		if (atomic_read(&mm->mm_users) <= 1) {
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/ia64/kernel/smp.c 2.6.23a/arch/ia64/kernel/smp.c
--- 2.6.23/arch/ia64/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/ia64/kernel/smp.c	2008-01-24 07:17:05.000000000 -0800
@@ -325,6 +325,8 @@ smp_flush_tlb_all (void)
 void
 smp_flush_tlb_mm (struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	preempt_disable();
 	/* this happens for the common case of a single-threaded fork():  */
 	if (likely(mm == current->active_mm && atomic_read(&mm->mm_users) == 1))
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/m32r/kernel/smp.c 2.6.23a/arch/m32r/kernel/smp.c
--- 2.6.23/arch/m32r/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/m32r/kernel/smp.c	2008-01-24 07:17:10.000000000 -0800
@@ -280,6 +280,8 @@ void smp_flush_tlb_mm(struct mm_struct *
 	unsigned long *mmc;
 	unsigned long flags;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	preempt_disable();
 	cpu_id = smp_processor_id();
 	mmc = &mm->context[cpu_id];
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/mips/kernel/smp.c 2.6.23a/arch/mips/kernel/smp.c
--- 2.6.23/arch/mips/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/mips/kernel/smp.c	2008-01-24 07:17:15.000000000 -0800
@@ -387,6 +387,8 @@ static inline void smp_on_each_tlb(void 
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	preempt_disable();
 
 	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/powerpc/mm/tlb_32.c 2.6.23a/arch/powerpc/mm/tlb_32.c
--- 2.6.23/arch/powerpc/mm/tlb_32.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/powerpc/mm/tlb_32.c	2008-01-24 07:17:19.000000000 -0800
@@ -144,6 +144,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *mp;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (Hash == 0) {
 		_tlbia();
 		return;
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/ppc/mm/tlb.c 2.6.23a/arch/ppc/mm/tlb.c
--- 2.6.23/arch/ppc/mm/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/ppc/mm/tlb.c	2008-01-24 07:17:23.000000000 -0800
@@ -144,6 +144,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *mp;
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (Hash == 0) {
 		_tlbia();
 		return;
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/sh64/mm/fault.c 2.6.23a/arch/sh64/mm/fault.c
--- 2.6.23/arch/sh64/mm/fault.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/sh64/mm/fault.c	2008-01-24 07:17:28.000000000 -0800
@@ -517,6 +517,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 	++calls_to_flush_tlb_mm;
 #endif
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (mm->context == NO_CONTEXT)
 		return;
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/sparc/kernel/smp.c 2.6.23a/arch/sparc/kernel/smp.c
--- 2.6.23/arch/sparc/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/sparc/kernel/smp.c	2008-01-24 07:17:33.000000000 -0800
@@ -163,6 +163,8 @@ void smp_flush_cache_mm(struct mm_struct
 
 void smp_flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if(mm->context != NO_CONTEXT) {
 		cpumask_t cpu_mask = mm->cpu_vm_mask;
 		cpu_clear(smp_processor_id(), cpu_mask);
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/sparc64/kernel/smp.c 2.6.23a/arch/sparc64/kernel/smp.c
--- 2.6.23/arch/sparc64/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/sparc64/kernel/smp.c	2008-01-24 07:17:37.000000000 -0800
@@ -1112,6 +1112,8 @@ void smp_flush_tlb_mm(struct mm_struct *
 	u32 ctx = CTX_HWBITS(mm->context);
 	int cpu = get_cpu();
 
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (atomic_read(&mm->mm_users) == 1) {
 		mm->cpu_vm_mask = cpumask_of_cpu(cpu);
 		goto local_flush_and_out;
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/um/kernel/tlb.c 2.6.23a/arch/um/kernel/tlb.c
--- 2.6.23/arch/um/kernel/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/um/kernel/tlb.c	2008-01-24 07:17:41.000000000 -0800
@@ -402,6 +402,7 @@ void flush_tlb_range(struct vm_area_stru
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
 	CHOOSE_MODE_PROC(flush_tlb_mm_tt, flush_tlb_mm_skas, mm);
 }
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/xtensa/mm/tlb.c 2.6.23a/arch/xtensa/mm/tlb.c
--- 2.6.23/arch/xtensa/mm/tlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/xtensa/mm/tlb.c	2008-01-24 07:17:46.000000000 -0800
@@ -63,6 +63,8 @@ void flush_tlb_all (void)
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
+	clear_bit(MMF_NEED_FLUSH, mm->flags);
+
 	if (mm == current->active_mm) {
 		int flags;
 		local_save_flags(flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
