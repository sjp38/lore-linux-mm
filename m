Date: Fri, 16 Aug 2002 14:37:00 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: clean up mem_map usage ... part 1
Message-ID: <2448940000.1029533820@flay>
In-Reply-To: <3D5D6CFF.9153184D@zip.com.au>
References: <2441610000.1029530734@flay> <3D5D6CFF.9153184D@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Looks good, thanks.  I'll nail an unneeded typecast in there.
> 
> My queue runneth over at present, and the kmap patches need to

I'm not suprised ;-) I can queue more stuff here rather than send it
to your queue, but I'd like you to keep an eye on me before I go too far
astray from what you want to see ;-)

> I won't send the rmap locking hacklets until we've nailed that
> BUG in __free_pages_ok.

That seems to occur with 2.5.31, AFIACS, it's not the extra patches
you have ... unless you mean just not stirring the pot at the moment.
 
> Does pci_map_page() work on discontigmem?

I think it will now I've replaced it with the macro, definitely wouldn't
have done before.

> What _is_ zone_start_mapnr?

A stinking piece of crap that I'm going to rip out in round 2 ;-)
Just testing that now .... (along with node_start_mapnr)

Basically, unless I'm very much mistaken the two things we have
floating around are

1. pfn - this is a page frame number and
pfn == physaddr >> PAGE_SHIFT

2. mapnr. This is the index into the mem_map array. For contigmem,
thats equiv to a pfn, and more or less made some sense.
For discontigmem that's a nasty hack. We don't have a mem_map array, 
we have an lmem_map array per pg_data_t (aka node or memory chunk). 
But we somehow decided to define mem_map = PAGE_OFFSET, then 
retend the whole of the virtual address space is some kind of klunky 
mem_map array with holes in. So node_start_mapnr = lmem_map - mem_map .... 
except that's really arith on struct pages, so it's the distance / sizeof(struct page). 
So we have to align lmem_map allocations on a boundary of size sizeof(struct page),
except that's really a boundary from PAGE_OFFSET, not absolute vaddr.
Gack. Look at free_area_init_core. It's unpleasant ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
