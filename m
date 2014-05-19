Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2246B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 14:14:55 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id z60so9499407qgd.32
        for <linux-mm@kvack.org>; Mon, 19 May 2014 11:14:54 -0700 (PDT)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id e7si9157596qai.19.2014.05.19.11.14.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 19 May 2014 11:14:42 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 19 May 2014 14:14:41 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 985AA6E804A
	for <linux-mm@kvack.org>; Mon, 19 May 2014 14:14:30 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4JIEct856950978
	for <linux-mm@kvack.org>; Mon, 19 May 2014 18:14:38 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4JIEaDE013927
	for <linux-mm@kvack.org>; Mon, 19 May 2014 14:14:36 -0400
Date: Mon, 19 May 2014 11:14:23 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 1/2] powerpc: numa: enable USE_PERCPU_NUMA_NODE_ID
Message-ID: <20140519181423.GL8941@linux.vnet.ibm.com>
References: <20140516233945.GI8941@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140516233945.GI8941@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, Anton Blanchard <anton@samba.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Ben Herrenschmidt <benh@kernel.crashing.org>

Hi Andrew,

I found one issue with my patch, fixed below...

On 16.05.2014 [16:39:45 -0700], Nishanth Aravamudan wrote:
> Based off 3bccd996 for ia64, convert powerpc to use the generic per-CPU
> topology tracking, specifically:
>     
> 	initialize per cpu numa_node entry in start_secondary
>     	remove the powerpc cpu_to_node()
>     	define CONFIG_USE_PERCPU_NUMA_NODE_ID if NUMA
>     
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

<snip>

> diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
> index e2a4232..b95be24 100644
> --- a/arch/powerpc/kernel/smp.c
> +++ b/arch/powerpc/kernel/smp.c
> @@ -750,6 +750,11 @@ void start_secondary(void *unused)
>  	}
>  	traverse_core_siblings(cpu, true);
>  
> +	/*
> +	 * numa_node_id() works after this.
> +	 */
> +	set_numa_node(numa_cpu_lookup_table[cpu]);
> +

Similar change is needed for the boot CPU. Update patch:


powerpc: numa: enable USE_PERCPU_NUMA_NODE_ID
    
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
index e2a4232..d7252ad 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -390,6 +390,7 @@ void smp_prepare_boot_cpu(void)
 #ifdef CONFIG_PPC64
 	paca[boot_cpuid].__current = current;
 #endif
+	set_numa_node(numa_cpu_lookup_table[boot_cpuid]);
 	current_set[boot_cpuid] = task_thread_info(current);
 }
 
@@ -750,6 +751,11 @@ void start_secondary(void *unused)
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
