Date: Thu, 9 May 2002 10:42:21 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020509174221.GQ15756@holomorphy.com>
References: <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org> <20020508224255.GM15756@holomorphy.com> <3CD9B42A.69D38522@linux-m68k.org> <20020509012929.GO15756@holomorphy.com> <3CDA6C8E.462A3AE5@linux-m68k.org> <20020509140943.GP15756@holomorphy.com> <3CDA9776.776CB406@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3CDA9776.776CB406@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> I stated starting at 0 as one of the preconditions for page - mem_map
>> based calculations. The only missing piece of information is the
>> starting address, which is not very difficult to take care of so as
>> to relax this invariant (compilers *should* optimize out 0). Hence,
>> static inline void *page_address(struct page *page)
>> {
>>         return __va(MEM_START + ((page - mem_map) << PAGE_SHIFT));
>> }

On Thu, May 09, 2002 at 05:36:22PM +0200, Roman Zippel wrote:
> There is no generic MEM_START, but there is PAGE_OFFSET. Why don't you
> want to use this instead?

MEM_START would be the lowest physical address, not the lowest virtual.
__va(PAGE_OFFSET + ((page - mem_map) << PAGE_SHIFT)) would yield
garbage... Perhaps __pa(PAGE_OFFSET) would work while relaxing only the
"memory starts at 0" precondition? It should come out to 0 for the
architectures with memory starting at 0, and the other preconditions
guarantee that it's the lowest physical, but that breaks if the lowest
physical isn't mapped to PAGE_OFFSET...

William Lee Irwin III wrote:
>> Unfortunately there isn't a CONFIG_MEM_STARTS_AT_ZERO or a MEM_START.

On Thu, May 09, 2002 at 05:36:22PM +0200, Roman Zippel wrote:
> And it's not needed, why should the vm care about the physical memory
> location?

VM is about translating virtual to physical, and so it must know
something resembling the physical address of a page just to edit PTE's?


William Lee Irwin III wrote:
>> To date I've gotten very few and/or very unclear responses from arch
>> maintainers. I'm very interested in getting info from arches such as
>> this but have had approximately zero input along this front thus far.
>> Do you have any suggestions as to a decent course of action here? My
>> first thought is a small set of #defines in include/asm-*/param.h or
>> some appropriate arch header.

On Thu, May 09, 2002 at 05:36:22PM +0200, Roman Zippel wrote:
> What do you want to define there?

(1) ARCH_SLOW_ALU
	Address calculation doesn't win on some CPU's with ridiculously
	slow ALU's (well, slow relative to memory fetch)
(2) ARCH_DENSEMAPS_ZONES (probably better to define it elsewhere)
	MAP_NR_DENSE() makes address calculation schemes somewhat more
	expensive
(3) ARCH_REMAPS_DISCONTIG
	__va() and __pa() may do strange things when physical memory is
	mapped in a strange ways for virtual contiguity, don't mess
	with these guys
(4) ARCH_TRIVIAL_MEMORY_LAYOUT
	We're the super-easy case that nobody complains about =)


William Lee Irwin III wrote:
>> I believe the real issue is that architectures don't yet export enough
>> information to select the version they really want. There just aren't
>> enough variations on this theme to warrant doing this in arch code, and
>> I think I got some consensus on that by the mere acceptance of the
>> patch to remove ->virtual in most instances.

On Thu, May 09, 2002 at 05:36:22PM +0200, Roman Zippel wrote:
> The basic mechanism is often the same, that's true. The problem is to
> allow the archs an efficient conversion. Only the arch specific code
> knows how the memory is laid out and can use this information to
> optimize the conversion at compile time by making some of the variables
> constant. As soon as you have managed to generalize this, I'm sure
> highmem will be the only special case left you have to deal with.

This sounds like an important direction I should investigate then. I've
already got a notion of how highmem could be dealt with (c.f. indexing
into kmap pool post). I'll have to dig around to see what architectures
export and see what needs to be standardized for an address calculation 
scheme based on constructing the address with the help of those constants.


On Thu, May 09, 2002 at 05:36:22PM +0200, Roman Zippel wrote:
>> If we can agree on this much then can we start pinning down a more
>> precise method of selecting the method of address calculation? I'm
>> very interested in maintaining this code and making it suitable for
>> all architectures.

On Thu, May 09, 2002 at 05:36:22PM +0200, Roman Zippel wrote:
> Why is it so important to move it out of the arch code? The simple case
> is trivial enough to be copied around or maybe put some templates into
> asm-generic, but I'd prefer to leave the archs complete control about
> this.

mem_map was bloated to the point where highmem machines couldn't get
enough ZONE_NORMAL to boot. Control definitely needs to be exerted over
the space consumption of mem_map, and killing ->virtual wherever/whenever
possible is a large part of that. I even have some evidence that what
control of that space consumption there is now may still be insufficient.

asm-generic has the small problem that it divorces the format of struct
page from the definition of page_address(). Also, it shouldn't really be
optional; the VM should be given enough information to do the right thing.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
