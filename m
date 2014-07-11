Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1CEF46B0031
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:35:15 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so1003530pab.1
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:35:14 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id nu1si1519312pbb.216.2014.07.11.00.35.13
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:35:13 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Date: Fri, 11 Jul 2014 15:37:17 +0800
Message-Id: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

Previously we have posted a patch fix a memory crash issue caused by
memoryless node on x86 platforms, please refer to
http://comments.gmane.org/gmane.linux.kernel/1687425

As suggested by David Rientjes, the most suitable fix for the issue
should be to use cpu_to_mem() rather than cpu_to_node() in the caller.
So this is the patchset according to David's suggestion.

Patch 1-26 prepare for enabling memoryless node on x86 platforms by
replacing cpu_to_node()/numa_node_id() with cpu_to_mem()/numa_mem_id().
Patch 27-29 enable support of memoryless node on x86 platforms.
Patch 30 tunes order to online NUMA node when doing CPU hot-addition.

This patchset fixes the issue mentioned by Mike Galbraith that CPUs
are associated with wrong node after adding memory to a memoryless
node.

With support of memoryless node enabled, it will correctly report system
hardware topology for nodes without memory installed.
root@bkd01sdp:~# numactl --hardware
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
node 0 size: 15725 MB
node 0 free: 15129 MB
node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89
node 1 size: 15862 MB
node 1 free: 15627 MB
node 2 cpus: 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104
node 2 size: 0 MB
node 2 free: 0 MB
node 3 cpus: 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
node 3 size: 0 MB
node 3 free: 0 MB
node distances:
node   0   1   2   3
  0:  10  21  21  21
  1:  21  10  21  21
  2:  21  21  10  21
  3:  21  21  21  10

With memoryless node enabled, CPUs are correctly associated with node 2
after memory hot-addition to node 2.
root@bkd01sdp:/sys/devices/system/node/node2# numactl --hardware
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
node 0 size: 15725 MB
node 0 free: 14872 MB
node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89
node 1 size: 15862 MB
node 1 free: 15641 MB
node 2 cpus: 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104
node 2 size: 128 MB
node 2 free: 127 MB
node 3 cpus: 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
node 3 size: 0 MB
node 3 free: 0 MB
node distances:
node   0   1   2   3
  0:  10  21  21  21
  1:  21  10  21  21
  2:  21  21  10  21
  3:  21  21  21  10

The patchset is based on the latest mainstream kernel and has been
tested on a 4-socket Intel platform with CPU/memory hot-addition
capability.

Any comments are welcomed!

Jiang Liu (30):
  mm, kernel: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, sched: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, net: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, netfilter: Use cpu_to_mem()/numa_mem_id() to support memoryless
    node
  mm, perf: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, tracing: Use cpu_to_mem()/numa_mem_id() to support memoryless
    node
  mm: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, thp: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, memcg: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, xfrm: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, char/mspec.c: Use cpu_to_mem()/numa_mem_id() to support
    memoryless node
  mm, IB/qib: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, i40e: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, i40evf: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, igb: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, ixgbe: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, intel_powerclamp: Use cpu_to_mem()/numa_mem_id() to support
    memoryless node
  mm, bnx2fc: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, bnx2i: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, fcoe: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, irqchip: Use cpu_to_mem()/numa_mem_id() to support memoryless
    node
  mm, of: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, x86: Use cpu_to_mem()/numa_mem_id() to support memoryless node
  mm, x86/platform/uv: Use cpu_to_mem()/numa_mem_id() to support
    memoryless node
  mm, x86, kvm: Use cpu_to_mem()/numa_mem_id() to support memoryless
    node
  mm, x86, perf: Use cpu_to_mem()/numa_mem_id() to support memoryless
    node
  x86, numa: Kill useless code to improve code readability
  mm: Update _mem_id_[] for every possible CPU when memory
    configuration changes
  mm, x86: Enable memoryless node support to better support CPU/memory
    hotplug
  x86, NUMA: Online node earlier when doing CPU hot-addition

 arch/x86/Kconfig                              |    3 ++
 arch/x86/kernel/acpi/boot.c                   |    6 ++-
 arch/x86/kernel/apic/io_apic.c                |   10 ++---
 arch/x86/kernel/cpu/perf_event_amd.c          |    2 +-
 arch/x86/kernel/cpu/perf_event_amd_uncore.c   |    2 +-
 arch/x86/kernel/cpu/perf_event_intel.c        |    2 +-
 arch/x86/kernel/cpu/perf_event_intel_ds.c     |    6 +--
 arch/x86/kernel/cpu/perf_event_intel_rapl.c   |    2 +-
 arch/x86/kernel/cpu/perf_event_intel_uncore.c |    2 +-
 arch/x86/kernel/devicetree.c                  |    2 +-
 arch/x86/kernel/irq_32.c                      |    4 +-
 arch/x86/kernel/smpboot.c                     |    2 +
 arch/x86/kvm/vmx.c                            |    2 +-
 arch/x86/mm/numa.c                            |   52 +++++++++++++++++--------
 arch/x86/platform/uv/tlb_uv.c                 |    2 +-
 arch/x86/platform/uv/uv_nmi.c                 |    3 +-
 arch/x86/platform/uv/uv_time.c                |    2 +-
 drivers/char/mspec.c                          |    2 +-
 drivers/infiniband/hw/qib/qib_file_ops.c      |    4 +-
 drivers/infiniband/hw/qib/qib_init.c          |    2 +-
 drivers/irqchip/irq-clps711x.c                |    2 +-
 drivers/irqchip/irq-gic.c                     |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |    2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c     |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 +-
 drivers/of/base.c                             |    2 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c             |    2 +-
 drivers/scsi/bnx2i/bnx2i_init.c               |    2 +-
 drivers/scsi/fcoe/fcoe.c                      |    2 +-
 drivers/thermal/intel_powerclamp.c            |    4 +-
 include/linux/gfp.h                           |    6 +--
 kernel/events/callchain.c                     |    2 +-
 kernel/events/core.c                          |    2 +-
 kernel/events/ring_buffer.c                   |    2 +-
 kernel/rcu/rcutorture.c                       |    2 +-
 kernel/sched/core.c                           |    8 ++--
 kernel/sched/deadline.c                       |    2 +-
 kernel/sched/fair.c                           |    4 +-
 kernel/sched/rt.c                             |    6 +--
 kernel/smp.c                                  |    2 +-
 kernel/smpboot.c                              |    2 +-
 kernel/taskstats.c                            |    2 +-
 kernel/timer.c                                |    2 +-
 kernel/trace/ring_buffer.c                    |   12 +++---
 kernel/trace/trace_uprobe.c                   |    2 +-
 mm/huge_memory.c                              |    6 +--
 mm/memcontrol.c                               |    2 +-
 mm/memory.c                                   |    2 +-
 mm/page_alloc.c                               |   10 ++---
 mm/percpu-vm.c                                |    2 +-
 mm/vmalloc.c                                  |    2 +-
 net/core/dev.c                                |    6 +--
 net/core/flow.c                               |    2 +-
 net/core/pktgen.c                             |   10 ++---
 net/core/sysctl_net_core.c                    |    2 +-
 net/netfilter/x_tables.c                      |    8 ++--
 net/xfrm/xfrm_ipcomp.c                        |    2 +-
 58 files changed, 139 insertions(+), 111 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
