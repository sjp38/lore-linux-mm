Date: Thu, 2 Aug 2007 12:28:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] vmemmap: pull out the vmemmap code into its own file
In-Reply-To: <20070802132621.GA9511@infradead.org>
Message-ID: <Pine.LNX.4.64.0708021220220.7948@schroedinger.engr.sgi.com>
References: <exportbomb.1186045945@pinky> <E1IGWw3-0002Xr-Dm@hellhawk.shadowen.org>
 <20070802132621.GA9511@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Christoph Hellwig wrote:

> On Thu, Aug 02, 2007 at 10:25:35AM +0100, Andy Whitcroft wrote:
> > + * Special Kconfig settings:
> > + *
> > + * CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
> > + *
> > + * 	The architecture has its own functions to populate the memory
> > + * 	map and provides a vmemmap_populate function.
> > + *
> > + * CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD

?? Why was this added? The arch can populate the PMDs on its own already 
if CONFIG_ARCH_SPARSEMEM_VMEMMAP is set.

> This is the kinda of mess I mean.  Which architecturs set either of these
> and why?  This code would be a lot more acceptable if we hadn't three
> different variants of the arch interface.

Initially at least my scheme was the following:

In general the sparsemem code can take care of a vmemmap that is using a 
section of the vmalloc space. In that case no arch code is needed to 
populate the vmemmap. Typical use is by arches with large pages (like 
IA64). This is the default if no other options are set and can simply be 
enabled by defining some constants in the arch code to reserve a section 
of the vmalloc space.

Then there is the option of using the PMD to map a higher order page. This 
can also be done transparently and is used by arches that have this 
capability and a small page size. Those arches also require no additional 
code to populate their vmemmap. This is true f.e. for i386 and x86_64. 
These have to set CONFIG_ARCH_SUPPORTS_PMD_MAPPING

Then there are arches that have the vmemmap in non standard ways. Memory 
may not be taken from the vmalloc space, special flags may have to be set 
for the page tables (or one may use a different mechanism for mapping). 
Those arches have to set CONFIG_ARCH_POPULATES_VIRTUAL_MEMMAP. In that 
case the arch must provide its own function to populate the memory map.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
