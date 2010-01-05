Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5E3D26007D7
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:13:10 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v3 11/12] Let host know whether the guest can handle async PF in non-userspace context.
Date: Tue,  5 Jan 2010 16:12:53 +0200
Message-Id: <1262700774-1808-12-git-send-email-gleb@redhat.com>
In-Reply-To: <1262700774-1808-1-git-send-email-gleb@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

If guest can detect that it runs in non-preemptable context it can
handle async PFs at any time, so let host know that it can send async
PF even if guest cpu is not in userspace.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    1 +
 arch/x86/include/asm/kvm_para.h |    1 +
 arch/x86/kernel/kvm.c           |    3 +++
 arch/x86/kvm/x86.c              |    5 +++--
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 43c1aca..cb0fd75 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -365,6 +365,7 @@ struct kvm_vcpu_arch {
 	unsigned long singlestep_rip;
 
 	u32 __user *apf_data;
+	bool apf_send_user_only;
 	u32 apf_memslot_ver;
 	u64 apf_msr_val;
 	u32 async_pf_id;
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index 98edaa9..8a18560 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -24,6 +24,7 @@
 #define KVM_MAX_MMU_OP_BATCH           32
 
 #define KVM_ASYNC_PF_ENABLED			(1 << 0)
+#define KVM_ASYNC_PF_SEND_ALWAYS		(1 << 1)
 
 /* Operations for KVM_HC_MMU_OP */
 #define KVM_MMU_OP_WRITE_PTE            1
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 49549fd..4241706 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -480,6 +480,9 @@ void __cpuinit kvm_guest_cpu_init(void)
 	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF)) {
 		u64 pa = __pa(&__get_cpu_var(apf_reason));
 
+#ifdef CONFIG_PREEMPT
+		pa |= KVM_ASYNC_PF_SEND_ALWAYS;
+#endif
 		if (native_write_msr_safe(MSR_KVM_ASYNC_PF_EN,
 					  pa | KVM_ASYNC_PF_ENABLED, pa >> 32))
 			return;
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index e2e33ac..47f1661 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -1009,8 +1009,8 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
 	int offset = offset_in_page(gpa);
 	unsigned long addr;
 
-	/* Bits 1:5 are resrved, Should be zero */
-	if (data & 0x3e)
+	/* Bits 2:5 are resrved, Should be zero */
+	if (data & 0x3c)
 		return 1;
 
 	vcpu->arch.apf_msr_val = data;
@@ -1032,6 +1032,7 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
 		return 1;
 	}
 	vcpu->arch.apf_memslot_ver = vcpu->kvm->memslot_version;
+	vcpu->arch.apf_send_user_only = !(data & KVM_ASYNC_PF_SEND_ALWAYS);
 	kvm_async_pf_wakeup_all(vcpu);
 	return 0;
 }
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
