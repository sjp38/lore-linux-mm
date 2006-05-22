Message-ID: <44717564.50607@shadowen.org>
Date: Mon, 22 May 2006 09:25:08 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Align the node_mem_map endpoints to a MAX_ORDER boundary
References: <20060519134241.29021.84756.sendpatchset@skynet>	<20060519134301.29021.71137.sendpatchset@skynet> <20060519134948.10992ba1.akpm@osdl.org>
In-Reply-To: <20060519134948.10992ba1.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, nickpiggin@yahoo.com.au, haveblue@us.ibm.com, ak@suse.de, bob.picco@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
>>Andy added code to buddy allocator which does not require the zone's
>>endpoints to be aligned to MAX_ORDER. An issue is that the buddy
>>allocator requires the node_mem_map's endpoints to be MAX_ORDER aligned.
>>Otherwise __page_find_buddy could compute a buddy not in node_mem_map for
>>partial MAX_ORDER regions at zone's endpoints. page_is_buddy will detect
>>that these pages at endpoints are not PG_buddy (they were zeroed out by
>>bootmem allocator and not part of zone). Of course the negative here is
>>we could waste a little memory but the positive is eliminating all the
>>old checks for zone boundary conditions.
>>
>>SPARSEMEM won't encounter this issue because of MAX_ORDER size constraint
>>when SPARSEMEM is configured. ia64 VIRTUAL_MEM_MAP doesn't need the
>>logic either because the holes and endpoints are handled differently.
>>This leaves checking alloc_remap and other arches which privately allocate
>>for node_mem_map.
> 
> 
> Do we think we need this in 2.6.17?

I would say yes, it is a very low risk patch in my view and provides a
very large part of the protections we require.  i386 as our largest
userbase should be safe from zone/node alignment issues with just this
change.  Others need slightly more (the page_zone_idx check) which is
being discussed in another thread.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
