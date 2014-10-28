Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id BD59A900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 13:14:25 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id 10so1027516lbg.29
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 10:14:24 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id q5si3452798lbp.93.2014.10.28.10.14.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 10:14:21 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 2/3] mmu_notifier: Call mmu_notifier_invalidate_range() from VMM
Date: Tue, 28 Oct 2014 18:13:59 +0100
Message-Id: <1414516440-910-3-git-send-email-joro@8bytes.org>
In-Reply-To: <1414516440-910-1-git-send-email-joro@8bytes.org>
References: <1414516440-910-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Add calls to the new mmu_notifier_invalidate_range()
function to all places in the VMM that need it.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 include/linux/mmu_notifier.h | 41 +++++++++++++++++++++++++++++++++++++++++
 kernel/events/uprobes.c      |  2 +-
 mm/fremap.c                  |  2 +-
 mm/huge_memory.c             |  9 +++++----
 mm/hugetlb.c                 |  7 ++++++-
 mm/ksm.c                     |  4 ++--
 mm/memory.c                  |  3 ++-
 mm/migrate.c                 |  3 ++-
 mm/rmap.c                    |  2 +-
 9 files changed, 61 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 1790790..966da2b 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -284,6 +284,44 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
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
+#define pmdp_get_and_clear_notify(__mm, __haddr, __pmd)			\
+({									\
+	unsigned long ___haddr = __haddr & HPAGE_PMD_MASK;		\
+	pmd_t ___pmd;							\
+									\
+	___pmd = pmdp_get_and_clear(__mm, __haddr, __pmd);		\
+	mmu_notifier_invalidate_range(__mm, ___haddr,			\
+				      ___haddr + HPAGE_PMD_SIZE);	\
+									\
+	___pmd;								\
+})
+
 /*
  * set_pte_at_notify() sets the pte _after_ running the notifier.
  * This is safe to start by updating the secondary MMUs, because the primary MMU
@@ -362,6 +400,9 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
+#define	ptep_clear_flush_notify ptep_clear_flush
+#define pmdp_clear_flush_notify pmdp_clear_flush
+#define pmdp_get_and_clear_notify pmdp_get_and_clear
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 1d0af8a..bc143cf 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -193,7 +193,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
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
index 74c78aa..ef320af 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1036,7 +1036,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		goto out_free_pages;
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
-	pmdp_clear_flush(vma, haddr, pmd);
+	pmdp_clear_flush_notify(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
@@ -1179,7 +1179,7 @@ alloc:
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		pmdp_clear_flush(vma, haddr, pmd);
+		pmdp_clear_flush_notify(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		mem_cgroup_commit_charge(new_page, memcg, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
@@ -1512,7 +1512,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		pmd_t entry;
 		ret = 1;
 		if (!prot_numa) {
-			entry = pmdp_get_and_clear(mm, addr, pmd);
+			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
 			if (pmd_numa(entry))
 				entry = pmd_mknonnuma(entry);
 			entry = pmd_modify(entry, newprot);
@@ -1644,6 +1644,7 @@ static int __split_huge_page_splitting(struct page *page,
 		 * serialize against split_huge_page*.
 		 */
 		pmdp_splitting_flush(vma, address, pmd);
+
 		ret = 1;
 		spin_unlock(ptl);
 	}
@@ -2833,7 +2834,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	pmd_t _pmd;
 	int i;
 
-	pmdp_clear_flush(vma, haddr, pmd);
+	pmdp_clear_flush_notify(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9fd7227..2e6add0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2598,8 +2598,11 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			}
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		} else {
-			if (cow)
+			if (cow) {
 				huge_ptep_set_wrprotect(src, addr, src_pte);
+				mmu_notifier_invalidate_range(src, mmun_start,
+								   mmun_end);
+			}
 			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
 			get_page(ptepage);
@@ -2899,6 +2902,7 @@ retry_avoidcopy:
 
 		/* Break COW */
 		huge_ptep_clear_flush(vma, address, ptep);
+		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
 		page_remove_rmap(old_page);
@@ -3374,6 +3378,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * and that page table be reused and filled with junk.
 	 */
 	flush_tlb_range(vma, start, end);
+	mmu_notifier_invalidate_range(mm, start, end);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 6b2e337..d247efa 100644
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
index 1cc6bfb..c287d4c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -238,6 +238,7 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	tlb->need_flush = 0;
 	tlb_flush(tlb);
+	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
@@ -2233,7 +2234,7 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush(vma, address, page_table);
+		ptep_clear_flush_notify(vma, address, page_table);
 		page_add_new_anon_rmap(new_page, vma, address);
 		mem_cgroup_commit_charge(new_page, memcg, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
diff --git a/mm/migrate.c b/mm/migrate.c
index 0143995..41945cb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1854,7 +1854,7 @@ fail_putback:
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
 	page_add_anon_rmap(new_page, vma, mmun_start);
-	pmdp_clear_flush(vma, mmun_start, pmd);
+	pmdp_clear_flush_notify(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	flush_tlb_range(vma, mmun_start, mmun_end);
 	update_mmu_cache_pmd(vma, address, &entry);
@@ -1862,6 +1862,7 @@ fail_putback:
 	if (page_count(page) != 2) {
 		set_pmd_at(mm, mmun_start, pmd, orig_entry);
 		flush_tlb_range(vma, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
 		update_mmu_cache_pmd(vma, address, &entry);
 		page_remove_rmap(new_page);
 		goto fail_putback;
diff --git a/mm/rmap.c b/mm/rmap.c
index 116a505..fdb8055 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1364,7 +1364,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush(vma, address, pte);
+		pteval = ptep_clear_flush_notify(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address)) {
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
