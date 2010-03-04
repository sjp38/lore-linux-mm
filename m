Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 501216B00A0
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 11:59:58 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 04 Mar 2010 12:07:22 -0500
Message-Id: <20100304170722.10606.82223.sendpatchset@localhost.localdomain>
In-Reply-To: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 4/8] numa:  ia64:  use generic percpu var numa_node_id() implementation
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.33-mmotm-100302-1838

ia64:  Use generic percpu implementation of numa_node_id()
   + intialize per cpu 'numa_node'
   + remove ia64 cpu_to_node() macro;  use generic
   + define CONFIG_USE_PERCPU_NUMA_NODE_ID when NUMA configured

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

New in V2

 arch/ia64/Kconfig                |    4 ++++
 arch/ia64/include/asm/topology.h |    5 -----
 arch/ia64/kernel/smpboot.c       |    6 ++++++
 3 files changed, 10 insertions(+), 5 deletions(-)

Index: linux-2.6.33-mmotm-100302-1838/arch/ia64/kernel/smpboot.c
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/arch/ia64/kernel/smpboot.c
+++ linux-2.6.33-mmotm-100302-1838/arch/ia64/kernel/smpboot.c
@@ -390,6 +390,11 @@ smp_callin (void)
 
 	fix_b0_for_bsp();
 
+	/*
+	 * numa_node_id() works after this.
+	 */
+	set_numa_node(cpu_to_node_map[cpuid]);
+
 	ipi_call_lock_irq();
 	spin_lock(&vector_lock);
 	/* Setup the per cpu irq handling data structures */
@@ -632,6 +637,7 @@ void __devinit smp_prepare_boot_cpu(void
 {
 	cpu_set(smp_processor_id(), cpu_online_map);
 	cpu_set(smp_processor_id(), cpu_callin_map);
+	set_numa_node(cpu_to_node_map[smp_processor_id()]);
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
 	paravirt_post_smp_prepare_boot_cpu();
 }
Index: linux-2.6.33-mmotm-100302-1838/arch/ia64/include/asm/topology.h
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/arch/ia64/include/asm/topology.h
+++ linux-2.6.33-mmotm-100302-1838/arch/ia64/include/asm/topology.h
@@ -26,11 +26,6 @@
 #define RECLAIM_DISTANCE 15
 
 /*
- * Returns the number of the node containing CPU 'cpu'
- */
-#define cpu_to_node(cpu) (int)(cpu_to_node_map[cpu])
-
-/*
  * Returns a bitmask of CPUs on Node 'node'.
  */
 #define cpumask_of_node(node) ((node) == -1 ?				\
Index: linux-2.6.33-mmotm-100302-1838/arch/ia64/Kconfig
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/arch/ia64/Kconfig
+++ linux-2.6.33-mmotm-100302-1838/arch/ia64/Kconfig
@@ -498,6 +498,10 @@ config HAVE_ARCH_NODEDATA_EXTENSION
 	def_bool y
 	depends on NUMA
 
+config USE_PERCPU_NUMA_NODE_ID
+	def_bool y
+	depends on NUMA
+
 config ARCH_PROC_KCORE_TEXT
 	def_bool y
 	depends on PROC_KCORE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
