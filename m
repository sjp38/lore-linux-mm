Date: Fri, 10 May 2002 13:37:50 +0200 (CEST)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [PATCH] rmap 13a
In-Reply-To: <20020509231309.GR15756@holomorphy.com>
Message-ID: <Pine.LNX.4.21.0205101324260.32715-100000@serv>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 9 May 2002, William Lee Irwin III wrote:

> > We have three possibilities to address a memory page: virtual address,
> > physical address and pgdat+index. In the simplest case we can map all
> > them linear for continuos memory configuration. Otherwise the mapping
> > between physical address and pgdat+index will always involve some lookup
> > mechanism. It's desirable to have at least one linear mapping, so the
> > virtual mapping should be aligned either to the physical address space
> > or the pgdat array(s). m68k does the latter, everyone else the first.
> 
> I'm not entirely sure what you mean by "aligned to the pgdat array(s)".

Mapping everything into a single virtual area, so that the virtual address
can be used as a index in the memmap array, e.g.
#define virt_to_page(kaddr)	(mem_map + (((unsigned long)(kaddr)-PAGE_OFFSET) >> PAGE_SHIFT))
#define page_to_virt(page)	((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)

> I've poked around m68k arch code (esp. since sun3 is not the most
> supported of the m68k platforms), and I wouldn't describe anything I
> saw down there in those terms. Could you clarify this somewhat?

sun3 doesn't has to deal with discontinuous memory, so you have to look at
the motorola code.

> It seems reasonable to expect __va()/__pa() to come from arch code...

But you cannot seperate this, all the conversion functions relate to each
other.

> Maybe a more compelling example might be some of the trickery you
> have in mind for optimizing page_address() on a per-arch basis? I'd
> be very interested in seeing a bit of that, and it might give me
> something to hold on to since I certainly saw nothing like that when
> I genericized it. Believe it or not I'm willing to be convinced, I'm
> just not going to change my mind without due cause.

A generic conversion function could look like:

table[(addr >> shift) & mask] + addr;

You have here three possible variables: table, shift and mask. If you know
enough about the memory configuration, you can make them constants. On
m68k I maybe can make table and mask constants, the shift had to be
patched into the kernel. In this case it's quite simple, as it has to be
loaded into a register anyway this is enough:

static inline int getshift(void) __attribute__ ((const));
#define shift getshift()

In the ppc example I mentioned it's not that easy, because the instruction
has to be patched, which does the operation, so the generic operation:

#define ___pa(vaddr) ((vaddr)-PPC_MEMOFFSET)

becomes

#define ___pa(vaddr) (ADD(vaddr, PPC_MEMOFFSET))

ADD() would do the magic you see in asm-ppc/page.h.

For the lookup function above this means it becomes:

TABLE(SHIFT_AND(addr, shift, mask)) + addr

so that every operation could be directly patched.

> Also, why is it
> attracting your attention? Is it creating significant overhead for you?

The current page_addr started it.
IMO it's better to just define it as:

#ifdef CONFIG_HIGHMEM
#define page_addr(p)	((p)->virtual)
#else
#define page_addr(p)	page_to_virt(p)
#endif

or if you don't want the virtual member:

#define page_addr(p)	(is_highpage(p) ? highpage_to_virt(p) : page_to_virt(p))

If I understand you correctly, the highpage_to_virt() function is what you
are really interested in.

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
