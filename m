Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC7E36B0003
	for <linux-mm@kvack.org>; Sat, 11 Aug 2018 14:19:52 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id p12-v6so9486056wro.7
        for <linux-mm@kvack.org>; Sat, 11 Aug 2018 11:19:52 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i124-v6si3242748wmg.205.2018.08.11.11.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 11 Aug 2018 11:19:51 -0700 (PDT)
Date: Sat, 11 Aug 2018 20:19:39 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [4.18.0 rc8 BUG] possible irq lock inversion dependency
 detected
In-Reply-To: <CABXGCsN2vUE-Lo32j6WeuqyQz620sdgkaSte=otV4dr5wcQwag@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1808112015390.1659@nanos.tec.linutronix.de>
References: <CABXGCsOni6VZTVq6+kfgniX+SO5vc5SSRrn93xa=SMEpw-NNCQ@mail.gmail.com> <20180811113039.GA10397@bombadil.infradead.org> <alpine.DEB.2.21.1808111511200.3202@nanos.tec.linutronix.de> <alpine.DEB.2.21.1808111552010.3202@nanos.tec.linutronix.de>
 <CABXGCsN2vUE-Lo32j6WeuqyQz620sdgkaSte=otV4dr5wcQwag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: willy@infradead.org, kvm@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, konrad.wilk@oracle.com, Tom Lendacky <thomas.lendacky@amd.com>

On Sat, 11 Aug 2018, Mikhail Gavrilov wrote:
> >         /*
> >          * If this vCPU has touched SPEC_CTRL, restore the guest's value if
> >          * it's non-zero. Since vmentry is serialising on affected CPUs, there
> > @@ -5590,6 +5588,8 @@ static void svm_vcpu_run(struct kvm_vcpu *vcpu)
> >          */
> >         x86_spec_ctrl_set_guest(svm->spec_ctrl, svm->virt_spec_ctrl);
> >
> > +       local_irq_enable();
> > +
> >         asm volatile (
> >                 "push %%" _ASM_BP "; \n\t"
> >                 "mov %c[rbx](%[svm]), %%" _ASM_BX " \n\t"
> >
> 
> 
> I am tested this patch, but it not help solve issue.
> New dmesg output is attached here.

Bah, stupid me. Forgot to fix the other end of that function as
well. Complete fix below.

Thanks,

	tglx

8<---------------
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index f059a73f0fd0..9799f86388e7 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -5580,8 +5580,6 @@ static void svm_vcpu_run(struct kvm_vcpu *vcpu)
 
 	clgi();
 
-	local_irq_enable();
-
 	/*
 	 * If this vCPU has touched SPEC_CTRL, restore the guest's value if
 	 * it's non-zero. Since vmentry is serialising on affected CPUs, there
@@ -5590,6 +5588,8 @@ static void svm_vcpu_run(struct kvm_vcpu *vcpu)
 	 */
 	x86_spec_ctrl_set_guest(svm->spec_ctrl, svm->virt_spec_ctrl);
 
+	local_irq_enable();
+
 	asm volatile (
 		"push %%" _ASM_BP "; \n\t"
 		"mov %c[rbx](%[svm]), %%" _ASM_BX " \n\t"
@@ -5712,12 +5712,12 @@ static void svm_vcpu_run(struct kvm_vcpu *vcpu)
 	if (unlikely(!msr_write_intercepted(vcpu, MSR_IA32_SPEC_CTRL)))
 		svm->spec_ctrl = native_read_msr(MSR_IA32_SPEC_CTRL);
 
-	x86_spec_ctrl_restore_host(svm->spec_ctrl, svm->virt_spec_ctrl);
-
 	reload_tss(vcpu);
 
 	local_irq_disable();
 
+	x86_spec_ctrl_restore_host(svm->spec_ctrl, svm->virt_spec_ctrl);
+
 	vcpu->arch.cr2 = svm->vmcb->save.cr2;
 	vcpu->arch.regs[VCPU_REGS_RAX] = svm->vmcb->save.rax;
 	vcpu->arch.regs[VCPU_REGS_RSP] = svm->vmcb->save.rsp;
