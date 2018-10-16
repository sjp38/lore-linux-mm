Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77E4C6B0266
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:14:22 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r134-v6so12031819pgr.19
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 06:14:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l20-v6sor4443475pgh.86.2018.10.16.06.14.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 06:14:21 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH v2 5/5] mm: optimise pte dirty/accessed bit setting by demand based pte insertion
Date: Tue, 16 Oct 2018 23:13:43 +1000
Message-Id: <20181016131343.20556-6-npiggin@gmail.com>
In-Reply-To: <20181016131343.20556-1-npiggin@gmail.com>
References: <20181016131343.20556-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, Ley Foon Tan <ley.foon.tan@intel.com>

Similarly to the previous patch, this tries to optimise dirty/accessed
bits in ptes to avoid access costs of hardware setting them.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/huge_memory.c | 12 ++++++++----
 mm/memory.c      |  9 ++++++---
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1f43265204d4..38c2cd3b4879 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1197,6 +1197,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
 		pte_t entry;
 		entry = mk_pte(pages[i], vma->vm_page_prot);
+		entry = pte_mkyoung(entry);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
@@ -2067,7 +2068,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct page *page;
 	pgtable_t pgtable;
 	pmd_t old_pmd, _pmd;
-	bool young, write, soft_dirty, pmd_migration = false;
+	bool young, write, dirty, soft_dirty, pmd_migration = false;
 	unsigned long addr;
 	int i;
 
@@ -2145,7 +2146,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		page = pmd_page(old_pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
-	if (pmd_dirty(old_pmd))
+	dirty = pmd_dirty(old_pmd);
+	if (dirty)
 		SetPageDirty(page);
 	write = pmd_write(old_pmd);
 	young = pmd_young(old_pmd);
@@ -2176,8 +2178,10 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			entry = maybe_mkwrite(entry, vma);
 			if (!write)
 				entry = pte_wrprotect(entry);
-			if (!young)
-				entry = pte_mkold(entry);
+			if (young)
+				entry = pte_mkyoung(entry);
+			if (dirty)
+				entry = pte_mkdirty(entry);
 			if (soft_dirty)
 				entry = pte_mksoft_dirty(entry);
 		}
diff --git a/mm/memory.c b/mm/memory.c
index 9e314339a0bd..f907ea7a6303 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1804,10 +1804,9 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
 
 out_mkwrite:
-	if (mkwrite) {
-		entry = pte_mkyoung(entry);
+	entry = pte_mkyoung(entry);
+	if (mkwrite)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	}
 
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
@@ -2534,6 +2533,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		}
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
+		entry = pte_mkyoung(entry);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
@@ -3043,6 +3043,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
 	pte = mk_pte(page, vma->vm_page_prot);
+	pte = pte_mkyoung(pte);
 	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		vmf->flags &= ~FAULT_FLAG_WRITE;
@@ -3185,6 +3186,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	__SetPageUptodate(page);
 
 	entry = mk_pte(page, vma->vm_page_prot);
+	entry = pte_mkyoung(entry);
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
@@ -3453,6 +3455,7 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 
 	flush_icache_page(vma, page);
 	entry = mk_pte(page, vma->vm_page_prot);
+	entry = pte_mkyoung(entry);
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 	/* copy-on-write page */
-- 
2.18.0
