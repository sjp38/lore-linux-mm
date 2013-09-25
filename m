Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC5B6B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:17:59 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so466146pab.24
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:17:59 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:47:49 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 07FC23940058
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:47:29 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNK0T538207540
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:50:01 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNHgND028576
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:47:43 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 00/40] mm: Memory Power Management
Date: Thu, 26 Sep 2013 04:43:36 +0530
Message-ID: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Here is version 4 of the Memory Power Management patchset, which includes the
targeted compaction mechanism (which was temporarily removed in v3). So now
that this includes all the major features & changes to the Linux MM intended
to aid memory power management, it gives us a better picture of the extent to
which this patchset performs better than mainline, in causing memory power
savings.


Role of the Linux MM in influencing Memory Power Management:
-----------------------------------------------------------

Modern memory hardware such as DDR3 support a number of power management
capabilities - for instance, the memory controller can automatically put
memory DIMMs/banks into content-preserving low-power states, if it detects
that the *entire* memory DIMM/bank has not been referenced for a threshold
amount of time. This in turn reduces the energy consumption of the memory
hardware. We term these power-manageable chunks of memory as "Memory Regions".

To increase the power savings we need to enhance the Linux MM to understand
the granularity at which RAM modules can be power-managed, and keep the
memory allocations and references consolidated to a minimum no. of these
memory regions.

Thus, we can summarize the goals for the Linux MM as follows:

o Consolidate memory allocations and/or references such that they are not
spread across the entire memory address space, because the area of memory
that is not being referenced can reside in low power state.

o Support light-weight targeted memory compaction/reclaim, to evacuate
lightly-filled memory regions. This helps avoid memory references to
those regions, thereby allowing them to reside in low power states.


Brief overview of the design/approach used in this patchset:
-----------------------------------------------------------

The strategy used in this patchset is to do page allocation in increasing order
of memory regions (within a zone) and perform region-compaction in the reverse
order, as illustrated below.

---------------------------- Increasing region number---------------------->

Direction of allocation--->               <---Direction of region-compaction


We achieve this by making 3 major design changes to the Linux kernel memory
manager, as outlined below.

1. Sorted-buddy design of buddy freelists

   To allocate pages in increasing order of memory regions, we first capture
   the memory region boundaries in suitable zone-level data-structures, and
   modify the buddy allocator so as to maintain the buddy freelists in
   region-sorted-order. This automatically ensures that page allocation occurs
   in the order of increasing memory regions.

2. Split-allocator design: Page-Allocator as front-end; Region-Allocator as
   back-end

   Mixing of movable and unmovable pages can disrupt opportunities for
   consolidating allocations. In order to separate such pages at a memory-region
   granularity, a "Region-Allocator" is introduced which allocates entire memory
   regions. The Page-Allocator is then modified to get its memory from the
   Region-Allocator and hand out pages to requesting applications in
   page-sized chunks. This design is showing significant improvements in the
   effectiveness of this patchset in consolidating allocations to a minimum no.
   of memory regions.

3. Targeted region compaction/evacuation

   Over time, due to multiple alloc()s and free()s in random order, memory gets
   fragmented, which means the memory allocations will no longer be consolidated
   to a minimum no. of memory regions. In such cases we need a light-weight
   mechanism to opportunistically compact memory to evacuate lightly-filled
   memory regions, thereby enhancing the power-savings.

   Noting that CMA (Contiguous Memory Allocator) does targeted compaction to
   achieve its goals, this patchset generalizes the targeted compaction code
   and reuses it to evacuate memory regions. A dedicated per-node "kmempowerd"
   kthread is employed to perform this region evacuation.


Assumptions and goals of this patchset:
--------------------------------------

In this patchset, we don't handle the part of getting the region boundary info
from the firmware/bootloader and populating it in the kernel data-structures.
The aim of this patchset is to propose and brainstorm on a power-aware design
of the Linux MM which can *use* the region boundary info to influence the MM
at various places such as page allocation, reclamation/compaction etc, thereby
contributing to memory power savings. So, in this patchset, we assume a simple
model in which each 512MB chunk of memory can be independently power-managed,
and hard-code this in the kernel.

However, its not very far-fetched to try this out with actual region boundary
info to get the real power savings numbers. For example, on ARM platforms, we
can make the bootloader export this info to the OS via device-tree and then run
this patchset. (This was the method used to get the power-numbers in [4]). But
even without doing that, we can very well evaluate the effectiveness of this
patchset in contributing to power-savings, by analyzing the free page statistics
per-memory-region; and we can observe the performance impact by running
benchmarks - this is the approach currently used to evaluate this patchset.


Experimental Results:
====================

In a nutshell here are the results (higher the better):

                  Free regions at test-start   Free regions after test-run
Without patchset               214                          8
With patchset                  210                        202

This shows that this patchset performs enormously better than mainline, in
terms of keeping allocations consolidated to a minimum no. of regions.

I'll include the detailed results as a reply to this cover-letter, since it
can benefit from a dedicated discussion.

This patchset has been hosted in the below git tree. It applies cleanly on
v3.12-rc2.

git://github.com/srivatsabhat/linux.git mem-power-mgmt-v4


Changes in v4:
=============

* Revived and redesigned the targeted region compaction code. Added a dedicated
  per-node kthread to perform the evacuation, instead of the workqueue worker
  used in the previous design.
* Redesigned the locking scheme in the targeted evacuation code to be much
  more simple and elegant.
* Fixed a bug pointed out by Yasuaki Ishimatsu.
* Got much better results (consolidation ratio) than v3, due to the addition of
  the targeted compaction logic. [ v3 used to get us to around 120, whereas
  this v4 is going up to 202! :-) ].


Some important TODOs:
====================

1. Add optimizations to improve the performance and reduce the overhead in
   the MM hot paths.

2. Add support for making this patchset work with sparsemem, THP, memcg etc.


References:
----------

[1]. LWN article that explains the goals and the design of my Memory Power
     Management patchset:
     http://lwn.net/Articles/547439/

[2]. v3 of the Memory Power Management patchset, with a new split-allocator
     design:
     http://lwn.net/Articles/565371/

[3]. v2 of the "Sorted-buddy" patchset with support for targeted memory
     region compaction:
     http://lwn.net/Articles/546696/

     LWN article describing this design: http://lwn.net/Articles/547439/

     v1 of the patchset:
     http://thread.gmane.org/gmane.linux.power-management.general/28498

[4]. Estimate of potential power savings on Samsung exynos board
     http://article.gmane.org/gmane.linux.kernel.mm/65935

[5]. C. Lefurgy, K. Rajamani, F. Rawson, W. Felter, M. Kistler, and Tom Keller.
     Energy management for commercial servers. In IEEE Computer, pages 39a??48,
     Dec 2003.
     Link: researcher.ibm.com/files/us-lefurgy/computer2003.pdf

[6]. ACPI 5.0 and MPST support
     http://www.acpi.info/spec.htm
     Section 5.2.21 Memory Power State Table (MPST)

[7]. Prototype implementation of parsing of ACPI 5.0 MPST tables, by Srinivas
     Pandruvada.
     https://lkml.org/lkml/2013/4/18/349


 Srivatsa S. Bhat (40):
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
      mm: Restructure the compaction part of CMA for wider use
      mm: Add infrastructure to evacuate memory regions using compaction
      kthread: Split out kthread-worker bits to avoid circular header-file dependency
      mm: Add a kthread to perform targeted compaction for memory power management
      mm: Add a mechanism to queue work to the kmempowerd kthread
      mm: Add intelligence in kmempowerd to ignore regions unsuitable for evacuation
      mm: Add triggers in the page-allocator to kick off region evacuation

 arch/x86/include/asm/bitops.h      |    4 
 include/asm-generic/bitops/__fls.h |    5 
 include/linux/compaction.h         |    7 
 include/linux/gfp.h                |    2 
 include/linux/kthread-work.h       |   92 +++
 include/linux/kthread.h            |   85 ---
 include/linux/migrate.h            |    3 
 include/linux/mm.h                 |   43 ++
 include/linux/mmzone.h             |   87 +++
 include/trace/events/migrate.h     |    3 
 mm/compaction.c                    |  309 +++++++++++
 mm/internal.h                      |   45 ++
 mm/page_alloc.c                    | 1018 ++++++++++++++++++++++++++++++++----
 mm/vmstat.c                        |  130 ++++-
 14 files changed, 1637 insertions(+), 196 deletions(-)
 create mode 100644 include/linux/kthread-work.h


Regards,
Srivatsa S. Bhat
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
