Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E53CF6B0007
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 18:49:33 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id s6so6442583plp.5
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 15:49:33 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n9si5519204pgr.552.2018.02.13.15.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 15:49:32 -0800 (PST)
From: Reinette Chatre <reinette.chatre@intel.com>
Subject: [RFC PATCH V2 00/22]  Intel(R) Resource Director Technology Cache Pseudo-Locking enabling
Date: Tue, 13 Feb 2018 07:46:44 -0800
Message-Id: <cover.1518443616.git.reinette.chatre@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, fenghua.yu@intel.com, tony.luck@intel.com
Cc: gavin.hindman@intel.com, vikas.shivappa@linux.intel.com, dave.hansen@intel.com, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, Reinette Chatre <reinette.chatre@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

Adding MM maintainers to v2 to share the new MM change (patch 21/22) that
enables large contiguous regions that was created to support large Cache
Pseudo-Locked regions (patch 22/22). This week MM team received another
proposal to support large contiguous allocations ("[RFC PATCH 0/3]
Interface for higher order contiguous allocations" at
http://lkml.kernel.org/r/20180212222056.9735-1-mike.kravetz@oracle.com).
I have not yet tested with this new proposal but it does seem appropriate
and I should be able to rework patch 22 from this series on top of that if
it is accepted instead of what I have in patch 21 of this series.

Changes since v1:
- Enable allocation of contiguous regions larger than what SLAB allocators
  can support. This removes the 4MB Cache Pseudo-Locking limitation
  documented in v1 submission.
  This depends on "mm: drop hotplug lock from lru_add_drain_all",
  now in v4.16-rc1 as 9852a7212324fd25f896932f4f4607ce47b0a22f.
- Convert to debugfs_file_get() and -put() from the now obsolete
  debugfs_use_file_start() and debugfs_use_file_finish() calls.
- Rebase on top of, and take into account, recent L2 CDP enabling.
- Simplify tracing output to print cache hits and miss counts on same line.

This version is based on x86/cache of tip.git when the HEAD was
(based on v4.15-rc8):

commit 31516de306c0c9235156cdc7acb976ea21f1f646
Author: Fenghua Yu <fenghua.yu@intel.com>
Date:   Wed Dec 20 14:57:24 2017 -0800

    x86/intel_rdt: Add command line parameter to control L2_CDP

Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>

No changes below. It is verbatim from first submission (except for
diffstat at the end that reflects v2).

Dear Maintainers,

Cache Allocation Technology (CAT), part of Intel(R) Resource Director
Technology (Intel(R) RDT), enables a user to specify the amount of cache
space into which an application can fill. Cache pseudo-locking builds on
the fact that a CPU can still read and write data pre-allocated outside
its current allocated area on cache hit. With cache pseudo-locking data
can be preloaded into a reserved portion of cache that no application can
fill, and from that point on will only serve cache hits. The cache
pseudo-locked memory is made accessible to user space where an application
can map it into its virtual address space and thus have a region of
memory with reduced average read latency.

The cache pseudo-locking approach relies on generation-specific behavior
of processors. It may provide benefits on certain processor generations,
but is not guaranteed to be supported in the future. It is not a guarantee
that data will remain in the cache. It is not a guarantee that data will
remain in certain levels or certain regions of the cache. Rather, cache
pseudo-locking increases the probability that data will remain in a certain
level of the cache via carefully configuring the CAT feature and carefully
controlling application behavior.

Known limitations:
Instructions like INVD, WBINVD, CLFLUSH, etc. can still evict pseudo-locked
memory from the cache. Power management C-states may still shrink or power
off cache causing eviction of cache pseudo-locked memory. We utilize
PM QoS to prevent entering deeper C-states on cores associated with cache
pseudo-locked regions at the time they (the pseudo-locked regions) are
created.

Known software limitation:
Cache pseudo-locked regions are currently limited to 4MB, even on
platforms that support larger cache sizes. Work is in progress to
support larger regions.

Graphs visualizing the benefits of cache pseudo-locking on an Intel(R)
NUC NUC6CAYS (it has an Intel(R) Celeron(R) Processor J3455) with the
default 2GB DDR3L-1600 memory are available. In these tests the patches
from this series were applied on the x86/cache branch of tip.git at the
time the HEAD was:

commit 87943db7dfb0c5ee5aa74a9ac06346fadd9695c8 (tip/x86/cache)
Author: Reinette Chatre <reinette.chatre@intel.com>
Date:   Fri Oct 20 02:16:59 2017 -0700
    x86/intel_rdt: Fix potential deadlock during resctrl mount

DISCLAIMER: Tests document performance of components on a particular test,
in specific systems. Differences in hardware, software, or configuration
will affect actual performance. Performance varies depending on system
configuration.

- https://github.com/rchatre/data/blob/master/cache_pseudo_locking/rfc_v1/perfcount.png
Above shows the few L2 cache misses possible with cache pseudo-locking
on the Intel(R) NUC with default configuration. Each test, which is
repeated 100 times, pseudo-locks schemata shown and then measure from
the kernel via precision counters the number of cache misses when
accessing the memory afterwards. This test is run on an idle system as
well as a system with significant noise (using stress-ng) from a
neighboring core associated with the same cache. This plot shows us that:
(1) the number of cache misses remain consistent irrespective of the size
of region being pseudo-locked, and (2) the number of cache misses for a
pseudo-locked region remains low when traversing memory regions ranging
in size from 256KB (4096 cache lines) to 896KB (14336 cache lines).

- https://github.com/rchatre/data/blob/master/cache_pseudo_locking/rfc_v1/userspace_malloc_with_load.png
Above shows the read latency experienced by an application running with
default CAT CLOS after it allocated 256KB memory with malloc() (and using
mlockall()). In this example the application reads randomly (to not trigger
hardware prefetcher) from its entire allocated region at 2 second intervals
while there is a noisy neighbor present. Each individual access is 32 bytes
in size and the latency of each access is measured using the rdtsc
instruction. In this visualization we can observe two groupings of data,
the group with lower latency indicating cache hits, and the group with
higher latency indicating cache misses. We can see a significant portion
of memory reads experience larger latencies.

- https://github.com/rchatre/data/blob/master/cache_pseudo_locking/rfc_v1/userspace_psl_with_load.png
Above plots a similar test as the previous, but instead of the application
reading from a 256KB malloc() region it reads from a 256KB pseudo-locked
region that was mmap()'ed into its address space. When comparing these
latencies to that of regular malloc() latencies we do see a significant
improvement in latencies experienced.

https://github.com/rchatre/data/blob/master/cache_pseudo_locking/rfc_v1/userspace_malloc_and_cat_with_load_clos0_fixed.png
Applications that are sensitive to latencies may use existing CAT
technology to isolate the sensitive application. In this plot we show an
application running with a dedicated CAT CLOS double the size (512KB) of
the memory being tested (256KB). A dedicated CLOS with CBM 0x0f is created and
the default CLOS changed to CBM 0xf0. We see in this plot that even though
the application runs within a dedicated portion of cache it still
experiences significant latency accessing its memory (when compared to
pseudo-locking).

Your feedback about this proposal for enabling of Cache Pseudo-Locking
will be greatly appreciated.

Regards,

Reinette

Reinette Chatre (22):
  x86/intel_rdt: Documentation for Cache Pseudo-Locking
  x86/intel_rdt: Make useful functions available internally
  x86/intel_rdt: Introduce hooks to create pseudo-locking files
  x86/intel_rdt: Introduce test to determine if closid is in use
  x86/intel_rdt: Print more accurate pseudo-locking availability
  x86/intel_rdt: Create pseudo-locked regions
  x86/intel_rdt: Connect pseudo-locking directory to operations
  x86/intel_rdt: Introduce pseudo-locking resctrl files
  x86/intel_rdt: Discover supported platforms via prefetch disable bits
  x86/intel_rdt: Disable pseudo-locking if CDP enabled
  x86/intel_rdt: Associate pseudo-locked regions with its domain
  x86/intel_rdt: Support CBM checking from value and character buffer
  x86/intel_rdt: Support schemata write - pseudo-locking core
  x86/intel_rdt: Enable testing for pseudo-locked region
  x86/intel_rdt: Prevent new allocations from pseudo-locked regions
  x86/intel_rdt: Create debugfs files for pseudo-locking testing
  x86/intel_rdt: Create character device exposing pseudo-locked region
  x86/intel_rdt: More precise L2 hit/miss measurements
  x86/intel_rdt: Support L3 cache performance event of Broadwell
  x86/intel_rdt: Limit C-states dynamically when pseudo-locking active
  mm/hugetlb: Enable large allocations through gigantic page API
  x86/intel_rdt: Support contiguous memory of all sizes

 Documentation/x86/intel_rdt_ui.txt                |  229 ++-
 arch/x86/Kconfig                                  |   11 +
 arch/x86/kernel/cpu/Makefile                      |    4 +-
 arch/x86/kernel/cpu/intel_rdt.h                   |   24 +
 arch/x86/kernel/cpu/intel_rdt_ctrlmondata.c       |   44 +-
 arch/x86/kernel/cpu/intel_rdt_pseudo_lock.c       | 1894 +++++++++++++++++++++
 arch/x86/kernel/cpu/intel_rdt_pseudo_lock_event.h |   52 +
 arch/x86/kernel/cpu/intel_rdt_rdtgroup.c          |   46 +-
 include/linux/hugetlb.h                           |    2 +
 mm/hugetlb.c                                      |   10 +-
 10 files changed, 2290 insertions(+), 26 deletions(-)
 create mode 100644 arch/x86/kernel/cpu/intel_rdt_pseudo_lock.c
 create mode 100644 arch/x86/kernel/cpu/intel_rdt_pseudo_lock_event.h

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
