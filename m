Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D62E280395
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:55:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id x36so14760495qtx.9
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:55:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a49si3976066qtc.359.2017.08.29.16.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 16:55:19 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 12/13] KVM: update to new mmu_notifier semantic
Date: Tue, 29 Aug 2017 19:54:46 -0400
Message-Id: <20170829235447.10050-13-jglisse@redhat.com>
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: kvm@vger.kernel.org
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 virt/kvm/kvm_main.c | 42 ------------------------------------------
 1 file changed, 42 deletions(-)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 15252d723b54..4d81f6ded88e 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -322,47 +322,6 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
 	return container_of(mn, struct kvm, mmu_notifier);
 }
 
-static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
-					     struct mm_struct *mm,
-					     unsigned long address)
-{
-	struct kvm *kvm = mmu_notifier_to_kvm(mn);
-	int need_tlb_flush, idx;
-
-	/*
-	 * When ->invalidate_page runs, the linux pte has been zapped
-	 * already but the page is still allocated until
-	 * ->invalidate_page returns. So if we increase the sequence
-	 * here the kvm page fault will notice if the spte can't be
-	 * established because the page is going to be freed. If
-	 * instead the kvm page fault establishes the spte before
-	 * ->invalidate_page runs, kvm_unmap_hva will release it
-	 * before returning.
-	 *
-	 * The sequence increase only need to be seen at spin_unlock
-	 * time, and not at spin_lock time.
-	 *
-	 * Increasing the sequence after the spin_unlock would be
-	 * unsafe because the kvm page fault could then establish the
-	 * pte after kvm_unmap_hva returned, without noticing the page
-	 * is going to be freed.
-	 */
-	idx = srcu_read_lock(&kvm->srcu);
-	spin_lock(&kvm->mmu_lock);
-
-	kvm->mmu_notifier_seq++;
-	need_tlb_flush = kvm_unmap_hva(kvm, address) | kvm->tlbs_dirty;
-	/* we've to flush the tlb before the pages can be freed */
-	if (need_tlb_flush)
-		kvm_flush_remote_tlbs(kvm);
-
-	spin_unlock(&kvm->mmu_lock);
-
-	kvm_arch_mmu_notifier_invalidate_page(kvm, address);
-
-	srcu_read_unlock(&kvm->srcu, idx);
-}
-
 static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 					struct mm_struct *mm,
 					unsigned long address,
@@ -510,7 +469,6 @@ static void kvm_mmu_notifier_release(struct mmu_notifier *mn,
 }
 
 static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
-	.invalidate_page	= kvm_mmu_notifier_invalidate_page,
 	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
 	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
 	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
