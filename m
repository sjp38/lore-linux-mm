Message-ID: <43E9DBE8.8020900@yahoo.com.au>
Date: Wed, 08 Feb 2006 22:54:16 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Removing page->flags
References: <1139381183.22509.186.camel@localhost>
In-Reply-To: <1139381183.22509.186.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:
> [RFC] Removing page-flags
> 
> Removing page->flags might not be the right way to put this idea, but it
> sums it up pretty good IMO. The idea is to save memory for smaller
> machines and also improve scalability for large SMP systems. Maybe too
> much overhead is introduced, hopefully someone of you can tell.
> 
> Today each page->flags contain two types of information:
> A) 21 bits defined in linux/page-flags.h
> B) Zone, node and sparsemem section bit fields, covered in linux/mm.h
> 
> On smaller systems (like my laptop), type B is only used to determine
> which zone it belongs to using any given struct page. At least 8 bits
> per struct page are unused in that case.
> 
> Large NUMA systems use type B more efficiently, but the fact that type A
> contains a mix of bits might be suboptimal. Especially since some bits
> may require atomic operations while others are already protected and
> doesn't require atomicy. The fact that the bits share the same word
> forces us to use atomic-only operation, which may result in unnecessary
> cache line bouncing.
> 
> Moving type A bits:
> 
> Instead of keeping the bits together, we spread them out and store a
> pointer to them from pg_data_t.
> 
> To be more exact, pg_data_t is extended to include an array of pointers,
> one pointer per bit defined in linux/page-flags.h. Today that would be
> 21 pointers. Each pointer is pointing to a bitmap, and the bitmap
> contains one bit per page in the node. The bitmap should be indexed
> using (pfn - node_start_pfn). Each one of these (21) bitmaps may be
> accessed using atomic or non-atomic operations, all depending on how the
> flag is used. This hopefully improves scalability.
> 

There are a large number of paths which access essentially random struct
pages (any memory allocation / deallocation, many pagecache operations).
Your proposal basically guarantees at least an extra cache miss on such
paths. On most modern machines the struct page should be less than or
equal to a cacheline I think.

Also, would you mind explaining how you'd allow non-atomic access to
bits which are already protected somewhere else? Without adding extra
cache misses for each different type of bit that is manipulated? Which
bits do you have in mind, exactly?

I don't think operations on page flags should ever inhibit scalability
just due to the fact they are atomic. Atomic bitops will hurt single
threaded performance, but scalability would probably be impacted more
by the extra cache misses and memory traffic.

The real hit to scalability is when there is multiple access to the same
flags, but in that case the problem remains.

> Removing type B bits:
> 
> Instead of using the highest bits of page->flags to locate zones, nodes
> or sparsemem section, let's remove them and locate them using alignment!
> 

If we accept that type A bits are a good idea, then removing just type B
is no point. Sometimes the more complex memory layouts will require more
than just arithmetic (ie. memory loads) so I doubt that is worthwhile
either.

> To locate which zone, node and sparsemem section a page belongs to, just
> use struct page (source_page) and aligment! The page that contains the
> specific struct page (and also contains other parts of mem_map), it's
> struct page is located using something like this:
> 
>   memmap_page = virt_to_page(source_page)
> 
> This memmap_page should be unused today. Maybe it is reserved. Anyway,
> memmap_page could be used to do all sorts of tricks, like misusing
> mapping to point to the zone, index to point to the sparsemem section,
> and while at it why not use lru.next to point to the node. One drawback
> with this idea is that it adds some extra limitations to the sizes of
> zones and sparsemem sections. One example is that a DMA zone of 4096
> pages works very well, but 4097 pages might force a certain page
> containing a part of mem_map to point to two different zones which of
> course does not work at all.
> 
> Much work, no gain? Comments?
> 
> / magnus
> 

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
