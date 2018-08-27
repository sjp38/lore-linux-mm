Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA3676B3F82
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:13:59 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e6-v6so7855953itc.7
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 01:13:59 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v130-v6si9120107iod.249.2018.08.27.01.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 Aug 2018 01:13:58 -0700 (PDT)
Date: Mon, 27 Aug 2018 10:13:29 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: TLB flushes on fixmap changes
Message-ID: <20180827081329.GZ24124@hirez.programming.kicks-ass.net>
References: <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com>
 <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
 <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com>
 <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
 <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com>
 <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
 <20180826112341.f77a528763e297cbc36058fa@kernel.org>
 <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
 <20180826090958.GT24124@hirez.programming.kicks-ass.net>
 <20180827120305.01a6f26267c64610cadec5d8@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180827120305.01a6f26267c64610cadec5d8@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Kees Cook <keescook@chromium.org>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, Aug 27, 2018 at 12:03:05PM +0900, Masami Hiramatsu wrote:
> On Sun, 26 Aug 2018 11:09:58 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:

> > FWIW, before text_poke_bp(), text_poke() would only be used from
> > stop_machine, so all the other CPUs would be stuck busy-waiting with
> > IRQs disabled. These days, yeah, that's lots more dodgy, but yes
> > text_mutex should be serializing all that.
> 
> I'm still not sure that speculative page-table walk can be done
> over the mutex. Also, if the fixmap area is for aliasing
> pages (which always mapped to memory), what kind of
> security issue can happen?

So suppose CPU-A is doing the text_poke (let's say through text_poke_bp,
such that other CPUs get to continue with whatever they're doing).

While at that point, CPU-B gets an interrupt, and the CPU's
branch-trace-buffer for the IRET points to / near our fixmap. Then the
CPU could do a speculative TLB fill based on the BTB value, either
directly or indirectly (through speculative driven fault-ahead) of
whatever is in te fixmap at the time.

Then CPU-A completes the text_poke and only does a local TLB invalidate
on CPU-A, leaving CPU-B with an active translation.

*FAIL*
