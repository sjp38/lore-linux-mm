Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DE6685F0040
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 05:23:09 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v7 11/12] Let host know whether the guest can handle async PF in non-userspace context.
Date: Thu, 14 Oct 2010 11:22:55 +0200
Message-Id: <1287048176-2563-12-git-send-email-gleb@redhat.com>
In-Reply-To: <1287048176-2563-1-git-send-email-gleb@redhat.com>
References: <1287048176-2563-1-git-send-email-gleb@redhat.com>
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
 Documentation/kvm/msr.txt       |    6 +++---
 arch/x86/include/asm/kvm_host.h |    1 +
 arch/x86/include/asm/kvm_para.h |    1 +
 arch/x86/kernel/kvm.c           |    3 +++
 arch/x86/kvm/x86.c              |    5 +++--
 5 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/Documentation/kvm/msr.txt b/Documentation/kvm/msr.txt
index 27c11a6..d079aed 100644
--- a/Documentation/kvm/msr.txt
+++ b/Documentation/kvm/msr.txt
@@ -154,9 +154,10 @@ MSR_KVM_SYSTEM_TIME: 0x12
 MSR_KVM_ASYNC_PF_EN: 0x4b564d02
 	data: Bits 63-6 hold 64-byte aligned physical address of a
 	64 byte memory area which must be in guest RAM and must be
-	zeroed. Bits 5-1 are reserved and should be zero. Bit 0 is 1
+	zeroed. Bits 5-2 are reserved and should be zero. Bit 0 is 1
 	when asynchronous page faults are enabled on the vcpu 0 when
-	disabled.
+	disabled. Bit 2 is 1 if asynchronous page faults can be injected
+	when vcpu is in cpl == 0.
 
 	First 4 byte of 64 byte memory location will be written to by
 	the hypervisor at the time of asynchronous page fault (APF)
@@ -184,4 +185,3 @@ MSR_KVM_ASYNC_PF_EN: 0x4b564d02
 
 	Currently type 2 APF will be always delivered on the same vcpu as
 	type 1 was, but guest should not rely on that.
-
diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index f1868ed..d2fa951 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -422,6 +422,7 @@ struct kvm_vcpu_arch {
 		struct gfn_to_hva_cache data;
 		u64 msr_val;
 		u32 id;
+		bool send_user_only;
 	} apf;
 };
 
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index fbfd367..d3a1a48 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -38,6 +38,7 @@
 #define KVM_MAX_MMU_OP_BATCH           32
 
 #define KVM_ASYNC_PF_ENABLED			(1 << 0)
+#define KVM_ASYNC_PF_SEND_ALWAYS		(1 << 1)
 
 /* Operations for KVM_HC_MMU_OP */
 #define KVM_MMU_OP_WRITE_PTE            1
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 47ea93e..91b3d65 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -449,6 +449,9 @@ void __cpuinit kvm_guest_cpu_init(void)
 	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF) && kvmapf) {
 		u64 pa = __pa(&__get_cpu_var(apf_reason));
 
+#ifdef CONFIG_PREEMPT
+		pa |= KVM_ASYNC_PF_SEND_ALWAYS;
+#endif
 		wrmsrl(MSR_KVM_ASYNC_PF_EN, pa | KVM_ASYNC_PF_ENABLED);
 		__get_cpu_var(apf_reason).enabled = 1;
 		printk(KERN_INFO"KVM setup async PF for cpu %d\n",
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 8e2fc59..1e442df 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -1435,8 +1435,8 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
 {
 	gpa_t gpa = data & ~0x3f;
 
-	/* Bits 1:5 are resrved, Should be zero */
-	if (data & 0x3e)
+	/* Bits 2:5 are resrved, Should be zero */
+	if (data & 0x3c)
 		return 1;
 
 	vcpu->arch.apf.msr_val = data;
@@ -1450,6 +1450,7 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
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
