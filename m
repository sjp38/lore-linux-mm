Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7198B6B0256
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 00:29:49 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so30749376pac.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 21:29:49 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id qa17si13486131pab.131.2015.09.09.21.29.47
        for <linux-mm@kvack.org>;
        Wed, 09 Sep 2015 21:29:48 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 2/7] x86, numa: Introduce a node to node array to map a node to its best online node.
Date: Thu, 10 Sep 2015 12:27:44 +0800
Message-ID: <1441859269-25831-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com
Cc: tangchen@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The whole patch-set aims at solving this problem:

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

But before that, we should make memory allocators be able to get best near online node
at any time, because if node hotplug happens, the best near online node will change.

In current kernel, CPUs on a memory-less node are all mapped to its best online
node to ensure the memory allocation on these CPUs successful. This is done
outside alloc_pages_node() and alloc_pages_exact_node(), when the kernel boots.

In this patch, we calculate best near online node for all nodes at node hotplug time,
and store them in an array so that they could be obtained inside memory allocator
at any time.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/topology.h | 10 ++++++++++
 arch/x86/mm/numa.c              | 32 +++++++++++++++++++++++++++++++-
 mm/memory_hotplug.c             |  4 ++++
 3 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/topology.h b/arch/x86/include/asm/topology.h
index 0fb4648..53422fd 100644
--- a/arch/x86/include/asm/topology.h
+++ b/arch/x86/include/asm/topology.h
@@ -82,6 +82,9 @@ static inline const struct cpumask *cpumask_of_node(int node)
 }
 #endif
 
+extern int get_near_online_node(int node);
+extern void update_node_to_near_node_map(void);
+
 extern void setup_node_to_cpumask_map(void);
 
 /*
@@ -113,6 +116,13 @@ static inline int early_cpu_to_node(int cpu)
 
 static inline void setup_node_to_cpumask_map(void) { }
 
+static inline int get_near_online_node(int node)
+{
+	return 0;
+}
+
+static inline void update_node_to_near_node_map() { }
+
 #endif
 
 #include <asm-generic/topology.h>
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index fea387a..8bd7661 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -78,6 +78,14 @@ EXPORT_SYMBOL(node_to_cpumask_map);
 DEFINE_EARLY_PER_CPU(int, x86_cpu_to_node_map, NUMA_NO_NODE);
 EXPORT_EARLY_PER_CPU_SYMBOL(x86_cpu_to_node_map);
 
+/*
+ * Map nid index to the best near online node. The best near online node
+ * is the backup node for memory allocation on offline node.
+ */
+static int node_to_near_node_map[] = {
+	[0 ... MAX_NUMNODES - 1] = NUMA_NO_NODE,
+};
+
 /**
  * find_near_online_node - Find the best near online node of a node.
  * @node: NUMA node ID of the current node.
@@ -89,7 +97,7 @@ EXPORT_EARLY_PER_CPU_SYMBOL(x86_cpu_to_node_map);
  * RETURNS:
  * The best near online node ID on success, -1 on failure.
  */
-static __init int find_near_online_node(int node)
+static int find_near_online_node(int node)
 {
 	int n, val;
 	int min_val = INT_MAX;
@@ -107,6 +115,25 @@ static __init int find_near_online_node(int node)
 	return near_node;
 }
 
+int get_near_online_node(int node)
+{
+	return node_to_near_node_map[node];
+}
+EXPORT_SYMBOL(get_near_online_node);
+
+static void set_near_online_node(int node)
+{
+	node_to_near_node_map[node] = find_near_online_node(node);
+}
+
+void update_node_to_near_node_map()
+{
+	int node;
+
+	for_each_node(node)
+		set_near_online_node(node);
+}
+
 void numa_set_node(int cpu, int node)
 {
 	int *cpu_to_node_map = early_per_cpu_ptr(x86_cpu_to_node_map);
@@ -126,6 +153,8 @@ void numa_set_node(int cpu, int node)
 #endif
 	per_cpu(x86_cpu_to_node_map, cpu) = node;
 
+	set_near_online_node(node);
+
 	set_cpu_numa_node(cpu, node);
 }
 
@@ -249,6 +278,7 @@ static void __init alloc_node_data(int nid)
 	memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
 
 	node_set_online(nid);
+	update_node_to_near_node_map();
 }
 
 /**
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6da82bc..9d78d5f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1164,6 +1164,8 @@ int try_online_node(int nid)
 		goto out;
 	}
 	node_set_online(nid);
+	update_node_to_near_node_map();
+
 	ret = register_one_node(nid);
 	BUG_ON(ret);
 
@@ -1264,6 +1266,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 
 	/* we online node here. we can't roll back from here. */
 	node_set_online(nid);
+	update_node_to_near_node_map();
 
 	if (new_node) {
 		ret = register_one_node(nid);
@@ -1970,6 +1973,7 @@ void try_offline_node(int nid)
 	 */
 	node_set_offline(nid);
 	unregister_one_node(nid);
+	update_node_to_near_node_map();
 
 	/* free waittable in each zone */
 	for (i = 0; i < MAX_NR_ZONES; i++) {
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
