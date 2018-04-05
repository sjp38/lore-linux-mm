Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 483D46B0008
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 13:19:14 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d6-v6so17716148plo.2
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 10:19:14 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0072.outbound.protection.outlook.com. [104.47.36.72])
        by mx.google.com with ESMTPS id w2-v6si6331086plk.702.2018.04.05.10.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 10:19:12 -0700 (PDT)
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: [PATCH 3/5] arm64: early ISB at exit from extended quiescent state
Date: Thu,  5 Apr 2018 20:17:58 +0300
Message-Id: <20180405171800.5648-4-ynorov@caviumnetworks.com>
In-Reply-To: <20180405171800.5648-1-ynorov@caviumnetworks.com>
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>
Cc: Yury Norov <ynorov@caviumnetworks.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This series enables delaying of kernel memory synchronization
for CPUs running in extended quiescent state (EQS) till the exit
of that state.

ARM64 uses IPI mechanism to notify all cores in  SMP system that
kernel text is changed; and IPI handler calls isb() to synchronize.

If we don't deliver IPI to EQS CPUs anymore, we should add ISB early
in EQS exit path.

There are 2 such paths. One starts in do_idle() loop, and other
in el0_svc entry. For do_idle(), isb() is added in
arch_cpu_idle_exit() hook. And for SVC handler, isb is called in
el0_svc_naked.

Suggested-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
---
 arch/arm64/kernel/entry.S   | 16 +++++++++++++++-
 arch/arm64/kernel/process.c |  7 +++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/kernel/entry.S b/arch/arm64/kernel/entry.S
index c8d9ec363ddd..b1e1c19b4432 100644
--- a/arch/arm64/kernel/entry.S
+++ b/arch/arm64/kernel/entry.S
@@ -48,7 +48,7 @@
 	.endm
 
 	.macro el0_svc_restore_syscall_args
-#if defined(CONFIG_CONTEXT_TRACKING)
+#if !defined(CONFIG_TINY_RCU) || defined(CONFIG_CONTEXT_TRACKING)
 	restore_syscall_args
 #endif
 	.endm
@@ -483,6 +483,19 @@ __bad_stack:
 	ASM_BUG()
 	.endm
 
+/*
+ * If CPU is in extended quiescent state we need isb to ensure that
+ * possible change of kernel text is visible by the core.
+ */
+	.macro	isb_if_eqs
+#ifndef CONFIG_TINY_RCU
+	bl	rcu_is_watching
+	cbnz	x0, 1f
+	isb 					// pairs with aarch64_insn_patch_text
+1:
+#endif
+	.endm
+
 el0_sync_invalid:
 	inv_entry 0, BAD_SYNC
 ENDPROC(el0_sync_invalid)
@@ -949,6 +962,7 @@ alternative_else_nop_endif
 
 el0_svc_naked:					// compat entry point
 	stp	x0, xscno, [sp, #S_ORIG_X0]	// save the original x0 and syscall number
+	isb_if_eqs
 	enable_daif
 	ct_user_exit
 	el0_svc_restore_syscall_args
diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index f08a2ed9db0d..74cad496b07b 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -88,6 +88,13 @@ void arch_cpu_idle(void)
 	trace_cpu_idle_rcuidle(PWR_EVENT_EXIT, smp_processor_id());
 }
 
+void arch_cpu_idle_exit(void)
+{
+	/* Pairs with aarch64_insn_patch_text() for EQS CPUs. */
+	if (!rcu_is_watching())
+		isb();
+}
+
 #ifdef CONFIG_HOTPLUG_CPU
 void arch_cpu_idle_dead(void)
 {
-- 
2.14.1
