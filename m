Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 129FE6B0295
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 11:53:08 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e19-v6so5014599pgv.11
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:53:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i13-v6sor4057961pgi.127.2018.07.25.08.53.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 08:53:06 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 4/4] mm: optimise flushing and pte manipulation for single threaded access
Date: Thu, 26 Jul 2018 01:52:46 +1000
Message-Id: <20180725155246.1085-5-npiggin@gmail.com>
In-Reply-To: <20180725155246.1085-1-npiggin@gmail.com>
References: <20180725155246.1085-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-arch@vger.kernel.org

I think many tlb->fullmm users actually want to know if there could
be concurrent memory accesses via the mappings being invalidated. If
there is no risk of the page being modified after the pte is changed
and if the pte dirty/young bits won't be modified by the hardware
concurrently, there is no reason to defer page freeing or atomically
update ptes.

I haven't gone carefully through all archs, maybe there is some
exception. But for core mm code I haven't been able to see why the
single threaded case should be different than the fullmm case in
terms of the pte updates and tlb flushing.
---
 include/asm-generic/tlb.h |  3 +++
 mm/huge_memory.c          |  4 ++--
 mm/madvise.c              |  4 ++--
 mm/memory.c               | 13 +++++++------
 4 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index a55ef1425f0d..601c9fefda8e 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -100,6 +100,9 @@ struct mmu_gather {
 	/* we are in the middle of an operation to clear
 	 * a full mm and can make some optimizations */
 	unsigned int		fullmm : 1,
+	/* we have a single thread, current, which is active in the user
+	 * address space */
+				singlethread: 1,
 	/* we have performed an operation which
 	 * requires a complete flush of the tlb */
 				need_flush_all : 1;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1cd7c1a57a14..8e3958a811f0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1703,7 +1703,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	 * operations.
 	 */
 	orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
-			tlb->fullmm);
+			tlb->singlethread);
 	tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 	if (vma_is_dax(vma)) {
 		if (arch_needs_pgtable_deposit())
@@ -1971,7 +1971,7 @@ int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	 * operations.
 	 */
 	orig_pud = pudp_huge_get_and_clear_full(tlb->mm, addr, pud,
-			tlb->fullmm);
+			tlb->singlethread);
 	tlb_remove_pud_tlb_entry(tlb, pud, addr);
 	if (vma_is_dax(vma)) {
 		spin_unlock(ptl);
diff --git a/mm/madvise.c b/mm/madvise.c
index 4d3c922ea1a1..d9e1f3ac8067 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -350,7 +350,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 				continue;
 			nr_swap--;
 			free_swap_and_cache(entry);
-			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
+			pte_clear_not_present_full(mm, addr, pte, tlb->singlethread);
 			continue;
 		}
 
@@ -417,7 +417,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			 * after pte clearing.
 			 */
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
-							tlb->fullmm);
+							tlb->singlethread);
 
 			ptent = pte_mkold(ptent);
 			ptent = pte_mkclean(ptent);
diff --git a/mm/memory.c b/mm/memory.c
index 490689909186..471ba07bc7e3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -221,8 +221,9 @@ void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 {
 	tlb->mm = mm;
 
-	/* Is it from 0 to ~0? */
 	tlb->fullmm     = !(start | (end+1));
+	tlb->singlethread = (mm == current->mm) &&
+				(atomic_read(&mm->mm_users) <= 1);
 	tlb->need_flush_all = 0;
 	tlb->local.next = NULL;
 	tlb->local.nr   = 0;
@@ -300,7 +301,7 @@ bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_
 	 * When this is our mm and there are no other users, there can not be
 	 * a concurrent memory access.
 	 */
-	if (current->mm == tlb->mm && atomic_read(&tlb->mm->mm_users) < 2) {
+	if (tlb->singlethread) {
 		free_page_and_swap_cache(page);
 		return false;
 	}
@@ -1315,7 +1316,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 					continue;
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
-							tlb->fullmm);
+							tlb->singlethread);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;
@@ -1330,7 +1331,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 					 * the old TLB after it was marked
 					 * clean.
 					 */
-					if (!tlb->fullmm) {
+					if (!tlb->singlethread) {
 						force_flush = 1;
 						locked_flush = 1;
 					}
@@ -1367,7 +1368,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 					continue;
 			}
 
-			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
+			pte_clear_not_present_full(mm, addr, pte, tlb->singlethread);
 			rss[mm_counter(page)]--;
 			page_remove_rmap(page, false);
 			put_page(page);
@@ -1389,7 +1390,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 		}
 		if (unlikely(!free_swap_and_cache(entry)))
 			print_bad_pte(vma, addr, ptent, NULL);
-		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
+		pte_clear_not_present_full(mm, addr, pte, tlb->singlethread);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 
 	add_mm_rss_vec(mm, rss);
-- 
2.17.0
