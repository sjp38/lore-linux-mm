Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D26C8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 18:10:16 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t2so5855098pfj.15
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:10:16 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j5si3784806pgq.82.2019.01.16.15.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 15:10:14 -0800 (PST)
Subject: [PATCH v8 0/3] mm: Randomize free memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 16 Jan 2019 14:57:36 -0800
Message-ID: <154767945660.1983228.12167020940431682725.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, keith.busch@intel.com

Changes since v7 [1]:
* Make the functionality available to non-ACPI_NUMA builds (Kees)
* Mark the shuffle_state configuration variable __ro_after_init, since
  it is not meant to be changed after boot. (Kees)
* Collect Reviewed-by tag from Kees on patch1 and patch3

[1]: https://lwn.net/Articles/776228/

---

Hi Andrew,

It has been a week since I attempted to nudge Mel from his
not-NAK-but-not-ACK position [2]. One of the concerns raised was
buddy-merging undoing the randomization over time. That situation is
avoided by the fact that the randomization is still valuable even at the
MAX_ORDER buddy-page size, and that is the default randomization
granularity. CMA might also undo some of the randomization, but there's
not much else to be done about that besides note the incompatibility. It
is not clear how widely CMA is used on servers.

Outside of the server performance use case Kees continues to "remain a
fan" of the set for its potential security implications. Recall that the
functionality is default-disabled and self contained. The risk of
merging this remains confined to workloads that were somehow dependent
on in-order page allocation as Mel discovered [3], *and* do not benefit
from increased average memory-side-cache utilization. Everyone else will
not be at risk for regression because this functionality will be
disabled without an explicit command line, or ACPI HMAT tables
indicating the presence of a direct-mapped memory-side-cache.

My read is that "not-NAK" is the best I can hope for from other core-mm
folks at this point. Please consider this for the -mm tree and the v5.1
merge window.

[2]: https://lore.kernel.org/lkml/CAPcyv4gkSBW5Te0RZLrkxzufyVq56-7pHu__YfffBiWhoqg7Yw@mail.gmail.com/
[3]: https://lkml.org/lkml/2018/10/12/309

---

Quote Patch 1:

Randomization of the page allocator improves the average utilization of
a direct-mapped memory-side-cache. Memory side caching is a platform
capability that Linux has been previously exposed to in HPC
(high-performance computing) environments on specialty platforms. In
that instance it was a smaller pool of high-bandwidth-memory relative to
higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
be found on general purpose server platforms where DRAM is a cache in
front of higher latency persistent memory [4].

Robert offered an explanation of the state of the art of Linux
interactions with memory-side-caches [5], and I copy it here:

    It's been a problem in the HPC space:
    http://www.nersc.gov/research-and-development/knl-cache-mode-performance-coe/

    A kernel module called zonesort is available to try to help:
    https://software.intel.com/en-us/articles/xeon-phi-software

    and this abandoned patch series proposed that for the kernel:
    https://lkml.org/lkml/2017/8/23/195

    Dan's patch series doesn't attempt to ensure buffers won't conflict, but
    also reduces the chance that the buffers will. This will make performance
    more consistent, albeit slower than "optimal" (which is near impossible
    to attain in a general-purpose kernel).  That's better than forcing
    users to deploy remedies like:
        "To eliminate this gradual degradation, we have added a Stream
         measurement to the Node Health Check that follows each job;
         nodes are rebooted whenever their measured memory bandwidth
         falls below 300 GB/s."

A replacement for zonesort was merged upstream in commit cc9aec03e58f
"x86/numa_emulation: Introduce uniform split capability". With this
numa_emulation capability, memory can be split into cache sized
("near-memory" sized) numa nodes. A bind operation to such a node, and
disabling workloads on other nodes, enables full cache performance.
However, once the workload exceeds the cache size then cache conflicts
are unavoidable. While HPC environments might be able to tolerate
time-scheduling of cache sized workloads, for general purpose server
platforms, the oversubscribed cache case will be the common case.

The worst case scenario is that a server system owner benchmarks a
workload at boot with an un-contended cache only to see that performance
degrade over time, even below the average cache performance due to
excessive conflicts. Randomization clips the peaks and fills in the
valleys of cache utilization to yield steady average performance.

See patch 1 for more details.

[4]: https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
[5]: https://lkml.org/lkml/2018/9/22/54

---

Dan Williams (3):
      mm: Shuffle initial free memory to improve memory-side-cache utilization
      mm: Move buddy list manipulations into helpers
      mm: Maintain randomization of page free lists


 include/linux/list.h     |   17 +++
 include/linux/mm.h       |    3 -
 include/linux/mm_types.h |    3 +
 include/linux/mmzone.h   |   65 +++++++++++++
 include/linux/shuffle.h  |   60 ++++++++++++
 init/Kconfig             |   35 +++++++
 mm/Makefile              |    7 +
 mm/compaction.c          |    4 -
 mm/memblock.c            |   10 ++
 mm/memory_hotplug.c      |    3 +
 mm/page_alloc.c          |   82 ++++++++--------
 mm/shuffle.c             |  231 ++++++++++++++++++++++++++++++++++++++++++++++
 12 files changed, 470 insertions(+), 50 deletions(-)
 create mode 100644 include/linux/shuffle.h
 create mode 100644 mm/shuffle.c
