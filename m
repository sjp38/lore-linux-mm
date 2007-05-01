Message-ID: <463723DE.9030507@yahoo.com.au>
Date: Tue, 01 May 2007 21:26:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Antifrag patchset comments
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie> <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 28 Apr 2007, Mel Gorman wrote:

>>>10. Radix tree as reclaimable? radix_tree_node_alloc()
>>>
>>>	Ummm... Its reclaimable in a sense if all the pages are removed
>>>	but I'd say not in general.
>>>
>>
>>I considered them to be indirectly reclaimable. Maybe it wasn't the best
>>choice.
> 
> 
> Maybe we need to ask Nick about this one.

I guess they are as reclaimable as the pagecache they hold is. Of
course, they are yet another type of object that makes higher order
reclaim inefficient, regardless of lumpy reclaim etc.

... and also there are things besides pagecache that use radix trees....

I guess you are faced with conflicting problems here. If you do not
mark things like radix tree nodes and dcache as reclaimable, then your
unreclaimable category gets expanded and fragmented more quickly.

On the other hand, if you do mark them (not just radix-trees, but also
bios, dcache, various other things) as reclaimable, then they make it
more difficult to reclaim from the reclaimable memory, and they also
make the reclaimable memory less robust, because you could have pinned
dentry, or some other radix tree user in there that cannot be reclaimed.

I guess making radix tree nodes reclaimable is probably the best of the
two options at this stage.

But now that I'm asked, I repeat my dislike for the antifrag patches,
because of the above -- ie. they're just a heuristic that slows down
the fragmentation of memory rather than avoids it.

I really oppose any code that _depends_ on higher order allocations.
Even if only used for performance reasons, I think it is sad because
a system that eventually gets fragmented will end up with worse
performance over time, which is just lame.

For those systems that really want a big chunk of memory set aside (for
hugepages or memory unplugging), I think reservations are reasonable
because they work and are robust. If we ever _really_ needed arbitrary
contiguous physical memory for some reason, then I think virtual kernel
mapping and true defragmentation would be the logical step.

AFAIK, nobody has tried to do this yet it seems like the (conceptually)
simplest and most logical way to go if you absolutely need contig
memory.

But firstly, I think we should fight against needing to do that step.
I don't care what people say, we are in some position to influence
hardware vendors, and it isn't the end of the world if we don't run
optimally on some hardware today. I say we try to avoid higher order
allocations. It will be hard to ever remove this large amount of
machinery once the code is in.

So to answer Andrew's request for review, I have looked through the
patches at times, and they don't seem to be technically wrong (I would
have prefered that it use resizable zones rather than new sub-zone
zones, but hey...). However I am against the whole direction they go
in, so I haven't really looked at them lately.

I think the direction we should take is firstly ask whether we can do
a reasonable job with PAGE_SIZE pages, secondly ask whether we can do
an acceptable special-case (eg. reserve memory), lastly, _actually_
do defragmentation of kernel memory. Anti-frag would come somewhere
after that last step, as a possible optimisation.

So I haven't been following where we're at WRT the requirements. Why
can we not do with PAGE_SIZE pages or memory reserves? If it is a
matter of efficiency, then how much does it matter, and to whom?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
