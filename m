Date: Wed, 01 Oct 2008 11:48:29 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] mm: show node to memory section relationship with symlinks in sysfs
In-Reply-To: <20080930194122.GA7123@us.ibm.com>
References: <1222789837.17630.41.camel@nimitz> <20080930194122.GA7123@us.ibm.com>
Message-Id: <20081001103221.306C.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Sep 30, 2008 at 08:50:37AM -0700, Dave Hansen wrote:
> > On Tue, 2008-09-30 at 17:06 +0900, Yasunori Goto wrote:
> > > > +#define section_nr_to_nid(section_nr) pfn_to_nid(section_nr_to_pfn(section_nr))
> > > >  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> > > 
> > > If the first page of the section is not valid, then this section_nr_to_nid()
> > > doesn't return correct value.
> > > 
> > > I tested this patch. In my box, the start_pfn of node 1 is 1200400, but 
> > > section_nr_to_pfn(mem_blk->phys_index) returns 1200000. As a result,
> > > the section is linked to node 0.
> > 
> > Crap, I was worried about that.
> > 
> > Gary, this means that we have a N:1 relationship between NUMA nodes and
> > sections.  This normally isn't a problem because sections don't really
> > care about nodes and they layer underneath them.
> 
> So, using Yasunori-san's example the memory section starting at
> pfn 1200000 actually resides on both node 0 and node 1.


It may be possible that one section is divided to different node in theory.
(I don't know really there is...)

But, the cause of my trouble differs from it.
There is a memory hole which is occupied by firmware.
So, the memory map of my box is here.

----
early_node_map[3] active PFN ranges
    0: 0x00000100 -> 0x00006d00
    0: 0x00408000 -> 0x00410000
    1: 0x01200400 -> 0x01210000
----

memmap_init() initializes from start_pfn (to end_pfn).
So, the memmaps for this first hole (0x1200000 - 0x12003ff) are not initialized,
and node id is not set for them. This is true cause.


Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
