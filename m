Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3324F6B0275
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:38:12 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id ro13so83990042pac.7
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:38:12 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0074.outbound.protection.outlook.com. [104.47.37.74])
        by mx.google.com with ESMTPS id fg9si1552786pab.205.2016.11.09.16.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:38:11 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 17/20] x86/kvm: Enable Secure Memory Encryption of
 nested page tables
Date: Wed, 9 Nov 2016 18:38:05 -0600
Message-ID: <20161110003805.3280.49182.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo
 Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas
 Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Update the KVM support to include the memory encryption mask when creating
and using nested page tables.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/kvm_host.h |    3 ++-
 arch/x86/kvm/mmu.c              |    8 ++++++--
 arch/x86/kvm/vmx.c              |    3 ++-
 arch/x86/kvm/x86.c              |    3 ++-
 4 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 33ae3a4..c51c1cb 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1039,7 +1039,8 @@ void kvm_mmu_setup(struct kvm_vcpu *vcpu);
 void kvm_mmu_init_vm(struct kvm *kvm);
 void kvm_mmu_uninit_vm(struct kvm *kvm);
 void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
-		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 p_mask);
+		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 p_mask,
+		u64 me_mask);
 
 void kvm_mmu_reset_context(struct kvm_vcpu *vcpu);
 void kvm_mmu_slot_remove_write_access(struct kvm *kvm,
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 3d4cc8cc..a7040f4 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -122,7 +122,7 @@ module_param(dbg, bool, 0644);
 					    * PT32_LEVEL_BITS))) - 1))
 
 #define PT64_PERM_MASK (PT_PRESENT_MASK | PT_WRITABLE_MASK | shadow_user_mask \
-			| shadow_x_mask | shadow_nx_mask)
+			| shadow_x_mask | shadow_nx_mask | shadow_me_mask)
 
 #define ACC_EXEC_MASK    1
 #define ACC_WRITE_MASK   PT_WRITABLE_MASK
@@ -177,6 +177,7 @@ static u64 __read_mostly shadow_accessed_mask;
 static u64 __read_mostly shadow_dirty_mask;
 static u64 __read_mostly shadow_mmio_mask;
 static u64 __read_mostly shadow_present_mask;
+static u64 __read_mostly shadow_me_mask;
 
 static void mmu_spte_set(u64 *sptep, u64 spte);
 static void mmu_free_roots(struct kvm_vcpu *vcpu);
@@ -284,7 +285,8 @@ static bool check_mmio_spte(struct kvm_vcpu *vcpu, u64 spte)
 }
 
 void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
-		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 p_mask)
+		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 p_mask,
+		u64 me_mask)
 {
 	shadow_user_mask = user_mask;
 	shadow_accessed_mask = accessed_mask;
@@ -292,6 +294,7 @@ void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
 	shadow_nx_mask = nx_mask;
 	shadow_x_mask = x_mask;
 	shadow_present_mask = p_mask;
+	shadow_me_mask = me_mask;
 }
 EXPORT_SYMBOL_GPL(kvm_mmu_set_mask_ptes);
 
@@ -2553,6 +2556,7 @@ static int set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
 		pte_access &= ~ACC_WRITE_MASK;
 
 	spte |= (u64)pfn << PAGE_SHIFT;
+	spte |= shadow_me_mask;
 
 	if (pte_access & ACC_WRITE_MASK) {
 
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 121fdf6..1ae30c2 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -6482,7 +6482,8 @@ static __init int hardware_setup(void)
 			(enable_ept_ad_bits) ? VMX_EPT_DIRTY_BIT : 0ull,
 			0ull, VMX_EPT_EXECUTABLE_MASK,
 			cpu_has_vmx_ept_execute_only() ?
-				      0ull : VMX_EPT_READABLE_MASK);
+				      0ull : VMX_EPT_READABLE_MASK,
+			0ull);
 		ept_set_mmio_spte_mask();
 		kvm_enable_tdp();
 	} else
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 2c7e775..3b4d967 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -65,6 +65,7 @@
 #include <asm/pvclock.h>
 #include <asm/div64.h>
 #include <asm/irq_remapping.h>
+#include <asm/mem_encrypt.h>
 
 #define CREATE_TRACE_POINTS
 #include "trace.h"
@@ -5875,7 +5876,7 @@ int kvm_arch_init(void *opaque)
 
 	kvm_mmu_set_mask_ptes(PT_USER_MASK, PT_ACCESSED_MASK,
 			PT_DIRTY_MASK, PT64_NX_MASK, 0,
-			PT_PRESENT_MASK);
+			PT_PRESENT_MASK, sme_me_mask);
 	kvm_timer_init();
 
 	perf_register_guest_info_callbacks(&kvm_guest_cbs);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
