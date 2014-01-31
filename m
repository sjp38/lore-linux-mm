Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9DE6B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 11:49:18 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so2491240ead.36
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 08:49:17 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y5si19163035eee.18.2014.01.31.08.49.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 08:49:16 -0800 (PST)
Date: Fri, 31 Jan 2014 11:49:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140131164901.GG6963@cmpxchg.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
 <20140129000359.GZ6963@cmpxchg.org>
 <20140129051102.GA11786@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140129051102.GA11786@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>

On Wed, Jan 29, 2014 at 02:11:02PM +0900, Minchan Kim wrote:
> It's interesting timing, I posted this patch Yew Year's Day
> and receives indepth design review Lunar New Year's Day. :)
> It's almost 0-day review. :)

That's the only way I can do 0-day reviews ;)

> On Tue, Jan 28, 2014 at 07:03:59PM -0500, Johannes Weiner wrote:
> > Hello Minchan,
> > 
> > On Thu, Jan 02, 2014 at 04:12:08PM +0900, Minchan Kim wrote:
> > > Hey all,
> > > 
> > > Happy New Year!
> > > 
> > > I know it's bad timing to send this unfamiliar large patchset for
> > > review but hope there are some guys with freshed-brain in new year
> > > all over the world. :)
> > > And most important thing is that before I dive into lots of testing,
> > > I'd like to make an agreement on design issues and others
> > > 
> > > o Syscall interface
> > 
> > Why do we need another syscall for this?  Can't we extend madvise to
> 
> Yeb. I should have written the reason. Early versions in this patchset
> had used madvise with VMA handling but it was terrible performance for
> ebizzy workload by mmap_sem's downside lock due to merging/split VMA.
> Even it was worse than old so I gave up the VMA approach.
> 
> You could see the difference.
> https://lkml.org/lkml/2013/10/8/63

So the compared kernels are 4 releases apart and the test happened
inside a VM.  It's also not really apparent from that link what the
tested workload is doing.  We first have to agree that it's doing
nothing that could be avoided.  E.g. we wouldn't introduce an
optimized version of write() because an application that writes 4G at
one byte per call is having problems.

The vroot lock has the same locking granularity as mmap_sem.  Why is
mmap_sem more contended in this test?

> > take MADV_VOLATILE, MADV_NONVOLATILE, and return -ENOMEM if something
> > in the range was purged?
> 
> In that case, -ENOMEM would have duplicated meaning "Purged" and "Out
> of memory so failed in the middle of the system call processing" and
> later could be a problem so we need to return value to indicate
> how many bytes are succeeded so far so it means we need additional
> out parameter. But yes, we can solve it by modifying semantic and
> behavior (ex, as you said below, we could just unmark volatile
> successfully if user pass (offset, len) consistent with marked volatile
> ranges. (IOW, if we give up overlapping/subrange marking/unmakring
> usecase. I expect it makes code simple further).
> It's request from John so If he is okay, I'm no problem.

Yes, I don't insist on using madvise.  And it's too early to decide on
an interface before we haven't fully nailed the semantics and features.

> > > o Not bind with vma split/merge logic to prevent mmap_sem cost and
> > > o Not bind with vma split/merge logic to avoid vm_area_struct memory
> > >   footprint.
> > 
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
> > 
> >    Userspace won't get this right, and even in the kernel this is
> >    error prone and adds a lot to the complexity of vma management.
> 
> Current semantic is following as,
> Vma handling logic in mm doesn't need to know vrange handling because
> vrange's internal logic always checks validity of the vma but
> one thing to do in vma logic is only clearing old volatile ranges
> on creating new vma.
> (Look at  [PATCH v10 02/16] vrange: Clear volatility on new mmaps)
> Acutally I don't like the idea and suggested following as.
> https://git.kernel.org/cgit/linux/kernel/git/minchan/linux.git/commit/?h=vrange-working&id=821f58333b381fd88ee7f37fd9c472949756c74e
> But John didn't like it. I guess if VMA size is really matter,
> maybe we can embedded the flag into somewhere field of
> vma(ex, vm_file LSB?)

It's not entirely clear to me how the per-VMA variable can work like
that when vmas can merge and split by other means (mprotect e.g.)

> > 2. If page reclaim discards a page from the upper end of a a range,
> >    you mark the whole range as purged.  If the user later marks the
> >    lower half of the range as non-volatile, the syscall will report
> >    purged=1 even though all requested pages are still there.
> 
> True, The assumption is that basically, user should have a range
> per object but we gives flexibility for user to handle subranges
> of a volatile range so it might report false positive as you said.
> In that case, please user can use mincore(2) for accuracy if he
> want so he has flexiblity but lose performance a bit.
> It's a tradeoff, IMO.

Look, we can't present a syscall that takes an exact range of bytes
and then return results that are not applicable to this range at all.

We can not make performance trade-offs that compromise the semantics
of the interface, and then recommend using an unrelated system call
that takes the same byte range but somehow gets it right.

> >    The only way to make these semantics clean is either
> > 
> >      a) have vrange() return a range ID so that only full ranges can
> >      later be marked non-volatile, or
> 
> > 
> >      b) remember individual page purges so that sub-range changes can
> >      properly report them
> > 
> >    I don't like a) much because it's somewhat arbitrarily more
> >    restrictive than madvise, mprotect, mmap/munmap etc.  And for b),
> >    the straight-forward solution would be to put purge-cookies into
> >    the page tables to properly report purges in subrange changes, but
> >    that would be even more coordination between vmas, page tables, and
> >    the ad-hoc vranges.
> 
> Agree but I don't want to put a accuracy of defalut vrange syscall.
> Page table lookup needs mmap_sem and O(N) cost so I'm afraid it would
> make userland folks hesitant using this system call.

If userspace sees nothing but cost in this system call, nothing but a
voluntary donation for the common good of the system, then it does not
matter how cheap this is, nobody will use it.  Why would they?  Even
if it's a lightweight call, they still have to implement a mechanism
for regenerating content etc.  It's still an investment to make, so
there has to be a personal benefit or it's flawed from the beginning.

So why do applications want to use it?

> > 3. Page reclaim usually happens on individual pages until an
> >    allocation can be satisfied, but the shrinker purges entire ranges.
> 
> Strictly speaking, not entire rangeS but entire A range.
> This recent patchset bails out if we discard as much as VM want.
> 
> > 
> >    Should it really take out an entire 1G volatile range even though 4
> >    pages would have been enough to satisfy an allocation?  Sure, we
> >    assume a range represents an single "object" and userspace would
> >    have to regenerate the whole thing with only one page missing, but
> >    there is still a massive difference in page frees, faults, and
> >    allocations.
> 
> That's why I wanted to introduce full and partial purging flag as system
> call argument.

I just wonder why we would anything but partial purging.

> > There needs to be a *really* good argument why VMAs are not enough for
> > this purpose.  I would really like to see anon volatility implemented
> 
> Strictly speaking, volatile ranges has two goals.
> 
> 1. Avoid unncessary swapping or OOM if system has lots of volatile memory
> 2. Give advanced free rather than madvise(DONTNEED)

Aren't they the same goal?  Giving applications a cheap way to
relinquish unused memory.  If there is memory pressure, well, it was
unused anyway.  If there isn't, the memory range can be reused without
another mmap() and page faults.

> First goal is very clear so I don't need to say again
> but it seems second goal isn't clear so that I try elaborate it a bit.
> 
> Current allocators really hates frequent calling munmap which is big
> performance overhead if other threads are allocating new address
> space or are faulting existing address space so they have used
> madvise(DONTNEED) as optimization so at least, faulting threads
> works well in parallel. It's better but allocators couldn't use
> madvise(DONTNEED) frequently because it still prevent other thread's
> allocation of new address space for a long time(becuase the overhead
> of the system call is O(vma_size(vma)).

My suggestion of clearing dirty bits off of page table ranges would
require only read-side mmap_sem.

> Volatile ranges system call never don't need to hold write-side mmap_sem
> and the execution time is almost O(log(nr_range))) and if we follow your
> suggestion(ie, vrange returns ID), it's O(1). It's better.

I already wrote that to John: what if you have an array of objects and
want to mark them all volatile, but then come back for individual
objects in the array?  If vrange() creates a single range and returns
an ID, you can't do this, unless you call vrange() for every single
object first.

O(1) is great, but we are duplicating VMA functionality, anon reclaim
functionality, have all these strange interactions, and a very
restricted interface.

We have to make trade-offs here and I don't want to have all this
complexity if there isn't a really solid reason for it.

> Another concern is that some of people want to handle range
> fine-granularity, maybe worst case, PAGE_SIZE, in that case
> so many VMA could be created if purging happens sparsely so it would
> be really memory concern.

That's also no problem if we implement it based on dirty page table
bits.

> > as a VMA attribute, and have regular reclaim decide based on rmap of
> > individual pages whether it needs to swap or purge.  Something like
> > this:
> > 
> > MADV_VOLATILE:
> >   split vma if necessary
> >   set VM_VOLATILE
> > 
> > MADV_NONVOLATILE:
> >   clear VM_VOLATILE
> >   merge vma if possible
> >   pte walk to check for pmd_purged()/pte_purged()
> >   return any_purged
> 
> It could make system call really slow so allocator people really
> would be reluctant to use it.

So what do they do instead?  munmap() and refault the pages?  Or sit
on a bunch of unused memory and get killed by the OOM killer?  Or wait
on IO while their unused pages are swapped in and out?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
