Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C89196B02D6
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 03:59:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id k25-v6so171097pff.15
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 00:59:16 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x8-v6sor10034570pgp.61.2018.10.26.00.59.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Oct 2018 00:59:15 -0700 (PDT)
Date: Fri, 26 Oct 2018 00:59:00 -0700
In-Reply-To: <20181026075900.111462-1-marcorr@google.com>
Message-Id: <20181026075900.111462-3-marcorr@google.com>
Mime-Version: 1.0
References: <20181026075900.111462-1-marcorr@google.com>
Subject: [kvm PATCH v4 2/2] kvm: vmx: use vmalloc() to allocate vcpus
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com
Cc: Marc Orr <marcorr@google.com>

Previously, vcpus were allocated through the kmem_cache_zalloc() API,
which requires the underlying physical memory to be contiguous.
Because the x86 vcpu struct, struct vcpu_vmx, is relatively large
(e.g., currently 47680 bytes on my setup), it can become hard to find
contiguous memory.

At the same time, the comments in the code indicate that the primary
reason for using the kmem_cache_zalloc() API is to align the memory
rather than to provide physical contiguity.

Thus, this patch updates the vcpu allocation logic for vmx to use the
vmalloc() API.

Signed-off-by: Marc Orr <marcorr@google.com>
---
 arch/x86/kvm/vmx.c  | 37 ++++++++++++++++++++++++++++++-------
 virt/kvm/kvm_main.c | 28 ++++++++++++++++------------
 2 files changed, 46 insertions(+), 19 deletions(-)

diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 3c0303cc101d..8eef21656f60 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -898,7 +898,14 @@ struct nested_vmx {
 #define POSTED_INTR_ON  0
 #define POSTED_INTR_SN  1
 
-/* Posted-Interrupt Descriptor */
+/*
+ * Posted-Interrupt Descriptor
+ *
+ * Note, the physical address of this structure is used by VMX. Furthermore, the
+ * translation code assumes that the entire pi_desc struct resides within a
+ * single page, which will be true because the struct is 64 bytes and 64-byte
+ * aligned.
+ */
 struct pi_desc {
 	u32 pir[8];     /* Posted interrupt requested */
 	union {
@@ -6633,6 +6640,14 @@ static void vmx_vcpu_setup(struct vcpu_vmx *vmx)
 	}
 
 	if (kvm_vcpu_apicv_active(&vmx->vcpu)) {
+		/*
+		 * Note, pi_desc is contained within a single
+		 * page because the struct is 64 bytes and 64-byte aligned.
+		 */
+		phys_addr_t pi_desc_phys =
+			page_to_phys(vmalloc_to_page(&vmx->pi_desc)) +
+			(u64)&vmx->pi_desc % PAGE_SIZE;
+
 		vmcs_write64(EOI_EXIT_BITMAP0, 0);
 		vmcs_write64(EOI_EXIT_BITMAP1, 0);
 		vmcs_write64(EOI_EXIT_BITMAP2, 0);
@@ -6641,7 +6656,7 @@ static void vmx_vcpu_setup(struct vcpu_vmx *vmx)
 		vmcs_write16(GUEST_INTR_STATUS, 0);
 
 		vmcs_write16(POSTED_INTR_NV, POSTED_INTR_VECTOR);
-		vmcs_write64(POSTED_INTR_DESC_ADDR, __pa((&vmx->pi_desc)));
+		vmcs_write64(POSTED_INTR_DESC_ADDR, pi_desc_phys);
 	}
 
 	if (!kvm_pause_in_guest(vmx->vcpu.kvm)) {
@@ -11493,13 +11508,18 @@ static void vmx_free_vcpu(struct kvm_vcpu *vcpu)
 	free_loaded_vmcs(vmx->loaded_vmcs);
 	kfree(vmx->guest_msrs);
 	kvm_vcpu_uninit(vcpu);
-	kmem_cache_free(kvm_vcpu_cache, vmx);
+	kmem_cache_free(vmx_msr_entry_cache, vmx->msr_autoload.guest.val);
+	kmem_cache_free(vmx_msr_entry_cache, vmx->msr_autoload.host.val);
+	vfree(vmx);
 }
 
 static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
 {
 	int err;
-	struct vcpu_vmx *vmx = kmem_cache_zalloc(kvm_vcpu_cache, GFP_KERNEL);
+	struct vcpu_vmx *vmx =
+		__vmalloc(sizeof(struct vcpu_vmx),
+			  GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT,
+			  PAGE_KERNEL);
 	unsigned long *msr_bitmap;
 	int cpu;
 
@@ -11610,7 +11630,7 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
 free_msr_autoload_guest:
 	kmem_cache_free(vmx_msr_entry_cache, vmx->msr_autoload.guest.val);
 free_vmx:
-	kmem_cache_free(kvm_vcpu_cache, vmx);
+	vfree(vmx);
 	return ERR_PTR(err);
 }
 
@@ -15221,8 +15241,11 @@ static int __init vmx_init(void)
 	}
 #endif
 
-	r = kvm_init(&vmx_x86_ops, sizeof(struct vcpu_vmx),
-		__alignof__(struct vcpu_vmx), THIS_MODULE);
+	/*
+	 * Disable kmem cache; vmalloc will be used instead
+	 * to avoid OOM'ing when memory is available but not contiguous.
+	 */
+	r = kvm_init(&vmx_x86_ops, 0, 0, THIS_MODULE);
 	if (r)
 		return r;
 	/*
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 786ade1843a2..8b979e7c3ecd 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -4038,18 +4038,22 @@ int kvm_init(void *opaque, unsigned vcpu_size, unsigned vcpu_align,
 		goto out_free_2;
 	register_reboot_notifier(&kvm_reboot_notifier);
 
-	/* A kmem cache lets us meet the alignment requirements of fx_save. */
-	if (!vcpu_align)
-		vcpu_align = __alignof__(struct kvm_vcpu);
-	kvm_vcpu_cache =
-		kmem_cache_create_usercopy("kvm_vcpu", vcpu_size, vcpu_align,
-					   SLAB_ACCOUNT,
-					   offsetof(struct kvm_vcpu, arch),
-					   sizeof_field(struct kvm_vcpu, arch),
-					   NULL);
-	if (!kvm_vcpu_cache) {
-		r = -ENOMEM;
-		goto out_free_3;
+	/*
+	 * When vcpu_size is zero,
+	 * architecture-specific code manages its own vcpu allocation.
+	 */
+	kvm_vcpu_cache = NULL;
+	if (vcpu_size) {
+		if (!vcpu_align)
+			vcpu_align = __alignof__(struct kvm_vcpu);
+		kvm_vcpu_cache = kmem_cache_create_usercopy(
+			"kvm_vcpu", vcpu_size, vcpu_align, SLAB_ACCOUNT,
+			offsetof(struct kvm_vcpu, arch),
+			sizeof_field(struct kvm_vcpu, arch), NULL);
+		if (!kvm_vcpu_cache) {
+			r = -ENOMEM;
+			goto out_free_3;
+		}
 	}
 
 	r = kvm_async_pf_init();
-- 
2.19.1.568.g152ad8e336-goog
