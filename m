Message-ID: <478D325A.7080409@sgi.com>
Date: Tue, 15 Jan 2008 14:23:22 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/10] x86: Change NR_CPUS arrays in numa_64 V2
References: <20080115021735.779102000@sgi.com>	<20080115021737.228970000@sgi.com> <p73wsqbl5pn.fsf@bingen.suse.de>
In-Reply-To: <p73wsqbl5pn.fsf@bingen.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> travis@sgi.com writes:
>> +
>>  /* Returns the number of the node containing CPU 'cpu' */
>>  static inline int cpu_to_node(int cpu)
>>  {
>> -	return cpu_to_node_map[cpu];
>> +	u16 *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
>> +
>> +	if (cpu_to_node_map)
>> +		return cpu_to_node_map[cpu];
>> +	else if(per_cpu_offset(cpu))
>> +		return per_cpu(x86_cpu_to_node_map, cpu);
>> +	else
>> +		return NUMA_NO_NODE;
> 
> Seems a little big now to be still inlined.
> 
> Also I wonder if there are really that many early callers that it
> isn't feasible to just convert them to a early_cpu_to_node(). Also
> early_cpu_to_node() should really not be speed critical, so just
> linearly searching some other table instead of setting up an explicit
> array should be fine for that.
> 
> -Andi


Is this what you had in mind?  (It's still panic'ing early in kernel startup
so it's not quite done.)

There are a fair number of early callers of cpu_to_node() particularly when
HOTPLUG_CPU is enabled.

One note is that I plan to optimize the check for "earliness" with a flag
that can be checked in the local node instead of always going back to node
0 to check for a non-null "early_ptr".  This will shorten up the inline
functions quite a bit maybe making these mods unnecessary?

Thanks,
Mike
---

diff -pur V2/arch/x86/kernel/setup64.c V3/arch/x86/kernel/setup64.c
--- V2/arch/x86/kernel/setup64.c	2008-01-15 14:06:03.000000000 -0800
+++ V3/arch/x86/kernel/setup64.c	2008-01-15 14:01:09.000000000 -0800
@@ -100,12 +100,12 @@ void __init setup_per_cpu_areas(void)
 	for_each_cpu_mask (i, cpu_possible_map) {
 		char *ptr;
 
-		if (!NODE_DATA(cpu_to_node(i))) {
+		if (!NODE_DATA(early_cpu_to_node(i))) {
 			printk("cpu with no node %d, num_online_nodes %d\n",
 			       i, num_online_nodes());
 			ptr = alloc_bootmem_pages(size);
 		} else { 
-			ptr = alloc_bootmem_pages_node(NODE_DATA(cpu_to_node(i)), size);
+			ptr = alloc_bootmem_pages_node(NODE_DATA(early_cpu_to_node(i)), size);
 		}
 		if (!ptr)
 			panic("Cannot allocate cpu data for CPU %d\n", i);
diff -pur V2/arch/x86/kernel/smpboot_64.c V3/arch/x86/kernel/smpboot_64.c
--- V2/arch/x86/kernel/smpboot_64.c	2008-01-15 14:06:19.000000000 -0800
+++ V3/arch/x86/kernel/smpboot_64.c	2008-01-15 14:01:09.000000000 -0800
@@ -569,7 +569,7 @@ static int __cpuinit do_boot_cpu(int cpu
 	/* Allocate node local memory for AP pdas */
 	if (cpu_pda(cpu) == &boot_cpu_pda[cpu]) {
 		struct x8664_pda *newpda, *pda;
-		int node = cpu_to_node(cpu);
+		int node = early_cpu_to_node(cpu);
 		pda = cpu_pda(cpu);
 		newpda = kmalloc_node(sizeof (struct x8664_pda), GFP_ATOMIC,
 				      node);
@@ -702,7 +702,7 @@ do_rest:
 	if (boot_error) {
 		cpu_clear(cpu, cpu_callout_map); /* was set here (do_boot_cpu()) */
 		clear_bit(cpu, (unsigned long *)&cpu_initialized); /* was set by cpu_init() */
-		clear_node_cpumask(cpu); /* was set by numa_add_cpu */
+		clear_bit(cpu, (unsigned long *)&node_to_cpumask_map[early_cpu_to_node(cpu)]);
 		cpu_clear(cpu, cpu_present_map);
 		cpu_clear(cpu, cpu_possible_map);
 		per_cpu(x86_cpu_to_apicid, cpu) = BAD_APICID;
@@ -1060,7 +1060,7 @@ void remove_cpu_from_maps(void)
 	cpu_clear(cpu, cpu_callout_map);
 	cpu_clear(cpu, cpu_callin_map);
 	clear_bit(cpu, (unsigned long *)&cpu_initialized); /* was set by cpu_init() */
-	clear_node_cpumask(cpu);
+	clear_bit(cpu, (unsigned long *)&node_to_cpumask_map[cpu_to_node(cpu)]);
 }
 
 int __cpu_disable(void)
diff -pur V2/arch/x86/kernel/vsyscall_64.c V3/arch/x86/kernel/vsyscall_64.c
--- V2/arch/x86/kernel/vsyscall_64.c	2008-01-15 14:06:03.000000000 -0800
+++ V3/arch/x86/kernel/vsyscall_64.c	2008-01-15 14:01:09.000000000 -0800
@@ -289,7 +289,7 @@ static void __cpuinit vsyscall_set_cpu(i
 	unsigned long *d;
 	unsigned long node = 0;
 #ifdef CONFIG_NUMA
-	node = cpu_to_node(cpu);
+	node = early_cpu_to_node(cpu);
 #endif
 	if (cpu_has(&cpu_data(cpu), X86_FEATURE_RDTSCP))
 		write_rdtscp_aux((node << 12) | cpu);
diff -pur V2/arch/x86/mm/numa_64.c V3/arch/x86/mm/numa_64.c
--- V2/arch/x86/mm/numa_64.c	2008-01-15 14:06:19.000000000 -0800
+++ V3/arch/x86/mm/numa_64.c	2008-01-15 14:01:09.000000000 -0800
@@ -281,7 +281,7 @@ void __init numa_init_array(void)
 
 	rr = first_node(node_online_map);
 	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_to_node(i) != NUMA_NO_NODE)
+		if (early_cpu_to_node(i) != NUMA_NO_NODE)
 			continue;
 		numa_set_node(i, rr);
 		rr = next_node(rr, node_online_map);
@@ -558,7 +558,7 @@ void __init numa_initmem_init(unsigned l
 
 __cpuinit void numa_add_cpu(int cpu)
 {
-	set_bit(cpu, (unsigned long *)&node_to_cpumask_map[cpu_to_node(cpu)]);
+	set_bit(cpu, (unsigned long *)&node_to_cpumask_map[early_cpu_to_node(cpu)]);
 }
 
 void __cpuinit numa_set_node(int cpu, int node)
diff -pur V2/arch/x86/mm/srat_64.c V3/arch/x86/mm/srat_64.c
--- V2/arch/x86/mm/srat_64.c	2008-01-15 14:06:18.000000000 -0800
+++ V3/arch/x86/mm/srat_64.c	2008-01-15 14:01:09.000000000 -0800
@@ -382,9 +382,10 @@ int __init acpi_scan_nodes(unsigned long
 			setup_node_bootmem(i, nodes[i].start, nodes[i].end);
 
 	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_to_node(i) == NUMA_NO_NODE)
+		int node = early_cpu_to_node(i);
+		if (node == NUMA_NO_NODE)
 			continue;
-		if (!node_isset(cpu_to_node(i), node_possible_map))
+		if (!node_isset(node, node_possible_map))
 			numa_set_node(i, NUMA_NO_NODE);
 	}
 	numa_init_array();
diff -pur V2/include/asm-x86/numa_64.h V3/include/asm-x86/numa_64.h
--- V2/include/asm-x86/numa_64.h	2008-01-15 14:06:19.000000000 -0800
+++ V3/include/asm-x86/numa_64.h	2008-01-15 14:01:09.000000000 -0800
@@ -29,15 +29,8 @@ extern void setup_node_bootmem(int nodei
 
 #ifdef CONFIG_NUMA
 extern void __init init_cpu_to_node(void);
-
-static inline void clear_node_cpumask(int cpu)
-{
-	clear_bit(cpu, (unsigned long *)&node_to_cpumask_map[cpu_to_node(cpu)]);
-}
-
 #else
 #define init_cpu_to_node() do {} while (0)
-#define clear_node_cpumask(cpu) do {} while (0)
 #endif
 
 #endif
diff -pur V2/include/asm-x86/topology.h V3/include/asm-x86/topology.h
--- V2/include/asm-x86/topology.h	2008-01-15 14:06:19.000000000 -0800
+++ V3/include/asm-x86/topology.h	2008-01-15 14:01:09.000000000 -0800
@@ -38,7 +38,8 @@ extern cpumask_t node_to_cpumask_map[];
 #define NUMA_NO_NODE	((u16)(~0))
 
 /* Returns the number of the node containing CPU 'cpu' */
-static inline int cpu_to_node(int cpu)
+static inline int early_cpu_to_node(int cpu)
 {
 	u16 *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
 
@@ -50,6 +51,15 @@ static inline int cpu_to_node(int cpu)
 		return NUMA_NO_NODE;
 }
 
+static inline int cpu_to_node(int cpu)
+{
+	if(per_cpu_offset(cpu))
+		return per_cpu(x86_cpu_to_node_map, cpu);
+	else
+		return NUMA_NO_NODE;
+}
+
 /*
  * Returns the number of the node containing Node 'node'. This
  * architecture is flat, so it is a pretty simple function!

diff -pur V2/include/linux/mmzone.h V3/include/linux/mmzone.h
--- V2/include/linux/mmzone.h	2008-01-15 14:06:03.000000000 -0800
+++ V3/include/linux/mmzone.h	2008-01-15 14:01:09.000000000 -0800
@@ -692,6 +692,7 @@ extern char numa_zonelist_order[];
 /* Returns the number of the current Node. */
 #ifndef numa_node_id
 #define numa_node_id()		(cpu_to_node(raw_smp_processor_id()))
+#define early_numa_node_id()	(early_cpu_to_node(raw_smp_processor_id()))
 #endif
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
