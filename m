Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD9246B2833
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 00:55:00 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s15-v6so3338608iob.11
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 21:55:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b12-v6sor1268128iok.136.2018.08.22.21.54.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 21:54:59 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180822154046.772017055@infradead.org>
 <20180823133103.30d6a16b@roar.ozlabs.ibm.com> <CA+55aFyY4fG8Hhds4ykSm5vUMdxbLdB7mYmC2pOPk8UKBXtpjA@mail.gmail.com>
 <20180823141642.38b53175@roar.ozlabs.ibm.com>
In-Reply-To: <20180823141642.38b53175@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 21:54:48 -0700
Message-ID: <CA+55aFzfnWv3JoB0mR7iCX322KsiE+uRq3HcmOpciEAiTw-oLw@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/tlb: Remove tlb_remove_table() non-concurrent condition
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 9:16 PM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> On Wed, 22 Aug 2018 20:35:16 -0700
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> >
> > And yes, those lazy tlbs are all kernel threads, but they can still
> > speculatively load user addresses.
>
> So?
>
> If the arch does not shoot those all down after the user page tables
> are removed then it's buggy regardless of this short cut.

Read the code.

That shortcut frees the pages *WITHOUT* doing that TLB flush. It just
does __tlb_remove_table(), which does *not* do that whole page
queueing so that we can batch flush and then free later.

So the fast-case it's buggy, exactly because of the reason you state.

The logic used to be that if you were the only cpu that had that tlb,
and it was a mid-level table, it didn't need that synchronization at
all.

And that logic is simply wrong. Exactly because even if mm_users is 1,
there can be things looking up TLB entries on other CPU's. Either
because of a lazy mm and a hw walker with speculation, or because of
use_mm() and a software walker.

So the whole "free immediately" shortcut was bogus. You *always* need
to queue, then flush the tlb, and then free.

That said, that wasn't actually the bug that Jann found. He found the
bug a few lines lower down, where the "I can't allocate memory for
queueing" ended up *also* not flushing the TLB.

> The only real problem I could see would be if a page walk cache still
> points to the freed table, then the table gets re-allocated and used
> elsewhere, and meanwhile a speculative access tries to load an entry
> from the page that is an invalid form of page table that might cause
> a machine check or something. That would be (u)arch specific, but if
> that's what we're concerned with here it's a different issue and needs
> to be documented as such.

We've *seen* that case, we had exactly that when we were being
aggressive about trying to avoid flushes for the lazy mmu case
entirely, because "we can just flush when we activate the lazy mm
state instead".

The logic was actually solid from a TLB case - who cares what garbage
TLB entries we might speculatively fill, when we're going to flush
them before they can possibly be used.

It turns out that that logic is solid, but hits another problem: at
least some AMD CPU's will cause machine checks when the TLB entries
are inconsistent with the machine setup. That can't happen with a
*good* page table, but when you speculatively walk already freed
tables, you can get any garbage.

I forget what the exact trigger was, but this was actually reported.
So you can't free page directory pages without flushing the tlb first
(to make that internal tlb node caches are flushed).

So the logic for freeing leaf pages and freeing middle nodes has to be
exactly the same: you make the modification to the page table to
remove the node/leaf, you queue up the memory for freeing, you flush
the tlb, and you then free the page.

That's the ordering that tlb_remove_page() has always honored, but
that tlb_remove_tabl() didn't.

It honored it for the *normal* case, which is why it took so long to
notice that the TLB shootdown had been broken on x86 when it moved to
the "generic" code. The *normal* case does this all right, and batches
things up, and then when the batch fills up it does a
tlb_table_flush() which does the TLB flush and schedules the actual
freeing.

But there were two cases that *didn't* do that. The special "I'm the
only thread" fast case, and the "oops I ran out of memory, so now I'll
fake it, and just synchronize with page twalkers manually, and then do
that special direct remove without flushing the tlb".

NOTE! Jann triggered that one by
 (a) forcing the machine low on memory
 (b) force-poisoning the page tables immediately after free

I suspect it's really hard to trigger under normal loads, exactly
because the *normal* case gets it right. It's literally the "oops, I
can't batch up because I ran out of memory" case that gets it wrong.

(And the special single-thread + lazy or use_mm() case, but that's
going to be entirely impossible to trigger, because in practice it's
just a single thread, and you won't ever hit the magic timing needed
that frees the page in the single thread at exactly the same time that
some optimistic lazy mm on another cpu happens to speculatively load
that address).

So the "atomic_read(&mm_users)" case is likely entirely impossible to
trigger any sane way. But because Jann found the problem with the 'ran
out of memory" case, we started looking at the more theoretical cases
that matched the same kind of "no tlb flush before free" pattern.

              Linus
