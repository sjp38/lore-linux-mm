Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1714D82F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:04:40 -0400 (EDT)
Received: by qgbb65 with SMTP id b65so37849636qgb.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:04:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y46si7209245qgd.62.2015.10.21.13.04.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:04:39 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v11 03/15] mmu_notifier: pass page pointer to mmu_notifier_invalidate_page() v2
Date: Wed, 21 Oct 2015 16:59:58 -0400
Message-Id: <1445461210-2605-4-git-send-email-jglisse@redhat.com>
In-Reply-To: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
References: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
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
index 52f7d64..69f0f7c 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -393,6 +393,7 @@ static int mn_clear_flush_young(struct mmu_notifier *mn,
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
index 71c526c..2782c7c 100644
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
index 4ac1930..d9b3cf1 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -179,6 +179,7 @@ struct mmu_notifier_ops {
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
 				unsigned long address,
+				struct page *page,
 				enum mmu_event event);
 
 	/*
@@ -300,6 +301,7 @@ extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      enum mmu_event event);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address,
+					  struct page *page,
 					  enum mmu_event event);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 					struct mmu_notifier_range *range);
@@ -357,10 +359,11 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 
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
@@ -533,6 +536,7 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 						unsigned long address,
+						struct page *page,
 						enum mmu_event event)
 {
 }
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index c43c851..316e4a9 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -177,6 +177,7 @@ void __mmu_notifier_change_pte(struct mm_struct *mm,
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 				    unsigned long address,
+				    struct page *page,
 				    enum mmu_event event)
 {
 	struct mmu_notifier *mn;
@@ -185,7 +186,7 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address, event);
+			mn->ops->invalidate_page(mn, mm, address, page, event);
 	}
 	srcu_read_unlock(&srcu, id);
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 8ff1e3b..c26b76a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1000,7 +1000,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 
 	if (ret) {
-		mmu_notifier_invalidate_page(mm, address, MMU_WRITE_BACK);
+		mmu_notifier_invalidate_page(mm, address, page, MMU_WRITE_BACK);
 		(*cleaned)++;
 	}
 out:
@@ -1420,7 +1420,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address, MMU_MIGRATE);
+		mmu_notifier_invalidate_page(mm, address, page, MMU_MIGRATE);
 out:
 	return ret;
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index fa2418f3..8164ce5 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -270,6 +270,7 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
 static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
 					     unsigned long address,
+					     struct page *page,
 					     enum mmu_event event)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
