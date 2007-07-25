Subject: Re: 2.6.23-rc1-mm1:  boot hang on ia64 with memoryless nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707251231570.8820@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>
	 <20070713151431.GG10067@us.ibm.com>
	 <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
	 <1185310277.5649.90.camel@localhost>
	 <Pine.LNX.4.64.0707241402010.4773@schroedinger.engr.sgi.com>
	 <1185372692.5604.22.camel@localhost>  <1185378322.5604.43.camel@localhost>
	 <1185390991.5604.87.camel@localhost>
	 <Pine.LNX.4.64.0707251231570.8820@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 25 Jul 2007 17:18:57 -0400
Message-Id: <1185398337.5604.96.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kxr@sgi.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>, Mel Gorman <mel@skynet.ie>, Eric Whitney <eric.whitney@hp.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-25 at 12:38 -0700, Christoph Lameter wrote:
> (ccing Andy who did the work on the config stuff)
> 
> On Wed, 25 Jul 2007, Lee Schermerhorn wrote:
> 
> > I tried to deselect SPARSEMEM_VMEMMAP.  Kconfig's "def_bool=y" wouldn't
> > let me :-(.  After hacking the Kconfig and mm/sparse.c to allow that,
> > boot hangs with no error messages shortly after "Built N zonelists..."
> > message.
> 
> I get a similar hang here and see the system looping in softirq / hrtimer 
> code.
> 
> > Backed off to DISCONTIGMEM+VIRTUAL_MEMORY_MAP, and saw same hang as with
> > (SPARSMEM && !SPARSEMEM_VMEMMAP).   
> 
> So its not related to SPARSE VMEMMAP? General VMEMMAP issue on IA64?

This hang is different from the one I see with SPARSE VMEMMAP -- no
"Unable to handle kernel paging request..." message.  Just hangs after
"Built N zonelists..."  and some message about "color" that I didn't
capture.  Next time [:-(]...

>  
> > I should mention that I have my test system in the "fully interleaved"
> > configuration for testing the memoryless node patches.  This means that
> > nodes 0-3 [the real nodes with the cpus attached] have no memory.  All
> > memory resides in a cpu-less pseudo-node.  I'm wondering if
> > SPARSEMEM_VMEMMAP can handle this?  22-rc6-mm1 booted OK on this config
> > w/ SPARSEMEM_EXTREME.
> 
> The vmemmap page table blocks get allocated on the nodes where there 
> is actual mmemory but sparse.c may not have been updated to only look for 
> memory on nodes that have memory. If it looks for online nodes then we 
> may have an issue there. Andy?

In free_area_init_nodes(), free_area_init_node() [singular] is called
for_each_online_node...   I'm looking into this.  I might need an
additional memoryless node patch to test the memoryless node patches...

> 
> Were you able to run discontig/vmemmap in the past with this 
> configuration?

Yeah, way back ~2.6.14/15 or so.  My configs have all used SPARSEMEM
since then.

I'm going to switch back to "100% cell local memory" and try again.
But, if you're seeing hangs w/o memoryless nodes, I'm not hopeful.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
