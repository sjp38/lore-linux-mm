Subject: Re: How to get a sense of VM pressure
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <488A1398.7020004@goop.org>
References: <488A1398.7020004@goop.org>
Content-Type: text/plain
Date: Mon, 28 Jul 2008 09:36:10 +0200
Message-Id: <1217230570.6331.6.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Virtualization Mailing List <virtualization@lists.osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-25 at 10:55 -0700, Jeremy Fitzhardinge wrote:
> I'm thinking about ways to improve the Xen balloon driver.  This is the 
> driver which allows the guest domain to expand or contract by either 
> asking for more memory from the hypervisor, or giving unneeded memory 
> back.  From the kernel's perspective, it simply looks like a driver 
> which allocates and frees pages; when it allocates memory it gives the 
> underlying physical page back to the hypervisor.  And conversely, when 
> it gets a page from the hypervisor, it glues it under a given pfn and 
> releases that page back to the kernel for reuse.
> 
> At the moment it's very dumb, and is pure mechanism.  It's told how much 
> memory to target, and it either allocates or frees memory until the 
> target is reached.  Unfortunately, that means if it's asked to shrink to 
> an unreasonably small size, it will do so without question, killing the 
> domain in a thrash-storm in the process.
> 
> There are several problems:
> 
>    1. it doesn't know what a reasonable lower limit is, and
>    2. it doesn't moderate the rate of shrinkage to give the rest of the
>       VM time to adjust to having less memory (by paging out, dropping
>       inactive, etc)
> 
> And possibly the third point is that the only mechanism it has for 
> applying memory pressure to the system is by allocating memory.  It 
> allocates with (GFP_HIGHUSER | __GFP_NOWARN | __GFP_NORETRY | 
> __GFP_NOMEMALLOC), trying not to steal memory away from things that 
> really need it.  But in practice, it can still easy drive the machine 
> into a massive unrecoverable swap storm.
> 
> So I guess what I need is some measurement of "memory use" which is 
> perhaps akin to a system-wide RSS; a measure of the number of pages 
> being actively used, that if non-resident would cause a large amount of 
> paging.  If you shrink the domain down to that number of pages + some 
> padding (x%?), then the system will run happily in a stable state.  If 
> that number increases, then the system will need new memory soon, to 
> stop it from thrashing.  And if that number goes way below the domain's 
> actual memory allocation, then it has "too much" memory.
> 
> Is this what "Active" accounts for?  Is Active just active 
> usermode/pagecache pages, or does it also include kernel allocations?  
> Presumably Inactive Clean memory can be freed very easily with little 
> impact on the system, Inactive Dirty memory isn't needed but needs IO to 
> free; is there some way to measure how big each class of memory is?
> 
> If you wanted to apply gentle memory pressure on the system to attempt 
> to accelerate freeing memory, how would you go about doing that?  Would 
> simply allocating memory at a controlled rate achieve it?
> 
> I guess it also gets more complex when you bring nodes and zones into 
> the picture.  Does it mean that this computation would need to be done 
> per node+zone rather than system-wide?
> 
> Or is there some better way to implement all this?

Have a peek at this:

  http://people.redhat.com/~riel/riel-OLS2006.pdf

The refault patches have been posted several times, but nobody really
tried to use them for your problem.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
