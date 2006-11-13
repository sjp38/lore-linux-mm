Date: Mon, 13 Nov 2006 21:08:46 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0611071629040.11212@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0611091425490.846@skynet.skynet.ie>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
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
 <Pine.LNX.4.64.0611032101190.25219@skynet.skynet.ie>
 <Pine.LNX.4.64.0611031329480.16397@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611071629040.11212@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Nov 2006, Mel Gorman wrote:

>> 
>> Right. Maybe we can get away with leaving the pageset cpu caches
>> untouched? On our largest systems with 1k nodes 4k cpus we currently have
>> 4 zones * 4096 cpus * 1024 nodes = 16 million pagesets. Each of those has
>> hot and cold yielding 32 million lists. Now we going triplicate that to
>> 192 mio lists and we also increase the size of the structure.
>> 
>
> I can see the problem with expanding the per-cpu structures. I'll check out 
> what happens when per-cpu caches are only used for movable allocations. This 
> is the way things were in an earlier version of anti-fragmentation but I do 
> not have figures any more.
>

This was harder to get right than expected.

Using the per-cpu allocator for only movable allocations led to 
considerable regressions - 2.5% on PPC64 for kbuild and the x86_64 figures 
were showing close to 2% regression. AIM9 results showed significant 
regressions in places, even on machines that normally give reliable AIM9 
results. Non-movable allocations are frequent enough that forcing them to 
not use the per-cpu allocator has a noticable impact.

However, I think I have a reasonable compromise. Pages on the per-cpu 
lists are not using page->private so the type of page can be stored in 
that field (i.e. Movable, Reclaimable, Unmovable). On allocation, the list 
is searched and the hotest page of the appropriate type is used, else 
rmqueue_bulk() is called. This stops the per-cpu allocator from "leaking" 
pages into undesirable areas without requiring larger per-cpu structures.

As care is taken to preserve the hotness of the pages and the page 
structures tend to be cache hot anyway, regressions should be very minor 
if detectable overall at all. What I've found in initial tests is that 
slight increases in time spent in the system are offset by reduced time 
spent in userspace so results tend to be within 0.2% of each other.

I'll rebase the patches to the latest -mm tree, run a set of tests to make 
sure it's working as expected and post a new set of patches

>> With the code currently in 2.6.19 we go from 4 to 2 zones. So we have only
>> 16 million pagesets. With the optional DMA in mm we got from 16 to 8
>> million pagesets. This effectively undoes the optimizations done in .19
>> .20.
>> 
>
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
