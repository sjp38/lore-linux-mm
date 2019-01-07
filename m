Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62E138E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 18:33:44 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 74so1316199pfk.12
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 15:33:44 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e6si10479033pgp.504.2019.01.07.15.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 15:33:42 -0800 (PST)
Subject: [PATCH v7 0/3] mm: Randomize free memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Jan 2019 15:21:04 -0800
Message-ID: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>mhocko@suse.com, keith.busch@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de

Changes since v6 [1]:
* Simplify the review, drop the autodetect patches from the series. That
  work simply results in a single call to page_alloc_shuffle(SHUFFLE_ENABLE)
  injected at the right location during ACPI NUMA initialization / parsing
  of the HMAT (Heterogeneous Memory Attributes Table). That is purely a
  follow-on consideration once the base shuffle implementation and
  definition of page_alloc_shuffle() is accepted. The end result for this
  series is that the command line parameter "page_alloc.shuffle" is
  required to enable the randomization.

* Fix declaration of page_alloc_shuffle() in the
  CONFIG_SHUFFLE_PAGE_ALLOCATOR=n case. (0day)

* Rebased on v5.0-rc1

[1]: https://lkml.org/lkml/2018/12/17/1116

---

Hi Andrew, please consider this series for -mm only after Michal and Mel
have had a chance to review and have their concerns addressed.

---

Quote Patch 1:

Randomization of the page allocator improves the average utilization of
a direct-mapped memory-side-cache. Memory side caching is a platform
capability that Linux has been previously exposed to in HPC
(high-performance computing) environments on specialty platforms. In
that instance it was a smaller pool of high-bandwidth-memory relative to
higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
be found on general purpose server platforms where DRAM is a cache in
front of higher latency persistent memory [2].

Robert offered an explanation of the state of the art of Linux
interactions with memory-side-caches [3], and I copy it here:

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

[2]: https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
[3]: https://lkml.org/lkml/2018/9/22/54

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
 init/Kconfig             |   36 +++++++
 mm/Makefile              |    7 +
 mm/compaction.c          |    4 -
 mm/memblock.c            |   10 ++
 mm/memory_hotplug.c      |    3 +
 mm/page_alloc.c          |   82 ++++++++--------
 mm/shuffle.c             |  231 ++++++++++++++++++++++++++++++++++++++++++++++
 12 files changed, 471 insertions(+), 50 deletions(-)
 create mode 100644 include/linux/shuffle.h
 create mode 100644 mm/shuffle.c
