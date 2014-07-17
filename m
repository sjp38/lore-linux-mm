Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 15CFD6B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 19:15:24 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id i13so2462862qae.34
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 16:15:23 -0700 (PDT)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id o11si7566766qay.79.2014.07.17.16.15.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 16:15:23 -0700 (PDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 17 Jul 2014 19:15:23 -0400
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id CC4B1C90041
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 19:15:12 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6HNFJS77602676
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 23:15:19 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6HNFITM023295
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 19:15:19 -0400
Date: Thu, 17 Jul 2014 16:15:12 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [RFC 2/2] powerpc: reorder per-cpu NUMA information's initialization
Message-ID: <20140717231512.GC32660@linux.vnet.ibm.com>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
 <20140717230958.GB32660@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140717230958.GB32660@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

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

Fix this by initializing the powerpc-specific CPU<->node/local memory
node mapping as early as possible, which on powerpc is
do_init_bootmem(). Currently that function initializes the mapping for
the boot CPU, but we extend it to setup the mapping for all possible
CPUs. Then, in smp_prepare_cpus(), we can correspondingly set the
per-cpu values for all possible CPUs. That ensures that before the
early_initcalls run (and really as early as possible), the per-cpu NUMA
mapping is accurate.

While testing memoryless nodes on PowerKVM guests with a fix to the
workqueue logic to use cpu_to_mem() instead of cpu_to_node(), with a
guest topology of:

available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49
node 0 size: 0 MB
node 0 free: 0 MB
node 1 cpus: 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
node 1 size: 16336 MB
node 1 free: 15329 MB
node distances:
node   0   1
  0:  10  40
  1:  40  10

the slab consumption decreases from

Slab:             932416 kB
SUnreclaim:       902336 kB

to

Slab:             395264 kB
SUnreclaim:       359424 kB

And we a corresponding increase in the slab efficiency from

slab                                   mem     objs    slabs
                                      used   active   active
------------------------------------------------------------
kmalloc-16384                       337 MB   11.28%  100.00%
task_struct                         288 MB    9.93%  100.00%

to

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

diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
index 51a3ff7..91ff531 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -376,6 +376,11 @@ void __init smp_prepare_cpus(unsigned int max_cpus)
 					GFP_KERNEL, cpu_to_node(cpu));
 		zalloc_cpumask_var_node(&per_cpu(cpu_core_map, cpu),
 					GFP_KERNEL, cpu_to_node(cpu));
+		/*
+		 * numa_node_id() works after this.
+		 */
+		set_cpu_numa_node(cpu, numa_cpu_lookup_table[cpu]);
+		set_cpu_numa_mem(cpu, local_memory_node(numa_cpu_lookup_table[cpu]));
 	}
 
 	cpumask_set_cpu(boot_cpuid, cpu_sibling_mask(boot_cpuid));
@@ -723,12 +728,6 @@ void start_secondary(void *unused)
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
index 3b181b2..b1f0b86 100644
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
+	 * We need the numa_cpu_lookup_table to be accurate for all CPUs,
+	 * even before we online them, so that we can use cpu_to_{node,mem}
+	 * early in boot, cf. smp_prepare_cpus().
+	 */
+	for_each_possible_cpu(cpu) {
+		cpu_numa_callback(&ppc64_numa_nb, CPU_UP_PREPARE,
+				  (void *)(unsigned long)cpu);
+	}
 }
 
 void __init paging_init(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
