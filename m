Message-Id: <20080123044924.784571000@sgi.com>
References: <20080123044924.508382000@sgi.com>
Date: Tue, 22 Jan 2008 20:49:25 -0800
From: travis@sgi.com
Subject: [PATCH 1/3] generic: Percpu infrastructure to rebase the per cpu area to zero
Content-Disposition: inline; filename=zero_based_infrastructure
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

	CONFIG_HAVE_ZERO_BASED_PER_CPU

      that makes offsets for per cpu variables to start at zero.

      If a percpu area starts at zero then:

	-  We do not need RELOC_HIDE anymore

	-  Provides for the future capability of architectures providing
	   a per cpu allocator that returns offsets instead of pointers.
	   The offsets would be independent of the processor so that
	   address calculations can be done in a processor independent way.
	   Per cpu instructions can then add the processor specific offset
	   at the last minute possibly in an atomic instruction.

      The data the linker provides is different for zero based percpu segments:

	__per_cpu_load	-> The address at which the percpu area was loaded
	__per_cpu_size	-> The length of the per cpu area

    * Removes the &__per_cpu_x in lockdep. The __per_cpu_x are already
      pointers. There is no need to take the address.

    * Changes generic setup_per_cpu_areas to allocate per_cpu space in
      node local memory.  This requires a generic early_cpu_to_node function.

Based on 2.6.24-rc8-mm1

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
 include/asm-alpha/topology.h          |    1 +
 include/asm-generic/percpu.h          |    7 ++++++-
 include/asm-generic/sections.h        |   10 ++++++++++
 include/asm-generic/topology.h        |    3 +++
 include/asm-generic/vmlinux.lds.h     |   15 +++++++++++++++
 include/asm-ia64/topology.h           |    1 +
 include/asm-mips/mach-ip27/topology.h |    1 +
 include/asm-powerpc/topology.h        |    1 +
 init/main.c                           |   18 ++++++++++--------
 kernel/lockdep.c                      |    4 ++--
 10 files changed, 50 insertions(+), 11 deletions(-)

--- a/include/asm-alpha/topology.h
+++ b/include/asm-alpha/topology.h
@@ -6,6 +6,7 @@
 #include <asm/machvec.h>
 
 #ifdef CONFIG_NUMA
+#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
 static inline int cpu_to_node(int cpu)
 {
 	int node;
--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -43,7 +43,12 @@ extern unsigned long __per_cpu_offset[NR
  * Only S390 provides its own means of moving the pointer.
  */
 #ifndef SHIFT_PERCPU_PTR
-#define SHIFT_PERCPU_PTR(__p, __offset)	RELOC_HIDE((__p), (__offset))
+# ifdef CONFIG_HAVE_ZERO_BASED_PER_CPU
+#  define SHIFT_PERCPU_PTR(__p, __offset) \
+	((__typeof(__p))(((void *)(__p)) + (__offset)))
+# else
+#  define SHIFT_PERCPU_PTR(__p, __offset)	RELOC_HIDE((__p), (__offset))
+# endif /* CONFIG_HAVE_ZERO_BASED_PER_CPU */
 #endif
 
 /*
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -9,7 +9,17 @@ extern char __bss_start[], __bss_stop[];
 extern char __init_begin[], __init_end[];
 extern char _sinittext[], _einittext[];
 extern char _end[];
+#ifdef CONFIG_HAVE_ZERO_BASED_PER_CPU
+extern char __per_cpu_load[];
+extern char ____per_cpu_size[];
+#define __per_cpu_size ((unsigned long)&____per_cpu_size)
+#define __per_cpu_start ((char *)0)
+#define __per_cpu_end ((char *)__per_cpu_size)
+#else
 extern char __per_cpu_start[], __per_cpu_end[];
+#define __per_cpu_load __per_cpu_start
+#define __per_cpu_size (__per_cpu_end - __per_cpu_start)
+#endif
 extern char __kprobes_text_start[], __kprobes_text_end[];
 extern char __initdata_begin[], __initdata_end[];
 extern char __start_rodata[], __end_rodata[];
--- a/include/asm-generic/topology.h
+++ b/include/asm-generic/topology.h
@@ -32,6 +32,9 @@
 #ifndef cpu_to_node
 #define cpu_to_node(cpu)	(0)
 #endif
+#ifndef early_cpu_to_node
+#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
+#endif
 #ifndef parent_node
 #define parent_node(node)	(0)
 #endif
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -255,6 +255,20 @@
   	*(.initcall7.init)						\
   	*(.initcall7s.init)
 
+#ifdef CONFIG_HAVE_ZERO_BASED_PER_CPU
+#define PERCPU(align)							\
+	. = ALIGN(align);						\
+	percpu : { } :percpu						\
+	__per_cpu_load = .;						\
+	.data.percpu 0 : AT(__per_cpu_load - LOAD_OFFSET) {		\
+		*(.data.percpu.first)					\
+		*(.data.percpu)						\
+		*(.data.percpu.shared_aligned)				\
+		____per_cpu_size = .;					\
+	}								\
+	. = __per_cpu_load + ____per_cpu_size;				\
+	data : { } :data
+#else
 #define PERCPU(align)							\
 	. = ALIGN(align);						\
 	__per_cpu_start = .;						\
@@ -263,3 +277,4 @@
 		*(.data.percpu.shared_aligned)				\
 	}								\
 	__per_cpu_end = .;
+#endif
--- a/include/asm-ia64/topology.h
+++ b/include/asm-ia64/topology.h
@@ -31,6 +31,7 @@
  * Returns the number of the node containing CPU 'cpu'
  */
 #define cpu_to_node(cpu) (int)(cpu_to_node_map[cpu])
+#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
 
 /*
  * Returns a bitmask of CPUs on Node 'node'.
--- a/include/asm-mips/mach-ip27/topology.h
+++ b/include/asm-mips/mach-ip27/topology.h
@@ -23,6 +23,7 @@ struct cpuinfo_ip27 {
 extern struct cpuinfo_ip27 sn_cpu_info[NR_CPUS];
 
 #define cpu_to_node(cpu)	(sn_cpu_info[(cpu)].p_nodeid)
+#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
 #define parent_node(node)	(node)
 #define node_to_cpumask(node)	(hub_data(node)->h_cpus)
 #define node_to_first_cpu(node)	(first_cpu(node_to_cpumask(node)))
--- a/include/asm-powerpc/topology.h
+++ b/include/asm-powerpc/topology.h
@@ -15,6 +15,7 @@ static inline int cpu_to_node(int cpu)
 	return numa_cpu_lookup_table[cpu];
 }
 
+#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
 #define parent_node(node)	(node)
 
 static inline cpumask_t node_to_cpumask(int node)
--- a/init/main.c
+++ b/init/main.c
@@ -370,18 +370,20 @@ EXPORT_SYMBOL(__per_cpu_offset);
 
 static void __init setup_per_cpu_areas(void)
 {
-	unsigned long size, i;
-	char *ptr;
-	unsigned long nr_possible_cpus = num_possible_cpus();
+	unsigned long size;
+	int cpu;
 
 	/* Copy section for each CPU (we discard the original) */
 	size = ALIGN(PERCPU_ENOUGH_ROOM, PAGE_SIZE);
-	ptr = alloc_bootmem_pages(size * nr_possible_cpus);
 
-	for_each_possible_cpu(i) {
-		__per_cpu_offset[i] = ptr - __per_cpu_start;
-		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
-		ptr += size;
+	printk(KERN_INFO "(generic)PERCPU: Allocating %lu bytes of per cpu data\n", size);
+
+	for_each_possible_cpu(cpu) {
+		char *ptr = alloc_bootmem_pages_node(
+				NODE_DATA(early_cpu_to_node(cpu)), size);
+
+		__per_cpu_offset[cpu] = ptr - __per_cpu_start;
+		memcpy(ptr, __per_cpu_load, __per_cpu_size);
 	}
 }
 #endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
--- a/kernel/lockdep.c
+++ b/kernel/lockdep.c
@@ -609,8 +609,8 @@ static int static_obj(void *obj)
 	 * percpu var?
 	 */
 	for_each_possible_cpu(i) {
-		start = (unsigned long) &__per_cpu_start + per_cpu_offset(i);
-		end   = (unsigned long) &__per_cpu_start + PERCPU_ENOUGH_ROOM
+		start = (unsigned long) __per_cpu_start + per_cpu_offset(i);
+		end   = (unsigned long) __per_cpu_start + PERCPU_ENOUGH_ROOM
 					+ per_cpu_offset(i);
 
 		if ((addr >= start) && (addr < end))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
