Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B9FAE6B0002
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 21:41:19 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 27 Feb 2013 19:41:18 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 7AC533E40044
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 19:41:07 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1S2fEAo086838
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 19:41:14 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1S2fET2005964
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 19:41:14 -0700
Date: Wed, 27 Feb 2013 18:41:12 -0800
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC] DNUMA: Runtime NUMA memory layout reconfiguration
Message-ID: <20130228024112.GA24970@negative>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

These patches allow the NUMA memory layout (meaning the mapping of a page to a
node) to be changed at runtime in place (without hotplugging).

= Why/when is this useful? =

In virtual machines (VMs) running on NUMA systems both [a] if/when the
hypervisor decides to move their backing memory around (compacting,
prioritizing another VMs desired layout, etc) and [b] in general for
migration of VMs.

The hardware is _already_ changing the NUMA layout underneath us. We have
powerpc64 systems with firmware that currently move the backing memory around,
and have the ability to notify Linux of new NUMA info.

= Code & testing =

web:
	https://github.com/jmesmon/linux/tree/dnuma/v26
git:
	https://github.com/jmesmon/linux.git dnuma/v26

commit range:
	7e4f3230c9161706ebe9d37d774398082dc352de^..01e16461cf4a914feb1a34ed8dd7b28f3e842645

Some patches are marked "XXX: ...", they are only for testing or
temporary documentation purposes.

A debugfs interface allows the NUMA memory layout to be changed.  Basically,
you don't need to have wierd systems to test this, in fact, I've done all my
testing so far in plain old qemu-i386.

A script which stripes the memory between nodes or pushes all memory to a
(potentially new) node is avaliable here:

	https://raw.github.com/jmesmon/trifles/master/bin/dnuma-test

Related LSF/MM Topic proposal:

	http://permalink.gmane.org/gmane.linux.kernel.mm/95342

= How are you managing to do this? =

Reconfiguration of page->node mappings is done at the page allocator
level by both pulling out free pages (when a new memory layout is
commited) & redirecting pages on free to their new node.

Because we can't change page_node(A) while A is allocated, a rbtree
holding the mapping from pfn ranges to node ids ('struct memlayout')
is introduced to track the pfn->node mapping for
yet-to-be-transplanted pages. A lookup in this rbtree occurs on any
page allocator path that decides which zone to free a page to.

To avoid horrible performance due to rbtree lookups all the time, the
rbtree is only consulted when the page is marked with a new pageflag
(LookupNode).

= Current Limitations =

For the reconfiguration to be effective (and not make the allocator make
poorer choices), updating the cpu->node mappings is also needed. This patchset
does _not_ handle this. Also missing is a way to update topology (node
distances), which is less fatal.

These patches only work on SPARSEMEM and the node id _must_ fit in the pageflags
(can't be pushed out to the section). This generally means that 32-bit
platforms are out (unless you hack MAX_PHYS{ADDR,MEM}_BITS like I do for
testing).

This code does the reconfiguration without hotplugging memory at all (1
errant page doesn't keep us from fixing the rest of them). But it still
depends on MEMORY_HOTPLUG for functions that online nodes & adjust
zone/pgdat size.

Things that need doing (but aren't quite bugs):
 - While the interface is meant to be driven via a hypervisor/firmware, that
   portion is not yet included.
 - notifier for kernel users of memory that need/want their allocations on a
   particular node (NODE_DATA(), for instance).
 - notifier for userspace.
 - a way to allocate things from the appropriate node prior to the page
   allocator being fully updated (could just be "allocate it wrong now &
   reallocate later").
 - Make memlayout faster (potentially via per-node allocation, different data
   structure, or more/smarter caching).
 - (potentially) propagation of updated layout knowledge into kmem_caches
   (SL*B).

Known Bugs:
 - Transplant of free pages is _very_ slow due to excessive use of
   stop_machine() via zone_pcp_update() & build_zonelists(). On my i5 laptop,
   it take ~9 minutes to stripe the layout in blocks of 256 pfns to 3 nodes on a
   128MB 8 cpu x86_32 VM booted with 2 nodes.
 - memory leak when SLUB is used (struct kmem_cache_nodes are leaked), SLAB
   appears fine.
 - Locking of managed_pages/present_pages needs adjustment, or they need to
   be updated outside of the free page path.
 - Exported numa/memory info in sysfs isn't updated (`numactl --show` segfaults,
   `numactl --hardware` shows new nodes as nearly empty).
 - Uses pageflag setters without "owning" pages, could cause loss of pageflag
   updates when combined with non-atomic pageflag users in mm/*.
 - some strange sleeps while atomic (for me they occur when memory is
   moved out of all the boot nodes)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
