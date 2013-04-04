Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 141C66B0081
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:38 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:24:57 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 27EF8125804E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:29:43 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345wJts262460
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:19 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wKBf026926
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:22 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 21/25] powerpc: Handle hugepage in perf callchain
Date: Thu,  4 Apr 2013 11:27:59 +0530
Message-Id: <1365055083-31956-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/perf/callchain.c |   32 +++++++++++++++++++++-----------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/perf/callchain.c b/arch/powerpc/perf/callchain.c
index 578cac7..99262ce 100644
--- a/arch/powerpc/perf/callchain.c
+++ b/arch/powerpc/perf/callchain.c
@@ -115,7 +115,7 @@ static int read_user_stack_slow(void __user *ptr, void *ret, int nb)
 {
 	pgd_t *pgdir;
 	pte_t *ptep, pte;
-	unsigned shift;
+	unsigned shift, hugepage;
 	unsigned long addr = (unsigned long) ptr;
 	unsigned long offset;
 	unsigned long pfn;
@@ -125,20 +125,30 @@ static int read_user_stack_slow(void __user *ptr, void *ret, int nb)
 	if (!pgdir)
 		return -EFAULT;
 
-	ptep = find_linux_pte_or_hugepte(pgdir, addr, &shift, NULL);
+	ptep = find_linux_pte_or_hugepte(pgdir, addr, &shift, &hugepage);
 	if (!shift)
 		shift = PAGE_SHIFT;
 
-	/* align address to page boundary */
-	offset = addr & ((1UL << shift) - 1);
-	addr -= offset;
-
-	if (ptep == NULL)
-		return -EFAULT;
-	pte = *ptep;
-	if (!pte_present(pte) || !(pte_val(pte) & _PAGE_USER))
+	if (!ptep)
 		return -EFAULT;
-	pfn = pte_pfn(pte);
+
+	if (hugepage) {
+		pmd_t pmd = *(pmd_t *)ptep;
+		shift = mmu_psize_defs[MMU_PAGE_16M].shift;
+		offset = addr & ((1UL << shift) - 1);
+
+		if (!pmd_large(pmd) || !(pmd_val(pmd) & PMD_HUGE_USER))
+			return -EFAULT;
+		pfn = pmd_pfn(pmd);
+	} else {
+		offset = addr & ((1UL << shift) - 1);
+
+		pte = *ptep;
+		if (!pte_present(pte) || !(pte_val(pte) & _PAGE_USER))
+			return -EFAULT;
+		pfn = pte_pfn(pte);
+	}
+
 	if (!page_is_ram(pfn))
 		return -EFAULT;
 
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
