Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 2FF196B002D
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 03:06:11 -0500 (EST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Feb 2013 18:01:26 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A439B2BB004F
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:06:05 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1Q7rT9G66977870
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 18:53:29 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1Q86430008711
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:06:05 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 21/24] powerpc: Handle huge page in perf callchain
Date: Tue, 26 Feb 2013 13:35:11 +0530
Message-Id: <1361865914-13911-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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
