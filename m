Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8826B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 13:33:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v68so135072410pfi.13
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 10:33:50 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t69si7158830pgd.95.2017.07.24.10.33.48
        for <linux-mm@kvack.org>;
        Mon, 24 Jul 2017 10:33:49 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [RFC PATCH 1/2] mm/hugetlb: Make huge_pte_offset() consistent between PUD and PMD entries
Date: Mon, 24 Jul 2017 18:33:17 +0100
Message-Id: <20170724173318.966-2-punit.agrawal@arm.com>
In-Reply-To: <20170724173318.966-1-punit.agrawal@arm.com>
References: <20170724173318.966-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Punit Agrawal <punit.agrawal@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, steve.capper@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

When walking the page tables to resolve an address that points to
!present_p*d() entry, huge_pte_offset() returns inconsistent values
depending on the level of page table (PUD or PMD).

In the case of a PUD entry, it returns NULL while in the case of a PMD
entry, it returns a pointer to the page table entry.

Make huge_pte_offset() consistent by always returning NULL on
encountering a !present_p*d() entry. Document the behaviour to clarify
the expected semantics of this function.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
---
 mm/hugetlb.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc48ee783dd9..686eb6fa9eb1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4603,6 +4603,13 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
+/*
+ * huge_pte_offset() - Walk the page table to resolve the hugepage
+ * entry at address @addr
+ *
+ * Return: Pointer to page table entry (PUD or PMD) for address @addr
+ * or NULL if the entry is not present.
+ */
 pte_t *huge_pte_offset(struct mm_struct *mm,
 		       unsigned long addr, unsigned long sz)
 {
@@ -4617,13 +4624,20 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 	p4d = p4d_offset(pgd, addr);
 	if (!p4d_present(*p4d))
 		return NULL;
+
 	pud = pud_offset(p4d, addr);
 	if (!pud_present(*pud))
 		return NULL;
 	if (pud_huge(*pud))
 		return (pte_t *)pud;
+
 	pmd = pmd_offset(pud, addr);
-	return (pte_t *) pmd;
+	if (!pmd_present(*pmd))
+		return NULL;
+	if (pmd_huge(*pmd))
+		return (pte_t *) pmd;
+
+	return NULL;
 }
 
 #endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
