Date: Tue, 23 Aug 2005 09:14:52 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
In-Reply-To: <Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0508230822300.5224@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks a lot for looking into it so quickly, Christoph.  Sorry for
giving you the work of deciphering it with so little description.

On Mon, 22 Aug 2005, Christoph Lameter wrote:
> On Mon, 22 Aug 2005, Hugh Dickins wrote:
> 
> > Here's my alternative to Christoph's pagefault scalability patches:
> > no pte xchging, just narrowing the scope of the page_table_lock and
> > (if CONFIG_SPLIT_PTLOCK=y when SMP) splitting it up per page table.
> 
> The basic idea is to have a spinlock per page table entry it seems.

A spinlock per page table, not a spinlock per page table entry.

That's the split ptlock Y part, but most of the patch is just moving the
taking and release of the lock inwards, good whether or not we split.

> I think that is a good idea since it avoids atomic operations and I
> hope it will bring the same performance as my patches (seems that the 
> page_table_lock can now be cached on the node that the fault is 
> happening). However, these are very extensive changes to the vm.

Maybe not push it for 2.6.13 ;-?

> The vm code in various places expects the page table lock to lock the 
> complete page table. How do the page based ptl's and the real ptl 
> interact?

If split ptlock N, they're one and the same - though that doesn't mean
there are no issues raised e.g. zap drops the lock at the end of the
pagetable, are all arch's tlb mmu_gather operations happy with that?
I have more checking to do there.

If split ptlock Y, then the mm->page_table_lock (could be renamed)
doesn't do much more than guard page table and anon_vma allocation,
a few other odds and ends.  All the interesting load falls on the
per-pt lock.  So long as arches don't have special code involving
page_table_lock, that change shouldn't matter to them; but a few
do (e.g. sparc64) and need checking/conversion.

> There are these various hackish things in there that will hopefully be 
> taken care of. F.e. there really should be a spinlock_t ptl in the struct 
> page. Spinlock_t is often much bigger than an unsigned long.

Yes, see my reply to Nick: I believe it's okay for now, even with
debug options, but fragile.  If it stays, needs robustification.

> The patch generally drops the first acquisition of the page 
> table lock from handle_mm_fault that is used to protect the read 
> operations on the page table. I doubt that this works with i386 PAE since 
> the page table read operations are not protected by the ptl. These are 64 
> bit which cannot be reliably retrieved in an 32 bit operation on i386 as 
> you pointed out last fall. There may be concurrent writes so that one 
> gets two pieces that do not fit. PAE mode either needs to fall back to 
> take the page_table_lock for reads or use some tricks to guarantee 64bit 
> atomicity.

Yes, you referred to that "futility" in mail a few days ago: sorry if
it seemed like I was ignoring you, I did embark upon a reply, but in
the course of that reply decided that I needed to spend the time getting
the patch right, then explain it after.

I've memories of that too.  Spent a while looking through my sent mail -
very spooky.  It was probably this concluding remark from 12 Dec 04,

> > Oh, hold on, isn't handle_mm_fault's pmd without page_table_lock
> > similarly racy, in both the 64-on-32 cases, and on architectures
> > which have a more complex pmd_t (sparc, m68k, h8300)?  Sigh.

The list is frv, h8300, i386 PAE, m68k, m68knommu, sparc, uml 3level32.

Needn't worry about h8300 and m68knommu because they're NOMMU.
Needn't worry about frv and m68k since they're neither SMP nor PREEMPT
(I haven't deciphered frv here, wonder if it's just been defined the
other way round from the other architectures).  UML would follow
what's decided for the others.

So the problem ones are i386 PAE and sparc: I haven't got down to sparc
yet, I expect it to need a little reordering and barriers, but no great
problem.

I don't believe we need to read or write the PAE entries atomically.

When writing we certainly need the ptlock, and we certainly need
correct ordering (there's already a wmb between writing the top half
and writing the bottom); oh, and yes, ptep_establish for rewriting
existing entries does need the atomicity it already has (I think,
I'm writing this reply in a rush, not cross-checking every word).

But the reading.  In particular, that "entry = *pte" in handle_pte_fault.
I believe that's fine, provided that the do_..._page handlers are
necessarily sceptical about that entry they're passed.  They're quite
free to do things like allocate a new page, or look up a cache page,
without checking, so long as they recheck entry under ptlock before
proceeding further, as they already did.  But they must not do anything
irrevocable, anything that might issue an error message to the logs,
if the entry they're passed is actually a mismatch of two halfs.
I believe I've already put in the necessary code for that e.g.
the sizeof(pte_t) checks.

Another aspect is peeking at (in particular) *pmd with any lock: that
too might give mismatched halves and nonsense, that's what alarmed me
in my mail last December.

After dealing with the really hard issues (how to get the definitions
and inlines into the header files without crashing the HIGHPTE build)
yesterday, I spent several hours ruminating again on that *pmd issue,
holding off from making a hundred edits; and in the end added just
an unsigned long cast into the i386 definition of pmd_none.  We must
avoid basing decisions on two mismatched halves; but pmd_present is
already safe, and now pmd_none also.  The remaining races are benign.

What do you think?

> I have various bad feelings about some elements but I like the general 
> direction.

Great (except for the bad feelings!).

> > Certainly not to be considered for merging into -mm yet: contains
> > various tangential mods (e.g. mremap move speedup) which should be
> > split off into separate patches for description, review and merge.
> 
> Could you modularize these patches? Its difficult to review as one. Maybe 
> separate the narrowing and the splitting and the miscellaneous things?

Of course I must.  This wasn't sent for review (though your review much
appreciated), just as something to try out to see if worth pursuing.
A suite of 39 seemed more hindrance than help at this stage.

(You may well feel a little review is in order before putting strange
patches on your special machines!)

The first sub-patches I post should be for some of the very tangential
things, tidyups that could safely go forward to 2.6.14 (perhaps).
Hopefully merging those would reduce the diff somewhat - though it'll
certainly need helpful subdivision and description beyond that.

> > Presented as a Request For Testing - any chance, Christoph, that you
> > could get someone to run it up on SGI's ia64 512-ways, to compare
> > against the vanilla 2.6.13-rc6-mm1 including your patches?  Thanks!
> 
> Compiles and boots fine on ia64. Survives my benchmark on a smaller box. 
> Numbers and more details will follow later. It takes some time to get a
> bigger iron. 

Thanks again for such prompt feedback,
Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
