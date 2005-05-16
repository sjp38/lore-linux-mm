Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4GHMUmD305754
	for <linux-mm@kvack.org>; Mon, 16 May 2005 13:22:30 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4GHMTdV100632
	for <linux-mm@kvack.org>; Mon, 16 May 2005 11:22:30 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4GHMTaY032740
	for <linux-mm@kvack.org>; Mon, 16 May 2005 11:22:29 -0600
Subject: Re: NUMA aware slab allocator V3
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0505160943140.1330@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	 <20050512000444.641f44a9.akpm@osdl.org>
	 <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
	 <20050513000648.7d341710.akpm@osdl.org>
	 <Pine.LNX.4.58.0505130411300.4500@schroedinger.engr.sgi.com>
	 <20050513043311.7961e694.akpm@osdl.org>
	 <Pine.LNX.4.62.0505131823210.12315@schroedinger.engr.sgi.com>
	 <1116251568.1005.29.camel@localhost>
	 <Pine.LNX.4.62.0505160943140.1330@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 16 May 2005 10:22:15 -0700
Message-Id: <1116264135.1005.73.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 2005-05-16 at 09:47 -0700, Christoph Lameter wrote:
> On Mon, 16 May 2005, Dave Hansen wrote:
> > There are some broken assumptions in the kernel that
> > CONFIG_DISCONTIG==CONFIG_NUMA.  These usually manifest when code assumes
> > that one pg_data_t means one NUMA node.
> > 
> > However, NUMA node ids are actually distinct from "discontigmem nodes".
> > A "discontigmem node" is just one physically contiguous area of memory,
> > thus one pg_data_t.  Some (non-NUMA) Mac G5's have a gap in their
> > address space, so they get two discontigmem nodes.
> 
> I thought the discontigous memory in one node was handled through zones? 
> I.e. ZONE_HIGHMEM in i386?

You can only have one zone of each type under each pg_data_t.  For
instance, you can't properly represent (DMA, NORMAL, HIGHMEM, <GAP>,
HIGHMEM) in a single pg_data_t without wasting node_mem_map[] space.
The "proper" discontig way of representing that is like this:

        pg_data_t[0] (DMA, NORMAL, HIGHMEM)
        <GAP>
        pg_data_t[1] (---, ------, HIGHMEM)

Where pg_data_t[1] has empty DMA and NORMAL zones.  Also, remember that
both of these could theoretically be on the same NUMA node.  But, I
don't think we ever do that in practice.

> > So, that #error is bogus.  It's perfectly valid to have multiple
> > discontigmem nodes, when the number of NUMA nodes is 1.  MAX_NUMNODES
> > refers to discontigmem nodes, not NUMA nodes.
> 
> Ok. We looked through the code and saw that the check may be removed 
> without causing problems. However, there is still a feeling of uneasiness 
> about this.

I don't blame you :)

> To what node does numa_node_id() refer?

That refers to the NUMA node that you're thinking of.  Close CPUs and
memory and I/O, etc...

> And it is legit to use 
> numa_node_id() to index cpu maps and stuff?

Yes, those are all NUMA nodes.

> How do the concepts of numa node id relate to discontig node ids?

I believe there are quite a few assumptions on some architectures that,
when NUMA is on, they are equivalent.  It appears to be pretty much
assumed everywhere that CONFIG_NUMA=y means one pg_data_t per NUMA node.

Remember, as you saw, you can't assume that MAX_NUMNODES=1 when NUMA=n
because of the DISCONTIG=y case.

So, in summary, if you want to do it right: use the
CONFIG_NEED_MULTIPLE_NODES that you see in -mm.  As plain DISCONTIG=y
gets replaced by sparsemem any code using this is likely to stay
working.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
