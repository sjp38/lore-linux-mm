Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 85DC96006A9
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 11:31:17 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v5 09/12] Retry fault before vmentry
Date: Mon, 19 Jul 2010 18:30:59 +0300
Message-Id: <1279553462-7036-10-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-1-git-send-email-gleb@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

When page is swapped in it is mapped into guest memory only after guest
tries to access it again and generate another fault. To save this fault
we can map it immediately since we know that guest is going to access
the page.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    7 +++++-
 arch/x86/kvm/mmu.c              |   27 +++++++++++++++++++------
 arch/x86/kvm/paging_tmpl.h      |   40 +++++++++++++++++++++++++++++++++++---
 arch/x86/kvm/x86.c              |    9 ++++++++
 virt/kvm/kvm_main.c             |    2 +
 5 files changed, 73 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index db514ea..45e6c12 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -236,7 +236,8 @@ struct kvm_pio_request {
  */
 struct kvm_mmu {
 	void (*new_cr3)(struct kvm_vcpu *vcpu);
-	int (*page_fault)(struct kvm_vcpu *vcpu, gva_t gva, u32 err);
+	int (*page_fault)(struct kvm_vcpu *vcpu, gva_t gva, u32 err, bool sync);
+	int (*page_fault_other_cr3)(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gva, u32 err);
 	void (*free)(struct kvm_vcpu *vcpu);
 	gpa_t (*gva_to_gpa)(struct kvm_vcpu *vcpu, gva_t gva, u32 access,
 			    u32 *error);
@@ -534,6 +535,8 @@ struct kvm_x86_ops {
 
 struct kvm_arch_async_pf {
 	u32 token;
+	gpa_t cr3;
+	u32 error_code;
 };
 
 extern struct kvm_x86_ops *kvm_x86_ops;
@@ -777,6 +780,8 @@ void kvm_arch_inject_async_page_not_present(struct kvm_vcpu *vcpu,
 					    struct kvm_async_pf *work);
 void kvm_arch_inject_async_page_present(struct kvm_vcpu *vcpu,
 					struct kvm_async_pf *work);
+void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
+			       struct kvm_async_pf *work);
 bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu);
 #endif /* _ASM_X86_KVM_HOST_H */
 
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 5e6105c..12d1a7b 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2327,7 +2327,7 @@ static gpa_t nonpaging_gva_to_gpa(struct kvm_vcpu *vcpu, gva_t vaddr,
 }
 
 static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
-				u32 error_code)
+				u32 error_code, bool sync)
 {
 	gfn_t gfn;
 	int r;
@@ -2346,10 +2346,13 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
 			     error_code & PFERR_WRITE_MASK, gfn);
 }
 
-int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
+int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gva,
+			    gfn_t gfn, u32 error_code)
 {
 	struct kvm_arch_async_pf arch;
 	arch.token = (vcpu->arch.async_pf_id++ << 12) | vcpu->vcpu_id;
+	arch.cr3 = cr3;
+	arch.error_code = error_code;
 	return kvm_setup_async_pf(vcpu, gva, gfn, &arch);
 }
 
@@ -2361,8 +2364,8 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
 	return !!kvm_x86_ops->get_cpl(vcpu);
 }
 
-static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
-				u32 error_code)
+static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
+			  bool sync)
 {
 	pfn_t pfn;
 	int r;
@@ -2385,7 +2388,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (can_do_async_pf(vcpu)) {
+	if (!sync && can_do_async_pf(vcpu)) {
 		pfn = gfn_to_pfn_async(vcpu->kvm, gfn, &async);
 		trace_kvm_try_async_get_page(async, pfn);
 	} else {
@@ -2395,7 +2398,8 @@ do_sync:
 	}
 
 	if (async) {
-		if (!kvm_arch_setup_async_pf(vcpu, gpa, gfn))
+		if (!kvm_arch_setup_async_pf(vcpu, vcpu->arch.cr3, gpa, gfn,
+					     error_code))
 			goto do_sync;
 		return 0;
 	}
@@ -2419,6 +2423,12 @@ out_unlock:
 	return 0;
 }
 
+static int tdp_page_fault_sync(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gpa,
+			       u32 error_code)
+{
+	return tdp_page_fault(vcpu, gpa, error_code, true);
+}
+
 static void nonpaging_free(struct kvm_vcpu *vcpu)
 {
 	mmu_free_roots(vcpu);
@@ -2549,6 +2559,7 @@ static int paging64_init_context_common(struct kvm_vcpu *vcpu, int level)
 	ASSERT(is_pae(vcpu));
 	context->new_cr3 = paging_new_cr3;
 	context->page_fault = paging64_page_fault;
+	context->page_fault_other_cr3 = paging64_page_fault_other_cr3;
 	context->gva_to_gpa = paging64_gva_to_gpa;
 	context->prefetch_page = paging64_prefetch_page;
 	context->sync_page = paging64_sync_page;
@@ -2573,6 +2584,7 @@ static int paging32_init_context(struct kvm_vcpu *vcpu)
 	reset_rsvds_bits_mask(vcpu, PT32_ROOT_LEVEL);
 	context->new_cr3 = paging_new_cr3;
 	context->page_fault = paging32_page_fault;
+	context->page_fault_other_cr3 = paging32_page_fault_other_cr3;
 	context->gva_to_gpa = paging32_gva_to_gpa;
 	context->free = paging_free;
 	context->prefetch_page = paging32_prefetch_page;
@@ -2596,6 +2608,7 @@ static int init_kvm_tdp_mmu(struct kvm_vcpu *vcpu)
 
 	context->new_cr3 = nonpaging_new_cr3;
 	context->page_fault = tdp_page_fault;
+	context->page_fault_other_cr3 = tdp_page_fault_sync;
 	context->free = nonpaging_free;
 	context->prefetch_page = nonpaging_prefetch_page;
 	context->sync_page = nonpaging_sync_page;
@@ -2983,7 +2996,7 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u32 error_code)
 	int r;
 	enum emulation_result er;
 
-	r = vcpu->arch.mmu.page_fault(vcpu, cr2, error_code);
+	r = vcpu->arch.mmu.page_fault(vcpu, cr2, error_code, false);
 	if (r < 0)
 		goto out;
 
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index f8c74a1..fec8e52 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -415,8 +415,8 @@ out_gpte_changed:
  *  Returns: 1 if we need to emulate the instruction, 0 otherwise, or
  *           a negative value on error.
  */
-static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
-			       u32 error_code)
+static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr, u32 error_code,
+			     bool sync)
 {
 	int write_fault = error_code & PFERR_WRITE_MASK;
 	int user_fault = error_code & PFERR_USER_MASK;
@@ -461,7 +461,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (can_do_async_pf(vcpu)) {
+	if (!sync && can_do_async_pf(vcpu)) {
 		pfn = gfn_to_pfn_async(vcpu->kvm, walker.gfn, &async);
 		trace_kvm_try_async_get_page(async, pfn);
 	} else {
@@ -471,7 +471,8 @@ do_sync:
 	}
 
 	if (async) {
-		if (!kvm_arch_setup_async_pf(vcpu, addr, walker.gfn))
+		if (!kvm_arch_setup_async_pf(vcpu, vcpu->arch.cr3, addr,
+					     walker.gfn, error_code))
 			goto do_sync;
 		return 0;
 	}
@@ -505,6 +506,37 @@ out_unlock:
 	return 0;
 }
 
+static int FNAME(page_fault_other_cr3)(struct kvm_vcpu *vcpu, gpa_t cr3,
+				       gva_t addr, u32 error_code)
+{
+	int r = 0;
+	gpa_t curr_cr3 = vcpu->arch.cr3;
+
+	if (curr_cr3 != cr3) {
+		/*
+		 * We do page fault on behalf of a process that is sleeping
+		 * because of async PF. PV guest takes reference to mm that cr3
+		 * belongs too, so it has to be valid here.
+		 */
+		kvm_set_cr3(vcpu, cr3);
+		if (kvm_mmu_reload(vcpu))
+			goto switch_cr3;
+	}
+
+	r = FNAME(page_fault)(vcpu, addr, error_code, true);
+
+	if (kvm_check_request(KVM_REQ_MMU_SYNC, vcpu))
+		kvm_mmu_sync_roots(vcpu);
+
+switch_cr3:
+	if (curr_cr3 != vcpu->arch.cr3) {
+		kvm_set_cr3(vcpu, curr_cr3);
+		kvm_mmu_reload(vcpu);
+	}
+
+	return r;
+}
+
 static void FNAME(invlpg)(struct kvm_vcpu *vcpu, gva_t gva)
 {
 	struct kvm_shadow_walk_iterator iterator;
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 2603cc4..5482db0 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5743,6 +5743,15 @@ void kvm_set_rflags(struct kvm_vcpu *vcpu, unsigned long rflags)
 }
 EXPORT_SYMBOL_GPL(kvm_set_rflags);
 
+void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
+			       struct kvm_async_pf *work)
+{
+	if (!vcpu->arch.mmu.page_fault_other_cr3 || is_error_page(work->page))
+		return;
+	vcpu->arch.mmu.page_fault_other_cr3(vcpu, work->arch.cr3, work->gva,
+					    work->arch.error_code);
+}
+
 static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
 {
 	if (unlikely(vcpu->arch.apf_memslot_ver !=
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index f56e8ac..de1d5b6 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1348,6 +1348,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 			spin_lock(&vcpu->async_pf_lock);
 			list_del(&work->link);
 			spin_unlock(&vcpu->async_pf_lock);
+			kvm_arch_async_page_ready(vcpu, work);
 			put_page(work->page);
 			async_pf_work_free(work);
 			list_del(&work->queue);
@@ -1366,6 +1367,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 	list_del(&work->queue);
 	vcpu->async_pf_queued--;
 
+	kvm_arch_async_page_ready(vcpu, work);
 	kvm_arch_inject_async_page_present(vcpu, work);
 
 	put_page(work->page);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
