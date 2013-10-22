Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id AA20D6B00E2
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 12:04:41 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so8798136pbb.41
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 09:04:41 -0700 (PDT)
Received: from psmtp.com ([74.125.245.117])
        by mx.google.com with SMTP id u9si12073420pbf.113.2013.10.22.09.04.37
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 09:04:40 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 Oct 2013 21:34:31 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id C5C2C3940D17
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:13 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9MBSUom33751082
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:30 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9MBSXDV023036
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:33 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/9] powerpc: Free up _PAGE_COHERENCE for numa fault use later
Date: Tue, 22 Oct 2013 16:58:13 +0530
Message-Id: <1382441300-1513-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Set  memory coherence always on hash64 config. If
a platform cannot have memory coherence always set they
can infer that from _PAGE_NO_CACHE and _PAGE_WRITETHRU
like in lpar. So we dont' really need a separate bit
for tracking _PAGE_COHERENCE.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pte-hash64.h |  2 +-
 arch/powerpc/mm/hash_low_64.S         | 15 ++++++++++++---
 arch/powerpc/mm/hash_utils_64.c       |  7 ++++---
 arch/powerpc/mm/hugepage-hash64.c     |  6 +++++-
 arch/powerpc/mm/hugetlbpage-hash64.c  |  4 ++++
 5 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/include/asm/pte-hash64.h b/arch/powerpc/include/asm/pte-hash64.h
index 0419eeb..55aea0c 100644
--- a/arch/powerpc/include/asm/pte-hash64.h
+++ b/arch/powerpc/include/asm/pte-hash64.h
@@ -19,7 +19,7 @@
 #define _PAGE_FILE		0x0002 /* (!present only) software: pte holds file offset */
 #define _PAGE_EXEC		0x0004 /* No execute on POWER4 and newer (we invert) */
 #define _PAGE_GUARDED		0x0008
-#define _PAGE_COHERENT		0x0010 /* M: enforce memory coherence (SMP systems) */
+/* We can derive Memory coherence from _PAGE_NO_CACHE */
 #define _PAGE_NO_CACHE		0x0020 /* I: cache inhibit */
 #define _PAGE_WRITETHRU		0x0040 /* W: cache write-through */
 #define _PAGE_DIRTY		0x0080 /* C: page changed */
diff --git a/arch/powerpc/mm/hash_low_64.S b/arch/powerpc/mm/hash_low_64.S
index d3cbda6..1136d26 100644
--- a/arch/powerpc/mm/hash_low_64.S
+++ b/arch/powerpc/mm/hash_low_64.S
@@ -148,7 +148,10 @@ END_MMU_FTR_SECTION_IFSET(MMU_FTR_1T_SEGMENT)
 	and	r0,r0,r4		/* _PAGE_RW & _PAGE_DIRTY ->r0 bit 30*/
 	andc	r0,r30,r0		/* r0 = pte & ~r0 */
 	rlwimi	r3,r0,32-1,31,31	/* Insert result into PP lsb */
-	ori	r3,r3,HPTE_R_C		/* Always add "C" bit for perf. */
+	/*
+	 * Always add "C" bit for perf. Memory coherence is always enabled
+	 */
+	ori	r3,r3,HPTE_R_C | HPTE_R_M
 
 	/* We eventually do the icache sync here (maybe inline that
 	 * code rather than call a C function...) 
@@ -457,7 +460,10 @@ END_MMU_FTR_SECTION_IFSET(MMU_FTR_1T_SEGMENT)
 	and	r0,r0,r4		/* _PAGE_RW & _PAGE_DIRTY ->r0 bit 30*/
 	andc	r0,r3,r0		/* r0 = pte & ~r0 */
 	rlwimi	r3,r0,32-1,31,31	/* Insert result into PP lsb */
-	ori	r3,r3,HPTE_R_C		/* Always add "C" bit for perf. */
+	/*
+	 * Always add "C" bit for perf. Memory coherence is always enabled
+	 */
+	ori	r3,r3,HPTE_R_C | HPTE_R_M
 
 	/* We eventually do the icache sync here (maybe inline that
 	 * code rather than call a C function...)
@@ -795,7 +801,10 @@ END_MMU_FTR_SECTION_IFSET(MMU_FTR_1T_SEGMENT)
 	and	r0,r0,r4		/* _PAGE_RW & _PAGE_DIRTY ->r0 bit 30*/
 	andc	r0,r30,r0		/* r0 = pte & ~r0 */
 	rlwimi	r3,r0,32-1,31,31	/* Insert result into PP lsb */
-	ori	r3,r3,HPTE_R_C		/* Always add "C" bit for perf. */
+	/*
+	 * Always add "C" bit for perf. Memory coherence is always enabled
+	 */
+	ori	r3,r3,HPTE_R_C | HPTE_R_M
 
 	/* We eventually do the icache sync here (maybe inline that
 	 * code rather than call a C function...)
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index bde8b55..fb176e9 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -169,9 +169,10 @@ static unsigned long htab_convert_pte_flags(unsigned long pteflags)
 	if ((pteflags & _PAGE_USER) && !((pteflags & _PAGE_RW) &&
 					 (pteflags & _PAGE_DIRTY)))
 		rflags |= 1;
-
-	/* Always add C */
-	return rflags | HPTE_R_C;
+	/*
+	 * Always add "C" bit for perf. Memory coherence is always enabled
+	 */
+	return rflags | HPTE_R_C | HPTE_R_M;
 }
 
 int htab_bolt_mapping(unsigned long vstart, unsigned long vend,
diff --git a/arch/powerpc/mm/hugepage-hash64.c b/arch/powerpc/mm/hugepage-hash64.c
index 34de9e0..826893f 100644
--- a/arch/powerpc/mm/hugepage-hash64.c
+++ b/arch/powerpc/mm/hugepage-hash64.c
@@ -127,7 +127,11 @@ repeat:
 
 		/* Add in WIMG bits */
 		rflags |= (new_pmd & (_PAGE_WRITETHRU | _PAGE_NO_CACHE |
-				      _PAGE_COHERENT | _PAGE_GUARDED));
+				      _PAGE_GUARDED));
+		/*
+		 * enable the memory coherence always
+		 */
+		rflags |= HPTE_R_M;
 
 		/* Insert into the hash table, primary slot */
 		slot = ppc_md.hpte_insert(hpte_group, vpn, pa, rflags, 0,
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index 0b7fb67..a5bcf93 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -99,6 +99,10 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 		/* Add in WIMG bits */
 		rflags |= (new_pte & (_PAGE_WRITETHRU | _PAGE_NO_CACHE |
 				      _PAGE_COHERENT | _PAGE_GUARDED));
+		/*
+		 * enable the memory coherence always
+		 */
+		rflags |= HPTE_R_M;
 
 		slot = hpte_insert_repeating(hash, vpn, pa, rflags, 0,
 					     mmu_psize, ssize);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
