Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD2E6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 20:44:05 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so1110850pbb.21
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 17:44:05 -0800 (PST)
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
        by mx.google.com with ESMTPS id xf4si496893pab.307.2014.01.28.17.44.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 17:44:04 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id x10so1085089pdj.39
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 17:44:03 -0800 (PST)
Message-ID: <52E85CDA.5090102@linaro.org>
Date: Tue, 28 Jan 2014 17:43:54 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
References: <1388646744-15608-1-git-send-email-minchan@kernel.org> <20140129000359.GZ6963@cmpxchg.org>
In-Reply-To: <20140129000359.GZ6963@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, pliard@google.com

On 01/28/2014 04:03 PM, Johannes Weiner wrote:
> Hello Minchan,
>
> On Thu, Jan 02, 2014 at 04:12:08PM +0900, Minchan Kim wrote:
>> Hey all,
>>
>> Happy New Year!
>>
>> I know it's bad timing to send this unfamiliar large patchset for
>> review but hope there are some guys with freshed-brain in new year
>> all over the world. :)
>> And most important thing is that before I dive into lots of testing,
>> I'd like to make an agreement on design issues and others
>>
>> o Syscall interface
> Why do we need another syscall for this?  Can't we extend madvise to
> take MADV_VOLATILE, MADV_NONVOLATILE, and return -ENOMEM if something
> in the range was purged?

So the madvise interface is insufficient to provide the semantics
needed. Not so much for MADV_VOLATILE, but MADV_NONVOLATILE. For the
NONVOLATILE call, we have to atomically unmark the volatility status of
the byte range and provide the purge status, which informs the caller if
any of the data in the specified range was discarded (and thus needs to
be regenerated).

The problem is that by clearing the range, we may need to allocate
memory (possibly by splitting in an existing range segment into two),
which possibly could fail. Unfortunately this could happen after we've
modified the volatile state of part of that range.  At this point we
can't just fail, because we've modified state and we also need to return
the purge status of the modified state.

Thus we seem to need a write-like interface, which returns the number of
bytes successfully manipulated. But we also have to return the purge
state, which we currently do via a argument pointer.

hpa suggested to create something like an madvise2 interface which would
provide the needed interface change, but would be a shared interface for
the new flags as well as the old (possibly allowing various flags to be
combined). I'm fine changing it (the interface has changed a number of
times already), but we really haven't seen much in the way of a deeper
review, so the current vrange syscall is mostly a placeholder to
demonstrate the functionality and hopefully spur discussion on the
deeper semantics of how volatile ranges should work.


>> o Not bind with vma split/merge logic to prevent mmap_sem cost and
>> o Not bind with vma split/merge logic to avoid vm_area_struct memory
>>   footprint.
> VMAs are there to track attributes of memory ranges.  Duplicating
> large parts of their functionality and co-maintaining both structures
> on create, destroy, split, and merge means duplicate code and complex
> interactions.
>
> 1. You need to define semantics and coordinate what happens when the
>    vma underlying a volatile range changes.
>
>    Either you have to strictly co-maintain both range objects, or you
>    have weird behavior like volatily outliving a vma and then applying
>    to a separate vma created in its place.

So indeed this is a difficult problem!  My initial approach is simply
when any new mapping is made, we clear the volatility of the affected
process memory. Admittedly this has extra overhead and Minchan has an
alternative here (which I'm not totally sold on yet, but may be ok). 
I'm almost convinced that for anonymous volatility, storing the
volatility in the vma would be ok, but Minchan is worried about the
performance overhead of the required locking for manipulating the vmas.

For file volatility, this is more complicated, because since the
volatility is shared, the ranges have to be tracked against the
address_space structure, and can't be stored in per-process vmas. So
this is partially why we've kept range trees hanging off of the mm and
address_spaces structures, since it allows the range manipulation logic
to be shared in both cases.


>    Userspace won't get this right, and even in the kernel this is
>    error prone and adds a lot to the complexity of vma management.
Not sure exactly I understand what you mean by "userspace won't get this
right" ?


>
> 2. If page reclaim discards a page from the upper end of a a range,
>    you mark the whole range as purged.  If the user later marks the
>    lower half of the range as non-volatile, the syscall will report
>    purged=1 even though all requested pages are still there.

To me this aspect is a non-ideal but acceptable result of the usage pattern.

Semantically, the hard rule would be we never report non-purged if pages
in a range were purged.  Reporting purged when pages technically weren't
is not optimal but acceptable side effect of unmarking a sub-range. And
could be avoided by applications marking and unmarking objects consistently.


>    The only way to make these semantics clean is either
>
>      a) have vrange() return a range ID so that only full ranges can
>      later be marked non-volatile, or
>
>      b) remember individual page purges so that sub-range changes can
>      properly report them
>
>    I don't like a) much because it's somewhat arbitrarily more
>    restrictive than madvise, mprotect, mmap/munmap etc.  
Agreed on A.

> And for b),
>    the straight-forward solution would be to put purge-cookies into
>    the page tables to properly report purges in subrange changes, but
>    that would be even more coordination between vmas, page tables, and
>    the ad-hoc vranges.

And for B this would cause way too much overhead for the mark/unmark
operations, which have to be lightweight.


> 3. Page reclaim usually happens on individual pages until an
>    allocation can be satisfied, but the shrinker purges entire ranges.
>
>    Should it really take out an entire 1G volatile range even though 4
>    pages would have been enough to satisfy an allocation?  Sure, we
>    assume a range represents an single "object" and userspace would
>    have to regenerate the whole thing with only one page missing, but
>    there is still a massive difference in page frees, faults, and
>    allocations.

So the purging behavior has been a (lightly) contentious item. Some have
argued that if a page from a range is purged, we might as well purge the
entire range before purging any page from another range. This makes the
most sense from the usage model where a range is marked and not touched
until it is unmarked.

However, if the user is utilizing the SIGBUS behavior and continues to
access the volatile range, we would really ideally have only the cold
pages purged so that the application can continue and the system can
manage all the pages via the LRU.

Minchan has proposed having flags to set the volatility mode (_PARTIAL
or _FULL) to allow applications to state their preferred behavior, but I
still favor having global LRU behavior and purging things page by page
via normal reclaim.  My opinion is due to the fact that full-range
purging causes purging to be least-recently-marked-volatile rather then
LRU, but if the ranges are not accessed while volatile, LRU should
approximate the least-recently-marked-volatile.

However there are more then just philosophical issues that complicate
things. On swapless systems, we don't age anonymous pages, so we don't
have a hook to purge volatile pages. So in that case we currently have
to use the shrinker and use the full-range purging behavior.

Adding anonymous aging for swapless systems might be able to help here,
but thats likely to be complicated as well. For now the dual approach
Minchan implemented (where the LRU can evict single pages, and the
shrinker can evict total ranges) seems like a reasonable compromise
while the functionality is reviewed.


> There needs to be a *really* good argument why VMAs are not enough for
> this purpose.  I would really like to see anon volatility implemented
> as a VMA attribute, and have regular reclaim decide based on rmap of
> individual pages whether it needs to swap or purge.  Something like
> this:


The performance aspect is the major issue. With the separate range tree,
the operations are close to O(log(#ranges)), which is really attractive.
Anything that changes it to O(#pages in range) would be problematic. 
But I think I could mostly go along with this if it stays O(log(#vmas)),
but will let Minchan detail his objections (which are mostly around the
locking contention). Though a few notes on your proposal...


>
> MADV_VOLATILE:
>   split vma if necessary
>   set VM_VOLATILE
>
> MADV_NONVOLATILE:
 also need a "split vma if necessary" here.
>   clear VM_VOLATILE
>   merge vma if possible
>   pte walk to check for pmd_purged()/pte_purged()
So I think the pte walk would be way too costly. Its probably easier to
have a VM_PURGED or something on the vma that we set when we purge a
page, which would simplify the purge state handling.


>   return any_purged
>
> shrink_page_list():
>   if PageAnon:
>     if try_to_purge_anon():
>       page_lock_anon_vma_read()
>       anon_vma_interval_tree_foreach:
>         if vma->vm_flags & VM_VOLATILE:
>           lock page table
>           unmap page
>           set_pmd_purged() / set_pte_purged()
>           unlock page table
>       page_lock_anon_vma_read()
>    ...
>    try to reclaim

Again, we'd have to sort out something here for swapless systems.


The only other issue with the using VMAs that confused me when I looked
at it earlier, was that I thought most vma operations will merge
adjacent vmas if the vma state is the same.  Your example doesn't have
this issue since you're checking the pages on non-volatile operations,
but assuming we store the purge state in the vma, we wouldn't want to
merge vmas  since that would result in two separate volatile (but
unpurged) ranges being merged, and then the increased likelyhood we'd
consider the entire thing purged. 


>
>> o Purging logic - when we trigger purging volatile pages to prevent
>>   working set and stop to prevent too excessive purging of volatile
>>   pages
>> o How to test
>>   Currently, we have a patched jemalloc allocator by Jason's help
>>   although it's not perfect and more rooms to be enhanced but IMO,
>>   it's enough to prove vrange-anonymous. The problem is that
>>   lack of benchmark for testing vrange-file side. I hope that
>>   Mozilla folks can help.
>>
>> So its been a while since the last release of the volatile ranges
>> patches, again. I and John have been busy with other things.
>> Still, we have been slowly chipping away at issues and differences
>> trying to get a patchset that we both agree on.
>>
>> There's still a few issues, but we figured any further polishing of
>> the patch series in private would be unproductive and it would be much
>> better to send the patches out for review and comment and get some wider
>> opinions.
>>
>> You could get full patchset by git
>>
>> git clone -b vrange-v10-rc5 --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git
>>
>> In v10, there are some notable changes following as
>>
>> Whats new in v10:
>> * Fix several bugs and build break
>> * Add shmem_purge_page to correct purging shmem/tmpfs
>> * Replace slab shrinker with direct hooked reclaim path
>> * Optimize pte scanning by caching previous place
>> * Reorder patch and tidy up Cc-list
>> * Rebased on v3.12
>> * Add vrange-anon test with jemalloc in Dhaval's test suite
>>   - https://github.com/volatile-ranges-test/vranges-test
>>   so, you could test any application with vrange-patched jemalloc by
>>   LD_PRELOAD but please keep in mind that it's just a prototype to
>>   prove vrange syscall concept so it has more rooms to optimize.
>>   So, please do not compare it with another allocator.
>>    
>> Whats new in v9:
>> * Updated to v3.11
>> * Added vrange purging logic to purge anonymous pages on
>>   swapless systems
> We stopped scanning anon on swapless systems because anon needed swap
> to be reclaimable.  If we can reclaim anon without swap, we have to
> start scanning anon again unconditionally.  It makes no sense to me to
> work around this optimization and implement a separate reclaim logic.

I'd personally prefer we move to that.. but I'm not sure if the
unconditional scanning would be considered too problematic?



>
>> The syscall interface is defined in patch [4/16] in this series, but
>> briefly there are two ways to utilze the functionality:
>>
>> Explicit marking method:
>> 1) Userland marks a range of memory that can be regenerated if necessary
>> as volatile
>> 2) Before accessing the memory again, userland marks the memroy as
>> nonvolatile, and the kernel will provide notifcation if any pages in the
>> range has been purged.
>>
>> Optimistic method:
>> 1) Userland marks a large range of data as volatile
>> 2) Userland continues to access the data as it needs.
>> 3) If userland accesses a page that has been purged, the kernel will
>> send a SIGBUS
>> 4) Userspace can trap the SIGBUS, mark the afected pages as
>> non-volatile, and refill the data as needed before continuing on
> What happens if a pointer to volatile memory is passed to a syscall
> and the fault happens inside copy_*_user()?

I'll have to look into that detail. Thanks for bringing it up.

I suspect it would be the same as if a pointer to mmapped file was
passed to a syscall and the file was truncated by another processes?



>
>> Other details:
>> The interface takes a range of memory, which can cover anonymous pages
>> as well as mmapped file pages. In the case that the pages are from a
>> shared mmapped file, the volatility set on those file pages is global.
>> Thus much as writes to those pages are shared to other processes, pages
>> marked volatile will be volatile to any other processes that have the
>> file mapped as well. It is advised that processes coordinate when using
>> volatile ranges on shared mappings (much as they must coordinate when
>> writing to shared data). Any uncleared volatility on mmapped files will
>> last until the the file is closed by all users (ie: volatility isn't
>> persistent on disk).
> Support for file pages are a very big deal and they seem to have had
> an impact on many design decisions, but they are only mentioned on a
> side note in this email.
>
> The rationale behind volatile anon pages was that they are often used
> as caches and that dropping them under pressure and regenerating the
> cache contents later on was much faster than swapping.
>
> But pages that are backed by an actual filesystem are "regenerated" by
> reading the contents back from disk!  What's the point of declaring
> them volatile?
>
> Shmem pages are a different story.  They might be implemented by a
> virtual filesystem, but they behave like anon pages when it comes to
> reclaim and repopulation so the same rationale for volatility appies.
Right. So file volatility is mostly interesting to me on tmpfs/shmem,
and your point about them being only sort of technically file pages is
true, it sort of depends on where you stand in the kernel as to if its
considered file or anonymous memory.

As for real-disk-backed file volatility, I'm not particularly interested
in that, and fine with losing it. However, some have expressed
theoretical interest that there may be cases where throwing the memory
away is faster then writing it back to disk, so it might have some value
there. But I don't have any concrete use cases that need it.

Really the *key* need for tmpfs/shmem file volatility is in order to
have volatility on shared memory.

> But a big aspect of anon volatility is communicating to userspace
> whether *content* has been destroyed while in volatile state.  Shmem
> pages might not necessarily need this.  The oft-cited example is the
> message passing in a large circular buffer that is unused most of the
> time.  The sender would mark it non-volatile before writing, and the
> receiver would mark it volatile again after reading.  The writer can
> later reuse any unreclaimed *memory*, but nobody is coming back for
> the actual *contents* stored in there.  This usecase would be
> perfectly fine with an interface that simply clears the dirty bits of
> a range of shmem pages (through mmap or fd).  The writer would set the
> pages non-volatile by dirtying them, whereas the reader would mark
> them volatile again by clearing the dirty bits.  Reclaim would simply
> discard clean pages.

So while in that case, its unlikely anyone is going to be trying to
reuse contents of the volatile data. However, there may be other cases
where for example, a image cache is managed in a shared tmpfs segment
between a jpeg renderer and a web-browser, so there can be improved
isolation/sandboxing between the functionality. In that case, the
management of the volatility would be handled completely by the
web-browser process, but we'd want memory to be shared so we've have
zero-copy from the render.

In that case, the browser would want to be able mark chunks of shared
buffer volatile when it wasn't in use, and to unmark the range and
re-use it if it wasn't purged.

But maybe I'm not quite seeing what your suggesting here!


> So I'm not convinced that the anon side needs to be that awkward, that
> all filesystems need to be supported because of shmem, and that shmem
> needs more than an interface to clear dirty bits.

Minchan may also have a different opinion then me, but I think I can
compromise/agree with your first two points there (or atleast see about
giving your approach a shot). The last I'm not confident of, but please
expand if my examples above don't contradict your idea.

Johannes: Thanks so much for the review here! After not getting too much
feedback, its been hard to put additional effort into this work, despite
feeling that it is important. This is really motivating!

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
