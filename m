Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0656B0253
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 23:15:52 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so50759068pdr.2
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 20:15:51 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id xg7si22329483pab.119.2015.08.16.20.15.50
        for <linux-mm@kvack.org>;
        Sun, 16 Aug 2015 20:15:51 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [Patch V3 0/9] Enable memoryless node support for x86
Date: Mon, 17 Aug 2015 11:18:57 +0800
Message-Id: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

This is the third version to enable memoryless node support on x86
platforms. The previous version (https://lkml.org/lkml/2014/7/11/75)
blindly replaces numa_node_id()/cpu_to_node() with numa_mem_id()/
cpu_to_mem(). That's not the right solution as pointed out by Tejun
and Peter due to:
1) We shouldn't shift the burden to normal slab users.
2) Details of memoryless node should be hidden in arch and mm code
   as much as possible.

After digging into more code and documentation, we found the rules to
deal with memoryless node should be:
1) Arch code should online corresponding NUMA node before onlining any
   CPU or memory, otherwise it may cause invalid memory access when
   accessing NODE_DATA(nid).
2) For normal memory allocations without __GFP_THISNODE setting in the
   gfp_flags, we should prefer numa_node_id()/cpu_to_node() instead of
   numa_mem_id()/cpu_to_mem() because the latter loses hardware topology
   information as pointed out by Tejun:
	   A - B - X - C - D
	Where X is the memless node.  numa_mem_id() on X would return
	either B or C, right?  If B or C can't satisfy the allocation,
	the allocator would fallback to A from B and D for C, both of
	which aren't optimal. It should first fall back to C or B
	respectively, which the allocator can't do anymoe because the
	information is lost when the caller side performs numa_mem_id().
3) For memory allocation with __GFP_THISNODE setting in gfp_flags,
   numa_node_id()/cpu_to_node() should be used if caller only wants to
   allocate from local memory, otherwise numa_mem_id()/cpu_to_mem()
   should be used if caller wants to allocate from the nearest node
   with memory.
4) numa_mem_id()/cpu_to_mem() should be used if caller wants to check
   whether a page is allocated from the nearest node.

Based on above rules, this patch set
1) Patch 1 is a bugfix to resolve a crash caused by socket hot-addition
2) Patch 2 replaces numa_mem_id() with numa_node_id() when __GFP_THISNODE
   isn't set in gfp_flags.
3) Patch 3-6 replaces numa_node_id()/cpu_to_node() with numa_mem_id()/
   cpu_to_mem() if caller wants to allocate from local node only.
4) Patch 7-9 enables support of memoryless node on x86.

With this patch set applied, on a system with two sockets enabled at boot,
one with memory and the other without memory, we got following numa
topology after boot:
root@bkd04sdp:~# numactl --hardware
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44
node 0 size: 15940 MB
node 0 free: 15397 MB
node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59
node 1 size: 0 MB
node 1 free: 0 MB
node distances:
node   0   1
  0:  10  21
  1:  21  10

After hot-adding the third socket without memory, we got:
root@bkd04sdp:~# numactl --hardware
available: 3 nodes (0-2)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44
node 0 size: 15940 MB
node 0 free: 15142 MB
node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59
node 1 size: 0 MB
node 1 free: 0 MB
node 2 cpus:
node 2 size: 0 MB
node 2 free: 0 MB
node distances:
node   0   1   2
  0:  10  21  21
  1:  21  10  21
  2:  21  21  10

Jiang Liu (9):
  x86, NUMA, ACPI: Online node earlier when doing CPU hot-addition
  kernel/profile.c: Replace cpu_to_mem() with cpu_to_node()
  sgi-xp: Replace cpu_to_node() with cpu_to_mem() to support memoryless
    node
  openvswitch: Replace cpu_to_node() with cpu_to_mem() to support
    memoryless node
  i40e: Use numa_mem_id() to better support memoryless node
  i40evf: Use numa_mem_id() to better support memoryless node
  x86, numa: Kill useless code to improve code readability
  mm: Update _mem_id_[] for every possible CPU when memory
    configuration changes
  mm, x86: Enable memoryless node support to better support CPU/memory
    hotplug

 arch/x86/Kconfig                              |    3 ++
 arch/x86/kernel/acpi/boot.c                   |    9 +++-
 arch/x86/kernel/smpboot.c                     |    2 +
 arch/x86/mm/numa.c                            |   59 +++++++++++++++----------
 drivers/misc/sgi-xp/xpc_uv.c                  |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |    2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |    2 +-
 kernel/profile.c                              |    2 +-
 mm/page_alloc.c                               |   10 ++---
 net/openvswitch/flow.c                        |    2 +-
 10 files changed, 59 insertions(+), 34 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
