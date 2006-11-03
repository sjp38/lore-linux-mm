Date: Fri, 3 Nov 2006 19:06:09 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0611030952530.14741@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0611031825420.25219@skynet.skynet.ie>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
 <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
 <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
 <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie>
 <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
 <454A2CE5.6080003@shadowen.org> <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021442210.10447@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
 <Pine.LNX.4.64.0611030952530.14741@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Nov 2006, Christoph Lameter wrote:

> On Fri, 3 Nov 2006, Mel Gorman wrote:
>
>> I know, this sort of thing would have to be written into page migration before
>> defrag for high-order allocations was developed. Even then, defrag needs to
>> sit on top of something like anti-frag to get teh clustering of movable pages.
>
> Hmmm... The disk defraggers are capable of defragmenting around pinned
> blocks and this seems to be a similar.

Not similar enough. Disk defragmentation aims at having files as 
contiguous as possible on the filesystem. if they are not contiguous, it 
doesn't matter to functionality but performance degrades slightly.

For allocation of hugepages, the physical pages must be contiguous and 
they must be aligned. If there is one unmovable or unreclaimable page in 
there, that block is unusable for a hugepage. We can defragment around it 
all right, but the resulting block is still not usable. It's not the same 
as disk defragmentation.

Defragmentation on it's own is not enough. The clustering based on 
reclaimability/movability is still required and that is what anti-frag 
provides.

> This only works if the number of
> unmovable objects is small compared to the movable objects otherwise we
> may need this sorting.  For other reasons discussed before (memory unplug,
> node unplug) I think it would be necessary to have this separation
> between movable and unmovable pages.
>

If there is only one unmovable block per MAX_ORDER_NR_PAGES in the system, 
you can defrag as much as you like and hugepage allocations will still 
fail. Similar for hot unplug.

> I can add a migrate_page_table_page() function? The migrate_pages()
> function is only capable of migrating user space pages since it relies on
> being able to take pages off the LRU. At some point we need to
> distinguishthe type of page and call the appropriate migration function
> for the various page types.
>

If such a function existed, then page table pages could be placed beside 
"reclaimable" pages and the block could be migrated. However, the 
clustering would still have be needed, be it based on reclaimability or 
movability (which in many cases is the same thing)

> int migrate_page_table_page(struct page *new, struct page *new);
> ?
>
>> Reclaimable - These are kernel allocations for caches that are
>>         reclaimable or allocations that are known to be very short-lived.
>> 	These allocations are marked __GFP_RECLAIMABLE
>
> For now this would include reclaimable slabs?

It could, but I don't. Currently, only network buffers, inode caches, 
buffer heads and dentries are marked like this.

> They are reclaimable with a
> huge effort and there may be pinned objects that we cannot move. Isnt this
> more another case of unmovable?

Probably, they would currently be treated as unmovable.

> Or can we tolerate the objects that cannot
> be moved and classify this as movable (with the understanding that we may
> have to do expensive slab reclaim (up to dropping all reclaimable slabs)
> in order to get there).
>

There is nothing stopping such marking taking place, but I wouldn't if I 
thought that reclaiming or moving them was that expensive.

>> Non-Movable - These are pages that are allocated by the kernel that
>>         are not trivially reclaimed. For example, the memory allocated for a
>>         loaded module would be in this category. By default, allocations are
>>         considered to be of this type
>> 	These are allocations that are not marked otherwise
>
> Ok.
>
> Note that memory for a loaded module is allocated via vmalloc, mapped via
> a page table (init_mm) and thus memory is remappable. We will likely be
> able to move those.
>

It's not just a case of updating init_mm. You would also need to tear down 
the vmalloc area for every current running process in the system in case 
they had faulted within that module. That would be pretty entertaining.

>> So, right now, page tables would not be marked __GFP_MOVABLE, but they would
>> be later when defrag was developed. Would that be any better?
>
> Isnt this is still doing reclaim instead of defragmentation?

Not necessarily reclaim. Currently we reclaim. Under memory pressure, we 
may still reclaim. However, if there was enough free memory (due to 
min_free_kbytes been set to a higher value for example), then we could 
migrate instead of reclaim to satisfy a high-order allocation. The page 
migration stuff is already there so it's clearly possible.

Once again, I am not adverse to writing such a defragment mechanism, but I 
see anti-frag as it currently stands as a prequisitie for a 
defragmentation mechanism having a decent success rate.

> Maybe it
> will work but I am not not sure about the performance impact. We
> would have to read pages back in from swap or disk?
>
> The problem that we have is that one cannot higher order pages since 
> memory is fragmented. Maybe what would initially be sufficient is that a 
> failing allocation of a higher order page lead to defrag occurring until 
> pages of suffiecient size have been created and then the allocation can 
> be satisfied.
>

Defragmentation on it's own would be insufficient for hugepage allocations 
because of unmovable pages dotted around the system. We know this because 
if you reclaim everything possible in the system, you still are unlikely 
to be able to grow the hugepage pool. If reclaiming everything doesn't 
give you huge pages, shuffling the same pages around the system won't 
improve the situation any either.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
