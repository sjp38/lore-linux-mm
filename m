Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id B361B6B0269
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:04 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id b35so20250920uaa.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:04 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c76si2475677vke.47.2016.12.16.10.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:36:03 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 08/14] sparc64: shared context tsb handling at context switch time
Date: Fri, 16 Dec 2016 10:35:31 -0800
Message-Id: <1481913337-9331-9-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

At context switch time, load the shared context TSB into the MMU (if
applicable) and set up global state to include the TSB.

sun4v loads the address of base and huge page TSBs into scratchpad
registers.  There is not an extra register for shared context TSB.
So, use offset 0xd0 in the trap block.  This is TRAP_PER_CPU_TSB_HUGE,
and is only used on sun4u.  We can then use this area for the shared
context on sun4v.

With this commit, global state is set up for shared context TSB but
still not used.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/include/asm/mmu_context_64.h | 27 ++++++++++++++----
 arch/sparc/include/asm/trap_block.h     |  3 +-
 arch/sparc/kernel/head_64.S             |  2 +-
 arch/sparc/kernel/tsb.S                 | 50 +++++++++++++++++++++------------
 4 files changed, 57 insertions(+), 25 deletions(-)

diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
index 84268df..0dc95cb5 100644
--- a/arch/sparc/include/asm/mmu_context_64.h
+++ b/arch/sparc/include/asm/mmu_context_64.h
@@ -36,21 +36,38 @@ void destroy_context(struct mm_struct *mm);
 void __tsb_context_switch(unsigned long pgd_pa,
 			  struct tsb_config *tsb_base,
 			  struct tsb_config *tsb_huge,
+			  struct tsb_config *tsb_huge_shared,
 			  unsigned long tsb_descr_pa);
 
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static inline void tsb_context_switch(struct mm_struct *mm)
 {
+	/*
+	 * The conditional for tsb_descr_pa handles shared context
+	 * case where tsb_block[0] may not be used.
+	 */
 	__tsb_context_switch(__pa(mm->pgd),
 			     &mm->context.tsb_block[MM_TSB_BASE],
-#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 			     (mm->context.tsb_block[MM_TSB_HUGE].tsb ?
 			      &mm->context.tsb_block[MM_TSB_HUGE] :
-			      NULL)
+			      NULL),
+			     (mm->context.tsb_block[MM_TSB_HUGE_SHARED].tsb ?
+			      &mm->context.tsb_block[MM_TSB_HUGE_SHARED] :
+			      NULL),
+			     (mm->context.tsb_block[0].tsb ?
+			      __pa(&mm->context.tsb_descr[0]) :
+			      __pa(&mm->context.tsb_descr[1])));
+}
 #else
-			     NULL
-#endif
-			     , __pa(&mm->context.tsb_descr[MM_TSB_BASE]));
+static inline void tsb_context_switch(struct mm_struct *mm)
+{
+	__tsb_context_switch(__pa(mm->pgd),
+			     &mm->context.tsb_block[MM_TSB_BASE],
+			     NULL,
+			     NULL,
+			     __pa(&mm->context.tsb_descr[MM_TSB_BASE]);
 }
+#endif
 
 void tsb_grow(struct mm_struct *mm,
 	      unsigned long tsb_index,
diff --git a/arch/sparc/include/asm/trap_block.h b/arch/sparc/include/asm/trap_block.h
index ec9c04d..e971785 100644
--- a/arch/sparc/include/asm/trap_block.h
+++ b/arch/sparc/include/asm/trap_block.h
@@ -96,7 +96,8 @@ extern struct sun4v_2insn_patch_entry __sun_m7_2insn_patch,
 #define TRAP_PER_CPU_FAULT_INFO		0x40
 #define TRAP_PER_CPU_CPU_MONDO_BLOCK_PA	0xc0
 #define TRAP_PER_CPU_CPU_LIST_PA	0xc8
-#define TRAP_PER_CPU_TSB_HUGE		0xd0
+#define TRAP_PER_CPU_TSB_HUGE		0xd0	/* sun4u only */
+#define TRAP_PER_CPU_TSB_HUGE_SHARED	0xd0	/* sun4v only */
 #define TRAP_PER_CPU_TSB_HUGE_TEMP	0xd8
 #define TRAP_PER_CPU_IRQ_WORKLIST_PA	0xe0
 #define TRAP_PER_CPU_CPU_MONDO_QMASK	0xe8
diff --git a/arch/sparc/kernel/head_64.S b/arch/sparc/kernel/head_64.S
index 6aa3da1..0bf1e1f 100644
--- a/arch/sparc/kernel/head_64.S
+++ b/arch/sparc/kernel/head_64.S
@@ -875,7 +875,6 @@ sparc64_boot_end:
 #include "sun4v_tlb_miss.S"
 #include "sun4v_ivec.S"
 #include "ktlb.S"
-#include "tsb.S"
 
 /*
  * The following skip makes sure the trap table in ttable.S is aligned
@@ -916,6 +915,7 @@ swapper_4m_tsb:
 
 ! 0x0000000000428000
 
+#include "tsb.S"
 #include "systbls_64.S"
 
 	.data
diff --git a/arch/sparc/kernel/tsb.S b/arch/sparc/kernel/tsb.S
index d568c82..3ed3e7c 100644
--- a/arch/sparc/kernel/tsb.S
+++ b/arch/sparc/kernel/tsb.S
@@ -374,7 +374,8 @@ tsb_flush:
 	 * %o0: page table physical address
 	 * %o1:	TSB base config pointer
 	 * %o2:	TSB huge config pointer, or NULL if none
-	 * %o3:	Hypervisor TSB descriptor physical address
+	 * %o3: TSB huge shared config pointer, or NULL if none
+	 * %o4: Hypervisor TSB descriptor physical address
 	 *
 	 * We have to run this whole thing with interrupts
 	 * disabled so that the current cpu doesn't change
@@ -387,6 +388,8 @@ __tsb_context_switch:
 	rdpr	%pstate, %g1
 	wrpr	%g1, PSTATE_IE, %pstate
 
+	mov	%o4, %g7
+
 	TRAP_LOAD_TRAP_BLOCK(%g2, %g3)
 
 	stx	%o0, [%g2 + TRAP_PER_CPU_PGD_PADDR]
@@ -397,13 +400,8 @@ __tsb_context_switch:
 
 	ldx	[%o2 + TSB_CONFIG_REG_VAL], %g3
 
-1:	stx	%g3, [%g2 + TRAP_PER_CPU_TSB_HUGE]
-
-	sethi	%hi(tlb_type), %g2
-	lduw	[%g2 + %lo(tlb_type)], %g2
-	cmp	%g2, 3
-	bne,pt	%icc, 50f
-	 nop
+1:	IF_TLB_TYPE_NOT_HYPE(%o5, 50f)
+	/* Only setup HV TSB descriptors on appropriate MMU */
 
 	/* Hypervisor TSB switch. */
 	mov	SCRATCHPAD_UTSBREG1, %o5
@@ -411,27 +409,43 @@ __tsb_context_switch:
 	mov	SCRATCHPAD_UTSBREG2, %o5
 	stxa	%g3, [%o5] ASI_SCRATCHPAD
 
-	mov	2, %o0
+	/* Start counting HV tsb descriptors. */
+	mov	1, %o0				/* Always MM_TSB_BASE */
+	cmp	%g3, -1				/* MM_TSB_HUGE ? */
+	beq	%xcc, 2f
+	 nop
+	add	%o0, 1, %o0
+2:
+	brz,pt	%o3, 3f				/* MM_TSB_HUGE_SHARED ? */
+	 mov	-1, %g3
+	ldx	[%o3 + TSB_CONFIG_REG_VAL], %g3
+3:
+	/* Put Huge Shared TSB in trap block */
+	stx	%g3, [%g2 + TRAP_PER_CPU_TSB_HUGE_SHARED]
 	cmp	%g3, -1
-	move	%xcc, 1, %o0
-
+	beq	%xcc, 4f
+	 nop
+	add	%o0, 1, %o0
+4:
 	mov	HV_FAST_MMU_TSB_CTXNON0, %o5
-	mov	%o3, %o1
+	mov	%g7, %o1
 	ta	HV_FAST_TRAP
 
 	/* Finish up.  */
-	ba,pt	%xcc, 9f
+	ba,pt	%xcc, 60f
 	 nop
 
 	/* SUN4U TSB switch.  */
-50:	mov	TSB_REG, %o5
+50:	stx	%g3, [%g2 + TRAP_PER_CPU_TSB_HUGE]
+
+	mov	TSB_REG, %o5
 	stxa	%o0, [%o5] ASI_DMMU
 	membar	#Sync
 	stxa	%o0, [%o5] ASI_IMMU
 	membar	#Sync
 
-2:	ldx	[%o1 + TSB_CONFIG_MAP_VADDR], %o4
-	brz	%o4, 9f
+	ldx	[%o1 + TSB_CONFIG_MAP_VADDR], %o4
+	brz	%o4, 60f
 	 ldx	[%o1 + TSB_CONFIG_MAP_PTE], %o5
 
 	sethi	%hi(sparc64_highest_unlocked_tlb_ent), %g2
@@ -443,7 +457,7 @@ __tsb_context_switch:
 	stxa	%o5, [%g2] ASI_DTLB_DATA_ACCESS
 	membar	#Sync
 
-	brz,pt	%o2, 9f
+	brz,pt	%o2, 60f
 	 nop
 
 	ldx	[%o2 + TSB_CONFIG_MAP_VADDR], %o4
@@ -455,7 +469,7 @@ __tsb_context_switch:
 	stxa	%o5, [%g2] ASI_DTLB_DATA_ACCESS
 	membar	#Sync
 
-9:
+60:
 	wrpr	%g1, %pstate
 
 	retl
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
