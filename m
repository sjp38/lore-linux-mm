Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3C1506B02CD
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 05:34:12 -0400 (EDT)
Date: Tue, 24 Aug 2010 12:33:56 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v5 09/12] Retry fault before vmentry
Message-ID: <20100824093356.GY10499@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
 <1279553462-7036-10-git-send-email-gleb@redhat.com>
 <4C73900D.1080404@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C73900D.1080404@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 12:25:33PM +0300, Avi Kivity wrote:
>  On 07/19/2010 06:30 PM, Gleb Natapov wrote:
> >When page is swapped in it is mapped into guest memory only after guest
> >tries to access it again and generate another fault. To save this fault
> >we can map it immediately since we know that guest is going to access
> >the page.
> >
> >
> >
> >-static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
> >-				u32 error_code)
> >+static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
> >+			  bool sync)
> 
> 'sync' means something else in the shadow mmu.  Please rename to
> something longer, maybe 'apf_completion'.
> 
> Alternatively, split to two functions, a base function that doesn't
> do apf and a wrapper that handles apf.
> 
Will rename to something else.

> >@@ -505,6 +506,37 @@ out_unlock:
> >  	return 0;
> >  }
> >
> >+static int FNAME(page_fault_other_cr3)(struct kvm_vcpu *vcpu, gpa_t cr3,
> >+				       gva_t addr, u32 error_code)
> >+{
> >+	int r = 0;
> >+	gpa_t curr_cr3 = vcpu->arch.cr3;
> >+
> >+	if (curr_cr3 != cr3) {
> >+		/*
> >+		 * We do page fault on behalf of a process that is sleeping
> >+		 * because of async PF. PV guest takes reference to mm that cr3
> >+		 * belongs too, so it has to be valid here.
> >+		 */
> >+		kvm_set_cr3(vcpu, cr3);
> >+		if (kvm_mmu_reload(vcpu))
> >+			goto switch_cr3;
> >+	}
> 
> With nested virtualization, we need to switch cr0, cr4, and efer as well...
> 
On SVM or VMX or both?

> >+
> >+	r = FNAME(page_fault)(vcpu, addr, error_code, true);
> >+
> >+	if (kvm_check_request(KVM_REQ_MMU_SYNC, vcpu))
> >+		kvm_mmu_sync_roots(vcpu);
> 
> Why is this needed?
> 
http://www.mail-archive.com/kvm@vger.kernel.org/msg37827.html

 KVM_REQ_MMU_SYNC request generated here must be processed before
 switching to a different cr3 (otherwise vcpu_enter_guest will process it 
 with the wrong cr3 in place).


> >+
> >+switch_cr3:
> >+	if (curr_cr3 != vcpu->arch.cr3) {
> >+		kvm_set_cr3(vcpu, curr_cr3);
> >+		kvm_mmu_reload(vcpu);
> >+	}
> >+
> >+	return r;
> >+}
> 
> This has the nasty effect of flushing the TLB on AMD.
> 
What is more expansive reenter the guest and handle one more fault, or
flash TLB here?

> >+
> >  static void FNAME(invlpg)(struct kvm_vcpu *vcpu, gva_t gva)
> >  {
> >  	struct kvm_shadow_walk_iterator iterator;
> >diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> >index 2603cc4..5482db0 100644
> >--- a/arch/x86/kvm/x86.c
> >+++ b/arch/x86/kvm/x86.c
> >@@ -5743,6 +5743,15 @@ void kvm_set_rflags(struct kvm_vcpu *vcpu, unsigned long rflags)
> >  }
> >  EXPORT_SYMBOL_GPL(kvm_set_rflags);
> >
> >+void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
> >+			       struct kvm_async_pf *work)
> >+{
> >+	if (!vcpu->arch.mmu.page_fault_other_cr3 || is_error_page(work->page))
> >+		return;
> >+	vcpu->arch.mmu.page_fault_other_cr3(vcpu, work->arch.cr3, work->gva,
> >+					    work->arch.error_code);
> >+}
> >+
> >  static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
> >  {
> >  	if (unlikely(vcpu->arch.apf_memslot_ver !=
> >diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> >index f56e8ac..de1d5b6 100644
> >--- a/virt/kvm/kvm_main.c
> >+++ b/virt/kvm/kvm_main.c
> >@@ -1348,6 +1348,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
> >  			spin_lock(&vcpu->async_pf_lock);
> >  			list_del(&work->link);
> >  			spin_unlock(&vcpu->async_pf_lock);
> >+			kvm_arch_async_page_ready(vcpu, work);
> >  			put_page(work->page);
> >  			async_pf_work_free(work);
> >  			list_del(&work->queue);
> >@@ -1366,6 +1367,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
> >  	list_del(&work->queue);
> >  	vcpu->async_pf_queued--;
> >
> >+	kvm_arch_async_page_ready(vcpu, work);
> >  	kvm_arch_inject_async_page_present(vcpu, work);
> >
> >  	put_page(work->page);
> 
> 
> -- 
> error compiling committee.c: too many arguments to function

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
