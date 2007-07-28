Message-ID: <46AAA25E.7040301@redhat.com>
Date: Fri, 27 Jul 2007 21:56:46 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: swap-prefetch:  A smart way to make good use of idle resources
 (was: updatedb)
References: <200707272243.02336.a1426z@gawab.com>
In-Reply-To: <200707272243.02336.a1426z@gawab.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Boldi <a1426z@gawab.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Al Boldi wrote:
> People wrote:
>>>> I believe the users who say their apps really do get paged back in
>>>> though, so suspect that's not the case.
>>> Stopping the bush-circumference beating, I do not. -ck (and gentoo) have
>>> this massive Calimero thing going among their users where people are
>>> much less interested in technology than in how the nasty big kernel
>>> meanies are keeping them down (*).
>> I think the problem is elsewhere. Users don't say: "My apps get paged
>> back in." They say: "My system is more responsive". They really don't
>> care *why* the reaction to a mouse click that takes three seconds with
>> a mainline kernel is instantaneous with -ck. Nasty big kernel meanies,
>> OTOH, want to understand *why* a patch helps in order to decide whether
>> it is really a good idea to merge it. So you've got a bunch of patches
>> (aka -ck) which visibly improve the overall responsiveness of a desktop
>> system, but apparently no one can conclusively explain why or how they
>> achieve that, and therefore they cannot be merged into mainline.
>>
>> I don't have a solution to that dilemma either.
> 
> IMHO, what everybody agrees on, is that swap-prefetch has a positive effect 
> in some cases, and nobody can prove an adverse effect (excluding power 
> consumption).  The reason for this positive effect is also crystal clear:  
> It prefetches from swap on idle into free memory, ie: it doesn't force 
> anybody out, and they are the first to be dropped without further swap-out, 
> which sounds really smart.
> 
> Conclusion:  Either prove swap-prefetch is broken, or get this merged quick.

If you can't prove why it helps and doesn't hurt, then it's a hack, by 
definition.  Behind any performance hack is some fundamental truth that can be 
exploited to greater effect if we reason about it.  So let's reason about it. 
I'll start.

Resource size has been outpacing processing latency since the dawn of time. 
Disks get bigger much faster than seek times shrink.  Main memory and cache keep 
growing, while single-threaded processing speed has nearly ground to a halt.

In the old days, it made lots of sense to manage resource allocation in pages 
and blocks.  In the past few years, we started reserving blocks in ext3 
automatically because it saves more in seek time than it costs in disk space. 
Now we're taking preallocation and antifragmentation to the next level with 
extent-based allocation in ext4.

Well, we're still using bitmap-style allocation for pages, and the prefetch-less 
swap mechanism adheres to this design as well.  Maybe it's time to start 
thinking about memory in a somewhat more extent-like fashion.

With swap prefetch, we're only optimizing the case when the box isn't loaded and 
there's RAM free, but we're not optimizing the case when the box is heavily 
loaded and we need for RAM to be free.  This is a complete reversal of sane 
development priorities.  If swap batching is an optimization at all (and we have 
empirical evidence that it is) then it should also be an optimization to swap 
out chunks of pages when we need to free memory.

So, how do we go about this grouping?  I suggest that if we keep per-VMA 
reference/fault/dirty statistics, we can tell which logically distinct chunks of 
memory are being regularly used.  This would also us to apply different page 
replacement policies to chunks of memory that are being used in different fashions.

With such statistics, we could then page out VMAs in 2MB chunks when we're under 
memory pressure, also giving us the option of transparently paging them back in 
to hugepages when we have the memory free, once anonymous hugepage support is in 
place.

I'm inclined to view swap prefetch as a successful scientific experiment, and 
use that data to inform a more reasoned engineering effort.  If we can design 
something intelligent which happens to behave more or less like swap prefetch 
does under the circumstances where swap prefetch helps, and does something else 
smart under the circumstances where swap prefetch makes no discernable 
difference, it'll be a much bigger improvement.

Because we cannot prove why the existing patch helps, we cannot say what impact 
it will have when things like virtualization and solid state drives radically 
change the coefficients of the equation we have not solved.  Providing a sysctl 
to turn off a misbehaving feature is a poor substitute for doing it right the 
first time, and leaving it off by default will ensure that it only gets used by 
the handful of people who know enough to rebuild with the patch anyway.

Let's talk about how we can make page replacement smarter, so it naturally 
accomplishes what swap prefetch accomplishes, as part of a design we can reason 
about.

CC-ing linux-mm, since that's where I think we should take this next.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
