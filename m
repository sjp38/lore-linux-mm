Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EAF086B0254
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 12:25:18 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v4 02/12] Add PV MSR to enable asynchronous page faults delivery.
Date: Tue,  6 Jul 2010 19:24:50 +0300
Message-Id: <1278433500-29884-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-1-git-send-email-gleb@redhat.com>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>


Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    3 ++
 arch/x86/include/asm/kvm_para.h |    4 +++
 arch/x86/kvm/x86.c              |   49 +++++++++++++++++++++++++++++++++++++-
 include/linux/kvm.h             |    1 +
 4 files changed, 55 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 502e53f..245831a 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -364,6 +364,9 @@ struct kvm_vcpu_arch {
 	u64 hv_vapic;
 
 	cpumask_var_t wbinvd_dirty_mask;
+
+	u32 __user *apf_data;
+	u64 apf_msr_val;
 };
 
 struct kvm_arch {
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index 42298ab..5b05e9f 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -20,6 +20,7 @@
  * are available. The use of 0x11 and 0x12 is deprecated
  */
 #define KVM_FEATURE_CLOCKSOURCE2        3
+#define KVM_FEATURE_ASYNC_PF		4
 
 /* The last 8 bits are used to indicate how to interpret the flags field
  * in pvclock structure. If no bits are set, all flags are ignored.
@@ -32,9 +33,12 @@
 /* Custom MSRs falls in the range 0x4b564d00-0x4b564dff */
 #define MSR_KVM_WALL_CLOCK_NEW  0x4b564d00
 #define MSR_KVM_SYSTEM_TIME_NEW 0x4b564d01
+#define MSR_KVM_ASYNC_PF_EN 0x4b564d02
 
 #define KVM_MAX_MMU_OP_BATCH           32
 
+#define KVM_ASYNC_PF_ENABLED			(1 << 0)
+
 /* Operations for KVM_HC_MMU_OP */
 #define KVM_MMU_OP_WRITE_PTE            1
 #define KVM_MMU_OP_FLUSH_TLB	        2
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 7070b41..744f8c1 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -726,12 +726,12 @@ EXPORT_SYMBOL_GPL(kvm_get_dr);
  * kvm-specific. Those are put in the beginning of the list.
  */
 
-#define KVM_SAVE_MSRS_BEGIN	7
+#define KVM_SAVE_MSRS_BEGIN	8
 static u32 msrs_to_save[] = {
 	MSR_KVM_SYSTEM_TIME, MSR_KVM_WALL_CLOCK,
 	MSR_KVM_SYSTEM_TIME_NEW, MSR_KVM_WALL_CLOCK_NEW,
 	HV_X64_MSR_GUEST_OS_ID, HV_X64_MSR_HYPERCALL,
-	HV_X64_MSR_APIC_ASSIST_PAGE,
+	HV_X64_MSR_APIC_ASSIST_PAGE, MSR_KVM_ASYNC_PF_EN,
 	MSR_IA32_SYSENTER_CS, MSR_IA32_SYSENTER_ESP, MSR_IA32_SYSENTER_EIP,
 	MSR_K6_STAR,
 #ifdef CONFIG_X86_64
@@ -1212,6 +1212,37 @@ static int set_msr_hyperv(struct kvm_vcpu *vcpu, u32 msr, u64 data)
 	return 0;
 }
 
+static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
+{
+	u64 gpa = data & ~0x3f;
+	int offset = offset_in_page(gpa);
+	unsigned long addr;
+
+	/* Bits 1:5 are resrved, Should be zero */
+	if (data & 0x3e)
+		return 1;
+
+	vcpu->arch.apf_msr_val = data;
+
+	if (!(data & KVM_ASYNC_PF_ENABLED)) {
+		vcpu->arch.apf_data = NULL;
+		return 0;
+	}
+
+	addr = gfn_to_hva(vcpu->kvm, gpa >> PAGE_SHIFT);
+	if (kvm_is_error_hva(addr))
+		return 1;
+
+	vcpu->arch.apf_data = (u32 __user*)(addr + offset);
+
+	/* check if address is mapped */
+	if (get_user(offset, vcpu->arch.apf_data)) {
+		vcpu->arch.apf_data = NULL;
+		return 1;
+	}
+	return 0;
+}
+
 int kvm_set_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 data)
 {
 	switch (msr) {
@@ -1294,6 +1325,10 @@ int kvm_set_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 data)
 		kvm_request_guest_time_update(vcpu);
 		break;
 	}
+	case MSR_KVM_ASYNC_PF_EN:
+		if (kvm_pv_enable_async_pf(vcpu, data))
+			return 1;
+		break;
 	case MSR_IA32_MCG_CTL:
 	case MSR_IA32_MCG_STATUS:
 	case MSR_IA32_MC0_CTL ... MSR_IA32_MC0_CTL + 4 * KVM_MAX_MCE_BANKS - 1:
@@ -1546,6 +1581,9 @@ int kvm_get_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 *pdata)
 	case MSR_KVM_SYSTEM_TIME_NEW:
 		data = vcpu->arch.time;
 		break;
+	case MSR_KVM_ASYNC_PF_EN:
+		data = vcpu->arch.apf_msr_val;
+		break;
 	case MSR_IA32_P5_MC_ADDR:
 	case MSR_IA32_P5_MC_TYPE:
 	case MSR_IA32_MCG_CAP:
@@ -1681,6 +1719,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 	case KVM_CAP_DEBUGREGS:
 	case KVM_CAP_X86_ROBUST_SINGLESTEP:
 	case KVM_CAP_XSAVE:
+	case KVM_CAP_ASYNC_PF:
 		r = 1;
 		break;
 	case KVM_CAP_COALESCED_MMIO:
@@ -5330,6 +5369,9 @@ free_vcpu:
 
 void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
 {
+	vcpu->arch.apf_data = NULL;
+	vcpu->arch.apf_msr_val = 0;
+
 	vcpu_load(vcpu);
 	kvm_mmu_unload(vcpu);
 	vcpu_put(vcpu);
@@ -5348,6 +5390,9 @@ int kvm_arch_vcpu_reset(struct kvm_vcpu *vcpu)
 	vcpu->arch.dr6 = DR6_FIXED_1;
 	vcpu->arch.dr7 = DR7_FIXED_1;
 
+	vcpu->arch.apf_data = NULL;
+	vcpu->arch.apf_msr_val = 0;
+
 	return kvm_x86_ops->vcpu_reset(vcpu);
 }
 
diff --git a/include/linux/kvm.h b/include/linux/kvm.h
index 636fc38..bab7ef0 100644
--- a/include/linux/kvm.h
+++ b/include/linux/kvm.h
@@ -530,6 +530,7 @@ struct kvm_enable_cap {
 #ifdef __KVM_HAVE_XCRS
 #define KVM_CAP_XCRS 56
 #endif
+#define KVM_CAP_ASYNC_PF 57
 
 #ifdef KVM_CAP_IRQ_ROUTING
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
