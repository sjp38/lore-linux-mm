Date: Thu, 9 May 2002 16:13:09 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020509231309.GR15756@holomorphy.com>
References: <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org> <20020508224255.GM15756@holomorphy.com> <3CD9B42A.69D38522@linux-m68k.org> <20020509012929.GO15756@holomorphy.com> <3CDA6C8E.462A3AE5@linux-m68k.org> <20020509140943.GP15756@holomorphy.com> <3CDA9776.776CB406@linux-m68k.org> <20020509174221.GQ15756@holomorphy.com> <3CDAEDE0.E12583FB@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3CDAEDE0.E12583FB@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2002 at 11:45:04PM +0200, Roman Zippel wrote:
> I scratch the rest of mail and try describe the more general problem.
> We have three possibilities to address a memory page: virtual address,
> physical address and pgdat+index. In the simplest case we can map all
> them linear for continuos memory configuration. Otherwise the mapping
> between physical address and pgdat+index will always involve some lookup
> mechanism. It's desirable to have at least one linear mapping, so the
> virtual mapping should be aligned either to the physical address space
> or the pgdat array(s). m68k does the latter, everyone else the first.

I'm not entirely sure what you mean by "aligned to the pgdat array(s)".
I've poked around m68k arch code (esp. since sun3 is not the most
supported of the m68k platforms), and I wouldn't describe anything I
saw down there in those terms. Could you clarify this somewhat?


On Thu, May 09, 2002 at 11:45:04PM +0200, Roman Zippel wrote:
> Now the archs or your general code has to provide mappings between every
> address space, so we have now:
> - virt_to_phys()/phys_to_virt()
> - pfn_to_page()/page_to_pfn()
> - virt_to_page()/page_to_virt^Wpage_addr()
> Please take a look at asm-ppc/page.h:__va()/__pa(). Here you have an
> example that even for linear mappings, we use some tricks to optimize
> this. How do you want to generalize this? So every arch specifies how to
> map between the address spaces and provides special functions to do the
> mapping, what is now left for the generic code?

It seems reasonable to expect __va()/__pa() to come from arch code...

Maybe a more compelling example might be some of the trickery you
have in mind for optimizing page_address() on a per-arch basis? I'd
be very interested in seeing a bit of that, and it might give me
something to hold on to since I certainly saw nothing like that when
I genericized it. Believe it or not I'm willing to be convinced, I'm
just not going to change my mind without due cause. Also, why is it
attracting your attention? Is it creating significant overhead for you?


On Thu, May 09, 2002 at 11:45:04PM +0200, Roman Zippel wrote:
> BTW 5 out of the 6 functions are currently defined by the archs, what
> makes the 6th so special?
> Highmem is the only special case, that can be handled by generic code,
> because the basic problem is on every arch the same.

struct page is generic. That, and it consumes a great deal of memory,
and so must be closely controlled. I'm very intent on calculating
page_address() especially on those machines the majority of whose
kernel virtual address spaces are now consumed chiefly by mem_map.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
