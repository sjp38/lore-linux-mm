Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8645C5F004D
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 05:23:17 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v7 03/12] Retry fault before vmentry
Date: Thu, 14 Oct 2010 11:22:47 +0200
Message-Id: <1287048176-2563-4-git-send-email-gleb@redhat.com>
In-Reply-To: <1287048176-2563-1-git-send-email-gleb@redhat.com>
References: <1287048176-2563-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

When page is swapped in it is mapped into guest memory only after guest
tries to access it again and generate another fault. To save this fault
we can map it immediately since we know that guest is going to access
the page. Do it only when tdp is enabled for now. Shadow paging case is
more complicated. CR[034] and EFER registers should be switched before
doing mapping and then switched back.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    4 +++-
 arch/x86/kvm/mmu.c              |   16 ++++++++--------
 arch/x86/kvm/paging_tmpl.h      |    6 +++---
 arch/x86/kvm/x86.c              |    7 +++++++
 virt/kvm/async_pf.c             |    2 ++
 5 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 043e29e..96aca44 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -241,7 +241,7 @@ struct kvm_mmu {
 	void (*new_cr3)(struct kvm_vcpu *vcpu);
 	void (*set_cr3)(struct kvm_vcpu *vcpu, unsigned long root);
 	unsigned long (*get_cr3)(struct kvm_vcpu *vcpu);
-	int (*page_fault)(struct kvm_vcpu *vcpu, gva_t gva, u32 err);
+	int (*page_fault)(struct kvm_vcpu *vcpu, gva_t gva, u32 err, bool no_apf);
 	void (*inject_page_fault)(struct kvm_vcpu *vcpu);
 	void (*free)(struct kvm_vcpu *vcpu);
 	gpa_t (*gva_to_gpa)(struct kvm_vcpu *vcpu, gva_t gva, u32 access,
@@ -839,6 +839,8 @@ void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
 				     struct kvm_async_pf *work);
 void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
 				 struct kvm_async_pf *work);
+void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
+			       struct kvm_async_pf *work);
 extern bool kvm_find_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn);
 
 #endif /* _ASM_X86_KVM_HOST_H */
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index f01e89a..11d152b 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2568,7 +2568,7 @@ static gpa_t nonpaging_gva_to_gpa_nested(struct kvm_vcpu *vcpu, gva_t vaddr,
 }
 
 static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
-				u32 error_code)
+				u32 error_code, bool no_apf)
 {
 	gfn_t gfn;
 	int r;
@@ -2604,8 +2604,8 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
 	return kvm_x86_ops->interrupt_allowed(vcpu);
 }
 
-static bool try_async_pf(struct kvm_vcpu *vcpu, gfn_t gfn, gva_t gva,
-			 pfn_t *pfn)
+static bool try_async_pf(struct kvm_vcpu *vcpu, bool no_apf, gfn_t gfn,
+			 gva_t gva, pfn_t *pfn)
 {
 	bool async;
 
@@ -2616,7 +2616,7 @@ static bool try_async_pf(struct kvm_vcpu *vcpu, gfn_t gfn, gva_t gva,
 
 	put_page(pfn_to_page(*pfn));
 
-	if (can_do_async_pf(vcpu)) {
+	if (!no_apf && can_do_async_pf(vcpu)) {
 		trace_kvm_try_async_get_page(async, *pfn);
 		if (kvm_find_async_pf_gfn(vcpu, gfn)) {
 			trace_kvm_async_pf_doublefault(gva, gfn);
@@ -2631,8 +2631,8 @@ static bool try_async_pf(struct kvm_vcpu *vcpu, gfn_t gfn, gva_t gva,
 	return false;
 }
 
-static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
-				u32 error_code)
+static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
+			  bool no_apf)
 {
 	pfn_t pfn;
 	int r;
@@ -2654,7 +2654,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (try_async_pf(vcpu, gfn, gpa, &pfn))
+	if (try_async_pf(vcpu, no_apf, gfn, gpa, &pfn))
 		return 0;
 
 	/* mmio */
@@ -3317,7 +3317,7 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u32 error_code)
 	int r;
 	enum emulation_result er;
 
-	r = vcpu->arch.mmu.page_fault(vcpu, cr2, error_code);
+	r = vcpu->arch.mmu.page_fault(vcpu, cr2, error_code, false);
 	if (r < 0)
 		goto out;
 
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index c45376d..d6b281e 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -527,8 +527,8 @@ out_gpte_changed:
  *  Returns: 1 if we need to emulate the instruction, 0 otherwise, or
  *           a negative value on error.
  */
-static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
-			       u32 error_code)
+static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr, u32 error_code,
+			     bool no_apf)
 {
 	int write_fault = error_code & PFERR_WRITE_MASK;
 	int user_fault = error_code & PFERR_USER_MASK;
@@ -569,7 +569,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (try_async_pf(vcpu, walker.gfn, addr, &pfn))
+	if (try_async_pf(vcpu, no_apf, walker.gfn, addr, &pfn))
 		return 0;
 
 	/* mmio */
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 09e72fc..bf37397 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -6131,6 +6131,13 @@ void kvm_set_rflags(struct kvm_vcpu *vcpu, unsigned long rflags)
 }
 EXPORT_SYMBOL_GPL(kvm_set_rflags);
 
+void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu, struct kvm_async_pf *work)
+{
+	if (!vcpu->arch.mmu.direct_map || is_error_page(work->page))
+		return;
+	vcpu->arch.mmu.page_fault(vcpu, work->gva, 0, true);
+}
+
 static inline u32 kvm_async_pf_hash_fn(gfn_t gfn)
 {
 	return hash_32(gfn & 0xffffffff, order_base_2(ASYNC_PF_PER_VCPU));
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index 8b144d5..41607ed 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -132,6 +132,8 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 	list_del(&work->link);
 	spin_unlock(&vcpu->async_pf.lock);
 
+	if (work->page)
+		kvm_arch_async_page_ready(vcpu, work);
 	kvm_arch_async_page_present(vcpu, work);
 
 	list_del(&work->queue);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
