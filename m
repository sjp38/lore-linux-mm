Message-ID: <3CDAEDE0.E12583FB@linux-m68k.org>
Date: Thu, 09 May 2002 23:45:04 +0200
From: Roman Zippel <zippel@linux-m68k.org>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap 13a
References: <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org> <20020508224255.GM15756@holomorphy.com> <3CD9B42A.69D38522@linux-m68k.org> <20020509012929.GO15756@holomorphy.com> <3CDA6C8E.462A3AE5@linux-m68k.org> <20020509140943.GP15756@holomorphy.com> <3CDA9776.776CB406@linux-m68k.org> <20020509174221.GQ15756@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

William Lee Irwin III wrote:

> MEM_START would be the lowest physical address, not the lowest virtual.
> __va(PAGE_OFFSET + ((page - mem_map) << PAGE_SHIFT)) would yield
> garbage... Perhaps __pa(PAGE_OFFSET) would work while relaxing only the
> "memory starts at 0" precondition? It should come out to 0 for the
> architectures with memory starting at 0, and the other preconditions
> guarantee that it's the lowest physical, but that breaks if the lowest
> physical isn't mapped to PAGE_OFFSET...

Sigh...
Why do you insist on calculating with the physical address? PAGE_OFFSET
is already a virtual address and without CONFIG_DISCONTIGMEM the page at
PAGE_OFFSET always corresponds to memmap[0] (on every arch).

> > And it's not needed, why should the vm care about the physical memory
> > location?
> 
> VM is about translating virtual to physical, and so it must know
> something resembling the physical address of a page just to edit PTE's?

The vm doesn't manage the memory based on the physical address, so all
it needs are functions to convert to/from a physical address, it doesn't
care about the value itself.

I scratch the rest of mail and try describe the more general problem.
We have three possibilities to address a memory page: virtual address,
physical address and pgdat+index. In the simplest case we can map all
them linear for continuos memory configuration. Otherwise the mapping
between physical address and pgdat+index will always involve some lookup
mechanism. It's desirable to have at least one linear mapping, so the
virtual mapping should be aligned either to the physical address space
or the pgdat array(s). m68k does the latter, everyone else the first.
Now the archs or your general code has to provide mappings between every
address space, so we have now:
- virt_to_phys()/phys_to_virt()
- pfn_to_page()/page_to_pfn()
- virt_to_page()/page_to_virt^Wpage_addr()
Please take a look at asm-ppc/page.h:__va()/__pa(). Here you have an
example that even for linear mappings, we use some tricks to optimize
this. How do you want to generalize this? So every arch specifies how to
map between the address spaces and provides special functions to do the
mapping, what is now left for the generic code?
BTW 5 out of the 6 functions are currently defined by the archs, what
makes the 6th so special?
Highmem is the only special case, that can be handled by generic code,
because the basic problem is on every arch the same.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
