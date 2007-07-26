Date: Thu, 26 Jul 2007 17:05:20 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 0/7] Sparsemem Virtual Memmap V5
Message-ID: <20070726080520.GA26394@linux-sh.org>
References: <exportbomb.1184333503@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <exportbomb.1184333503@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 13, 2007 at 02:34:37PM +0100, Andy Whitcroft wrote:
> However, if there is enough virtual space available and the arch
> already maps its 1-1 kernel space using TLBs (f.e. true of IA64
> and x86_64) then this technique makes SPARSEMEM lookups even more
> efficient than CONFIG_FLATMEM.  FLATMEM needs to read the contents
> of the mem_map variable to get the start of the memmap and then add
> the offset to the required entry.  vmemmap is a constant to which
> we can simply add the offset.
> 
This is something I've been debating how to make use of on SH, but I
haven't come to any good conclusions yet, so I think a brain-dump is in
order (MIPS will have the same concerns I suppose).

SH has lowmem (512M) directly accessible with physical/virtual and
cached/uncached simply being a matter of flipping high bits, there are no
TLBs for this space, as it's not really a translatable space in the
strictest sense of the word (we only end up taking page faults for user
addresses, special memory windows, and various other memory blocks --
include/asm-sh/io.h:__ioremap_mode() might serve as a good example). For
contiguous system memory it would be possible just to wrap the vmemmap
base to the beginning of P1 space and not worry about any of this.
However, for memories that exist outside of this space (whether it be
highmem or other nodes built on memories in different part of the address
space completely), it's still necessary to map with TLBs. Building a
vmemmap for lowmem would seem to be a waste of space, and it doesn't
really buy us anything that I can see. On the other hand, this is
something that's desirable for the other nodes or anything translatable
(ie, memories outside of the lowmem range) as it gives us the ability to
construct the memmap using large TLBs.

This is something that's fairly trivial to hack up with out-of-line
__page_to_pfn()/__pfn_to_page() as we can simply reference the vmemmap
for memory that is not in the low 512M and do the high bit mangling
otherwise (assuming we've populated it in a similar fashion), but I
wonder if that's the best way to approach this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
