Message-ID: <3DF8B1A8.1080303@earthlink.net>
Date: Thu, 12 Dec 2002 08:56:24 -0700
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: Question on swapping
References: <3DF071C3.C3E1EC39@scs.ch> <1039224592.4551.57.camel@amol.in.ishoni.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amol Kumar Lad <amolk@ishoni.com>
Cc: Martin Maletinsky <maletinsky@scs.ch>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Amol Kumar Lad wrote:
>For the first time P would never be found in the swap cache, infact
> try_to_swap_out shall do following
> a] Page is dirty (in page table entry), so set PG_DIRTY in struct page

This appears to be the *only* place in the kernel where pte dirty
bits are propagated into the mem_map.

> b] Allocate a swap entry and add this page to swap cache
> c] release the page, and add the modify page table entry to point it to
> swap entry
> 
> Now We have 
> a] Page table entry for P contains swap info
> b] Page P in swap cache
> c] PG_DIRTY _is_ set (infact for a page in swap cache this is always
> true)
> 
> Do remember, along with the swap cache P may be party of inactive_dirty
> list.
> 
> The actual swapping to backing store is done by page scanner.
> It shall do following. Assume it has decided to _really_ free P
> 1] As page is dirty, call the page write back function. Thus here for
> the first time page found its place in swap.
> 2] send P back home, to buddy allocator
> 
> If process A again access the page, then page fault handler shall do
> following
> 1] allocate a swap cache page
> 2] read the page from swap.
> 3] Modify page table entry of A to point to this page 

So now the page is not marked dirty in the mem_map. What if A *now*
writes the page and then tries to swap it out? That's Martin's question:
in that case, we have a page that's in the swap cache; whose
page struct is *not* marked dirty; but which *is* actually dirty.
How do we know the page will be kept up to date on disk?

I used to understand how this worked, but I've forgotten. Or
maybe I never really understood it.

Cheers,

-- Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
