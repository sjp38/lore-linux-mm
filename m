Message-Id: <20080121211600.273130000@sgi.com>
References: <20080121211600.079162000@sgi.com>
Date: Mon, 21 Jan 2008 13:16:01 -0800
From: travis@sgi.com
Subject: [PATCH 1/4] x86: Change size of node ids from u8 to s16 fixup V2
Content-Disposition: inline; filename=big_nodeids-fixup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Yinghai Lu <yhlu.kernel@gmail.com>, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

Change the size of node ids for X86_64 from u8 to s16 to
accomodate more than 32k nodes and allow for NUMA_NO_NODE
(-1) to be sign extended to int.

Based on 2.6.24-rc8-mm1

Cc: David Rientjes <rientjes@google.com>
Cc: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
fixup-V2:

    - Fixed populate_memnodemap as suggested by Eric.
    - Change to using s16 for static node id arrays and
      int for node id's in per_cpu variables and __initdata
      arrays as suggested by David and Yinghai.
    - NUMA_NO_NODE is now (-1)

fixup:

    - Size of memnode.embedded_map needs to be changed to
      accomodate 16-bit node ids as suggested by Eric.

V2->V3:
    - changed memnode.embedded_map from [64-16] to [64-8]
      (and size comment to 128 bytes)

V1->V2:
    - changed pxm_to_node_map to u16
    - changed memnode map entries to u16
---
 arch/x86/Kconfig            |    1 +
 arch/x86/mm/numa_64.c       |   14 +++++++-------
 include/asm-x86/mmzone_64.h |    6 +++---
 include/asm-x86/numa_64.h   |    2 +-
 include/asm-x86/topology.h  |    8 ++++----
 5 files changed, 16 insertions(+), 15 deletions(-)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -882,6 +882,7 @@ config NUMA_EMU
 
 config NODES_SHIFT
 	int
+	range 1 15  if X86_64
 	default "6" if X86_64
 	default "4" if X86_NUMAQ
 	default "3"
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -31,16 +31,16 @@ bootmem_data_t plat_node_bdata[MAX_NUMNO
 
 struct memnode memnode;
 
-u16 x86_cpu_to_node_map_init[NR_CPUS] = {
+int x86_cpu_to_node_map_init[NR_CPUS] = {
 	[0 ... NR_CPUS-1] = NUMA_NO_NODE
 };
 void *x86_cpu_to_node_map_early_ptr;
 EXPORT_SYMBOL(x86_cpu_to_node_map_init);
 EXPORT_SYMBOL(x86_cpu_to_node_map_early_ptr);
-DEFINE_PER_CPU(u16, x86_cpu_to_node_map) = NUMA_NO_NODE;
+DEFINE_PER_CPU(int, x86_cpu_to_node_map) = NUMA_NO_NODE;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_node_map);
 
-u16 apicid_to_node[MAX_LOCAL_APIC] __cpuinitdata = {
+s16 apicid_to_node[MAX_LOCAL_APIC] __cpuinitdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
 };
 
@@ -64,7 +64,7 @@ static int __init populate_memnodemap(co
 	unsigned long addr, end;
 	int i, res = -1;
 
-	memset(memnodemap, 0xff, memnodemapsize);
+	memset(memnodemap, 0xff, sizeof(s16)*memnodemapsize);
 	for (i = 0; i < numnodes; i++) {
 		addr = nodes[i].start;
 		end = nodes[i].end;
@@ -73,7 +73,7 @@ static int __init populate_memnodemap(co
 		if ((end >> shift) >= memnodemapsize)
 			return 0;
 		do {
-			if (memnodemap[addr >> shift] != 0xff)
+			if (memnodemap[addr >> shift] != NUMA_NO_NODE)
 				return -1;
 			memnodemap[addr >> shift] = i;
 			addr += (1UL << shift);
@@ -88,7 +88,7 @@ static int __init allocate_cachealigned_
 	unsigned long pad, pad_addr;
 
 	memnodemap = memnode.embedded_map;
-	if (memnodemapsize <= 48)
+	if (memnodemapsize <= ARRAY_SIZE(memnode.embedded_map))
 		return 0;
 
 	pad = L1_CACHE_BYTES - 1;
@@ -566,7 +566,7 @@ __cpuinit void numa_add_cpu(int cpu)
 
 void __cpuinit numa_set_node(int cpu, int node)
 {
-	u16 *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
+	int *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
 
 	cpu_pda(cpu)->nodenumber = node;
 
--- a/include/asm-x86/mmzone_64.h
+++ b/include/asm-x86/mmzone_64.h
@@ -15,9 +15,9 @@
 struct memnode {
 	int shift;
 	unsigned int mapsize;
-	u8 *map;
-	u8 embedded_map[64-16];
-} ____cacheline_aligned; /* total size = 64 bytes */
+	s16 *map;
+	s16 embedded_map[64-8];
+} ____cacheline_aligned; /* total size = 128 bytes */
 extern struct memnode memnode;
 #define memnode_shift memnode.shift
 #define memnodemap memnode.map
--- a/include/asm-x86/numa_64.h
+++ b/include/asm-x86/numa_64.h
@@ -20,7 +20,7 @@ extern void numa_set_node(int cpu, int n
 extern void srat_reserve_add_area(int nodeid);
 extern int hotadd_percent;
 
-extern u16 apicid_to_node[MAX_LOCAL_APIC];
+extern s16 apicid_to_node[MAX_LOCAL_APIC];
 
 extern void numa_initmem_init(unsigned long start_pfn, unsigned long end_pfn);
 extern unsigned long numa_free_all_bootmem(void);
--- a/include/asm-x86/topology.h
+++ b/include/asm-x86/topology.h
@@ -30,17 +30,17 @@
 #include <asm/mpspec.h>
 
 /* Mappings between logical cpu number and node number */
-DECLARE_PER_CPU(u16, x86_cpu_to_node_map);
-extern u16 x86_cpu_to_node_map_init[];
+DECLARE_PER_CPU(int, x86_cpu_to_node_map);
+extern int x86_cpu_to_node_map_init[];
 extern void *x86_cpu_to_node_map_early_ptr;
 extern cpumask_t node_to_cpumask_map[];
 
-#define NUMA_NO_NODE	((u16)(~0))
+#define NUMA_NO_NODE	(-1)
 
 /* Returns the number of the node containing CPU 'cpu' */
 static inline int cpu_to_node(int cpu)
 {
-	u16 *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
+	int *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
 
 	if (cpu_to_node_map)
 		return cpu_to_node_map[cpu];

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
