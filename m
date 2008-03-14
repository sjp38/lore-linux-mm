Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2DNnsGj031359
	for <linux-mm@kvack.org>; Thu, 13 Mar 2008 19:49:54 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DNnsEF163260
	for <linux-mm@kvack.org>; Thu, 13 Mar 2008 17:49:54 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DNnrJD030723
	for <linux-mm@kvack.org>; Thu, 13 Mar 2008 17:49:53 -0600
Subject: Re: grow_dev_page's __GFP_MOVABLE
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20080313154428.GD12351@csn.ul.ie>
References: <Pine.LNX.4.64.0803112116380.18085@blonde.site>
	 <20080312140831.GD6072@csn.ul.ie>
	 <Pine.LNX.4.64.0803121740170.32508@blonde.site>
	 <20080313120755.GC12351@csn.ul.ie>
	 <1205420758.19403.6.camel@dyn9047017100.beaverton.ibm.com>
	 <20080313154428.GD12351@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 13 Mar 2008 16:50:06 -0800
Message-Id: <1205455806.19403.47.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-03-13 at 15:44 +0000, Mel Gorman wrote:
> On (13/03/08 07:05), Badari Pulavarty didst pronounce:
> > > <SNIP>
> > 
> > Mel,
> > 
> > All I can say is, marking grow_dev_page() __GFP_MOVABLE is causing
> > nothing but trouble in my hotplug memory remove testing :(
> > 
> 
> Dirt.
> 
> > I constantly see that even though memblock is marked "removable", I
> > can't move the allocations. Most of the times these allocations came
> > from grow_dev_pages or its friends :(
> > 
> > Either these pages are not movable/migratable or code is not working
> > or filesystem/block device is holding them up :(
> > 
> 
> Or no effort is being made to reclaim pages whose address_space has no
> migratepages() handler.
> 
> > 
> > memory offlining 0x8000 to 0x9000 failed
> > 
> > page_owner shows:
> > 
> > Page allocated via order 0, mask 0x120050
> > PFN 30625 Block 7 type 2          Flags      L
> 
> This page is indicated as being on the LRU so it should have been possible
> to reclaim. Is memory hot-remove making any effort to reclaim this page or
> is it depending only on page migration?

offline_pages() finds all the pages on LRU and tries to migrate them by
calling unmap_and_move(). I don't see any explicit attempt to reclaim.
It tries to migrate the page (move_to_new_page()), but what I have seen
in the past is that these pages have buffer heads attached to them. 
So, migrate_page_move_mapping() fails to release the page. (BTW,
I narrowed this in Oct 2007 and forgot most of the details). I can
take a closer look again. Can we reclaim these pages easily ?

> 
> > [0xc0000000000c511c] .alloc_pages_current+208
> > [0xc0000000001049d8] .__find_get_block_slow+88
> > [0xc0000000004f0bbc] .__wait_on_bit+232
> > [0xc0000000000994ec] .__page_cache_alloc+24
> > [0xc000000000104fd8] .__find_get_block+272
> > [0xc00000000009a124] .find_or_create_page+76
> > [0xc0000000001063fc] .unlock_buffer+48
> > [0xc000000000105280] .__getblk+312
> > 

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
