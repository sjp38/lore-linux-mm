Date: Wed, 29 Nov 2006 13:21:55 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: ia64 ORDERROUNDDOWN issue
Message-Id: <20061129132155.f617dcfb.akpm@osdl.org>
In-Reply-To: <617E1C2C70743745A92448908E030B2AD89B2A@scsmsx411.amr.corp.intel.com>
References: <617E1C2C70743745A92448908E030B2AD89B2A@scsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: xb <xavier.bru@bull.net>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(add linux-mm)

On Wed, 29 Nov 2006 10:34:24 -0800
"Luck, Tony" <tony.luck@intel.com> wrote:

> > After some investigations I stated that count_node_pages() was computing 
> > mem_data[1].min_pfn = 0, and mem_data[1].max_pfn = 20000 for node 1, 
> > thus conflicting with the 0-2GB DMA memory range on node 0.
> > This is due to the line:
> >    start = ORDERROUNDDOWN(start);
> 
> There is an assumption here that the memory space on a node doesn't
> cross a MAX_ORDER boundary ... and I'm not really sure where to go
> with that.  Your patch papers over the problem for your specific case,
> but as you point out it will just re-appear for someone who picks
> a bigger MAX_ORDER.
> 
> Having nodes that are smaller than MAX_ORDER will cause confusion in
> the allocator (if all the memory belonging to two nodes is in a
> single MAX_ORDER page, the buddy allocator will give all the memory
> to one node, and none to the other (won't it?).
> 
> > This should at least be checked in the count_node_pages() function.
> 
> Yes, a check should be made ... but count_node_pages() doesn't have
> all the information if needs to do this (it just gets the start/size
> for the memory on the node ... and it needs to check whether the
> rounddown of the start address (or the roundup of the end address)
> would cause conflicts with memory belonging to other nodes.
> 
> Do we need a "max_order" variable that could be adjusted to some lower
> value that MAX_ORDER if we find the memory topology doesn't fit inside
> the lines?  
> 

(Your email talks about nodes, but I am asuming that we're actually dealing
with per-zone concepts here)

We could of course do that, although it looks like your runtime max_order
should be per-zone and not global.  And making it a runtime thing would
cause more code to be emitted for alloc_pages() and alloc_pages_node(), so
we'd at least have to move their checks into .c.

But I wonder if a better approach would be to teach ia64 to just throw away
the last 1 ..  MAX_ORDER-1 pages from the oddball zone?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
