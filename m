Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51E726B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 13:18:57 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u7-v6so16229888plr.13
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 10:18:57 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0054.outbound.protection.outlook.com. [104.47.41.54])
        by mx.google.com with ESMTPS id j65si5842013pgc.346.2018.04.05.10.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 10:18:55 -0700 (PDT)
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: [PATCH 2/5] arm64: entry: introduce restore_syscall_args macro
Date: Thu,  5 Apr 2018 20:17:57 +0300
Message-Id: <20180405171800.5648-3-ynorov@caviumnetworks.com>
In-Reply-To: <20180405171800.5648-1-ynorov@caviumnetworks.com>
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>
Cc: Yury Norov <ynorov@caviumnetworks.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Syscall arguments are passed in registers x0..x7. If assembler
code has to call C functions before passing control to syscall
handler, it should restore original state of that registers
after the call.

Currently, syscall arguments restoring is opencoded in el0_svc_naked
and __sys_trace. This patch introduces restore_syscall_args macro to
use it there.

Also, parameter 'syscall = 0' is removed from ct_user_exit to make
el0_svc_naked call restore_syscall_args explicitly. This is needed
because the following patch of the series adds another call to C
function in el0_svc_naked, and restoring of syscall args becomes not
only a matter of ct_user_exit.

Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
---
 arch/arm64/kernel/entry.S | 37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/arch/arm64/kernel/entry.S b/arch/arm64/kernel/entry.S
index 9c06b4b80060..c8d9ec363ddd 100644
--- a/arch/arm64/kernel/entry.S
+++ b/arch/arm64/kernel/entry.S
@@ -37,22 +37,29 @@
 #include <asm/unistd.h>
 
 /*
- * Context tracking subsystem.  Used to instrument transitions
- * between user and kernel mode.
+ * Save/restore needed during syscalls.  Restore syscall arguments from
+ * the values already saved on stack during kernel_entry.
  */
-	.macro ct_user_exit, syscall = 0
-#ifdef CONFIG_CONTEXT_TRACKING
-	bl	context_tracking_user_exit
-	.if \syscall == 1
-	/*
-	 * Save/restore needed during syscalls.  Restore syscall arguments from
-	 * the values already saved on stack during kernel_entry.
-	 */
+	.macro restore_syscall_args
 	ldp	x0, x1, [sp]
 	ldp	x2, x3, [sp, #S_X2]
 	ldp	x4, x5, [sp, #S_X4]
 	ldp	x6, x7, [sp, #S_X6]
-	.endif
+	.endm
+
+	.macro el0_svc_restore_syscall_args
+#if defined(CONFIG_CONTEXT_TRACKING)
+	restore_syscall_args
+#endif
+	.endm
+
+/*
+ * Context tracking subsystem.  Used to instrument transitions
+ * between user and kernel mode.
+ */
+	.macro ct_user_exit
+#ifdef CONFIG_CONTEXT_TRACKING
+	bl	context_tracking_user_exit
 #endif
 	.endm
 
@@ -943,7 +950,8 @@ alternative_else_nop_endif
 el0_svc_naked:					// compat entry point
 	stp	x0, xscno, [sp, #S_ORIG_X0]	// save the original x0 and syscall number
 	enable_daif
-	ct_user_exit 1
+	ct_user_exit
+	el0_svc_restore_syscall_args
 
 	tst	x16, #_TIF_SYSCALL_WORK		// check for syscall hooks
 	b.ne	__sys_trace
@@ -976,10 +984,7 @@ __sys_trace:
 	mov	x1, sp				// pointer to regs
 	cmp	wscno, wsc_nr			// check upper syscall limit
 	b.hs	__ni_sys_trace
-	ldp	x0, x1, [sp]			// restore the syscall args
-	ldp	x2, x3, [sp, #S_X2]
-	ldp	x4, x5, [sp, #S_X4]
-	ldp	x6, x7, [sp, #S_X6]
+	restore_syscall_args
 	ldr	x16, [stbl, xscno, lsl #3]	// address in the syscall table
 	blr	x16				// call sys_* routine
 
-- 
2.14.1
