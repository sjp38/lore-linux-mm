Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F1BAB6B0087
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:47 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 09/12] Retry fault before vmentry
Date: Mon, 23 Nov 2009 16:06:04 +0200
Message-Id: <1258985167-29178-10-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-1-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

When page is swapped in it is mapped into guest memory only after guest
tries to access it again and generate another fault. To save this fault
we can map it immediately since we know that guest is going to access
the page.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    6 +++++-
 arch/x86/kvm/mmu.c              |   15 +++++++++------
 arch/x86/kvm/paging_tmpl.h      |   38 +++++++++++++++++++++++++++++++++++---
 arch/x86/kvm/x86.c              |    7 +++++++
 virt/kvm/kvm_main.c             |    2 ++
 5 files changed, 58 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index ad177a4..39009a4 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -254,7 +254,7 @@ struct kvm_pio_request {
  */
 struct kvm_mmu {
 	void (*new_cr3)(struct kvm_vcpu *vcpu);
-	int (*page_fault)(struct kvm_vcpu *vcpu, gva_t gva, u32 err);
+	int (*page_fault)(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gva, u32 err);
 	void (*free)(struct kvm_vcpu *vcpu);
 	gpa_t (*gva_to_gpa)(struct kvm_vcpu *vcpu, gva_t gva);
 	void (*prefetch_page)(struct kvm_vcpu *vcpu,
@@ -542,6 +542,8 @@ struct kvm_x86_ops {
 
 struct kvm_arch_async_pf {
 	u32 token;
+	gpa_t cr3;
+	u32 error_code;
 };
 
 extern struct kvm_x86_ops *kvm_x86_ops;
@@ -828,6 +830,8 @@ void kvm_arch_inject_async_page_not_present(struct kvm_vcpu *vcpu,
 					    struct kvm_async_pf *work);
 void kvm_arch_inject_async_page_present(struct kvm_vcpu *vcpu,
 					struct kvm_async_pf *work);
+void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
+			       struct kvm_async_pf *work);
 bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu);
 #endif /* _ASM_X86_KVM_HOST_H */
 
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 2cdf3e3..1225c31 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2172,7 +2172,7 @@ static gpa_t nonpaging_gva_to_gpa(struct kvm_vcpu *vcpu, gva_t vaddr)
 	return vaddr;
 }
 
-static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
+static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gva,
 				u32 error_code)
 {
 	gfn_t gfn;
@@ -2192,10 +2192,13 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
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
 
@@ -2207,7 +2210,7 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
 	return !!kvm_x86_ops->get_cpl(vcpu);
 }
 
-static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
+static int tdp_page_fault(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gpa,
 				u32 error_code)
 {
 	pfn_t pfn;
@@ -2230,7 +2233,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (can_do_async_pf(vcpu)) {
+	if (cr3 == vcpu->arch.cr3 && can_do_async_pf(vcpu)) {
 		r = gfn_to_pfn_async(vcpu->kvm, gfn, &pfn);
 		trace_kvm_try_async_get_page(r, pfn);
 	} else {
@@ -2240,7 +2243,7 @@ do_sync:
 	}
 
 	if (!r) {
-		if (!kvm_arch_setup_async_pf(vcpu, gpa, gfn))
+		if (!kvm_arch_setup_async_pf(vcpu, cr3, gpa, gfn, error_code))
 			goto do_sync;
 		return 0;
 	}
@@ -2810,7 +2813,7 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u32 error_code)
 	int r;
 	enum emulation_result er;
 
-	r = vcpu->arch.mmu.page_fault(vcpu, cr2, error_code);
+	r = vcpu->arch.mmu.page_fault(vcpu, vcpu->arch.cr3, cr2, error_code);
 	if (r < 0)
 		goto out;
 
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index 44d19dc..702893c 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -375,7 +375,7 @@ static u64 *FNAME(fetch)(struct kvm_vcpu *vcpu, gva_t addr,
  *  Returns: 1 if we need to emulate the instruction, 0 otherwise, or
  *           a negative value on error.
  */
-static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
+static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t addr,
 			       u32 error_code)
 {
 	int write_fault = error_code & PFERR_WRITE_MASK;
@@ -388,6 +388,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	pfn_t pfn;
 	int level = PT_PAGE_TABLE_LEVEL;
 	unsigned long mmu_seq;
+	gpa_t curr_cr3 = vcpu->arch.cr3;
 
 	pgprintk("%s: addr %lx err %x\n", __func__, addr, error_code);
 	kvm_mmu_audit(vcpu, "pre page fault");
@@ -396,6 +397,19 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	if (r)
 		return r;
 
+	if (curr_cr3 != cr3) {
+		/*
+		 * We do page fault on behaltf of a process that is sleeping
+		 * because of async PF. PV guest shouldn't kill process while
+		 * it waits for host to swap-in the page so cr3 has to be
+		 * valid here.
+		 */
+		vcpu->arch.cr3 = cr3;
+		paging_new_cr3(vcpu);
+		if (kvm_mmu_reload(vcpu))
+			goto switch_cr3;
+	}
+
 	/*
 	 * Look up the guest pte for the faulting address.
 	 */
@@ -406,6 +420,8 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	 * The page is not mapped by the guest.  Let the guest handle it.
 	 */
 	if (!r) {
+		if (curr_cr3 != vcpu->arch.cr3)
+			goto switch_cr3;
 		pgprintk("%s: guest page fault\n", __func__);
 		inject_page_fault(vcpu, addr, walker.error_code);
 		vcpu->arch.last_pt_write_count = 0; /* reset fork detector */
@@ -420,7 +436,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (can_do_async_pf(vcpu)) {
+	if (curr_cr3 == vcpu->arch.cr3 && can_do_async_pf(vcpu)) {
 		r = gfn_to_pfn_async(vcpu->kvm, walker.gfn, &pfn);
 		trace_kvm_try_async_get_page(r, pfn);
 	} else {
@@ -430,13 +446,18 @@ do_sync:
 	}
 
 	if (!r) {
-		if (!kvm_arch_setup_async_pf(vcpu, addr, walker.gfn))
+		if (!kvm_arch_setup_async_pf(vcpu, cr3, addr, walker.gfn,
+					     error_code))
 			goto do_sync;
+		if (curr_cr3 != vcpu->arch.cr3)
+			goto switch_cr3;
 		return 0;
 	}
 
 	/* mmio */
 	if (is_error_pfn(pfn)) {
+		if (curr_cr3 != vcpu->arch.cr3)
+			goto switch_cr3;
 		pgprintk("gfn %lx is mmio\n", walker.gfn);
 		kvm_release_pfn_clean(pfn);
 		return 1;
@@ -458,12 +479,23 @@ do_sync:
 	kvm_mmu_audit(vcpu, "post page fault (fixed)");
 	spin_unlock(&vcpu->kvm->mmu_lock);
 
+	if (curr_cr3 != vcpu->arch.cr3)
+		goto switch_cr3;
+
 	return write_pt;
 
 out_unlock:
 	spin_unlock(&vcpu->kvm->mmu_lock);
 	kvm_release_pfn_clean(pfn);
 	return 0;
+switch_cr3:
+	if (curr_cr3 != vcpu->arch.cr3) {
+		vcpu->arch.cr3 = curr_cr3;
+		paging_new_cr3(vcpu);
+		kvm_mmu_reload(vcpu);
+	}
+
+	return write_pt;
 }
 
 static void FNAME(invlpg)(struct kvm_vcpu *vcpu, gva_t gva)
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index cbbe5fd..c29af1d 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5306,6 +5306,13 @@ void kvm_set_rflags(struct kvm_vcpu *vcpu, unsigned long rflags)
 }
 EXPORT_SYMBOL_GPL(kvm_set_rflags);
 
+void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
+			       struct kvm_async_pf *work)
+{
+	vcpu->arch.mmu.page_fault(vcpu, work->arch.cr3, work->gva,
+				  work->arch.error_code);
+}
+
 void kvm_arch_inject_async_page_not_present(struct kvm_vcpu *vcpu,
 					    struct kvm_async_pf *work)
 {
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 14ac02a..6e6769f 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1212,6 +1212,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 			spin_lock(&vcpu->async_pf_lock);
 			list_del(&work->link);
 			spin_unlock(&vcpu->async_pf_lock);
+			kvm_arch_async_page_ready(vcpu, work);
 			put_page(work->page);
 			async_pf_work_free(work);
 		}
@@ -1226,6 +1227,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 	list_del(&work->link);
 	spin_unlock(&vcpu->async_pf_lock);
 
+	kvm_arch_async_page_ready(vcpu, work);
 	kvm_arch_inject_async_page_present(vcpu, work);
 
 	put_page(work->page);
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
