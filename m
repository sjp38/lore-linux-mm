Date: Sun, 10 Jul 2005 18:58:54 -0700 (PDT)
From: Paul Jackson <pj@sgi.com>
Message-Id: <20050711015854.23183.17359.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20050711015835.23183.40213.sendpatchset@tomahawk.engr.sgi.com>
References: <20050711015835.23183.40213.sendpatchset@tomahawk.engr.sgi.com>
Subject: [PATCH 3/4] cpusets formalize intermediate GFP_KERNEL containment
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dinakar Guniguntala <dino@in.ibm.com>, Simon Derr <Simon.Derr@bull.net>, Erich Focht <efocht@hpce.nec.com>
Cc: linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

This patch depends on the previous patches cpuset_gfp_hardwall_flag
and cpuset_mm_alloc_oom_fixes.

This patch makes use of the previously underutilized cpuset flag
'mem_exclusive' to provide what amounts to another layer of
memory placement resolution.  With this patch, there are now the
following four layers of memory placement available:

 1) The whole system (interrupt and GFP_ATOMIC allocations can use this),
 2) The nearest enclosing mem_exclusive cpuset (GFP_KERNEL allocations can use),
 3) The current tasks cpuset (GFP_USER allocations constrained to here), and
 4) Specific node placement, using mbind and set_mempolicy.

These nest - each layer is a subset (same or within) of the previous.

Layer (2) is new with this patch. The cpuset_zone_allowed() call that
is used to check whether a zone's node is in a tasks mems_allowed
(which is constrained by the tasks cpuset) is extended to take
a gfp_mask argument, and its logic is extended, in the case that
__GFP_HARDWALL is not set in the flag bits, to look up the cpuset
hierarchy for the nearest enclosing mem_exclusive cpuset, to determine
if the zone's node is allowed in that cpuset.

The definition of GFP_USER, which used to be identical to GFP_KERNEL,
is changed to also set the __GFP_HARDWALL bit, in the previous
cpuset_gfp_hardwall_flag patch.

GFP_ATOMIC and GFP_KERNEL allocations will stay within the current
tasks cpuset, so long as any node therein is not too tight on memory,
but will escape to the larger layer, if need be.

The intended use is to allow something like a batch manager to
handle several jobs, each job in its own cpuset, but using common
kernel memory for caches and such.  Swapper and oom_kill activity is
also constrained to Layer (2).  A task in or below one mem_exclusive
cpuset should not cause swapping on nodes in another non-overlapping
mem_exclusive cpuset, nor provoke oom_killing of a task in another
such cpuset.  Heavy use of kernel memory for i/o caching and such
by one job should not impact the memory available to jobs in other
non-overlapping mem_exclusive cpusets.

This patch enables providing hardwall, inescapable cpusets for
memory allocations of each job, while sharing kernel memory
allocations between several jobs, in an enclosing mem_exclusive
cpuset.

Like Dinakar's patch earlier to enable administering sched domains
using the cpu_exclusive flag, this patch also provides a useful
meaning to a cpuset flag that had previously done nothing much 
useful other than restrict what cpuset configurations were allowed.

Signed-off-by: Paul Jackson <pj@sgi.com>

Index: linux-2.6-mem_exclusive/Documentation/cpusets.txt
===================================================================
--- linux-2.6-mem_exclusive.orig/Documentation/cpusets.txt	2005-07-02 17:40:54.000000000 -0700
+++ linux-2.6-mem_exclusive/Documentation/cpusets.txt	2005-07-02 17:43:15.000000000 -0700
@@ -51,6 +51,7 @@ mems_allowed vector.
 
 If a cpuset is cpu or mem exclusive, no other cpuset, other than a direct
 ancestor or descendent, may share any of the same CPUs or Memory Nodes.
+
 A cpuset that is cpu exclusive has a sched domain associated with it.
 The sched domain consists of all cpus in the current cpuset that are not
 part of any exclusive child cpusets.
@@ -60,6 +61,18 @@ all of the cpus in the system. This remo
 load balancing code trying to pull tasks outside of the cpu exclusive
 cpuset only to be prevented by the tasks' cpus_allowed mask.
 
+A cpuset that is mem_exclusive restricts kernel allocations for
+page, buffer and other data commonly shared by the kernel across
+multiple users.  All cpusets, whether mem_exclusive or not, restrict
+allocations of memory for user space.  This enables configuring a
+system so that several independent jobs can share common kernel
+data, such as file system pages, while isolating each jobs user
+allocation in its own cpuset.  To do this, construct a large
+mem_exclusive cpuset to hold all the jobs, and construct child,
+non-mem_exclusive cpusets for each individual job.  Only a small
+amount of typical kernel memory, such as requests from interrupt
+handlers, is allowed to be taken outside even a mem_exclusive cpuset.
+
 User level code may create and destroy cpusets by name in the cpuset
 virtual file system, manage the attributes and permissions of these
 cpusets and which CPUs and Memory Nodes are assigned to each cpuset,
Index: linux-2.6-mem_exclusive/include/linux/cpuset.h
===================================================================
--- linux-2.6-mem_exclusive.orig/include/linux/cpuset.h	2005-07-02 17:40:04.000000000 -0700
+++ linux-2.6-mem_exclusive/include/linux/cpuset.h	2005-07-02 17:43:15.000000000 -0700
@@ -23,7 +23,7 @@ void cpuset_init_current_mems_allowed(vo
 void cpuset_update_current_mems_allowed(void);
 void cpuset_restrict_to_mems_allowed(unsigned long *nodes);
 int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl);
-int cpuset_zone_allowed(struct zone *z);
+extern int cpuset_zone_allowed(struct zone *z, unsigned int __nocast gfp_mask);
 extern struct file_operations proc_cpuset_operations;
 extern char *cpuset_task_status_allowed(struct task_struct *task, char *buffer);
 
@@ -48,7 +48,8 @@ static inline int cpuset_zonelist_valid_
 	return 1;
 }
 
-static inline int cpuset_zone_allowed(struct zone *z)
+static inline int cpuset_zone_allowed(struct zone *z,
+					unsigned int __nocast gfp_mask)
 {
 	return 1;
 }
Index: linux-2.6-mem_exclusive/mm/page_alloc.c
===================================================================
--- linux-2.6-mem_exclusive.orig/mm/page_alloc.c	2005-07-02 17:40:04.000000000 -0700
+++ linux-2.6-mem_exclusive/mm/page_alloc.c	2005-07-02 17:43:15.000000000 -0700
@@ -806,11 +806,14 @@ __alloc_pages(unsigned int __nocast gfp_
 	classzone_idx = zone_idx(zones[0]);
 
 restart:
-	/* Go through the zonelist once, looking for a zone with enough free */
+	/*
+	 * Go through the zonelist once, looking for a zone with enough free.
+	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
+	 */
 	for (i = 0; (z = zones[i]) != NULL; i++) {
 		int do_reclaim = should_reclaim_zone(z, gfp_mask);
 
-		if (!cpuset_zone_allowed(z))
+		if (!cpuset_zone_allowed(z, __GFP_HARDWALL))
 			continue;
 
 		/*
@@ -845,6 +848,7 @@ zone_reclaim_retry:
 	 *
 	 * This is the last chance, in general, before the goto nopage.
 	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
+	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
 	for (i = 0; (z = zones[i]) != NULL; i++) {
 		if (!zone_watermark_ok(z, order, z->pages_min,
@@ -852,7 +856,7 @@ zone_reclaim_retry:
 				       gfp_mask & __GFP_HIGH))
 			continue;
 
-		if (wait && !cpuset_zone_allowed(z))
+		if (wait && !cpuset_zone_allowed(z, gfp_mask))
 			continue;
 
 		page = buffered_rmqueue(z, order, gfp_mask);
@@ -867,7 +871,7 @@ zone_reclaim_retry:
 		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
 			/* go through the zonelist yet again, ignoring mins */
 			for (i = 0; (z = zones[i]) != NULL; i++) {
-				if (!cpuset_zone_allowed(z))
+				if (!cpuset_zone_allowed(z, gfp_mask))
 					continue;
 				page = buffered_rmqueue(z, order, gfp_mask);
 				if (page)
@@ -908,7 +912,7 @@ rebalance:
 					       gfp_mask & __GFP_HIGH))
 				continue;
 
-			if (!cpuset_zone_allowed(z))
+			if (!cpuset_zone_allowed(z, gfp_mask))
 				continue;
 
 			page = buffered_rmqueue(z, order, gfp_mask);
@@ -927,7 +931,7 @@ rebalance:
 					       classzone_idx, 0, 0))
 				continue;
 
-			if (!cpuset_zone_allowed(z))
+			if (!cpuset_zone_allowed(z, __GFP_HARDWALL))
 				continue;
 
 			page = buffered_rmqueue(z, order, gfp_mask);
Index: linux-2.6-mem_exclusive/kernel/cpuset.c
===================================================================
--- linux-2.6-mem_exclusive.orig/kernel/cpuset.c	2005-07-02 17:40:04.000000000 -0700
+++ linux-2.6-mem_exclusive/kernel/cpuset.c	2005-07-02 17:43:15.000000000 -0700
@@ -1563,12 +1563,79 @@ int cpuset_zonelist_valid_mems_allowed(s
 }
 
 /*
- * Is 'current' valid, and is zone z allowed in current->mems_allowed?
+ * nearest_exclusive_ancestor() - Returns the nearest mem_exclusive
+ * ancestor to the specified cpuset.  Call while holding cpuset_sem.
+ * If no ancestor is mem_exclusive (an unusual configuration), then
+ * returns the root cpuset.
  */
-int cpuset_zone_allowed(struct zone *z)
+static const struct cpuset *nearest_exclusive_ancestor(const struct cpuset *cs)
 {
-	return in_interrupt() ||
-		node_isset(z->zone_pgdat->node_id, current->mems_allowed);
+	while (!is_mem_exclusive(cs) && cs->parent)
+		cs = cs->parent;
+	return cs;
+}
+
+/**
+ * cpuset_zone_allowed - Can we allocate memory on zone z's memory node?
+ * @z: is this zone on an allowed node?
+ * @gfp_mask: memory allocation flags (we use __GFP_HARDWALL)
+ *
+ * If we're in interrupt, yes, we can always allocate.  If zone
+ * z's node is in our tasks mems_allowed, yes.  If it's not a
+ * __GFP_HARDWALL request and this zone's nodes is in the nearest
+ * mem_exclusive cpuset ancestor to this tasks cpuset, yes.
+ * Otherwise, no.
+ *
+ * GFP_USER allocations are marked with the __GFP_HARDWALL bit,
+ * and do not allow allocations outside the current tasks cpuset.
+ * GFP_KERNEL allocations are not so marked, so can escape to the
+ * nearest mem_exclusive ancestor cpuset.
+ *
+ * Scanning up parent cpusets requires cpuset_sem.  The __alloc_pages()
+ * routine only calls here with __GFP_HARDWALL bit _not_ set if
+ * it's a GFP_KERNEL allocation, and all nodes in the current tasks
+ * mems_allowed came up empty on the first pass over the zonelist.
+ * So only GFP_KERNEL allocations, if all nodes in the cpuset are
+ * short of memory, might require taking the cpuset_sem semaphore.
+ *
+ * The first loop over the zonelist in mm/page_alloc.c:__alloc_pages()
+ * calls here with __GFP_HARDWALL always set in gfp_mask, enforcing
+ * hardwall cpusets - no allocation on a node outside the cpuset is
+ * allowed (unless in interrupt, of course).
+ *
+ * The second loop doesn't even call here for GFP_ATOMIC requests
+ * (if the __alloc_pages() local variable 'wait' is set).  That check
+ * and the checks below have the combined affect in the second loop of
+ * the __alloc_pages() routine that:
+ *	in_interrupt - any node ok (current task context irrelevant)
+ *	GFP_ATOMIC   - any node ok
+ *	GFP_KERNEL   - any node in enclosing mem_exclusive cpuset ok
+ *	GFP_USER     - only nodes in current tasks mems allowed ok.
+ **/
+int cpuset_zone_allowed(struct zone *z, unsigned int __nocast gfp_mask)
+{
+	int node;			/* node that zone z is on */
+	const struct cpuset *cs;	/* current cpuset ancestors */
+	int allowed = 1;		/* is allocation in zone z allowed? */
+
+	if (in_interrupt())
+		return 1;
+	node = z->zone_pgdat->node_id;
+	if (node_isset(node, current->mems_allowed))
+		return 1;
+	if (gfp_mask & __GFP_HARDWALL)	/* If hardwall request, stop here */
+		return 0;
+
+	/* Not hardwall and node outside mems_allowed: scan up cpusets */
+	down(&cpuset_sem);
+	cs = current->cpuset;
+	if (!cs)
+		goto done;		/* current task exiting */
+	cs = nearest_exclusive_ancestor(cs);
+	allowed = node_isset(node, cs->mems_allowed);
+done:
+	up(&cpuset_sem);
+	return allowed;
 }
 
 /*
Index: linux-2.6-mem_exclusive/mm/vmscan.c
===================================================================
--- linux-2.6-mem_exclusive.orig/mm/vmscan.c	2005-07-02 17:40:04.000000000 -0700
+++ linux-2.6-mem_exclusive/mm/vmscan.c	2005-07-02 17:43:15.000000000 -0700
@@ -890,7 +890,7 @@ shrink_caches(struct zone **zones, struc
 		if (zone->present_pages == 0)
 			continue;
 
-		if (!cpuset_zone_allowed(zone))
+		if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
 			continue;
 
 		zone->temp_priority = sc->priority;
@@ -938,7 +938,7 @@ int try_to_free_pages(struct zone **zone
 	for (i = 0; zones[i] != NULL; i++) {
 		struct zone *zone = zones[i];
 
-		if (!cpuset_zone_allowed(zone))
+		if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
 			continue;
 
 		zone->temp_priority = DEF_PRIORITY;
@@ -984,7 +984,7 @@ out:
 	for (i = 0; zones[i] != 0; i++) {
 		struct zone *zone = zones[i];
 
-		if (!cpuset_zone_allowed(zone))
+		if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
 			continue;
 
 		zone->prev_priority = zone->temp_priority;
@@ -1254,7 +1254,7 @@ void wakeup_kswapd(struct zone *zone, in
 		return;
 	if (pgdat->kswapd_max_order < order)
 		pgdat->kswapd_max_order = order;
-	if (!cpuset_zone_allowed(zone))
+	if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
 		return;
 	if (!waitqueue_active(&zone->zone_pgdat->kswapd_wait))
 		return;

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
