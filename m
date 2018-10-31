Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00C366B026E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:26:48 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id j192-v6so7601207oih.11
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:26:47 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e14sor2651563otk.75.2018.10.31.06.26.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 06:26:46 -0700 (PDT)
Date: Wed, 31 Oct 2018 06:26:33 -0700
In-Reply-To: <20181031132634.50440-1-marcorr@google.com>
Message-Id: <20181031132634.50440-4-marcorr@google.com>
Mime-Version: 1.0
References: <20181031132634.50440-1-marcorr@google.com>
Subject: [kvm PATCH v5 3/4] kvm: vmx: refactor vmx_msrs struct for vmalloc
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com
Cc: Marc Orr <marcorr@google.com>

Previously, the vmx_msrs struct relied being aligned within a struct
that is backed by the direct map (e.g., memory allocated with kalloc()).
Specifically, this enabled the virtual addresses associated with the
struct to be translated to physical addresses. However, we'd like to
refactor the host struct, vcpu_vmx, to be allocated with vmalloc(), so
that allocation will succeed when contiguous physical memory is scarce.

Thus, this patch refactors how vmx_msrs is declared and allocated, to
ensure that it can be mapped to the physical address space, even when
vmx_msrs resides within in a vmalloc()'d struct.

Signed-off-by: Marc Orr <marcorr@google.com>
---
 arch/x86/kvm/vmx.c | 57 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 55 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 4078cf15a4b0..315cf4b5f262 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -970,8 +970,25 @@ static inline int pi_test_sn(struct pi_desc *pi_desc)
 
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
@@ -11497,6 +11514,19 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
 		goto free_partial_vcpu;
 	}
 
+	vmx->msr_autoload.guest.val =
+		kmem_cache_zalloc(vmx_msr_entry_cache, GFP_KERNEL);
+	if (!vmx->msr_autoload.guest.val) {
+		err = -ENOMEM;
+		goto free_fpu;
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
@@ -11584,6 +11614,10 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
 	kvm_vcpu_uninit(&vmx->vcpu);
 free_vcpu:
 	free_vpid(vmx->vpid);
+	kmem_cache_free(vmx_msr_entry_cache, vmx->msr_autoload.host.val);
+free_msr_autoload_guest:
+	kmem_cache_free(vmx_msr_entry_cache, vmx->msr_autoload.guest.val);
+free_fpu:
 	kmem_cache_free(x86_fpu_cache, vmx->vcpu.arch.guest_fpu);
 free_partial_vcpu:
 	kmem_cache_free(kvm_vcpu_cache, vmx);
@@ -15163,6 +15197,10 @@ module_exit(vmx_exit);
 static int __init vmx_init(void)
 {
 	int r;
+	size_t vmx_msr_entry_size =
+		sizeof(struct vmx_msr_entry) * NR_AUTOLOAD_MSRS;
+
+	CHECK_INTRA_PAGE(vmx_msr_entry_size);
 
 #if IS_ENABLED(CONFIG_HYPERV)
 	/*
@@ -15194,9 +15232,21 @@ static int __init vmx_init(void)
 #endif
 
 	r = kvm_init(&vmx_x86_ops, sizeof(struct vcpu_vmx),
-		     __alignof__(struct vcpu_vmx), THIS_MODULE);
+		__alignof__(struct vcpu_vmx), THIS_MODULE);
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
@@ -15220,5 +15270,8 @@ static int __init vmx_init(void)
 	vmx_check_vmcs12_offsets();
 
 	return 0;
+out:
+	kvm_exit();
+	return r;
 }
 module_init(vmx_init);
-- 
2.19.1.568.g152ad8e336-goog
