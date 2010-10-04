Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 05C6D6B0087
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 11:56:46 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v6 09/12] Inject asynchronous page fault into a PV guest if page is swapped out.
Date: Mon,  4 Oct 2010 17:56:31 +0200
Message-Id: <1286207794-16120-10-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-1-git-send-email-gleb@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

Send async page fault to a PV guest if it accesses swapped out memory.
Guest will choose another task to run upon receiving the fault.

Allow async page fault injection only when guest is in user mode since
otherwise guest may be in non-sleepable context and will not be able
to reschedule.

Vcpu will be halted if guest will fault on the same page again or if
vcpu executes kernel code.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    3 ++
 arch/x86/kvm/mmu.c              |    1 +
 arch/x86/kvm/x86.c              |   49 ++++++++++++++++++++++++++++++++------
 include/trace/events/kvm.h      |   17 ++++++++----
 virt/kvm/async_pf.c             |    3 +-
 5 files changed, 58 insertions(+), 15 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index de31551..2f6fc87 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -419,6 +419,7 @@ struct kvm_vcpu_arch {
 		gfn_t gfns[roundup_pow_of_two(ASYNC_PF_PER_VCPU)];
 		struct gfn_to_hva_cache data;
 		u64 msr_val;
+		u32 id;
 	} apf;
 };
 
@@ -594,6 +595,7 @@ struct kvm_x86_ops {
 };
 
 struct kvm_arch_async_pf {
+	u32 token;
 	gfn_t gfn;
 };
 
@@ -842,6 +844,7 @@ void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
 				 struct kvm_async_pf *work);
 void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
 			       struct kvm_async_pf *work);
+bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu);
 extern bool kvm_find_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn);
 
 #endif /* _ASM_X86_KVM_HOST_H */
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index d85fda8..de53cab 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2580,6 +2580,7 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
 int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
 {
 	struct kvm_arch_async_pf arch;
+	arch.token = (vcpu->arch.apf.id++ << 12) | vcpu->vcpu_id;
 	arch.gfn = gfn;
 
 	return kvm_setup_async_pf(vcpu, gva, gfn, &arch);
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 3e123ab..0e69d37 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -6225,25 +6225,58 @@ static void kvm_del_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn)
 	}
 }
 
+static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
+{
+
+	return kvm_write_guest_cached(vcpu->kvm, &vcpu->arch.apf.data, &val,
+				      sizeof(val));
+}
+
 void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
 				     struct kvm_async_pf *work)
 {
-	vcpu->arch.mp_state = KVM_MP_STATE_HALTED;
-
-	if (work == kvm_double_apf)
+	if (work == kvm_double_apf) {
 		trace_kvm_async_pf_doublefault(kvm_rip_read(vcpu));
-	else {
-		trace_kvm_async_pf_not_present(work->gva);
-
+		vcpu->arch.mp_state = KVM_MP_STATE_HALTED;
+	} else {
+		trace_kvm_async_pf_not_present(work->arch.token, work->gva);
 		kvm_add_async_pf_gfn(vcpu, work->arch.gfn);
+
+		if (!(vcpu->arch.apf.msr_val & KVM_ASYNC_PF_ENABLED) ||
+		    kvm_x86_ops->get_cpl(vcpu) == 0)
+			vcpu->arch.mp_state = KVM_MP_STATE_HALTED;
+		else if (!apf_put_user(vcpu, KVM_PV_REASON_PAGE_NOT_PRESENT)) {
+			vcpu->arch.fault.error_code = 0;
+			vcpu->arch.fault.address = work->arch.token;
+			kvm_inject_page_fault(vcpu);
+		}
 	}
 }
 
 void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
 				 struct kvm_async_pf *work)
 {
-	trace_kvm_async_pf_ready(work->gva);
-	kvm_del_async_pf_gfn(vcpu, work->arch.gfn);
+	trace_kvm_async_pf_ready(work->arch.token, work->gva);
+	if (is_error_page(work->page))
+		work->arch.token = ~0; /* broadcast wakeup */
+	else
+		kvm_del_async_pf_gfn(vcpu, work->arch.gfn);
+
+	if ((vcpu->arch.apf.msr_val & KVM_ASYNC_PF_ENABLED) &&
+	    !apf_put_user(vcpu, KVM_PV_REASON_PAGE_READY)) {
+		vcpu->arch.fault.error_code = 0;
+		vcpu->arch.fault.address = work->arch.token;
+		kvm_inject_page_fault(vcpu);
+	}
+}
+
+bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu)
+{
+	if (!(vcpu->arch.apf.msr_val & KVM_ASYNC_PF_ENABLED))
+		return true;
+	else
+		return !kvm_event_needs_reinjection(vcpu) &&
+			kvm_x86_ops->interrupt_allowed(vcpu);
 }
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_exit);
diff --git a/include/trace/events/kvm.h b/include/trace/events/kvm.h
index bcc69b2..dd44aa3 100644
--- a/include/trace/events/kvm.h
+++ b/include/trace/events/kvm.h
@@ -204,34 +204,39 @@ TRACE_EVENT(
 
 TRACE_EVENT(
 	kvm_async_pf_not_present,
-	TP_PROTO(u64 gva),
-	TP_ARGS(gva),
+	TP_PROTO(u64 token, u64 gva),
+	TP_ARGS(token, gva),
 
 	TP_STRUCT__entry(
+		__field(__u64, token)
 		__field(__u64, gva)
 		),
 
 	TP_fast_assign(
+		__entry->token = token;
 		__entry->gva = gva;
 		),
 
-	TP_printk("gva %#llx not present", __entry->gva)
+	TP_printk("token %#llx gva %#llx not present", __entry->token,
+		  __entry->gva)
 );
 
 TRACE_EVENT(
 	kvm_async_pf_ready,
-	TP_PROTO(u64 gva),
-	TP_ARGS(gva),
+	TP_PROTO(u64 token, u64 gva),
+	TP_ARGS(token, gva),
 
 	TP_STRUCT__entry(
+		__field(__u64, token)
 		__field(__u64, gva)
 		),
 
 	TP_fast_assign(
+		__entry->token = token;
 		__entry->gva = gva;
 		),
 
-	TP_printk("gva %#llx ready", __entry->gva)
+	TP_printk("token %#llx gva %#llx ready", __entry->token, __entry->gva)
 );
 
 TRACE_EVENT(
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index 44f4005..d1cd495 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -138,7 +138,8 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 		}
 	}
 
-	if (list_empty_careful(&vcpu->async_pf.done))
+	if (list_empty_careful(&vcpu->async_pf.done) ||
+	    !kvm_arch_can_inject_async_page_present(vcpu))
 		return;
 
 	spin_lock(&vcpu->async_pf.lock);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
