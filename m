Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B13DB6B007B
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:13:11 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 13 Nov 2009 16:18:17 -0500
Message-Id: <20091113211817.15074.72532.sendpatchset@localhost.localdomain>
In-Reply-To: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
References: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 5/6] numa: ia64: support numa_mem_id() for memoryless nodes
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC numa: ia64:  support memoryless nodes

Against: 2.6.32-rc5-mmotm-091101-1001

Enable 'HAVE_MEMORYLESS_NODES' by default when NUMA configured
on ia64.  Initialize percpu 'numa_mem' variable when starting
secondary cpus.  Generic initialization will handle the boot
cpu.

Nothing uses 'numa_mem_id()' yet.  Subsequent patch with modify
slab to use this.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

New in V2

---

 arch/ia64/Kconfig          |    4 ++++
 arch/ia64/kernel/smpboot.c |    1 +
 2 files changed, 5 insertions(+)

Index: linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/Kconfig
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/arch/ia64/Kconfig	2009-11-11 12:09:13.000000000 -0500
+++ linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/Kconfig	2009-11-11 12:16:56.000000000 -0500
@@ -499,6 +499,10 @@ config USE_PERCPU_NUMA_NODE_ID
 	def_bool y
 	depends on NUMA
 
+config HAVE_MEMORYLESS_NODES
+	def_bool y
+	depends on NUMA
+
 config ARCH_PROC_KCORE_TEXT
 	def_bool y
 	depends on PROC_KCORE
Index: linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/kernel/smpboot.c
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/arch/ia64/kernel/smpboot.c	2009-11-11 12:05:42.000000000 -0500
+++ linux-2.6.32-rc5-mmotm-091101-1001/arch/ia64/kernel/smpboot.c	2009-11-11 12:16:56.000000000 -0500
@@ -395,6 +395,7 @@ smp_callin (void)
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
