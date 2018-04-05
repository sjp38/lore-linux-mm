Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 025026B0009
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 13:19:29 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d6-v6so17716745plo.2
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 10:19:28 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0055.outbound.protection.outlook.com. [104.47.36.55])
        by mx.google.com with ESMTPS id 73si5726605pgg.68.2018.04.05.10.19.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 10:19:27 -0700 (PDT)
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: [PATCH 4/5] rcu: arm64: add rcu_dynticks_eqs_exit_sync()
Date: Thu,  5 Apr 2018 20:17:59 +0300
Message-Id: <20180405171800.5648-5-ynorov@caviumnetworks.com>
In-Reply-To: <20180405171800.5648-1-ynorov@caviumnetworks.com>
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>
Cc: Yury Norov <ynorov@caviumnetworks.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The following patch of the series enables delaying of kernel memory
synchronization for CPUs running in extended quiescent state (EQS)
till the exit of that state.

In previous patch ISB was added in EQS exit path to ensure that
any change made by kernel patching framework is visible. But after
that isb(), EQS is still enabled for a while, and there's a chance
that some other core will modify text in parallel, and EQS core
will be not notified about it, as EQS will mask IPI:

CPU0                            CPU1

ISB
				patch_some_text()
				kick_all_active_cpus_sync()
exit EQS

// not synchronized!
use_of_patched_text()

This patch introduces rcu_dynticks_eqs_exit_sync() function and uses
it in arm64 code to call ipi() after the exit from quiescent state.

Suggested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
---
 arch/arm64/kernel/Makefile | 2 ++
 arch/arm64/kernel/rcu.c    | 8 ++++++++
 kernel/rcu/tree.c          | 4 ++++
 3 files changed, 14 insertions(+)
 create mode 100644 arch/arm64/kernel/rcu.c

diff --git a/arch/arm64/kernel/Makefile b/arch/arm64/kernel/Makefile
index 9b55a3f24be7..c87a203524ab 100644
--- a/arch/arm64/kernel/Makefile
+++ b/arch/arm64/kernel/Makefile
@@ -54,6 +54,8 @@ arm64-obj-$(CONFIG_ARM64_RELOC_TEST)	+= arm64-reloc-test.o
 arm64-reloc-test-y := reloc_test_core.o reloc_test_syms.o
 arm64-obj-$(CONFIG_CRASH_DUMP)		+= crash_dump.o
 arm64-obj-$(CONFIG_ARM_SDE_INTERFACE)	+= sdei.o
+arm64-obj-$(CONFIG_TREE_RCU)		+= rcu.o
+arm64-obj-$(CONFIG_PREEMPT_RCU)		+= rcu.o
 
 arm64-obj-$(CONFIG_KVM_INDIRECT_VECTORS)+= bpi.o
 
diff --git a/arch/arm64/kernel/rcu.c b/arch/arm64/kernel/rcu.c
new file mode 100644
index 000000000000..67fe33c0ea03
--- /dev/null
+++ b/arch/arm64/kernel/rcu.c
@@ -0,0 +1,8 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <asm/barrier.h>
+
+void rcu_dynticks_eqs_exit_sync(void)
+{
+	isb();
+};
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 2a734692a581..363f91776b66 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -264,6 +264,8 @@ void rcu_bh_qs(void)
 #define rcu_eqs_special_exit() do { } while (0)
 #endif
 
+void __weak rcu_dynticks_eqs_exit_sync(void) {};
+
 static DEFINE_PER_CPU(struct rcu_dynticks, rcu_dynticks) = {
 	.dynticks_nesting = 1,
 	.dynticks_nmi_nesting = DYNTICK_IRQ_NONIDLE,
@@ -308,6 +310,8 @@ static void rcu_dynticks_eqs_exit(void)
 	 * critical section.
 	 */
 	seq = atomic_add_return(RCU_DYNTICK_CTRL_CTR, &rdtp->dynticks);
+	rcu_dynticks_eqs_exit_sync();
+
 	WARN_ON_ONCE(IS_ENABLED(CONFIG_RCU_EQS_DEBUG) &&
 		     !(seq & RCU_DYNTICK_CTRL_CTR));
 	if (seq & RCU_DYNTICK_CTRL_MASK) {
-- 
2.14.1
