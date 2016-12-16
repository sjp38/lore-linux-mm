Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE7D66B0268
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:03 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j49so62870050qta.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:03 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j32si3817655qte.316.2016.12.16.10.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:36:03 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 07/14] sparc64: move COMPUTE_TAG_TARGET and COMPUTE_TSB_PTR to header file
Date: Fri, 16 Dec 2016 10:35:30 -0800
Message-Id: <1481913337-9331-8-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Move macros COMPUTE_TSB_PTR and COMPUTE_TSB_PTR out of .S file to
headers so that they can be used in other files.

Also, add new macro IF_TLB_TYPE_NOT_HYPE

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/include/asm/tsb.h       | 38 ++++++++++++++++++++++++++++++++++++++
 arch/sparc/kernel/sun4v_tlb_miss.S | 29 ++---------------------------
 2 files changed, 40 insertions(+), 27 deletions(-)

diff --git a/arch/sparc/include/asm/tsb.h b/arch/sparc/include/asm/tsb.h
index 311cd4e..bb7df61 100644
--- a/arch/sparc/include/asm/tsb.h
+++ b/arch/sparc/include/asm/tsb.h
@@ -75,6 +75,44 @@ extern struct tsb_phys_patch_entry __tsb_phys_patch, __tsb_phys_patch_end;
 
 extern struct kmem_cache *shared_mmu_ctx_cachep __read_mostly;
 #endif
+
+	/*
+	 * If tlb type is not hypervisor, branch to label
+	 */
+#define	IF_TLB_TYPE_NOT_HYPE(TMP, NOT_HYPE_LABEL)	\
+	sethi	%hi(tlb_type), TMP;			\
+	lduw	[TMP + %lo(tlb_type)], TMP;		\
+	cmp	TMP, 3;					\
+	bne,pn	%icc, NOT_HYPE_LABEL;			\
+	nop
+
+	/* DEST = (VADDR >> 22)
+	 *
+	 * Branch to ZERO_CTX_LABEL if context is zero.
+	 */
+#define	COMPUTE_TAG_TARGET(DEST, VADDR, CTX, ZERO_CTX_LABEL) \
+	srlx	VADDR, 22, DEST; \
+	brz,pn	CTX, ZERO_CTX_LABEL; \
+	 nop;
+
+	/* Create TSB pointer.  This is something like:
+	 *
+	 * index_mask = (512 << (tsb_reg & 0x7UL)) - 1UL;
+	 * tsb_base = tsb_reg & ~0x7UL;
+	 * tsb_index = ((vaddr >> HASH_SHIFT) & tsb_mask);
+	 * tsb_ptr = tsb_base + (tsb_index * 16);
+	 */
+#define COMPUTE_TSB_PTR(TSB_PTR, VADDR, HASH_SHIFT, TMP1, TMP2) \
+	and	TSB_PTR, 0x7, TMP1;			\
+	mov	512, TMP2;				\
+	andn	TSB_PTR, 0x7, TSB_PTR;			\
+	sllx	TMP2, TMP1, TMP2;			\
+	srlx	VADDR, HASH_SHIFT, TMP1;		\
+	sub	TMP2, 1, TMP2;				\
+	and	TMP1, TMP2, TMP1;			\
+	sllx	TMP1, 4, TMP1;				\
+	add	TSB_PTR, TMP1, TSB_PTR;
+
 #define TSB_LOAD_QUAD(TSB, REG)	\
 661:	ldda		[TSB] ASI_NUCLEUS_QUAD_LDD, REG; \
 	.section	.tsb_ldquad_phys_patch, "ax"; \
diff --git a/arch/sparc/kernel/sun4v_tlb_miss.S b/arch/sparc/kernel/sun4v_tlb_miss.S
index 6179e19..46fbc16 100644
--- a/arch/sparc/kernel/sun4v_tlb_miss.S
+++ b/arch/sparc/kernel/sun4v_tlb_miss.S
@@ -3,6 +3,8 @@
  * Copyright (C) 2006 <davem@davemloft.net>
  */
 
+#include <asm/tsb.h>
+
 	.text
 	.align	32
 
@@ -16,33 +18,6 @@
 	ldx	[BASE + HV_FAULT_D_ADDR_OFFSET], VADDR; \
 	ldx	[BASE + HV_FAULT_D_CTX_OFFSET], CTX;
 
-	/* DEST = (VADDR >> 22)
-	 *
-	 * Branch to ZERO_CTX_LABEL if context is zero.
-	 */
-#define	COMPUTE_TAG_TARGET(DEST, VADDR, CTX, ZERO_CTX_LABEL) \
-	srlx	VADDR, 22, DEST; \
-	brz,pn	CTX, ZERO_CTX_LABEL; \
-	 nop;
-
-	/* Create TSB pointer.  This is something like:
-	 *
-	 * index_mask = (512 << (tsb_reg & 0x7UL)) - 1UL;
-	 * tsb_base = tsb_reg & ~0x7UL;
-	 * tsb_index = ((vaddr >> HASH_SHIFT) & tsb_mask);
-	 * tsb_ptr = tsb_base + (tsb_index * 16);
-	 */
-#define COMPUTE_TSB_PTR(TSB_PTR, VADDR, HASH_SHIFT, TMP1, TMP2) \
-	and	TSB_PTR, 0x7, TMP1;			\
-	mov	512, TMP2;				\
-	andn	TSB_PTR, 0x7, TSB_PTR;			\
-	sllx	TMP2, TMP1, TMP2;			\
-	srlx	VADDR, HASH_SHIFT, TMP1;		\
-	sub	TMP2, 1, TMP2;				\
-	and	TMP1, TMP2, TMP1;			\
-	sllx	TMP1, 4, TMP1;				\
-	add	TSB_PTR, TMP1, TSB_PTR;
-
 sun4v_itlb_miss:
 	/* Load MMU Miss base into %g2.  */
 	ldxa	[%g0] ASI_SCRATCHPAD, %g2
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
