Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3B088E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:30:29 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id z16so2123529wrt.5
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:30:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor9746660wro.22.2018.12.21.09.30.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 09:30:28 -0800 (PST)
MIME-Version: 1.0
References: <20181106222009.90833-1-marcorr@google.com> <20181106222009.90833-3-marcorr@google.com>
 <fe4cff79-f24e-4eb0-a28c-ca770e3186df@redhat.com>
In-Reply-To: <fe4cff79-f24e-4eb0-a28c-ca770e3186df@redhat.com>
From: Marc Orr <marcorr@google.com>
Date: Fri, 21 Dec 2018 09:30:16 -0800
Message-ID: <CAA03e5FpxXXho-2XQUDbJ48a6j4-tpRqDkKPO0-QvvhCJZurdw@mail.gmail.com>
Subject: Re: [kvm PATCH v7 2/2] kvm: x86: Dynamically allocate guest_fpu
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>, Dave Hansen <dave.hansen@intel.com>

On Fri, Dec 21, 2018 at 2:28 AM Paolo Bonzini <pbonzini@redhat.com> wrote:
>
> On 06/11/18 23:20, Marc Orr wrote:
> > +     x86_fpu_cache = kmem_cache_create_usercopy(
> > +                             "x86_fpu",
> > +                             fpu_kernel_xstate_size,
>
> This unfortunately is wrong because there are other members in struct
> fpu before the fpregs_state union.  It's enough to run a guest and then
> rmmod kvm to see slub errors which are actually caused by memory
> corruption.
>
> The right way to size it is shown in fpu__init_task_struct_size but for
> now I'll revert it to sizeof(struct fpu).  I have plans to move
> fsave/fxsave/xsave directly in KVM, without using the kernel FPU
> helpers, and actually this guest_fpu thing will come in handy for that.
> :)  Once it's done, the size of the object in the cache will be
> something like kvm_xstate_size.
>
> Paolo
>
>
> > +                             __alignof__(struct fpu),
> > +                             SLAB_ACCOUNT,
> > +                             offsetof(struct fpu, state),
> > +                             fpu_kernel_xstate_size,
> > +                             NULL);
>

Oops. Thanks for debugging, explaining and fixing!
