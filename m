Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 11BAD6007F5
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 11:31:17 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v5 11/12] Let host know whether the guest can handle async PF in non-userspace context.
Date: Mon, 19 Jul 2010 18:31:01 +0300
Message-Id: <1279553462-7036-12-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-1-git-send-email-gleb@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

If guest can detect that it runs in non-preemptable context it can
handle async PFs at any time, so let host know that it can send async
PF even if guest cpu is not in userspace.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    1 +
 arch/x86/include/asm/kvm_para.h |    1 +
 arch/x86/kernel/kvm.c           |    3 +++
 arch/x86/kvm/x86.c              |    5 +++--
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 45e6c12..c675d5d 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -367,6 +367,7 @@ struct kvm_vcpu_arch {
 	cpumask_var_t wbinvd_dirty_mask;
 
 	u32 __user *apf_data;
+	bool apf_send_user_only;
 	u32 apf_memslot_ver;
 	u64 apf_msr_val;
 	u32 async_pf_id;
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index edf07cf..a33372c 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -38,6 +38,7 @@
 #define KVM_MAX_MMU_OP_BATCH           32
 
 #define KVM_ASYNC_PF_ENABLED			(1 << 0)
+#define KVM_ASYNC_PF_SEND_ALWAYS		(1 << 1)
 
 /* Operations for KVM_HC_MMU_OP */
 #define KVM_MMU_OP_WRITE_PTE            1
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 914b0fc..462b47d 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -429,6 +429,9 @@ void __cpuinit kvm_guest_cpu_init(void)
 	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF)) {
 		u64 pa = __pa(&__get_cpu_var(apf_reason));
 
+#ifdef CONFIG_PREEMPT
+		pa |= KVM_ASYNC_PF_SEND_ALWAYS;
+#endif
 		if (native_write_msr_safe(MSR_KVM_ASYNC_PF_EN,
 					  pa | KVM_ASYNC_PF_ENABLED, pa >> 32))
 			return;
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 5482db0..ba351f5 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -1222,8 +1222,8 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
 	int offset = offset_in_page(gpa);
 	unsigned long addr;
 
-	/* Bits 1:5 are resrved, Should be zero */
-	if (data & 0x3e)
+	/* Bits 2:5 are resrved, Should be zero */
+	if (data & 0x3c)
 		return 1;
 
 	vcpu->arch.apf_msr_val = data;
@@ -1246,6 +1246,7 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
 		return 1;
 	}
 	vcpu->arch.apf_memslot_ver = vcpu->kvm->memslot_version;
+	vcpu->arch.apf_send_user_only = !(data & KVM_ASYNC_PF_SEND_ALWAYS);
 	kvm_async_pf_wakeup_all(vcpu);
 	return 0;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
