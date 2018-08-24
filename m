Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 545246B2EC0
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:43:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q26-v6so3416683wmc.0
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 01:43:19 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id g3-v6si4970658wrr.281.2018.08.24.01.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 Aug 2018 01:43:17 -0700 (PDT)
Date: Fri, 24 Aug 2018 10:42:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/4] mm/tlb: Remove tlb_remove_table() non-concurrent
 condition
Message-ID: <20180824084259.GJ24124@hirez.programming.kicks-ass.net>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.772017055@infradead.org>
 <20180823133103.30d6a16b@roar.ozlabs.ibm.com>
 <CA+55aFyY4fG8Hhds4ykSm5vUMdxbLdB7mYmC2pOPk8UKBXtpjA@mail.gmail.com>
 <20180823141642.38b53175@roar.ozlabs.ibm.com>
 <CA+55aFzfnWv3JoB0mR7iCX322KsiE+uRq3HcmOpciEAiTw-oLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzfnWv3JoB0mR7iCX322KsiE+uRq3HcmOpciEAiTw-oLw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 09:54:48PM -0700, Linus Torvalds wrote:

> It honored it for the *normal* case, which is why it took so long to
> notice that the TLB shootdown had been broken on x86 when it moved to
> the "generic" code. The *normal* case does this all right, and batches
> things up, and then when the batch fills up it does a
> tlb_table_flush() which does the TLB flush and schedules the actual
> freeing.
> 
> But there were two cases that *didn't* do that. The special "I'm the
> only thread" fast case, and the "oops I ran out of memory, so now I'll
> fake it, and just synchronize with page twalkers manually, and then do
> that special direct remove without flushing the tlb".

The actual RCU batching case was also busted; there was no guarantee
that by the time we run the RCU callbacks the invalidate would've
happened. Exceedingly unlikely, but no guarantee.

So really, all 3 cases in tlb_remove_table() were busted in this
respect.
