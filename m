Subject: [RFC][PATCH] Allow Cpuset nodesets to expand under pressure
Message-Id: <20061205114513.4D7A63D675D@localhost>
Date: Tue,  5 Dec 2006 03:45:13 -0800 (PST)
From: menage@google.com (Paul Menage)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, pj@sgi.com, linux-mm@kvack.org
Cc: mbligh@google.com, winget@google.com, rohitseth@google.com, nickpiggin@yahoo.com.au, ckrm-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Allow Cpuset memory nodesets to expand under pressure


Users don't always know how much memory they will really need, or how
to trade off performance against memory (particularly pagecache) usage.

In order to reduce wastage but still allow applications to get memory
when they need it, this patch adds several files to the cpusets
directory to allow additional memory nodes to be allocated to a cpuset
by the kernel if the cpuset's internal memory pressure gets too high.

The following files are added:

- expansion_limit - the maximum size (in bytes) to which this cpuset's
memory set can be expanded

- expansion_pressure - the abstract memory pressure for tasks within
the cpuset, ranging from 0 (no pressure) to 100 (about to go OOM) at
which expansion can occur

- unused_mems (read-only) - the set of memory nodes that are available
to this cpuset and not assigned to the mems set of any of this
cpuset's children; automatically maintained by the system

- expansion_mems - a vector of nodelists that determine which nodes
should be considered as potential expansion nodes, if available, in
priority order

A callback is added from try_to_free_pages() into the cpuset code,
passing a "memory pressure" value representing how hard the VM is
trying to free memory for the current cpuset. If the pressure is
greater than the cpuset's expansion_pressure, and the cpuset's total
assigned memory nodes sum to less than its expansion_limit, then the
elements of the cpuset's expansion_mems will be checked in turn to
find an intersection with the parent's unused_mems. The first such
intersecting node found is used to expand the cpuset's memory nodes.

The expansion_pressure value for a cpuset can be used as a simple
tuning knob to trade off ease of expansion (== greater memory usage)
versus performance, without requiring users to have a deep
understanding of how the VM allocation/reclaim mechanisms work. 


Controversial points about the patch:

- It makes the synchronization rules in cpuset.c more complex;
specifically the rule that you need to take both manage_mutex and
callback_mutex in order to modify a cpuset is no longer true; hence
even while holding manage_mutex, it's necessary to assume that certain
fields (*->mems_generation, *->mems_allowed, cpuset_mems_generation)
can change under you if you're not holding callback_mutex. This
requires race-detection and retry in update_nodemask() and
update_flag().

- During auto-expansion, a cpuset's mems_allowed can change without
invoking the same mempolicy rebinding/migration code as when
explicitly modified by userspace. I don't think that this is a
problem, since expanding a memory set by one node doesn't really cause
a useful migration event anyway. But I may be wrong ...

- The "memory pressure" used by the expansion functions is distinct
from the existing "memory pressure" reported by cpusets via the
flowmeter abstraction. I experimented with using the flowmeter
abstraction to trigger expansion events, but decided that it wasn't
really suitable - it reports the smoothed frequency of recent memory
reclaim events, rather than how hard we're currently trying to find
free memory; since a failure to find free memory results in an OOM
kill for one of the processes in the CPUset, this value doesn't always
show what we need. Perhaps these two concepts of memory pressure could
be combined in some way to give a single memory pressure value that's
appropriate for both uses; alternatively my "expansion_pressure" could
be renamed to something else.

- In an ideal world, the code to pick and allocate an additional node for the
cpuset belongs in userspace; this would require one of:

  - exporting much more state about the VM to userspace along with a
    userspace application that's checking very frequently for potentially
    OOM cpusets (an app allocating memory in busts can go OOM
    incredibly quickly)

  - a new callback mechanism to userspace that's invoked when internal
    memory pressure reaches a certain value, and requires userspace to
    quickly decide and assign a new node to the ailing cpuset, whilst
    avoiding potential deadlocking issues between the userspace
    process that's updating the cpuset and the memory-allocating
    process that's stuck in the callback

Allowing the user to (periodically, as necessary) specify nodemasks
with decreasing priority, along with a pressure threshold and limit,
and letting the kernel use these parameters when running low on memory
for a cpuset, seems like a good split between policy in userspace and
mechanism in the kernel


TODO: update Documentation/cpusets.txt, once any issues have been resolved

Signed-off-by: Paul Menage <menage@google.com>

---
 include/linux/cpuset.h |    7 +
 kernel/cpuset.c        |  323 +++++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c            |   12 +
 3 files changed, 330 insertions(+), 12 deletions(-)

Index: 2.6.19-autoexpand/include/linux/cpuset.h
===================================================================
--- 2.6.19-autoexpand.orig/include/linux/cpuset.h
+++ 2.6.19-autoexpand/include/linux/cpuset.h
@@ -46,6 +46,8 @@ extern int cpuset_excl_nodes_overlap(con
 extern int cpuset_memory_pressure_enabled;
 extern void __cpuset_memory_pressure_bump(void);
 
+extern int cpuset_expand_memset(int pressure, int gfp_mask);
+
 extern struct file_operations proc_cpuset_operations;
 extern char *cpuset_task_status_allowed(struct task_struct *task, char *buffer);
 
@@ -106,6 +108,11 @@ static inline int cpuset_excl_nodes_over
 
 static inline void cpuset_memory_pressure_bump(void) {}
 
+static inline int cpuset_expand_memset(int pressure, int gfp_mask)
+{
+	return 0;
+}
+
 static inline char *cpuset_task_status_allowed(struct task_struct *task,
 							char *buffer)
 {
Index: 2.6.19-autoexpand/kernel/cpuset.c
===================================================================
--- 2.6.19-autoexpand.orig/kernel/cpuset.c
+++ 2.6.19-autoexpand/kernel/cpuset.c
@@ -72,10 +72,14 @@ struct fmeter {
 	spinlock_t lock;	/* guards read or write of above */
 };
 
+#define MAX_EXPANSION_MEM_TIERS 5
+
 struct cpuset {
 	unsigned long flags;		/* "unsigned long" so bitops work */
 	cpumask_t cpus_allowed;		/* CPUs allowed to tasks in cpuset */
 	nodemask_t mems_allowed;	/* Memory Nodes allowed to tasks */
+	int        total_pages;		/* Total memory available */
+	nodemask_t unused_mems;		/* mems_allowed - all child mems */
 
 	/*
 	 * Count is atomic so can incr (fork) or decr (exit) without a lock.
@@ -99,6 +103,15 @@ struct cpuset {
 	int mems_generation;
 
 	struct fmeter fmeter;		/* memory_pressure filter */
+
+	int expansion_pressure;         /* memory pressure (0-100) at
+        				 * which expansion occurs */
+	u64 expansion_limit;		/* limit in pages at which further
+					 * expansion is forbidden */
+
+	/* Memory nodes available for expansion of child cpusets */
+	nodemask_t expansion_mems[MAX_EXPANSION_MEM_TIERS];
+
 };
 
 /* bits in struct cpuset flags field */
@@ -205,6 +218,17 @@ static struct super_block *cpuset_sb;
  * If a task is only holding callback_mutex, then it has read-only
  * access to cpusets.
  *
+ * There is one exception to this rule - whilst holding
+ * callback_mutex, a task may migrate a bit from
+ * cs->parent->unused_mems to cs->mems_allowed/cs->unused_mems. This
+ * allows tasks using auto-expanding memsets to increase their memory
+ * size without needing take the manage_mutex from within the memory
+ * allocator. To handle this, anyone modifying the mems_allowed field
+ * for a cpuset should read cpuset_mems_generation and
+ * cs->mems_allowed initially under callback_mutex, and then do a
+ * final check after aquiring callback_mutex but before making the
+ * change, to ensure that cpuset_mems_generation hasn't changed.
+ *
  * The task_struct fields mems_allowed and mems_generation may only
  * be accessed in the context of that task, so require no locks.
  *
@@ -787,7 +811,7 @@ static int update_cpumask(struct cpuset 
  *
  *    Migrate memory region from one set of nodes to another.
  *
- *    Temporarilly set tasks mems_allowed to target nodes of migration,
+ *    Temporarily set tasks mems_allowed to target nodes of migration,
  *    so that the migration code can allocate pages on these nodes.
  *
  *    Call holding manage_mutex, so our current->cpuset won't change
@@ -831,6 +855,34 @@ static void cpuset_migrate_mm(struct mm_
 	mutex_unlock(&callback_mutex);
 }
 
+/* Update cs->unused_mems to be cs->mems_allowed - the union of all
+ * child mems_allowed masks. Must be called with callback_mutex
+ * held */
+
+static void update_unused_mems(struct cpuset *cs) {
+	struct cpuset *child;
+	cs->unused_mems = cs->mems_allowed;
+	list_for_each_entry(child, &cs->children, sibling) {
+		nodes_andnot(cs->unused_mems, cs->unused_mems,
+			     child->mems_allowed);
+	}
+}
+
+/* Update cs->total_pages to be the sum of the present_pages on all
+ * nodes available to the cpuset. Must be called with callback_mutex
+ * held */
+static void update_total_pages(struct cpuset *cs) {
+	nodemask_t tmp_nodes = cs->mems_allowed;
+	int total_pages = 0;
+	while (!nodes_empty(tmp_nodes)) {
+		int node = first_node(tmp_nodes);
+		node_clear(node, tmp_nodes);
+		if (node_isset(node, node_online_map))
+			total_pages += node_present_pages(node);
+	}
+	cs->total_pages = total_pages;
+}
+
 /*
  * Handle user request to change the 'mems' memory placement
  * of a cpuset.  Needs to validate the request, update the
@@ -855,17 +907,24 @@ static int update_nodemask(struct cpuset
 	int migrate;
 	int fudge;
 	int retval;
+	int generation;
+ again:
+	mutex_lock(&callback_mutex);
+	generation = cpuset_mems_generation;
+	oldmem = cs->mems_allowed;
+	mutex_unlock(&callback_mutex);
 
 	/* top_cpuset.mems_allowed tracks node_online_map; it's read-only */
 	if (cs == &top_cpuset)
 		return -EACCES;
 
+	/* Non-atomically reads cs->mems_allowed, but that's OK since
+	 * we're about to overwrite it in trialcs anyway */
 	trialcs = *cs;
 	retval = nodelist_parse(buf, trialcs.mems_allowed);
 	if (retval < 0)
 		goto done;
 	nodes_and(trialcs.mems_allowed, trialcs.mems_allowed, node_online_map);
-	oldmem = cs->mems_allowed;
 	if (nodes_equal(oldmem, trialcs.mems_allowed)) {
 		retval = 0;		/* Too easy - nothing to do */
 		goto done;
@@ -879,8 +938,16 @@ static int update_nodemask(struct cpuset
 		goto done;
 
 	mutex_lock(&callback_mutex);
+	if (generation != cpuset_mems_generation) {
+		/* We may have raced with an auto-expansion */
+		mutex_unlock(&callback_mutex);
+		goto again;
+	}
 	cs->mems_allowed = trialcs.mems_allowed;
 	cs->mems_generation = cpuset_mems_generation++;
+	update_unused_mems(cs);
+	if (cs->parent) update_unused_mems(cs->parent);
+	update_total_pages(cs);
 	mutex_unlock(&callback_mutex);
 
 	set_cpuset_being_rebound(cs);		/* causes mpol_copy() rebind */
@@ -946,9 +1013,9 @@ static int update_nodemask(struct cpuset
 	for (i = 0; i < n; i++) {
 		struct mm_struct *mm = mmarray[i];
 
-		mpol_rebind_mm(mm, &cs->mems_allowed);
+		mpol_rebind_mm(mm, &trialcs.mems_allowed);
 		if (migrate)
-			cpuset_migrate_mm(mm, &oldmem, &cs->mems_allowed);
+			cpuset_migrate_mm(mm, &oldmem, &trialcs.mems_allowed);
 		mmput(mm);
 	}
 
@@ -960,6 +1027,42 @@ done:
 	return retval;
 }
 
+/* called with manage_mutex held. Splits buf into whitespace-separated
+ * nodelists (up to MAX_EXPANSION_MEM_TIERS) and stores them in
+ * cs->expansion_mems[] */
+static int update_expansionmask(struct cpuset *cs, char *buf)
+{
+	nodemask_t new_mask;
+	int retval = 0;
+	char *nodelist;
+	int i = 0;
+
+	nodemask_t expansion_mems[MAX_EXPANSION_MEM_TIERS];
+
+	while (i < MAX_EXPANSION_MEM_TIERS) {
+		expansion_mems[i] = NODE_MASK_NONE;
+		nodelist = strsep(&buf, " \t\n");
+		if (!nodelist) break;
+		if (!*nodelist) continue;
+
+		retval = nodelist_parse(nodelist, new_mask);
+		if (retval)
+			return retval;
+
+		expansion_mems[i] = new_mask;
+		i++;
+	}
+	if (buf)
+		return -ENOSPC;
+
+	mutex_lock(&callback_mutex);
+	memcpy(cs->expansion_mems, expansion_mems, sizeof(cs->expansion_mems));
+	mutex_unlock(&callback_mutex);
+
+	return retval;
+}
+
+
 /*
  * Call with manage_mutex held.
  */
@@ -988,11 +1091,16 @@ static int update_flag(cpuset_flagbits_t
 {
 	int turning_on;
 	struct cpuset trialcs;
-	int err;
+	int err, mem_exclusive_set;
+	int generation;
 
+ again:
+	mutex_lock(&callback_mutex);
+	generation = cpuset_mems_generation;
+	trialcs = *cs;
+	mutex_unlock(&callback_mutex);
 	turning_on = (simple_strtoul(buf, NULL, 10) != 0);
 
-	trialcs = *cs;
 	if (turning_on)
 		set_bit(bit, &trialcs.flags);
 	else
@@ -1001,7 +1109,14 @@ static int update_flag(cpuset_flagbits_t
 	err = validate_change(cs, &trialcs);
 	if (err < 0)
 		return err;
+	mem_exclusive_set =
+		(!is_mem_exclusive(cs) && is_mem_exclusive(&trialcs));
 	mutex_lock(&callback_mutex);
+	if (mem_exclusive_set && generation != cpuset_mems_generation) {
+		/* We may have raced with an auto-expansion */
+		mutex_unlock(&callback_mutex);
+		goto again;
+	}
 	cs->flags = trialcs.flags;
 	mutex_unlock(&callback_mutex);
 
@@ -1127,6 +1242,11 @@ static int attach_task(struct cpuset *cs
 
 	if (sscanf(pidbuf, "%d", &pid) != 1)
 		return -EIO;
+	/* Here it's safe to access cs->mems_allowed without taking
+	 * callback_mutex - the only change permitted while we hold
+	 * manage_mutex is an expansion event, which can only set a
+	 * single bit in cs->mems_allowed and hence make the
+	 * nodes_empty() call transition from true to false. */
 	if (cpus_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
 		return -ENOSPC;
 
@@ -1216,6 +1336,10 @@ typedef enum {
 	FILE_SPREAD_PAGE,
 	FILE_SPREAD_SLAB,
 	FILE_TASKLIST,
+	FILE_UNUSED_MEMS,
+	FILE_EXPANSION_PRESSURE,
+	FILE_EXPANSION_MEMS,
+	FILE_EXPANSION_LIMIT,
 } cpuset_filetype_t;
 
 static ssize_t cpuset_common_file_write(struct file *file,
@@ -1230,7 +1354,8 @@ static ssize_t cpuset_common_file_write(
 	int retval = 0;
 
 	/* Crude upper limit on largest legitimate cpulist user might write. */
-	if (nbytes > 100 + 6 * max(NR_CPUS, MAX_NUMNODES))
+	if (nbytes > 100 + 6 * max(NR_CPUS,
+				   MAX_NUMNODES * MAX_EXPANSION_MEM_TIERS))
 		return -E2BIG;
 
 	/* +1 for nul-terminator */
@@ -1286,6 +1411,23 @@ static ssize_t cpuset_common_file_write(
 	case FILE_TASKLIST:
 		retval = attach_task(cs, buffer, &pathbuf);
 		break;
+	case FILE_UNUSED_MEMS:
+		retval = -EACCES;
+		break;
+	case FILE_EXPANSION_PRESSURE:
+		mutex_lock(&callback_mutex);
+		cs->expansion_pressure = simple_strtoul(buffer, NULL, 10);
+		mutex_unlock(&callback_mutex);
+		break;
+	case FILE_EXPANSION_LIMIT:
+		mutex_lock(&callback_mutex);
+		cs->expansion_limit =
+			simple_strtoull(buffer, NULL, 10) / PAGE_SIZE;
+		mutex_unlock(&callback_mutex);
+		break;
+	case FILE_EXPANSION_MEMS:
+		retval = update_expansionmask(cs, buffer);
+		break;
 	default:
 		retval = -EINVAL;
 		goto out2;
@@ -1341,15 +1483,15 @@ static int cpuset_sprintf_cpulist(char *
 	return cpulist_scnprintf(page, PAGE_SIZE, mask);
 }
 
-static int cpuset_sprintf_memlist(char *page, struct cpuset *cs)
+static int cpuset_scnprintf_memlist(char *page, size_t size, nodemask_t *m)
 {
 	nodemask_t mask;
 
 	mutex_lock(&callback_mutex);
-	mask = cs->mems_allowed;
+	mask = *m;
 	mutex_unlock(&callback_mutex);
 
-	return nodelist_scnprintf(page, PAGE_SIZE, mask);
+	return nodelist_scnprintf(page, size, mask);
 }
 
 static ssize_t cpuset_common_file_read(struct file *file, char __user *buf,
@@ -1360,19 +1502,20 @@ static ssize_t cpuset_common_file_read(s
 	cpuset_filetype_t type = cft->private;
 	char *page;
 	ssize_t retval = 0;
-	char *s;
+	char *s, *end;
 
 	if (!(page = (char *)__get_free_page(GFP_KERNEL)))
 		return -ENOMEM;
 
 	s = page;
+	end = page + PAGE_SIZE - 1;
 
 	switch (type) {
 	case FILE_CPULIST:
 		s += cpuset_sprintf_cpulist(s, cs);
 		break;
 	case FILE_MEMLIST:
-		s += cpuset_sprintf_memlist(s, cs);
+		s += cpuset_scnprintf_memlist(s, end - s, &cs->mems_allowed);
 		break;
 	case FILE_CPU_EXCLUSIVE:
 		*s++ = is_cpu_exclusive(cs) ? '1' : '0';
@@ -1398,6 +1541,29 @@ static ssize_t cpuset_common_file_read(s
 	case FILE_SPREAD_SLAB:
 		*s++ = is_spread_slab(cs) ? '1' : '0';
 		break;
+	case FILE_UNUSED_MEMS:
+		s += cpuset_scnprintf_memlist(s, PAGE_SIZE, &cs->unused_mems);
+		break;
+	case FILE_EXPANSION_PRESSURE:
+		s += sprintf(s, "%d", cs->expansion_pressure);
+		break;
+	case FILE_EXPANSION_LIMIT:
+		s += sprintf(s, "%lld",
+			     ((u64)cs->expansion_limit) * PAGE_SIZE);
+		break;
+	case FILE_EXPANSION_MEMS: {
+		int i;
+
+		for (i = 0; i < MAX_EXPANSION_MEM_TIERS; i++) {
+			if (nodes_empty(cs->expansion_mems[i])) break;
+
+			if (i && (s < end) )
+				*s++ = '\n';
+			s += cpuset_scnprintf_memlist(s, end - s,
+						      &cs->expansion_mems[i]);
+		}
+		break;
+	}
 	default:
 		retval = -EINVAL;
 		goto out;
@@ -1771,6 +1937,26 @@ static struct cftype cft_spread_slab = {
 	.private = FILE_SPREAD_SLAB,
 };
 
+static struct cftype cft_unused_mems = {
+	.name = "unused_mems",
+	.private = FILE_UNUSED_MEMS,
+};
+
+static struct cftype cft_expansion_pressure = {
+	.name = "expansion_pressure",
+	.private = FILE_EXPANSION_PRESSURE,
+};
+
+static struct cftype cft_expansion_mems = {
+	.name = "expansion_mems",
+	.private = FILE_EXPANSION_MEMS,
+};
+
+static struct cftype cft_expansion_limit = {
+	.name = "expansion_limit",
+	.private = FILE_EXPANSION_LIMIT,
+};
+
 static int cpuset_populate_dir(struct dentry *cs_dentry)
 {
 	int err;
@@ -1795,6 +1981,14 @@ static int cpuset_populate_dir(struct de
 		return err;
 	if ((err = cpuset_add_file(cs_dentry, &cft_tasks)) < 0)
 		return err;
+	if ((err = cpuset_add_file(cs_dentry, &cft_unused_mems)) < 0)
+		return err;
+	if ((err = cpuset_add_file(cs_dentry, &cft_expansion_pressure)) < 0)
+		return err;
+	if ((err = cpuset_add_file(cs_dentry, &cft_expansion_mems)) < 0)
+		return err;
+	if ((err = cpuset_add_file(cs_dentry, &cft_expansion_limit)) < 0)
+		return err;
 	return 0;
 }
 
@@ -1827,11 +2021,16 @@ static long cpuset_create(struct cpuset 
 		set_bit(CS_SPREAD_SLAB, &cs->flags);
 	cs->cpus_allowed = CPU_MASK_NONE;
 	cs->mems_allowed = NODE_MASK_NONE;
+	cs->unused_mems = NODE_MASK_NONE;
+	cs->total_pages = 0;
 	atomic_set(&cs->count, 0);
 	INIT_LIST_HEAD(&cs->sibling);
 	INIT_LIST_HEAD(&cs->children);
 	cs->mems_generation = cpuset_mems_generation++;
 	fmeter_init(&cs->fmeter);
+	cs->expansion_pressure = -1;
+	memset(cs->expansion_mems, 0, sizeof(cs->expansion_mems));
+	cs->expansion_limit = 0;
 
 	cs->parent = parent;
 
@@ -1899,6 +2098,7 @@ static int cpuset_rmdir(struct inode *un
 	cpuset_d_remove_dir(d);
 	dput(d);
 	number_of_cpusets--;
+	update_unused_mems(parent);
 	mutex_unlock(&callback_mutex);
 	if (list_empty(&parent->children))
 		check_for_release(parent, &pathbuf);
@@ -1935,6 +2135,8 @@ int __init cpuset_init(void)
 
 	top_cpuset.cpus_allowed = CPU_MASK_ALL;
 	top_cpuset.mems_allowed = NODE_MASK_ALL;
+	update_total_pages(&top_cpuset);
+	update_unused_mems(&top_cpuset);
 
 	fmeter_init(&top_cpuset.fmeter);
 	top_cpuset.mems_generation = cpuset_mems_generation++;
@@ -2024,6 +2226,8 @@ static void common_cpu_mem_hotplug_unplu
 	guarantee_online_cpus_mems_in_subtree(&top_cpuset);
 	top_cpuset.cpus_allowed = cpu_online_map;
 	top_cpuset.mems_allowed = node_online_map;
+	update_unused_mems(&top_cpuset);
+	update_total_pages(&top_cpuset);
 
 	mutex_unlock(&callback_mutex);
 	mutex_unlock(&manage_mutex);
@@ -2069,6 +2273,8 @@ void __init cpuset_init_smp(void)
 {
 	top_cpuset.cpus_allowed = cpu_online_map;
 	top_cpuset.mems_allowed = node_online_map;
+	update_unused_mems(&top_cpuset);
+	update_total_pages(&top_cpuset);
 
 	hotcpu_notifier(cpuset_handle_cpuhp, 0);
 }
@@ -2544,3 +2750,96 @@ char *cpuset_task_status_allowed(struct 
 	buffer += sprintf(buffer, "\n");
 	return buffer;
 }
+
+static int find_expansion_node(struct cpuset *cs) {
+	struct cpuset *parent;
+	nodemask_t tmp_nodes;
+	int i;
+
+	parent = cs->parent;
+	if (!parent)
+		return -1;
+	if (nodes_empty(parent->unused_mems))
+		return -1;
+	for (i = 0; i < MAX_EXPANSION_MEM_TIERS &&
+		     !nodes_empty(cs->expansion_mems[i]); i++) {
+		nodes_and(tmp_nodes, parent->unused_mems,
+			  cs->expansion_mems[i]);
+		if (!nodes_empty(tmp_nodes)) {
+			return first_node(tmp_nodes);
+		}
+	}
+	return -1;
+}
+
+static inline int can_expand_memset(struct cpuset *cs, int pressure) {
+	/* if expansion isn't configured, don't expand */
+	if (cs->expansion_pressure < 0) return 0;
+	/* if memory pressure isn't high enough, don't expand */
+	if (pressure < cs->expansion_pressure) return 0;
+	/* if we're at the limit, don't expand */
+	if (cs->total_pages >= cs->expansion_limit) return 0;
+	return 1;
+}
+
+/* Callback from try_to_free_pages() to see whether the current cpuset
+ * can/should grow in response to memory pressure */
+int cpuset_expand_memset(int pressure, int gfp_mask) {
+
+	int retval = 0;
+	struct cpuset *cs = NULL;
+	int node;
+	int ok = 1;
+
+	if (!(gfp_mask & __GFP_WAIT)) goto out;
+
+	/* Simple checks before we take the mutex */
+	rcu_read_lock();
+	cs = rcu_dereference(current->cpuset);
+	/* We should take the lock if this CPUset is expandable */
+	ok = can_expand_memset(cs, pressure);
+	/* We should take the lock if this task is out-of-date */
+	ok |= cs->mems_generation != current->cpuset_mems_generation;
+	rcu_read_unlock();
+	if (!ok) return 0;
+
+	/* It looks like we might be able to expand. Grab the lock and
+	 * check again */
+	mutex_lock(&callback_mutex);
+	cs = current->cpuset;
+	if (!nodes_equal(cs->mems_allowed, current->mems_allowed)) {
+		/* Our memset is out of date. Update it, but don't
+		 * update our cpuset_mems_generation, since we've not
+		 * done a full sync. */
+		guarantee_online_mems(cs, &current->mems_allowed);
+	}
+
+	if (!can_expand_memset(cs, pressure))
+		goto unlock;
+
+	node = find_expansion_node(cs);
+	if (node == -1)
+		goto unlock;
+
+	/* Move one bit from our parent's unused_mems to our own
+	 * mems_allowed */
+	node_clear(node, cs->parent->unused_mems);
+	/* Here we're changing cs->mems_allowed without doing the full
+	 * migration and mpol_rebind_mm() dance. But that's OK, since
+	 * we're not really changing the node set, we're expanding it,
+	 * so there wouldn't be any appropriate migration remapping
+	 * behaviour anyway. */
+	node_set(node, cs->mems_allowed);
+	node_set(node, cs->unused_mems);
+	cs->mems_generation = cpuset_mems_generation++;
+	update_total_pages(cs);
+	/* Update the task's mems_allowed. We can't do the full
+	 * cpuset_update_task_memory_state() since that could itself
+	 * try to allocate memory */
+	node_set(node, current->mems_allowed);
+	retval = 1;
+ unlock:
+	mutex_unlock(&callback_mutex);
+ out:
+	return retval;
+}
Index: 2.6.19-autoexpand/mm/vmscan.c
===================================================================
--- 2.6.19-autoexpand.orig/mm/vmscan.c
+++ 2.6.19-autoexpand/mm/vmscan.c
@@ -1058,6 +1058,18 @@ unsigned long try_to_free_pages(struct z
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+		/* See if we can expand the current cpuset's
+		 * nodemask. Translate the current priority value into
+		 * an abstract pressure ranging between 0 (no
+		 * pressure) and 100 (about to OOM) */
+		int pressure = (DEF_PRIORITY - priority) * 100 / DEF_PRIORITY;
+		if (!(current->flags & PF_KSWAPD) &&
+		    cpuset_expand_memset(pressure, gfp_mask)) {
+			/* We successfully allocated a new node. This
+			 * counts as progress. */
+			ret = 1;
+			goto out;
+		}
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
