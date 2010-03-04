Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D5CA26B009D
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 11:59:01 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 04 Mar 2010 12:07:16 -0500
Message-Id: <20100304170716.10606.24477.sendpatchset@localhost.localdomain>
In-Reply-To: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 3/8] numa:  x86_64:  use generic percpu var for numa_node_id() implementation
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.33-mmotm-100302-1838

x86 arch specific changes to use generic numa_node_id() based on
generic percpu variable infrastructure.  Back out x86's custom
version of numa_node_id()

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
[Christoph's signoff here?]

V0: based on:
# From cl@linux-foundation.org Wed Nov  4 10:36:12 2009
# Date: Wed, 4 Nov 2009 12:35:14 -0500 (EST)
# From: Christoph Lameter <cl@linux-foundation.org>
# To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
# Subject: Re: [PATCH/RFC] slab:  handle memoryless nodes efficiently
# 
# I have a very early form of a draft of a patch here that genericizes
# numa_node_id(). Uses the new generic this_cpu_xxx stuff.
# 
# Not complete.

V1:
  + split out x86-specific changes from generic.
  + change 'node_number' => 'numa_node' in x86 arch code
  + define __this_cpu_read in x86 asm/percpu.h
  + change x86/kernel/setup_percpu.c to use early_cpu_to_node() to
    setup 'numa_node' as cpu_to_node() now depends on the per cpu var.
    [I think!  What about cpu_to_node() func in x86/mm/numa_64.c ???]

V2:
  + cpu_to_node() => early_cpu_to_node(); incomplete change in V01
  + x86 arch define USE_PERCPU_NUMA_NODE_ID.

 arch/x86/Kconfig                |    4 ++++
 arch/x86/include/asm/percpu.h   |    2 ++
 arch/x86/include/asm/topology.h |   13 +------------
 arch/x86/kernel/cpu/common.c    |    6 +++---
 arch/x86/kernel/setup_percpu.c  |    4 ++--
 arch/x86/mm/numa_64.c           |    5 +----
 6 files changed, 13 insertions(+), 21 deletions(-)

Index: linux-2.6.33-mmotm-100302-1838/arch/x86/include/asm/topology.h
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/arch/x86/include/asm/topology.h
+++ linux-2.6.33-mmotm-100302-1838/arch/x86/include/asm/topology.h
@@ -53,33 +53,22 @@
 extern int cpu_to_node_map[];
 
 /* Returns the number of the node containing CPU 'cpu' */
-static inline int cpu_to_node(int cpu)
+static inline int early_cpu_to_node(int cpu)
 {
 	return cpu_to_node_map[cpu];
 }
-#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
 
 #else /* CONFIG_X86_64 */
 
 /* Mappings between logical cpu number and node number */
 DECLARE_EARLY_PER_CPU(int, x86_cpu_to_node_map);
 
-/* Returns the number of the current Node. */
-DECLARE_PER_CPU(int, node_number);
-#define numa_node_id()		percpu_read(node_number)
-
 #ifdef CONFIG_DEBUG_PER_CPU_MAPS
 extern int cpu_to_node(int cpu);
 extern int early_cpu_to_node(int cpu);
 
 #else	/* !CONFIG_DEBUG_PER_CPU_MAPS */
 
-/* Returns the number of the node containing CPU 'cpu' */
-static inline int cpu_to_node(int cpu)
-{
-	return per_cpu(x86_cpu_to_node_map, cpu);
-}
-
 /* Same function but used if called before per_cpu areas are setup */
 static inline int early_cpu_to_node(int cpu)
 {
Index: linux-2.6.33-mmotm-100302-1838/arch/x86/mm/numa_64.c
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/arch/x86/mm/numa_64.c
+++ linux-2.6.33-mmotm-100302-1838/arch/x86/mm/numa_64.c
@@ -33,9 +33,6 @@ int numa_off __initdata;
 static unsigned long __initdata nodemap_addr;
 static unsigned long __initdata nodemap_size;
 
-DEFINE_PER_CPU(int, node_number) = 0;
-EXPORT_PER_CPU_SYMBOL(node_number);
-
 /*
  * Map cpu index to node index
  */
@@ -809,7 +806,7 @@ void __cpuinit numa_set_node(int cpu, in
 	per_cpu(x86_cpu_to_node_map, cpu) = node;
 
 	if (node != NUMA_NO_NODE)
-		per_cpu(node_number, cpu) = node;
+		per_cpu(numa_node, cpu) = node;
 }
 
 void __cpuinit numa_clear_node(int cpu)
Index: linux-2.6.33-mmotm-100302-1838/arch/x86/include/asm/percpu.h
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/arch/x86/include/asm/percpu.h
+++ linux-2.6.33-mmotm-100302-1838/arch/x86/include/asm/percpu.h
@@ -208,10 +208,12 @@ do {									\
 #define percpu_or(var, val)		percpu_to_op("or", var, val)
 #define percpu_xor(var, val)		percpu_to_op("xor", var, val)
 
+#define __this_cpu_read(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
 #define __this_cpu_read_1(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
 #define __this_cpu_read_2(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
 #define __this_cpu_read_4(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
 
+#define __this_cpu_write(pcp, val)	percpu_to_op("mov", (pcp), val)
 #define __this_cpu_write_1(pcp, val)	percpu_to_op("mov", (pcp), val)
 #define __this_cpu_write_2(pcp, val)	percpu_to_op("mov", (pcp), val)
 #define __this_cpu_write_4(pcp, val)	percpu_to_op("mov", (pcp), val)
Index: linux-2.6.33-mmotm-100302-1838/arch/x86/kernel/cpu/common.c
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/arch/x86/kernel/cpu/common.c
+++ linux-2.6.33-mmotm-100302-1838/arch/x86/kernel/cpu/common.c
@@ -1121,9 +1121,9 @@ void __cpuinit cpu_init(void)
 	oist = &per_cpu(orig_ist, cpu);
 
 #ifdef CONFIG_NUMA
-	if (cpu != 0 && percpu_read(node_number) == 0 &&
-	    cpu_to_node(cpu) != NUMA_NO_NODE)
-		percpu_write(node_number, cpu_to_node(cpu));
+	if (cpu != 0 && percpu_read(numa_node) == 0 &&
+	    early_cpu_to_node(cpu) != NUMA_NO_NODE)
+		set_numa_node(early_cpu_to_node(cpu));
 #endif
 
 	me = current;
Index: linux-2.6.33-mmotm-100302-1838/arch/x86/kernel/setup_percpu.c
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/arch/x86/kernel/setup_percpu.c
+++ linux-2.6.33-mmotm-100302-1838/arch/x86/kernel/setup_percpu.c
@@ -265,10 +265,10 @@ void __init setup_per_cpu_areas(void)
 
 #if defined(CONFIG_X86_64) && defined(CONFIG_NUMA)
 	/*
-	 * make sure boot cpu node_number is right, when boot cpu is on the
+	 * make sure boot cpu numa_node is right, when boot cpu is on the
 	 * node that doesn't have mem installed
 	 */
-	per_cpu(node_number, boot_cpu_id) = cpu_to_node(boot_cpu_id);
+	per_cpu(numa_node, boot_cpu_id) = early_cpu_to_node(boot_cpu_id);
 #endif
 
 	/* Setup node to cpumask map */
Index: linux-2.6.33-mmotm-100302-1838/arch/x86/Kconfig
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/arch/x86/Kconfig
+++ linux-2.6.33-mmotm-100302-1838/arch/x86/Kconfig
@@ -1696,6 +1696,10 @@ config HAVE_ARCH_EARLY_PFN_TO_NID
 	def_bool X86_64
 	depends on NUMA
 
+config USE_PERCPU_NUMA_NODE_ID
+	def_bool y
+	depends on NUMA
+
 menu "Power management and ACPI options"
 
 config ARCH_HIBERNATION_HEADER

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
