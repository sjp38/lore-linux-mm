Date: Fri, 27 Oct 2006 18:00:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <20061026150938.bdf9d812.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
 <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
 <45347288.6040808@yahoo.com.au> <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
 <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org>
 <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
 <20061026150938.bdf9d812.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Oct 2006, Andrew Morton wrote:

> I really really want to drop all those patches[1] and rethink it all.

I think it would be good to do drop it. That may allow a consolidation of 
the patches after the experience we have had so far with it but there is 
also the danger that I may have to drop it completely for now since the 
project is getting to be too much of an effort. Having to repeat the same 
arguments is not that productive.

Note that the zone_table work is independent from the ZONE_DMA work. 
So please keep the get-rid-of-zone_table.patch. Just drop the rest.

get-rid-of-zone_table-fix-3.patch is not really a fix for the zone_table 
patch but addresses an issue created by the optional zone_dma patch.

> Like...  would it make sense to eliminate the hard-coded concepts of DMA,
> DMA32, NORMAL and HIGHMEM and simply say "we support 1 to N zones" per
> node?  Obviously we'd need to keep the DMA/NORMAL/HIGHMEM nomenclature in
> the interfaces so the rest of the kernel builds and works, but the core mm
> just shouldn't need to care: all it cares about is one or more zones.

Ok. Recap of some of the earlier discussion:

- DMA has no clearly defined boundaries. They vary according to arch
  and many arches / platforms depend on particular ZONE_DMA semantics.
- DMA32 is only supported for x86_64 and has a particular role
  to play there.
- Highmem requires special treatment with kmap that is different from 
  all others.

In order to have N zones (I think you would want that to cover 
different restricted DMA areas?) one would need to have some sort of 
standard definition and purposes for those N zones. They would need to be 
able to be treated in the same way. For the ZONE_DMAxx zones you may be 
able to get there. HIGHMEM is definitely much different.

Then you would probably want to support the dma_mask supported by the SCSI 
subsystem and dma_alloc_coherent functions to allow arbitrary bitmasks. In 
order to support that with zones we would need a large quantity of those 
or a way to dynamically create zones. I am pretty sure this will not 
simplify mm. There is a potential here for increasing fragmentation and 
getting into complicated load balancing situations between the zones.

A number of architectures and platforms (I think we are up to 8 
to 10 or so?) do not need what ZONE_DMA provides and can avoid having to 
deal with this mess right now if we allow an opt out as provided by my 
current patches in mm. No additional measures would be needed.

For those platforms that still need the abiltity to allocate from a 
subse of memory it would be possible to provide a page allocator 
function where one can specify an allowed memory range. That would 
avoid the need for various DMA style zones.

But I cannot find any justification in my contexts to complete work on 
this functionality because plainly all the hardware that I use does not 
have problem laden DMA controllers and works just fine with a single 
zone. This includes x86_64, i386 and ia64 boxes that I test my patches on.
I would have to find time to research this and test with such a device. 
So far I have not found a way to justify taking time for that beyond the 
initial RFC that I posted a while back.

> Or something like that.  Something which makes the mm easier to understand,
> easier to maintain and faster.  Rather than harder to understand, harder to
> maintain and faster.

The simplest approach is to allow configurations with a single zone. That 
makes mm easier to understand, faster and maintainable. For that purpose 
functionality provided by specialized zones like ZONE_HIGHMEM, ZONE_DMA32 
and ZONE_DMA needs to be isolated and made configurable. I have done that 
for HIGHEMEM and DMA32 and the code is in 2.6.19.

The point of the patches is to do the same thing for ZONE_DMA.

There are many other subsystems that add special DMA overhead like in the 
slab allocators etc. On platforms that do not need ZONE_DMA we 
currently just see empty counters, create dead slabs, have dead code etc. 
This seems where I ran into trouble since it seems that you think it gets 
too complicated to have the ability to compile a kernel without the 
useless and problematic GFP_DMA. ZONE_DMA material.

I think just the opposite is happening. The patches separate out ZONE_DMA 
functionality that is badly defined, not standardized, rarely used and has 
caused lots of weird code in the kernel to be written. Ever seen the code 
in some arches alloc_dma_coherent where they allocate a page and then 
check if its in a certain range? If not more creative artistry follows.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
