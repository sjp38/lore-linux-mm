Date: Wed, 30 Apr 2008 08:03:40 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] data race in page table setup/walking?
Message-ID: <20080430060340.GE27652@wotan.suse.de>
References: <20080429050054.GC21795@wotan.suse.de> <Pine.LNX.4.64.0804291333540.22025@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804291333540.22025@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 01:36:41PM +0100, Hugh Dickins wrote:
> On Tue, 29 Apr 2008, Nick Piggin wrote:
> > I *think* there is a possible data race in the page table walking code. After
> > the split ptlock patches, it actually seems to have been introduced to the core
> > code, but even before that I think it would have impacted some architectures.
> > 
> > The race is as follows:
> > The pte page is allocated, zeroed, and its struct page gets its spinlock
> > initialized. The mm-wide ptl is then taken, and then the pte page is inserted
> > into the pagetables.
> > 
> > At this point, the spinlock is not guaranteed to have ordered the previous
> > stores to initialize the pte page with the subsequent store to put it in the
> > page tables. So another Linux page table walker might be walking down (without
> > any locks, because we have split-leaf-ptls), and find that new pte we've
> > inserted. It might try to take the spinlock before the store from the other
> > CPU initializes it. And subsequently it might read a pte_t out before stores
> > from the other CPU have cleared the memory.
> > 
> > There seem to be similar races in higher levels of the page tables, but they
> > obviously don't involve the spinlock, but one could see uninitialized memory.
> 
> It's sad, but I have to believe you're right.  I'm slightly more barrier-
> aware now than I was back when doing split ptlock (largely thanks to your
> persistence); and looking back at it, I cannot now imagine how it could
> be correct to remove a lock from that walkdown without adding barriers.

Well don't worry too much, I was one of the reviewers of that code too :P In
our defence, there were pre-existing counter examples of lockless page table
walking in arch code... but it is sometimes just really hard to spot these
ordering races. We've had many many others in mm/ I'm afraid to say.


> Ugh.  It's just so irritating to introduce these blockages against
> such a remote possibility (but there again, that's what so much of
> kernel code has to be about).  Is there any other way of handling it?

As Ben pointed out, the overhead is not too bad. On the read path, only
Alpha would care (and if Alpha was more than a curiosity at this point,
I guess they could introduce a lighter barrier, or detect if a specific
implementation doesn't require data dep barriers).


> > Arch code and hardware pagetable walkers that walk the pagetables without
> > locks could see similar uninitialized memory problems (regardless of whether
> > we have split ptes or not).
> 
> The hardware walkers, hmm.  Well, I guess each arch has its own rules
> to protect against those, and all you can do is provide a macro for
> each to fill in.   You assume smp_read_barrier_depends versus smp_wmb
> below: sure of those, or is it worth providing particular new stubs?

Yes, it definitely is a data dependency barrier: the load of the pte page
spinlock or the ptes out of the page itself depends on the load of the
pointer to the pte page.

Hardware walkers, I shouldn't worry too much about, except as a thought
exercise to realise that we have lockless readers. I think(?) alpha can
walk the linux ptes in hardware on TLB miss, but surely they will have
to do the requisite barriers in hardware too (otherwise things get
really messy)

Powerpc's find_linux_pte is one of the software walked lockless ones.
That's basically how I imagine hardware walkers essentially should operate.


> > This isn't a complete patch yet, but a demonstration of the problem, and an
> > RFC really as to the form of the solution. I prefer to put the barriers in
> > core code, because that's where the higher level logic happens, but the page
> > table accessors are per-arch, and open-coding them everywhere I don't think
> > is an option.
> 
> If there's no better way (I think not), this looks about right to me;
> though I leave all the hard thought to you ;)

I'll work on it ;) Thanks for the comments.

 
> While I'm in the confessional, something else you probably need to
> worry about there: handle_pte_fault's "entry = *pte" without holding
> the lock; several cases are self-righting, but there's pte_unmap_same
> for a couple of cases where we need to make sure of the right decision
> - presently it's only worrying about the PAE case, when it might have
> got the top of one pte with the bottom of another, but now you need
> some barrier thinking?  Oh, perhaps this is already safely covered
> by your pte_offset_map.

Yes I think it should be OK to dereference it because we came to it
from pte_alloc_map.

The issue of taking the top or bottom of the pte I think is a different
data race, and yes I think we don't have to worry about it (although
it would be nice to wrap _all_ page table dereferences in functions, so
we can audit and modify them more easily).

Actually, aside, all those smp_wmb() things in pgtable-3level.h can
probably go away if we cared: because we could be sneaky and leverage
the assumption that top and bottom will always be in the same cacheline
and thus should be shielded from memory consistency problems :)

 
> The pte_offset_kernel one (aside from the trivial of needing a ret):
> I'm not convinced that needs to be changed at all.  I still believe,
> as I believed at split ptlock time, that the kernel walkdowns need
> no locking (or barriers) of their own: that it's a separate kernel
> bug if a kernel subsystem is making speculative accesses to addresses
> it cannot be sure have been allocated.  Counter-examples?
> 
> Ah, but perhaps naughty userspace (depending on architecture) could
> make those speculative accesses into kernel address space, and have
> a chance of striking lucky with the hardware walker, without proper
> barriers at the kernel end?

I'm not sure about that. Apparently the hardware prefetcher can do
pretty wild things on some CPUs including setting up TLBs. As far
as userspace access goes, I'm not completely sure, either.

My thinking is that it might be better not to take any chances even
in the kernel path. I guess I should comment my thinking, so that it
can be easier to understand/dispute in future.


> > So anyway... comments, please? Am I dreaming the whole thing up? I suspect
> > that if I'm not, then powerpc at least might have been impacted by the race,
> > but as far as I know of, they haven't seen stability problems around there...
> > Might just be terribly rare, though. I'd like to try to make a test program
> > to reproduce the problem if I can get access to a box...
> 
> Please do, if you're feeling ingenious: it's tiresome adding overhead
> without being able to show it's really achieved something.

Heh ;) I'll try to kick some grey cells into action and think up something!
I'd still like to demonstrate it even if everyone agrees that it is a
problem.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
