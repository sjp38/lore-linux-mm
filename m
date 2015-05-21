Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 66C506B0192
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:33:26 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so59379705qkd.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:26 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id w104si1670357qgd.2.2015.05.21.12.33.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:33:25 -0700 (PDT)
Received: by qkgv12 with SMTP id v12so64229882qkg.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:24 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 03/36] mmu_notifier: pass page pointer to mmu_notifier_invalidate_page()
Date: Thu, 21 May 2015 15:31:12 -0400
Message-Id: <1432236705-4209-4-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Listener of mm event might not have easy way to get the struct page
behind and address invalidated with mmu_notifier_invalidate_page()
function as this happens after the cpu page table have been clear/
updated. This happens for instance if the listener is storing a dma
mapping inside its secondary page table. To avoid complex reverse
dma mapping lookup just pass along a pointer to the page being
invalidated.

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
index 8f7f845..d10dd88 100644
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
index 0e8aa12..90693ce 100644
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
index ada3ed1..283ad26 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -172,6 +172,7 @@ struct mmu_notifier_ops {
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
 				unsigned long address,
+				struct page *page,
 				enum mmu_event event);
 
 	/*
@@ -290,6 +291,7 @@ extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      enum mmu_event event);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address,
+					  struct page *page,
 					  enum mmu_event event);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 						  struct mmu_notifier_range *range);
@@ -338,10 +340,11 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 
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
@@ -492,6 +495,7 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 						unsigned long address,
+						struct page *page,
 						enum mmu_event event)
 {
 }
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 294ebc4..2ff6d43 100644
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
index 74c51e0..4563edc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -915,7 +915,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 
 	if (ret) {
-		mmu_notifier_invalidate_page(mm, address, MMU_WRITE_BACK);
+		mmu_notifier_invalidate_page(mm, address, page, MMU_WRITE_BACK);
 		(*cleaned)++;
 	}
 out:
@@ -1338,7 +1338,7 @@ discard:
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address, MMU_MIGRATE);
+		mmu_notifier_invalidate_page(mm, address, page, MMU_MIGRATE);
 out:
 	return ret;
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 6177c56..62978ed 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -261,6 +261,7 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
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
