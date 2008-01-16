Message-Id: <20080116170902.328187000@sgi.com>
References: <20080116170902.006151000@sgi.com>
Date: Wed, 16 Jan 2008 09:09:04 -0800
From: travis@sgi.com
Subject: [PATCH 02/10] x86: Change size of node ids from u8 to u16 V3
Content-Disposition: inline; filename=big_nodeids
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Eric Dumazet <dada1@cosmosbay.com>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the size of node ids from 8 bits to 16 bits to
accomodate more than 256 nodes.

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
V1->V2:
    - changed pxm_to_node_map to u16
    - changed memnode map entries to u16
V2->V3:
    - changed memnode.embedded_map from [64-16] to [64-8]
      (and size comment to 128 bytes)
---
 arch/x86/mm/numa_64.c       |    9 ++++++---
 arch/x86/mm/srat_64.c       |    2 +-
 drivers/acpi/numa.c         |    2 +-
 include/asm-x86/mmzone_64.h |    6 +++---
 include/asm-x86/numa_64.h   |    4 ++--
 include/asm-x86/topology.h  |    2 +-
 6 files changed, 14 insertions(+), 11 deletions(-)

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
@@ -395,7 +395,7 @@ int __init acpi_scan_nodes(unsigned long
 static int fake_node_to_pxm_map[MAX_NUMNODES] __initdata = {
 	[0 ... MAX_NUMNODES-1] = PXM_INVAL
 };
-static unsigned char fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
+static u16 fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
 };
 static int __init find_node_by_addr(unsigned long addr)
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -38,7 +38,7 @@ ACPI_MODULE_NAME("numa");
 static nodemask_t nodes_found_map = NODE_MASK_NONE;
 
 /* maps to convert between proximity domain and logical node ID */
-static int pxm_to_node_map[MAX_PXM_DOMAINS]
+static u16 pxm_to_node_map[MAX_PXM_DOMAINS]
 				= { [0 ... MAX_PXM_DOMAINS - 1] = NID_INVAL };
 static int node_to_pxm_map[MAX_NUMNODES]
 				= { [0 ... MAX_NUMNODES - 1] = PXM_INVAL };
--- a/include/asm-x86/mmzone_64.h
+++ b/include/asm-x86/mmzone_64.h
@@ -15,9 +15,9 @@
 struct memnode {
 	int shift;
 	unsigned int mapsize;
-	u8 *map;
-	u8 embedded_map[64-16];
-} ____cacheline_aligned; /* total size = 64 bytes */
+	u16 *map;
+	u16 embedded_map[64-8];
+} ____cacheline_aligned; /* total size = 128 bytes */
 extern struct memnode memnode;
 #define memnode_shift memnode.shift
 #define memnodemap memnode.map
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
