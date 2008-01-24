Date: Thu, 24 Jan 2008 12:01:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
In-Reply-To: <20080124143454.GN7141@v2.random>
Message-ID: <Pine.LNX.4.64.0801241141030.22285@schroedinger.engr.sgi.com>
References: <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random>
 <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random>
 <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
 <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com>
 <20080123114136.GE15848@v2.random> <Pine.LNX.4.64.0801231149150.13547@schroedinger.engr.sgi.com>
 <20080124143454.GN7141@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jan 2008, Andrea Arcangeli wrote:

> > SetPageExported is set when a remote instance of linux establishes a 
> > reference to the page (a kind of remote page fault). In the KVM scenario 
> > that would occur when memory is made available.
> 
> The remote page fault is exactly the thing that has to wait on the
> PageExported bit to return on! So how can it be the thing that sets
> SetPageExported?

I do not remember us saying that the remote page fault has to wait on PageExported.

> The idea is:
> 
>     NODE0			NODE1

SetPageLocked

>     ->invalidate_page()
>     ClearPageExported
>     GFP_KERNEL (== GFP_ATOMIC in mm/rmap.c, won't ever do any I/O)
> 
> 				->invalidate_page() arrives and drop
>                                   references
> 
ClearPageLocked

>     __free_page -> unpin so it can be freed
>     go ahead after invalidate_page
> 
>     zero locking so previous invalidate_page could schedule (not wait for I/O,
>     there' won't be any I/O out of GFP_KERNEL inside PF_MEMALLOC i.e. mm/rmap.c!!!)

PageLocked is set and there could be synchronization among the 
callbacks. F.e. the mm_struct invalidate_page could set a flag to prevent 
new references to be established. The callback after removal of the OS 
ptes could reenable establishing new references.

> 
> 				remote page fault
> 				tries to instantiate more references
>     remote page fault arrives
>     instantiate more references
>     get_page() -> pin

lock_page	Waits until rmap is complete. Then rechecks if page is 
		still part of the mapping.

>     SetPageExported
> 				remote page fault succeeded
> 
>     zero locking so invalidate_page can schedule (not wait for I/O,
>     there' won't be any I/O out of GFP_KERNEL!)

Ok this is often a PF_MEMALLOC context. We already do disk I/O in that 
context?

 
> I thought your solution was to have the remote page fault wait on
> PG_exported to return ON!! But now you tell me the remote page fault
> is the thing that has to SetPageExported, not the linux VM. So make up
> your mind about this PG_exported mess...

The SetPageExported is mainly a switchon/off of the callbacks for a page. 
Not necessarily used for synchronization. PageExported should be modified 
under Pagelock.


> > You are saying that clearing the main linux ptes and leaving the remote 
> > ptes in place will not allow access to the page via the remote ptes?
> 
> No, I'm saying if you clear the main linux pte while there are still
> remote ptes in place (in turn the page_count has been boosted by 1
> with your current code), and you relay on mm/rmap.c for the
> ->invalidate_page, you will generate a unswappable-pin-leak.

The invalidate_page presumably would reduce the page count to zero after 
clearing the remote ptes?
 
> The linux pte must be present and the page must be mapped in userland
> as long as there are remote references to the page and in turn as long
> as the page_count has been boosted by 1. Otherwise mm/rmap.c won't be
> called.

page_mapped() must be true. So we would need to increase mapcount instead 
of page_count?

> At the very least you should move your invalidate_page in
> mm/vmscan.c and have it called regardless if the page is mapped in
> userland or not.

That would not cover page migration and other uses. We also need the
invalidate_page for page_mkclean etc. Needed for dirty page tracking.


> > Right. That is why the mmu_ops approach does not work and that is why we 
> > need to sleep.
> 
> You told me you worried about atomic allocations. Now you tell me you
> need to sleep after I just explained you how utterly useless is to
> sleep inside GFP_KERNEL allocations when invoked by try_to_unmap in
> the mm/rmap.c paths. You will never sleep in any memory allocation
> other than to call schedule() because need_resched is set. You will do
> zero I/O. all your allocations will come from the PF_MEMALLOC pool
> like I said above, not from swapping, not from the VM. The VM will
> obviously refuse to be invoked recursively.

That may be okay if we do not need to generate listheads to track all the 
mm_structs in the rmap loops. If we loop on our own then we do not need to 
construct this list and can directly communicate with the other partition.

> Also not sure why you call my patch mmops, when it's mmu_notifier instead.

Oh. Sorry. Will use the correct name in the future. I think I keyed of the 
mm_ops structure.

> > > All kvm guest physical pages would need to be marked exported of
> > > course.
> > 
> > Why export all pages? Then you are planning to have mm_struct 
> > notifiers for all processes in the system?
> 
> KVM is 1 process, not sure how you get to imagine I need to track
> process in the system, when infact I only need to track pages
> belonging to the KVM process.

Ahh. A KVM is one process to the host but may have multiple processes 
running in it and you want the notifier for the one process in the host.

> It's utterly useless to call ->invalidate_page(page) on a page that is
> still mapped by some linux pte with the young bit set. You must defer
> the ->invalidate_page after all young bits are gone. This is what I
> do, infact I do tons more than that by also honouring the accessed
> bits in all sptes. There's zero chance you can do as remotely as
> efficient as my mmu-notifiers are, unless you also do "cat rmap.c >>
> /sgi/yoursubsystem/something.c" and you check the young bit in the
> linux ptes yourself _before_ deciding if you've to start dropping
> remote references or not.

I think we agreed on doing the callback after the OS rmaps have been 
walked right.

> > that point we do not have an mm_struct anymore so the callback would have 
> 
> The mm struct wasn't available in the place where you put
> invalidate_page either.

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
