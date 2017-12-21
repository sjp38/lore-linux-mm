Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE806B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 16:44:11 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h200so8933658itb.3
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 13:44:11 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j70si843335iod.69.2017.12.21.13.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 13:44:10 -0800 (PST)
Subject: Re: [RFC PATCH v4 05/18] kvm: x86: add kvm_arch_vcpu_set_regs()
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-6-alazar@bitdefender.com>
From: Patrick Colp <patrick.colp@oracle.com>
Message-ID: <2cb184ba-f0ea-b7fa-3c50-e3b0903b95e9@oracle.com>
Date: Thu, 21 Dec 2017 16:39:02 -0500
MIME-Version: 1.0
In-Reply-To: <20171218190642.7790-6-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Adalber_Laz=c4=83r?= <alazar@bitdefender.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>

On 2017-12-18 02:06 PM, Adalber LazA?r wrote:
> From: Adalbert Lazar <alazar@bitdefender.com>
> 
> This is a version of kvm_arch_vcpu_ioctl_set_regs() which does not touch
> the exceptions vector.
> 
> Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
> ---
>   arch/x86/kvm/x86.c       | 34 ++++++++++++++++++++++++++++++++++
>   include/linux/kvm_host.h |  1 +
>   2 files changed, 35 insertions(+)
> 
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index e1a3c2c6ec08..4b0c3692386d 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -7389,6 +7389,40 @@ int kvm_arch_vcpu_ioctl_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs)
>   	return 0;
>   }
>   
> +/*
> + * Similar to kvm_arch_vcpu_ioctl_set_regs() but it does not reset
> + * the exceptions
> + */
> +void kvm_arch_vcpu_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs)
> +{
> +	vcpu->arch.emulate_regs_need_sync_from_vcpu = true;
> +	vcpu->arch.emulate_regs_need_sync_to_vcpu = false;
> +
> +	kvm_register_write(vcpu, VCPU_REGS_RAX, regs->rax);
> +	kvm_register_write(vcpu, VCPU_REGS_RBX, regs->rbx);
> +	kvm_register_write(vcpu, VCPU_REGS_RCX, regs->rcx);
> +	kvm_register_write(vcpu, VCPU_REGS_RDX, regs->rdx);
> +	kvm_register_write(vcpu, VCPU_REGS_RSI, regs->rsi);
> +	kvm_register_write(vcpu, VCPU_REGS_RDI, regs->rdi);
> +	kvm_register_write(vcpu, VCPU_REGS_RSP, regs->rsp);
> +	kvm_register_write(vcpu, VCPU_REGS_RBP, regs->rbp);
> +#ifdef CONFIG_X86_64
> +	kvm_register_write(vcpu, VCPU_REGS_R8, regs->r8);
> +	kvm_register_write(vcpu, VCPU_REGS_R9, regs->r9);
> +	kvm_register_write(vcpu, VCPU_REGS_R10, regs->r10);
> +	kvm_register_write(vcpu, VCPU_REGS_R11, regs->r11);
> +	kvm_register_write(vcpu, VCPU_REGS_R12, regs->r12);
> +	kvm_register_write(vcpu, VCPU_REGS_R13, regs->r13);
> +	kvm_register_write(vcpu, VCPU_REGS_R14, regs->r14);
> +	kvm_register_write(vcpu, VCPU_REGS_R15, regs->r15);
> +#endif
> +
> +	kvm_rip_write(vcpu, regs->rip);
> +	kvm_set_rflags(vcpu, regs->rflags);
> +
> +	kvm_make_request(KVM_REQ_EVENT, vcpu);
> +}
> +

kvm_arch_vcpu_ioctl_set_regs() returns an int (so that, for e.g., in ARM 
it can return an error to indicate that the function is not 
supported/implemented). Is there a reason this function shouldn't do the 
same (is it only ever going to be implemented for x86)?

>   void kvm_get_cs_db_l_bits(struct kvm_vcpu *vcpu, int *db, int *l)
>   {
>   	struct kvm_segment cs;
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index 6bdd4b9f6611..68e4d756f5c9 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -767,6 +767,7 @@ int kvm_arch_vcpu_ioctl_translate(struct kvm_vcpu *vcpu,
>   
>   int kvm_arch_vcpu_ioctl_get_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs);
>   int kvm_arch_vcpu_ioctl_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs);
> +void kvm_arch_vcpu_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs);
>   int kvm_arch_vcpu_ioctl_get_sregs(struct kvm_vcpu *vcpu,
>   				  struct kvm_sregs *sregs);
>   int kvm_arch_vcpu_ioctl_set_sregs(struct kvm_vcpu *vcpu,
> 


Patrick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
