Message-Id: <20080305080000.432133000@menage.corp.google.com>
References: <20080305075237.608599000@menage.corp.google.com>
Date: Tue, 04 Mar 2008 23:52:39 -0800
From: menage@google.com
Subject: [PATCH 2/2] Cpuset hardwall flag:  Add a mem_hardwall flag to cpusets
Content-Disposition: inline; filename=hardwall.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pj@sgi.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This flag provides the hardwalling properties of mem_exclusive,
without enforcing the exclusivity. Either mem_hardwall or
mem_exclusive is sufficient to prevent GFP_KERNEL allocations from
passing outside the cpuset's assigned nodes.

Signed-off-by: Paul Menage <menage@google.com>

---
 Documentation/cpusets.txt |   26 +++++++++++++-----------
 kernel/cpuset.c           |   48 ++++++++++++++++++++++++++++++----------------
 2 files changed, 46 insertions(+), 28 deletions(-)

Index: hardwall-2.6.25-rc3-mm1/kernel/cpuset.c
===================================================================
--- hardwall-2.6.25-rc3-mm1.orig/kernel/cpuset.c
+++ hardwall-2.6.25-rc3-mm1/kernel/cpuset.c
@@ -124,6 +124,7 @@ struct cpuset_hotplug_scanner {
 typedef enum {
 	CS_CPU_EXCLUSIVE,
 	CS_MEM_EXCLUSIVE,
+	CS_MEM_HARDWALL,
 	CS_MEMORY_MIGRATE,
 	CS_SCHED_LOAD_BALANCE,
 	CS_SPREAD_PAGE,
@@ -141,6 +142,11 @@ static inline int is_mem_exclusive(const
 	return test_bit(CS_MEM_EXCLUSIVE, &cs->flags);
 }
 
+static inline int is_mem_hardwall(const struct cpuset *cs)
+{
+	return test_bit(CS_MEM_HARDWALL, &cs->flags);
+}
+
 static inline int is_sched_load_balance(const struct cpuset *cs)
 {
 	return test_bit(CS_SCHED_LOAD_BALANCE, &cs->flags);
@@ -1002,12 +1008,9 @@ int current_cpuset_is_being_rebound(void
 
 /*
  * update_flag - read a 0 or a 1 in a file and update associated flag
- * bit:	the bit to update (CS_CPU_EXCLUSIVE, CS_MEM_EXCLUSIVE,
- *				CS_SCHED_LOAD_BALANCE,
- *				CS_NOTIFY_ON_RELEASE, CS_MEMORY_MIGRATE,
- *				CS_SPREAD_PAGE, CS_SPREAD_SLAB)
- * cs:	the cpuset to update
- * buf:	the buffer where we read the 0 or 1
+ * bit:		the bit to update (see cpuset_flagbits_t)
+ * cs:		the cpuset to update
+ * turning_on: 	whether the flag is being set or cleared
  *
  * Call with cgroup_mutex held.
  */
@@ -1188,6 +1191,7 @@ typedef enum {
 	FILE_MEMLIST,
 	FILE_CPU_EXCLUSIVE,
 	FILE_MEM_EXCLUSIVE,
+	FILE_MEM_HARDWALL,
 	FILE_SCHED_LOAD_BALANCE,
 	FILE_MEMORY_PRESSURE_ENABLED,
 	FILE_MEMORY_PRESSURE,
@@ -1268,6 +1272,9 @@ static int cpuset_write_u64(struct cgrou
 	case FILE_MEM_EXCLUSIVE:
 		retval = update_flag(CS_MEM_EXCLUSIVE, cs, val);
 		break;
+	case FILE_MEM_HARDWALL:
+		retval = update_flag(CS_MEM_HARDWALL, cs, val);
+		break;
 	case FILE_SCHED_LOAD_BALANCE:
 		retval = update_flag(CS_SCHED_LOAD_BALANCE, cs, val);
 		break;
@@ -1375,6 +1382,8 @@ static u64 cpuset_read_u64(struct cgroup
 		return is_cpu_exclusive(cs);
 	case FILE_MEM_EXCLUSIVE:
 		return is_mem_exclusive(cs);
+	case FILE_MEM_HARDWALL:
+		return is_mem_hardwall(cs);
 	case FILE_SCHED_LOAD_BALANCE:
 		return is_sched_load_balance(cs);
 	case FILE_MEMORY_MIGRATE:
@@ -1427,6 +1436,13 @@ static struct cftype files[] = {
 	},
 
 	{
+		.name = "mem_hardwall",
+		.read_u64 = cpuset_read_u64,
+		.write_u64 = cpuset_write_u64,
+		.private = FILE_MEM_HARDWALL,
+	},
+
+	{
 		.name = "sched_load_balance",
 		.read_u64 = cpuset_read_u64,
 		.write_u64 = cpuset_write_u64,
@@ -1913,14 +1929,14 @@ int cpuset_nodemask_valid_mems_allowed(n
 }
 
 /*
- * nearest_exclusive_ancestor() - Returns the nearest mem_exclusive
- * ancestor to the specified cpuset.  Call holding callback_mutex.
- * If no ancestor is mem_exclusive (an unusual configuration), then
- * returns the root cpuset.
+ * nearest_hardwall_ancestor() - Returns the nearest mem_exclusive or
+ * mem_hardwall ancestor to the specified cpuset.  Call holding
+ * callback_mutex.  If no ancestor is mem_exclusive or mem_hardwall
+ * (an unusual configuration), then returns the root cpuset.
  */
-static const struct cpuset *nearest_exclusive_ancestor(const struct cpuset *cs)
+static const struct cpuset *nearest_hardwall_ancestor(const struct cpuset *cs)
 {
-	while (!is_mem_exclusive(cs) && cs->parent)
+	while (!(is_mem_exclusive(cs) || is_mem_hardwall(cs)) && cs->parent)
 		cs = cs->parent;
 	return cs;
 }
@@ -1934,7 +1950,7 @@ static const struct cpuset *nearest_excl
  * __GFP_THISNODE is set, yes, we can always allocate.  If zone
  * z's node is in our tasks mems_allowed, yes.  If it's not a
  * __GFP_HARDWALL request and this zone's nodes is in the nearest
- * mem_exclusive cpuset ancestor to this tasks cpuset, yes.
+ * hardwalled cpuset ancestor to this tasks cpuset, yes.
  * If the task has been OOM killed and has access to memory reserves
  * as specified by the TIF_MEMDIE flag, yes.
  * Otherwise, no.
@@ -1957,7 +1973,7 @@ static const struct cpuset *nearest_excl
  * and do not allow allocations outside the current tasks cpuset
  * unless the task has been OOM killed as is marked TIF_MEMDIE.
  * GFP_KERNEL allocations are not so marked, so can escape to the
- * nearest enclosing mem_exclusive ancestor cpuset.
+ * nearest enclosing hardwalled ancestor cpuset.
  *
  * Scanning up parent cpusets requires callback_mutex.  The
  * __alloc_pages() routine only calls here with __GFP_HARDWALL bit
@@ -1980,7 +1996,7 @@ static const struct cpuset *nearest_excl
  *	in_interrupt - any node ok (current task context irrelevant)
  *	GFP_ATOMIC   - any node ok
  *	TIF_MEMDIE   - any node ok
- *	GFP_KERNEL   - any node in enclosing mem_exclusive cpuset ok
+ *	GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
  *	GFP_USER     - only nodes in current tasks mems allowed ok.
  *
  * Rule:
@@ -2017,7 +2033,7 @@ int __cpuset_zone_allowed_softwall(struc
 	mutex_lock(&callback_mutex);
 
 	task_lock(current);
-	cs = nearest_exclusive_ancestor(task_cs(current));
+	cs = nearest_hardwall_ancestor(task_cs(current));
 	task_unlock(current);
 
 	allowed = node_isset(node, cs->mems_allowed);
Index: hardwall-2.6.25-rc3-mm1/Documentation/cpusets.txt
===================================================================
--- hardwall-2.6.25-rc3-mm1.orig/Documentation/cpusets.txt
+++ hardwall-2.6.25-rc3-mm1/Documentation/cpusets.txt
@@ -169,6 +169,7 @@ files describing that cpuset:
  - memory_migrate flag: if set, move pages to cpusets nodes
  - cpu_exclusive flag: is cpu placement exclusive?
  - mem_exclusive flag: is memory placement exclusive?
+ - mem_hardwall flag:  is memory allocation hardwalled
  - memory_pressure: measure of how much paging pressure in cpuset
 
 In addition, the root cpuset only has the following file:
@@ -220,17 +221,18 @@ If a cpuset is cpu or mem exclusive, no 
 a direct ancestor or descendent, may share any of the same CPUs or
 Memory Nodes.
 
-A cpuset that is mem_exclusive restricts kernel allocations for
-page, buffer and other data commonly shared by the kernel across
-multiple users.  All cpusets, whether mem_exclusive or not, restrict
-allocations of memory for user space.  This enables configuring a
-system so that several independent jobs can share common kernel data,
-such as file system pages, while isolating each jobs user allocation in
-its own cpuset.  To do this, construct a large mem_exclusive cpuset to
-hold all the jobs, and construct child, non-mem_exclusive cpusets for
-each individual job.  Only a small amount of typical kernel memory,
-such as requests from interrupt handlers, is allowed to be taken
-outside even a mem_exclusive cpuset.
+A cpuset that is mem_exclusive *or* mem_hardwall is "hardwalled",
+i.e. it restricts kernel allocations for page, buffer and other data
+commonly shared by the kernel across multiple users.  All cpusets,
+whether hardwalled or not, restrict allocations of memory for user
+space.  This enables configuring a system so that several independent
+jobs can share common kernel data, such as file system pages, while
+isolating each job's user allocation in its own cpuset.  To do this,
+construct a large mem_exclusive cpuset to hold all the jobs, and
+construct child, non-mem_exclusive cpusets for each individual job.
+Only a small amount of typical kernel memory, such as requests from
+interrupt handlers, is allowed to be taken outside even a
+mem_exclusive cpuset.
 
 
 1.5 What is memory_pressure ?
@@ -639,7 +641,7 @@ Now you want to do something with this c
 
 In this directory you can find several files:
 # ls
-cpus  cpu_exclusive  mems  mem_exclusive  tasks
+cpus  cpu_exclusive  mems  mem_exclusive mem_hardwall  tasks
 
 Reading them will give you information about the state of this cpuset:
 the CPUs and Memory Nodes it can use, the processes that are using

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
