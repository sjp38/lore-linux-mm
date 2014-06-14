Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id C199B6B0037
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 20:49:05 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id m20so5119823qcx.27
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 17:49:05 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id y9si6273419qat.45.2014.06.13.17.49.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 17:49:05 -0700 (PDT)
Received: by mail-qc0-f169.google.com with SMTP id c9so5079692qcz.28
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 17:49:05 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <j.glisse@gmail.com>
Subject: [PATCH 3/5] mmu_notifier: pass through vma to invalidate_range and invalidate_page
Date: Fri, 13 Jun 2014 20:48:31 -0400
Message-Id: <1402706913-7432-4-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1402706913-7432-3-git-send-email-j.glisse@gmail.com>
References: <1402706913-7432-1-git-send-email-j.glisse@gmail.com>
 <1402706913-7432-2-git-send-email-j.glisse@gmail.com>
 <1402706913-7432-3-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, torvalds@linux-foundation.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

New user of the mmu_notifier interface need to lookup vma in order to
perform the invalidation operation. Instead of redoing a vma lookup
inside the callback just pass through the vma from the call site where
it is already available.

This needs small refactoring in memory.c to call invalidate_range on
vma boundary the overhead should be low enough.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/gpu/drm/i915/i915_gem_userptr.c |  1 +
 drivers/iommu/amd_iommu_v2.c            |  3 +++
 drivers/misc/sgi-gru/grutlbpurge.c      |  6 +++++-
 drivers/xen/gntdev.c                    |  4 +++-
 fs/proc/task_mmu.c                      | 13 +++++++----
 include/linux/mmu_notifier.h            | 18 +++++++++++++---
 kernel/events/uprobes.c                 |  4 ++--
 mm/filemap_xip.c                        |  2 +-
 mm/fremap.c                             |  6 ++++--
 mm/huge_memory.c                        | 26 +++++++++++-----------
 mm/hugetlb.c                            | 16 +++++++-------
 mm/ksm.c                                |  8 +++----
 mm/memory.c                             | 38 ++++++++++++++++++++++-----------
 mm/migrate.c                            |  6 +++---
 mm/mmu_notifier.c                       |  9 +++++---
 mm/mprotect.c                           |  4 ++--
 mm/mremap.c                             |  4 ++--
 mm/rmap.c                               |  8 +++----
 virt/kvm/kvm_main.c                     |  3 +++
 19 files changed, 114 insertions(+), 65 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 7f7b4f3..70bae03 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -55,6 +55,7 @@ struct i915_mmu_object {
 
 static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 						       struct mm_struct *mm,
+						       struct vm_area_struct *vma,
 						       unsigned long start,
 						       unsigned long end,
 						       enum mmu_action action)
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 81ff80b..6f025a1 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -421,6 +421,7 @@ static void mn_change_pte(struct mmu_notifier *mn,
 
 static void mn_invalidate_page(struct mmu_notifier *mn,
 			       struct mm_struct *mm,
+			       struct vm_area_struct *vma,
 			       unsigned long address,
 			       enum mmu_action action)
 {
@@ -429,6 +430,7 @@ static void mn_invalidate_page(struct mmu_notifier *mn,
 
 static void mn_invalidate_range_start(struct mmu_notifier *mn,
 				      struct mm_struct *mm,
+				      struct vm_area_struct *vma,
 				      unsigned long start,
 				      unsigned long end,
 				      enum mmu_action action)
@@ -448,6 +450,7 @@ static void mn_invalidate_range_start(struct mmu_notifier *mn,
 
 static void mn_invalidate_range_end(struct mmu_notifier *mn,
 				    struct mm_struct *mm,
+				    struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    enum mmu_action action)
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index 3427bfc..716501b 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -221,6 +221,7 @@ void gru_flush_all_tlb(struct gru_state *gru)
  */
 static void gru_invalidate_range_start(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
+				       struct vm_area_struct *vma,
 				       unsigned long start, unsigned long end,
 				       enum mmu_action action)
 {
@@ -235,7 +236,9 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
 }
 
 static void gru_invalidate_range_end(struct mmu_notifier *mn,
-				     struct mm_struct *mm, unsigned long start,
+				     struct mm_struct *mm,
+				     struct vm_area_struct *vma,
+				     unsigned long start,
 				     unsigned long end,
 				     enum mmu_action action)
 {
@@ -250,6 +253,7 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 }
 
 static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
+				struct vm_area_struct *vma,
 				unsigned long address,
 				enum mmu_action action)
 {
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 84aa5a7..447c3fb 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -428,6 +428,7 @@ static void unmap_if_in_range(struct grant_map *map,
 
 static void mn_invl_range_start(struct mmu_notifier *mn,
 				struct mm_struct *mm,
+				struct vm_area_struct *vma,
 				unsigned long start,
 				unsigned long end,
 				enum mmu_action action)
@@ -447,10 +448,11 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
 
 static void mn_invl_page(struct mmu_notifier *mn,
 			 struct mm_struct *mm,
+			 struct vm_area_struct *vma,
 			 unsigned long address,
 			 enum mmu_action action)
 {
-	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE, action);
+	mn_invl_range_start(mn, mm, vma, address, address + PAGE_SIZE, action);
 }
 
 static void mn_release(struct mmu_notifier *mn,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 24255de..25e4a8d 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -829,8 +829,6 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			.private = &cp,
 		};
 		down_read(&mm->mmap_sem);
-		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_start(mm, 0, -1, MMU_SOFT_DIRTY);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			cp.vma = vma;
 			if (is_vm_hugetlb_page(vma))
@@ -853,12 +851,19 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			if (type == CLEAR_REFS_SOFT_DIRTY) {
 				if (vma->vm_flags & VM_SOFTDIRTY)
 					vma->vm_flags &= ~VM_SOFTDIRTY;
+				mmu_notifier_invalidate_range_start(mm, vma,
+								    vma->vm_start,
+								    vma->vm_end,
+								    MMU_SOFT_DIRTY);
 			}
 			walk_page_range(vma->vm_start, vma->vm_end,
 					&clear_refs_walk);
+			if (type == CLEAR_REFS_SOFT_DIRTY)
+				mmu_notifier_invalidate_range_end(mm, vma,
+								  vma->vm_start,
+								  vma->vm_end,
+								  MMU_SOFT_DIRTY);
 		}
-		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_end(mm, 0, -1, MMU_SOFT_DIRTY);
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 3ef6a20..5808b0f 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -127,6 +127,7 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
+				struct vm_area_struct *vma,
 				unsigned long address,
 				enum mmu_action action);
 
@@ -175,11 +176,13 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
+				       struct vm_area_struct *vma,
 				       unsigned long start,
 				       unsigned long end,
 				       enum mmu_action action);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
+				     struct vm_area_struct *vma,
 				     unsigned long start,
 				     unsigned long end,
 				     enum mmu_action action);
@@ -223,13 +226,16 @@ extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      pte_t pte,
 				      enum mmu_action action);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+					   struct vm_area_struct *vma,
 					   unsigned long address,
 					   enum mmu_action action);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+						  struct vm_area_struct *vma,
 						  unsigned long start,
 						  unsigned long end,
 						  enum mmu_action action);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+						struct vm_area_struct *vma,
 						unsigned long start,
 						unsigned long end,
 						enum mmu_action action);
@@ -266,29 +272,32 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+						struct vm_area_struct *vma,
 						unsigned long address,
 						enum mmu_action action)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_page(mm, address, action);
+		__mmu_notifier_invalidate_page(mm, vma, address, action);
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+						       struct vm_area_struct *vma,
 						       unsigned long start,
 						       unsigned long end,
 						       enum mmu_action action)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end, action);
+		__mmu_notifier_invalidate_range_start(mm, vma, start, end, action);
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+						     struct vm_area_struct *vma,
 						     unsigned long start,
 						     unsigned long end,
 						     enum mmu_action action)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end, action);
+		__mmu_notifier_invalidate_range_end(mm, vma, start, end, action);
 }
 
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
@@ -370,12 +379,14 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+						struct vm_area_struct *vma,
 						unsigned long address,
 						enum mmu_action action)
 {
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+						       struct vm_area_struct *vma,
 						       unsigned long start,
 						       unsigned long end,
 						       enum mmu_action action)
@@ -383,6 +394,7 @@ static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+						     struct vm_area_struct *vma,
 						     unsigned long start,
 						     unsigned long end,
 						     enum mmu_action action)
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 3e2308f..a0459dd 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -171,7 +171,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_UNMAP);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_UNMAP);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -200,7 +200,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	err = 0;
  unlock:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_UNMAP);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_UNMAP);
 	unlock_page(page);
 	return err;
 }
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index d529ab9..e01c68b 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -198,7 +198,7 @@ retry:
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			/* must invalidate_page _before_ freeing the page */
-			mmu_notifier_invalidate_page(mm, address, MMU_UNMAP);
+			mmu_notifier_invalidate_page(mm, vma, address, MMU_UNMAP);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/fremap.c b/mm/fremap.c
index f324a84..ef86ae8 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -258,9 +258,11 @@ get_write_lock:
 		vma->vm_flags = vm_flags;
 	}
 
-	mmu_notifier_invalidate_range_start(mm, start, start + size, MMU_FREMAP);
+	mmu_notifier_invalidate_range_start(mm, vma, start,
+					    start + size, MMU_FREMAP);
 	err = vma->vm_ops->remap_pages(vma, start, size, pgoff);
-	mmu_notifier_invalidate_range_end(mm, start, start + size, MMU_FREMAP);
+	mmu_notifier_invalidate_range_end(mm, vma, start,
+					  start + size, MMU_FREMAP);
 
 	/*
 	 * We can't clear VM_NONLINEAR because we'd have to do
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 086e0db..6570ead 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -993,7 +993,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
@@ -1023,7 +1023,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	page_remove_rmap(page);
 	spin_unlock(ptl);
 
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
@@ -1033,7 +1033,7 @@ out:
 
 out_free_pages:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 	mem_cgroup_uncharge_start();
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		mem_cgroup_uncharge_page(pages[i]);
@@ -1123,7 +1123,7 @@ alloc:
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 
 	spin_lock(ptl);
 	if (page)
@@ -1153,7 +1153,7 @@ alloc:
 	}
 	spin_unlock(ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 out:
 	return ret;
 out_unlock:
@@ -1588,7 +1588,7 @@ static int __split_huge_page_splitting(struct page *page,
 	const unsigned long mmun_start = address;
 	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_THP_SPLIT);
 	pmd = page_check_address_pmd(page, mm, address,
 			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
 	if (pmd) {
@@ -1603,7 +1603,7 @@ static int __split_huge_page_splitting(struct page *page,
 		ret = 1;
 		spin_unlock(ptl);
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_THP_SPLIT);
 
 	return ret;
 }
@@ -2402,7 +2402,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	mmun_start = address;
 	mmun_end   = address + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_THP_SPLIT);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
@@ -2412,7 +2412,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	_pmd = pmdp_clear_flush(vma, address, pmd);
 	spin_unlock(pmd_ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_THP_SPLIT);
 
 	spin_lock(pte_ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
@@ -2801,24 +2801,24 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 again:
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_THP_SPLIT);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
+		mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_THP_SPLIT);
 		return;
 	}
 	if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
+		mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_THP_SPLIT);
 		return;
 	}
 	page = pmd_page(*pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	get_page(page);
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_THP_SPLIT);
 
 	split_huge_page(page);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index fdfcded..9b804c2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2539,7 +2539,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	mmun_start = vma->vm_start;
 	mmun_end = vma->vm_end;
 	if (cow)
-		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end, MMU_COW);
+		mmu_notifier_invalidate_range_start(src, vma, mmun_start, mmun_end, MMU_COW);
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
@@ -2573,7 +2573,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	}
 
 	if (cow)
-		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end, MMU_COW);
+		mmu_notifier_invalidate_range_end(src, vma, mmun_start, mmun_end, MMU_COW);
 
 	return ret;
 }
@@ -2625,7 +2625,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	BUG_ON(end & ~huge_page_mask(h));
 
 	tlb_start_vma(tlb, vma);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_UNMAP);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_UNMAP);
 again:
 	for (address = start; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
@@ -2696,7 +2696,7 @@ unlock:
 		if (address < end && !ref_page)
 			goto again;
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_UNMAP);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_UNMAP);
 	tlb_end_vma(tlb, vma);
 }
 
@@ -2883,7 +2883,7 @@ retry_avoidcopy:
 
 	mmun_start = address & huge_page_mask(h);
 	mmun_end = mmun_start + huge_page_size(h);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_UNMAP);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_UNMAP);
 	/*
 	 * Retake the page table lock to check for racing updates
 	 * before the page tables are altered
@@ -2903,7 +2903,7 @@ retry_avoidcopy:
 		new_page = old_page;
 	}
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_UNMAP);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_UNMAP);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
 
@@ -3341,7 +3341,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mmu_notifier_invalidate_range_start(mm, start, end, action);
+	mmu_notifier_invalidate_range_start(mm, vma, start, end, action);
 	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
@@ -3371,7 +3371,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 */
 	flush_tlb_range(vma, start, end);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
-	mmu_notifier_invalidate_range_end(mm, start, end, action);
+	mmu_notifier_invalidate_range_end(mm, vma, start, end, action);
 
 	return pages << h->order;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 6a32bc4..3752820 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -872,7 +872,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_KSM_RONLY);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_KSM_RONLY);
 
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -912,7 +912,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_KSM_RONLY);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_KSM_RONLY);
 out:
 	return err;
 }
@@ -949,7 +949,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_KSM);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_KSM);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (!pte_same(*ptep, orig_pte)) {
@@ -972,7 +972,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_KSM);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_KSM);
 out:
 	return err;
 }
diff --git a/mm/memory.c b/mm/memory.c
index d175dcf..7c8fd1d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1049,7 +1049,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	mmun_start = addr;
 	mmun_end   = end;
 	if (is_cow)
-		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
+		mmu_notifier_invalidate_range_start(src_mm, vma, mmun_start,
 						    mmun_end, MMU_COW);
 
 	ret = 0;
@@ -1067,7 +1067,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow)
-		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end,
+		mmu_notifier_invalidate_range_end(src_mm, vma, mmun_start, mmun_end,
 						  MMU_COW);
 	return ret;
 }
@@ -1374,10 +1374,17 @@ void unmap_vmas(struct mmu_gather *tlb,
 {
 	struct mm_struct *mm = vma->vm_mm;
 
-	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr, MMU_MUNMAP);
-	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
+	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
+		mmu_notifier_invalidate_range_start(mm, vma,
+						    max(start_addr, vma->vm_start),
+						    min(end_addr, vma->vm_end),
+						    MMU_MUNMAP);
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
-	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr, MMU_MUNMAP);
+		mmu_notifier_invalidate_range_end(mm, vma,
+						  max(start_addr, vma->vm_start),
+						  min(end_addr, vma->vm_end),
+						  MMU_MUNMAP);
+	}
 }
 
 /**
@@ -1399,10 +1406,17 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, start, end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MUNMAP);
-	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
+	for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
+		mmu_notifier_invalidate_range_start(mm, vma,
+						    max(start, vma->vm_start),
+						    min(end, vma->vm_end),
+						    MMU_MUNMAP);
 		unmap_single_vma(&tlb, vma, start, end, details);
-	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MUNMAP);
+		mmu_notifier_invalidate_range_end(mm, vma,
+						  max(start, vma->vm_start),
+						  min(end, vma->vm_end),
+						  MMU_MUNMAP);
+	}
 	tlb_finish_mmu(&tlb, start, end);
 }
 
@@ -1425,9 +1439,9 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, address, end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, address, end, MMU_MUNMAP);
+	mmu_notifier_invalidate_range_start(mm, vma, address, end, MMU_MUNMAP);
 	unmap_single_vma(&tlb, vma, address, end, details);
-	mmu_notifier_invalidate_range_end(mm, address, end, MMU_MUNMAP);
+	mmu_notifier_invalidate_range_end(mm, vma, address, end, MMU_MUNMAP);
 	tlb_finish_mmu(&tlb, address, end);
 }
 
@@ -2210,7 +2224,7 @@ gotten:
 
 	mmun_start  = address & PAGE_MASK;
 	mmun_end    = mmun_start + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_FAULT_WP);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_FAULT_WP);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2279,7 +2293,7 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (mmun_end > mmun_start)
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_FAULT_WP);
+		mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_FAULT_WP);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/migrate.c b/mm/migrate.c
index 01cd98a..6b2797d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1827,12 +1827,12 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, MMU_MIGRATE);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
 fail_putback:
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_MIGRATE);
+		mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_MIGRATE);
 
 		/* Reverse changes made by migrate_page_copy() */
 		if (TestClearPageActive(new_page))
@@ -1898,7 +1898,7 @@ fail_putback:
 	 */
 	mem_cgroup_end_migration(memcg, page, new_page, true);
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, MMU_MIGRATE);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
 	get_page(new_page);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index a906744..0b0e1ca 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -139,6 +139,7 @@ void __mmu_notifier_change_pte(struct mm_struct *mm,
 }
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+				    struct vm_area_struct *vma,
 				    unsigned long address,
 				    enum mmu_action action)
 {
@@ -148,12 +149,13 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address, action);
+			mn->ops->invalidate_page(mn, mm, vma, address, action);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+					   struct vm_area_struct *vma,
 					   unsigned long start,
 					   unsigned long end,
 					   enum mmu_action action)
@@ -165,13 +167,14 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start, end, action);
+			mn->ops->invalidate_range_start(mn, mm, vma, start, end, action);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+					 struct vm_area_struct *vma,
 					 unsigned long start,
 					 unsigned long end,
 					 enum mmu_action action)
@@ -182,7 +185,7 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start, end, action);
+			mn->ops->invalidate_range_end(mn, mm, vma, start, end, action);
 	}
 	srcu_read_unlock(&srcu, id);
 }
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 6c2846f..ebe92d1 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -158,7 +158,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		/* invoke the mmu notifier if the pmd is populated */
 		if (!mni_start) {
 			mni_start = addr;
-			mmu_notifier_invalidate_range_start(mm, mni_start, end, action);
+			mmu_notifier_invalidate_range_start(mm, vma, mni_start, end, action);
 		}
 
 		if (pmd_trans_huge(*pmd)) {
@@ -186,7 +186,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	} while (pmd++, addr = next, addr != end);
 
 	if (mni_start)
-		mmu_notifier_invalidate_range_end(mm, mni_start, end, action);
+		mmu_notifier_invalidate_range_end(mm, vma, mni_start, end, action);
 
 	if (nr_huge_updates)
 		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
diff --git a/mm/mremap.c b/mm/mremap.c
index ceb8a47..0b008a0 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -177,7 +177,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 	mmun_start = old_addr;
 	mmun_end   = old_end;
-	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end, MMU_MREMAP);
+	mmu_notifier_invalidate_range_start(vma->vm_mm, vma, mmun_start, mmun_end, MMU_MREMAP);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
@@ -228,7 +228,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	if (likely(need_flush))
 		flush_tlb_range(vma, old_end-len, old_addr);
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end, MMU_MREMAP);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, vma, mmun_start, mmun_end, MMU_MREMAP);
 
 	return len + old_addr - old_end;	/* how much done */
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 723f754..813738a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -840,7 +840,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 
 	if (ret) {
-		mmu_notifier_invalidate_page(mm, address, MMU_FILE_WB);
+		mmu_notifier_invalidate_page(mm, vma, address, MMU_FILE_WB);
 		(*cleaned)++;
 	}
 out:
@@ -1262,7 +1262,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address, action);
+		mmu_notifier_invalidate_page(mm, vma, address, action);
 out:
 	return ret;
 
@@ -1354,7 +1354,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 	mmun_start = address;
 	mmun_end   = end;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, action);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start, mmun_end, action);
 
 	/*
 	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
@@ -1419,7 +1419,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, action);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, action);
 	if (locked_vma)
 		up_read(&vma->vm_mm->mmap_sem);
 	return ret;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index eb5a635..1bd7117 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -262,6 +262,7 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
 
 static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
+					     struct vm_area_struct *vma,
 					     unsigned long address,
 					     enum mmu_action action)
 {
@@ -318,6 +319,7 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 
 static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						    struct mm_struct *mm,
+						    struct vm_area_struct *vma,
 						    unsigned long start,
 						    unsigned long end,
 						    enum mmu_action action)
@@ -345,6 +347,7 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
 						  struct mm_struct *mm,
+						  struct vm_area_struct *vma,
 						  unsigned long start,
 						  unsigned long end,
 						  enum mmu_action action)
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
