Message-ID: <4544914F.3000502@yahoo.com.au>
Date: Sun, 29 Oct 2006 22:32:31 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Page allocator: Single Zone optimizations
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com> <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com> <45347288.6040808@yahoo.com.au> <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com> <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org> <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com> <20061026150938.bdf9d812.akpm@osdl.org> <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com> <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com> <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com> <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com> <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 28 Oct 2006, Andrew Morton wrote:
> 
> 
>>>We (and I personally with the prezeroing patches) have been down 
>>>this road several times and did not like what we saw. 
>>
>>Details?
> 
> 
> The most important issues that come to my mind right now  (this has 
> been discussed frequently in various contexts so I may be missing 
> some things) are:
> 
> 1. Duplicate the caches (pageset structures). This reduces cache hit 
>    rates. Duplicates lots of information in the page allocator.

You would have to do the same thing to get an O(1) per-CPU allocation
for a specific zone/reclaim type/etc regardless whether or not you use
zones.

> 2. Necessity of additional load balancing across multiple zones.

a. we have to do this anyway for eg. dma32 and NUMA, and b. it is much
better than the highmem problem was because all the memory is kernel
addressable.

If you use another scheme (eg. lists within zones within nodes, rather
than just more zones within nodes), then you still fundamentally have
to balance somehow.

> 3. The NUMA layer can only support memory policies for a single zone.

That's broken. The VM had zones long before it had nodes or memory
policies.

> 4. You may have to duplicate the slab allocator caches for that
>    purpose.

If you want specific allocations from a given zone, yes. So you may
have to do the same if you want a specific slab allcoation from a
list within a zone.

> 5. More bits used in the page flags.

Aren't there patches to move the bits out of the page flags? A list
within zones approach would have to use either page flags or some
external info (eg. page pfn) to determine what list for the page to
go back to anyway, wouldn't you?

> 6. ZONES have to be sized at bootup which creates more dangers of runinng
>    out of memory, possibly requiring more complex load balancing.

Mel's list based defrag approach requires complex load balancing too.

>>Again.  On the whole, that was a pretty useless email.  Please give us
>>something we can use.
> 
> 
> Well review the discussions that we had regarding Mel Gorman's defrag 
> approaches. We discussed this in detail at the VM summit and decided to 
> not create additional zones but instead separate the free lists. You and 
> Linus seemed to be in agreement with this. I am a bit surprised .... 
> Is this a Google effect?
> 
> Moreover the discussion here is only remotely connected to the issue at 
> hand. We all agree that ZONE_DMA is bad and we want to have an alternate 
> scheme. Why not continue making it possible to not compile ZONE_DMA 
> dependent code into the kernel?
> 
> Single zone patches would increase VM performance. That would in turn 
> make it more difficult to get approaches in that require multiple zones 
> since the performance drop would be more significant.

node->zone->many lists vs node->many zones? I guess the zones approach is
faster?

Not that I am any more convinced that defragmentation is a good idea than
I was a year ago, but I think it is naive to think we can instantly be rid
of all the problems associated with zones by degenerating that layer of the
VM and introducing a new one that does basically the same things.

It is true that zones may not be a perfect fit for what some people want to
do, but until they have shown a) what they want to do is a good idea, and
b) zones can't easily be adapted, then using the infrastructure we already
have throughout the entire mm seems like a good idea.

IMO, Andrew's idea to have 1..N zones in a node seems sane and it would be
a good generalisation of even the present code.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
