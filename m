Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id E20D9280345
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:53:18 -0400 (EDT)
Received: by igvi1 with SMTP id i1so41477674igv.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:53:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q141si9925613ioe.147.2015.07.17.11.53.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:53:17 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 01/15] mmu_notifier: add event information to address invalidation v8
Date: Fri, 17 Jul 2015 14:52:11 -0400
Message-Id: <1437159145-6548-2-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

The event information will be useful for new user of mmu_notifier API.
The event argument differentiate between a vma disappearing, a page
being write protected or simply a page being unmaped. This allow new
user to take different path for different event for instance on unmap
the resource used to track a vma are still valid and should stay around.
While if the event is saying that a vma is being destroy it means that any
resources used to track this vma can be free.

Changed since v1:
  - renamed action into event (updated commit message too).
  - simplified the event names and clarified their usage
    also documenting what exceptation the listener can have in
    respect to each event.

Changed since v2:
  - Avoid crazy name.
  - Do not move code that do not need to move.

Changed since v3:
  - Separate huge page split from mlock/munlock and softdirty.

Changed since v4:
  - Rebase (no other changes).

Changed since v5:
  - Typo fix.
  - Changed zap_page_range from MMU_MUNMAP to MMU_MIGRATE to reflect the
    fact that the address range is still valid just the page backing it
    are no longer.

Changed since v6:
  - try_to_unmap_one() only invalidate when doing migration.
  - Differentiate fork from other case.

Changed since v7:
  - Renamed MMU_HUGE_PAGE_SPLIT to MMU_HUGE_PAGE_SPLIT.
  - Renamed MMU_ISDIRTY to MMU_CLEAR_SOFT_DIRTY.
  - Renamed MMU_WRITE_PROTECT to MMU_KSM_WRITE_PROTECT.
  - English syntax fixes.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  |   3 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c |   3 +-
 drivers/gpu/drm/radeon/radeon_mn.c      |   3 +-
 drivers/infiniband/core/umem_odp.c      |   9 ++-
 drivers/iommu/amd_iommu_v2.c            |   3 +-
 drivers/misc/sgi-gru/grutlbpurge.c      |   9 ++-
 drivers/xen/gntdev.c                    |   9 ++-
 fs/proc/task_mmu.c                      |   6 +-
 include/linux/mmu_notifier.h            | 132 ++++++++++++++++++++++++++------
 kernel/events/uprobes.c                 |  10 ++-
 mm/huge_memory.c                        |  39 ++++++----
 mm/hugetlb.c                            |  23 +++---
 mm/ksm.c                                |  18 +++--
 mm/memory.c                             |  27 ++++---
 mm/migrate.c                            |   9 ++-
 mm/mmu_notifier.c                       |  28 ++++---
 mm/mprotect.c                           |   6 +-
 mm/mremap.c                             |   6 +-
 mm/rmap.c                               |   4 +-
 virt/kvm/kvm_main.c                     |  12 ++-
 20 files changed, 258 insertions(+), 101 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index b1969f2..7ca805c 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -121,7 +121,8 @@ static void amdgpu_mn_release(struct mmu_notifier *mn,
 static void amdgpu_mn_invalidate_range_start(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
 					     unsigned long start,
-					     unsigned long end)
+					     unsigned long end,
+					     enum mmu_event event)
 {
 	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
 	struct interval_tree_node *it;
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 1f4e5a3..dee1e3d 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -132,7 +132,8 @@ restart:
 static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 						       struct mm_struct *mm,
 						       unsigned long start,
-						       unsigned long end)
+						       unsigned long end,
+						       enum mmu_event event)
 {
 	struct i915_mmu_notifier *mn = container_of(_mn, struct i915_mmu_notifier, mn);
 	struct interval_tree_node *it = NULL;
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index eef006c..3a9615b 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -121,7 +121,8 @@ static void radeon_mn_release(struct mmu_notifier *mn,
 static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
 					     unsigned long start,
-					     unsigned long end)
+					     unsigned long end,
+					     enum mmu_event event)
 {
 	struct radeon_mn *rmn = container_of(mn, struct radeon_mn, mn);
 	struct interval_tree_node *it;
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 40becdb..6ed69fa 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -165,7 +165,8 @@ static int invalidate_page_trampoline(struct ib_umem *item, u64 start,
 
 static void ib_umem_notifier_invalidate_page(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
-					     unsigned long address)
+					     unsigned long address,
+					     enum mmu_event event)
 {
 	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
 
@@ -192,7 +193,8 @@ static int invalidate_range_start_trampoline(struct ib_umem *item, u64 start,
 static void ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						    struct mm_struct *mm,
 						    unsigned long start,
-						    unsigned long end)
+						    unsigned long end,
+						    enum mmu_event event)
 {
 	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
 
@@ -217,7 +219,8 @@ static int invalidate_range_end_trampoline(struct ib_umem *item, u64 start,
 static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
 						  struct mm_struct *mm,
 						  unsigned long start,
-						  unsigned long end)
+						  unsigned long end,
+						  enum mmu_event event)
 {
 	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
 
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 3465faf..4aa4de6 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -384,7 +384,8 @@ static int mn_clear_flush_young(struct mmu_notifier *mn,
 
 static void mn_invalidate_page(struct mmu_notifier *mn,
 			       struct mm_struct *mm,
-			       unsigned long address)
+			       unsigned long address,
+			       enum mmu_event event)
 {
 	__mn_flush_page(mn, address);
 }
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
index 67b9163..1afef26 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -467,7 +467,9 @@ static void unmap_if_in_range(struct grant_map *map,
 
 static void mn_invl_range_start(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-				unsigned long start, unsigned long end)
+				unsigned long start,
+				unsigned long end,
+				enum mmu_event event)
 {
 	struct gntdev_priv *priv = container_of(mn, struct gntdev_priv, mn);
 	struct grant_map *map;
@@ -484,9 +486,10 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
 
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
index ca1e091..4c450fa 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -934,11 +934,13 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				downgrade_write(&mm->mmap_sem);
 				break;
 			}
-			mmu_notifier_invalidate_range_start(mm, 0, -1);
+			mmu_notifier_invalidate_range_start(mm, 0, -1,
+							MMU_CLEAR_SOFT_DIRTY);
 		}
 		walk_page_range(0, ~0UL, &clear_refs_walk);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_end(mm, 0, -1);
+			mmu_notifier_invalidate_range_end(mm, 0, -1,
+							MMU_CLEAR_SOFT_DIRTY);
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
 out_mm:
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 61cd67f..f9b1e10 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -9,6 +9,67 @@
 struct mmu_notifier;
 struct mmu_notifier_ops;
 
+/* MMU Events report fine-grained information to the callback routine, allowing
+ * the event listener to make a more informed decision as to what action to
+ * take. The event types are:
+ *
+ *   - MMU_FORK a process is forking. This will lead to vmas getting
+ *     write-protected, in order to set up COW
+ *
+ *   - MMU_HUGE_PAGE_SPLIT the pages don't move, nor does their content change,
+ *     but the page table structure is updated (levels added or removed).
+ *
+ *   - MMU_CLEAR_SOFT_DIRTY need to write protect so write properly update the
+ *     soft dirty bit of page table entry.
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
+ *   - MMU_MUNLOCK: unlock memory. Content of page table stays the same but
+ *     page are unlocked.
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
+ *   - MMU_KSM_WRITE_PROTECT: memory is being write protected for KSM.
+ *
+ * If in doubt when adding a new notifier caller, please use MMU_MIGRATE,
+ * because it will always lead to reasonable behavior, but will not allow the
+ * listener a chance to optimize its events.
+ */
+enum mmu_event {
+	MMU_FORK = 0,
+	MMU_HUGE_PAGE_SPLIT,
+	MMU_CLEAR_SOFT_DIRTY,
+	MMU_MIGRATE,
+	MMU_MPROT,
+	MMU_MUNLOCK,
+	MMU_MUNMAP,
+	MMU_WRITE_BACK,
+	MMU_KSM_WRITE_PROTECT,
+};
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
@@ -82,7 +143,8 @@ struct mmu_notifier_ops {
 	void (*change_pte)(struct mmu_notifier *mn,
 			   struct mm_struct *mm,
 			   unsigned long address,
-			   pte_t pte);
+			   pte_t pte,
+			   enum mmu_event event);
 
 	/*
 	 * Before this is invoked any secondary MMU is still ok to
@@ -93,7 +155,8 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-				unsigned long address);
+				unsigned long address,
+				enum mmu_event event);
 
 	/*
 	 * invalidate_range_start() and invalidate_range_end() must be
@@ -140,10 +203,14 @@ struct mmu_notifier_ops {
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
 
 	/*
 	 * invalidate_range() is either called between
@@ -206,13 +273,20 @@ extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
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
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 
@@ -240,31 +314,38 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
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
 
 static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
@@ -359,13 +440,13 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
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
 
@@ -393,22 +474,29 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
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
index cb346f2..802828a 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -176,7 +176,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -194,7 +195,9 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush_notify(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+	set_pte_at_notify(mm, addr, ptep,
+			  mk_pte(kpage, vma->vm_page_prot),
+			  MMU_MIGRATE);
 
 	page_remove_rmap(page);
 	if (!page_mapped(page))
@@ -208,7 +211,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	err = 0;
  unlock:
 	mem_cgroup_cancel_charge(kpage, memcg);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 	unlock_page(page);
 	return err;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c107094..80131c0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1024,7 +1024,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_MIGRATE);
 
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
@@ -1058,7 +1059,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	page_remove_rmap(page);
 	spin_unlock(ptl);
 
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
@@ -1068,7 +1070,8 @@ out:
 
 out_free_pages:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
@@ -1160,7 +1163,8 @@ alloc:
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_MIGRATE);
 
 	spin_lock(ptl);
 	if (page)
@@ -1192,7 +1196,8 @@ alloc:
 	}
 	spin_unlock(ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 out:
 	return ret;
 out_unlock:
@@ -1611,7 +1616,8 @@ static int __split_huge_page_splitting(struct page *page,
 	const unsigned long mmun_start = address;
 	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_HUGE_PAGE_SPLIT);
 	pmd = page_check_address_pmd(page, mm, address,
 			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
 	if (pmd) {
@@ -1627,7 +1633,8 @@ static int __split_huge_page_splitting(struct page *page,
 		ret = 1;
 		spin_unlock(ptl);
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_HUGE_PAGE_SPLIT);
 
 	return ret;
 }
@@ -2491,7 +2498,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	mmun_start = address;
 	mmun_end   = address + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
@@ -2501,7 +2509,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	_pmd = pmdp_collapse_flush(vma, address, pmd);
 	spin_unlock(pmd_ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 
 	spin_lock(pte_ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
@@ -2898,24 +2907,28 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
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
index a8c3087..2b513e2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2749,7 +2749,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	mmun_start = vma->vm_start;
 	mmun_end = vma->vm_end;
 	if (cow)
-		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_start(src, mmun_start,
+						    mmun_end, MMU_MIGRATE);
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
@@ -2803,7 +2804,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	}
 
 	if (cow)
-		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(src, mmun_start,
+						  mmun_end, MMU_MIGRATE);
 
 	return ret;
 }
@@ -2829,7 +2831,8 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	BUG_ON(end & ~huge_page_mask(h));
 
 	tlb_start_vma(tlb, vma);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 	address = start;
 again:
 	for (; address < end; address += sz) {
@@ -2903,7 +2906,8 @@ unlock:
 		if (address < end && !ref_page)
 			goto again;
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 	tlb_end_vma(tlb, vma);
 }
 
@@ -3082,8 +3086,8 @@ retry_avoidcopy:
 
 	mmun_start = address & huge_page_mask(h);
 	mmun_end = mmun_start + huge_page_size(h);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_MIGRATE);
 	/*
 	 * Retake the page table lock to check for racing updates
 	 * before the page tables are altered
@@ -3104,7 +3108,8 @@ retry_avoidcopy:
 		new_page = old_page;
 	}
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
+					  MMU_MIGRATE);
 out_release_all:
 	page_cache_release(new_page);
 out_release_old:
@@ -3572,7 +3577,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MPROT);
 	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
@@ -3622,7 +3627,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_tlb_range(vma, start, end);
 	mmu_notifier_invalidate_range(mm, start, end);
 	i_mmap_unlock_write(vma->vm_file->f_mapping);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MPROT);
 
 	return pages << h->order;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 7ee101e..eb1b2b5 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -872,7 +872,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_KSM_WRITE_PROTECT);
 
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -904,7 +905,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		if (pte_dirty(entry))
 			set_page_dirty(page);
 		entry = pte_mkclean(pte_wrprotect(entry));
-		set_pte_at_notify(mm, addr, ptep, entry);
+		set_pte_at_notify(mm, addr, ptep, entry, MMU_KSM_WRITE_PROTECT);
 	}
 	*orig_pte = *ptep;
 	err = 0;
@@ -912,7 +913,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
+					  MMU_KSM_WRITE_PROTECT);
 out:
 	return err;
 }
@@ -948,7 +950,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
+					    MMU_MIGRATE);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (!pte_same(*ptep, orig_pte)) {
@@ -961,7 +964,9 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush_notify(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+	set_pte_at_notify(mm, addr, ptep,
+			  mk_pte(kpage, vma->vm_page_prot),
+			  MMU_MIGRATE);
 
 	page_remove_rmap(page);
 	if (!page_mapped(page))
@@ -971,7 +976,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
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
index 388dcf9..1be64ce 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1048,7 +1048,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	mmun_end   = end;
 	if (is_cow)
 		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
-						    mmun_end);
+						    mmun_end, MMU_FORK);
 
 	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
@@ -1065,7 +1065,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow)
-		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(src_mm, mmun_start,
+						  mmun_end, MMU_FORK);
 	return ret;
 }
 
@@ -1335,10 +1336,12 @@ void unmap_vmas(struct mmu_gather *tlb,
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
@@ -1360,10 +1363,10 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, start, end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MIGRATE);
 	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
 		unmap_single_vma(&tlb, vma, start, end, details);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MIGRATE);
 	tlb_finish_mmu(&tlb, start, end);
 }
 
@@ -1386,9 +1389,9 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
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
 
@@ -2087,7 +2090,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start,
+					    mmun_end, MMU_MIGRATE);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2120,7 +2124,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * mmu page tables (such as kvm shadow page tables), we want the
 		 * new page to be mapped directly into the secondary page table.
 		 */
-		set_pte_at_notify(mm, address, page_table, entry);
+		set_pte_at_notify(mm, address, page_table, entry, MMU_MIGRATE);
 		update_mmu_cache(vma, address, page_table);
 		if (old_page) {
 			/*
@@ -2159,7 +2163,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_cache_release(new_page);
 
 	pte_unmap_unlock(page_table, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/migrate.c b/mm/migrate.c
index ee401e4..31995b5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1759,12 +1759,14 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
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
@@ -1818,7 +1820,8 @@ fail_putback:
 	page_remove_rmap(page);
 
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start,
+					  mmun_end, MMU_MIGRATE);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
 	get_page(new_page);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 3b9b3d0..e51ea02 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -142,8 +142,10 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
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
@@ -151,13 +153,14 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
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
@@ -165,13 +168,16 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
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
@@ -179,14 +185,17 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
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
@@ -204,7 +213,8 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 		if (mn->ops->invalidate_range)
 			mn->ops->invalidate_range(mn, mm, start, end);
 		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start, end);
+			mn->ops->invalidate_range_end(mn, mm, start,
+						      end, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
diff --git a/mm/mprotect.c b/mm/mprotect.c
index e7d6f11..a57e8af 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -155,7 +155,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		/* invoke the mmu notifier if the pmd is populated */
 		if (!mni_start) {
 			mni_start = addr;
-			mmu_notifier_invalidate_range_start(mm, mni_start, end);
+			mmu_notifier_invalidate_range_start(mm, mni_start,
+							    end, MMU_MPROT);
 		}
 
 		if (pmd_trans_huge(*pmd)) {
@@ -183,7 +184,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	} while (pmd++, addr = next, addr != end);
 
 	if (mni_start)
-		mmu_notifier_invalidate_range_end(mm, mni_start, end);
+		mmu_notifier_invalidate_range_end(mm, mni_start, end,
+						  MMU_MPROT);
 
 	if (nr_huge_updates)
 		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
diff --git a/mm/mremap.c b/mm/mremap.c
index a7c93ec..72051cf 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -176,7 +176,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
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
index 171b687..b1e6eae 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -891,7 +891,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 
 	if (ret) {
-		mmu_notifier_invalidate_page(mm, address);
+		mmu_notifier_invalidate_page(mm, address, MMU_WRITE_BACK);
 		(*cleaned)++;
 	}
 out:
@@ -1298,7 +1298,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address);
+		mmu_notifier_invalidate_page(mm, address, MMU_MIGRATE);
 out:
 	return ret;
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 8b8a444..4dfa91c 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -259,7 +259,8 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
 
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
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
