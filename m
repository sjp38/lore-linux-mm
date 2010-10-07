Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CAAE36B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 08:51:05 -0400 (EDT)
Message-ID: <4CADC229.9040402@redhat.com>
Date: Thu, 07 Oct 2010 14:50:49 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 07/12] Add async PF initialization to PV guest.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-8-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-8-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> Enable async PF in a guest if async PF capability is discovered.
>
>
> +void __cpuinit kvm_guest_cpu_init(void)
> +{
> +	if (!kvm_para_available())
> +		return;
> +
> +	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF)&&  kvmapf) {
> +		u64 pa = __pa(&__get_cpu_var(apf_reason));
> +
> +		if (native_write_msr_safe(MSR_KVM_ASYNC_PF_EN,
> +					  pa | KVM_ASYNC_PF_ENABLED, pa>>  32))

native_ versions of processor accessors shouldn't be used generally.

Also, the MSR isn't documented to fail on valid input, so you can use a 
normal wrmsrl() here.

> +			return;
> +		__get_cpu_var(apf_reason).enabled = 1;
> +		printk(KERN_INFO"KVM setup async PF for cpu %d\n",
> +		       smp_processor_id());
> +	}
> +}
> +
>
> +static int kvm_pv_reboot_notify(struct notifier_block *nb,
> +				unsigned long code, void *unused)
> +{
> +	if (code == SYS_RESTART)
> +		on_each_cpu(kvm_pv_disable_apf, NULL, 1);
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block kvm_pv_reboot_nb = {
> +	.notifier_call = kvm_pv_reboot_notify,
> +};

Does this handle kexec?

> +
> +static void kvm_guest_cpu_notify(void *dummy)
> +{
> +	if (!dummy)
> +		kvm_guest_cpu_init();
> +	else
> +		kvm_pv_disable_apf(NULL);
> +}

Why are you making decisions based on a dummy input?

The whole thing looks strange.  Use two functions?


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
