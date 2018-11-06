Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8D66B049B
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 17:20:28 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id h17so2089721qto.4
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 14:20:28 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id s63-v6sor23561356qkd.108.2018.11.06.14.20.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 14:20:27 -0800 (PST)
Date: Tue,  6 Nov 2018 14:20:09 -0800
In-Reply-To: <20181106222009.90833-1-marcorr@google.com>
Message-Id: <20181106222009.90833-3-marcorr@google.com>
Mime-Version: 1.0
References: <20181106222009.90833-1-marcorr@google.com>
Subject: [kvm PATCH v7 2/2] kvm: x86: Dynamically allocate guest_fpu
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com
Cc: Marc Orr <marcorr@google.com>, Dave Hansen <dave.hansen@intel.com>

Previously, the guest_fpu field was embedded in the kvm_vcpu_arch
struct. Unfortunately, the field is quite large, (e.g., 4352 bytes on my
current setup). This bloats the kvm_vcpu_arch struct for x86 into an
order 3 memory allocation, which can become a problem on overcommitted
machines. Thus, this patch moves the fpu state outside of the
kvm_vcpu_arch struct.

With this patch applied, the kvm_vcpu_arch struct is reduced to 15168
bytes for vmx on my setup when building the kernel with kvmconfig.

Suggested-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Marc Orr <marcorr@google.com>
---
 arch/x86/include/asm/kvm_host.h |  3 +-
 arch/x86/kvm/svm.c              | 10 +++++++
 arch/x86/kvm/vmx.c              | 10 +++++++
 arch/x86/kvm/x86.c              | 51 ++++++++++++++++++++++++---------
 4 files changed, 60 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index ebb1d7a755d4..c8a2a263f91f 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -610,7 +610,7 @@ struct kvm_vcpu_arch {
 	 * "guest_fpu" state here contains the guest FPU context, with the
 	 * host PRKU bits.
 	 */
-	struct fpu guest_fpu;
+	struct fpu *guest_fpu;
 
 	u64 xcr0;
 	u64 guest_supported_xcr0;
@@ -1194,6 +1194,7 @@ struct kvm_arch_async_pf {
 };
 
 extern struct kvm_x86_ops *kvm_x86_ops;
+extern struct kmem_cache *x86_fpu_cache;
 
 #define __KVM_HAVE_ARCH_VM_ALLOC
 static inline struct kvm *kvm_arch_alloc_vm(void)
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index f416f5c7f2ae..ac0c52ca22c6 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -2121,6 +2121,13 @@ static struct kvm_vcpu *svm_create_vcpu(struct kvm *kvm, unsigned int id)
 		goto out;
 	}
 
+	svm->vcpu.arch.guest_fpu = kmem_cache_zalloc(x86_fpu_cache, GFP_KERNEL);
+	if (!svm->vcpu.arch.guest_fpu) {
+		printk(KERN_ERR "kvm: failed to allocate vcpu's fpu\n");
+		err = -ENOMEM;
+		goto free_partial_svm;
+	}
+
 	err = kvm_vcpu_init(&svm->vcpu, kvm, id);
 	if (err)
 		goto free_svm;
@@ -2180,6 +2187,8 @@ static struct kvm_vcpu *svm_create_vcpu(struct kvm *kvm, unsigned int id)
 uninit:
 	kvm_vcpu_uninit(&svm->vcpu);
 free_svm:
+	kmem_cache_free(x86_fpu_cache, svm->vcpu.arch.guest_fpu);
+free_partial_svm:
 	kmem_cache_free(kvm_vcpu_cache, svm);
 out:
 	return ERR_PTR(err);
@@ -2194,6 +2203,7 @@ static void svm_free_vcpu(struct kvm_vcpu *vcpu)
 	__free_page(virt_to_page(svm->nested.hsave));
 	__free_pages(virt_to_page(svm->nested.msrpm), MSRPM_ALLOC_ORDER);
 	kvm_vcpu_uninit(vcpu);
+	kmem_cache_free(x86_fpu_cache, svm->vcpu.arch.guest_fpu);
 	kmem_cache_free(kvm_vcpu_cache, svm);
 	/*
 	 * The vmcb page can be recycled, causing a false negative in
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index abeeb45d1c33..4078cf15a4b0 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -11476,6 +11476,7 @@ static void vmx_free_vcpu(struct kvm_vcpu *vcpu)
 	free_loaded_vmcs(vmx->loaded_vmcs);
 	kfree(vmx->guest_msrs);
 	kvm_vcpu_uninit(vcpu);
+	kmem_cache_free(x86_fpu_cache, vmx->vcpu.arch.guest_fpu);
 	kmem_cache_free(kvm_vcpu_cache, vmx);
 }
 
@@ -11489,6 +11490,13 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
 	if (!vmx)
 		return ERR_PTR(-ENOMEM);
 
+	vmx->vcpu.arch.guest_fpu = kmem_cache_zalloc(x86_fpu_cache, GFP_KERNEL);
+	if (!vmx->vcpu.arch.guest_fpu) {
+		printk(KERN_ERR "kvm: failed to allocate vcpu's fpu\n");
+		err = -ENOMEM;
+		goto free_partial_vcpu;
+	}
+
 	vmx->vpid = allocate_vpid();
 
 	err = kvm_vcpu_init(&vmx->vcpu, kvm, id);
@@ -11576,6 +11584,8 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
 	kvm_vcpu_uninit(&vmx->vcpu);
 free_vcpu:
 	free_vpid(vmx->vpid);
+	kmem_cache_free(x86_fpu_cache, vmx->vcpu.arch.guest_fpu);
+free_partial_vcpu:
 	kmem_cache_free(kvm_vcpu_cache, vmx);
 	return ERR_PTR(err);
 }
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index ff77514f7367..8abe058f48d9 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -213,6 +213,9 @@ struct kvm_stats_debugfs_item debugfs_entries[] = {
 
 u64 __read_mostly host_xcr0;
 
+struct kmem_cache *x86_fpu_cache;
+EXPORT_SYMBOL_GPL(x86_fpu_cache);
+
 static int emulator_fix_hypercall(struct x86_emulate_ctxt *ctxt);
 
 static inline void kvm_async_pf_hash_reset(struct kvm_vcpu *vcpu)
@@ -3635,7 +3638,7 @@ static int kvm_vcpu_ioctl_x86_set_debugregs(struct kvm_vcpu *vcpu,
 
 static void fill_xsave(u8 *dest, struct kvm_vcpu *vcpu)
 {
-	struct xregs_state *xsave = &vcpu->arch.guest_fpu.state.xsave;
+	struct xregs_state *xsave = &vcpu->arch.guest_fpu->state.xsave;
 	u64 xstate_bv = xsave->header.xfeatures;
 	u64 valid;
 
@@ -3677,7 +3680,7 @@ static void fill_xsave(u8 *dest, struct kvm_vcpu *vcpu)
 
 static void load_xsave(struct kvm_vcpu *vcpu, u8 *src)
 {
-	struct xregs_state *xsave = &vcpu->arch.guest_fpu.state.xsave;
+	struct xregs_state *xsave = &vcpu->arch.guest_fpu->state.xsave;
 	u64 xstate_bv = *(u64 *)(src + XSAVE_HDR_OFFSET);
 	u64 valid;
 
@@ -3725,7 +3728,7 @@ static void kvm_vcpu_ioctl_x86_get_xsave(struct kvm_vcpu *vcpu,
 		fill_xsave((u8 *) guest_xsave->region, vcpu);
 	} else {
 		memcpy(guest_xsave->region,
-			&vcpu->arch.guest_fpu.state.fxsave,
+			&vcpu->arch.guest_fpu->state.fxsave,
 			sizeof(struct fxregs_state));
 		*(u64 *)&guest_xsave->region[XSAVE_HDR_OFFSET / sizeof(u32)] =
 			XFEATURE_MASK_FPSSE;
@@ -3755,7 +3758,7 @@ static int kvm_vcpu_ioctl_x86_set_xsave(struct kvm_vcpu *vcpu,
 		if (xstate_bv & ~XFEATURE_MASK_FPSSE ||
 			mxcsr & ~mxcsr_feature_mask)
 			return -EINVAL;
-		memcpy(&vcpu->arch.guest_fpu.state.fxsave,
+		memcpy(&vcpu->arch.guest_fpu->state.fxsave,
 			guest_xsave->region, sizeof(struct fxregs_state));
 	}
 	return 0;
@@ -6818,11 +6821,30 @@ int kvm_arch_init(void *opaque)
 		goto out;
 	}
 
+	if (!boot_cpu_has(X86_FEATURE_FPU) || !boot_cpu_has(X86_FEATURE_FXSR)) {
+		printk(KERN_ERR "kvm: inadequate fpu\n");
+		r = -EOPNOTSUPP;
+		goto out;
+	}
+
 	r = -ENOMEM;
+	x86_fpu_cache = kmem_cache_create_usercopy(
+				"x86_fpu",
+				fpu_kernel_xstate_size,
+				__alignof__(struct fpu),
+				SLAB_ACCOUNT,
+				offsetof(struct fpu, state),
+				fpu_kernel_xstate_size,
+				NULL);
+	if (!x86_fpu_cache) {
+		printk(KERN_ERR "kvm: failed to allocate cache for x86 fpu\n");
+		goto out;
+	}
+
 	shared_msrs = alloc_percpu(struct kvm_shared_msrs);
 	if (!shared_msrs) {
 		printk(KERN_ERR "kvm: failed to allocate percpu kvm_shared_msrs\n");
-		goto out;
+		goto out_free_x86_fpu_cache;
 	}
 
 	r = kvm_mmu_module_init();
@@ -6855,6 +6877,8 @@ int kvm_arch_init(void *opaque)
 
 out_free_percpu:
 	free_percpu(shared_msrs);
+out_free_x86_fpu_cache:
+	kmem_cache_destroy(x86_fpu_cache);
 out:
 	return r;
 }
@@ -6878,6 +6902,7 @@ void kvm_arch_exit(void)
 	kvm_x86_ops = NULL;
 	kvm_mmu_module_exit();
 	free_percpu(shared_msrs);
+	kmem_cache_destroy(x86_fpu_cache);
 }
 
 int kvm_vcpu_halt(struct kvm_vcpu *vcpu)
@@ -8001,7 +8026,7 @@ static void kvm_load_guest_fpu(struct kvm_vcpu *vcpu)
 	preempt_disable();
 	copy_fpregs_to_fpstate(&current->thread.fpu);
 	/* PKRU is separately restored in kvm_x86_ops->run.  */
-	__copy_kernel_to_fpregs(&vcpu->arch.guest_fpu.state,
+	__copy_kernel_to_fpregs(&vcpu->arch.guest_fpu->state,
 				~XFEATURE_MASK_PKRU);
 	preempt_enable();
 	trace_kvm_fpu(1);
@@ -8011,7 +8036,7 @@ static void kvm_load_guest_fpu(struct kvm_vcpu *vcpu)
 static void kvm_put_guest_fpu(struct kvm_vcpu *vcpu)
 {
 	preempt_disable();
-	copy_fpregs_to_fpstate(&vcpu->arch.guest_fpu);
+	copy_fpregs_to_fpstate(vcpu->arch.guest_fpu);
 	copy_kernel_to_fpregs(&current->thread.fpu.state);
 	preempt_enable();
 	++vcpu->stat.fpu_reload;
@@ -8506,7 +8531,7 @@ int kvm_arch_vcpu_ioctl_get_fpu(struct kvm_vcpu *vcpu, struct kvm_fpu *fpu)
 
 	vcpu_load(vcpu);
 
-	fxsave = &vcpu->arch.guest_fpu.state.fxsave;
+	fxsave = &vcpu->arch.guest_fpu->state.fxsave;
 	memcpy(fpu->fpr, fxsave->st_space, 128);
 	fpu->fcw = fxsave->cwd;
 	fpu->fsw = fxsave->swd;
@@ -8526,7 +8551,7 @@ int kvm_arch_vcpu_ioctl_set_fpu(struct kvm_vcpu *vcpu, struct kvm_fpu *fpu)
 
 	vcpu_load(vcpu);
 
-	fxsave = &vcpu->arch.guest_fpu.state.fxsave;
+	fxsave = &vcpu->arch.guest_fpu->state.fxsave;
 
 	memcpy(fxsave->st_space, fpu->fpr, 128);
 	fxsave->cwd = fpu->fcw;
@@ -8582,9 +8607,9 @@ static int sync_regs(struct kvm_vcpu *vcpu)
 
 static void fx_init(struct kvm_vcpu *vcpu)
 {
-	fpstate_init(&vcpu->arch.guest_fpu.state);
+	fpstate_init(&vcpu->arch.guest_fpu->state);
 	if (boot_cpu_has(X86_FEATURE_XSAVES))
-		vcpu->arch.guest_fpu.state.xsave.header.xcomp_bv =
+		vcpu->arch.guest_fpu->state.xsave.header.xcomp_bv =
 			host_xcr0 | XSTATE_COMPACTION_ENABLED;
 
 	/*
@@ -8708,11 +8733,11 @@ void kvm_vcpu_reset(struct kvm_vcpu *vcpu, bool init_event)
 		 */
 		if (init_event)
 			kvm_put_guest_fpu(vcpu);
-		mpx_state_buffer = get_xsave_addr(&vcpu->arch.guest_fpu.state.xsave,
+		mpx_state_buffer = get_xsave_addr(&vcpu->arch.guest_fpu->state.xsave,
 					XFEATURE_MASK_BNDREGS);
 		if (mpx_state_buffer)
 			memset(mpx_state_buffer, 0, sizeof(struct mpx_bndreg_state));
-		mpx_state_buffer = get_xsave_addr(&vcpu->arch.guest_fpu.state.xsave,
+		mpx_state_buffer = get_xsave_addr(&vcpu->arch.guest_fpu->state.xsave,
 					XFEATURE_MASK_BNDCSR);
 		if (mpx_state_buffer)
 			memset(mpx_state_buffer, 0, sizeof(struct mpx_bndcsr));
-- 
2.19.1.930.g4563a0d9d0-goog
