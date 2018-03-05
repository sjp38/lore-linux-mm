Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB216B0271
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:27:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c142so4407481wmh.4
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:27:51 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id o4si1048635edd.392.2018.03.05.02.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:14 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 13/34] x86/entry/32: Add PTI cr3 switches to NMI handler code
Date: Mon,  5 Mar 2018 11:25:42 +0100
Message-Id: <1520245563-8444-14-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The NMI handler is special, as it needs to leave with the
same cr3 as it was entered with. We need to do this because
we could enter the NMI handler from kernel code with
user-cr3 already loaded.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 52 +++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 46 insertions(+), 6 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index b1a5f34ee..35379e5 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -77,6 +77,8 @@
 #endif
 .endm
 
+#define PTI_SWITCH_MASK         (1 << PAGE_SHIFT)
+
 /*
  * User gs save/restore
  *
@@ -167,8 +169,30 @@
 
 .endm
 
-.macro SAVE_ALL_NMI
+.macro SAVE_ALL_NMI cr3_reg:req
 	SAVE_ALL
+
+	/*
+	 * Now switch the CR3 when PTI is enabled.
+	 *
+	 * We can enter with either user or kernel cr3, the code will
+	 * store the old cr3 in \cr3_reg and switches to the kernel cr3
+	 * if necessary.
+	 */
+	ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
+
+	movl	%cr3, \cr3_reg
+	testl	$PTI_SWITCH_MASK, \cr3_reg
+	jz	.Lend_\@	/* Already on kernel cr3 */
+
+	/* On user cr3 - write new kernel cr3 */
+	andl	$(~PTI_SWITCH_MASK), \cr3_reg
+	movl	\cr3_reg, %cr3
+
+	/* Restore user cr3 value */
+	orl	$PTI_SWITCH_MASK, \cr3_reg
+
+.Lend_\@:
 .endm
 /*
  * This is a sneaky trick to help the unwinder find pt_regs on the stack.  The
@@ -227,13 +251,29 @@
 	RESTORE_SKIP_SEGMENTS \pop
 .endm
 
-.macro RESTORE_ALL_NMI pop=0
+.macro RESTORE_ALL_NMI cr3_reg:req pop=0
 	/*
 	 * Restore segments - might cause exceptions when loading
 	 * user-space segments
 	 */
 	RESTORE_SEGMENTS
 
+	/*
+	 * Now switch the CR3 when PTI is enabled.
+	 *
+	 * We enter with kernel cr3 and switch the cr3 to the value
+	 * stored on \cr3_reg, which is either a user or a kernel cr3.
+	 */
+	ALTERNATIVE "jmp .Lswitched_\@", "", X86_FEATURE_PTI
+
+	testl	$PTI_SWITCH_MASK, \cr3_reg
+	jz	.Lswitched_\@
+
+	/* User cr3 in \cr3_reg - write it to hardware cr3 */
+	movl	\cr3_reg, %cr3
+
+.Lswitched_\@:
+
 	/* Restore integer registers and unwind stack to iret frame */
 	RESTORE_INT_REGS
 	RESTORE_SKIP_SEGMENTS \pop
@@ -1242,7 +1282,7 @@ ENTRY(nmi)
 #endif
 
 	pushl	%eax				# pt_regs->orig_ax
-	SAVE_ALL_NMI
+	SAVE_ALL_NMI cr3_reg=%edi
 	ENCODE_FRAME_POINTER
 	xorl	%edx, %edx			# zero error code
 	movl	%esp, %eax			# pt_regs pointer
@@ -1270,7 +1310,7 @@ ENTRY(nmi)
 
 .Lnmi_return:
 	CHECK_AND_APPLY_ESPFIX
-	RESTORE_ALL_NMI pop=4
+	RESTORE_ALL_NMI cr3_reg=%edi pop=4
 	jmp	.Lirq_return
 
 #ifdef CONFIG_X86_ESPFIX32
@@ -1286,12 +1326,12 @@ ENTRY(nmi)
 	pushl	16(%esp)
 	.endr
 	pushl	%eax
-	SAVE_ALL_NMI
+	SAVE_ALL_NMI cr3_reg=%edi
 	ENCODE_FRAME_POINTER
 	FIXUP_ESPFIX_STACK			# %eax == %esp
 	xorl	%edx, %edx			# zero error code
 	call	do_nmi
-	RESTORE_ALL_NMI
+	RESTORE_ALL_NMI cr3_reg=%edi
 	lss	12+4(%esp), %esp		# back to espfix stack
 	jmp	.Lirq_return
 #endif
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
