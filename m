Received: from sgi.com (SGI.COM [192.48.153.1] (may be forged))
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA19281
	for <Linux-MM@kvack.org>; Fri, 12 Feb 1999 15:08:44 -0500
Date: Fri, 12 Feb 1999 11:59:32 -0800
From: kanoj@kulten.engr.sgi.com (Kanoj Sarcar)
Message-Id: <9902121159.ZM19605@kulten.engr.sgi.com>
In-Reply-To: Jakub Jelinek <jj@sunsite.ms.mff.cuni.cz>
        "Re: (ia32) vmalloc/ioremap" (Feb 12,  7:00am)
References: <199902120600.HAA26089@sunsite.mff.cuni.cz>
Subject: Re: (ia32) vmalloc/ioremap
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: kanoj@kulten.engr.sgi.com, Jakub Jelinek <jj@sunsite.ms.mff.cuni.cz>, Linux-MM@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Feb 12,  7:00am, Jakub Jelinek wrote:
> Subject: Re: (ia32) vmalloc/ioremap
> >
> > Hi,
> >
> > Has anyone noticed that vmalloc()/ioremap() seem to be
> > overly complicated procedures? Basically, vmalloc_area_pages()/
> > remap_area_pages() might be getting called on an until now unused
> > kernel virtual address, for which a kernel page table needs to be
> > allocated. set_pgdir() takes care of this by:
> > 1. updating the page directory of each running task.
> > 2. updating the cached free page directories on each cpu.
> >
> > It seems to me that we could do away with the complexity of set_pgdir
> > if we were to allocate a few kernel page tables at kernel startup
> > time, have the kernel page directory entries for swapper_pg_dir
> > mapping the vmalloc area point to these kernel page tables and have
> > those be copied to every new page directory in the system. Of course,
> > the whole vmalloc area (VMALLOC_START .. VMALLOC_END) would take too
> > many kernel page tables probably, so we would need to resize the
> > vmalloc area to something more easily handled, say 32M on a 64M
> > system (or any other heuristic), which requires 8 kernel page table
> > pages.
>
> Huh? There are several places which need larger vmalloc area, so even if
> you'd preallocated some vmalloc pgdirs, you could easily run out of them and
> would need exactly the same set_pgdir() to allocate further pgdirs.
> If you preallocate 8 pgdirs, then the current scheme will do set_pgdir 8
> times... What's the problem? It is usually not speed critical.
> Not to say that with nice MMU you don't have to suffer from such complexity
> at all.

Note that there's already a limit on vmalloc space, 64Mb (VMALLOC_RESERVE).
The question is, how much is right? (if you are not happy with 32M, lets go
with 64Mb for now). I would tend to believe that "bigger" (more cpu/more
memory)
systems would need more vmalloc space, but unfortunately, the more memory
you have, the lesser the vmalloc space becomes.

Can you give examples of code that uses huge vmalloc space? How do these
work in 64Mb vmalloc configs? I did some searching in the source to see
how vmalloc was being used, but the only parts that I recognized were doing
allocation on the order of a few pages. A related question is, why would
vmalloc be preferred over kmalloc, except for high memory mappings (ioremap),
specially given the tlb flushing involved?

As to why the current implementation of set_pgdir() is a problem, it
holds the tasklist_lock(), basically locking out other cpus that might
be in schedule(). Other than that, there is the added overhead of having
to go thru the entire task list while doing the vmalloc (as you point
out, speed is not critical probably). Allocating 12 (48Mb vmalloc) or
16 (64Mb vmalloc) kernel page tables in paging_init/mem_init would allow
us to make the ia32 specific set_pgdir() do nothing (basically a null
macro), and this could be adopted for some other architecture too.

I am trying to code something up and post a patch, maybe people can
look at it and comment whether the code/behavior will be "better" than
at it is now.

Thanks.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
