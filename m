Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5DDB56007D6
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:13:22 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v3 02/12] Add PV MSR to enable asynchronous page faults delivery.
Date: Tue,  5 Jan 2010 16:12:44 +0200
Message-Id: <1262700774-1808-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1262700774-1808-1-git-send-email-gleb@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>


Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    3 ++
 arch/x86/include/asm/kvm_para.h |    4 +++
 arch/x86/kvm/x86.c              |   49 +++++++++++++++++++++++++++++++++++++-
 include/linux/kvm.h             |    1 +
 4 files changed, 55 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 741b897..01d3ec4 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -362,6 +362,9 @@ struct kvm_vcpu_arch {
 	/* used for guest single stepping over the given code position */
 	u16 singlestep_cs;
 	unsigned long singlestep_rip;
+
+	u32 __user *apf_data;
+	u64 apf_msr_val;
 };
 
 struct kvm_mem_alias {
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index 5f580f2..f77eed3 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -15,12 +15,16 @@
 #define KVM_FEATURE_CLOCKSOURCE		0
 #define KVM_FEATURE_NOP_IO_DELAY	1
 #define KVM_FEATURE_MMU_OP		2
+#define KVM_FEATURE_ASYNC_PF		3
 
 #define MSR_KVM_WALL_CLOCK  0x11
 #define MSR_KVM_SYSTEM_TIME 0x12
+#define MSR_KVM_ASYNC_PF_EN 0x4b564d00
 
 #define KVM_MAX_MMU_OP_BATCH           32
 
+#define KVM_ASYNC_PF_ENABLED			(1 << 0)
+
 /* Operations for KVM_HC_MMU_OP */
 #define KVM_MMU_OP_WRITE_PTE            1
 #define KVM_MMU_OP_FLUSH_TLB	        2
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index adc8597..f6821b9 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -620,9 +620,9 @@ static inline u32 bit(int bitno)
  * kvm-specific. Those are put in the beginning of the list.
  */
 
-#define KVM_SAVE_MSRS_BEGIN	2
+#define KVM_SAVE_MSRS_BEGIN	3
 static u32 msrs_to_save[] = {
-	MSR_KVM_SYSTEM_TIME, MSR_KVM_WALL_CLOCK,
+	MSR_KVM_SYSTEM_TIME, MSR_KVM_WALL_CLOCK, MSR_KVM_ASYNC_PF_EN,
 	MSR_IA32_SYSENTER_CS, MSR_IA32_SYSENTER_ESP, MSR_IA32_SYSENTER_EIP,
 	MSR_K6_STAR,
 #ifdef CONFIG_X86_64
@@ -1003,6 +1003,37 @@ out:
 	return r;
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
@@ -1083,6 +1114,10 @@ int kvm_set_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 data)
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
@@ -1275,6 +1310,9 @@ int kvm_get_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 *pdata)
 	case MSR_KVM_SYSTEM_TIME:
 		data = vcpu->arch.time;
 		break;
+	case MSR_KVM_ASYNC_PF_EN:
+		data = vcpu->arch.apf_msr_val;
+		break;
 	case MSR_IA32_P5_MC_ADDR:
 	case MSR_IA32_P5_MC_TYPE:
 	case MSR_IA32_MCG_CAP:
@@ -1397,6 +1435,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 	case KVM_CAP_XEN_HVM:
 	case KVM_CAP_ADJUST_CLOCK:
 	case KVM_CAP_VCPU_EVENTS:
+	case KVM_CAP_ASYNC_PF:
 		r = 1;
 		break;
 	case KVM_CAP_COALESCED_MMIO:
@@ -5117,6 +5156,9 @@ free_vcpu:
 
 void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
 {
+	vcpu->arch.apf_data = NULL;
+	vcpu->arch.apf_msr_val = 0;
+
 	vcpu_load(vcpu);
 	kvm_mmu_unload(vcpu);
 	vcpu_put(vcpu);
@@ -5134,6 +5176,9 @@ int kvm_arch_vcpu_reset(struct kvm_vcpu *vcpu)
 	vcpu->arch.dr6 = DR6_FIXED_1;
 	vcpu->arch.dr7 = DR7_FIXED_1;
 
+	vcpu->arch.apf_data = NULL;
+	vcpu->arch.apf_msr_val = 0;
+
 	return kvm_x86_ops->vcpu_reset(vcpu);
 }
 
diff --git a/include/linux/kvm.h b/include/linux/kvm.h
index f2feef6..85a7161 100644
--- a/include/linux/kvm.h
+++ b/include/linux/kvm.h
@@ -497,6 +497,7 @@ struct kvm_ioeventfd {
 #endif
 #define KVM_CAP_S390_PSW 42
 #define KVM_CAP_PPC_SEGSTATE 43
+#define KVM_CAP_ASYNC_PF 44
 
 #ifdef KVM_CAP_IRQ_ROUTING
 
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
