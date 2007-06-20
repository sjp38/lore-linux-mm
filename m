Subject: Re: Some thoughts on memory policies
References: <Pine.LNX.4.64.0706181257010.13154@schroedinger.engr.sgi.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 20 Jun 2007 14:30:17 +0200
In-Reply-To: <Pine.LNX.4.64.0706181257010.13154@schroedinger.engr.sgi.com>
Message-ID: <p73lkeerep2.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, wli@holomorphy.com, lee.schermerhorn@hp.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> writes:

> I think we are getting into more and more of a mess with the existing 
> memory policies. The refcount issue with shmem is just one bad symptom of 
> it. 

That's easy to fix by just making the mpol freeing RCU
and not use a reference count for this window. I'll
send a patch soon.

> Memory policies were intended to be process based

Not true, e.g. shmem is a good counter example. Also kernel
has its own policies too.

> and 
> taking them out of that context causes various issues.

My primary concern is if there is a good user interface
that you can actually explain to a normal sysadmin and can
be used relatively race free. Many of the proposals I've
seen earlier failed these tests.


> - Device drivers may need to control memory allocations in
>   devices either because their DMA engines can only reach a
>   subsection of the system

On what system does this happen? Not sure you can call that
a "coherent system"

> or because memory transfer
>   performance is superior in certain nodes of the system.

Most architectures already give a sensible default for the coherent DMA
mappings (node the device is attached to) For the others it is
really not under driver control.

> - File / Socket. One may have particular reasons to place
>   objects on a set of nodes because of how the threads of
>   an application are spread out in the system.

The default right now seems reasonable to me. e.g. network
devices typically allocate on the node their interrupt
is assigned to. If you bind the application to that node
then you'll have everything local.

Now figuring out how to do this automatically without
explicit configuration would be great, but I don't
know of a really general solution (Especially when
you consider MSI-X hash based load balancing). Ok the 
scheduler does a little work in this direction by nudging
processes already towards the CPU that gets the wakeups
from; perhaps this could be made a little stronher.

Arguably irqbalanced needs to be more NUMA aware, 
but that's not really a kernel issue.

But frankly I wouldn't see the value of more explicit
configuration here.

> - Cpuset / Container. Some simple support is there with
>   memory spreading today. That could be made more universal.

Agreed.
> 
> - System policies. The system policy is currently not
>   modifiable. It may be useful to be able to set this.
>   Small NUMA systems may want to run with interleave by default 

Yes we need page cache policy. That's easy to do though.

> - Address range. For the virtual memory address range
>   this is included in todays functionality but one may also
>   want to control the physical address range to make sure
>   f.e. that memory is allocated in an area where a device
>   can reach it.

Why?  Where do we have such broken devices that cannot
DMA everywhere?  If they're really that broken they
probably deserve to be slow (or rather use double buffering,
not DMA)

Also controlling from the device where the submitted
data is difficult unless you bind processes. If you do 
it just works, but if you don't want to (for most cases
explicit binding is bad) it is hard.

I would be definitely opposed to anything that exposes
addresses as user interface.

> - Memory policies need to be attachable to types of pages.
>   F.e. executable pages of a threaded application are best
>   spread (or replicated) 

There are some experimental patches for text replication.
I used to think they were probably not needed, but there
are now some benchmark results that show they're a good
idea for some workloads.

This should be probably investigated. I think Nick P. was looking
at it.


>   whereas the stack and the data may
>   best be allocated in a node local way.
>   Useful categories that I can think of
>   Stack, Data, Filebacked pages, Anonymous Memory,
>   Shared memory, Page tables, Slabs, Mlocked pages and
>   huge pages.

My experience so far with user feedback is that most
users only use the barest basics of NUMA policy and they
rarely use anything more advanced. For anything complicated
you need a very very good justification. 

> 
>   Maybe a set of global policies would be useful for these
>   categories. Andy hacked subsystem memory policies into
>   shmem and it seems that we are now trying to do the same
>   for hugepages.

It's already there for huge pages if you look at the code 
(I was confused earlier when I claimed it wasn't) 

For page cache that is not mmaped I agree it's useful.
But I suspect a couple of sysctls would do fine here
(SLES9 had something like this for page cache as a sysctl) 

> 2. Memory policies need to support additional constraints
> 
> - Restriction to a set of nodes. That is what we have today.
> 
> - Restriction to a container or cpuset. Maybe restriction
>   to a set of containers?

Why?

> 
> - Strict vs no strict allocations. A strict allocation needs
>   to fail if the constraints cannot be met. A non strict
>   allocation can fall back.

That's already there -- that's the difference between PREFERED
and BIND.

> 
> - Order of allocation. Higher order pages may require

What higher order pages?  Right now they're only 
in hugetlbfs.

Regarding your page cache proposal: I think it's a bad
idea, larger soft page sizes would be better.

> - Automigrate flag so that memory touched by a process
>   is moved to a memory location that has best performance.

Hmm, possible. Do we actually have users for this though? 

> - Page order flag that determines the preferred allocation
>   order. Maybe useful in connection with the large blocksize
>   patch to control anonymous memory orders.

Not sure I see the point of this.

> 4. Policy combinations
> 
> We need some way to combine policies in a systematic way. The current
> hieracy from System->cpuset->proces->memory range does not longer
> work if a process can use policies set up in shmem or huge pages.
> Some consistent scheme to combine memory policies would also need
> to be able to synthesize different policies. I.e. automigrate
> can be combined with node local or interleave and a cpuset constraint.

Maybe.

> The esoteric
> nature of memory policy semantics makes them difficult to comprehend.

Exactly.  It doesn't make sense to implement if you can't
give it a good interface.

> 7. Allocators must change
> 
> Right now the policy is set by the process context which is bad because
> one cannot specify a memory policy for an allocation. It must be possible
> to pass a memory policy to the allocators and then get the memory 
> requested.

We already can allocate on a node. If there is really demand
we could also expose interleaved allocations, but again
we would need a good user.

Not sure it is useful for sl[aou]b.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
