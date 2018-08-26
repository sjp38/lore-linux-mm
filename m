Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D80B6B3D2B
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 18:30:06 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l14-v6so13156942oii.9
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 15:30:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e126-v6sor7072876oig.186.2018.08.26.15.30.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 Aug 2018 15:30:05 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180823133958.GA1496@brain-police>
 <20180824084717.GK24124@hirez.programming.kicks-ass.net> <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com>
 <20180824180438.GS24124@hirez.programming.kicks-ass.net> <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com>
 <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
 <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com> <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
 <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com> <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
 <20180826112341.f77a528763e297cbc36058fa@kernel.org> <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
 <CAGXu5j+xUbq_mu=2jvH2Vu+mviteZJqdPNTrxpaijwsuDdN-sw@mail.gmail.com>
 <952A64F0-90B3-4E2F-B410-7E20BE90D617@amacapital.net> <CAGXu5jKk+ELGsSXC8e3v67oo74BF9rP2HDqMHx1Sb17-0F-xZQ@mail.gmail.com>
 <DF353FDA-4A57-4F5E-A403-531DDA0DBC25@amacapital.net> <alpine.DEB.2.21.1808262212030.1195@nanos.tec.linutronix.de>
 <CAGXu5jJQGiGwQRBGuVrmhQqyUEfRUUSD6WYokc2xezExY9ZNUg@mail.gmail.com>
In-Reply-To: <CAGXu5jJQGiGwQRBGuVrmhQqyUEfRUUSD6WYokc2xezExY9ZNUg@mail.gmail.com>
From: Jann Horn <jannh@google.com>
Date: Mon, 27 Aug 2018 00:29:37 +0200
Message-ID: <CAG48ez0tXJgsuoez3akJr4LW8fDGFFGg_9Mpb=MU7yP_7UbJ=A@mail.gmail.com>
Subject: Re: TLB flushes on fixmap changes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@amacapital.net>, mhiramat@kernel.org, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, jkosina@suse.cz, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, benh@au1.ibm.com, npiggin@gmail.com, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, Aug 27, 2018 at 12:11 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Sun, Aug 26, 2018 at 1:15 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Sun, 26 Aug 2018, Andy Lutomirski wrote:
> >> > On Aug 26, 2018, at 9:47 AM, Kees Cook <keescook@chromium.org> wrote:
> >> >> On Sun, Aug 26, 2018 at 7:20 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> >> >>> I tried to convince Ingo to use this method for doing "write rarely"
> >> >>> and he soundly rejected it. :) I've always liked this because AFAICT,
> >> >>> it's local to the CPU. I had proposed it in
> >> >>> https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=kspp/write-rarely&id=9ab0cb2618ebbc51f830ceaa06b7d2182fe1a52d
> >> >>
> >> >> Ingo, can you clarify why you hate it?  I personally would rather use CR3, but CR0 seems like a fine first step, at least for text_poke.
> >> >
> >> > Sorry, it looks like it was tglx, not Ingo:
> >> >
> >> > https://lkml.kernel.org/r/alpine.DEB.2.20.1704071048360.1716@nanos
> >> >
> >> > This thread is long, and one thing that I think went unanswered was
> >> > "why do we want this to be fast?" the answer is: for doing page table
> >> > updates. Page tables are becoming a bigger target for attacks now, and
> >> > it's be nice if they could stay read-only unless they're getting
> >> > updated (with something like this).
> >> >
> >> >
> >> It kind of sounds like tglx would prefer the CR3 approach. And indeed my
> >> patch has a serious problem wrt the NMI code.
> >
> > That's exactly the problem I have with CR0. It leaves everything and some
> > more writeable for any code which can interrupt that section.
>
> I thought the point was that the implementation I suggested was
> NMI-proof? (And in reading Documentation/preempt-locking.txt it sounds
> like disabling interrupts is redundant to preempt_disable()? But I
> don't understand how; it looks like the preempt stuff is advisory?)

Where are you dealing with NMIs? local_irq_disable() disables the
interrupt flag, but Non-Maskable Interrupts can still come in. As far
as I know, the only way to block those is to artificially generate an
NMI yourself (Xen does that sometimes). Otherwise, you have to twiddle
CR0.WP in the NMI handler entry/exit code.
