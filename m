Message-ID: <4162E0AF.4000704@colorfullife.com>
Date: Tue, 05 Oct 2004 19:58:07 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: slab fragmentation ?
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com>	 <20040929204143.134154bc.akpm@osdl.org>  <29460000.1096555795@[10.10.2.4]>	 <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>	 <415F968B.8000403@colorfullife.com>	 <1096905099.12861.117.camel@dyn318077bld.beaverton.ibm.com>	 <41617567.9010507@colorfullife.com> <1096987570.12861.122.camel@dyn318077bld.beaverton.ibm.com>
In-Reply-To: <1096987570.12861.122.camel@dyn318077bld.beaverton.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:

>Here is the /proc/slabinfo output collected every 1 second while
>running the scsi-debug test. I enabled STATS and DEBUG.
>
>  
>
Ok, thanks.

Before test:
size-40 2088 9760 64 61 1
    tunables 32 16 8
    slabdata 160 160 0
    globalstat 3324 2010 160 0 0 0 173
    cpustat 5675 213 3945 2

2nd value of cpustat ALLOCMISS: 213 calls to cache_alloc_refill.
first value of slabdata: 160 slabs.
sane.

2nd value of globalstat: maximum 2010 objects allocated.
first value of the "size" line: 2088 objects active right now.
sane,too.

After a few seconds:

size-40 4582 31110 64 61 1
    tunables 32 16 8
    slabdata 510 510 0
    globalstat 5468 4085 510 0 0 0 173
    cpustat 7924 347 4247 2
first value of slabdata: 510 slabs around.
second value of cpudata: total of 347 cache_alloc_refill calls.
Huh? Very odd. Each call of cache_alloc_refill causes at most one 
cache_grow, and a cache_grow creates exactly one slab.

2nd value of globalstat: max of 4085 objects allocated.
First value of size line: 4582 objects active.
Huh? More active objects than kmem_cache_alloc/kmalloc calls?

Could you add a printk into kmem_cache_alloc_node()? Perhaps with a 
dump_stack() or something like that. I'd bet that someone calls 
kmem_cache_alloc_node(). Probably indirectly through alloc_percpu() - 
hch recently broke the public interface.

Hmm. init_disk_stats() uses alloc_percpu. What are you testing? Creating 
lots of disks for testing? If you end up calling kmem_cache_alloc_node() 
then I know what happens.
The fix would be simple: kmem_cache_alloc_node must walk through the 
list of partial slabs and check if it finds a slab from the correct 
node. If it does, then just use that slab instead of allocating a new 
one. And statistics must be added to kmem_cache_alloc_node - I forgot 
that when I wrote the function.

--
    Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
