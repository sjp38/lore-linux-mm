Date: Wed, 8 May 2002 14:34:52 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020508213452.GJ15756@holomorphy.com>
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3CD96CB1.4630ED48@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2002 at 08:21:37PM +0200, Roman Zippel wrote:
> I'd suggest, we move page_address to asm/page.h (as counterpart of
> virt_to_page). discontigmem configs can then use some more efficient
> table lookup. Other config usually want to implement it better as:
> #define page_address(page)	((((page) - mem_map) << PAGE_SHIFT) +
> PAGE_OFFSET)
> bye, Roman

Trouble is, there are only four different useful variations.

A:
static inline void *page_address(struct page *page)
{
	return __va((page - mem_map) << PAGE_SHIFT);
}

B:
static inline void *page_address(struct page *page)
{
	return page->virtual;
}

C:
static inline void *page_address(struct page *page)
{
	zone_t *zone = page_zone(page);
	return __va(((page - zone->zone_mem_map) << PAGE_SHIFT)
			+ zone->zone_start_paddr);
}

D:
static inline void *page_address(struct page *page)
{
	zone_t *zone = page_zone(page);

	return __va((UNMAP_NR_DENSE(page - zone->zone_mem_map) << PAGE_SHIFT)
			+ zone->zone_start_paddr);
}

Where A is fine without highmem or discontigmem, B is required any time
there is highmem, C is needed for discontiguous non-highmem, and D is
required for SGI-based discontigmem using MAP_NR_DENSE() to pack pages
from a discontiguous region into a single zone to avoid having mem_map
larger than the largest contiguous memory region or having too many zones
to be tractable. Also, C and D could be collapsed to one case if
UNMAP_NR_DENSE() is defined as an identity mapping for those not using it.
C and D are of course on the space conservation side of the time/space
tradeoff. (C is actually already needed on NUMA-Q.)

What I believe *really* needs to be straightened out here is how the
various architectures get to select their favorite variant.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
