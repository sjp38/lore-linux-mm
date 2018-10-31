Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A38A6B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:14:05 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id d16-v6so14214921wre.11
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:14:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a19-v6sor3726367wmb.2.2018.10.31.14.14.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 14:14:03 -0700 (PDT)
MIME-Version: 1.0
References: <20181031132634.50440-1-marcorr@google.com> <20181031132634.50440-3-marcorr@google.com>
 <cf476e07-e2fc-45c9-7259-3952a5cbb30e@intel.com>
In-Reply-To: <cf476e07-e2fc-45c9-7259-3952a5cbb30e@intel.com>
From: Marc Orr <marcorr@google.com>
Date: Wed, 31 Oct 2018 14:13:51 -0700
Message-ID: <CAA03e5HmMq-+9WsJ+Kd05ary85A7HJ5HJbNMUzc87QCRxamJGg@mail.gmail.com>
Subject: Re: [kvm PATCH v5 2/4] kvm: x86: Dynamically allocate guest_fpu
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

> We should basically never be using sizeof(struct fpu), anywhere.  As you
> saw, it's about a page in size, but the actual hardware FPU structure
> can be as small as ~500 bytes or as big as ~3k.  Doing it this way is a
> pretty unnecessary waste of memory because sizeof(struct fpu) is sized
> for the worst-case (largest) possible XSAVE buffer that we support on
> *any* CPU.  It will also get way worse if anyone ever throws a bunch
> more state into the XSAVE area and we need to make it way bigger.
>
> If you want a kmem cache for this, I'd suggest creating a cache which is
> the size of the host XSAVE buffer.  That can be found in a variable
> called 'fpu_kernel_xstate_size'.  I'm assuming here that the guest FPU
> is going to support a strict subset of host kernel XSAVE states.


This suggestion sounds good. Though, I have one uncertainty. KVM
explicitly cast guest_fpu.state as a fxregs_state in a few places
(e.g., the ioctls). Yet, I see a code path in
fpu__init_system_xstate_size_legacy() that sets fpu_kernel_xstate_size
to sizeof(struct fregs_state). Will this cause problems? You mentioned
that the fpu's state field is expected to range from ~500 bytes to
~3k, which implies that it should never get set to sizeof(struct
fregs_state). But I want to confirm.

>
>
> The other alternative is to calculate the actual size of the XSAVE
> buffer that the guest needs.  You can do that from the values that KVM
> sets to limit guest XCR0 values (the name of the control field is
> escaping me at the moment).
