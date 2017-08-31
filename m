Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A65B76B0493
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:18:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b20so2308206qkg.6
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 14:18:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 32si631588qtz.524.2017.08.31.14.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 14:18:09 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 12/13] KVM: update to new mmu_notifier semantic v2
Date: Thu, 31 Aug 2017 17:17:37 -0400
Message-Id: <20170831211738.17922-13-jglisse@redhat.com>
In-Reply-To: <20170831211738.17922-1-jglisse@redhat.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Changed since v1 (Linus Torvalds)
    - remove now useless kvm_arch_mmu_notifier_invalidate_page()

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Tested-by: Mike Galbraith <efault@gmx.de>
Tested-by: Adam Borowski <kilobyte@angband.pl>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: kvm@vger.kernel.org
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/arm/include/asm/kvm_host.h     |  6 ------
 arch/arm64/include/asm/kvm_host.h   |  6 ------
 arch/mips/include/asm/kvm_host.h    |  5 -----
 arch/powerpc/include/asm/kvm_host.h |  5 -----
 arch/x86/include/asm/kvm_host.h     |  2 --
 arch/x86/kvm/x86.c                  | 11 ----------
 virt/kvm/kvm_main.c                 | 42 -------------------------------------
 7 files changed, 77 deletions(-)

diff --git a/arch/arm/include/asm/kvm_host.h b/arch/arm/include/asm/kvm_host.h
index 127e2dd2e21c..4a879f6ff13b 100644
--- a/arch/arm/include/asm/kvm_host.h
+++ b/arch/arm/include/asm/kvm_host.h
@@ -225,12 +225,6 @@ int kvm_arm_copy_reg_indices(struct kvm_vcpu *vcpu, u64 __user *indices);
 int kvm_age_hva(struct kvm *kvm, unsigned long start, unsigned long end);
 int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
 
-/* We do not have shadow page tables, hence the empty hooks */
-static inline void kvm_arch_mmu_notifier_invalidate_page(struct kvm *kvm,
-							 unsigned long address)
-{
-}
-
 struct kvm_vcpu *kvm_arm_get_running_vcpu(void);
 struct kvm_vcpu __percpu **kvm_get_running_vcpus(void);
 void kvm_arm_halt_guest(struct kvm *kvm);
diff --git a/arch/arm64/include/asm/kvm_host.h b/arch/arm64/include/asm/kvm_host.h
index d68630007b14..e923b58606e2 100644
--- a/arch/arm64/include/asm/kvm_host.h
+++ b/arch/arm64/include/asm/kvm_host.h
@@ -326,12 +326,6 @@ void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 int kvm_age_hva(struct kvm *kvm, unsigned long start, unsigned long end);
 int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
 
-/* We do not have shadow page tables, hence the empty hooks */
-static inline void kvm_arch_mmu_notifier_invalidate_page(struct kvm *kvm,
-							 unsigned long address)
-{
-}
-
 struct kvm_vcpu *kvm_arm_get_running_vcpu(void);
 struct kvm_vcpu * __percpu *kvm_get_running_vcpus(void);
 void kvm_arm_halt_guest(struct kvm *kvm);
diff --git a/arch/mips/include/asm/kvm_host.h b/arch/mips/include/asm/kvm_host.h
index 2998479fd4e8..a9af1d2dcd69 100644
--- a/arch/mips/include/asm/kvm_host.h
+++ b/arch/mips/include/asm/kvm_host.h
@@ -938,11 +938,6 @@ void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 int kvm_age_hva(struct kvm *kvm, unsigned long start, unsigned long end);
 int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
 
-static inline void kvm_arch_mmu_notifier_invalidate_page(struct kvm *kvm,
-							 unsigned long address)
-{
-}
-
 /* Emulation */
 int kvm_get_inst(u32 *opc, struct kvm_vcpu *vcpu, u32 *out);
 enum emulation_result update_pc(struct kvm_vcpu *vcpu, u32 cause);
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index 8b3f1238d07f..e372ed871c51 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -67,11 +67,6 @@ extern int kvm_age_hva(struct kvm *kvm, unsigned long start, unsigned long end);
 extern int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
 extern void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 
-static inline void kvm_arch_mmu_notifier_invalidate_page(struct kvm *kvm,
-							 unsigned long address)
-{
-}
-
 #define HPTEG_CACHE_NUM			(1 << 15)
 #define HPTEG_HASH_BITS_PTE		13
 #define HPTEG_HASH_BITS_PTE_LONG	12
diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index f4d120a3e22e..92c9032502d8 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1375,8 +1375,6 @@ int kvm_arch_interrupt_allowed(struct kvm_vcpu *vcpu);
 int kvm_cpu_get_interrupt(struct kvm_vcpu *v);
 void kvm_vcpu_reset(struct kvm_vcpu *vcpu, bool init_event);
 void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu);
-void kvm_arch_mmu_notifier_invalidate_page(struct kvm *kvm,
-					   unsigned long address);
 
 void kvm_define_shared_msr(unsigned index, u32 msr);
 int kvm_set_shared_msr(unsigned index, u64 val, u64 mask);
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 05a5e57c6f39..272320eb328c 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -6734,17 +6734,6 @@ void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu)
 }
 EXPORT_SYMBOL_GPL(kvm_vcpu_reload_apic_access_page);
 
-void kvm_arch_mmu_notifier_invalidate_page(struct kvm *kvm,
-					   unsigned long address)
-{
-	/*
-	 * The physical address of apic access page is stored in the VMCS.
-	 * Update it when it becomes invalid.
-	 */
-	if (address == gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT))
-		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
-}
-
 /*
  * Returns 1 to let vcpu_run() continue the guest execution loop without
  * exiting to the userspace.  Otherwise, the value will be returned to the
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
