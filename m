Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id B72EC6B0038
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 14:47:23 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id j15so2154662qaq.25
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 11:47:23 -0700 (PDT)
Received: from mail-qc0-x22d.google.com (mail-qc0-x22d.google.com [2607:f8b0:400d:c01::22d])
        by mx.google.com with ESMTPS id i64si5491149qge.60.2014.07.17.11.47.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 11:47:23 -0700 (PDT)
Received: by mail-qc0-f173.google.com with SMTP id c9so2481182qcz.32
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 11:47:23 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 3/7] mmu_notifier: pass through vma to invalidate_range and invalidate_page v3
Date: Thu, 17 Jul 2014 14:46:49 -0400
Message-Id: <1405622809-3797-4-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
References: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

New user of the mmu_notifier interface need to lookup vma in order to
perform the invalidation operation. Instead of redoing a vma lookup
inside the callback just pass through the vma from the call site where
it is already available.

This needs small refactoring in memory.c to call invalidate_range on
vma boundary while previously it was call once for larger range. The
affected function are :
  - unmap_vmas() call either from exit_mmap or from munmap syscall. For
  exit_mmap the overhead might be important but this only happen when
  a process exit. For the munmap case, it should be low to no overhead
  if we assume that munmap is usual use on per vma basis.
  - zap_page_range() only call to zap_page_range that are not already
  clamp to a single vma are call from the madvice syscall. I think it
  is a fair assumption that even for this case the overhead will not
  hurt performances.
  - zap_page_range_single() change as no impact as this function was a
  per vma function.

Changed since v1 :
  - Only passthrough the vma.
  - Commit comment.

Changed since v2 :
  - Updated commit message to evaluate impact of mmu_notifier call per
    vma while they were over range which could cover several vma before.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/gpu/drm/i915/i915_gem_userptr.c |  1 +
 drivers/iommu/amd_iommu_v2.c            |  6 ++---
 drivers/misc/sgi-gru/grutlbpurge.c      |  8 ++++---
 drivers/xen/gntdev.c                    |  6 ++---
 fs/proc/task_mmu.c                      | 16 ++++++++-----
 include/linux/mmu_notifier.h            | 41 +++++++++++++++++----------------
 kernel/events/uprobes.c                 |  4 ++--
 mm/filemap_xip.c                        |  3 ++-
 mm/huge_memory.c                        | 26 ++++++++++-----------
 mm/hugetlb.c                            | 16 ++++++-------
 mm/ksm.c                                |  8 +++----
 mm/memory.c                             | 30 ++++++++++++------------
 mm/migrate.c                            |  6 ++---
 mm/mmu_notifier.c                       | 15 +++++++-----
 mm/mprotect.c                           |  6 ++---
 mm/mremap.c                             |  4 ++--
 mm/rmap.c                               |  9 ++++----
 virt/kvm/kvm_main.c                     |  6 ++---
 18 files changed, 112 insertions(+), 99 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 8c18bb1..84a408f 100644
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
index 33482ef..9a665a0 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -421,7 +421,7 @@ static void mn_change_pte(struct mmu_notifier *mn,
 }
 
 static void mn_invalidate_page(struct mmu_notifier *mn,
-			       struct mm_struct *mm,
+			       struct vm_area_struct *vma,
 			       unsigned long address,
 			       enum mmu_event event)
 {
@@ -429,7 +429,7 @@ static void mn_invalidate_page(struct mmu_notifier *mn,
 }
 
 static void mn_invalidate_range_start(struct mmu_notifier *mn,
-				      struct mm_struct *mm,
+				      struct vm_area_struct *vma,
 				      unsigned long start,
 				      unsigned long end,
 				      enum mmu_event event)
@@ -452,7 +452,7 @@ static void mn_invalidate_range_start(struct mmu_notifier *mn,
 }
 
 static void mn_invalidate_range_end(struct mmu_notifier *mn,
-				    struct mm_struct *mm,
+				    struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    enum mmu_event event)
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index e67fed1..ef29b45 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -220,7 +220,7 @@ void gru_flush_all_tlb(struct gru_state *gru)
  * MMUOPS notifier callout functions
  */
 static void gru_invalidate_range_start(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
+				       struct vm_area_struct *vma,
 				       unsigned long start, unsigned long end,
 				       enum mmu_event event)
 {
@@ -235,7 +235,8 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
 }
 
 static void gru_invalidate_range_end(struct mmu_notifier *mn,
-				     struct mm_struct *mm, unsigned long start,
+				     struct vm_area_struct *vma,
+				     unsigned long start,
 				     unsigned long end,
 				     enum mmu_event event)
 {
@@ -249,7 +250,8 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms, start, end);
 }
 
-static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
+static void gru_invalidate_page(struct mmu_notifier *mn,
+				struct vm_area_struct *vma,
 				unsigned long address,
 				enum mmu_event event)
 {
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index fe9da94..768f425 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -427,7 +427,7 @@ static void unmap_if_in_range(struct grant_map *map,
 }
 
 static void mn_invl_range_start(struct mmu_notifier *mn,
-				struct mm_struct *mm,
+				struct vm_area_struct *vma,
 				unsigned long start,
 				unsigned long end,
 				enum mmu_event event)
@@ -446,11 +446,11 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
 }
 
 static void mn_invl_page(struct mmu_notifier *mn,
-			 struct mm_struct *mm,
+			 struct vm_area_struct *vma,
 			 unsigned long address,
 			 enum mmu_event event)
 {
-	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE, event);
+	mn_invl_range_start(mn, vma, address, address + PAGE_SIZE, event);
 }
 
 static void mn_release(struct mmu_notifier *mn,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index e9e79f7..d1ed285 100644
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
+				mmu_notifier_invalidate_range_start(vma,
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
+				mmu_notifier_invalidate_range_end(vma,
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
index 496ff08..798ecfa 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -142,7 +142,7 @@ struct mmu_notifier_ops {
 	 * be called internally to this method.
 	 */
 	void (*invalidate_page)(struct mmu_notifier *mn,
-				struct mm_struct *mm,
+				struct vm_area_struct *vma,
 				unsigned long address,
 				enum mmu_event event);
 
@@ -190,12 +190,12 @@ struct mmu_notifier_ops {
 	 * the last refcount is dropped.
 	 */
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
+				       struct vm_area_struct *vma,
 				       unsigned long start,
 				       unsigned long end,
 				       enum mmu_event event);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
-				     struct mm_struct *mm,
+				     struct vm_area_struct *vma,
 				     unsigned long start,
 				     unsigned long end,
 				     enum mmu_event event);
@@ -240,14 +240,14 @@ extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      unsigned long address,
 				      pte_t pte,
 				      enum mmu_event event);
-extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address,
-					  enum mmu_event event);
-extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+extern void __mmu_notifier_invalidate_page(struct vm_area_struct *vma,
+					   unsigned long address,
+					   enum mmu_event event);
+extern void __mmu_notifier_invalidate_range_start(struct vm_area_struct *vma,
 						  unsigned long start,
 						  unsigned long end,
 						  enum mmu_event event);
-extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+extern void __mmu_notifier_invalidate_range_end(struct vm_area_struct *vma,
 						unsigned long start,
 						unsigned long end,
 						enum mmu_event event);
@@ -283,30 +283,31 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 		__mmu_notifier_change_pte(mm, address, pte, event);
 }
 
-static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+static inline void mmu_notifier_invalidate_page(struct vm_area_struct *vma,
 						unsigned long address,
 						enum mmu_event event)
 {
-	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_page(mm, address, event);
+	if (mm_has_notifiers(vma->vm_mm))
+		__mmu_notifier_invalidate_page(vma, address, event);
 }
 
-static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+static inline void mmu_notifier_invalidate_range_start(struct vm_area_struct *vma,
 						       unsigned long start,
 						       unsigned long end,
 						       enum mmu_event event)
 {
-	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end, event);
+	if (mm_has_notifiers(vma->vm_mm))
+		__mmu_notifier_invalidate_range_start(vma, start,
+						      end, event);
 }
 
-static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+static inline void mmu_notifier_invalidate_range_end(struct vm_area_struct *vma,
 						     unsigned long start,
 						     unsigned long end,
 						     enum mmu_event event)
 {
-	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end, event);
+	if (mm_has_notifiers(vma->vm_mm))
+		__mmu_notifier_invalidate_range_end(vma, start, end, event);
 }
 
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
@@ -391,20 +392,20 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 {
 }
 
-static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+static inline void mmu_notifier_invalidate_page(struct vm_area_struct *vma,
 						unsigned long address,
 						enum mmu_event event)
 {
 }
 
-static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+static inline void mmu_notifier_invalidate_range_start(struct vm_area_struct *vma,
 						       unsigned long start,
 						       unsigned long end,
 						       enum mmu_event event)
 {
 }
 
-static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+static inline void mmu_notifier_invalidate_range_end(struct vm_area_struct *vma,
 						     unsigned long start,
 						     unsigned long end,
 						     enum mmu_event event)
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 62d07e9..8c65320 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -176,7 +176,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
@@ -211,7 +211,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	err = 0;
  unlock:
 	mem_cgroup_cancel_charge(kpage, memcg);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
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
index a2f1a20..d60043b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1029,7 +1029,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+	mmu_notifier_invalidate_range_start(vma, mmun_start, mmun_end,
 					    MMU_MIGRATE);
 
 	ptl = pmd_lock(mm, pmd);
@@ -1064,7 +1064,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	page_remove_rmap(page);
 	spin_unlock(ptl);
 
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	ret |= VM_FAULT_WRITE;
@@ -1075,7 +1075,7 @@ out:
 
 out_free_pages:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		memcg = (void *)page_private(pages[i]);
@@ -1168,7 +1168,7 @@ alloc:
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+	mmu_notifier_invalidate_range_start(vma, mmun_start, mmun_end,
 					    MMU_MIGRATE);
 
 	spin_lock(ptl);
@@ -1201,7 +1201,7 @@ alloc:
 	}
 	spin_unlock(ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 out:
 	return ret;
@@ -1637,7 +1637,7 @@ static int __split_huge_page_splitting(struct page *page,
 	const unsigned long mmun_start = address;
 	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(vma, mmun_start,
 					    mmun_end, MMU_STATUS);
 	pmd = page_check_address_pmd(page, mm, address,
 			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
@@ -1653,7 +1653,7 @@ static int __split_huge_page_splitting(struct page *page,
 		ret = 1;
 		spin_unlock(ptl);
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
 					  mmun_end, MMU_STATUS);
 
 	return ret;
@@ -2453,7 +2453,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	mmun_start = address;
 	mmun_end   = address + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
@@ -2464,7 +2464,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	_pmd = pmdp_clear_flush(vma, address, pmd);
 	spin_unlock(pmd_ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	spin_lock(pte_ptl);
@@ -2854,19 +2854,19 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 again:
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start,
+		mmu_notifier_invalidate_range_end(vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 		return;
 	}
 	if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start,
+		mmu_notifier_invalidate_range_end(vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 		return;
 	}
@@ -2874,7 +2874,7 @@ again:
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	get_page(page);
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	split_huge_page(page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index fc38555..e2736f4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2557,7 +2557,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	mmun_start = vma->vm_start;
 	mmun_end = vma->vm_end;
 	if (cow)
-		mmu_notifier_invalidate_range_start(src, mmun_start,
+		mmu_notifier_invalidate_range_start(vma, mmun_start,
 						    mmun_end, MMU_MIGRATE);
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
@@ -2608,7 +2608,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	}
 
 	if (cow)
-		mmu_notifier_invalidate_range_end(src, mmun_start,
+		mmu_notifier_invalidate_range_end(vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 
 	return ret;
@@ -2635,7 +2635,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	BUG_ON(end & ~huge_page_mask(h));
 
 	tlb_start_vma(tlb, vma);
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 again:
 	for (address = start; address < end; address += sz) {
@@ -2707,7 +2707,7 @@ unlock:
 		if (address < end && !ref_page)
 			goto again;
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 	tlb_end_vma(tlb, vma);
 }
@@ -2886,7 +2886,7 @@ retry_avoidcopy:
 
 	mmun_start = address & huge_page_mask(h);
 	mmun_end = mmun_start + huge_page_size(h);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+	mmu_notifier_invalidate_range_start(vma, mmun_start, mmun_end,
 					    MMU_MIGRATE);
 	/*
 	 * Retake the page table lock to check for racing updates
@@ -2907,7 +2907,7 @@ retry_avoidcopy:
 		new_page = old_page;
 	}
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
+	mmu_notifier_invalidate_range_end(vma, mmun_start, mmun_end,
 					  MMU_MIGRATE);
 out_release_all:
 	page_cache_release(new_page);
@@ -3346,7 +3346,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MPROT);
+	mmu_notifier_invalidate_range_start(vma, start, end, MMU_MPROT);
 	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
@@ -3376,7 +3376,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 */
 	flush_tlb_range(vma, start, end);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
-	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MPROT);
+	mmu_notifier_invalidate_range_end(vma, start, end, MMU_MPROT);
 
 	return pages << h->order;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 21d210b..d64c0b4 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -872,7 +872,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+	mmu_notifier_invalidate_range_start(vma, mmun_start, mmun_end,
 					    MMU_WRITE_PROTECT);
 
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
@@ -913,7 +913,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
+	mmu_notifier_invalidate_range_end(vma, mmun_start, mmun_end,
 					  MMU_WRITE_PROTECT);
 out:
 	return err;
@@ -950,7 +950,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+	mmu_notifier_invalidate_range_start(vma, mmun_start, mmun_end,
 					    MMU_MIGRATE);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
@@ -976,7 +976,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
+	mmu_notifier_invalidate_range_end(vma, mmun_start, mmun_end,
 					  MMU_MIGRATE);
 out:
 	return err;
diff --git a/mm/memory.c b/mm/memory.c
index 4dae9f5..409cace 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1049,7 +1049,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	mmun_start = addr;
 	mmun_end   = end;
 	if (is_cow)
-		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
+		mmu_notifier_invalidate_range_start(vma, mmun_start,
 						    mmun_end, MMU_MIGRATE);
 
 	ret = 0;
@@ -1067,8 +1067,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow)
-		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end,
-						  MMU_MIGRATE);
+		mmu_notifier_invalidate_range_end(vma, mmun_start,
+						  mmun_end, MMU_MIGRATE);
 	return ret;
 }
 
@@ -1319,6 +1319,11 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 	if (end <= vma->vm_start)
 		return;
 
+	mmu_notifier_invalidate_range_start(vma,
+					    max(start_addr, vma->vm_start),
+					    min(end_addr, vma->vm_end),
+					    MMU_MUNMAP);
+
 	if (vma->vm_file)
 		uprobe_munmap(vma, start, end);
 
@@ -1346,6 +1351,11 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 		} else
 			unmap_page_range(tlb, vma, start, end, details);
 	}
+
+	mmu_notifier_invalidate_range_end(vma,
+					  max(start_addr, vma->vm_start),
+					  min(end_addr, vma->vm_end),
+					  MMU_MUNMAP);
 }
 
 /**
@@ -1370,14 +1380,8 @@ void unmap_vmas(struct mmu_gather *tlb,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr)
 {
-	struct mm_struct *mm = vma->vm_mm;
-
-	mmu_notifier_invalidate_range_start(mm, start_addr,
-					    end_addr, MMU_MUNMAP);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
-	mmu_notifier_invalidate_range_end(mm, start_addr,
-					  end_addr, MMU_MUNMAP);
 }
 
 /**
@@ -1399,10 +1403,8 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, start, end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MUNMAP);
 	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
 		unmap_single_vma(&tlb, vma, start, end, details);
-	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MUNMAP);
 	tlb_finish_mmu(&tlb, start, end);
 }
 
@@ -1425,9 +1427,7 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, address, end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, address, end, MMU_MUNMAP);
 	unmap_single_vma(&tlb, vma, address, end, details);
-	mmu_notifier_invalidate_range_end(mm, address, end, MMU_MUNMAP);
 	tlb_finish_mmu(&tlb, address, end);
 }
 
@@ -2211,7 +2211,7 @@ gotten:
 
 	mmun_start  = address & PAGE_MASK;
 	mmun_end    = mmun_start + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 
 	/*
@@ -2283,7 +2283,7 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (mmun_end > mmun_start)
-		mmu_notifier_invalidate_range_end(mm, mmun_start,
+		mmu_notifier_invalidate_range_end(vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 	if (old_page) {
 		/*
diff --git a/mm/migrate.c b/mm/migrate.c
index 791e265..73cdf4d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1820,13 +1820,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
+	mmu_notifier_invalidate_range_start(vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
 fail_putback:
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start,
+		mmu_notifier_invalidate_range_end(vma, mmun_start,
 						  mmun_end, MMU_MIGRATE);
 
 		/* Reverse changes made by migrate_page_copy() */
@@ -1880,7 +1880,7 @@ fail_putback:
 	page_remove_rmap(page);
 
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index de039e4..5d5fe2d 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -157,52 +157,55 @@ void __mmu_notifier_change_pte(struct mm_struct *mm,
 	srcu_read_unlock(&srcu, id);
 }
 
-void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+void __mmu_notifier_invalidate_page(struct vm_area_struct *vma,
 				    unsigned long address,
 				    enum mmu_event event)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_notifier *mn;
 	int id;
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address, event);
+			mn->ops->invalidate_page(mn, vma, address, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 
-void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+void __mmu_notifier_invalidate_range_start(struct vm_area_struct *vma,
 					   unsigned long start,
 					   unsigned long end,
 					   enum mmu_event event)
 
 {
+	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_notifier *mn;
 	int id;
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start,
+			mn->ops->invalidate_range_start(mn, vma, start,
 							end, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
-void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+void __mmu_notifier_invalidate_range_end(struct vm_area_struct *vma,
 					 unsigned long start,
 					 unsigned long end,
 					 enum mmu_event event)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_notifier *mn;
 	int id;
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start,
+			mn->ops->invalidate_range_end(mn, vma, start,
 						      end, event);
 	}
 	srcu_read_unlock(&srcu, id);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 886405b..fdcb254 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -140,7 +140,6 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		pgprot_t newprot, int dirty_accountable, int prot_numa)
 {
 	pmd_t *pmd;
-	struct mm_struct *mm = vma->vm_mm;
 	unsigned long next;
 	unsigned long pages = 0;
 	unsigned long nr_huge_updates = 0;
@@ -157,7 +156,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		/* invoke the mmu notifier if the pmd is populated */
 		if (!mni_start) {
 			mni_start = addr;
-			mmu_notifier_invalidate_range_start(mm, mni_start,
+			mmu_notifier_invalidate_range_start(vma, mni_start,
 							    end, MMU_MPROT);
 		}
 
@@ -186,7 +185,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	} while (pmd++, addr = next, addr != end);
 
 	if (mni_start)
-		mmu_notifier_invalidate_range_end(mm, mni_start, end, MMU_MPROT);
+		mmu_notifier_invalidate_range_end(vma, mni_start,
+						  end, MMU_MPROT);
 
 	if (nr_huge_updates)
 		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
diff --git a/mm/mremap.c b/mm/mremap.c
index 6827d2f..a223c20 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -177,7 +177,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 	mmun_start = old_addr;
 	mmun_end   = old_end;
-	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start,
+	mmu_notifier_invalidate_range_start(vma, mmun_start,
 					    mmun_end, MMU_MIGRATE);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
@@ -229,7 +229,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	if (likely(need_flush))
 		flush_tlb_range(vma, old_end-len, old_addr);
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start,
+	mmu_notifier_invalidate_range_end(vma, mmun_start,
 					  mmun_end, MMU_MIGRATE);
 
 	return len + old_addr - old_end;	/* how much done */
diff --git a/mm/rmap.c b/mm/rmap.c
index 6b053cd..c2382c7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -840,7 +840,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 
 	if (ret) {
-		mmu_notifier_invalidate_page(mm, address, MMU_WRITE_BACK);
+		mmu_notifier_invalidate_page(vma, address, MMU_WRITE_BACK);
 		(*cleaned)++;
 	}
 out:
@@ -1237,7 +1237,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address, event);
+		mmu_notifier_invalidate_page(vma, address, event);
 out:
 	return ret;
 
@@ -1325,7 +1325,8 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 	mmun_start = address;
 	mmun_end   = end;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, event);
+	mmu_notifier_invalidate_range_start(vma, mmun_start,
+					    mmun_end, event);
 
 	/*
 	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
@@ -1390,7 +1391,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, event);
+	mmu_notifier_invalidate_range_end(vma, mmun_start, mmun_end, event);
 	if (locked_vma)
 		up_read(&vma->vm_mm->mmap_sem);
 	return ret;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 6e1992f..35ed19c 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -261,7 +261,7 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
 }
 
 static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
-					     struct mm_struct *mm,
+					     struct vm_area_struct *vma,
 					     unsigned long address,
 					     enum mmu_event event)
 {
@@ -317,7 +317,7 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 }
 
 static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						    struct mm_struct *mm,
+						    struct vm_area_struct *vma,
 						    unsigned long start,
 						    unsigned long end,
 						    enum mmu_event event)
@@ -344,7 +344,7 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 }
 
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						  struct mm_struct *mm,
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
