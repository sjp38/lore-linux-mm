Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA00E6B04A3
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 17:54:04 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id s24-v6so14471853plp.12
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 14:54:04 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t132sor9273688pgc.85.2018.11.06.14.54.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 14:54:03 -0800 (PST)
Date: Tue,  6 Nov 2018 14:53:55 -0800
In-Reply-To: <20181106225356.119901-1-marcorr@google.com>
Message-Id: <20181106225356.119901-2-marcorr@google.com>
Mime-Version: 1.0
References: <20181106225356.119901-1-marcorr@google.com>
Subject: [kvm PATCH v8 1/2] kvm: x86: Use task structs fpu field for user
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com
Cc: Marc Orr <marcorr@google.com>, Dave Hansen <dave.hansen@intel.com>

Previously, x86's instantiation of 'struct kvm_vcpu_arch' added an fpu
field to save/restore fpu-related architectural state, which will differ
from kvm's fpu state. However, this is redundant to the 'struct fpu'
field, called fpu, embedded in the task struct, via the thread field.
Thus, this patch removes the user_fpu field from the kvm_vcpu_arch
struct and replaces it with the task struct's fpu field.

This change is significant because the fpu struct is actually quite
large. For example, on the system used to develop this patch, this
change reduces the size of the vcpu_vmx struct from 23680 bytes down to
19520 bytes, when building the kernel with kvmconfig. This reduction in
the size of the vcpu_vmx struct moves us closer to being able to
allocate the struct at order 2, rather than order 3.

Suggested-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Marc Orr <marcorr@google.com>
---
 arch/x86/include/asm/kvm_host.h | 7 +++----
 arch/x86/kvm/x86.c              | 4 ++--
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 55e51ff7e421..ebb1d7a755d4 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -601,16 +601,15 @@ struct kvm_vcpu_arch {
 
 	/*
 	 * QEMU userspace and the guest each have their own FPU state.
-	 * In vcpu_run, we switch between the user and guest FPU contexts.
-	 * While running a VCPU, the VCPU thread will have the guest FPU
-	 * context.
+	 * In vcpu_run, we switch between the user, maintained in the
+	 * task_struct struct, and guest FPU contexts. While running a VCPU,
+	 * the VCPU thread will have the guest FPU context.
 	 *
 	 * Note that while the PKRU state lives inside the fpu registers,
 	 * it is switched out separately at VMENTER and VMEXIT time. The
 	 * "guest_fpu" state here contains the guest FPU context, with the
 	 * host PRKU bits.
 	 */
-	struct fpu user_fpu;
 	struct fpu guest_fpu;
 
 	u64 xcr0;
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index bdcb5babfb68..ff77514f7367 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7999,7 +7999,7 @@ static int complete_emulated_mmio(struct kvm_vcpu *vcpu)
 static void kvm_load_guest_fpu(struct kvm_vcpu *vcpu)
 {
 	preempt_disable();
-	copy_fpregs_to_fpstate(&vcpu->arch.user_fpu);
+	copy_fpregs_to_fpstate(&current->thread.fpu);
 	/* PKRU is separately restored in kvm_x86_ops->run.  */
 	__copy_kernel_to_fpregs(&vcpu->arch.guest_fpu.state,
 				~XFEATURE_MASK_PKRU);
@@ -8012,7 +8012,7 @@ static void kvm_put_guest_fpu(struct kvm_vcpu *vcpu)
 {
 	preempt_disable();
 	copy_fpregs_to_fpstate(&vcpu->arch.guest_fpu);
-	copy_kernel_to_fpregs(&vcpu->arch.user_fpu.state);
+	copy_kernel_to_fpregs(&current->thread.fpu.state);
 	preempt_enable();
 	++vcpu->stat.fpu_reload;
 	trace_kvm_fpu(0);
-- 
2.19.1.930.g4563a0d9d0-goog
