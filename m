Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0CA48E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:49:52 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f125so30907065pgc.20
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 09:49:52 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u69si17338498pfj.219.2019.01.04.09.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 09:49:51 -0800 (PST)
From: Dave Hansen <dave.hansen@linux.intel.com>
Subject: [PATCH 2/5] x86/mpx: remove bounds exception code
Date: Fri,  4 Jan 2019 09:49:40 -0800
Message-Id: <1546624183-26543-3-git-send-email-dave.hansen@linux.intel.com>
In-Reply-To: <1546624183-26543-1-git-send-email-dave.hansen@linux.intel.com>
References: <1546624183-26543-1-git-send-email-dave.hansen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>

MPX is being removed from the kernel due to a lack of support
in the toolchain going forward (gcc).

Remove the other user-visible ABI: signal handling.  This code
should basically have been inactive after the prctl()s were
removed, but there may be some small ABI remnants from this code.
Remove it.

This, along with the prctl() removal is probably what we should
apply first.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 arch/x86/kernel/traps.c | 74 -------------------------------------------------
 1 file changed, 74 deletions(-)

diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index 9b7c4ca..85cccad 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -57,8 +57,6 @@
 #include <asm/mach_traps.h>
 #include <asm/alternative.h>
 #include <asm/fpu/xstate.h>
-#include <asm/trace/mpx.h>
-#include <asm/mpx.h>
 #include <asm/vm86.h>
 #include <asm/umip.h>
 
@@ -433,8 +431,6 @@ dotraplinkage void do_double_fault(struct pt_regs *regs, long error_code)
 
 dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
 {
-	const struct mpx_bndcsr *bndcsr;
-
 	RCU_LOCKDEP_WARN(!rcu_is_watching(), "entry code didn't wake RCU");
 	if (notify_die(DIE_TRAP, "bounds", regs, error_code,
 			X86_TRAP_BR, SIGSEGV) == NOTIFY_STOP)
@@ -444,76 +440,6 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
 	if (!user_mode(regs))
 		die("bounds", regs, error_code);
 
-	if (!cpu_feature_enabled(X86_FEATURE_MPX)) {
-		/* The exception is not from Intel MPX */
-		goto exit_trap;
-	}
-
-	/*
-	 * We need to look at BNDSTATUS to resolve this exception.
-	 * A NULL here might mean that it is in its 'init state',
-	 * which is all zeros which indicates MPX was not
-	 * responsible for the exception.
-	 */
-	bndcsr = get_xsave_field_ptr(XFEATURE_MASK_BNDCSR);
-	if (!bndcsr)
-		goto exit_trap;
-
-	trace_bounds_exception_mpx(bndcsr);
-	/*
-	 * The error code field of the BNDSTATUS register communicates status
-	 * information of a bound range exception #BR or operation involving
-	 * bound directory.
-	 */
-	switch (bndcsr->bndstatus & MPX_BNDSTA_ERROR_CODE) {
-	case 2:	/* Bound directory has invalid entry. */
-		if (mpx_handle_bd_fault())
-			goto exit_trap;
-		break; /* Success, it was handled */
-	case 1: /* Bound violation. */
-	{
-		struct task_struct *tsk = current;
-		struct mpx_fault_info mpx;
-
-		if (mpx_fault_info(&mpx, regs)) {
-			/*
-			 * We failed to decode the MPX instruction.  Act as if
-			 * the exception was not caused by MPX.
-			 */
-			goto exit_trap;
-		}
-		/*
-		 * Success, we decoded the instruction and retrieved
-		 * an 'mpx' containing the address being accessed
-		 * which caused the exception.  This information
-		 * allows and application to possibly handle the
-		 * #BR exception itself.
-		 */
-		if (!do_trap_no_signal(tsk, X86_TRAP_BR, "bounds", regs,
-				       error_code))
-			break;
-
-		show_signal(tsk, SIGSEGV, "trap ", "bounds", regs, error_code);
-
-		force_sig_bnderr(mpx.addr, mpx.lower, mpx.upper);
-		break;
-	}
-	case 0: /* No exception caused by Intel MPX operations. */
-		goto exit_trap;
-	default:
-		die("bounds", regs, error_code);
-	}
-
-	return;
-
-exit_trap:
-	/*
-	 * This path out is for all the cases where we could not
-	 * handle the exception in some way (like allocating a
-	 * table or telling userspace about it.  We will also end
-	 * up here if the kernel has MPX turned off at compile
-	 * time..
-	 */
 	do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code, 0, NULL);
 }
 
-- 
2.7.4
