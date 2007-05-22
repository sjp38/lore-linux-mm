Received: from attica.americas.sgi.com (attica.americas.sgi.com [128.162.236.44])
	by netops-testserver-4.corp.sgi.com (Postfix) with ESMTP id 9906461B49
	for <linux-mm@kvack.org>; Tue, 22 May 2007 13:53:00 -0700 (PDT)
Date: Tue, 22 May 2007 15:53:00 -0500
Subject: [PATCH 1/1] hotplug cpu: cpusets/sched_domain reconciliation
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20070522205300.5D43A371894@attica.americas.sgi.com>
From: cpw@sgi.com (Cliff Wickman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This patch reconciles cpusets and sched_domains that get out of sync
due to hotplug disabling and re-enabling of cpu's.

Here is an example of how the problem can occur:

   system of cpu's 0-31
   create cpuset /x  16-31
   create cpuset /x/y  16-23
   all cpu_exclusive

   disable cpu 17
     x is now    16,18-31
     x/y is now 16,18-23
   enable cpu 17
     x and x/y are unchanged

   to restore the cpusets:
     echo 16-31 > /dev/cpuset/x
     echo 16-23 > /dev/cpuset/x/y

   At the first echo, update_cpu_domains() is called for cpuset x/.

   The system is partitioned between:
	its parent, the root cpuset of 0-31, minus its
				    children (x/ is 16-31): 0-15
        and x/ (16-31), minus its children (x/y/ 16,18-23): 17,24-31

   The sched_domain's for parent 0-15 are updated.
   The sched_domain's for current 17,24-31 are updated.

   But 16 has been untouched.
   As a result, 17's SD points to sched_group_phys[17] which is the only
   sched_group_phys on 17's list.  It points to itself.
   But 16's SD points to sched_group_phys[16], which still points to
   sched_group_phys[17].
   When cpu 16 executes find_busiest_group() it will hang on the non-
   circular sched_group list.
           
This solution is to update the sched_domain's for the cpuset
whose cpu's were changed and, in addition, all its children.
Instead of calling update_cpu_domains(), call update_cpu_domains_tree(),
which calls update_cpu_domains() for every node from the one specified
down to all its children.

The extra sched_domain reconstruction is overhead, but only at the
frequency of administrative change to the cpuset.

There seems to be no administrative procedural work-around.  In the
example above one could not reverse the two echo's and set x/y before
x/.  It is not logical, so not allowed (Permission denied).

Thus the patch to cpuset.c makes the sched_domain's correct.

This patch also includes checks in find_busiest_group() and
find_idlest_group() that break from their loops on a sched_group that
points to itself.  This is needed because cpu's are going through
load balancing before all sched_domains have been reconstructed (see
the example above).

Thus the patch to sched.c prevents the hangs that would otherwise occur
until the sched_domain's are made correct.

Diffed against 2.6.21

Signed-off-by: Cliff Wickman <cpw@sgi.com>

---
 kernel/cpuset.c |   43 +++++++++++++++++++++++++++++++++++++++----
 kernel/sched.c  |   18 ++++++++++++++----
 2 files changed, 53 insertions(+), 8 deletions(-)

Index: linus.070504/kernel/sched.c
===================================================================
--- linus.070504.orig/kernel/sched.c
+++ linus.070504/kernel/sched.c
@@ -1211,11 +1211,14 @@ static inline unsigned long cpu_avg_load
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
@@ -1251,8 +1254,10 @@ find_idlest_group(struct sched_domain *s
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
@@ -2276,7 +2281,8 @@ find_busiest_group(struct sched_domain *
 		   unsigned long *imbalance, enum idle_type idle, int *sd_idle,
 		   cpumask_t *cpus, int *balance)
 {
-	struct sched_group *busiest = NULL, *this = NULL, *group = sd->groups;
+	struct sched_group *busiest = NULL, *this = sd->groups, *group = sd->groups;
+	struct sched_group *self, *prev;
 	unsigned long max_load, avg_load, total_load, this_load, total_pwr;
 	unsigned long max_pull;
 	unsigned long busiest_load_per_task, busiest_nr_running;
@@ -2299,6 +2305,8 @@ find_busiest_group(struct sched_domain *
 	else
 		load_idx = sd->idle_idx;
 
+	prev = group;
+	self = group;
 	do {
 		unsigned long load, group_capacity;
 		int local_group;
@@ -2427,8 +2435,10 @@ find_busiest_group(struct sched_domain *
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
Index: linus.070504/kernel/cpuset.c
===================================================================
--- linus.070504.orig/kernel/cpuset.c
+++ linus.070504/kernel/cpuset.c
@@ -53,6 +53,7 @@
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
 #include <linux/mutex.h>
+#include <linux/kfifo.h>
 
 #define CPUSET_SUPER_MAGIC		0x27e0eb
 
@@ -790,8 +791,8 @@ static void update_cpu_domains(struct cp
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
@@ -809,6 +810,40 @@ static void update_cpu_domains(struct cp
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
 
@@ -836,7 +871,7 @@ static int update_cpumask(struct cpuset 
 	cs->cpus_allowed = trialcs.cpus_allowed;
 	mutex_unlock(&callback_mutex);
 	if (is_cpu_exclusive(cs) && !cpus_unchanged)
-		update_cpu_domains(cs);
+		update_cpu_domains_tree(cs);
 	return 0;
 }
 
@@ -1066,7 +1101,7 @@ static int update_flag(cpuset_flagbits_t
 	mutex_unlock(&callback_mutex);
 
 	if (cpu_exclusive_changed)
-                update_cpu_domains(cs);
+                update_cpu_domains_tree(cs);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
