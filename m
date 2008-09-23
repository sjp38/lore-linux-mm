Date: Tue, 23 Sep 2008 11:50:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: PTE access rules & abstraction
Message-ID: <20080923095054.GA29951@wotan.suse.de>
References: <1221846139.8077.25.camel@pasglop> <48D739B2.1050202@goop.org> <1222117551.12085.39.camel@pasglop> <20080923031037.GA11907@wotan.suse.de> <1222147886.12085.93.camel@pasglop> <48D88904.4030909@goop.org> <1222152572.12085.129.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1222152572.12085.129.camel@pasglop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 23, 2008 at 04:49:32PM +1000, Benjamin Herrenschmidt wrote:
> 
> > A good first step might be to define some conventions.  For example,
> > define that set_pte*() *always* means setting a non-valid pte to either
> > a new non-valid state (like a swap reference) or to a valid state. 
> > modify_pte() would modify the flags of a valid
> > pte, giving a new valid pte.  etc...
> 
> Yup. Or make it clear that ptep_set_access_flags() should only be used
> to -relax- access (ie, set dirty, writeable, accessed, ... but not
> remove any of them).
> 
> > It may be that a given architecture collapses some or all of these down
> > to the same underlying functionality, but it would allow the core intent
> > to be clearly expressed.
> > 
> > What is the complete set of primitives we need?  I also noticed that a
> > number of the existing pagetable operations are used only once or twice
> > in the core code; I wonder if we really need such special cases, or
> > whether we can make each arch pte operation carry a bit more weight?
> 
> Yes, that was some of my concern. It's getting close to having one API
> per call site :-)

I don't think that is a huge problem as such... if there was lots of
repeated uses of the API I'd also be concerned about mm/ code not being
well factored :)

My concern is that things aren't well documented, maybe not consistent
enough, and are usually named according to what their implementation looks
like on the favourite arch of the person who introduced them, rather than
what the VM needs to get done :P

Which leads some architectures (I'm looking at ia64 ;)) to reinvent things
or just add new primitives rather than finding existing common code. Which
makes the problem worse.

And it makes generic VM developers not be able to follow what's going on
with all the different architectures...


 
> > Also, rather than leaving all the rule enforcing to documentation and a
> > maintainer, we should also consider having a debug mode which adds
> > enough paranoid checks to each operation so that any rule breakage will
> > fail obviously on all architectures.
> 
> We could do both.
> 
> Now, regarding operations, let's first find the major call sites, see
> what I miss. I'm omitting free_* in memory.c as those are for freeing
> pte pages, not accessing PTEs themselves. I'm also ignoring read-only
> call sites and hugetlb for now.
> 
> * None-iterative accessors
> 
>  - handle_pte_fault in memory.c, on "fixup" faults (pte is present and
> it's not a COW), for fixing up DIRTY and ACCESSED (btw, could we make
> that also fixup EXEC ? I would like this for some stuff I'm working on
> at the moment, ie set it if the vma has VM_EXEC and it was lost from the
> PTE as I might want to mask it out of PTEs under some circumstances).
> Textbook usage of ptep_set_access_flags(), so that's fine.
> 
>  - do_wp_page() in memory.c for COW or fixup of shared writeable mapping
> writeable-ness. Doesn't overwrite existing PTE for COW anymore, it uses
> clear_flush nowadays and fixup of shared writeable mapping uses
> ptep_set_access_flags() as it should, so that's all good.

This is one example of being too low level. It wouldn't be hard to have
an arch where the SMC race does not apply, or even it is probably possible
to avoid the flush in the case of single-threaded mm. Can't do that however,
because the call asks for a flush so we must flush.

 
>  - insert_pfn() and insert_page() still in memory.c for fancy page
> faults. Just a trivial set_pte_at() of a !present one, no big deal here
> 
>   - RMAP ones ? Some ad-hoc stuff due to _notify thingies.

rmap ones should only do set_pte_at after a clear_flush I think.
 

> * Iterative accessors (some don't batch, maybe they could/should).
> 
>  - zapping a mapping (zap_p*) in memory.c
>  - fork (copy_p*) in memory.c could batch better maybe ?
>  - setting linear user mappings (remap_p*) in memory.c, trivial
> set_pte_at() on a range, pte's should be !present I think.

Yes.


>  - mprotect (change_p*) in memory.c, which has the problem I mentioned
>  - moving page tables (move_p*), pretty trivial clear_flush + set_pte_at
>  - clear_regs_pte_range via walk_page_range in fs/proc/task_mmu.c, does
> a test_and_clear_young, flushes mm afterward, could use some lazy stuff
> so we can batch properly on ppc64.
>  - vmalloc, that's a bit special and kernel only, doesn't have nasty
> races between creating/tearing down mappings vs. using them
>  - highmem I leave alone for now, it's mostly trivial set_pte_at &
> flushing for normal kmap but kmap_atomic can be nasty, though it's arch
> specific.

It's also for kva rather than uva, so it's a bit different too...


>  - some stuff in fremap I'm not too familiar with and I need to run...

fremap is only ever doing clear_flush on present ptes, or set_pte_at on
pte_none_ptes (and in this case it is going from !present to !present,
which is probably also unusual in some cases for arch code to deal with,
although it is not restricted to fremap I guess)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
