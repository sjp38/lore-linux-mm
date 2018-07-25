Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D3A436B0266
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:19:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b25-v6so3282165eds.17
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:19:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v57-v6si1356074edm.88.2018.07.25.09.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 09:19:36 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6PGFgW8055717
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:19:34 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2keu9rm1wb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:19:34 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 25 Jul 2018 12:19:32 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V2 5/6] powerpc/mm/thp: update pmd_trans_huge to check for pmd_present
Date: Wed, 25 Jul 2018 21:49:02 +0530
In-Reply-To: <20180725161903.31257-1-aneesh.kumar@linux.ibm.com>
References: <20180725161903.31257-1-aneesh.kumar@linux.ibm.com>
Message-Id: <20180725161903.31257-5-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

We need to make sure pmd_trans_huge returns false for a pmd migration entry.
We mark the migration entry by clearing the _PAGE_PRESENT bit. We keep the
_PAGE_PTE bit set to indicate a leaf page table entry. Hence we need to make
sure we check for pmd_present() so that pmd_trans_huge won't return true on
pmd migration entry.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 .../include/asm/book3s/64/pgtable-64k.h        |  3 +++
 arch/powerpc/include/asm/book3s/64/pgtable.h   | 18 ++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable-64k.h b/arch/powerpc/include/asm/book3s/64/pgtable-64k.h
index d7ee249d6890..e3d4dd4ae2fa 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable-64k.h
@@ -10,6 +10,9 @@
  *
  * Defined in such a way that we can optimize away code block at build time
  * if CONFIG_HUGETLB_PAGE=n.
+ *
+ * returns true for pmd migration entries, THP, devmap, hugetlb
+ * But compile time dependent on CONFIG_HUGETLB_PAGE
  */
 static inline int pmd_huge(pmd_t pmd)
 {
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index fce9ce8781a0..8b80c5e16896 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -1129,6 +1129,10 @@ pmd_hugepage_update(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp,
 	return hash__pmd_hugepage_update(mm, addr, pmdp, clr, set);
 }
 
+/*
+ * returns true for pmd migration entries, THP, devmap, hugetlb
+ * But compile time dependent on THP config
+ */
 static inline int pmd_large(pmd_t pmd)
 {
 	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
@@ -1163,8 +1167,22 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 		pmd_hugepage_update(mm, addr, pmdp, 0, _PAGE_PRIVILEGED);
 }
 
+/*
+ * Only returns true for a THP. False for pmd migration entry.
+ * We also need to return true when we come across a pte that
+ * in between a thp split. While splitting THP, we mark the pmd
+ * invalid (pmdp_invalidate()) before we set it with pte page
+ * address. A pmd_trans_huge() check against a pmd entry during that time
+ * should return true.
+ * We should not call this on a hugetlb entry. We should check for HugeTLB
+ * entry using vma->vm_flags
+ * The page table walk rule is explained in Documentation/vm/transhuge.rst
+ */
 static inline int pmd_trans_huge(pmd_t pmd)
 {
+	if (!pmd_present(pmd))
+		return false;
+
 	if (radix_enabled())
 		return radix__pmd_trans_huge(pmd);
 	return hash__pmd_trans_huge(pmd);
-- 
2.17.1
