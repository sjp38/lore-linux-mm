Subject: [PATCH take3] Memoryless nodes:  use "node_memory_map" for cpuset
	mems_allowed validation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>
	 <20070711182250.005856256@sgi.com>
	 <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 24 Jul 2007 16:30:19 -0400
Message-Id: <1185309019.5649.69.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Memoryless Nodes:  use "node_memory_map" for cpusets - take 3

Against 2.6.22-rc6-mm1 atop Christoph Lameter's memoryless nodes
series

take 2:
+ replaced node_online_map in cpuset_current_mems_allowed()
  with node_states[N_MEMORY]
+ replaced node_online_map in cpuset_init_smp() with
  node_states[N_MEMORY]

take 3:
+ fix up comments and top level cpuset tracking of nodes
  with memory [instead of on-line nodes].
+ maybe I got them all this time?

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

 include/linux/cpuset.h |    2 -
 kernel/cpuset.c        |   51 +++++++++++++++++++++++++++++++------------------
 2 files changed, 34 insertions(+), 19 deletions(-)

Index: Linux/kernel/cpuset.c
===================================================================
--- Linux.orig/kernel/cpuset.c	2007-07-24 11:24:56.000000000 -0400
+++ Linux/kernel/cpuset.c	2007-07-24 12:20:40.000000000 -0400
@@ -316,26 +316,26 @@ static void guarantee_online_cpus(const 
 
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
@@ -606,7 +606,7 @@ static int update_nodemask(struct cpuset
 	int retval;
 	struct container_iter it;
 
-	/* top_cpuset.mems_allowed tracks node_online_map; it's read-only */
+	/* top_cpuset.mems_allowed tracks node_states[N_MEMORY]; it's read-only */
 	if (cs == &top_cpuset)
 		return -EACCES;
 
@@ -623,8 +623,21 @@ static int update_nodemask(struct cpuset
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
@@ -1366,8 +1379,9 @@ static void guarantee_online_cpus_mems_i
 
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
@@ -1387,7 +1401,7 @@ static void common_cpu_mem_hotplug_unplu
 
 	guarantee_online_cpus_mems_in_subtree(&top_cpuset);
 	top_cpuset.cpus_allowed = cpu_online_map;
-	top_cpuset.mems_allowed = node_online_map;
+	top_cpuset.mems_allowed = node_states[N_MEMORY];
 
 	mutex_unlock(&callback_mutex);
 	container_unlock();
@@ -1412,8 +1426,9 @@ static int cpuset_handle_cpuhp(struct no
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
- * Keep top_cpuset.mems_allowed tracking node_online_map.
- * Call this routine anytime after you change node_online_map.
+ * Keep top_cpuset.mems_allowed tracking node_states[N_MEMORY].
+ * Call this routine anytime after you change
+ * node_states[N_MEMORY].
  * See also the previous routine cpuset_handle_cpuhp().
  */
 
@@ -1432,7 +1447,7 @@ void cpuset_track_online_nodes(void)
 void __init cpuset_init_smp(void)
 {
 	top_cpuset.cpus_allowed = cpu_online_map;
-	top_cpuset.mems_allowed = node_online_map;
+	top_cpuset.mems_allowed = node_states[N_MEMORY];
 
 	hotcpu_notifier(cpuset_handle_cpuhp, 0);
 }
@@ -1472,7 +1487,7 @@ void cpuset_init_current_mems_allowed(vo
  *
  * Description: Returns the nodemask_t mems_allowed of the cpuset
  * attached to the specified @tsk.  Guaranteed to return some non-empty
- * subset of node_online_map, even if this means going outside the
+ * subset of node_states[N_MEMORY], even if this means going outside the
  * tasks cpuset.
  **/
 
Index: Linux/include/linux/cpuset.h
===================================================================
--- Linux.orig/include/linux/cpuset.h	2007-07-24 11:24:56.000000000 -0400
+++ Linux/include/linux/cpuset.h	2007-07-24 12:20:56.000000000 -0400
@@ -92,7 +92,7 @@ static inline nodemask_t cpuset_mems_all
 	return node_possible_map;
 }
 
-#define cpuset_current_mems_allowed (node_online_map)
+#define cpuset_current_mems_allowed (node_states[N_MEMORY))
 static inline void cpuset_init_current_mems_allowed(void) {}
 static inline void cpuset_update_task_memory_state(void) {}
 #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
