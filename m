Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 92C266B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 13:30:57 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so1104906eae.5
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 10:30:56 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id x3si6042170eea.34.2014.01.29.10.30.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 10:30:55 -0800 (PST)
Date: Wed, 29 Jan 2014 13:30:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140129183032.GA6963@cmpxchg.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
 <20140129000359.GZ6963@cmpxchg.org>
 <52E85CDA.5090102@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52E85CDA.5090102@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, pliard@google.com

On Tue, Jan 28, 2014 at 05:43:54PM -0800, John Stultz wrote:
> On 01/28/2014 04:03 PM, Johannes Weiner wrote:
> > On Thu, Jan 02, 2014 at 04:12:08PM +0900, Minchan Kim wrote:
> >> o Syscall interface
> > Why do we need another syscall for this?  Can't we extend madvise to
> > take MADV_VOLATILE, MADV_NONVOLATILE, and return -ENOMEM if something
> > in the range was purged?
> 
> So the madvise interface is insufficient to provide the semantics
> needed. Not so much for MADV_VOLATILE, but MADV_NONVOLATILE. For the
> NONVOLATILE call, we have to atomically unmark the volatility status of
> the byte range and provide the purge status, which informs the caller if
> any of the data in the specified range was discarded (and thus needs to
> be regenerated).
> 
> The problem is that by clearing the range, we may need to allocate
> memory (possibly by splitting in an existing range segment into two),
> which possibly could fail. Unfortunately this could happen after we've
> modified the volatile state of part of that range.  At this point we
> can't just fail, because we've modified state and we also need to return
> the purge status of the modified state.

munmap() can theoretically fail for the same reason (splitting has to
allocate a new vma) but it's not even documented.  The allocator does
not fail allocations of that order.

I'm not sure this is good enough, but to me it sounds a bit overkill
to design a new system call around a non-existent problem.

> >> o Not bind with vma split/merge logic to prevent mmap_sem cost and
> >> o Not bind with vma split/merge logic to avoid vm_area_struct memory
> >>   footprint.
> > VMAs are there to track attributes of memory ranges.  Duplicating
> > large parts of their functionality and co-maintaining both structures
> > on create, destroy, split, and merge means duplicate code and complex
> > interactions.
> >
> > 1. You need to define semantics and coordinate what happens when the
> >    vma underlying a volatile range changes.
> >
> >    Either you have to strictly co-maintain both range objects, or you
> >    have weird behavior like volatily outliving a vma and then applying
> >    to a separate vma created in its place.
> 
> So indeed this is a difficult problem!  My initial approach is simply
> when any new mapping is made, we clear the volatility of the affected
> process memory. Admittedly this has extra overhead and Minchan has an
> alternative here (which I'm not totally sold on yet, but may be ok). 
> I'm almost convinced that for anonymous volatility, storing the
> volatility in the vma would be ok, but Minchan is worried about the
> performance overhead of the required locking for manipulating the vmas.
>
> For file volatility, this is more complicated, because since the
> volatility is shared, the ranges have to be tracked against the
> address_space structure, and can't be stored in per-process vmas. So
> this is partially why we've kept range trees hanging off of the mm and
> address_spaces structures, since it allows the range manipulation logic
> to be shared in both cases.

The fs people probably have not noticed yet what you've done to struct
address_space / struct inode ;-) I doubt that this is mergeable in its
current form, so we have to think about a separate mechanism for shmem
page ranges either way.

> >    Userspace won't get this right, and even in the kernel this is
> >    error prone and adds a lot to the complexity of vma management.
> Not sure exactly I understand what you mean by "userspace won't get this
> right" ?

I meant, userspace being responsible for keeping vranges coherent with
its mmap and munmap operations, instead of the kernel doing it.

> > 2. If page reclaim discards a page from the upper end of a a range,
> >    you mark the whole range as purged.  If the user later marks the
> >    lower half of the range as non-volatile, the syscall will report
> >    purged=1 even though all requested pages are still there.
> 
> To me this aspect is a non-ideal but acceptable result of the usage pattern.
> 
> Semantically, the hard rule would be we never report non-purged if pages
> in a range were purged.  Reporting purged when pages technically weren't
> is not optimal but acceptable side effect of unmarking a sub-range. And
> could be avoided by applications marking and unmarking objects consistently.
> 
> 
> >    The only way to make these semantics clean is either
> >
> >      a) have vrange() return a range ID so that only full ranges can
> >      later be marked non-volatile, or
> >
> >      b) remember individual page purges so that sub-range changes can
> >      properly report them
> >
> >    I don't like a) much because it's somewhat arbitrarily more
> >    restrictive than madvise, mprotect, mmap/munmap etc.  
> Agreed on A.
> 
> > And for b),
> >    the straight-forward solution would be to put purge-cookies into
> >    the page tables to properly report purges in subrange changes, but
> >    that would be even more coordination between vmas, page tables, and
> >    the ad-hoc vranges.
> 
> And for B this would cause way too much overhead for the mark/unmark
> operations, which have to be lightweight.

Yes, and allocators/message passers truly don't need this because at
the time they set a region to volatile the contents are invalidated
and the non-volatile declaration doesn't give a hoot if content has
been destroyed.

But caches certainly would have to know if they should regenerate the
contents.  And bigger areas should be using huge pages, so we'd check
in 2MB steps.  Is this really more expensive than regenerating the
contents on a false positive?

MADV_NONVOLATILE and MADV_NONVOLATILE_REPORT? (catchy, I know...)

What worries me a bit is that we have started from the baseline that
anything that scales with range size is way too much overhead,
regardless of how awkward and alien the alternatives are to implement.
But even in its most direct implementation, marking discardable pages
one by one is still a massive improvement over thrashing cache or
swapping, so why do we have to start from such an extreme?

Applications won't use this interface because it's O(1), but because
they don't want to be #1 in memory consumption when the system hangs
and thrashes and swaps.

Obviously, the lighter the better, but this code just doesn't seem to
integrate at all into the VM and I don't think it's justified.

> > 3. Page reclaim usually happens on individual pages until an
> >    allocation can be satisfied, but the shrinker purges entire ranges.
> >
> >    Should it really take out an entire 1G volatile range even though 4
> >    pages would have been enough to satisfy an allocation?  Sure, we
> >    assume a range represents an single "object" and userspace would
> >    have to regenerate the whole thing with only one page missing, but
> >    there is still a massive difference in page frees, faults, and
> >    allocations.
> 
> So the purging behavior has been a (lightly) contentious item. Some have
> argued that if a page from a range is purged, we might as well purge the
> entire range before purging any page from another range. This makes the
> most sense from the usage model where a range is marked and not touched
> until it is unmarked.

If the pages in a range were faulted in together, their LRU order will
reflect this.

> However, if the user is utilizing the SIGBUS behavior and continues to
> access the volatile range, we would really ideally have only the cold
> pages purged so that the application can continue and the system can
> manage all the pages via the LRU.
>
> Minchan has proposed having flags to set the volatility mode (_PARTIAL
> or _FULL) to allow applications to state their preferred behavior, but I
> still favor having global LRU behavior and purging things page by page
> via normal reclaim.  My opinion is due to the fact that full-range
> purging causes purging to be least-recently-marked-volatile rather then
> LRU, but if the ranges are not accessed while volatile, LRU should
> approximate the least-recently-marked-volatile.

I'm with you on this.  We could always isolate anon pages in vrange
clusters around the target LRU page, but the primary means of aging
and reclaiming anon memory should remain the LRU list scanner.

> However there are more then just philosophical issues that complicate
> things. On swapless systems, we don't age anonymous pages, so we don't
> have a hook to purge volatile pages. So in that case we currently have
> to use the shrinker and use the full-range purging behavior.
> 
> Adding anonymous aging for swapless systems might be able to help here,
> but thats likely to be complicated as well. For now the dual approach
> Minchan implemented (where the LRU can evict single pages, and the
> shrinker can evict total ranges) seems like a reasonable compromise
> while the functionality is reviewed.

We should at least *try* to go back to aging anon and run some tests
to quantify the costs, before creating a new VM object with its own
separate ad-hoc aging on speculation!  We've been there and it wasn't
that bad...

> > There needs to be a *really* good argument why VMAs are not enough for
> > this purpose.  I would really like to see anon volatility implemented
> > as a VMA attribute, and have regular reclaim decide based on rmap of
> > individual pages whether it needs to swap or purge.  Something like
> > this:
> 
> 
> The performance aspect is the major issue. With the separate range tree,
> the operations are close to O(log(#ranges)), which is really attractive.
> Anything that changes it to O(#pages in range) would be problematic. 
> But I think I could mostly go along with this if it stays O(log(#vmas)),
> but will let Minchan detail his objections (which are mostly around the
> locking contention). Though a few notes on your proposal...
> 
> 
> >
> > MADV_VOLATILE:
> >   split vma if necessary
> >   set VM_VOLATILE
> >
> > MADV_NONVOLATILE:
>  also need a "split vma if necessary" here.

True.

> >   clear VM_VOLATILE
> >   merge vma if possible
> >   pte walk to check for pmd_purged()/pte_purged()
> So I think the pte walk would be way too costly. Its probably easier to
> have a VM_PURGED or something on the vma that we set when we purge a
> page, which would simplify the purge state handling.

I added it because, right now, userspace only knows about pages.  It
does not know that when you mmap/madvise/mprotect that the kernel
creates range objects - that's an implementation detail - it only
knows that you are changing the attributes of a bunch of pages.

Reporting a result for a super-range of what you actually speficied in
the syscall would implicitely turn ranges into first class
user-visible VM objects.

This is a huge precedent.  "The traditional Unix memory objects of
file mappings, shared memory segments, anon mappings, pages, bytes,
and vranges!"  Is it really that strong of an object type?  Does a
performance optimization of a single use case justify it?

I'd rather we make the reporting optional and report nothing in cases
where it's not needed, if that's all it takes.

And try very hard to stick with pages as the primary unit of paging.

> >   return any_purged
> >
> > shrink_page_list():
> >   if PageAnon:
> >     if try_to_purge_anon():
> >       page_lock_anon_vma_read()
> >       anon_vma_interval_tree_foreach:
> >         if vma->vm_flags & VM_VOLATILE:
> >           lock page table
> >           unmap page
> >           set_pmd_purged() / set_pte_purged()
> >           unlock page table
> >       page_lock_anon_vma_read()
> >    ...
> >    try to reclaim
> 
> Again, we'd have to sort out something here for swapless systems.

Do you mean aside from making sure anon is aged?

> >> Whats new in v9:
> >> * Updated to v3.11
> >> * Added vrange purging logic to purge anonymous pages on
> >>   swapless systems
> > We stopped scanning anon on swapless systems because anon needed swap
> > to be reclaimable.  If we can reclaim anon without swap, we have to
> > start scanning anon again unconditionally.  It makes no sense to me to
> > work around this optimization and implement a separate reclaim logic.
> 
> I'd personally prefer we move to that.. but I'm not sure if the
> unconditional scanning would be considered too problematic?

Quantifying the costs would be good, so that we know whether the
complexity of an out-of-band reclaim mechanism for anon pages is
justifiable.  I doubt it, tbh.

> >> Optimistic method:
> >> 1) Userland marks a large range of data as volatile
> >> 2) Userland continues to access the data as it needs.
> >> 3) If userland accesses a page that has been purged, the kernel will
> >> send a SIGBUS
> >> 4) Userspace can trap the SIGBUS, mark the afected pages as
> >> non-volatile, and refill the data as needed before continuing on
> > What happens if a pointer to volatile memory is passed to a syscall
> > and the fault happens inside copy_*_user()?
> 
> I'll have to look into that detail. Thanks for bringing it up.
> 
> I suspect it would be the same as if a pointer to mmapped file was
> passed to a syscall and the file was truncated by another processes?

I think so.  But doing that is kind of questionable to begin with,
whereas passing volatile pointers around would be a common and valid
thing to do.

> > Support for file pages are a very big deal and they seem to have had
> > an impact on many design decisions, but they are only mentioned on a
> > side note in this email.
> >
> > The rationale behind volatile anon pages was that they are often used
> > as caches and that dropping them under pressure and regenerating the
> > cache contents later on was much faster than swapping.
> >
> > But pages that are backed by an actual filesystem are "regenerated" by
> > reading the contents back from disk!  What's the point of declaring
> > them volatile?
> >
> > Shmem pages are a different story.  They might be implemented by a
> > virtual filesystem, but they behave like anon pages when it comes to
> > reclaim and repopulation so the same rationale for volatility appies.
> Right. So file volatility is mostly interesting to me on tmpfs/shmem,
> and your point about them being only sort of technically file pages is
> true, it sort of depends on where you stand in the kernel as to if its
> considered file or anonymous memory.

Yeah, there are many angles to look at it, but it's important that the
behavior is sane and consistent across all of them.

> As for real-disk-backed file volatility, I'm not particularly interested
> in that, and fine with losing it. However, some have expressed
> theoretical interest that there may be cases where throwing the memory
> away is faster then writing it back to disk, so it might have some value
> there. But I don't have any concrete use cases that need it.

That could also be covered with an interface that clears dirty bits in
a range of pages.

> Really the *key* need for tmpfs/shmem file volatility is in order to
> have volatility on shared memory.
>
> > But a big aspect of anon volatility is communicating to userspace
> > whether *content* has been destroyed while in volatile state.  Shmem
> > pages might not necessarily need this.  The oft-cited example is the
> > message passing in a large circular buffer that is unused most of the
> > time.  The sender would mark it non-volatile before writing, and the
> > receiver would mark it volatile again after reading.  The writer can
> > later reuse any unreclaimed *memory*, but nobody is coming back for
> > the actual *contents* stored in there.  This usecase would be
> > perfectly fine with an interface that simply clears the dirty bits of
> > a range of shmem pages (through mmap or fd).  The writer would set the
> > pages non-volatile by dirtying them, whereas the reader would mark
> > them volatile again by clearing the dirty bits.  Reclaim would simply
> > discard clean pages.
> 
> So while in that case, its unlikely anyone is going to be trying to
> reuse contents of the volatile data. However, there may be other cases
> where for example, a image cache is managed in a shared tmpfs segment
> between a jpeg renderer and a web-browser, so there can be improved
> isolation/sandboxing between the functionality. In that case, the
> management of the volatility would be handled completely by the
> web-browser process, but we'd want memory to be shared so we've have
> zero-copy from the render.
> 
> In that case, the browser would want to be able mark chunks of shared
> buffer volatile when it wasn't in use, and to unmark the range and
> re-use it if it wasn't purged.

You are right, we probably can not ignore such cases.

The way I see it, the simplest design, the common denominator for
private anon, true file, shmem, tmpfs, would be for MADV/FADV_VOLATILE
to clear dirty bits off shared pages, or ptes/pmds in the private
mapped case to keep the COW charade intact.  And for the NONVOLATILE
side to set dirty on what's still present and report if something is
missing.

Allocators and message passers don't care about content once volatile,
only about the memory.  They wouldn't even have to go through the
non-volatile step anymore, they could just write to memory again and
it'll set the dirty bits and refault what's missing.

Caches in anon memory would have to mark the pages volatile and then
later non-volatile to see if the contents have been preserved.

In the standard configuration, this would exclude the optimistic
usecase, but it's conceivable to have a settable per-VMA flag that
prevents purged pages from refaulting silently and make them trip a
SIGBUS instead.  But I'm still a little dubious whether this usecase
is workable in general...

Such an interface would be dead simple to use and consistent across
all types.  The basic implementation would require only a couple of
lines of code, and while O(pages), it would still be much cheaper than
thrashing and swapping, and still cheaper than actively giving ranges
back to the kernel and reallocating and repopulating them later on.

Compare this to the diffstat of the current vrange implementation and
the complexity and inconsistencies it introduces into the VM.  I'm not
sure an O(pages) interface would be unattractive enough to justify it.

Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
