Received: by rv-out-0708.google.com with SMTP id f25so619438rvb.26
        for <linux-mm@kvack.org>; Sun, 04 May 2008 11:44:39 -0700 (PDT)
Message-ID: <86802c440805041144n6fd17b06k23d1e5d53122e21c@mail.gmail.com>
Date: Sun, 4 May 2008 11:44:39 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [RFC 0/2] Rootmem: boot-time memory allocator
In-Reply-To: <87lk2qt75m.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080503152502.191599824@symbol.fehenstaub.lan>
	 <20080503175426.GB5292@elte.hu>
	 <86802c440805032106t4d020838v39aaf93309003cdb@mail.gmail.com>
	 <87hcdev448.fsf@saeurebad.de> <87r6citaqg.fsf@saeurebad.de>
	 <87lk2qt75m.fsf@saeurebad.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, May 4, 2008 at 8:34 AM, Johannes Weiner <hannes@saeurebad.de> wrote:
>
> Hi,
>
>  Johannes Weiner <hannes@saeurebad.de> writes:
>
>  > Hi Yinghai,
>  >
>  > Johannes Weiner <hannes@saeurebad.de> writes:
>  >
>  >> Hi,
>  >>
>  >> "Yinghai Lu" <yhlu.kernel@gmail.com> writes:
>  >>
>  >>> On Sat, May 3, 2008 at 10:54 AM, Ingo Molnar <mingo@elte.hu> wrote:
>  >>>>
>  >>>>  * Johannes Weiner <hannes@saeurebad.de> wrote:
>  >>>>
>  >>>>  > I was spending some time and work on the bootmem allocator the last
>  >>>>  > few weeks and came to the conclusion that its current design is not
>  >>>>  > appropriate anymore.
>  >>>>  >
>  >>>>  > As Ingo said in another email, NUMA technologies will become weirder,
>  >>>>  > nodes whose PFNs span other nodes for example and it makes bootmem
>  >>>>  > code become an unreadable mess.
>  >>>>  >
>  >>>>  > So I sat down two days ago and rewrote the allocator, here is the
>  >>>>  > result: rootmem!
>  >>>>
>  >>>>  hehe :-)
>  >>>>
>  >>>>
>  >>>>  > The biggest difference to the old design is that there is only one
>  >>>>  > bitmap for all PFNs of all nodes together, so the overlapping PFN
>  >>>>  > problems simply dissolve and fun like allocations crossing node
>  >>>>  > boundaries work implicitely.  The new API requires every node used by
>  >>>>  > the allocator to be registered and after that the bitmap gets
>  >>>>  > allocated and the allocator enabled.
>  >>>>  >
>  >>>>  > I chose to add a new allocator rather than replacing bootmem at once
>  >>>>  > because that would have required all callsites to switch in one go,
>  >>>>  > which would be a lot.  The new allocator can be adopted more slowly
>  >>>>  > and I added a compatibility API for everything besides actually
>  >>>>  > setting up the allocator.  When the last user dies, bootmem can be
>  >>>>  > dropped completely (including pgdat->bdata, whee..)
>  >>>>  >
>  >>>>  > The main ideas from bootmem have been stolen^W preserved but the new
>  >>>>  > design allowed me to shrink the code a lot and express things more
>  >>>>  > simple and clear:
>  >>>>  >
>  >>>>  > $ sloc.awk < mm/bootmem.c
>  >>>>  > 455 lines of code, 65 lines of comments (520 lines total)
>  >>>>  >
>  >>>>  > $ sloc.awk < mm/rootmem.c
>  >>>>  > 243 lines of code, 96 lines of comments (339 lines total)
>  >>>>
>  >>>>  amazing!
>  >>>>
>  >>>>  i'd still suggest to keep it all named bootmem though :-/ How about
>  >>>>  bootmem2.c and then renaming it back to bootmem.c, once the last user is
>  >>>>  gone? That would save people from having to rename whole chapters in
>  >>>>  entire books ;-)
>  >>>
>  >>> for spanning support node0:0-2g, 4-6g; node1: 2-4g, 6-8g, could have
>  >>> some problem.
>  >>
>  >> Could you eleborate on that?
>  >>
>  >>> +/*
>  >>> + * rootmem_register_node - register a node to rootmem
>  >>> + * @nid: node id
>  >>> + * @start: first pfn on the node
>  >>> + * @end: first pfn after the node
>  >>> + *
>  >>> + * This function must not be called anymore if the allocator
>  >>> + * is already up and running (rootmem_setup() has been called).
>  >>> + */
>  >>> +void __init rootmem_register_node(int nid, unsigned long start,
>  >>> +                       unsigned long end)
>  >>> +{
>  >>> +       BUG_ON(rootmem_functional);
>  >>> +
>  >>> +       if (start < rootmem_min_pfn)
>  >>> +               rootmem_min_pfn = start;
>  >>> +       if (end > rootmem_max_pfn)
>  >>> +               rootmem_max_pfn = end;
>  >>> +
>  >>> +       rootmem_node_pages[nid] = end - start;
>  >>> +       rootmem_node_offsets[nid] = start;
>  >>> +       rootmem_nr_nodes++;
>  >>> +}
>  >>>
>  >>> could change rootmem_node_pages/offsets to be struct array with
>  >>> offset, pages, and nid. and every node could several struct. and whole
>  >>> array should be sorted with nid.
>
>  In the long term, this would have to be implemented no matter if
>  rootmem/bootmem2 gets merged or not, because bootmem suffers the same
>  problem, right?
>
>
>  >> The whole point is to be agnostic about weird NUMA configs.  Right now,
>  >> I am pretty proud of the simple data structures and I would avoid
>  >> blowing them up again unless there is a hard reason to do so.
>
>  This is non-helping crap, please excuse me.
>
>
>  > One thing I have found is that __rootmem_alloc_node can not garuantee
>  > that the memory it returns is on the requested node right now.
>
>  Hm, we have two choices: Either we introduce a new API that requests the
>  arch code to register not only node ranges but also subranges on that
>  node, or we won't garuantee that you get all memory on the node you
>  specified.  Correct?
>
>  The first option would be what you have proposed, I think.

1. current bootmem, add not_used_map to bdata.
2. or in bootmem2, use pages_offset struct for every range... so one
node could have several ranges.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
