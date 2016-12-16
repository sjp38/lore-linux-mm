Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 653E96B0269
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:04 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id x26so62782293qtb.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:04 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m30si3810716qtg.333.2016.12.16.10.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:36:03 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 04/14] sparc64: load shared id into context register 1
Date: Fri, 16 Dec 2016 10:35:27 -0800
Message-Id: <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

In current code, only context ID register 0 is set and used by the MMU.
On sun4v platforms that support MMU shared context, there is an additional
context ID register: specifically context register 1.  When searching
the TLB, the MMU will find a match if the virtual address matches and
the ID contained in context register 0 -OR- context register 1 matches.

Load the shared context ID into context ID register 1.  Care must be
taken to load register 1 after register 0, as loading register 0
overwrites both register 0 and 1.  Modify code loading register 0 to
also load register one if applicable.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/include/asm/mmu_context_64.h | 37 +++++++++++++++++--
 arch/sparc/include/asm/spitfire.h       |  2 ++
 arch/sparc/kernel/fpu_traps.S           | 63 +++++++++++++++++++++++++++++++++
 arch/sparc/kernel/rtrap_64.S            | 20 +++++++++++
 arch/sparc/kernel/trampoline_64.S       | 20 +++++++++++
 5 files changed, 140 insertions(+), 2 deletions(-)

diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
index acaea6d..84268df 100644
--- a/arch/sparc/include/asm/mmu_context_64.h
+++ b/arch/sparc/include/asm/mmu_context_64.h
@@ -61,8 +61,11 @@ void smp_tsb_sync(struct mm_struct *mm);
 #define smp_tsb_sync(__mm) do { } while (0)
 #endif
 
-/* Set MMU context in the actual hardware. */
-#define load_secondary_context(__mm) \
+/*
+ * Set MMU context in the actual hardware.  Secondary context register
+ * zero is loaded with task specific context.
+ */
+#define load_secondary_context_0(__mm) \
 	__asm__ __volatile__( \
 	"\n661:	stxa		%0, [%1] %2\n" \
 	"	.section	.sun4v_1insn_patch, \"ax\"\n" \
@@ -74,6 +77,36 @@ void smp_tsb_sync(struct mm_struct *mm);
 	: "r" (CTX_HWBITS((__mm)->context)), \
 	  "r" (SECONDARY_CONTEXT), "i" (ASI_DMMU), "i" (ASI_MMU))
 
+/*
+ * Secondary context register one is loaded with shared context if
+ * it exists for the task.
+ */
+#define load_secondary_context_1(__mm) \
+	__asm__ __volatile__( \
+	"\n661: stxa		%0, [%1] %2\n" \
+	"	.section	.sun4v_1insn_patch, \"ax\"\n" \
+	"	.word		661b\n" \
+	"	stxa		%0, [%1] %3\n" \
+	"	.previous\n" \
+	"	flush		%%g6\n" \
+	: /* No outputs */ \
+	: "r" (SHARED_CTX_HWBITS((__mm)->context)), \
+	  "r" (SECONDARY_CONTEXT_R1), "i" (ASI_DMMU), "i" (ASI_MMU))
+
+#if defined(CONFIG_SHARED_MMU_CTX)
+#define load_secondary_context(__mm) \
+	do { \
+		load_secondary_context_0(__mm); \
+		if ((__mm)->context.shared_ctx) \
+			load_secondary_context_1(__mm); \
+	} while (0)
+#else
+#define load_secondary_context(__mm) \
+	do { \
+		load_secondary_context_0(__mm); \
+	} while (0)
+#endif
+
 void __flush_tlb_mm(unsigned long, unsigned long);
 
 /* Switch the current MM context. */
diff --git a/arch/sparc/include/asm/spitfire.h b/arch/sparc/include/asm/spitfire.h
index 1d8321c..1fa4594 100644
--- a/arch/sparc/include/asm/spitfire.h
+++ b/arch/sparc/include/asm/spitfire.h
@@ -33,6 +33,8 @@
 #define DMMU_SFAR		0x0000000000000020
 #define VIRT_WATCHPOINT		0x0000000000000038
 #define PHYS_WATCHPOINT		0x0000000000000040
+#define	PRIMARY_CONTEXT_R1	0x0000000000000108
+#define	SECONDARY_CONTEXT_R1	0x0000000000000110
 
 #define SPITFIRE_HIGHEST_LOCKED_TLBENT	(64 - 1)
 #define CHEETAH_HIGHEST_LOCKED_TLBENT	(16 - 1)
diff --git a/arch/sparc/kernel/fpu_traps.S b/arch/sparc/kernel/fpu_traps.S
index 336d275..f85a034 100644
--- a/arch/sparc/kernel/fpu_traps.S
+++ b/arch/sparc/kernel/fpu_traps.S
@@ -73,6 +73,16 @@ do_fpdis:
 	ldxa		[%g3] ASI_MMU, %g5
 	.previous
 
+661:	nop
+	nop
+	.section	.sun4v_2insn_patch, "ax"
+	.word		661b
+	mov		SECONDARY_CONTEXT_R1, %g3
+	ldxa		[%g3] ASI_MMU, %g4
+	.previous
+	/* Unnecessary on sun4u and pre-Niagara 2 sun4v */
+	mov		SECONDARY_CONTEXT, %g3
+
 	sethi		%hi(sparc64_kern_sec_context), %g2
 	ldx		[%g2 + %lo(sparc64_kern_sec_context)], %g2
 
@@ -114,6 +124,16 @@ do_fpdis:
 	ldxa		[%g3] ASI_MMU, %g5
 	.previous
 
+661:	nop
+	nop
+	.section	.sun4v_2insn_patch, "ax"
+	.word		661b
+	mov		SECONDARY_CONTEXT_R1, %g3
+	ldxa		[%g3] ASI_MMU, %g4
+	.previous
+	/* Unnecessary on sun4u and pre-Niagara 2 sun4v */
+	mov		SECONDARY_CONTEXT, %g3
+
 	add		%g6, TI_FPREGS, %g1
 	sethi		%hi(sparc64_kern_sec_context), %g2
 	ldx		[%g2 + %lo(sparc64_kern_sec_context)], %g2
@@ -155,6 +175,16 @@ do_fpdis:
 	ldxa		[%g3] ASI_MMU, %g5
 	.previous
 
+661:	nop
+	nop
+	.section	.sun4v_2insn_patch, "ax"
+	.word		661b
+	mov		SECONDARY_CONTEXT_R1, %g3
+	ldxa		[%g3] ASI_MMU, %g4
+	.previous
+	/* Unnecessary on sun4u and pre-Niagara 2 sun4v */
+	mov		SECONDARY_CONTEXT, %g3
+
 	sethi		%hi(sparc64_kern_sec_context), %g2
 	ldx		[%g2 + %lo(sparc64_kern_sec_context)], %g2
 
@@ -181,11 +211,24 @@ fpdis_exit:
 	stxa		%g5, [%g3] ASI_MMU
 	.previous
 
+661:	nop
+	nop
+	.section	.sun4v_2insn_patch, "ax"
+	.word		661b
+	mov		SECONDARY_CONTEXT_R1, %g3
+	stxa		%g4, [%g3] ASI_MMU
+	.previous
+
 	membar		#Sync
 fpdis_exit2:
 	wr		%g7, 0, %gsr
 	ldx		[%g6 + TI_XFSR], %fsr
 	rdpr		%tstate, %g3
+661:	nop
+	.section	.sun4v_1insn_patch, "ax"
+	.word		661b
+	sethi		%hi(TSTATE_PEF), %g4
+	.previous
 	or		%g3, %g4, %g3		! anal...
 	wrpr		%g3, %tstate
 	wr		%g0, FPRS_FEF, %fprs	! clean DU/DL bits
@@ -347,6 +390,16 @@ do_fptrap_after_fsr:
 	ldxa		[%g3] ASI_MMU, %g5
 	.previous
 
+661:	nop
+	nop
+	.section	.sun4v_2insn_patch, "ax"
+	.word		661b
+	mov		SECONDARY_CONTEXT_R1, %g3
+	ldxa		[%g3] ASI_MMU, %g4
+	.previous
+	/* Unnecessary on sun4u and pre-Niagara 2 sun4v */
+	mov		SECONDARY_CONTEXT, %g3
+
 	sethi		%hi(sparc64_kern_sec_context), %g2
 	ldx		[%g2 + %lo(sparc64_kern_sec_context)], %g2
 
@@ -377,7 +430,17 @@ do_fptrap_after_fsr:
 	stxa		%g5, [%g1] ASI_MMU
 	.previous
 
+661:	nop
+	nop
+	.section	.sun4v_2insn_patch, "ax"
+	.word		661b
+	mov		SECONDARY_CONTEXT_R1, %g1
+	stxa		%g4, [%g1] ASI_MMU
+	.previous
+
 	membar		#Sync
+	/* Unnecessary on sun4u and pre-Niagara 2 sun4v */
+	mov		SECONDARY_CONTEXT, %g1
 	ba,pt		%xcc, etrap
 	 wr		%g0, 0, %fprs
 	.size		do_fptrap,.-do_fptrap
diff --git a/arch/sparc/kernel/rtrap_64.S b/arch/sparc/kernel/rtrap_64.S
index 216948c..d409d84 100644
--- a/arch/sparc/kernel/rtrap_64.S
+++ b/arch/sparc/kernel/rtrap_64.S
@@ -202,6 +202,7 @@ rt_continue:	ldx			[%sp + PTREGS_OFF + PT_V9_G1], %g1
 		brnz,pn			%l3, kern_rtt
 		 mov			PRIMARY_CONTEXT, %l7
 
+		/* Get value from SECONDARY_CONTEXT register */
 661:		ldxa			[%l7 + %l7] ASI_DMMU, %l0
 		.section		.sun4v_1insn_patch, "ax"
 		.word			661b
@@ -212,12 +213,31 @@ rt_continue:	ldx			[%sp + PTREGS_OFF + PT_V9_G1], %g1
 		ldx			[%l1 + %lo(sparc64_kern_pri_nuc_bits)], %l1
 		or			%l0, %l1, %l0
 
+		/* and, put into PRIMARY_CONTEXT register */
 661:		stxa			%l0, [%l7] ASI_DMMU
 		.section		.sun4v_1insn_patch, "ax"
 		.word			661b
 		stxa			%l0, [%l7] ASI_MMU
 		.previous
 
+		/* Get value from SECONDARY_CONTEXT_R1 register */
+661:		nop
+		nop
+		.section		.sun4v_2insn_patch, "ax"
+		.word			661b
+		mov			SECONDARY_CONTEXT_R1, %l7
+		ldxa			[%l7] ASI_MMU, %l0
+		.previous
+
+		/* and, put into PRIMARY_CONTEXT_R1 register */
+661:		nop
+		nop
+		.section		.sun4v_2insn_patch, "ax"
+		.word			661b
+		mov			PRIMARY_CONTEXT_R1, %l7
+		stxa			%l0, [%l7] ASI_MMU
+		.previous
+
 		sethi			%hi(KERNBASE), %l7
 		flush			%l7
 		rdpr			%wstate, %l1
diff --git a/arch/sparc/kernel/trampoline_64.S b/arch/sparc/kernel/trampoline_64.S
index 88ede1d..7c4ab3b 100644
--- a/arch/sparc/kernel/trampoline_64.S
+++ b/arch/sparc/kernel/trampoline_64.S
@@ -260,6 +260,16 @@ after_lock_tlb:
 	stxa		%g0, [%g7] ASI_MMU
 	.previous
 
+	/* Save SECONDARY_CONTEXT_R1, membar should be part of patch */
+	membar		#Sync
+661:	nop
+	nop
+	.section	.sun4v_2insn_patch, "ax"
+	.word		661b
+	mov		SECONDARY_CONTEXT_R1, %g7
+	ldxa		[%g7] ASI_MMU, %g1
+	.previous
+
 	membar		#Sync
 	mov		SECONDARY_CONTEXT, %g7
 
@@ -269,6 +279,16 @@ after_lock_tlb:
 	stxa		%g0, [%g7] ASI_MMU
 	.previous
 
+	/* Restore SECONDARY_CONTEXT_R1, membar should be part of patch */
+	membar		#Sync
+661:	nop
+	nop
+	.section	.sun4v_2insn_patch, "ax"
+	.word		661b
+	mov		SECONDARY_CONTEXT_R1, %g7
+	stxa		%g1, [%g7] ASI_MMU
+	.previous
+
 	membar		#Sync
 
 	/* Everything we do here, until we properly take over the
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
