Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 57F166B0035
	for <linux-mm@kvack.org>; Fri, 16 May 2014 19:40:48 -0400 (EDT)
Received: by mail-yk0-f170.google.com with SMTP id 10so2742228ykt.15
        for <linux-mm@kvack.org>; Fri, 16 May 2014 16:40:48 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id w49si13327852yhd.198.2014.05.16.16.40.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 May 2014 16:40:47 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 16 May 2014 17:40:46 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2843519D8039
	for <linux-mm@kvack.org>; Fri, 16 May 2014 17:40:37 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4GNdSSM2752944
	for <linux-mm@kvack.org>; Sat, 17 May 2014 01:39:36 +0200
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4GNeARs020153
	for <linux-mm@kvack.org>; Fri, 16 May 2014 17:40:11 -0600
Date: Fri, 16 May 2014 16:39:45 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH] powerpc: numa: enable USE_PERCPU_NUMA_NODE_ID
Message-ID: <20140516233945.GI8941@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, Anton Blanchard <anton@samba.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Ben Herrenschmidt <benh@kernel.crashing.org>

Based off 3bccd996 for ia64, convert powerpc to use the generic per-CPU
topology tracking, specifically:
    
	initialize per cpu numa_node entry in start_secondary
    	remove the powerpc cpu_to_node()
    	define CONFIG_USE_PERCPU_NUMA_NODE_ID if NUMA
    
Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index e099899..9125964 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -453,6 +453,10 @@ config NODES_SHIFT
 	default "4"
 	depends on NEED_MULTIPLE_NODES
 
+config USE_PERCPU_NUMA_NODE_ID
+	def_bool y
+	depends on NUMA
+
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 	depends on PPC64
diff --git a/arch/powerpc/include/asm/topology.h b/arch/powerpc/include/asm/topology.h
index c920215..5ecf7ea 100644
--- a/arch/powerpc/include/asm/topology.h
+++ b/arch/powerpc/include/asm/topology.h
@@ -20,19 +20,6 @@ struct device_node;
 
 #include <asm/mmzone.h>
 
-static inline int cpu_to_node(int cpu)
-{
-	int nid;
-
-	nid = numa_cpu_lookup_table[cpu];
-
-	/*
-	 * During early boot, the numa-cpu lookup table might not have been
-	 * setup for all CPUs yet. In such cases, default to node 0.
-	 */
-	return (nid < 0) ? 0 : nid;
-}
-
 #define parent_node(node)	(node)
 
 #define cpumask_of_node(node) ((node) == -1 ?				\
diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
index e2a4232..b95be24 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -750,6 +750,11 @@ void start_secondary(void *unused)
 	}
 	traverse_core_siblings(cpu, true);
 
+	/*
+	 * numa_node_id() works after this.
+	 */
+	set_numa_node(numa_cpu_lookup_table[cpu]);
+
 	smp_wmb();
 	notify_cpu_starting(cpu);
 	set_cpu_online(cpu, true);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
