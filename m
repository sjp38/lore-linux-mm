Date: Thu, 9 May 2002 07:09:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020509140943.GP15756@holomorphy.com>
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org> <20020508224255.GM15756@holomorphy.com> <3CD9B42A.69D38522@linux-m68k.org> <20020509012929.GO15756@holomorphy.com> <3CDA6C8E.462A3AE5@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3CDA6C8E.462A3AE5@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> It's not only i386. Other architectures are able to do likewise if
>> they satisfy the preconditions. And this is exactly one of four
>> variations, where all four together are able to handle all cases.
>> (In fact, just reverting to B works as a catch-all.)

On Thu, May 09, 2002 at 02:33:18PM +0200, Roman Zippel wrote:
> Your preconditions were no CONFIG_DISCONTIGMEM and no CONFIG_HIGHMEM.
> This is true for m68k, but it still breaks every single of your
> assumptions, but even on other archs where do these preconditions
> require physical memory to start at 0?

I stated starting at 0 as one of the preconditions for page - mem_map
based calculations. The only missing piece of information is the
starting address, which is not very difficult to take care of so as
to relax this invariant (compilers *should* optimize out 0). Hence,

static inline void *page_address(struct page *page)
{
	return __va(MEM_START + ((page - mem_map) << PAGE_SHIFT));
}

Unfortunately there isn't a CONFIG_MEM_STARTS_AT_ZERO or a MEM_START.
To date I've gotten very few and/or very unclear responses from arch
maintainers. I'm very interested in getting info from arches such as
this but have had approximately zero input along this front thus far.
Do you have any suggestions as to a decent course of action here? My
first thought is a small set of #defines in include/asm-*/param.h or
some appropriate arch header.


On Thu, May 09, 2002 at 02:33:18PM +0200, Roman Zippel wrote:
> It's really not m68k specific. You are trying to generalize a very small
> part of the whole problem. First you only take some special cases (A.
> and B.) and the rest was completely arch specific so far. You have to
> define the complete model of how virtual and physical addresses and the
> pgdat/index tuple relate to each other, before you can generalize
> something of it. So far it was completely up to the archs to define this
> relationship with only little assumptions from the generic code.

I think you're overestimating how much there is to do here. It is either
inefficient to calculate the address due to the deep arch issues (e.g.
a low-level virtual remapping to crossdress ridiculously discontiguous
memory maps) or the invariants with zones and/or mem_map make it easy.
The only instances in which a zone is not a physically contiguous range
of memory with a corresponding contiguous range of virtual memory to
map it are CONFIG_HIGHMEM, SGI's CONFIG_DISCONTIGMEM, and architectures
with memory so discontiguous they remap everything for virtual contiguity.
The general CONFIG_DISCONTIGMEM case does not distinguish between
MAP_NR_DENSE() being present and/or an identity mapping and MAP_NR_DENSE()
being there and doing something, so I'm missing information on high-end
machines as well.

I believe the real issue is that architectures don't yet export enough
information to select the version they really want. There just aren't
enough variations on this theme to warrant doing this in arch code, and
I think I got some consensus on that by the mere acceptance of the
patch to remove ->virtual in most instances.

If we can agree on this much then can we start pinning down a more
precise method of selecting the method of address calculation? I'm
very interested in maintaining this code and making it suitable for
all architectures.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
