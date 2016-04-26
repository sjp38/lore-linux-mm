Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1056B0278
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:59:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so50292656pfb.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:59:03 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0071.outbound.protection.outlook.com. [157.56.110.71])
        by mx.google.com with ESMTPS id r9si3551546pae.39.2016.04.26.15.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:59:02 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 17/18] x86/kvm: Enable Secure Memory Encryption of
 nested page tables
Date: Tue, 26 Apr 2016 17:58:55 -0500
Message-ID: <20160426225855.13567.53070.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

Update the KVM support to include the memory encryption mask when creating
and using nested page tables.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/kvm_host.h |    2 +-
 arch/x86/kvm/mmu.c              |    7 +++++--
 arch/x86/kvm/vmx.c              |    2 +-
 arch/x86/kvm/x86.c              |    3 ++-
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index b7e3944..75f1e30 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1012,7 +1012,7 @@ void kvm_mmu_setup(struct kvm_vcpu *vcpu);
 void kvm_mmu_init_vm(struct kvm *kvm);
 void kvm_mmu_uninit_vm(struct kvm *kvm);
 void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
-		u64 dirty_mask, u64 nx_mask, u64 x_mask);
+		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 me_mask);
 
 void kvm_mmu_reset_context(struct kvm_vcpu *vcpu);
 void kvm_mmu_slot_remove_write_access(struct kvm *kvm,
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 4c6972f..5c7d939 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -121,7 +121,7 @@ module_param(dbg, bool, 0644);
 					    * PT32_LEVEL_BITS))) - 1))
 
 #define PT64_PERM_MASK (PT_PRESENT_MASK | PT_WRITABLE_MASK | shadow_user_mask \
-			| shadow_x_mask | shadow_nx_mask)
+			| shadow_x_mask | shadow_nx_mask | shadow_me_mask)
 
 #define ACC_EXEC_MASK    1
 #define ACC_WRITE_MASK   PT_WRITABLE_MASK
@@ -175,6 +175,7 @@ static u64 __read_mostly shadow_user_mask;
 static u64 __read_mostly shadow_accessed_mask;
 static u64 __read_mostly shadow_dirty_mask;
 static u64 __read_mostly shadow_mmio_mask;
+static u64 __read_mostly shadow_me_mask;
 
 static void mmu_spte_set(u64 *sptep, u64 spte);
 static void mmu_free_roots(struct kvm_vcpu *vcpu);
@@ -282,13 +283,14 @@ static bool check_mmio_spte(struct kvm_vcpu *vcpu, u64 spte)
 }
 
 void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
-		u64 dirty_mask, u64 nx_mask, u64 x_mask)
+		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 me_mask)
 {
 	shadow_user_mask = user_mask;
 	shadow_accessed_mask = accessed_mask;
 	shadow_dirty_mask = dirty_mask;
 	shadow_nx_mask = nx_mask;
 	shadow_x_mask = x_mask;
+	shadow_me_mask = me_mask;
 }
 EXPORT_SYMBOL_GPL(kvm_mmu_set_mask_ptes);
 
@@ -2549,6 +2551,7 @@ static int set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
 		pte_access &= ~ACC_WRITE_MASK;
 
 	spte |= (u64)pfn << PAGE_SHIFT;
+	spte |= shadow_me_mask;
 
 	if (pte_access & ACC_WRITE_MASK) {
 
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index d5908bd..5d8eb4b 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -6351,7 +6351,7 @@ static __init int hardware_setup(void)
 		kvm_mmu_set_mask_ptes(0ull,
 			(enable_ept_ad_bits) ? VMX_EPT_ACCESS_BIT : 0ull,
 			(enable_ept_ad_bits) ? VMX_EPT_DIRTY_BIT : 0ull,
-			0ull, VMX_EPT_EXECUTABLE_MASK);
+			0ull, VMX_EPT_EXECUTABLE_MASK, 0ull);
 		ept_set_mmio_spte_mask();
 		kvm_enable_tdp();
 	} else
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 12f33e6..9432e27 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -67,6 +67,7 @@
 #include <asm/pvclock.h>
 #include <asm/div64.h>
 #include <asm/irq_remapping.h>
+#include <asm/mem_encrypt.h>
 
 #define MAX_IO_MSRS 256
 #define KVM_MAX_MCE_BANKS 32
@@ -5859,7 +5860,7 @@ int kvm_arch_init(void *opaque)
 	kvm_x86_ops = ops;
 
 	kvm_mmu_set_mask_ptes(PT_USER_MASK, PT_ACCESSED_MASK,
-			PT_DIRTY_MASK, PT64_NX_MASK, 0);
+			PT_DIRTY_MASK, PT64_NX_MASK, 0, sme_me_mask);
 
 	kvm_timer_init();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
