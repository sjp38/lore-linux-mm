Date: Sat, 28 Oct 2006 18:29:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <20061028180402.7c3e6ad8.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
 <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
 <45347288.6040808@yahoo.com.au> <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
 <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org>
 <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
 <20061026150938.bdf9d812.akpm@osdl.org> <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
 <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
 <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
 <20061028180402.7c3e6ad8.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Oct 2006, Andrew Morton wrote:

> > We (and I personally with the prezeroing patches) have been down 
> > this road several times and did not like what we saw. 
> 
> Details?

The most important issues that come to my mind right now  (this has 
been discussed frequently in various contexts so I may be missing 
some things) are:

1. Duplicate the caches (pageset structures). This reduces cache hit 
   rates. Duplicates lots of information in the page allocator.

2. Necessity of additional load balancing across multiple zones.

3. The NUMA layer can only support memory policies for a single zone.

4. You may have to duplicate the slab allocator caches for that
   purpose.

5. More bits used in the page flags.

6. ZONES have to be sized at bootup which creates more dangers of runinng
   out of memory, possibly requiring more complex load balancing.

7. Having more zones increases fragmentation since the different zones
   have separate freelists.

> > For that we would have to have a distinction of removable memory which 
> > wont be necessary if we use the existing mappings to move the physical
> > location while keeping the virtual addresses.
> 
> You're proposing that all kernel memory be virtually mapped?
> 
> I've never seen such a proposal nor any implementation.

It has been that way for years on ia64 and x86_64 also has virtual maps 
for all of kernel memory. x86_64 currently uses huge page entries for
the kernel (arch/x86_64/mm/init.c). ia64 has a special TLB entry generator 
in arch/ia64/kernel/ivt.S. I assume that other arches do the same. I have 
hacked the ia64 TLB entry generator for variable kernel page sizes (see 
my memmap patches posted a while back on linux-ia64).

> Or maybe you're referring to something else.  Please let's stop playing
> question-and-answer.  Please provide sufficient information so that people
> can understand what you're saying.

In the case of x86_64 it is possible to drain pages from an area and then 
switch from a huge mapping to page size mappings for the leftover pages by 
creating the lower layer pte pages. Then these can be moved individually 
if we can stop kernel accesses (need to have a quiescent state on all 
processors for this IPI?) while switching the ptes.

AFAIK Virtual iron (last years OLS) simply used a virtual mapping for node 
unplug. They drained all the memory via swap and then creates a husk that
contained the remaining pages relocated to nodes still in use (I think 
they called it a Zombie node which continued to exist while pages were 
remaining or until the node was brought up again). 

> Again.  On the whole, that was a pretty useless email.  Please give us
> something we can use.

Well review the discussions that we had regarding Mel Gorman's defrag 
approaches. We discussed this in detail at the VM summit and decided to 
not create additional zones but instead separate the free lists. You and 
Linus seemed to be in agreement with this. I am a bit surprised .... 
Is this a Google effect?

Moreover the discussion here is only remotely connected to the issue at 
hand. We all agree that ZONE_DMA is bad and we want to have an alternate 
scheme. Why not continue making it possible to not compile ZONE_DMA 
dependent code into the kernel?

Single zone patches would increase VM performance. That would in turn 
make it more difficult to get approaches in that require multiple zones 
since the performance drop would be more significant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
