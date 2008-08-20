Message-ID: <48AC83CB.4000100@linux-foundation.org>
Date: Wed, 20 Aug 2008 15:51:23 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: sparsemem support for mips with highmem
References: <48A4AC39.7020707@sciatl.com>	<1218753308.23641.56.camel@nimitz>	<48A4C542.5000308@sciatl.com>	<20080815080331.GA6689@alpha.franken.de>	<1218815299.23641.80.camel@nimitz>	<48A5AADE.1050808@sciatl.com>	<20080815163302.GA9846@alpha.franken.de>	<48A5B9F1.3080201@sciatl.com>	<1218821875.23641.103.camel@nimitz>	<48A5C831.3070002@sciatl.com> <20080818094412.09086445.rdunlap@xenotime.net> <48A9E89C.4020408@linux-foundation.org> <48A9F047.7050906@cisco.com> <48AAC54D.8020609@linux-foundation.org> <48AB5959.6090609@cisco.com> <48AC231B.3090801@linux-foundation.org> <48AC7056.8070903@cisco.com>
In-Reply-To: <48AC7056.8070903@cisco.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David VomLehn <dvomlehn@cisco.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, C Michael Sundius <Michael.sundius@sciatl.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

David VomLehn wrote:
> 
> For a flat memory model, the page descriptors array memmap is
> contiguously allocated in low memory. For sparse memory, you only
> allocate memory to hold page descriptors that actually exist. If you
> don't enable CONFIG_SPARSEMEM_VMEMMAP, you introduce a level of
> indirection where the top bits of an address gives you an index into an
> array that points to an array of page descriptors for that section of
> memory. This has some performance impact relative to flat memory due to
> the extra memory access to read the pointer to the array of page
> descriptors.

Right.

> If you do enable CONFIG_SPARSEMEM_VMEMMAP, you still allocate memory to
> hold page descriptors, but you map that memory into virtual space so
> that a given page descriptor for a physical address is at the offset
> from the beginning of the virtual memmap corresponding to the page frame
> number of that address. This gives you a single memmap, just like you
> had in the flat memory case, though memmap now lives in virtual address
> space. Since memmap now lives in virtual address space, you don't need
> to use any memory to back the virtual addresses that correspond to the
> holes in your physical memory, which is how you save a lot of physical
> memory. The performance impact relative to flag memory is now that of
> having to go through the TLB to get to the page descriptor.

Correct.

> If you are using CONFIG_SPARSEMEM_VMEMMAP and the corresponding TLB
> entry is present, you expect this will be faster than the extra memory
> access you do when CONFIG_SPARSEMEM_VMEMMAP is not enabled, even if that
> memory is in cache. This seems like a pretty reasonable expectation to
> me. Since TLB entries cover much more memory than the cache, it also
> seems like there would be a much better chance that you already have the
> corresponding TLB entry than having the indirect memory pointer in
> cache. And, in the worst case, reading the TLB entry is just another
> memory access, so it's closely equivalent to not enabling
> CONFIG_SPARSEMEM_VMEMMAP.

Exactly.

> So, if I understand this right, the overhead on a MIPS processor using
> flat memory versus using sparse memory with CONFIG_SPARSEMEM_VMEMMAP
> enabled would be mostly the difference between accessing unmapped
> memory, which doesn't go through the TLB, and mapped memory, which does.
> Even though there is some impact due to TLB misses, this should be
> pretty reasonable. What a way cool approach!

Great. Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
