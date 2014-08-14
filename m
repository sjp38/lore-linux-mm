Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id A6ED56B0037
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 20:17:34 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id uy5so402575obc.11
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 17:17:34 -0700 (PDT)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id pg10si4844800oeb.31.2014.08.13.17.17.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 17:17:34 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 13 Aug 2014 20:17:33 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 26C1EC90052
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 20:17:22 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s7E0HToU7406002
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 00:17:29 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7E0HSXq006051
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 20:17:29 -0400
Date: Wed, 13 Aug 2014 17:17:23 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [RFC PATCH 4/4] powerpc: reorder per-cpu NUMA information's
 initialization
Message-ID: <20140814001723.GM11121@linux.vnet.ibm.com>
References: <20140814001301.GI11121@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140814001301.GI11121@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

There is an issue currently where NUMA information is used on powerpc
(and possibly ia64) before it has been read from the device-tree, which
leads to large slab consumption with CONFIG_SLUB and memoryless nodes.

NUMA powerpc non-boot CPU's cpu_to_node/cpu_to_mem is only accurate
after start_secondary(), similar to ia64, which is invoked via
smp_init().

Commit 6ee0578b4daae ("workqueue: mark init_workqueues() as
early_initcall()") made init_workqueues() be invoked via
do_pre_smp_initcalls(), which is obviously before the secondary
processors are online.

Additionally, the following commits changed init_workqueues() to use
cpu_to_node to determine the node to use for kthread_create_on_node:

bce903809ab3f ("workqueue: add wq_numa_tbl_len and
wq_numa_possible_cpumask[]")
f3f90ad469342 ("workqueue: determine NUMA node of workers accourding to
the allowed cpumask")

Therefore, when init_workqueues() runs, it sees all CPUs as being on
Node 0. On LPARs or KVM guests where Node 0 is memoryless, this leads to
a high number of slab deactivations
(http://www.spinics.net/lists/linux-mm/msg67489.html).

While testing memoryless nodes on PowerKVM guests with a fix to the
workqueue logic to use cpu_to_mem() instead of cpu_to_node(), with a
guest topology:

    available: 2 nodes (0-1)
    node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 2
    node 0 size: 0 MB
    node 0 free: 0 MB
    node 1 cpus: 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70
    node 1 size: 16336 MB
    node 1 free: 15329 MB
    node distances:
    node   0   1
      0:  10  40
      1:  40  10

the slab consumption decreases from:

    Slab:             932416 kB
    SUnreclaim:       902336 kB

to

    Slab:             395264 kB
    SUnreclaim:       359424 kB

And we see a corresponding increase in the slab efficiency from:

    slab                                   mem     objs    slabs
                                          used   active   active
    ------------------------------------------------------------
    kmalloc-16384                       337 MB   11.28%  100.00%
    task_struct                         288 MB    9.93%  100.00%

to:

    slab                                   mem     objs    slabs
                                          used   active   active
    ------------------------------------------------------------
    kmalloc-16384                        37 MB  100.00%  100.00%
    task_struct                          31 MB  100.00%  100.00%

Powerpc didn't support memoryless nodes until recently (64bb80d87f01
"powerpc/numa: Enable CONFIG_HAVE_MEMORYLESS_NODES" and 8c272261194d
"powerpc/numa: Enable USE_PERCPU_NUMA_NODE_ID"). Those commits also
helped improve memory consumption with these kind of environments.

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

---
Ben & others, one area I'm still unsure of is if calling the NUMA
callback for all CPUs is desired. I don't know how else to get the NUMA
topology into the array easily, but I didn't test in an environment with
hotpluggable CPUs, so I'm not sure if it will lead to errors there (are
there device-tree entries for the topology of CPUs that will be plugged
in? I assume not, actually, so maybe we should keep the logic in
start_secondary so that those CPUs that are hotplugged later get the
right topology data?

diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
index 1007fb802e6b..1fc8984f272e 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -376,6 +376,12 @@ void __init smp_prepare_cpus(unsigned int max_cpus)
 					GFP_KERNEL, cpu_to_node(cpu));
 		zalloc_cpumask_var_node(&per_cpu(cpu_core_map, cpu),
 					GFP_KERNEL, cpu_to_node(cpu));
+		/*
+		 * numa_node_id() works after this.
+		 */
+		set_cpu_numa_node(cpu, numa_cpu_lookup_table[cpu]);
+		set_cpu_numa_mem(cpu,
+				 local_memory_node(numa_cpu_lookup_table[cpu]));
 	}
 
 	cpumask_set_cpu(boot_cpuid, cpu_sibling_mask(boot_cpuid));
@@ -723,12 +729,6 @@ void start_secondary(void *unused)
 	}
 	traverse_core_siblings(cpu, true);
 
-	/*
-	 * numa_node_id() works after this.
-	 */
-	set_numa_node(numa_cpu_lookup_table[cpu]);
-	set_numa_mem(local_memory_node(numa_cpu_lookup_table[cpu]));
-
 	smp_wmb();
 	notify_cpu_starting(cpu);
 	set_cpu_online(cpu, true);
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index d3e9a78eaed3..32341e16b8ce 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -1049,7 +1049,7 @@ static void __init mark_reserved_regions_for_nid(int nid)
 
 void __init do_init_bootmem(void)
 {
-	int nid;
+	int nid, cpu;
 
 	min_low_pfn = 0;
 	max_low_pfn = memblock_end_of_DRAM() >> PAGE_SHIFT;
@@ -1122,8 +1122,15 @@ void __init do_init_bootmem(void)
 
 	reset_numa_cpu_lookup_table();
 	register_cpu_notifier(&ppc64_numa_nb);
-	cpu_numa_callback(&ppc64_numa_nb, CPU_UP_PREPARE,
-			  (void *)(unsigned long)boot_cpuid);
+	/*
+	 * We need the numa_cpu_lookup_table to be accurate for all
+	 * CPUs, even before we online them, so that we can use
+	 * cpu_to_{node,mem} early in boot, cf. smp_prepare_cpus().
+	 */
+	for_each_possible_cpu(cpu) {
+		cpu_numa_callback(&ppc64_numa_nb, CPU_UP_PREPARE,
+				  (void *)(unsigned long)boot_cpuid);
+	}
 }
 
 void __init paging_init(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
