Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1036B03AD
	for <linux-mm@kvack.org>; Sun,  7 May 2017 08:39:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 191so42984727pfb.8
        for <linux-mm@kvack.org>; Sun, 07 May 2017 05:39:35 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id t26si7020485pgo.414.2017.05.07.05.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 05:39:34 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 10/10] x86,kvm: Teach KVM's VMX code that CR3 isn't a constant
Date: Sun,  7 May 2017 05:38:39 -0700
Message-Id: <59ea83a0a78025439e3d15e09b693846fa1f4770.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

When PCID is enabled, CR3's PCID bits can change during context
switches, so KVM won't be able to treat CR3 as a per-mm constant any
more.

I structured this like the existing CR4 handling.  Under ordinary
circumstances (PCID disabled or if the current PCID and the value
that's already in the VMCS match), then we won't do an extra VMCS
write, and we'll never do an extra direct CR3 read.  The overhead
should be minimal.

I disallowed using the new helper in non-atomic context because
PCID support will cause CR3 to stop being constant in non-atomic
process context.

(Frankly, it also scares me a bit that KVM ever treated CR3 as
constant, but it looks like it was okay before.)

Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: kvm@vger.kernel.org
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/mmu_context.h | 19 +++++++++++++++++++
 arch/x86/kvm/vmx.c                 | 21 ++++++++++++++++++---
 2 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 187c39470a0b..f20d7ea47095 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -266,4 +266,23 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	return __pkru_allows_pkey(vma_pkey(vma), write);
 }
 
+
+/*
+ * This can be used from process context to figure out what the value of
+ * CR3 is without needing to do a (slow) read_cr3().
+ *
+ * It's intended to be used for code like KVM that sneakily changes CR3
+ * and needs to restore it.  It needs to be used very carefully.
+ */
+static inline unsigned long __get_current_cr3_fast(void)
+{
+	unsigned long cr3 = __pa(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd);
+
+	/* For now, be very restrictive about when this can be called. */
+	VM_WARN_ON(in_nmi() || !in_atomic());
+
+	VM_BUG_ON(cr3 != read_cr3());
+	return cr3;
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 535cc065b844..2771235072aa 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -48,6 +48,7 @@
 #include <asm/kexec.h>
 #include <asm/apic.h>
 #include <asm/irq_remapping.h>
+#include <asm/mmu_context.h>
 
 #include "trace.h"
 #include "pmu.h"
@@ -596,6 +597,7 @@ struct vcpu_vmx {
 		int           gs_ldt_reload_needed;
 		int           fs_reload_needed;
 		u64           msr_host_bndcfgs;
+		unsigned long vmcs_host_cr3;	/* May not match real cr3 */
 		unsigned long vmcs_host_cr4;	/* May not match real cr4 */
 	} host_state;
 	struct {
@@ -5017,12 +5019,19 @@ static void vmx_set_constant_host_state(struct vcpu_vmx *vmx)
 	u32 low32, high32;
 	unsigned long tmpl;
 	struct desc_ptr dt;
-	unsigned long cr0, cr4;
+	unsigned long cr0, cr3, cr4;
 
 	cr0 = read_cr0();
 	WARN_ON(cr0 & X86_CR0_TS);
 	vmcs_writel(HOST_CR0, cr0);  /* 22.2.3 */
-	vmcs_writel(HOST_CR3, read_cr3());  /* 22.2.3  FIXME: shadow tables */
+
+	/*
+	 * Save the most likely value for this task's CR3 in the VMCS.
+	 * We can't use __get_current_cr3_fast() because we're not atomic.
+	 */
+	cr3 = read_cr3();
+	vmcs_writel(HOST_CR3, cr3);		/* 22.2.3  FIXME: shadow tables */
+	vmx->host_state.vmcs_host_cr3 = cr3;
 
 	/* Save the most likely value for this task's CR4 in the VMCS. */
 	cr4 = cr4_read_shadow();
@@ -8927,7 +8936,7 @@ static void vmx_arm_hv_timer(struct kvm_vcpu *vcpu)
 static void __noclone vmx_vcpu_run(struct kvm_vcpu *vcpu)
 {
 	struct vcpu_vmx *vmx = to_vmx(vcpu);
-	unsigned long debugctlmsr, cr4;
+	unsigned long debugctlmsr, cr3, cr4;
 
 	/* Record the guest's net vcpu time for enforced NMI injections. */
 	if (unlikely(!cpu_has_virtual_nmis() && vmx->soft_vnmi_blocked))
@@ -8953,6 +8962,12 @@ static void __noclone vmx_vcpu_run(struct kvm_vcpu *vcpu)
 	if (test_bit(VCPU_REGS_RIP, (unsigned long *)&vcpu->arch.regs_dirty))
 		vmcs_writel(GUEST_RIP, vcpu->arch.regs[VCPU_REGS_RIP]);
 
+	cr3 = __get_current_cr3_fast();
+	if (unlikely(cr3 != vmx->host_state.vmcs_host_cr3)) {
+		vmcs_writel(HOST_CR3, cr3);
+		vmx->host_state.vmcs_host_cr3 = cr3;
+	}
+
 	cr4 = cr4_read_shadow();
 	if (unlikely(cr4 != vmx->host_state.vmcs_host_cr4)) {
 		vmcs_writel(HOST_CR4, cr4);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
