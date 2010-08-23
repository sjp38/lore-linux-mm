Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CBCF06007EE
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 11:36:06 -0400 (EDT)
Date: Mon, 23 Aug 2010 18:35:49 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v5 03/12] Add async PF initialization to PV guest.
Message-ID: <20100823153549.GU10499@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
 <1279553462-7036-4-git-send-email-gleb@redhat.com>
 <4C729342.6070205@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C729342.6070205@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 06:26:58PM +0300, Avi Kivity wrote:
>  On 07/19/2010 06:30 PM, Gleb Natapov wrote:
> >Enable async PF in a guest if async PF capability is discovered.
> >
> >Signed-off-by: Gleb Natapov<gleb@redhat.com>
> >---
> >  arch/x86/include/asm/kvm_para.h |    5 +++
> >  arch/x86/kernel/kvm.c           |   68 +++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 73 insertions(+), 0 deletions(-)
> >
> >diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
> >index 5b05e9f..f1662d7 100644
> >--- a/arch/x86/include/asm/kvm_para.h
> >+++ b/arch/x86/include/asm/kvm_para.h
> >@@ -65,6 +65,11 @@ struct kvm_mmu_op_release_pt {
> >  	__u64 pt_phys;
> >  };
> >
> >+struct kvm_vcpu_pv_apf_data {
> >+	__u32 reason;
> >+	__u32 enabled;
> >+};
> >+
> 
> The guest will have to align this on a 64 byte boundary, should this
> be marked __aligned(64) here?
> 
I do __aligned(64) when I declare variable of that type:

static DEFINE_PER_CPU(struct kvm_vcpu_pv_apf_data, apf_reason) __aligned(64);

> >@@ -231,12 +235,72 @@ static void __init paravirt_ops_setup(void)
> >  #endif
> >  }
> >
> >+void __cpuinit kvm_guest_cpu_init(void)
> >+{
> >+	if (!kvm_para_available())
> >+		return;
> >+
> >+	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF)) {
> >+		u64 pa = __pa(&__get_cpu_var(apf_reason));
> >+
> >+		if (native_write_msr_safe(MSR_KVM_ASYNC_PF_EN,
> >+					  pa | KVM_ASYNC_PF_ENABLED, pa>>  32))
> >+			return;
> >+		__get_cpu_var(apf_reason).enabled = 1;
> >+		printk(KERN_INFO"KVM setup async PF for cpu %d\n",
> >+		       smp_processor_id());
> >+	}
> >+}
> 
> Need a way to disable apf from the guest kernel command line.
> 
OK.

> >+
> >+static int __cpuinit kvm_cpu_notify(struct notifier_block *self,
> >+				    unsigned long action, void *hcpu)
> >+{
> >+	switch (action) {
> >+	case CPU_ONLINE:
> >+	case CPU_ONLINE_FROZEN:
> >+		kvm_guest_cpu_init();
> >+		break;
> >+	default:
> >+		break;
> 
> Should we disable apf if the cpu is dying here?
> 
Why? Can CPU die with outstanding sleeping tasks?

> >+	}
> >+	return NOTIFY_OK;
> >+}
> >+
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
