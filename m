Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D1C876B007D
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 11:56:44 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v6 06/12] Add PV MSR to enable asynchronous page faults delivery.
Date: Mon,  4 Oct 2010 17:56:28 +0200
Message-Id: <1286207794-16120-7-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-1-git-send-email-gleb@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

Guest enables async PF vcpu functionality using this MSR.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 Documentation/kvm/cpuid.txt     |    3 +++
 Documentation/kvm/msr.txt       |   13 ++++++++++++-
 arch/x86/include/asm/kvm_host.h |    2 ++
 arch/x86/include/asm/kvm_para.h |    4 ++++
 arch/x86/kvm/x86.c              |   38 ++++++++++++++++++++++++++++++++++++--
 include/linux/kvm.h             |    1 +
 6 files changed, 58 insertions(+), 3 deletions(-)

diff --git a/Documentation/kvm/cpuid.txt b/Documentation/kvm/cpuid.txt
index 14a12ea..8820685 100644
--- a/Documentation/kvm/cpuid.txt
+++ b/Documentation/kvm/cpuid.txt
@@ -36,6 +36,9 @@ KVM_FEATURE_MMU_OP                 ||     2 || deprecated.
 KVM_FEATURE_CLOCKSOURCE2           ||     3 || kvmclock available at msrs
                                    ||       || 0x4b564d00 and 0x4b564d01
 ------------------------------------------------------------------------------
+KVM_FEATURE_ASYNC_PF               ||     4 || async pf can be enabled by
+                                   ||       || writing to msr 0x4b564d02
+------------------------------------------------------------------------------
 KVM_FEATURE_CLOCKSOURCE_STABLE_BIT ||    24 || host will warn if no guest-side
                                    ||       || per-cpu warps are expected in
                                    ||       || kvmclock.
diff --git a/Documentation/kvm/msr.txt b/Documentation/kvm/msr.txt
index 8ddcfe8..d64e723 100644
--- a/Documentation/kvm/msr.txt
+++ b/Documentation/kvm/msr.txt
@@ -3,7 +3,6 @@ Glauber Costa <glommer@redhat.com>, Red Hat Inc, 2010
 =====================================================
 
 KVM makes use of some custom MSRs to service some requests.
-At present, this facility is only used by kvmclock.
 
 Custom MSRs have a range reserved for them, that goes from
 0x4b564d00 to 0x4b564dff. There are MSRs outside this area,
@@ -151,3 +150,15 @@ MSR_KVM_SYSTEM_TIME: 0x12
 			return PRESENT;
 		} else
 			return NON_PRESENT;
+
+MSR_KVM_ASYNC_PF_EN: 0x4b564d02
+	data: Bits 63-6 hold 64-byte aligned physical address of a 32bit memory
+	area which must be in guest RAM. Bits 5-1 are reserved and should be
+	zero. Bit 0 is 1 when asynchronous page faults are enabled on the vcpu
+	0 when disabled.
+
+	Physical address points to 32 bit memory location that will be written
+	to by the hypervisor at the time of asynchronous page fault injection to
+	indicate type of asynchronous page fault. Value of 1 means that the page
+	referred to by the page fault is not present. Value 2 means that the
+	page is now available.
diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index b9f263e..de31551 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -417,6 +417,8 @@ struct kvm_vcpu_arch {
 
 	struct {
 		gfn_t gfns[roundup_pow_of_two(ASYNC_PF_PER_VCPU)];
+		struct gfn_to_hva_cache data;
+		u64 msr_val;
 	} apf;
 };
 
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index e3faaaf..8662ae0 100644
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
index 48fd59d..3e123ab 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -782,12 +782,12 @@ EXPORT_SYMBOL_GPL(kvm_get_dr);
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
 	MSR_STAR,
 #ifdef CONFIG_X86_64
@@ -1425,6 +1425,29 @@ static int set_msr_hyperv(struct kvm_vcpu *vcpu, u32 msr, u64 data)
 	return 0;
 }
 
+static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
+{
+	gpa_t gpa = data & ~0x3f;
+
+	/* Bits 1:5 are resrved, Should be zero */
+	if (data & 0x3e)
+		return 1;
+
+	vcpu->arch.apf.msr_val = data;
+
+	if (!(data & KVM_ASYNC_PF_ENABLED)) {
+		kvm_clear_async_pf_completion_queue(vcpu);
+		memset(vcpu->arch.apf.gfns, 0xff, sizeof vcpu->arch.apf.gfns);
+		return 0;
+	}
+
+	if (kvm_gfn_to_hva_cache_init(vcpu->kvm, &vcpu->arch.apf.data, gpa))
+		return 1;
+
+	kvm_async_pf_wakeup_all(vcpu);
+	return 0;
+}
+
 int kvm_set_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 data)
 {
 	switch (msr) {
@@ -1506,6 +1529,10 @@ int kvm_set_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 data)
 		}
 		break;
 	}
+	case MSR_KVM_ASYNC_PF_EN:
+		if (kvm_pv_enable_async_pf(vcpu, data))
+			return 1;
+		break;
 	case MSR_IA32_MCG_CTL:
 	case MSR_IA32_MCG_STATUS:
 	case MSR_IA32_MC0_CTL ... MSR_IA32_MC0_CTL + 4 * KVM_MAX_MCE_BANKS - 1:
@@ -1782,6 +1809,9 @@ int kvm_get_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 *pdata)
 	case MSR_KVM_SYSTEM_TIME_NEW:
 		data = vcpu->arch.time;
 		break;
+	case MSR_KVM_ASYNC_PF_EN:
+		data = vcpu->arch.apf.msr_val;
+		break;
 	case MSR_IA32_P5_MC_ADDR:
 	case MSR_IA32_P5_MC_TYPE:
 	case MSR_IA32_MCG_CAP:
@@ -1929,6 +1959,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 	case KVM_CAP_DEBUGREGS:
 	case KVM_CAP_X86_ROBUST_SINGLESTEP:
 	case KVM_CAP_XSAVE:
+	case KVM_CAP_ASYNC_PF:
 		r = 1;
 		break;
 	case KVM_CAP_COALESCED_MMIO:
@@ -5778,6 +5809,8 @@ free_vcpu:
 
 void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
 {
+	vcpu->arch.apf.msr_val = 0;
+
 	vcpu_load(vcpu);
 	kvm_mmu_unload(vcpu);
 	vcpu_put(vcpu);
@@ -5797,6 +5830,7 @@ int kvm_arch_vcpu_reset(struct kvm_vcpu *vcpu)
 	vcpu->arch.dr7 = DR7_FIXED_1;
 
 	kvm_make_request(KVM_REQ_EVENT, vcpu);
+	vcpu->arch.apf.msr_val = 0;
 
 	kvm_clear_async_pf_completion_queue(vcpu);
 	memset(vcpu->arch.apf.gfns, 0xff, sizeof vcpu->arch.apf.gfns);
diff --git a/include/linux/kvm.h b/include/linux/kvm.h
index 919ae53..ea2dc1a 100644
--- a/include/linux/kvm.h
+++ b/include/linux/kvm.h
@@ -540,6 +540,7 @@ struct kvm_ppc_pvinfo {
 #endif
 #define KVM_CAP_PPC_GET_PVINFO 57
 #define KVM_CAP_PPC_IRQ_LEVEL 58
+#define KVM_CAP_ASYNC_PF 59
 
 #ifdef KVM_CAP_IRQ_ROUTING
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
