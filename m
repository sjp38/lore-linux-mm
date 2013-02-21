Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 3219F6B002D
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:48:07 -0500 (EST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 22:16:02 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id B1E97E0057
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:19:02 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LGlxZm30015540
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:59 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LGm0Ze011583
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 03:48:01 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH -V2 21/21] powerpc/THP: Enable THP on PPC64
Date: Thu, 21 Feb 2013 22:17:28 +0530
Message-Id: <1361465248-10867-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We enable only if the we support 16MB page size.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable.h |   33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 5b8e93b..ae9114b 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -107,8 +107,37 @@ static inline int pmd_trans_huge(pmd_t pmd)
 	return ((pmd_val(pmd) & PMD_ISHUGE) ==  PMD_ISHUGE);
 }
 
-/* We will enable it in the last patch */
-#define has_transparent_hugepage() 0
+static inline int has_transparent_hugepage(void)
+{
+	if (!mmu_has_feature(MMU_FTR_16M_PAGE))
+		return 0;
+	/*
+	 * We support THP only if HPAGE_SHIFT is 16MB.
+	 */
+	if (!HPAGE_SHIFT || (HPAGE_SHIFT != mmu_psize_defs[MMU_PAGE_16M].shift))
+		return 0;
+	/*
+	 * We need to make sure that we support 16MB huge page in a segement
+	 * with base page size 64K or 4K. We only enable THP with a PAGE_SIZE
+	 * of 64K.
+	 */
+	/* FIXME!! is the nonzero check always correct ? Can there be an machine
+	 * where penc is 0 ?
+	 */
+	/*
+	 * If we have 64K HPTE, we will be using that by default
+	 */
+	if (mmu_psize_defs[MMU_PAGE_64K].shift &&
+	    !mmu_psize_defs[MMU_PAGE_64K].penc[MMU_PAGE_16M])
+		return 0;
+	/*
+	 * Ok we only have 4K HPTE
+	 */
+	if (!mmu_psize_defs[MMU_PAGE_4K].penc[MMU_PAGE_16M])
+		return 0;
+
+	return 1;
+}
 
 static inline pmd_t pmd_mkold(pmd_t pmd)
 {
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
