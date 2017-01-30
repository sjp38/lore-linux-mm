Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7306B0038
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:15 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z67so440786829pgb.0
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:37:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g11si11354709pfj.289.2017.01.29.19.37.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:37:13 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YKXs089836
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:13 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 289haaaeuw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:13 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:37:10 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id BEC243578053
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:07 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3axxZ33947734
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:07 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3aZ7I019490
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:36:35 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 00/12] Define coherent device memory node
Date: Mon, 30 Jan 2017 09:05:41 +0530
Message-Id: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

	There are certain devices like accelerators, GPU cards, network
cards, FPGA cards, PLD cards etc which might contain on board memory. This
on board memory can be coherent along with system RAM and may be accessible
from either the CPU or from the device. The coherency is usually achieved
through synchronizing the cache accesses from either side. This makes the
device memory appear in the same address space as that of the system RAM.
The on board device memory and system RAM are coherent but have differences
in their properties as explained and elaborated below. Following diagram
explains how the coherent device memory appears in the memory address
space.

                +-----------------+         +-----------------+
                |                 |         |                 |
                |       CPU       |         |     DEVICE      |
                |                 |         |                 |
                +-----------------+         +-----------------+
                         |                           |
                         |   Shared Address Space    |
 +---------------------------------------------------------------------+
 |                                             |                       |
 |                                             |                       |
 |                 System RAM                  |     Coherent Memory   |
 |                                             |                       |
 |                                             |                       |
 +---------------------------------------------------------------------+

	User space applications might be interested in using the coherent
device memory either explicitly or implicitly along with the system RAM
utilizing the basic semantics for memory allocation, access and release.
Basically the user applications should be able to allocate memory any where
(system RAM or coherent memory) and then get it accessed either from the
CPU or from the coherent device for various computation or data
transformation purpose. User space really should not be concerned about
memory placement and their subsequent allocations when the memory really
faults because of the access.

	To achieve seamless integration between system RAM and coherent
device memory it must be able to utilize core memory kernel features like
anon mapping, file mapping, page cache, driver managed pages, HW poisoning,
migrations, reclaim, compaction, etc. Making the coherent device memory
appear as a distinct memory only NUMA node which will be initialized as any
other node with memory can create this integration with currently available
system RAM memory. Also at the same time there should be a differentiating
mark which indicates that this node is a coherent device memory node not
any other memory only system RAM node.
 
	Coherent device memory invariably isn't available until the driver
for the device has been initialized. It is desirable but not required for
the device to support memory offlining for the purposes such as power
management, link management and hardware errors. Kernel allocation should
not come here as it cannot be moved out. Hence coherent device memory
should go inside ZONE_MOVABLE zone instead. This guarantees that kernel
allocations will never be satisfied from this memory and any process having
un-movable pages on this coherent device memory (likely achieved through
pinning later on after initial allocation) can be killed to free up memory
from page table and eventually hot plugging the node out.

	After similar representation as a NUMA node, the coherent memory
might still need some special consideration while being inside the kernel.
There can be a variety of coherent device memory nodes with different
expectations and special considerations from the core kernel. This RFC
discusses only one such scenario where the coherent device memory requires
just isolation.

	Now let us consider in detail the case of a coherent device memory
node which requires isolation. This kind of coherent device memory is on
board an external device attached to the system through a link where there
is a chance of link errors plugging out the entire memory node with it.
More over the memory might also have higher chances of ECC errors as
compared to the system RAM. These are just some possibilities. But the fact
remains that the coherent device memory can have some other different
properties which might not be desirable for some user space applications.
An application should not be exposed to related risks of a device if its
not taking advantage of special features of that device and it's memory.

	Because of the reasons explained above allocations into isolation
based coherent device memory node should further be regulated apart from
earlier requirement of kernel allocations not coming there. User space
allocations should not come here implicitly without the user application
explicitly knowing about it. This summarizes isolation requirement of
certain kind of a coherent device memory node as an example.

	Some coherent memory devices may not require isolation altogether.
Then there might be other coherent memory devices which require some other
special treatment after being part of core memory representation in kernel.
Though the framework suggested by this RFC has made provisions for them, it
has not considered any other kind of requirement other than isolation for
now.

	Though this RFC series currently attempts to implement one such
isolation seeking coherent device memory example, this framework can be
extended to accommodate any present or future coherent memory devices which
will fit the requirement as explained before even with new requirements
other than isolation. In case of isolation seeking coherent device memory
node, there will be other core VM code paths which need to be taken care
before it can be completely isolated as required.

	Core kernel memory features like reclamation, evictions etc. might
need to be restricted or modified on the coherent device memory node as
they can be performance limiting. The RFC does not propose anything on this
yet but it can be looked into later on. For now it just disables Auto NUMA
for any VMA which has coherent device memory.

	Seamless integration of coherent device memory with system memory
will enable various other features, some of which can be listed as follows.

	a. Seamless migrations between system RAM and the coherent memory
	b. Will have asynchronous and high throughput migrations
	c. Be able to allocate huge order pages from these memory regions
	d. Restrict allocations to a large extent to the tasks using the
	   device for workload acceleration

	Before concluding, will look into the reasons why the existing
solutions don't work. There are two basic requirements which have to be
satisfies before the coherent device memory can be integrated with core
kernel seamlessly.

	a. PFN must have struct page
	b. Struct page must able to be inside standard LRU lists

	The above two basic requirements discard the existing method of
device memory representation approaches like these which then requires the
need of creating a new framework.

(1) Traditional ioremap

	a. Memory is mapped into kernel (linear and virtual) and user space
	b. These PFNs do not have struct pages associated with it
	c. These special PFNs are marked with special flags inside the PTE
	d. Cannot participate in core VM functions much because of this
	e. Cannot do easy user space migrations

(2) Zone ZONE_DEVICE

	a. Memory is mapped into kernel and user space
	b. PFNs do have struct pages associated with it
	c. These struct pages are allocated inside it's own memory range
	d. Unfortunately the struct page's union containing LRU has been
	   used for struct dev_pagemap pointer
	e. Hence it cannot be part of any LRU (like Page cache)
	f. Hence file cached mapping cannot reside on these PFNs
	g. Cannot do easy migrations

	I had also explored non LRU representation of this coherent device
memory where the integration with system RAM in the core VM is limited only
to the following functions. Not being inside LRU is definitely going to
reduce the scope of tight integration with system RAM.

(1) Migration support between system RAM and coherent memory
(2) Migration support between various coherent memory nodes
(3) Isolation of the coherent memory
(4) Mapping the coherent memory into user space through driver's
    struct vm_operations
(5) HW poisoning of the coherent memory

	Allocating the entire memory of the coherent device node right
after hot plug into ZONE_MOVABLE (where the memory is already inside the
buddy system) will still expose a time window where other user space
allocations can come into the coherent device memory node and prevent the
intended isolation. So traditional hot plug is not the solution. Hence
started looking into CMA based non LRU solution but then hit the following
roadblocks.

(1) CMA does not support hot plugging of new memory node
	a. CMA area needs to be marked during boot before buddy is
	   initialized
	b. cma_alloc()/cma_release() can happen on the marked area
	c. Should be able to mark the CMA areas just after memory hot plug
	d. cma_alloc()/cma_release() can happen later after the hot plug
	e. This is not currently supported right now

(2) Mapped non LRU migration of pages
	a. Recent work from Michan Kim makes non LRU page migratable
	b. But it still does not support migration of mapped non LRU pages
	c. With non LRU CMA reserved, again there are some additional
	   challenges

	With hot pluggable CMA and non LRU mapped migration support there
may be an alternate approach to represent coherent device memory. Please do
review this RFC proposal and let me know your comments or suggestions.

Challenges:

ZONELIST approach:
	* Requires node FALLBACK zonelist creation process to be changed
	  to implement implicit allocation isolation. But still provides
	  access to the CDM memory which has system RAM zones as fallback.
	* Requires mbind(MPOL_BIND) semantics to be changed only for the
	  CDM nodes without introducing any regression for others.

CPUSET approach:
	* Removes CDM nodes from the root cpuset and also every process's
	  mems_allowed nodemask to achieve implicit allocation isolation.
	  In the process this also removes the ability to allocate on the
	  CDM node even with the help of  __GFP_THISNODE allocation flag
	  from inside the kernel. Currently we have a brute hack which
	  forces the allocator to ignore cpuset completely if allocation
	  flag has got __GFP_THISNODE
	* Cpuset will require changes in its way of dealing with hardwalled
	  and exclussive cpusets. Its interaction with __GFP_HARDWALL also
	  needed to be audited to implement isolation as well ability to
	  allocate from CDM nodes both in and out of context of the task.

BUDDY approach:
	* We are still looking into this approach where the core buddy
	  allocator __alloc_pages_nodemask() can be changed to implement
	  the required isolation as awell allocation method. This might
	  involve how the passed nodemask interacts with mems_allowed
	  and applicable memory policy which can also be influenced by
	  cpuset changes in the system during fast path as well as slow
	  path allocation.

Open Questions:

HugeTLB allocation isolation:

Now, we ensure complete HugeTLB allocation isolation from CDM nodes. Going
forward if we need to support HugeTLB allocation on CDM nodes on targeted
basis, then we would have to enable those allocations through the
/sys/devices/system/node/nodeN/hugepages/hugepages-16384kB/nr_hugepages
interface while still ensuring isolation from other generic sysctl and
/sys/kernel/mm/hugepages/hugepages-16384kB/nr_hugepages interfaces.


FALLBACK zonelist creation:

CDM node's FALLBACK zonelist can also be changed to accommodate other CDM
memory zones along with system RAM zones in which case they can be used as
fallback options instead of first depending on the sytsem RAM zones when
it's own memory falls insufficient during allocation.

Choice of zonelist:

There are multiple ways of choosing a CDM node's FALLBACK zonelist which
will contain CDM memory in cases where the requesting local node is not
part of the user provided nodemask. This nodemask check can be restricted
to the first node in the nodemask as implemented or it scan through the
entire nodemask provided to find any present CDM node on it to choose or
select the first CDM node only if all other nodes in the nodemask are CDM.
These are variour possible approaches, the first one is implemented in the
current series. We can also implement restrictions during user mbind() sys
call where if a single node is a CDM in the nodemask then all of them have
to be CDM else the request gets declined to maintain simplicity.

VM_CDM tagged VMA:

There are two parts to this problem.

* How to mark a VMA with VM_CDM ?
	- During page fault path
	- During mbind(MPOL_BIND) call
	- Any other paths ?
	- Should a driver mark a VMA with VM_CDM explicitly ?

* How VM_CDM marked VMA gets treated ?

	- Disabled from auto NUMA migrations
	- Disabled from KSM merging
	- Anything else ?

Previous versions:

V1  RFC: https://lkml.org/lkml/2016/10/24/19
V12 RFC: https://lkml.org/lkml/2016/11/22/339

Changes in V2:

* Both the ZONELIST and CPUSET approaches have been combined together to
  utilize maximum possible common code, debug facilities and test programs.
  This will also help in review of individual components. For this purpose
  CONFIG_COHERENT_DEVICE still depends on CONFIG_CPUSET just to achieve
  this unification even its not required for the ZONELIST based proposal.

* NODE_DATA(node)->coherent_device based CDM identification is no longer
  supported. Now CDM is identified through node_state[N_COHERENT_DEVICE]
  based nodemask element which gets popullated when the particular node
  gets hot plugged into the system. It gets clear when the node gets hot
  pluged out from the system. This enables a new sysfs based interface
  /sys/devices/system/node/is_coherent_device which shows all the CDM
  nodes present on the system. Supporting architectures must export a
  function arch_check_node_cdm() which identifies CDM nodes.

* We still have all the names as CDM. But as Dave Hansen had mentioned
  before all these can still be applicable to any generic coherent memory
  type which is not on a device but might be present on processor itself.
  Will change the name appropriately later on.

* Complete isolation on CDM for HugeTLB allocation is achieved through
  ram_nodemask() fetched nodemask instead of using node_states[N_MEMORY]
  directly.

* After the changes with commit 6d8409580b: ("mm, mempolicy: clean up
  __GFP_THISNODE confusion in policy zonelist"), the MPOL_BIND changes
  had to be adjusted for CDM nodes. As regular node's zonelist does not
  contain CDM memory, the zonelist selection has to be from the given
  CDM nodes for the memory to be allocated successfully.

* Added a new patch which makes the KSM ignore madvise(MADV_MERGEABLE)
  request on a CDM memory based VMA.

* Added a new patch which will mark all applicable VMAs with VM_CDM flag
  during mbind(MPOL_BIND) call if the user passed nodemask has a CDM node.

* Brought back all VM_CDM based changes including the auto NUMA change.

* Some amount of code, documentation and commit message cleanups.

Changes in V12:

* Moved from specialized zonelist rebuilding to cpuset based isolation for
  the coherent device memory nodes

* Right now with this new approach, there is no explicit way of allocation
  into the coherent device memory nodes from user space, though it can be
  explored into later on

* Changed the behaviour of __alloc_pages_nodemask() when both cpuset is
  enabled and the allocation request has __GFP_THISNODE flag

* Dropped the VMA flag VM_CDM and related auto NUMA changes

* Dropped migrate_virtual_range() function from the series and moved that
  into the DEBUG patches

NOTE: These two set of patches mutually exclusive of each other and
represent two different approaches. Only one of these sets should be
applied at any point of time.

Set1:
  mm: Change generic FALLBACK zonelist creation process
  mm: Change mbind(MPOL_BIND) implementation for CDM nodes

Set2:
  cpuset: Add cpuset_inc() inside cpuset_init()
  mm: Exclude CDM nodes from task->mems_allowed and root cpuset
  mm: Ignore cpuset enforcement when allocation flag has __GFP_THISNODE

Anshuman Khandual (12):
  mm: Define coherent device memory (CDM) node
  mm: Isolate HugeTLB allocations away from CDM nodes
  mm: Change generic FALLBACK zonelist creation process
  mm: Change mbind(MPOL_BIND) implementation for CDM nodes
  cpuset: Add cpuset_inc() inside cpuset_init()
  mm: Exclude CDM nodes from task->mems_allowed and root cpuset
  mm: Ignore cpuset enforcement when allocation flag has __GFP_THISNODE
  mm: Add new VMA flag VM_CDM
  mm: Exclude CDM marked VMAs from auto NUMA
  mm: Ignore madvise(MADV_MERGEABLE) request for VM_CDM marked VMAs
  mm: Tag VMA with VM_CDM flag during page fault
  mm: Tag VMA with VM_CDM flag explicitly during mbind(MPOL_BIND)

 Documentation/ABI/stable/sysfs-devices-node |  7 ++++
 arch/powerpc/Kconfig                        |  1 +
 arch/powerpc/mm/numa.c                      |  7 ++++
 drivers/base/node.c                         |  6 +++
 include/linux/mempolicy.h                   | 14 +++++++
 include/linux/mm.h                          |  5 +++
 include/linux/node.h                        | 49 +++++++++++++++++++++++
 include/linux/nodemask.h                    |  3 ++
 kernel/cpuset.c                             | 14 ++++---
 kernel/sched/fair.c                         |  3 +-
 mm/Kconfig                                  |  5 +++
 mm/hugetlb.c                                | 25 +++++++-----
 mm/ksm.c                                    |  4 ++
 mm/memory_hotplug.c                         | 10 +++++
 mm/mempolicy.c                              | 62 +++++++++++++++++++++++++++++
 mm/page_alloc.c                             | 12 +++++-
 16 files changed, 211 insertions(+), 16 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
