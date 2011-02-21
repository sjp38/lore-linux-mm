Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 309CE8D0039
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 22:19:24 -0500 (EST)
Message-ID: <4D61DA04.4060007@cn.fujitsu.com>
Date: Mon, 21 Feb 2011 11:20:36 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7ED1.2070601@cn.fujitsu.com> <alpine.DEB.2.00.1102191745180.27722@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1102191745180.27722@chino.kir.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, miaox@cn.fujitsu.com, linux-mm@kvack.org

David Rientjes wrote:
> On Thu, 17 Feb 2011, Li Zefan wrote:
> 
>> Those functions that use NODEMASK_ALLOC() can't propogate errno
>> to users, but will fail silently.
>>
>> Since all of them are called with cgroup_mutex held, here we use
>> a global nodemask_t variable.
>>
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> I like the idea and the comment is explicit enough that we don't need any 
> refcounting to ensure double usage under cgroup_lock.  I think each 
> function should be modified to use cpuset_mems directly, though, instead 
> of defining local variables that indirectly access it which only serves to 
> make this patch smaller.  Then we can ensure that all occurrences of 
> cpuset_mems appear within the lock without being concerned about other 
> references.
> 

Unfortunately, as I looked into the code again I found cpuset_change_nodemask()
is called by other functions that use the global cpuset_mems, so I
think we'd better check the refcnt of cpuset_mems.

How about this:

[PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()

Those functions that use NODEMASK_ALLOC() can't propogate errno
to users, so might fail silently.

Based on the fact that all of them are called with cgroup_mutex
held, we fix this by using a global nodemask.

cpuset_change_nodemask() is an exception, because it's called
by other functions. Here we declare a static nodemask in the
function for its own use.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cpuset.c |   82 +++++++++++++++++++++++++++++++++----------------------
 1 files changed, 49 insertions(+), 33 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 70c9ca2..da620d2 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -79,6 +79,38 @@ int number_of_cpusets __read_mostly;
 struct cgroup_subsys cpuset_subsys;
 struct cpuset;
 
+static nodemask_t cpuset_mems;
+static int cpuset_mems_ref;
+
+/*
+ * In functions that can't propagate errno to users, to avoid declaring a
+ * nodemask_t variable in stack, and avoid using NODEMASK_ALLOC that can
+ * return -ENOMEM, we use a global cpuset_mems.
+ *
+ * It must be used with cgroup_lock held.
+ */
+static nodemask_t *cpuset_static_nodemask(void)
+{
+	WARN_ON(!cgroup_lock_is_held());
+	WARN_ON(cpuset_mems_ref);
+
+	cpuset_mems_ref++;
+	return &cpuset_mems;
+}
+
+/*
+ * Calling cpuset_static_nodemask() should be paired with this function,
+ * so we insure the global nodemask won't be used by more than one user
+ * at the one time.
+ */
+static void cpuset_release_static_nodemask(void)
+{
+	WARN_ON(!cgroup_lock_is_held());
+
+	cpuset_mems_ref--;
+	WARN_ON(!cpuset_mems_ref);
+}
+
 /* See "Frequency meter" comments, below. */
 
 struct fmeter {
@@ -1015,17 +1047,12 @@ static void cpuset_change_nodemask(struct task_struct *p,
 	struct cpuset *cs;
 	int migrate;
 	const nodemask_t *oldmem = scan->data;
-	NODEMASK_ALLOC(nodemask_t, newmems, GFP_KERNEL);
-
-	if (!newmems)
-		return;
+	static nodemask_t newmems;	/* protected by cgroup_mutex */
 
 	cs = cgroup_cs(scan->cg);
-	guarantee_online_mems(cs, newmems);
-
-	cpuset_change_task_nodemask(p, newmems);
+	guarantee_online_mems(cs, &newmems);
 
-	NODEMASK_FREE(newmems);
+	cpuset_change_task_nodemask(p, &newmems);
 
 	mm = get_task_mm(p);
 	if (!mm)
@@ -1096,13 +1123,10 @@ static void update_tasks_nodemask(struct cpuset *cs, const nodemask_t *oldmem,
 static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 			   const char *buf)
 {
-	NODEMASK_ALLOC(nodemask_t, oldmem, GFP_KERNEL);
+	nodemask_t *oldmem = cpuset_static_nodemask();
 	int retval;
 	struct ptr_heap heap;
 
-	if (!oldmem)
-		return -ENOMEM;
-
 	/*
 	 * top_cpuset.mems_allowed tracks node_stats[N_HIGH_MEMORY];
 	 * it's read-only
@@ -1152,7 +1176,7 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 
 	heap_free(&heap);
 done:
-	NODEMASK_FREE(oldmem);
+	cpuset_release_static_nodemask();
 	return retval;
 }
 
@@ -1438,10 +1462,7 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	struct mm_struct *mm;
 	struct cpuset *cs = cgroup_cs(cont);
 	struct cpuset *oldcs = cgroup_cs(oldcont);
-	NODEMASK_ALLOC(nodemask_t, to, GFP_KERNEL);
-
-	if (to == NULL)
-		goto alloc_fail;
+	nodemask_t *to = cpuset_static_nodemask();
 
 	if (cs == &top_cpuset) {
 		cpumask_copy(cpus_attach, cpu_possible_mask);
@@ -1461,18 +1482,17 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 		rcu_read_unlock();
 	}
 
+	cpuset_release_static_nodemask();
+
 	/* change mm; only needs to be done once even if threadgroup */
-	*to = cs->mems_allowed;
 	mm = get_task_mm(tsk);
 	if (mm) {
-		mpol_rebind_mm(mm, to);
+		mpol_rebind_mm(mm, &cs->mems_allowed);
 		if (is_memory_migrate(cs))
-			cpuset_migrate_mm(mm, &oldcs->mems_allowed, to);
+			cpuset_migrate_mm(mm, &oldcs->mems_allowed,
+					  &cs->mems_allowed);
 		mmput(mm);
 	}
-
-alloc_fail:
-	NODEMASK_FREE(to);
 }
 
 /* The various types of files and directories in a cpuset file system */
@@ -2051,10 +2071,7 @@ static void scan_for_empty_cpusets(struct cpuset *root)
 	struct cpuset *cp;	/* scans cpusets being updated */
 	struct cpuset *child;	/* scans child cpusets of cp */
 	struct cgroup *cont;
-	NODEMASK_ALLOC(nodemask_t, oldmems, GFP_KERNEL);
-
-	if (oldmems == NULL)
-		return;
+	nodemask_t *oldmems = cpuset_static_nodemask();
 
 	list_add_tail((struct list_head *)&root->stack_list, &queue);
 
@@ -2090,7 +2107,8 @@ static void scan_for_empty_cpusets(struct cpuset *root)
 			update_tasks_nodemask(cp, oldmems, NULL);
 		}
 	}
-	NODEMASK_FREE(oldmems);
+
+	cpuset_release_static_nodemask();
 }
 
 /*
@@ -2132,19 +2150,18 @@ void cpuset_update_active_cpus(void)
 static int cpuset_track_online_nodes(struct notifier_block *self,
 				unsigned long action, void *arg)
 {
-	NODEMASK_ALLOC(nodemask_t, oldmems, GFP_KERNEL);
-
-	if (oldmems == NULL)
-		return NOTIFY_DONE;
+	nodemask_t *oldmems;
 
 	cgroup_lock();
 	switch (action) {
 	case MEM_ONLINE:
+		oldmems = cpuset_static_nodemask();
 		*oldmems = top_cpuset.mems_allowed;
 		mutex_lock(&callback_mutex);
 		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
 		mutex_unlock(&callback_mutex);
 		update_tasks_nodemask(&top_cpuset, oldmems, NULL);
+		cpuset_release_static_nodemask();
 		break;
 	case MEM_OFFLINE:
 		/*
@@ -2158,7 +2175,6 @@ static int cpuset_track_online_nodes(struct notifier_block *self,
 	}
 	cgroup_unlock();
 
-	NODEMASK_FREE(oldmems);
 	return NOTIFY_OK;
 }
 #endif
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
