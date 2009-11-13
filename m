Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6E86B0078
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:12:59 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 13 Nov 2009 16:18:04 -0500
Message-Id: <20091113211804.15074.12322.sendpatchset@localhost.localdomain>
In-Reply-To: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
References: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 3/6] numa:  ia64:  use generic percpu var numa_node_id() implementation
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.32-rc5-mmotm-091101-1001

ia64:  Use generic percpu implementation of numa_node_id()
   + intialize per cpu 'numa_node'
   + remove ia64 cpu_to_node() macro;  use generic
   + define CONFIG_USE_PERCPU_NUMA_NODE_ID when NUMA configured

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

New in V2

---

 arch/ia64/Kconfig                |    4 ++++
 arch/ia64/include/asm/topology.h |    5 -----
 arch/ia64/kernel/smpboot.c       |    6 ++++++
 3 files changed, 10 insertions(+), 5 deletions(-)

Index: linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/kernel/smpboot.c
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/arch/ia64/kernel/smpboot.c	2009-11-11 11:43:47.000000000 -0500
+++ linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/kernel/smpboot.c	2009-11-11 12:05:42.000000000 -0500
@@ -391,6 +391,11 @@ smp_callin (void)
 
 	fix_b0_for_bsp();
 
+	/*
+	 * numa_node_id() works after this.
+	 */
+	set_numa_node(cpu_to_node_map[cpuid]);
+
 	ipi_call_lock_irq();
 	spin_lock(&vector_lock);
 	/* Setup the per cpu irq handling data structures */
@@ -637,6 +642,7 @@ void __devinit smp_prepare_boot_cpu(void
 {
 	cpu_set(smp_processor_id(), cpu_online_map);
 	cpu_set(smp_processor_id(), cpu_callin_map);
+	set_numa_node(cpu_to_node_map[smp_processor_id()]);
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
 	paravirt_post_smp_prepare_boot_cpu();
 }
Index: linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/include/asm/topology.h
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/arch/ia64/include/asm/topology.h	2009-11-11 11:43:47.000000000 -0500
+++ linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/include/asm/topology.h	2009-11-11 12:05:42.000000000 -0500
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
 #define cpumask_of_node(node) (&node_to_cpu_mask[node])
Index: linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/Kconfig
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/arch/ia64/Kconfig	2009-11-02 15:51:36.000000000 -0500
+++ linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/Kconfig	2009-11-11 12:09:13.000000000 -0500
@@ -495,6 +495,10 @@ config HAVE_ARCH_NODEDATA_EXTENSION
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
