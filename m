Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id BADAC6B00A8
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 21:10:38 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id rl12so3058655iec.15
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 18:10:38 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTP id pb9si12179111wjb.143.2014.07.24.07.36.16
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 07:36:17 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 2/3] mmu_notifier: Call mmu_notifier_invalidate_range() from VMM
Date: Thu, 24 Jul 2014 16:35:40 +0200
Message-Id: <1406212541-25975-3-git-send-email-joro@8bytes.org>
In-Reply-To: <1406212541-25975-1-git-send-email-joro@8bytes.org>
References: <1406212541-25975-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, jroedel@suse.de, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

From: Joerg Roedel <jroedel@suse.de>

Add calls to the new mmu_notifier_invalidate_range()
function to all places if the VMM that need it.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 include/linux/mmu_notifier.h | 28 ++++++++++++++++++++++++++++
 kernel/events/uprobes.c      |  2 +-
 mm/fremap.c                  |  2 +-
 mm/huge_memory.c             |  9 +++++----
 mm/hugetlb.c                 |  7 ++++++-
 mm/ksm.c                     |  4 ++--
 mm/memory.c                  |  3 ++-
 mm/migrate.c                 |  3 ++-
 mm/rmap.c                    |  2 +-
 9 files changed, 48 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index f333668..6959dc8 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -273,6 +273,32 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	__young;							\
 })
 
+#define	ptep_clear_flush_notify(__vma, __address, __ptep)		\
+({									\
+	unsigned long ___addr = __address & PAGE_MASK;			\
+	struct mm_struct *___mm = (__vma)->vm_mm;			\
+	pte_t ___pte;							\
+									\
+	___pte = ptep_clear_flush(__vma, __address, __ptep);		\
+	mmu_notifier_invalidate_range(___mm, ___addr,			\
+					___addr + PAGE_SIZE);		\
+									\
+	___pte;								\
+})
+
+#define pmdp_clear_flush_notify(__vma, __haddr, __pmd)			\
+({									\
+	unsigned long ___haddr = __haddr & HPAGE_PMD_MASK;		\
+	struct mm_struct *___mm = (__vma)->vm_mm;			\
+	pmd_t ___pmd;							\
+									\
+	___pmd = pmdp_clear_flush(__vma, __haddr, __pmd);		\
+	mmu_notifier_invalidate_range(___mm, ___haddr,			\
+				      ___haddr + HPAGE_PMD_SIZE);	\
+									\
+	___pmd;								\
+})
+
 /*
  * set_pte_at_notify() sets the pte _after_ running the notifier.
  * This is safe to start by updating the secondary MMUs, because the primary MMU
@@ -346,6 +372,8 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
+#define	ptep_clear_flush_notify ptep_clear_flush
+#define pmdp_clear_flush_notify pmdp_clear_flush
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 6f3254e..642262d 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -186,7 +186,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	}
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
-	ptep_clear_flush(vma, addr, ptep);
+	ptep_clear_flush_notify(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
 
 	page_remove_rmap(page);
diff --git a/mm/fremap.c b/mm/fremap.c
index 72b8fa3..9129013 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -37,7 +37,7 @@ static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (pte_present(pte)) {
 		flush_cache_page(vma, addr, pte_pfn(pte));
-		pte = ptep_clear_flush(vma, addr, ptep);
+		pte = ptep_clear_flush_notify(vma, addr, ptep);
 		page = vm_normal_page(vma, addr, pte);
 		if (page) {
 			if (pte_dirty(pte))
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 33514d8..b322c97 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1031,7 +1031,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		goto out_free_pages;
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
-	pmdp_clear_flush(vma, haddr, pmd);
+	pmdp_clear_flush_notify(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
@@ -1168,7 +1168,7 @@ alloc:
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		pmdp_clear_flush(vma, haddr, pmd);
+		pmdp_clear_flush_notify(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		update_mmu_cache_pmd(vma, address, pmd);
@@ -1499,7 +1499,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		pmd_t entry;
 		ret = 1;
 		if (!prot_numa) {
-			entry = pmdp_get_and_clear(mm, addr, pmd);
+			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
 			if (pmd_numa(entry))
 				entry = pmd_mknonnuma(entry);
 			entry = pmd_modify(entry, newprot);
@@ -1631,6 +1631,7 @@ static int __split_huge_page_splitting(struct page *page,
 		 * serialize against split_huge_page*.
 		 */
 		pmdp_splitting_flush(vma, address, pmd);
+
 		ret = 1;
 		spin_unlock(ptl);
 	}
@@ -2793,7 +2794,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	pmd_t _pmd;
 	int i;
 
-	pmdp_clear_flush(vma, haddr, pmd);
+	pmdp_clear_flush_notify(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2024bbd..da37ad1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2602,8 +2602,11 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			}
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		} else {
-			if (cow)
+			if (cow) {
 				huge_ptep_set_wrprotect(src, addr, src_pte);
+				mmu_notifier_invalidate_range(src, mmun_start,
+								   mmun_end);
+			}
 			ptepage = pte_page(entry);
 			get_page(ptepage);
 			page_dup_rmap(ptepage);
@@ -2910,6 +2913,7 @@ retry_avoidcopy:
 
 		/* Break COW */
 		huge_ptep_clear_flush(vma, address, ptep);
+		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
 		page_remove_rmap(old_page);
@@ -3384,6 +3388,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * and that page table be reused and filled with junk.
 	 */
 	flush_tlb_range(vma, start, end);
+	mmu_notifier_invalidate_range(mm, start, end);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 346ddc9..a73df3b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -892,7 +892,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		 * this assure us that no O_DIRECT can happen after the check
 		 * or in the middle of the check.
 		 */
-		entry = ptep_clear_flush(vma, addr, ptep);
+		entry = ptep_clear_flush_notify(vma, addr, ptep);
 		/*
 		 * Check that no O_DIRECT or similar I/O is in progress on the
 		 * page
@@ -960,7 +960,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	page_add_anon_rmap(kpage, vma, addr);
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
-	ptep_clear_flush(vma, addr, ptep);
+	ptep_clear_flush_notify(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
 
 	page_remove_rmap(page);
diff --git a/mm/memory.c b/mm/memory.c
index d67fd9f..ceff829 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -236,6 +236,7 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	tlb->need_flush = 0;
 	tlb_flush(tlb);
+	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
@@ -2232,7 +2233,7 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush(vma, address, page_table);
+		ptep_clear_flush_notify(vma, address, page_table);
 		page_add_new_anon_rmap(new_page, vma, address);
 		/*
 		 * We call the notify macro here because, when using secondary
diff --git a/mm/migrate.c b/mm/migrate.c
index 9e0beaa..812c0d6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1874,7 +1874,7 @@ fail_putback:
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
 	page_add_anon_rmap(new_page, vma, mmun_start);
-	pmdp_clear_flush(vma, mmun_start, pmd);
+	pmdp_clear_flush_notify(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	flush_tlb_range(vma, mmun_start, mmun_end);
 	update_mmu_cache_pmd(vma, address, &entry);
@@ -1882,6 +1882,7 @@ fail_putback:
 	if (page_count(page) != 2) {
 		set_pmd_at(mm, mmun_start, pmd, orig_entry);
 		flush_tlb_range(vma, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
 		update_mmu_cache_pmd(vma, address, &entry);
 		page_remove_rmap(new_page);
 		goto fail_putback;
diff --git a/mm/rmap.c b/mm/rmap.c
index b7e94eb..c2a703b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1384,7 +1384,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush(vma, address, pte);
+		pteval = ptep_clear_flush_notify(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address)) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
