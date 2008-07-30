From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: GRU driver feedback
Date: Wed, 30 Jul 2008 15:50:34 +1000
References: <20080723141229.GB13247@wotan.suse.de> <200807291200.09907.nickpiggin@yahoo.com.au> <20080729185315.GA14260@sgi.com>
In-Reply-To: <20080729185315.GA14260@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807301550.34500.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>, "Torvalds, Linus" <torvalds@linux-foundation.org>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 30 July 2008 04:53, Robin Holt wrote:
> On Tue, Jul 29, 2008 at 12:00:09PM +1000, Nick Piggin wrote:
> > On Tuesday 29 July 2008 03:36, Jack Steiner wrote:
> > > I appreciate the thorough review. The GRU is a complicated device. I
> > > tried to provide comments in the code but I know it is still difficult
> > > to understand.
> > >
> > > You appear to have a pretty good idea of how it works. I've added a
> > > few new comments to the code to make it clearer in a few cases.
> >
> > Hi Jack,
> >
> > Thanks very much for your thorough comments in return. I will take longer
> > to digest them, but quick reply now because you're probably rushing to
> > get things merged... So I think you've resolved all my concerns except
> > one.
> >
> > > > - GRU driver -- gru_intr finds mm to fault pages from, does an
> > > > "atomic pte lookup" which looks up the pte atomically using similar
> > > > lockless pagetable walk from get_user_pages_fast. This only works
> > > > because it can guarantee page table existence by disabling interrupts
> > > > on the CPU where mm is currently running.  It looks like atomic pte
> > > > lookup can be run on mms which are not presently running on the local
> > > > CPU. This would have been noticed if it had been using a specialised
> > > > function in
> > > > arch/*/mm/gup.c, because it would not have provided an mm_struct
> > > > parameter ;)
> > >
> > > Existence of the mm is guaranteed thru an indirect path. The  mm
> > > struct cannot go away until the GRU context that caused the interrupt
> > > is unloaded.  When the GRU hardware sends an interrupt, it locks the
> > > context & prevents it from being unloaded until the interrupt is
> > > serviced.  If the atomic pte is successful, the subsequent TLB dropin
> > > will unlock the context to allow it to be unloaded. The mm can't go
> > > away until the context is unloaded.
> >
> > It is not existence of the mm that I am worried about, but existence
> > of the page tables. get_user_pages_fast works the way it does on x86
> > because x86's pagetable shootdown and TLB flushing requires that an
> > IPI be sent to all running threads of a process before page tables
> > are freed. So if `current` is one such thread, and wants to do a page
> > table walk of its own mm, then it can guarantee page table existence
> > by turning off interrupts (and so blocking the IPI).
> >
> > This will not work if you are trying to walk down somebody else's
> > page tables because there is nothing to say the processor you are
> > running on will get an IPI. This is why get_user_pages_fast can not
> > work if task != current or mm != current->mm.
> >
> > So I think there is still a problem.
>
> I reserve the right to be wrong, but I think this is covered.

You're most welcome to have that right :) I exercise mine all the time!

In this case, I don't think you'll need it though.


> First, let me be clear about what I gathered your concern is.  I assume
> you are addressing the case of page tables being torn down.

That's what I was worried about in the above message, yes.


> In the case where unmap_region is clearing page tables, the caller to
> unmap_region is expected to be holding the mmap_sem writably.  Jacks fault
> handler will immediately return when it fails on the down_read_trylock().

No, you are right of course. I had in my mind the problems faced by lockless
get_user_pages, in which case I was worried about the page table existence,
but missed the fact that you're holding mmap_sem to provide existence (which
it would, as you note, although one day we may want to reclaim page tables
or something that doesn't take mmap_sem, so a big comment would be nice here).


> In the exit_mmap case, the sequence is mmu_notifier_release(), ... some
> other stuff ..., free_pgtables().  Here is where special hardware
> comes into play again.  The mmu_notifier_release() callout to the GRU
> will result in all of the GRU contexts for this MM to be torn down.
> That process will free the actual hardware's context.  The hardware-free
> portion of the hardware will not complete until all NUMA traffic
> associated with this context are finished and all fault interrupts have
> been either ack'd or terminated (last part of the interrupt handler).
>
> I am sorry for the rushed explanation.  I hope my understanding of your
> concern is correct and my explanation is clear.

You are right I think.

Hmm, isn't there a memory ordering problem in gru_try_dropin, between
atomic_read(ms_range_active); and atomic_pte_lookup();?

The write side goes like this:

pte_clear(pte);
atomic_dec_and_test(ms_range_active);

So the atomic pte lookup could potentially execute its loads first,
which finds the pte not yet cleared; and then the load of ms_range_active
executes and finds ms_range_active is 0, and the should have been
invalidated pte gets inserted.

I'm slightly scared of this flush-tlb-before-clearing-ptes design of tlb
flushing, as I've said lots of times now. I *think* it seems OK after
this (and the other) memory ordering issues are fixed, but you can just
see that it is more fragile and complex.

Anyway, I'll try to come up with some patches eventually to change all
that, and will try to get them merged. I'll stop whining about it now :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
