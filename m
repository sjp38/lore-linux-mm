Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1250F83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 04:36:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so79209470pfx.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 01:36:11 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ro7si14440841pab.37.2016.08.25.01.36.09
        for <linux-mm@kvack.org>;
        Thu, 25 Aug 2016 01:36:10 -0700 (PDT)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH v12 2/7] x86, acpi, cpu-hotplug: Enable acpi to register all possible cpus at boot time.
Date: Thu, 25 Aug 2016 16:35:15 +0800
Message-ID: <1472114120-3281-3-git-send-email-douly.fnst@cn.fujitsu.com>
In-Reply-To: <1472114120-3281-1-git-send-email-douly.fnst@cn.fujitsu.com>
References: <1472114120-3281-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org
Cc: x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dou Liyang <douly.fnst@cn.fujitsu.com>

From: Gu Zheng <guz.fnst@cn.fujitsu.com>

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

There are four mappings in the kernel:
1. nodeid (logical node id)   <->   pxm
2. apicid (physical cpu id)   <->   nodeid
3. cpuid (logical cpu id)     <->   apicid
4. cpuid (logical cpu id)     <->   nodeid

1. pxm (proximity domain) is provided by ACPI firmware in SRAT, and nodeid <-> pxm
   mapping is setup at boot time. This mapping is persistent, won't change.

2. apicid <-> nodeid mapping is setup using info in 1. The mapping is setup at boot
   time and CPU hotadd time, and cleared at CPU hotremove time. This mapping is also
   persistent.

3. cpuid <-> apicid mapping is setup at boot time and CPU hotadd time. cpuid is
   allocated, lower ids first, and released at CPU hotremove time, reused for other
   hotadded CPUs. So this mapping is not persistent.

4. cpuid <-> nodeid mapping is also setup at boot time and CPU hotadd time, and
   cleared at CPU hotremove time. As a result of 3, this mapping is not persistent.

To fix this problem, we establish cpuid <-> nodeid mapping for all the possible
cpus at boot time, and make it persistent. And according to init_cpu_to_node(),
cpuid <-> nodeid mapping is based on apicid <-> nodeid mapping and cpuid <-> apicid
mapping. So the key point is obtaining all cpus' apicid.

apicid can be obtained by _MAT (Multiple APIC Table Entry) method or found in
MADT (Multiple APIC Description Table). So we finish the job in the following steps:

1. Enable apic registeration flow to handle both enabled and disabled cpus.
   This is done by introducing an extra parameter to generic_processor_info to let the
   caller control if disabled cpus are ignored.

2. Introduce a new array storing all possible cpuid <-> apicid mapping. And also modify
   the way cpuid is calculated. Establish all possible cpuid <-> apicid mapping when
   registering local apic. Store the mapping in this array.

3. Enable _MAT and MADT relative apis to return non-presnet or disabled cpus' apicid.
   This is also done by introducing an extra parameter to these apis to let the caller
   control if disabled cpus are ignored.

4. Establish all possible cpuid <-> nodeid mapping.
   This is done via an additional acpi namespace walk for processors.

This patch finished step 1.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
---
 arch/x86/kernel/apic/apic.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
index cea4fc1..e5612a9 100644
--- a/arch/x86/kernel/apic/apic.c
+++ b/arch/x86/kernel/apic/apic.c
@@ -2024,7 +2024,7 @@ void disconnect_bsp_APIC(int virt_wire_setup)
 	apic_write(APIC_LVT1, value);
 }
 
-int generic_processor_info(int apicid, int version)
+static int __generic_processor_info(int apicid, int version, bool enabled)
 {
 	int cpu, max = nr_cpu_ids;
 	bool boot_cpu_detected = physid_isset(boot_cpu_physical_apicid,
@@ -2090,7 +2090,6 @@ int generic_processor_info(int apicid, int version)
 		return -EINVAL;
 	}
 
-	num_processors++;
 	if (apicid == boot_cpu_physical_apicid) {
 		/*
 		 * x86_bios_cpu_apicid is required to have processors listed
@@ -2113,6 +2112,7 @@ int generic_processor_info(int apicid, int version)
 
 		pr_warning("APIC: Package limit reached. Processor %d/0x%x ignored.\n",
 			   thiscpu, apicid);
+
 		disabled_cpus++;
 		return -ENOSPC;
 	}
@@ -2132,7 +2132,6 @@ int generic_processor_info(int apicid, int version)
 			apic_version[boot_cpu_physical_apicid], cpu, version);
 	}
 
-	physid_set(apicid, phys_cpu_present_map);
 	if (apicid > max_physical_apicid)
 		max_physical_apicid = apicid;
 
@@ -2145,11 +2144,22 @@ int generic_processor_info(int apicid, int version)
 		apic->x86_32_early_logical_apicid(cpu);
 #endif
 	set_cpu_possible(cpu, true);
-	set_cpu_present(cpu, true);
+
+	if (enabled) {
+		num_processors++;
+		physid_set(apicid, phys_cpu_present_map);
+		set_cpu_present(cpu, true);
+	} else
+		disabled_cpus++;
 
 	return cpu;
 }
 
+int generic_processor_info(int apicid, int version)
+{
+	return __generic_processor_info(apicid, version, true);
+}
+
 int hard_smp_processor_id(void)
 {
 	return read_apic_id();
-- 
2.5.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
