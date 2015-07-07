Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CCEE46B0253
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 05:30:05 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so36800603pac.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 02:30:05 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id nt5si33614692pbc.196.2015.07.07.02.30.03
        for <linux-mm@kvack.org>;
        Tue, 07 Jul 2015 02:30:04 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 0/5] Make cpuid <-> nodeid mapping persistent.
Date: Tue, 7 Jul 2015 17:30:20 +0800
Message-ID: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, laijs@cn.fujitsu.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com
Cc: tangchen@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

[Problem]

cpuid <-> nodeid mapping is firstly established at boot time. And workqueue caches
the mapping in wq_numa_possible_cpumask in wq_numa_init() at boot time.

When doing node online/offline, cpuid <-> nodeid mapping is established/destroyed,
which means, cpuid <-> nodeid mapping will change if node hotplug happens. But
workqueue does not update wq_numa_possible_cpumask.

So here is the problem:

Assume we have the following cpuid <-> nodeid in the beginning:

  Node | CPU
------------------------
node 0 |  0-14, 60-74
node 1 | 15-29, 75-89
node 2 | 30-44, 90-104
node 3 | 45-59, 105-119

and we hot-remove node2 and node3, it becomes:

  Node | CPU
------------------------
node 0 |  0-14, 60-74
node 1 | 15-29, 75-89

and we hot-add node4 and node5, it becomes:

  Node | CPU
------------------------
node 0 |  0-14, 60-74
node 1 | 15-29, 75-89
node 4 | 30-59
node 5 | 90-119

But in wq_numa_possible_cpumask, cpu30 is still mapped to node2, and the like.

When a pool workqueue is initialized, if its cpumask belongs to a node, its
pool->node will be mapped to that node. And memory used by this workqueue will
also be allocated on that node.

static struct worker_pool *get_unbound_pool(const struct workqueue_attrs *attrs){
...
        /* if cpumask is contained inside a NUMA node, we belong to that node */
        if (wq_numa_enabled) {
                for_each_node(node) {
                        if (cpumask_subset(pool->attrs->cpumask,
                                           wq_numa_possible_cpumask[node])) {
                                pool->node = node;
                                break;
                        }
                }
        }

Since wq_numa_possible_cpumask is not updated, it could be mapped to an offline node,
which will lead to memory allocation failure:

 SLUB: Unable to allocate memory on node 2 (gfp=0x80d0)
  cache: kmalloc-192, object size: 192, buffer size: 192, default order: 1, min order: 0
  node 0: slabs: 6172, objs: 259224, free: 245741
  node 1: slabs: 3261, objs: 136962, free: 127656

It happens here:

create_worker(struct worker_pool *pool)
 |--> worker = alloc_worker(pool->node);

static struct worker *alloc_worker(int node)
{
        struct worker *worker;

        worker = kzalloc_node(sizeof(*worker), GFP_KERNEL, node); --> Here, useing the wrong node.

        ......

        return worker;
}

[Solution]

To fix this problem, we establish cpuid <-> nodeid mapping for all the possible
cpus at boot time, and make it invariable. And according to init_cpu_to_node(),
cpuid <-> nodeid mapping is based on apicid <-> nodeid mapping and cpuid <-> apicid
mapping. So the key point is obtaining all cpus' apicid.

apicid can be obtained by _MAT (Multiple APIC Table Entry) method or found in
MADT (Multiple APIC Description Table). So we finish the job in the following steps:

1. Enable apic registeration flow to handle both enabled and disabled cpus.
   This is done by introducing an extra parameter to generic_processor_info to let the
   caller control if disabled cpus are ignored.

2. Introduce a new array storing all possible cpuid <-> apicid mapping. And also modify
   the way cpuid is calculated. Establish all possible cpuid <-> apicid mapping when
   registering local apic. Store the mapping in the array introduced above.

4. Enable _MAT and MADT relative apis to return non-presnet or disabled cpus' apicid.
   This is also done by introducing an extra parameter to these apis to let the caller
   control if disabled cpus are ignored.

5. Establish all possible cpuid <-> nodeid mapping.
   This is done via an additional acpi namespace walk for processors.


For previous discussion, please refer to:
https://lkml.org/lkml/2015/2/27/145
https://lkml.org/lkml/2015/3/25/989
https://lkml.org/lkml/2015/5/14/244


Gu Zheng (5):
  x86, gfp: Cache best near node for memory allocation.
  x86, acpi, cpu-hotplug: Enable acpi to register all possible cpus at
    boot time.
  x86, acpi, cpu-hotplug: Introduce apicid_to_cpuid[] array to store
    persistent cpuid <-> apicid mapping.
  x86, acpi, cpu-hotplug: Enable MADT APIs to return disabled apicid.
  x86, acpi, cpu-hotplug: Set persistent cpuid <-> nodeid mapping when
    booting.

 arch/ia64/kernel/acpi.c         |   2 +-
 arch/x86/include/asm/mpspec.h   |   1 +
 arch/x86/include/asm/topology.h |   2 +
 arch/x86/kernel/acpi/boot.c     |   8 +--
 arch/x86/kernel/apic/apic.c     |  71 ++++++++++++++++++++---
 arch/x86/mm/numa.c              |  57 ++++++++++++-------
 drivers/acpi/acpi_processor.c   |   5 +-
 drivers/acpi/bus.c              |   3 +
 drivers/acpi/processor_core.c   | 122 +++++++++++++++++++++++++++++++++-------
 include/linux/acpi.h            |   2 +
 include/linux/gfp.h             |  12 +++-
 11 files changed, 227 insertions(+), 58 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
