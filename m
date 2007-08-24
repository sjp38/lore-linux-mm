Date: Fri, 24 Aug 2007 14:38:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/6] Per cpu structures for SLUB
Message-Id: <20070824143848.a1ecb6bc.akpm@linux-foundation.org>
In-Reply-To: <20070823064653.081843729@sgi.com>
References: <20070823064653.081843729@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 23:46:53 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> The following patchset introduces per cpu structures for SLUB. These
> are very small (and multiples of these may fit into one cacheline)
> and (apart from performance improvements) allow the addressing of
> several isues in SLUB:
> 
> 1. The number of objects per slab is no longer limited to a 16 bit
>    number.
> 
> 2. Room is freed up in the page struct. We can avoid using the
>    mapping field which allows to get rid of the #ifdef CONFIG_SLUB
>    in page_mapping().
> 
> 3. We will have an easier time adding new things like Peter Z.s reserve
>    management.
> 
> The RFC for this patchset was discussed on lkml a while ago:
> 
> http://marc.info/?l=linux-kernel&m=118386677704534&w=2
> 
> (And no this patchset does not include the use of cmpxchg_local that
> we discussed recently on lkml nor the cmpxchg implementation
> mentioned in the RFC)
> 
> Performance
> -----------
> 
> 
> Norm = 2.6.23-rc3
> PCPU = Adds page allocator pass through plus per cpu structure patches
> 
> 
> IA64 8p 4n NUMA Altix
> 
>             Single threaded               Concurrent Alloc
> 
> 	Kmalloc		Alloc/Free	Kmalloc         Alloc/Free
>  Size	Norm   PCPU	Norm   PCPU	Norm   PCPU	Norm   PCPU
> -------------------------------------------------------------------
>     8	132	84	93	104	98	90	95	106
>    16    98	92	93	104	115	98	95	106
>    32   112	105	93	104	146	111	95	106
>    64	119	112	93	104	214	133	95	106
>   128   132	119	94	104	321	163	95	106
>   256+  83255	176	106	115	415	224	108	117
>   512   191	176	106	115	487	341	108	117
>  1024   252	246	106	115	937	609	108	117
>  2048   308	292	107	115	2494	1207	108	117
>  4096   341	319	107	115	2497	1217	108	117
>  8192   402	380	107	115	2367	1188	108	117
> 16384*  560	474	106	434	4464	1904	108	478
> 
> X86_64 2p SMP (Dual Core Pentium 940)
> 
>          Single threaded                   Concurrent Alloc
> 
>         Kmalloc         Alloc/Free      Kmalloc         Alloc/Free
>  Size   Norm   PCPU     Norm   PCPU     Norm   PCPU     Norm   PCPU
> --------------------------------------------------------------------
>     8	313	227	314	324	207	208	314	323
>    16   202	203	315	324	209	211	312	321
>    32	212	207	314	324	251	243	312	321
>    64	240	237	314	326	329	306	312	321
>   128	301	302	314	324	511	416	313	324
>   256   498	554	327	332	970	837	326	332
>   512   532	553	324	332	1025	932	326	335
>  1024   705	718	325	333	1489	1231	324	330
>  2048   764	767	324	334	2708	2175	324	332
>  4096* 1033	476	325	674	4727	782	324	678

I'm struggling a bit to understand these numbers.  Bigger is better, I
assume?  In what units are these numbers?

> Notes:
> 
> Worst case:
> -----------
> We generally loose in the alloc free test (x86_64 3%, IA64 5-10%)
> since the processing overhead increases because we need to lookup
> the per cpu structure. Alloc/Free is simply kfree(kmalloc(size, mask)).
> So objects with the shortest lifetime possible. We would never use
> objects in that way but the measurement is important to show the worst
> case overhead created.
> 
> Single Threaded:
> ----------------
> The single threaded kmalloc test shows behavior of a continual stream
> of allocation without contention. In the SMP case the losses are minimal.
> In the NUMA case we already have a winner there because the per cpu structure
> is placed local to the processor. So in the single threaded case we already
> win around 5% just by placing things better.
> 
> Concurrent Alloc:
> -----------------
> We have varying gains up to a 50% on NUMA because we are now never updating
> a cacheline used by the other processor and the data structures are local
> to the processor.
> 
> The SMP case shows gains but they are smaller (especially since
> this is the smallest SMP system possible.... 2 CPUs). So only up
> to 25%.
> 
> Page allocator pass through
> ---------------------------
> There is a significant difference in the columns marked with a * because
> of the way that allocations for page sized objects are handled.

OK, but what happened to the third pair of columns (Concurrent Alloc,
Kmalloc) for 1024 and 2048-byte allocations?  They seem to have become
significantly slower?

Thanks for running the numbers, but it's still a bit hard to work out
whether these changes are an aggregate benefit?

> If we handle
> the allocations in the slab allocator (Norm) then the alloc free tests
> results are superb since we can use the per cpu slab to just pass a pointer
> back and forth. The page allocator pass through (PCPU) shows that the page
> allocator may have problems with giving back the same page after a free.
> Or there something else in the page allocator that creates significant
> overhead compared to slab. Needs to be checked out I guess.
> 
> However, the page allocator pass through is a win in the other cases
> since we can cut out the page allocator overhead. That is the more typical
> load of allocating a sequence of objects and we should optimize for that.
> 
> (+ = Must be some cache artifact here or code crossing a TLB boundary.
> The result is reproducable)
> 

Most Linux machines are uniprocessor.  We should keep an eye on what effect
a change like this has on code size and performance for CONFIG_SMP=n
builds..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
