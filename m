Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 073926B0036
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:48:19 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 07:40:49 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id B45D32BB0051
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:48:08 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39Lm31u10617190
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:48:03 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39Lm7Nh007558
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:48:08 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 00/15][Sorted-buddy] mm: Memory Power Management
Date: Wed, 10 Apr 2013 03:15:28 +0530
Message-ID: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


[I know, this cover letter is a little too long, but I wanted to clearly
explain the overall goals and the high-level design of this patchset in
detail. I hope this helps more than it annoys, and makes it easier for
reviewers to relate to the background and the goals of this patchset.]


Overview of Memory Power Management and its implications to the Linux MM
========================================================================

Today, we are increasingly seeing computer systems sporting larger and larger
amounts of RAM, in order to meet workload demands. However, memory consumes a
significant amount of power, potentially upto more than a third of total system
power on server systems. So naturally, memory becomes the next big target for
power management - on embedded systems and smartphones, and all the way upto
large server systems.

Power-management capabilities in modern memory hardware:
-------------------------------------------------------

Modern memory hardware such as DDR3 support a number of power management
capabilities - for instance, the memory controller can automatically put
memory DIMMs/banks into content-preserving low-power states, if it detects
that that *entire* memory DIMM/bank has not been referenced for a threshold
amount of time, thus reducing the energy consumption of the memory hardware.
We term these power-manageable chunks of memory as "Memory Regions".

Exporting memory region info of the platform to the OS:
------------------------------------------------------

The OS needs to know about the granularity at which the hardware can perform
automatic power-management of the memory banks (i.e., the address boundaries
of the memory regions). On ARM platforms, the bootloader can be modified to
pass on this info to the kernel via the device-tree. On x86 platforms, the
new ACPI 5.0 spec has added support for exporting the power-management
capabilities of the memory hardware to the OS in a standard way[5].

Estimate of power-savings from power-aware Linux MM:
---------------------------------------------------

Once the firmware/bootloader exports the required info to the OS, it is upto
the kernel's MM subsystem to make the best use of these capabilities and manage
memory power-efficiently. It had been demonstrated on a Samsung Exynos board
(with 2 GB RAM) that upto 6 percent of total system power can be saved by
making the Linux kernel MM subsystem power-aware[4]. (More savings can be
expected on systems with larger amounts of memory, and perhaps improved further
using better MM designs).


Role of the Linux MM in enhancing memory power savings:
------------------------------------------------------

Often, this simply translates to having the Linux MM understand the granularity
at which RAM modules can be power-managed, and keeping the memory allocations
and references consolidated to a minimum no. of these power-manageable
"memory regions". It is of particular interest to note that most of these memory
hardware have the intelligence to automatically save power, by putting memory
banks into (content-preserving) low-power states when not referenced for a
threshold amount of time. All that the kernel has to do, is avoid wrecking
the power-savings logic by scattering its allocations and references all over
the system memory. (The kernel/MM doesn't have to perform the actual power-state
transitions; its mostly done in the hardware automatically, and this is OK
because these are *content-preserving* low-power states).

So we can summarize the goals for the Linux MM as:

o Consolidate memory allocations and/or references such that they are not
spread across the entire memory address space.  Basically the area of memory
that is not being referenced can reside in low power state.

o Support light-weight targetted memory compaction/reclaim, to evacuate
lightly-filled memory regions. This helps avoid memory references to
those regions, thereby allowing them to reside in low power states.


Assumptions and goals of this patchset:
--------------------------------------

In this patchset, we don't handle the part of getting the region boundary info
from the firmware/bootloader and populating it in the kernel data-structures.
The aim of this patchset is to propose and brainstorm on a power-aware design
of the Linux MM which can *use* the region boundary info to influence the MM
at various places such as page allocation, reclamation/compaction etc, thereby
contributing to memory power savings. (This patchset is very much an RFC at
the moment and is not intended for mainline-inclusion yet).

So, in this patchset, we assume a simple model in which each 512MB chunk of
memory can be independently power-managed, and hard-code this into the patchset.
As mentioned, the focus of this patchset is not so much on how we get this info
from the firmware or how exactly we handle a variety of configurations, but
rather on discussing the power-savings/performance impact of the MM algorithms
that *act* upon this info in order to save memory power.

That said, its not very far-fetched to try this out with actual region
boundary info to get the actual power savings numbers. For example, on ARM
platforms, we can make the bootloader export this info to the OS via device-tree
and then run this patchset. (This was the method used to get the power-numbers
in [4]). But even without doing that, we can very well evaluate the
effectiveness of this patchset in contributing to power-savings, by analyzing
the free page statistics per-memory-region; and we can observe the performance
impact by running benchmarks - this is the approach currently used to evaluate
this patchset.


Brief overview of the design/approach used in this patchset:
-----------------------------------------------------------

This patchset implements the 'Sorted-buddy design' for Memory Power Management,
in which the buddy (page) allocator is altered to keep the buddy freelists
region-sorted, which helps influence the page allocation paths to keep the
allocations consolidated to a minimum no. of memory regions. This patchset also
includes a light-weight targetted compaction/reclaim algorithm that works
hand-in-hand with the page-allocator, to evacuate lightly-filled memory regions
when memory gets fragmented, in order to further enhance memory power savings.

This Sorted-buddy design was developed based on some of the suggestions
received[1] during the review of the earlier patchset on Memory Power
Management written by Ankita Garg ('Hierarchy design')[2].
One of the key aspects of this Sorted-buddy design is that it avoids the
zone-fragmentation problem that was present in the earlier design[3].



Design of sorted buddy allocator and light-weight targetted region compaction:
=============================================================================

Sorted buddy allocator:
----------------------

In this design, the memory region boundaries are captured in a data structure
parallel to zones, instead of fitting regions between nodes and zones in the
hierarchy. Further, the buddy allocator is altered, such that we maintain the
zones' freelists in region-sorted-order and thus do page allocation in the
order of increasing memory regions. (The freelists need not be fully
address-sorted, they just need to be region-sorted).

The idea is to do page allocation in increasing order of memory regions
(within a zone) and perform region-compaction in the reverse order, as
illustrated below.

---------------------------- Increasing region number---------------------->

Direction of allocation--->               <---Direction of region-compaction


The sorting logic (to maintain freelist pageblocks in region-sorted-order)
lies in the page-free path and hence the critical page-allocation paths remain
fast. Also, the sorting logic is optimized to be O(log n).

Advantages of this design:
--------------------------
1. No zone-fragmentation (IOW, we don't create more zones than necessary) and
   hence we avoid its associated problems (like too many zones, extra kswapd
   activity, question of choosing watermarks etc).
   [This is an advantage over the 'Hierarchy' design]

2. Performance overhead is expected to be low: Since we retain the simplicity
   of the algorithm in the page allocation path, page allocation can
   potentially remain as fast as it would be without memory regions. The
   overhead is pushed to the page-freeing paths which are not that critical.


Light-weight targetted region compaction:
----------------------------------------

Over time, due to multiple alloc()s and free()s in random order, memory gets
fragmented, which means the memory allocations will no longer be consolidated
to a minimum no. of memory regions. In such cases we need a light-weight
mechanism to opportunistically compact memory to evacuate lightly-filled
memory regions, thereby enhancing the power-savings.

Noting that CMA (Contiguous Memory Allocator) does targetted compaction to
achieve its goals, this patchset generalizes the targetted compaction code
and reuses it to evacuate memory regions. The region evacuation is triggered
by the page allocator : when it notices the first page allocation in a new
region, it sets up a worker function to perform compaction and evacuate that
region in the future, if possible. There are handshakes between the alloc
and the free paths in the page allocator to help do this smartly, which are
explained in detail in the patches.


This patchset has been hosted in the below git tree. It applies cleanly on
v3.9-rc5.

git://github.com/srivatsabhat/linux.git mem-power-mgmt-v2


Changes in this v2:
==================

* Fixed a bug in the NUMA case.
* Added a new optimized O(log n) sorting algorithm to speed up region-sorting
  of the buddy freelists (patch 9). The efficiency of this new algorithm and
  its design allows us to support large amounts of RAM quite easily.
* Added light-weight targetted compaction/reclaim support for memory power
  management (patches 10-14).
* Revamped the cover-letter to better explain the idea behind memory power
  management and this patchset.


Experimental Results:
====================

Test setup:
----------

x86 dual-socket quad core HT-enabled machine booted with mem=8G
Memory region size = 512 MB

Functional testing:
------------------

Ran pagetest, a simple C program that allocates and touches a required number
of pages.

Below is the statistics from the regions within ZONE_NORMAL, at various sizes
of allocations from pagetest.


	     Present pages   |	Free pages at various allocation sizes   |
			     |  start	|  512 MB  |  1024 MB | 2048 MB  |
  Region 0           1	     |      0   |      0   |       0  |       0  |
  Region 1      131072       |  41537   |  13858   |   13790  |   13334  |
  Region 2      131072       | 131072   |  26839   |      82  |     122  |
  Region 3      131072       | 131072   | 131072   |   26624  |       0  |
  Region 4      131072       | 131072   | 131072   |  131072  |       0  |
  Region 5      131072       | 131072   | 131072   |  131072  |   26624  |
  Region 6      131072       | 131072   | 131072   |  131072  |  131072  |
  Region 7      131072       | 131072   | 131072   |  131072  |  131072  |
  Region 8      131071       |  72704   |  72704   |   72704  |   72704  |

This shows that page allocation occurs in the order of increasing region
numbers, as intended in this design.

Performance impact:
-------------------

Kernbench results didn't show any noticeable performance degradation with
this patchset as compared to vanilla 3.9-rc5.


Todos and ideas for enhancing the design further:
================================================

1. Add support for making this work with sparsemem, memcg etc.

2. Mel Gorman pointed out that regular compaction algorithm would work
   against the sorted-buddy allocation strategy, since it creates free space
   at lower pfns. For now, I have not handled this because regular compaction
   triggers only when the memory pressure is very high, and hence memory
   power management is pointless in those situations. Besides, it is
   immaterial whether memory allocations are consolidated towards lower or
   higher pfns, because it saves power either way, and hence the regular
   compaction algorithm doesn't actually work against memory power management.

3. Add more optimizations to the targetted region compaction algorithm in order
   to enhance its benefits and reduce the overhead, such as:
   a. Migrate only active pages during region evacuation, because, strictly
      speaking we only want to avoid _references_ to the region. So inactive
      pages can be kept around, thus reducing the page-migration overhead.
   b. Reduce the search-space for region evacuation, by having the
      page-allocator note down the highest allocated pfn within that region.

4. Have stronger influence over how freepages from different migratetypes
   are exchanged, so that unmovable and non-reclaimable allocations are
   contained within least no. of memory regions.

5. Influence the refill of per-cpu pagesets and perhaps even heavily used
   slab caches, such that they all get their memory from least no. of memory
   regions. This is to avoid frequent fragmentation of memory regions.

6. Don't perform region evacuation at situations of high memory utilization.
   Also, never use freepages from MIGRATE_RESERVE for the purpose of
   region-evacuation.

7. Add more tracing/debug info to enable better evaluation of the
   effectiveness and benefits of this patchset over vanilla kernel.

8. Add a higher level policy to control the aggressiveness of memory power
   management.


References:
----------

[1]. Review comments suggesting modifying the buddy allocator to be aware of
     memory regions:
     http://article.gmane.org/gmane.linux.power-management.general/24862
     http://article.gmane.org/gmane.linux.power-management.general/25061
     http://article.gmane.org/gmane.linux.kernel.mm/64689

[2]. Patch series that implemented the node-region-zone hierarchy design:
     http://lwn.net/Articles/445045/
     http://thread.gmane.org/gmane.linux.kernel.mm/63840

     Summary of the discussion on that patchset:
     http://article.gmane.org/gmane.linux.power-management.general/25061

     Forward-port of that patchset to 3.7-rc3 (minimal x86 config)
     http://thread.gmane.org/gmane.linux.kernel.mm/89202

[3]. Disadvantages of having memory regions in the hierarchy between nodes and
     zones:
     http://article.gmane.org/gmane.linux.kernel.mm/63849

[4]. Estimate of potential power savings on Samsung exynos board
     http://article.gmane.org/gmane.linux.kernel.mm/65935

[5]. ACPI 5.0 and MPST support
     http://www.acpi.info/spec.htm
     Section 5.2.21 Memory Power State Table (MPST)

[6]. v1 of Sorted-buddy memory power management patchset:
     http://thread.gmane.org/gmane.linux.power-management.general/28498


 Srivatsa S. Bhat (15):
      mm: Introduce memory regions data-structure to capture region boundaries within nodes
      mm: Initialize node memory regions during boot
      mm: Introduce and initialize zone memory regions
      mm: Add helpers to retrieve node region and zone region for a given page
      mm: Add data-structures to describe memory regions within the zones' freelists
      mm: Demarcate and maintain pageblocks in region-order in the zones' freelists
      mm: Add an optimized version of del_from_freelist to keep page allocation fast
      bitops: Document the difference in indexing between fls() and __fls()
      mm: A new optimized O(log n) sorting algo to speed up buddy-sorting
      mm: Add support to accurately track per-memory-region allocation
      mm: Restructure the compaction part of CMA for wider use
      mm: Add infrastructure to evacuate memory regions using compaction
      mm: Implement the worker function for memory region compaction
      mm: Add alloc-free handshake to trigger memory region compaction
      mm: Print memory region statistics to understand the buddy allocator behavior


  arch/x86/include/asm/bitops.h      |    4 
 include/asm-generic/bitops/__fls.h |    5 
 include/linux/compaction.h         |    7 
 include/linux/gfp.h                |    2 
 include/linux/migrate.h            |    3 
 include/linux/mm.h                 |   62 ++++
 include/linux/mmzone.h             |   78 ++++-
 include/trace/events/migrate.h     |    3 
 mm/compaction.c                    |  149 +++++++++
 mm/internal.h                      |   40 ++
 mm/page_alloc.c                    |  617 ++++++++++++++++++++++++++++++++----
 mm/vmstat.c                        |   36 ++
 12 files changed, 935 insertions(+), 71 deletions(-)


Regards,
Srivatsa S. Bhat
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
