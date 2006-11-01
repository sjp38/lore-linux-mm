Date: Wed, 1 Nov 2006 22:13:59 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0611011255070.14406@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0611012210290.29614@skynet.skynet.ie>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
 <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
 <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
 <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
 <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie>
 <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611011255070.14406@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@skynet.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Nov 2006, Christoph Lameter wrote:

> On Wed, 1 Nov 2006, Andrew Morton wrote:
>
>> And hot-unplug isn't actually the interesting application.  Modern Intel
>> memory controllers apparently have (or will have) the ability to power down
>> DIMMs.
>
> Plus one would want to be able to move memory out of an area where we may
> have a bad DIMM. If we monitor soft ECC failures then we could also
> judge a DIMM to be bad if we have a too high soft failure rate.
>

For this, it'd be desirable to be able to marge a range of pages as 
unusable. In the anti-frag patches I posted, I included a mechanism for 
having flags that affected a whole block of pages. One intent in the 
future was to be able to mark a whole block of pages as getting reclaimed 
for the allocation of superpages.

The same mechanism could be used to mark pages as being offlined so you 
could mark a DIMM as offlined and start reclaiming in there knowing it can 
be unplugged some time in the future.

> If there is a hard failure and we can recover (page cache page f.e.)
> then we could preemptively disable the complete DIMM.
>
> I still think that we need to generalize the approach to be
> able to cover as much memory as possible. Remapping can solve some of the
> issues, for others we could add additional ways to make things movable.
> F.e. one could make page table pages movable by adding a back pointer to
> the mm, reclaimable slab pages by adding a move function, driver
> allocations could have a backpointer to the driver that would be able to
> move its memory.

I got the impression that we wouldn't be allowed to introduce such a 
mechanism because driver writers would get it wrong. It was why proper 
defragmentation was never really implemented.

> Hmm.... Maybe generally a way to provide a
> function to move data in the page struct for kernel allocations?
>

As devices are able to get physical addresses which then get pinned for 
IO, it gets messy.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
