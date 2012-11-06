Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id DFBD46B0068
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:40:42 -0500 (EST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 05:38:40 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JUJCu3080616
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:30:19 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6JeWr5017327
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:40:32 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 00/10][Hierarchy] mm: Linux VM Infrastructure to support
 Memory Power Management
Date: Wed, 07 Nov 2012 01:09:25 +0530
Message-ID: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

This is a forward-port of the Memory Power Management patchset that Ankita
Garg had posted last year [5], to current mainline (3.7-rc3). This design
introduces memory regions in-between the node->zone hierarchy, and is hence
termed as the "Hierarchy" design.

I'll be immediately posting another patchset that implements an alternative
design (very different from this one) developed based on the review feedback
that was received [7] for the above patchset last year. This new design alters
the buddy-lists and keeps them region-sorted, and is hence identified as
the "Sorted-buddy" design.

The idea behind forward-porting the earlier patchset ("Hierarchy" design) and
also posting a new alternative ("Sorted-buddy" design), is to enable people
to see and evaluate the 2 designs side-by-side and compare how well they meet
the various requirements and also perhaps to identify the best parts of both
the designs, for further improvement.


Though the original implementation of this "Hierarchy" design was targetted for
and tested on ARM platforms, this forward-port includes changes to make it work
on x86 as well (minimalistic config). Original patchset description follows...

-----------------------------------------------------------------------------

Modern systems offer higher CPU performance and large amount of memory in
each generation in order to support application demands.  Memory subsystem has
began to offer wide range of capabilities for managing power consumption,
which is driving the need to relook at the way memory is managed by the
operating system. Linux VM subsystem has sophisticated algorithms to
optimally  manage the scarce resources for best overall system performance.
Apart from the capacity and location of memory areas, the VM subsystem tracks
special addressability restrictions in zones and relative distance from CPU as
NUMA nodes if necessary. Power management capabilities in the memory subsystem
and inclusion of different class of main memory like PCM, or non-volatile RAM,
brings in new boundaries and attributes that needs to be tagged within the
Linux VM subsystem for exploitation by the kernel and applications.

This patchset proposes a generic memory regions infrastructure that can be
used to tag boundaries of memory blocks which belongs to a specific memory
power management domain and further enable exploitation of platform memory
power management capabilities.

How can Linux VM help memory power savings?

o Consolidate memory allocations and/or references such that they are
not spread across the entire memory address space.  Basically area of memory
that is not being referenced, can reside in low power state.

o Support targeted memory reclaim, where certain areas of memory that can be
easily freed can be offlined, allowing those areas of memory to be put into
lower power states.

What is a Memory Region ?
-------------------------

Memory regions is a generic memory management framework that enables the
virtual memory manager to consider memory characteristics when making memory
allocation and deallocation decisions. It is a layer of abstraction under the
real NUMA nodes, that encapsulate knowledge of the underlying memory hardware.
This layer is created at boot time, with information from firmware regarding
the granularity at which memory power can be managed on the platform. For
example, on platforms with support for Partial Array Self-Refresh (PASR) [1],
regions could be aligned to memory unit that can be independently put into
self-refresh or turned off (content destructive power off). On the other hand,
platforms with support for multiple memory controllers that control the power
states of memory, one memory region could be created for all the memory under
a single memory controller.

The aim of the alignment is to ensure that memory allocations, deallocations
and reclaim are performed within a defined hardware boundary. By creating
zones under regions, the buddy allocator would operate at the level of
regions. The proposed data structure is as shown in the Figure below:


             -----------------------------
             |N0 |N1 |N2 |N3 |.. |.. |Nn |
             -----------------------------
             / \ \
            /   \  \
           /     \   \
 ------------    |  ------------
 | Mem Rgn0 |    |  | Mem Rgn3 |
 ------------    |  ------------
    |            |         |
    |      ------------    | ---------
    |      | Mem Rgn1 |    ->| zones |
    |      ------------      ---------
    |          |     ---------
    |          ----->| zones |
    | ---------      ---------
    ->| zones |
      ---------

Memory regions enable the following :

o Sequential allocation of memory in the order of memory regions, thus
  ensuring that greater number of memory regions are devoid of allocations to
  begin with
o With time however, the memory allocations will tend to be spread across
  different regions. But the notion of a region boundary and region level
  memory statistics will enable specific regions to be evacuated using
  targetted allocation and reclaim.

Lumpy reclaim and other memory compaction work by Mel Gorman, would further
aid in consolidation of memory [4].

Memory regions is just a base infrastructure that would enable the Linux VM to
be aware of the physical memory hardware characterisitics, a pre-requisite to
implementing other sophisticated algorithms and techniques to actually
conserve power.

Advantages
-----------

Memory regions framework works with existing memory management data
structures and only adds one more layer of abstraction that is required to
capture special boundaries and properties.  Most VM code paths work similar
to current implementation with additional traversal of zone data structures
in pre-defined order.

Alternative Approach:

There are other ways in which memory belonging to the same power domain could
be grouped together. Fake NUMA nodes under a real NUMA node could encapsulate
information about the memory hardware units that can be independently power
managed. With minimal code changes, the same functionality as memory regions
can be achieved. However, the fake NUMA nodes is a non-intuitive solution,
that breaks the NUMA semantics and is not generic in nature. It would present
an incorrect view of the system to the administrator, by showing that it has a
greater number of NUMA nodes than actually present.

Challenges
----------

o Memory interleaving is typically used on all platforms to increase the
  memory bandwidth and hence memory performance. However, in the presence of
  interleaving, the amount of idle memory within the hardware domain reduces,
  impacting power savings. For a given platform, it is important to select an
  interleaving scheme that gives good performance with optimum power savings.

This is a RFC patchset with minimal functionality to demonstrate the
requirement and proposed implementation options. It has been tested on TI
OMAP4 Panda board with 1Gb RAM and the Samsung Exynos 4210 board. The patch
applies on kernel version 2.6.39-rc5 (this version applies on 3.7-rc3), compiled
with the default config files for the two platforms. I have turned off cgroup,
memory hotplug and kexec to begin. Support to these framework can be easily
extended. The u-boot bootloader does not yet export information regarding the
physical memory bank boundaries and hence the regions are not correctly aligned
to hardware and hence hard coded for test/demo purposes. Also, the code assumes
that atleast one region is present in the node. Compile time exclusion of memory
regions is a todo.

Results (from [5])
------------------------------
Ran pagetest, a simple C program that allocates and touches a required number
of pages, on a Samsung Exynos 4210 board with ~2GB RAM, booted with 4 memory
regions, each with ~512MB. The allocation size used was 512MB. Below is the
free page statistics while running the benchmark:

		---------------------------------------
	 	|	   | start  | ~480MB |  512MB |
		---------------------------------------
		| Region 0 | 124013 | 1129   | 484    |
		| Region 1 | 131072 | 131072 | 130824 |
		| Region 2 | 131072 | 131072 | 131072 |
		| Region 3 | 57332  | 57332  | 57332  |
		---------------------------------------

(The total number of pages in Region 3 is 57332, as it contains all the
remaining pages and hence the region size is not 512MB).

Column 1 indicates the number of free pages in each region at the start of the
benchmark, column 2 at about 480MB allocation and column 3 at 512MB
allocation. The memory in regions 1,2 & 3 is free and only region0 is
utilized. So if the regions are aligned to the hardware memory units, free
regions could potentially be put either into low power state or turned off. It
may be possible to allocate from lower address without regions, but once the
page reclaim comes into play, the page allocations will tend to get spread
around.

References
----------

[1] Partial Array Self Refresh
    http://focus.ti.com/general/docs/wtbu/wtbudocumentcenter.tsp?templateId=6123&navigationId=12037

[2] TI OMAP$ Panda board
    http://pandaboard.org/node/224/#manual

[3] Memory Regions discussion at Ubuntu Development Summit, May 2011
    https://wiki.linaro.org/Specs/KernelGeneralPerformanceO?action=AttachFile&do=view&target=k81-memregions.odp

[4] Memory compaction
    http://lwn.net/Articles/368869/

[5] First posting of this patch series:
    http://lwn.net/Articles/445045/
    http://thread.gmane.org/gmane.linux.kernel.mm/63840

    Summary of the discussions on this patchset:
    http://article.gmane.org/gmane.linux.power-management.general/25061

[6] Estimate of potential power savings on Samsung exynos board
    http://article.gmane.org/gmane.linux.kernel.mm/65935

[7] Review comments suggesting modifying the buddy allocator to be aware of
    memory regions:
    http://article.gmane.org/gmane.linux.power-management.general/24862
    http://article.gmane.org/gmane.linux.power-management.general/25061
    http://article.gmane.org/gmane.linux.kernel.mm/64689

 Ankita Garg (10):
      mm: Introduce the memory regions data structure
      mm: Helper routines
      mm: Init zones inside memory regions
      mm: Refer to zones from memory regions
      mm: Create zonelists
      mm: Verify zonelists
      mm: Modify vmstat
      mm: Modify vmscan
      mm: Reflect memory region changes in zoneinfo
      mm: Create memory regions at boot-up


  include/linux/mm.h     |   11 +
 include/linux/mmzone.h |   55 +++++--
 include/linux/vmstat.h |   21 ++-
 mm/mm_init.c           |   57 ++++---
 mm/mmzone.c            |   48 +++++-
 mm/page_alloc.c        |  398 +++++++++++++++++++++++++++++++-----------------
 mm/vmscan.c            |  364 +++++++++++++++++++++++---------------------
 mm/vmstat.c            |   71 +++++----
 8 files changed, 631 insertions(+), 394 deletions(-)


Thanks,
Srivatsa S. Bhat
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
