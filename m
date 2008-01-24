Message-Id: <20080124011204.614765000@sgi.com>
References: <20080124011204.470412000@sgi.com>
Date: Wed, 23 Jan 2008 17:12:05 -0800
From: travis@sgi.com
Subject: [PATCH 1/1] x86: early cpu_to_node fix in numa_64.c
Content-Disposition: inline; filename=cpu_to_node-fix-2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Both of these references to cpu_to_node() can potentially occur
before the "late" cpu_to_node map is setup.  Therefore, they
should be changed to use early_cpu_to_node().

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/mm/numa_64.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -251,7 +251,7 @@ void __init numa_init_array(void)
 
 	rr = first_node(node_online_map);
 	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_to_node(i) != NUMA_NO_NODE)
+		if (early_cpu_to_node(i) != NUMA_NO_NODE)
 			continue;
 		numa_set_node(i, rr);
 		rr = next_node(rr, node_online_map);
@@ -528,7 +528,8 @@ void __init numa_initmem_init(unsigned l
 
 __cpuinit void numa_add_cpu(int cpu)
 {
-	set_bit(cpu, (unsigned long *)&node_to_cpumask_map[cpu_to_node(cpu)]);
+	set_bit(cpu,
+		(unsigned long *)&node_to_cpumask_map[early_cpu_to_node(cpu)]);
 }
 
 void __cpuinit numa_set_node(int cpu, int node)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
