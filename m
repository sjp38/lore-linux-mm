Date: Fri, 27 Oct 2006 19:04:52 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061027190452.6ff86cae.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
	<20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
	<45347288.6040808@yahoo.com.au>
	<Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
	<45360CD7.6060202@yahoo.com.au>
	<20061018123840.a67e6a44.akpm@osdl.org>
	<Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
	<20061026150938.bdf9d812.akpm@osdl.org>
	<Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Oct 2006 18:00:42 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> But I cannot find any justification in my contexts to complete work on 
> this functionality because plainly all the hardware that I use does not 
> have problem laden DMA controllers and works just fine with a single 
> zone.

How about memory hot-unplug?

The only feasible way we're going to implement that is to support it on
user allocations only.  IOW: for all those allocations which were performed
with __GFP_HIGHMEM.

(This is an overloading of the GFP_HIGHMEM concept, but it happens to be a
very accurate one.  Perhaps we should have a separate __GFP_UNPLUGGABLE).

> This includes x86_64, i386 and ia64 boxes that I test my patches on.
> I would have to find time to research this and test with such a device. 
> So far I have not found a way to justify taking time for that beyond the 
> initial RFC that I posted a while back.
> 
> > Or something like that.  Something which makes the mm easier to understand,
> > easier to maintain and faster.  Rather than harder to understand, harder to
> > maintain and faster.
> 
> The simplest approach is to allow configurations with a single zone. That 
> makes mm easier to understand, faster and maintainable. For that purpose 
> functionality provided by specialized zones like ZONE_HIGHMEM, ZONE_DMA32 
> and ZONE_DMA needs to be isolated and made configurable. I have done that 
> for HIGHEMEM and DMA32 and the code is in 2.6.19.
> 
> The point of the patches is to do the same thing for ZONE_DMA.
> 
> There are many other subsystems that add special DMA overhead like in the 
> slab allocators etc. On platforms that do not need ZONE_DMA we 
> currently just see empty counters, create dead slabs, have dead code etc. 
> This seems where I ran into trouble since it seems that you think it gets 
> too complicated to have the ability to compile a kernel without the 
> useless and problematic GFP_DMA. ZONE_DMA material.
> 
> I think just the opposite is happening. The patches separate out ZONE_DMA 
> functionality that is badly defined, not standardized, rarely used and has 
> caused lots of weird code in the kernel to be written. Ever seen the code 
> in some arches alloc_dma_coherent where they allocate a page and then 
> check if its in a certain range? If not more creative artistry follows.

One way to address the dma problem is to always split all memory into
log2(physical memory) zones.  So we have one zone for pages 0 and 1,
another zone for pages 2 and 3, another zone for pages 4, 5, 6, and 7,
another for pages 8, 9, 10, ...  15, etc.

So each zone represents one additional bit of physical address.  So a
device driver can just ask "give me a page below physical address N".

A 4GB machine would have 32-log2(PAGE_SIZE) = 20 zones.  We'd coalesce the
lowest 16MB, which takes us down to 8 zones.  13 zones on a 128GB machine. 
Did I do all the arith correctly?  If so, it sounds feasible.

So all the GFP_DMA/NORMAL/HIGHMEM/DMA32 stuff goes away in favour of
alloc_pages_below(int log2_address, int order) or whatever.

What effect would NUMA have on all this?   Not much, I suspect.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
