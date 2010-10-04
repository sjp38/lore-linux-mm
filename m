Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C8A466B0078
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 11:56:44 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v6 11/12] Let host know whether the guest can handle async PF in non-userspace context.
Date: Mon,  4 Oct 2010 17:56:33 +0200
Message-Id: <1286207794-16120-12-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-1-git-send-email-gleb@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
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
 Documentation/kvm/msr.txt       |    5 +++--
 arch/x86/include/asm/kvm_host.h |    1 +
 arch/x86/include/asm/kvm_para.h |    1 +
 arch/x86/kernel/kvm.c           |    3 +++
 arch/x86/kvm/x86.c              |    5 +++--
 5 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/Documentation/kvm/msr.txt b/Documentation/kvm/msr.txt
index d64e723..918f9ad 100644
--- a/Documentation/kvm/msr.txt
+++ b/Documentation/kvm/msr.txt
@@ -153,9 +153,10 @@ MSR_KVM_SYSTEM_TIME: 0x12
 
 MSR_KVM_ASYNC_PF_EN: 0x4b564d02
 	data: Bits 63-6 hold 64-byte aligned physical address of a 32bit memory
-	area which must be in guest RAM. Bits 5-1 are reserved and should be
+	area which must be in guest RAM. Bits 5-2 are reserved and should be
 	zero. Bit 0 is 1 when asynchronous page faults are enabled on the vcpu
-	0 when disabled.
+	0 when disabled. Bit 2 is 1 if asynchronous page faults can be injected
+	when vcpu is in kernel mode.
 
 	Physical address points to 32 bit memory location that will be written
 	to by the hypervisor at the time of asynchronous page fault injection to
diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 2f6fc87..81c1a4f 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -420,6 +420,7 @@ struct kvm_vcpu_arch {
 		struct gfn_to_hva_cache data;
 		u64 msr_val;
 		u32 id;
+		bool send_user_only;
 	} apf;
 };
 
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index bcc5022..bf3dab3 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -38,6 +38,7 @@
 #define KVM_MAX_MMU_OP_BATCH           32
 
 #define KVM_ASYNC_PF_ENABLED			(1 << 0)
+#define KVM_ASYNC_PF_SEND_ALWAYS		(1 << 1)
 
 /* Operations for KVM_HC_MMU_OP */
 #define KVM_MMU_OP_WRITE_PTE            1
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index f73946f..d5877bf 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -449,6 +449,9 @@ void __cpuinit kvm_guest_cpu_init(void)
 	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF) && kvmapf) {
 		u64 pa = __pa(&__get_cpu_var(apf_reason));
 
+#ifdef CONFIG_PREEMPT
+		pa |= KVM_ASYNC_PF_SEND_ALWAYS;
+#endif
 		if (native_write_msr_safe(MSR_KVM_ASYNC_PF_EN,
 					  pa | KVM_ASYNC_PF_ENABLED, pa >> 32))
 			return;
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 0e69d37..cad4412 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -1429,8 +1429,8 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
 {
 	gpa_t gpa = data & ~0x3f;
 
-	/* Bits 1:5 are resrved, Should be zero */
-	if (data & 0x3e)
+	/* Bits 2:5 are resrved, Should be zero */
+	if (data & 0x3c)
 		return 1;
 
 	vcpu->arch.apf.msr_val = data;
@@ -1444,6 +1444,7 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
 	if (kvm_gfn_to_hva_cache_init(vcpu->kvm, &vcpu->arch.apf.data, gpa))
 		return 1;
 
+	vcpu->arch.apf.send_user_only = !(data & KVM_ASYNC_PF_SEND_ALWAYS);
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
