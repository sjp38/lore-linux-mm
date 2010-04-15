Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB6E6B0210
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:30:44 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 15 Apr 2010 13:30:09 -0400
Message-Id: <20100415173009.8801.67345.sendpatchset@localhost.localdomain>
In-Reply-To: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
Subject: [PATCH 3/8] numa:  ia64:  use generic percpu var numa_node_id() implementation
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Against:  2.6.34-rc3-mmotm-100405-1609

ia64:  Use generic percpu implementation of numa_node_id()
   + intialize per cpu 'numa_node'
   + remove ia64 cpu_to_node() macro;  use generic
   + define CONFIG_USE_PERCPU_NUMA_NODE_ID when NUMA configured

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

---

New in V2

V3, V4: no change

 arch/ia64/Kconfig                |    4 ++++
 arch/ia64/include/asm/topology.h |    5 -----
 arch/ia64/kernel/smpboot.c       |    6 ++++++
 3 files changed, 10 insertions(+), 5 deletions(-)

Index: linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/kernel/smpboot.c
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/arch/ia64/kernel/smpboot.c	2010-04-07 10:03:38.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/kernel/smpboot.c	2010-04-07 10:10:27.000000000 -0400
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
Index: linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/include/asm/topology.h
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/arch/ia64/include/asm/topology.h	2010-04-07 09:49:13.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/include/asm/topology.h	2010-04-07 10:10:27.000000000 -0400
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
Index: linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/Kconfig
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/arch/ia64/Kconfig	2010-04-07 10:04:03.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/Kconfig	2010-04-07 10:10:27.000000000 -0400
@@ -497,6 +497,10 @@ config HAVE_ARCH_NODEDATA_EXTENSION
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
