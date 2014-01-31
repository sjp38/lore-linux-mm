Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9846B0036
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 20:27:25 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so3857571pab.38
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:27:24 -0800 (PST)
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
        by mx.google.com with ESMTPS id va10si8442312pbc.338.2014.01.30.17.27.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 17:27:24 -0800 (PST)
Received: by mail-pd0-f177.google.com with SMTP id x10so3702455pdj.36
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:27:23 -0800 (PST)
Message-ID: <52EAFBF6.7020603@linaro.org>
Date: Thu, 30 Jan 2014 17:27:18 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
References: <1388646744-15608-1-git-send-email-minchan@kernel.org> <20140129000359.GZ6963@cmpxchg.org> <52E85CDA.5090102@linaro.org> <20140129183032.GA6963@cmpxchg.org>
In-Reply-To: <20140129183032.GA6963@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, pliard@google.com

On 01/29/2014 10:30 AM, Johannes Weiner wrote:
> On Tue, Jan 28, 2014 at 05:43:54PM -0800, John Stultz wrote:
>> On 01/28/2014 04:03 PM, Johannes Weiner wrote:
>>> On Thu, Jan 02, 2014 at 04:12:08PM +0900, Minchan Kim wrote:
>>>> o Syscall interface
>>> Why do we need another syscall for this?  Can't we extend madvise to
>>> take MADV_VOLATILE, MADV_NONVOLATILE, and return -ENOMEM if something
>>> in the range was purged?
>> So the madvise interface is insufficient to provide the semantics
>> needed. Not so much for MADV_VOLATILE, but MADV_NONVOLATILE. For the
>> NONVOLATILE call, we have to atomically unmark the volatility status of
>> the byte range and provide the purge status, which informs the caller if
>> any of the data in the specified range was discarded (and thus needs to
>> be regenerated).
>>
>> The problem is that by clearing the range, we may need to allocate
>> memory (possibly by splitting in an existing range segment into two),
>> which possibly could fail. Unfortunately this could happen after we've
>> modified the volatile state of part of that range.  At this point we
>> can't just fail, because we've modified state and we also need to return
>> the purge status of the modified state.
> munmap() can theoretically fail for the same reason (splitting has to
> allocate a new vma) but it's not even documented.  The allocator does
> not fail allocations of that order.
>
> I'm not sure this is good enough, but to me it sounds a bit overkill
> to design a new system call around a non-existent problem.

I still think its problematic design issue. With munmap, I think
re-calling on failure should be fine. But with _NONVOLATILE we could
possibly lose the purge status on a second call (for instance if only
the first page of memory was purged, but we errored out mid-call w/
ENOMEM, on the second call it will seem like the range was successfully
set non-volatile with no memory purged).

And even if the current allocator never ever fails, I worry at some
point in the future that rule might change and then we'd have a broken
interface.



>>>> o Not bind with vma split/merge logic to prevent mmap_sem cost and
>>>> o Not bind with vma split/merge logic to avoid vm_area_struct memory
>>>>   footprint.
>>> VMAs are there to track attributes of memory ranges.  Duplicating
>>> large parts of their functionality and co-maintaining both structures
>>> on create, destroy, split, and merge means duplicate code and complex
>>> interactions.
>>>
>>> 1. You need to define semantics and coordinate what happens when the
>>>    vma underlying a volatile range changes.
>>>
>>>    Either you have to strictly co-maintain both range objects, or you
>>>    have weird behavior like volatily outliving a vma and then applying
>>>    to a separate vma created in its place.
>> So indeed this is a difficult problem!  My initial approach is simply
>> when any new mapping is made, we clear the volatility of the affected
>> process memory. Admittedly this has extra overhead and Minchan has an
>> alternative here (which I'm not totally sold on yet, but may be ok). 
>> I'm almost convinced that for anonymous volatility, storing the
>> volatility in the vma would be ok, but Minchan is worried about the
>> performance overhead of the required locking for manipulating the vmas.
>>
>> For file volatility, this is more complicated, because since the
>> volatility is shared, the ranges have to be tracked against the
>> address_space structure, and can't be stored in per-process vmas. So
>> this is partially why we've kept range trees hanging off of the mm and
>> address_spaces structures, since it allows the range manipulation logic
>> to be shared in both cases.
> The fs people probably have not noticed yet what you've done to struct
> address_space / struct inode ;-) I doubt that this is mergeable in its
> current form, so we have to think about a separate mechanism for shmem
> page ranges either way.

Yea. But given the semantics will likely be *very* similar, it seems
strange to try to force separate mechanisms.

That said, in an earlier implementation I stored the range tree in a
hash so we wouldn't have to add anything to the address_space structure.
But for now I want to make it clear that the ranges are tied to the
address space (and it gives the fs folks something to notice ;).


>>>    Userspace won't get this right, and even in the kernel this is
>>>    error prone and adds a lot to the complexity of vma management.
>> Not sure exactly I understand what you mean by "userspace won't get this
>> right" ?
> I meant, userspace being responsible for keeping vranges coherent with
> its mmap and munmap operations, instead of the kernel doing it.
>
>>> 2. If page reclaim discards a page from the upper end of a a range,
>>>    you mark the whole range as purged.  If the user later marks the
>>>    lower half of the range as non-volatile, the syscall will report
>>>    purged=1 even though all requested pages are still there.
>> To me this aspect is a non-ideal but acceptable result of the usage pattern.
>>
>> Semantically, the hard rule would be we never report non-purged if pages
>> in a range were purged.  Reporting purged when pages technically weren't
>> is not optimal but acceptable side effect of unmarking a sub-range. And
>> could be avoided by applications marking and unmarking objects consistently.
>>
>>
>>>    The only way to make these semantics clean is either
>>>
>>>      a) have vrange() return a range ID so that only full ranges can
>>>      later be marked non-volatile, or
>>>
>>>      b) remember individual page purges so that sub-range changes can
>>>      properly report them
>>>
>>>    I don't like a) much because it's somewhat arbitrarily more
>>>    restrictive than madvise, mprotect, mmap/munmap etc.  
>> Agreed on A.
>>
>>> And for b),
>>>    the straight-forward solution would be to put purge-cookies into
>>>    the page tables to properly report purges in subrange changes, but
>>>    that would be even more coordination between vmas, page tables, and
>>>    the ad-hoc vranges.
>> And for B this would cause way too much overhead for the mark/unmark
>> operations, which have to be lightweight.
> Yes, and allocators/message passers truly don't need this because at
> the time they set a region to volatile the contents are invalidated
> and the non-volatile declaration doesn't give a hoot if content has
> been destroyed.
>
> But caches certainly would have to know if they should regenerate the
> contents.  And bigger areas should be using huge pages, so we'd check
> in 2MB steps.  Is this really more expensive than regenerating the
> contents on a false positive?

So you make a good argument. I'd counter that the false-positives are
only caused when unmarking subranges of larger marked volatile range,
and for use cases that would care about regenerating the contents,
that's not a likely useage model (as they're probably going to be
marking objects in memory volatile/nonvolatile, not just arbitrary
ranges of pages).


> MADV_NONVOLATILE and MADV_NONVOLATILE_REPORT? (catchy, I know...)

Something like this might be doable. I suspect the non-reporting
non-volatile is more of a special case (reporting should probably be the
default - as its safer), so it should probably have the longer name. 
But that's a minor issue.


> What worries me a bit is that we have started from the baseline that
> anything that scales with range size is way too much overhead,
> regardless of how awkward and alien the alternatives are to implement.
> But even in its most direct implementation, marking discardable pages
> one by one is still a massive improvement over thrashing cache or
> swapping, so why do we have to start from such an extreme?
>
> Applications won't use this interface because it's O(1), but because
> they don't want to be #1 in memory consumption when the system hangs
> and thrashes and swaps.
>
> Obviously, the lighter the better, but this code just doesn't seem to
> integrate at all into the VM and I don't think it's justified.

You're point about the implementation being somewhat alien is understood
(though again, there's not really a VMA like structure for files, so
tmpfs volatility I think will need something like this anyway) and at
this point I'm willing to give this a try. A fast design that gets
ignored is of less use then a slower one that gets reviewed and can be
merged. :)

That said, the whole premise here isn't in any single applications best
interest. We're basically asking applications to pledge donations of
memory, which will can only hurt their performance if the kernel take
it. This allows the entire system to run better, as more applications
can stay in memory, but if an application can get a 15% performance bump
by not donating memory and hoping the OOM killer will get some
other-app, that probably is hard to argue against. So I think lowering
the bar as much as possible so the "donations" minimally affect
performance is important for adoption (for example, think of the issue
w/ fsync on ext3).

But again, maybe that performance issue is something folks would be
willing to look into at a later point once the functionality is merged
and well understood?

>> However there are more then just philosophical issues that complicate
>> things. On swapless systems, we don't age anonymous pages, so we don't
>> have a hook to purge volatile pages. So in that case we currently have
>> to use the shrinker and use the full-range purging behavior.
>>
>> Adding anonymous aging for swapless systems might be able to help here,
>> but thats likely to be complicated as well. For now the dual approach
>> Minchan implemented (where the LRU can evict single pages, and the
>> shrinker can evict total ranges) seems like a reasonable compromise
>> while the functionality is reviewed.
> We should at least *try* to go back to aging anon and run some tests
> to quantify the costs, before creating a new VM object with its own
> separate ad-hoc aging on speculation!  We've been there and it wasn't
> that bad...

Fair enough!


>>>   clear VM_VOLATILE
>>>   merge vma if possible
>>>   pte walk to check for pmd_purged()/pte_purged()
>> So I think the pte walk would be way too costly. Its probably easier to
>> have a VM_PURGED or something on the vma that we set when we purge a
>> page, which would simplify the purge state handling.
> I added it because, right now, userspace only knows about pages.  It
> does not know that when you mmap/madvise/mprotect that the kernel
> creates range objects - that's an implementation detail - it only
> knows that you are changing the attributes of a bunch of pages.
>
> Reporting a result for a super-range of what you actually speficied in
> the syscall would implicitely turn ranges into first class
> user-visible VM objects.
>
> This is a huge precedent.  "The traditional Unix memory objects of
> file mappings, shared memory segments, anon mappings, pages, bytes,
> and vranges!"  Is it really that strong of an object type?  Does a
> performance optimization of a single use case justify it?
>
> I'd rather we make the reporting optional and report nothing in cases
> where it's not needed, if that's all it takes.
>
> And try very hard to stick with pages as the primary unit of paging.

I'd still think that ranges are still bunches of pages. But that by
allowing for the reporting of false positives (which applications have
to be able to handle anyway) in the unlikely case of unmarking a
sub-range of pages that were marked, we are able to make the
marking/unmarking operation much faster. Yes, behaviorally one can
intuit from this that there are these page-range objects managed by the
kernel, but I'd think its not really a first-order object.

But you have a strong argument, and I'm willing to concede the point
(this is your space, afterall :).  However I do worry that by limiting
the flexibility of the semantics, we'll lock out some potential
performance optimizations later.


>>> Support for file pages are a very big deal and they seem to have had
>>> an impact on many design decisions, but they are only mentioned on a
>>> side note in this email.
>>>
>>> The rationale behind volatile anon pages was that they are often used
>>> as caches and that dropping them under pressure and regenerating the
>>> cache contents later on was much faster than swapping.
>>>
>>> But pages that are backed by an actual filesystem are "regenerated" by
>>> reading the contents back from disk!  What's the point of declaring
>>> them volatile?
>>>
>>> Shmem pages are a different story.  They might be implemented by a
>>> virtual filesystem, but they behave like anon pages when it comes to
>>> reclaim and repopulation so the same rationale for volatility appies.
>> Right. So file volatility is mostly interesting to me on tmpfs/shmem,
>> and your point about them being only sort of technically file pages is
>> true, it sort of depends on where you stand in the kernel as to if its
>> considered file or anonymous memory.
> Yeah, there are many angles to look at it, but it's important that the
> behavior is sane and consistent across all of them.

Agreed.


>> As for real-disk-backed file volatility, I'm not particularly interested
>> in that, and fine with losing it. However, some have expressed
>> theoretical interest that there may be cases where throwing the memory
>> away is faster then writing it back to disk, so it might have some value
>> there. But I don't have any concrete use cases that need it.
> That could also be covered with an interface that clears dirty bits in
> a range of pages.

Well.. possibly. The issues with real files are ugly, since you don't
want have stale data show up after the purge. In the past I proposed the
hole punching for this, but that could be just as costly then writing
the data back.

Practically, I really don't see how true-file volatility makes any sense.

The only rational interest was made by Dave Chinner, but what he really
wanted was totally different. Something like a file-system persistent
(instead of in-memory) volatility, so that filesystems could pick chunks
of files to purge when disk space got tight.


>> Really the *key* need for tmpfs/shmem file volatility is in order to
>> have volatility on shared memory.
>>
>>> But a big aspect of anon volatility is communicating to userspace
>>> whether *content* has been destroyed while in volatile state.  Shmem
>>> pages might not necessarily need this.  The oft-cited example is the
>>> message passing in a large circular buffer that is unused most of the
>>> time.  The sender would mark it non-volatile before writing, and the
>>> receiver would mark it volatile again after reading.  The writer can
>>> later reuse any unreclaimed *memory*, but nobody is coming back for
>>> the actual *contents* stored in there.  This usecase would be
>>> perfectly fine with an interface that simply clears the dirty bits of
>>> a range of shmem pages (through mmap or fd).  The writer would set the
>>> pages non-volatile by dirtying them, whereas the reader would mark
>>> them volatile again by clearing the dirty bits.  Reclaim would simply
>>> discard clean pages.
>> So while in that case, its unlikely anyone is going to be trying to
>> reuse contents of the volatile data. However, there may be other cases
>> where for example, a image cache is managed in a shared tmpfs segment
>> between a jpeg renderer and a web-browser, so there can be improved
>> isolation/sandboxing between the functionality. In that case, the
>> management of the volatility would be handled completely by the
>> web-browser process, but we'd want memory to be shared so we've have
>> zero-copy from the render.
>>
>> In that case, the browser would want to be able mark chunks of shared
>> buffer volatile when it wasn't in use, and to unmark the range and
>> re-use it if it wasn't purged.
> You are right, we probably can not ignore such cases.
>
> The way I see it, the simplest design, the common denominator for
> private anon, true file, shmem, tmpfs, would be for MADV/FADV_VOLATILE
> to clear dirty bits off shared pages, or ptes/pmds in the private
> mapped case to keep the COW charade intact.  And for the NONVOLATILE
> side to set dirty on what's still present and report if something is
> missing.

Hrmmm. This sounds reasonable, but I'm not sure its right.  It seems the
missing part here is (with anonymous scanning on swapless systems), we
still have to set the volatility of the page somewhere so the LRU
scanner will actually purge those made-clean pages, no? Otherwise won't
anon and tmpfs files either just be swapped or passed over and left in
memory? And again, for true-files, we don't want stale data.


> Allocators and message passers don't care about content once volatile,
> only about the memory.  They wouldn't even have to go through the
> non-volatile step anymore, they could just write to memory again and
> it'll set the dirty bits and refault what's missing.

So this would implicitly make any write effectively clear the volatility
of a page? That probably would be an ok semantic with the use cases I'm
aware of, but its new.


> Caches in anon memory would have to mark the pages volatile and then
> later non-volatile to see if the contents have been preserved.
>
> In the standard configuration, this would exclude the optimistic
> usecase, but it's conceivable to have a settable per-VMA flag that
> prevents purged pages from refaulting silently and make them trip a
> SIGBUS instead.  But I'm still a little dubious whether this usecase
> is workable in general...

So the SIGBUS bit is of particular interest to the Mozilla folks. My
understanding of the usage case they want to have is expanding
compressed library files into memory, but allowing the cold library
pages to be purged. Then on access, any purged pages triggers the
SIGBUS, which allows them to "fault" back in that page from the
compressed file.

Similarly I can see folks wanting to use the optimistic model for other
use cases in general, especially if we go with a O(#pages) algorithm, as
it allows even less overhead by avoiding umarking and remarking pages on
access.

That said, the SIGBUS model is a bit painful as properly handling
signals in a large application is treacherous. So alternative solutions
for what is bascially userland page-faulting would be of interest.



> Such an interface would be dead simple to use and consistent across
> all types.  The basic implementation would require only a couple of
> lines of code, and while O(pages), it would still be much cheaper than
> thrashing and swapping, and still cheaper than actively giving ranges
> back to the kernel and reallocating and repopulating them later on.
>
> Compare this to the diffstat of the current vrange implementation and
> the complexity and inconsistencies it introduces into the VM.  I'm not
> sure an O(pages) interface would be unattractive enough to justify it.

Ok. So I think we're in agreement with:
* Moving the volatility state for anonymous volatility into the VMA
* Getting anonymous scanning going again on swapless systems

I'm still not totally sure about, but willing to try
* Page granular volatile tracking

I'm still not convinced on:
* madvise as a sufficient interface


I'll try to work out a draft of what your proposing (probably just for
anonymous memory for now) and we can iterate from there?

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
