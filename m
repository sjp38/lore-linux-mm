Date: Mon, 22 May 2006 10:28:29 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 2/2] mm: handle unaligned zones
In-Reply-To: <Pine.LNX.4.64.0605221008180.14117@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0605221026210.14117@skynet.skynet.ie>
References: <4470232B.7040802@yahoo.com.au> <44702358.1090801@yahoo.com.au>
 <20060521021905.0f73e01a.akpm@osdl.org> <4470417F.2000605@yahoo.com.au>
 <20060521035906.3a9997b0.akpm@osdl.org> <44705291.9070105@yahoo.com.au>
 <4470547D.2030505@yahoo.com.au> <Pine.LNX.4.64.0605221008180.14117@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, apw@shadowen.org, stable@kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 May 2006, Mel Gorman wrote:

> On Sun, 21 May 2006, Nick Piggin wrote:
>
>> Nick Piggin wrote:
>>> Andrew Morton wrote:
>>> 
>>>> How about just throwing the pages away?  It sounds like a pretty rare
>>>> problem.
>>> 
>>> 
>>> Well that's what many architectures will end up doing, yes. But on
>>> small or embedded platforms, 4MB - 1 is a whole lot of memory to be
>>> throwing away.
>>> 
>>> Also, I'm not sure it is something we can be doing in generic code,
>>> because some architectures apparently have very strange zone setups
>>> (eg. zones from several pages interleaved within a single zone's
>>> ->spanned_pages). So it doesn't sound like a simple matter of trying
>>> to override the zones' intervals.
>> 
>> Oh I see, yeah I guess you could throw away the pages forming the
>> present fraction of the MAX_ORDER buddy...
>> 
>
> As Andy points out in another thread, the need to check unaligned zones is 
> heavily relaxed (if not redundant) once the node_mem_map is aligned by patch 
> "[PATCH 1/2] Align the node_mem_map endpoints to a MAX_ORDER boundary".
>

Sorry, this is wrong. If the zones are not aligned, we still need to check 
that page_zone() matches in page_is_buddy(). I was looking at -mm1 and 
just noticed that mainline did not have the check;

         if (page_zone_id(page) != page_zone_id(buddy))
                 return 0;

> Once the node_mem_map is aligned, we know that we'll be checking a valid 
> struct page. If the zones are not aligned, the unused struct pages forming 
> the absent fraction of the MAX_ORDER buddy will be marked reserved since 
> memmap_init_zone(). This will be caught by free_pages_check() and the buddies 
> will not be merged.
>
> I don't think there is any need to do these complex zone boundary checks once 
> the node_mem_map is aligned for CONFIG_FLAT_NODE_MEM_MAP and SPARSEMEM 
> already gets this right.
>
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
