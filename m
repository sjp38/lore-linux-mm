Subject: Re: slab fragmentation ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <4162ECAD.8090403@colorfullife.com>
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com>
	 <20040929204143.134154bc.akpm@osdl.org>  <29460000.1096555795@[10.10.2.4]>
	 <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>
	 <415F968B.8000403@colorfullife.com>
	 <1096905099.12861.117.camel@dyn318077bld.beaverton.ibm.com>
	 <41617567.9010507@colorfullife.com>
	 <1096987570.12861.122.camel@dyn318077bld.beaverton.ibm.com>
	 <4162E0AF.4000704@colorfullife.com>
	 <1097000846.12861.143.camel@dyn318077bld.beaverton.ibm.com>
	 <4162ECAD.8090403@colorfullife.com>
Content-Type: text/plain
Message-Id: <1097074688.12861.182.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 06 Oct 2004 07:58:08 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-05 at 11:49, Manfred Spraul wrote:
> Badari Pulavarty wrote:
> 
> >>The fix would be simple: kmem_cache_alloc_node must walk through the 
> >>list of partial slabs and check if it finds a slab from the correct 
> >>node. If it does, then just use that slab instead of allocating a new 
> >>one. 

I have been looking at the code, I don't understand few things here.
alloc_percpu() calls kmem_cache_alloc_node() to allocate objects from
each node. Its just making sure that each object comes from different
node where the CPU belongs. So, without NUMA all the allocations come
from same node. Isn't it ?

If so, in NON numa case why bother allocating a new slab at all ?
Why can't we return an object from our per-cpu cache list ? Yes. We
might end up allocating objects for all CPUs from the cpu cache
we are running on. But current code doesn't deal with CPUs, only
nodes. So it should be same.

OR just grab  first partial slab and allocate it from there ?

If NUMA, we need to do get a partial slab belongs to the node and
do the allocation from there.

Am I missing something fundamental here ?

Thanks,
Badari



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
