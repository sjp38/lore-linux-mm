Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7786B03A9
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:16:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 1so94389184pgz.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:16:13 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0049.outbound.protection.outlook.com. [104.47.41.49])
        by mx.google.com with ESMTPS id b5si7683669ple.195.2017.03.02.07.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:16:12 -0800 (PST)
Subject: [RFC PATCH v2 18/32] kvm: svm: Use the hardware provided GPA
 instead of page walk
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:16:05 -0500
Message-ID: <148846776540.2349.3123530065053870721.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

When a guest causes a NPF which requires emulation, KVM sometimes walks
the guest page tables to translate the GVA to a GPA. This is unnecessary
most of the time on AMD hardware since the hardware provides the GPA in
EXITINFO2.

The only exception cases involve string operations involving rep or
operations that use two memory locations. With rep, the GPA will only be
the value of the initial NPF and with dual memory locations we won't know
which memory address was translated into EXITINFO2.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/include/asm/kvm_emulate.h |    1 +
 arch/x86/include/asm/kvm_host.h    |    3 ++
 arch/x86/kvm/emulate.c             |   20 +++++++++++++---
 arch/x86/kvm/svm.c                 |    2 ++
 arch/x86/kvm/x86.c                 |   45 ++++++++++++++++++++++++++++--------
 5 files changed, 57 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/kvm_emulate.h b/arch/x86/include/asm/kvm_emulate.h
index e9cd7be..3e8c287 100644
--- a/arch/x86/include/asm/kvm_emulate.h
+++ b/arch/x86/include/asm/kvm_emulate.h
@@ -441,5 +441,6 @@ int emulator_task_switch(struct x86_emulate_ctxt *ctxt,
 int emulate_int_real(struct x86_emulate_ctxt *ctxt, int irq);
 void emulator_invalidate_register_cache(struct x86_emulate_ctxt *ctxt);
 void emulator_writeback_register_cache(struct x86_emulate_ctxt *ctxt);
+bool emulator_can_use_gpa(struct x86_emulate_ctxt *ctxt);
 
 #endif /* _ASM_X86_KVM_X86_EMULATE_H */
diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 37326b5..bff1f15 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -668,6 +668,9 @@ struct kvm_vcpu_arch {
 
 	int pending_ioapic_eoi;
 	int pending_external_vector;
+
+	/* GPA available (AMD only) */
+	bool gpa_available;
 };
 
 struct kvm_lpage_info {
diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index cedbba0..45c7306 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -173,6 +173,7 @@
 #define NearBranch  ((u64)1 << 52)  /* Near branches */
 #define No16	    ((u64)1 << 53)  /* No 16 bit operand */
 #define IncSP       ((u64)1 << 54)  /* SP is incremented before ModRM calc */
+#define TwoMemOp    ((u64)1 << 55)  /* Instruction has two memory operand */
 
 #define DstXacc     (DstAccLo | SrcAccHi | SrcWrite)
 
@@ -4298,7 +4299,7 @@ static const struct opcode group1[] = {
 };
 
 static const struct opcode group1A[] = {
-	I(DstMem | SrcNone | Mov | Stack | IncSP, em_pop), N, N, N, N, N, N, N,
+	I(DstMem | SrcNone | Mov | Stack | IncSP | TwoMemOp, em_pop), N, N, N, N, N, N, N,
 };
 
 static const struct opcode group2[] = {
@@ -4336,7 +4337,7 @@ static const struct opcode group5[] = {
 	I(SrcMemFAddr | ImplicitOps,		em_call_far),
 	I(SrcMem | NearBranch,			em_jmp_abs),
 	I(SrcMemFAddr | ImplicitOps,		em_jmp_far),
-	I(SrcMem | Stack,			em_push), D(Undefined),
+	I(SrcMem | Stack | TwoMemOp,		em_push), D(Undefined),
 };
 
 static const struct opcode group6[] = {
@@ -4556,8 +4557,8 @@ static const struct opcode opcode_table[256] = {
 	/* 0xA0 - 0xA7 */
 	I2bv(DstAcc | SrcMem | Mov | MemAbs, em_mov),
 	I2bv(DstMem | SrcAcc | Mov | MemAbs | PageTable, em_mov),
-	I2bv(SrcSI | DstDI | Mov | String, em_mov),
-	F2bv(SrcSI | DstDI | String | NoWrite, em_cmp_r),
+	I2bv(SrcSI | DstDI | Mov | String | TwoMemOp, em_mov),
+	F2bv(SrcSI | DstDI | String | NoWrite | TwoMemOp, em_cmp_r),
 	/* 0xA8 - 0xAF */
 	F2bv(DstAcc | SrcImm | NoWrite, em_test),
 	I2bv(SrcAcc | DstDI | Mov | String, em_mov),
@@ -5671,3 +5672,14 @@ void emulator_writeback_register_cache(struct x86_emulate_ctxt *ctxt)
 {
 	writeback_registers(ctxt);
 }
+
+bool emulator_can_use_gpa(struct x86_emulate_ctxt *ctxt)
+{
+	if (ctxt->rep_prefix && (ctxt->d & String))
+		return false;
+
+	if (ctxt->d & TwoMemOp)
+		return false;
+
+	return true;
+}
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 36d61ff..b581499 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -4184,6 +4184,8 @@ static int handle_exit(struct kvm_vcpu *vcpu)
 
 	trace_kvm_exit(exit_code, vcpu, KVM_ISA_SVM);
 
+	vcpu->arch.gpa_available = (exit_code == SVM_EXIT_NPF);
+
 	if (!is_cr_intercept(svm, INTERCEPT_CR0_WRITE))
 		vcpu->arch.cr0 = svm->vmcb->save.cr0;
 	if (npt_enabled)
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 9e6a593..2099df8 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -4465,6 +4465,21 @@ int kvm_write_guest_virt_system(struct x86_emulate_ctxt *ctxt,
 }
 EXPORT_SYMBOL_GPL(kvm_write_guest_virt_system);
 
+static int vcpu_is_mmio_gpa(struct kvm_vcpu *vcpu, unsigned long gva,
+			    gpa_t gpa, bool write)
+{
+	/* For APIC access vmexit */
+	if ((gpa & PAGE_MASK) == APIC_DEFAULT_PHYS_BASE)
+		return 1;
+
+	if (vcpu_match_mmio_gpa(vcpu, gpa)) {
+		trace_vcpu_match_mmio(gva, gpa, write, true);
+		return 1;
+	}
+
+	return 0;
+}
+
 static int vcpu_mmio_gva_to_gpa(struct kvm_vcpu *vcpu, unsigned long gva,
 				gpa_t *gpa, struct x86_exception *exception,
 				bool write)
@@ -4491,16 +4506,7 @@ static int vcpu_mmio_gva_to_gpa(struct kvm_vcpu *vcpu, unsigned long gva,
 	if (*gpa == UNMAPPED_GVA)
 		return -1;
 
-	/* For APIC access vmexit */
-	if ((*gpa & PAGE_MASK) == APIC_DEFAULT_PHYS_BASE)
-		return 1;
-
-	if (vcpu_match_mmio_gpa(vcpu, *gpa)) {
-		trace_vcpu_match_mmio(gva, *gpa, write, true);
-		return 1;
-	}
-
-	return 0;
+	return vcpu_is_mmio_gpa(vcpu, gva, *gpa, write);
 }
 
 int emulator_write_phys(struct kvm_vcpu *vcpu, gpa_t gpa,
@@ -4597,6 +4603,22 @@ static int emulator_read_write_onepage(unsigned long addr, void *val,
 	int handled, ret;
 	bool write = ops->write;
 	struct kvm_mmio_fragment *frag;
+	struct x86_emulate_ctxt *ctxt = &vcpu->arch.emulate_ctxt;
+
+	/*
+	 * If the exit was due to a NPF we may already have a GPA.
+	 * If the GPA is present, use it to avoid the GVA to GPA table walk.
+	 * Note, this cannot be used on string operations since string
+	 * operation using rep will only have the initial GPA from the NPF
+	 * occurred.
+	 */
+	if (vcpu->arch.gpa_available &&
+	    emulator_can_use_gpa(ctxt) &&
+	    vcpu_is_mmio_gpa(vcpu, addr, exception->address, write) &&
+	    (addr & ~PAGE_MASK) == (exception->address & ~PAGE_MASK)) {
+		gpa = exception->address;
+		goto mmio;
+	}
 
 	ret = vcpu_mmio_gva_to_gpa(vcpu, addr, &gpa, exception, write);
 
@@ -5613,6 +5635,9 @@ int x86_emulate_instruction(struct kvm_vcpu *vcpu,
 	}
 
 restart:
+	/* Save the faulting GPA (cr2) in the address field */
+	ctxt->exception.address = cr2;
+
 	r = x86_emulate_insn(ctxt);
 
 	if (r == EMULATION_INTERCEPTED)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
