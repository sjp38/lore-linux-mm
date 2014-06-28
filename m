Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7CAD6B0039
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 22:00:57 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id z60so183941qgd.38
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 19:00:57 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id hl16si16046450qcb.1.2014.06.27.19.00.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 19:00:57 -0700 (PDT)
Received: by mail-qc0-f169.google.com with SMTP id c9so5246387qcz.28
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 19:00:57 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <j.glisse@gmail.com>
Subject: [PATCH 4/6] mmu_notifier: pass through vma to invalidate_range and invalidate_page
Date: Fri, 27 Jun 2014 22:00:22 -0400
Message-Id: <1403920822-14488-5-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, torvalds@linux-foundation.org, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

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
 drivers/misc/sgi-gru/grutlbpurge.c      |  6 ++++-
 drivers/xen/gntdev.c                    |  4 +++-
 fs/proc/task_mmu.c                      | 16 ++++++++-----
 include/linux/mmu_notifier.h            | 19 ++++++++++++---
 kernel/events/uprobes.c                 |  4 ++--
 mm/filemap_xip.c                        |  3 ++-
 mm/huge_memory.c                        | 26 ++++++++++----------
 mm/hugetlb.c                            | 16 ++++++-------
 mm/ksm.c                                |  8 +++----
 mm/memory.c                             | 42 +++++++++++++++++++++------------
 mm/migrate.c                            |  6 ++---
 mm/mmu_notifier.c                       |  9 ++++---
 mm/mprotect.c                           |  5 ++--
 mm/mremap.c                             |  4 ++--
 mm/rmap.c                               |  9 +++----
 virt/kvm/kvm_main.c                     |  3 +++
 18 files changed, 116 insertions(+), 68 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index ed6f35e..191ac71 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -55,6 +55,7 @@ struct i915_mmu_object {
 
 static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 						       struct mm_struct *mm,
+						       struct vm_area_struct *vma,
 						       unsigned long start,
 						       unsigned long end,
 						       enum mmu_event event)
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 2bb9771..9f9e706 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -422,6 +422,7 @@ static void mn_change_pte(struct mmu_notifier *mn,
 
 static void mn_invalidate_page(struct mmu_notifier *mn,
 			       struct mm_struct *mm,
+			       struct vm_area_struct *vma,
 			       unsigned long address,
 			       enum mmu_event event)
 {
@@ -430,6 +431,7 @@ static void mn_invalidate_page(struct mmu_notifier *mn,
 
 static void mn_invalidate_range_start(struct mmu_notifier *mn,
 				      struct mm_struct *mm,
+				      struct vm_area_struct *vma,
 				      unsigned long start,
 				      unsigned long end,
 				      enum mmu_event event)
@@ -453,6 +455,7 @@ static void mn_invalidate_range_start(struct mmu_notifier *mn,
 
 static void mn_invalidate_range_end(struct mmu_notifier *mn,
 				    struct mm_struct *mm,
+				    struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    enum mmu_event event)
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index e67fed1..d02e4c7 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -221,6 +221,7 @@ void gru_flush_all_tlb(struct gru_state *gru)
  */
 static void gru_invalidate_range_start(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
+				       struct vm_area_struct *vma,
 				       unsigned long start, unsigned long end,
 				       enum mmu_event event)
 {
@@ -235,7 +236,9 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
 }
 
 static void gru_invalidate_range_end(struct mmu_notifier *mn,
-				     struct mm_struct *mm, unsigned long start,
+				     struct mm_struct *mm,
+				     struct vm_area_struct *vma,
+				     unsigned long start,
 				     unsigned long end,
 				     enum mmu_event event)
 {
@@ -250,6 +253,7 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 }
 
 static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
+				struct vm_area_struct *vma,
 				unsigned long address,
 				enum mmu_event event)
 {
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index fe9da94..219928b 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -428,6 +428,7 @@ static void unmap_if_in_range(struct grant_map *map,
 
 static void mn_invl_range_start(struct mmu_notifier *mn,
 				struct mm_struct *mm,
+				struct vm_area_struct *vma,
 				unsigned long start,
 				unsigned long end,
 				enum mmu_event event)
@@ -447,10 +448,11 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
 
 static void mn_invl_page(struct mmu_notifier *mn,
 			 struct mm_struct *mm,
+			 struct vm_area_struct *vma,
 			 unsigned long address,
 			 enum mmu_event event)
 {
-	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE, event);
+	mn_invl_range_start(mn, mm, vma, address, address + PAGE_SIZE, event);
 }
 
 static void mn_release(struct mmu_notifier *mn,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index e9e79f7..8b0f25d 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -829,13 +829,15 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			.private = &cp,
 		};
 		down_read(&mm->mmap_sem);
-		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_start(mm, 0,
-							    -1, MMU_STATUS);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			cp.vma = vma;
 			if (is_vm_hugetlb_page(vma))
 				continue;
+			if (type == CLEAR_REFS_SOFT_DIRTY)
+				mmu_notifier_invalidate_range_start(mm, vma,
+								    vma->vm_start,
+								    vma->vm_end,
+								    MMU_STATUS);
 			/*
 			 * Writing 1 to /proc/pid/clear_refs affects all pages.
 			 *
@@ -857,10 +859,12 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			}
 			walk_page_range(vma->vm_start, vma->vm_end,
 					&clear_refs_walk);
+			if (type == CLEAR_REFS_SOFT_DIRTY)
+				mmu_notifier_invalidate_range_end(mm, vma,
+								  vma->vm_start,
+								  vma->vm_end,
+								  MMU_STATUS);
 		}
-		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_end(mm, 0,
-							  -1, MMU_STATUS);
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 82e9577..8907e5d 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -137,6 +137,7 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
+				struct vm_area_struct *vma,
 				unsigned long address,
 				enum mmu_event event);
 
@@ -185,11 +186,13 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
+				       struct vm_area_struct *vma,
 				       unsigned long start,
 				       unsigned long end,
 				       enum mmu_event event);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
+				     struct vm_area_struct *vma,
 				     unsigned long start,
 				     unsigned long end,
 				     enum mmu_event event);
@@ -233,13 +236,16 @@ extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      pte_t pte,
 				      enum mmu_event event);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+					   struct vm_area_struct *vma,
 					  unsigned long address,
 					  enum mmu_event event);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+						  struct vm_area_struct *vma,
 						  unsigned long start,
 						  unsigned long end,
 						  enum mmu_event event);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+						struct vm_area_struct *vma,
 						unsigned long start,
 						unsigned long end,
 						enum mmu_event event);
@@ -276,29 +282,33 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+						struct vm_area_struct *vma,
 						unsigned long address,
 						enum mmu_event event)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_page(mm, address, event);
+		__mmu_notifier_invalidate_page(mm, vma, address, event);
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+						       struct vm_area_struct *vma,
 						       unsigned long start,
 						       unsigned long end,
 						       enum mmu_event event)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end, event);
+		__mmu_notifier_invalidate_range_start(mm, vma, start,
+						      end, event);
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+						     struct vm_area_struct *vma,
 						     unsigned long start,
 						     unsigned long end,
 						     enum mmu_event event)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end, event);
+		__mmu_notifier_invalidate_range_end(mm, vma, start, end, event);
 }
 
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
@@ -380,12 +390,14 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+						struct vm_area_struct *vma,
 						unsigned long address,
 						enum mmu_event event)
 {
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+						       struct vm_area_struct *vma,
 						       unsigned long start,
 						       unsigned long end,
 						       enum mmu_event event)
@@ -393,6 +405,7 @@ static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+						     struct vm_area_struct *vma,
 						     unsigned long start,
 						     unsigned long end,
 						     enum mmu_event event)
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 296f81e..0f552bc 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -177,7 +177,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
@@ -212,7 +212,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	err = 0;
  unlock:
 	mem_cgroup_cancel_charge(kpage, memcg);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 	unlock_page(page);
 	return err;
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index a2b3f09..f0113df 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -198,7 +198,8 @@ retry:
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			/* must invalidate_page _before_ freeing the page */
-			mmu_notifier_invalidate_page(mm, address, MMU_MIGRATE);
+			mmu_notifier_invalidate_page(mm, vma, address,
+						     MMU_MIGRATE);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fa30857..cc74b60 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1022,7 +1022,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
@@ -1064,7 +1064,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	page_remove_rmap(page);
 	spin_unlock(ptl);
 
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	ret |= VM_FAULT_WRITE;
@@ -1075,7 +1075,7 @@ out:
 
 out_free_pages:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		memcg = (void *)page_private(pages[i]);
@@ -1162,7 +1162,7 @@ alloc:
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 
 	if (!page)
@@ -1201,7 +1201,7 @@ alloc:
 	}
 	spin_unlock(ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 out:
 	return ret;
@@ -1637,7 +1637,7 @@ static int __split_huge_page_splitting(struct page *page,
 	const unsigned long mmun_start = address;
 	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_STATUS);
 	pmd = page_check_address_pmd(page, mm, address,
 			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
@@ -1653,7 +1653,7 @@ static int __split_huge_page_splitting(struct page *page,
 		ret = 1;
 		spin_unlock(ptl);
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_STATUS);
 
 	return ret;
@@ -2453,7 +2453,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	mmun_start = address;
 	mmun_end   = address + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
@@ -2464,7 +2464,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	_pmd = pmdp_clear_flush(vma, address, pmd);
 	spin_unlock(pmd_ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	spin_lock(pte_ptl);
@@ -2854,19 +2854,19 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 again:
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start,
+		mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 		return;
 	}
 	if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start,
+		mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 		return;
 	}
@@ -2874,7 +2874,7 @@ again:
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	get_page(page);
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	split_huge_page(page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 73e1576..15f0123 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2565,7 +2565,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	mmun_start = vma->vm_start;
 	mmun_end = vma->vm_end;
 	if (cow)
-		mmu_notifier_invalidate_range_start(src, mmun_start,
+		mmu_notifier_invalidate_range_start(src, vma, mmun_start,
 						    mmun_end, MMU_MIGRATE);
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
@@ -2616,7 +2616,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	}
 
 	if (cow)
-		mmu_notifier_invalidate_range_end(src, mmun_start,
+		mmu_notifier_invalidate_range_end(src, vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 
 	return ret;
@@ -2643,7 +2643,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	BUG_ON(end & ~huge_page_mask(h));
 
 	tlb_start_vma(tlb, vma);
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 again:
 	for (address = start; address < end; address += sz) {
@@ -2715,7 +2715,7 @@ unlock:
 		if (address < end && !ref_page)
 			goto again;
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 	tlb_end_vma(tlb, vma);
 }
@@ -2903,7 +2903,7 @@ retry_avoidcopy:
 
 	mmun_start = address & huge_page_mask(h);
 	mmun_end = mmun_start + huge_page_size(h);
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 	/*
 	 * Retake the page table lock to check for racing updates
@@ -2924,7 +2924,7 @@ retry_avoidcopy:
 		new_page = old_page;
 	}
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
@@ -3363,7 +3363,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mmu_notifier_invalidate_range_start(mm, start, end, event);
+	mmu_notifier_invalidate_range_start(mm, vma, start, end, event);
 	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
@@ -3393,7 +3393,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 */
 	flush_tlb_range(vma, start, end);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
-	mmu_notifier_invalidate_range_end(mm, start, end, event);
+	mmu_notifier_invalidate_range_end(mm, vma, start, end, event);
 
 	return pages << h->order;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 4b659f1..1f3c4d7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -873,7 +873,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MPROT_RONLY);
 
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
@@ -914,7 +914,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MPROT_RONLY);
 out:
 	return err;
@@ -951,7 +951,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
@@ -977,7 +977,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 out:
 	return err;
diff --git a/mm/memory.c b/mm/memory.c
index d3908f0..4717579 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1049,7 +1049,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	mmun_start = addr;
 	mmun_end   = end;
 	if (is_cow)
-		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
+		mmu_notifier_invalidate_range_start(src_mm, vma, mmun_start,
 						    mmun_end, MMU_MIGRATE);
 
 	ret = 0;
@@ -1067,8 +1067,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow)
-		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end,
-						  MMU_MIGRATE);
+		mmu_notifier_invalidate_range_end(src_mm, vma, mmun_start,
+						  mmun_end, MMU_MIGRATE);
 	return ret;
 }
 
@@ -1372,12 +1372,17 @@ void unmap_vmas(struct mmu_gather *tlb,
 {
 	struct mm_struct *mm = vma->vm_mm;
 
-	mmu_notifier_invalidate_range_start(mm, start_addr,
-					    end_addr, MMU_MUNMAP);
-	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
+	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
+		mmu_notifier_invalidate_range_start(mm, vma,
+						    max(start_addr, vma->vm_start),
+						    min(end_addr, vma->vm_end),
+						    MMU_MUNMAP);
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
-	mmu_notifier_invalidate_range_end(mm, start_addr,
-					  end_addr, MMU_MUNMAP);
+		mmu_notifier_invalidate_range_end(mm, vma,
+						  max(start_addr, vma->vm_start),
+						  min(end_addr, vma->vm_end),
+						  MMU_MUNMAP);
+	}
 }
 
 /**
@@ -1399,10 +1404,17 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
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
 
@@ -1425,9 +1437,9 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
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
 
@@ -2211,7 +2223,7 @@ gotten:
 
 	mmun_start  = address & PAGE_MASK;
 	mmun_end    = mmun_start + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 
 	/*
@@ -2283,7 +2295,7 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (mmun_end > mmun_start)
-		mmu_notifier_invalidate_range_end(mm, mmun_start,
+		mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 	if (old_page) {
 		/*
diff --git a/mm/migrate.c b/mm/migrate.c
index b526c72..0c61aa9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1820,13 +1820,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
 fail_putback:
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start,
+		mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 
 		/* Reverse changes made by migrate_page_copy() */
@@ -1880,7 +1880,7 @@ fail_putback:
 	page_remove_rmap(page);
 
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 9decb88..87e6bc5 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -139,6 +139,7 @@ void __mmu_notifier_change_pte(struct mm_struct *mm,
 }
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+				    struct vm_area_struct *vma,
 				    unsigned long address,
 				    enum mmu_event event)
 {
@@ -148,12 +149,13 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address, event);
+			mn->ops->invalidate_page(mn, mm, vma, address, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+					   struct vm_area_struct *vma,
 					   unsigned long start,
 					   unsigned long end,
 					   enum mmu_event event)
@@ -165,7 +167,7 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start,
+			mn->ops->invalidate_range_start(mn, vma, mm, start,
 							end, event);
 	}
 	srcu_read_unlock(&srcu, id);
@@ -173,6 +175,7 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+					 struct vm_area_struct *vma,
 					 unsigned long start,
 					 unsigned long end,
 					 enum mmu_event event)
@@ -183,7 +186,7 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start,
+			mn->ops->invalidate_range_end(mn, vma, mm, start,
 						      end, event);
 	}
 	srcu_read_unlock(&srcu, id);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 6ce6c23..16ce504 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -158,7 +158,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		/* invoke the mmu notifier if the pmd is populated */
 		if (!mni_start) {
 			mni_start = addr;
-			mmu_notifier_invalidate_range_start(mm, mni_start,
+			mmu_notifier_invalidate_range_start(mm, vma, mni_start,
 							    end, event);
 		}
 
@@ -187,7 +187,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	} while (pmd++, addr = next, addr != end);
 
 	if (mni_start)
-		mmu_notifier_invalidate_range_end(mm, mni_start, end, event);
+		mmu_notifier_invalidate_range_end(mm, vma, mni_start,
+						  end, event);
 
 	if (nr_huge_updates)
 		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
diff --git a/mm/mremap.c b/mm/mremap.c
index 6827d2f..9bee6de 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -177,7 +177,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 	mmun_start = old_addr;
 	mmun_end   = old_end;
-	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start,
+	mmu_notifier_invalidate_range_start(vma->vm_mm, vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
@@ -229,7 +229,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	if (likely(need_flush))
 		flush_tlb_range(vma, old_end-len, old_addr);
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma->vm_mm, vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	return len + old_addr - old_end;	/* how much done */
diff --git a/mm/rmap.c b/mm/rmap.c
index bd7e6d7..f1be50d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -840,7 +840,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 
 	if (ret) {
-		mmu_notifier_invalidate_page(mm, address, MMU_WB);
+		mmu_notifier_invalidate_page(mm, vma, address, MMU_WB);
 		(*cleaned)++;
 	}
 out:
@@ -1237,7 +1237,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address, event);
+		mmu_notifier_invalidate_page(mm, vma, address, event);
 out:
 	return ret;
 
@@ -1325,7 +1325,8 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 	mmun_start = address;
 	mmun_end   = end;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, event);
+	mmu_notifier_invalidate_range_start(mm, vma, mmun_start,
+					    mmun_end, event);
 
 	/*
 	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
@@ -1390,7 +1391,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, event);
+	mmu_notifier_invalidate_range_end(mm, vma, mmun_start, mmun_end, event);
 	if (locked_vma)
 		up_read(&vma->vm_mm->mmap_sem);
 	return ret;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 6e1992f..c4b7bf9 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -262,6 +262,7 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
 
 static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
+					     struct vm_area_struct *vma,
 					     unsigned long address,
 					     enum mmu_event event)
 {
@@ -318,6 +319,7 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 
 static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						    struct mm_struct *mm,
+						    struct vm_area_struct *vma,
 						    unsigned long start,
 						    unsigned long end,
 						    enum mmu_event event)
@@ -345,6 +347,7 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
 						  struct mm_struct *mm,
+						  struct vm_area_struct *vma,
 						  unsigned long start,
 						  unsigned long end,
 						  enum mmu_event event)
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
