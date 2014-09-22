Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 87A616B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 16:00:20 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so5121560pab.5
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:00:20 -0700 (PDT)
Received: from mail-pa0-x249.google.com (mail-pa0-x249.google.com [2607:f8b0:400e:c03::249])
        by mx.google.com with ESMTPS id nz8si11091195pab.116.2014.09.22.13.00.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 13:00:19 -0700 (PDT)
Received: by mail-pa0-f73.google.com with SMTP id ey11so1086386pad.4
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:00:19 -0700 (PDT)
From: Andres Lagar-Cavilla <andreslc@google.com>
Subject: [PATCH v2] kvm: Fix page ageing bugs
Date: Mon, 22 Sep 2014 13:00:15 -0700
Message-Id: <1411416015-30685-1-git-send-email-andreslc@google.com>
In-Reply-To: <1411410865-3603-1-git-send-email-andreslc@google.com>
References: <1411410865-3603-1-git-send-email-andreslc@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Andres Lagar-Cavilla <andreslc@gooogle.com>

1. We were calling clear_flush_young_notify in unmap_one, but we are
within an mmu notifier invalidate range scope. The spte exists no more
(due to range_start) and the accessed bit info has already been
propagated (due to kvm_pfn_set_accessed). Simply call
clear_flush_young.

2. We clear_flush_young on a primary MMU PMD, but this may be mapped
as a collection of PTEs by the secondary MMU (e.g. during log-dirty).
This required expanding the interface of the clear_flush_young mmu
notifier, so a lot of code has been trivially touched.

3. In the absence of shadow_accessed_mask (e.g. EPT A bit), we emulate
the access bit by blowing the spte. This requires proper synchronizing
with MMU notifier consumers, like every other removal of spte's does.

---
v1 -> v2: * Small cosmetic changes
          * Remove unnecessary handling of mmu_notifier_seq in
            mmu_lock protected region
          * Func prototypes fixed
---
Signed-off-by: Andres Lagar-Cavilla <andreslc@gooogle.com>
---
 arch/arm/include/asm/kvm_host.h     |  3 ++-
 arch/arm64/include/asm/kvm_host.h   |  3 ++-
 arch/powerpc/include/asm/kvm_host.h |  2 +-
 arch/powerpc/kvm/book3s.c           |  4 ++--
 arch/powerpc/kvm/book3s.h           |  3 ++-
 arch/powerpc/kvm/book3s_64_mmu_hv.c |  4 ++--
 arch/powerpc/kvm/book3s_pr.c        |  3 ++-
 arch/powerpc/kvm/e500_mmu_host.c    |  2 +-
 arch/x86/include/asm/kvm_host.h     |  2 +-
 arch/x86/kvm/mmu.c                  | 46 +++++++++++++++++++++++--------------
 drivers/iommu/amd_iommu_v2.c        |  6 +++--
 include/linux/mmu_notifier.h        | 24 +++++++++++++------
 include/trace/events/kvm.h          | 10 ++++----
 mm/mmu_notifier.c                   |  5 ++--
 mm/rmap.c                           |  6 ++++-
 virt/kvm/kvm_main.c                 |  5 ++--
 16 files changed, 81 insertions(+), 47 deletions(-)

diff --git a/arch/arm/include/asm/kvm_host.h b/arch/arm/include/asm/kvm_host.h
index 032a853..8c3f7eb 100644
--- a/arch/arm/include/asm/kvm_host.h
+++ b/arch/arm/include/asm/kvm_host.h
@@ -170,7 +170,8 @@ unsigned long kvm_arm_num_regs(struct kvm_vcpu *vcpu);
 int kvm_arm_copy_reg_indices(struct kvm_vcpu *vcpu, u64 __user *indices);
 
 /* We do not have shadow page tables, hence the empty hooks */
-static inline int kvm_age_hva(struct kvm *kvm, unsigned long hva)
+static inline int kvm_age_hva(struct kvm *kvm, unsigned long start,
+			      unsigned long end)
 {
 	return 0;
 }
diff --git a/arch/arm64/include/asm/kvm_host.h b/arch/arm64/include/asm/kvm_host.h
index be9970a..a3c671b 100644
--- a/arch/arm64/include/asm/kvm_host.h
+++ b/arch/arm64/include/asm/kvm_host.h
@@ -180,7 +180,8 @@ int kvm_unmap_hva_range(struct kvm *kvm,
 void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 
 /* We do not have shadow page tables, hence the empty hooks */
-static inline int kvm_age_hva(struct kvm *kvm, unsigned long hva)
+static inline int kvm_age_hva(struct kvm *kvm, unsigned long start,
+			      unsigned long end)
 {
 	return 0;
 }
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index 6040008..d329bc5 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -56,7 +56,7 @@
 extern int kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
 extern int kvm_unmap_hva_range(struct kvm *kvm,
 			       unsigned long start, unsigned long end);
-extern int kvm_age_hva(struct kvm *kvm, unsigned long hva);
+extern int kvm_age_hva(struct kvm *kvm, unsigned long start, unsigned long end);
 extern int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
 extern void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 
diff --git a/arch/powerpc/kvm/book3s.c b/arch/powerpc/kvm/book3s.c
index dd03f6b..c16cfbf 100644
--- a/arch/powerpc/kvm/book3s.c
+++ b/arch/powerpc/kvm/book3s.c
@@ -851,9 +851,9 @@ int kvm_unmap_hva_range(struct kvm *kvm, unsigned long start, unsigned long end)
 	return kvm->arch.kvm_ops->unmap_hva_range(kvm, start, end);
 }
 
-int kvm_age_hva(struct kvm *kvm, unsigned long hva)
+int kvm_age_hva(struct kvm *kvm, unsigned long start, unsigned long end)
 {
-	return kvm->arch.kvm_ops->age_hva(kvm, hva);
+	return kvm->arch.kvm_ops->age_hva(kvm, start, end);
 }
 
 int kvm_test_age_hva(struct kvm *kvm, unsigned long hva)
diff --git a/arch/powerpc/kvm/book3s.h b/arch/powerpc/kvm/book3s.h
index 4bf956c..d2b3ec0 100644
--- a/arch/powerpc/kvm/book3s.h
+++ b/arch/powerpc/kvm/book3s.h
@@ -17,7 +17,8 @@ extern void kvmppc_core_flush_memslot_hv(struct kvm *kvm,
 extern int kvm_unmap_hva_hv(struct kvm *kvm, unsigned long hva);
 extern int kvm_unmap_hva_range_hv(struct kvm *kvm, unsigned long start,
 				  unsigned long end);
-extern int kvm_age_hva_hv(struct kvm *kvm, unsigned long hva);
+extern int kvm_age_hva_hv(struct kvm *kvm, unsigned long start,
+			  unsigned long end);
 extern int kvm_test_age_hva_hv(struct kvm *kvm, unsigned long hva);
 extern void kvm_set_spte_hva_hv(struct kvm *kvm, unsigned long hva, pte_t pte);
 
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 72c20bb..81460c5 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -1002,11 +1002,11 @@ static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp,
 	return ret;
 }
 
-int kvm_age_hva_hv(struct kvm *kvm, unsigned long hva)
+int kvm_age_hva_hv(struct kvm *kvm, unsigned long start, unsigned long end)
 {
 	if (!kvm->arch.using_mmu_notifiers)
 		return 0;
-	return kvm_handle_hva(kvm, hva, kvm_age_rmapp);
+	return kvm_handle_hva_range(kvm, start, end, kvm_age_rmapp);
 }
 
 static int kvm_test_age_rmapp(struct kvm *kvm, unsigned long *rmapp,
diff --git a/arch/powerpc/kvm/book3s_pr.c b/arch/powerpc/kvm/book3s_pr.c
index faffb27..852fcd8 100644
--- a/arch/powerpc/kvm/book3s_pr.c
+++ b/arch/powerpc/kvm/book3s_pr.c
@@ -295,7 +295,8 @@ static int kvm_unmap_hva_range_pr(struct kvm *kvm, unsigned long start,
 	return 0;
 }
 
-static int kvm_age_hva_pr(struct kvm *kvm, unsigned long hva)
+static int kvm_age_hva_pr(struct kvm *kvm, unsigned long start,
+			  unsigned long end)
 {
 	/* XXX could be more clever ;) */
 	return 0;
diff --git a/arch/powerpc/kvm/e500_mmu_host.c b/arch/powerpc/kvm/e500_mmu_host.c
index 08f14bb..b1f3f63 100644
--- a/arch/powerpc/kvm/e500_mmu_host.c
+++ b/arch/powerpc/kvm/e500_mmu_host.c
@@ -732,7 +732,7 @@ int kvm_unmap_hva_range(struct kvm *kvm, unsigned long start, unsigned long end)
 	return 0;
 }
 
-int kvm_age_hva(struct kvm *kvm, unsigned long hva)
+int kvm_age_hva(struct kvm *kvm, unsigned long start, unsigned long end)
 {
 	/* XXX could be more clever ;) */
 	return 0;
diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 028df8d..a96c61b 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1036,7 +1036,7 @@ asmlinkage void kvm_spurious_fault(void);
 #define KVM_ARCH_WANT_MMU_NOTIFIER
 int kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
 int kvm_unmap_hva_range(struct kvm *kvm, unsigned long start, unsigned long end);
-int kvm_age_hva(struct kvm *kvm, unsigned long hva);
+int kvm_age_hva(struct kvm *kvm, unsigned long start, unsigned long end);
 int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
 void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 int cpuid_maxphyaddr(struct kvm_vcpu *vcpu);
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 76398fe..f33d5e4 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -1406,32 +1406,24 @@ static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp,
 	struct rmap_iterator uninitialized_var(iter);
 	int young = 0;
 
-	/*
-	 * In case of absence of EPT Access and Dirty Bits supports,
-	 * emulate the accessed bit for EPT, by checking if this page has
-	 * an EPT mapping, and clearing it if it does. On the next access,
-	 * a new EPT mapping will be established.
-	 * This has some overhead, but not as much as the cost of swapping
-	 * out actively used pages or breaking up actively used hugepages.
-	 */
-	if (!shadow_accessed_mask) {
-		young = kvm_unmap_rmapp(kvm, rmapp, slot, data);
-		goto out;
-	}
+	BUG_ON(!shadow_accessed_mask);
 
 	for (sptep = rmap_get_first(*rmapp, &iter); sptep;
 	     sptep = rmap_get_next(&iter)) {
+		struct kvm_mmu_page *sp;
+		gfn_t gfn;
 		BUG_ON(!is_shadow_present_pte(*sptep));
+		/* From spte to gfn. */
+		sp = page_header(__pa(sptep));
+		gfn = kvm_mmu_page_get_gfn(sp, sptep - sp->spt);
 
 		if (*sptep & shadow_accessed_mask) {
 			young = 1;
 			clear_bit((ffs(shadow_accessed_mask) - 1),
 				 (unsigned long *)sptep);
 		}
+		trace_kvm_age_page(gfn, slot, young);
 	}
-out:
-	/* @data has hva passed to kvm_age_hva(). */
-	trace_kvm_age_page(data, slot, young);
 	return young;
 }
 
@@ -1478,9 +1470,29 @@ static void rmap_recycle(struct kvm_vcpu *vcpu, u64 *spte, gfn_t gfn)
 	kvm_flush_remote_tlbs(vcpu->kvm);
 }
 
-int kvm_age_hva(struct kvm *kvm, unsigned long hva)
+int kvm_age_hva(struct kvm *kvm, unsigned long start, unsigned long end)
 {
-	return kvm_handle_hva(kvm, hva, hva, kvm_age_rmapp);
+	/*
+	 * In case of absence of EPT Access and Dirty Bits supports,
+	 * emulate the accessed bit for EPT, by checking if this page has
+	 * an EPT mapping, and clearing it if it does. On the next access,
+	 * a new EPT mapping will be established.
+	 * This has some overhead, but not as much as the cost of swapping
+	 * out actively used pages or breaking up actively used hugepages.
+	 */
+	if (!shadow_accessed_mask) {
+		/*
+		 * We are holding the kvm->mmu_lock, and we are blowing up
+		 * shadow PTEs. MMU notifier consumers need to be kept at bay.
+		 * This is correct as long as we don't decouple the mmu_lock
+		 * protected regions (like invalidate_range_start|end does).
+		 */
+		kvm->mmu_notifier_seq++;
+		return kvm_handle_hva_range(kvm, start, end, 0,
+					    kvm_unmap_rmapp);
+	}
+
+	return kvm_handle_hva_range(kvm, start, end, 0, kvm_age_rmapp);
 }
 
 int kvm_test_age_hva(struct kvm *kvm, unsigned long hva)
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 5f578e8..90d734b 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -402,9 +402,11 @@ static void __mn_flush_page(struct mmu_notifier *mn,
 
 static int mn_clear_flush_young(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-				unsigned long address)
+				unsigned long start,
+				unsigned long end)
 {
-	__mn_flush_page(mn, address);
+	for (; start < end; start += PAGE_SIZE)
+		__mn_flush_page(mn, start);
 
 	return 0;
 }
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 2728869..4269f2c 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -57,10 +57,13 @@ struct mmu_notifier_ops {
 	 * pte. This way the VM will provide proper aging to the
 	 * accesses to the page through the secondary MMUs and not
 	 * only to the ones through the Linux pte.
+	 * Start-end is necessary in case the secondary MMU is mapping the page
+	 * at a smaller granularity than the primary MMU.
 	 */
 	int (*clear_flush_young)(struct mmu_notifier *mn,
 				 struct mm_struct *mm,
-				 unsigned long address);
+				 unsigned long start,
+				 unsigned long end);
 
 	/*
 	 * test_young is called to check the young/accessed bitflag in
@@ -175,7 +178,8 @@ extern void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
 extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
-					  unsigned long address);
+					  unsigned long start,
+					  unsigned long end);
 extern int __mmu_notifier_test_young(struct mm_struct *mm,
 				     unsigned long address);
 extern void __mmu_notifier_change_pte(struct mm_struct *mm,
@@ -194,10 +198,11 @@ static inline void mmu_notifier_release(struct mm_struct *mm)
 }
 
 static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
-					  unsigned long address)
+					  unsigned long start,
+					  unsigned long end)
 {
 	if (mm_has_notifiers(mm))
-		return __mmu_notifier_clear_flush_young(mm, address);
+		return __mmu_notifier_clear_flush_young(mm, start, end);
 	return 0;
 }
 
@@ -255,7 +260,9 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	unsigned long ___address = __address;				\
 	__young = ptep_clear_flush_young(___vma, ___address, __ptep);	\
 	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
-						  ___address);		\
+						  ___address,		\
+						  ___address +		\
+							PAGE_SIZE);	\
 	__young;							\
 })
 
@@ -266,7 +273,9 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	unsigned long ___address = __address;				\
 	__young = pmdp_clear_flush_young(___vma, ___address, __pmdp);	\
 	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
-						  ___address);		\
+						  ___address,		\
+						  ___address +		\
+							PMD_PAGE_SIZE);	\
 	__young;							\
 })
 
@@ -301,7 +310,8 @@ static inline void mmu_notifier_release(struct mm_struct *mm)
 }
 
 static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
-					  unsigned long address)
+					  unsigned long start,
+					  unsigned long end)
 {
 	return 0;
 }
diff --git a/include/trace/events/kvm.h b/include/trace/events/kvm.h
index ab679c3..f58ef59 100644
--- a/include/trace/events/kvm.h
+++ b/include/trace/events/kvm.h
@@ -225,8 +225,8 @@ TRACE_EVENT(kvm_fpu,
 );
 
 TRACE_EVENT(kvm_age_page,
-	TP_PROTO(ulong hva, struct kvm_memory_slot *slot, int ref),
-	TP_ARGS(hva, slot, ref),
+	TP_PROTO(ulong gfn, struct kvm_memory_slot *slot, int ref),
+	TP_ARGS(gfn, slot, ref),
 
 	TP_STRUCT__entry(
 		__field(	u64,	hva		)
@@ -235,9 +235,9 @@ TRACE_EVENT(kvm_age_page,
 	),
 
 	TP_fast_assign(
-		__entry->hva		= hva;
-		__entry->gfn		=
-		  slot->base_gfn + ((hva - slot->userspace_addr) >> PAGE_SHIFT);
+		__entry->gfn		= gfn;
+		__entry->hva		= ((gfn - slot->base_gfn) >>
+					    PAGE_SHIFT) + slot->userspace_addr;
 		__entry->referenced	= ref;
 	),
 
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 950813b..2c8da98 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -107,7 +107,8 @@ void __mmu_notifier_release(struct mm_struct *mm)
  * existed or not.
  */
 int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
-					unsigned long address)
+					unsigned long start,
+					unsigned long end)
 {
 	struct mmu_notifier *mn;
 	int young = 0, id;
@@ -115,7 +116,7 @@ int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->clear_flush_young)
-			young |= mn->ops->clear_flush_young(mn, mm, address);
+			young |= mn->ops->clear_flush_young(mn, mm, start, end);
 	}
 	srcu_read_unlock(&srcu, id);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 3e8491c..66b075f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1355,7 +1355,11 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 			continue;	/* don't unmap */
 		}
 
-		if (ptep_clear_flush_young_notify(vma, address, pte))
+		/*
+		 * No need for _notify because we're called within an
+		 * mmu_notifier_invalidate_range_ {start|end} scope.
+		 */
+		if (ptep_clear_flush_young(vma, address, pte))
 			continue;
 
 		/* Nuke the page table entry. */
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index db57363..ea327f4 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -367,7 +367,8 @@ static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
 
 static int kvm_mmu_notifier_clear_flush_young(struct mmu_notifier *mn,
 					      struct mm_struct *mm,
-					      unsigned long address)
+					      unsigned long start,
+					      unsigned long end)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int young, idx;
@@ -375,7 +376,7 @@ static int kvm_mmu_notifier_clear_flush_young(struct mmu_notifier *mn,
 	idx = srcu_read_lock(&kvm->srcu);
 	spin_lock(&kvm->mmu_lock);
 
-	young = kvm_age_hva(kvm, address);
+	young = kvm_age_hva(kvm, start, end);
 	if (young)
 		kvm_flush_remote_tlbs(kvm);
 
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
