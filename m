Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4GLsjmD360716
	for <linux-mm@kvack.org>; Mon, 16 May 2005 17:54:45 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4GLsjdV100230
	for <linux-mm@kvack.org>; Mon, 16 May 2005 15:54:45 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4GLsiJ8004291
	for <linux-mm@kvack.org>; Mon, 16 May 2005 15:54:44 -0600
Subject: Re: NUMA aware slab allocator V3
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200505161410.43382.jbarnes@virtuousgeek.org>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>
	 <714210000.1116266915@flay>  <200505161410.43382.jbarnes@virtuousgeek.org>
Content-Type: text/plain
Date: Mon, 16 May 2005 14:54:30 -0700
Message-Id: <1116280470.1005.137.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Christoph Lameter <clameter@engr.sgi.com>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 2005-05-16 at 14:10 -0700, Jesse Barnes wrote:
> On Monday, May 16, 2005 11:08 am, Martin J. Bligh wrote:
> > > I have never seen such a machine. A SMP machine with multiple
> > > "nodes"? So essentially one NUMA node has multiple discontig
> > > "nodes"?
> >
> > I believe you (SGI) make one ;-) Anywhere where you have large gaps
> > in the physical address range within a node, this is what you really
> > need. Except ia64 has this wierd virtual mem_map thing that can go
> > away once we have sparsemem.
> 
> Right, the SGI boxes have discontiguous memory within a node, but it's 
> not represented by pgdats (like you said, one 'virtual memmap' spans 
> the whole address space of a node).  Sparse can help simplify this 
> across platforms, but has the potential to be more expensive for 
> systems with dynamically sized holes, due to the additional calculation 
> and potential cache miss associated with indexing into the correct 
> memmap (Dave can probably correct me here, it's been awhile).  With a 
> virtual memmap, you only occasionally take a TLB miss on the struct 
> page access after indexing into the array.

The sparsemem calculation costs are quite low.  One of the main costs is
bringing the actual 'struct page' into the cache so you can use the
hints in page->flags.  In reality, after almost every pfn_to_page(), you
go ahead and touch the 'struct page' anyway.  So, this cost is
effectively zero.  In fact, it's kinda like doing a prefetch, so it may
even speed some things up.

After you have the section index from page->flags (which costs just a
shift and a mask), you access into a static array, and do a single
subtraction.  Here's the I386) disassembly this function with
SPARSEMEM=y:

        unsigned long page_to_pfn_stub(struct page *page)
        {
                return page_to_pfn(page);
        }

    1c30:       8b 54 24 04             mov    0x4(%esp),%edx
    1c34:       8b 02                   mov    (%edx),%eax
    1c36:       c1 e8 1a                shr    $0x1a,%eax
    1c39:       8b 04 85 00 00 00 00    mov    0x0(,%eax,4),%eax
    1c40:       24 fc                   and    $0xfc,%al
    1c42:       29 c2                   sub    %eax,%edx
    1c44:       c1 fa 05                sar    $0x5,%edx
    1c47:       89 d0                   mov    %edx,%eax
    1c49:       c3                      ret

Other than popping the arguments off the stack, I think there are only
two loads in there: the page->flags load, and the mem_section[]
dereference.  So, in the end, the only advantage of the vmem_map[]
approach is saving that _one_ load.  The worst-case-scenario for this
load in the sparsemem case is a full cache miss.  The worst case in the
vmem_map[] case is a TLB miss, which is probably hundreds of times
slower than even a full cache miss.

BTW, the object footprint of sparsemem is lower than discontigmem, too:

		SPARSEMEM 	DISCONTIGMEM
pfn_to_page:	      25b	         41b
page_to_pfn:	      25b		 33b

So, that helps out things like icache footprint.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
