Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A64866B005A
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:53:26 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 05:49:44 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JrKMG393472
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:53:21 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6JrK9d011027
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:53:20 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to support
 Memory Power Management
Date: Wed, 07 Nov 2012 01:22:13 +0530
Message-ID: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

This is an alternative design for Memory Power Management, developed based on
some of the suggestions[1] received during the review of the earlier patchset
("Hierarchy" design) on Memory Power Management[2]. This alters the buddy-lists
to keep them region-sorted, and is hence identified as the "Sorted-buddy" design.

One of the key aspects of this design is that it avoids the zone-fragmentation
problem that was present in the earlier design[3].


Quick overview of Memory Power Management and Memory Regions:
------------------------------------------------------------

Today memory subsystems are offer a wide range of capabilities for managing
memory power consumption. As a quick example, if a block of memory is not
referenced for a threshold amount of time, the memory controller can decide to
put that chunk into a low-power content-preserving state. And the next
reference to that memory chunk would bring it back to full power for read/write.
With this capability in place, it becomes important for the OS to understand
the boundaries of such power-manageable chunks of memory and to ensure that
references are consolidated to a minimum number of such memory power management
domains.

ACPI 5.0 has introduced MPST tables (Memory Power State Tables) [5] so that
the firmware can expose information regarding the boundaries of such memory
power management domains to the OS in a standard way.

How can Linux VM help memory power savings?

o Consolidate memory allocations and/or references such that they are
not spread across the entire memory address space.  Basically area of memory
that is not being referenced, can reside in low power state.

o Support targeted memory reclaim, where certain areas of memory that can be
easily freed can be offlined, allowing those areas of memory to be put into
lower power states.

Memory Regions:
---------------

"Memory Regions" is a way of capturing the boundaries of power-managable
chunks of memory, within the MM subsystem.


Short description of the "Sorted-buddy" design:
-----------------------------------------------

In this design, the memory region boundaries are captured in a parallel
data-structure instead of fitting regions between nodes and zones in the
hierarchy. Further, the buddy allocator is altered, such that we maintain the
zones' freelists in region-sorted-order and thus do page allocation in the
order of increasing memory regions. (The freelists need not be fully
address-sorted, they just need to be region-sorted. Patch 6 explains this
in more detail).

The idea is to do page allocation in increasing order of memory regions
(within a zone) and perform page reclaim in the reverse order, as illustrated
below.

---------------------------- Increasing region number---------------------->

Direction of allocation--->                         <---Direction of reclaim


The sorting logic (to maintain freelist pageblocks in region-sorted-order)
lies in the page-free path and not the page-allocation path and hence the
critical page allocation paths remain fast. Moreover, the heart of the page
allocation algorithm itself remains largely unchanged, and the region-related
data-structures are optimized to avoid unnecessary updates during the
page-allocator's runtime.

Advantages of this design:
--------------------------
1. No zone-fragmentation (IOW, we don't create more zones than necessary) and
   hence we avoid its associated problems (like too many zones, extra page
   reclaim threads, question of choosing watermarks etc).
   [This is an advantage over the "Hierarchy" design]

2. Performance overhead is expected to be low: Since we retain the simplicity
   of the algorithm in the page allocation path, page allocation can
   potentially remain as fast as it would be without memory regions. The
   overhead is pushed to the page-freeing paths which are not that critical.


Results:
=======

Test setup:
-----------
This patchset applies cleanly on top of 3.7-rc3.

x86 dual-socket quad core HT-enabled machine booted with mem=8G
Memory region size = 512 MB

Functional testing:
-------------------

Ran pagetest, a simple C program that allocates and touches a required number
of pages.

Below is the statistics from the regions within ZONE_NORMAL, at various sizes
of allocations from pagetest.

	     Present pages   |	Free pages at various allocations        |
			     |  start	|  512 MB  |  1024 MB | 2048 MB  |
  Region 0      16	     |   0      |    0     |     0    |    0     |
  Region 1      131072       |  87219   |  8066    |   7892   |  7387    |
  Region 2      131072       | 131072   |  79036   |     0    |    0     |
  Region 3      131072       | 131072   | 131072   |   79061  |    0     |
  Region 4      131072       | 131072   | 131072   |  131072  |    0     |
  Region 5      131072       | 131072   | 131072   |  131072  |  79051   |
  Region 6      131072       | 131072   | 131072   |  131072  |  131072  |
  Region 7      131072       | 131072   | 131072   |  131072  |  131072  |
  Region 8      131056       | 105475   | 105472   |  105472  |  105472  |

This shows that page allocation occurs in the order of increasing region
numbers, as intended in this design.

Performance impact:
-------------------

Kernbench results didn't show much of a difference between the performance
of vanilla 3.7-rc3 and this patchset.


Todos:
=====

1. Memory-region aware page-reclamation:
----------------------------------------

We would like to do page reclaim in the reverse order of page allocation
within a zone, ie., in the order of decreasing region numbers.
To achieve that, while scanning lru pages to reclaim, we could potentially
look for pages belonging to higher regions (considering region boundaries)
or perhaps simply prefer pages of higher pfns (and skip lower pfns) as
reclaim candidates.

2. Compile-time exclusion of Memory Power Management, and extending the
support to also work with other features such as Mem cgroups, kexec etc.

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

 Srivatsa S. Bhat (8):
      mm: Introduce memory regions data-structure to capture region boundaries within node
      mm: Initialize node memory regions during boot
      mm: Introduce and initialize zone memory regions
      mm: Add helpers to retrieve node region and zone region for a given page
      mm: Add data-structures to describe memory regions within the zones' freelists
      mm: Demarcate and maintain pageblocks in region-order in the zones' freelists
      mm: Add an optimized version of del_from_freelist to keep page allocation fast
      mm: Print memory region statistics to understand the buddy allocator behavior


  include/linux/mm.h     |   38 +++++++
 include/linux/mmzone.h |   52 +++++++++
 mm/compaction.c        |    8 +
 mm/page_alloc.c        |  263 ++++++++++++++++++++++++++++++++++++++++++++----
 mm/vmstat.c            |   59 ++++++++++-
 5 files changed, 390 insertions(+), 30 deletions(-)


Thanks,
Srivatsa S. Bhat
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
