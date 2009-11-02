Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 429126B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 07:18:57 -0500 (EST)
Message-ID: <4AEECE2E.2050609@redhat.com>
Date: Mon, 02 Nov 2009 14:18:54 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/11] Add shared memory hypercall to PV Linux guest.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-2-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-2-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 11/01/2009 01:56 PM, Gleb Natapov wrote:
> Add hypercall that allows guest and host to setup per cpu shared
> memory.
>
>    

Better to set this up as an MSR (with bit zero enabling, bits 1-5 
features, and 64-byte alignment).  This allows auto-reset on INIT and 
live migration using the existing MSR save/restore infrastructure.

>   arch/x86/include/asm/kvm_host.h |    3 +
>   arch/x86/include/asm/kvm_para.h |   11 +++++
>   arch/x86/kernel/kvm.c           |   82 +++++++++++++++++++++++++++++++++++++++
>   arch/x86/kernel/setup.c         |    1 +
>   arch/x86/kernel/smpboot.c       |    3 +
>   arch/x86/kvm/x86.c              |   70 +++++++++++++++++++++++++++++++++
>   include/linux/kvm.h             |    1 +
>   include/linux/kvm_para.h        |    4 ++
>   8 files changed, 175 insertions(+), 0 deletions(-)
>    

Please separate into guest and host patches.

> +#define KVM_PV_SHM_VERSION 1
>    

versions = bad, feature bits = good

> +
> +#define KVM_PV_SHM_FEATURES_ASYNC_PF		(1<<  0)
> +
> +struct kvm_vcpu_pv_shm {
> +	__u64 features;
> +	__u64 reason;
> +	__u64 param;
> +};
> +
>    

Some documentation for this?

Also, the name should reflect the pv pagefault use.  For other uses we 
can register other areas.

>   #define MMU_QUEUE_SIZE 1024
>
> @@ -37,6 +41,7 @@ struct kvm_para_state {
>   };
>
>   static DEFINE_PER_CPU(struct kvm_para_state, para_state);
> +static DEFINE_PER_CPU(struct kvm_vcpu_pv_shm *, kvm_vcpu_pv_shm);
>    

Easier to put the entire structure here, not a pointer.

> +
> +static int kvm_pv_reboot_notify(struct notifier_block *nb,
> +				unsigned long code, void *unused)
> +{
> +	if (code == SYS_RESTART)
> +		on_each_cpu(kvm_pv_unregister_shm, NULL, 1);
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block kvm_pv_reboot_nb = {
> +        .notifier_call = kvm_pv_reboot_notify,
> +};
>    

Is this called on kexec, or do we need another hook?

> +static int kvm_pv_setup_shm(struct kvm_vcpu *vcpu, unsigned long gpa,
> +			    unsigned long size, unsigned long version,
> +			    unsigned long *ret)
> +{
> +	addr = gfn_to_hva(vcpu->kvm, gfn);
> +	if (kvm_is_error_hva(addr))
> +		return -EFAULT;
> +
> +	/* pin page with pv shared memory */
> +	down_read(&mm->mmap_sem);
> +	r = get_user_pages(current, mm, addr, 1, 1, 0,&vcpu->arch.pv_shm_page,
> +			   NULL);
> +	up_read(&mm->mmap_sem);
>    

This fails if the memory area straddles a page boundary.  Aligning would 
solve this.  I prefer using put_user() though than a permanent 
get_user_pages().


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
