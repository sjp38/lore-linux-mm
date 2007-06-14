Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706131550520.32399@schroedinger.engr.sgi.com>
References: <20070612032055.GQ3798@us.ibm.com>
	 <1181660782.5592.50.camel@localhost> <20070612172858.GV3798@us.ibm.com>
	 <1181674081.5592.91.camel@localhost>
	 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
	 <1181677473.5592.149.camel@localhost>
	 <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
	 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
	 <20070613175802.GP3798@us.ibm.com> <1181758874.6148.73.camel@localhost>
	 <Pine.LNX.4.64.0706131550520.32399@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 14 Jun 2007 11:50:47 -0400
Message-Id: <1181836247.5410.85.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-13 at 15:51 -0700, Christoph Lameter wrote:
> On Wed, 13 Jun 2007, Lee Schermerhorn wrote:
> 
> > Yep.  I'm testing the stack "as is" now.  If it doesn't spread the huge
> > pages evenly because of our funky DMA-only node, I'll post a fix up
> > patch for consideration.
> 
> Note that the memory from your DMA only node is allocated without 
> requiring DMA memory. We just fall back in the allocation to DMA memory.
> Thus you do not need special handling as far as I can tell.

Just a note to clarify what was happening.  I already described the
zonelist selected by the gfp_zone for that node.  The first zone in the
list was on node 0, so everytime the interleave cursor specified node 4,
I got a page on node0.  I ended up with twice as many huge pages on node
0 as any other node.  

Nish's code also got the accounting wrong when he changed
"nr_huge_pages_node[page_to_nid(page)]++;" to
"nr_huge_pages_node[nid]++;" in his "numafy several functions" patch.
This caused the total/free counts to get out of sync and the total count
on node 0 to go negative when I free the pages.  This won't happen if
alloc_pages_node() never returns off-node pages.  

On my particular config [number of nodes/amount of memory], if the dma
zone had been first in the list [old, "node order" zonelists], the
allocation would have failed because no page of the requested order
would have been available there.  alloc_pages_node() would have failed
because get_page_from_freelist() would have detected that the 2nd zone
was off node and bailed out.  The "right thing" would have happened here
because of the order of the allocation.  Regular page allocations would
succeed and consume all of DMA--why we added "node order" zonelists.
Also, on a larger config, there would be more DMA memory, so a few [2 or
3?] huge pages might come from the dma memory.

It's even more complicated:  I can configure the platform so that more
of the memory from each of the real nodes in available in the
pseudo-node that contains memory that is hardware interleaved at the
cache-line granularity--all the way up to 100% interleaved.   At 100%
interleaved, all of the real nodes become "memoryless" and all memory
exists in the pseudo-node.   Up to the 1st 4GB will be in zone DMA and
the remainder in zone NORMAL.  This interleaved memory has different
latency/bandwidth properties from node local memory, so in a mixed
local/interleaved configuration, I'd like to handle it separately--e.g.,
not automatically used for task memory interleaving.  It will never be
"local" to any cpu, so default policy won't allocate there.  I'd love to
make the default page cache policy prefer that node, or use it for a
data base shared global area, ...  

The point of all this is that, as you've pointed out, the original NUMA
and memory policy designs assumed a fairly symmetric system
configuration with all nodes populated with [similar amounts?] of
roughly equivalent memory.  That probably describes a majority of NUMA
systems, so the system should handle this well, as a default.  We still
need to be able to handle the less symmetric configs--with boot
parameters, sysctls, cpusets, ...--that specify non-default behavior,
and cause the generic code to do the right thing.  Certainly, the
generic code can't "fall over and die" in the presence of memoryless
nodes or other "interesting" configurations.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
