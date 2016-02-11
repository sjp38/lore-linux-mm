Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 67C816B0253
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 04:29:19 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id e127so26738249pfe.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 01:29:19 -0800 (PST)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id r1si11438488pfa.220.2016.02.11.01.29.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 01:29:18 -0800 (PST)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 2/2] ARC: mm: THP: use generic THP deposit/withdraw
Date: Thu, 11 Feb 2016 14:58:27 +0530
Message-ID: <1455182907-15445-3-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1455182907-15445-1-git-send-email-vgupta@synopsys.com>
References: <1455182907-15445-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Generic code can now cope with pgtable_t != struct page *

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/hugepage.h |  8 --------
 arch/arc/mm/tlb.c               | 37 -------------------------------------
 2 files changed, 45 deletions(-)

diff --git a/arch/arc/include/asm/hugepage.h b/arch/arc/include/asm/hugepage.h
index c5094de86403..8653ed2f2ec5 100644
--- a/arch/arc/include/asm/hugepage.h
+++ b/arch/arc/include/asm/hugepage.h
@@ -66,14 +66,6 @@ extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
 
 #define has_transparent_hugepage() 1
 
-/* Generic variants assume pgtable_t is struct page *, hence need for these */
-#define __HAVE_ARCH_PGTABLE_DEPOSIT
-extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
-				       pgtable_t pgtable);
-
-#define __HAVE_ARCH_PGTABLE_WITHDRAW
-extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
-
 #define __HAVE_ARCH_FLUSH_PMD_TLB_RANGE
 extern void flush_pmd_tlb_range(struct vm_area_struct *vma, unsigned long start,
 				unsigned long end);
diff --git a/arch/arc/mm/tlb.c b/arch/arc/mm/tlb.c
index 2e731c87011e..b300479b8ad3 100644
--- a/arch/arc/mm/tlb.c
+++ b/arch/arc/mm/tlb.c
@@ -663,43 +663,6 @@ void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
 	update_mmu_cache(vma, addr, &pte);
 }
 
-void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
-				pgtable_t pgtable)
-{
-	struct list_head *lh = (struct list_head *) pgtable;
-
-	assert_spin_locked(&mm->page_table_lock);
-
-	/* FIFO */
-	if (!pmd_huge_pte(mm, pmdp))
-		INIT_LIST_HEAD(lh);
-	else
-		list_add(lh, (struct list_head *) pmd_huge_pte(mm, pmdp));
-	pmd_huge_pte(mm, pmdp) = pgtable;
-}
-
-pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
-{
-	struct list_head *lh;
-	pgtable_t pgtable;
-
-	assert_spin_locked(&mm->page_table_lock);
-
-	pgtable = pmd_huge_pte(mm, pmdp);
-	lh = (struct list_head *) pgtable;
-	if (list_empty(lh))
-		pmd_huge_pte(mm, pmdp) = NULL;
-	else {
-		pmd_huge_pte(mm, pmdp) = (pgtable_t) lh->next;
-		list_del(lh);
-	}
-
-	pte_val(pgtable[0]) = 0;
-	pte_val(pgtable[1]) = 0;
-
-	return pgtable;
-}
-
 void local_flush_pmd_tlb_range(struct vm_area_struct *vma, unsigned long start,
 			       unsigned long end)
 {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
