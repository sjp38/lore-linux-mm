Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC9A82A8B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:38:48 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so950523pdi.32
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:38:48 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ei3si1526882pbb.219.2014.07.11.00.38.47
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:38:47 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 29/30] mm, x86: Enable memoryless node support to better support CPU/memory hotplug
Date: Fri, 11 Jul 2014 15:37:46 +0800
Message-Id: <1405064267-11678-30-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Toshi Kani <toshi.kani@hp.com>, Igor Mammedov <imammedo@redhat.com>, Borislav Petkov <bp@alien8.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Jiang Liu <jiang.liu@linux.intel.com>, Lans Zhang <jia.zhang@windriver.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-pm@vger.kernel.org

With current implementation, all CPUs within a NUMA node will be
assocaited with another NUMA node if the node has no memory installed.

For example, on a four-node system, CPUs on node 2 and 3 are associated
with node 0 when are no memory install on node 2 and 3, which may
confuse users.
root@bkd01sdp:~# numactl --hardware
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
node 0 size: 15602 MB
node 0 free: 15014 MB
node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89
node 1 size: 15985 MB
node 1 free: 15686 MB
node distances:
node   0   1
  0:  10  21
  1:  21  10

To be worse, the CPU affinity relationship won't get fixed even after
memory has been added to those nodes. After memory hot-addition to
node 2, CPUs on node 2 are still associated with node 0. This may cause
sub-optimal performance.
root@bkd01sdp:/sys/devices/system/node/node2# numactl --hardware
available: 3 nodes (0-2)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
node 0 size: 15602 MB
node 0 free: 14743 MB
node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89
node 1 size: 15985 MB
node 1 free: 15715 MB
node 2 cpus:
node 2 size: 128 MB
node 2 free: 128 MB
node distances:
node   0   1   2
  0:  10  21  21
  1:  21  10  21
  2:  21  21  10

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

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/x86/Kconfig            |    3 +++
 arch/x86/kernel/acpi/boot.c |    5 ++++-
 arch/x86/kernel/smpboot.c   |    2 ++
 arch/x86/mm/numa.c          |   42 +++++++++++++++++++++++++++++++++++-------
 4 files changed, 44 insertions(+), 8 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index a8f749ef0fdc..f35b25b88625 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1887,6 +1887,9 @@ config USE_PERCPU_NUMA_NODE_ID
 	def_bool y
 	depends on NUMA
 
+config HAVE_MEMORYLESS_NODES
+	def_bool NUMA
+
 config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 	def_bool y
 	depends on X86_64 || X86_PAE
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 86281ffb96d6..3b5641703a49 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -612,6 +612,8 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 	if (nid != -1) {
 		set_apicid_to_node(physid, nid);
 		numa_set_node(cpu, nid);
+		if (node_online(nid))
+			set_cpu_numa_mem(cpu, local_memory_node(nid));
 	}
 #endif
 }
@@ -644,9 +646,10 @@ int acpi_unmap_lsapic(int cpu)
 {
 #ifdef CONFIG_ACPI_NUMA
 	set_apicid_to_node(per_cpu(x86_cpu_to_apicid, cpu), NUMA_NO_NODE);
+	set_cpu_numa_mem(cpu, NUMA_NO_NODE);
 #endif
 
-	per_cpu(x86_cpu_to_apicid, cpu) = -1;
+	per_cpu(x86_cpu_to_apicid, cpu) = BAD_APICID;
 	set_cpu_present(cpu, false);
 	num_processors--;
 
diff --git a/arch/x86/kernel/smpboot.c b/arch/x86/kernel/smpboot.c
index 5492798930ef..4a5437989ffe 100644
--- a/arch/x86/kernel/smpboot.c
+++ b/arch/x86/kernel/smpboot.c
@@ -162,6 +162,8 @@ static void smp_callin(void)
 		      __func__, cpuid);
 	}
 
+	set_numa_mem(local_memory_node(cpu_to_node(cpuid)));
+
 	/*
 	 * the boot CPU has finished the init stage and is spinning
 	 * on callin_map until we finish. We are free to set up this
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index eec4f6c322bb..0d17c05480d2 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -22,6 +22,7 @@
 
 int __initdata numa_off;
 nodemask_t numa_nodes_parsed __initdata;
+static nodemask_t numa_nodes_empty __initdata;
 
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
@@ -523,8 +524,12 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 			end = max(mi->blk[i].end, end);
 		}
 
-		if (start < end)
+		if (start < end) {
 			setup_node_data(nid, start, end);
+		} else if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES)) {
+			setup_node_data(nid, 0, 0);
+			node_set(nid, numa_nodes_empty);
+		}
 	}
 
 	/* Dump memblock with node info and return. */
@@ -541,14 +546,18 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
  */
 static void __init numa_init_array(void)
 {
-	int rr, i;
+	int i, rr = MAX_NUMNODES;
 
-	rr = first_node(node_online_map);
 	for (i = 0; i < nr_cpu_ids; i++) {
+		/* Search for an onlined node with memory */
+		do {
+			if (rr != MAX_NUMNODES)
+				rr = next_node(rr, node_online_map);
+			if (rr == MAX_NUMNODES)
+				rr = first_node(node_online_map);
+		} while (!node_spanned_pages(rr));
+
 		numa_set_node(i, rr);
-		rr = next_node(rr, node_online_map);
-		if (rr == MAX_NUMNODES)
-			rr = first_node(node_online_map);
 	}
 }
 
@@ -694,9 +703,12 @@ static __init int find_near_online_node(int node)
 {
 	int n, val;
 	int min_val = INT_MAX;
-	int best_node = -1;
+	int best_node = NUMA_NO_NODE;
 
 	for_each_online_node(n) {
+		if (!node_spanned_pages(n))
+			continue;
+
 		val = node_distance(node, n);
 
 		if (val < min_val) {
@@ -737,6 +749,22 @@ void __init init_cpu_to_node(void)
 		if (!node_online(node))
 			node = find_near_online_node(node);
 		numa_set_node(cpu, node);
+		if (node_spanned_pages(node))
+			set_cpu_numa_mem(cpu, node);
+		if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES))
+			node_clear(node, numa_nodes_empty);
+	}
+
+	/* Destroy empty nodes */
+	if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES)) {
+		int nid;
+		const size_t nd_size = roundup(sizeof(pg_data_t), PAGE_SIZE);
+
+		for_each_node_mask(nid, numa_nodes_empty) {
+			node_set_offline(nid);
+			memblock_free(__pa(node_data[nid]), nd_size);
+			node_data[nid] = NULL;
+		}
 	}
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
