Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B91216B000C
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:19:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f8-v6so3319010eds.6
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:19:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b24-v6si4385723edj.131.2018.07.25.09.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 09:19:27 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6PGEN4X008009
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:19:25 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kevj206rf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:19:25 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 25 Jul 2018 12:19:24 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V2 3/6] powerpc/mm/book3s: Check for pmd_large instead of pmd_trans_huge
Date: Wed, 25 Jul 2018 21:49:00 +0530
In-Reply-To: <20180725161903.31257-1-aneesh.kumar@linux.ibm.com>
References: <20180725161903.31257-1-aneesh.kumar@linux.ibm.com>
Message-Id: <20180725161903.31257-3-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

Update few code paths to check for pmd_large.

set_pmd_at:
We want to use this to store swap pte at pmd level. For swap ptes we don't want
to set H_PAGE_THP_HUGE. Hence check for pmd_large in set_pmd_at. This remove
the false WARN_ON when using this with swap pmd entry.

pmd_page:
We don't really use them on pmd migration entries. But they can also work with
migration entries and we don't differentiate at the pte level. Hence update
pmd_page to work with pmd migration entries too

__find_linux_pte:
lockless page table walk need to handle pmd migration entries. pmd_trans_huge
check will return false on them. We don't set thp = 1 for such entries, but
update hpage_shift correctly. Without this we will walk pmd migration entries
as a pte page pointer which is wrong.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/mm/hugetlbpage.c      | 8 ++++++--
 arch/powerpc/mm/pgtable-book3s64.c | 2 +-
 arch/powerpc/mm/pgtable_64.c       | 2 +-
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 7ae5e4bfd318..80fdeec89698 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -846,8 +846,12 @@ pte_t *__find_linux_pte(pgd_t *pgdir, unsigned long ea,
 				ret_pte = (pte_t *) pmdp;
 				goto out;
 			}
-
-			if (pmd_huge(pmd)) {
+			/*
+			 * pmd_large check below will handle the swap pmd pte
+			 * we need to do both the check because they are config
+			 * dependent.
+			 */
+			if (pmd_huge(pmd) || pmd_large(pmd)) {
 				ret_pte = (pte_t *) pmdp;
 				goto out;
 			} else if (is_hugepd(__hugepd(pmd_val(pmd))))
diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
index 24346ab4cd37..16d963f281a3 100644
--- a/arch/powerpc/mm/pgtable-book3s64.c
+++ b/arch/powerpc/mm/pgtable-book3s64.c
@@ -71,7 +71,7 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 #ifdef CONFIG_DEBUG_VM
 	WARN_ON(pte_present(pmd_pte(*pmdp)) && !pte_protnone(pmd_pte(*pmdp)));
 	assert_spin_locked(pmd_lockptr(mm, pmdp));
-	WARN_ON(!(pmd_trans_huge(pmd) || pmd_devmap(pmd)));
+	WARN_ON(!(pmd_large(pmd) || pmd_devmap(pmd)));
 #endif
 	trace_hugepage_set_pmd(addr, pmd_val(pmd));
 	return set_pte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 53e9eeecd5d4..e15e63079ba8 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -306,7 +306,7 @@ struct page *pud_page(pud_t pud)
  */
 struct page *pmd_page(pmd_t pmd)
 {
-	if (pmd_trans_huge(pmd) || pmd_huge(pmd) || pmd_devmap(pmd))
+	if (pmd_large(pmd) || pmd_huge(pmd) || pmd_devmap(pmd))
 		return pte_page(pmd_pte(pmd));
 	return virt_to_page(pmd_page_vaddr(pmd));
 }
-- 
2.17.1
