Message-ID: <46B3424F.7010800@shadowen.org>
Date: Fri, 03 Aug 2007 15:57:19 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] vmemmap: pull out the vmemmap code into its own file
References: <exportbomb.1186045945@pinky> <E1IGWw3-0002Xr-Dm@hellhawk.shadowen.org> <20070802132621.GA9511@infradead.org> <Pine.LNX.4.64.0708021220220.7948@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708021220220.7948@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 2 Aug 2007, Christoph Hellwig wrote:
> 
>> On Thu, Aug 02, 2007 at 10:25:35AM +0100, Andy Whitcroft wrote:
>>> + * Special Kconfig settings:
>>> + *
>>> + * CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
>>> + *
>>> + * 	The architecture has its own functions to populate the memory
>>> + * 	map and provides a vmemmap_populate function.
>>> + *
>>> + * CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD
> 
> ?? Why was this added? The arch can populate the PMDs on its own already 
> if CONFIG_ARCH_SPARSEMEM_VMEMMAP is set.

The defines are essentially the ones which were in the V3 version of
VMEMMAP I picked up from you.  They had slightly different names:

 * CONFIG_ARCH_POPULATES_VIRTUAL_MEMMAP
 * CONFIG_ARCH_SUPPORTS_PMD_MAPPING

The names were changed based on the PMD support not really being
generic, and to better then describe what they did.  We still have the
same three options.

>> This is the kinda of mess I mean.  Which architecturs set either of these
>> and why?  This code would be a lot more acceptable if we hadn't three
>> different variants of the arch interface.
> 
> Initially at least my scheme was the following:
> 
> In general the sparsemem code can take care of a vmemmap that is using a 
> section of the vmalloc space. In that case no arch code is needed to 
> populate the vmemmap. Typical use is by arches with large pages (like 
> IA64). This is the default if no other options are set and can simply be 
> enabled by defining some constants in the arch code to reserve a section 
> of the vmalloc space.
> 
> Then there is the option of using the PMD to map a higher order page. This 
> can also be done transparently and is used by arches that have this 
> capability and a small page size. Those arches also require no additional 
> code to populate their vmemmap. This is true f.e. for i386 and x86_64. 
> These have to set CONFIG_ARCH_SUPPORTS_PMD_MAPPING
> 
> Then there are arches that have the vmemmap in non standard ways. Memory 
> may not be taken from the vmalloc space, special flags may have to be set 
> for the page tables (or one may use a different mechanism for mapping). 
> Those arches have to set CONFIG_ARCH_POPULATES_VIRTUAL_MEMMAP. In that 
> case the arch must provide its own function to populate the memory map.

Yes in my view there is two parts to VMEMMAP.  There is the runtime side
which is common to all architectures using the single virtually mapped
mem_map using the simple addition accessors, none of these options alter
the post-init behaviour of VMEMMAP.  Then there is the initialisation
side, all of the configuration options here pertain to how that
initialisation is done.

There are three basic options:

1) it can be completely generic in that we use base pages mapped using
regular PTE's, or
2) the architecture can supply a PMD level initialiser, or
3) the architecture can supply a vmemmap_populate initialise which
instantiates the entire map.

As the PMD initialisers are only used by x86_64 we could make it supply
a complete vmemmap_populate level initialiser but that would result in
us duplicating the PUD level initialier function there which seems like
a bad idea.

I have been looking at a rejig of the configuration options to make them
all positive, so that you only have to assert a single VMEMMAP_* define
to get the correct code.  But that does not really get rid of the defines.

The code as it stands would allow for us to pull out the "PTE/PMD"
initialiser from the vmemmap code and allow the architecture to select
it as a helper, it living in its own file again.  But that seems excessive.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
