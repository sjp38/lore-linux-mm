Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 776326B3E4A
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 23:03:12 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u6-v6so10020340pgn.10
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 20:03:12 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e72-v6si10645320pfk.198.2018.08.26.20.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Aug 2018 20:03:11 -0700 (PDT)
Date: Mon, 27 Aug 2018 12:03:05 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: TLB flushes on fixmap changes
Message-Id: <20180827120305.01a6f26267c64610cadec5d8@kernel.org>
In-Reply-To: <20180826090958.GT24124@hirez.programming.kicks-ass.net>
References: <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com>
	<20180824180438.GS24124@hirez.programming.kicks-ass.net>
	<56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com>
	<CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
	<9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com>
	<CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
	<8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com>
	<CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
	<20180826112341.f77a528763e297cbc36058fa@kernel.org>
	<CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
	<20180826090958.GT24124@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Kees Cook <keescook@chromium.org>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Sun, 26 Aug 2018 11:09:58 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Sat, Aug 25, 2018 at 09:21:22PM -0700, Andy Lutomirski wrote:
> > I just re-read text_poke().  It's, um, horrible.  Not only is the
> > implementation overcomplicated and probably buggy, but it's SLOOOOOW.
> > It's totally the wrong API -- poking one instruction at a time
> > basically can't be efficient on x86.  The API should either poke lots
> > of instructions at once or should be text_poke_begin(); ...;
> > text_poke_end();.
> 
> I don't think anybody ever cared about performance here. Only
> correctness. That whole text_poke_bp() thing is entirely tricky.

Agreed. Self modification is a special event.

> FWIW, before text_poke_bp(), text_poke() would only be used from
> stop_machine, so all the other CPUs would be stuck busy-waiting with
> IRQs disabled. These days, yeah, that's lots more dodgy, but yes
> text_mutex should be serializing all that.

I'm still not sure that speculative page-table walk can be done
over the mutex. Also, if the fixmap area is for aliasing
pages (which always mapped to memory), what kind of
security issue can happen?

Anyway, from the viewpoint of kprobes, either per-cpu fixmap or
changing CR3 sounds good to me. I think we don't even need per-cpu,
it can call a thread/function on a dedicated core (like the first
boot processor) and wait :) This may prevent leakage of pte change
to other cores.

> And on that, I so hate comments like: "must be called under foo_mutex",
> we have lockdep_assert_held() for that.

Indeed. I also think that text_poke() should not call BUG_ON, but
its caller should decide it is recoverable or not.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
