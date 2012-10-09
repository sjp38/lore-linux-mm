Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id E32FC6B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 22:45:22 -0400 (EDT)
Date: Tue, 9 Oct 2012 11:49:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] Volatile Ranges (v7) & Lots of words
Message-ID: <20121009024932.GE13817@bbox>
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
 <20121008062517.GA13817@bbox>
 <50737CF3.8040605@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50737CF3.8040605@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kleen, Andi" <andi@firstfloor.org>

On Mon, Oct 08, 2012 at 06:25:07PM -0700, John Stultz wrote:
> On 10/07/2012 11:25 PM, Minchan Kim wrote:
> >Hi John,
> >
> >On Fri, Sep 28, 2012 at 11:16:30PM -0400, John Stultz wrote:
> >>After Kernel Summit and Plumbers, I wanted to consider all the various
> >>side-discussions and try to summarize my current thoughts here along
> >>with sending out my current implementation for review.
> >>
> >>Also: I'm going on four weeks of paternity leave in the very near
> >>(but non-deterministic) future. So while I hope I still have time
> >>for some discussion, I may have to deal with fussier complaints
> >>then yours. :)  In any case, you'll have more time to chew on
> >>the idea and come up with amazing suggestions. :)
> >>
> >>
> >>General Interface semantics:
> >>----------------------------------------------
> >>
> >>The high level interface I've been pushing has so far stayed fairly
> >>consistent:
> >>
> >>Application marks a range of data as volatile. Volatile data may
> >>be purged at any time. Accessing volatile data is undefined, so
> >>applications should not do so. If the application wants to access
> >>data in a volatile range, it should mark it as non-volatile. If any
> >>of the pages in the range being marked non-volatile had been purged,
> >>the kernel will return an error, notifying the application that the
> >>data was lost.
> >>
> >>But one interesting new tweak on this design, suggested by the Taras
> >>Glek and others at Mozilla, is as follows:
> >>
> >>Instead of leaving volatile data access as being undefined , when
> >>accessing volatile data, either the data expected will be returned
> >>if it has not been purged, or the application will get a SIGBUS when
> >>it accesses volatile data that has been purged.
> >>
> >>Everything else remains the same (error on marking non-volatile
> >>if data was purged, etc). This model allows applications to avoid
> >>having to unmark volatile data when it wants to access it, then
> >>immediately re-mark it as volatile when its done. It is in effect
> >Just out of curiosity.
> >Why should application remark it as volatile again?
> >It have been already volatile range and application doesn't receive
> >any signal while it uses that range. So I think it doesn't need to
> >remark.
> 
> Not totally sure I understand your question clearly.
> 
> So assuming one has a large cache of independently accessed objects,
> this mark-nonvolatile/access/mark-volatile pattern is useful if you
> don't want to have to deal with handling the SIGBUS.
> 
> For instance, if when accessing the data (say uncompressed image
> data), you are passing it to a library (to do something like an
> image filter, in place), where you don't want the library's access
> of the data to cause an unexpected SIGBUS that would be difficult to
> recover from.

I just confused by your word.
AFAIUC, you mean following as.

1) mark volatile
2) access pages in the range until SIGBUS happens
3) when SIGBUS happens, unmark volatile
4) access pages in the raange
5) When it's done, remark it as volatile

I agree this model.

> 
> 
> >>"lazy" with its marking, allowing the kernel to hit it with a signal
> >>when it gets unlucky and touches purged data. From the signal handler,
> >>the application can note the address it faulted on, unmark the range,
> >>and regenerate the needed data before returning to execution.
> >I like this model if plumbers really want it.
> 
> I think it makes sense.  Also it avoids a hole in the earlier
> semantics: If accessing volatile data is undefined, and you might
> get the data, or you might get zeros, there's the problem of writes
> that occur on purged ranges (Credits to Mike Hommey for pointing
> this out in his critique of Android's ashmem).  If an application
> writes data to a purged range, the range continues to be considered
> volatile, and since neighboring data may still be purged, the entire
> set is considered purged.  Because of this, we don't end up purging
> the data again (at least with the shrinker method).
> 
> By adding the SIGBUS on access of purged pages, it cleans up the
> semantics nicely.
> 
> 
> 
> >
> >>However, If applications don't want to deal with handling the
> >>sigbus, they can use the more straightforward (but more costly)
> >>unmark/access/mark pattern in the same way as my earlier proposals.
> >>
> >>This allows folks to balance the cost vs complexity in their
> >>application appropriately.
> >>
> >>So that's a general overview of how the idea I'm proposing could
> >>be used.
> >My idea is that we don't need to move all pages in the range
> >to tail of LRU or new LRU list. Just move a page in the range
> >into tail of LRU or new LRU list. And when reclaimer start to find
> >victim page, it can know this page is volatile by something
> >(ex, if we use new LRU list, we can know it easily, Otherwise,
> >we can use VMA's new flag - VM_VOLATILE and we can know it easily
> >by page_check_references's tweak) and isolate all pages of the range
> >in middle of LRU list and reclaim them all at once.
> >So the cost of marking is just a (search cost for finding in-memory
> >page of the range + moving a page between LRU or from middle to tail)
> >It means we can move the cost time from mark/unmark to reclaim point.
> 
> So this general idea of moving a single page to represent the entire
> range has been mentioned before (I think Neil also suggested
> something similar).
> 
> But what happens if we are creating a large volatile range, most of
> which hasn't been accessed in a long time. However, the chosen flag
> page has been accessed recently.  In this case, we might end up
> swapping volatile pages to disk before we try to evict the volatile
> flag page.

Is your concern is that mostly-used flag page is in the middle of
LRU while rest of the pages in that range are in the tail of LRU?

If we use VMA flag, it shouldn't be a problem because VM can know
that the non-flag page is in volatile vma by VM_VOLATILE so VM can
discard the page without swapout.

If we use ez-reclaim LRU list, VM should peek ez-reclaim LRU list firsty
before looking up anon LRU list so it shouldn't be a problem, either.
Problem in this approach is only space shortage for new page flag in 32bit
machine. I had patch for making new room but lost it :(.
Anyway, if we really want it, I think I can make that patch again.

> 
> I haven't looked it up, but I worry that trying to purge the rest of
> the range would end up causing those pages to be swapped back in.
> 
> And Neil's suggestion of removing the rest of the pages from the
> LRUs (if I understood his suggestion correctly) to avoid swapping
> out those pages, unfortunately results in the same extra O(n) cost
> of touching all the pages in the range every time we change the
> volatility state.
> 
> 
> >>
> >>
> >>Specific Interface semantics:
> >>---------------------------------------------
> >>
> >>Here are some of the open question about how the user interface
> >>should look:
> [snip]
> >>fd based interfaces vs madvise:
> >>	In talking with Taras Glek, he pointed out that for his
> >>	needs, the fd based interface is a little annoying, as it
> >>	requires having to get access to tmpfs file and mmap it in,
> >>	then instead of just referencing a pointer to the data he
> >>	wants to mark volatile, he has to calculate the offset from
> >>	start of the mmap and pass those file offsets to the interface.
> >>	Instead he mentioned that using something like madvise would be
> >>	much nicer, since they could just pass a pointer to the object
> >>	in memory they want to make volatile and avoid the extra work.
> >>
> >>	I'm not opposed to adding an madvise interface for this as
> >>	well, but since we have a existing use case with Android's
> >>	ashmem, I want to make sure we support this existing behavior.
> >>	Specifically as with ashmem  applications can be sharing
> >>	these tmpfs fds, and so file-relative volatile ranges make
> >>	more sense if you need to coordinate what data is volatile
> >>	between two applications.
> >>
> >>	Also, while I agree that having an madvise interface for
> >>	volatile ranges would be nice, it does open up some more
> >>	complex implementation issues, since with files, there is a
> >>	fixed relationship between pages and the files' address_space
> >>	mapping, where you can't have pages shared between different
> >>	mappings. This makes it easy to hang the volatile-range tree
> >>	off of the mapping (well, indirectly via a hash table). With
> >>	general anonymous memory, pages can be shared between multiple
> >>	processes, and as far as I understand, don't have any grouping
> >>	structure we could use to determine if the page is in a
> >>	volatile range or not. We would also need to determine more
> >>	complex questions like: What are the semantics of volatility
> >>	with copy-on-write pages?  I'm hoping to investigate this
> >>	idea more deeply soon so I can be sure whatever is pushed has
> >>	a clear plan of how to address this idea. Further thoughts
> >>	here would be appreciated.
> >I like madvise interface because allocator can use it for memory pool.
> >If allocator has free memory which just return from application
> >he can mark it into volatile so VM can reclaim that pages without swapout
> >when memory pressure happens and it can unmark it before allocating.
> >It would be more effective rather than calling munmap or madvise(DONTNEED)
> >which those operations requires all page table operation and even vma
> >unlinking in case of munmap.
> >
> >For it, we can add new VMA flag VM_VOLATILE and we can use reverse mapping
> >for grouping structure. For COW semantics, I think we can discard volatile
> >page only if all vmas which share the page don't have VM_VOLATILE.
> 
> I'll look into this approach some more. I've got some concerns below.
> 
> 
> >
> >>It would really be great to get any thoughts on these issues, as they
> >>are higher-priority to me then diving into the details of how we
> >>implement this internally, which can shift over time.
> >>
> >>
> >>
> >>Implementation Considerations:
> >>---------------------------------------------
> [snip]
> >>* Purging order between volatile ranges:
> >>	Again, since it makes sense to purge all the complete
> >>	pages in a range at the same time, we need to consider the
> >>	subtle difference between the least-recently-used pages vs
> >>	least-recently-used ranges. A single range could contain very
> >>	frequently accessed data, as well as rarely accessed data.
> >>	One must also consider that the act of marking a range as
> >>	volatile may not actually touch the underlying pages. Thus
> >>	purging ranges based on a least-recently-used page may also
> >>	result in purging the most-recently used page.
> >>
> >>	Android addressed the purging order question by purging ranges
> >>	in the order they were marked volatile. Thus the oldest
> >>	volatile range is the first range to be purged. This works
> >>	well in the Android  model, as applications aren't supposed
> >>	to access volatile data, so the least-recently-marked-volatile
> >>	order maps well to the least-recently-used-range.
> >>
> >>	However, this assumption doesn't hold with the lazy SIGBUS
> >>	notification method, as pages in a volatile range may continue
> >>	to be accessed after the range is marked volatile.  So the
> >>	question as to what is the best order of purging volatile
> >>	ranges is definitely open.
> >>
> >>	Abstractly the ideal solution might be to evaluate the
> >>	most-recently used page in each range, and to purge the range
> >>	with the oldest recently-used-page, but I suspect this is
> >>	not something that could be calculated efficiently.
> >>
> >>	Additionally, in my conversations with Taras, he pointed out
> >>	that if we are using a one-application-at-a-time UI model,
> >>	it would be ideal to discourage purging volatile data used by
> >>	the current application, instead prioritizing volatile ranges
> >>	from applications that aren't active. However, I'm not sure
> >>	what mechanism could be used to prioritize range purging in
> >>	this fashion, especially considering volatile ranges can be
> >>	on data that is shared between applications.
> >My thought is that "let it be" without creating new LRU list or
> >deactivating volatile page to tail of LRU for early reclaiming.
> >It means volatile pages has same priorty with other normal pages.
> >Volatile doesn't mean "Early reclaim" but "we don't need to swap out
> >them for reclaiming" in my perception.
> 
> Right. Using your earlier terms, ez-reclaim instead early-reclaim.
> 
> Ideally I think we would want to have preference of purging volatile
> pages over laundering dirty pages under pressure, but maybe that's a

Yes. It does make sense. Under memory pressure, writing out of dirty pages
makes system's responsiveness very slow.

> separate vmscan issue/optimization for now?

I think so. After we settle down "What's the volatile page?",
we can optimize it for early reclaim of volatile pages than
dirty page's writeout. Normally, it's hard to reclaim anonymous pages
compared to file-backed pages so it can happen that writeout of dirty pages
for reclaim occurs although there are lots of volatile pages in anon lru list.
The one of idea is we can rotate volatile pages from inactive's tail to
inactive's head instead of active LRU list's head in aging model.
It can make volatile pages be reclaimable easily.

> 
> 
> 
> >In summary, the idea I am suggesting now if we select lazy SIGBUS is
> >following as,
> >
> >1) use madvise and VMA rmap with newly VM_VOLATILE page
> >2) mark
> >    just mark VM_VOLATILE in the VMA
> >3) treat volatile pages same with normal pages in POV aging
> >    (Of course, non swap system, we have to tweak VM for reclaimaing
> >     volatile pages, for example, we can move all volatile pages into
> >     inactive's tail when swapoff happens and VM peek tail of inactive
> >     LRU list without aging when memory pressure happens)
> >4) unmark
> >    just unmark VM_VOLATILE in the VMA and return error.
> 
> So to better grasp this, you're suggesting using the vma in-effect
> as the volatile range object? So if we mark a large area as
> volatile, we'll create a new vma with the (start, end), splitting
> the remaining portions of the old area into two non-volatile vmas?

Exactly.

> 
> The caveat for #3 seems a bit large.  Since on no-swap cases (which
> are standard for Android) that sounds like we're still having to
> migrate every page in the range to the end of the list (and move
> them to the head when they are marked non-volatile).  This seems to
> have the same O(n) performance issue.

Firstly, I still don't convinced that volatile pages should be reclaimed by
top prioirty., As I mentioned, it's just for representing "NOT necessary
swapout because it's volatile" so we don't need to migrate thoese pages
into tail of LRU, IMHO.
Instead, we need to do aging anon LRU list if the system has volatile pages.

If we don't want to do aging in anon LRU list and select model which we 
should reclaim volatile pages by top prioirty, we can move migration cost
from mark/unmark time to reclaim time.
I mean mark/unmark don't need to migrate the pages. Instead, VM can scan anon
LRU list to find volatile pages when memory pressure happens.
It's a tradeoff but normally reclaim path is inherently not fast path so
it wouldn't be a big problem. But if we want to select this model really,
I would like to make new LRU list than making VM more complicated.

Anyway, it's policy problem we should define about "volatile page".
Firstly, let's define reclaim policy of volatile page.

> 
> Also,  if I understand correctly, you could have a one page in
> multiple vmas, and the semantics for when we consider the page as
> volatile are awkward. When we want to purge/writeout, do we have to
> scan every vma the page is in to determine if its volatile?

Yes and VM have done already. Look at page_check_references.
> 
> Another thing I worry about with this, is that the since the vmas
> are per-mm, I don't see how volatile range could be shared, like
> with a tmpfs file between two applications, a usage model that
> Android's ashmem supports.

In your mail, you mentioned COW so that's why I said this model.
If application which has volatile VMA calls fork, pages in that range
could be shared by parent and child and rmap can manage them.

> 
> I'm likely missing something, as I'm unfamiliar so far with the rmap
> code, so I'll look into this some more (although I may not get too
> much time for it in the next month).  Andi Kleen tried something
> similar to your suggestion awhile back, but I'm just not confident
> that the per-mm vmas are the right place to manage this state (thus
> why I've used address_space mappings).
> 
> Thanks again for the feedback!

I will start to implement prototype for my idea and hope sending them
before traveling in next week.


> -john
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
