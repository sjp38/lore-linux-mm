Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC7D8E021D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 21:01:08 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id s14so5838688pfk.16
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:01:08 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 97si5313542plb.3.2018.12.14.18.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 18:01:06 -0800 (PST)
Subject: [PATCH v5 0/5] mm: Randomize free memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Dec 2018 17:48:30 -0800
Message-ID: <154483851047.1672629.15001135860756738866.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Keith Busch <keith.busch@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>, x86@kernel.org, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.orgx86@kernel.org, linux-kernel@vger.kernel.org

Changes since v4: [1]
* Default the randomization to off and enable it dynamically based on
  the detection of a memory side cache advertised by platform firmware.
  In the case of x86 this enumeration comes from the ACPI HMAT. (Michal
  and Mel)
* Improve the changelog of the patch that introduces the shuffling to
  clarify the motivation and better explain the tradeoffs. (Michal and
  Mel)
* Include the required HMAT enabling in the series.

[1]: https://lkml.kernel.org/r/153922180166.838512.8260339805733812034.stgit@dwillia2-desk3.amr.corp.intel.com

---

Quote patch 3:

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

See patch 3 for more details.

[2]: https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
[3]: https://lkml.org/lkml/2018/9/22/54

---                                                                                        
                                                                                           
Dan Williams (3):
      mm: Shuffle initial free memory to improve memory-side-cache utilization
      mm: Move buddy list manipulations into helpers
      mm: Maintain randomization of page free lists

Keith Busch (2):
      acpi: Create subtable parsing infrastructure
      acpi/numa: Set the memory-side-cache size in memblocks


 arch/ia64/kernel/acpi.c                       |   12 +
 arch/x86/Kconfig                              |    1 
 arch/x86/kernel/acpi/boot.c                   |   36 ++--
 drivers/acpi/numa.c                           |   48 +++++
 drivers/acpi/scan.c                           |    4 
 drivers/acpi/tables.c                         |   67 ++++++--
 drivers/irqchip/irq-gic-v2m.c                 |    2 
 drivers/irqchip/irq-gic-v3-its-pci-msi.c      |    2 
 drivers/irqchip/irq-gic-v3-its-platform-msi.c |    2 
 drivers/irqchip/irq-gic-v3-its.c              |    6 -
 drivers/irqchip/irq-gic-v3.c                  |    8 -
 drivers/irqchip/irq-gic.c                     |    4 
 drivers/mailbox/pcc.c                         |    2 
 include/linux/acpi.h                          |    5 -
 include/linux/list.h                          |   17 ++
 include/linux/memblock.h                      |   36 ++++
 include/linux/mm.h                            |   53 ++++++
 include/linux/mm_types.h                      |    3 
 include/linux/mmzone.h                        |   65 +++++++
 init/Kconfig                                  |   36 ++++
 mm/Kconfig                                    |    3 
 mm/Makefile                                   |    7 +
 mm/compaction.c                               |    4 
 mm/memblock.c                                 |   37 ++++
 mm/memory_hotplug.c                           |    2 
 mm/page_alloc.c                               |   81 ++++-----
 mm/shuffle.c                                  |  222 +++++++++++++++++++++++++
 27 files changed, 657 insertions(+), 108 deletions(-)
 create mode 100644 mm/shuffle.c

--
Signature
