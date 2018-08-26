Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 922F96B3A07
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 05:10:48 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id w23-v6so11198846iob.18
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 02:10:48 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x24-v6si7570431iob.157.2018.08.26.02.10.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 Aug 2018 02:10:47 -0700 (PDT)
Date: Sun, 26 Aug 2018 11:09:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: TLB flushes on fixmap changes
Message-ID: <20180826090958.GT24124@hirez.programming.kicks-ass.net>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Kees Cook <keescook@chromium.org>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Sat, Aug 25, 2018 at 09:21:22PM -0700, Andy Lutomirski wrote:
> I just re-read text_poke().  It's, um, horrible.  Not only is the
> implementation overcomplicated and probably buggy, but it's SLOOOOOW.
> It's totally the wrong API -- poking one instruction at a time
> basically can't be efficient on x86.  The API should either poke lots
> of instructions at once or should be text_poke_begin(); ...;
> text_poke_end();.

I don't think anybody ever cared about performance here. Only
correctness. That whole text_poke_bp() thing is entirely tricky.

FWIW, before text_poke_bp(), text_poke() would only be used from
stop_machine, so all the other CPUs would be stuck busy-waiting with
IRQs disabled. These days, yeah, that's lots more dodgy, but yes
text_mutex should be serializing all that.

And on that, I so hate comments like: "must be called under foo_mutex",
we have lockdep_assert_held() for that.
