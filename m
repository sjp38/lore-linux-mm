Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE6E56B02C3
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 10:54:43 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y129so176050165pgy.1
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 07:54:43 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k33si2586649pld.372.2017.08.18.07.54.42
        for <linux-mm@kvack.org>;
        Fri, 18 Aug 2017 07:54:42 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v2] mm/hugetlb.c: make huge_pte_offset() consistent and document behaviour
Date: Fri, 18 Aug 2017 15:54:15 +0100
Message-Id: <20170818145415.7588-1-punit.agrawal@arm.com>
In-Reply-To: <20170725154114.24131-2-punit.agrawal@arm.com>
References: <20170725154114.24131-2-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

When walking the page tables to resolve an address that points to
!p*d_present() entry, huge_pte_offset() returns inconsistent values
depending on the level of page table (PUD or PMD).

It returns NULL in the case of a PUD entry while in the case of a PMD
entry, it returns a pointer to the page table entry.

A similar inconsitency exists when handling swap entries - returns NULL
for a PUD entry while a pointer to the pte_t is retured for the PMD entry.

Update huge_pte_offset() to make the behaviour consistent - return a
pointer to the pte_t for hugepage or swap entries. Only return NULL in
instances where we have a p*d_none() entry and the size parameter
doesn't match the hugepage size at this level of the page table.

Document the behaviour to clarify the expected behaviour of this function.
This is to set clear semantics for architecture specific implementations
of huge_pte_offset().

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Steve Capper <steve.capper@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
---

Hi Andrew,

>From discussions on the arm64 implementation of huge_pte_offset()[0]
we realised that there is benefit from returning a pte_t* in the case
of p*d_none().

The fault handling code in hugetlb_fault() can handle p*d_none()
entries and saves an extra round trip to huge_pte_alloc(). Other
callers of huge_pte_offset() should be ok as well.

Apologies for sending a late update but I thought if we are defining
the semantics, it's worth getting them right.

Could you please pick this version please?

Thanks,
Punit

[0] http://www.spinics.net/lists/linux-mm/msg133699.html

v2: 

 mm/hugetlb.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 31e207cb399b..1d54a131bdd5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4600,6 +4600,15 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
+/*
+ * huge_pte_offset() - Walk the page table to resolve the hugepage
+ * entry at address @addr
+ *
+ * Return: Pointer to page table or swap entry (PUD or PMD) for
+ * address @addr, or NULL if a p*d_none() entry is encountered and the
+ * size @sz doesn't match the hugepage size at this level of the page
+ * table.
+ */
 pte_t *huge_pte_offset(struct mm_struct *mm,
 		       unsigned long addr, unsigned long sz)
 {
@@ -4614,13 +4623,22 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 	p4d = p4d_offset(pgd, addr);
 	if (!p4d_present(*p4d))
 		return NULL;
+
 	pud = pud_offset(p4d, addr);
-	if (!pud_present(*pud))
+	if (sz != PUD_SIZE && pud_none(*pud))
 		return NULL;
-	if (pud_huge(*pud))
+	/* hugepage or swap? */
+	if (pud_huge(*pud) || !pud_present(*pud))
 		return (pte_t *)pud;
+
 	pmd = pmd_offset(pud, addr);
-	return (pte_t *) pmd;
+	if (sz != PMD_SIZE && pmd_none(*pmd))
+		return NULL;
+	/* hugepage or swap? */
+	if (pmd_huge(*pmd) || !pmd_present(*pmd))
+		return (pte_t *)pmd;
+
+	return NULL;
 }
 
 #endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
