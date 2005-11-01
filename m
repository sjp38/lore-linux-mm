Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA1KVmuW002594
	for <linux-mm@kvack.org>; Tue, 1 Nov 2005 15:31:48 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jA1KWpDC527962
	for <linux-mm@kvack.org>; Tue, 1 Nov 2005 13:32:51 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jA1KVlPY016654
	for <linux-mm@kvack.org>; Tue, 1 Nov 2005 13:31:48 -0700
Message-ID: <4367D0AD.3070900@austin.ibm.com>
Date: Tue, 01 Nov 2005 14:31:41 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030235440.6938a0e9.akpm@osdl.org> <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu> <200511011223.43841.rob@landley.net>
In-Reply-To: <200511011223.43841.rob@landley.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rob Landley <rob@landley.net>
Cc: Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

>>>The set of patches do fix a lot and make a strong start at addressing
>>>the fragmentation problem, just not 100% of the way. [...]
>>
>>do you have an expectation to be able to solve the 'fragmentation
>>problem', all the time, in a 100% way, now or in the future?
> 
> 
> Considering anybody can allocate memory and never release it, _any_ 100% 
> solution is going to require migrating existing pages, regardless of 
> allocation strategy.
> 

Three issues here.  Fragmentation of memory in general, fragmentation of usage, 
and being able to have 100% success rate at removing memory.

We will never be able to have 100% contiguous memory with no fragmentation. 
Ever.  Certainly not while we have non-movable pieces of memory.  Even if we 
could move every piece of memory it would be impractical.  What these patches do 
for general fragmentation is to keep the allocations that never will get freed 
away from the rest of memory, so that memory has a chance to form larger 
contiguous ranges when it is freed.

By separating memory based on usage there is another side effect.  It also makes 
possible some more active defragmentation methods on easier memory, because it 
doesn't have annoying hard memory scattered throughout.  Suddenly we can talk 
about being able to do memory hotplug remove on significant portions of memory. 
    Or allocating these hugepages after boot.  Or doing active defragmentation. 
  Or modules being able to be modules because they don't have to preallocate big 
pieces of contiguous memory.

Some people will argue that we need 100% separation of usage or no separation at 
all.  Well, change the array of fallback to not allow kernel non-reclaimable to 
fallback and we are done.  4 line change, 100% separation.  But the tradeoff is 
that under memory pressure we might fail allocations when we still have free 
memory.  There are other options for fallback of course, the fallback_alloc() 
function is easily replaceable if somebody wants to.  Many of these options get 
easier once memory migration is in.  The way fallback is done in the current 
patches is to maintain current behavior as much as possible, satisfy 
allocations, and not affect performance.

As to the 100% success at removing memory, this set of patches doesn't solve 
that.  But it solves the 80% problem quite nicely (when combined with the memory 
migration patches).  80% is great for virtualized systems where the OS has some 
choice over which memory to remove, but not the quantity to remove.  It is also 
a good start to 100%, because we can separate and identify the easy memory from 
the hard memory.  Dave Hansen has outlined in separate posts how we can get to 
100%, including hard memory.

>>can you always, under any circumstance hot unplug RAM with these patches
>>applied? If not, do you have any expectation to reach 100%?
> 
> 
> You're asking intentionally leading questions, aren't you?  Without on-demand 
> page migration a given area of physical memory would only ever be free by 
> sheer coincidence.  Less fragmented page allocation doesn't address _where_ 
> the free areas are, it just tries to make them contiguous.
> 
> A page migration strategy would have to do less work if there's less 
> fragmention, and it also allows you to cluster the "difficult" cases (such as 
> kernel structures that just ain't moving) so you can much more easily 
> hot-unplug everything else.  It also makes larger order allocations easier to 
> do so drivers needing that can load as modules after boot, and it also means 
> hugetlb comes a lot closer to general purpose infrastructure rather than a 
> funky boot-time reservation thing.  Plus page prezeroing approaches get to 
> work on larger chunks, and so on.
> 
> But any strategy to demand that "this physical memory range must be freed up 
> now" will by definition require moving pages...

Perfectly stated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
