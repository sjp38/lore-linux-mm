From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: NUMA aware slab allocator V3
Date: Mon, 16 May 2005 14:10:43 -0700
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com> <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com> <714210000.1116266915@flay>
In-Reply-To: <714210000.1116266915@flay>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200505161410.43382.jbarnes@virtuousgeek.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Monday, May 16, 2005 11:08 am, Martin J. Bligh wrote:
> > I have never seen such a machine. A SMP machine with multiple
> > "nodes"? So essentially one NUMA node has multiple discontig
> > "nodes"?
>
> I believe you (SGI) make one ;-) Anywhere where you have large gaps
> in the physical address range within a node, this is what you really
> need. Except ia64 has this wierd virtual mem_map thing that can go
> away once we have sparsemem.

Right, the SGI boxes have discontiguous memory within a node, but it's 
not represented by pgdats (like you said, one 'virtual memmap' spans 
the whole address space of a node).  Sparse can help simplify this 
across platforms, but has the potential to be more expensive for 
systems with dynamically sized holes, due to the additional calculation 
and potential cache miss associated with indexing into the correct 
memmap (Dave can probably correct me here, it's been awhile).  With a 
virtual memmap, you only occasionally take a TLB miss on the struct 
page access after indexing into the array.

> The end point of where we're getting to is 1 node = 1 pgdat (which we
> can then rename to struct node or something). All this confusing mess
> of config options is just a migration path, which I'll leave it to
> Andy to explain ;-)

Yes!

> No, it's a discontigmem screwup. Currently a pgdat represents 2
> different scenarios:
>
> (1) physically discontiguous memory chunk.
> (2) a NUMA node.
>
> I don't think we support both at the same time with the old code. So
> it seems to me like your numa aware slab code (which I'm still
> intending to go read, but haven't yet) is only interested in real
> nodes. Logically speaking, that would be CONFIG_NUMA. The current
> transition config options are a bit of a mess ... Andy, I presume
> CONFIG_NEED_MULTIPLE_NODES is really CONFIG_NEED_MULTIPLE_PGDATS ?

Yeah, makes sense for the NUMA aware slab allocator to depend on 
CONFIG_NUMA.

Jesse
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
