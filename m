Date: Tue, 3 Mar 1998 23:49:06 GMT
Message-Id: <199803032349.XAA02804@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: reverse pte lookups and anonymous private mappings; avl trees?
In-Reply-To: <Pine.LNX.3.95.980302235716.8007A-100000@as200.spellcast.com>
References: <199803022303.XAA03640@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.95.980302235716.8007A-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi again,

On Tue, 3 Mar 1998 01:29:41 -0500 (EST), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> Monday's brought some enlightenment now.

> 	     vm_next/prev_private (aka vm_private list)
> 	vma -> vma -> vma -> vma
> 	 |      |      |      |
> 	...    ...    ...    ...
> 	 |      |      |      |
> 	pte    pte    pte    pte
> 	 |   /          \    /
> 	page             page
> 	 |->vma == vma1   |->vma == vma3

> (number the vma's from 1->4, left to right)  the values for page->vma are
> arbitrary, and really only need to be one of the vmas on the (doubly link)
> vm_private list.  Somewhere below in this message is the code for finding
> a single pte, trivially extended for all cases as the early January
> patch/idea suggested.  It basically creates the same thing that exists for
> inode backed pages - a list to traverse that contains all *possible*
> mappings to the page.

> This is where the type (a) approach really shines.  At fork time, each
> non-shared vma created gets inserted into the vm_next_private list.  The
> more its swirled around my mind, the nastier doing a get_empty_inode for
> each vma on fork() makes me kringe -- we can't slow down fork! ;-) 

A different but largely equivalent approach occurred to me a while ago.
On exec(), create a new "mm_family" context, and link the mm_struct to
it.  On fork, add the mm_struct to the original mm_family.  That gives
us a quick way to find every mm_struct (and, by implication, every vma)
which can share any given page.

>> What about privately mapped images, such as shared libraries?  Will
>> those vmas will end up with one inode for the backing file and a
>> separate inode for the private pages?  Such private vmas still have
>> anonymous pages in them.

> The type 'a' approach can basically be considered to be exactly the
> same as what is done now: if the page is still being shared, it's in
> the page cache for the inode, hence we can find the pte by means of
> the i_mmap list.  If it's anonymous, then we can find each and every
> pte via the vm_private list (the vma of the page will get set upon its
> creation - COW or swapin) by walking vm_(prev|next)_private in either
> direction, skipping over the ptes which do *not* point to the page --
> exactly the same as we'd do for shared mappings.

OK.  Next point --- what about RSS limits and quotas?  The big problem
in this case is that we may want an anonymous page to be present in some
page tables but not in others.  The reason that this is such a problem
is that in this case, the page is marked by swap entry in some ptes, and
by a present pte in others.  The way we deal with that is the swap
cache, which implies that either we disallow this situation, we deal
with it by some mechanism other than the swap cache, or we cannot use
the page->inode and ->offset fields for the vma indexing.

That's not necessarily a bad thing --- we *don't* need the full
functionality of the page cache for the vma linkage.  In particular, we
won't ever want to page by its (vma, offset) name --- that's what the
page tables themselves are for.  All we need is to get the (vma, offset)
from the struct page, so we don't necessarily need all of the page hash
linkages to support this.

Also, any page which has been swapped in readonly does still need a swap
cache entry if we are to avoid freeing the space on disk.

Note that the swap cache functionality _does_ need the page hash
linkages, since we do need to find the physical page by its
(swapper-inode, entry) name.  That implies that if we combine these two
mechanisms, we need to keep the swap cache as is and add separate
page->vma and page->vm_offset fields independent of the page->inode and
page->offset fields.

> On mremap(), nothing really happens -- unless the area is shrunk, in
> which case any vma that disappears is removed from it's vma_private
> list.

Hmm.  How do we find all of the vmas which reference a specific physical
page if the virtual address of that page is not a constant?  Consider a
forked process having a page range vmremapped in a child --- we still
have only the one page, but it is now at a different VA in each process.
We need to record the _original_ starting virtual address in each
private vma to cope with this --- in other words, when we remap(), we
cannot afford to change the offset we are using to label the page, since
other forked children will continue to use the original offset.  Note
also that we may have many different vmas with the same starting VA even
in a single process --- we can allocate private pages, remap them, then
reallocate the original address range again.  That gives two distinct
vmas with the same original starting VA.

> One of the things that I didn't describe earlier is that page->vm_offset
> is relative to vma->vm_offset (same as page->offset, that is pte vaddr =
> page->vm_offset - vma->vm_offset + vma->vm_start).  If the vma is shrunk,
> vma->vm_offset is increased as it would be for shared pages.

Hmm, that makes a difference --- keeping vma->vm_offset the same over a
mremap, and initialising the vm_offset to VA on a new mmap and
page->vm_offset to (VA - vma->vm_offset + vma->vm_start) on a new page
fault, will sort out a lot of the above problems.

>> Yes.  The conclusion I came to a while ago is that (c) is the only way
>> to go if we do this.

> I hope I've cleared up my explanation of (a) enough that it is
> beginning to look viable.  It seems to be what Linus had in mind when
> the discussions came up a while ago (he suggested adding a pointer to
> the vma in struct page - the offset and vm_private list follow
> naturally).

Actually, what you describe as (a) above is more close to what I had in
mind for (c) --- a single anchor point (the private vma list in this
case) which is shared between all forked processes.  This is definitely
workable.

>> This leaves us with one main question --- how do we select pages for
>> swapout?  We either do it via a scan of the page tables, as currently
>> happens in vmscan, or with a scan of physical pages as shrink_mmap()
>> does.  The changes described here are only useful if we take the
>> second choice.

>> My personal feeling at the moment is that the second option is going
>> to give us lower overhead swapping and a much fairer balance between
>> private data and the page cache.  However, there are are other
>> arguments; in particular, it is much easier to do RSS quotas and
>> guarantees if we are swapping on a per page-table basis.

> Ummm, not really.  I think that because of the mm scheme chosen to
> support clone, these quotas are really only applicable on a per-mm
> basis.  

Yes, absolutely.

> Sticking a quota on a process, only to have it exceeded by it's
> clone() twin doesn't make terribly much sense to me.  In the pte_list
> patch, rather than kill a single task when a fault occurred during
> swapin/out, I walked the task table and killed all which shared the
> mm.

But even imposing a mm_struct RSS limit means that we have to unlink a
bunch of pages by walking ptes, not physical pages.  It effectively
gives us two separate swapping mechanisms.

>> I'm not at all averse to growing the struct page if we absolutely
>> have to, however.  If we can effectively keep several hundred more
>> pages in memory as a result of not having to throw data away just to
>> cope with the worst-case interrupt memory requirements, then we will
>> still see a great overall performance improvement.

> I'd like to see get_free_pages (non-atomic) block until enough pages
> have been reclaimed to the dumpable list; that way we can avoid the
> system ever deadlocking on swap.  But the network stack would need the
> patches Pavel wrote to drop packets when low on memory -- don't drop
> packets destined for the swapping socket, but all others are game.
> Wow, that would make Linux much more stable indeed!

Yes.  The other part of this is to allow kswapd to continue looking for
free pages even when there is insufficient memory to write to swap ---
just let it look for non-dirty pages to discard.

> Oh, below are my current changes to mm.h to give you a hint of where
> I'm going.  Note that despite the cvs directory name, it is against
> 2.1.89-5.  I'm actually proposing the use of 6 possible queues for
> pages to be on, mostly so that we can keep track of and grab what we
> want when we want it; this could be pruned if it matters.

OK, it's the dumpable queue which matters to my own code.  I'm nearly
done making the page cache IRQ- and SMP-safe, so page unhook from IRQ
will be possible soon.  I'll give you patches when it's working, and I
can also mark out hooks for adding pages to that queue at the
appropriate time.

Cheers,
 Stephen.
