Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09EF26B0295
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:30:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x21-v6so5800041eds.2
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:30:23 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 5-v6si1636630edo.397.2018.07.11.04.30.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 04:30:22 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 39/39] x86/entry/32: Add debug code to check entry/exit cr3
Date: Wed, 11 Jul 2018 13:29:46 +0200
Message-Id: <1531308586-29340-40-git-send-email-joro@8bytes.org>
In-Reply-To: <1531308586-29340-1-git-send-email-joro@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Add a config option that enabled code to check that we enter
and leave the kernel with the correct cr3. This is needed
because we have no NX protection of user-addresses in the
kernel-cr3 on x86-32 and wouldn't notice that type of bug
otherwise.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/Kconfig.debug    | 12 ++++++++++++
 arch/x86/entry/entry_32.S | 43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+)

diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug
index c6dd1d9..6eaca2d 100644
--- a/arch/x86/Kconfig.debug
+++ b/arch/x86/Kconfig.debug
@@ -340,6 +340,18 @@ config X86_DEBUG_FPU
 
 	  If unsure, say N.
 
+config X86_DEBUG_ENTRY_CR3
+	bool	"Debug CR3 for Kernel entry/exit"
+	depends on X86_32 && PAGE_TABLE_ISOLATION
+	help
+	  Add instructions to the x86-32 entry code to check whether the kernel
+	  is entered and left with the correct CR3. When PTI is enabled, this
+	  checks whether we enter the kernel with the user-space cr3 when
+	  coming from user-mode and if we leave with user-cr3 back to
+	  user-space.
+
+	  If unsure, say N.
+
 config PUNIT_ATOM_DEBUG
 	tristate "ATOM Punit debug driver"
 	depends on PCI
diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index a368583..d8d9a54 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -166,6 +166,24 @@
 .Lend_\@:
 .endm
 
+.macro BUG_IF_WRONG_CR3 no_user_check=0
+#ifdef CONFIG_X86_DEBUG_ENTRY_CR3
+	ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
+	.if \no_user_check == 0
+	/* coming from usermode? */
+	testl	$SEGMENT_RPL_MASK, PT_CS(%esp)
+	jz	.Lend_\@
+	.endif
+	/* On user-cr3? */
+	movl	%cr3, %eax
+	testl	$PTI_SWITCH_MASK, %eax
+	jnz	.Lend_\@
+	/* From userspace with kernel cr3 - BUG */
+	ud2
+.Lend_\@:
+#endif
+.endm
+
 /*
  * Switch to kernel cr3 if not already loaded and return current cr3 in
  * \scratch_reg
@@ -218,6 +236,8 @@
 .macro SAVE_ALL_NMI cr3_reg:req
 	SAVE_ALL
 
+	BUG_IF_WRONG_CR3
+
 	/*
 	 * Now switch the CR3 when PTI is enabled.
 	 *
@@ -229,6 +249,7 @@
 
 .Lend_\@:
 .endm
+
 /*
  * This is a sneaky trick to help the unwinder find pt_regs on the stack.  The
  * frame pointer is replaced with an encoded pointer to pt_regs.  The encoding
@@ -292,6 +313,8 @@
 
 .Lswitched_\@:
 
+	BUG_IF_WRONG_CR3
+
 	RESTORE_REGS pop=\pop
 .endm
 
@@ -362,6 +385,8 @@
 
 	ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
 
+	BUG_IF_WRONG_CR3
+
 	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
 
 	/*
@@ -803,6 +828,7 @@ ENTRY(entry_SYSENTER_32)
 	 */
 	pushfl
 	pushl	%eax
+	BUG_IF_WRONG_CR3 no_user_check=1
 	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
 	popl	%eax
 	popfl
@@ -897,6 +923,7 @@ ENTRY(entry_SYSENTER_32)
 	 * whereas POPF does not.)
 	 */
 	btrl	$X86_EFLAGS_IF_BIT, (%esp)
+	BUG_IF_WRONG_CR3 no_user_check=1
 	popfl
 	popl	%eax
 
@@ -974,6 +1001,8 @@ restore_all:
 	/* Switch back to user CR3 */
 	SWITCH_TO_USER_CR3 scratch_reg=%eax
 
+	BUG_IF_WRONG_CR3
+
 	/* Restore user state */
 	RESTORE_REGS pop=4			# skip orig_eax/error_code
 .Lirq_return:
@@ -987,6 +1016,7 @@ restore_all:
 restore_all_kernel:
 	TRACE_IRQS_IRET
 	PARANOID_EXIT_TO_KERNEL_MODE
+	BUG_IF_WRONG_CR3
 	RESTORE_REGS 4
 	jmp	.Lirq_return
 
@@ -994,6 +1024,19 @@ restore_all_kernel:
 ENTRY(iret_exc	)
 	pushl	$0				# no error code
 	pushl	$do_iret_error
+
+#ifdef CONFIG_X86_DEBUG_ENTRY_CR3
+	/*
+	 * The stack-frame here is the one that iret faulted on, so its a
+	 * return-to-user frame. We are on kernel-cr3 because we come here from
+	 * the fixup code. This confuses the CR3 checker, so switch to user-cr3
+	 * as the checker expects it.
+	 */
+	pushl	%eax
+	SWITCH_TO_USER_CR3 scratch_reg=%eax
+	popl	%eax
+#endif
+
 	jmp	common_exception
 .previous
 	_ASM_EXTABLE(.Lirq_return, iret_exc)
-- 
2.7.4
