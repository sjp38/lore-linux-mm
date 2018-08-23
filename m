Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7534D6B2850
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:15:26 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g36-v6so1996688plb.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 22:15:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z19-v6sor930894pgj.192.2018.08.22.22.15.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 22:15:25 -0700 (PDT)
Date: Thu, 23 Aug 2018 15:15:16 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/4] mm/tlb: Remove tlb_remove_table() non-concurrent
 condition
Message-ID: <20180823151516.5dc87dbf@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFzfnWv3JoB0mR7iCX322KsiE+uRq3HcmOpciEAiTw-oLw@mail.gmail.com>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.772017055@infradead.org>
	<20180823133103.30d6a16b@roar.ozlabs.ibm.com>
	<CA+55aFyY4fG8Hhds4ykSm5vUMdxbLdB7mYmC2pOPk8UKBXtpjA@mail.gmail.com>
	<20180823141642.38b53175@roar.ozlabs.ibm.com>
	<CA+55aFzfnWv3JoB0mR7iCX322KsiE+uRq3HcmOpciEAiTw-oLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 22 Aug 2018 21:54:48 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Aug 22, 2018 at 9:16 PM Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > On Wed, 22 Aug 2018 20:35:16 -0700
> > Linus Torvalds <torvalds@linux-foundation.org> wrote:  
> > >
> > > And yes, those lazy tlbs are all kernel threads, but they can still
> > > speculatively load user addresses.  
> >
> > So?
> >
> > If the arch does not shoot those all down after the user page tables
> > are removed then it's buggy regardless of this short cut.  
> 
> Read the code.
> 
> That shortcut frees the pages *WITHOUT* doing that TLB flush.

I've read the code and I understand that. Hence I'm asking because I
did't think the changelog matched the change. But possibly it was
because I actually didn't read the changelog enough -- I guess it does
say the TLB operation is the problem. I may have got side tracked by
the word speculativee.

> It just
> does __tlb_remove_table(), which does *not* do that whole page
> queueing so that we can batch flush and then free later.
> 
> So the fast-case it's buggy, exactly because of the reason you state.

Okay sure, thanks for confirming it for me. I would ask for changelog
to be slightly expanded on, but maybe it's just my reading
comprehension needs improvement...

> > The only real problem I could see would be if a page walk cache still
> > points to the freed table, then the table gets re-allocated and used
> > elsewhere, and meanwhile a speculative access tries to load an entry
> > from the page that is an invalid form of page table that might cause
> > a machine check or something. That would be (u)arch specific, but if
> > that's what we're concerned with here it's a different issue and needs
> > to be documented as such.  
> 
> We've *seen* that case, we had exactly that when we were being
> aggressive about trying to avoid flushes for the lazy mmu case
> entirely, because "we can just flush when we activate the lazy mm
> state instead".
> 
> The logic was actually solid from a TLB case - who cares what garbage
> TLB entries we might speculatively fill, when we're going to flush
> them before they can possibly be used.
> 
> It turns out that that logic is solid, but hits another problem: at
> least some AMD CPU's will cause machine checks when the TLB entries
> are inconsistent with the machine setup. That can't happen with a
> *good* page table, but when you speculatively walk already freed
> tables, you can get any garbage.

Yeah that does make sense.

> 
> I forget what the exact trigger was, but this was actually reported.
> So you can't free page directory pages without flushing the tlb first
> (to make that internal tlb node caches are flushed).
> 
> So the logic for freeing leaf pages and freeing middle nodes has to be
> exactly the same: you make the modification to the page table to
> remove the node/leaf, you queue up the memory for freeing, you flush
> the tlb, and you then free the page.
> 
> That's the ordering that tlb_remove_page() has always honored, but
> that tlb_remove_tabl() didn't.
> 
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
> 
> NOTE! Jann triggered that one by
>  (a) forcing the machine low on memory
>  (b) force-poisoning the page tables immediately after free
> 
> I suspect it's really hard to trigger under normal loads, exactly
> because the *normal* case gets it right. It's literally the "oops, I
> can't batch up because I ran out of memory" case that gets it wrong.
> 
> (And the special single-thread + lazy or use_mm() case, but that's
> going to be entirely impossible to trigger, because in practice it's
> just a single thread, and you won't ever hit the magic timing needed
> that frees the page in the single thread at exactly the same time that
> some optimistic lazy mm on another cpu happens to speculatively load
> that address).
> 
> So the "atomic_read(&mm_users)" case is likely entirely impossible to
> trigger any sane way. But because Jann found the problem with the 'ran
> out of memory" case, we started looking at the more theoretical cases
> that matched the same kind of "no tlb flush before free" pattern.

Thanks for giving that background. In that case I'm happy with this fix.

Thanks,
Nick
