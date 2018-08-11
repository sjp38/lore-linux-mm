Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E24016B0005
	for <linux-mm@kvack.org>; Sat, 11 Aug 2018 09:56:19 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f13-v6so9399934wru.5
        for <linux-mm@kvack.org>; Sat, 11 Aug 2018 06:56:19 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r199-v6si3417591wmg.37.2018.08.11.06.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 11 Aug 2018 06:56:18 -0700 (PDT)
Date: Sat, 11 Aug 2018 15:56:12 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [4.18.0 rc8 BUG] possible irq lock inversion dependency
 detected
In-Reply-To: <alpine.DEB.2.21.1808111511200.3202@nanos.tec.linutronix.de>
Message-ID: <alpine.DEB.2.21.1808111552010.3202@nanos.tec.linutronix.de>
References: <CABXGCsOni6VZTVq6+kfgniX+SO5vc5SSRrn93xa=SMEpw-NNCQ@mail.gmail.com> <20180811113039.GA10397@bombadil.infradead.org> <alpine.DEB.2.21.1808111511200.3202@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, kvm@vger.kernel.org, linux-mm@kvack.org, Borislav Petkov <bp@suse.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Sat, 11 Aug 2018, Thomas Gleixner wrote:

> On Sat, 11 Aug 2018, Matthew Wilcox wrote:
> 
> > On Sat, Aug 11, 2018 at 12:28:24PM +0500, Mikhail Gavrilov wrote:
> > > Hi guys.
> > > I am catched new bug. It occured when I start virtual machine.
> > > Can anyone look?
> > 
> > I'd suggest that st->lock should be taken with irqsave.  Like this;
> > please test.
> 
> That should fix it, but that's suboptimal because that's an extra
> safe/restore in switch_to(). So we better disable interrupts at the other
> call site. Patch below.

Which is wrong as well. The placement of the speculation update call in the
SVM code should be moved, so just SVM is affected by a slightly larger irq
disabled region and no overhead at all for all others. Revised patch below.

Thanks,

	tglx

8<------------------
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index f059a73f0fd0..9c9b976d1afd 100644
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
