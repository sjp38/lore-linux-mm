Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 5217E6B0039
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:18:45 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 07:18:44 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 061A319D8043
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:18:04 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDHs0s040586
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:17:55 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDHok9015838
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:17:54 -0600
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RESEND RFC PATCH v3 00/35] mm: Memory Power Management
Date: Fri, 30 Aug 2013 18:43:54 +0530
Message-ID: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[ Resending, since some of the patches didn't go through successfully
the last time around. ]

Overview of Memory Power Management and its implications to the Linux MM
========================================================================

Today, we are increasingly seeing computer systems sporting larger and larger
amounts of RAM, in order to meet workload demands. However, memory consumes a
significant amount of power, potentially upto more than a third of total system
power on server systems[4]. So naturally, memory becomes the next big target
for power management - on embedded systems and smartphones, and all the way
upto large server systems.

Power-management capabilities in modern memory hardware:
-------------------------------------------------------

Modern memory hardware such as DDR3 support a number of power management
capabilities - for instance, the memory controller can automatically put
memory DIMMs/banks into content-preserving low-power states, if it detects
that the *entire* memory DIMM/bank has not been referenced for a threshold
amount of time, thus reducing the energy consumption of the memory hardware.
We term these power-manageable chunks of memory as "Memory Regions".

Exporting memory region info from the platform to the OS:
--------------------------------------------------------

The OS needs to know about the granularity at which the hardware can perform
automatic power-management of the memory banks (i.e., the address boundaries
of the memory regions). On ARM platforms, the bootloader can be modified to
pass on this info to the kernel via the device-tree. On x86 platforms, the
new ACPI 5.0 spec has added support for exporting the power-management
capabilities of the memory hardware to the OS in a standard way[5][6].

Estimate of power-savings from power-aware Linux MM:
---------------------------------------------------

Once the firmware/bootloader exports the required info to the OS, it is upto
the kernel's MM subsystem to make the best use of these capabilities and manage
memory power-efficiently. It had been demonstrated on a Samsung Exynos board
(with 2 GB RAM) that upto 6 percent of total system power can be saved by
making the Linux kernel MM subsystem power-aware[3]. (More savings can be
expected on systems with larger amounts of memory, and perhaps improved further
using better MM designs).


Role of the Linux MM in enhancing memory power savings:
------------------------------------------------------

Often, this simply translates to having the Linux MM understand the granularity
at which RAM modules can be power-managed, and keeping the memory allocations
and references consolidated to a minimum no. of these power-manageable
"memory regions". The memory hardware has the intelligence to automatically
transition memory banks that haven't been referenced for a threshold amount
of time, to low-power content-preserving states. And they can also perform
OS-cooperative power-off of unused (unallocated) memory regions. So the onus
is on the Linux VM to become power-aware and shape the allocations and
influence the references in such a way that it helps conserve memory power.
This involves consolidating the allocations/references at the right address
boundaries, keeping the memory-region granularity in mind.


So we can summarize the goals for the Linux MM as follows:

o Consolidate memory allocations and/or references such that they are not
spread across the entire memory address space, because the area of memory
that is not being referenced can reside in low power state.

o Support light-weight targeted memory compaction/reclaim, to evacuate
lightly-filled memory regions. This helps avoid memory references to
those regions, thereby allowing them to reside in low power states.


Assumptions and goals of this patchset:
--------------------------------------

In this patchset, we don't handle the part of getting the region boundary info
from the firmware/bootloader and populating it in the kernel data-structures.
The aim of this patchset is to propose and brainstorm on a power-aware design
of the Linux MM which can *use* the region boundary info to influence the MM
at various places such as page allocation, reclamation/compaction etc, thereby
contributing to memory power savings.

So, in this patchset, we assume a simple model in which each 512MB chunk of
memory can be independently power-managed, and hard-code this in the kernel.
As mentioned, the focus of this patchset is not so much on how we get this info
from the firmware or how exactly we handle a variety of configurations, but
rather on discussing the power-savings/performance impact of the MM algorithms
that *act* upon this info in order to save memory power.

That said, its not very far-fetched to try this out with actual region
boundary info to get the real power savings numbers. For example, on ARM
platforms, we can make the bootloader export this info to the OS via device-tree
and then run this patchset. (This was the method used to get the power-numbers
in [3]). But even without doing that, we can very well evaluate the
effectiveness of this patchset in contributing to power-savings, by analyzing
the free page statistics per-memory-region; and we can observe the performance
impact by running benchmarks - this is the approach currently used to evaluate
this patchset.


Brief overview of the design/approach used in this patchset:
-----------------------------------------------------------

The strategy used in this patchset is to do page allocation in increasing order
of memory regions (within a zone) and perform region-compaction in the reverse
order, as illustrated below.

---------------------------- Increasing region number---------------------->

Direction of allocation--->               <---Direction of region-compaction


We achieve this by making 3 major design changes to the Linux kernel memory
manager, as outlined below.

1. Sorted-buddy design of buddy freelists:

   To allocate pages in increasing order of memory regions, we first capture
   the memory region boundaries in suitable zone-level data-structures, and
   modify the buddy allocator such that we maintain the buddy freelists in
   region-sorted-order. Thus, automatically page allocation occurs in the
   order of increasing memory regions.

2. Split-allocator design: Page-Allocator as front-end; Region-Allocator as
   back-end:

   Mixing up movable and unmovable pages can disrupt opportunities for
   consolidating allocations. In order to separate such pages at a memory-region
   granularity, a "Region-Allocator" is introduced which allocates entire memory
   regions. The Page-Allocator is then modified to get its memory from the
   Region-Allocator and hand out pages to requesting applications in
   page-sized chunks. This design is showing significant improvements in the
   effectiveness of this patchset in consolidating allocations to minimum no.
   of memory regions.

3. Targeted region compaction/evacuation:

   Over time, due to multiple alloc()s and free()s in random order, memory gets
   fragmented, which means the memory allocations will no longer be consolidated
   to a minimum no. of memory regions. In such cases we need a light-weight
   mechanism to opportunistically compact memory to evacuate lightly-filled
   memory regions, thereby enhancing the power-savings.

   Noting that CMA (Contiguous Memory Allocator) does targeted compaction to
   achieve its goals, the v2 of this patchset generalized the targeted
   compaction code and reused it to evacuate memory regions.

   [ I have temporarily dropped this feature in this version (v3) of the
    patchset, since it can benefit from some considerable changes. I'll revive
    it in the next version and integrate it with the split-allocator design. ]


Experimental Results:
====================

I'll include the detailed results as a reply to this cover-letter, since it
can benefit from a dedicated discussion, rather than squeezing it here itself.


This patchset has been hosted in the below git tree. It applies cleanly on
v3.11-rc7.

git://github.com/srivatsabhat/linux.git mem-power-mgmt-v3


Changes in v3:
=============

* The major change is the splitting of the memory allocator into a
  Page-Allocator front-end and a Region-Allocator back-end. This helps in
  keeping movable and unmovable allocations separated across region
  boundaries, thus improving the opportunities for consolidation of memory
  allocations to a minimum no. of regions.

* A bunch of fixes all over, especially in the handling of freepage
  migratetypes and the buddy merging code.


Changes in v2:
=============

* Fixed a bug in the NUMA case.
* Added a new optimized O(log n) sorting algorithm to speed up region-sorting
  of the buddy freelists (patch 9). The efficiency of this new algorithm and
  its design allows us to support large amounts of RAM quite easily.
* Added light-weight targetted compaction/reclaim support for memory power
  management (patches 10-14).
* Revamped the cover-letter to better explain the idea behind memory power
  management and this patchset.


Some important TODOs:
====================

1. Revive the targeted region-compaction/evacuation code and make it
   work well with the new Page-Allocator - Region-Allocator split design.

2. Add optimizations to improve the performance and reduce the overhead in
   the MM hot paths.

3. Add support for making this patchset work with sparsemem, THP, memcg etc.


References:
----------

[1]. LWN article that explains the goals and the design of my Memory Power
     Management patchset:
     http://lwn.net/Articles/547439/

[2]. v2 of the "Sorted-buddy" patchset with support for targeted memory
     region compaction:
     http://lwn.net/Articles/546696/

     LWN article describing this design: http://lwn.net/Articles/547439/

     v1 of the patchset:
     http://thread.gmane.org/gmane.linux.power-management.general/28498

[3]. Estimate of potential power savings on Samsung exynos board
     http://article.gmane.org/gmane.linux.kernel.mm/65935

[4]. C. Lefurgy, K. Rajamani, F. Rawson, W. Felter, M. Kistler, and Tom Keller.
     Energy management for commercial servers. In IEEE Computer, pages 39a??48,
     Dec 2003.
     Link: researcher.ibm.com/files/us-lefurgy/computer2003.pdf

[5]. ACPI 5.0 and MPST support
     http://www.acpi.info/spec.htm
     Section 5.2.21 Memory Power State Table (MPST)

[6]. Prototype implementation of parsing of ACPI 5.0 MPST tables, by Srinivas
     Pandruvada.
     https://lkml.org/lkml/2013/4/18/349

[7]. Review comments suggesting modifying the buddy allocator to be aware of
     memory regions:
     http://article.gmane.org/gmane.linux.power-management.general/24862
     http://article.gmane.org/gmane.linux.power-management.general/25061
     http://article.gmane.org/gmane.linux.kernel.mm/64689

[8]. Patch series that implemented the node-region-zone hierarchy design:
     http://lwn.net/Articles/445045/
     http://thread.gmane.org/gmane.linux.kernel.mm/63840

     Summary of the discussion on that patchset:
     http://article.gmane.org/gmane.linux.power-management.general/25061

     Forward-port of that patchset to 3.7-rc3 (minimal x86 config)
     http://thread.gmane.org/gmane.linux.kernel.mm/89202

[9]. Disadvantages of having memory regions in the hierarchy between nodes and
     zones:
     http://article.gmane.org/gmane.linux.kernel.mm/63849


 Srivatsa S. Bhat (35):
      mm: Restructure free-page stealing code and fix a bug
      mm: Fix the value of fallback_migratetype in alloc_extfrag tracepoint
      mm: Introduce memory regions data-structure to capture region boundaries within nodes
      mm: Initialize node memory regions during boot
      mm: Introduce and initialize zone memory regions
      mm: Add helpers to retrieve node region and zone region for a given page
      mm: Add data-structures to describe memory regions within the zones' freelists
      mm: Demarcate and maintain pageblocks in region-order in the zones' freelists
      mm: Track the freepage migratetype of pages accurately
      mm: Use the correct migratetype during buddy merging
      mm: Add an optimized version of del_from_freelist to keep page allocation fast
      bitops: Document the difference in indexing between fls() and __fls()
      mm: A new optimized O(log n) sorting algo to speed up buddy-sorting
      mm: Add support to accurately track per-memory-region allocation
      mm: Print memory region statistics to understand the buddy allocator behavior
      mm: Enable per-memory-region fragmentation stats in pagetypeinfo
      mm: Add aggressive bias to prefer lower regions during page allocation
      mm: Introduce a "Region Allocator" to manage entire memory regions
      mm: Add a mechanism to add pages to buddy freelists in bulk
      mm: Provide a mechanism to delete pages from buddy freelists in bulk
      mm: Provide a mechanism to release free memory to the region allocator
      mm: Provide a mechanism to request free memory from the region allocator
      mm: Maintain the counter for freepages in the region allocator
      mm: Propagate the sorted-buddy bias for picking free regions, to region allocator
      mm: Fix vmstat to also account for freepages in the region allocator
      mm: Drop some very expensive sorted-buddy related checks under DEBUG_PAGEALLOC
      mm: Connect Page Allocator(PA) to Region Allocator(RA); add PA => RA flow
      mm: Connect Page Allocator(PA) to Region Allocator(RA); add PA <= RA flow
      mm: Update the freepage migratetype of pages during region allocation
      mm: Provide a mechanism to check if a given page is in the region allocator
      mm: Add a way to request pages of a particular region from the region allocator
      mm: Modify move_freepages() to handle pages in the region allocator properly
      mm: Never change migratetypes of pageblocks during freepage stealing
      mm: Set pageblock migratetype when allocating regions from region allocator
      mm: Use a cache between page-allocator and region-allocator


 arch/x86/include/asm/bitops.h      |    4 
 include/asm-generic/bitops/__fls.h |    5 
 include/linux/mm.h                 |   42 ++
 include/linux/mmzone.h             |   75 +++
 include/trace/events/kmem.h        |   10 
 mm/compaction.c                    |    2 
 mm/page_alloc.c                    |  935 +++++++++++++++++++++++++++++++++---
 mm/vmstat.c                        |  130 +++++
 8 files changed, 1124 insertions(+), 79 deletions(-)


Regards,
Srivatsa S. Bhat
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
