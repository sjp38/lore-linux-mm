Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1CF16B026B
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:06 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j49so62870826qta.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:06 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o64si3824816qkd.241.2016.12.16.10.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:36:05 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 09/14] sparc64: TLB/TSB miss handling for shared context
Date: Fri, 16 Dec 2016 10:35:32 -0800
Message-Id: <1481913337-9331-10-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Modifications to the fault handling code to take shared context TSB
into account.  For now, the shared context code mirrors the huge
page code.  The _PAGE_SHR_CTX_4V page flag is used to determine
which TSB should be used.

Note, TRAP_PER_CPU_TSB_HUGE_TEMP is used to stash away calculation
of a TTE address in the huge page TSB.  At present, tehre is no
similar mechanism for shared context TSB so the address must be
recalculated.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/kernel/sun4v_tlb_miss.S |   8 +++
 arch/sparc/kernel/tsb.S            | 122 ++++++++++++++++++++++++++++++++-----
 2 files changed, 116 insertions(+), 14 deletions(-)

diff --git a/arch/sparc/kernel/sun4v_tlb_miss.S b/arch/sparc/kernel/sun4v_tlb_miss.S
index 46fbc16..c438ccc 100644
--- a/arch/sparc/kernel/sun4v_tlb_miss.S
+++ b/arch/sparc/kernel/sun4v_tlb_miss.S
@@ -152,6 +152,14 @@ sun4v_tsb_miss_common:
 	sub	%g2, TRAP_PER_CPU_FAULT_INFO, %g2
 
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
+	/*
+	 * FIXME
+	 *
+	 * This just computes the possible huge page TSB entry.  It does
+	 * not consider the shared huge page TSB.  Also, care must be taken
+	 * so that TRAP_PER_CPU_TSB_HUGE_TEMP is only used for non-shared
+	 * huge TSB.
+	 */
 	mov	SCRATCHPAD_UTSBREG2, %g5
 	ldxa	[%g5] ASI_SCRATCHPAD, %g5
 	cmp	%g5, -1
diff --git a/arch/sparc/kernel/tsb.S b/arch/sparc/kernel/tsb.S
index 3ed3e7c..57ee5ad 100644
--- a/arch/sparc/kernel/tsb.S
+++ b/arch/sparc/kernel/tsb.S
@@ -55,6 +55,9 @@ tsb_miss_page_table_walk:
 	 */
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 
+	/*
+	 * First check the normal huge page TSB
+	 */
 661:	ldx		[%g7 + TRAP_PER_CPU_TSB_HUGE], %g5
 	nop
 	.section	.sun4v_2insn_patch, "ax"
@@ -64,7 +67,47 @@ tsb_miss_page_table_walk:
 	.previous
 
 	cmp		%g5, -1
-	be,pt		%xcc, 80f
+	be,pt		%xcc, chk_huge_page_shared
+	 nop
+
+	/* We need an aligned pair of registers containing 2 values
+	 * which can be easily rematerialized.  %g6 and %g7 foot the
+	 * bill just nicely.  We'll save %g6 away into %g2 for the
+	 * huge page TSB TAG comparison.
+	 *
+	 * Perform a huge page TSB lookup.
+	 */
+	mov		%g6, %g2
+
+	COMPUTE_TSB_PTR(%g5, %g4, REAL_HPAGE_SHIFT, %g6, %g7)
+
+	TSB_LOAD_QUAD(%g5, %g6)
+	cmp		%g6, %g2
+	be,a,pt		%xcc, tsb_tlb_reload
+	 mov		%g7, %g5
+
+	/*
+	 * No match, restore %g6 and %g7.
+	 * Store huge page TSB entry address
+	 *
+	 * FIXME - Look into use of TRAP_PER_CPU_TSB_HUGE_TEMP as it
+	 * is only used for regular, not shared huge pages.
+	 */
+	TRAP_LOAD_TRAP_BLOCK(%g7, %g6)
+	srlx		%g4, 22, %g6
+
+chk_huge_page_shared:
+	stx		%g5, [%g7 + TRAP_PER_CPU_TSB_HUGE_TEMP]
+
+	/*
+	 * For now (POC) only check shared context on hypervisor
+	 */
+	IF_TLB_TYPE_NOT_HYPE(%g2, huge_checks_done)
+
+	/* Check the shared huge page TSB */
+	ldx		[%g7 + TRAP_PER_CPU_TSB_HUGE_SHARED], %g5
+	cmp		%g5, -1
+	bne,pn		%xcc, huge_checks_done
 	 nop
 
 	/* We need an aligned pair of registers containing 2 values
@@ -75,15 +118,8 @@ tsb_miss_page_table_walk:
 	 * Perform a huge page TSB lookup.
 	 */
 	mov		%g6, %g2
-	and		%g5, 0x7, %g6
-	mov		512, %g7
-	andn		%g5, 0x7, %g5
-	sllx		%g7, %g6, %g7
-	srlx		%g4, REAL_HPAGE_SHIFT, %g6
-	sub		%g7, 1, %g7
-	and		%g6, %g7, %g6
-	sllx		%g6, 4, %g6
-	add		%g5, %g6, %g5
+
+	COMPUTE_TSB_PTR(%g5, %g4, REAL_HPAGE_SHIFT, %g6, %g7)
 
 	TSB_LOAD_QUAD(%g5, %g6)
 	cmp		%g6, %g2
@@ -91,25 +127,29 @@ tsb_miss_page_table_walk:
 	 mov		%g7, %g5
 
 	/* No match, remember the huge page TSB entry address,
-	 * and restore %g6 and %g7.
+	 * restore %g6 and %g7.
+	 *
+	 * NOT REALLY REMEMBERING -  See FIXME above
 	 */
 	TRAP_LOAD_TRAP_BLOCK(%g7, %g6)
 	srlx		%g4, 22, %g6
-80:	stx		%g5, [%g7 + TRAP_PER_CPU_TSB_HUGE_TEMP]
 
+huge_checks_done:
+	stx		%g5, [%g7 + TRAP_PER_CPU_TSB_HUGE_TEMP]
 #endif
 
 	ldx		[%g7 + TRAP_PER_CPU_PGD_PADDR], %g7
 
 	/* At this point we have:
-	 * %g1 --	TSB entry address
+	 * %g1 --	Base TSB entry address
 	 * %g3 --	FAULT_CODE_{D,I}TLB
 	 * %g4 --	missing virtual address
 	 * %g6 --	TAG TARGET (vaddr >> 22)
 	 * %g7 --	page table physical address
 	 *
 	 * We know that both the base PAGE_SIZE TSB and the HPAGE_SIZE
-	 * TSB both lack a matching entry.
+	 * TSB both lack a matching entry, as well as shared TSBs if
+	 * present.
 	 */
 tsb_miss_page_table_walk_sun4v_fastpath:
 	USER_PGTABLE_WALK_TL1(%g4, %g7, %g5, %g2, tsb_do_fault)
@@ -152,12 +192,42 @@ tsb_miss_page_table_walk_sun4v_fastpath:
 	 * thus handle it here.  This also makes sure that we can
 	 * allocate the TSB hash table on the correct NUMA node.
 	 */
+
+	/*
+	 * Check for shared context PTE, in this case we do not have
+	 * a saved TSB entry pointer and must compute now
+	 */
+	IF_TLB_TYPE_NOT_HYPE(%g2, no_shared_ctx_pte)
+
+	mov		_PAGE_SHR_CTX_4V, %g2
+	andcc		%g5, %g2, %g2
+	be,pn		%xcc, no_shared_ctx_pte
+
+	/*
+	 * If there was a shared context TSB, then we need to copmute the
+	 * TSB entry address.  Previously, only the non-shared context
+	 * TSB entry address was calculated.
+	 *
+	 * FIXME
+	 */
+	TRAP_LOAD_TRAP_BLOCK(%g7, %g1)
+	ldx		[%g7 + TRAP_PER_CPU_TSB_HUGE_SHARED], %g1
+	cmp		%g1, -1
+	be,pn		%xcc, no_shared_hugetlb
+	 nop
+
+	COMPUTE_TSB_PTR(%g1, %g4, REAL_HPAGE_SHIFT, %g2, %g7)
+
+	ba,a,pt %xcc,tsb_reload
+
+no_shared_ctx_pte:
 	TRAP_LOAD_TRAP_BLOCK(%g7, %g2)
 	ldx		[%g7 + TRAP_PER_CPU_TSB_HUGE_TEMP], %g1
 	cmp		%g1, -1
 	bne,pt		%xcc, 60f
 	 nop
 
+no_hugetlb:
 661:	rdpr		%pstate, %g5
 	wrpr		%g5, PSTATE_AG | PSTATE_MG, %pstate
 	.section	.sun4v_2insn_patch, "ax"
@@ -177,6 +247,30 @@ tsb_miss_page_table_walk_sun4v_fastpath:
 	ba,pt	%xcc, rtrap
 	 nop
 
+	/*
+	 * This is the same as above call to hugetlb_setup.
+	 * FIXME
+	 */
+no_shared_hugetlb:
+661:	rdpr		%pstate, %g5
+	wrpr		%g5, PSTATE_AG | PSTATE_MG, %pstate
+	.section	.sun4v_2insn_patch, "ax"
+	.word		661b
+	SET_GL(1)
+	nop
+	.previous
+
+	rdpr	%tl, %g7
+	cmp	%g7, 1
+	bne,pn	%xcc, winfix_trampoline
+	 mov	%g3, %g4
+	ba,pt	%xcc, etrap
+	 rd	%pc, %g7
+	call	hugetlb_shared_setup
+	 add	%sp, PTREGS_OFF, %o0
+	ba,pt	%xcc, rtrap
+	 nop
+
 60:
 #endif
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
