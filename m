Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7976B0006
	for <linux-mm@kvack.org>; Sat, 11 Aug 2018 15:44:36 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p12-v6so9891764iog.8
        for <linux-mm@kvack.org>; Sat, 11 Aug 2018 12:44:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x21-v6sor4688964iog.108.2018.08.11.12.44.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 11 Aug 2018 12:44:34 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsOni6VZTVq6+kfgniX+SO5vc5SSRrn93xa=SMEpw-NNCQ@mail.gmail.com>
 <20180811113039.GA10397@bombadil.infradead.org> <alpine.DEB.2.21.1808111511200.3202@nanos.tec.linutronix.de>
 <alpine.DEB.2.21.1808111552010.3202@nanos.tec.linutronix.de>
 <CABXGCsN2vUE-Lo32j6WeuqyQz620sdgkaSte=otV4dr5wcQwag@mail.gmail.com> <alpine.DEB.2.21.1808112015390.1659@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1808112015390.1659@nanos.tec.linutronix.de>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Sun, 12 Aug 2018 00:44:23 +0500
Message-ID: <CABXGCsNdt4=z0b2H0pf5-0HVeiDBcU3Q3c-+WZ-dsExxwih4YA@mail.gmail.com>
Subject: Re: [4.18.0 rc8 BUG] possible irq lock inversion dependency detected
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de
Cc: willy@infradead.org, kvm@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, konrad.wilk@oracle.com, thomas.lendacky@amd.com

On Sat, 11 Aug 2018 at 23:19, Thomas Gleixner <tglx@linutronix.de> wrote:
>
> On Sat, 11 Aug 2018, Mikhail Gavrilov wrote:
> > >         /*
> > >          * If this vCPU has touched SPEC_CTRL, restore the guest's value if
> > >          * it's non-zero. Since vmentry is serialising on affected CPUs, there
> > > @@ -5590,6 +5588,8 @@ static void svm_vcpu_run(struct kvm_vcpu *vcpu)
> > >          */
> > >         x86_spec_ctrl_set_guest(svm->spec_ctrl, svm->virt_spec_ctrl);
> > >
> > > +       local_irq_enable();
> > > +
> > >         asm volatile (
> > >                 "push %%" _ASM_BP "; \n\t"
> > >                 "mov %c[rbx](%[svm]), %%" _ASM_BX " \n\t"
> > >
> >
> >
> > I am tested this patch, but it not help solve issue.
> > New dmesg output is attached here.
>
> Bah, stupid me. Forgot to fix the other end of that function as
> well. Complete fix below.
>
> Thanks,
>
>         tglx
>
> 8<---------------
> diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
> index f059a73f0fd0..9799f86388e7 100644
> --- a/arch/x86/kvm/svm.c
> +++ b/arch/x86/kvm/svm.c
> @@ -5580,8 +5580,6 @@ static void svm_vcpu_run(struct kvm_vcpu *vcpu)
>
>         clgi();
>
> -       local_irq_enable();
> -
>         /*
>          * If this vCPU has touched SPEC_CTRL, restore the guest's value if
>          * it's non-zero. Since vmentry is serialising on affected CPUs, there
> @@ -5590,6 +5588,8 @@ static void svm_vcpu_run(struct kvm_vcpu *vcpu)
>          */
>         x86_spec_ctrl_set_guest(svm->spec_ctrl, svm->virt_spec_ctrl);
>
> +       local_irq_enable();
> +
>         asm volatile (
>                 "push %%" _ASM_BP "; \n\t"
>                 "mov %c[rbx](%[svm]), %%" _ASM_BX " \n\t"
> @@ -5712,12 +5712,12 @@ static void svm_vcpu_run(struct kvm_vcpu *vcpu)
>         if (unlikely(!msr_write_intercepted(vcpu, MSR_IA32_SPEC_CTRL)))
>                 svm->spec_ctrl = native_read_msr(MSR_IA32_SPEC_CTRL);
>
> -       x86_spec_ctrl_restore_host(svm->spec_ctrl, svm->virt_spec_ctrl);
> -
>         reload_tss(vcpu);
>
>         local_irq_disable();
>
> +       x86_spec_ctrl_restore_host(svm->spec_ctrl, svm->virt_spec_ctrl);
> +
>         vcpu->arch.cr2 = svm->vmcb->save.cr2;
>         vcpu->arch.regs[VCPU_REGS_RAX] = svm->vmcb->save.rax;
>         vcpu->arch.regs[VCPU_REGS_RSP] = svm->vmcb->save.rsp;
>

Perfect, the issue was gone!
Can I hope to see this patch in 4.18 kernel or already too late?
