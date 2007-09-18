Date: Tue, 18 Sep 2007 15:40:23 -0500
Subject: [PATCH] hotplug cpu: move tasks in empty cpusets to parent
Message-ID: <46F037B7.mailxR21ILE48@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: cpw@sgi.com (Cliff Wickman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch corrects a situation that occurs when one disables all the cpus
in a cpuset.

Currently, the disabled (cpu-less) cpuset inherits the cpus of its parent,
which may overlap its exclusive sibling.
(You will get non-removable cpusets -- "Invalid argument")

Tasks of an empty cpuset should be moved to the cpuset which is the parent
of their current cpuset. Or if the parent cpuset has no cpus, to its
parent, etc.

And the empty cpuset should be removed (if it is flagged notify_on_release).

This patch uses a workqueue thread to call the function that deletes the
cpuset.  That way we avoid the complexity of the cpuset locks.


This is about version 4, of this patch.  It avoids a recursive method that
was first used, and incorporates fixes for locking and notify_on_release
conceptual issues raised by Paul Jackson.

Diffed against 2.6.23-rc3

Signed-off-by: Cliff Wickman <cpw@sgi.com>

---
 kernel/cpuset.c |  210 ++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 180 insertions(+), 30 deletions(-)

Index: linus.070821/kernel/cpuset.c
===================================================================
--- linus.070821.orig/kernel/cpuset.c
+++ linus.070821/kernel/cpuset.c
@@ -53,6 +53,7 @@
 #include <asm/atomic.h>
 #include <linux/mutex.h>
 #include <linux/kfifo.h>
+#include <linux/workqueue.h>
 
 #define CPUSET_SUPER_MAGIC		0x27e0eb
 
@@ -110,6 +111,7 @@ typedef enum {
 	CS_NOTIFY_ON_RELEASE,
 	CS_SPREAD_PAGE,
 	CS_SPREAD_SLAB,
+	CS_RELEASED_RESOURCE,
 } cpuset_flagbits_t;
 
 /* convenient tests for these bits */
@@ -148,6 +150,11 @@ static inline int is_spread_slab(const s
 	return test_bit(CS_SPREAD_SLAB, &cs->flags);
 }
 
+static inline int has_released_a_resource(const struct cpuset *cs)
+{
+	return test_bit(CS_RELEASED_RESOURCE, &cs->flags);
+}
+
 /*
  * Increment this integer everytime any cpuset changes its
  * mems_allowed value.  Users of cpusets can track this generation
@@ -542,7 +549,7 @@ static void cpuset_release_agent(const c
 static void check_for_release(struct cpuset *cs, char **ppathbuf)
 {
 	if (notify_on_release(cs) && atomic_read(&cs->count) == 0 &&
-	    list_empty(&cs->children)) {
+					list_empty(&cs->children)) {
 		char *buf;
 
 		buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
@@ -834,7 +841,8 @@ update_cpu_domains_tree(struct cpuset *r
 
 	while (__kfifo_get(queue, (unsigned char *)&cp, sizeof(cp))) {
 		list_for_each_entry(child, &cp->children, sibling)
-		    __kfifo_put(queue,(unsigned char *)&child,sizeof(child));
+			__kfifo_put(queue, (unsigned char *)&child,
+							sizeof(child));
 		update_cpu_domains(cp);
 	}
 
@@ -1122,7 +1130,7 @@ static int update_flag(cpuset_flagbits_t
 	mutex_unlock(&callback_mutex);
 
 	if (cpu_exclusive_changed)
-                update_cpu_domains_tree(cs);
+		update_cpu_domains_tree(cs);
 	return 0;
 }
 
@@ -1300,6 +1308,7 @@ static int attach_task(struct cpuset *cs
 
 	from = oldcs->mems_allowed;
 	to = cs->mems_allowed;
+	set_bit(CS_RELEASED_RESOURCE, &oldcs->flags);
 
 	mutex_unlock(&callback_mutex);
 
@@ -2030,6 +2039,7 @@ static int cpuset_rmdir(struct inode *un
 	cpuset_d_remove_dir(d);
 	dput(d);
 	number_of_cpusets--;
+	set_bit(CS_RELEASED_RESOURCE, &parent->flags);
 	mutex_unlock(&callback_mutex);
 	if (list_empty(&parent->children))
 		check_for_release(parent, &pathbuf);
@@ -2097,50 +2107,173 @@ out:
 }
 
 /*
+ * Move every task that is a member of cpuset "from" to cpuset "to".
+ *
+ * Called with both manage_sem and callback_sem held
+ */
+static void move_member_tasks_to_cpuset(struct cpuset *from, struct cpuset *to)
+{
+	int moved=0;
+	struct task_struct *g, *tsk;
+
+	read_lock(&tasklist_lock);
+	do_each_thread(g, tsk) {
+		if (tsk->cpuset == from) {
+			moved++;
+			task_lock(tsk);
+			tsk->cpuset = to;
+			task_unlock(tsk);
+		}
+	} while_each_thread(g, tsk);
+	read_unlock(&tasklist_lock);
+	atomic_add(moved, &to->count);
+	atomic_set(&from->count, 0);
+}
+
+/*
  * If common_cpu_mem_hotplug_unplug(), below, unplugs any CPUs
  * or memory nodes, we need to walk over the cpuset hierarchy,
  * removing that CPU or node from all cpusets.  If this removes the
- * last CPU or node from a cpuset, then the guarantee_online_cpus()
- * or guarantee_online_mems() code will use that emptied cpusets
- * parent online CPUs or nodes.  Cpusets that were already empty of
- * CPUs or nodes are left empty.
+ * last CPU or node from a cpuset, then move the tasks in the empty
+ * cpuset to its next-highest non-empty parent.
  *
- * This routine is intentionally inefficient in a couple of regards.
- * It will check all cpusets in a subtree even if the top cpuset of
- * the subtree has no offline CPUs or nodes.  It checks both CPUs and
- * nodes, even though the caller could have been coded to know that
- * only one of CPUs or nodes needed to be checked on a given call.
- * This was done to minimize text size rather than cpu cycles.
+ * Called with both manage_sem and callback_sem held
+ */
+static void remove_tasks_in_empty_cpuset(struct cpuset *cs)
+{
+	struct cpuset *parent;
+
+	/* cs->count is the number of tasks using the cpuset */
+	if (atomic_read(&cs->count) == 0)
+		return;
+
+	/* this cpuset has had member tasks */
+	set_bit(CS_RELEASED_RESOURCE, &cs->flags);
+
+	/*
+	 * Find its next-highest non-empty parent, (top cpuset
+	 * has online cpus, so can't be empty).
+	 */
+	parent = cs->parent;
+	while (cpus_empty(parent->cpus_allowed)) {
+		/*
+		 * this empty cpuset should now be considered to
+		 * have been used, and therefore eligible for
+		 * release when empty (if it is notify_on_release)
+		 */
+		set_bit(CS_RELEASED_RESOURCE, &parent->flags);
+		parent = parent->parent;
+	}
+
+	move_member_tasks_to_cpuset(cs, parent);
+}
+
+/*
+ * Walk the specified cpuset subtree and count the number of empty
+ * notify_on_release cpusets.
+ *
+ * Note that such a notify_on_release cpuset must have had, at some time,
+ * member tasks or cpuset descendants and cpus and memory, before it can
+ * be a candidate for release.
  *
- * Call with both manage_mutex and callback_mutex held.
+ * Call with both manage_sem and callback_sem held so
+ * that this function can modify cpus_allowed and mems_allowed.
+ *
+ * This walk processes the tree from top to bottom, completing one layer
+ * before dropping down to the next.  It always processes a node before
+ * any of its children.
  *
- * Recursive, on depth of cpuset subtree.
+ * Argument "queue" is the fifo queue of cpusets to be walked.
  */
+static int count_releasable_cpusets(const struct cpuset *root,
+							struct kfifo *queue)
+{
+	int count = 0;
+	struct cpuset *cp;	/* scans cpusets being updated */
+	struct cpuset *child;	/* scans child cpusets of cp */
+
+	__kfifo_put(queue, (unsigned char *)&root, sizeof(root));
+
+	while (__kfifo_get(queue, (unsigned char *)&cp, sizeof(cp))) {
+		list_for_each_entry(child, &cp->children, sibling)
+			__kfifo_put(queue, (unsigned char *)&child,
+							sizeof(child));
+		/* Remove offline cpus and mems from this cpuset. */
+		cpus_and(cp->cpus_allowed, cp->cpus_allowed, cpu_online_map);
+		nodes_and(cp->mems_allowed, cp->mems_allowed, node_online_map);
+		if ((cpus_empty(cp->cpus_allowed) ||
+		     nodes_empty(cp->mems_allowed))) {
+		        /* Move tasks from the empty cpuset to a parent */
+			remove_tasks_in_empty_cpuset(cp);
+			if (notify_on_release(cp) &&
+			    has_released_a_resource(cp))
+				/* count the cpuset to be released */
+				count++;
+		}
+	}
+
+	kfifo_free(queue);
+	return count;
+}
 
-static void guarantee_online_cpus_mems_in_subtree(const struct cpuset *cur)
+/*
+ * Walk the specified cpuset subtree and release the empty
+ * notify_on_release cpusets.
+ *
+ * This walk processes the tree from top to bottom, completing one layer
+ * before dropping down to the next.  It always processes a node before
+ * any of its children.
+ */
+static void release_empty_cpusets(const struct cpuset *root)
 {
-	struct cpuset *c;
+	struct cpuset *cp;	/* scans cpusets being updated */
+	struct cpuset *child;	/* scans child cpusets of cp */
+	struct kfifo *queue;	/* fifo queue of cpusets to be updated */
+	char *pathbuf = NULL;
 
-	/* Each of our child cpusets mems must be online */
-	list_for_each_entry(c, &cur->children, sibling) {
-		guarantee_online_cpus_mems_in_subtree(c);
-		if (!cpus_empty(c->cpus_allowed))
-			guarantee_online_cpus(c, &c->cpus_allowed);
-		if (!nodes_empty(c->mems_allowed))
-			guarantee_online_mems(c, &c->mems_allowed);
+	queue = kfifo_alloc(number_of_cpusets * sizeof(cp), GFP_KERNEL, NULL);
+	if (queue == ERR_PTR(-ENOMEM))
+		return;
+
+	__kfifo_put(queue, (unsigned char *)&root, sizeof(root));
+
+	while (__kfifo_get(queue, (unsigned char *)&cp, sizeof(cp))) {
+		list_for_each_entry(child, &cp->children, sibling)
+			__kfifo_put(queue, (unsigned char *)&child,
+							sizeof(child));
+		if ((notify_on_release(cp)) && has_released_a_resource(cp) &&
+			(cpus_empty(cp->cpus_allowed) ||
+			 nodes_empty(cp->mems_allowed))) {
+			check_for_release(cp, &pathbuf);
+			cpuset_release_agent(pathbuf);
+		}
 	}
+
+	kfifo_free(queue);
+	return;
+}
+
+/*
+ * This runs from a workqueue.
+ *
+ * It's job is to remove any notify_on_release cpusets that have no
+ * online cpus.
+ *
+ * The argument is not used.
+ */
+static void remove_empty_cpusets(struct work_struct *p)
+{
+	release_empty_cpusets(&top_cpuset);
+	return;
 }
 
+static DECLARE_WORK(remove_empties_block, remove_empty_cpusets);
+
 /*
  * The cpus_allowed and mems_allowed nodemasks in the top_cpuset track
  * cpu_online_map and node_online_map.  Force the top cpuset to track
  * whats online after any CPU or memory node hotplug or unplug event.
  *
- * To ensure that we don't remove a CPU or node from the top cpuset
- * that is currently in use by a child cpuset (which would violate
- * the rule that cpusets must be subsets of their parent), we first
- * call the recursive routine guarantee_online_cpus_mems_in_subtree().
- *
  * Since there are two callers of this routine, one for CPU hotplug
  * events and one for memory node hotplug events, we could have coded
  * two separate routines here.  We code it as a single common routine
@@ -2149,12 +2282,26 @@ static void guarantee_online_cpus_mems_i
 
 static void common_cpu_mem_hotplug_unplug(void)
 {
+	int cnt=0;
+	struct kfifo *queue;
+
+	/*
+	 * Pre-allocate the fifo queue of cpusets to be walked. You can't
+	 * call memory allocation functions while holding callback_mutex.
+	 */
+	queue = kfifo_alloc(number_of_cpusets * sizeof(struct cpuset *),
+							GFP_KERNEL, NULL);
+	if (queue == ERR_PTR(-ENOMEM))
+		return;
+
 	mutex_lock(&manage_mutex);
 	mutex_lock(&callback_mutex);
 
-	guarantee_online_cpus_mems_in_subtree(&top_cpuset);
 	top_cpuset.cpus_allowed = cpu_online_map;
 	top_cpuset.mems_allowed = node_online_map;
+	cnt = count_releasable_cpusets(&top_cpuset, queue);
+	if (cnt)
+		schedule_work(&remove_empties_block);
 
 	mutex_unlock(&callback_mutex);
 	mutex_unlock(&manage_mutex);
@@ -2303,6 +2450,9 @@ void cpuset_exit(struct task_struct *tsk
 		mutex_lock(&manage_mutex);
 		if (atomic_dec_and_test(&cs->count))
 			check_for_release(cs, &pathbuf);
+		mutex_lock(&callback_mutex);
+		set_bit(CS_RELEASED_RESOURCE, &cs->flags);
+		mutex_unlock(&callback_mutex);
 		mutex_unlock(&manage_mutex);
 		cpuset_release_agent(pathbuf);
 	} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
