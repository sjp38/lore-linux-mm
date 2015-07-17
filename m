Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 594FD280348
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:53:26 -0400 (EDT)
Received: by igvi1 with SMTP id i1so41479784igv.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:53:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si3739347iom.51.2015.07.17.11.53.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:53:25 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 03/15] mmu_notifier: pass page pointer to mmu_notifier_invalidate_page() v2
Date: Fri, 17 Jul 2015 14:52:13 -0400
Message-Id: <1437159145-6548-4-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Listener of mm event might not have easy way to get the struct page
behind an address invalidated with mmu_notifier_invalidate_page()
function as this happens after the cpu page table have been clear/
updated. This happens for instance if the listener is storing a dma
mapping inside its secondary page table. To avoid complex reverse
dma mapping lookup just pass along a pointer to the page being
invalidated.

Changed since v1:
  - English syntax fixes.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/infiniband/core/umem_odp.c | 1 +
 drivers/iommu/amd_iommu_v2.c       | 1 +
 drivers/misc/sgi-gru/grutlbpurge.c | 1 +
 drivers/xen/gntdev.c               | 1 +
 include/linux/mmu_notifier.h       | 6 +++++-
 mm/mmu_notifier.c                  | 3 ++-
 mm/rmap.c                          | 4 ++--
 virt/kvm/kvm_main.c                | 1 +
 8 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 58d9a00..0541761 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -166,6 +166,7 @@ static int invalidate_page_trampoline(struct ib_umem *item, u64 start,
 static void ib_umem_notifier_invalidate_page(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
 					     unsigned long address,
+					     struct page *page,
 					     enum mmu_event event)
 {
 	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 4aa4de6..de3c540 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -385,6 +385,7 @@ static int mn_clear_flush_young(struct mmu_notifier *mn,
 static void mn_invalidate_page(struct mmu_notifier *mn,
 			       struct mm_struct *mm,
 			       unsigned long address,
+			       struct page *page,
 			       enum mmu_event event)
 {
 	__mn_flush_page(mn, address);
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index 44b41b7..c7659b76 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -250,6 +250,7 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 
 static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
 				unsigned long address,
+				struct page *page,
 				enum mmu_event event)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index a601f69..3cc52c2 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -485,6 +485,7 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
 static void mn_invl_page(struct mmu_notifier *mn,
 			 struct mm_struct *mm,
 			 unsigned long address,
+			 struct page *page,
 			 enum mmu_event event)
 {
 	struct mmu_notifier_range range;
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 13b4b51..1a20145c 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -169,6 +169,7 @@ struct mmu_notifier_ops {
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
 				unsigned long address,
+				struct page *page,
 				enum mmu_event event);
 
 	/*
@@ -287,6 +288,7 @@ extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      enum mmu_event event);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address,
+					  struct page *page,
 					  enum mmu_event event);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 					struct mmu_notifier_range *range);
@@ -335,10 +337,11 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 						unsigned long address,
+						struct page *page,
 						enum mmu_event event)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_page(mm, address, event);
+		__mmu_notifier_invalidate_page(mm, address, page, event);
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
@@ -489,6 +492,7 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 						unsigned long address,
+						struct page *page,
 						enum mmu_event event)
 {
 }
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 99fccbd..2ed6d0d 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -160,6 +160,7 @@ void __mmu_notifier_change_pte(struct mm_struct *mm,
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 				    unsigned long address,
+				    struct page *page,
 				    enum mmu_event event)
 {
 	struct mmu_notifier *mn;
@@ -168,7 +169,7 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address, event);
+			mn->ops->invalidate_page(mn, mm, address, page, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index b1e6eae..65aee96 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -891,7 +891,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 
 	if (ret) {
-		mmu_notifier_invalidate_page(mm, address, MMU_WRITE_BACK);
+		mmu_notifier_invalidate_page(mm, address, page, MMU_WRITE_BACK);
 		(*cleaned)++;
 	}
 out:
@@ -1298,7 +1298,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address, MMU_MIGRATE);
+		mmu_notifier_invalidate_page(mm, address, page, MMU_MIGRATE);
 out:
 	return ret;
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 7e79aa8..5f35340 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -260,6 +260,7 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
 static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
 					     unsigned long address,
+					     struct page *page,
 					     enum mmu_event event)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
