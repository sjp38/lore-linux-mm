Date: Fri, 10 May 2002 09:28:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020510162824.GV15756@holomorphy.com>
References: <20020509231309.GR15756@holomorphy.com> <Pine.LNX.4.21.0205101324260.32715-100000@serv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0205101324260.32715-100000@serv>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2002 at 01:37:50PM +0200, Roman Zippel wrote:
> Mapping everything into a single virtual area, so that the virtual address
> can be used as a index in the memmap array, e.g.
> #define virt_to_page(kaddr)	(mem_map + (((unsigned long)(kaddr)-PAGE_OFFSET) >> PAGE_SHIFT))
> #define page_to_virt(page)	((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)

This appears to be calculating it from a physical address...


On Thu, 9 May 2002, William Lee Irwin III wrote:
>> It seems reasonable to expect __va()/__pa() to come from arch code...

On Fri, May 10, 2002 at 01:37:50PM +0200, Roman Zippel wrote:
> A generic conversion function could look like:
> table[(addr >> shift) & mask] + addr;
> You have here three possible variables: table, shift and mask. If you know
> enough about the memory configuration, you can make them constants. On
> m68k I maybe can make table and mask constants, the shift had to be
> patched into the kernel. In this case it's quite simple, as it has to be
> loaded into a register anyway this is enough:
> static inline int getshift(void) __attribute__ ((const));
> #define shift getshift()
> In the ppc example I mentioned it's not that easy, because the instruction
> has to be patched, which does the operation, so the generic operation:
> #define ___pa(vaddr) ((vaddr)-PPC_MEMOFFSET)
> becomes
> #define ___pa(vaddr) (ADD(vaddr, PPC_MEMOFFSET))
> ADD() would do the magic you see in asm-ppc/page.h.
> For the lookup function above this means it becomes:
> TABLE(SHIFT_AND(addr, shift, mask)) + addr
> so that every operation could be directly patched.

This is the most interesting part, and appears very easy to genericize;
I can produce this in short order unless you have a particular interest
in doing it yourself (or have a patch waiting in the wings already).


On Thu, 9 May 2002, William Lee Irwin III wrote:
>> Also, why is it
>> attracting your attention? Is it creating significant overhead for you?

On Fri, May 10, 2002 at 01:37:50PM +0200, Roman Zippel wrote:
> The current page_addr started it.

This seems begs the question.


On Fri, May 10, 2002 at 01:37:50PM +0200, Roman Zippel wrote:
> IMO it's better to just define it as:
> #ifdef CONFIG_HIGHMEM
> #define page_addr(p)	((p)->virtual)
> #else
> #define page_addr(p)	page_to_virt(p)
> #endif

Highmem machines are the ones needing the space conservation the most,
yet they're the only ones who aren't allowed to omit ->virtual. There
is some irony here...


On Fri, May 10, 2002 at 01:37:50PM +0200, Roman Zippel wrote:
> or if you don't want the virtual member:
> #define page_addr(p)	(is_highpage(p) ? highpage_to_virt(p) : page_to_virt(p))
> If I understand you correctly, the highpage_to_virt() function is what you
> are really interested in.

Not entirely. I'm very much in favor of space conservation even beyond
the particular interest of i386 highmem. I would like to kill ->virtual
entirely except as a very rarely used helper for superslow ALU's.

Maybe I should turn the question around instead, so I understand your
motivation better:
Why are you trying to hide physical addresses from the VM?


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
