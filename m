Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC21440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:34 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q126so9863271pgq.7
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:34 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f9si9251496pgt.793.2017.11.10.11.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:31 -0800 (PST)
Subject: [PATCH 08/30] x86, kaiser: unmap kernel from userspace page tables (core patch)
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:12 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193112.6A962D6A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

These patches are based on work from a team at Graz University of
Technology: https://github.com/IAIK/KAISER .  This work would not have
been possible without their work as a starting point.

KAISER is a countermeasure against side channel attacks against kernel
virtual memory.  It leaves the existing page tables largely alone and
refers to them as the "kernel page tables.  It adds a "shadow" pgd for
every process which is intended for use when running userspace.  The
shadow pgd maps all the same user memory as the "kernel" copy, but
only maps a minimal set of kernel memory.

Whenever entering the kernel (syscalls, interrupts, exceptions), the
pgd is switched to the "kernel" copy.  When switching back to user
mode, the shadow pgd is used.

The minimalistic kernel page tables try to map only what is needed to
enter/exit the kernel such as the entry/exit functions themselves and
the interrupt descriptors (IDT).

Changes from original KAISER patch:
 * Gobs of coding style cleanups
 * The original patch tried to allocate an order-2 page, then
   8k-align the result.  That's silly since order-2 is already
   guaranteed to be 16k-aligned.  Removed that gunk and just
   allocate an order-1 page.
 * Handle (or at least detect and warn on) allocation failures
 * Use _KERNPG_TABLE, not _PAGE_TABLE when creating mappings for
   the kernel in the shadow (user) page tables.
 * BUG_ON() for !pte_none() case was totally insane: it checked
   the physical address of the 'struct page' against the physical
   address of the page being mapped.
 * Added 5-level page table support
 * Never free kaiser page tables.  We don't have the locking to
   keep them from getting referenced during the freeing process.
 * Use a totally different scheme in the entry code.  The
   original code just fell apart in horrific ways in debug faults,
   NMIs, or when iret faults.  Big thanks to Andy Lutomirski for
   reducing the number of places that needed to be patched.  He
   made the code a ton simpler.
 * Use new entry trampoline instead of mapping process stacks.

Note: The original KAISER authors signed-off on their patch.  Some of
their code has been broken out into other patches in this series, but
their SoB was only retained here.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/Documentation/x86/kaiser.txt      |  160 +++++++++++++
 b/arch/x86/entry/calling.h          |    1 
 b/arch/x86/entry/entry_64.S         |   15 +
 b/arch/x86/include/asm/kaiser.h     |   57 ++++
 b/arch/x86/include/asm/pgtable.h    |    6 
 b/arch/x86/include/asm/pgtable_64.h |   93 +++++++
 b/arch/x86/kernel/espfix_64.c       |   17 +
 b/arch/x86/kernel/head_64.S         |   14 -
 b/arch/x86/kernel/traps.c           |   46 +++
 b/arch/x86/mm/Makefile              |    1 
 b/arch/x86/mm/kaiser.c              |  423 ++++++++++++++++++++++++++++++++++++
 b/arch/x86/mm/pageattr.c            |    2 
 b/arch/x86/mm/pgtable.c             |   16 +
 b/include/linux/kaiser.h            |   29 ++
 b/init/main.c                       |    3 
 b/kernel/fork.c                     |    1 
 16 files changed, 867 insertions(+), 17 deletions(-)

diff -puN arch/x86/entry/calling.h~kaiser-base arch/x86/entry/calling.h
--- a/arch/x86/entry/calling.h~kaiser-base	2017-11-10 11:22:09.005244950 -0800
+++ b/arch/x86/entry/calling.h	2017-11-10 11:22:09.030244950 -0800
@@ -1,6 +1,7 @@
 #include <linux/jump_label.h>
 #include <asm/unwind_hints.h>
 #include <asm/cpufeatures.h>
+#include <asm/page_types.h>
 
 /*
 
diff -puN arch/x86/entry/entry_64.S~kaiser-base arch/x86/entry/entry_64.S
--- a/arch/x86/entry/entry_64.S~kaiser-base	2017-11-10 11:22:09.007244950 -0800
+++ b/arch/x86/entry/entry_64.S	2017-11-10 11:22:09.031244950 -0800
@@ -145,6 +145,16 @@ ENTRY(entry_SYSCALL_64)
 
 	swapgs
 	movq	%rsp, PER_CPU_VAR(rsp_scratch)
+
+	/*
+	 * We need a good kernel CR3 to be able to map the process
+	 * stack, but we need a scratch register to be able to load
+	 * CR3.  We could create another PER_CPU_VAR(), but %rsp is
+	 * actually clobberable right now.  Just use it.  It will only
+	 * be insane for one a couple instructions.
+	 */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
+
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 
 	/* Construct struct pt_regs on stack */
@@ -169,8 +179,6 @@ GLOBAL(entry_SYSCALL_64_after_hwframe)
 
 	/* NB: right here, all regs except r11 are live. */
 
-	SWITCH_TO_KERNEL_CR3 scratch_reg=%r11
-
 	/* Must wait until we have the kernel CR3 to call C functions: */
 	TRACE_IRQS_OFF
 
@@ -1269,6 +1277,7 @@ ENTRY(error_entry)
 	 * gsbase and proceed.  We'll fix up the exception and land in
 	 * .Lgs_change's error handler with kernel gsbase.
 	 */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
 	SWAPGS
 	jmp .Lerror_entry_done
 
@@ -1382,6 +1391,7 @@ ENTRY(nmi)
 
 	swapgs
 	cld
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdx
 	movq	%rsp, %rdx
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 	UNWIND_HINT_IRET_REGS base=%rdx offset=8
@@ -1410,7 +1420,6 @@ ENTRY(nmi)
 	UNWIND_HINT_REGS
 	ENCODE_FRAME_POINTER
 
-	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
 	/*
 	 * At this point we no longer need to worry about stack damage
 	 * due to nesting -- we're on the normal thread stack and we're
diff -puN /dev/null arch/x86/include/asm/kaiser.h
--- /dev/null	2017-11-06 07:51:38.702108459 -0800
+++ b/arch/x86/include/asm/kaiser.h	2017-11-10 11:22:09.031244950 -0800
@@ -0,0 +1,57 @@
+#ifndef _ASM_X86_KAISER_H
+#define _ASM_X86_KAISER_H
+/*
+ * Copyright(c) 2017 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * Based on work published here: https://github.com/IAIK/KAISER
+ * Modified by Dave Hansen <dave.hansen@intel.com to actually work.
+ */
+#ifndef __ASSEMBLY__
+
+#ifdef CONFIG_KAISER
+/**
+ *  kaiser_add_mapping - map a kernel range into the user page tables
+ *  @addr: the start address of the range
+ *  @size: the size of the range
+ *  @flags: The mapping flags of the pages
+ *
+ *  Use this on all data and code that need to be mapped into both
+ *  copies of the page tables.  This includes the code that switches
+ *  to/from userspace and all of the hardware structures that are
+ *  virtually-addressed and needed in userspace like the interrupt
+ *  table.
+ */
+extern int kaiser_add_mapping(unsigned long addr, unsigned long size,
+			      unsigned long flags);
+
+/**
+ *  kaiser_remove_mapping - remove a kernel mapping from the userpage tables
+ *  @addr: the start address of the range
+ *  @size: the size of the range
+ */
+extern void kaiser_remove_mapping(unsigned long start, unsigned long size);
+
+/**
+ *  kaiser_init - Initialize the shadow mapping
+ *
+ *  Most parts of the shadow mapping can be mapped upon boot
+ *  time.  Only per-process things like the thread stacks
+ *  or a new LDT have to be mapped at runtime.  These boot-
+ *  time mappings are permanent and never unmapped.
+ */
+extern void kaiser_init(void);
+
+#endif
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _ASM_X86_KAISER_H */
diff -puN arch/x86/include/asm/pgtable_64.h~kaiser-base arch/x86/include/asm/pgtable_64.h
--- a/arch/x86/include/asm/pgtable_64.h~kaiser-base	2017-11-10 11:22:09.009244950 -0800
+++ b/arch/x86/include/asm/pgtable_64.h	2017-11-10 11:22:09.032244950 -0800
@@ -130,9 +130,88 @@ static inline pud_t native_pudp_get_and_
 #endif
 }
 
+#ifdef CONFIG_KAISER
+/*
+ * All top-level KAISER page tables are order-1 pages (8k-aligned
+ * and 8k in size).  The kernel one is at the beginning 4k and
+ * the user (shadow) one is in the last 4k.  To switch between
+ * them, you just need to flip the 12th bit in their addresses.
+ */
+#define KAISER_PGTABLE_SWITCH_BIT	PAGE_SHIFT
+
+/*
+ * This generates better code than the inline assembly in
+ * __set_bit().
+ */
+static inline void *ptr_set_bit(void *ptr, int bit)
+{
+	unsigned long __ptr = (unsigned long)ptr;
+	__ptr |= (1<<bit);
+	return (void *)__ptr;
+}
+static inline void *ptr_clear_bit(void *ptr, int bit)
+{
+	unsigned long __ptr = (unsigned long)ptr;
+	__ptr &= ~(1<<bit);
+	return (void *)__ptr;
+}
+
+static inline pgd_t *native_get_shadow_pgd(pgd_t *pgdp)
+{
+	return ptr_set_bit(pgdp, KAISER_PGTABLE_SWITCH_BIT);
+}
+static inline pgd_t *native_get_normal_pgd(pgd_t *pgdp)
+{
+	return ptr_clear_bit(pgdp, KAISER_PGTABLE_SWITCH_BIT);
+}
+static inline p4d_t *native_get_shadow_p4d(p4d_t *p4dp)
+{
+	return ptr_set_bit(p4dp, KAISER_PGTABLE_SWITCH_BIT);
+}
+static inline p4d_t *native_get_normal_p4d(p4d_t *p4dp)
+{
+	return ptr_clear_bit(p4dp, KAISER_PGTABLE_SWITCH_BIT);
+}
+#endif /* CONFIG_KAISER */
+
+/*
+ * Page table pages are page-aligned.  The lower half of the top
+ * level is used for userspace and the top half for the kernel.
+ * This returns true for user pages that need to get copied into
+ * both the user and kernel copies of the page tables, and false
+ * for kernel pages that should only be in the kernel copy.
+ */
+static inline bool is_userspace_pgd(void *__ptr)
+{
+	unsigned long ptr = (unsigned long)__ptr;
+
+	return ((ptr % PAGE_SIZE) < (PAGE_SIZE / 2));
+}
+
 static inline void native_set_p4d(p4d_t *p4dp, p4d_t p4d)
 {
+#if defined(CONFIG_KAISER) && !defined(CONFIG_X86_5LEVEL)
+	/*
+	 * set_pgd() does not get called when we are running
+	 * CONFIG_X86_5LEVEL=y.  So, just hack around it.  We
+	 * know here that we have a p4d but that it is really at
+	 * the top level of the page tables; it is really just a
+	 * pgd.
+	 */
+	/* Do we need to also populate the shadow p4d? */
+	if (is_userspace_pgd(p4dp))
+		native_get_shadow_p4d(p4dp)->pgd = p4d.pgd;
+	/*
+	 * Even if the entry is *mapping* userspace, ensure
+	 * that userspace can not use it.  This way, if we
+	 * get out to userspace with the wrong CR3 value,
+	 * userspace will crash instead of running.
+	 */
+	if (!p4d.pgd.pgd)
+		p4dp->pgd.pgd = p4d.pgd.pgd | _PAGE_NX;
+#else /* CONFIG_KAISER */
 	*p4dp = p4d;
+#endif
 }
 
 static inline void native_p4d_clear(p4d_t *p4d)
@@ -146,7 +225,21 @@ static inline void native_p4d_clear(p4d_
 
 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
+#ifdef CONFIG_KAISER
+	/* Do we need to also populate the shadow pgd? */
+	if (is_userspace_pgd(pgdp))
+		native_get_shadow_pgd(pgdp)->pgd = pgd.pgd;
+	/*
+	 * Even if the entry is mapping userspace, ensure
+	 * that it is unusable for userspace.  This way,
+	 * if we get out to userspace with the wrong CR3
+	 * value, userspace will crash instead of running.
+	 */
+	if (!pgd_none(pgd))
+		pgdp->pgd = pgd.pgd | _PAGE_NX;
+#else /* CONFIG_KAISER */
 	*pgdp = pgd;
+#endif
 }
 
 static inline void native_pgd_clear(pgd_t *pgd)
diff -puN arch/x86/include/asm/pgtable.h~kaiser-base arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~kaiser-base	2017-11-10 11:22:09.011244950 -0800
+++ b/arch/x86/include/asm/pgtable.h	2017-11-10 11:22:09.032244950 -0800
@@ -1105,6 +1105,12 @@ static inline void pmdp_set_wrprotect(st
 static inline void clone_pgd_range(pgd_t *dst, pgd_t *src, int count)
 {
        memcpy(dst, src, count * sizeof(pgd_t));
+#ifdef CONFIG_KAISER
+	/* Clone the shadow pgd part as well */
+	memcpy(native_get_shadow_pgd(dst),
+	       native_get_shadow_pgd(src),
+	       count * sizeof(pgd_t));
+#endif
 }
 
 #define PTE_SHIFT ilog2(PTRS_PER_PTE)
diff -puN arch/x86/kernel/espfix_64.c~kaiser-base arch/x86/kernel/espfix_64.c
--- a/arch/x86/kernel/espfix_64.c~kaiser-base	2017-11-10 11:22:09.013244950 -0800
+++ b/arch/x86/kernel/espfix_64.c	2017-11-10 11:22:09.032244950 -0800
@@ -41,6 +41,7 @@
 #include <asm/pgalloc.h>
 #include <asm/setup.h>
 #include <asm/espfix.h>
+#include <asm/kaiser.h>
 
 /*
  * Note: we only need 6*8 = 48 bytes for the espfix stack, but round
@@ -128,6 +129,22 @@ void __init init_espfix_bsp(void)
 	pgd = &init_top_pgt[pgd_index(ESPFIX_BASE_ADDR)];
 	p4d = p4d_alloc(&init_mm, pgd, ESPFIX_BASE_ADDR);
 	p4d_populate(&init_mm, p4d, espfix_pud_page);
+	/*
+	 * Just copy the top-level PGD that is mapping the espfix
+	 * area to ensure it is mapped into the shadow user page
+	 * tables.
+	 *
+	 * For 5-level paging, we should have already populated
+	 * the espfix pgd when kaiser_init() pre-populated all
+	 * the pgd entries.  The above p4d_alloc() would never do
+	 * anything and the p4d_populate() would be done to a p4d
+	 * already mapped in the userspace pgd.
+	 */
+#ifdef CONFIG_KAISER
+	if (CONFIG_PGTABLE_LEVELS <= 4)
+		set_pgd(native_get_shadow_pgd(pgd),
+			__pgd(_KERNPG_TABLE | (p4d_pfn(*p4d) << PAGE_SHIFT)));
+#endif
 
 	/* Randomize the locations */
 	init_espfix_random();
diff -puN arch/x86/kernel/head_64.S~kaiser-base arch/x86/kernel/head_64.S
--- a/arch/x86/kernel/head_64.S~kaiser-base	2017-11-10 11:22:09.015244950 -0800
+++ b/arch/x86/kernel/head_64.S	2017-11-10 11:22:09.033244950 -0800
@@ -339,6 +339,14 @@ GLOBAL(early_recursion_flag)
 	.balign	PAGE_SIZE; \
 GLOBAL(name)
 
+#ifdef CONFIG_KAISER
+#define NEXT_PGD_PAGE(name) \
+	.balign 2 * PAGE_SIZE; \
+GLOBAL(name)
+#else
+#define NEXT_PGD_PAGE(name) NEXT_PAGE(name)
+#endif
+
 /* Automate the creation of 1 to 1 mapping pmd entries */
 #define PMDS(START, PERM, COUNT)			\
 	i = 0 ;						\
@@ -348,7 +356,7 @@ GLOBAL(name)
 	.endr
 
 	__INITDATA
-NEXT_PAGE(early_top_pgt)
+NEXT_PGD_PAGE(early_top_pgt)
 	.fill	511,8,0
 #ifdef CONFIG_X86_5LEVEL
 	.quad	level4_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
@@ -362,10 +370,10 @@ NEXT_PAGE(early_dynamic_pgts)
 	.data
 
 #ifndef CONFIG_XEN
-NEXT_PAGE(init_top_pgt)
+NEXT_PGD_PAGE(init_top_pgt)
 	.fill	512,8,0
 #else
-NEXT_PAGE(init_top_pgt)
+NEXT_PGD_PAGE(init_top_pgt)
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
 	.org    init_top_pgt + PGD_PAGE_OFFSET*8, 0
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
diff -puN arch/x86/kernel/traps.c~kaiser-base arch/x86/kernel/traps.c
--- a/arch/x86/kernel/traps.c~kaiser-base	2017-11-10 11:22:09.017244950 -0800
+++ b/arch/x86/kernel/traps.c	2017-11-10 11:22:09.033244950 -0800
@@ -329,6 +329,43 @@ __visible void __noreturn handle_stack_o
 }
 #endif
 
+/*
+ * This "fakes" a #GP from userspace upon returning (iret'ing)
+ * from this double fault.
+ */
+void setup_fake_gp_at_iret(struct pt_regs *regs)
+{
+	unsigned long *new_stack_top = (unsigned long *)
+		(this_cpu_read(cpu_tss.x86_tss.ist[0]) - 0x1500);
+
+	/*
+	 * Set up a stack just like the hardware would for a #GP.
+	 *
+	 * This format is an "iret frame", plus the error code
+	 * that the hardware puts on the stack for us for
+	 * exceptions.  (see struct pt_regs).
+	 */
+	new_stack_top[-1] = regs->ss;
+	new_stack_top[-2] = regs->sp;
+	new_stack_top[-3] = regs->flags;
+	new_stack_top[-4] = regs->cs;
+	new_stack_top[-5] = regs->ip;
+	new_stack_top[-6] = 0;	/* faked #GP error code */
+
+	/*
+	 * 'regs' points to the "iret frame" for *this*
+	 * exception, *not* the #GP we are faking.  Here,
+	 * we are telling 'iret' to jump to general_protection
+	 * when returning from this double fault.
+	 */
+	regs->ip = (unsigned long)general_protection;
+	/*
+	 * Make iret move the stack to the "fake #GP" stack
+	 * we created above.
+	 */
+	regs->sp = (unsigned long)&new_stack_top[-6];
+}
+
 #ifdef CONFIG_X86_64
 /* Runs on IST stack */
 dotraplinkage void do_double_fault(struct pt_regs *regs, long error_code)
@@ -354,14 +391,7 @@ dotraplinkage void do_double_fault(struc
 		regs->cs == __KERNEL_CS &&
 		regs->ip == (unsigned long)native_irq_return_iret)
 	{
-		struct pt_regs *normal_regs = task_pt_regs(current);
-
-		/* Fake a #GP(0) from userspace. */
-		memmove(&normal_regs->ip, (void *)regs->sp, 5*8);
-		normal_regs->orig_ax = 0;  /* Missing (lost) #GP error code */
-		regs->ip = (unsigned long)general_protection;
-		regs->sp = (unsigned long)&normal_regs->orig_ax;
-
+		setup_fake_gp_at_iret(regs);
 		return;
 	}
 #endif
diff -puN /dev/null arch/x86/mm/kaiser.c
--- /dev/null	2017-11-06 07:51:38.702108459 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-10 11:22:09.034244950 -0800
@@ -0,0 +1,423 @@
+/*
+ * Copyright(c) 2017 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * This code is based in part on work published here:
+ *
+ *	https://github.com/IAIK/KAISER
+ *
+ * The original work was written by and and signed off by for the Linux
+ * kernel by:
+ *
+ *   Signed-off-by: Richard Fellner <richard.fellner@student.tugraz.at>
+ *   Signed-off-by: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
+ *   Signed-off-by: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
+ *   Signed-off-by: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
+ *
+ * Major changes to the original code by: Dave Hansen <dave.hansen@intel.com>
+ */
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/bug.h>
+#include <linux/init.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/uaccess.h>
+
+#include <asm/kaiser.h>
+#include <asm/pgtable.h>
+#include <asm/pgalloc.h>
+#include <asm/tlbflush.h>
+#include <asm/desc.h>
+
+/*
+ * At runtime, the only things we map are some things for CPU
+ * hotplug, and stacks for new processes.  No two CPUs will ever
+ * be populating the same addresses, so we only need to ensure
+ * that we protect between two CPUs trying to allocate and
+ * populate the same page table page.
+ *
+ * Only take this lock when doing a set_p[4um]d(), but it is not
+ * needed for doing a set_pte().  We assume that only the *owner*
+ * of a given allocation will be doing this for _their_
+ * allocation.
+ *
+ * This ensures that once a system has been running for a while
+ * and there have been stacks all over and these page tables
+ * are fully populated, there will be no further acquisitions of
+ * this lock.
+ */
+static DEFINE_SPINLOCK(shadow_table_allocation_lock);
+
+/*
+ * This is only for walking kernel addresses.  We use it too help
+ * recreate the "shadow" page tables which are used while we are in
+ * userspace.
+ *
+ * This can be called on any kernel memory addresses and will work
+ * with any page sizes and any types: normal linear map memory,
+ * vmalloc(), even kmap().
+ *
+ * Note: this is only used when mapping new *kernel* entries into
+ * the user/shadow page tables.  It is never used for userspace
+ * addresses.
+ *
+ * Returns -1 on error.
+ */
+static inline unsigned long get_pa_from_kernel_map(unsigned long vaddr)
+{
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	/* We should only be asked to walk kernel addresses */
+	if (vaddr < PAGE_OFFSET) {
+		WARN_ON_ONCE(1);
+		return -1;
+	}
+
+	pgd = pgd_offset_k(vaddr);
+	/*
+	 * We made all the kernel PGDs present in kaiser_init().
+	 * We expect them to stay that way.
+	 */
+	if (pgd_none(*pgd)) {
+		WARN_ON_ONCE(1);
+		return -1;
+	}
+	/*
+	 * PGDs are either 512GB or 128TB on all x86_64
+	 * configurations.  We don't handle these.
+	 */
+	if (pgd_large(*pgd)) {
+		WARN_ON_ONCE(1);
+		return -1;
+	}
+
+	p4d = p4d_offset(pgd, vaddr);
+	if (p4d_none(*p4d)) {
+		WARN_ON_ONCE(1);
+		return -1;
+	}
+
+	pud = pud_offset(p4d, vaddr);
+	if (pud_none(*pud)) {
+		WARN_ON_ONCE(1);
+		return -1;
+	}
+
+	if (pud_large(*pud))
+		return (pud_pfn(*pud) << PAGE_SHIFT) | (vaddr & ~PUD_PAGE_MASK);
+
+	pmd = pmd_offset(pud, vaddr);
+	if (pmd_none(*pmd)) {
+		WARN_ON_ONCE(1);
+		return -1;
+	}
+
+	if (pmd_large(*pmd))
+		return (pmd_pfn(*pmd) << PAGE_SHIFT) | (vaddr & ~PMD_PAGE_MASK);
+
+	pte = pte_offset_kernel(pmd, vaddr);
+	if (pte_none(*pte)) {
+		WARN_ON_ONCE(1);
+		return -1;
+	}
+
+	return (pte_pfn(*pte) << PAGE_SHIFT) | (vaddr & ~PAGE_MASK);
+}
+
+/*
+ * Walk the shadow copy of the page tables (optionally) trying to
+ * allocate page table pages on the way down.  Does not support
+ * large pages since the data we are mapping is (generally) not
+ * large enough or aligned to 2MB.
+ *
+ * Note: this is only used when mapping *new* kernel data into the
+ * user/shadow page tables.  It is never used for userspace data.
+ *
+ * Returns a pointer to a PTE on success, or NULL on failure.
+ */
+#define KAISER_WALK_ATOMIC  0x1
+static pte_t *kaiser_shadow_pagetable_walk(unsigned long address,
+					   unsigned long flags)
+{
+	pte_t *pte;
+	pmd_t *pmd;
+	pud_t *pud;
+	p4d_t *p4d;
+	pgd_t *pgd = native_get_shadow_pgd(pgd_offset_k(address));
+	gfp_t gfp = (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO);
+
+	if (flags & KAISER_WALK_ATOMIC) {
+		gfp &= ~GFP_KERNEL;
+		gfp |= __GFP_HIGH | __GFP_ATOMIC;
+	}
+
+	if (address < PAGE_OFFSET) {
+		WARN_ONCE(1, "attempt to walk user address\n");
+		return NULL;
+	}
+
+	if (pgd_none(*pgd)) {
+		WARN_ONCE(1, "All shadow pgds should have been populated\n");
+		return NULL;
+	}
+	BUILD_BUG_ON(pgd_large(*pgd) != 0);
+
+	p4d = p4d_offset(pgd, address);
+	BUILD_BUG_ON(p4d_large(*p4d) != 0);
+	if (p4d_none(*p4d)) {
+		unsigned long new_pud_page = __get_free_page(gfp);
+		if (!new_pud_page)
+			return NULL;
+
+		spin_lock(&shadow_table_allocation_lock);
+		if (p4d_none(*p4d))
+			set_p4d(p4d, __p4d(_KERNPG_TABLE | __pa(new_pud_page)));
+		else
+			free_page(new_pud_page);
+		spin_unlock(&shadow_table_allocation_lock);
+	}
+
+	pud = pud_offset(p4d, address);
+	/* The shadow page tables do not use large mappings: */
+	if (pud_large(*pud)) {
+		WARN_ON(1);
+		return NULL;
+	}
+	if (pud_none(*pud)) {
+		unsigned long new_pmd_page = __get_free_page(gfp);
+		if (!new_pmd_page)
+			return NULL;
+
+		spin_lock(&shadow_table_allocation_lock);
+		if (pud_none(*pud))
+			set_pud(pud, __pud(_KERNPG_TABLE | __pa(new_pmd_page)));
+		else
+			free_page(new_pmd_page);
+		spin_unlock(&shadow_table_allocation_lock);
+	}
+
+	pmd = pmd_offset(pud, address);
+	/* The shadow page tables do not use large mappings: */
+	if (pmd_large(*pmd)) {
+		WARN_ON(1);
+		return NULL;
+	}
+	if (pmd_none(*pmd)) {
+		unsigned long new_pte_page = __get_free_page(gfp);
+		if (!new_pte_page)
+			return NULL;
+
+		spin_lock(&shadow_table_allocation_lock);
+		if (pmd_none(*pmd))
+			set_pmd(pmd, __pmd(_KERNPG_TABLE  | __pa(new_pte_page)));
+		else
+			free_page(new_pte_page);
+		spin_unlock(&shadow_table_allocation_lock);
+	}
+
+	pte = pte_offset_kernel(pmd, address);
+	if (pte_flags(*pte) & _PAGE_USER) {
+		WARN_ONCE(1, "attempt to walk to user pte\n");
+		return NULL;
+	}
+	return pte;
+}
+
+/*
+ * Given a kernel address, @__start_addr, copy that mapping into
+ * the user (shadow) page tables.  This may need to allocate page
+ * table pages.
+ */
+int kaiser_add_user_map(const void *__start_addr, unsigned long size,
+			unsigned long flags)
+{
+	pte_t *pte;
+	unsigned long start_addr = (unsigned long)__start_addr;
+	unsigned long address = start_addr & PAGE_MASK;
+	unsigned long end_addr = PAGE_ALIGN(start_addr + size);
+	unsigned long target_address;
+
+	for (; address < end_addr; address += PAGE_SIZE) {
+		target_address = get_pa_from_kernel_map(address);
+		if (target_address == -1)
+			return -EIO;
+
+		pte = kaiser_shadow_pagetable_walk(address, false);
+		/*
+		 * Errors come from either -ENOMEM for a page
+		 * table page, or something screwy that did a
+		 * WARN_ON().  Just return -ENOMEM.
+		 */
+		if (!pte)
+			return -ENOMEM;
+		if (pte_none(*pte)) {
+			set_pte(pte, __pte(flags | target_address));
+		} else {
+			pte_t tmp;
+			set_pte(&tmp, __pte(flags | target_address));
+			WARN_ON_ONCE(!pte_same(*pte, tmp));
+		}
+	}
+	return 0;
+}
+
+int kaiser_add_user_map_ptrs(const void *__start_addr,
+			     const void *__end_addr,
+			     unsigned long flags)
+{
+	return kaiser_add_user_map(__start_addr,
+				   __end_addr - __start_addr,
+				   flags);
+}
+
+/*
+ * Ensure that the top level of the (shadow) page tables are
+ * entirely populated.  This ensures that all processes that get
+ * forked have the same entries.  This way, we do not have to
+ * ever go set up new entries in older processes.
+ *
+ * Note: we never free these, so there are no updates to them
+ * after this.
+ */
+static void __init kaiser_init_all_pgds(void)
+{
+	pgd_t *pgd;
+	int i = 0;
+
+	pgd = native_get_shadow_pgd(pgd_offset_k(0UL));
+	for (i = PTRS_PER_PGD / 2; i < PTRS_PER_PGD; i++) {
+		unsigned long addr = PAGE_OFFSET + i * PGDIR_SIZE;
+#if CONFIG_PGTABLE_LEVELS > 4
+		p4d_t *p4d = p4d_alloc_one(&init_mm, addr);
+		if (!p4d) {
+			WARN_ON(1);
+			break;
+		}
+		set_pgd(pgd + i, __pgd(_KERNPG_TABLE | __pa(p4d)));
+#else /* CONFIG_PGTABLE_LEVELS <= 4 */
+		pud_t *pud = pud_alloc_one(&init_mm, addr);
+		if (!pud) {
+			WARN_ON(1);
+			break;
+		}
+		set_pgd(pgd + i, __pgd(_KERNPG_TABLE | __pa(pud)));
+#endif /* CONFIG_PGTABLE_LEVELS */
+	}
+}
+
+/*
+ * The page table allocations in here can theoretically fail, but
+ * we can not do much about it in early boot.  Do the checking
+ * and warning in a macro to make it more readable.
+ */
+#define kaiser_add_user_map_early(start, size, flags) do {	\
+	int __ret = kaiser_add_user_map(start, size, flags);	\
+	WARN_ON(__ret);						\
+} while (0)
+
+#define kaiser_add_user_map_ptrs_early(start, end, flags) do {		\
+	int __ret = kaiser_add_user_map_ptrs(start, end, flags);	\
+	WARN_ON(__ret);							\
+} while (0)
+
+extern char __per_cpu_user_mapped_start[], __per_cpu_user_mapped_end[];
+/*
+ * If anything in here fails, we will likely die on one of the
+ * first kernel->user transitions and init will die.  But, we
+ * will have most of the kernel up by then and should be able to
+ * get a clean warning out of it.  If we BUG_ON() here, we run
+ * the risk of being before we have good console output.
+ *
+ * When KAISER is enabled, we remove _PAGE_GLOBAL from all of the
+ * kernel PTE permissions.  This ensures that the TLB entries for
+ * the kernel are not available when in userspace.  However, for
+ * the pages that are available to userspace *anyway*, we might as
+ * well continue to map them _PAGE_GLOBAL and enjoy the potential
+ * performance advantages.
+ */
+void __init kaiser_init(void)
+{
+	int cpu;
+
+	kaiser_init_all_pgds();
+
+	for_each_possible_cpu(cpu) {
+		void *percpu_vaddr = __per_cpu_user_mapped_start +
+				     per_cpu_offset(cpu);
+		unsigned long percpu_sz = __per_cpu_user_mapped_end -
+					  __per_cpu_user_mapped_start;
+		kaiser_add_user_map_early(percpu_vaddr, percpu_sz,
+					  __PAGE_KERNEL | _PAGE_GLOBAL);
+	}
+
+	kaiser_add_user_map_ptrs_early(__entry_text_start, __entry_text_end,
+				       __PAGE_KERNEL_RX | _PAGE_GLOBAL);
+
+	/* the fixed map address of the idt_table */
+	kaiser_add_user_map_early((void *)idt_descr.address,
+				  sizeof(gate_desc) * NR_VECTORS,
+				  __PAGE_KERNEL_RO | _PAGE_GLOBAL);
+}
+
+int kaiser_add_mapping(unsigned long addr, unsigned long size,
+		       unsigned long flags)
+{
+	return kaiser_add_user_map((const void *)addr, size, flags);
+}
+
+void kaiser_remove_mapping(unsigned long start, unsigned long size)
+{
+	unsigned long addr;
+
+	/* The shadow page tables always use small pages: */
+	for (addr = start; addr < start + size; addr += PAGE_SIZE) {
+		/*
+		 * Do an "atomic" walk in case this got called from an atomic
+		 * context.  This should not do any allocations because we
+		 * should only be walking things that are known to be mapped.
+		 */
+		pte_t *pte = kaiser_shadow_pagetable_walk(addr, KAISER_WALK_ATOMIC);
+
+		/*
+		 * We are removing a mapping that should
+		 * exist.  WARN if it was not there:
+		 */
+		if (!pte) {
+			WARN_ON_ONCE(1);
+			continue;
+		}
+
+		pte_clear(&init_mm, addr, pte);
+	}
+	/*
+	 * This ensures that the TLB entries used to map this data are
+	 * no longer usable on *this* CPU.  We theoretically want to
+	 * flush the entries on all CPUs here, but that's too
+	 * expensive right now: this is called to unmap process
+	 * stacks in the exit() path path.
+	 *
+	 * This can change if we get to the point where this is not
+	 * in a remotely hot path, like only called via write_ldt().
+	 *
+	 * Note: we could probably also just invalidate the individual
+	 * addresses to take care of *this* PCID and then do a
+	 * tlb_flush_shared_nonglobals() to ensure that all other
+	 * PCIDs get flushed before being used again.
+	 */
+	__native_flush_tlb_global();
+}
diff -puN arch/x86/mm/Makefile~kaiser-base arch/x86/mm/Makefile
--- a/arch/x86/mm/Makefile~kaiser-base	2017-11-10 11:22:09.019244950 -0800
+++ b/arch/x86/mm/Makefile	2017-11-10 11:22:09.034244950 -0800
@@ -45,6 +45,7 @@ obj-$(CONFIG_NUMA_EMU)		+= numa_emulatio
 obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
 obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
 obj-$(CONFIG_RANDOMIZE_MEMORY) += kaslr.o
+obj-$(CONFIG_KAISER)		+= kaiser.o
 
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
diff -puN arch/x86/mm/pageattr.c~kaiser-base arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~kaiser-base	2017-11-10 11:22:09.020244950 -0800
+++ b/arch/x86/mm/pageattr.c	2017-11-10 11:22:09.035244950 -0800
@@ -859,7 +859,7 @@ static void unmap_pmd_range(pud_t *pud,
 			pud_clear(pud);
 }
 
-static void unmap_pud_range(p4d_t *p4d, unsigned long start, unsigned long end)
+void unmap_pud_range(p4d_t *p4d, unsigned long start, unsigned long end)
 {
 	pud_t *pud = pud_offset(p4d, start);
 
diff -puN arch/x86/mm/pgtable.c~kaiser-base arch/x86/mm/pgtable.c
--- a/arch/x86/mm/pgtable.c~kaiser-base	2017-11-10 11:22:09.022244950 -0800
+++ b/arch/x86/mm/pgtable.c	2017-11-10 11:22:09.035244950 -0800
@@ -354,14 +354,26 @@ static inline void _pgd_free(pgd_t *pgd)
 		kmem_cache_free(pgd_cache, pgd);
 }
 #else
+
+#ifdef CONFIG_KAISER
+/*
+ * Instead of one pgd, we aquire two pgds.  Being order-1, it is
+ * both 8k in size and 8k-aligned.  That lets us just flip bit 12
+ * in a pointer to swap between the two 4k halves.
+ */
+#define PGD_ALLOCATION_ORDER 1
+#else
+#define PGD_ALLOCATION_ORDER 0
+#endif
+
 static inline pgd_t *_pgd_alloc(void)
 {
-	return (pgd_t *)__get_free_page(PGALLOC_GFP);
+	return (pgd_t *)__get_free_pages(PGALLOC_GFP, PGD_ALLOCATION_ORDER);
 }
 
 static inline void _pgd_free(pgd_t *pgd)
 {
-	free_page((unsigned long)pgd);
+	free_pages((unsigned long)pgd, PGD_ALLOCATION_ORDER);
 }
 #endif /* CONFIG_X86_PAE */
 
diff -puN /dev/null Documentation/x86/kaiser.txt
--- /dev/null	2017-11-06 07:51:38.702108459 -0800
+++ b/Documentation/x86/kaiser.txt	2017-11-10 11:22:09.035244950 -0800
@@ -0,0 +1,160 @@
+Overview
+========
+
+KAISER is a countermeasure against attacks on kernel address
+information.  There are at least three existing, published,
+approaches using the shared user/kernel mapping and hardware features
+to defeat KASLR.  One approach referenced in the paper locates the
+kernel by observing differences in page fault timing between
+present-but-inaccessable kernel pages and non-present pages.
+
+When we enter the kernel via syscalls, interrupts or exceptions,
+page tables are switched to the full "kernel" copy.  When the
+system switches back to user mode, the user/shadow copy is used.
+
+The minimalistic kernel portion of the user page tables try to
+map only what is needed to enter/exit the kernel such as the
+entry/exit functions themselves and the interrupt descriptor
+table (IDT).
+
+This helps ensure that side-channel attacks that leverage the
+paging structures do not function when KAISER is enabled.  It
+can be enabled by setting CONFIG_KAISER=y
+
+Page Table Management
+=====================
+
+KAISER logically keeps a "copy" of the page tables which unmap
+the kernel while in userspace.  The kernel manages the page
+tables as normal, but the "copying" is done with a few tricks
+that mean that we do not have to manage two full copies.
+
+The first trick is that for any any new kernel mapping, we
+presume that we do not want it mapped to userspace.  That means
+we normally have no copying to do.  We only copy the kernel
+entries over to the shadow in response to a kaiser_add_*()
+call which is rare.
+
+For a new userspace mapping, the kernel makes the entries in
+its page tables like normal.  The only difference is when the
+kernel makes entries in the top (PGD) level.  In addition to
+setting the entry in the main kernel PGD, a copy if the entry
+is made in the shadow PGD.
+
+PGD entries always point to another page table.  Two PGD
+entries pointing to the same thing gives us shared page tables
+for all the lower entries.  This leaves a single, shared set of
+userspace page tables to manage.  One PTE to lock, one set set
+of accessed bits, dirty bits, etc...
+
+Overhead
+========
+
+Protection against side-channel attacks is important.  But,
+this protection comes at a cost:
+
+1. Increased Memory Use
+  a. Each process now needs an order-1 PGD instead of order-0.
+     (Consumes 4k per process).
+  b. The pre-allocated second-level (p4d or pud) kernel page
+     table pages cost ~1MB of additional memory at boot.  This
+     is not totally wasted because some of these pages would
+     have been needed eventually for normal kernel page tables
+     and things in the vmalloc() area like vmemmap[].
+  c. Statically-allocated structures and entry/exit text must
+     be padded out to 4k (or 8k for PGDs) so they can be mapped
+     into the user page tables.  This bloats the kernel image
+     by ~20-30k.
+  d. The shadow page tables eventually grow to map all of used
+     vmalloc() space.  They can have roughly the same memory
+     consumption as the vmalloc() page tables.
+
+2. Runtime Cost
+  a. CR3 manipulation to switch between the page table copies
+     must be done at interrupt, syscall, and exception entry
+     and exit (it can be skipped when the kernel is interrupted,
+     though.)  Moves to CR3 are on the order of a hundred
+     cycles, and we need one at entry and another at exit.
+  b. Task stacks must be mapped/unmapped.  We need to walk
+     and modify the shadow page tables at fork() and exit().
+  c. Global pages are disabled.  This feature of the MMU
+     allows different processes to share TLB entries mapping
+     the kernel.  Losing the feature means potentially more
+     TLB misses after a context switch.
+  d. Process Context IDentifiers (PCID) is a CPU feature that
+     allows us to skip flushing the entire TLB when we switch
+     the page tables.  This makes switching the page tables
+     (at context switch, or kernel entry/exit) cheaper.  But,
+     on systems with PCID support, the context switch code
+     must flush both the user and kernel entries out of the
+     TLB, with an INVPCID in addition to the CR3 write.  This
+     INVPCID is generally slower than a CR3 write, but still
+     on the order of a hundred cycles.
+  e. The shadow page tables must be populated for each new
+     process.  Even without KAISER, since we share all of the
+     kernel mappings in all processes, we can do all this
+     population for kernel addresses at the top level of the
+     page tables (the PGD level).  But, with KAISER, we now
+     have *two* kernel mappings: one in the kernel page tables
+     that maps everything and one in the user/shadow page
+     tables mapping the "minimal" kernel.  At fork(), we
+     copy the portion of the shadow PGD that maps the minimal
+     kernel structures in addition to the normal kernel one.
+  f. In addition to the fork()-time copying, we must also
+     update the shadow PGD any time a set_pgd() is done on a
+     PGD used to map userspace.  This ensures that the kernel
+     and user/shadow copies always map the same userspace
+     memory.
+  g. On systems without PCID support, each CR3 write flushes
+     the entire TLB.  That means that each syscall, interrupt
+     or exception flushes the TLB.
+
+Possible Future Work:
+1. We can be more careful about not actually writing to CR3
+   unless we actually switch it.
+2. Try to have dedicated entry/exit kernel stacks so we do
+   not have to map/unmap the task/thread stacks.
+3. Compress the user/shadow-mapped data to be mapped together
+   underneath a single PGD entry.
+4. Re-enable global pages, but use them for mappings in the
+   user/shadow page tables.  This would allow the kernel to
+   take advantage of TLB entries that were established from
+   the user page tables.  This might speed up the entry/exit
+   code or userspace since it will not have to reload all of
+   its TLB entries.  However, its upside is limited by PCID
+   being used.
+5. Allow KAISER to enabled/disabled at runtime so folks can
+   run a single kernel image.
+
+Debugging:
+
+Bugs in KAISER cause a few different signatures of crashes
+that are worth noting here.
+
+ * Crashes in early boot, especially around CPU bringup.  Bugs
+   in the trampoline code or mappings cause these.
+ * Crashes at the first interrupt.  Caused by bugs in entry_64.S,
+   like screwing up a page table switch.  Also caused by
+   incorrectly mapping the IRQ handler entry code.
+ * Crashes at the first NMI.  The NMI code is separate from main
+   interrupt handlers and can have bugs that do not affect
+   normal interrupts.  Also caused by incorrectly mapping NMI
+   code.  NMIs that interrupt the entry code must be very
+   careful and can be the cause of crashes that show up when
+   running perf.
+ * Kernel crashes at the first exit to userspace.  entry_64.S
+   bugs, or failing to map some of the exit code.
+ * Crashes at first interrupt that interrupts userspace. The paths
+   in entry_64.S that return to userspace are sometimes separate
+   from the ones that return to the kernel.
+ * Double faults: overflowing the kernel stack because of page
+   faults upon page faults.  Caused by touching non-kaiser-mapped
+   data in the entry code, or forgetting to switch to kernel
+   CR3 before calling into C functions which are not kaiser-mapped.
+ * Failures of the selftests/x86 code.  Usually a bug in one of the
+   more obscure corners of entry_64.S
+ * Userspace segfaults early in boot, sometimes manifesting
+   as mount(8) failing to mount the rootfs.  These have
+   tended to be TLB invalidation issues.  Usually invalidating
+   the wrong PCID, or otherwise missing an invalidation.
+
diff -puN /dev/null include/linux/kaiser.h
--- /dev/null	2017-11-06 07:51:38.702108459 -0800
+++ b/include/linux/kaiser.h	2017-11-10 11:22:09.036244950 -0800
@@ -0,0 +1,29 @@
+#ifndef _INCLUDE_KAISER_H
+#define _INCLUDE_KAISER_H
+
+#ifdef CONFIG_KAISER
+#include <asm/kaiser.h>
+#else
+
+/*
+ * These stubs are used whenever CONFIG_KAISER is off, which
+ * includes architectures that support KAISER, but have it
+ * disabled.
+ */
+
+static inline void kaiser_init(void)
+{
+}
+
+static inline void kaiser_remove_mapping(unsigned long start, unsigned long size)
+{
+}
+
+static inline int kaiser_add_mapping(unsigned long addr, unsigned long size,
+				     unsigned long flags)
+{
+	return 0;
+}
+
+#endif /* !CONFIG_KAISER */
+#endif /* _INCLUDE_KAISER_H */
diff -puN init/main.c~kaiser-base init/main.c
--- a/init/main.c~kaiser-base	2017-11-10 11:22:09.025244950 -0800
+++ b/init/main.c	2017-11-10 11:22:09.036244950 -0800
@@ -75,6 +75,7 @@
 #include <linux/slab.h>
 #include <linux/perf_event.h>
 #include <linux/ptrace.h>
+#include <linux/kaiser.h>
 #include <linux/blkdev.h>
 #include <linux/elevator.h>
 #include <linux/sched_clock.h>
@@ -504,6 +505,8 @@ static void __init mm_init(void)
 	pgtable_init();
 	vmalloc_init();
 	ioremap_huge_init();
+	/* This just needs to be done before we first run userspace: */
+	kaiser_init();
 }
 
 asmlinkage __visible void __init start_kernel(void)
diff -puN kernel/fork.c~kaiser-base kernel/fork.c
--- a/kernel/fork.c~kaiser-base	2017-11-10 11:22:09.027244950 -0800
+++ b/kernel/fork.c	2017-11-10 11:22:09.037244950 -0800
@@ -70,6 +70,7 @@
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
 #include <linux/freezer.h>
+#include <linux/kaiser.h>
 #include <linux/delayacct.h>
 #include <linux/taskstats_kern.h>
 #include <linux/random.h>
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
