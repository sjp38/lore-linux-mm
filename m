Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id C089B6B0007
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 15:39:25 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id w13-v6so5005751iop.2
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 12:39:25 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v64-v6sor9308270itb.31.2018.10.24.12.39.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 12:39:24 -0700 (PDT)
Date: Wed, 24 Oct 2018 12:39:12 -0700
Message-Id: <20181024193912.37318-1-marcorr@google.com>
Mime-Version: 1.0
Subject: [kvm PATCH v3 1/1] kvm: vmx: use vmalloc() to allocate vcpus
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org
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

Note, this patch uses the __vmalloc_node_range() API, which is in the
include/linux/vmalloc.h file. To use __vmalloc_node_range(), this patch
exports the API.

Signed-off-by: Marc Orr <marcorr@google.com>
---
 arch/x86/kvm/vmx.c      | 89 +++++++++++++++++++++++++++++++++++++----
 include/linux/vmalloc.h |  1 +
 mm/vmalloc.c            |  7 ++++
 virt/kvm/kvm_main.c     | 28 +++++++------
 4 files changed, 105 insertions(+), 20 deletions(-)

diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index abeeb45d1c33..62fcc0d63585 100644
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
@@ -970,8 +977,25 @@ static inline int pi_test_sn(struct pi_desc *pi_desc)
 
 struct vmx_msrs {
 	unsigned int		nr;
-	struct vmx_msr_entry	val[NR_AUTOLOAD_MSRS];
+	struct vmx_msr_entry	*val;
 };
+struct kmem_cache *vmx_msr_entry_cache;
+
+/*
+ * To prevent vmx_msr_entry array from crossing a page boundary, require:
+ * sizeof(*vmx_msrs.vmx_msr_entry.val) to be a power of two. This is guaranteed
+ * through compile-time asserts that:
+ *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) is a power of two
+ *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) <= PAGE_SIZE
+ *   - The allocation of vmx_msrs.vmx_msr_entry.val is aligned to its size.
+ */
+#define CHECK_POWER_OF_TWO(val) \
+	BUILD_BUG_ON_MSG(!((val) && !((val) & ((val) - 1))), \
+	#val " is not a power of two.")
+#define CHECK_INTRA_PAGE(val) do { \
+		CHECK_POWER_OF_TWO(val); \
+		BUILD_BUG_ON(!(val <= PAGE_SIZE)); \
+	} while (0)
 
 struct vcpu_vmx {
 	struct kvm_vcpu       vcpu;
@@ -6616,6 +6640,14 @@ static void vmx_vcpu_setup(struct vcpu_vmx *vmx)
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
@@ -6624,7 +6656,7 @@ static void vmx_vcpu_setup(struct vcpu_vmx *vmx)
 		vmcs_write16(GUEST_INTR_STATUS, 0);
 
 		vmcs_write16(POSTED_INTR_NV, POSTED_INTR_VECTOR);
-		vmcs_write64(POSTED_INTR_DESC_ADDR, __pa((&vmx->pi_desc)));
+		vmcs_write64(POSTED_INTR_DESC_ADDR, pi_desc_phys);
 	}
 
 	if (!kvm_pause_in_guest(vmx->vcpu.kvm)) {
@@ -11476,19 +11508,34 @@ static void vmx_free_vcpu(struct kvm_vcpu *vcpu)
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
+	struct vcpu_vmx *vmx = vzalloc_account(sizeof(struct vcpu_vmx));
 	unsigned long *msr_bitmap;
 	int cpu;
 
 	if (!vmx)
 		return ERR_PTR(-ENOMEM);
 
+	vmx->msr_autoload.guest.val =
+		kmem_cache_zalloc(vmx_msr_entry_cache, GFP_KERNEL);
+	if (!vmx->msr_autoload.guest.val) {
+		err = -ENOMEM;
+		goto free_vmx;
+	}
+	vmx->msr_autoload.host.val =
+		kmem_cache_zalloc(vmx_msr_entry_cache, GFP_KERNEL);
+	if (!vmx->msr_autoload.host.val) {
+		err = -ENOMEM;
+		goto free_msr_autoload_guest;
+	}
+
 	vmx->vpid = allocate_vpid();
 
 	err = kvm_vcpu_init(&vmx->vcpu, kvm, id);
@@ -11576,7 +11623,11 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
 	kvm_vcpu_uninit(&vmx->vcpu);
 free_vcpu:
 	free_vpid(vmx->vpid);
-	kmem_cache_free(kvm_vcpu_cache, vmx);
+	kmem_cache_free(vmx_msr_entry_cache, vmx->msr_autoload.host.val);
+free_msr_autoload_guest:
+	kmem_cache_free(vmx_msr_entry_cache, vmx->msr_autoload.guest.val);
+free_vmx:
+	vfree(vmx);
 	return ERR_PTR(err);
 }
 
@@ -15153,6 +15204,10 @@ module_exit(vmx_exit);
 static int __init vmx_init(void)
 {
 	int r;
+	size_t vmx_msr_entry_size =
+		sizeof(struct vmx_msr_entry) * NR_AUTOLOAD_MSRS;
+
+	CHECK_INTRA_PAGE(vmx_msr_entry_size);
 
 #if IS_ENABLED(CONFIG_HYPERV)
 	/*
@@ -15183,10 +15238,25 @@ static int __init vmx_init(void)
 	}
 #endif
 
-	r = kvm_init(&vmx_x86_ops, sizeof(struct vcpu_vmx),
-		     __alignof__(struct vcpu_vmx), THIS_MODULE);
+	/*
+	 * Disable kmem cache; vmalloc will be used instead
+	 * to avoid OOM'ing when memory is available but not contiguous.
+	 */
+	r = kvm_init(&vmx_x86_ops, 0, 0, THIS_MODULE);
 	if (r)
 		return r;
+	/*
+	 * A vmx_msr_entry array resides exclusively within the kernel. Thus,
+	 * use kmem_cache_create_usercopy(), with the usersize argument set to
+	 * ZERO, to blacklist copying vmx_msr_entry to/from user space.
+	 */
+	vmx_msr_entry_cache =
+		kmem_cache_create_usercopy("vmx_msr_entry", vmx_msr_entry_size,
+				  vmx_msr_entry_size, SLAB_ACCOUNT, 0, 0, NULL);
+	if (!vmx_msr_entry_cache) {
+		r = -ENOMEM;
+		goto out;
+	}
 
 	/*
 	 * Must be called after kvm_init() so enable_ept is properly set
@@ -15210,5 +15280,8 @@ static int __init vmx_init(void)
 	vmx_check_vmcs12_offsets();
 
 	return 0;
+out:
+	kvm_exit();
+	return r;
 }
 module_init(vmx_init);
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..47ae6e19ea72 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -71,6 +71,7 @@ static inline void vmalloc_init(void)
 
 extern void *vmalloc(unsigned long size);
 extern void *vzalloc(unsigned long size);
+extern void *vzalloc_account(unsigned long size);
 extern void *vmalloc_user(unsigned long size);
 extern void *vmalloc_node(unsigned long size, int node);
 extern void *vzalloc_node(unsigned long size, int node);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a728fc492557..20adc04d9558 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1846,6 +1846,13 @@ void *vzalloc(unsigned long size)
 }
 EXPORT_SYMBOL(vzalloc);
 
+void *vzalloc_account(unsigned long size)
+{
+	return __vmalloc_node_flags(size, NUMA_NO_NODE,
+				GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT);
+}
+EXPORT_SYMBOL(vzalloc_account);
+
 /**
  * vmalloc_user - allocate zeroed virtually contiguous memory for userspace
  * @size: allocation size
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
