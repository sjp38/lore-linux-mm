Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 897576B026D
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:39:34 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id b139-v6so3597050wme.8
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:39:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g184-v6sor6389303wmf.24.2018.10.31.14.39.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 14:39:33 -0700 (PDT)
MIME-Version: 1.0
References: <20181031132634.50440-1-marcorr@google.com> <20181031132634.50440-3-marcorr@google.com>
 <cf476e07-e2fc-45c9-7259-3952a5cbb30e@intel.com> <CAA03e5HmMq-+9WsJ+Kd05ary85A7HJ5HJbNMUzc87QCRxamJGg@mail.gmail.com>
 <4094fe59-a161-99f0-e3cd-7ac14eb9f5a4@intel.com> <CAA03e5F7LsYcrr6fgHWdwQ=hyYm2Su7Lqke7==Un7tSp57JtSA@mail.gmail.com>
 <07251c42-e9d9-6428-60cd-6ecbaf78c3a5@intel.com>
In-Reply-To: <07251c42-e9d9-6428-60cd-6ecbaf78c3a5@intel.com>
From: Marc Orr <marcorr@google.com>
Date: Wed, 31 Oct 2018 14:39:20 -0700
Message-ID: <CAA03e5FBri+LSZoGKJpJJruSEoNZ39DTbJMRhJbatgQAs6BiaA@mail.gmail.com>
Subject: Re: [kvm PATCH v5 2/4] kvm: x86: Dynamically allocate guest_fpu
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

On Wed, Oct 31, 2018 at 2:30 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 10/31/18 2:24 PM, Marc Orr wrote:
> >> It can get set to sizeof(struct fregs_state) for systems where XSAVE is
> >> not in use.  I was neglecting to mention those when I said the "~500
> >> byte" number.
> >>
> >> My point was that it can vary wildly and that any static allocation
> >> scheme will waste lots of memory when we have small hardware-supported
> >> buffers.
> >
> > Got it. Then I think we need to set the size for the kmem cache to
> > max(fpu_kernel_xstate_size, sizeof(fxregs_state)), unless I'm missing
> > something. I'll send out a version of the patch that does this in a
> > bit. Thanks!
>
> Despite its name, fpu_kernel_xstate_size *should* always be the "size of
> the hardware buffer we need to back 'struct fpu'".  That's true for all
> of the various formats we support: XSAVE, fxregs, swregs, etc...
>
> fpu__init_system_xstate_size_legacy() does that when XSAVE itself is not
> in play.

That makes sense. But my specific concern is the code I've copied
below, from arch/x86/kvm/x86.c. Notice on a system where
guest_fpu.state is a fregs_state, this code would generate garbage for
some fields. With the new code we're talking about, it will cause
memory corruption. But maybe it's not possible to run this code on a
system with an fregs_state, because such systems would predate VMX?

8382 int kvm_arch_vcpu_ioctl_get_fpu(struct kvm_vcpu *vcpu, struct kvm_fpu *fpu)
8383 {
8384         struct fxregs_state *fxsave;
8385
8386         vcpu_load(vcpu);
8387
8388         fxsave = &vcpu->arch.guest_fpu->state.fxsave;
8389         memcpy(fpu->fpr, fxsave->st_space, 128);
8390         fpu->fcw = fxsave->cwd;
8391         fpu->fsw = fxsave->swd;
8392         fpu->ftwx = fxsave->twd;
8393         fpu->last_opcode = fxsave->fop;
8394         fpu->last_ip = fxsave->rip;
8395         fpu->last_dp = fxsave->rdp;
8396         memcpy(fpu->xmm, fxsave->xmm_space, sizeof fxsave->xmm_space);
8397
8398         vcpu_put(vcpu);
8399         return 0;
8400 }
