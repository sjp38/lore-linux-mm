Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id E246A6B0039
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 19:52:30 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so5501679qaq.10
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 16:52:30 -0700 (PDT)
Received: from mail-qa0-x236.google.com (mail-qa0-x236.google.com [2607:f8b0:400d:c00::236])
        by mx.google.com with ESMTPS id d16si21339844qac.131.2014.07.08.16.52.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 16:52:29 -0700 (PDT)
Received: by mail-qa0-f54.google.com with SMTP id s7so1503017qap.13
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 16:52:29 -0700 (PDT)
Date: Tue, 8 Jul 2014 19:52:24 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 3/8] mmu_notifier: add event information to address
 invalidation v3
Message-ID: <20140708235223.GD5222@gmail.com>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <1404856801-11702-4-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1404856801-11702-4-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Tue, Jul 08, 2014 at 06:00:00PM -0400, j.glisse@gmail.com wrote:
From: Jerome Glisse <jglisse@redhat.com>

The event information will be usefull for new user of mmu_notifier API.
The event argument differentiate between a vma disappearing, a page
being write protected or simply a page being unmaped. This allow new
user to take different path for different event for instance on unmap
the resource used to track a vma are still valid and should stay around.
While if the event is saying that a vma is being destroy it means that any
resources used to track this vma can be free.

Changed since v1:
  - renamed action into event (updated commit message too).
  - simplified the event names and clarified their intented usage
    also documenting what exceptation the listener can have in
    respect to each event.

Changed since v2:
  - Avoid crazy name.
  - Do not move code that do not need to move.

Signed-off-by: Jerome Glisse <jglisse@redhat.com>
---
 drivers/gpu/drm/i915/i915_gem_userptr.c |   3 +-
 drivers/iommu/amd_iommu_v2.c            |  14 ++--
 drivers/misc/sgi-gru/grutlbpurge.c      |   9 ++-
 drivers/xen/gntdev.c                    |   9 ++-
 fs/proc/task_mmu.c                      |   6 +-
 include/linux/mmu_notifier.h            | 123 ++++++++++++++++++++++++++------
 kernel/events/uprobes.c                 |  10 ++-
 mm/filemap_xip.c                        |   2 +-
 mm/huge_memory.c                        |  39 ++++++----
 mm/hugetlb.c                            |  23 +++---
 mm/ksm.c                                |  18 +++--
 mm/memory.c                             |  27 ++++---
 mm/migrate.c                            |   9 ++-
 mm/mmu_notifier.c                       |  28 +++++---
 mm/mprotect.c                           |   5 +-
 mm/mremap.c                             |   6 +-
 mm/rmap.c                               |  24 +++++--
 virt/kvm/kvm_main.c                     |  12 ++--
 18 files changed, 263 insertions(+), 104 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 21ea928..ed6f35e 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -56,7 +56,8 @@ struct i915_mmu_object {
 static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 						       struct mm_struct *mm,
 						       unsigned long start,
-						       unsigned long end)
+						       unsigned long end,
+						       enum mmu_event event)
 {
 	struct i915_mmu_notifier *mn = container_of(_mn, struct i915_mmu_notifier, mn);
 	struct interval_tree_node *it = NULL;
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 499b436..2bb9771 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -414,21 +414,25 @@ static int mn_clear_flush_young(struct mmu_notifier *mn,
 static void mn_change_pte(struct mmu_notifier *mn,
 			  struct mm_struct *mm,
 			  unsigned long address,
-			  pte_t pte)
+			  pte_t pte,
+			  enum mmu_event event)
 {
 	__mn_flush_page(mn, address);
 }
 
 static void mn_invalidate_page(struct mmu_notifier *mn,
 			       struct mm_struct *mm,
-			       unsigned long address)
+			       unsigned long address,
+			       enum mmu_event event)
 {
 	__mn_flush_page(mn, address);
 }
 
 static void mn_invalidate_range_start(struct mmu_notifier *mn,
 				      struct mm_struct *mm,
-				      unsigned long start, unsigned long end)
+				      unsigned long start,
+				      unsigned long end,
+				      enum mmu_event event)
 {
 	struct pasid_state *pasid_state;
 	struct device_state *dev_state;
@@ -449,7 +453,9 @@ static void mn_invalidate_range_start(struct mmu_notifier *mn,
 
 static void mn_invalidate_range_end(struct mmu_notifier *mn,
 				    struct mm_struct *mm,
-				    unsigned long start, unsigned long end)
+				    unsigned long start,
+				    unsigned long end,
+				    enum mmu_event event)
 {
 	struct pasid_state *pasid_state;
 	struct device_state *dev_state;
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index 2129274..e67fed1 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -221,7 +221,8 @@ void gru_flush_all_tlb(struct gru_state *gru)
  */
 static void gru_invalidate_range_start(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end)
+				       unsigned long start, unsigned long end,
+				       enum mmu_event event)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -235,7 +236,8 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
 
 static void gru_invalidate_range_end(struct mmu_notifier *mn,
 				     struct mm_struct *mm, unsigned long start,
-				     unsigned long end)
+				     unsigned long end,
+				     enum mmu_event event)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -248,7 +250,8 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 }
 
 static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
-				unsigned long address)
+				unsigned long address,
+				enum mmu_event event)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 073b4a1..fe9da94 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -428,7 +428,9 @@ static void unmap_if_in_range(struct grant_map *map,
 
 static void mn_invl_range_start(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-				unsigned long start, unsigned long end)
+				unsigned long start,
+				unsigned long end,
+				enum mmu_event event)
 {
 	struct gntdev_priv *priv = container_of(mn, struct gntdev_priv, mn);
 	struct grant_map *map;
@@ -445,9 +447,10 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
 
 static void mn_invl_page(struct mmu_notifier *mn,
 			 struct mm_struct *mm,
-			 unsigned long address)
+			 unsigned long address,
+			 enum mmu_event event)
 {
-	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE);
+	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE, event);
 }
 
 static void mn_release(struct mmu_notifier *mn,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index cfa63ee..e9e79f7 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -830,7 +830,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		};
 		down_read(&mm->mmap_sem);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_start(mm, 0, -1);
+			mmu_notifier_invalidate_range_start(mm, 0,
+							    -1, MMU_STATUS);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			cp.vma = vma;
 			if (is_vm_hugetlb_page(vma))
@@ -858,7 +859,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					&clear_refs_walk);
 		}
 		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_end(mm, 0, -1);
+			mmu_notifier_invalidate_range_end(mm, 0,
+							  -1, MMU_STATUS);
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index deca874..34717b8 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -9,6 +9,58 @@
 struct mmu_notifier;
 struct mmu_notifier_ops;
 
+/* MMU Events report fine-grained information to the callback routine, allowing
+ * the event listener to make a more informed decision as to what action to
+ * take. The event types are:
+ *
+ *   - MMU_MIGRATE: memory is migrating from one page to another, thus all write
+ *     access must stop after invalidate_range_start callback returns.
+ *     Furthermore, no read access should be allowed either, as a new page can
+ *     be remapped with write access before the invalidate_range_end callback
+ *     happens and thus any read access to old page might read stale data. There
+ *     are several sources for this event, including:
+ *
+ *         - A page moving to swap (various reasons, including page reclaim),
+ *         - An mremap syscall,
+ *         - migration for NUMA reasons,
+ *         - balancing the memory pool,
+ *         - write fault on COW page,
+ *         - and more that are not listed here.
+ *
+ *   - MMU_MPROT: memory access protection is changing. Refer to the vma to get
+ *     the new access protection. All memory access are still valid until the
+ *     invalidate_range_end callback.
+ *
+ *   - MMU_MUNMAP: the range is being unmapped (outcome of a munmap syscall or
+ *     process destruction). However, access is still allowed, up until the
+ *     invalidate_range_free_pages callback. This also implies that secondary
+ *     page table can be trimmed, because the address range is no longer valid.
+ *
+ *   - MMU_WRITE_BACK: memory is being written back to disk, all write accesses
+ *     must stop after invalidate_range_start callback returns. Read access are
+ *     still allowed.
+ *
+ *   - MMU_WRITE_PROTECT: memory is being writte protected (ie should be mapped
+ *     read only no matter what the vma memory protection allows). All write
+ *     accesses must stop after invalidate_range_start callback returns. Read
+ *     access are still allowed.
+ *
+ *   - MMU_STATUS memory status change, like soft dirty, or huge page
+ *     splitting flag being set on pmd.
+ *
+ * If in doubt when adding a new notifier caller, please use MMU_MIGRATE,
+ * because it will always lead to reasonable behavior, but will not allow the
+ * listener a chance to optimize its events.
+ */
+enum mmu_event {
+	MMU_MIGRATE = 0,
+	MMU_MPROT,
+	MMU_MUNMAP,
+	MMU_STATUS,
+	MMU_WRITE_BACK,
+	MMU_WRITE_PROTECT,
+};
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
@@ -79,7 +131,8 @@ struct mmu_notifier_ops {
 	void (*change_pte)(struct mmu_notifier *mn,
 			   struct mm_struct *mm,
 			   unsigned long address,
-			   pte_t pte);
+			   pte_t pte,
+			   enum mmu_event event);
 
 	/*
 	 * Before this is invoked any secondary MMU is still ok to
@@ -90,7 +143,8 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-				unsigned long address);
+				unsigned long address,
+				enum mmu_event event);
 
 	/*
 	 * invalidate_range_start() and invalidate_range_end() must be
@@ -137,10 +191,14 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end);
+				       unsigned long start,
+				       unsigned long end,
+				       enum mmu_event event);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
-				     unsigned long start, unsigned long end);
+				     unsigned long start,
+				     unsigned long end,
+				     enum mmu_event event);
 };
 
 /*
@@ -177,13 +235,20 @@ extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 extern int __mmu_notifier_test_young(struct mm_struct *mm,
 				     unsigned long address);
 extern void __mmu_notifier_change_pte(struct mm_struct *mm,
-				      unsigned long address, pte_t pte);
+				      unsigned long address,
+				      pte_t pte,
+				      enum mmu_event event);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address);
+					  unsigned long address,
+					  enum mmu_event event);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
+						  unsigned long start,
+						  unsigned long end,
+						  enum mmu_event event);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
+						unsigned long start,
+						unsigned long end,
+						enum mmu_event event);
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
@@ -208,31 +273,38 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_change_pte(struct mm_struct *mm,
-					   unsigned long address, pte_t pte)
+					   unsigned long address,
+					   pte_t pte,
+					   enum mmu_event event)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_change_pte(mm, address, pte);
+		__mmu_notifier_change_pte(mm, address, pte, event);
 }
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
+						unsigned long address,
+						enum mmu_event event)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_page(mm, address);
+		__mmu_notifier_invalidate_page(mm, address, event);
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+						       unsigned long start,
+						       unsigned long end,
+						       enum mmu_event event)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end);
+		__mmu_notifier_invalidate_range_start(mm, start, end, event);
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+						     unsigned long start,
+						     unsigned long end,
+						     enum mmu_event event)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end);
+		__mmu_notifier_invalidate_range_end(mm, start, end, event);
 }
 
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
@@ -278,13 +350,13 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
  * old page would remain mapped readonly in the secondary MMUs after the new
  * page is already writable by some CPU through the primary MMU.
  */
-#define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
+#define set_pte_at_notify(__mm, __address, __ptep, __pte, __event)	\
 ({									\
 	struct mm_struct *___mm = __mm;					\
 	unsigned long ___address = __address;				\
 	pte_t ___pte = __pte;						\
 									\
-	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
+	mmu_notifier_change_pte(___mm, ___address, ___pte, __event);	\
 	set_pte_at(___mm, ___address, __ptep, ___pte);			\
 })
 
@@ -307,22 +379,29 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_change_pte(struct mm_struct *mm,
-					   unsigned long address, pte_t pte)
+					   unsigned long address,
+					   pte_t pte,
+					   enum mmu_event event)
 {
 }
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
+						unsigned long address,
+						enum mmu_event event)
 {
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+						       unsigned long start,
+						       unsigned long end,
+						       enum mmu_event event)
 {
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+						     unsigned long start,
+						     unsigned long end,
+						     enum mmu_event event)
 {
 }
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 29aad1f..ddbe598 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -177,7 +177,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -195,7 +196,9 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+	set_pte_at_notify(mm, addr, ptep,
+			  mk_pte(kpage, vma->vm_page_prot),
+			  MMU_MIGRATE);
 
 	page_remove_rmap(page);
 	if (!page_mapped(page))
@@ -209,7 +212,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	err = 0;
  unlock:
 	mem_cgroup_cancel_charge(kpage, memcg);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 	unlock_page(page);
 	return err;
 }
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index d8d9fe3..a2b3f09 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -198,7 +198,7 @@ retry:
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			/* must invalidate_page _before_ freeing the page */
-			mmu_notifier_invalidate_page(mm, address);
+			mmu_notifier_invalidate_page(mm, address, MMU_MIGRATE);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5d562a9..3fb1f9e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1029,7 +1029,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_MIGRATE);
 
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
@@ -1063,7 +1064,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	page_remove_rmap(page);
 	spin_unlock(ptl);
 
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
@@ -1073,7 +1075,8 @@ out:
 
 out_free_pages:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
@@ -1165,7 +1168,8 @@ alloc:
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_MIGRATE);
 
 	spin_lock(ptl);
 	if (page)
@@ -1197,7 +1201,8 @@ alloc:
 	}
 	spin_unlock(ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 out:
 	return ret;
 out_unlock:
@@ -1632,7 +1637,8 @@ static int __split_huge_page_splitting(struct page *page,
 	const unsigned long mmun_start = address;
 	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_STATUS);
 	pmd = page_check_address_pmd(page, mm, address,
 			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
 	if (pmd) {
@@ -1647,7 +1653,8 @@ static int __split_huge_page_splitting(struct page *page,
 		ret = 1;
 		spin_unlock(ptl);
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_STATUS);
 
 	return ret;
 }
@@ -2446,7 +2453,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	mmun_start = address;
 	mmun_end   = address + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
@@ -2456,7 +2464,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	_pmd = pmdp_clear_flush(vma, address, pmd);
 	spin_unlock(pmd_ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 
 	spin_lock(pte_ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
@@ -2845,24 +2854,28 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 again:
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(mm, mmun_start,
+						  mmun_end, MMU_MIGRATE);
 		return;
 	}
 	if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(mm, mmun_start,
+						  mmun_end, MMU_MIGRATE);
 		return;
 	}
 	page = pmd_page(*pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	get_page(page);
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 
 	split_huge_page(page);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4e49741..fa28018 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2555,7 +2555,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	mmun_start = vma->vm_start;
 	mmun_end = vma->vm_end;
 	if (cow)
-		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_start(src, mmun_start,
+						    mmun_end, MMU_MIGRATE);
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
@@ -2605,7 +2606,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	}
 
 	if (cow)
-		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(src, mmun_start,
+						  mmun_end, MMU_MIGRATE);
 
 	return ret;
 }
@@ -2631,7 +2633,8 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	BUG_ON(end & ~huge_page_mask(h));
 
 	tlb_start_vma(tlb, vma);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 again:
 	for (address = start; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
@@ -2702,7 +2705,8 @@ unlock:
 		if (address < end && !ref_page)
 			goto again;
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 	tlb_end_vma(tlb, vma);
 }
 
@@ -2880,8 +2884,8 @@ retry_avoidcopy:
 
 	mmun_start = address & huge_page_mask(h);
 	mmun_end = mmun_start + huge_page_size(h);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_MIGRATE);
 	/*
 	 * Retake the page table lock to check for racing updates
 	 * before the page tables are altered
@@ -2901,7 +2905,8 @@ retry_avoidcopy:
 		new_page = old_page;
 	}
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
+					  MMU_MIGRATE);
 out_release_all:
 	page_cache_release(new_page);
 out_release_old:
@@ -3339,7 +3344,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MPROT);
 	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
@@ -3369,7 +3374,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 */
 	flush_tlb_range(vma, start, end);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MPROT);
 
 	return pages << h->order;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index cb1e976..f50e103 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -873,7 +873,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_WRITE_PROTECT);
 
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -905,7 +906,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		if (pte_dirty(entry))
 			set_page_dirty(page);
 		entry = pte_mkclean(pte_wrprotect(entry));
-		set_pte_at_notify(mm, addr, ptep, entry);
+		set_pte_at_notify(mm, addr, ptep, entry, MMU_WRITE_PROTECT);
 	}
 	*orig_pte = *ptep;
 	err = 0;
@@ -913,7 +914,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
+					  MMU_WRITE_PROTECT);
 out:
 	return err;
 }
@@ -949,7 +951,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_MIGRATE);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (!pte_same(*ptep, orig_pte)) {
@@ -962,7 +965,9 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+	set_pte_at_notify(mm, addr, ptep,
+			  mk_pte(kpage, vma->vm_page_prot),
+			  MMU_MIGRATE);
 
 	page_remove_rmap(page);
 	if (!page_mapped(page))
@@ -972,7 +977,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
+					  MMU_MIGRATE);
 out:
 	return err;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 13141ae..74fe242 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1050,7 +1050,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	mmun_end   = end;
 	if (is_cow)
 		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
-						    mmun_end);
+						    mmun_end, MMU_MIGRATE);
 
 	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
@@ -1067,7 +1067,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow)
-		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end,
+						  MMU_MIGRATE);
 	return ret;
 }
 
@@ -1371,10 +1372,12 @@ void unmap_vmas(struct mmu_gather *tlb,
 {
 	struct mm_struct *mm = vma->vm_mm;
 
-	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
+	mmu_notifier_invalidate_range_start(mm, start_addr,
+					    end_addr, MMU_MUNMAP);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
-	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
+	mmu_notifier_invalidate_range_end(mm, start_addr,
+					  end_addr, MMU_MUNMAP);
 }
 
 /**
@@ -1396,10 +1399,10 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
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
 
@@ -1422,9 +1425,9 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
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
 
@@ -2208,7 +2211,8 @@ gotten:
 
 	mmun_start  = address & PAGE_MASK;
 	mmun_end    = mmun_start + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2240,7 +2244,7 @@ gotten:
 		 * mmu page tables (such as kvm shadow page tables), we want the
 		 * new page to be mapped directly into the secondary page table.
 		 */
-		set_pte_at_notify(mm, address, page_table, entry);
+		set_pte_at_notify(mm, address, page_table, entry, MMU_MIGRATE);
 		update_mmu_cache(vma, address, page_table);
 		if (old_page) {
 			/*
@@ -2279,7 +2283,8 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (mmun_end > mmun_start)
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(mm, mmun_start,
+						  mmun_end, MMU_MIGRATE);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/migrate.c b/mm/migrate.c
index ab43fbf..b526c72 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1820,12 +1820,14 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
 fail_putback:
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(mm, mmun_start,
+						  mmun_end, MMU_MIGRATE);
 
 		/* Reverse changes made by migrate_page_copy() */
 		if (TestClearPageActive(new_page))
@@ -1878,7 +1880,8 @@ fail_putback:
 	page_remove_rmap(page);
 
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
 	get_page(new_page);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 41cefdf..9decb88 100644
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
+			       enum mmu_event event)
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -131,13 +133,14 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->change_pte)
-			mn->ops->change_pte(mn, mm, address, pte);
+			mn->ops->change_pte(mn, mm, address, pte, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
+				    unsigned long address,
+				    enum mmu_event event)
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -145,13 +148,16 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address);
+			mn->ops->invalidate_page(mn, mm, address, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					   unsigned long start,
+					   unsigned long end,
+					   enum mmu_event event)
+
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -159,14 +165,17 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start, end);
+			mn->ops->invalidate_range_start(mn, mm, start,
+							end, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					 unsigned long start,
+					 unsigned long end,
+					 enum mmu_event event)
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -174,7 +183,8 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start, end);
+			mn->ops->invalidate_range_end(mn, mm, start,
+						      end, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
diff --git a/mm/mprotect.c b/mm/mprotect.c
index c43d557..886405b 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -157,7 +157,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		/* invoke the mmu notifier if the pmd is populated */
 		if (!mni_start) {
 			mni_start = addr;
-			mmu_notifier_invalidate_range_start(mm, mni_start, end);
+			mmu_notifier_invalidate_range_start(mm, mni_start,
+							    end, MMU_MPROT);
 		}
 
 		if (pmd_trans_huge(*pmd)) {
@@ -185,7 +186,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	} while (pmd++, addr = next, addr != end);
 
 	if (mni_start)
-		mmu_notifier_invalidate_range_end(mm, mni_start, end);
+		mmu_notifier_invalidate_range_end(mm, mni_start, end, MMU_MPROT);
 
 	if (nr_huge_updates)
 		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180..6827d2f 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -177,7 +177,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 	mmun_start = old_addr;
 	mmun_end   = old_end;
-	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
@@ -228,7 +229,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	if (likely(need_flush))
 		flush_tlb_range(vma, old_end-len, old_addr);
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 
 	return len + old_addr - old_end;	/* how much done */
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 7928ddd..474a913 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -840,7 +840,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 
 	if (ret) {
-		mmu_notifier_invalidate_page(mm, address);
+		mmu_notifier_invalidate_page(mm, address, MMU_WRITE_BACK);
 		(*cleaned)++;
 	}
 out:
@@ -1128,6 +1128,10 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 	enum ttu_flags flags = (enum ttu_flags)arg;
+	enum mmu_event event = MMU_MIGRATE;
+
+	if (flags & TTU_MUNLOCK)
+		event = MMU_STATUS;
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
@@ -1233,7 +1237,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address);
+		mmu_notifier_invalidate_page(mm, address, event);
 out:
 	return ret;
 
@@ -1287,7 +1291,9 @@ out_mlock:
 #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
 
 static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
-		struct vm_area_struct *vma, struct page *check_page)
+				struct vm_area_struct *vma,
+				struct page *check_page,
+				enum ttu_flags flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t *pmd;
@@ -1301,6 +1307,10 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	unsigned long end;
 	int ret = SWAP_AGAIN;
 	int locked_vma = 0;
+	enum mmu_event event = MMU_MIGRATE;
+
+	if (flags & TTU_MUNLOCK)
+		event = MMU_STATUS;
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;
@@ -1315,7 +1325,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 	mmun_start = address;
 	mmun_end   = end;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, event);
 
 	/*
 	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
@@ -1380,7 +1390,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, event);
 	if (locked_vma)
 		up_read(&vma->vm_mm->mmap_sem);
 	return ret;
@@ -1436,7 +1446,9 @@ static int try_to_unmap_nonlinear(struct page *page,
 			while (cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
 				if (try_to_unmap_cluster(cursor, &mapcount,
-						vma, page) == SWAP_MLOCK)
+							 vma, page,
+							 (enum ttu_flags)arg)
+							 == SWAP_MLOCK)
 					ret = SWAP_MLOCK;
 				cursor += CLUSTER_SIZE;
 				vma->vm_private_data = (void *) cursor;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 4b6c01b..6e1992f 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -262,7 +262,8 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
 
 static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
-					     unsigned long address)
+					     unsigned long address,
+					     enum mmu_event event)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int need_tlb_flush, idx;
@@ -301,7 +302,8 @@ static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 					struct mm_struct *mm,
 					unsigned long address,
-					pte_t pte)
+					pte_t pte,
+					enum mmu_event event)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int idx;
@@ -317,7 +319,8 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						    struct mm_struct *mm,
 						    unsigned long start,
-						    unsigned long end)
+						    unsigned long end,
+						    enum mmu_event event)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int need_tlb_flush = 0, idx;
@@ -343,7 +346,8 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
 						  struct mm_struct *mm,
 						  unsigned long start,
-						  unsigned long end)
+						  unsigned long end,
+						  enum mmu_event event)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
