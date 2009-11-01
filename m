Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 404106B0089
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 06:56:37 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 07/11] Retry fault before vmentry
Date: Sun,  1 Nov 2009 13:56:26 +0200
Message-Id: <1257076590-29559-8-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-1-git-send-email-gleb@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When page is swapped in it is mapped into guest memory only after guest
tries to access it again and generate another fault. To save this fault
we can map it immediately since we know that guest is going to access
the page.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    4 +++-
 arch/x86/kvm/mmu.c              |   18 ++++++++++++------
 arch/x86/kvm/paging_tmpl.h      |   32 ++++++++++++++++++++++++++++----
 3 files changed, 43 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index e3cdbfe..6c781ea 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -241,6 +241,8 @@ struct kvm_mmu_async_pf {
 	struct list_head link;
 	struct kvm_vcpu *vcpu;
 	struct mm_struct *mm;
+	gpa_t cr3;
+	u32 error_code;
 	gva_t gva;
 	unsigned long addr;
 	u64 token;
@@ -267,7 +269,7 @@ struct kvm_pio_request {
  */
 struct kvm_mmu {
 	void (*new_cr3)(struct kvm_vcpu *vcpu);
-	int (*page_fault)(struct kvm_vcpu *vcpu, gva_t gva, u32 err);
+	int (*page_fault)(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gva, u32 err);
 	void (*free)(struct kvm_vcpu *vcpu);
 	gpa_t (*gva_to_gpa)(struct kvm_vcpu *vcpu, gva_t gva);
 	void (*prefetch_page)(struct kvm_vcpu *vcpu,
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 31e837b..abe1ce9 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2171,7 +2171,7 @@ static gpa_t nonpaging_gva_to_gpa(struct kvm_vcpu *vcpu, gva_t vaddr)
 	return vaddr;
 }
 
-static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
+static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gva,
 				u32 error_code)
 {
 	gfn_t gfn;
@@ -2322,6 +2322,8 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 			spin_lock(&vcpu->arch.mmu_async_pf_lock);
 			list_del(&work->link);
 			spin_unlock(&vcpu->arch.mmu_async_pf_lock);
+			vcpu->arch.mmu.page_fault(vcpu, (gpa_t)-1, work->gva,
+						  work->error_code);
 			put_page(work->page);
 			async_pf_work_free(work);
 		}
@@ -2338,6 +2340,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 	list_del(&work->link);
 	spin_unlock(&vcpu->arch.mmu_async_pf_lock);
 
+	vcpu->arch.mmu.page_fault(vcpu, (gpa_t)-1, work->gva, work->error_code);
 	vcpu->arch.pv_shm->reason = KVM_PV_REASON_PAGE_READY;
 	vcpu->arch.pv_shm->param = work->token;
 	kvm_inject_page_fault(vcpu, work->gva, 0);
@@ -2363,7 +2366,8 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
 	return !!(kvm_seg.selector & 3);
 }
 
-static int setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
+static int setup_async_pf(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gva,
+			  gfn_t gfn, u32 error_code)
 {
 	struct kvm_mmu_async_pf *work;
 
@@ -2378,6 +2382,8 @@ static int setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
 	atomic_set(&work->used, 1);
 	work->page = NULL;
 	work->vcpu = vcpu;
+	work->cr3 = cr3;
+	work->error_code = error_code;
 	work->gva = gva;
 	work->addr = gfn_to_hva(vcpu->kvm, gfn);
 	work->token = (vcpu->arch.async_pf_id++ << 12) | vcpu->vcpu_id;
@@ -2403,7 +2409,7 @@ retry_sync:
 	return 0;
 }
 
-static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
+static int tdp_page_fault(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gpa,
 				u32 error_code)
 {
 	pfn_t pfn;
@@ -2426,7 +2432,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (can_do_async_pf(vcpu)) {
+	if (cr3 != (gpa_t)-1 && can_do_async_pf(vcpu)) {
 		r = gfn_to_pfn_async(vcpu->kvm, gfn, &pfn);
 		trace_kvm_mmu_try_async_get_page(r, pfn);
 	} else {
@@ -2436,7 +2442,7 @@ do_sync:
 	}
 
 	if (!r) {
-		if (!setup_async_pf(vcpu, gpa, gfn))
+		if (!setup_async_pf(vcpu, cr3, gpa, gfn, error_code))
 			goto do_sync;
 		return 0;
 	}
@@ -3006,7 +3012,7 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u32 error_code)
 	int r;
 	enum emulation_result er;
 
-	r = vcpu->arch.mmu.page_fault(vcpu, cr2, error_code);
+	r = vcpu->arch.mmu.page_fault(vcpu, vcpu->arch.cr3, cr2, error_code);
 	if (r < 0)
 		goto out;
 
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index 9fe2ecd..b1fe61f 100644
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
@@ -396,6 +397,13 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	if (r)
 		return r;
 
+	if (curr_cr3 != cr3) {
+		vcpu->arch.cr3 = cr3;
+		paging_new_cr3(vcpu);
+		if (kvm_mmu_reload(vcpu))
+			goto switch_cr3;
+	}
+
 	/*
 	 * Look up the guest pte for the faulting address.
 	 */
@@ -406,6 +414,8 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	 * The page is not mapped by the guest.  Let the guest handle it.
 	 */
 	if (!r) {
+		if (curr_cr3 != vcpu->arch.cr3)
+			goto switch_cr3;
 		pgprintk("%s: guest page fault\n", __func__);
 		inject_page_fault(vcpu, addr, walker.error_code);
 		vcpu->arch.last_pt_write_count = 0; /* reset fork detector */
@@ -420,7 +430,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (can_do_async_pf(vcpu)) {
+	if (cr3 != (gpa_t)-1 && can_do_async_pf(vcpu)) {
 		r = gfn_to_pfn_async(vcpu->kvm, walker.gfn, &pfn);
 		trace_kvm_mmu_try_async_get_page(r, pfn);
 	} else {
@@ -430,13 +440,17 @@ do_sync:
 	}
 
 	if (!r) {
-		if (!setup_async_pf(vcpu, addr, walker.gfn))
+		if (!setup_async_pf(vcpu, cr3, addr, walker.gfn, error_code))
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
@@ -458,12 +472,22 @@ do_sync:
 	kvm_mmu_audit(vcpu, "post page fault (fixed)");
 	spin_unlock(&vcpu->kvm->mmu_lock);
 
+	if (curr_cr3 != vcpu->arch.cr3)
+		goto switch_cr3;
+
 	return write_pt;
 
 out_unlock:
 	spin_unlock(&vcpu->kvm->mmu_lock);
 	kvm_release_pfn_clean(pfn);
-	return 0;
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
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
