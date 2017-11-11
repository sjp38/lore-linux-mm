Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C13F52802AA
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 19:11:33 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d15so636695pfl.0
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 16:11:33 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b73si9798461pga.432.2017.11.10.16.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 16:11:32 -0800 (PST)
Subject: [PATCH] x86, kaiser: fix 32-bit SYSENTER
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 16:11:13 -0800
Message-Id: <20171111001113.830CCB86@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


This is a fix on top of the KAISER [v3] patches I posted earlier.
It is a fix for:

	[PATCH 05/30] x86, kaiser: prepare assembly for entry/exit CR3 switching

I made a mistake and stopped running the 32-bit selftests at
some point.  My changes from one of Borislav's review comments
ended up breaking the 32-bit SYSENTER path.

The issue was that we switched over to the process stack before
and wrote to it before we switched CR3.  Since it is now unmapped
this access faulted.

I can also send a consolidated 05/30 patch that contains this
fix if that would be easier.

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

 b/arch/x86/entry/entry_64_compat.S |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff -puN arch/x86/entry/entry_64_compat.S~kaiser-mpx-32-splat arch/x86/entry/entry_64_compat.S
--- a/arch/x86/entry/entry_64_compat.S~kaiser-mpx-32-splat	2017-11-10 15:44:42.893205660 -0800
+++ b/arch/x86/entry/entry_64_compat.S	2017-11-10 16:01:14.880203186 -0800
@@ -48,6 +48,10 @@
 ENTRY(entry_SYSENTER_compat)
 	/* Interrupts are off on entry. */
 	SWAPGS
+
+	/* We are about to clobber %rsp anyway, clobbering here is OK */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
+
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 
 	/*
@@ -91,9 +95,6 @@ ENTRY(entry_SYSENTER_compat)
 	pushq   $0			/* pt_regs->r15 = 0 */
 	cld
 
-	/* We just saved all the registers, so safe to clobber %rdi */
-	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
-
 	/*
 	 * SYSENTER doesn't filter flags, so we need to clear NT and AC
 	 * ourselves.  To save a few cycles, we can check whether
@@ -245,7 +246,6 @@ sysret32_from_system_call:
 	popq	%rsi			/* pt_regs->si */
 	popq	%rdi			/* pt_regs->di */
 
-	SWITCH_TO_USER_CR3 scratch_reg=%r8
         /*
          * USERGS_SYSRET32 does:
          *  GSBASE = user's GS base
@@ -261,10 +261,18 @@ sysret32_from_system_call:
 	 * when the system call started, which is already known to user
 	 * code.  We zero R8-R10 to avoid info leaks.
          */
+	movq	RSP-ORIG_RAX(%rsp), %rsp
+
+	/*
+	 * %rsp is not mapped to userspace so the switch to the user
+	 * CR3 can not be done until after all references to it are
+	 * complete.
+	 */
+	SWITCH_TO_USER_CR3 scratch_reg=%r8
+
 	xorq	%r8, %r8
 	xorq	%r9, %r9
 	xorq	%r10, %r10
-	movq	RSP-ORIG_RAX(%rsp), %rsp
 	swapgs
 	sysretl
 END(entry_SYSCALL_compat)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
