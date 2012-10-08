Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 423136B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 02:21:13 -0400 (EDT)
Date: Mon, 8 Oct 2012 15:25:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] Volatile Ranges (v7) & Lots of words
Message-ID: <20121008062517.GA13817@bbox>
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi John,

On Fri, Sep 28, 2012 at 11:16:30PM -0400, John Stultz wrote:
> 
> After Kernel Summit and Plumbers, I wanted to consider all the various
> side-discussions and try to summarize my current thoughts here along
> with sending out my current implementation for review.
> 
> Also: I'm going on four weeks of paternity leave in the very near
> (but non-deterministic) future. So while I hope I still have time
> for some discussion, I may have to deal with fussier complaints
> then yours. :)  In any case, you'll have more time to chew on
> the idea and come up with amazing suggestions. :)
> 
> 
> General Interface semantics:
> ----------------------------------------------
> 
> The high level interface I've been pushing has so far stayed fairly
> consistent:
> 
> Application marks a range of data as volatile. Volatile data may
> be purged at any time. Accessing volatile data is undefined, so
> applications should not do so. If the application wants to access
> data in a volatile range, it should mark it as non-volatile. If any
> of the pages in the range being marked non-volatile had been purged,
> the kernel will return an error, notifying the application that the
> data was lost.
> 
> But one interesting new tweak on this design, suggested by the Taras
> Glek and others at Mozilla, is as follows:
> 
> Instead of leaving volatile data access as being undefined , when
> accessing volatile data, either the data expected will be returned
> if it has not been purged, or the application will get a SIGBUS when
> it accesses volatile data that has been purged.
> 
> Everything else remains the same (error on marking non-volatile
> if data was purged, etc). This model allows applications to avoid
> having to unmark volatile data when it wants to access it, then
> immediately re-mark it as volatile when its done. It is in effect

Just out of curiosity.
Why should application remark it as volatile again?
It have been already volatile range and application doesn't receive
any signal while it uses that range. So I think it doesn't need to
remark.


> "lazy" with its marking, allowing the kernel to hit it with a signal
> when it gets unlucky and touches purged data. From the signal handler,
> the application can note the address it faulted on, unmark the range,
> and regenerate the needed data before returning to execution.

I like this model if plumbers really want it.

> 
> Since this approach avoids the more explicit unmark/access/mark
> pattern, it avoids the extra overhead required to ensure data is
> non-volatile before being accessed.

I have an idea to reduce the overhead.
See below.

> 
> However, If applications don't want to deal with handling the
> sigbus, they can use the more straightforward (but more costly)
> unmark/access/mark pattern in the same way as my earlier proposals.
> 
> This allows folks to balance the cost vs complexity in their
> application appropriately.
> 
> So that's a general overview of how the idea I'm proposing could
> be used.

My idea is that we don't need to move all pages in the range
to tail of LRU or new LRU list. Just move a page in the range
into tail of LRU or new LRU list. And when reclaimer start to find
victim page, it can know this page is volatile by something
(ex, if we use new LRU list, we can know it easily, Otherwise,
we can use VMA's new flag - VM_VOLATILE and we can know it easily
by page_check_references's tweak) and isolate all pages of the range
in middle of LRU list and reclaim them all at once.
So the cost of marking is just a (search cost for finding in-memory
page of the range + moving a page between LRU or from middle to tail)
It means we can move the cost time from mark/unmark to reclaim point.

> 
> 
> 
> Specific Interface semantics:
> ---------------------------------------------
> 
> Here are some of the open question about how the user interface
> should look:
> 
> fadvise vs fallocate:
> 
> 	So while originally I used fadvise, currently my
> 	implementation uses fallocate(fd, FALLOC_FL_MARK_VOLATILE,
> 	start, len) to mark a range as volatile and fallocate(fd,
> 	FALLOC_FL_UNMARK_VOLATILE, start, len) to unmark ranges.
> 
> 	During kernel summit, the question was brought up if fallocate
> 	was really the right interface to be using, and if fadvise
> 	would be better. To me fadvise makes a little more sense,
> 	but earlier it was pointed out that marking data ranges as
> 	volatile could also be seen as a type of cancellable and lazy
> 	hole-punching, so from that perspective fallocate might make
> 	more sense.  This is still an open question and I'd appreciate
> 	further input here.
> 
> tmpfs vs non-shmem filesystems:
> 	Android's ashmem primarily provides a way to get unlinked
> 	tmpfs fds that can be shared between applications. Its
> 	just an additional feature that those pages can "unpinned"
> 	or marked volatile in my terminology. Thus in implementing
> 	volatile ranges, I've focused on getting it to work on tmpfs
> 	file descriptors.  However, there has been some interest in
> 	using volatile ranges with more traditional filesystems. The
> 	semantics for how volatile range purging would work on a
> 	real filesystem are not well established, and I can't say I
> 	understand the utility quite yet, but there may be a case for
> 	having data that you know won't be committed to disk until it
> 	is marked as non-volatile.  However, returning an EINVAL on
> 	non-tmpfs filesystems until such a use is established should
> 	be fine.
> 
> fd based interfaces vs madvise:
> 	In talking with Taras Glek, he pointed out that for his
> 	needs, the fd based interface is a little annoying, as it
> 	requires having to get access to tmpfs file and mmap it in,
> 	then instead of just referencing a pointer to the data he
> 	wants to mark volatile, he has to calculate the offset from
> 	start of the mmap and pass those file offsets to the interface.
> 	Instead he mentioned that using something like madvise would be
> 	much nicer, since they could just pass a pointer to the object
> 	in memory they want to make volatile and avoid the extra work.
> 
> 	I'm not opposed to adding an madvise interface for this as
> 	well, but since we have a existing use case with Android's
> 	ashmem, I want to make sure we support this existing behavior.
> 	Specifically as with ashmem  applications can be sharing
> 	these tmpfs fds, and so file-relative volatile ranges make
> 	more sense if you need to coordinate what data is volatile
> 	between two applications.
> 
> 	Also, while I agree that having an madvise interface for
> 	volatile ranges would be nice, it does open up some more
> 	complex implementation issues, since with files, there is a
> 	fixed relationship between pages and the files' address_space
> 	mapping, where you can't have pages shared between different
> 	mappings. This makes it easy to hang the volatile-range tree
> 	off of the mapping (well, indirectly via a hash table). With
> 	general anonymous memory, pages can be shared between multiple
> 	processes, and as far as I understand, don't have any grouping
> 	structure we could use to determine if the page is in a
> 	volatile range or not. We would also need to determine more
> 	complex questions like: What are the semantics of volatility
> 	with copy-on-write pages?  I'm hoping to investigate this
> 	idea more deeply soon so I can be sure whatever is pushed has
> 	a clear plan of how to address this idea. Further thoughts
> 	here would be appreciated.

I like madvise interface because allocator can use it for memory pool.
If allocator has free memory which just return from application
he can mark it into volatile so VM can reclaim that pages without swapout
when memory pressure happens and it can unmark it before allocating.
It would be more effective rather than calling munmap or madvise(DONTNEED)
which those operations requires all page table operation and even vma
unlinking in case of munmap.

For it, we can add new VMA flag VM_VOLATILE and we can use reverse mapping
for grouping structure. For COW semantics, I think we can discard volatile
page only if all vmas which share the page don't have VM_VOLATILE.
> 
> 
> It would really be great to get any thoughts on these issues, as they
> are higher-priority to me then diving into the details of how we
> implement this internally, which can shift over time.
> 
> 
> 
> Implementation Considerations:
> ---------------------------------------------
> 
> How best to manage volatile ranges internally in the kernel is still
> an open question.
> 
> With this patch set, I'm really wanting to provide a proof of concept
> of the general interface semantics above. This allows applications to
> play with the idea and validate that it would work for them. Allowing
> further discussion to continue on how to best implement or best allow
> the implementation to evolve in the kernel.
> 
> Even so, I'm very interested in any discussion about how to manage
> volatile ranges optimally.
> 
> Before describing the different management approaches I've tried,
> there are some abstract properties and considerations that need to
> be kept in mind:
> 
> * Range-granular Purging:
> 	Since volatile ranges can be reclaimed at any time, the
> 	question of how the kernel should reclaim volatile data
> 	needs to be addressed.	When a large data range  is marked
> 	as volatile, if any single page in that range is purged,
> 	the application will get an error when it marks the range
> 	as non-volatile.  Thus when any single page in a range
> 	is purged, the "value" of the entire range is destroyed.
> 	Because of this property, it makes most sense to purge the
> 	entire range together.
> 
> 
> * Coalescing of adjacent volatile ranges:
> 	With volatile ranges, any overlapping ranges are always
> 	coalesced. However, there is an open question of what to
> 	do with neighboring ranges. With Android's approach, any
> 	neighboring ranges were coalesced into one range.  I've since
> 	tweaked this so that adjacent ranges are coalesced only if
> 	both have not yet been purged (or both are already purged).
> 	This avoids throwing away fine data just because its next
> 	to data that has already been tossed.  Not coalescing
> 	non-overlapping ranges is also an option I've considered,
> 	as it better follows the applications wishes, since as
> 	the application is providing these non-overlapping ranges
> 	separately, we should probably also purge them separately.
> 	The one complication here is that for userlands-sake, we
> 	manage volatile ranges at a byte level. So if an application
> 	marks one an a half pages of data as volatile, we only purge
> 	pages that are entirely volatile. This avoids accidentally
> 	purging non-volatile data on the rest of the page.  However,
> 	if an array of sub-page sized data is marked volatile one by
> 	one, coalescing the ranges allows us to purge a page that
> 	consists entirely of multiple volatile ranges.	So for now
> 	I'm still coalescing assuming the neighbors are both unpurged,
> 	but this behavior is open to being tweaked.
> 
> 
> * Purging order between volatile ranges:
> 	Again, since it makes sense to purge all the complete
> 	pages in a range at the same time, we need to consider the
> 	subtle difference between the least-recently-used pages vs
> 	least-recently-used ranges. A single range could contain very
> 	frequently accessed data, as well as rarely accessed data.
> 	One must also consider that the act of marking a range as
> 	volatile may not actually touch the underlying pages. Thus
> 	purging ranges based on a least-recently-used page may also
> 	result in purging the most-recently used page.
> 
> 	Android addressed the purging order question by purging ranges
> 	in the order they were marked volatile. Thus the oldest
> 	volatile range is the first range to be purged. This works
> 	well in the Android  model, as applications aren't supposed
> 	to access volatile data, so the least-recently-marked-volatile
> 	order maps well to the least-recently-used-range.
> 
> 	However, this assumption doesn't hold with the lazy SIGBUS
> 	notification method, as pages in a volatile range may continue
> 	to be accessed after the range is marked volatile.  So the
> 	question as to what is the best order of purging volatile
> 	ranges is definitely open.
> 
> 	Abstractly the ideal solution might be to evaluate the
> 	most-recently used page in each range, and to purge the range
> 	with the oldest recently-used-page, but I suspect this is
> 	not something that could be calculated efficiently.
> 
> 	Additionally, in my conversations with Taras, he pointed out
> 	that if we are using a one-application-at-a-time UI model,
> 	it would be ideal to discourage purging volatile data used by
> 	the current application, instead prioritizing volatile ranges
> 	from applications that aren't active. However, I'm not sure
> 	what mechanism could be used to prioritize range purging in
> 	this fashion, especially considering volatile ranges can be
> 	on data that is shared between applications.

My thought is that "let it be" without creating new LRU list or
deactivating volatile page to tail of LRU for early reclaiming.
It means volatile pages has same priorty with other normal pages.
Volatile doesn't mean "Early reclaim" but "we don't need to swap out
them for reclaiming" in my perception.

> 
> 
> * Volatile range purging order relative to non-volatile pages:
> 	Initially I had proposed that since applications had offered
> 	data up as unused, volatile ranges should be purged before we
> 	try to free any other pages in the system.  At Plumbers, Andrea
> 	pointed out that this doesn't make much sense, as there may be
> 	inactive file pages from some streaming file data which are not
> 	going to be used any time soon, and would be a better candidate
> 	to free then an application's volatile pages. This sounded
> 	quite reasonable, so its likely we need to balance volatile
> 	purging with freeing other pages in the system. However, I do
> 	think it is advantageous to purge volatile pages before we
> 	free any dirty pages that must be laundered, as part of the
> 	goal of volatile pages is to avoid extra io. Although from
> 	my reading of shrink_page_list in vmscan.c I'm not sure I see
> 	if/how we prioritize freeing clean pages prior to dirty ones.
> 
> 
> So with that background covered, on to discussing actual
> implementations.
> 
> Implementation Details:
> ---------------------------------------------
> 
> There is two rough approaches that I have tried so far
> 
> 1) Managing volatile range objects, in a tree or list, which are then
> purged using a shrinker
> 
> 2) Page based management, where pages marked volatile are moved to
> a new LRU list and are purged from there.
> 
> 
> 
> 1) This patchset is of the the shrinker-based approach. In many ways it
> is simpler, but it does have a few drawbacks.  Basically when marking a
> range as volatile, we create a range object, and add it to an rbtree.
> This allows us to be able to quickly find ranges, given an address in
> the file.  We also add each range object to the tail of a  filesystem
> global linked list, which acts as an LRU allowing us to quickly find
> the least recently created volatile range. We then use a shrinker
> callback to trigger purging, where we'll select the range on the head
> of the LRU list, purge the data, mark the range object as purged,
> and remove it from the lru list.
> 
> This allows fairly efficient behavior, as marking and unmarking
> a range are both O(logn) operation with respect to the number of
> ranges, to insert and remove from the tree.  Purging the range is
> also O(1) to select the range, and we purge the entire range in
> least-recently-marked-volatile order.
> 
> The drawbacks with this approach is that it uses a shrinker, thus it is
> numa un-aware. We track the virtual address of the pages in the file,
> so we don't have a sense of what physical pages we're using, nor on
> which node those pages may be on. So its possible on a multi-node
> system that when one node was under pressure, we'd purge volatile
> ranges that are all on a different node, in effect throwing data away
> without helping anything. This is clearly non-ideal for numa systems.
> 
> One idea I discussed with Michel Lespinasse is that this might be
> something we could improve by providing the shrinker some node context,
> then keep track in the range  what node their first page is on. That
> way we would be sure to at least free up one page on the node under
> pressure when purging that range.
> 
> 
> 2) The second approach, which was more page based, was also tried. In
> this case when we marked a range as volatile, the pages in that range
> were moved to a new  lru list LRU _VOLATILE in vmscan.c.  This provided
> a page lru list that could be used to free pages before looking at
> the LRU_INACTIVE_FILE/ANONYMOUS lists.
> 
> This integrates the feature deeper in the mm code, which is nice,
> especially as we have an LRU_VOLATILE list for each numa node. Thus
> under pressure we won't purge ranges that are entirely on a different
> node, as is possible with the other approach.
> 
> However, this approach is more costly.	When marking a range
> as volatile, we have to migrate every page in that range to the
> LRU_VOLATILE list, and similarly on unmarking we have to move each
> page back. This ends up being O(n) with respect to the number of
> pages in the range we're marking or unmarking. Similarly when purging,
> we let the scanning code select a page off the lru, then we have to
> map it back to the volatile range so we can purge the entire range,
> making it a more expensive O(logn),  with respect to the number of
> ranges, operation.
> 
> This is a particular concern as applications that want to mark and
> unmark data as volatile with fine granularity will likely be calling
> these operations frequently, adding quite a bit of overhead. This
> makes it less likely that applications will choose to volunteer data
> as volatile to the system.
> 
> However, with the new lazy SIGBUS notification, applications using
> the SIGBUS method would avoid having to mark and unmark data when
> accessing it, so this overhead may be less of a concern. However, for
> cases where applications don't want to deal with the SIGBUS and would
> rather have the more deterministic behavior of the unmark/access/mark
> pattern, the performance is a concern.
> 
> Additionally, there may be ways to defer and batch the page migration
> so that applications don't suffer the extra cost, but this solution
> may be limited or could  cause some strange behavior, as we can't
> defer the unmark method, as we don't want pages to be purged after
> the application thinks they were unmarked.
> 

In summary, the idea I am suggesting now if we select lazy SIGBUS is
following as,

1) use madvise and VMA rmap with newly VM_VOLATILE page
2) mark
   just mark VM_VOLATILE in the VMA
3) treat volatile pages same with normal pages in POV aging
   (Of course, non swap system, we have to tweak VM for reclaimaing
    volatile pages, for example, we can move all volatile pages into
    inactive's tail when swapoff happens and VM peek tail of inactive
    LRU list without aging when memory pressure happens)
4) unmark
   just unmark VM_VOLATILE in the VMA and return error.

> 
> Whew, that was long...

Thanks for really good summary, John!

> 
> Anyway, if you got this far and are still interested, I'd be greatly
> appreciate  hearing of any other suggested implementations, or ways
> around the drawbacks of the already tried approaches.
> 
> thanks
> -john
> 
> 
> For this v7 patchset revision the changes are as follows:
> * Dropped the LRU_VOLATILE approach for now so we can focus on
>   getting the general interface semantics agreed upon
> * Converted to using byte ranges rather then page ranges to make
>   userland's life easier.	
> * Add SIGBUS on purged page access behavior, allowing for access
>   of volatile data without having to unmark it.
> 
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Andrea Righi <andrea@betterlinux.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> 
> 
> John Stultz (3):
>   [RFC] Add volatile range management code
>   [RFC] tmpfs: Add FALLOC_FL_MARK_VOLATILE/UNMARK_VOLATILE handlers
>   [RFC] ashmem: Convert ashmem to use volatile ranges
> 
>  drivers/staging/android/ashmem.c |  335 +---------------------
>  fs/open.c                        |    3 +-
>  include/linux/falloc.h           |    7 +-
>  include/linux/volatile.h         |   46 +++
>  mm/Makefile                      |    2 +-
>  mm/shmem.c                       |  120 ++++++++
>  mm/volatile.c                    |  580 ++++++++++++++++++++++++++++++++++++++
>  7 files changed, 763 insertions(+), 330 deletions(-)
>  create mode 100644 include/linux/volatile.h
>  create mode 100644 mm/volatile.c
> 
> -- 
> 1.7.9.5
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
