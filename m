Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 96C726B0267
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 12:25:39 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v4 08/12] Inject asynchronous page fault into a guest if page is swapped out.
Date: Tue,  6 Jul 2010 19:24:56 +0300
Message-Id: <1278433500-29884-9-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-1-git-send-email-gleb@redhat.com>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

If guest access swapped out memory do not swap it in from vcpu thread
context. Setup slow work to do swapping and send async page fault to
a guest.

Allow async page fault injection only when guest is in user mode since
otherwise guest may be in non-sleepable context and will not be able to
reschedule.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |   16 +++
 arch/x86/kvm/Kconfig            |    2 +
 arch/x86/kvm/mmu.c              |   35 +++++-
 arch/x86/kvm/paging_tmpl.h      |   17 +++-
 arch/x86/kvm/x86.c              |   63 +++++++++-
 include/linux/kvm_host.h        |   31 +++++
 include/trace/events/kvm.h      |   60 +++++++++
 virt/kvm/Kconfig                |    3 +
 virt/kvm/kvm_main.c             |  263 ++++++++++++++++++++++++++++++++++++++-
 9 files changed, 481 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 245831a..db514ea 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -366,7 +366,9 @@ struct kvm_vcpu_arch {
 	cpumask_var_t wbinvd_dirty_mask;
 
 	u32 __user *apf_data;
+	u32 apf_memslot_ver;
 	u64 apf_msr_val;
+	u32 async_pf_id;
 };
 
 struct kvm_arch {
@@ -444,6 +446,8 @@ struct kvm_vcpu_stat {
 	u32 hypercalls;
 	u32 irq_injections;
 	u32 nmi_injections;
+	u32 apf_not_present;
+	u32 apf_present;
 };
 
 struct kvm_x86_ops {
@@ -528,6 +532,10 @@ struct kvm_x86_ops {
 	const struct trace_print_flags *exit_reasons_str;
 };
 
+struct kvm_arch_async_pf {
+	u32 token;
+};
+
 extern struct kvm_x86_ops *kvm_x86_ops;
 
 int kvm_mmu_module_init(void);
@@ -763,4 +771,12 @@ void kvm_set_shared_msr(unsigned index, u64 val, u64 mask);
 
 bool kvm_is_linear_rip(struct kvm_vcpu *vcpu, unsigned long linear_rip);
 
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
index 970bbd4..2461284 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -28,6 +28,8 @@ config KVM
 	select HAVE_KVM_IRQCHIP
 	select HAVE_KVM_EVENTFD
 	select KVM_APIC_ARCHITECTURE
+	select KVM_ASYNC_PF
+	select SLOW_WORK
 	select USER_RETURN_NOTIFIER
 	select KVM_MMIO
 	---help---
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index c515753..a49565b 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -21,6 +21,7 @@
 #include "mmu.h"
 #include "x86.h"
 #include "kvm_cache_regs.h"
+#include "x86.h"
 
 #include <linux/kvm_host.h>
 #include <linux/types.h>
@@ -2264,6 +2265,21 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
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
@@ -2272,6 +2288,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 	int level;
 	gfn_t gfn = gpa >> PAGE_SHIFT;
 	unsigned long mmu_seq;
+	bool async;
 
 	ASSERT(vcpu);
 	ASSERT(VALID_PAGE(vcpu->arch.mmu.root_hpa));
@@ -2286,7 +2303,23 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
-	pfn = gfn_to_pfn(vcpu->kvm, gfn);
+
+	if (can_do_async_pf(vcpu)) {
+		pfn = gfn_to_pfn_async(vcpu->kvm, gfn, &async);
+		trace_kvm_try_async_get_page(async, pfn);
+	} else {
+do_sync:
+		async = false;
+		pfn = gfn_to_pfn(vcpu->kvm, gfn);
+	}
+
+	if (async) {
+		if (!kvm_arch_setup_async_pf(vcpu, gpa, gfn))
+			goto do_sync;
+		return 0;
+	}
+
+	/* mmio */
 	if (is_error_pfn(pfn))
 		return kvm_handle_bad_page(vcpu->kvm, gfn, pfn);
 	spin_lock(&vcpu->kvm->mmu_lock);
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index 3350c02..26d6b74 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -423,6 +423,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	pfn_t pfn;
 	int level = PT_PAGE_TABLE_LEVEL;
 	unsigned long mmu_seq;
+	bool async;
 
 	pgprintk("%s: addr %lx err %x\n", __func__, addr, error_code);
 	kvm_mmu_audit(vcpu, "pre page fault");
@@ -454,7 +455,21 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
-	pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
+
+	if (can_do_async_pf(vcpu)) {
+		pfn = gfn_to_pfn_async(vcpu->kvm, walker.gfn, &async);
+		trace_kvm_try_async_get_page(async, pfn);
+	} else {
+do_sync:
+		async = false;
+		pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
+	}
+
+	if (async) {
+		if (!kvm_arch_setup_async_pf(vcpu, addr, walker.gfn))
+			goto do_sync;
+		return 0;
+	}
 
 	/* mmio */
 	if (is_error_pfn(pfn))
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 744f8c1..6b7542f 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -118,6 +118,8 @@ static DEFINE_PER_CPU(struct kvm_shared_msrs, shared_msrs);
 struct kvm_stats_debugfs_item debugfs_entries[] = {
 	{ "pf_fixed", VCPU_STAT(pf_fixed) },
 	{ "pf_guest", VCPU_STAT(pf_guest) },
+	{ "apf_not_present", VCPU_STAT(apf_not_present) },
+	{ "apf_present", VCPU_STAT(apf_present) },
 	{ "tlb_flush", VCPU_STAT(tlb_flush) },
 	{ "invlpg", VCPU_STAT(invlpg) },
 	{ "exits", VCPU_STAT(exits) },
@@ -1226,6 +1228,7 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
 
 	if (!(data & KVM_ASYNC_PF_ENABLED)) {
 		vcpu->arch.apf_data = NULL;
+		kvm_clear_async_pf_completion_queue(vcpu);
 		return 0;
 	}
 
@@ -1240,6 +1243,8 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
 		vcpu->arch.apf_data = NULL;
 		return 1;
 	}
+	vcpu->arch.apf_memslot_ver = vcpu->kvm->memslot_version;
+	kvm_async_pf_wakeup_all(vcpu);
 	return 0;
 }
 
@@ -4721,6 +4726,8 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
 	if (unlikely(r))
 		goto out;
 
+	kvm_check_async_pf_completion(vcpu);
+
 	preempt_disable();
 
 	kvm_x86_ops->prepare_guest_switch(vcpu);
@@ -5393,6 +5400,8 @@ int kvm_arch_vcpu_reset(struct kvm_vcpu *vcpu)
 	vcpu->arch.apf_data = NULL;
 	vcpu->arch.apf_msr_val = 0;
 
+	kvm_clear_async_pf_completion_queue(vcpu);
+
 	return kvm_x86_ops->vcpu_reset(vcpu);
 }
 
@@ -5534,8 +5543,10 @@ static void kvm_free_vcpus(struct kvm *kvm)
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
 
@@ -5647,6 +5658,7 @@ void kvm_arch_flush_shadow(struct kvm *kvm)
 int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu)
 {
 	return vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE
+		|| !list_empty_careful(&vcpu->async_pf_done)
 		|| vcpu->arch.mp_state == KVM_MP_STATE_SIPI_RECEIVED
 		|| vcpu->arch.nmi_pending ||
 		(kvm_arch_interrupt_allowed(vcpu) &&
@@ -5704,6 +5716,55 @@ void kvm_set_rflags(struct kvm_vcpu *vcpu, unsigned long rflags)
 }
 EXPORT_SYMBOL_GPL(kvm_set_rflags);
 
+static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
+{
+	if (unlikely(vcpu->arch.apf_memslot_ver !=
+		     vcpu->kvm->memslot_version)) {
+		u64 gpa = vcpu->arch.apf_msr_val & ~0x3f;
+		unsigned long addr;
+		int offset = offset_in_page(gpa);
+
+		addr = gfn_to_hva(vcpu->kvm, gpa >> PAGE_SHIFT);
+		vcpu->arch.apf_data = (u32 __user*)(addr + offset);
+		if (kvm_is_error_hva(addr)) {
+			vcpu->arch.apf_data = NULL;
+			return -EFAULT;
+		}
+	}
+
+	return put_user(val, vcpu->arch.apf_data);
+}
+
+void kvm_arch_inject_async_page_not_present(struct kvm_vcpu *vcpu,
+					    struct kvm_async_pf *work)
+{
+	if (!apf_put_user(vcpu, KVM_PV_REASON_PAGE_NOT_PRESENT)) {
+		kvm_inject_page_fault(vcpu, work->arch.token, 0);
+		++vcpu->stat.apf_not_present;
+		trace_kvm_send_async_pf(work->arch.token, work->gva,
+					KVM_PV_REASON_PAGE_NOT_PRESENT);
+	}
+}
+
+void kvm_arch_inject_async_page_present(struct kvm_vcpu *vcpu,
+					struct kvm_async_pf *work)
+{
+	if (is_error_page(work->page))
+		work->arch.token = ~0; /* broadcast wakeup */
+	if (!apf_put_user(vcpu, KVM_PV_REASON_PAGE_READY)) {
+		kvm_inject_page_fault(vcpu, work->arch.token, 0);
+		++vcpu->stat.apf_present;
+		trace_kvm_send_async_pf(work->arch.token, work->gva,
+					KVM_PV_REASON_PAGE_READY);
+	}
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
index 64f62f1..09c646f 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -16,6 +16,7 @@
 #include <linux/mm.h>
 #include <linux/preempt.h>
 #include <linux/msi.h>
+#include <linux/slow-work.h>
 #include <asm/signal.h>
 
 #include <linux/kvm.h>
@@ -73,6 +74,27 @@ int kvm_io_bus_register_dev(struct kvm *kvm, enum kvm_bus bus_idx,
 int kvm_io_bus_unregister_dev(struct kvm *kvm, enum kvm_bus bus_idx,
 			      struct kvm_io_device *dev);
 
+#ifdef CONFIG_KVM_ASYNC_PF
+struct kvm_async_pf {
+	struct slow_work work;
+	struct list_head link;
+	struct list_head queue;
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
+int kvm_async_pf_wakeup_all(struct kvm_vcpu *vcpu);
+#endif
+
 struct kvm_vcpu {
 	struct kvm *kvm;
 #ifdef CONFIG_PREEMPT_NOTIFIERS
@@ -103,6 +125,14 @@ struct kvm_vcpu {
 	gpa_t mmio_phys_addr;
 #endif
 
+#ifdef CONFIG_KVM_ASYNC_PF
+	u32 async_pf_queued;
+	struct list_head async_pf_queue;
+	struct list_head async_pf_done;
+	spinlock_t async_pf_lock;
+	struct kvm_async_pf *async_pf_work;
+#endif
+
 	struct kvm_vcpu_arch arch;
 };
 
@@ -296,6 +326,7 @@ void kvm_release_page_dirty(struct page *page);
 void kvm_set_page_dirty(struct page *page);
 void kvm_set_page_accessed(struct page *page);
 
+pfn_t gfn_to_pfn_async(struct kvm *kvm, gfn_t gfn, bool *async);
 pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn);
 pfn_t gfn_to_pfn_memslot(struct kvm *kvm,
 			 struct kvm_memory_slot *slot, gfn_t gfn);
diff --git a/include/trace/events/kvm.h b/include/trace/events/kvm.h
index 6dd3a51..6d9f0c2 100644
--- a/include/trace/events/kvm.h
+++ b/include/trace/events/kvm.h
@@ -185,6 +185,66 @@ TRACE_EVENT(kvm_age_page,
 		  __entry->referenced ? "YOUNG" : "OLD")
 );
 
+#ifdef CONFIG_KVM_ASYNC_PF
+TRACE_EVENT(
+	kvm_try_async_get_page,
+	TP_PROTO(bool async, u64 pfn),
+	TP_ARGS(async, pfn),
+
+	TP_STRUCT__entry(
+		__field(__u64, pfn)
+		),
+
+	TP_fast_assign(
+		__entry->pfn = (!async) ? pfn : (u64)-1;
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
index 7f1178f..f63ccb0 100644
--- a/virt/kvm/Kconfig
+++ b/virt/kvm/Kconfig
@@ -15,3 +15,6 @@ config KVM_APIC_ARCHITECTURE
 
 config KVM_MMIO
        bool
+
+config KVM_ASYNC_PF
+       bool
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 733558c..0656054 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -78,6 +78,11 @@ static atomic_t hardware_enable_failed;
 struct kmem_cache *kvm_vcpu_cache;
 EXPORT_SYMBOL_GPL(kvm_vcpu_cache);
 
+#ifdef CONFIG_KVM_ASYNC_PF
+#define ASYNC_PF_PER_VCPU 100
+static struct kmem_cache *async_pf_cache;
+#endif
+
 static __read_mostly struct preempt_ops kvm_preempt_ops;
 
 struct dentry *kvm_debugfs_dir;
@@ -183,6 +188,11 @@ int kvm_vcpu_init(struct kvm_vcpu *vcpu, struct kvm *kvm, unsigned id)
 	vcpu->kvm = kvm;
 	vcpu->vcpu_id = id;
 	init_waitqueue_head(&vcpu->wq);
+#ifdef CONFIG_KVM_ASYNC_PF
+	INIT_LIST_HEAD(&vcpu->async_pf_done);
+	INIT_LIST_HEAD(&vcpu->async_pf_queue);
+	spin_lock_init(&vcpu->async_pf_lock);
+#endif
 
 	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
 	if (!page) {
@@ -935,7 +945,7 @@ unsigned long gfn_to_hva(struct kvm *kvm, gfn_t gfn)
 }
 EXPORT_SYMBOL_GPL(gfn_to_hva);
 
-static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr)
+static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr, bool *async)
 {
 	struct page *page[1];
 	int npages;
@@ -943,7 +953,19 @@ static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr)
 
 	might_sleep();
 
-	npages = get_user_pages_fast(addr, 1, 1, page);
+	if (async) {
+#ifdef CONFIG_X86
+		npages = __get_user_pages_fast(addr, 1, 1, page);
+#endif
+		if (unlikely(npages != 1)) {
+			down_read(&current->mm->mmap_sem);
+			npages = get_user_pages_noio(current, current->mm,
+						     addr, 1, 1, 0, page,
+						     NULL);
+			up_read(&current->mm->mmap_sem);
+		}
+	} else
+		npages = get_user_pages_fast(addr, 1, 1, page);
 
 	if (unlikely(npages != 1)) {
 		struct vm_area_struct *vma;
@@ -959,6 +981,9 @@ static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr)
 
 		if (vma == NULL || addr < vma->vm_start ||
 		    !(vma->vm_flags & VM_PFNMAP)) {
+			if (async && !(vma->vm_flags & VM_PFNMAP) &&
+			    (vma->vm_flags & VM_WRITE))
+				*async = true;
 			up_read(&current->mm->mmap_sem);
 			get_page(bad_page);
 			return page_to_pfn(bad_page);
@@ -973,25 +998,37 @@ static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr)
 	return pfn;
 }
 
-pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn)
+static inline pfn_t __gfn_to_pfn(struct kvm *kvm, gfn_t gfn, bool *async)
 {
 	unsigned long addr;
 
+	if (async)
+		*async = false;
 	addr = gfn_to_hva(kvm, gfn);
 	if (kvm_is_error_hva(addr)) {
 		get_page(bad_page);
 		return page_to_pfn(bad_page);
 	}
 
-	return hva_to_pfn(kvm, addr);
+	return hva_to_pfn(kvm, addr, async);
+}
+
+pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn)
+{
+	return __gfn_to_pfn(kvm, gfn, NULL);
 }
 EXPORT_SYMBOL_GPL(gfn_to_pfn);
 
+pfn_t gfn_to_pfn_async(struct kvm *kvm, gfn_t gfn, bool *async)
+{
+	return __gfn_to_pfn(kvm, gfn, async);
+}
+
 pfn_t gfn_to_pfn_memslot(struct kvm *kvm,
 			 struct kvm_memory_slot *slot, gfn_t gfn)
 {
 	unsigned long addr = gfn_to_hva_memslot(slot, gfn);
-	return hva_to_pfn(kvm, addr);
+	return hva_to_pfn(kvm, addr, NULL);
 }
 
 struct page *gfn_to_page(struct kvm *kvm, gfn_t gfn)
@@ -1204,6 +1241,196 @@ void mark_page_dirty(struct kvm *kvm, gfn_t gfn)
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
+	/* cancel outstanding slow work item */
+	while (!list_empty(&vcpu->async_pf_queue)) {
+		struct kvm_async_pf *work =
+			list_entry(vcpu->async_pf_queue.next,
+				   typeof(*work), queue);
+		slow_work_cancel(&work->work);
+		list_del(&work->queue);
+		if (!work->page) /* work was canceled */
+			kmem_cache_free(async_pf_cache, work);
+	}
+
+	spin_lock(&vcpu->async_pf_lock);
+	while (!list_empty(&vcpu->async_pf_done)) {
+		struct kvm_async_pf *work =
+			list_entry(vcpu->async_pf_done.next,
+				   typeof(*work), link);
+		list_del(&work->link);
+		put_page(work->page);
+		kmem_cache_free(async_pf_cache, work);
+	}
+	spin_unlock(&vcpu->async_pf_lock);
+
+	vcpu->async_pf_queued = 0;
+	vcpu->async_pf_work = NULL;
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
+			list_del(&work->queue);
+			vcpu->async_pf_queued--;
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
+	list_del(&work->queue);
+	vcpu->async_pf_queued--;
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
+	if (vcpu->async_pf_queued >= ASYNC_PF_PER_VCPU)
+		return 0;
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
+	list_add_tail(&work->queue, &vcpu->async_pf_queue);
+	vcpu->async_pf_queued++;
+	return 1;
+retry_sync:
+	kvm_put_kvm(work->vcpu->kvm);
+	mmdrop(work->mm);
+	kmem_cache_free(async_pf_cache, work);
+	return 0;
+}
+
+int kvm_async_pf_wakeup_all(struct kvm_vcpu *vcpu)
+{
+	struct kvm_async_pf *work;
+
+	if (!list_empty(&vcpu->async_pf_done))
+		return 0;
+
+	work = kmem_cache_zalloc(async_pf_cache, GFP_ATOMIC);
+	if (!work)
+		return -ENOMEM;
+
+	atomic_set(&work->used, 1);
+	work->page = bad_page;
+	get_page(bad_page);
+	INIT_LIST_HEAD(&work->queue); /* for list_del to work */
+
+	list_add_tail(&work->link, &vcpu->async_pf_done);
+	vcpu->async_pf_queued++;
+	return 0;
+}
+#endif
+
 /*
  * The vCPU has executed a HLT instruction with in-kernel mode enabled.
  */
@@ -2267,6 +2494,19 @@ int kvm_init(void *opaque, unsigned vcpu_size, unsigned vcpu_align,
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
+	r = slow_work_register_user(THIS_MODULE);
+	if (r)
+		goto out_free;
+#endif
+
 	kvm_chardev_ops.owner = module;
 	kvm_vm_fops.owner = module;
 	kvm_vcpu_fops.owner = module;
@@ -2274,7 +2514,7 @@ int kvm_init(void *opaque, unsigned vcpu_size, unsigned vcpu_align,
 	r = misc_register(&kvm_dev);
 	if (r) {
 		printk(KERN_ERR "kvm: misc device register failed\n");
-		goto out_free;
+		goto out_unreg;
 	}
 
 	kvm_preempt_ops.sched_in = kvm_sched_in;
@@ -2284,7 +2524,13 @@ int kvm_init(void *opaque, unsigned vcpu_size, unsigned vcpu_align,
 
 	return 0;
 
+out_unreg:
+#ifdef CONFIG_KVM_ASYNC_PF
+	slow_work_unregister_user(THIS_MODULE);
 out_free:
+	kmem_cache_destroy(async_pf_cache);
+out_free_6:
+#endif
 	kmem_cache_destroy(kvm_vcpu_cache);
 out_free_5:
 	sysdev_unregister(&kvm_sysdev);
@@ -2314,6 +2560,11 @@ void kvm_exit(void)
 	kvm_exit_debug();
 	misc_deregister(&kvm_dev);
 	kmem_cache_destroy(kvm_vcpu_cache);
+#ifdef CONFIG_KVM_ASYNC_PF
+	if (async_pf_cache)
+		kmem_cache_destroy(async_pf_cache);
+	slow_work_unregister_user(THIS_MODULE);
+#endif
 	sysdev_unregister(&kvm_sysdev);
 	sysdev_class_unregister(&kvm_sysdev_class);
 	unregister_reboot_notifier(&kvm_reboot_notifier);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
