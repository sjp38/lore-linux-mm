Message-ID: <4342B623.3060007@colorfullife.com>
Date: Tue, 04 Oct 2005 19:04:35 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
References: <20050930193754.GB16812@xeon.cnet> <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com> <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com> <43419686.60600@colorfullife.com> <20051003221743.GB29091@logos.cnet>
In-Reply-To: <20051003221743.GB29091@logos.cnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, akpm@osdl.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

>Hi Manfred,
>
>On Mon, Oct 03, 2005 at 10:37:26PM +0200, Manfred Spraul wrote:
>  
>
>>Christoph Lameter wrote:
>>
>>    
>>
>>>On Sat, 1 Oct 2005, Marcelo wrote:
>>>
>>>
>>>
>>>      
>>>
>>>>I thought about having a mini-API for this such as "struct 
>>>>slab_reclaim_ops" implemented by each reclaimable cache, invoked by a 
>>>>generic SLAB function.
>>>>
>>>>  
>>>>
>>>>        
>>>>
>>Which functions would be needed?
>>- lock_cache(): No more alive/dead changes
>>- objp_is_alive()
>>- objp_is_killable()
>>- objp_kill() 
>>    
>>
>
>Yep something along that line. I'll come up with something more precise
>tomorrow.
>
>  
>
>>I think it would be simpler if the caller must mark the objects as 
>>alive/dead before/after calling kmem_cache_alloc/free: I don't think 
>>it's a good idea to add special case code and branches to the normal 
>>kmem_cache_alloc codepath. And especially: It would mean that 
>>kmem_cache_alloc must perform a slab lookup  in each alloc call, this 
>>could be slow.
>>The slab users could store the alive status somewhere in the object. And 
>>they could set the flag early, e.g. disable alive as soon as an object 
>>is put on the rcu aging list.
>>    
>>
>
>The "i_am_alive" flag purpose at the moment is to avoid interpreting
>uninitialized data (in the dentry cache, the reference counter is bogus
>in such case). It was just a quick hack to watch it work, it seemed to
>me it could be done within SLAB code.
>
>This information ("liveness" of objects) is managed inside the SLAB
>generic code, and it seems to be available already through the
>kmembufctl array which is part of the management data, right?
>
>  
>
Not really. The array is only updated when the free status reaches the 
slab structure, which is quite late.

kmem_cache_free
- puts the object into a per-cpu array. No locking at all, each cpu can 
only read it's own array.
- when that array is full, then it's put into a global array (->shared).
- when the global array is full, then the object is marked as free in 
the slab structure.
- when add objects from a slab are free, then the slab is placed on the 
free slab list
- when there is memory pressure, then the pages from the free slab list 
are reclaimed.

>Suppose there's no need for the cache specific functions to be aware of
>liveness, ie. its SLAB specific information.
>
>  
>
What about RCU? We have dying objects: Still alive, because someone 
might have a pointer to it, but already on the rcu list and will be 
released after the next quiescent state. slab can't know that.

>Another issue is synchronization between multiple threads in this 
>level of the reclaim path. Can be dealt with PageLock: if the bit is set,
>don't bother checking the page, someone else is already doing
>so.
>
>You mention
>
>  
>
>>- lock_cache(): No more alive/dead changes
>>    
>>
>
>With the PageLock bit, you can instruct kmem_cache_alloc() to skip partial
>but Locked pages (thus avoiding any object allocations within that page).
>Hum, what about higher order SLABs?
>
>  
>
You have misunderstood my question: I was thinking about object 
dead/alive changes.
There are two questions: First figure out how many objects from a 
certain slab are alive. Then, if it's below a threshold, try to free 
them. With this approach, you need lock(), is_objp_alive(), release_objp().

>Well, kmem_cache_alloc() can be a little bit smarter at this point, since 
>its already a slow path, no? Its refill time, per-CPU cache is exhausted...
>
>  
>
Definitively. Fast path is only kmem_cache_alloc and kmem_cache_free. No 
global cache line writes in these functions. They were down to 1 
conditional branch and 2-3 cachelines, One of them read-only, the 
other(s) are read/write, but per-cpu. I'm not sure how much changed with 
the NUMA patches, but the non-numa case should try to remain simple. And 
e.g. looking up the bufctl means an integer division. Just that 
instruction could nearly double the runtime of kmem_cache_free().
The shared_array part from cache_flusharray and cache_alloc_refill are 
partially fast path: If we slow that down, then it will affect packet 
routing. The rest is slow path.

--
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
