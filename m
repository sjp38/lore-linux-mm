Date: Fri, 3 Nov 2006 21:11:46 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0611031124340.15242@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0611032101190.25219@skynet.skynet.ie>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
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
 <Pine.LNX.4.64.0611031825420.25219@skynet.skynet.ie>
 <Pine.LNX.4.64.0611031124340.15242@schroedinger.engr.sgi.com>
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
>>> For now this would include reclaimable slabs?
>>
>> It could, but I don't. Currently, only network buffers, inode caches, buffer
>> heads and dentries are marked like this.
>
> inode cache and dentries basically contain most of the reclaimable
> slab caches.
>

Yes, and they are the largest amount of memory allocated by a significant 
margin. When they are clustered together, cache shrinking tends to free up 
contiguous blocks of pages.

>>> They are reclaimable with a
>>> huge effort and there may be pinned objects that we cannot move. Isnt this
>>> more another case of unmovable?
>>
>> Probably, they would currently be treated as unmovable.
>
> So you really do not currently need that section? If you drop the section
> then we have the same distinction that we wouild need for memory hotplug.
>

You mean, drop the section dealing with clustering the cache and dentries? 
That section is needed. Without it, success rates at succeeding high order 
allocations is lower and the mechanism breaks down after a few hours 
uptime.

>>> Note that memory for a loaded module is allocated via vmalloc, mapped via
>>> a page table (init_mm) and thus memory is remappable. We will likely be
>>> able to move those.
>>>
>>
>> It's not just a case of updating init_mm. You would also need to tear down the
>> vmalloc area for every current running process in the system in case they had
>> faulted within that module. That would be pretty entertaining.
>
> vmalloc areas are not process specific
> and this works just fine within the
> kernel. Eeek... remap_vmalloc_range() maps into user space. Need to have a
> list it seems to be able to also update those ptes.
>

>> Once again, I am not adverse to writing such a defragment mechanism, but I see
>> anti-frag as it currently stands as a prequisitie for a defragmentation
>> mechanism having a decent success rate.
>
> What you call anti-frag is really a mechanism to separate two different
> kinds of allocations that may be useful for multiple purposes not only
> anti-frag.
>

Well, currently three types of allocations. It's worth separating out 
really unmovable pages and kernel allocations that can be reclaimed/moved 
in some fashion.

Is it the name anti-frag you have a problem with? If so, what would you 
suggest calling it?

>> Defragmentation on it's own would be insufficient for hugepage allocations
>> because of unmovable pages dotted around the system. We know this because if
>> you reclaim everything possible in the system, you still are unlikely to be
>> able to grow the hugepage pool. If reclaiming everything doesn't give you huge
>> pages, shuffling the same pages around the system won't improve the situation
>
> It all depends on the movability of pages. If unmovable pages are
> sufficiently rare then this will work.
>

They are common enough that they get spread throughout memory unless they 
are clustered. If that was not the case, the hugepage pool would be a lot 
easier to grow after a decent amount of uptime.

> I think we need something like what is done here via anti-frag but I wish
> it would be more generic and not solely rely on reclaim to get pages freed
> up.
>

How could it have been made more generic? Fundamentally, all we are doing 
at the moment is using the freelists to cluster types of pages together. 
We only depend on reclaim now. If we get the clustering part done, I can 
start working on the page migration part.

> Also the duplication of the page struct caches worries me because it
> reduces the hit rate.

do you mean the per-cpu caches? If so, without clustering in the per-cpu 
caches, unmovable allocations would "leak" into blocks used for movable 
allocations.

> Removing the intermediate type would reduce the page
> caches to 2.

And significantly reduce the effectiveness of the clustering in the 
process.

> And maybe we do not need caches for unreclaimable/unmovable
> pages? slab already does its own buffering there.
>

That is true. If it is a problem, what could be done is have a per-cpu 
cache for movable and unmovable allocations. Then have the __GFP_KERNRCLM 
allocations bypass the per-cpu allocator altogether and go straight to the 
buddy allocator.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
