Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33FDA6B3FCA
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 05:39:43 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j15-v6so11309131pff.12
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 02:39:43 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q90-v6si15159656pfa.272.2018.08.27.02.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 02:39:42 -0700 (PDT)
Date: Mon, 27 Aug 2018 18:39:36 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: TLB flushes on fixmap changes
Message-Id: <20180827183936.75f4e9bc131cdeac943f44e3@kernel.org>
In-Reply-To: <20180827081329.GZ24124@hirez.programming.kicks-ass.net>
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
	<20180827081329.GZ24124@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, Kees Cook <keescook@chromium.org>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, 27 Aug 2018 10:13:29 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

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

Hmm, but how "near" is it enough? Since text_poke just map a non
executable alias page in fixmap, it is hard to suppose that IRET points
there (except for attacker change the IRET address).

I see that Intel CPU sometimes speculatively read-ahead the page tables,
but in that case, I guess we just need to keep fixmap area away from
text area. (Of course, it is hard to estimate how far is enough :( )

Anyway, I agree to introduce new page-table (and kthread?) for fixmap.

> Then CPU-A completes the text_poke and only does a local TLB invalidate
> on CPU-A, leaving CPU-B with an active translation.
> 
> *FAIL*

Ah, I got it. So on CPU-B, it can write-access to fixmap'd pages unless
the CPU-B shoot down the full TLB...

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
