Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0B96B7CCE
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:51:12 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id p131so973107oig.10
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:51:12 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r17si688844otk.179.2018.12.06.14.51.11
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 14:51:11 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V5 5/7] arm64: mm: Prevent mismatched 52-bit VA support
Date: Thu,  6 Dec 2018 22:50:40 +0000
Message-Id: <20181206225042.11548-6-steve.capper@arm.com>
In-Reply-To: <20181206225042.11548-1-steve.capper@arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, suzuki.poulose@arm.com, jcm@redhat.com, Steve Capper <steve.capper@arm.com>

For cases where there is a mismatch in ARMv8.2-LVA support between CPUs
we have to be careful in allowing secondary CPUs to boot if 52-bit
virtual addresses have already been enabled on the boot CPU.

This patch adds code to the secondary startup path. If the boot CPU has
enabled 52-bit VAs then ID_AA64MMFR2_EL1 is checked to see if the
secondary can also enable 52-bit support. If not, the secondary is
prevented from booting and an error message is displayed indicating why.

Technically this patch could be implemented using the cpufeature code
when considering 52-bit userspace support. However, we employ low level
checks here as the cpufeature code won't be able to run if we have
mismatched 52-bit kernel va support.

Signed-off-by: Steve Capper <steve.capper@arm.com>

---

Patch is new in V5 of the series
---
 arch/arm64/kernel/head.S | 26 ++++++++++++++++++++++++++
 arch/arm64/kernel/smp.c  |  5 +++++
 2 files changed, 31 insertions(+)

diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
index f60081be9a1b..58fcc1edd852 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -707,6 +707,7 @@ secondary_startup:
 	/*
 	 * Common entry point for secondary CPUs.
 	 */
+	bl	__cpu_secondary_check52bitva
 	bl	__cpu_setup			// initialise processor
 	adrp	x1, swapper_pg_dir
 	bl	__enable_mmu
@@ -785,6 +786,31 @@ ENTRY(__enable_mmu)
 	ret
 ENDPROC(__enable_mmu)
 
+ENTRY(__cpu_secondary_check52bitva)
+#ifdef CONFIG_ARM64_52BIT_VA
+	ldr_l	x0, vabits_user
+	cmp	x0, #52
+	b.ne	2f
+
+	mrs_s	x0, SYS_ID_AA64MMFR2_EL1
+	and	x0, x0, #(0xf << ID_AA64MMFR2_LVA_SHIFT)
+	cbnz	x0, 2f
+
+	adr_l	x0, va52mismatch
+	mov	w1, #1
+	strb	w1, [x0]
+	dmb	sy
+	dc	ivac, x0	// Invalidate potentially stale cache line
+
+	update_early_cpu_boot_status CPU_STUCK_IN_KERNEL, x0, x1
+1:	wfe
+	wfi
+	b	1b
+
+#endif
+2:	ret
+ENDPROC(__cpu_secondary_check52bitva)
+
 __no_granule_support:
 	/* Indicate that this CPU can't boot and is stuck in the kernel */
 	update_early_cpu_boot_status CPU_STUCK_IN_KERNEL, x1, x2
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index 96b8f2f51ab2..e15b0b64d4d0 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -108,6 +108,7 @@ static int boot_secondary(unsigned int cpu, struct task_struct *idle)
 }
 
 static DECLARE_COMPLETION(cpu_running);
+bool va52mismatch __ro_after_init;
 
 int __cpu_up(unsigned int cpu, struct task_struct *idle)
 {
@@ -137,6 +138,10 @@ int __cpu_up(unsigned int cpu, struct task_struct *idle)
 
 		if (!cpu_online(cpu)) {
 			pr_crit("CPU%u: failed to come online\n", cpu);
+
+			if (IS_ENABLED(CONFIG_ARM64_52BIT_VA) && va52mismatch)
+				pr_crit("CPU%u: does not support 52-bit VAs\n", cpu);
+
 			ret = -EIO;
 		}
 	} else {
-- 
2.19.2
