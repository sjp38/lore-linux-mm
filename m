Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id BCC7F6B026D
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:13 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 20:01:12 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id B55456E803C
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:05 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r43018v7322284
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:08 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r43018lO010718
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:08 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 00/31] Dynamic NUMA: Runtime NUMA memory layout reconfiguration
Date: Thu,  2 May 2013 17:00:32 -0700
Message-Id: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

There is still some cleanup to do, so I'm just posting these early and often. I
would appreciate some review to make sure that the basic approaches are sound,
and especially suggestions regarding TODO #1 below. If everything goes well,
I'd like to seem them merged circa 3.12.

--

These patches allow the NUMA memory layout (meaning which node each physical
page belongs to, the mapping from physical pages to NUMA nodes) to be changed
at runtime in place (without hotplugging).

TODO:

 1) Currently, I use pageflag setters without "owning" pages which could cause
   loss of pageflag updates when combined with non-atomic pageflag users in
   mm/*. Some options for solving this: (a) make all pageflags access atomic,
   (b) use pageblock flags, (c) use bits in a new bitmap, or (d) attempt to work
   around races in a similar way to memory-failure.

 2) Fix inaccurate accounting in some cases. Example:
	## "5 MB" should be ~"42 MB"
	# dnuma-test s 0 2 128
	# numactl --hardware
	available: 4 nodes (0-3)
	node 0 cpus: 0
	node 0 size: 43 MB
	node 0 free: 11 MB
	node 1 cpus:
	node 1 size: 5 MB
	node 1 free: 34 MB
	node 2 cpus:
	node 2 size: 42 MB
	node 2 free: 28 MB
	node 3 cpus:
	node 3 size: 0 MB
	node 3 free: 0 MB

= Why/when is this useful? =

In virtual machines (VMs) running on NUMA systems both [a] if/when the
hypervisor decides to move their backing memory around (compacting,
prioritizing another VMs desired layout, etc) and [b] in general for
migration of VMs.

The hardware is _already_ changing the NUMA layout underneath us. We have
powerpc64 systems with firmware that currently move the backing memory around,
and have the ability to notify Linux of new NUMA info.

= How are you managing to do this? =

Reconfiguration of page->node mappings is done at the page allocator
level by both pulling free pages out of the free lists (when a new memory
layout is committed) & redirecting pages on free to their new node.

Because we can't change page_node(A) while A is allocated [1], a rbtree
holding the mapping from pfn ranges to node ids ('struct memlayout')
is introduced to track the pfn->node mapping for
yet-to-be-transplanted pages. A lookup in this rbtree occurs on any
page allocator path that decides which zone to free a page to.

To avoid horrible performance due to rbtree lookups all the time, the
rbtree is only consulted when the page is marked with a new pageflag
(LookupNode).

[1]: quite a few users of page_node() depend on it not changing, some
accumulate per-node stats by using this. We'd also have to change it via atomic
operations to avoid disturbing the pageflags which share the same unsigned
long.

= Code & testing =

A debugfs interface allows the NUMA memory layout to be changed.  Basically,
you don't need to have weird systems to test this, in fact, I've done all my
testing so far in plain old qemu-i386 & qemu-x86_64.

A script which stripes the memory between nodes or pushes all memory to a
(potentially new) node is avaliable here:

	https://raw.github.com/jmesmon/trifles/master/bin/dnuma-test

The patches are also available via:

	https://github.com/jmesmon/linux.git dnuma/v36

	2325de5^..e0f8f35

= Current Limitations =

For the reconfiguration to be effective (and not make the allocator make
poorer choices), updating the cpu->node mappings is also needed. This patchset
does _not_ handle this. Also missing is a way to update topology (node
distances), which is slightly less fatal.

These patches only work on SPARSEMEM and the node id _must_ fit in the pageflags
(can't be pushed out to the section). This generally means that 32-bit
platforms are out (unless you hack MAX_PHYS{ADDR,MEM}_BITS).

This code does the reconfiguration without hotplugging memory at all (1
errant page doesn't keep us from fixing the rest of them). But it still
depends on MEMORY_HOTPLUG for functions that online nodes & adjust
zone/pgdat size.

Things that need doing or would be nice to have but aren't bugs:

 - While the interface is meant to be driven via a hypervisor/firmware, that
   portion is not yet included.
 - notifier for kernel users of memory that need/want their allocations on a
   particular node (NODE_DATA(), for instance).
 - notifier for userspace.
 - a way to allocate things from the appropriate node prior to the page
   allocator being fully updated (could just be "allocate it wrong now &
   reallocate later").
 - Make memlayout faster (potentially via per-node allocation, different data
   structure, and/or more/smarter caching).
 - Propagation of updated layout knowledge into kmem_caches (SL*B).

--

Since v2: http://comments.gmane.org/gmane.linux.kernel.mm/98371

 - update sysfs node->memory region mappings when a reconfiguration occurs
 - fixup locking when updating node_spanned_pages.
 - rework memlayout api for use by sysfs refresh code
 - remove holes for memlayouts to make iteration over them less of a chore.

Since v1: http://comments.gmane.org/gmane.linux.kernel.mm/95541

 - Update watermarks.
 - Update zone percpu pageset ->batch & ->high only when needed.
 - Don't lazily adjust {pgdat,zone}->{present_pages,managed_pages}, set them all at once.
 - Don't attempt to use more than nr_node_ids nodes.

--


Cody P Schafer (31):
  rbtree: add postorder iteration functions.
  rbtree: add rbtree_postorder_for_each_entry_safe() helper.
  mm/memory_hotplug: factor out zone+pgdat growth.
  memory_hotplug: export ensure_zone_is_initialized() in mm/internal.h
  mm/memory_hotplug: use {pgdat,zone}_is_empty() when resizing zones &
    pgdats
  mm: add nid_zone() helper
  mm: Add Dynamic NUMA Kconfig.
  page_alloc: add return_pages_to_zone() when DYNAMIC_NUMA is enabled.
  page_alloc: in move_freepages(), skip pages instead of VM_BUG on node
    differences.
  page_alloc: when dynamic numa is enabled, don't check that all pages
    in a block belong to the same zone
  page-flags dnuma: reserve a pageflag for determining if a page needs a
    node lookup.
  memory_hotplug: factor out locks in mem_online_cpu()
  mm: add memlayout & dnuma to track pfn->nid & transplant pages between
    nodes
  mm: memlayout+dnuma: add debugfs interface
  drivers/base/memory.c: alphabetize headers.
  drivers/base/node,memory: rename function to match interface
  drivers/base/node: rename unregister_mem_blk_under_nodes() to be more
    acurate
  drivers/base/node: add unregister_mem_block_under_nodes()
  mm: memory,memlayout: add refresh_memory_blocks() for Dynamic NUMA.
  page_alloc: use dnuma to transplant newly freed pages in
    __free_pages_ok()
  page_alloc: use dnuma to transplant newly freed pages in
    free_hot_cold_page()
  page_alloc: transplant pages that are being flushed from the per-cpu
    lists
  x86: memlayout: add a arch specific inital memlayout setter.
  init/main: call memlayout_global_init() in start_kernel().
  dnuma: memlayout: add memory_add_physaddr_to_nid() for memory_hotplug
  x86/mm/numa: when dnuma is enabled, use memlayout to handle memory
    hotplug's physaddr_to_nid.
  mm/memory_hotplug: VM_BUG if nid is too large.
  mm/page_alloc: in page_outside_zone_boundaries(), avoid premature
    decisions.
  mm/page_alloc: make pr_err() in page_outside_zone_boundaries() more
    useful
  mm/page_alloc: use manage_pages instead of present pages when
    calculating default_zonelist_order()
  mm: add a early_param "extra_nr_node_ids" to increase nr_node_ids
    above the minimum by a percentage.

 Documentation/kernel-parameters.txt |   6 +
 arch/x86/mm/numa.c                  |  32 ++-
 drivers/base/memory.c               |  55 ++++-
 drivers/base/node.c                 |  70 ++++--
 include/linux/dnuma.h               |  97 ++++++++
 include/linux/memlayout.h           | 134 +++++++++++
 include/linux/memory.h              |   5 +
 include/linux/memory_hotplug.h      |   4 +
 include/linux/mm.h                  |   7 +-
 include/linux/node.h                |  20 +-
 include/linux/page-flags.h          |  19 ++
 include/linux/rbtree.h              |  12 +
 init/main.c                         |   2 +
 lib/rbtree.c                        |  40 ++++
 mm/Kconfig                          |  54 +++++
 mm/Makefile                         |   2 +
 mm/dnuma.c                          | 432 ++++++++++++++++++++++++++++++++++++
 mm/internal.h                       |  13 +-
 mm/memlayout-debugfs.c              | 339 ++++++++++++++++++++++++++++
 mm/memlayout-debugfs.h              |  39 ++++
 mm/memlayout.c                      | 354 +++++++++++++++++++++++++++++
 mm/memory_hotplug.c                 |  54 +++--
 mm/page_alloc.c                     | 154 +++++++++++--
 23 files changed, 1866 insertions(+), 78 deletions(-)
 create mode 100644 include/linux/dnuma.h
 create mode 100644 include/linux/memlayout.h
 create mode 100644 mm/dnuma.c
 create mode 100644 mm/memlayout-debugfs.c
 create mode 100644 mm/memlayout-debugfs.h
 create mode 100644 mm/memlayout.c

-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
