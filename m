Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3ADD16B007B
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:27 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 08/12] Inject asynchronous page fault into a guest if page is swapped out.
Date: Mon, 23 Nov 2009 16:06:03 +0200
Message-Id: <1258985167-29178-9-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-1-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

If guest access swapped out memory do not swap it in from vcpu thread
context. Setup slow work to do swapping and send async page fault to
a guest.

Allow async page fault injection only when guest is in user mode since
otherwise guest may be in non-sleepable context and will not be able to
reschedule.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |   13 +++
 arch/x86/kvm/Kconfig            |    2 +
 arch/x86/kvm/mmu.c              |   36 ++++++-
 arch/x86/kvm/paging_tmpl.h      |   16 +++-
 arch/x86/kvm/x86.c              |   37 ++++++-
 include/linux/kvm_host.h        |   27 +++++
 include/trace/events/kvm.h      |   60 +++++++++++
 virt/kvm/Kconfig                |    3 +
 virt/kvm/kvm_main.c             |  225 ++++++++++++++++++++++++++++++++++++++-
 9 files changed, 412 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 9598e85..ad177a4 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -377,6 +377,7 @@ struct kvm_vcpu_arch {
 
 	u32 __user *apf_data;
 	u64 apf_msr_val;
+	u32 async_pf_id;
 };
 
 struct kvm_mem_alias {
@@ -539,6 +540,10 @@ struct kvm_x86_ops {
 	const struct trace_print_flags *exit_reasons_str;
 };
 
+struct kvm_arch_async_pf {
+	u32 token;
+};
+
 extern struct kvm_x86_ops *kvm_x86_ops;
 
 int kvm_mmu_module_init(void);
@@ -817,4 +822,12 @@ int kvm_cpu_get_interrupt(struct kvm_vcpu *v);
 void kvm_define_shared_msr(unsigned index, u32 msr);
 void kvm_set_shared_msr(unsigned index, u64 val);
 
+struct kvm_async_pf;
+
+void kvm_arch_inject_async_page_not_present(struct kvm_vcpu *vcpu,
+					    struct kvm_async_pf *work);
+void kvm_arch_inject_async_page_present(struct kvm_vcpu *vcpu,
+					struct kvm_async_pf *work);
+bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu);
 #endif /* _ASM_X86_KVM_HOST_H */
+
diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
index 4cd4983..f77b127 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -28,6 +28,8 @@ config KVM
 	select HAVE_KVM_IRQCHIP
 	select HAVE_KVM_EVENTFD
 	select KVM_APIC_ARCHITECTURE
+	select KVM_ASYNC_PF
+	select SLOW_WORK
 	select USER_RETURN_NOTIFIER
 	---help---
 	  Support hosting fully virtualized guest machines using hardware
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 4c3e5b2..2cdf3e3 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -19,6 +19,7 @@
 
 #include "mmu.h"
 #include "kvm_cache_regs.h"
+#include "x86.h"
 
 #include <linux/kvm_host.h>
 #include <linux/types.h>
@@ -29,6 +30,8 @@
 #include <linux/swap.h>
 #include <linux/hugetlb.h>
 #include <linux/compiler.h>
+#include <trace/events/kvm.h>
+#undef TRACE_INCLUDE_FILE
 
 #include <asm/page.h>
 #include <asm/cmpxchg.h>
@@ -2189,6 +2192,21 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
 			     error_code & PFERR_WRITE_MASK, gfn);
 }
 
+int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
+{
+	struct kvm_arch_async_pf arch;
+	arch.token = (vcpu->arch.async_pf_id++ << 12) | vcpu->vcpu_id;
+	return kvm_setup_async_pf(vcpu, gva, gfn, &arch);
+}
+
+static bool can_do_async_pf(struct kvm_vcpu *vcpu)
+{
+	if (!vcpu->arch.apf_data || kvm_event_needs_reinjection(vcpu))
+		return false;
+
+	return !!kvm_x86_ops->get_cpl(vcpu);
+}
+
 static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 				u32 error_code)
 {
@@ -2211,7 +2229,23 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
-	pfn = gfn_to_pfn(vcpu->kvm, gfn);
+
+	if (can_do_async_pf(vcpu)) {
+		r = gfn_to_pfn_async(vcpu->kvm, gfn, &pfn);
+		trace_kvm_try_async_get_page(r, pfn);
+	} else {
+do_sync:
+		r = 1;
+		pfn = gfn_to_pfn(vcpu->kvm, gfn);
+	}
+
+	if (!r) {
+		if (!kvm_arch_setup_async_pf(vcpu, gpa, gfn))
+			goto do_sync;
+		return 0;
+	}
+
+	/* mmio */
 	if (is_error_pfn(pfn)) {
 		kvm_release_pfn_clean(pfn);
 		return 1;
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index a601713..44d19dc 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -419,7 +419,21 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
-	pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
+
+	if (can_do_async_pf(vcpu)) {
+		r = gfn_to_pfn_async(vcpu->kvm, walker.gfn, &pfn);
+		trace_kvm_try_async_get_page(r, pfn);
+	} else {
+do_sync:
+		r = 1;
+		pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
+	}
+
+	if (!r) {
+		if (!kvm_arch_setup_async_pf(vcpu, addr, walker.gfn))
+			goto do_sync;
+		return 0;
+	}
 
 	/* mmio */
 	if (is_error_pfn(pfn)) {
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index ce8e66d..cbbe5fd 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -3898,6 +3898,8 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
 		}
 	}
 
+	kvm_check_async_pf_completion(vcpu);
+
 	preempt_disable();
 
 	kvm_x86_ops->prepare_guest_switch(vcpu);
@@ -5151,8 +5153,10 @@ static void kvm_free_vcpus(struct kvm *kvm)
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
 
@@ -5251,10 +5255,11 @@ void kvm_arch_flush_shadow(struct kvm *kvm)
 int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu)
 {
 	return vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE
+		|| !list_empty_careful(&vcpu->async_pf_done)
 		|| vcpu->arch.mp_state == KVM_MP_STATE_SIPI_RECEIVED
-		|| vcpu->arch.nmi_pending ||
-		(kvm_arch_interrupt_allowed(vcpu) &&
-		 kvm_cpu_has_interrupt(vcpu));
+		|| vcpu->arch.nmi_pending
+		|| (kvm_arch_interrupt_allowed(vcpu) &&
+		    kvm_cpu_has_interrupt(vcpu));
 }
 
 void kvm_vcpu_kick(struct kvm_vcpu *vcpu)
@@ -5301,6 +5306,30 @@ void kvm_set_rflags(struct kvm_vcpu *vcpu, unsigned long rflags)
 }
 EXPORT_SYMBOL_GPL(kvm_set_rflags);
 
+void kvm_arch_inject_async_page_not_present(struct kvm_vcpu *vcpu,
+					    struct kvm_async_pf *work)
+{
+	put_user(KVM_PV_REASON_PAGE_NOT_PRESENT, vcpu->arch.apf_data);
+	kvm_inject_page_fault(vcpu, work->arch.token, 0);
+	trace_kvm_send_async_pf(work->arch.token, work->gva,
+				KVM_PV_REASON_PAGE_NOT_PRESENT);
+}
+
+void kvm_arch_inject_async_page_present(struct kvm_vcpu *vcpu,
+					struct kvm_async_pf *work)
+{
+	put_user(KVM_PV_REASON_PAGE_READY, vcpu->arch.apf_data);
+	kvm_inject_page_fault(vcpu, work->arch.token, 0);
+	trace_kvm_send_async_pf(work->arch.token, work->gva,
+				KVM_PV_REASON_PAGE_READY);
+}
+
+bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu)
+{
+	return !kvm_event_needs_reinjection(vcpu) &&
+		kvm_x86_ops->interrupt_allowed(vcpu);
+}
+
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_exit);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_inj_virq);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_page_fault);
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index bd5a616..7579685 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -16,6 +16,7 @@
 #include <linux/mm.h>
 #include <linux/preempt.h>
 #include <linux/msi.h>
+#include <linux/slow-work.h>
 #include <asm/signal.h>
 
 #include <linux/kvm.h>
@@ -72,6 +73,25 @@ void __kvm_io_bus_unregister_dev(struct kvm_io_bus *bus,
 void kvm_io_bus_unregister_dev(struct kvm *kvm, struct kvm_io_bus *bus,
 			       struct kvm_io_device *dev);
 
+#ifdef CONFIG_KVM_ASYNC_PF
+struct kvm_async_pf {
+	struct slow_work work;
+	struct list_head link;
+	struct kvm_vcpu *vcpu;
+	struct mm_struct *mm;
+	gva_t gva;
+	unsigned long addr;
+	struct kvm_arch_async_pf arch;
+	struct page *page;
+	atomic_t used;
+};
+
+void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu);
+void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu);
+int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
+		       struct kvm_arch_async_pf *arch);
+#endif
+
 struct kvm_vcpu {
 	struct kvm *kvm;
 #ifdef CONFIG_PREEMPT_NOTIFIERS
@@ -99,6 +119,12 @@ struct kvm_vcpu {
 	gpa_t mmio_phys_addr;
 #endif
 
+#ifdef CONFIG_KVM_ASYNC_PF
+	struct list_head async_pf_done;
+	spinlock_t async_pf_lock;
+	struct kvm_async_pf *async_pf_work;
+#endif
+
 	struct kvm_vcpu_arch arch;
 };
 
@@ -263,6 +289,7 @@ void kvm_release_page_dirty(struct page *page);
 void kvm_set_page_dirty(struct page *page);
 void kvm_set_page_accessed(struct page *page);
 
+int gfn_to_pfn_async(struct kvm *kvm, gfn_t gfn, pfn_t *pfn);
 pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn);
 void kvm_release_pfn_dirty(pfn_t);
 void kvm_release_pfn_clean(pfn_t pfn);
diff --git a/include/trace/events/kvm.h b/include/trace/events/kvm.h
index dbe1084..ddfdd8e 100644
--- a/include/trace/events/kvm.h
+++ b/include/trace/events/kvm.h
@@ -145,6 +145,66 @@ TRACE_EVENT(kvm_mmio,
 		  __entry->len, __entry->gpa, __entry->val)
 );
 
+#ifdef CONFIG_KVM_ASYNC_PF
+TRACE_EVENT(
+	kvm_try_async_get_page,
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
+	kvm_send_async_pf,
+	TP_PROTO(u64 token, u64 gva, u64 reason),
+	TP_ARGS(token, gva, reason),
+
+	TP_STRUCT__entry(
+		__field(__u64, token)
+		__field(__u64, gva)
+		__field(bool, np)
+		),
+
+	TP_fast_assign(
+		__entry->token = token;
+		__entry->gva = gva;
+		__entry->np = (reason == KVM_PV_REASON_PAGE_NOT_PRESENT);
+		),
+
+	TP_printk("token %#llx gva %#llx %s", __entry->token, __entry->gva,
+		  __entry->np ? "not present" : "ready")
+);
+
+TRACE_EVENT(
+	kvm_async_pf_completed,
+	TP_PROTO(unsigned long address, struct page *page, u64 gva),
+	TP_ARGS(address, page, gva),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, address)
+		__field(struct page*, page)
+		__field(u64, gva)
+		),
+
+	TP_fast_assign(
+		__entry->address = address;
+		__entry->page = page;
+		__entry->gva = gva;
+		),
+
+	TP_printk("gva %#llx address %#lx pfn %lx",  __entry->gva,
+		  __entry->address, page_to_pfn(__entry->page))
+);
+#endif
+
 #endif /* _TRACE_KVM_MAIN_H */
 
 /* This part must be outside protection */
diff --git a/virt/kvm/Kconfig b/virt/kvm/Kconfig
index daece36..ccbc47a 100644
--- a/virt/kvm/Kconfig
+++ b/virt/kvm/Kconfig
@@ -12,3 +12,6 @@ config HAVE_KVM_EVENTFD
 
 config KVM_APIC_ARCHITECTURE
        bool
+
+config KVM_ASYNC_PF
+       bool
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index f92ba13..14ac02a 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -76,6 +76,10 @@ static atomic_t hardware_enable_failed;
 struct kmem_cache *kvm_vcpu_cache;
 EXPORT_SYMBOL_GPL(kvm_vcpu_cache);
 
+#ifdef CONFIG_KVM_ASYNC_PF
+static struct kmem_cache *async_pf_cache;
+#endif
+
 static __read_mostly struct preempt_ops kvm_preempt_ops;
 
 struct dentry *kvm_debugfs_dir;
@@ -176,6 +180,10 @@ int kvm_vcpu_init(struct kvm_vcpu *vcpu, struct kvm *kvm, unsigned id)
 	vcpu->kvm = kvm;
 	vcpu->vcpu_id = id;
 	init_waitqueue_head(&vcpu->wq);
+#ifdef CONFIG_KVM_ASYNC_PF
+	INIT_LIST_HEAD(&vcpu->async_pf_done);
+	spin_lock_init(&vcpu->async_pf_lock);
+#endif
 
 	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
 	if (!page) {
@@ -822,6 +830,52 @@ unsigned long gfn_to_hva(struct kvm *kvm, gfn_t gfn)
 }
 EXPORT_SYMBOL_GPL(gfn_to_hva);
 
+int gfn_to_pfn_async(struct kvm *kvm, gfn_t gfn, pfn_t *pfn)
+{
+	struct page *page[1];
+	unsigned long addr;
+	int npages = 0;
+
+	*pfn = bad_pfn;
+
+	addr = gfn_to_hva(kvm, gfn);
+	if (kvm_is_error_hva(addr)) {
+		get_page(bad_page);
+		return 1;
+	}
+
+#ifdef CONFIG_X86
+	npages = __get_user_pages_fast(addr, 1, 1, page);
+
+#endif
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
 pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn)
 {
 	struct page *page[1];
@@ -1076,6 +1130,151 @@ void mark_page_dirty(struct kvm *kvm, gfn_t gfn)
 	}
 }
 
+#ifdef CONFIG_KVM_ASYNC_PF
+static void async_pf_work_free(struct kvm_async_pf *apf)
+{
+	if (atomic_dec_and_test(&apf->used))
+		kmem_cache_free(async_pf_cache, apf);
+}
+
+static int async_pf_get_ref(struct slow_work *work)
+{
+	struct kvm_async_pf *apf =
+		container_of(work, struct kvm_async_pf, work);
+
+	atomic_inc(&apf->used);
+	return 0;
+}
+
+static void async_pf_put_ref(struct slow_work *work)
+{
+	struct kvm_async_pf *apf =
+		container_of(work, struct kvm_async_pf, work);
+
+	kvm_put_kvm(apf->vcpu->kvm);
+	async_pf_work_free(apf);
+}
+
+static void async_pf_execute(struct slow_work *work)
+{
+	struct page *page;
+	struct kvm_async_pf *apf =
+		container_of(work, struct kvm_async_pf, work);
+	wait_queue_head_t *q = &apf->vcpu->wq;
+
+	might_sleep();
+
+	down_read(&apf->mm->mmap_sem);
+	get_user_pages(current, apf->mm, apf->addr, 1, 1, 0, &page, NULL);
+	up_read(&apf->mm->mmap_sem);
+
+	spin_lock(&apf->vcpu->async_pf_lock);
+	list_add_tail(&apf->link, &apf->vcpu->async_pf_done);
+	apf->page = page;
+	spin_unlock(&apf->vcpu->async_pf_lock);
+
+	trace_kvm_async_pf_completed(apf->addr, apf->page, apf->gva);
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
+	while (!list_empty(&vcpu->async_pf_done)) {
+		struct kvm_async_pf *work =
+			list_entry(vcpu->async_pf_done.next,
+				   typeof(*work), link);
+		list_del(&work->link);
+		put_page(work->page);
+		kmem_cache_free(async_pf_cache, work);
+	}
+}
+
+void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
+{
+	struct kvm_async_pf *work = vcpu->async_pf_work;
+
+	if (work) {
+		vcpu->async_pf_work = NULL;
+		if (work->page == NULL) {
+			kvm_arch_inject_async_page_not_present(vcpu, work);
+			return;
+		} else {
+			spin_lock(&vcpu->async_pf_lock);
+			list_del(&work->link);
+			spin_unlock(&vcpu->async_pf_lock);
+			put_page(work->page);
+			async_pf_work_free(work);
+		}
+	}
+
+	if (list_empty_careful(&vcpu->async_pf_done) ||
+	    !kvm_arch_can_inject_async_page_present(vcpu))
+		return;
+
+	spin_lock(&vcpu->async_pf_lock);
+	work = list_first_entry(&vcpu->async_pf_done, typeof(*work), link);
+	list_del(&work->link);
+	spin_unlock(&vcpu->async_pf_lock);
+
+	kvm_arch_inject_async_page_present(vcpu, work);
+
+	put_page(work->page);
+	async_pf_work_free(work);
+}
+
+int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
+		       struct kvm_arch_async_pf *arch)
+{
+	struct kvm_async_pf *work;
+
+	/* setup slow work */
+
+	/* do alloc atomic since if we are going to sleep anyway we
+	   may as well sleep faulting in page */
+	work = kmem_cache_zalloc(async_pf_cache, GFP_ATOMIC);
+	if (!work)
+		return 0;
+
+	atomic_set(&work->used, 1);
+	work->page = NULL;
+	work->vcpu = vcpu;
+	work->gva = gva;
+	work->addr = gfn_to_hva(vcpu->kvm, gfn);
+	work->arch = *arch;
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
+	vcpu->async_pf_work = work;
+	return 1;
+retry_sync:
+	kvm_put_kvm(work->vcpu->kvm);
+	mmdrop(work->mm);
+	kmem_cache_free(async_pf_cache, work);
+	return 0;
+}
+
+#endif
+
 /*
  * The vCPU has executed a HLT instruction with in-kernel mode enabled.
  */
@@ -2104,6 +2303,19 @@ int kvm_init(void *opaque, unsigned int vcpu_size,
 		goto out_free_5;
 	}
 
+#ifdef CONFIG_KVM_ASYNC_PF
+	async_pf_cache = KMEM_CACHE(kvm_async_pf, 0);
+
+	if (!async_pf_cache) {
+		r = -ENOMEM;
+		goto out_free_6;
+	}
+
+	r = slow_work_register_user();
+	if (r)
+		goto out_free;
+#endif
+
 	kvm_chardev_ops.owner = module;
 	kvm_vm_fops.owner = module;
 	kvm_vcpu_fops.owner = module;
@@ -2111,7 +2323,7 @@ int kvm_init(void *opaque, unsigned int vcpu_size,
 	r = misc_register(&kvm_dev);
 	if (r) {
 		printk(KERN_ERR "kvm: misc device register failed\n");
-		goto out_free;
+		goto out_unreg;
 	}
 
 	kvm_preempt_ops.sched_in = kvm_sched_in;
@@ -2121,7 +2333,13 @@ int kvm_init(void *opaque, unsigned int vcpu_size,
 
 	return 0;
 
+out_unreg:
+#ifdef CONFIG_KVM_ASYNC_PF
+	slow_work_unregister_user();
 out_free:
+	kmem_cache_destroy(async_pf_cache);
+out_free_6:
+#endif
 	kmem_cache_destroy(kvm_vcpu_cache);
 out_free_5:
 	sysdev_unregister(&kvm_sysdev);
@@ -2150,6 +2368,11 @@ void kvm_exit(void)
 	kvm_exit_debug();
 	misc_deregister(&kvm_dev);
 	kmem_cache_destroy(kvm_vcpu_cache);
+#ifdef CONFIG_KVM_ASYNC_PF
+	if (async_pf_cache)
+		kmem_cache_destroy(async_pf_cache);
+	slow_work_unregister_user();
+#endif
 	sysdev_unregister(&kvm_sysdev);
 	sysdev_class_unregister(&kvm_sysdev_class);
 	unregister_reboot_notifier(&kvm_reboot_notifier);
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
