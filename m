Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id A6EC76B754F
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:42:11 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q23so9616353otn.3
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:42:11 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e24si9611951otl.194.2018.12.05.08.42.09
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 08:42:09 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V4 5/6] arm64: mm: introduce 52-bit userspace support
Date: Wed,  5 Dec 2018 16:41:44 +0000
Message-Id: <20181205164145.24568-6-steve.capper@arm.com>
In-Reply-To: <20181205164145.24568-1-steve.capper@arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com, Steve Capper <steve.capper@arm.com>

On arm64 there is optional support for a 52-bit virtual address space.
To exploit this one has to be running with a 64KB page size and be
running on hardware that supports this.

For an arm64 kernel supporting a 48 bit VA with a 64KB page size,
some changes are needed to support a 52-bit userspace:
 * TCR_EL1.T0SZ needs to be 12 instead of 16,
 * TASK_SIZE needs to reflect the new size.

This patch implements the above when the support for 52-bit VAs is
detected at early boot time.

On arm64 userspace addresses translation is controlled by TTBR0_EL1. As
well as userspace, TTBR0_EL1 controls:
 * The identity mapping,
 * EFI runtime code.

It is possible to run a kernel with an identity mapping that has a
larger VA size than userspace (and for this case __cpu_set_tcr_t0sz()
would set TCR_EL1.T0SZ as appropriate). However, when the conditions for
52-bit userspace are met; it is possible to keep TCR_EL1.T0SZ fixed at
12. Thus in this patch, the TCR_EL1.T0SZ size changing logic is
disabled.

Signed-off-by: Steve Capper <steve.capper@arm.com>

---

Changed in V4, pgd_index logic removed as we offset ttbr1 instead
---
 arch/arm64/Kconfig                   |  4 ++++
 arch/arm64/include/asm/assembler.h   |  7 +++----
 arch/arm64/include/asm/mmu_context.h |  3 +++
 arch/arm64/include/asm/processor.h   | 14 +++++++++-----
 arch/arm64/kernel/head.S             | 13 +++++++++++++
 arch/arm64/mm/fault.c                |  2 +-
 arch/arm64/mm/mmu.c                  |  1 +
 arch/arm64/mm/proc.S                 | 10 +++++++++-
 8 files changed, 43 insertions(+), 11 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 787d7850e064..eab02d24f5d1 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -709,6 +709,10 @@ config ARM64_PA_BITS_52
 
 endchoice
 
+config ARM64_52BIT_VA
+	def_bool y
+	depends on ARM64_VA_BITS_48 && ARM64_64K_PAGES
+
 config ARM64_PA_BITS
 	int
 	default 48 if ARM64_PA_BITS_48
diff --git a/arch/arm64/include/asm/assembler.h b/arch/arm64/include/asm/assembler.h
index e2fe378d2a63..243ec4f0c00f 100644
--- a/arch/arm64/include/asm/assembler.h
+++ b/arch/arm64/include/asm/assembler.h
@@ -342,11 +342,10 @@ alternative_endif
 	.endm
 
 /*
- * tcr_set_idmap_t0sz - update TCR.T0SZ so that we can load the ID map
+ * tcr_set_t0sz - update TCR.T0SZ so that we can load the ID map
  */
-	.macro	tcr_set_idmap_t0sz, valreg, tmpreg
-	ldr_l	\tmpreg, idmap_t0sz
-	bfi	\valreg, \tmpreg, #TCR_T0SZ_OFFSET, #TCR_TxSZ_WIDTH
+	.macro	tcr_set_t0sz, valreg, t0sz
+	bfi	\valreg, \t0sz, #TCR_T0SZ_OFFSET, #TCR_TxSZ_WIDTH
 	.endm
 
 /*
diff --git a/arch/arm64/include/asm/mmu_context.h b/arch/arm64/include/asm/mmu_context.h
index 1e58bf58c22b..b125fafc611b 100644
--- a/arch/arm64/include/asm/mmu_context.h
+++ b/arch/arm64/include/asm/mmu_context.h
@@ -72,6 +72,9 @@ extern u64 idmap_ptrs_per_pgd;
 
 static inline bool __cpu_uses_extended_idmap(void)
 {
+	if (IS_ENABLED(CONFIG_ARM64_52BIT_VA))
+		return false;
+
 	return unlikely(idmap_t0sz != TCR_T0SZ(VA_BITS));
 }
 
diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index fe95fd8b065e..b363fc705be4 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -19,11 +19,12 @@
 #ifndef __ASM_PROCESSOR_H
 #define __ASM_PROCESSOR_H
 
-#define TASK_SIZE_64		(UL(1) << VA_BITS)
-
-#define KERNEL_DS	UL(-1)
-#define USER_DS		(TASK_SIZE_64 - 1)
-
+#define KERNEL_DS		UL(-1)
+#ifdef CONFIG_ARM64_52BIT_VA
+#define USER_DS			((UL(1) << 52) - 1)
+#else
+#define USER_DS			((UL(1) << VA_BITS) - 1)
+#endif /* CONFIG_ARM64_52IT_VA */
 #ifndef __ASSEMBLY__
 #ifdef __KERNEL__
 
@@ -48,6 +49,9 @@
 
 #define DEFAULT_MAP_WINDOW_64	(UL(1) << VA_BITS)
 
+extern u64 vabits_user;
+#define TASK_SIZE_64		(UL(1) << vabits_user)
+
 #ifdef CONFIG_COMPAT
 #define TASK_SIZE_32		UL(0x100000000)
 #define TASK_SIZE		(test_thread_flag(TIF_32BIT) ? \
diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
index f60081be9a1b..5bc776b8ee5e 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -318,6 +318,19 @@ __create_page_tables:
 	adrp	x0, idmap_pg_dir
 	adrp	x3, __idmap_text_start		// __pa(__idmap_text_start)
 
+#ifdef CONFIG_ARM64_52BIT_VA
+	mrs_s	x6, SYS_ID_AA64MMFR2_EL1
+	and	x6, x6, #(0xf << ID_AA64MMFR2_LVA_SHIFT)
+	mov	x5, #52
+	cbnz	x6, 1f
+#endif
+	mov	x5, #VA_BITS
+1:
+	adr_l	x6, vabits_user
+	str	x5, [x6]
+	dmb	sy
+	dc	ivac, x6		// Invalidate potentially stale cache line
+
 	/*
 	 * VA_BITS may be too small to allow for an ID mapping to be created
 	 * that covers system RAM if that is located sufficiently high in the
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 7d9571f4ae3d..5fe6d2e40e9b 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -160,7 +160,7 @@ void show_pte(unsigned long addr)
 
 	pr_alert("%s pgtable: %luk pages, %u-bit VAs, pgdp = %p\n",
 		 mm == &init_mm ? "swapper" : "user", PAGE_SIZE / SZ_1K,
-		 VA_BITS, mm->pgd);
+		 mm == &init_mm ? VA_BITS : (int) vabits_user, mm->pgd);
 	pgdp = pgd_offset(mm, addr);
 	pgd = READ_ONCE(*pgdp);
 	pr_alert("[%016lx] pgd=%016llx", addr, pgd_val(pgd));
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 394b8d554def..f8fc393143ea 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -52,6 +52,7 @@
 
 u64 idmap_t0sz = TCR_T0SZ(VA_BITS);
 u64 idmap_ptrs_per_pgd = PTRS_PER_PGD;
+u64 vabits_user __ro_after_init;
 
 u64 kimage_voffset __ro_after_init;
 EXPORT_SYMBOL(kimage_voffset);
diff --git a/arch/arm64/mm/proc.S b/arch/arm64/mm/proc.S
index 2db1c491d45d..0cf86b17714c 100644
--- a/arch/arm64/mm/proc.S
+++ b/arch/arm64/mm/proc.S
@@ -450,7 +450,15 @@ ENTRY(__cpu_setup)
 	ldr	x10, =TCR_TxSZ(VA_BITS) | TCR_CACHE_FLAGS | TCR_SMP_FLAGS | \
 			TCR_TG_FLAGS | TCR_KASLR_FLAGS | TCR_ASID16 | \
 			TCR_TBI0 | TCR_A1
-	tcr_set_idmap_t0sz	x10, x9
+
+#ifdef CONFIG_ARM64_52BIT_VA
+	ldr_l 		x9, vabits_user
+	sub		x9, xzr, x9
+	add		x9, x9, #64
+#else
+	ldr_l		x9, idmap_t0sz
+#endif
+	tcr_set_t0sz	x10, x9
 
 	/*
 	 * Set the IPS bits in TCR_EL1.
-- 
2.19.2
