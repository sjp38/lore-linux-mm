Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE1216B754E
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:42:08 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id 73so12499504oii.12
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:42:08 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x188si9127266oix.138.2018.12.05.08.42.07
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 08:42:07 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V4 4/6] arm64: mm: Offset TTBR1 to allow 52-bit PTRS_PER_PGD
Date: Wed,  5 Dec 2018 16:41:43 +0000
Message-Id: <20181205164145.24568-5-steve.capper@arm.com>
In-Reply-To: <20181205164145.24568-1-steve.capper@arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com, Steve Capper <steve.capper@arm.com>

Enabling 52-bit VAs on arm64 requires that the PGD table expands from 64
entries (for the 48-bit case) to 1024 entries. This quantity,
PTRS_PER_PGD is used as follows to compute which PGD entry corresponds
to a given virtual address, addr:

pgd_index(addr) -> (addr >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)

Userspace addresses are prefixed by 0's, so for a 48-bit userspace
address, uva, the following is true:
(uva >> PGDIR_SHIFT) & (1024 - 1) == (uva >> PGDIR_SHIFT) & (64 - 1)

In other words, a 48-bit userspace address will have the same pgd_index
when using PTRS_PER_PGD = 64 and 1024.

Kernel addresses are prefixed by 1's so, given a 48-bit kernel address,
kva, we have the following inequality:
(kva >> PGDIR_SHIFT) & (1024 - 1) != (kva >> PGDIR_SHIFT) & (64 - 1)

In other words a 48-bit kernel virtual address will have a different
pgd_index when using PTRS_PER_PGD = 64 and 1024.

If, however, we note that:
kva = 0xFFFF << 48 + lower (where lower[63:48] == 0b)
and, PGDIR_SHIFT = 42 (as we are dealing with 64KB PAGE_SIZE)

We can consider:
(kva >> PGDIR_SHIFT) & (1024 - 1) - (kva >> PGDIR_SHIFT) & (64 - 1)
 = (0xFFFF << 6) & 0x3FF - (0xFFFF << 6) & 0x3F	// "lower" cancels out
 = 0x3C0

In other words, one can switch PTRS_PER_PGD to the 52-bit value globally
provided that they increment ttbr1_el1 by 0x3C0 * 8 = 0x1E00 bytes when
running with 48-bit kernel VAs (TCR_EL1.T1SZ = 16).

For kernel configuration where 52-bit userspace VAs are possible, this
patch offsets ttbr1_el1 and sets PTRS_PER_PGD corresponding to the
52-bit value.

Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Steve Capper <steve.capper@arm.com>

---

This patch is new in V4 of the series
---
 arch/arm64/include/asm/asm-uaccess.h   |  4 ++++
 arch/arm64/include/asm/assembler.h     | 23 +++++++++++++++++++++++
 arch/arm64/include/asm/pgtable-hwdef.h |  9 +++++++++
 arch/arm64/include/asm/uaccess.h       |  4 ++++
 arch/arm64/kernel/head.S               |  1 +
 arch/arm64/kernel/hibernate-asm.S      |  1 +
 arch/arm64/mm/proc.S                   |  4 ++++
 7 files changed, 46 insertions(+)

diff --git a/arch/arm64/include/asm/asm-uaccess.h b/arch/arm64/include/asm/asm-uaccess.h
index 4128bec033f6..cd361dd16b12 100644
--- a/arch/arm64/include/asm/asm-uaccess.h
+++ b/arch/arm64/include/asm/asm-uaccess.h
@@ -14,11 +14,13 @@
 #ifdef CONFIG_ARM64_SW_TTBR0_PAN
 	.macro	__uaccess_ttbr0_disable, tmp1
 	mrs	\tmp1, ttbr1_el1			// swapper_pg_dir
+	restore_ttbr1 \tmp1
 	bic	\tmp1, \tmp1, #TTBR_ASID_MASK
 	sub	\tmp1, \tmp1, #RESERVED_TTBR0_SIZE	// reserved_ttbr0 just before swapper_pg_dir
 	msr	ttbr0_el1, \tmp1			// set reserved TTBR0_EL1
 	isb
 	add	\tmp1, \tmp1, #RESERVED_TTBR0_SIZE
+	offset_ttbr1 \tmp1
 	msr	ttbr1_el1, \tmp1		// set reserved ASID
 	isb
 	.endm
@@ -27,8 +29,10 @@
 	get_thread_info \tmp1
 	ldr	\tmp1, [\tmp1, #TSK_TI_TTBR0]	// load saved TTBR0_EL1
 	mrs	\tmp2, ttbr1_el1
+	restore_ttbr1 \tmp2
 	extr    \tmp2, \tmp2, \tmp1, #48
 	ror     \tmp2, \tmp2, #16
+	offset_ttbr1 \tmp2
 	msr	ttbr1_el1, \tmp2		// set the active ASID
 	isb
 	msr	ttbr0_el1, \tmp1		// set the non-PAN TTBR0_EL1
diff --git a/arch/arm64/include/asm/assembler.h b/arch/arm64/include/asm/assembler.h
index 6142402c2eb4..e2fe378d2a63 100644
--- a/arch/arm64/include/asm/assembler.h
+++ b/arch/arm64/include/asm/assembler.h
@@ -515,6 +515,29 @@ USER(\label, ic	ivau, \tmp2)			// invalidate I line PoU
 	mrs	\rd, sp_el0
 	.endm
 
+/*
+ * Offset ttbr1 to allow for 48-bit kernel VAs set with 52-bit PTRS_PER_PGD.
+ * orr is used as it can cover the immediate value (and is idempotent).
+ * In future this may be nop'ed out when dealing with 52-bit kernel VAs.
+ * 	ttbr: Value of ttbr to set, modified.
+ */
+	.macro	offset_ttbr1, ttbr
+#ifdef CONFIG_ARM64_52BIT_VA
+	orr	\ttbr, \ttbr, #TTBR1_BADDR_4852_OFFSET
+#endif
+	.endm
+
+/*
+ * Perform the reverse of offset_ttbr1.
+ * bic is used as it can cover the immediate value and, in future, won't need
+ * to be nop'ed out when dealing with 52-bit kernel VAs.
+ */
+	.macro	restore_ttbr1, ttbr
+#ifdef CONFIG_ARM64_52BIT_VA
+	bic	\ttbr, \ttbr, #TTBR1_BADDR_4852_OFFSET
+#endif
+	.endm
+
 /*
  * Arrange a physical address in a TTBR register, taking care of 52-bit
  * addresses.
diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
index 1d7d8da2ef9b..4a29c7e03ae4 100644
--- a/arch/arm64/include/asm/pgtable-hwdef.h
+++ b/arch/arm64/include/asm/pgtable-hwdef.h
@@ -80,7 +80,11 @@
 #define PGDIR_SHIFT		ARM64_HW_PGTABLE_LEVEL_SHIFT(4 - CONFIG_PGTABLE_LEVELS)
 #define PGDIR_SIZE		(_AC(1, UL) << PGDIR_SHIFT)
 #define PGDIR_MASK		(~(PGDIR_SIZE-1))
+#ifdef CONFIG_ARM64_52BIT_VA
+#define PTRS_PER_PGD		(1 << (52 - PGDIR_SHIFT))
+#else
 #define PTRS_PER_PGD		(1 << (VA_BITS - PGDIR_SHIFT))
+#endif
 
 /*
  * Section address mask and size definitions.
@@ -306,4 +310,9 @@
 #define TTBR_BADDR_MASK_52	(((UL(1) << 46) - 1) << 2)
 #endif
 
+#ifdef CONFIG_ARM64_52BIT_VA
+#define TTBR1_BADDR_4852_OFFSET	(((UL(1) << (52 - PGDIR_SHIFT)) - \
+				 (UL(1) << (48 - PGDIR_SHIFT))) * 8)
+#endif
+
 #endif
diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index 07c34087bd5e..df60b3978568 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -124,7 +124,11 @@ static inline void __uaccess_ttbr0_disable(void)
 	ttbr = read_sysreg(ttbr1_el1);
 	ttbr &= ~TTBR_ASID_MASK;
 	/* reserved_ttbr0 placed before swapper_pg_dir */
+#ifdef CONFIG_ARM64_52BIT_VA
+	write_sysreg((ttbr & ~TTBR1_BADDR_4852_OFFSET) - RESERVED_TTBR0_SIZE, ttbr0_el1);
+#else
 	write_sysreg(ttbr - RESERVED_TTBR0_SIZE, ttbr0_el1);
+#endif
 	isb();
 	/* Set reserved ASID */
 	write_sysreg(ttbr, ttbr1_el1);
diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
index 4471f570a295..f60081be9a1b 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -769,6 +769,7 @@ ENTRY(__enable_mmu)
 	phys_to_ttbr x1, x1
 	phys_to_ttbr x2, x2
 	msr	ttbr0_el1, x2			// load TTBR0
+	offset_ttbr1 x1
 	msr	ttbr1_el1, x1			// load TTBR1
 	isb
 	msr	sctlr_el1, x0
diff --git a/arch/arm64/kernel/hibernate-asm.S b/arch/arm64/kernel/hibernate-asm.S
index dd14ab8c9f72..fe36d85c60bd 100644
--- a/arch/arm64/kernel/hibernate-asm.S
+++ b/arch/arm64/kernel/hibernate-asm.S
@@ -40,6 +40,7 @@
 	tlbi	vmalle1
 	dsb	nsh
 	phys_to_ttbr \tmp, \page_table
+	offset_ttbr1 \tmp
 	msr	ttbr1_el1, \tmp
 	isb
 .endm
diff --git a/arch/arm64/mm/proc.S b/arch/arm64/mm/proc.S
index 2c75b0b903ae..2db1c491d45d 100644
--- a/arch/arm64/mm/proc.S
+++ b/arch/arm64/mm/proc.S
@@ -182,6 +182,7 @@ ENDPROC(cpu_do_switch_mm)
 .macro	__idmap_cpu_set_reserved_ttbr1, tmp1, tmp2
 	adrp	\tmp1, empty_zero_page
 	phys_to_ttbr \tmp2, \tmp1
+	offset_ttbr1 \tmp2
 	msr	ttbr1_el1, \tmp2
 	isb
 	tlbi	vmalle1
@@ -200,6 +201,7 @@ ENTRY(idmap_cpu_replace_ttbr1)
 
 	__idmap_cpu_set_reserved_ttbr1 x1, x3
 
+	offset_ttbr1 x0
 	msr	ttbr1_el1, x0
 	isb
 
@@ -254,6 +256,7 @@ ENTRY(idmap_kpti_install_ng_mappings)
 	pte		.req	x16
 
 	mrs	swapper_ttb, ttbr1_el1
+	restore_ttbr1	swapper_ttb
 	adr	flag_ptr, __idmap_kpti_flag
 
 	cbnz	cpu, __idmap_kpti_secondary
@@ -373,6 +376,7 @@ __idmap_kpti_secondary:
 	cbnz	w18, 1b
 
 	/* All done, act like nothing happened */
+	offset_ttbr1 swapper_ttb
 	msr	ttbr1_el1, swapper_ttb
 	isb
 	ret
-- 
2.19.2
