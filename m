Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1CB6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 20:09:19 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so7780643pbc.13
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 17:09:19 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id tq5si22473505pac.124.2014.02.03.17.09.15
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 17:09:18 -0800 (PST)
Date: Tue, 4 Feb 2014 10:09:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140204010917.GA3481@bbox>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
 <20140129000359.GZ6963@cmpxchg.org>
 <20140129051102.GA11786@bbox>
 <20140131164901.GG6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140131164901.GG6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>

On Fri, Jan 31, 2014 at 11:49:01AM -0500, Johannes Weiner wrote:
> On Wed, Jan 29, 2014 at 02:11:02PM +0900, Minchan Kim wrote:
> > It's interesting timing, I posted this patch Yew Year's Day
> > and receives indepth design review Lunar New Year's Day. :)
> > It's almost 0-day review. :)
> 
> That's the only way I can do 0-day reviews ;)
> 
> > On Tue, Jan 28, 2014 at 07:03:59PM -0500, Johannes Weiner wrote:
> > > Hello Minchan,
> > > 
> > > On Thu, Jan 02, 2014 at 04:12:08PM +0900, Minchan Kim wrote:
> > > > Hey all,
> > > > 
> > > > Happy New Year!
> > > > 
> > > > I know it's bad timing to send this unfamiliar large patchset for
> > > > review but hope there are some guys with freshed-brain in new year
> > > > all over the world. :)
> > > > And most important thing is that before I dive into lots of testing,
> > > > I'd like to make an agreement on design issues and others
> > > > 
> > > > o Syscall interface
> > > 
> > > Why do we need another syscall for this?  Can't we extend madvise to
> > 
> > Yeb. I should have written the reason. Early versions in this patchset
> > had used madvise with VMA handling but it was terrible performance for
> > ebizzy workload by mmap_sem's downside lock due to merging/split VMA.
> > Even it was worse than old so I gave up the VMA approach.
> > 
> > You could see the difference.
> > https://lkml.org/lkml/2013/10/8/63
> 
> So the compared kernels are 4 releases apart and the test happened
> inside a VM.  It's also not really apparent from that link what the
> tested workload is doing.  We first have to agree that it's doing
> nothing that could be avoided.  E.g. we wouldn't introduce an
> optimized version of write() because an application that writes 4G at
> one byte per call is having problems.

About ebizzy workload, the process allocates several chunks then,
threads start to alloc own chunk and *copy( the content from random
chunk which was one of preallocated chunk to own chunk.
It means lots of threads are page-faulting so mmap_sem write-side
lock is really critical point for performance.
(I don't know ebizzy is really good for real practice but at least,
several papers and benchmark suites have used it so we couldn't
ignore. And per-thread allocator are really popular these days)

With VMA approach, we need mmap_sem write-side lock twice to mark/unmark
VM_VOLATILE in vma->vm_flags so with my experiment, the performance was
terrible as I said on link.

I don't think the situation of current kernel would be better than old.
And virtulization is really important technique thesedays so we couldn't
ignore that although I tested it on VM for convenience. If you want,
I surely can test it on bare box.

> 
> The vroot lock has the same locking granularity as mmap_sem.  Why is
> mmap_sem more contended in this test?

It seems above explanation is enough.

> 
> > > take MADV_VOLATILE, MADV_NONVOLATILE, and return -ENOMEM if something
> > > in the range was purged?
> > 
> > In that case, -ENOMEM would have duplicated meaning "Purged" and "Out
> > of memory so failed in the middle of the system call processing" and
> > later could be a problem so we need to return value to indicate
> > how many bytes are succeeded so far so it means we need additional
> > out parameter. But yes, we can solve it by modifying semantic and
> > behavior (ex, as you said below, we could just unmark volatile
> > successfully if user pass (offset, len) consistent with marked volatile
> > ranges. (IOW, if we give up overlapping/subrange marking/unmakring
> > usecase. I expect it makes code simple further).
> > It's request from John so If he is okay, I'm no problem.
> 
> Yes, I don't insist on using madvise.  And it's too early to decide on
> an interface before we haven't fully nailed the semantics and features.
> 
> > > > o Not bind with vma split/merge logic to prevent mmap_sem cost and
> > > > o Not bind with vma split/merge logic to avoid vm_area_struct memory
> > > >   footprint.
> > > 
> > > VMAs are there to track attributes of memory ranges.  Duplicating
> > > large parts of their functionality and co-maintaining both structures
> > > on create, destroy, split, and merge means duplicate code and complex
> > > interactions.
> > > 
> > > 1. You need to define semantics and coordinate what happens when the
> > >    vma underlying a volatile range changes.
> > > 
> > >    Either you have to strictly co-maintain both range objects, or you
> > >    have weird behavior like volatily outliving a vma and then applying
> > >    to a separate vma created in its place.
> > > 
> > >    Userspace won't get this right, and even in the kernel this is
> > >    error prone and adds a lot to the complexity of vma management.
> > 
> > Current semantic is following as,
> > Vma handling logic in mm doesn't need to know vrange handling because
> > vrange's internal logic always checks validity of the vma but
> > one thing to do in vma logic is only clearing old volatile ranges
> > on creating new vma.
> > (Look at  [PATCH v10 02/16] vrange: Clear volatility on new mmaps)
> > Acutally I don't like the idea and suggested following as.
> > https://git.kernel.org/cgit/linux/kernel/git/minchan/linux.git/commit/?h=vrange-working&id=821f58333b381fd88ee7f37fd9c472949756c74e
> > But John didn't like it. I guess if VMA size is really matter,
> > maybe we can embedded the flag into somewhere field of
> > vma(ex, vm_file LSB?)
> 
> It's not entirely clear to me how the per-VMA variable can work like
> that when vmas can merge and split by other means (mprotect e.g.)

I don't get it. What's problem in mprotect?
If mprotect try to merge puerged VMA and none-purged VMA,
it couldn't be merged.
If mprotect splits on purged VMA, both VMAs should have purged
state.
You are concerning of false-postive report?

> 
> > > 2. If page reclaim discards a page from the upper end of a a range,
> > >    you mark the whole range as purged.  If the user later marks the
> > >    lower half of the range as non-volatile, the syscall will report
> > >    purged=1 even though all requested pages are still there.
> > 
> > True, The assumption is that basically, user should have a range
> > per object but we gives flexibility for user to handle subranges
> > of a volatile range so it might report false positive as you said.
> > In that case, please user can use mincore(2) for accuracy if he
> > want so he has flexiblity but lose performance a bit.
> > It's a tradeoff, IMO.
> 
> Look, we can't present a syscall that takes an exact range of bytes
> and then return results that are not applicable to this range at all.
> 
> We can not make performance trade-offs that compromise the semantics
> of the interface, and then recommend using an unrelated system call
> that takes the same byte range but somehow gets it right.

Fair enough.

> 
> > >    The only way to make these semantics clean is either
> > > 
> > >      a) have vrange() return a range ID so that only full ranges can
> > >      later be marked non-volatile, or
> > 
> > > 
> > >      b) remember individual page purges so that sub-range changes can
> > >      properly report them
> > > 
> > >    I don't like a) much because it's somewhat arbitrarily more
> > >    restrictive than madvise, mprotect, mmap/munmap etc.  And for b),
> > >    the straight-forward solution would be to put purge-cookies into
> > >    the page tables to properly report purges in subrange changes, but
> > >    that would be even more coordination between vmas, page tables, and
> > >    the ad-hoc vranges.
> > 
> > Agree but I don't want to put a accuracy of defalut vrange syscall.
> > Page table lookup needs mmap_sem and O(N) cost so I'm afraid it would
> > make userland folks hesitant using this system call.
> 
> If userspace sees nothing but cost in this system call, nothing but a
> voluntary donation for the common good of the system, then it does not
> matter how cheap this is, nobody will use it.  Why would they?  Even
> if it's a lightweight call, they still have to implement a mechanism
> for regenerating content etc.  It's still an investment to make, so
> there has to be a personal benefit or it's flawed from the beginning.
> 
> So why do applications want to use it?

In case of general allocator, sometime, madvise(DONTNEED) is really harmful
due to page-fault+allocation+zeroing

> 
> > > 3. Page reclaim usually happens on individual pages until an
> > >    allocation can be satisfied, but the shrinker purges entire ranges.
> > 
> > Strictly speaking, not entire rangeS but entire A range.
> > This recent patchset bails out if we discard as much as VM want.
> > 
> > > 
> > >    Should it really take out an entire 1G volatile range even though 4
> > >    pages would have been enough to satisfy an allocation?  Sure, we
> > >    assume a range represents an single "object" and userspace would
> > >    have to regenerate the whole thing with only one page missing, but
> > >    there is still a massive difference in page frees, faults, and
> > >    allocations.
> > 
> > That's why I wanted to introduce full and partial purging flag as system
> > call argument.
> 
> I just wonder why we would anything but partial purging.

I thought volatile pages are a not first class citizens.
I'd like to evict volatile pages firstly insead of working set.
Yes, it's really difficult to find when we should evict them so
that's one of reason why I introduced 09/16, where I just used
DER_PRIOIRTY - 2 for detecting memory pressure but it could be
changed easily with more smart algorithm in future.
Otherwise, we could deactivate volatile pages in tail of inactive LRU
when system call is called but it adds more time with write mmap_sem
so I'm not sure.

> 
> > > There needs to be a *really* good argument why VMAs are not enough for
> > > this purpose.  I would really like to see anon volatility implemented
> > 
> > Strictly speaking, volatile ranges has two goals.
> > 
> > 1. Avoid unncessary swapping or OOM if system has lots of volatile memory
> > 2. Give advanced free rather than madvise(DONTNEED)
> 
> Aren't they the same goal?  Giving applications a cheap way to
> relinquish unused memory.  If there is memory pressure, well, it was
> unused anyway.  If there isn't, the memory range can be reused without
> another mmap() and page faults.

Goal is same but implemtation should be different.
In case of 2, we should really avoid write mmap_sem.

> 
> > First goal is very clear so I don't need to say again
> > but it seems second goal isn't clear so that I try elaborate it a bit.
> > 
> > Current allocators really hates frequent calling munmap which is big
> > performance overhead if other threads are allocating new address
> > space or are faulting existing address space so they have used
> > madvise(DONTNEED) as optimization so at least, faulting threads
> > works well in parallel. It's better but allocators couldn't use
> > madvise(DONTNEED) frequently because it still prevent other thread's
> > allocation of new address space for a long time(becuase the overhead
> > of the system call is O(vma_size(vma)).
> 
> My suggestion of clearing dirty bits off of page table ranges would
> require only read-side mmap_sem.

So, you are suggesting the approach which doesn't mark/unmark VM_VOLATILE
in vma->vm_flags?

> 
> > Volatile ranges system call never don't need to hold write-side mmap_sem
> > and the execution time is almost O(log(nr_range))) and if we follow your
> > suggestion(ie, vrange returns ID), it's O(1). It's better.
> 
> I already wrote that to John: what if you have an array of objects and
> want to mark them all volatile, but then come back for individual
> objects in the array?  If vrange() creates a single range and returns
> an ID, you can't do this, unless you call vrange() for every single
> object first.
> 
> O(1) is great, but we are duplicating VMA functionality, anon reclaim
> functionality, have all these strange interactions, and a very
> restricted interface.

I agree with your concern and that's why I tried volatile ranges
with VMA approach in earier versions but it was terrible for allocators. :(

> 
> We have to make trade-offs here and I don't want to have all this
> complexity if there isn't a really solid reason for it.
> 
> > Another concern is that some of people want to handle range
> > fine-granularity, maybe worst case, PAGE_SIZE, in that case
> > so many VMA could be created if purging happens sparsely so it would
> > be really memory concern.
> 
> That's also no problem if we implement it based on dirty page table
> bits.

Still, marking/unmarking VM_VOLATILE is really problem.

> 
> > > as a VMA attribute, and have regular reclaim decide based on rmap of
> > > individual pages whether it needs to swap or purge.  Something like
> > > this:
> > > 
> > > MADV_VOLATILE:
> > >   split vma if necessary
> > >   set VM_VOLATILE
> > > 
> > > MADV_NONVOLATILE:
> > >   clear VM_VOLATILE
> > >   merge vma if possible
> > >   pte walk to check for pmd_purged()/pte_purged()
> > >   return any_purged
> > 
> > It could make system call really slow so allocator people really
> > would be reluctant to use it.
> 
> So what do they do instead?  munmap() and refault the pages?  Or sit
> on a bunch of unused memory and get killed by the OOM killer?  Or wait
> on IO while their unused pages are swapped in and out?

The more I discuss with you, the more I convince that we should
separate normal volatile ranges's usecase and allocators's one.
Allocator doesn't need to look back purged ranges so it would
be unnecesary unmarking VM_VOLATILE and even it doen't need to
mark VM_VOLATILE of vma. If so, it's really same semantic with
MADV_FREE. Although MADV_FREE is O(#pages), it wouldn't be big
overhead as you said because trend are huge pages and it doen't
need to require mmap_sem write-side lock.
As bonus point, if we take the usecase out from volatile semantics,
we're okay to put more overhead into vrange syscall so it turns
out VMA approach would be good and everyone is happy?

Still problem I am concerning that WHEN we should evict volatile
pages which are second class citizens?

Thanks for the comment, Hannes!

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
