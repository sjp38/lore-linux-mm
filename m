Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 88FE96B0082
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 06:56:36 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 08/11] Add "wait for page" hypercall.
Date: Sun,  1 Nov 2009 13:56:27 +0200
Message-Id: <1257076590-29559-9-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-1-git-send-email-gleb@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

We want to be able to inject async pagefault into guest event if a guest
is not executing userspace code. But in this case guest may receive
async page fault in non-sleepable context. In this case it will be
able to make "wait for page" hypercall vcpu will be put to sleep until
page is swapped in and guest can continue without reschedule.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    2 ++
 arch/x86/kvm/mmu.c              |   35 ++++++++++++++++++++++++++++++++++-
 arch/x86/kvm/mmutrace.h         |   19 +++++++++++++++++++
 arch/x86/kvm/x86.c              |    5 +++++
 include/linux/kvm_para.h        |    1 +
 5 files changed, 61 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 6c781ea..d404b14 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -456,6 +456,7 @@ struct kvm_vm_stat {
 
 struct kvm_vcpu_stat {
 	u32 pf_fixed;
+	u32 pf_async_wait;
 	u32 pf_guest;
 	u32 tlb_flush;
 	u32 invlpg;
@@ -676,6 +677,7 @@ void kvm_mmu_unload(struct kvm_vcpu *vcpu);
 void kvm_mmu_sync_roots(struct kvm_vcpu *vcpu);
 void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu);
 void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu);
+int kvm_pv_wait_for_async_pf(struct kvm_vcpu *vcpu);
 
 int kvm_emulate_hypercall(struct kvm_vcpu *vcpu);
 
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index abe1ce9..3d33994 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2281,7 +2281,7 @@ static void async_pf_execute(struct slow_work *work)
 					apf->gva);
 
 	if (waitqueue_active(q))
-		wake_up_interruptible(q);
+		wake_up(q);
 
 	mmdrop(apf->mm);
 }
@@ -2351,6 +2351,39 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 	async_pf_work_free(work);
 }
 
+static bool kvm_asyc_pf_is_done(struct kvm_vcpu *vcpu)
+{
+	struct kvm_mmu_async_pf *p, *node;
+	bool found = false;
+
+	spin_lock(&vcpu->arch.mmu_async_pf_lock);
+	list_for_each_entry_safe(p, node, &vcpu->arch.mmu_async_pf_done, link) {
+		if (p->guest_task != vcpu->arch.pv_shm->current_task)
+			continue;
+		list_del(&p->link);
+		found = true;
+		break;
+	}
+	spin_unlock(&vcpu->arch.mmu_async_pf_lock);
+	if (found) {
+		vcpu->arch.mmu.page_fault(vcpu, (gpa_t)-1, p->gva,
+					  p->error_code);
+		put_page(p->page);
+		async_pf_work_free(p);
+		trace_kvm_mmu_async_pf_wait(vcpu->arch.pv_shm->current_task, 0);
+	}
+	return found;
+}
+
+int kvm_pv_wait_for_async_pf(struct kvm_vcpu *vcpu)
+{
+	++vcpu->stat.pf_async_wait;
+	trace_kvm_mmu_async_pf_wait(vcpu->arch.pv_shm->current_task, 1);
+	wait_event(vcpu->wq, kvm_asyc_pf_is_done(vcpu));
+
+	return 0;
+}
+
 static bool can_do_async_pf(struct kvm_vcpu *vcpu)
 {
 	struct kvm_segment kvm_seg;
diff --git a/arch/x86/kvm/mmutrace.h b/arch/x86/kvm/mmutrace.h
index d6dd63c..a74f718 100644
--- a/arch/x86/kvm/mmutrace.h
+++ b/arch/x86/kvm/mmutrace.h
@@ -274,6 +274,25 @@ TRACE_EVENT(
 		  __entry->gva, __entry->address, page_to_pfn(__entry->page))
 );
 
+TRACE_EVENT(
+	kvm_mmu_async_pf_wait,
+	TP_PROTO(u64 task, bool wait),
+	TP_ARGS(task, wait),
+
+	TP_STRUCT__entry(
+		__field(u64, task)
+		__field(bool, wait)
+		),
+
+	TP_fast_assign(
+		__entry->task = task;
+		__entry->wait = wait;
+		),
+
+	TP_printk("task %#llx %s", __entry->task, __entry->wait ?
+		  "waits for PF" : "end wait for PF")
+);
+
 #endif /* _TRACE_KVMMMU_H */
 
 /* This part must be outside protection */
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index e6bd3ad..9208796 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -109,6 +109,7 @@ static DEFINE_PER_CPU(struct kvm_shared_msrs, shared_msrs);
 
 struct kvm_stats_debugfs_item debugfs_entries[] = {
 	{ "pf_fixed", VCPU_STAT(pf_fixed) },
+	{ "pf_async_wait", VCPU_STAT(pf_async_wait) },
 	{ "pf_guest", VCPU_STAT(pf_guest) },
 	{ "tlb_flush", VCPU_STAT(tlb_flush) },
 	{ "invlpg", VCPU_STAT(invlpg) },
@@ -3484,6 +3485,10 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 	case KVM_HC_SETUP_SHM:
 		r = kvm_pv_setup_shm(vcpu, a0, a1, a2, &ret);
 		break;
+	case KVM_HC_WAIT_FOR_ASYNC_PF:
+		r = kvm_pv_wait_for_async_pf(vcpu);
+		ret = 0;
+		break;
 	default:
 		ret = -KVM_ENOSYS;
 		break;
diff --git a/include/linux/kvm_para.h b/include/linux/kvm_para.h
index 1c37495..50296a6 100644
--- a/include/linux/kvm_para.h
+++ b/include/linux/kvm_para.h
@@ -19,6 +19,7 @@
 #define KVM_HC_VAPIC_POLL_IRQ		1
 #define KVM_HC_MMU_OP			2
 #define KVM_HC_SETUP_SHM		3
+#define KVM_HC_WAIT_FOR_ASYNC_PF	4
 
 /*
  * hypercalls use architecture specific
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
