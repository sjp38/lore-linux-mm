Date: Sat, 23 Sep 2006 18:56:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: One idea to free up page flags on NUMA
In-Reply-To: <1159039469.24331.32.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0609231847520.16383@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com>
 <200609231804.40348.ak@suse.de>  <Pine.LNX.4.64.0609230937140.15303@schroedinger.engr.sgi.com>
 <1159039469.24331.32.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Sat, 23 Sep 2006, Dave Hansen wrote:

> I'm not sure to what sparse overhead you are referring.  Its only
> storage overhead is one pointer per SECTION_SIZE bytes of memory.  The
> worst case scenario is 16MB sections on ppc64 with 16TB of memory.  

The problem is that these arrays frequently referenced. They increase
the VM overhead and if we already have page table in place then its easy
to just use the format of the page tables for sparse like memory 
functionality.

> 2^20 sections * 2^3 bytes/pointer = 2^23 bytes of sparse overhead, which
> is 8MB.  That's pretty little overhead no matter how you look at it,
> cache footprint, tlb load, etc...  Add to that the fact that we get some
> extra things from sparsemem like pfn_valid() and the bookkeeping for
> whether or not the memory is there (before the mem_map is actually
> allocated), and it doesn't look too bad.

Page table also provide the same functionality. There is a present bit
etc. Simulation of core MMU functionality is certainly not faster than
using the cpu MMU engines.

> If someone can actually demonstrate some actual, measurable performance
> problem with it, then I'm all ears.  I worry that anything else is just
> potential overzealous micro-optimization trying to solve problems that
> don't really exist.  Remember, sparsemem slightly beats discontigmem on
> x86 NUMA hardware, so it isn't much of a dog to begin with.

Yes it may beat it if you use 4k page sizes for it and if you are
wasting additional TLB entries for it. If we are already using a page
table for memory then this can only be better than managing tables on your 
own.

> Sparsemem is a ~100 line patch to port to a new architecture.  That code
> is virtually all #defines and hooking into the pfn_to_page() mechanisms.
> There's virtually no logic in there.  That's going to be hard to beat
> with any kind of vmem_map[] approach.

Well we already have page tables there. Its just a matter of reserving
a virtual memory area for the virtual memmap and changing some page table
entries. Then one can get rid of the sparse tables and simply use
existing non sparse virt_to_page and page_address() (have a look how ia64 
does it). The main problem with sparsemem is in that situation is that we 
uselessly have additional tables that waste cachelines plus we use a 
series of bits in page flags that could be used for better purposes.

If sparse would use the native page table format then you can use that to 
plug memory in and out. From what I can tell there is the same information 
in those tables. virt_to_page and page_address are really fast without 
table lookups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
