Message-ID: <3CDA9776.776CB406@linux-m68k.org>
Date: Thu, 09 May 2002 17:36:22 +0200
From: Roman Zippel <zippel@linux-m68k.org>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap 13a
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org> <20020508224255.GM15756@holomorphy.com> <3CD9B42A.69D38522@linux-m68k.org> <20020509012929.GO15756@holomorphy.com> <3CDA6C8E.462A3AE5@linux-m68k.org> <20020509140943.GP15756@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

William Lee Irwin III wrote:

> I stated starting at 0 as one of the preconditions for page - mem_map
> based calculations. The only missing piece of information is the
> starting address, which is not very difficult to take care of so as
> to relax this invariant (compilers *should* optimize out 0). Hence,
> 
> static inline void *page_address(struct page *page)
> {
>         return __va(MEM_START + ((page - mem_map) << PAGE_SHIFT));
> }

There is no generic MEM_START, but there is PAGE_OFFSET. Why don't you
want to use this instead?

> Unfortunately there isn't a CONFIG_MEM_STARTS_AT_ZERO or a MEM_START.

And it's not needed, why should the vm care about the physical memory
location?

> To date I've gotten very few and/or very unclear responses from arch
> maintainers. I'm very interested in getting info from arches such as
> this but have had approximately zero input along this front thus far.
> Do you have any suggestions as to a decent course of action here? My
> first thought is a small set of #defines in include/asm-*/param.h or
> some appropriate arch header.

What do you want to define there?

> I believe the real issue is that architectures don't yet export enough
> information to select the version they really want. There just aren't
> enough variations on this theme to warrant doing this in arch code, and
> I think I got some consensus on that by the mere acceptance of the
> patch to remove ->virtual in most instances.

The basic mechanism is often the same, that's true. The problem is to
allow the archs an efficient conversion. Only the arch specific code
knows how the memory is laid out and can use this information to
optimize the conversion at compile time by making some of the variables
constant. As soon as you have managed to generalize this, I'm sure
highmem will be the only special case left you have to deal with.

> If we can agree on this much then can we start pinning down a more
> precise method of selecting the method of address calculation? I'm
> very interested in maintaining this code and making it suitable for
> all architectures.

Why is it so important to move it out of the arch code? The simple case
is trivial enough to be copied around or maybe put some templates into
asm-generic, but I'd prefer to leave the archs complete control about
this.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
