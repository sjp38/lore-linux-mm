Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC1786B0069
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 06:04:51 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id f132so5051070wmf.6
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:04:51 -0800 (PST)
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id r16si6367346wmd.165.2017.12.22.03.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 03:04:50 -0800 (PST)
Received: from smtp02.buh.bitdefender.net (smtp.bitdefender.biz [10.17.80.76])
	by mx-sr.buh.bitdefender.com (Postfix) with ESMTP id CC70A7FC7B
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 11:29:12 +0200 (EET)
From: alazar@bitdefender.com
Subject: Re: [RFC PATCH v4 05/18] kvm: x86: add kvm_arch_vcpu_set_regs()
In-Reply-To: <2cb184ba-f0ea-b7fa-3c50-e3b0903b95e9@oracle.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
	<20171218190642.7790-6-alazar@bitdefender.com>
	<2cb184ba-f0ea-b7fa-3c50-e3b0903b95e9@oracle.com>
Date: Fri, 22 Dec 2017 11:29:18 +0200
Message-ID: <1513934958.Af5f.18170@host>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Patrick Colp <patrick.colp@oracle.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>, Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>

On Thu, 21 Dec 2017 16:39:02 -0500, Patrick Colp <patrick.colp@oracle.com> wrote:
> On 2017-12-18 02:06 PM, Adalber LazA?r wrote:
> > From: Adalbert Lazar <alazar@bitdefender.com>
> > 
> > This is a version of kvm_arch_vcpu_ioctl_set_regs() which does not touch
> > the exceptions vector.
> > 
> > Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
> > ---
> >   arch/x86/kvm/x86.c       | 34 ++++++++++++++++++++++++++++++++++
> >   include/linux/kvm_host.h |  1 +
> >   2 files changed, 35 insertions(+)
> > 
> > diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> > index e1a3c2c6ec08..4b0c3692386d 100644
> > --- a/arch/x86/kvm/x86.c
> > +++ b/arch/x86/kvm/x86.c
> > @@ -7389,6 +7389,40 @@ int kvm_arch_vcpu_ioctl_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs)
> >   	return 0;
> >   }
> >   
> > +/*
> > + * Similar to kvm_arch_vcpu_ioctl_set_regs() but it does not reset
> > + * the exceptions
> > + */
> > +void kvm_arch_vcpu_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs)
> > +{
> > +	vcpu->arch.emulate_regs_need_sync_from_vcpu = true;
> > +	vcpu->arch.emulate_regs_need_sync_to_vcpu = false;
> > +
> > +	kvm_register_write(vcpu, VCPU_REGS_RAX, regs->rax);
> > +	kvm_register_write(vcpu, VCPU_REGS_RBX, regs->rbx);
> > +	kvm_register_write(vcpu, VCPU_REGS_RCX, regs->rcx);
> > +	kvm_register_write(vcpu, VCPU_REGS_RDX, regs->rdx);
> > +	kvm_register_write(vcpu, VCPU_REGS_RSI, regs->rsi);
> > +	kvm_register_write(vcpu, VCPU_REGS_RDI, regs->rdi);
> > +	kvm_register_write(vcpu, VCPU_REGS_RSP, regs->rsp);
> > +	kvm_register_write(vcpu, VCPU_REGS_RBP, regs->rbp);
> > +#ifdef CONFIG_X86_64
> > +	kvm_register_write(vcpu, VCPU_REGS_R8, regs->r8);
> > +	kvm_register_write(vcpu, VCPU_REGS_R9, regs->r9);
> > +	kvm_register_write(vcpu, VCPU_REGS_R10, regs->r10);
> > +	kvm_register_write(vcpu, VCPU_REGS_R11, regs->r11);
> > +	kvm_register_write(vcpu, VCPU_REGS_R12, regs->r12);
> > +	kvm_register_write(vcpu, VCPU_REGS_R13, regs->r13);
> > +	kvm_register_write(vcpu, VCPU_REGS_R14, regs->r14);
> > +	kvm_register_write(vcpu, VCPU_REGS_R15, regs->r15);
> > +#endif
> > +
> > +	kvm_rip_write(vcpu, regs->rip);
> > +	kvm_set_rflags(vcpu, regs->rflags);
> > +
> > +	kvm_make_request(KVM_REQ_EVENT, vcpu);
> > +}
> > +
> 
> kvm_arch_vcpu_ioctl_set_regs() returns an int (so that, for e.g., in ARM 
> it can return an error to indicate that the function is not 
> supported/implemented). Is there a reason this function shouldn't do the 
> same (is it only ever going to be implemented for x86)?
> 
> > diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> > index 6bdd4b9f6611..68e4d756f5c9 100644
> > --- a/include/linux/kvm_host.h
> > +++ b/include/linux/kvm_host.h
> > @@ -767,6 +767,7 @@ int kvm_arch_vcpu_ioctl_translate(struct kvm_vcpu *vcpu,
> >   
> >   int kvm_arch_vcpu_ioctl_get_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs);
> >   int kvm_arch_vcpu_ioctl_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs);
> > +void kvm_arch_vcpu_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs);
> >   int kvm_arch_vcpu_ioctl_get_sregs(struct kvm_vcpu *vcpu,
> >   				  struct kvm_sregs *sregs);
> 
> 
> Patrick

Hi Patrick,

Thank you for taking the time to review these patches.

You're right. This function should return an error code, regardless on
the time when ARM will be supported.

Adalbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
