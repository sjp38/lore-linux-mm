Date: Tue, 29 Jul 2008 13:53:15 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: GRU driver feedback
Message-ID: <20080729185315.GA14260@sgi.com>
References: <20080723141229.GB13247@wotan.suse.de> <20080728173605.GB28480@sgi.com> <200807291200.09907.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200807291200.09907.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 29, 2008 at 12:00:09PM +1000, Nick Piggin wrote:
> On Tuesday 29 July 2008 03:36, Jack Steiner wrote:
> > I appreciate the thorough review. The GRU is a complicated device. I
> > tried to provide comments in the code but I know it is still difficult
> > to understand.
> >
> > You appear to have a pretty good idea of how it works. I've added a
> > few new comments to the code to make it clearer in a few cases.
> 
> Hi Jack,
> 
> Thanks very much for your thorough comments in return. I will take longer
> to digest them, but quick reply now because you're probably rushing to
> get things merged... So I think you've resolved all my concerns except one.
> 
> 
> > > - GRU driver -- gru_intr finds mm to fault pages from, does an "atomic
> > > pte lookup" which looks up the pte atomically using similar lockless
> > > pagetable walk from get_user_pages_fast. This only works because it can
> > > guarantee page table existence by disabling interrupts on the CPU where
> > > mm is currently running.  It looks like atomic pte lookup can be run on
> > > mms which are not presently running on the local CPU. This would have
> > > been noticed if it had been using a specialised function in
> > > arch/*/mm/gup.c, because it would not have provided an mm_struct
> > > parameter ;)
> >
> > Existence of the mm is guaranteed thru an indirect path. The  mm
> > struct cannot go away until the GRU context that caused the interrupt
> > is unloaded.  When the GRU hardware sends an interrupt, it locks the
> > context & prevents it from being unloaded until the interrupt is
> > serviced.  If the atomic pte is successful, the subsequent TLB dropin
> > will unlock the context to allow it to be unloaded. The mm can't go
> > away until the context is unloaded.
> 
> It is not existence of the mm that I am worried about, but existence
> of the page tables. get_user_pages_fast works the way it does on x86
> because x86's pagetable shootdown and TLB flushing requires that an
> IPI be sent to all running threads of a process before page tables
> are freed. So if `current` is one such thread, and wants to do a page
> table walk of its own mm, then it can guarantee page table existence
> by turning off interrupts (and so blocking the IPI).
> 
> This will not work if you are trying to walk down somebody else's
> page tables because there is nothing to say the processor you are
> running on will get an IPI. This is why get_user_pages_fast can not
> work if task != current or mm != current->mm.
> 
> So I think there is still a problem.

I reserve the right to be wrong, but I think this is covered.

First, let me be clear about what I gathered your concern is.  I assume
you are addressing the case of page tables being torn down.

In the case where unmap_region is clearing page tables, the caller to
unmap_region is expected to be holding the mmap_sem writably.  Jacks fault
handler will immediately return when it fails on the down_read_trylock().

In the exit_mmap case, the sequence is mmu_notifier_release(), ... some
other stuff ..., free_pgtables().  Here is where special hardware
comes into play again.  The mmu_notifier_release() callout to the GRU
will result in all of the GRU contexts for this MM to be torn down.
That process will free the actual hardware's context.  The hardware-free
portion of the hardware will not complete until all NUMA traffic
associated with this context are finished and all fault interrupts have
been either ack'd or terminated (last part of the interrupt handler).

I am sorry for the rushed explanation.  I hope my understanding of your
concern is correct and my explanation is clear.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
