Subject: Audit of "all uses of node_online()"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <20070731192241.380e93a0.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	 <20070731200522.c19b3b95.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	 <20070731203203.2691ca59.akpm@linux-foundation.org>
	 <1185977011.5059.36.camel@localhost>
	 <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 16:19:53 -0400
Message-Id: <1186085994.5040.98.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Was Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
purposes

On Wed, 2007-08-01 at 10:41 -0700, Christoph Lameter wrote:
> On Wed, 1 Aug 2007, Lee Schermerhorn wrote:
> 
> > I think Andrew is referring to the "exclude selected nodes from
> > interleave policy" and "preferred policy fixups" patches.  Those are
> > related to the memoryless node patches in the sense that they touch some
> > of the same lines in mempolicy.c.  However, IMO, those patches shouldn't
> > gate the memoryless node series once the i386 issues are resolved.
> 
> Right. I think we first need to get the basic set straight. In order to be 
> complete we need to audit all uses of node_online() in the kernel and 
> think about those uses. They may require either N_NORMAL_MEMORY or 
> N_HIGH_MEMORY depending on the check being for a page cache or a kernel 
> allocation.

Below is a list of files in 23-rc1-mm2 with the memoryless nodes patches
applied [the last ones I posted, not the most recent from Christoph's
tree] that contain the strings 'node_online' or 'online_node'--i.e.
possible uses of the node_online_map or the for_each_online_node macro.
48 files in all, I think.

I have started looking at all of these and I'm preparing a patch to
"fix" the ones that look obviously wrong to me.  Not very far along,
yet, and I won't finish it today.  I won't be in on Friday [or the
weekend :-)], but will continue next week.

Note that the list includes a lot of architectural dependent files.
Shall I do a separate patch for each arch, so that arch maintainer can
focus on that [I assume they'll want to review], or a single "jumbo
patch" to reduce traffic?

Lee


------------

arch/alpha/mm/numa.c
arch/arm/mm/init.c
arch/avr32/kernel/setup.c
arch/avr32/mm/init.c
arch/i386/kernel/numaq.c
arch/i386/kernel/setup.c
arch/i386/kernel/srat.c
arch/i386/kernel/topology.c
arch/i386/mm/discontig.c
arch/i386/pci/numa.c
arch/ia64/kernel/acpi.c
arch/ia64/kernel/topology.c
arch/ia64/mm/discontig.c
arch/ia64/sn/kernel/setup.c
arch/ia64/sn/kernel/sn2/prominfo_proc.c
arch/ia64/sn/kernel/sn2/sn_hwperf.c
arch/ia64/sn/kernel/xpc_partition.c
arch/m32r/kernel/setup.c
arch/m32r/mm/discontig.c
arch/m32r/mm/init.c
arch/mips/kernel/topology.c
arch/mips/sgi-ip27/ip27-klnuma.c
arch/mips/sgi-ip27/ip27-memory.c
arch/mips/sgi-ip27/ip27-nmi.c
arch/mips/sgi-ip27/ip27-reset.c
arch/mips/sgi-ip27/ip27-smp.c
arch/parisc/mm/init.c
arch/powerpc/mm/mem.c
arch/powerpc/mm/numa.c
arch/powerpc/platforms/cell/iommu.c
arch/powerpc/platforms/cell/spufs/sched.c
arch/sh/kernel/setup.c
arch/sh/kernel/topology.c
arch/sh/mm/init.c
arch/x86_64/kernel/pci-dma.c
arch/x86_64/kernel/setup.c
arch/x86_64/mm/numa.c
drivers/base/node.c
drivers/char/mmtimer.c
include/linux/nodemask.h
include/linux/topology.h
mm/mempolicy.c
	? should BIND nodes be limited to nodes with memory?
	? ALL policies in mpol_new()?
	? should mpol_check_policy() require a subset of nodes with memory?
mm/shmem.c
	fixed mount option parsing and superblock setup.
mm/page-writeback.c
	fixed highmem_dirtyable_memory() to just look at N_MEMORY
mm/page_alloc.c
mm/slab.c
mm/swap_prefetch.c
	fixed clear_{last|current}_prefetch_free()
net/sunrpc/svc.c
	fixed svc_pool_map_choose_mode()


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
