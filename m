Date: Thu, 1 Mar 2007 13:55:04 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Safer nr_node_ids and nr_node_ids determination and initial
 values
Message-ID: <Pine.LNX.4.64.0703011352450.28125@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The nr_cpu_ids value is currently only calculated in smp_init. However, it
may be needed before (SLUB needs it on kmem_cache_init!) and other kernel 
components may also want to allocate dynamically sized per cpu array
before smp_init. So move the determination of possible cpus into 
sched_init() where we already loop over all possible cpus early in boot.

Also initialize both nr_node_ids and nr_cpu_ids with the highest value
they could take. If we have accidental users before these values are
determined then the current valud of 0 may cause too small per cpu
and per node arrays to be allocated. If it is set to the maximum possible
then we only waste some memory for early boot users.

Signed-off-by: Christoph Lameter <clameter@sgi.coim>

Index: linux-2.6.21-rc2/lib/cpumask.c
===================================================================
--- linux-2.6.21-rc2.orig/lib/cpumask.c	2007-03-01 13:34:07.000000000 -0800
+++ linux-2.6.21-rc2/lib/cpumask.c	2007-03-01 13:50:20.000000000 -0800
@@ -15,9 +15,6 @@ int __next_cpu(int n, const cpumask_t *s
 }
 EXPORT_SYMBOL(__next_cpu);
 
-int nr_cpu_ids;
-EXPORT_SYMBOL(nr_cpu_ids);
-
 int __any_online_cpu(const cpumask_t *mask)
 {
 	int cpu;
Index: linux-2.6.21-rc2/mm/page_alloc.c
===================================================================
--- linux-2.6.21-rc2.orig/mm/page_alloc.c	2007-03-01 13:34:07.000000000 -0800
+++ linux-2.6.21-rc2/mm/page_alloc.c	2007-03-01 13:35:13.000000000 -0800
@@ -665,7 +665,7 @@ static int rmqueue_bulk(struct zone *zon
 }
 
 #if MAX_NUMNODES > 1
-int nr_node_ids __read_mostly;
+int nr_node_ids __read_mostly = MAX_NUMNODES;
 EXPORT_SYMBOL(nr_node_ids);
 
 /*
Index: linux-2.6.21-rc2/init/main.c
===================================================================
--- linux-2.6.21-rc2.orig/init/main.c	2007-03-01 13:34:07.000000000 -0800
+++ linux-2.6.21-rc2/init/main.c	2007-03-01 13:35:13.000000000 -0800
@@ -388,11 +388,6 @@ static void __init setup_per_cpu_areas(v
 static void __init smp_init(void)
 {
 	unsigned int cpu;
-	unsigned highest = 0;
-
-	for_each_cpu_mask(cpu, cpu_possible_map)
-		highest = cpu;
-	nr_cpu_ids = highest + 1;
 
 	/* FIXME: This should be done in userspace --RR */
 	for_each_present_cpu(cpu) {
Index: linux-2.6.21-rc2/kernel/sched.c
===================================================================
--- linux-2.6.21-rc2.orig/kernel/sched.c	2007-03-01 13:34:07.000000000 -0800
+++ linux-2.6.21-rc2/kernel/sched.c	2007-03-01 13:50:20.000000000 -0800
@@ -6910,9 +6910,14 @@ int in_sched_functions(unsigned long add
 		&& addr < (unsigned long)__sched_text_end);
 }
 
+/* Number of possible processor ids */
+int nr_cpu_ids = NR_CPUS;
+EXPORT_SYMBOL(nr_cpu_ids);
+
 void __init sched_init(void)
 {
 	int i, j, k;
+	int highest_cpu = 0;
 
 	for_each_possible_cpu(i) {
 		struct prio_array *array;
@@ -6947,7 +6952,9 @@ void __init sched_init(void)
 			// delimiter for bitsearch
 			__set_bit(MAX_PRIO, array->bitmap);
 		}
+		highest_cpu = i;
 	}
+	nr_cpu_ids = highest_cpu + 1;
 
 	set_load_weight(&init_task);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
