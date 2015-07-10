Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 849689003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:50:35 -0400 (EDT)
Received: by padck2 with SMTP id ck2so7221252pad.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 10:50:35 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ko11si14827141pbd.60.2015.07.10.10.42.31
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 10:42:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 22/36] sparc, thp: remove infrastructure for handling splitting PMDs
Date: Fri, 10 Jul 2015 20:41:56 +0300
Message-Id: <1436550130-112636-23-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we don't need to mark PMDs splitting. Let's drop
code to handle this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/sparc/include/asm/pgtable_64.h | 16 ----------------
 arch/sparc/mm/fault_64.c            |  3 ---
 arch/sparc/mm/gup.c                 |  2 +-
 3 files changed, 1 insertion(+), 20 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 5833dc5ee7d7..7a38d6a576c5 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -681,13 +681,6 @@ static inline unsigned long pmd_trans_huge(pmd_t pmd)
 	return pte_val(pte) & _PAGE_PMD_HUGE;
 }
 
-static inline unsigned long pmd_trans_splitting(pmd_t pmd)
-{
-	pte_t pte = __pte(pmd_val(pmd));
-
-	return pmd_trans_huge(pmd) && pte_special(pte);
-}
-
 #define has_transparent_hugepage() 1
 
 static inline pmd_t pmd_mkold(pmd_t pmd)
@@ -744,15 +737,6 @@ static inline pmd_t pmd_mkwrite(pmd_t pmd)
 	return __pmd(pte_val(pte));
 }
 
-static inline pmd_t pmd_mksplitting(pmd_t pmd)
-{
-	pte_t pte = __pte(pmd_val(pmd));
-
-	pte = pte_mkspecial(pte);
-
-	return __pmd(pte_val(pte));
-}
-
 static inline pgprot_t pmd_pgprot(pmd_t entry)
 {
 	unsigned long val = pmd_val(entry);
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 479823249429..a504a4d85ebd 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -113,9 +113,6 @@ static unsigned int get_user_insn(unsigned long tpc)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	if (pmd_trans_huge(*pmdp)) {
-		if (pmd_trans_splitting(*pmdp))
-			goto out_irq_enable;
-
 		pa  = pmd_pfn(*pmdp) << PAGE_SHIFT;
 		pa += tpc & ~HPAGE_MASK;
 
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index 9091c5daa2e1..eb3d8e8ebc6b 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -114,7 +114,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		pmd_t pmd = *pmdp;
 
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+		if (pmd_none(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd))) {
 			if (!gup_huge_pmd(pmdp, pmd, addr, next,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
