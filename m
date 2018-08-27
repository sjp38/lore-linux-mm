Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3831E6B3FDC
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 05:55:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j17-v6so14115741oii.8
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 02:55:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u141-v6sor7942113oie.151.2018.08.27.02.55.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 02:55:28 -0700 (PDT)
MIME-Version: 1.0
References: <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com>
 <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
 <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com> <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
 <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com> <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
 <20180826112341.f77a528763e297cbc36058fa@kernel.org> <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
 <20180826090958.GT24124@hirez.programming.kicks-ass.net> <20180827120305.01a6f26267c64610cadec5d8@kernel.org>
 <20180827081329.GZ24124@hirez.programming.kicks-ass.net>
In-Reply-To: <20180827081329.GZ24124@hirez.programming.kicks-ass.net>
From: Jann Horn <jannh@google.com>
Date: Mon, 27 Aug 2018 11:55:00 +0200
Message-ID: <CAG48ez2sn_5a1HFXpDjLHmHvp49iLn06isPwAati26Y47r2ttw@mail.gmail.com>
Subject: Re: TLB flushes on fixmap changes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>
Cc: mhiramat@kernel.org, Kees Cook <keescook@chromium.org>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, jkosina@suse.cz, Will Deacon <will.deacon@arm.com>, benh@au1.ibm.com, npiggin@gmail.com, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Adin Scannell <ascannell@google.com>, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, Aug 27, 2018 at 10:13 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Mon, Aug 27, 2018 at 12:03:05PM +0900, Masami Hiramatsu wrote:
> > On Sun, 26 Aug 2018 11:09:58 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
>
> > > FWIW, before text_poke_bp(), text_poke() would only be used from
> > > stop_machine, so all the other CPUs would be stuck busy-waiting with
> > > IRQs disabled. These days, yeah, that's lots more dodgy, but yes
> > > text_mutex should be serializing all that.
> >
> > I'm still not sure that speculative page-table walk can be done
> > over the mutex. Also, if the fixmap area is for aliasing
> > pages (which always mapped to memory), what kind of
> > security issue can happen?
>
> So suppose CPU-A is doing the text_poke (let's say through text_poke_bp,
> such that other CPUs get to continue with whatever they're doing).
>
> While at that point, CPU-B gets an interrupt, and the CPU's
> branch-trace-buffer for the IRET points to / near our fixmap. Then the
> CPU could do a speculative TLB fill based on the BTB value, either
> directly or indirectly (through speculative driven fault-ahead) of
> whatever is in te fixmap at the time.

Worse: The way academics have been defeating KASLR for a while is
based on TLB fills for kernel addresses, triggered from userspace.
Quoting https://www.ieee-security.org/TC/SP2013/papers/4977a191.pdf :

| Additionally, even if a permission error occurs, this still allows to
| launch address translations and, hence, generate valid TLB entries
| by accessing privileged kernel space memory from user mode.

This was actually part of the original motivation for KAISER/KPTI.
Quoting https://gruss.cc/files/kaiser.pdf :

| Modern operating system kernels employ address space layout
| randomization (ASLR) to prevent control-flow hijacking attacks and
| code-injection attacks. While kernel security relies fundamentally
on preventing
| access to address information, recent attacks have shown that the
| hardware directly leaks this information.

I believe that PTI probably prevents this way of directly triggering
TLB fills for now (under the assumption that hyperthreads with equal
CR3 don't share TLB entries), but I would still assume that an
attacker can probably trigger TLB fills for arbitrary addresses
anytime. And at some point in the future, I believe people would
probably like to be able to disable PTI again?

> Then CPU-A completes the text_poke and only does a local TLB invalidate
> on CPU-A, leaving CPU-B with an active translation.
>
> *FAIL*
