Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3293B6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:21:12 -0400 (EDT)
Date: Tue, 27 Oct 2009 19:21:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091027182109.GA5753@random.random>
References: <20091026185130.GC4868@random.random>
 <alpine.DEB.1.10.0910271630540.20363@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0910271630540.20363@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 04:42:39PM -0400, Christoph Lameter wrote:
> > 1) hugepages have to be swappable or the guest physical memory remains
> >    locked in RAM and can't be paged out to swap
> 
> Thats not such a big issue IMHO. Paging is not necessary. Swapping is
> deadly to many performance based loads. You would abort a job anyways that

Yes, swapping is deadly to performance based loads and it should be
avoided as much as possible, but it's not nice when in order to get a
boost in guest performance when the host isn't low on memory, you lose
the ability to swap when the host is low on memory and all VM are
locked in memory like in inferior-design virtual machines that won't
ever support paging. When system starts swapping the manager can
migrate the VM to other hosts with more memory free to restore the
full RAM performance as soon as possible. Overcommit can be very
useful at maxing out RAM utilization, just like it happens for regular
linux tasks (few people runs with overcommit = 2 for this very
reason.. besides overcommit = 2 includes swap in its equation so you
can still max out ram by adding more free swap).

> it going to swap. On the other hand I wish we would have migration support
> (which may be contingent on swap support).

Agreed, migration is important on numa systems as much as swapping is
important on regular hosts, and this patch allows both in the very
same way with a few liner addition (that is a noop and doesn't modify
the kernel binary when CONFIG_TRANSPARENT_HUGEPAGE=N). The hugepages
in this patch should already relocatable just fine with move_pages (I
say "should" because I didn't test move_pages yet ;).

> > 2) if a hugepage allocation fails, regular pages should be allocated
> >    instead and mixed in the same vma without any failure and without
> >    userland noticing
> 
> Wont you be running into issues with page dirtying on that level?

Not sure I follow what the problem should be. At the moment when
pmd_trans_huge is true, the dirty bit is meaningless (hugepages at the
moment are splitted in place into regular pages before they can be
converted to swapcache, only after an hugepage becomes swapcache its
dirty bit on the pte becomes meaningful to handle the case of an
exclusive swapcache mapped writeable into a single pte and marked
clean to be able to swap it out at zerocost if memory pressure returns
and to avoid a cow if the page is written to before it is paged out
again), but the accessed bit is already handled just fine at the pmd
level.

> > 3) if some task quits and more hugepages become available in the
> >    buddy, guest physical memory backed by regular pages should be
> >    relocated on hugepages automatically in regions under
> >    madvise(MADV_HUGEPAGE) (ideally event driven by waking up the
> >    kernel deamon if the order=HPAGE_SHIFT-PAGE_SHIFT list becomes not
> >    null)
> 
> Oww. This sounds like a heuristic page promotion demotion scheme.
> http://www.cs.rice.edu/~jnavarro/superpages/
> We have discussed this a couple of times and there was a strong feeling
> that the heuristics are bad. But that may no longer be the case since we
> already have stuff like KSM in the kernel. Memory management may get very
> complex in the future.

The good thing is, all real complexity is in the patch I posted. That
solves the locking and the handling of hugepages in regular vmas. The
complexity of the collapse_huge_page daemon that will scan the
MADV_HUGEPAGE registered mappings and relocate regular pages into
hugepages whenever hugepages become available in the buddy, will be
_self_contained_. So it'll be additional complex code yes, but it will
be self contained in huge_memory.c and it won't make the VM any more
complex than this patch already does.

Plus the daemon will be off by default, just like kksmd has to be off
by default at boot...

If you run linux purely as hypervisor it's ok to spend some CPU to
make sure all 2M pages that become available are immediately going to
replace fragmented pages so that the NPT pagetables becomes 3level
instead of 4levels and guest immediately runs faster.

> > The most important design choice is: always fallback to 4k allocation
> > if the hugepage allocation fails! This is the _very_ opposite of some
> > large pagecache patches that failed with -EIO back then if a 64k (or
> > similar) allocation failed...
> 
> Those also had fall back logic to 4k. Does this scheme also allow I/O with

Well maybe I remember your patches wrong, or I might have not followed
later developments but I was quite sure to remember when we discussed
it, the reason of the -EIO failure was the fs had softblocksize bigger
than 4k... and in general fs can't handle blocksize bigger than the
PAGE_CACHE_SIZE... In effect the core trouble wasnt' the large
pagecache but the fact the fs wanted a blocksize larger than
PAGE_SIZE, despite not being able to handle it, if the block was
splitted in multiple 4k not contiguous areas.

> Hugepages through the VFS layer?

Hugepage right now can only be transparently mapped and
swapped/splitted in anon mappings, not in file mappings (not even the
MAP_PRIVATE ones that generate anonymous cache with the COW). This is
to keep it simple. Also keep in mind this is motivated by KVM needing
to run faster like other hypervisors that support hugepages. We
already can handle hugepages to get the hardware boost, but we want
our guests to run as fast as possible _always_ (not only if hugepages
are reserved at boot to avoid memory failure at runtime, or if the
user is not ok to swap, and we don't want to lose the other features
of regular mappings including migration, plus we want the regular
pages to be collapsed in hugepages when they become available). The
whole guest physical memory is mapped by anonymous vmas, so it is
natural to start from there... It's also orders of magnitude simpler
to start from there than to address pagecache ;). Nothing will prevent
to extend this logic to pagecache later...

> > Second important decision (to reduce the impact of the feature on the
> > existing pagetable handling code) is that at any time we can split an
> > hugepage into 512 regular pages and it has to be done with an
> > operation that can't fail. This way the reliability of the swapping
> > isn't decreased (no need to allocate memory when we are short on
> > memory to swap) and it's trivial to plug a split_huge_page* one-liner
> > where needed without polluting the VM. Over time we can teach
> > mprotect, mremap and friends to handle pmd_trans_huge natively without
> > calling split_huge_page*. The fact it can't fail isn't just for swap:
> > if split_huge_page would return -ENOMEM (instead of the current void)
> > we'd need to rollback the mprotect from the middle of it (ideally
> > including undoing the split_vma) which would be a big change and in
> > the very wrong direction (it'd likely be simpler not to call
> > split_huge_page at all and to teach mprotect and friends to handle
> > hugepages instead of rolling them back from the middle). In short the
> > very value of split_huge_page is that it can't fail.
> 
> I dont get the point of this. What do you mean by "an operation that
> cannot fail"? Atomic section?

In short I mean it cannot return -ENOMEM (and an additional bonus is
that I managed it not to require scheduling or blocking
operations). The idea is that you can plug it anywhere with a one
liner and your code becomes hugepage compatible (sure it would run
faster if you were to teach to your code to handle pmd_trans_huge
natively but we can't do it all at once :).

> > The default I like is that transparent hugepages are used at page
> > fault time if they're available in O(1) in the buddy. This can be
> > disabled via sysctl/sysfs setting the value to 0, and if it is
> 
> The consequence of this could be a vast waste of memory if you f.e. touch
> memory only in 1 megabyte increments.

Sure, this is the feature... But if somebody does mmap(2M) supposedly
he's not only going to touch 4k, or I'd blame on the app and not on
the kernel that tries to make that 2M mapping so much faster both at
page fault time (hugely faster ;) and later during random access too.

Now it may very well be the default should be disabled, but I really
doubt with any regular workstation anybody wants it off by
default. Surely embedded should turn it off, and stick to madvise for
their regions (libhugetlbfs will become a bit simpler by only having
to run madvise after mmap) to be sure not to waste any precious kbyte.

> Separate the patch into a patchset for easy review.

I'll try yes...

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
