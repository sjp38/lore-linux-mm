Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1986B0214
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:30:59 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 15 Apr 2010 13:30:24 -0400
Message-Id: <20100415173024.8801.36840.sendpatchset@localhost.localdomain>
In-Reply-To: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
Subject: [PATCH 5/8] numa: ia64: support numa_mem_id() for memoryless nodes
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Against:  2.6.34-rc3-mmotm-100405-1609

IA64: Support memoryless nodes

Enable 'HAVE_MEMORYLESS_NODES' by default when NUMA configured
on ia64.  Initialize percpu 'numa_mem' variable when starting
secondary cpus.  Generic initialization will handle the boot
cpu.

Nothing uses 'numa_mem_id()' yet.  Subsequent patch with modify
slab to use this.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

---

New in V2

V3, V4:  no change

 arch/ia64/Kconfig          |    4 ++++
 arch/ia64/kernel/smpboot.c |    1 +
 2 files changed, 5 insertions(+)

Index: linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/Kconfig
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/arch/ia64/Kconfig	2010-04-07 10:10:27.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/Kconfig	2010-04-07 10:10:30.000000000 -0400
@@ -501,6 +501,10 @@ config USE_PERCPU_NUMA_NODE_ID
 	def_bool y
 	depends on NUMA
 
+config HAVE_MEMORYLESS_NODES
+	def_bool y
+	depends on NUMA
+
 config ARCH_PROC_KCORE_TEXT
 	def_bool y
 	depends on PROC_KCORE
Index: linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/kernel/smpboot.c
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/arch/ia64/kernel/smpboot.c	2010-04-07 10:10:27.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/arch/ia64/kernel/smpboot.c	2010-04-07 10:10:30.000000000 -0400
@@ -394,6 +394,7 @@ smp_callin (void)
 	 * numa_node_id() works after this.
 	 */
 	set_numa_node(cpu_to_node_map[cpuid]);
+	set_numa_mem(local_memory_node(cpu_to_node_map[cpuid]));
 
 	ipi_call_lock_irq();
 	spin_lock(&vector_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
