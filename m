Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f172.google.com (mail-ve0-f172.google.com [209.85.128.172])
	by kanga.kvack.org (Postfix) with ESMTP id 357CF6B0035
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 12:21:47 -0400 (EDT)
Received: by mail-ve0-f172.google.com with SMTP id jx11so7041242veb.3
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 09:21:46 -0700 (PDT)
Received: from mail-ve0-x235.google.com (mail-ve0-x235.google.com [2607:f8b0:400c:c01::235])
        by mx.google.com with ESMTPS id w5si3059898vcl.174.2014.04.27.09.21.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 27 Apr 2014 09:21:46 -0700 (PDT)
Received: by mail-ve0-f181.google.com with SMTP id oy12so6746269veb.40
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 09:21:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140427072034.GC1429@laptop.programming.kicks-ass.net>
References: <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
	<1398389846.8437.6.camel@pasglop>
	<1398393700.8437.22.camel@pasglop>
	<CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
	<5359CD7C.5020604@zytor.com>
	<CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
	<alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
	<20140425135101.GE11096@twins.programming.kicks-ass.net>
	<alpine.LSU.2.11.1404251215280.5909@eggly.anvils>
	<20140426180711.GM26782@laptop.programming.kicks-ass.net>
	<20140427072034.GC1429@laptop.programming.kicks-ass.net>
Date: Sun, 27 Apr 2014 09:21:45 -0700
Message-ID: <CA+55aFwLumAqA6mYyPKRZYOCr2TRPxUVdCKhHMg0nYN_KbBDbQ@mail.gmail.com>
Subject: Re: Dirty/Access bits vs. page content
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Sun, Apr 27, 2014 at 12:20 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> OK, so I've been thinking and figured I either mis-understand how the
> hardware works or don't understand how Linus' patch will actually fully
> fix the issue.
>
> So what both try_to_unmap_one() and zap_pte_range() end up doing is
> clearing the PTE entry and then flushing the TLBs.

Right. And we can't do it in the other order, since if we flush the
TLBs first, another cpu (or even this cpu, doing speculative memory
accesses) could re-fill them between the flush and the clearing of the
page table.

So that's race #1, easily fixed by ordering the TLB flush after
clearing the page table entry. We've never done this particular race
wrong, afaik. It's _so_ obvious that it's the only one we've always
gotten right.

On to the ones we've historically gotten wrong:

> However, that still leaves a window where there are remote TLB entries.
> What if any of those remote entries cause a write (or have a dirty bit
> cached) while we've already removed the PTE entry.

So this is race #2: the race between clearing the entry and a TLB miss
loading it and marking it accessed or dirty.

That race is handled by the fact that the CPU does the accessed/dirty
bit update as an atomic read-modify-write operation, and actually
re-checks the PTE entry as it does so.

So in theory a CPU could just remember what address it loaded the TLB
entry from, and do a blind "set the dirty bit" with just an atomic
"or" operation. In fact, for a while I thought that CPU's could do
that, and the TLB flushing sequence would be:

    entry = atomic_xchg(pte, 0);
    flush_tlb();
    entry |= *pte;

so that we'd catch any races with the A/D bit getting set.

It turns out no CPU actually does that, and I'm not sure we ever had
that code sequence in the kernel (but some code archaeologist might go
look).

What CPU's actually do is simpler both for them and for us: instead of
remembering where they loaded the TLB entry from, they re-walk the
page table when they mark the TLB dirty, and if the page table entry
is no longer present (or if it's non-writable), the store will fault
instead of marking the TLB entry dirty.

So race #2 doesn't need the above complex sequence, but it still
*does* need that TLB entry to be loaded with an atomic exchange with
zero (or at least with something that clears the present bit, zero
obviously being the simplest such value). So a simple

    entry = atomic_xchg(pte, 0);

is sufficient for this race (except we call it "ptep_get_and_clear()" ;)

Of course, *If* a CPU were to remember the address it loaded the TLB
entry from, then such a CPU might as well make the TLB be part of the
cache-coherency domain, and then we wouldn't need to do any TLB
flushing at all. I wish.

> Will the hardware fault when it does a translation and needs to update
> the dirty/access bits while the PTE entry is !present?

Yes indeed, see above (but see how broken hardware _could_ work, which
would be really painful for us).

What we are fighting is race #3: the TLB happily exists on this or
other CPU's, an dis _not_ getting updated (so no re-walk), but _is_
getting used.

And we've actually had a fix for race #3 for a long time: the whole
"don't free the pages until after the flush" is very much this issue.
So it's not a new condition by any means (as far as I can tell, the
mmu_gather infrastructure was introduced in 2.4.9.13, so 2001 - the
exact commit predates even BK history).

But this new issue is related to race #3, but purely in software: when
we do the "set_page_dirty()" before doing the TLB flush, we need to
protect against our cleaning that bit until after the flush.

And we've now had three different ways to fix that race, one
introducing a new race (my original two-patch series that delayed the
set_page_dirty() the same way we delay the page freeing), one using a
new lock entirely (Hugh latest patch - mapping->i_mmap_mutex isn't a
new lock, but in this context it is), and one that extends the rules
we already had in place for the single-PTE cases (do the
set_page_dirty() and TLB flushing atomically wrt the page table lock,
which makes it atomic wrt mkclean_one).

And the reason I think I'll merge my patch rather than Hugh's (despite
Hugh's being smaller) is exactly the fact that it doesn't really
introduce any new locking rules - it just fixes the fact that we
didn't really realize how important it was, and didn't follow the same
rules as the single-pte cases did.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
