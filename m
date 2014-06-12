Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id E22456B0107
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:57:42 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id i8so2633632qcq.34
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 11:57:42 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id h6si2085733qcm.9.2014.06.12.11.57.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 11:57:42 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id j15so2187962qaq.26
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 11:57:42 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 2/5] mmu_notifier: add action information to address invalidation.
Date: Thu, 12 Jun 2014 14:57:31 -0400
Message-Id: <1402599454-3526-2-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1402599454-3526-1-git-send-email-j.glisse@gmail.com>
References: <1402598029-3331-1-git-send-email-j.glisse@gmail.com>
 <1402599454-3526-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

The action information will be usefull for new user of mmu_notifier API.
The action argument differentiate between a vma disappearing, a page
being write protected or simply a page being unmaped. This allow new
user to take different action for instance on unmap the resource used
to track a vma are still valid and should stay around if need be.
While if the action is saying that a vma is being destroy it means that
that any resources used to track this vma can be free.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/gpu/drm/i915/i915_gem_userptr.c |   3 +-
 drivers/iommu/amd_iommu_v2.c            |  14 +++--
 drivers/misc/sgi-gru/grutlbpurge.c      |   9 ++-
 drivers/xen/gntdev.c                    |   9 ++-
 fs/proc/task_mmu.c                      |   4 +-
 include/linux/hugetlb.h                 |   7 ++-
 include/linux/mmu_notifier.h            | 108 +++++++++++++++++++++++++-------
 kernel/events/uprobes.c                 |   6 +-
 mm/filemap_xip.c                        |   2 +-
 mm/huge_memory.c                        |  26 ++++----
 mm/hugetlb.c                            |  19 +++---
 mm/ksm.c                                |  12 ++--
 mm/memory.c                             |  23 +++----
 mm/mempolicy.c                          |   2 +-
 mm/migrate.c                            |   6 +-
 mm/mmu_notifier.c                       |  26 +++++---
 mm/mprotect.c                           |  30 ++++++---
 mm/mremap.c                             |   4 +-
 mm/rmap.c                               |  31 +++++++--
 virt/kvm/kvm_main.c                     |  12 ++--
 20 files changed, 238 insertions(+), 115 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 21ea928..7f7b4f3 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -56,7 +56,8 @@ struct i915_mmu_object {
 static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 						       struct mm_struct *mm,
 						       unsigned long start,
-						       unsigned long end)
+						       unsigned long end,
+						       enum mmu_action action)
 {
 	struct i915_mmu_notifier *mn = container_of(_mn, struct i915_mmu_notifier, mn);
 	struct interval_tree_node *it = NULL;
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index d4daa05..81ff80b 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -413,21 +413,25 @@ static int mn_clear_flush_young(struct mmu_notifier *mn,
 static void mn_change_pte(struct mmu_notifier *mn,
 			  struct mm_struct *mm,
 			  unsigned long address,
-			  pte_t pte)
+			  pte_t pte,
+			  enum mmu_action action)
 {
 	__mn_flush_page(mn, address);
 }
 
 static void mn_invalidate_page(struct mmu_notifier *mn,
 			       struct mm_struct *mm,
-			       unsigned long address)
+			       unsigned long address,
+			       enum mmu_action action)
 {
 	__mn_flush_page(mn, address);
 }
 
 static void mn_invalidate_range_start(struct mmu_notifier *mn,
 				      struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
+				      unsigned long start,
+				      unsigned long end,
+				      enum mmu_action action)
 {
 	struct pasid_state *pasid_state;
 	struct device_state *dev_state;
@@ -444,7 +448,9 @@ static void mn_invalidate_range_start(struct mmu_notifier *mn,
 
 static void mn_invalidate_range_end(struct mmu_notifier *mn,
 				    struct mm_struct *mm,
-				    unsigned long start, unsigned long end)
+				    unsigned long start,
+				    unsigned long end,
+				    enum mmu_action action)
 {
 	struct pasid_state *pasid_state;
 	struct device_state *dev_state;
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index 2129274..3427bfc 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -221,7 +221,8 @@ void gru_flush_all_tlb(struct gru_state *gru)
  */
 static void gru_invalidate_range_start(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end)
+				       unsigned long start, unsigned long end,
+				       enum mmu_action action)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -235,7 +236,8 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
 
 static void gru_invalidate_range_end(struct mmu_notifier *mn,
 				     struct mm_struct *mm, unsigned long start,
-				     unsigned long end)
+				     unsigned long end,
+				     enum mmu_action action)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -248,7 +250,8 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 }
 
 static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
-				unsigned long address)
+				unsigned long address,
+				enum mmu_action action)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 073b4a1..84aa5a7 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -428,7 +428,9 @@ static void unmap_if_in_range(struct grant_map *map,
 
 static void mn_invl_range_start(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-				unsigned long start, unsigned long end)
+				unsigned long start,
+				unsigned long end,
+				enum mmu_action action)
 {
 	struct gntdev_priv *priv = container_of(mn, struct gntdev_priv, mn);
 	struct grant_map *map;
@@ -445,9 +447,10 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
 
 static void mn_invl_page(struct mmu_notifier *mn,
 			 struct mm_struct *mm,
-			 unsigned long address)
+			 unsigned long address,
+			 enum mmu_action action)
 {
-	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE);
+	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE, action);
 }
 
 static void mn_release(struct mmu_notifier *mn,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3c16356..fda2324 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -824,11 +824,11 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		};
 		down_read(&mm->mmap_sem);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_start(mm, 0, -1);
+			mmu_notifier_invalidate_range_start(mm, 0, -1, MMU_SOFT_DIRTY);
 		for (vma = mm->mmap; vma; vma = vma->vm_next)
 			walk_page_vma(vma, &clear_refs_walk);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_end(mm, 0, -1);
+			mmu_notifier_invalidate_range_end(mm, 0, -1, MMU_SOFT_DIRTY);
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6a836ef..13ea5e8 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -6,6 +6,7 @@
 #include <linux/fs.h>
 #include <linux/hugetlb_inline.h>
 #include <linux/cgroup.h>
+#include <linux/mmu_notifier.h>
 #include <linux/list.h>
 #include <linux/kref.h>
 
@@ -103,7 +104,8 @@ struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
 int pmd_huge(pmd_t pmd);
 int pud_huge(pud_t pmd);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
-		unsigned long address, unsigned long end, pgprot_t newprot);
+		unsigned long address, unsigned long end, pgprot_t newprot,
+		enum mmu_action action);
 
 #else /* !CONFIG_HUGETLB_PAGE */
 
@@ -148,7 +150,8 @@ static inline bool isolate_huge_page(struct page *page, struct list_head *list)
 #define is_hugepage_active(x)	false
 
 static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
-		unsigned long address, unsigned long end, pgprot_t newprot)
+		unsigned long address, unsigned long end, pgprot_t newprot,
+		enum mmu_action action)
 {
 	return 0;
 }
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index deca874..90b9105 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -9,6 +9,41 @@
 struct mmu_notifier;
 struct mmu_notifier_ops;
 
+/* Action report finer information to the callback allowing the event listener
+ * to take better action. For instance WP means that the page are still valid
+ * and can be use as read only.
+ *
+ * UNMAP means the vma is still valid and that only pages are unmaped and thus
+ * they should no longer be read or written to.
+ *
+ * ZAP means vma is disappearing and that any resource that were use to track
+ * this vma can be freed.
+ *
+ * In doubt when adding a new notifier caller use ZAP it will always trigger
+ * right thing but won't be optimal.
+ */
+enum mmu_action {
+	MMU_MPROT_NONE = 0,
+	MMU_MPROT_RONLY,
+	MMU_MPROT_RANDW,
+	MMU_MPROT_WONLY,
+	MMU_COW,
+	MMU_KSM,
+	MMU_KSM_RONLY,
+	MMU_SOFT_DIRTY,
+	MMU_UNMAP,
+	MMU_VMSCAN,
+	MMU_POISON,
+	MMU_MREMAP,
+	MMU_MUNMAP,
+	MMU_MUNLOCK,
+	MMU_MIGRATE,
+	MMU_FILE_WB,
+	MMU_FAULT_WP,
+	MMU_THP_SPLIT,
+	MMU_THP_FAULT_WP,
+};
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
@@ -79,7 +114,8 @@ struct mmu_notifier_ops {
 	void (*change_pte)(struct mmu_notifier *mn,
 			   struct mm_struct *mm,
 			   unsigned long address,
-			   pte_t pte);
+			   pte_t pte,
+			   enum mmu_action action);
 
 	/*
 	 * Before this is invoked any secondary MMU is still ok to
@@ -90,7 +126,8 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-				unsigned long address);
+				unsigned long address,
+				enum mmu_action action);
 
 	/*
 	 * invalidate_range_start() and invalidate_range_end() must be
@@ -137,10 +174,14 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end);
+				       unsigned long start,
+				       unsigned long end,
+				       enum mmu_action action);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
-				     unsigned long start, unsigned long end);
+				     unsigned long start,
+				     unsigned long end,
+				     enum mmu_action action);
 };
 
 /*
@@ -177,13 +218,20 @@ extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 extern int __mmu_notifier_test_young(struct mm_struct *mm,
 				     unsigned long address);
 extern void __mmu_notifier_change_pte(struct mm_struct *mm,
-				      unsigned long address, pte_t pte);
+				      unsigned long address,
+				      pte_t pte,
+				      enum mmu_action action);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address);
+					   unsigned long address,
+					   enum mmu_action action);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
+						  unsigned long start,
+						  unsigned long end,
+						  enum mmu_action action);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
+						unsigned long start,
+						unsigned long end,
+						enum mmu_action action);
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
@@ -208,31 +256,38 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_change_pte(struct mm_struct *mm,
-					   unsigned long address, pte_t pte)
+					   unsigned long address,
+					   pte_t pte,
+					   enum mmu_action action)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_change_pte(mm, address, pte);
+		__mmu_notifier_change_pte(mm, address, pte, action);
 }
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
+						unsigned long address,
+						enum mmu_action action)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_page(mm, address);
+		__mmu_notifier_invalidate_page(mm, address, action);
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+						       unsigned long start,
+						       unsigned long end,
+						       enum mmu_action action)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end);
+		__mmu_notifier_invalidate_range_start(mm, start, end, action);
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+						     unsigned long start,
+						     unsigned long end,
+						     enum mmu_action action)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end);
+		__mmu_notifier_invalidate_range_end(mm, start, end, action);
 }
 
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
@@ -278,13 +333,13 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
  * old page would remain mapped readonly in the secondary MMUs after the new
  * page is already writable by some CPU through the primary MMU.
  */
-#define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
+#define set_pte_at_notify(__mm, __address, __ptep, __pte, __action)	\
 ({									\
 	struct mm_struct *___mm = __mm;					\
 	unsigned long ___address = __address;				\
 	pte_t ___pte = __pte;						\
 									\
-	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
+	mmu_notifier_change_pte(___mm, ___address, ___pte, __action);	\
 	set_pte_at(___mm, ___address, __ptep, ___pte);			\
 })
 
@@ -307,22 +362,29 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_change_pte(struct mm_struct *mm,
-					   unsigned long address, pte_t pte)
+					   unsigned long address,
+					   pte_t pte,
+					   enum mmu_action action)
 {
 }
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
+						unsigned long address,
+						enum mmu_action action)
 {
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+						       unsigned long start,
+						       unsigned long end,
+						       enum mmu_action action)
 {
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+						     unsigned long start,
+						     unsigned long end,
+						     enum mmu_action action)
 {
 }
 
@@ -336,7 +398,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
-#define set_pte_at_notify set_pte_at
+#define set_pte_at_notify(__mm, __address, __ptep, __pte, __action) set_pte_at(__mm, __address, __ptep, __pte)
 
 #endif /* CONFIG_MMU_NOTIFIER */
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index c445e39..3e2308f 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -171,7 +171,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_UNMAP);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -187,7 +187,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot), MMU_UNMAP);
 
 	page_remove_rmap(page);
 	if (!page_mapped(page))
@@ -200,7 +200,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	err = 0;
  unlock:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_UNMAP);
 	unlock_page(page);
 	return err;
 }
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index d8d9fe3..d529ab9 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -198,7 +198,7 @@ retry:
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			/* must invalidate_page _before_ freeing the page */
-			mmu_notifier_invalidate_page(mm, address);
+			mmu_notifier_invalidate_page(mm, address, MMU_UNMAP);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c5ff461..4ad9b73 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -993,7 +993,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
@@ -1023,7 +1023,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	page_remove_rmap(page);
 	spin_unlock(ptl);
 
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
@@ -1033,7 +1033,7 @@ out:
 
 out_free_pages:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 	mem_cgroup_uncharge_start();
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		mem_cgroup_uncharge_page(pages[i]);
@@ -1123,7 +1123,7 @@ alloc:
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 
 	spin_lock(ptl);
 	if (page)
@@ -1153,7 +1153,7 @@ alloc:
 	}
 	spin_unlock(ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_FAULT_WP);
 out:
 	return ret;
 out_unlock:
@@ -1588,7 +1588,7 @@ static int __split_huge_page_splitting(struct page *page,
 	const unsigned long mmun_start = address;
 	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
 	pmd = page_check_address_pmd(page, mm, address,
 			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
 	if (pmd) {
@@ -1603,7 +1603,7 @@ static int __split_huge_page_splitting(struct page *page,
 		ret = 1;
 		spin_unlock(ptl);
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
 
 	return ret;
 }
@@ -2402,7 +2402,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	mmun_start = address;
 	mmun_end   = address + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
@@ -2412,7 +2412,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	_pmd = pmdp_clear_flush(vma, address, pmd);
 	spin_unlock(pmd_ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
 
 	spin_lock(pte_ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
@@ -2801,24 +2801,24 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 again:
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
 		return;
 	}
 	if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
 		return;
 	}
 	page = pmd_page(*pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	get_page(page);
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_THP_SPLIT);
 
 	split_huge_page(page);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2e7ac30..bfb455e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2540,7 +2540,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	mmun_start = vma->vm_start;
 	mmun_end = vma->vm_end;
 	if (cow)
-		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end, MMU_COW);
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
@@ -2574,7 +2574,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	}
 
 	if (cow)
-		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end, MMU_COW);
 
 	return ret;
 }
@@ -2626,7 +2626,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	BUG_ON(end & ~huge_page_mask(h));
 
 	tlb_start_vma(tlb, vma);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_UNMAP);
 again:
 	for (address = start; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
@@ -2697,7 +2697,7 @@ unlock:
 		if (address < end && !ref_page)
 			goto again;
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_UNMAP);
 	tlb_end_vma(tlb, vma);
 }
 
@@ -2884,7 +2884,7 @@ retry_avoidcopy:
 
 	mmun_start = address & huge_page_mask(h);
 	mmun_end = mmun_start + huge_page_size(h);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_UNMAP);
 	/*
 	 * Retake the page table lock to check for racing updates
 	 * before the page tables are altered
@@ -2904,7 +2904,7 @@ retry_avoidcopy:
 		new_page = old_page;
 	}
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_UNMAP);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
 
@@ -3329,7 +3329,8 @@ same_page:
 }
 
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
-		unsigned long address, unsigned long end, pgprot_t newprot)
+		unsigned long address, unsigned long end, pgprot_t newprot,
+		enum mmu_action action)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long start = address;
@@ -3341,7 +3342,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, action);
 	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
@@ -3371,7 +3372,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 */
 	flush_tlb_range(vma, start, end);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end, action);
 
 	return pages << h->order;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 68710e8..6a32bc4 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -872,7 +872,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_KSM_RONLY);
 
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -904,7 +904,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		if (pte_dirty(entry))
 			set_page_dirty(page);
 		entry = pte_mkclean(pte_wrprotect(entry));
-		set_pte_at_notify(mm, addr, ptep, entry);
+		set_pte_at_notify(mm, addr, ptep, entry, MMU_KSM_RONLY);
 	}
 	*orig_pte = *ptep;
 	err = 0;
@@ -912,7 +912,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_KSM_RONLY);
 out:
 	return err;
 }
@@ -949,7 +949,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_KSM);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (!pte_same(*ptep, orig_pte)) {
@@ -962,7 +962,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot), MMU_KSM);
 
 	page_remove_rmap(page);
 	if (!page_mapped(page))
@@ -972,7 +972,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_KSM);
 out:
 	return err;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 532dde2..55d4e91 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1050,7 +1050,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	mmun_end   = end;
 	if (is_cow)
 		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
-						    mmun_end);
+						    mmun_end, MMU_COW);
 
 	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
@@ -1067,7 +1067,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow)
-		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end,
+						  MMU_COW);
 	return ret;
 }
 
@@ -1373,10 +1374,10 @@ void unmap_vmas(struct mmu_gather *tlb,
 {
 	struct mm_struct *mm = vma->vm_mm;
 
-	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
+	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr, MMU_MUNMAP);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
-	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
+	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr, MMU_MUNMAP);
 }
 
 /**
@@ -1398,10 +1399,10 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, start, end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MUNMAP);
 	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
 		unmap_single_vma(&tlb, vma, start, end, details);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MUNMAP);
 	tlb_finish_mmu(&tlb, start, end);
 }
 
@@ -1424,9 +1425,9 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, address, end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, address, end);
+	mmu_notifier_invalidate_range_start(mm, address, end, MMU_MUNMAP);
 	unmap_single_vma(&tlb, vma, address, end, details);
-	mmu_notifier_invalidate_range_end(mm, address, end);
+	mmu_notifier_invalidate_range_end(mm, address, end, MMU_MUNMAP);
 	tlb_finish_mmu(&tlb, address, end);
 }
 
@@ -2209,7 +2210,7 @@ gotten:
 
 	mmun_start  = address & PAGE_MASK;
 	mmun_end    = mmun_start + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_FAULT_WP);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2239,7 +2240,7 @@ gotten:
 		 * mmu page tables (such as kvm shadow page tables), we want the
 		 * new page to be mapped directly into the secondary page table.
 		 */
-		set_pte_at_notify(mm, address, page_table, entry);
+		set_pte_at_notify(mm, address, page_table, entry, MMU_FAULT_WP);
 		update_mmu_cache(vma, address, page_table);
 		if (old_page) {
 			/*
@@ -2278,7 +2279,7 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (mmun_end > mmun_start)
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_FAULT_WP);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8bc1199..156f34c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -561,7 +561,7 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	int nr_updated;
 
-	nr_updated = change_protection(vma, addr, end, vma->vm_page_prot, 0, 1);
+	nr_updated = change_protection(vma, addr, end, vma->vm_page_prot, 0, 1, 0);
 	if (nr_updated)
 		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 63f0cd5..01cd98a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1827,12 +1827,12 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, MMU_MIGRATE);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
 fail_putback:
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_MIGRATE);
 
 		/* Reverse changes made by migrate_page_copy() */
 		if (TestClearPageActive(new_page))
@@ -1898,7 +1898,7 @@ fail_putback:
 	 */
 	mem_cgroup_end_migration(memcg, page, new_page, true);
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, MMU_MIGRATE);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
 	get_page(new_page);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 41cefdf..a906744 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -122,8 +122,10 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 	return young;
 }
 
-void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
-			       pte_t pte)
+void __mmu_notifier_change_pte(struct mm_struct *mm,
+			       unsigned long address,
+			       pte_t pte,
+			       enum mmu_action action)
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -131,13 +133,14 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->change_pte)
-			mn->ops->change_pte(mn, mm, address, pte);
+			mn->ops->change_pte(mn, mm, address, pte, action);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
+				    unsigned long address,
+				    enum mmu_action action)
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -145,13 +148,16 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address);
+			mn->ops->invalidate_page(mn, mm, address, action);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					   unsigned long start,
+					   unsigned long end,
+					   enum mmu_action action)
+
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -159,14 +165,16 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start, end);
+			mn->ops->invalidate_range_start(mn, mm, start, end, action);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					 unsigned long start,
+					 unsigned long end,
+					 enum mmu_action action)
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -174,7 +182,7 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start, end);
+			mn->ops->invalidate_range_end(mn, mm, start, end, action);
 	}
 	srcu_read_unlock(&srcu, id);
 }
diff --git a/mm/mprotect.c b/mm/mprotect.c
index c43d557..6c2846f 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -137,7 +137,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		pud_t *pud, unsigned long addr, unsigned long end,
-		pgprot_t newprot, int dirty_accountable, int prot_numa)
+		pgprot_t newprot, int dirty_accountable, int prot_numa,
+		enum mmu_action action)
 {
 	pmd_t *pmd;
 	struct mm_struct *mm = vma->vm_mm;
@@ -157,7 +158,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		/* invoke the mmu notifier if the pmd is populated */
 		if (!mni_start) {
 			mni_start = addr;
-			mmu_notifier_invalidate_range_start(mm, mni_start, end);
+			mmu_notifier_invalidate_range_start(mm, mni_start, end, action);
 		}
 
 		if (pmd_trans_huge(*pmd)) {
@@ -185,7 +186,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	} while (pmd++, addr = next, addr != end);
 
 	if (mni_start)
-		mmu_notifier_invalidate_range_end(mm, mni_start, end);
+		mmu_notifier_invalidate_range_end(mm, mni_start, end, action);
 
 	if (nr_huge_updates)
 		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
@@ -194,7 +195,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 		pgd_t *pgd, unsigned long addr, unsigned long end,
-		pgprot_t newprot, int dirty_accountable, int prot_numa)
+		pgprot_t newprot, int dirty_accountable, int prot_numa,
+		enum mmu_action action)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -206,7 +208,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 		if (pud_none_or_clear_bad(pud))
 			continue;
 		pages += change_pmd_range(vma, pud, addr, next, newprot,
-				 dirty_accountable, prot_numa);
+				 dirty_accountable, prot_numa, action);
 	} while (pud++, addr = next, addr != end);
 
 	return pages;
@@ -214,7 +216,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 
 static unsigned long change_protection_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa)
+		int dirty_accountable, int prot_numa, enum mmu_action action)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
@@ -231,7 +233,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
 		pages += change_pud_range(vma, pgd, addr, next, newprot,
-				 dirty_accountable, prot_numa);
+				 dirty_accountable, prot_numa, action);
 	} while (pgd++, addr = next, addr != end);
 
 	/* Only flush the TLB if we actually modified any entries: */
@@ -247,11 +249,21 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 		       int dirty_accountable, int prot_numa)
 {
 	unsigned long pages;
+	enum mmu_action action = MMU_MPROT_NONE;
+
+	/* At this points vm_flags is updated. */
+	if ((vma->vm_flags & VM_READ) && (vma->vm_flags & VM_WRITE)) {
+		action = MMU_MPROT_RANDW;
+	} else if (vma->vm_flags & VM_WRITE) {
+		action = MMU_MPROT_WONLY;
+	} else if (vma->vm_flags & VM_READ) {
+		action = MMU_MPROT_RONLY;
+	}
 
 	if (is_vm_hugetlb_page(vma))
-		pages = hugetlb_change_protection(vma, start, end, newprot);
+		pages = hugetlb_change_protection(vma, start, end, newprot, action);
 	else
-		pages = change_protection_range(vma, start, end, newprot, dirty_accountable, prot_numa);
+		pages = change_protection_range(vma, start, end, newprot, dirty_accountable, prot_numa, action);
 
 	return pages;
 }
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180..ceb8a47 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -177,7 +177,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 	mmun_start = old_addr;
 	mmun_end   = old_end;
-	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end, MMU_MREMAP);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
@@ -228,7 +228,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	if (likely(need_flush))
 		flush_tlb_range(vma, old_end-len, old_addr);
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end, MMU_MREMAP);
 
 	return len + old_addr - old_end;	/* how much done */
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index ba6580d..3db669e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -836,7 +836,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 
 	if (ret) {
-		mmu_notifier_invalidate_page(mm, address);
+		mmu_notifier_invalidate_page(mm, address, MMU_FILE_WB);
 		(*cleaned)++;
 	}
 out:
@@ -1144,6 +1144,15 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 	enum ttu_flags flags = (enum ttu_flags)arg;
+	enum mmu_action action = MMU_VMSCAN;
+
+	if (flags & TTU_MIGRATION) {
+		action = MMU_MIGRATE;
+	} else if (flags & TTU_MUNLOCK) {
+		action = MMU_MUNLOCK;
+	} else if (unlikely(flags & TTU_POISON)) {
+		action = MMU_POISON;
+	}
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
@@ -1249,7 +1258,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address);
+		mmu_notifier_invalidate_page(mm, address, action);
 out:
 	return ret;
 
@@ -1303,7 +1312,8 @@ out_mlock:
 #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
 
 static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
-		struct vm_area_struct *vma, struct page *check_page)
+				struct vm_area_struct *vma, struct page *check_page,
+				enum ttu_flags flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t *pmd;
@@ -1317,6 +1327,15 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	unsigned long end;
 	int ret = SWAP_AGAIN;
 	int locked_vma = 0;
+	enum mmu_action action = MMU_VMSCAN;
+
+	if (flags & TTU_MIGRATION) {
+		action = MMU_MIGRATE;
+	} else if (flags & TTU_MUNLOCK) {
+		action = MMU_MUNLOCK;
+	} else if (unlikely(flags & TTU_POISON)) {
+		action = MMU_POISON;
+	}
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;
@@ -1331,7 +1350,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 	mmun_start = address;
 	mmun_end   = end;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, action);
 
 	/*
 	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
@@ -1396,7 +1415,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, action);
 	if (locked_vma)
 		up_read(&vma->vm_mm->mmap_sem);
 	return ret;
@@ -1452,7 +1471,7 @@ static int try_to_unmap_nonlinear(struct page *page,
 			while (cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
 				if (try_to_unmap_cluster(cursor, &mapcount,
-						vma, page) == SWAP_MLOCK)
+						vma, page, (enum ttu_flags)arg) == SWAP_MLOCK)
 					ret = SWAP_MLOCK;
 				cursor += CLUSTER_SIZE;
 				vma->vm_private_data = (void *) cursor;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 4b6c01b..eb5a635 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -262,7 +262,8 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
 
 static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
-					     unsigned long address)
+					     unsigned long address,
+					     enum mmu_action action)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int need_tlb_flush, idx;
@@ -301,7 +302,8 @@ static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 					struct mm_struct *mm,
 					unsigned long address,
-					pte_t pte)
+					pte_t pte,
+					enum mmu_action action)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int idx;
@@ -317,7 +319,8 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						    struct mm_struct *mm,
 						    unsigned long start,
-						    unsigned long end)
+						    unsigned long end,
+						    enum mmu_action action)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int need_tlb_flush = 0, idx;
@@ -343,7 +346,8 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
 						  struct mm_struct *mm,
 						  unsigned long start,
-						  unsigned long end)
+						  unsigned long end,
+						  enum mmu_action action)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
