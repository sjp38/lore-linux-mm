Subject: [PATCH take2] Memoryless nodes:  use "node_memory_map" for cpuset
	mems_allowed validation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>
	 <20070711182250.005856256@sgi.com>
	 <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 24 Jul 2007 10:15:25 -0400
Message-Id: <1185286525.5649.27.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Memoryless Nodes:  use "node_memory_map" for cpusets - take 2

Against 2.6.22-rc6-mm1 atop Christoph Lameter's memoryless nodes
series

take 2:
+ replaced node_online_map in cpuset_current_mems_allowed()
  with node_states[N_MEMORY]
+ replaced node_online_map in cpuset_init_smp() with
  node_states[N_MEMORY]

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

 include/linux/cpuset.h |    2 +-
 kernel/cpuset.c        |   35 ++++++++++++++++++++++++-----------
 2 files changed, 25 insertions(+), 12 deletions(-)

Index: Linux/kernel/cpuset.c
===================================================================
--- Linux.orig/kernel/cpuset.c	2007-07-20 16:02:01.000000000 -0400
+++ Linux/kernel/cpuset.c	2007-07-24 08:38:38.000000000 -0400
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
@@ -1432,7 +1445,7 @@ void cpuset_track_online_nodes(void)
 void __init cpuset_init_smp(void)
 {
 	top_cpuset.cpus_allowed = cpu_online_map;
-	top_cpuset.mems_allowed = node_online_map;
+	top_cpuset.mems_allowed = node_states[N_MEMORY];
 
 	hotcpu_notifier(cpuset_handle_cpuhp, 0);
 }
Index: Linux/include/linux/cpuset.h
===================================================================
--- Linux.orig/include/linux/cpuset.h	2007-07-13 15:41:45.000000000 -0400
+++ Linux/include/linux/cpuset.h	2007-07-24 08:37:50.000000000 -0400
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
