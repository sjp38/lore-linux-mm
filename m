Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id D3A7F6B0035
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 01:16:01 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id o10so2093418eaj.11
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 22:16:01 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y48si15524031eew.205.2014.01.30.22.16.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 22:16:00 -0800 (PST)
Date: Fri, 31 Jan 2014 01:15:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140131061543.GF6963@cmpxchg.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
 <20140129000359.GZ6963@cmpxchg.org>
 <52E85CDA.5090102@linaro.org>
 <20140129183032.GA6963@cmpxchg.org>
 <52EAFBF6.7020603@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52EAFBF6.7020603@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, pliard@google.com

On Thu, Jan 30, 2014 at 05:27:18PM -0800, John Stultz wrote:
> On 01/29/2014 10:30 AM, Johannes Weiner wrote:
> > On Tue, Jan 28, 2014 at 05:43:54PM -0800, John Stultz wrote:
> >> On 01/28/2014 04:03 PM, Johannes Weiner wrote:
> >>> On Thu, Jan 02, 2014 at 04:12:08PM +0900, Minchan Kim wrote:
> >>>> o Syscall interface
> >>> Why do we need another syscall for this?  Can't we extend madvise to
> >>> take MADV_VOLATILE, MADV_NONVOLATILE, and return -ENOMEM if something
> >>> in the range was purged?
> >> So the madvise interface is insufficient to provide the semantics
> >> needed. Not so much for MADV_VOLATILE, but MADV_NONVOLATILE. For the
> >> NONVOLATILE call, we have to atomically unmark the volatility status of
> >> the byte range and provide the purge status, which informs the caller if
> >> any of the data in the specified range was discarded (and thus needs to
> >> be regenerated).
> >>
> >> The problem is that by clearing the range, we may need to allocate
> >> memory (possibly by splitting in an existing range segment into two),
> >> which possibly could fail. Unfortunately this could happen after we've
> >> modified the volatile state of part of that range.  At this point we
> >> can't just fail, because we've modified state and we also need to return
> >> the purge status of the modified state.
> > munmap() can theoretically fail for the same reason (splitting has to
> > allocate a new vma) but it's not even documented.  The allocator does
> > not fail allocations of that order.
> >
> > I'm not sure this is good enough, but to me it sounds a bit overkill
> > to design a new system call around a non-existent problem.
> 
> I still think its problematic design issue. With munmap, I think
> re-calling on failure should be fine. But with _NONVOLATILE we could
> possibly lose the purge status on a second call (for instance if only
> the first page of memory was purged, but we errored out mid-call w/
> ENOMEM, on the second call it will seem like the range was successfully
> set non-volatile with no memory purged).
> 
> And even if the current allocator never ever fails, I worry at some
> point in the future that rule might change and then we'd have a broken
> interface.

Fair enough, we don't have to paint ourselves into a corner.

> >>> 2. If page reclaim discards a page from the upper end of a a range,
> >>>    you mark the whole range as purged.  If the user later marks the
> >>>    lower half of the range as non-volatile, the syscall will report
> >>>    purged=1 even though all requested pages are still there.
> >> To me this aspect is a non-ideal but acceptable result of the usage pattern.
> >>
> >> Semantically, the hard rule would be we never report non-purged if pages
> >> in a range were purged.  Reporting purged when pages technically weren't
> >> is not optimal but acceptable side effect of unmarking a sub-range. And
> >> could be avoided by applications marking and unmarking objects consistently.
> >>
> >>
> >>>    The only way to make these semantics clean is either
> >>>
> >>>      a) have vrange() return a range ID so that only full ranges can
> >>>      later be marked non-volatile, or
> >>>
> >>>      b) remember individual page purges so that sub-range changes can
> >>>      properly report them
> >>>
> >>>    I don't like a) much because it's somewhat arbitrarily more
> >>>    restrictive than madvise, mprotect, mmap/munmap etc.  
> >> Agreed on A.
> >>
> >>> And for b),
> >>>    the straight-forward solution would be to put purge-cookies into
> >>>    the page tables to properly report purges in subrange changes, but
> >>>    that would be even more coordination between vmas, page tables, and
> >>>    the ad-hoc vranges.
> >> And for B this would cause way too much overhead for the mark/unmark
> >> operations, which have to be lightweight.
> > Yes, and allocators/message passers truly don't need this because at
> > the time they set a region to volatile the contents are invalidated
> > and the non-volatile declaration doesn't give a hoot if content has
> > been destroyed.
> >
> > But caches certainly would have to know if they should regenerate the
> > contents.  And bigger areas should be using huge pages, so we'd check
> > in 2MB steps.  Is this really more expensive than regenerating the
> > contents on a false positive?
> 
> So you make a good argument. I'd counter that the false-positives are
> only caused when unmarking subranges of larger marked volatile range,
> and for use cases that would care about regenerating the contents,
> that's not a likely useage model (as they're probably going to be
> marking objects in memory volatile/nonvolatile, not just arbitrary
> ranges of pages).

I can imagine that applications have continuous areas of same-sized
objects and want to mark a whole range of them volatile in one go,
then later come back for individual objects.

Otherwise we'd require N adjacent objects to be marked individually
through N syscalls to create N separate internal ranges, or they'd get
strange and unexpected results.

I'm agreeing with you about what's the most likely and common usecase,
but it shouldn't get too weird around the edges.

> > MADV_NONVOLATILE and MADV_NONVOLATILE_REPORT? (catchy, I know...)
> 
> Something like this might be doable. I suspect the non-reporting
> non-volatile is more of a special case (reporting should probably be the
> default - as its safer), so it should probably have the longer name. 

Sure thing.

> >> As for real-disk-backed file volatility, I'm not particularly interested
> >> in that, and fine with losing it. However, some have expressed
> >> theoretical interest that there may be cases where throwing the memory
> >> away is faster then writing it back to disk, so it might have some value
> >> there. But I don't have any concrete use cases that need it.
> > That could also be covered with an interface that clears dirty bits in
> > a range of pages.
> 
> Well.. possibly. The issues with real files are ugly, since you don't
> want have stale data show up after the purge. In the past I proposed the
> hole punching for this, but that could be just as costly then writing
> the data back.
> 
> Practically, I really don't see how true-file volatility makes any sense.
> 
> The only rational interest was made by Dave Chinner, but what he really
> wanted was totally different. Something like a file-system persistent
> (instead of in-memory) volatility, so that filesystems could pick chunks
> of files to purge when disk space got tight.

Yeah, it might be a good idea to keep this separate and focus on
memory reclaim behavior for now.

It might even be beneficial if interfaces for memory volatility and
filesystem volatility are not easily mistaken for each other :)

> > The way I see it, the simplest design, the common denominator for
> > private anon, true file, shmem, tmpfs, would be for MADV/FADV_VOLATILE
> > to clear dirty bits off shared pages, or ptes/pmds in the private
> > mapped case to keep the COW charade intact.  And for the NONVOLATILE
> > side to set dirty on what's still present and report if something is
> > missing.
> 
> Hrmmm. This sounds reasonable, but I'm not sure its right.  It seems the
> missing part here is (with anonymous scanning on swapless systems), we
> still have to set the volatility of the page somewhere so the LRU
> scanner will actually purge those made-clean pages, no? Otherwise won't
> anon and tmpfs files either just be swapped or passed over and left in
> memory? And again, for true-files, we don't want stale data.

During anon page reclaim, we walk all vmas that reference a page to
check its reference bits, then add it to swap (sets PageDirty), walk
all vmas again to unmap and install swap entries, then write it out
and reclaim it.

We should be able to modify the walk for reference bits to also check
for dirty bits, and then don't add a page without any to swap.  It'll
be unmapped (AFAICS try_to_unmap_one needs minor tweak) and discarded
without swap.

Unless I'm missing something, clean shmem pages are discarded like any
other clean filesystem page.

> > Allocators and message passers don't care about content once volatile,
> > only about the memory.  They wouldn't even have to go through the
> > non-volatile step anymore, they could just write to memory again and
> > it'll set the dirty bits and refault what's missing.
> 
> So this would implicitly make any write effectively clear the volatility
> of a page? That probably would be an ok semantic with the use cases I'm
> aware of, but its new.

Yes.

> > Such an interface would be dead simple to use and consistent across
> > all types.  The basic implementation would require only a couple of
> > lines of code, and while O(pages), it would still be much cheaper than
> > thrashing and swapping, and still cheaper than actively giving ranges
> > back to the kernel and reallocating and repopulating them later on.
> >
> > Compare this to the diffstat of the current vrange implementation and
> > the complexity and inconsistencies it introduces into the VM.  I'm not
> > sure an O(pages) interface would be unattractive enough to justify it.
> 
> Ok. So I think we're in agreement with:
> * Moving the volatility state for anonymous volatility into the VMA
> * Getting anonymous scanning going again on swapless systems

Cool!

> I'm still not totally sure about, but willing to try
> * Page granular volatile tracking

Okay.

> I'm still not convinced on:
> * madvise as a sufficient interface

Me neither :)

> I'll try to work out a draft of what your proposing (probably just for
> anonymous memory for now) and we can iterate from there?

Sounds good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
