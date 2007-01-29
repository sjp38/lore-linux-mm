Date: Mon, 29 Jan 2007 14:39:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH]Convert highest_possible_processor_id to nr_cpu_ids
Message-ID: <Pine.LNX.4.64.0701291437590.1067@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This follows up on the patch to create nr_node_ids... Patch against 
2.6.20-rc6 + Andrew's fix for mistakenly replacing  
highest_possible_processor_id() with nr_node_ids.





We frequently need the maximum number of possible processors in order
to allocate arrays for all processors. So far this was done using
highest_possible_processor_id(). However, we do need the number of
processors not the highest id. Moreover the number was so far
dynamically calculated on each invokation. The number of possible
processors does not change when the system is running. We can
therefore calculate that number once.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc6-mm1/include/linux/cpumask.h
===================================================================
--- linux-2.6.20-rc6-mm1.orig/include/linux/cpumask.h	2007-01-29 14:11:44.000000000 -0600
+++ linux-2.6.20-rc6-mm1/include/linux/cpumask.h	2007-01-29 14:24:21.111873045 -0600
@@ -398,11 +398,11 @@ extern cpumask_t cpu_present_map;
 #endif
 
 #ifdef CONFIG_SMP
-int highest_possible_processor_id(void);
+extern int nr_cpu_ids;
 #define any_online_cpu(mask) __any_online_cpu(&(mask))
 int __any_online_cpu(const cpumask_t *mask);
 #else
-#define highest_possible_processor_id()	0
+#define nr_cpu_ids			0
 #define any_online_cpu(mask)		0
 #endif
 
Index: linux-2.6.20-rc6-mm1/lib/cpumask.c
===================================================================
--- linux-2.6.20-rc6-mm1.orig/lib/cpumask.c	2007-01-29 14:11:44.000000000 -0600
+++ linux-2.6.20-rc6-mm1/lib/cpumask.c	2007-01-29 14:24:21.124569478 -0600
@@ -15,22 +15,8 @@ int __next_cpu(int n, const cpumask_t *s
 }
 EXPORT_SYMBOL(__next_cpu);
 
-/*
- * Find the highest possible smp_processor_id()
- *
- * Note: if we're prepared to assume that cpu_possible_map never changes
- * (reasonable) then this function should cache its return value.
- */
-int highest_possible_processor_id(void)
-{
-	unsigned int cpu;
-	unsigned highest = 0;
-
-	for_each_cpu_mask(cpu, cpu_possible_map)
-		highest = cpu;
-	return highest;
-}
-EXPORT_SYMBOL(highest_possible_processor_id);
+int nr_cpu_ids;
+EXPORT_SYMBOL(nr_cpu_ids);
 
 int __any_online_cpu(const cpumask_t *mask)
 {
Index: linux-2.6.20-rc6-mm1/net/bridge/netfilter/ebtables.c
===================================================================
--- linux-2.6.20-rc6-mm1.orig/net/bridge/netfilter/ebtables.c	2007-01-29 14:18:38.000000000 -0600
+++ linux-2.6.20-rc6-mm1/net/bridge/netfilter/ebtables.c	2007-01-29 14:24:21.149962345 -0600
@@ -833,8 +833,7 @@ static int translate_table(char *name, s
 		/* this will get free'd in do_replace()/ebt_register_table()
 		   if an error occurs */
 		newinfo->chainstack =
-			vmalloc((highest_possible_processor_id()+1)
-				   	* sizeof(*(newinfo->chainstack)));
+			vmalloc(nr_cpu_ids * sizeof(*(newinfo->chainstack)));
 		if (!newinfo->chainstack)
 			return -ENOMEM;
 		for_each_possible_cpu(i) {
@@ -947,8 +946,7 @@ static int do_replace(void __user *user,
 	if (tmp.num_counters >= INT_MAX / sizeof(struct ebt_counter))
 		return -ENOMEM;
 
-	countersize = COUNTER_OFFSET(tmp.nentries) * 
-					(highest_possible_processor_id()+1);
+	countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
 	newinfo = vmalloc(sizeof(*newinfo) + countersize);
 	if (!newinfo)
 		return -ENOMEM;
@@ -1168,8 +1166,7 @@ int ebt_register_table(struct ebt_table 
 		return -EINVAL;
 	}
 
-	countersize = COUNTER_OFFSET(repl->nentries) *
-					(highest_possible_processor_id()+1);
+	countersize = COUNTER_OFFSET(repl->nentries) * nr_cpu_ids;
 	newinfo = vmalloc(sizeof(*newinfo) + countersize);
 	ret = -ENOMEM;
 	if (!newinfo)
Index: linux-2.6.20-rc6-mm1/net/sunrpc/svc.c
===================================================================
--- linux-2.6.20-rc6-mm1.orig/net/sunrpc/svc.c	2007-01-29 14:24:19.447663635 -0600
+++ linux-2.6.20-rc6-mm1/net/sunrpc/svc.c	2007-01-29 14:24:21.181215104 -0600
@@ -115,7 +115,7 @@ fail:
 static int
 svc_pool_map_init_percpu(struct svc_pool_map *m)
 {
-	unsigned int maxpools = highest_possible_processor_id()+1;
+	unsigned int maxpools = nr_cpu_ids;
 	unsigned int pidx = 0;
 	unsigned int cpu;
 	int err;
Index: linux-2.6.20-rc6-mm1/init/main.c
===================================================================
--- linux-2.6.20-rc6-mm1.orig/init/main.c	2007-01-29 14:18:35.000000000 -0600
+++ linux-2.6.20-rc6-mm1/init/main.c	2007-01-29 14:24:21.196841483 -0600
@@ -386,14 +386,19 @@ static void __init setup_per_cpu_areas(v
 /* Called by boot processor to activate the rest. */
 static void __init smp_init(void)
 {
-	unsigned int i;
+	unsigned int cpu;
+	unsigned highest = 0;
+
+	for_each_cpu_mask(cpu, cpu_possible_map)
+		highest = cpu;
+	nr_cpu_ids = highest + 1;
 
 	/* FIXME: This should be done in userspace --RR */
-	for_each_present_cpu(i) {
+	for_each_present_cpu(cpu) {
 		if (num_online_cpus() >= max_cpus)
 			break;
-		if (!cpu_online(i))
-			cpu_up(i);
+		if (!cpu_online(cpu))
+			cpu_up(cpu);
 	}
 
 	/* Any cleanup work */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
