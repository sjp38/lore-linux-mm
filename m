Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D6CDF6B3CA1
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 16:16:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b134-v6so6149167wmd.6
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 13:16:08 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 71-v6si5445778wmm.75.2018.08.26.13.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 Aug 2018 13:16:07 -0700 (PDT)
Date: Sun, 26 Aug 2018 22:15:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: TLB flushes on fixmap changes
In-Reply-To: <DF353FDA-4A57-4F5E-A403-531DDA0DBC25@amacapital.net>
Message-ID: <alpine.DEB.2.21.1808262212030.1195@nanos.tec.linutronix.de>
References: <20180822153012.173508681@infradead.org> <20180823133958.GA1496@brain-police> <20180824084717.GK24124@hirez.programming.kicks-ass.net> <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com> <20180824180438.GS24124@hirez.programming.kicks-ass.net>
 <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com> <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com> <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com> <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
 <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com> <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com> <20180826112341.f77a528763e297cbc36058fa@kernel.org> <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
 <CAGXu5j+xUbq_mu=2jvH2Vu+mviteZJqdPNTrxpaijwsuDdN-sw@mail.gmail.com> <952A64F0-90B3-4E2F-B410-7E20BE90D617@amacapital.net> <CAGXu5jKk+ELGsSXC8e3v67oo74BF9rP2HDqMHx1Sb17-0F-xZQ@mail.gmail.com> <DF353FDA-4A57-4F5E-A403-531DDA0DBC25@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Sun, 26 Aug 2018, Andy Lutomirski wrote:
> > On Aug 26, 2018, at 9:47 AM, Kees Cook <keescook@chromium.org> wrote:
> >> On Sun, Aug 26, 2018 at 7:20 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> >>> I tried to convince Ingo to use this method for doing "write rarely"
> >>> and he soundly rejected it. :) I've always liked this because AFAICT,
> >>> it's local to the CPU. I had proposed it in
> >>> https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=kspp/write-rarely&id=9ab0cb2618ebbc51f830ceaa06b7d2182fe1a52d
> >> 
> >> Ingo, can you clarify why you hate it?  I personally would rather use CR3, but CR0 seems like a fine first step, at least for text_poke.
> > 
> > Sorry, it looks like it was tglx, not Ingo:
> > 
> > https://lkml.kernel.org/r/alpine.DEB.2.20.1704071048360.1716@nanos
> > 
> > This thread is long, and one thing that I think went unanswered was
> > "why do we want this to be fast?" the answer is: for doing page table
> > updates. Page tables are becoming a bigger target for attacks now, and
> > it's be nice if they could stay read-only unless they're getting
> > updated (with something like this).
> > 
> > 
> It kind of sounds like tglx would prefer the CR3 approach. And indeed my
> patch has a serious problem wrt the NMI code.

That's exactly the problem I have with CR0. It leaves everything and some
more writeable for any code which can interrupt that section.

Performance wise CR0 is not that much better than CR3 except that it has
the costs nicely hidden.

Thanks,

	tglx
