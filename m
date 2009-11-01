Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 05A746B0085
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 06:56:36 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 06/11] Inject asynchronous page fault into a guest if page is swapped out.
Date: Sun,  1 Nov 2009 13:56:25 +0200
Message-Id: <1257076590-29559-7-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-1-git-send-email-gleb@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If guest access swapped out memory do not swap it in from vcpu thread
context. Setup slow work to do swapping and send async page fault to
a guest.

Allow async page fault injection only when guest is in user mode since
otherwise guest may be in non-sleepable context and will not be able to
reschedule.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |   20 +++
 arch/x86/kvm/mmu.c              |  243 ++++++++++++++++++++++++++++++++++++++-
 arch/x86/kvm/mmutrace.h         |   60 ++++++++++
 arch/x86/kvm/paging_tmpl.h      |   16 +++-
 arch/x86/kvm/x86.c              |   22 +++-
 5 files changed, 352 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 2d1f526..e3cdbfe 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -15,6 +15,7 @@
 #include <linux/mm.h>
 #include <linux/mmu_notifier.h>
 #include <linux/tracepoint.h>
+#include <linux/slow-work.h>
 
 #include <linux/kvm.h>
 #include <linux/kvm_para.h>
@@ -235,6 +236,18 @@ struct kvm_pv_mmu_op_buffer {
 	char buf[512] __aligned(sizeof(long));
 };
 
+struct kvm_mmu_async_pf {
+	struct slow_work work;
+	struct list_head link;
+	struct kvm_vcpu *vcpu;
+	struct mm_struct *mm;
+	gva_t gva;
+	unsigned long addr;
+	u64 token;
+	struct page *page;
+	atomic_t used;
+};
+
 struct kvm_pio_request {
 	unsigned long count;
 	int cur_count;
@@ -318,6 +331,11 @@ struct kvm_vcpu_arch {
 		unsigned long mmu_seq;
 	} update_pte;
 
+	struct list_head mmu_async_pf_done;
+	spinlock_t mmu_async_pf_lock;
+	struct kvm_mmu_async_pf *mmu_async_pf_work;
+	u32 async_pf_id;
+
 	struct i387_fxsave_struct host_fx_image;
 	struct i387_fxsave_struct guest_fx_image;
 
@@ -654,6 +672,8 @@ void __kvm_mmu_free_some_pages(struct kvm_vcpu *vcpu);
 int kvm_mmu_load(struct kvm_vcpu *vcpu);
 void kvm_mmu_unload(struct kvm_vcpu *vcpu);
 void kvm_mmu_sync_roots(struct kvm_vcpu *vcpu);
+void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu);
+void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu);
 
 int kvm_emulate_hypercall(struct kvm_vcpu *vcpu);
 
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index a902479..31e837b 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -19,6 +19,7 @@
 
 #include "mmu.h"
 #include "kvm_cache_regs.h"
+#include "x86.h"
 
 #include <linux/kvm_host.h>
 #include <linux/types.h>
@@ -188,6 +189,7 @@ typedef int (*mmu_parent_walk_fn) (struct kvm_vcpu *vcpu, struct kvm_mmu_page *s
 static struct kmem_cache *pte_chain_cache;
 static struct kmem_cache *rmap_desc_cache;
 static struct kmem_cache *mmu_page_header_cache;
+static struct kmem_cache *mmu_async_pf_cache;
 
 static u64 __read_mostly shadow_trap_nonpresent_pte;
 static u64 __read_mostly shadow_notrap_nonpresent_pte;
@@ -2189,6 +2191,218 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
 			     error_code & PFERR_WRITE_MASK, gfn);
 }
 
+static int gfn_to_pfn_async(struct kvm *kvm, gfn_t gfn, pfn_t *pfn)
+{
+	struct page *page[1];
+	unsigned long addr;
+	int npages;
+
+	*pfn = bad_pfn;
+
+	addr = gfn_to_hva(kvm, gfn);
+	if (kvm_is_error_hva(addr)) {
+		get_page(bad_page);
+		return 1;
+	}
+
+	npages = __get_user_pages_fast(addr, 1, 1, page);
+
+	if (unlikely(npages != 1)) {
+		down_read(&current->mm->mmap_sem);
+		npages = get_user_pages_noio(current, current->mm, addr, 1, 1,
+					     0, page, NULL);
+		up_read(&current->mm->mmap_sem);
+	}
+
+	if (unlikely(npages != 1)) {
+		struct vm_area_struct *vma;
+
+		down_read(&current->mm->mmap_sem);
+		vma = find_vma(current->mm, addr);
+
+		if (vma == NULL || addr < vma->vm_start ||
+		    !(vma->vm_flags & VM_PFNMAP)) {
+			up_read(&current->mm->mmap_sem);
+			return 0; /* do async fault in */
+		}
+
+		*pfn = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+		up_read(&current->mm->mmap_sem);
+		BUG_ON(!kvm_is_mmio_pfn(*pfn));
+	} else
+		*pfn = page_to_pfn(page[0]);
+
+	return 1;
+}
+
+static void async_pf_work_free(struct kvm_mmu_async_pf *apf)
+{
+	if (atomic_dec_and_test(&apf->used))
+		kmem_cache_free(mmu_async_pf_cache, apf);
+}
+
+static int async_pf_get_ref(struct slow_work *work)
+{
+	struct kvm_mmu_async_pf *apf =
+		container_of(work, struct kvm_mmu_async_pf, work);
+
+	atomic_inc(&apf->used);
+	return 0;
+}
+
+static void async_pf_put_ref(struct slow_work *work)
+{
+	struct kvm_mmu_async_pf *apf =
+		container_of(work, struct kvm_mmu_async_pf, work);
+
+	kvm_put_kvm(apf->vcpu->kvm);
+	async_pf_work_free(apf);
+}
+
+static void async_pf_execute(struct slow_work *work)
+{
+	struct page *page[1];
+	struct kvm_mmu_async_pf *apf =
+		container_of(work, struct kvm_mmu_async_pf, work);
+	wait_queue_head_t *q = &apf->vcpu->wq;
+
+	might_sleep();
+
+	down_read(&apf->mm->mmap_sem);
+	get_user_pages(current, apf->mm, apf->addr, 1, 1, 0, page, NULL);
+	up_read(&apf->mm->mmap_sem);
+
+	spin_lock(&apf->vcpu->arch.mmu_async_pf_lock);
+	list_add_tail(&apf->link, &apf->vcpu->arch.mmu_async_pf_done);
+	apf->page = page[0];
+	spin_unlock(&apf->vcpu->arch.mmu_async_pf_lock);
+
+	trace_kvm_mmu_async_pf_executed(apf->addr, apf->page, apf->token,
+					apf->gva);
+
+	if (waitqueue_active(q))
+		wake_up_interruptible(q);
+
+	mmdrop(apf->mm);
+}
+
+struct slow_work_ops async_pf_ops = {
+	.get_ref = async_pf_get_ref,
+	.put_ref = async_pf_put_ref,
+	.execute = async_pf_execute
+};
+
+void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu)
+{
+	while (!list_empty(&vcpu->arch.mmu_async_pf_done)) {
+		struct kvm_mmu_async_pf *work =
+			list_entry(vcpu->arch.mmu_async_pf_done.next,
+				   typeof(*work), link);
+		list_del(&work->link);
+		put_page(work->page);
+		kmem_cache_free(mmu_async_pf_cache, work);
+	}
+}
+
+void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
+{
+	struct kvm_mmu_async_pf *work = vcpu->arch.mmu_async_pf_work;
+
+	if (work) {
+		vcpu->arch.mmu_async_pf_work = NULL;
+		if (work->page == NULL) {
+			vcpu->arch.pv_shm->reason = KVM_PV_REASON_PAGE_NP;
+			vcpu->arch.pv_shm->param = work->token;
+			kvm_inject_page_fault(vcpu, work->gva, 0);
+			trace_kvm_mmu_send_async_pf(
+				vcpu->arch.pv_shm->param,
+				work->gva, KVM_PV_REASON_PAGE_NP);
+			return;
+		} else {
+			spin_lock(&vcpu->arch.mmu_async_pf_lock);
+			list_del(&work->link);
+			spin_unlock(&vcpu->arch.mmu_async_pf_lock);
+			put_page(work->page);
+			async_pf_work_free(work);
+		}
+	}
+
+	if (list_empty_careful(&vcpu->arch.mmu_async_pf_done) ||
+	    kvm_event_needs_reinjection(vcpu) ||
+	    !kvm_x86_ops->interrupt_allowed(vcpu))
+		return;
+
+	spin_lock(&vcpu->arch.mmu_async_pf_lock);
+	work = list_first_entry(&vcpu->arch.mmu_async_pf_done, typeof(*work),
+				link);
+	list_del(&work->link);
+	spin_unlock(&vcpu->arch.mmu_async_pf_lock);
+
+	vcpu->arch.pv_shm->reason = KVM_PV_REASON_PAGE_READY;
+	vcpu->arch.pv_shm->param = work->token;
+	kvm_inject_page_fault(vcpu, work->gva, 0);
+	trace_kvm_mmu_send_async_pf(work->token, work->gva,
+				    KVM_PV_REASON_PAGE_READY);
+
+	put_page(work->page);
+	async_pf_work_free(work);
+}
+
+static bool can_do_async_pf(struct kvm_vcpu *vcpu)
+{
+	struct kvm_segment kvm_seg;
+
+	if (!vcpu->arch.pv_shm ||
+	    !(vcpu->arch.pv_shm->features & KVM_PV_SHM_FEATURES_ASYNC_PF) ||
+	    kvm_event_needs_reinjection(vcpu))
+		return false;
+
+	kvm_get_segment(vcpu, &kvm_seg, VCPU_SREG_CS);
+
+	/* is userspace code? TODO check VM86 mode */
+	return !!(kvm_seg.selector & 3);
+}
+
+static int setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
+{
+	struct kvm_mmu_async_pf *work;
+
+	/* setup slow work */
+
+	/* do alloc atomic since if we are going to sleep anyway we
+	   may as well sleep faulting in page */
+	work = kmem_cache_zalloc(mmu_async_pf_cache, GFP_ATOMIC);
+	if (!work)
+		return 0;
+
+	atomic_set(&work->used, 1);
+	work->page = NULL;
+	work->vcpu = vcpu;
+	work->gva = gva;
+	work->addr = gfn_to_hva(vcpu->kvm, gfn);
+	work->token = (vcpu->arch.async_pf_id++ << 12) | vcpu->vcpu_id;
+	work->mm = current->mm;
+	atomic_inc(&work->mm->mm_count);
+	kvm_get_kvm(work->vcpu->kvm);
+
+	/* this can't really happen otherwise gfn_to_pfn_async
+	   would succeed */
+	if (unlikely(kvm_is_error_hva(work->addr)))
+		goto retry_sync;
+
+	slow_work_init(&work->work, &async_pf_ops);
+	if (slow_work_enqueue(&work->work) != 0)
+		goto retry_sync;
+
+	vcpu->arch.mmu_async_pf_work = work;
+	return 1;
+retry_sync:
+	kvm_put_kvm(work->vcpu->kvm);
+	mmdrop(work->mm);
+	kmem_cache_free(mmu_async_pf_cache, work);
+	return 0;
+}
+
 static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 				u32 error_code)
 {
@@ -2211,7 +2425,23 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
-	pfn = gfn_to_pfn(vcpu->kvm, gfn);
+
+	if (can_do_async_pf(vcpu)) {
+		r = gfn_to_pfn_async(vcpu->kvm, gfn, &pfn);
+		trace_kvm_mmu_try_async_get_page(r, pfn);
+	} else {
+do_sync:
+		r = 1;
+		pfn = gfn_to_pfn(vcpu->kvm, gfn);
+	}
+
+	if (!r) {
+		if (!setup_async_pf(vcpu, gpa, gfn))
+			goto do_sync;
+		return 0;
+	}
+
+	/* mmio */
 	if (is_error_pfn(pfn)) {
 		kvm_release_pfn_clean(pfn);
 		return 1;
@@ -2220,8 +2450,8 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 	if (mmu_notifier_retry(vcpu, mmu_seq))
 		goto out_unlock;
 	kvm_mmu_free_some_pages(vcpu);
-	r = __direct_map(vcpu, gpa, error_code & PFERR_WRITE_MASK,
-			 level, gfn, pfn);
+	r = __direct_map(vcpu, gpa, error_code & PFERR_WRITE_MASK, level, gfn,
+			 pfn);
 	spin_unlock(&vcpu->kvm->mmu_lock);
 
 	return r;
@@ -2976,6 +3206,8 @@ static void mmu_destroy_caches(void)
 		kmem_cache_destroy(rmap_desc_cache);
 	if (mmu_page_header_cache)
 		kmem_cache_destroy(mmu_page_header_cache);
+	if (mmu_async_pf_cache)
+		kmem_cache_destroy(mmu_async_pf_cache);
 }
 
 void kvm_mmu_module_exit(void)
@@ -3003,6 +3235,11 @@ int kvm_mmu_module_init(void)
 	if (!mmu_page_header_cache)
 		goto nomem;
 
+	mmu_async_pf_cache = KMEM_CACHE(kvm_mmu_async_pf, 0);
+
+	if (!mmu_async_pf_cache)
+		goto nomem;
+
 	register_shrinker(&mmu_shrinker);
 
 	return 0;
diff --git a/arch/x86/kvm/mmutrace.h b/arch/x86/kvm/mmutrace.h
index 3e4a5c6..d6dd63c 100644
--- a/arch/x86/kvm/mmutrace.h
+++ b/arch/x86/kvm/mmutrace.h
@@ -214,6 +214,66 @@ TRACE_EVENT(
 	TP_printk("%s", KVM_MMU_PAGE_PRINTK())
 );
 
+TRACE_EVENT(
+	kvm_mmu_try_async_get_page,
+	TP_PROTO(bool r, u64 pfn),
+	TP_ARGS(r, pfn),
+
+	TP_STRUCT__entry(
+		__field(__u64, pfn)
+		),
+
+	TP_fast_assign(
+		__entry->pfn = r ? pfn : (u64)-1;
+		),
+
+	TP_printk("pfn %#llx", __entry->pfn)
+);
+
+TRACE_EVENT(
+	kvm_mmu_send_async_pf,
+	TP_PROTO(u64 task, u64 gva, u64 reason),
+	TP_ARGS(task, gva, reason),
+
+	TP_STRUCT__entry(
+		__field(__u64, task)
+		__field(__u64, gva)
+		__field(bool, np)
+		),
+
+	TP_fast_assign(
+		__entry->task = task;
+		__entry->gva = gva;
+		__entry->np = (reason == KVM_PV_REASON_PAGE_NP);
+		),
+
+	TP_printk("task %#llx gva %#llx %s", __entry->task, __entry->gva,
+		  __entry->np ? "not present" : "ready")
+);
+
+TRACE_EVENT(
+	kvm_mmu_async_pf_executed,
+	TP_PROTO(unsigned long address, struct page *page, u64 task, u64 gva),
+	TP_ARGS(address, page, task, gva),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, address)
+		__field(struct page*, page)
+		__field(u64, task)
+		__field(u64, gva)
+		),
+
+	TP_fast_assign(
+		__entry->address = address;
+		__entry->page = page;
+		__entry->task = task;
+		__entry->gva = gva;
+		),
+
+	TP_printk("task %#llx gva %#llx address %#lx pfn %lx", __entry->task,
+		  __entry->gva, __entry->address, page_to_pfn(__entry->page))
+);
+
 #endif /* _TRACE_KVMMMU_H */
 
 /* This part must be outside protection */
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index 72558f8..9fe2ecd 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -419,7 +419,21 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
-	pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
+
+	if (can_do_async_pf(vcpu)) {
+		r = gfn_to_pfn_async(vcpu->kvm, walker.gfn, &pfn);
+		trace_kvm_mmu_try_async_get_page(r, pfn);
+	} else {
+do_sync:
+		r = 1;
+		pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
+	}
+
+	if (!r) {
+		if (!setup_async_pf(vcpu, addr, walker.gfn))
+			goto do_sync;
+		return 0;
+	}
 
 	/* mmio */
 	if (is_error_pfn(pfn)) {
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index c177933..e6bd3ad 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -3330,6 +3330,10 @@ int kvm_arch_init(void *opaque)
 		goto out;
 	}
 
+	r = slow_work_register_user();
+	if (r)
+		goto out;
+
 	r = kvm_mmu_module_init();
 	if (r)
 		goto out;
@@ -3352,6 +3356,7 @@ out:
 
 void kvm_arch_exit(void)
 {
+	slow_work_unregister_user();
 	if (!boot_cpu_has(X86_FEATURE_CONSTANT_TSC))
 		cpufreq_unregister_notifier(&kvmclock_cpufreq_notifier_block,
 					    CPUFREQ_TRANSITION_NOTIFIER);
@@ -3837,6 +3842,8 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
 		}
 	}
 
+	kvm_check_async_pf_completion(vcpu);
+
 	preempt_disable();
 
 	kvm_x86_ops->prepare_guest_switch(vcpu);
@@ -3927,7 +3934,6 @@ out:
 	return r;
 }
 
-
 static int __vcpu_run(struct kvm_vcpu *vcpu)
 {
 	int r;
@@ -5026,6 +5032,9 @@ int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
 	}
 	vcpu->arch.mcg_cap = KVM_MAX_MCE_BANKS;
 
+	INIT_LIST_HEAD(&vcpu->arch.mmu_async_pf_done);
+	spin_lock_init(&vcpu->arch.mmu_async_pf_lock);
+
 	return 0;
 
 fail_mmu_destroy:
@@ -5078,8 +5087,10 @@ static void kvm_free_vcpus(struct kvm *kvm)
 	/*
 	 * Unpin any mmu pages first.
 	 */
-	kvm_for_each_vcpu(i, vcpu, kvm)
+	kvm_for_each_vcpu(i, vcpu, kvm) {
+		kvm_clear_async_pf_completion_queue(vcpu);
 		kvm_unload_vcpu_mmu(vcpu);
+	}
 	kvm_for_each_vcpu(i, vcpu, kvm)
 		kvm_arch_vcpu_free(vcpu);
 
@@ -5178,10 +5189,11 @@ void kvm_arch_flush_shadow(struct kvm *kvm)
 int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu)
 {
 	return vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE
+		|| !list_empty_careful(&vcpu->arch.mmu_async_pf_done)
 		|| vcpu->arch.mp_state == KVM_MP_STATE_SIPI_RECEIVED
-		|| vcpu->arch.nmi_pending ||
-		(kvm_arch_interrupt_allowed(vcpu) &&
-		 kvm_cpu_has_interrupt(vcpu));
+		|| vcpu->arch.nmi_pending
+		|| (kvm_arch_interrupt_allowed(vcpu) &&
+		    kvm_cpu_has_interrupt(vcpu));
 }
 
 void kvm_vcpu_kick(struct kvm_vcpu *vcpu)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
