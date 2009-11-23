Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 400366B007E
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:28 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 02/12] Add PV MSR to enable asynchronous page faults delivery.
Date: Mon, 23 Nov 2009 16:05:57 +0200
Message-Id: <1258985167-29178-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-1-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>


Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    3 ++
 arch/x86/include/asm/kvm_para.h |    2 +
 arch/x86/kvm/x86.c              |   42 +++++++++++++++++++++++++++++++++++++-
 include/linux/kvm.h             |    1 +
 4 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 06e0856..9598e85 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -374,6 +374,9 @@ struct kvm_vcpu_arch {
 	/* used for guest single stepping over the given code position */
 	u16 singlestep_cs;
 	unsigned long singlestep_rip;
+
+	u32 __user *apf_data;
+	u64 apf_msr_val;
 };
 
 struct kvm_mem_alias {
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index 5f580f2..222d5fd 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -15,9 +15,11 @@
 #define KVM_FEATURE_CLOCKSOURCE		0
 #define KVM_FEATURE_NOP_IO_DELAY	1
 #define KVM_FEATURE_MMU_OP		2
+#define KVM_FEATURE_ASYNC_PF		3
 
 #define MSR_KVM_WALL_CLOCK  0x11
 #define MSR_KVM_SYSTEM_TIME 0x12
+#define MSR_KVM_ASYNC_PF_EN 0x13
 
 #define KVM_MAX_MMU_OP_BATCH           32
 
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 35eea30..ce8e66d 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -566,9 +566,9 @@ static inline u32 bit(int bitno)
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
@@ -949,6 +949,26 @@ out:
 	return r;
 }
 
+static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
+{
+	u64 gpa = data & ~0x3f;
+	int offset = offset_in_page(gpa);
+	unsigned long addr;
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
@@ -1029,6 +1049,14 @@ int kvm_set_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 data)
 		kvm_request_guest_time_update(vcpu);
 		break;
 	}
+	case MSR_KVM_ASYNC_PF_EN:
+		vcpu->arch.apf_msr_val = data;
+		if (data & 1) {
+			if (kvm_pv_enable_async_pf(vcpu, data))
+				return 1;
+		} else
+			vcpu->arch.apf_data = NULL;
+		break;
 	case MSR_IA32_MCG_CTL:
 	case MSR_IA32_MCG_STATUS:
 	case MSR_IA32_MC0_CTL ... MSR_IA32_MC0_CTL + 4 * KVM_MAX_MCE_BANKS - 1:
@@ -1221,6 +1249,9 @@ int kvm_get_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 *pdata)
 	case MSR_KVM_SYSTEM_TIME:
 		data = vcpu->arch.time;
 		break;
+	case MSR_KVM_ASYNC_PF_EN:
+		data = vcpu->arch.apf_msr_val;
+		break;
 	case MSR_IA32_P5_MC_ADDR:
 	case MSR_IA32_P5_MC_TYPE:
 	case MSR_IA32_MCG_CAP:
@@ -1343,6 +1374,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 	case KVM_CAP_XEN_HVM:
 	case KVM_CAP_ADJUST_CLOCK:
 	case KVM_CAP_VCPU_EVENTS:
+	case KVM_CAP_ASYNC_PF:
 		r = 1;
 		break;
 	case KVM_CAP_COALESCED_MMIO:
@@ -4965,6 +4997,9 @@ free_vcpu:
 
 void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
 {
+	vcpu->arch.apf_data = NULL;
+	vcpu->arch.apf_msr_val = 0;
+
 	vcpu_load(vcpu);
 	kvm_mmu_unload(vcpu);
 	vcpu_put(vcpu);
@@ -4982,6 +5017,9 @@ int kvm_arch_vcpu_reset(struct kvm_vcpu *vcpu)
 	vcpu->arch.dr6 = DR6_FIXED_1;
 	vcpu->arch.dr7 = DR7_FIXED_1;
 
+	vcpu->arch.apf_data = NULL;
+	vcpu->arch.apf_msr_val = 0;
+
 	return kvm_x86_ops->vcpu_reset(vcpu);
 }
 
diff --git a/include/linux/kvm.h b/include/linux/kvm.h
index 92045a9..6af1c99 100644
--- a/include/linux/kvm.h
+++ b/include/linux/kvm.h
@@ -492,6 +492,7 @@ struct kvm_ioeventfd {
 #ifdef __KVM_HAVE_VCPU_EVENTS
 #define KVM_CAP_VCPU_EVENTS 41
 #endif
+#define KVM_CAP_ASYNC_PF 42
 
 #ifdef KVM_CAP_IRQ_ROUTING
 
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
