Received: from estes.americas.sgi.com (estes.americas.sgi.com [128.162.236.10])
	by netops-testserver-4.corp.sgi.com (Postfix) with ESMTP id 179D661B3A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 15:05:18 -0700 (PDT)
Received: from eag09.americas.sgi.com (eag09.americas.sgi.com [128.162.232.15])
	by estes.americas.sgi.com (Postfix) with ESMTP id C761870006F5
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 17:05:17 -0500 (CDT)
Date: Thu, 23 Aug 2007 17:05:17 -0500
From: Cliff Wickman <cpw@sgi.com>
Subject: [PATCH 1/1] cpusets/sched_domain reconciliation
Message-ID: <20070823220517.GA23216@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch reconciles cpusets and sched_domains that get out of sync
due to disabling and re-enabling cpu's.

This is still a problem in the 2.6.23-rc3 kernel.  (and also 2.6.22)

Here is an example of how the problem can occur:

   system of cpu's   0 1 2 3 4 5
   create cpuset /x      2 3 4 5 
   create cpuset /x/y    2 3
   all cpusets are cpu_exclusive

   disable cpu 3
     x is now            2   4 5
     x/y is now          2
   enable cpu 3
     cpusets x and x/y are unchanged

   to restore the cpusets:
     echo 2-5 > /dev/cpuset/x
     echo 2-3 > /dev/cpuset/x/y

   At the first echo, which restores 3 to cpuset x, update_cpu_domains() is
   called for cpuset x/. 
   system of cpu's   0 1 2 3 4 5
   x is now              2 3 4 5
   x/y is now            2

   The system is partitioned between:
	its parent, the root cpuset, minus its child (x/ is 2-5): 0-1
        and x/ (2-5) , minus its child (x/y/ 2): 3-5

   The sched_domain's for parent 0-1 are updated.
   The sched_domain's for current 3-5 are updated.

   But 2 has been untouched.
   As a result, 3's SD points to sched_group_phys[3] which is the only
   sched_group_phys on 3's list.  It points to itself.
   But 2's SD points to sched_group_phys[2], which still points to
   sched_group_phys[3].
   When cpu 2 executes find_busiest_group() it will hang on the non-
   circular sched_group list.
           
cpuset.c:

This solution is to update the sched_domain's for the cpuset
whose cpu's were changed and, in addition, all its children.
Instead of calling update_cpu_domains(), call update_cpu_domains_tree(),
which calls update_cpu_domains() for every node from the one specified
down to all its children.

The extra sched_domain reconstruction is overhead, but only at the
frequency of administrative change to the cpusets.

There seems to be no administrative procedural work-around.  In the
example above one could not reverse the two echo's and set x/y before
x/.  It is not logical, so not allowed (Permission denied).

Thus the patch to cpuset.c makes the sched_domain's correct.

sched.c:

The patch to sched.c prevents the cpu hangs that otherwise occur
until the sched_domain's are made correct.

It puts checks into find_busiest_group() and find_idlest_group()
that break from their loops on a sched_group that points to itself.
This is needed because cpu's are going through load balancing before all
sched_domains have been reconstructed (see the example above).

This is admittedly a kludge. I leave it to the scheduler gurus to recommend
a better way to keep cpus out of the sched_domains while they are
being reconstructed.

Diffed against 2.6.23-rc3

Signed-off-by: Cliff Wickman <cpw@sgi.com>

---
 kernel/cpuset.c |   43 +++++++++++++++++++++++++++++++++++++++----
 kernel/sched.c  |   18 ++++++++++++++----
 2 files changed, 53 insertions(+), 8 deletions(-)

Index: linus.070821/kernel/sched.c
===================================================================
--- linus.070821.orig/kernel/sched.c
+++ linus.070821/kernel/sched.c
@@ -1196,11 +1196,14 @@ static inline unsigned long cpu_avg_load
 static struct sched_group *
 find_idlest_group(struct sched_domain *sd, struct task_struct *p, int this_cpu)
 {
-	struct sched_group *idlest = NULL, *this = NULL, *group = sd->groups;
+	struct sched_group *idlest = NULL, *this = sd->groups, *group = sd->groups;
+	struct sched_group *self, *prev;
 	unsigned long min_load = ULONG_MAX, this_load = 0;
 	int load_idx = sd->forkexec_idx;
 	int imbalance = 100 + (sd->imbalance_pct-100)/2;
 
+	prev = group;
+	self = group;
 	do {
 		unsigned long load, avg_load;
 		int local_group;
@@ -1237,8 +1240,10 @@ find_idlest_group(struct sched_domain *s
 			idlest = group;
 		}
 nextgroup:
+		prev = self;
+		self = group;
 		group = group->next;
-	} while (group != sd->groups);
+	} while (group != sd->groups && group != self && group != prev);
 
 	if (!idlest || 100*this_load < imbalance*min_load)
 		return NULL;
@@ -2288,7 +2293,8 @@ find_busiest_group(struct sched_domain *
 		   unsigned long *imbalance, enum cpu_idle_type idle,
 		   int *sd_idle, cpumask_t *cpus, int *balance)
 {
-	struct sched_group *busiest = NULL, *this = NULL, *group = sd->groups;
+	struct sched_group *busiest = NULL, *this = sd->groups, *group = sd->groups;
+	struct sched_group *self, *prev;
 	unsigned long max_load, avg_load, total_load, this_load, total_pwr;
 	unsigned long max_pull;
 	unsigned long busiest_load_per_task, busiest_nr_running;
@@ -2311,6 +2317,8 @@ find_busiest_group(struct sched_domain *
 	else
 		load_idx = sd->idle_idx;
 
+	prev = group;
+	self = group;
 	do {
 		unsigned long load, group_capacity;
 		int local_group;
@@ -2443,8 +2451,10 @@ find_busiest_group(struct sched_domain *
 		}
 group_next:
 #endif
+		prev = self;
+		self = group;
 		group = group->next;
-	} while (group != sd->groups);
+	} while (group != sd->groups && group != self && group != prev);
 
 	if (!busiest || this_load >= max_load || busiest_nr_running == 0)
 		goto out_balanced;
Index: linus.070821/kernel/cpuset.c
===================================================================
--- linus.070821.orig/kernel/cpuset.c
+++ linus.070821/kernel/cpuset.c
@@ -52,6 +52,7 @@
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
 #include <linux/mutex.h>
+#include <linux/kfifo.h>
 
 #define CPUSET_SUPER_MAGIC		0x27e0eb
 
@@ -789,8 +790,8 @@ static void update_cpu_domains(struct cp
 			return;
 		cspan = CPU_MASK_NONE;
 	} else {
-		if (cpus_empty(pspan))
-			return;
+		/* parent may be empty, but update anyway */
+
 		cspan = cur->cpus_allowed;
 		/*
 		 * Get all cpus from current cpuset's cpus_allowed not part
@@ -808,6 +809,40 @@ static void update_cpu_domains(struct cp
 }
 
 /*
+ * Call update_cpu_domains for cpuset "cur", and for all of its children.
+ *
+ * This walk processes the tree from top to bottom, completing one layer
+ * before dropping down to the next.  It always processes a node before
+ * any of its children.
+ *
+ * Call with manage_mutex held.
+ * Must not be called holding callback_mutex, because we must
+ * not call lock_cpu_hotplug() while holding callback_mutex.
+ */
+static void
+update_cpu_domains_tree(struct cpuset *root)
+{
+	struct cpuset *cp;	/* scans cpusets being updated */
+	struct cpuset *child;	/* scans child cpusets of cp */
+	struct kfifo *queue;	/* fifo queue of cpusets to be updated */
+
+	queue = kfifo_alloc(number_of_cpusets * sizeof(cp), GFP_KERNEL, NULL);
+	if (queue == ERR_PTR(-ENOMEM))
+		return;
+
+	__kfifo_put(queue, (unsigned char *)&root, sizeof(root));
+
+	while (__kfifo_get(queue, (unsigned char *)&cp, sizeof(cp))) {
+		list_for_each_entry(child, &cp->children, sibling)
+		    __kfifo_put(queue,(unsigned char *)&child,sizeof(child));
+		update_cpu_domains(cp);
+	}
+
+	kfifo_free(queue);
+	return;
+}
+
+/*
  * Call with manage_mutex held.  May take callback_mutex during call.
  */
 
@@ -846,7 +881,7 @@ static int update_cpumask(struct cpuset 
 	cs->cpus_allowed = trialcs.cpus_allowed;
 	mutex_unlock(&callback_mutex);
 	if (is_cpu_exclusive(cs) && !cpus_unchanged)
-		update_cpu_domains(cs);
+		update_cpu_domains_tree(cs);
 	return 0;
 }
 
@@ -1087,7 +1122,7 @@ static int update_flag(cpuset_flagbits_t
 	mutex_unlock(&callback_mutex);
 
 	if (cpu_exclusive_changed)
-                update_cpu_domains(cs);
+                update_cpu_domains_tree(cs);
 	return 0;
 }
 
-- 
Cliff Wickman
Silicon Graphics, Inc.
cpw@sgi.com
(651) 683-3824

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
