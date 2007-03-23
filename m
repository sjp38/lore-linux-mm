Message-ID: <460362B7.1070700@yahoo.com.au>
Date: Fri, 23 Mar 2007 16:16:39 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Subject: [PATCH RESEND 1/1] cpusets/sched_domain reconciliation
References: <20070322231559.GA22656@sgi.com>	<46033311.1000101@yahoo.com.au> <20070322204720.cd3a51c9.pj@sgi.com> <4603504A.1000805@yahoo.com.au>
In-Reply-To: <4603504A.1000805@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------040305000202000506030108"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Paul Jackson <pj@sgi.com>, cpw@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040305000202000506030108
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

> All that aside, I think we can probably do without cpus_exclusive
> entirely (for sched-domains), and automatically detect a correct
> set of partitions. I remember leaving that as an exercise for the
> reader ;) but I think I've got some renewed energy, so I might
> try tackling it.

OK, something like this patch should automatically carve up the
sched-domains into an optimal set of partitions based solely on
the state of tasks in the system.

The downsides are that it is going to a very expensive operation,
and also that it would need to be called at task exit time in
order to never lose updates.

However, the same algorithm can be implemented using the cpusets
topology instead of cpus_allowed, and it will be much cheaper
(and cpusets already has a task exit hook).

Hmm, there will be still some problems with kernel thread like
pdflush in the root cpuset, preventing the partitioning to be
actually activated...

-- 
SUSE Labs, Novell Inc.

--------------040305000202000506030108
Content-Type: text/plain;
 name="sched-domains-cpusets-fixes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sched-domains-cpusets-fixes.patch"

Index: linux-2.6/kernel/cpuset.c
===================================================================
--- linux-2.6.orig/kernel/cpuset.c	2007-02-27 20:14:11.000000000 +1100
+++ linux-2.6/kernel/cpuset.c	2007-03-23 16:02:41.000000000 +1100
@@ -754,61 +754,6 @@ static int validate_change(const struct 
 }
 
 /*
- * For a given cpuset cur, partition the system as follows
- * a. All cpus in the parent cpuset's cpus_allowed that are not part of any
- *    exclusive child cpusets
- * b. All cpus in the current cpuset's cpus_allowed that are not part of any
- *    exclusive child cpusets
- * Build these two partitions by calling partition_sched_domains
- *
- * Call with manage_mutex held.  May nest a call to the
- * lock_cpu_hotplug()/unlock_cpu_hotplug() pair.
- * Must not be called holding callback_mutex, because we must
- * not call lock_cpu_hotplug() while holding callback_mutex.
- */
-
-static void update_cpu_domains(struct cpuset *cur)
-{
-	struct cpuset *c, *par = cur->parent;
-	cpumask_t pspan, cspan;
-
-	if (par == NULL || cpus_empty(cur->cpus_allowed))
-		return;
-
-	/*
-	 * Get all cpus from parent's cpus_allowed not part of exclusive
-	 * children
-	 */
-	pspan = par->cpus_allowed;
-	list_for_each_entry(c, &par->children, sibling) {
-		if (is_cpu_exclusive(c))
-			cpus_andnot(pspan, pspan, c->cpus_allowed);
-	}
-	if (!is_cpu_exclusive(cur)) {
-		cpus_or(pspan, pspan, cur->cpus_allowed);
-		if (cpus_equal(pspan, cur->cpus_allowed))
-			return;
-		cspan = CPU_MASK_NONE;
-	} else {
-		if (cpus_empty(pspan))
-			return;
-		cspan = cur->cpus_allowed;
-		/*
-		 * Get all cpus from current cpuset's cpus_allowed not part
-		 * of exclusive children
-		 */
-		list_for_each_entry(c, &cur->children, sibling) {
-			if (is_cpu_exclusive(c))
-				cpus_andnot(cspan, cspan, c->cpus_allowed);
-		}
-	}
-
-	lock_cpu_hotplug();
-	partition_sched_domains(&pspan, &cspan);
-	unlock_cpu_hotplug();
-}
-
-/*
  * Call with manage_mutex held.  May take callback_mutex during call.
  */
 
@@ -835,8 +780,6 @@ static int update_cpumask(struct cpuset 
 	mutex_lock(&callback_mutex);
 	cs->cpus_allowed = trialcs.cpus_allowed;
 	mutex_unlock(&callback_mutex);
-	if (is_cpu_exclusive(cs) && !cpus_unchanged)
-		update_cpu_domains(cs);
 	return 0;
 }
 
@@ -1064,9 +1007,6 @@ static int update_flag(cpuset_flagbits_t
 	mutex_lock(&callback_mutex);
 	cs->flags = trialcs.flags;
 	mutex_unlock(&callback_mutex);
-
-	if (cpu_exclusive_changed)
-                update_cpu_domains(cs);
 	return 0;
 }
 
@@ -1931,17 +1871,6 @@ static int cpuset_mkdir(struct inode *di
 	return cpuset_create(c_parent, dentry->d_name.name, mode | S_IFDIR);
 }
 
-/*
- * Locking note on the strange update_flag() call below:
- *
- * If the cpuset being removed is marked cpu_exclusive, then simulate
- * turning cpu_exclusive off, which will call update_cpu_domains().
- * The lock_cpu_hotplug() call in update_cpu_domains() must not be
- * made while holding callback_mutex.  Elsewhere the kernel nests
- * callback_mutex inside lock_cpu_hotplug() calls.  So the reverse
- * nesting would risk an ABBA deadlock.
- */
-
 static int cpuset_rmdir(struct inode *unused_dir, struct dentry *dentry)
 {
 	struct cpuset *cs = dentry->d_fsdata;
@@ -1961,13 +1890,7 @@ static int cpuset_rmdir(struct inode *un
 		mutex_unlock(&manage_mutex);
 		return -EBUSY;
 	}
-	if (is_cpu_exclusive(cs)) {
-		int retval = update_flag(CS_CPU_EXCLUSIVE, cs, "0");
-		if (retval < 0) {
-			mutex_unlock(&manage_mutex);
-			return retval;
-		}
-	}
+
 	parent = cs->parent;
 	mutex_lock(&callback_mutex);
 	set_bit(CS_REMOVED, &cs->flags);
Index: linux-2.6/kernel/sched.c
===================================================================
--- linux-2.6.orig/kernel/sched.c	2007-03-22 20:48:52.000000000 +1100
+++ linux-2.6/kernel/sched.c	2007-03-23 16:06:00.000000000 +1100
@@ -4600,6 +4600,8 @@ cpumask_t nohz_cpu_mask = CPU_MASK_NONE;
  * 7) we wake up and the migration is done.
  */
 
+static void autopartition_sched_domains(void);
+
 /*
  * Change a given task's CPU affinity. Migrate the thread to a
  * proper CPU and schedule it away if the CPU it's executing on
@@ -4623,6 +4625,7 @@ int set_cpus_allowed(struct task_struct 
 	}
 
 	p->cpus_allowed = new_mask;
+
 	/* Can the task run on the task's current CPU? If so, we're done */
 	if (cpu_isset(task_cpu(p), new_mask))
 		goto out;
@@ -4637,6 +4640,7 @@ int set_cpus_allowed(struct task_struct 
 	}
 out:
 	task_rq_unlock(rq, &flags);
+	autopartition_sched_domains();
 
 	return ret;
 }
@@ -6328,29 +6332,106 @@ static void detach_destroy_domains(const
 
 /*
  * Partition sched domains as specified by the cpumasks below.
- * This attaches all cpus from the cpumasks to the NULL domain,
+ * This attaches all cpus from the partition to the NULL domain,
  * waits for a RCU quiescent period, recalculates sched
- * domain information and then attaches them back to the
- * correct sched domains
- * Call with hotplug lock held
+ * domain information and then attaches them back to their own
+ * isolated partition.
+ *
+ * Called with hotplug lock held
+ *
+ * Returns 0 on success.
  */
-int partition_sched_domains(cpumask_t *partition1, cpumask_t *partition2)
+int partition_sched_domains(const cpumask_t *partition)
 {
-	cpumask_t change_map;
-	int err = 0;
+	cpumask_t cpu_offline_map;
 
-	cpus_and(*partition1, *partition1, cpu_online_map);
-	cpus_and(*partition2, *partition2, cpu_online_map);
-	cpus_or(change_map, *partition1, *partition2);
+	if (cpus_intersects(*partition, cpu_isolated_map) &&
+			cpus_weight(*partition) != 1) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+
+	cpus_complement(cpu_offline_map, cpu_online_map);
+	if (cpus_intersects(*partition, cpu_offline_map)) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
 
 	/* Detach sched domains from all of the affected cpus */
-	detach_destroy_domains(&change_map);
-	if (!cpus_empty(*partition1))
-		err = build_sched_domains(partition1);
-	if (!err && !cpus_empty(*partition2))
-		err = build_sched_domains(partition2);
+	detach_destroy_domains(partition);
 
-	return err;
+	return build_sched_domains(partition);
+}
+
+struct domain_partition {
+	struct list_head list;
+	cpumask_t cpumask;
+};
+
+static DEFINE_MUTEX(autopartition_mutex);
+static void autopartition_sched_domains(void)
+{
+	LIST_HEAD(cover);
+	cpumask_t span;
+	struct task_struct *p;
+	struct domain_partition *dp, *tmp;
+
+	mutex_lock(&autopartition_mutex);
+	cpus_clear(span);
+
+	/*
+	 * Need to build the disjoint covering set of unions of overlapping
+	 * task cpumasks. This gives us the best possible sched-domains
+	 * partition.
+	 */
+	/* XXX: note this would need to be called at task exit to always
+	 * provide a perfect partition. This is probably going to be much
+	 * easier if driven from cpusets.
+	 */
+	read_lock(&tasklist_lock);
+	for_each_process(p) {
+
+		cpumask_t c = p->cpus_allowed;
+		if (!cpus_intersects(span, c)) {
+add_new_partition:
+			dp = kmalloc(sizeof(struct domain_partition), GFP_ATOMIC);
+			if (!dp)
+				panic("XXX: should preallocate these\n");
+			INIT_LIST_HEAD(&dp->list);
+			dp->cpumask = c;
+
+			list_add(&dp->list, &cover);
+			cpus_or(span, span, c);
+		} else {
+			cpumask_t newcov = c;
+			list_for_each_entry_safe(dp, tmp, &cover, list) {
+				if (cpus_intersects(c, dp->cpumask)) {
+					cpus_or(newcov, newcov, dp->cpumask);
+					list_del(&dp->list);
+					kfree(dp);
+				}
+			}
+			c = newcov;
+			goto add_new_partition;
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	detach_destroy_domains(&cpu_online_map);
+
+	cpus_clear(span);
+	list_for_each_entry_safe(dp, tmp, &cover, list) {
+		BUG_ON(cpus_intersects(span, dp->cpumask));
+		cpus_or(span, span, dp->cpumask);
+
+		build_sched_domains(&dp->cpumask);
+
+		list_del(&dp->list);
+		kfree(dp);
+	}
+	BUG_ON(!list_empty(&cover));
+
+	mutex_unlock(&autopartition_mutex);
 }
 
 #if defined(CONFIG_SCHED_MC) || defined(CONFIG_SCHED_SMT)
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h	2007-03-22 20:45:18.000000000 +1100
+++ linux-2.6/include/linux/sched.h	2007-03-23 15:19:43.000000000 +1100
@@ -729,8 +729,7 @@ struct sched_domain {
 #endif
 };
 
-extern int partition_sched_domains(cpumask_t *partition1,
-				    cpumask_t *partition2);
+extern int partition_sched_domains(const cpumask_t *partition);
 
 /*
  * Maximum cache size the migration-costs auto-tuning code will

--------------040305000202000506030108--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
