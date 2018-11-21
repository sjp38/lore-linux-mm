Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5406B2443
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:28:37 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m13so6098471pls.15
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 21:28:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d23si29647316pll.161.2018.11.20.21.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 21:28:35 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAL5SLo8144313
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:28:34 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nw0fasm95-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:28:34 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 21 Nov 2018 05:28:32 -0000
From: Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v2 4/4] kvmppc: Handle memory plug/unplug to secure VM
Date: Wed, 21 Nov 2018 10:58:11 +0530
In-Reply-To: <20181121052811.4819-1-bharata@linux.ibm.com>
References: <20181121052811.4819-1-bharata@linux.ibm.com>
Message-Id: <20181121052811.4819-5-bharata@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com, Bharata B Rao <bharata@linux.ibm.com>

Register the new memslot with UV during plug and unregister
the memslot during unplug.

This needs addition of kvm_mr_change argument to
kvm_ops->commit_memory_region()

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/kvm_ppc.h   |  6 ++++--
 arch/powerpc/include/asm/ucall-api.h |  5 +++++
 arch/powerpc/kvm/book3s.c            |  5 +++--
 arch/powerpc/kvm/book3s_hv.c         | 22 +++++++++++++++++++++-
 arch/powerpc/kvm/book3s_pr.c         |  3 ++-
 arch/powerpc/kvm/powerpc.c           |  2 +-
 6 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/include/asm/kvm_ppc.h b/arch/powerpc/include/asm/kvm_ppc.h
index 5f4b6a73789f..1ac920f2e18b 100644
--- a/arch/powerpc/include/asm/kvm_ppc.h
+++ b/arch/powerpc/include/asm/kvm_ppc.h
@@ -224,7 +224,8 @@ extern int kvmppc_core_prepare_memory_region(struct kvm *kvm,
 extern void kvmppc_core_commit_memory_region(struct kvm *kvm,
 				const struct kvm_userspace_memory_region *mem,
 				const struct kvm_memory_slot *old,
-				const struct kvm_memory_slot *new);
+				const struct kvm_memory_slot *new,
+				enum kvm_mr_change change);
 extern int kvm_vm_ioctl_get_smmu_info(struct kvm *kvm,
 				      struct kvm_ppc_smmu_info *info);
 extern void kvmppc_core_flush_memslot(struct kvm *kvm,
@@ -294,7 +295,8 @@ struct kvmppc_ops {
 	void (*commit_memory_region)(struct kvm *kvm,
 				     const struct kvm_userspace_memory_region *mem,
 				     const struct kvm_memory_slot *old,
-				     const struct kvm_memory_slot *new);
+				     const struct kvm_memory_slot *new,
+				     enum kvm_mr_change change);
 	int (*unmap_hva_range)(struct kvm *kvm, unsigned long start,
 			   unsigned long end);
 	int (*age_hva)(struct kvm *kvm, unsigned long start, unsigned long end);
diff --git a/arch/powerpc/include/asm/ucall-api.h b/arch/powerpc/include/asm/ucall-api.h
index 347637995b1b..02c9be311a4f 100644
--- a/arch/powerpc/include/asm/ucall-api.h
+++ b/arch/powerpc/include/asm/ucall-api.h
@@ -25,4 +25,9 @@ static inline int uv_register_mem_slot(u64 lpid, u64 start_gpa, u64 size,
 	return 0;
 }
 
+static inline int uv_unregister_mem_slot(u64 lpid, u64 dw0)
+{
+	return 0;
+}
+
 #endif	/* _ASM_POWERPC_UCALL_API_H */
diff --git a/arch/powerpc/kvm/book3s.c b/arch/powerpc/kvm/book3s.c
index fd9893bc7aa1..a35fb4099094 100644
--- a/arch/powerpc/kvm/book3s.c
+++ b/arch/powerpc/kvm/book3s.c
@@ -830,9 +830,10 @@ int kvmppc_core_prepare_memory_region(struct kvm *kvm,
 void kvmppc_core_commit_memory_region(struct kvm *kvm,
 				const struct kvm_userspace_memory_region *mem,
 				const struct kvm_memory_slot *old,
-				const struct kvm_memory_slot *new)
+				const struct kvm_memory_slot *new,
+				enum kvm_mr_change change)
 {
-	kvm->arch.kvm_ops->commit_memory_region(kvm, mem, old, new);
+	kvm->arch.kvm_ops->commit_memory_region(kvm, mem, old, new, change);
 }
 
 int kvm_unmap_hva_range(struct kvm *kvm, unsigned long start, unsigned long end)
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index d7aa85330016..351ce259d8bb 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -75,6 +75,7 @@
 #include <asm/xics.h>
 #include <asm/xive.h>
 #include <asm/kvm_host.h>
+#include <asm/ucall-api.h>
 
 #include "book3s.h"
 
@@ -4392,7 +4393,8 @@ static int kvmppc_core_prepare_memory_region_hv(struct kvm *kvm,
 static void kvmppc_core_commit_memory_region_hv(struct kvm *kvm,
 				const struct kvm_userspace_memory_region *mem,
 				const struct kvm_memory_slot *old,
-				const struct kvm_memory_slot *new)
+				const struct kvm_memory_slot *new,
+				enum kvm_mr_change change)
 {
 	unsigned long npages = mem->memory_size >> PAGE_SHIFT;
 
@@ -4404,6 +4406,24 @@ static void kvmppc_core_commit_memory_region_hv(struct kvm *kvm,
 	 */
 	if (npages)
 		atomic64_inc(&kvm->arch.mmio_update);
+	/*
+	 * If UV hasn't yet called H_SVM_INIT_START, don't register memslots.
+	 */
+	if (!kvm->arch.secure)
+		return;
+
+	/*
+	 * TODO: Handle KVM_MR_MOVE
+	 */
+	if (change == KVM_MR_CREATE) {
+		uv_register_mem_slot(kvm->arch.lpid,
+					   new->base_gfn << PAGE_SHIFT,
+					   new->npages * PAGE_SIZE,
+					   0,
+					   new->id);
+	} else if (change == KVM_MR_DELETE) {
+		uv_unregister_mem_slot(kvm->arch.lpid, old->id);
+	}
 }
 
 /*
diff --git a/arch/powerpc/kvm/book3s_pr.c b/arch/powerpc/kvm/book3s_pr.c
index 4efd65d9e828..3aeb17b88de7 100644
--- a/arch/powerpc/kvm/book3s_pr.c
+++ b/arch/powerpc/kvm/book3s_pr.c
@@ -1913,7 +1913,8 @@ static int kvmppc_core_prepare_memory_region_pr(struct kvm *kvm,
 static void kvmppc_core_commit_memory_region_pr(struct kvm *kvm,
 				const struct kvm_userspace_memory_region *mem,
 				const struct kvm_memory_slot *old,
-				const struct kvm_memory_slot *new)
+				const struct kvm_memory_slot *new,
+				enum kvm_mr_change change)
 {
 	return;
 }
diff --git a/arch/powerpc/kvm/powerpc.c b/arch/powerpc/kvm/powerpc.c
index 2869a299c4ed..6a7a6a101efd 100644
--- a/arch/powerpc/kvm/powerpc.c
+++ b/arch/powerpc/kvm/powerpc.c
@@ -696,7 +696,7 @@ void kvm_arch_commit_memory_region(struct kvm *kvm,
 				   const struct kvm_memory_slot *new,
 				   enum kvm_mr_change change)
 {
-	kvmppc_core_commit_memory_region(kvm, mem, old, new);
+	kvmppc_core_commit_memory_region(kvm, mem, old, new, change);
 }
 
 void kvm_arch_flush_shadow_memslot(struct kvm *kvm,
-- 
2.17.1
