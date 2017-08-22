Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4214C2803D0
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:44:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k10so108277480pgs.11
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 03:44:09 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i8si8541642pgf.434.2017.08.22.03.44.07
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 03:44:08 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v7 2/9] arm64: hugetlb: Introduce pte_pgprot helper
Date: Tue, 22 Aug 2017 11:42:42 +0100
Message-Id: <20170822104249.2189-3-punit.agrawal@arm.com>
In-Reply-To: <20170822104249.2189-1-punit.agrawal@arm.com>
References: <20170822104249.2189-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, Punit Agrawal <punit.agrawal@arm.com>

From: Steve Capper <steve.capper@arm.com>

Rather than xor pte bits in various places, use this helper function.

Cc: David Woods <dwoods@mellanox.com>
Signed-off-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Reviewed-by: Mark Rutland <mark.rutland@arm.com>
---
 arch/arm64/mm/hugetlbpage.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 7b61e4833432..cb84ca33bc6b 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -41,6 +41,16 @@ int pud_huge(pud_t pud)
 #endif
 }
 
+/*
+ * Select all bits except the pfn
+ */
+static inline pgprot_t pte_pgprot(pte_t pte)
+{
+	unsigned long pfn = pte_pfn(pte);
+
+	return __pgprot(pte_val(pfn_pte(pfn, __pgprot(0))) ^ pte_val(pte));
+}
+
 static int find_num_contig(struct mm_struct *mm, unsigned long addr,
 			   pte_t *ptep, size_t *pgsize)
 {
@@ -80,7 +90,7 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 
 	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
 	pfn = pte_pfn(pte);
-	hugeprot = __pgprot(pte_val(pfn_pte(pfn, __pgprot(0))) ^ pte_val(pte));
+	hugeprot = pte_pgprot(pte);
 	for (i = 0; i < ncontig; i++) {
 		pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
 			 pte_val(pfn_pte(pfn, hugeprot)));
@@ -223,9 +233,7 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 		size_t pgsize = 0;
 		unsigned long pfn = pte_pfn(pte);
 		/* Select all bits except the pfn */
-		pgprot_t hugeprot =
-			__pgprot(pte_val(pfn_pte(pfn, __pgprot(0))) ^
-				 pte_val(pte));
+		pgprot_t hugeprot = pte_pgprot(pte);
 
 		pfn = pte_pfn(pte);
 		ncontig = find_num_contig(vma->vm_mm, addr, ptep,
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
