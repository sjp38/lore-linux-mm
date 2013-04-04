Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 16DE86B0006
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:20 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:25:13 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 552D83940023
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:28:14 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345wAgg11469076
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:10 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wCHc026422
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:13 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 03/25] powerpc: Don't hard code the size of pte page
Date: Thu,  4 Apr 2013 11:27:41 +0530
Message-Id: <1365055083-31956-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

USE PTRS_PER_PTE to indicate the size of pte page. To support THP,
later patches will be changing PTRS_PER_PTE value.

Acked-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable.h |    6 ++++++
 arch/powerpc/mm/hash_low_64.S      |    4 ++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index a9cbd3b..4b52726 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -17,6 +17,12 @@ struct mm_struct;
 #  include <asm/pgtable-ppc32.h>
 #endif
 
+/*
+ * We save the slot number & secondary bit in the second half of the
+ * PTE page. We use the 8 bytes per each pte entry.
+ */
+#define PTE_PAGE_HIDX_OFFSET (PTRS_PER_PTE * 8)
+
 #ifndef __ASSEMBLY__
 
 #include <asm/tlbflush.h>
diff --git a/arch/powerpc/mm/hash_low_64.S b/arch/powerpc/mm/hash_low_64.S
index 7443481..abdd5e2 100644
--- a/arch/powerpc/mm/hash_low_64.S
+++ b/arch/powerpc/mm/hash_low_64.S
@@ -490,7 +490,7 @@ END_FTR_SECTION(CPU_FTR_NOEXECUTE|CPU_FTR_COHERENT_ICACHE, CPU_FTR_NOEXECUTE)
 	beq	htab_inval_old_hpte
 
 	ld	r6,STK_PARAM(R6)(r1)
-	ori	r26,r6,0x8000		/* Load the hidx mask */
+	ori	r26,r6,PTE_PAGE_HIDX_OFFSET /* Load the hidx mask. */
 	ld	r26,0(r26)
 	addi	r5,r25,36		/* Check actual HPTE_SUB bit, this */
 	rldcr.	r0,r31,r5,0		/* must match pgtable.h definition */
@@ -607,7 +607,7 @@ htab_pte_insert_ok:
 	sld	r4,r4,r5
 	andc	r26,r26,r4
 	or	r26,r26,r3
-	ori	r5,r6,0x8000
+	ori	r5,r6,PTE_PAGE_HIDX_OFFSET
 	std	r26,0(r5)
 	lwsync
 	std	r30,0(r6)
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
