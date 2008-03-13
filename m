Date: Thu, 13 Mar 2008 15:44:28 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: grow_dev_page's __GFP_MOVABLE
Message-ID: <20080313154428.GD12351@csn.ul.ie>
References: <Pine.LNX.4.64.0803112116380.18085@blonde.site> <20080312140831.GD6072@csn.ul.ie> <Pine.LNX.4.64.0803121740170.32508@blonde.site> <20080313120755.GC12351@csn.ul.ie> <1205420758.19403.6.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1205420758.19403.6.camel@dyn9047017100.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (13/03/08 07:05), Badari Pulavarty didst pronounce:
> > <SNIP>
> 
> Mel,
> 
> All I can say is, marking grow_dev_page() __GFP_MOVABLE is causing
> nothing but trouble in my hotplug memory remove testing :(
> 

Dirt.

> I constantly see that even though memblock is marked "removable", I
> can't move the allocations. Most of the times these allocations came
> from grow_dev_pages or its friends :(
> 
> Either these pages are not movable/migratable or code is not working
> or filesystem/block device is holding them up :(
> 

Or no effort is being made to reclaim pages whose address_space has no
migratepages() handler.

> 
> memory offlining 0x8000 to 0x9000 failed
> 
> page_owner shows:
> 
> Page allocated via order 0, mask 0x120050
> PFN 30625 Block 7 type 2          Flags      L

This page is indicated as being on the LRU so it should have been possible
to reclaim. Is memory hot-remove making any effort to reclaim this page or
is it depending only on page migration?

> [0xc0000000000c511c] .alloc_pages_current+208
> [0xc0000000001049d8] .__find_get_block_slow+88
> [0xc0000000004f0bbc] .__wait_on_bit+232
> [0xc0000000000994ec] .__page_cache_alloc+24
> [0xc000000000104fd8] .__find_get_block+272
> [0xc00000000009a124] .find_or_create_page+76
> [0xc0000000001063fc] .unlock_buffer+48
> [0xc000000000105280] .__getblk+312
> 
> 
> Thanks,
> Badari
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
