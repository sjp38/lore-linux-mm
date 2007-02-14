Message-ID: <45D37369.8060500@redhat.com>
Date: Wed, 14 Feb 2007 15:39:05 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [RFC] page replacement requirements
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Over the last few years, page replacement problems in the Linux VM
have been getting resolved as they cropped up, but sometimes the same
kind of bug has been getting fixed and reincroduced over and over
again.

This has convinced me that it is time to take a look at the actual
requirements of a page replacement mechanism, so we can try to fix
things without reintroducing other bugs.  Understanding what is going
on should also help us deal better with really large memory systems.

I have started writing down the list of requirements and explanations
on the linux-mm wiki.  I will update this page as more requirements
come up during this discussion.  It should also be easier to read than
the cut'n'paste below the URL, so you'll probably want to read the page:

	http://linux-mm.org/PageReplacementRequirements


Requirements shortlist

    1. Must select good pages for eviction.
    2. Must not submit too much I/O at once. Submitting too much I/O at 
once can kill latency and even lead to deadlocks when bounce buffers 
(highmem) are involved. Note that submitting sequential I/O is a good thing.
    3. Must be able to efficiently evict the pages on which pageout I/O 
completed.
    4. Must be able to deal with multiple memory zones efficiently.
    5. Must always have some pages ready to evict. Scanning 32GB of 
"recently referenced" memory is not an option when memory gets tight.
    6. Must be able to process pages in batches, to reduce SMP lock 
contention.
    7. A bad decision should have bounded consequences. The VM needs to 
be resilient against its own heuristics going bad.
    8. Low overhead of execution.

Pageout selection

Scan Resistant

A large sequential scan (eg. daily backup) should not be able to push 
the working set out of memory.

Effective as second level cache

The only hits in a second level cache are the cache misses from the 
primary cache. This means that the inter-reference distances on eg. a 
file server may be very large. A page replacement algorithm should be 
able to detect and cache the most frequently accessed pages even in this 
case.

Recency vs. Frequency

Which of the two is more important depends entirely on the workload. It 
would be nice if the pageout selection algorithm would adapt automatically.

Limited pageout I/O

Pageout I/O is submitted as pages hit the end of the LRU list. Dirty 
pages are then rotated back onto the start of inactive list. Not only 
does this disturb LRU order, but it can result in hundreds of megabytes 
worth of small I/Os being submitted at once. This kills I/O latency and 
can lead to deadlocks on 32 bit systems with highmem, where the kernel 
needs to allocate bounce buffers and/or buffer heads from low memory.

Reclaim after I/O

The rotate_reclaimable_page() mechanism in the current 2.6 kernels fixes 
part of the problem by moving pages back to the end of the inactive list 
when IO finishes, but there is no effective mechanism to limit how much 
I/O is submitted at once.

The importance of sequential I/O

Since most disk writes are seek time dominated, the VM should aim to do 
sequential/clustered writeouts, as well as refrain from submitting too 
much pageout I/O at once. If the VM wants to free 10MB of memory, it 
should not submit 500MB worth of I/O, just because there are that many 
pages on the inactive list.

Asynchronous Page-Out

The page-out operation is not synchonous. Dirty pages that are selected 
for reclaim are not directly freed, writeback is started against them 
(PG_writeback is set) and they are fed back to the resident list. When 
on completion of the write to their backing-store the reference bit is 
still unset a callback is invoked to place them so that they are 
immediate candidates for reclaim again (rotate_reclaimable_page).

When scanning for reclaimable pages make sure you are not stuck on a 
writeback saturated list.

Multiple Zones

Unlike most, linux has multiple memory zones; that is, memory is not 
viewed as one big continuous section. There are specific sections of 
memory where it is desirable to have the ability to free pages in. Think 
of NUMA topologies or DMA engines that cannot operate on the full 
address space. Hence memory is viewed in multiple zones.

For traditional page replacement algorithms this is not a big issue 
since we just implement per zone page replacement; eg. a CLOCK per zone. 
However with the introduction of non-resident page state tracking in the 
recent algorithms this does become a problem. Since a page can fault 
into a different zone than where it came from, the non-resident page 
state tracking needs to be over all memory, not just a single zone.

This makes for per zone resident page tracking and global non-resident 
page tracking; this separation is not present in several proposed 
algorithms and hence makes implementing them a challenge.

Background aging

After a day of no memory shortage, it is possible for a system to end up 
with most pages having the referenced bit set. This has a number of bad 
effects:

     * Essentially a random page will be evicted.
     * The system may have to scan through hundreds of thousands of 
pages in order to find a page to be evicted.

To avoid these situations, the system should always have some pages on 
hand that are good candidates to be evicted. Light background aging of 
pages may be one solution to get the desired result. There may be others.

Batch processing

To reduce SMP lock contention on the pageout list locks, the algorithms 
must allow for pages to be moved around in batches instead of 
individually. This is relatively easy to satisfy.

Resilience

Unlike many other subsystems, which are optimized for the common case, 
the VM also needs to be optimized for the worst case. This is because 
the latency difference between RAM and disk can be tens of millions of 
CPU cycles.

All heuristics will do the wrong thing occasionally, and the VM is no 
exception. However, there should be mechanisms (probably feedback loops) 
to stop the VM from blindly continuing down the wrong path and turning a 
single mistake into a worst case scenario.

Examples of worst case scenarios could be:

     * LRU eviction on a circularly accessed working set slightly larger 
than memory.
     * Readahead window thrashing.
     * Doing small I/Os through the pageout path, instead of larger 
contiguous I/Os through the inode writeback path.

One bad decision by the VM should never lead to the system going down 
the drain.

Low overhead of execution

Evicting the wrong pages can be extremely costly, reducing system 
performance by orders of magnitude. However, the VM also cannot go 
overboard in trying to analyze what is going on and selecting pages to 
evict. The algorithms used for pageout selection cannot scan the page 
structs and page tables too often, otherwise they will end up wasting 
too much CPU. This is especially true when thinking about large memory 
systems, 128GB RAM is not that strange any more in 2007, and 1TB systems 
will probably be common within a few years.
Expensive Referenced Check

Because multiple page table entries can refer to the same physical page 
checking the referenced bit is not as cheap as most algorithms assume it 
is (rmap). Hence we need to do the check without holding most locks. 
This suggests a batched approach to minimize the lock/unlock frequency. 
Modifying algorithms to do this is not usualy very hard.

Other considerations

Insert Referenced

Since we fault in pages it is per definition that the page is going to 
be used (readahead?) right after we switch back to userspace. Hence we 
effectifly insert page with their reference bit set. Since most 
algorithms assume we insert pages with their reference bit unset the 
need arises to modify the algorithms so that pages are not promoted on 
their first reference (use-once).

Use once

The use once algorithm currently in the 2.6 kernel does the wrong thing 
in some use cases. For example, rsync can briefly touch the same pages 
twice, and then never again. In this case, the pages should not get 
promoted to the active list.

For page replacement purposes "referenced twice" should mean that the 
page was referenced in two time slots during which the VM scanned the 
page referenced bit, so "referenced twice" is counted the same for page 
tables as it is for page structs.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
