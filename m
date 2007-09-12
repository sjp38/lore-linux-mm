Message-Id: <20070912015645.566522143@sgi.com>
References: <20070912015644.927677070@sgi.com>
Date: Tue, 11 Sep 2007 18:56:46 -0700
From: travis@sgi.com
Subject: [PATCH 02/10] x86: fix cpu_to_node references (v3)
Content-Disposition: inline; filename=fix-cpu_to_node-refs
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix four instances where cpu_to_node is referenced
by array instead of via the cpu_to_node macro.  This
is preparation to moving it to the per_cpu data area.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86_64/kernel/vsyscall.c |    2 +-
 arch/x86_64/mm/numa.c         |    4 ++--
 arch/x86_64/mm/srat.c         |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

--- a/arch/x86_64/kernel/vsyscall.c
+++ b/arch/x86_64/kernel/vsyscall.c
@@ -291,7 +291,7 @@
 	unsigned long *d;
 	unsigned long node = 0;
 #ifdef CONFIG_NUMA
-	node = cpu_to_node[cpu];
+	node = cpu_to_node(cpu);
 #endif
 	if (cpu_has(&cpu_data[cpu], X86_FEATURE_RDTSCP))
 		write_rdtscp_aux((node << 12) | cpu);
--- a/arch/x86_64/mm/numa.c
+++ b/arch/x86_64/mm/numa.c
@@ -261,7 +261,7 @@
 	   We round robin the existing nodes. */
 	rr = first_node(node_online_map);
 	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_to_node[i] != NUMA_NO_NODE)
+		if (cpu_to_node(i) != NUMA_NO_NODE)
 			continue;
  		numa_set_node(i, rr);
 		rr = next_node(rr, node_online_map);
@@ -543,7 +543,7 @@
 void __cpuinit numa_set_node(int cpu, int node)
 {
 	cpu_pda(cpu)->nodenumber = node;
-	cpu_to_node[cpu] = node;
+	cpu_to_node(cpu) = node;
 }
 
 unsigned long __init numa_free_all_bootmem(void) 
--- a/arch/x86_64/mm/srat.c
+++ b/arch/x86_64/mm/srat.c
@@ -431,9 +431,9 @@
 			setup_node_bootmem(i, nodes[i].start, nodes[i].end);
 
 	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_to_node[i] == NUMA_NO_NODE)
+		if (cpu_to_node(i) == NUMA_NO_NODE)
 			continue;
-		if (!node_isset(cpu_to_node[i], node_possible_map))
+		if (!node_isset(cpu_to_node(i), node_possible_map))
 			numa_set_node(i, NUMA_NO_NODE);
 	}
 	numa_init_array();

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
