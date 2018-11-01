Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAC1D6B0003
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 13:35:25 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 88-v6so16508202wrp.21
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 10:35:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6-v6sor1315929wmh.18.2018.11.01.10.35.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Nov 2018 10:35:24 -0700 (PDT)
MIME-Version: 1.0
References: <20181031234928.144206-1-marcorr@google.com> <20181031234928.144206-3-marcorr@google.com>
 <86c27c0c-1326-c757-9b43-251f2290182b@intel.com>
In-Reply-To: <86c27c0c-1326-c757-9b43-251f2290182b@intel.com>
From: Marc Orr <marcorr@google.com>
Date: Thu, 1 Nov 2018 10:35:11 -0700
Message-ID: <CAA03e5EU9j3tCLH=ZU8T4vz_N=D+2os_s8VcAYjC-o9cu-TJ0g@mail.gmail.com>
Subject: Re: [kvm PATCH v6 2/2] kvm: x86: Dynamically allocate guest_fpu
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

> On 10/31/18 4:49 PM, Marc Orr wrote:
> > +     if (!boot_cpu_has(X86_FEATURE_FPU) || !boot_cpu_has(X86_FEATURE_FXSR)) {
> > +             printk(KERN_ERR "kvm: inadequate fpu\n");
> > +             r = -EOPNOTSUPP;
> > +             goto out;
> > +     }
>
> It would be nice to have a comment about _why_ this is inadequate.

Ack. I'll uptdate the patch.

> >       r = -ENOMEM;
> > +     x86_fpu_cache = kmem_cache_create_usercopy(
> > +                             "x86_fpu",
>
> For now, this should probably be kvm_x86_fpu since it's not used as a
> generic x86 thing, yet.
>
> Also, why is this a "usercopy"?  "fpu_kernel_xstate_size" includes (or
> will soon include) supervisor state which can never be copied to
> userspace.  If this structure is going out to userspace, that tells me
> we might instead want fpu_user_xstate_size, *or* we want the
> non-usercopy variant.

Good question. Configuring the usercopy kmem cache to restrict access
beyond fpu_user_xstate_size bytes (rather than fpu_kernel_xstate_size
bytes) from the beginning of the state field seems intuitive to me,
but I'm honestly not familiar with what user space expects KVM to
return through the ioctls. Can someone familiar with this suggest what
to do? Otherwise, I can update the patch to use the non-usercopy
variant.
