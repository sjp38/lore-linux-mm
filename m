Message-Id: <20080113183454.288993000@sgi.com>
References: <20080113183453.973425000@sgi.com>
Date: Sun, 13 Jan 2008 10:34:55 -0800
From: travis@sgi.com
Subject: [PATCH 02/10] x86: Change size of node ids from u8 to u16
Content-Disposition: inline; filename=big_nodeids
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the size of node ids from 8 bits to 16 bits to
accomodate more than 256 nodes.

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
 arch/x86/mm/numa_64.c      |    9 ++++++---
 arch/x86/mm/srat_64.c      |    2 +-
 include/asm-x86/numa_64.h  |    4 ++--
 include/asm-x86/topology.h |    2 +-
 4 files changed, 10 insertions(+), 7 deletions(-)

--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -11,6 +11,7 @@
 #include <linux/ctype.h>
 #include <linux/module.h>
 #include <linux/nodemask.h>
+#include <linux/sched.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -30,12 +31,12 @@ bootmem_data_t plat_node_bdata[MAX_NUMNO
 
 struct memnode memnode;
 
-int cpu_to_node_map[NR_CPUS] __read_mostly = {
+u16 cpu_to_node_map[NR_CPUS] __read_mostly = {
 	[0 ... NR_CPUS-1] = NUMA_NO_NODE
 };
 EXPORT_SYMBOL(cpu_to_node_map);
 
-unsigned char apicid_to_node[MAX_LOCAL_APIC] __cpuinitdata = {
+u16 apicid_to_node[MAX_LOCAL_APIC] __cpuinitdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
 };
 
@@ -544,7 +545,9 @@ void __init numa_initmem_init(unsigned l
 	node_set(0, node_possible_map);
 	for (i = 0; i < NR_CPUS; i++)
 		numa_set_node(i, 0);
-	node_to_cpumask_map[0] = cpumask_of_cpu(0);
+	/* we can't use cpumask_of_cpu() yet */
+	memset(&node_to_cpumask_map[0], 0, sizeof(node_to_cpumask_map[0]));
+	cpu_set(0, node_to_cpumask_map[0]);
 	e820_register_active_regions(0, start_pfn, end_pfn);
 	setup_node_bootmem(0, start_pfn << PAGE_SHIFT, end_pfn << PAGE_SHIFT);
 }
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -391,7 +391,7 @@ int __init acpi_scan_nodes(unsigned long
 static int fake_node_to_pxm_map[MAX_NUMNODES] __initdata = {
 	[0 ... MAX_NUMNODES-1] = PXM_INVAL
 };
-static unsigned char fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
+static u16 fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
 };
 static int __init find_node_by_addr(unsigned long addr)
--- a/include/asm-x86/numa_64.h
+++ b/include/asm-x86/numa_64.h
@@ -20,7 +20,7 @@ extern void numa_set_node(int cpu, int n
 extern void srat_reserve_add_area(int nodeid);
 extern int hotadd_percent;
 
-extern unsigned char apicid_to_node[MAX_LOCAL_APIC];
+extern u16 apicid_to_node[MAX_LOCAL_APIC];
 
 extern void numa_initmem_init(unsigned long start_pfn, unsigned long end_pfn);
 extern unsigned long numa_free_all_bootmem(void);
@@ -40,6 +40,6 @@ static inline void clear_node_cpumask(in
 #define clear_node_cpumask(cpu) do {} while (0)
 #endif
 
-#define NUMA_NO_NODE 0xff
+#define NUMA_NO_NODE 0xffff
 
 #endif
--- a/include/asm-x86/topology.h
+++ b/include/asm-x86/topology.h
@@ -30,7 +30,7 @@
 #include <asm/mpspec.h>
 
 /* Mappings between logical cpu number and node number */
-extern int cpu_to_node_map[];
+extern u16 cpu_to_node_map[];
 extern cpumask_t node_to_cpumask_map[];
 
 /* Returns the number of the node containing CPU 'cpu' */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
