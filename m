Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7900C6B0295
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:36:30 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s9so1692593pfe.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:36:30 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z79si16382985pfa.116.2017.11.22.16.36.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:36:29 -0800 (PST)
Subject: [PATCH 22/23] x86, kaiser: allow KAISER to be enabled/disabled at runtime
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:35:23 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003523.28FFBAB6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The KAISER CR3 switches are expensive for many reasons.  Not all systems
benefit from the protection provided by KAISER.  Some of them can not
pay the high performance cost.

This patch adds a debugfs file.  To disable KAISER, you do:

	echo 0 > /sys/kernel/debug/x86/kaiser-enabled

and to re-enable it, you can:

	echo 1 > /sys/kernel/debug/x86/kaiser-enabled

This is a *minimal* implementation.  There are certainly plenty of
optimizations that can be done on top of this by using ALTERNATIVES
among other things.

This does, however, completely remove all the KAISER-based CR3 writes.
This permits a paravirtualized system that can not tolerate CR3
writes to theoretically survive with CONFIG_KAISER=y, albeit with
/sys/kernel/debug/x86/kaiser-enabled=0.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/entry/calling.h |   12 +++++++
 b/arch/x86/mm/kaiser.c     |   70 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 78 insertions(+), 4 deletions(-)

diff -puN arch/x86/entry/calling.h~kaiser-dynamic-asm arch/x86/entry/calling.h
--- a/arch/x86/entry/calling.h~kaiser-dynamic-asm	2017-11-22 15:45:56.402619721 -0800
+++ b/arch/x86/entry/calling.h	2017-11-22 15:45:56.407619721 -0800
@@ -209,19 +209,29 @@ For 32-bit we have the following convent
 	orq     $(KAISER_SWITCH_MASK), \reg
 .endm
 
+.macro JUMP_IF_KAISER_OFF	label
+	testq   $1, kaiser_asm_do_switch
+	jz      \label
+.endm
+
 .macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
+	JUMP_IF_KAISER_OFF	.Lswitch_done_\@
 	mov	%cr3, \scratch_reg
 	ADJUST_KERNEL_CR3 \scratch_reg
 	mov	\scratch_reg, %cr3
+.Lswitch_done_\@:
 .endm
 
 .macro SWITCH_TO_USER_CR3 scratch_reg:req
+	JUMP_IF_KAISER_OFF	.Lswitch_done_\@
 	mov	%cr3, \scratch_reg
 	ADJUST_USER_CR3 \scratch_reg
 	mov	\scratch_reg, %cr3
+.Lswitch_done_\@:
 .endm
 
 .macro SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg:req save_reg:req
+	JUMP_IF_KAISER_OFF	.Ldone_\@
 	movq	%cr3, %r\scratch_reg
 	movq	%r\scratch_reg, \save_reg
 	/*
@@ -244,11 +254,13 @@ For 32-bit we have the following convent
 .endm
 
 .macro RESTORE_CR3 save_reg:req
+	JUMP_IF_KAISER_OFF	.Ldone_\@
 	/*
 	 * The CR3 write could be avoided when not changing its value,
 	 * but would require a CR3 read *and* a scratch register.
 	 */
 	movq	\save_reg, %cr3
+.Ldone_\@:
 .endm
 
 #else /* CONFIG_KAISER=n: */
diff -puN arch/x86/mm/kaiser.c~kaiser-dynamic-asm arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-dynamic-asm	2017-11-22 15:45:56.404619721 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-22 15:45:56.408619721 -0800
@@ -43,6 +43,9 @@
 
 #define KAISER_WALK_ATOMIC  0x1
 
+__aligned(PAGE_SIZE)
+unsigned long kaiser_asm_do_switch[PAGE_SIZE/sizeof(unsigned long)] = { 1 };
+
 /*
  * At runtime, the only things we map are some things for CPU
  * hotplug, and stacks for new processes.  No two CPUs will ever
@@ -395,6 +398,9 @@ void __init kaiser_init(void)
 
 	kaiser_init_all_pgds();
 
+	kaiser_add_user_map_early(&kaiser_asm_do_switch, PAGE_SIZE,
+				  __PAGE_KERNEL | _PAGE_GLOBAL);
+
 	for_each_possible_cpu(cpu) {
 		void *percpu_vaddr = __per_cpu_user_mapped_start +
 				     per_cpu_offset(cpu);
@@ -483,6 +489,56 @@ static ssize_t kaiser_enabled_read_file(
 	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
 }
 
+enum poison {
+	KAISER_POISON,
+	KAISER_UNPOISON
+};
+void kaiser_poison_pgds(enum poison do_poison);
+
+void kaiser_do_disable(void)
+{
+	/* Make sure the kernel PGDs are usable by userspace: */
+	kaiser_poison_pgds(KAISER_UNPOISON);
+
+	/*
+	 * Make sure all the CPUs have the poison clear in their TLBs.
+	 * This also functions as a barrier to ensure that everyone
+	 * sees the unpoisoned PGDs.
+	 */
+	flush_tlb_all();
+
+	/* Tell the assembly code to stop switching CR3. */
+	kaiser_asm_do_switch[0] = 0;
+
+	/*
+	 * Make sure everybody does an interrupt.  This means that
+	 * they have gone through a SWITCH_TO_KERNEL_CR3 amd are no
+	 * longer running on the userspace CR3.  If we did not do
+	 * this, we might have CPUs running on the shadow page tables
+	 * that then enter the kernel and think they do *not* need to
+	 * switch.
+	 */
+	flush_tlb_all();
+}
+
+void kaiser_do_enable(void)
+{
+	/* Tell the assembly code to start switching CR3: */
+	kaiser_asm_do_switch[0] = 1;
+
+	/* Make sure everyone can see the kaiser_asm_do_switch update: */
+	synchronize_rcu();
+
+	/*
+	 * Now that userspace is no longer using the kernel copy of
+	 * the page tables, we can poison it:
+	 */
+	kaiser_poison_pgds(KAISER_POISON);
+
+	/* Make sure all the CPUs see the poison: */
+	flush_tlb_all();
+}
+
 static ssize_t kaiser_enabled_write_file(struct file *file,
 		 const char __user *user_buf, size_t count, loff_t *ppos)
 {
@@ -504,7 +560,17 @@ static ssize_t kaiser_enabled_write_file
 	if (kaiser_enabled == enable)
 		return count;
 
+	/*
+	 * This tells the page table code to stop poisoning PGDs
+	 */
 	WRITE_ONCE(kaiser_enabled, enable);
+	synchronize_rcu();
+
+	if (enable)
+		kaiser_do_enable();
+	else
+		kaiser_do_disable();
+
 	return count;
 }
 
@@ -522,10 +588,6 @@ static int __init create_kaiser_enabled(
 }
 late_initcall(create_kaiser_enabled);
 
-enum poison {
-	KAISER_POISON,
-	KAISER_UNPOISON
-};
 void kaiser_poison_pgd_page(pgd_t *pgd_page, enum poison do_poison)
 {
 	int i = 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
