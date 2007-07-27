From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:44:40 -0400
Message-Id: <20070727194440.18614.95660.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 13/14] Memoryless Nodes:  use "node_memory_map" for cpusets
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 13/14] Memoryless Nodes:  use "node_memory_map" for cpusets - take 4

Against 2.6.22-rc1-mm1 atop Christoph Lameter's memoryless nodes
series

take 2:
+ replaced node_online_map in cpuset_current_mems_allowed()
  with node_states[N_MEMORY]
+ replaced node_online_map in cpuset_init_smp() with
  node_states[N_MEMORY]

take 3:
+ fix up comments and top level cpuset tracking of nodes
  with memory [instead of on-line nodes]

take 4:
+ fix typo in !CPUSETS definition of cpuset_current_mems_allowed()
+ fix up Documentation/cpusets.txt to reflect these changes.

cpusets try to ensure that any node added to a cpuset's 
mems_allowed is on-line and contains memory.  The assumption
was that online nodes contained memory.  Thus, it is possible
to add memoryless nodes to a cpuset and then add tasks to this
cpuset.  This results in continuous series of oom-kill and
apparent system hang.

Change cpusets to use node_states[N_MEMORY] [a.k.a.
node_memory_map] in place of node_online_map when vetting 
memories.  Return error if admin attempts to write a non-empty
mems_allowed node mask containing only memoryless-nodes.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Bob Picco <bob.picco@hp.com>
Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

	Tested on 4-node ppc64 with 2 memoryless nodes. Top cpuset
	(and all subsequent ones) only allow nodes 0 and 1 (the
	nodes with memory).

 Documentation/cpusets.txt |    8 ++++---
 include/linux/cpuset.h    |    2 -
 kernel/cpuset.c           |   51 +++++++++++++++++++++++++++++-----------------
 3 files changed, 39 insertions(+), 22 deletions(-)

Index: Linux/kernel/cpuset.c
===================================================================
--- Linux.orig/kernel/cpuset.c	2007-07-26 12:40:16.000000000 -0400
+++ Linux/kernel/cpuset.c	2007-07-26 12:55:29.000000000 -0400
@@ -307,26 +307,26 @@ static void guarantee_online_cpus(const 
 
 /*
  * Return in *pmask the portion of a cpusets's mems_allowed that
- * are online.  If none are online, walk up the cpuset hierarchy
- * until we find one that does have some online mems.  If we get
- * all the way to the top and still haven't found any online mems,
- * return node_online_map.
+ * are online, with memory.  If none are online with memory, walk
+ * up the cpuset hierarchy until we find one that does have some
+ * online mems.  If we get all the way to the top and still haven't
+ * found any online mems, return node_states[N_MEMORY].
  *
  * One way or another, we guarantee to return some non-empty subset
- * of node_online_map.
+ * of node_states[N_MEMORY].
  *
  * Call with callback_mutex held.
  */
 
 static void guarantee_online_mems(const struct cpuset *cs, nodemask_t *pmask)
 {
-	while (cs && !nodes_intersects(cs->mems_allowed, node_online_map))
+	while (cs && !nodes_intersects(cs->mems_allowed, node_states[N_MEMORY]))
 		cs = cs->parent;
 	if (cs)
-		nodes_and(*pmask, cs->mems_allowed, node_online_map);
+		nodes_and(*pmask, cs->mems_allowed, node_states[N_MEMORY]);
 	else
-		*pmask = node_online_map;
-	BUG_ON(!nodes_intersects(*pmask, node_online_map));
+		*pmask = node_states[N_MEMORY];
+	BUG_ON(!nodes_intersects(*pmask, node_states[N_MEMORY]));
 }
 
 /**
@@ -597,7 +597,7 @@ static int update_nodemask(struct cpuset
 	int retval;
 	struct container_iter it;
 
-	/* top_cpuset.mems_allowed tracks node_online_map; it's read-only */
+	/* top_cpuset.mems_allowed tracks node_states[N_MEMORY]; it's read-only */
 	if (cs == &top_cpuset)
 		return -EACCES;
 
@@ -614,8 +614,21 @@ static int update_nodemask(struct cpuset
 		retval = nodelist_parse(buf, trialcs.mems_allowed);
 		if (retval < 0)
 			goto done;
+		if (!nodes_intersects(trialcs.mems_allowed,
+						node_states[N_MEMORY])) {
+			/*
+			 * error if only memoryless nodes specified.
+			 */
+			retval = -ENOSPC;
+			goto done;
+		}
 	}
-	nodes_and(trialcs.mems_allowed, trialcs.mems_allowed, node_online_map);
+	/*
+	 * Exclude memoryless nodes.  We know that trialcs.mems_allowed
+	 * contains at least one node with memory.
+	 */
+	nodes_and(trialcs.mems_allowed, trialcs.mems_allowed,
+						node_states[N_MEMORY]);
 	oldmem = cs->mems_allowed;
 	if (nodes_equal(oldmem, trialcs.mems_allowed)) {
 		retval = 0;		/* Too easy - nothing to do */
@@ -1356,8 +1369,9 @@ static void guarantee_online_cpus_mems_i
 
 /*
  * The cpus_allowed and mems_allowed nodemasks in the top_cpuset track
- * cpu_online_map and node_online_map.  Force the top cpuset to track
- * whats online after any CPU or memory node hotplug or unplug event.
+ * cpu_online_map and node_states[N_MEMORY].  Force the top cpuset to
+ * track what's online after any CPU or memory node hotplug or unplug
+ * event.
  *
  * To ensure that we don't remove a CPU or node from the top cpuset
  * that is currently in use by a child cpuset (which would violate
@@ -1377,7 +1391,7 @@ static void common_cpu_mem_hotplug_unplu
 
 	guarantee_online_cpus_mems_in_subtree(&top_cpuset);
 	top_cpuset.cpus_allowed = cpu_online_map;
-	top_cpuset.mems_allowed = node_online_map;
+	top_cpuset.mems_allowed = node_states[N_MEMORY];
 
 	mutex_unlock(&callback_mutex);
 	container_unlock();
@@ -1405,8 +1419,9 @@ static int cpuset_handle_cpuhp(struct no
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
- * Keep top_cpuset.mems_allowed tracking node_online_map.
- * Call this routine anytime after you change node_online_map.
+ * Keep top_cpuset.mems_allowed tracking node_states[N_MEMORY].
+ * Call this routine anytime after you change
+ * node_states[N_MEMORY].
  * See also the previous routine cpuset_handle_cpuhp().
  */
 
@@ -1425,7 +1440,7 @@ void cpuset_track_online_nodes(void)
 void __init cpuset_init_smp(void)
 {
 	top_cpuset.cpus_allowed = cpu_online_map;
-	top_cpuset.mems_allowed = node_online_map;
+	top_cpuset.mems_allowed = node_states[N_MEMORY];
 
 	hotcpu_notifier(cpuset_handle_cpuhp, 0);
 }
@@ -1465,7 +1480,7 @@ void cpuset_init_current_mems_allowed(vo
  *
  * Description: Returns the nodemask_t mems_allowed of the cpuset
  * attached to the specified @tsk.  Guaranteed to return some non-empty
- * subset of node_online_map, even if this means going outside the
+ * subset of node_states[N_MEMORY], even if this means going outside the
  * tasks cpuset.
  **/
 
Index: Linux/include/linux/cpuset.h
===================================================================
--- Linux.orig/include/linux/cpuset.h	2007-07-26 12:40:16.000000000 -0400
+++ Linux/include/linux/cpuset.h	2007-07-26 12:55:30.000000000 -0400
@@ -92,7 +92,7 @@ static inline nodemask_t cpuset_mems_all
 	return node_possible_map;
 }
 
-#define cpuset_current_mems_allowed (node_online_map)
+#define cpuset_current_mems_allowed (node_states[N_MEMORY])
 static inline void cpuset_init_current_mems_allowed(void) {}
 static inline void cpuset_update_task_memory_state(void) {}
 #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)
Index: Linux/Documentation/cpusets.txt
===================================================================
--- Linux.orig/Documentation/cpusets.txt	2007-07-25 09:29:48.000000000 -0400
+++ Linux/Documentation/cpusets.txt	2007-07-26 13:02:00.000000000 -0400
@@ -8,6 +8,7 @@ Portions Copyright (c) 2004-2006 Silicon
 Modified by Paul Jackson <pj@sgi.com>
 Modified by Christoph Lameter <clameter@sgi.com>
 Modified by Paul Menage <menage@google.com>
+Modified by Lee Schermerhorn <lee.schermerhorn@hp.com>
 
 CONTENTS:
 =========
@@ -35,7 +36,8 @@ CONTENTS:
 ----------------------
 
 Cpusets provide a mechanism for assigning a set of CPUs and Memory
-Nodes to a set of tasks.
+Nodes to a set of tasks.   In this document "Memory Node" refers to
+an on-line node that contains memory.
 
 Cpusets constrain the CPU and Memory placement of tasks to only
 the resources within a tasks current cpuset.  They form a nested
@@ -207,8 +209,8 @@ and name space for cpusets, with a minim
 The cpus and mems files in the root (top_cpuset) cpuset are
 read-only.  The cpus file automatically tracks the value of
 cpu_online_map using a CPU hotplug notifier, and the mems file
-automatically tracks the value of node_online_map using the
-cpuset_track_online_nodes() hook.
+automatically tracks the value of node_states[N_MEMORY]--i.e.,
+nodes with memory--using the cpuset_track_online_nodes() hook.
 
 
 1.4 What are exclusive cpusets ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
