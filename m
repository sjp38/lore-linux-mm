Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBC2C6B0274
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 13:06:10 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id u22so3841526otd.13
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 10:06:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z66si1644566otb.102.2017.11.30.10.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 10:06:10 -0800 (PST)
From: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>
Subject: [PATCH 2/2] TESTING! KVM: x86: add invalidate_range mmu notifier
Date: Thu, 30 Nov 2017 19:05:46 +0100
Message-Id: <20171130180546.4331-2-rkrcmar@redhat.com>
In-Reply-To: <20171130180546.4331-1-rkrcmar@redhat.com>
References: <20171130161933.GB1606@flask>
 <20171130180546.4331-1-rkrcmar@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?q?Fabian=20Gr=C3=BCnbichler?= <f.gruenbichler@proxmox.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Does roughly what kvm_mmu_notifier_invalidate_page did before.

I am not certain why this would be needed.  It might mean that we have
another bug with start/end or just that I missed something.

Please try just [1/2] first and apply this one only if [1/2] still bugs,
thanks!
---
 virt/kvm/kvm_main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index b7f4689e373f..0825ea624f16 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -342,6 +342,29 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 	srcu_read_unlock(&kvm->srcu, idx);
 }
 
+static void kvm_mmu_notifier_invalidate_range(struct mmu_notifier *mn,
+						    struct mm_struct *mm,
+						    unsigned long start,
+						    unsigned long end)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	int need_tlb_flush = 0, idx;
+
+	idx = srcu_read_lock(&kvm->srcu);
+	spin_lock(&kvm->mmu_lock);
+	kvm->mmu_notifier_seq++;
+	need_tlb_flush = kvm_unmap_hva_range(kvm, start, end);
+	need_tlb_flush |= kvm->tlbs_dirty;
+	if (need_tlb_flush)
+		kvm_flush_remote_tlbs(kvm);
+
+	spin_unlock(&kvm->mmu_lock);
+
+	kvm_arch_mmu_notifier_invalidate_range(kvm, start, end);
+
+	srcu_read_unlock(&kvm->srcu, idx);
+}
+
 static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						    struct mm_struct *mm,
 						    unsigned long start,
@@ -476,6 +499,7 @@ static void kvm_mmu_notifier_release(struct mmu_notifier *mn,
 }
 
 static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
+	.invalidate_range	= kvm_mmu_notifier_invalidate_range,
 	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
 	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
 	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
